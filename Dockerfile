# Base image: Optimized for Dev Containers
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Avoid warnings by switching to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# 1. Install ALL System Dependencies (Root)
# -----------------------------------------------------------------------------
# Combined: Python deps, C++ utils, Net/Utils, CLI tools, Playwright deps
RUN apt-get update && apt-get install -y \
    # Python Build Dependencies
    python3 python3-pip python3-venv libssl-dev libffi-dev \
    # C++ & RISC-V Toolchain
    build-essential cmake ninja-build ccache gdb-multiarch \
    gcc-riscv64-linux-gnu g++-riscv64-linux-gnu qemu-user \
    # Common Network & Utils
    curl wget git openssh-client unzip gnupg apt-transport-https \
    # Document Utilities
    pandoc poppler-utils libmagic1 \
    # Modern CLI Tools
    jq ripgrep fd-find fzf bat \
    # Playwright System Dependencies (for Headless Chrome)
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libasound2 libpango-1.0-0 libcairo2 \
    # Tauri 2.0 Dependencies (WebKit2GTK 4.1)
    libwebkit2gtk-4.1-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Rclone
RUN curl https://rclone.org/install.sh | bash

# Symlink bat (batcat -> bat)
RUN mkdir -p /usr/local/bin && ln -s /usr/bin/batcat /usr/local/bin/bat

# -----------------------------------------------------------------------------
# 2. Install Global Tools (Root)
# -----------------------------------------------------------------------------

# Node.js 20 (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# uv (Fast Python Package Manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Just (Task Runner)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# DuckDB CLI
RUN wget https://github.com/duckdb/duckdb/releases/download/v1.1.3/duckdb_cli-linux-amd64.zip \
    && unzip duckdb_cli-linux-amd64.zip -d /usr/local/bin \
    && rm duckdb_cli-linux-amd64.zip

# Starship (Shell Prompt) & Direnv
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y \
    && curl -sfL https://direnv.net/install.sh | bash

# Rust (for Tauri compilation)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable \
    && . $HOME/.cargo/env \
    && rustup default stable

# -----------------------------------------------------------------------------
# 3. Install Global Python Packages (Root, via uv system)
# -----------------------------------------------------------------------------
# Strategy: Bake core libraries into the image to speed up agent start time
RUN uv pip install --system \
    # Data Science
    duckdb polars pandas \
    # Scraping & Content
    playwright beautifulsoup4 html2text \
    # AI Core
    pydantic tiktoken openai anthropic \
    # Google Ecosystem
    google-generativeai google-cloud-aiplatform \
    google-api-python-client google-auth-httplib2 google-auth-oauthlib \
    # Utilities
    python-dotenv rich httpx typer

# -----------------------------------------------------------------------------
# 4. Global Configuration (Root)
# -----------------------------------------------------------------------------
# Ccache configuration to speed up builds
ENV PATH="/usr/lib/ccache:${PATH}"
# Rust cargo bin to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Switch to dialog for runtime
ENV DEBIAN_FRONTEND=dialog

# Verify core installations
RUN python3 --version && node --version && uv --version && cmake --version \
    && rustc --version && cargo --version

# -----------------------------------------------------------------------------
# 5. User Environment Setup (vscode)
# -----------------------------------------------------------------------------
USER vscode

# Configure .bashrc for the user
RUN echo 'eval "$(starship init bash)"' >> ~/.bashrc \
    && echo 'eval "$(direnv hook bash)"' >> ~/.bashrc \
    && echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc \
    && echo 'source $HOME/.cargo/env' >> ~/.bashrc \
    && echo 'alias ll="ls -alF"' >> ~/.bashrc \
    && echo 'alias python="python3"' >> ~/.bashrc \
    && mkdir -p ~/.cache && chown -R vscode:vscode ~/.cache

# Copy Rust installation to vscode user (Rust was installed as root)
RUN mkdir -p /home/vscode/.cargo \
    && cp -r /root/.cargo/* /home/vscode/.cargo/ \
    && cp -r /root/.rustup /home/vscode/ 2>/dev/null || true \
    && chown -R vscode:vscode /home/vscode/.cargo /home/vscode/.rustup 2>/dev/null || true

WORKDIR /workspace