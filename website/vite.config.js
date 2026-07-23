import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true,   // Expose on all LAN interfaces (0.0.0.0)
    port: 5173,
  },
  build: {
    // Build into a /web/ subfolder inside Spring Boot's static resources
    // so it doesn't conflict with the Flutter web build in the root
    outDir: path.resolve(__dirname, '../src/main/resources/static/web'),
    emptyOutDir: true,
  },
  // Served at /api/web/ because of server.servlet.context-path=/api
  base: process.env.NODE_ENV === 'production' ? '/api/web/' : '/',
})
