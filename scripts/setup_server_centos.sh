#!/bin/bash
# 服务器初始化脚本(将此文件内容直接粘贴到远端服务器上执行)
sudo -i

cat > setup_server_centos.sh << 'EOF'

set -euo pipefail

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    OS_VERSION=$(lsb_release -sr)
elif [ -f /etc/redhat-release ]; then
    OS="centos"
    OS_VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)
else
    echo "无法检测操作系统类型"
    exit 1
fi

echo "检测到操作系统: $OS $OS_VERSION"

# 安装软件包
install_packages() {
    case $OS in
        ubuntu|debian)
            echo "在 Debian/Ubuntu 系统上安装软件包..."
            sudo apt update -y
            sudo apt install -y "$@"
            ;;
        centos|rhel|fedora|amzn)
            echo "在 CentOS/RHEL 系统上安装软件包..."
            if [ "$OS" = "amzn" ]; then
                sudo yum update -y
                sudo yum install -y "$@"
            else
                # 修复：先更新 centos-release 解决冲突
                if [ "$OS" = "centos" ]; then
                    sudo yum update -y centos-release
                fi
                sudo yum install -y epel-release
                sudo yum update -y
                sudo yum install -y "$@"
            fi
            ;;
        *)
            echo "不支持的操作系统: $OS"
            exit 1
            ;;
    esac
}

# 添加部署用户
add_deploy_user() {
    if id "deployer" &>/dev/null; then
        echo "部署用户 'deployer' 已存在"
        return
    fi

    case $OS in
        ubuntu|debian)
            echo "创建部署用户 (Debian/Ubuntu)"
            sudo adduser --disabled-password --gecos "" deployer
            ;;
        centos|rhel|fedora|amzn)
            echo "创建部署用户 (CentOS/RHEL)"
            sudo adduser deployer
            sudo passwd -d deployer
            ;;
    esac

    echo "配置 sudo 权限..."
    echo "deployer ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/deployer
    sudo chmod 0440 /etc/sudoers.d/deployer
}

# 配置防火墙
configure_firewall() {
    case $OS in
        ubuntu|debian)
            echo "配置防火墙 (UFW)"
            sudo ufw allow 80
            sudo ufw allow 22
            sudo ufw --force enable
            ;;
        centos|rhel|fedora|amzn)
            echo "配置防火墙 (FirewallD)"
            sudo systemctl start firewalld
            sudo systemctl enable firewalld
            sudo firewall-cmd --permanent --add-service=http
            sudo firewall-cmd --permanent --add-service=ssh
            sudo firewall-cmd --reload
            ;;
    esac
}

# 配置项目目录
setup_project_dir() {
    echo "创建项目目录..."
    sudo mkdir -p /opt/rsbfourth
    sudo chown -R deployer:deployer /opt/rsbfourth
}

# 安装 Node.js
install_nodejs() {
    if command -v node &>/dev/null && node --version | grep -q 'v18'; then
        echo "Node.js 18 已安装"
        return
    fi

    echo "安装 Node.js 18..."

    case $OS in
        ubuntu|debian)
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt install -y nodejs
            ;;
        centos|rhel|fedora|amzn)
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs
            ;;
    esac

    # 验证安装
    node --version
    npm --version
}

# 配置 Nginx
configure_nginx() {
    echo "安装和配置 Nginx..."
    install_packages nginx

    # 创建 Nginx 配置
    sudo tee /etc/nginx/conf.d/rsbfourth.conf << 'NGINX_EOF'
server {
    listen 80;
    server_name _;

    location / {
        root /opt/rsbfourth/frontend;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://127.0.0.1:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX_EOF

    # 在 CentOS 上启用配置
    if [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" || "$OS" == "amzn" ]]; then
        if [ -f /etc/nginx/nginx.conf ]; then
            # 确保包含 conf.d 目录
            sudo sed -i '/include \/etc\/nginx\/conf\.d\/\*\.conf;/d' /etc/nginx/nginx.conf
            sudo sed -i '/http {/a include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
        fi
    fi

    # 测试并启动 Nginx
    sudo nginx -t
    sudo systemctl enable nginx
    sudo systemctl restart nginx
}

# 配置 Systemd 服务
configure_systemd_service() {
    echo "配置 Systemd 服务..."
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
    sudo systemctl enable rsbfourth
}

# 主函数
main() {
    # 安装必要软件
    install_packages openjdk-17-jdk maven git

    # 安装 Node.js
    install_nodejs

    # 添加部署用户
    add_deploy_user

    # 配置防火墙
    configure_firewall

    # 配置项目目录
    setup_project_dir

    # 配置 Nginx
    configure_nginx

    # 配置 Systemd 服务
    configure_systemd_service

    echo "=========================================="
    echo "服务器初始化完成！"
    echo "操作系统: $OS $OS_VERSION"
    echo "部署用户: deployer"
    echo "项目目录: /opt/rsbfourth"
    echo "Nginx 配置文件: /etc/nginx/conf.d/rsbfourth.conf"
    echo "Systemd 服务: rsbfourth.service"
    echo "=========================================="
}

# 执行主函数
main

EOF

chmod +x setup_server_centos.sh
./setup_server_centos.sh