// 创建统一的 API 客户端
const VITE_API_FULL_URL = import.meta.env.VITE_API_BASE_URL + ":"
    + import.meta.env.VITE_BACKEND_PORT
    + import.meta.env.VITE_API_BASE_PATH;

const handleResponse = async (response) => {
    if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        const error = new Error(`API 请求失败: ${response.statusText}`);
        error.status = response.status;
        error.data = errorData;
        throw error;
    }
    return response.json();
};

export const apiClient = {
    get: async (endpoint) => {
    const url = `${VITE_API_FULL_URL}${endpoint}`;
console.log(`发送 GET 请求到: ${url}`);

const response = await fetch(url, {
    method: 'GET',
    headers: {
        'Content-Type': 'application/json'
    }
});

return handleResponse(response);
},

post: async (endpoint, data) => {
    const url = `${API_BASE_URL}${endpoint}`;
    console.log(`发送 POST 请求到: ${url}`, data);

    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    });

    return handleResponse(response);
}
};