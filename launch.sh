#!/bin/bash
set -e

CONTAINER_NAME="general-dev-run"
IMAGE_NAME="general-dev-env"

# 1. 建置 Docker Image
echo "🔨 Building Docker image..."
docker build -t $IMAGE_NAME -f Dockerfile .

# 2. 準備持久化目錄
touch ~/.dev_bash_history
mkdir -p ~/.uv_cache

# 3. 啟動容器
# 注意: 容器內部預設使用 'vscode' (uid=1000)，路徑為 /home/vscode
echo "🚀 Launching container..."
docker run --rm -it \
    --name $CONTAINER_NAME \
    --hostname dev-box \
    --user vscode \
    -v $HOME/.ssh:/home/vscode/.ssh:ro \
    -v $HOME/.gitconfig:/home/vscode/.gitconfig:ro \
    -v $(pwd):/workspace \
    -v $HOME/.dev_bash_history:/home/vscode/.bash_history \
    -v $HOME/.uv_cache:/home/vscode/.cache/uv \
    $IMAGE_NAME
