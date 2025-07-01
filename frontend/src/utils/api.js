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
    // // 获取完整的 URL
    // var fullURL = window.location.href;
    //
    // 获取协议（例如：https:）
    const protocol = window.location.protocol;

    // 获取主机名（例如：www.example.com）
    const hostname = window.location.hostname;

    // // 获取端口号（如果有的话）
    // var port = window.location.port;
    //
    // // 获取路径名（例如：/path/to/page）
    // var pathname = window.location.pathname;
    //
    // // 获取查询字符串（例如：?name=John&age=30）
    // var search = window.location.search;
    //
    // // 获取哈希值（例如：#section1）
    // var hash = window.location.hash;

    // console.log("Full URL:", fullURL);
    // console.log("Protocol:", protocol);
    // console.log("Hostname:", hostname);
    // console.log("Port:", port);
    // console.log("Pathname:", pathname);
    // console.log("Search:", search);
    // console.log("Hash:", hash);
    // 创建统一的 API 客户端
    const VITE_API_FULL_URL = protocol + "//" + hostname + ":"
        + import.meta.env.VITE_BACKEND_PORT
        + import.meta.env.VITE_API_BASE_PATH;
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