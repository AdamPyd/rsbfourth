#!/bin/bash
# 服务器初始化脚本(将此文件内容直接粘贴到远端服务器上执行)

# 创建 setup_server.sh 文件
cat > setup_server.sh << 'EOF'
#!/bin/bash

# 更新系统
sudo apt update -y
sudo apt upgrade -y

# 创建部署用户
sudo adduser deployer --gecos "" --disabled-password
echo "deployer ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/deployer

# 安装基础软件
sudo apt install -y openjdk-17-jdk nodejs npm maven nginx git ufw

# 配置防火墙
sudo ufw allow 80
sudo ufw allow 22
sudo ufw --force enable

# 配置项目目录
sudo mkdir -p /opt/rsbfourth
sudo chown -R deployer:deployer /opt/rsbfourth

# 配置Nginx
sudo tee /etc/nginx/sites-available/rsbfourth << 'NGINX_EOF'
server {
    listen 80;
    server_name _;

    location / {
        root /opt/rsbfourth/frontend;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX_EOF

sudo ln -sf /etc/nginx/sites-available/rsbfourth /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# 配置Systemd服务
sudo tee /etc/systemd/system/rsbfourth.service << 'SERVICE_EOF'
[Unit]
Description=rsbfourth Backend Service
After=network.target

[Service]
User=deployer
Group=deployer
WorkingDirectory=/opt/rsbfourth
ExecStart=/usr/bin/java -jar backend.jar
Restart=always
RestartSec=30
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
SERVICE_EOF

sudo systemctl daemon-reload
EOF

# 执行服务器初始化
chmod +x setup_server.sh
sudo ./setup_server.sh