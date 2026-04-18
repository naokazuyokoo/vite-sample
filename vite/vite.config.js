import { defineConfig, loadEnv } from 'vite';
import liveReload from 'vite-plugin-live-reload';
import mkcert from 'vite-plugin-mkcert';
import path from 'path';
import fs from 'fs';

function hotFilePlugin(devServerHost) {
  const hotFilePath = path.resolve(__dirname, '.hot');

  return {
    name: 'write-hot-file',
    configureServer(server) {
      const protocol = server.config.server.https ? 'https' : 'http';

      server.httpServer?.once('listening', () => {
        const address = server.httpServer?.address();
        if (!address || typeof address === 'string') return;
        const hotUrl = `${protocol}://${devServerHost}:${address.port}`;
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

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, __dirname, '');
  const devServerHost = env.VITE_DEV_SERVER_HOST || 'localhost';

  return {
    plugins: [liveReload(path.resolve(__dirname, '../**/*.php')), mkcert(), hotFilePlugin(devServerHost)],
    root: '',
    base: mode === 'development' ? '/' : './',
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
      host: devServerHost,
      cors: true,
      strictPort: false,
      https: true,
      hmr: {
        host: devServerHost,
      },
    },
    css: {
      transformer: 'lightningcss',
    },
  };
});
