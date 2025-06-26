#!/bin/bash
# 服务器初始化脚本(将此文件内容直接粘贴到远端服务器上执行)
sudo -i

cat > setup_server_centos.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# 检测操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
elif [ -f /etc/redhat-release ]; then
    OS="centos"
    OS_VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)
else
    echo "无法检测操作系统类型"
    exit 1
fi

echo "检测到操作系统: $OS $OS_VERSION"

# 修复CentOS 7的软件包冲突
fix_centos7_conflict() {
    if [[ "$OS" == "centos" && "$OS_VERSION" == "7" ]]; then
        echo "正在解决CentOS 7软件包冲突..."
        
        # 强制更新centos-release
        sudo yum install -y --disablerepo=* --enablerepo=base,updates centos-release
        
        # 清理并重建仓库缓存
        sudo yum clean all
        sudo rm -rf /var/cache/yum
        sudo rpm --rebuilddb
        
        # 更新系统核心包（跳过冲突）
        sudo yum update -y --skip-broken
    fi
}

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
                # 首先安装 EPEL 仓库
                sudo yum install -y epel-release
                
                # 安装基础工具
                sudo yum install -y curl wget
                
                # 安装其他包
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

# 安装 Node.js (使用NVM方法)
install_nodejs() {
    # 检查是否已安装Node.js v16
    if command -v node &>/dev/null && node --version | grep -q 'v16'; then
        echo "Node.js 16 已安装"
        return
    fi

    echo "安装 Node.js 16 (CentOS 7 兼容版本)..."

    case $OS in
        ubuntu|debian)
            # Ubuntu/Debian使用官方仓库安装
            curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
            sudo apt install -y nodejs
            ;;
        centos|rhel|fedora|amzn)
            # CentOS/RHEL使用NVM安装
            echo "使用NVM安装Node.js..."
            
            # 安装依赖
            sudo yum install -y curl git gcc-c++ make 
            
            # 安装NVM
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            
            # 立即加载NVM
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
            
            # 安装Node.js v16
            nvm install 16
            nvm use 16
            
            # 确保所有用户都能使用Node.js
            NODE_PATH=$(which node)
            NPM_PATH=$(which npm)
            sudo ln -sf "$NODE_PATH" /usr/local/bin/node
            sudo ln -sf "$NPM_PATH" /usr/local/bin/npm
            sudo ln -sf "$(which npx)" /usr/local/bin/npx
            
            # 添加环境变量到全局profile
            echo 'export NVM_DIR="$HOME/.nvm"' | sudo tee /etc/profile.d/nvm.sh
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' | sudo tee -a /etc/profile.d/nvm.sh
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' | sudo tee -a /etc/profile.d/nvm.sh
            echo 'export PATH=$PATH:/usr/local/bin' | sudo tee -a /etc/profile.d/nvm.sh
            
            # 立即生效
            source /etc/profile.d/nvm.sh
            ;;
    esac

    # 验证安装 (使用绝对路径确保可用)
    echo "Node.js 版本: $(/usr/local/bin/node -v)"
    echo "npm 版本: $(/usr/local/bin/npm -v)"
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
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires 0;
    }

    location /api {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # 健康检查端点
    location /health {
        proxy_pass http://127.0.0.1:8080/api/health;
        access_log off;
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
ExecStart=/usr/bin/java -Xms512m -Xmx1024m -jar backend.jar
Environment="SPRING_PROFILES_ACTIVE=prod"
SuccessExitStatus=143
Restart=always
RestartSec=30
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=rsbfourth

# 安全加固
NoNewPrivileges=yes
ProtectSystem=full
PrivateTmp=yes
PrivateDevices=yes

[Install]
WantedBy=multi-user.target
SERVICE_EOF

    sudo systemctl daemon-reload
    sudo systemctl enable rsbfourth
}

# 主函数
main() {
    # 修复CentOS 7软件包冲突
    fix_centos7_conflict
    
    # 安装必要软件
    install_packages openjdk-8-jdk maven git

    # 安装 Node.js (使用NVM方法)
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
    echo "✅ 服务器初始化完成！"
    echo "操作系统: $OS $OS_VERSION"
    echo "部署用户: deployer"
    echo "项目目录: /opt/rsbfourth"
    echo "Node.js 版本: $(/usr/local/bin/node -v)"
    echo "Nginx 配置文件: /etc/nginx/conf.d/rsbfourth.conf"
    echo "Systemd 服务: rsbfourth.service"
    echo "=========================================="
    
    # 最终验证
    echo "正在执行最终验证..."
    if ! command -v node &> /dev/null; then
        echo "❌ 错误: node 命令仍然不可用"
        echo "尝试手动修复:"
        echo "1. 检查符号链接: ls -l /usr/local/bin/node"
        echo "2. 加载环境变量: source /etc/profile.d/nvm.sh"
        echo "3. 检查PATH: echo \$PATH"
    else
        echo "✅ 验证通过: node 命令可用"
    fi
}

# 执行主函数
main
EOF

# 设置执行权限
chmod +x setup_server_centos.sh

# 执行修复后的脚本
echo "开始执行服务器初始化脚本..."
./setup_server_centos.sh

# 最终检查
if [ $? -eq 0 ]; then
    echo "服务器初始化脚本执行完成！"
else
    echo "脚本执行过程中出现错误。"
    echo "请检查日志并执行以下命令手动验证Node.js安装:"
    echo "source /etc/profile.d/nvm.sh"
    echo "node -v"
fi