[English](./README.md)

# Yet Another ENV Script

![License](https://img.shields.io/github/license/kookiejarz/runpod_env_script)
![Python](https://img.shields.io/badge/python-3.12-blue)
![CUDA](https://img.shields.io/badge/CUDA-13.0-green)
![uv](https://img.shields.io/badge/package%20manager-uv-purple)
![Platform](https://img.shields.io/badge/platform-Linux-yellow)

一个专为 RunPod 及其它 Linux 环境设计的 AI 训练与推理环境一键配置脚本。通过 `uv` 高效管理依赖，并集成 Hugging Face 高性能传输模式。

## 🚀 快速开始

在终端（推荐 RunPod PyTorch 模板）中直接运行：

```bash
curl -sSL https://raw.githubusercontent.com/kookiejarz/runpod_env_script/main/setup.sh | bash
```

## ✨ 主要功能

- **极速安装** — 使用 `uv` 代替传统 `pip`，依赖解析和安装速度大幅提升。
- **环境隔离** — 构建两个独立虚拟环境，彻底避免量化与推理依赖冲突。
- **高性能传输** — 默认开启 `HF_HUB_ENABLE_HF_TRANSFER` 和 `HF_XET_HIGH_PERFORMANCE`，大幅加速模型下载。
- **CUDA 优化** — 自动配置 PyTorch + CUDA 13.0 镜像源，开箱即用硬件加速。

## 🛠️ 使用方法

脚本执行完成后，当前目录会生成两个激活脚本：

**1. 进入量化环境**

```bash
source activate_quant.sh
```

包含：`llmcompressor`, `transformers`, `accelerate`, `datasets`, `pandas`,`torchvision`,`sentencepiece`, `huggingface_hub[cli,hf_transfer]`

**2. 进入推理环境（vLLM）**

```bash
source activate_vllm.sh
```

包含：`vllm==0.18.0`、`huggingface_hub[cli,hf_transfer]`

**3. 退出环境**

```bash
deactivate
```

## ⚙️ 环境变量说明

激活脚本会自动注入以下配置：

| 变量名 | 值 | 作用 |
|--------|----|------|
| `HF_HUB_ENABLE_HF_TRANSFER` | `1` | 启用基于 Rust 的 HF 高速下载器 |
| `HF_XET_HIGH_PERFORMANCE` | `1` | 开启 XetHub 高性能传输模式 |

## 📄 开源协议

本项目基于 [MIT License](./LICENSE) 开源。Copyright (c) 2026 Yunheng Liu。

> **提示：** 运行前请确保已安装 NVIDIA 显卡驱动，并建议预留足够系统盘空间用于存放虚拟环境和模型缓存。
