import React, { useState } from 'react';
import { Button, message, Card, Spin } from 'antd';
import { apiClient } from '../utils/api';

// 获取前端端口
const frontendPort = import.meta.env.VITE_WEB_URL_PORT;

const TestPage = () => {
    const [response, setResponse] = useState('');
    const [loading, setLoading] = useState(false);

    const callBackend = async () => {
        setLoading(true);
        try {
            // 使用统一的 API 客户端
            const data = await apiClient.get('/hello.json');
            setResponse(data.message);
            message.success('API 调用成功!');
        } catch (error) {
            console.error('API 调用失败:', error);
            message.error(`API 调用失败: ${error.message}`);
            setResponse(`错误: ${error.message} (状态码: ${error.status})`);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div style={{ padding: 24 }}>
            <Card title="API 测试">
                <Button
                    type="primary"
                    onClick={callBackend}
                    disabled={loading}
                >
                    {loading ? <Spin size="small" /> : '调用后端 API'}
                </Button>

                {response && (
                    <div style={{ marginTop: 20, padding: 16, backgroundColor: '#f0f2f5', borderRadius: 4 }}>
                        <h3>API 响应:</h3>
                        <pre>{JSON.stringify(response, null, 2)}</pre>
                    </div>
                )}
            </Card>

            <Card title="调试信息" style={{ marginTop: 24 }}>
                <p><strong>当前环境:</strong> {import.meta.env.MODE}</p>
                <p><strong>API 基地址:</strong> {import.meta.env.VITE_API_BASE_URL}:{import.meta.env.VITE_BACKEND_PORT}{import.meta.env.VITE_API_BASE_PATH}</p>
                <p><strong>后端端口:</strong> {import.meta.env.VITE_BACKEND_PORT}</p>
                <p><strong>前端端口:</strong> {import.meta.env.VITE_WEB_URL_PORT}</p>
            </Card>
        </div>
    );
};

export default TestPage;