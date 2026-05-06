#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/wan2gp}"
DATA_DIR="${DATA_DIR:-/workspace}"
PORT="${SERVER_PORT:-${PORT:-7860}}"

export PYTHONNOUSERSITE=1
export HF_HOME="${HF_HOME:-$DATA_DIR/.cache/huggingface}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$DATA_DIR/.cache}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-4}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-4}"
export SDL_AUDIODRIVER="${SDL_AUDIODRIVER:-dummy}"

mkdir -p \
  "$DATA_DIR/ckpts" \
  "$DATA_DIR/outputs" \
  "$DATA_DIR/loras" \
  "$DATA_DIR/settings" \
  "$DATA_DIR/config" \
  "$HF_HOME"

cd "$APP_DIR"

for name in ckpts outputs loras; do
  rm -rf "$APP_DIR/$name"
  ln -s "$DATA_DIR/$name" "$APP_DIR/$name"
done

python - <<'PY'
import torch
print(f"Torch: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")
PY

extra_args=()
if [[ -n "${WAN2GP_ARGS:-}" ]]; then
  read -r -a extra_args <<< "$WAN2GP_ARGS"
fi

exec python wgp.py \
  --listen \
  --server-port "$PORT" \
  --settings "$DATA_DIR/settings" \
  --config "$DATA_DIR/config" \
  "${extra_args[@]}"
