# 開發環境配置 (Dev Env Dockfiles)

本倉庫提供了一套高度優化的通用開發環境，專為 **WSL 2** 與 **VS Code Dev Containers** 設計。
整合了 Python (AI/Data Stack), Node.js, C++ 工具鏈以及現代化命令行工具。

## 檔案說明

### 1. `Dockerfile` (核心配置)

這是本專案的主要開發環境映像檔，具有以下特點：

- **基礎系統**: 基於 `mcr.microsoft.com/devcontainers/base:ubuntu-22.04`，針對開發容器優化。
- **高效能工具**:
  - **uv**: 極速 Python 套件管理器 (替代 pip)。
  - **Just**: 現代化任務執行器 (替代 Make)。
  - **ccache**: C/C++ 編譯快取。
- **預裝語言與函式庫**:
  - **Python**: 預裝 Data (Pandas, Polars, DuckDB), AI (OpenAI, Anthropic), Scraping (Playwright, BeautifulSoup) 等常用戰略庫。
  - **Node.js**: LTS v20 版本。
  - **C++/System**: 包含 build-essential, cmake, ninja, gdb-multiarch 以及 RISC-V Cross Compiler (`gcc-riscv64-linux-gnu`)。
- **CLI 生產力工具**:
  - `ripgrep` (rg), `fd`, `fzf`, `bat`, `jq`。
  - **Starship**: 極速且客製化的 Shell Prompt。
  - **Direnv**: 目錄級環境變數管理。
- **WSL 2 優化**:
  - 預設使用非 root 使用者 (`vscode`)。
  - 修正了各類權限與路徑映射問題。

### 2. `.devcontainer/devcontainer.json`

VS Code Dev Container 的設定檔。

- 自動掛載 WSL Host 的 SSH Key (`~/.ssh`), Git Config (`~/.gitconfig`), Google Cloud (`~/.config/gcloud`) 與 Rclone 設定。
- 設定快取卷 (Volume) 以加速 ccache 與 uv 下載。

### 3. 啟動腳本 (Launch Scripts)

本專案提供兩種啟動模式的腳本：

- **`launch-auto.sh` (自動模式 - 推薦)**
  - 嘗試呼叫 `devcontainer` CLI 或 `code` / `cursor` 來啟動 VS Code 環境。
  - 這是最標準的使用方式，確保完全整合 IDE 功能。

- **`launch-manual.sh` (手動模式 - 靈活)**
  - 使用純 Docker 命令 (`docker run`) 啟動容器。
  - 自動掛載所有必要的設定檔與 Volume。
  - 適合不開啟 IDE，僅在終端機進行快速測試或維護時使用。

## 使用方式

### 透過 VS Code (推薦)

執行以下腳本自動開啟：

```bash
./launch-auto.sh
```

或者手動在 VS Code 中選擇 **"Reopen in Container"**。

### 透過 Docker CLI (手動)

執行以下腳本進入容器終端機：

```bash
./launch-manual.sh
```
