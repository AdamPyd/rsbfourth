#!/bin/bash

# 服务器环境准备脚本 (CentOS 兼容版)
# 适用于 CentOS 7/8 和 RHEL 7/8

# 检查 root 权限
if [ "$(id -u)" != "0" ]; then
   echo "此脚本必须以 root 权限运行" 
   exit 1
fi

# 安装基础工具
echo "安装基础工具..."
yum update -y
yum install -y curl wget git

# 安装 Node.js 18.x
echo "安装 Node.js 18.x..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# 安装 JDK 17
echo "安装 OpenJDK 17..."
yum install -y java-17-openjdk-devel

# 设置 JAVA_HOME
echo "配置 JAVA_HOME..."
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
source /etc/profile

# 安装 Maven
echo "安装 Maven..."
yum install -y maven

# 安装 Nginx
echo "安装 Nginx..."
yum install -y epel-release
yum install -y nginx

# 创建部署用户
echo "创建部署用户..."
if ! id -u deployer >/dev/null 2>&1; then
    adduser deployer
    # 设置密码
    echo "deployer:DeployerPass123!" | chpasswd
else
    echo "用户 deployer 已存在"
fi

# 添加 sudo 权限
echo "为 deployer 添加 sudo 权限..."
if ! grep -q "^%wheel" /etc/sudoers; then
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi
usermod -aG wheel deployer

# 配置 SSH 密钥
echo "配置 SSH 密钥..."
DEPLOYER_HOME=/home/deployer
mkdir -p $DEPLOYER_HOME/.ssh
chown deployer:deployer $DEPLOYER_HOME/.ssh
chmod 700 $DEPLOYER_HOME/.ssh

touch $DEPLOYER_HOME/.ssh/authorized_keys
chown deployer:deployer $DEPLOYER_HOME/.ssh/authorized_keys
chmod 600 $DEPLOYER_HOME/.ssh/authorized_keys

# 配置防火墙
echo "配置防火墙..."
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# 创建项目目录
echo "创建项目目录..."
APP_DIR="/opt/rsbfourth"
mkdir -p $APP_DIR
chown -R deployer:deployer $APP_DIR

# 配置 Nginx
echo "配置 Nginx..."
NGINX_CONF="/etc/nginx/conf.d/rsbfourth.conf"

cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name _;

    location / {
        root $APP_DIR/frontend;
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# 测试并重启 Nginx
nginx -t
systemctl restart nginx
systemctl enable nginx

# 配置 Systemd 服务
echo "配置 Systemd 服务..."
SERVICE_FILE="/etc/systemd/system/rsbfourth.service"

cat > $SERVICE_FILE <<EOF
[Unit]
Description=MyApp Service
After=network.target

[Service]
User=deployer
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/java -jar $APP_DIR/backend.jar --spring.profiles.active=prod
Restart=always
RestartSec=30
Environment="SPRING_PROFILES_ACTIVE=prod"

[Install]
WantedBy=multi-user.target
EOF

# 启用服务
systemctl daemon-reload
systemctl enable rsbfourth

echo "========================================"
echo "服务器环境准备完成！"
echo "========================================"
echo "后续步骤："
echo "1. 将 SSH 公钥添加到 /home/deployer/.ssh/authorized_keys"
echo "2. 部署应用文件到 $APP_DIR"
echo "3. 启动服务: sudo systemctl start rsbfourth"
echo "========================================"