import { defineConfig } from 'vite';
import liveReload from 'vite-plugin-live-reload';
import mkcert from 'vite-plugin-mkcert';
import path from 'path';
import fs from 'fs';

function hotFilePlugin() {
  const hotFilePath = path.resolve(__dirname, '.hot');

  return {
    name: 'write-hot-file',
    configureServer(server) {
      const protocol = server.config.server.https ? 'https' : 'http';
      const host = process.env.VITE_DEV_SERVER_HOST || 'localhost';

      server.httpServer?.once('listening', () => {
        const address = server.httpServer?.address();
        if (!address || typeof address === 'string') return;
        const hotUrl = `${protocol}://${host}:${address.port}`;
        fs.writeFileSync(hotFilePath, `${hotUrl}\n`, 'utf8');
      });

      server.httpServer?.once('close', () => {
        if (fs.existsSync(hotFilePath)) {
          fs.unlinkSync(hotFilePath);
        }
      });
    },
  };
}

export default defineConfig({
  plugins: [liveReload(path.resolve(__dirname, '../**/*.php')), mkcert(), hotFilePlugin()],
  root: '',
  base: process.env.NODE_ENV === 'development' ? '/' : './',
  envDir: __dirname,
  build: {
    outDir: path.resolve(__dirname, './dist'),
    emptyOutDir: true,
    manifest: true,
    rollupOptions: {
      input: path.resolve(__dirname, 'src/main.js'),
    },
    assetsDir: '',
  },
  server: {
    cors: true,
    strictPort: false,
    https: true,
    hmr: {
      host: 'localhost',
    },
  },
  css: {
    transformer: 'lightningcss',
  },
});
