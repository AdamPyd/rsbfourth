#!/bin/bash

# 自动部署脚本
# 使用: sudo -u deployer /opt/rsbfourth/deploy.sh

# 配置信息
APP_DIR="/opt/rsbfourth"
GITHUB_REPO="git@github.com:AdamPyd/rsbfourth.git"
LOG_FILE="$APP_DIR/deploy.log"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# 开始部署
log "====== 开始部署 ======"

# 1. 克隆或更新代码
log "步骤 1: 获取最新代码"
if [ ! -d "$APP_DIR/repo" ]; then
    log "首次克隆仓库..."
    git clone $GITHUB_REPO $APP_DIR/repo
else
    log "更新现有仓库..."
    cd $APP_DIR/repo
    git pull origin main
fi

# 2. 构建前端
log "步骤 2: 构建前端"
cd $APP_DIR/repo/frontend
npm install --silent
npm run build

# 3. 构建后端
log "步骤 3: 构建后端"
cd ../backend
mvn clean package -DskipTests -q

# 4. 停止服务
log "步骤 4: 停止服务"
systemctl stop rsbfourth

# 5. 部署文件
log "步骤 5: 部署文件"
rm -rf $APP_DIR/frontend
cp -r $APP_DIR/repo/frontend/dist $APP_DIR/frontend
cp $APP_DIR/repo/backend/target/*.jar $APP_DIR/backend.jar

# 6. 启动服务
log "步骤 6: 启动服务"
systemctl start rsbfourth

# 7. 健康检查
log "步骤 7: 健康检查"
sleep 10
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/api/health)
if [ "$HTTP_STATUS" -eq 200 ]; then
    log "健康检查成功: 服务已启动"
    log "====== 部署成功完成 ======"
    exit 0
else
    log "健康检查失败: 状态码 $HTTP_STATUS"
    log "====== 部署失败 ======"
    exit 1
fi