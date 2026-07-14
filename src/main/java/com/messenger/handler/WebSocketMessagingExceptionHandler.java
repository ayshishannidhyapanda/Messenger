package com.messenger.handler;

import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Controller;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Controller
@Slf4j
public class WebSocketMessagingExceptionHandler {

    @MessageExceptionHandler(UsernameNotFoundException.class)
    @SendToUser("/queue/errors")
    public Map<String, Object> handleUsernameNotFound(UsernameNotFoundException ex) {
        log.error("WebSocket message failed: {}", ex.getMessage(), ex);
        return errorBody("USER_NOT_FOUND", ex.getMessage());
    }

    @MessageExceptionHandler(IllegalArgumentException.class)
    @SendToUser("/queue/errors")
    public Map<String, Object> handleIllegalArgument(IllegalArgumentException ex) {
        log.error("WebSocket message failed: {}", ex.getMessage(), ex);
        return errorBody("BAD_REQUEST", ex.getMessage());
    }

    @MessageExceptionHandler(Exception.class)
    @SendToUser("/queue/errors")
    public Map<String, Object> handleGenericException(Exception ex) {
        log.error("Unhandled WebSocket message failure", ex);
        return errorBody("INTERNAL_ERROR",
                ex.getMessage() != null ? ex.getMessage() : ex.getClass().getSimpleName());
    }

    private Map<String, Object> errorBody(String code, String message) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("code", code);
        body.put("message", message);
        return body;
    }
}
