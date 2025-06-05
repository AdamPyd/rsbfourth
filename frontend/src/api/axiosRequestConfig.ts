// axiosRequestConfig.js

const requestMethod={
   // 登录校验
   doLoginConfig:{
       method:'post',
       url:'/user/login',
       // proxy:{
       //     port:80,
       // }
   },
   // 登录状态验证
   loginStateConfig:{
       method:'get',
       url:'/user/loginState',
       // proxy:{
       //     port:80,
       // }
   },
   // 退出登录
   loginOutConfig:{
       method:'get',
       url:'/user/loginOut',
       // proxy:{
       //     port:80,
       // }
   },
    // 测试请求
    testConfig:{
        method:'get',
        url:'/api/hello.json',
        // proxy:{
        //     port:80,
        // }
    }
}

export default requestMethod