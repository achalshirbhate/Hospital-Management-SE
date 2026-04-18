import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/websocket_service.dart';
import 'dart:async';

class VideoCallScreen extends StatefulWidget {
  final int tokenId;
  final int userId;
  final String userName;
  final String? scheduledTime;

  const VideoCallScreen({
    super.key,
    required this.tokenId,
    required this.userId,
    required this.userName,
    this.scheduledTime,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _getUserMedia();
    await _createPeerConnection();
    _listenToWebSocket();
  }

  Future<void> _getUserMedia() async {
    try {
      final mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      setState(() {});
    } catch (e) {
      debugPrint('❌ Error getting user media: $e');
      _showError('Failed to access camera/microphone');
    }
  }

  Future<void> _createPeerConnection() async {
    try {
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      // Add local stream tracks
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      // Handle remote stream
      _peerConnection?.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams[0];
          setState(() => _isConnected = true);
        }
      };

      // Handle ICE candidates
      _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
        WebSocketService.instance.send({
          'type': 'ice-candidate',
          'tokenId': widget.tokenId,
          'candidate': candidate.toMap(),
        });
      };

      // Handle connection state
      _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('🔗 Connection state: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          setState(() => _isConnected = true);
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          setState(() => _isConnected = false);
        }
      };

      // Create and send offer
      await _createOffer();
    } catch (e) {
      debugPrint('❌ Error creating peer connection: $e');
      _showError('Failed to establish connection');
    }
  }

  Future<void> _createOffer() async {
    try {
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      WebSocketService.instance.send({
        'type': 'video-offer',
        'tokenId': widget.tokenId,
        'offer': offer.toMap(),
      });
    } catch (e) {
      debugPrint('❌ Error creating offer: $e');
    }
  }

  void _listenToWebSocket() {
    _wsSubscription = WebSocketService.instance.messages.listen((message) async {
      final type = message['type'] as String?;
      
      if (message['tokenId'] != widget.tokenId) return;

      switch (type) {
        case 'video-answer':
          final answer = RTCSessionDescription(
            message['answer']['sdp'] as String,
            message['answer']['type'] as String,
          );
          await _peerConnection?.setRemoteDescription(answer);
          break;

        case 'ice-candidate':
          final candidate = RTCIceCandidate(
            message['candidate']['candidate'] as String,
            message['candidate']['sdpMid'] as String,
            message['candidate']['sdpMLineIndex'] as int,
          );
          await _peerConnection?.addCandidate(candidate);
          break;

        case 'video-terminated':
          _showTerminatedDialog();
          break;
      }
    });
  }

  void _toggleMute() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = _isMuted;
      setState(() => _isMuted = !_isMuted);
    }
  }

  void _toggleVideo() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = _isVideoOff;
      setState(() => _isVideoOff = !_isVideoOff);
    }
  }

  void _terminateCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Call?'),
        content: const Text('Are you sure you want to end this video consultation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              WebSocketService.instance.send({
                'type': 'video-terminate',
                'tokenId': widget.tokenId,
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('End Call', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTerminatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Call Ended'),
        content: const Text('The video consultation has been terminated.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📹 Video Consultation', style: TextStyle(fontSize: 16)),
            if (widget.scheduledTime != null)
              Text(
                widget.scheduledTime!,
                style: const TextStyle(fontSize: 12, color: AppColors.cyan),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Remote video (main)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  if (_isConnected)
                    RTCVideoView(_remoteRenderer, mirror: false)
                  else
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Waiting for other party...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  // Connection status
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isConnected ? AppColors.success : AppColors.warning,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isConnected ? '● Connected' : '● Connecting...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Local video (small)
          Container(
            height: 200,
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: RTCVideoView(_localRenderer, mirror: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? 'Unmute' : 'Mute',
                  onPressed: _toggleMute,
                  color: _isMuted ? AppColors.danger : Colors.white,
                ),
                _ControlButton(
                  icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                  label: _isVideoOff ? 'Video On' : 'Video Off',
                  onPressed: _toggleVideo,
                  color: _isVideoOff ? AppColors.danger : Colors.white,
                ),
                _ControlButton(
                  icon: Icons.call_end,
                  label: 'End Call',
                  onPressed: _terminateCall,
                  color: AppColors.danger,
                  isLarge: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isLarge;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(isLarge ? 35 : 30),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(isLarge ? 35 : 30),
            child: Container(
              width: isLarge ? 70 : 60,
              height: isLarge ? 70 : 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: isLarge ? 32 : 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
