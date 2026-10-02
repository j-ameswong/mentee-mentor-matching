import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // The historical Sinatra public/ contains user uploads. Never publish it.
  publicDir: 'assets',
  server: { host: '127.0.0.1', port: 5173, strictPort: true },
  build: { sourcemap: false, target: 'es2022' },
})
