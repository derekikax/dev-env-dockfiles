#!/bin/bash
set -e

echo "🤖 [自動模式] 準備呼叫 VS Code Dev Containers..."

# 檢查是否安裝了 'gemini' (Antigravity CLI)
if command -v gemini &> /dev/null; then
    echo "✅ 偵測到 Gemini CLI (Antigravity)..."
    echo "🚀 正在開啟 Antigravity..."
    gemini .
    exit 0
fi

# 檢查是否安裝了 'devcontainer' CLI (來自 npm install -g @devcontainers/cli)
if command -v devcontainer &> /dev/null; then
    echo "✅ 偵測到 devcontainer CLI，正在開啟工作區..."
    devcontainer open .
    exit 0
fi

# 檢查是否安裝了 'code' (VS Code CLI)
if command -v code &> /dev/null; then
    echo "✅ 偵測到 VS Code CLI..."
    echo "🚀 正在開啟 VS Code，請在視窗開啟後："
    echo "   1. 點擊右下角通知 'Reopen in Container'"
    echo "   2. 或按 F1 輸入 'Dev Containers: Reopen in Container'"
    code .
    exit 0
fi

if command -v cursor &> /dev/null; then
    echo "✅ 偵測到 Cursor CLI..."
    echo "🚀 正在開啟 Cursor，請在視窗開啟後手動選擇 Reopen in Container。"
    cursor .
    exit 0
fi

echo "❌ 錯誤: 找不到 'devcontainer', 'code' 或 'cursor' 指令。"
echo "請手動開啟您的 IDE 並載入此專案資料夾。"
exit 1
