import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Layout, Menu } from 'antd';
import TestPage from '../TestPage';

const { Header, Content } = Layout;

function App() {
    return (
        <BrowserRouter>
            <Layout>
                <Routes>
                    <Route path="/" element={<TestPage />} />
                </Routes>
            </Layout>
        </BrowserRouter>
    );
}

export default App;