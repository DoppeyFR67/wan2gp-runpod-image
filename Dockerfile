FROM nvidia/cuda:13.0.0-cudnn-devel-ubuntu22.04

ARG WAN2GP_REPO=https://github.com/deepbeepmeep/Wan2GP.git
ARG WAN2GP_REF=main

ENV DEBIAN_FRONTEND=noninteractive \
    CONDA_DIR=/opt/conda \
    PATH=/opt/conda/envs/wan2gp/bin:/opt/conda/bin:$PATH \
    PYTHONNOUSERSITE=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/workspace/.cache/huggingface \
    XDG_CACHE_HOME=/workspace/.cache

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      ffmpeg \
      git \
      libgl1 \
      libglib2.0-0 \
      libgomp1 \
      libsm6 \
      libxext6 \
      libxrender1 \
      libsndfile1 \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/miniforge.sh \
      https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh \
    && bash /tmp/miniforge.sh -b -p "$CONDA_DIR" \
    && rm /tmp/miniforge.sh \
    && conda create -y -n wan2gp python=3.11.14 pip \
    && conda clean -afy

RUN git clone --depth 1 --branch "$WAN2GP_REF" "$WAN2GP_REPO" /opt/wan2gp

WORKDIR /opt/wan2gp

RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install torch==2.10.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 \
    && python -m pip install -r requirements.txt \
    && python - <<'PY'
import decord
import torch
import transformers
from mmgp import offload, safetensors2, profile_type, quant_router
from optimum.quanto import QModuleMixin

print(f"python smoke OK, torch={torch.__version__}, transformers={transformers.__version__}")
PY

COPY runpod-start.sh /opt/wan2gp/runpod-start.sh

RUN chmod +x /opt/wan2gp/runpod-start.sh \
    && mkdir -p /workspace \
    && useradd -m -u 1000 user \
    && chown -R user:user /opt/wan2gp /workspace

USER user

EXPOSE 7860

ENTRYPOINT ["/opt/wan2gp/runpod-start.sh"]
