import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './page/home/App.jsx'
import uriConfig from './config/uriConfig'

import {
    createBrowserRouter,
    RouterProvider,
    Route,
    Link
} from 'react-router-dom';

const router = createBrowserRouter(uriConfig);

createRoot(document.getElementById('root')).render(
  <StrictMode>
      <RouterProvider router={router} />
  </StrictMode>,
)
