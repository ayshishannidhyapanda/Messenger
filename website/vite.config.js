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
    // On Vercel: default 'dist'. For Spring Boot: embed in static resources
    outDir: process.env.VERCEL ? 'dist' : path.resolve(__dirname, '../src/main/resources/static/web'),
    emptyOutDir: true,
  },
  // On Vercel: serve from root '/'. For Spring Boot embed: '/api/web/'
  base: process.env.VERCEL ? '/' : (process.env.NODE_ENV === 'production' ? '/api/web/' : '/'),
})
