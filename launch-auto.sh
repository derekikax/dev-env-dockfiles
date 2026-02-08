#!/bin/bash
set -e

echo "🤖 [自動模式] 準備呼叫 VS Code Dev Containers..."

# 檢查是否安裝了 'gemini' (Antigravity CLI)
if command -v gemini &> /dev/null; then
    echo "✅ 偵測到 Antigravity (Gemini) CLI..."
    echo "🚀 正在開啟 Antigravity / Gemini..."
    gemini .
    exit 0
fi

# 檢查是否安裝了 'devcontainer' CLI
if command -v devcontainer &> /dev/null; then
    echo "✅ 偵測到 devcontainer CLI，正在開啟工作區..."
    devcontainer open .
    exit 0
fi

# 提示用戶在當前 IDE 中重新開啟
echo "💡 提示：您似乎正在使用 Antigravity / Gemini IDE。"
echo "請確保在 IDE 介面中選擇 'Reopen in Container' 以進入開發環境。"

# 保留 VS Code 作為備援，但降低優先級，並移除 Cursor
if command -v code &> /dev/null; then
    echo "✅ 偵測到 VS Code CLI (備援)..."
    echo "🚀 如果您需要切換到 VS Code，請執行："
    echo "   code ."
    exit 0
fi

echo "❌ 錯誤: 找不到 'gemini' 或 'devcontainer' 指令。"
echo "請手動在您的 Antigravity / Gemini IDE 中開啟工作區並 Reopen in Container。"
exit 1
