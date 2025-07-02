import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ command, mode }) => {
    // 加载环境变量
    const env = loadEnv(mode, process.cwd(), 'VITE_');
    console.log(env);
    // 获取前端端口
    const WEB_URL_PORT = env.VITE_WEB_URL_PORT || '3000';
    const API_BASE_PATH = env.VITE_API_BASE_PATH || '/api';
    // const WEB_URL_PORT = '3000';

    return {
        plugins: [react()],
        server: {
            port: WEB_URL_PORT,
            host: '0.0.0.0',
            strictPort: true, // 确保端口固定
        },
        // 这个 proxy 貌似没什么用
        // proxy: {
        //     // 代理所有以 /api 开头的请求
        //     API_BASE_PATH: {
        //         target: 'http://localhost:123',
        //         changeOrigin: true,
        //         secure: false,
        //         rewrite: (path) => path.replace(/^\/api/, ''),
        //         // 添加日志记录用于调试
        //         configure: (proxy) => {
        //             proxy.on('proxyReq', (proxyReq, req) => {
        //                 console.log(`代理请求: ${req.url} -> ${proxyReq.path}`);
        //             });
        //             proxy.on('proxyRes', (proxyRes, req) => {
        //                 console.log(`代理响应: ${req.url} -> ${proxyRes.statusCode}`);
        //             });
        //         }
        //     }
        // },
        build: {
            outDir: '../backend/src/main/resources/static',
                emptyOutDir: true
        }
    };
});