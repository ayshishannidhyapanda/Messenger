package com.messenger.config;

import com.messenger.dto.ChatMessageDto;
import org.junit.jupiter.api.Test;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.access.AccessDeniedException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class WebSocketMessagingRegressionTest {

    private static final MessageChannel TEST_CHANNEL = new MessageChannel() {
        @Override
        public boolean send(Message<?> message) {
            return true;
        }

        @Override
        public boolean send(Message<?> message, long timeout) {
            return true;
        }
    };

    @Test
    void chatMessageDtoHasNoArgsConstructorForInboundJsonBinding() {
        boolean hasNoArgsConstructor = true;

        try {
            ChatMessageDto.class.getDeclaredConstructor();
        } catch (NoSuchMethodException ex) {
            hasNoArgsConstructor = false;
        }

        assertTrue(hasNoArgsConstructor);
    }

    @Test
    void authenticatedConnectKeepsPrincipalForUserQueues() {
        WebSocketAuthInterceptor interceptor = new WebSocketAuthInterceptor();

        StompHeaderAccessor accessor = StompHeaderAccessor.create(StompCommand.CONNECT);
        accessor.setUser(() -> "8658472229");
        accessor.setLeaveMutable(true);

        Message<byte[]> message = MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());
        Message<?> intercepted = interceptor.preSend(message, TEST_CHANNEL);
        StompHeaderAccessor interceptedAccessor =
                MessageHeaderAccessor.getAccessor(intercepted, StompHeaderAccessor.class);

        assertNotNull(interceptedAccessor);
        assertNotNull(interceptedAccessor.getUser());
        assertEquals("8658472229", interceptedAccessor.getUser().getName());
    }

    @Test
    void unauthenticatedConnectIsRejected() {
        WebSocketAuthInterceptor interceptor = new WebSocketAuthInterceptor();

        StompHeaderAccessor accessor = StompHeaderAccessor.create(StompCommand.CONNECT);
        accessor.setLeaveMutable(true);

        Message<byte[]> message = MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());

        assertThrows(AccessDeniedException.class, () -> interceptor.preSend(message, TEST_CHANNEL));
    }
}
