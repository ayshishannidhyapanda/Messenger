package com.messenger.config;

/*
 * Copyright (c) 2026 Ayshi Shannidhya Panda. All rights reserved.
 *
 * This source code is confidential and intended solely for internal use.
 * Unauthorized copying, modification, distribution, or disclosure of this
 * file, via any medium, is strictly prohibited.
 *
 * Project: Messenger
 * Author: Ayshi Shannidhya Panda
 * Created on: 13-03-2026
 */

import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NonNull;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

import java.security.Principal;

@Component
@Slf4j
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    @Override
    public Message<?> preSend(@NonNull Message<?> message, @NonNull MessageChannel channel) {

        log.info("INVOKED INTERCEPTOR");
        StompHeaderAccessor accessor =
                MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor == null || accessor.getCommand() == null) {
            return message;
        }

        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            Principal principal = accessor.getUser();

            if (principal == null) {
                log.warn("Rejecting unauthenticated WebSocket CONNECT for sessionId: {}", accessor.getSessionId());
                throw new AccessDeniedException("Authentication is required for WebSocket connections");
            }

            log.info("WebSocket CONNECT accepted for user: {}",
                    principal.getName());
        }

        if (StompCommand.SEND.equals(accessor.getCommand()) || StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            Principal principal = accessor.getUser();
            if (principal == null) {
                log.warn("Rejecting unauthenticated WebSocket {} for destination: {}",
                        accessor.getCommand(), accessor.getDestination());
                throw new AccessDeniedException("Authentication is required for WebSocket messaging");
            }

            log.info("WebSocket {} - user: {}, destination: {}, sessionId: {}",
                    accessor.getCommand(),
                    principal.getName(),
                    accessor.getDestination(),
                    accessor.getSessionId());
        }

        return message;
    }
}
