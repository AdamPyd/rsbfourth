#!/bin/bash

# 在本地执行

# 创建本地部署脚本 deploy.sh
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

SERVER_IP="47.114.48.162"  # 替换为实际IP
SSH_USER="deployer"
SSH_KEY="$HOME/.ssh/rsbfourth_deploy"

# 构建前端
cd frontend
npm run build
cd ..

# 构建后端
cd backend
mvn clean package -DskipTests
cd ..

# 准备部署包
rm -rf deploy_artifacts
mkdir deploy_artifacts
cp -r frontend/dist deploy_artifacts/frontend
cp backend/target/*.jar deploy_artifacts/backend.jar
tar -czvf artifacts.tar.gz deploy_artifacts

# 传输文件
scp -i "$SSH_KEY" artifacts.tar.gz ${SSH_USER}@${SERVER_IP}:/opt/rsbfourth/

# 远程执行部署
ssh -i "$SSH_KEY" ${SSH_USER}@${SERVER_IP} << 'REMOTE_EOF'
set -euo pipefail
cd /opt/rsbfourth
tar -xzvf artifacts.tar.gz
sudo systemctl stop rsbfourth || true
cp deploy_artifacts/backend.jar .
rm -rf frontend
cp -r deploy_artifacts/frontend .
sudo chown -R deployer:deployer /opt/rsbfourth
sudo systemctl start rsbfourth
rm -rf deploy_artifacts artifacts.tar.gz
REMOTE_EOF

# 清理本地文件
rm -rf deploy_artifacts artifacts.tar.gz

echo "部署完成！访问 http://${SERVER_IP}"
EOF

# 执行本地部署
chmod +x deploy.sh
./deploy.sh