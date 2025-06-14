#!/bin/bash

SERVER_IP="47.114.48.162"  # 替换为实际IP
SSH_USER="deployer"

# 构建前端
cd frontend
npm install
npm run build

# 构建后端
cd ../backend
./mvnw clean package -DskipTests

# 上传文件
scp backend/target/*.jar ${SSH_USER}@${SERVER_IP}:/opt/rsbfourth/backend.jar
ssh ${SSH_USER}@${SERVER_IP} "rm -rf /opt/rsbfourth/frontend"
scp -r frontend/dist ${SSH_USER}@${SERVER_IP}:/opt/rsbfourth/frontend

# 重启服务
ssh ${SSH_USER}@${SERVER_IP} "sudo systemctl restart rsbfourth"

echo "部署完成！访问 http://${SERVER_IP}"