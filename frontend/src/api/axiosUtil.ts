//axiosUtil.js

import axios from 'axios'

const axiosUtil ={
    axiosMethod: (config:any) => {
        console.log(config);
        axios({
            method: config.method,
            url: config.url,
            params: config.params ? config.params : null,
            data: config.data ? config.data : null,
            proxy: config?.proxy ? config?.proxy : false,
        }).then(config.callback).catch(config.catch ? config.catch : () => {})
    }
};

export default axiosUtil;