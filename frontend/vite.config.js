import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    server: {
        port: 3000,
        strictPort: true, // 确保端口固定
        proxy: {
            // 代理所有以 /api 开头的请求
            '/api': {
                target: 'http://localhost:8080',
                changeOrigin: true,
                secure: false,
                rewrite: (path) => path.replace(/^\/api/, ''),
            // 添加日志记录用于调试
            configure: (proxy) => {
            proxy.on('proxyReq', (proxyReq, req) => {
                console.log(`代理请求: ${req.url} -> ${proxyReq.path}`);
            });
            proxy.on('proxyRes', (proxyRes, req) => {
                console.log(`代理响应: ${req.url} -> ${proxyRes.statusCode}`);
            });
}
}
}
},
build: {
    outDir: '../backend/src/main/resources/static',
        emptyOutDir: true
}
});