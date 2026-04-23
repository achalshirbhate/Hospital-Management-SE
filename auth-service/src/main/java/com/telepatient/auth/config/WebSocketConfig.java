package com.telepatient.auth.config;

import com.telepatient.auth.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

@Configuration
@EnableWebSocket
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketConfigurer {

    private final VideoSignalingHandler signalingHandler;
    private final JwtUtil jwtUtil;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(signalingHandler, "/ws/video")
                .addInterceptors(jwtHandshakeInterceptor())
                .setAllowedOriginPatterns("*");
    }

    private HandshakeInterceptor jwtHandshakeInterceptor() {
        return new HandshakeInterceptor() {
            @Override
            public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                           WebSocketHandler wsHandler, Map<String, Object> attributes) {
                String query = request.getURI().getQuery();
                if (query != null && query.contains("token=")) {
                    String token = query.split("token=")[1].split("&")[0];
                    if (jwtUtil.isTokenValid(token)) {
                        attributes.put("userId", jwtUtil.extractUserId(token));
                        attributes.put("role",   jwtUtil.extractRole(token));
                        return true;
                    }
                    return false; // reject unauthenticated WS
                }
                return false;
            }

            @Override
            public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response,
                                       WebSocketHandler wsHandler, Exception exception) {}
        };
    }
}
