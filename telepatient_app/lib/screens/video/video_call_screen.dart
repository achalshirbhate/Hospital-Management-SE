import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../utils/constants.dart';

/// WebRTC video call screen.
/// Uses the backend WebSocket signaling server at /ws/video.
/// Room ID = tokenId (string).
class VideoCallScreen extends StatefulWidget {
  final int tokenId;

  const VideoCallScreen({
    super.key,
    required this.tokenId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // ─── WebRTC ────────────────────────────────────────────────────────────────
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final _localRenderer  = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  // ─── WebSocket ─────────────────────────────────────────────────────────────
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _connected    = false;
  bool _peerJoined   = false;
  bool _callEnded    = false;
  bool _micMuted     = false;
  bool _camOff       = false;
  String _status     = 'Connecting...';

  // ICE server config (STUN only for local testing)
  final Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _startLocalStream();
    _connectSignaling();
  }

  Future<void> _startLocalStream() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _localStream = stream;
    _localRenderer.srcObject = stream;
    if (mounted) setState(() {});
  }

  void _connectSignaling() {
    _channel = WebSocketChannel.connect(
        Uri.parse(AppConstants.wsVideoUrl));
    _wsSub = _channel!.stream.listen(
      _onSignalingMessage,
      onDone: () {
        if (mounted) setState(() => _status = 'Disconnected');
      },
      onError: (_) {
        if (mounted) setState(() => _status = 'Connection error');
      },
    );
    // Join the room
    _send({'type': 'join', 'roomId': widget.tokenId.toString()});
    if (mounted) setState(() { _connected = true; _status = 'Waiting for peer...'; });
  }

  void _send(Map<String, dynamic> msg) {
    _channel?.sink.add(jsonEncode(msg));
  }

  Future<void> _onSignalingMessage(dynamic raw) async {
    final msg = jsonDecode(raw as String) as Map<String, dynamic>;
    final type = msg['type'] as String?;

    switch (type) {
      case 'peer-joined':
        // We are the caller — create offer
        setState(() { _peerJoined = true; _status = 'Peer joined, connecting...'; });
        await _createPeerConnection();
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        _send({'type': 'offer', 'roomId': widget.tokenId.toString(),
               'sdp': offer.sdp, 'sdpType': offer.type});
        break;

      case 'offer':
        // We are the callee — answer the offer
        setState(() { _peerJoined = true; _status = 'Incoming call...'; });
        await _createPeerConnection();
        await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(msg['sdp'], msg['sdpType']));
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        _send({'type': 'answer', 'roomId': widget.tokenId.toString(),
               'sdp': answer.sdp, 'sdpType': answer.type});
        break;

      case 'answer':
        await _peerConnection?.setRemoteDescription(
            RTCSessionDescription(msg['sdp'], msg['sdpType']));
        break;

      case 'candidate':
        await _peerConnection?.addCandidate(RTCIceCandidate(
            msg['candidate'], msg['sdpMid'], msg['sdpMLineIndex']));
        break;

      case 'peer-left':
        setState(() { _status = 'Peer disconnected'; _callEnded = true; });
        break;
    }
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceConfig);

    // Add local tracks
    _localStream?.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // ICE candidates
    _peerConnection!.onIceCandidate = (candidate) {
      _send({
        'type': 'candidate',
        'roomId': widget.tokenId.toString(),
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    // Remote stream
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
          _status = 'Connected';
        });
      }
    };

    _peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() => _status = 'Connected');
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
                 state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        setState(() { _status = 'Call ended'; _callEnded = true; });
      }
    };
  }

  void _toggleMic() {
    _localStream?.getAudioTracks().forEach((t) {
      t.enabled = _micMuted;
    });
    setState(() => _micMuted = !_micMuted);
  }

  void _toggleCam() {
    _localStream?.getVideoTracks().forEach((t) {
      t.enabled = _camOff;
    });
    setState(() => _camOff = !_camOff);
  }

  Future<void> _endCall() async {
    await _peerConnection?.close();
    _localStream?.dispose();
    _channel?.sink.close();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _channel?.sink.close();
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // ── Remote video (full screen) ──────────────────────────────────────
        Positioned.fill(
          child: _peerJoined && _remoteStream != null
              ? RTCVideoView(_remoteRenderer, objectFit:
                    RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off,
                          color: Colors.white54, size: 64),
                      const SizedBox(height: 16),
                      Text(_status,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
        ),

        // ── Local video (picture-in-picture) ────────────────────────────────
        Positioned(
          top: 48,
          right: 16,
          width: 100,
          height: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _localStream != null
                ? RTCVideoView(_localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit
                        .RTCVideoViewObjectFitCover)
                : Container(color: Colors.grey.shade800),
          ),
        ),

        // ── Status bar ───────────────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_status,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
              ]),
            ),
          ),
        ),

        // ── Call controls ────────────────────────────────────────────────────
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: _micMuted ? Icons.mic_off : Icons.mic,
                color: _micMuted ? Colors.red : Colors.white,
                onTap: _toggleMic,
              ),
              const SizedBox(width: 20),
              // End call
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end,
                      color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 20),
              _ControlButton(
                icon: _camOff ? Icons.videocam_off : Icons.videocam,
                color: _camOff ? Colors.red : Colors.white,
                onTap: _toggleCam,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ControlButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
