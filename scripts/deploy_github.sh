#!/bin/bash

SERVER_IP="47.114.48.162"  # 替换为实际IP
SSH_USER="deployer"
GITHUB_REPO="https://github.com/yourusername/yourrepo.git"

ssh ${SSH_USER}@${SERVER_IP} << EOF
  # 清理旧目录
  rm -rf /opt/rsbfourth/tmp

  # 克隆代码
  git clone ${GITHUB_REPO} /opt/rsbfourth/tmp

  # 构建前端
  cd /opt/rsbfourth/tmp/frontend
  npm install
  npm run build

  # 构建后端
  cd /opt/rsbfourth/tmp/backend
  mvn clean package -DskipTests

  # 部署文件
  sudo systemctl stop rsbfourth
  cp /opt/rsbfourth/tmp/backend/target/*.jar /opt/rsbfourth/backend.jar
  rm -rf /opt/rsbfourth/frontend
  cp -r /opt/rsbfourth/tmp/frontend/dist /opt/rsbfourth/frontend
  sudo systemctl start rsbfourth

  # 清理
  rm -rf /opt/rsbfourth/tmp
EOF

echo "部署完成！访问 http://${SERVER_IP}"