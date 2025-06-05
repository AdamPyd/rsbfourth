import * as React from 'react';
// import { useState } from 'react'
import { Button } from 'antd'
// import reactLogo from '../../assets/react.svg'
// import viteLogo from '/vite.svg'
import utils from '../../api/axiosUtil'
import requestMethod from '../../api/axiosRequestConfig'
import './App.css'


class App extends React.Component {
    constructor(props) {
        super(props);
        this.loginOutMethod = this.loginOutMethod.bind(this);
    }

    loginOutMethod() {
        const testConfig = axiosRequestConfig.testConfig;
        const config = {
            param: { t: new Date().getTime() },
            callback: (response) => {
                alert(response);
                if (response.data.code === 0) {
                    history.push('/');
                }
            }
        }
        const finalConfig = { ...testConfig, ...config };
        axiosUtil.axiosMethod(finalConfig);
    }

    componentDidMount() {}

    request () {
        const requestConfig = requestMethod.testConfig;
        utils.axiosMethod(requestConfig);
    }

    render() {
        return (
            <>
                <Button onClick={request()}>
                    点击，发送请求给后端
                </Button>
            </>
        );
    }
}

export default App;
