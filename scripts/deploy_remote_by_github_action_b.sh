#!/bin/bash
## 远程服务器操作

# 创建远程部署脚本 server_deploy.sh
sudo -u deployer tee /home/deployer/server_deploy.sh << 'EOF'
#!/bin/bash
set -euxo pipefail  # 增加详细输出

# 配置参数
GITHUB_REPO="git@github.com:AdamPyd/rsbfourth.git"
TMP_DIR="/opt/rsbfourth/tmp_$(date +%s)"
APP_DIR="/opt/rsbfourth"
BRANCH="main"

# 打印环境信息
echo "===== 部署开始 ====="
echo "时间: $(date)"
echo "用户: $(whoami)"
echo "目录: $(pwd)"

# 调试 SSH 配置
echo "===== SSH 配置 ====="
cat ~/.ssh/config || true
echo "公钥内容:"
cat ~/.ssh/github_rsbfourth.pub || true

# 测试 GitHub 连接
echo "===== 测试 GitHub 连接 ====="
ssh -vT git@github.com || echo "SSH 测试失败"

# 清理旧目录
mkdir -p "$APP_DIR/backups"
find "$APP_DIR/backups" -type d -name "backup_*" -mtime +30 -exec rm -rf {} \; || true

# 确保使用正确的密钥
export GIT_SSH_COMMAND="ssh -i ~/.ssh/github_rsbfourth -o IdentitiesOnly=yes"

# 克隆代码
echo "===== 克隆代码库 ====="
git clone --branch "$BRANCH" --depth 1 "$GITHUB_REPO" "$TMP_DIR"

# 构建前端
echo "===== 构建前端 ====="
cd "$TMP_DIR/frontend"
npm ci --production --prefer-offline
npm run build

# 构建后端
echo "===== 构建后端 ====="
cd "$TMP_DIR/backend"
mvn clean package -DskipTests

# 创建备份
echo "===== 创建备份 ====="
BACKUP_DIR="$APP_DIR/backups/backup_$(date +%Y%m%d_%H%M%S)"
sudo mkdir -p "$BACKUP_DIR"
sudo cp "$APP_DIR/backend.jar" "$BACKUP_DIR/" || true
sudo cp -r "$APP_DIR/frontend" "$BACKUP_DIR/" || true

# 停止服务
sudo systemctl stop rsbfourth || true

# 部署新版本
echo "===== 部署新版本 ====="
sudo cp "$TMP_DIR/backend/target/"*.jar "$APP_DIR/backend.jar"
sudo rm -rf "$APP_DIR/frontend"
sudo cp -r "$TMP_DIR/frontend/dist" "$APP_DIR/frontend"

# 添加版本信息
echo "DEPLOY_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" | sudo tee "$APP_DIR/version.info"
echo "GIT_COMMIT=$(git -C "$TMP_DIR" rev-parse HEAD)" | sudo tee -a "$APP_DIR/version.info"

# 设置权限
sudo chown -R deployer:deployer "$APP_DIR"

# 启动服务
sudo systemctl start rsbfourth

# 清理
rm -rf "$TMP_DIR"

# 验证部署
echo "===== 验证服务状态 ====="
sleep 5
curl -f http://localhost/api/health || (echo "健康检查失败"; exit 1)

echo "✅ 部署成功！版本: $(cat $APP_DIR/version.info)"
echo "===== 部署完成 ====="
EOF

# 设置权限并执行
sudo -u deployer chmod +x /home/deployer/server_deploy.sh
sudo -u deployer /home/deployer/server_deploy.sh