#!/bin/bash
# ----------------------------------------------------------------
# AI Environment Setup Script (System Disk Version)
# ----------------------------------------------------------------
set -euo pipefail

# 1. 基础配置
export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_XET_HIGH_PERFORMANCE=1

echo "🚀 Starting System Disk Setup..."

# 2. 检测 CUDA 版本，选对应 wheel index
CUDA_VER=$(nvidia-smi | grep -oP "CUDA Version: \K[0-9]+\.[0-9]+" || echo "0.0")
CUDA_MAJOR=$(echo "$CUDA_VER" | cut -d. -f1)

if [ "$CUDA_MAJOR" -ge 13 ]; then
    TORCH_INDEX="cu130"
elif [ "$CUDA_MAJOR" -eq 12 ]; then
    TORCH_INDEX="cu128"
elif [ "$CUDA_MAJOR" -eq 11 ]; then
    TORCH_INDEX="cu118"
else
    echo "⚠️  Could not detect CUDA version, falling back to cu128"
    TORCH_INDEX="cu128"
fi

echo "🔍 Detected CUDA $CUDA_VER → using torch index: $TORCH_INDEX"

# 3. 安装 uv (系统标准路径: ~/.local/bin)
if ! command -v uv &>/dev/null; then
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# 4. 环境 A：量化环境 (venv-quant)
echo "🐍 Building (venv-quant)..."
uv venv venv-quant --python 3.12 --clear
source venv-quant/bin/activate
uv pip install \
    llmcompressor \
    transformers accelerate datasets pandas \
    "huggingface_hub[cli,hf_transfer]" \
    --extra-index-url "https://download.pytorch.org/whl/$TORCH_INDEX" \
    --index-strategy unsafe-best-match
cat > activate_quant.sh << EOF
export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_XET_HIGH_PERFORMANCE=1
source $(pwd)/venv-quant/bin/activate
echo "✅ Activated (llmcompressor) on System Disk"
EOF
deactivate 2>/dev/null || true

# 5. 环境 B：推理环境 (venv-vllm)
echo "🐍 Building (venv-vllm)..."
uv venv venv-vllm --python 3.12 --clear
source venv-vllm/bin/activate
uv pip install \
    vllm==0.18.0 \
    "huggingface_hub[cli,hf_transfer]" \
    --extra-index-url "https://download.pytorch.org/whl/$TORCH_INDEX" \
    --index-strategy unsafe-best-match
cat > activate_vllm.sh << EOF
export HF_HUB_ENABLE_HF_TRANSFER=1
export HF_XET_HIGH_PERFORMANCE=1
source $(pwd)/venv-vllm/bin/activate
echo "✅ Activated (vLLM) on System Disk"
EOF
deactivate 2>/dev/null || true

# 6. 完成
chmod +x activate_quant.sh activate_vllm.sh
echo "------------------------------------------------"
echo "🎉 All environments are ready on System Disk."
echo "👉 source activate_quant.sh"
echo "👉 source activate_vllm.sh"
