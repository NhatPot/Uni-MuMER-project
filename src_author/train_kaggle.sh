#!/bin/bash

# Script train Uni-MuMER trên Kaggle với 2 GPU T4
# Mục tiêu: Train 100 epochs trong 8 giờ

set -e  # Dừng nếu có lỗi

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Train Uni-MuMER trên Kaggle (2x T4)"
echo "Mục tiêu: 100 epochs trong 8 giờ"
echo "=========================================="

# Lấy đường dẫn script hiện tại
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Kiểm tra GPU
echo ""
echo "Kiểm tra GPU..."
python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('Number of GPUs:', torch.cuda.device_count()); [print(f'GPU {i}: {torch.cuda.get_device_name(i)}') for i in range(torch.cuda.device_count())]"

if ! python -c "import torch; assert torch.cuda.is_available(), 'CUDA không khả dụng'" 2>/dev/null; then
    echo -e "${RED}Lỗi: CUDA không khả dụng.${NC}"
    exit 1
fi

# Kiểm tra số GPU
NUM_GPUS=$(python -c "import torch; print(torch.cuda.device_count())" 2>/dev/null)
if [ "$NUM_GPUS" -lt 2 ]; then
    echo -e "${YELLOW}Cảnh báo: Chỉ có ${NUM_GPUS} GPU. Script được thiết kế cho 2 GPU.${NC}"
fi

# Kiểm tra config file
CONFIG_FILE="train/Uni-MuMER-train-kaggle.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Lỗi: Không tìm thấy config file: ${CONFIG_FILE}${NC}"
    exit 1
fi

# Kiểm tra dữ liệu
if [ ! -d "data" ]; then
    echo -e "${RED}Lỗi: Không tìm thấy thư mục data/${NC}"
    exit 1
fi

echo ""
echo "=========================================="
echo "Bắt đầu training..."
echo "=========================================="
echo "Config file: ${CONFIG_FILE}"
echo "Output directory: saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_kaggle"
echo "Method: LoRA (Low-Rank Adaptation) - Tối ưu tốc độ"
echo "Target: 100 epochs trong 8 giờ"
echo ""

# Di chuyển vào thư mục LLaMA-Factory và chạy training
cd train/LLaMA-Factory

# Chạy training với multi-GPU
echo -e "${GREEN}Đang chạy training với ${NUM_GPUS} GPU...${NC}"
# Set biến môi trường để tối ưu CUDA memory allocation
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
# Force torchrun cho multi-GPU (LLaMA-Factory sẽ tự động phát hiện)
export FORCE_TORCHRUN=1

# LLaMA-Factory tự động phát hiện số GPU và sử dụng torchrun
llamafactory-cli train ../Uni-MuMER-train-kaggle.yaml

echo ""
echo "=========================================="
echo -e "${GREEN}Training hoàn tất!${NC}"
echo "=========================================="
echo ""
echo "Checkpoints được lưu tại: saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_kaggle"
echo ""

