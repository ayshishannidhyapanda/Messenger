import { useState, useEffect, useRef, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';
import * as chatSocket from '../services/chatSocket';
import * as e2ee from '../services/e2ee';
import Sidebar from '../components/Sidebar';
import ChatView from '../components/ChatView';
import EmptyChat from '../components/EmptyChat';
import NewChatModal from '../components/NewChatModal';
import './ChatScreen.css';

export default function ChatScreen() {
  const { user, logoutUser } = useAuth();
  const [connectionStatus, setConnectionStatus] = useState('disconnected');
  const [conversations, setConversations] = useState(() => {
    return JSON.parse(localStorage.getItem('conversations') || '[]');
  });
  const [activeChat, setActiveChat] = useState(null);
  const [messages, setMessages] = useState({});
  const [onlineUsers, setOnlineUsers] = useState(new Set());
  const [showNewChat, setShowNewChat] = useState(false);
  const [sidebarVisible, setSidebarVisible] = useState(true);
  const [encryptedChats, setEncryptedChats] = useState(new Set()); // phones with E2EE
  const messagesRef = useRef(messages);
  messagesRef.current = messages;

  // Persist conversations
  useEffect(() => {
    localStorage.setItem('conversations', JSON.stringify(conversations));
  }, [conversations]);

  // Generate E2EE key pair on mount
  useEffect(() => {
    if (user?.mobNumber) {
      e2ee.generateKeyPair(user.mobNumber).catch(console.error);
    }
  }, [user]);

  // Check which contacts already have shared keys
  useEffect(() => {
    async function checkKeys() {
      const encrypted = new Set();
      for (const conv of conversations) {
        if (await e2ee.hasSharedKey(user.mobNumber, conv.phone)) {
          encrypted.add(conv.phone);
        }
      }
      setEncryptedChats(encrypted);
    }
    if (user?.mobNumber && conversations.length > 0) {
      checkKeys();
    }
  }, [conversations, user]);

  // Connect WebSocket
  useEffect(() => {
    const unsubs = [];

    unsubs.push(chatSocket.onConnection((status) => {
      setConnectionStatus(status);
    }));

    unsubs.push(chatSocket.onMessage((body) => {
      handleIncomingMessage(body);
    }));

    unsubs.push(chatSocket.onPresence((data) => {
      if (data.type === 'ONLINE' && data.userId) {
        setOnlineUsers((prev) => new Set([...prev, data.userId]));
      } else if (data.type === 'OFFLINE' && data.userId) {
        setOnlineUsers((prev) => {
          const next = new Set(prev);
          next.delete(data.userId);
          return next;
        });
      }
    }));

    unsubs.push(chatSocket.onError((err) => {
      console.error('[Chat] Error:', err);
    }));

    chatSocket.connect();

    return () => {
      unsubs.forEach((u) => u());
      chatSocket.disconnect();
    };
  }, []);

  const handleIncomingMessage = useCallback(async (body) => {
    if (body.messageType) {
      const msg = {
        id: body.id || Date.now(),
        sender: body.sender,
        receiver: body.receiver,
        message: body.message,
        messageType: body.messageType,
        isRead: body.isRead,
        isReceived: body.isReceived,
        timestamp: Date.now(),
        encrypted: false,
      };

      const otherPhone = msg.sender === user.mobNumber ? msg.receiver : msg.sender;

      // Handle key exchange messages
      if (e2ee.isKeyExchangeMessage(msg.message)) {
        const pubKey = e2ee.extractPublicKey(msg.message);
        if (pubKey) {
          const ok = await e2ee.processReceivedPublicKey(user.mobNumber, otherPhone, pubKey);
          if (ok) {
            console.log('[E2EE] Key exchange complete with', otherPhone);
            setEncryptedChats((prev) => new Set([...prev, otherPhone]));
            // Send our key back so the other side can also derive
            const ourKeyMsg = await e2ee.createKeyExchangeMessage(user.mobNumber);
            chatSocket.sendPrivateMessage({
              senderPhone: user.mobNumber,
              receiverPhone: otherPhone,
              message: ourKeyMsg,
              messageType: 'TEXT',
            });
          }
        }
        // Don't show key exchange messages in the chat
        return;
      }

      // Decrypt E2EE messages
      if (e2ee.isEncryptedMessage(msg.message)) {
        msg.message = await e2ee.decryptMessage(user.mobNumber, otherPhone, msg.message);
        msg.encrypted = true;
      }

      addMessageToConversation(otherPhone, msg);

    } else if (body.chats && Array.isArray(body.chats)) {
      const person1 = body.person1;
      const person2 = body.person2;
      const otherPhone = person1?.mobNumber === user.mobNumber
        ? person2?.mobNumber
        : person1?.mobNumber;

      if (otherPhone) {
        const otherPerson = person1?.mobNumber === user.mobNumber ? person2 : person1;
        ensureConversation(otherPhone, otherPerson?.firstName, otherPerson?.lastName);

        for (const chat of body.chats) {
          let messageText = chat.message;
          let isEncrypted = false;

          if (e2ee.isKeyExchangeMessage(messageText)) continue; // Skip key exchanges

          if (e2ee.isEncryptedMessage(messageText)) {
            messageText = await e2ee.decryptMessage(user.mobNumber, otherPhone, messageText);
            isEncrypted = true;
          }

          const msg = {
            id: chat.id || Date.now(),
            sender: chat.sender,
            receiver: chat.receiver,
            message: messageText,
            messageType: chat.messageType,
            timestamp: Date.now(),
            encrypted: isEncrypted,
          };
          addMessageToConversation(otherPhone, msg);
        }
      }
    }
  }, [user]);

  const ensureConversation = (phone, firstName, lastName) => {
    setConversations((prev) => {
      const exists = prev.find((c) => c.phone === phone);
      if (exists) return prev;
      return [
        {
          phone,
          name: firstName && lastName ? `${firstName} ${lastName}` : phone,
          lastMessage: '',
          time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          unread: 0,
        },
        ...prev,
      ];
    });
  };

  const addMessageToConversation = (phone, msg) => {
    ensureConversation(phone);

    setMessages((prev) => {
      const existing = prev[phone] || [];
      if (msg.id && existing.some((m) => m.id === msg.id)) return prev;
      return { ...prev, [phone]: [...existing, msg] };
    });

    setConversations((prev) =>
      prev.map((c) =>
        c.phone === phone
          ? {
              ...c,
              lastMessage: msg.message || '📎 File',
              time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
              unread: (c.unread || 0) + (msg.sender !== user.mobNumber ? 1 : 0),
            }
          : c
      )
    );
  };

  const sendMessage = async (text) => {
    if (!activeChat || !text.trim()) return;

    // Try to encrypt the message
    let messageToSend = text;
    const hasKey = await e2ee.hasSharedKey(user.mobNumber, activeChat);

    if (hasKey) {
      const encrypted = await e2ee.encryptMessage(user.mobNumber, activeChat, text);
      if (encrypted) {
        messageToSend = encrypted;
      }
    }

    chatSocket.sendPrivateMessage({
      senderPhone: user.mobNumber,
      receiverPhone: activeChat,
      message: messageToSend,
      messageType: 'TEXT',
    });
  };

  const openChat = async (phone) => {
    setActiveChat(phone);
    setSidebarVisible(false);

    // Clear unread
    setConversations((prev) =>
      prev.map((c) => (c.phone === phone ? { ...c, unread: 0 } : c))
    );

    // Initiate key exchange if we don't have a shared key yet
    const hasKey = await e2ee.hasSharedKey(user.mobNumber, phone);
    if (!hasKey) {
      try {
        const keyMsg = await e2ee.createKeyExchangeMessage(user.mobNumber);
        chatSocket.sendPrivateMessage({
          senderPhone: user.mobNumber,
          receiverPhone: phone,
          message: keyMsg,
          messageType: 'TEXT',
        });
        console.log('[E2EE] Sent key exchange to', phone);
      } catch (err) {
        console.error('[E2EE] Failed to send key exchange:', err);
      }
    }
  };

  const startNewChat = (phone) => {
    if (!phone.trim()) return;
    ensureConversation(phone);
    setShowNewChat(false);
    openChat(phone);
  };

  const handleLogout = () => {
    chatSocket.disconnect();
    logoutUser();
  };

  const goBackToSidebar = () => {
    setSidebarVisible(true);
    setActiveChat(null);
  };

  return (
    <div className="chat-app">
      <Sidebar
        conversations={conversations}
        activeChat={activeChat}
        onSelectChat={openChat}
        onNewChat={() => setShowNewChat(true)}
        onLogout={handleLogout}
        connectionStatus={connectionStatus}
        onlineUsers={onlineUsers}
        user={user}
        visible={sidebarVisible}
        encryptedChats={encryptedChats}
      />

      <main className="chat-area">
        {activeChat ? (
          <ChatView
            phone={activeChat}
            messages={messages[activeChat] || []}
            onSend={sendMessage}
            onBack={goBackToSidebar}
            isOnline={onlineUsers.has(activeChat)}
            currentUser={user}
            conversationName={conversations.find((c) => c.phone === activeChat)?.name}
            isEncrypted={encryptedChats.has(activeChat)}
          />
        ) : (
          <EmptyChat />
        )}
      </main>

      {showNewChat && (
        <NewChatModal
          onClose={() => setShowNewChat(false)}
          onStart={startNewChat}
        />
      )}
    </div>
  );
}
