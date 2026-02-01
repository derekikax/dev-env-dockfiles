#!/bin/bash
set -e

# SSH Key 權限修復
# 檢查宿主機掛載的 SSH 目錄是否存在
if [ -d "/mnt/ssh-readonly" ]; then
    mkdir -p /root/.ssh
    
    # 複製檔案 (忽略權限錯誤，因來源可能是唯讀)
    cp -r /mnt/ssh-readonly/* /root/.ssh/ 2>/dev/null || true
    
    # 強制修正權限 (關鍵步驟)
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/* 2>/dev/null || true
    
    echo "✅ SSH keys copied and permissions fixed."
fi

# Git Config 設定
if [ -f "/mnt/gitconfig" ]; then
    cp /mnt/gitconfig /root/.gitconfig
    echo "✅ Git config copied."
fi

# 執行原定指令
exec "$@"
