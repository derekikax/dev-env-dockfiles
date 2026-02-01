#!/bin/bash
set -e

CONTAINER_NAME="dev-env-enhanced"
IMAGE_NAME="dev-env-image"

# 1. 建置 Docker Image
echo "🔨 Building Docker image..."
docker build -t $IMAGE_NAME -f dev-env-dockfiles/Dockerfile dev-env-dockfiles

# 2. 準備持久化目錄 (避免掛載報錯)
touch ~/.dev_bash_history
mkdir -p ~/.uv_cache

# 3. 啟動容器
echo "🚀 Launching container..."
docker run --rm -it \
    --name $CONTAINER_NAME \
    --hostname dev-box \
    -v $HOME/.ssh:/mnt/ssh-readonly:ro \
    -v $HOME/.gitconfig:/mnt/gitconfig:ro \
    -v $(pwd):/workspace \
    -v $HOME/.dev_bash_history:/root/.bash_history \
    -v $HOME/.uv_cache:/root/.cache/uv \
    $IMAGE_NAME
