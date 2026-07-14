package com.messenger.controller;

/*
 * Copyright (c) 2026 Ayshi Shannidhya Panda. All rights reserved.
 *
 * This source code is confidential and intended solely for internal use.
 * Unauthorized copying, modification, distribution, or disclosure of this
 * file, via any medium, is strictly prohibited.
 *
 * Project: Messenger
 * Author: Ayshi Shannidhya Panda
 * Created on: 15-03-2026
 */

import com.messenger.dto.ChatMessageDto;
import com.messenger.service.ChatService;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.Principal;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

@RestController
@RequestMapping("/v1")
@RequiredArgsConstructor
@Slf4j
public class ChatController {

    private final ChatService chatService;
    private final Validator validator;
    private final SimpMessageSendingOperations messagingTemplate;

    @MessageMapping("/chat.private")
    public void sendPrivateChat(
            @Header("senderPhone") String senderPhone,
            @Header("receiverPhone") String receiverPhone,
            @Payload ChatMessageDto chatMessage,
            SimpMessageHeaderAccessor accessor,
            Principal principal
    ) {
        log.info("INVOKED CONTROLLER - senderPhone: {}, receiverPhone: {}, principal: {}",
                senderPhone, receiverPhone, principal != null ? principal.getName() : "null");

        Set<ConstraintViolation<ChatMessageDto>> violations = validator.validate(chatMessage);

        if (!violations.isEmpty()) {
            // send error back to user
            String userId = Objects.requireNonNull(accessor.getUser()).getName();
            messagingTemplate.convertAndSendToUser(userId, "/queue/errors",
                    Map.of("error", "Validation failed",
                            "details", violations.stream()
                                    .map(v -> v.getPropertyPath() + ": " + v.getMessage())
                                    .toList())
            );
            return;
        }

        chatService.sendPrivateMessage(senderPhone, receiverPhone, chatMessage, principal);
    }

    @MessageExceptionHandler(UsernameNotFoundException.class)
    @SendToUser("/queue/errors")
    public Map<String, Object> handleUserNotFound(UsernameNotFoundException ex) {
        log.error("WebSocket chat failed: {}", ex.getMessage(), ex);
        return errorBody("USER_NOT_FOUND", ex.getMessage());
    }

    private Map<String, Object> errorBody(String code, String message) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("code", code);
        body.put("message", message);
        return body;
    }

    @MessageExceptionHandler(IllegalArgumentException.class)
    @SendToUser("/queue/errors")
    public Map<String, Object> handleIllegalArgument(IllegalArgumentException ex) {
        log.error("WebSocket chat failed: {}", ex.getMessage(), ex);
        return errorBody("BAD_REQUEST", ex.getMessage());
    }

    @MessageExceptionHandler(Exception.class)
    @SendToUser("/queue/errors")
    public Map<String, Object> handleGenericException(Exception ex) {
        log.error("Unhandled WebSocket chat failure", ex);
        return errorBody("INTERNAL_ERROR",
                ex.getMessage() != null ? ex.getMessage() : ex.getClass().getSimpleName());
    }
}
