#!/bin/bash

# Script train Uni-MuMER trên máy local
# Cấu hình: E5-2680v4, RTX 3070 (8GB VRAM), 144GB RAM

set -e  # Dừng nếu có lỗi

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Train Uni-MuMER trên máy local"
echo "=========================================="

# Lấy đường dẫn script hiện tại
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Tên môi trường
ENV_NAME="unimumer"

# Kiểm tra môi trường conda
if ! command -v conda &> /dev/null; then
    echo -e "${RED}Lỗi: Conda chưa được cài đặt.${NC}"
    exit 1
fi

# Kích hoạt môi trường
echo -e "${GREEN}Kích hoạt môi trường conda: ${ENV_NAME}${NC}"
eval "$(conda shell.bash hook)"
if ! conda activate ${ENV_NAME}; then
    echo -e "${RED}Lỗi: Không thể kích hoạt môi trường ${ENV_NAME}${NC}"
    echo "Vui lòng chạy: bash setup_conda_local.sh trước"
    exit 1
fi

# Kiểm tra GPU
echo ""
echo "Kiểm tra GPU..."
python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A')"

if ! python -c "import torch; assert torch.cuda.is_available(), 'CUDA không khả dụng'" 2>/dev/null; then
    echo -e "${YELLOW}Cảnh báo: CUDA không khả dụng. Training sẽ chạy trên CPU (rất chậm).${NC}"
    read -p "Bạn có muốn tiếp tục không? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Kiểm tra LLaMA-Factory
if [ ! -d "train/LLaMA-Factory" ]; then
    echo -e "${RED}Lỗi: Không tìm thấy LLaMA-Factory${NC}"
    echo "Vui lòng chạy: bash setup_conda_local.sh trước"
    exit 1
fi

# Kiểm tra config file
CONFIG_FILE="train/Uni-MuMER-train-local.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Lỗi: Không tìm thấy config file: ${CONFIG_FILE}${NC}"
    exit 1
fi

# Kiểm tra dữ liệu
if [ ! -d "data" ]; then
    echo -e "${YELLOW}Cảnh báo: Không tìm thấy thư mục data/${NC}"
    echo "Vui lòng giải nén data.zip vào thư mục src_author/"
    read -p "Bạn có muốn tiếp tục không? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "Bắt đầu training..."
echo "=========================================="
echo "Config file: ${CONFIG_FILE}"
echo "Output directory: saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_local"
echo "Method: LoRA (Low-Rank Adaptation) - Tiết kiệm memory hơn full fine-tuning"
echo ""

# Di chuyển vào thư mục LLaMA-Factory và chạy training
cd train/LLaMA-Factory

# Chạy training với tối ưu memory
echo -e "${GREEN}Đang chạy training...${NC}"
# Set biến môi trường để tối ưu CUDA memory allocation
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
llamafactory-cli train ../Uni-MuMER-train-local.yaml

echo ""
echo "=========================================="
echo -e "${GREEN}Training hoàn tất!${NC}"
echo "=========================================="
echo ""
echo "Checkpoints được lưu tại: saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_local"
echo ""
echo "Để tiếp tục train trên Kaggle, push code lên GitHub và sử dụng notebook UniMER_Kaggle_Setup.ipynb"
echo ""

