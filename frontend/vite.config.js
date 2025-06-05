import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// 根据环境变量切换API基地址
const apiBaseUrl = process.env.NODE_ENV === 'production'
    ? '/api'
    : 'http://localhost:8080/api';

export default defineConfig({
      plugins: [react()],
      server: {
        port: 3000,
        proxy: {
          // 开发环境代理配置
          '/api': {
            target: 'http://localhost:8080',
            changeOrigin: true,
            rewrite: (path) => path.replace(/^\/api/, '')
        }
      }
    },
    build: {
  // 构建输出到后端静态资源目录
  outDir: '../backend/src/main/resources/static',
      emptyOutDir: true
}
});