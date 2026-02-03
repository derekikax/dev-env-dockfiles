#!/bin/bash
set -e

# 設定容器與映像檔名稱
CONTAINER_NAME="general-dev-manual"
IMAGE_NAME="general-dev-env"

echo "🔧 [手動模式] 準備啟動開發環境..."

# 1. 確保映像檔存在 (若不存在則建置)
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "⚠️  找不到映像檔 '$IMAGE_NAME'，正在進行建置..."
    docker build -t $IMAGE_NAME .
else
    echo "✅ 偵測到映像檔 '$IMAGE_NAME'，準備啟動。"
fi

# 2. 準備持久化目錄與快取卷 (模擬 devcontainer 行為)
# 確保 Host 端目錄存在，避免 Docker 自動建立成 root 權限目錄
mkdir -p $HOME/.config/gcloud
mkdir -p $HOME/.config/rclone

# 建立 Docker Volume (如果尚未存在)
docker volume create ccache-vol > /dev/null
docker volume create uv-cache-vol > /dev/null

echo "🚀 啟動容器中..."
echo "ℹ️  提示: 您將以此終端機直接進入容器 (Attached Mode)。"
echo "ℹ️  輸入 'exit' 可退出並自動清理容器。"

# 3. 啟動容器
# 參數說明:
# --user vscode: 對應 Dockerfile 中的非 root 使用者
# -v ...: 對應 devcontainer.json 的 Mounts
docker run --rm -it \
    --name $CONTAINER_NAME \
    --hostname dev-box-manual \
    --user vscode \
    --net host \
    -v $HOME/.ssh:/home/vscode/.ssh:ro \
    -v $HOME/.gitconfig:/home/vscode/.gitconfig:ro \
    -v $HOME/.config/gcloud:/home/vscode/.config/gcloud \
    -v $HOME/.config/rclone:/home/vscode/.config/rclone \
    -v $(pwd):/workspace \
    -v ccache-vol:/home/vscode/.ccache \
    -v uv-cache-vol:/home/vscode/.cache/uv \
    $IMAGE_NAME \
    /bin/bash
