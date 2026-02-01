# 使用 Ubuntu 22.04 作為基底
FROM ubuntu:22.04

# 環境變數設定
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 安裝系統工具與相依套件
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    cmake \
    ninja-build \
    openssh-client \
    vim \
    sudo \
    locales \
    jq \
    ripgrep \
    fd-find \
    fzf \
    bat \
    && rm -rf /var/lib/apt/lists/*

# 設定工具別名 (fd-find -> fd, bat -> batcat)
RUN ln -s $(which fdfind) /usr/local/bin/fd && \
    ln -s $(which batcat) /usr/local/bin/bat

# 安裝 Starship (Prompt)
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y

# 安裝 Direnv
RUN curl -sfL https://direnv.net/install.sh | bash

# 安裝 Just (Command Runner)
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# 安裝 uv (從官方 image 複製)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# 安裝 Miniconda
ENV CONDA_DIR=/opt/conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# 將 Conda 加入 PATH
ENV PATH=$CONDA_DIR/bin:$PATH

# 安裝 Python 常用庫
RUN pip install --no-cache-dir numpy pandas requests python-dotenv tqdm

# Shell 設定 (.bashrc)
RUN echo 'eval "$(starship init bash)"' >> /root/.bashrc && \
    echo 'eval "$(direnv hook bash)"' >> /root/.bashrc && \
    echo "alias ll='ls -alF'" >> /root/.bashrc && \
    echo "alias g='git'" >> /root/.bashrc

# 複製並設定 Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 設定工作目錄
WORKDIR /workspace

# 設定入口點
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
