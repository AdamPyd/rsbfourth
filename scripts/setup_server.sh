#!/bin/bash

# 安装基础工具
sudo apt update
sudo apt install -y curl wget git ufw

# 安装 Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 安装 JDK 17
sudo apt install -y openjdk-17-jdk

# 安装 Maven
sudo apt install -y maven

# 安装 Nginx
sudo apt install -y nginx

# 创建部署用户
sudo adduser --disabled-password --gecos "" deployer
sudo usermod -aG sudo deployer

# 配置 SSH 密钥
sudo -u deployer mkdir -p /home/deployer/.ssh
sudo -u deployer touch /home/deployer/.ssh/authorized_keys
sudo chmod 600 /home/deployer/.ssh/authorized_keys

# 配置防火墙
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# 创建项目目录
sudo mkdir -p /opt/rsbfourth
sudo chown -R deployer:deployer /opt/rsbfourth

# 配置 Nginx
sudo tee /etc/nginx/sites-available/rsbfourth > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        root /opt/rsbfourth/frontend;
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/rsbfourth /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

# 配置 Systemd 服务
sudo tee /etc/systemd/system/rsbfourth.service > /dev/null <<EOF
[Unit]
Description=MyApp Service
After=network.target

[Service]
User=deployer
WorkingDirectory=/opt/rsbfourth
ExecStart=/usr/bin/java -jar backend.jar --spring.profiles.active=prod
Restart=always
RestartSec=30
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable rsbfourth

echo "服务器环境准备完成！"