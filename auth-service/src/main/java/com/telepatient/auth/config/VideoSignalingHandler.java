package com.telepatient.auth.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket signaling server for WebRTC video calls.
 * Rooms are keyed by tokenId. Each room holds up to 2 peers.
 */
@Component
public class VideoSignalingHandler extends TextWebSocketHandler {

    // roomId (tokenId) -> list of sessions in that room
    private final Map<String, Map<String, WebSocketSession>> rooms = new ConcurrentHashMap<>();
    // sessionId -> roomId
    private final Map<String, String> sessionRoom = new ConcurrentHashMap<>();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        // Room join happens on first message
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        Map<String, Object> payload = mapper.readValue(message.getPayload(), Map.class);
        String type = (String) payload.get("type");
        String roomId = (String) payload.get("roomId");

        if ("join".equals(type)) {
            rooms.computeIfAbsent(roomId, k -> new ConcurrentHashMap<>()).put(session.getId(), session);
            sessionRoom.put(session.getId(), roomId);
            // Notify others in room that someone joined
            broadcastToOthers(session, roomId, mapper.writeValueAsString(Map.of("type", "peer-joined")));
            return;
        }

        // Forward offer / answer / candidate to the other peer in the room
        if (roomId != null) {
            broadcastToOthers(session, roomId, message.getPayload());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String roomId = sessionRoom.remove(session.getId());
        if (roomId != null) {
            Map<String, WebSocketSession> room = rooms.get(roomId);
            if (room != null) {
                room.remove(session.getId());
                if (room.isEmpty()) rooms.remove(roomId);
                else broadcastToOthers(session, roomId, "{\"type\":\"peer-left\"}");
            }
        }
    }

    private void broadcastToOthers(WebSocketSession sender, String roomId, String msg) {
        Map<String, WebSocketSession> room = rooms.get(roomId);
        if (room == null) return;
        room.forEach((id, ws) -> {
            if (!id.equals(sender.getId()) && ws.isOpen()) {
                try { ws.sendMessage(new TextMessage(msg)); } catch (Exception ignored) {}
            }
        });
    }
}
