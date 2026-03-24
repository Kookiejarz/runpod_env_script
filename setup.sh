#!/bin/bash
set -euo pipefail

# 1. 基础配置
WORKSPACE_DIR=$(pwd)
CACHE_DIR="$WORKSPACE_DIR/.cache"
mkdir -p "$CACHE_DIR/uv" "$CACHE_DIR/tmp" "$CACHE_DIR/hf"

export UV_CACHE_DIR="$CACHE_DIR/uv"
export TMPDIR="$CACHE_DIR/tmp"
export HF_HOME="$CACHE_DIR/hf"
export HF_HUB_ENABLE_HF_TRANSFER=1

echo "🚀 Starting..."

# 2. 安装 uv
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# 3. 环境 A：量化环境 (venv-quant)
echo "🐍 Building (venv-quant)..."
uv venv "$WORKSPACE_DIR/venv-quant" --python 3.12 --clear
source "$WORKSPACE_DIR/venv-quant/bin/activate"

uv pip install \
    llmcompressor \
    transformers accelerate datasets pandas \
    "huggingface_hub[cli,hf_transfer]" \
    torch==2.10.0+cu130 \
    --extra-index-url https://download.pytorch.org/whl/cu130 \
    --no-cache-dir

cat > activate_quant.sh << EOF
export PATH="$HOME/.local/bin:$PATH"
export HF_HOME="$HF_HOME"
export HF_HUB_ENABLE_HF_TRANSFER=1
source $WORKSPACE_DIR/venv-quant/bin/activate
echo "✅ 已进入量化环境 (llmcompressor)"
EOF
deactivate

# 4. 环境 B：推理环境 (venv-vllm)
echo "🐍 Building (venv-vllm)..."
uv venv "$WORKSPACE_DIR/venv-vllm" --python 3.12 --clear
source "$WORKSPACE_DIR/venv-vllm/bin/activate"

uv pip install \
    vllm==0.18.0 \
    "huggingface_hub[cli,hf_transfer]" \
    torch==2.10.0+cu130 \
    --extra-index-url https://download.pytorch.org/whl/cu130 \
    --no-cache-dir \
    --index-strategy unsafe-best-match

cat > activate_vllm.sh << EOF
export PATH="$HOME/.local/bin:$PATH"
export HF_HOME="$HF_HOME"
export HF_HUB_ENABLE_HF_TRANSFER=1
source $WORKSPACE_DIR/venv-vllm/bin/activate
echo "✅ 已进入推理环境 (vLLM)"
EOF
deactivate

# 5. Finish
chmod +x activate_quant.sh activate_vllm.sh
echo "------------------------------------------------"
echo "🎉 Two environments built!"
echo "👉 For model quantization: source activate_quant.sh"
echo "👉 For inference deployment: source activate_vllm.sh"
