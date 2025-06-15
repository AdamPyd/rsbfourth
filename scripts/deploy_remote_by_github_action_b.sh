## 远程服务器操作

# 创建远程部署脚本 server_deploy.sh
sudo -u deployer tee /home/deployer/server_deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

GITHUB_REPO="git@github.com:AdamPyd/rsbfourth.git"
TMP_DIR="/opt/rsbfourth/tmp"
APP_DIR="/opt/rsbfourth"

# 清理旧目录
rm -rf "$TMP_DIR"

# 克隆代码
git clone "$GITHUB_REPO" "$TMP_DIR"

# 构建前端
cd "$TMP_DIR/frontend"
npm ci
npm run build

# 构建后端
cd "$TMP_DIR/backend"
mvn clean package -DskipTests

# 停止服务
sudo systemctl stop rsbfourth || true

# 部署文件
cp "$TMP_DIR/backend/target/"*.jar "$APP_DIR/backend.jar"
rm -rf "$APP_DIR/frontend"
cp -r "$TMP_DIR/frontend/dist" "$APP_DIR/frontend"

# 设置权限
sudo chown -R deployer:deployer "$APP_DIR"

# 启动服务
sudo systemctl start rsbfourth

# 清理
rm -rf "$TMP_DIR"

echo "部署完成！服务已启动"
EOF

# 设置权限并执行
sudo -u deployer chmod +x /home/deployer/server_deploy.sh
sudo -u deployer /home/deployer/server_deploy.sh