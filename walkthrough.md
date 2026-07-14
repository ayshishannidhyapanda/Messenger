# Messenger App — Walkthrough

## What Was Built

### 1. Flutter Mobile App (`messenger_app/`)

A complete cross-platform chat app (Android + iOS + Web) with 7 screens:

| Screen | Purpose |
|---|---|
| **Server Config** | Enter server URL (local IP or ngrok) |
| **Login** | Phone + password sign in |
| **Register** | Create new account |
| **OTP** | 6-digit verification code |
| **Home** | Conversation list with online indicators |
| **Chat** | Real-time messaging with WhatsApp-style bubbles |
| **Settings** | Profile, server URL, connection status, logout |

**Tech stack:** Flutter 3.44.6, Provider (state), STOMP WebSocket, SharedPreferences

### 2. ngrok Integration

| File | Purpose |
|---|---|
| [start_server.bat](file:///c:/Users/Ankit/IdeaProjects/Messenger/start_server.bat) | One-click: starts backend + ngrok |
| [start_server.ps1](file:///c:/Users/Ankit/IdeaProjects/Messenger/start_server.ps1) | Smart version: waits for health check, extracts public URL |
| [WebSecurityConfig.java](file:///c:/Users/Ankit/IdeaProjects/Messenger/src/main/java/com/messenger/config/WebSecurityConfig.java) | Added CORS config for cross-origin requests |
| [api_service.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/services/api_service.dart) | `ngrok-skip-browser-warning` header added |

### 3. Backend Changes

- **CORS enabled** in `WebSecurityConfig` — allows requests from ngrok domains and mobile apps
- **WebSocket** already had `setAllowedOriginPatterns("*")` — no change needed

---

## How to Run

### Step 1: Start the Server + ngrok

**Option A — Simple (bat file):**
```
Double-click start_server.bat
```

**Option B — Smart (PowerShell):**
```powershell
.\start_server.ps1
```
This will:
1. Start Spring Boot on port 8080
2. Wait until it's healthy
3. Start ngrok tunnel
4. Display the public URL

### Step 2: Run the Flutter App

```bash
cd messenger_app
flutter run
```

### Step 3: Enter Server URL in the App

On the **"Connect to Server"** screen, enter:
- **Same WiFi:** `http://<your-pc-ip>:8080`
- **Any network (ngrok):** The `https://xxxx.ngrok-free.app` URL from step 1

---

## Project Structure

```
Messenger/
├── src/                          # Spring Boot backend (existing)
├── messenger_app/                # Flutter app (NEW)
│   ├── lib/
│   │   ├── config/               # Theme, routes, API constants
│   │   ├── models/               # User, ChatMessage, ApiResponse, enums
│   │   ├── services/             # HTTP, WebSocket, storage, auth
│   │   ├── providers/            # State management (Provider)
│   │   ├── screens/              # 7 screens
│   │   └── widgets/              # Reusable UI components
│   ├── android/                  # Android config (INTERNET permission added)
│   ├── ios/                      # iOS config
│   └── pubspec.yaml              # Dependencies
├── start_server.bat              # One-click startup (NEW)
├── start_server.ps1              # Smart startup (NEW)
└── build.gradle                  # Backend build
```

## Key Files

| Layer | Files |
|---|---|
| **Entry** | [main.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/main.dart), [app.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/app.dart) |
| **Config** | [app_theme.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/config/app_theme.dart), [api_constants.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/config/api_constants.dart) |
| **Services** | [api_service.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/services/api_service.dart), [chat_service.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/services/chat_service.dart), [auth_service.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/services/auth_service.dart) |
| **Screens** | [server_config_screen.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/screens/server_config/server_config_screen.dart), [login_screen.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/screens/auth/login_screen.dart), [chat_screen.dart](file:///c:/Users/Ankit/IdeaProjects/Messenger/messenger_app/lib/screens/chat/chat_screen.dart) |
| **Server** | [start_server.ps1](file:///c:/Users/Ankit/IdeaProjects/Messenger/start_server.ps1), [WebSecurityConfig.java](file:///c:/Users/Ankit/IdeaProjects/Messenger/src/main/java/com/messenger/config/WebSecurityConfig.java) |
