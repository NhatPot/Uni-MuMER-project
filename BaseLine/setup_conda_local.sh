#!/bin/bash

# Script setup môi trường conda cho Uni-MuMER trên máy local
# Cấu hình: E5-2680v4, RTX 3070 (8GB VRAM), 144GB RAM

# Không dùng set -e để có thể retry khi lỗi kết nối

echo "=========================================="
echo "Setup môi trường Conda cho Uni-MuMER"
echo "=========================================="

# Màu sắc cho output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kiểm tra conda đã cài chưa
if ! command -v conda &> /dev/null; then
    echo -e "${YELLOW}Conda chưa được cài đặt. Vui lòng cài Miniconda hoặc Anaconda trước.${NC}"
    echo "Tải Miniconda: https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

echo -e "${GREEN}✓ Conda đã được cài đặt${NC}"

# Tên môi trường
ENV_NAME="unimumer"
PYTHON_VERSION="3.10"

# Kiểm tra môi trường đã tồn tại chưa
if conda env list | grep -q "^${ENV_NAME} "; then
    echo -e "${YELLOW}Môi trường ${ENV_NAME} đã tồn tại.${NC}"
    read -p "Bạn có muốn xóa và tạo lại không? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Đang xóa môi trường cũ..."
        conda env remove -n ${ENV_NAME} -y
    else
        echo "Sử dụng môi trường hiện có."
        echo "Để kích hoạt: conda activate ${ENV_NAME}"
        exit 0
    fi
fi

echo "=========================================="
echo "1. Tạo môi trường conda với Python ${PYTHON_VERSION}"
echo "=========================================="
conda create -n ${ENV_NAME} python=${PYTHON_VERSION} -y

echo "=========================================="
echo "2. Kích hoạt môi trường và cài đặt PyTorch"
echo "=========================================="
# Kích hoạt môi trường và cài PyTorch với CUDA 12.1 (tương thích RTX 3070)
eval "$(conda shell.bash hook)"
conda activate ${ENV_NAME}

# Hàm retry với conda install
install_pytorch_conda() {
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Thử cài PyTorch với conda (lần $attempt/$max_attempts)..."
        if conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y; then
            echo -e "${GREEN}✓ Cài đặt PyTorch thành công với conda${NC}"
            return 0
        else
            echo -e "${YELLOW}Lỗi kết nối (lần $attempt). Đợi 10 giây trước khi thử lại...${NC}"
            sleep 10
            attempt=$((attempt + 1))
        fi
    done
    
    return 1
}

# Hàm cài PyTorch với pip (phương án dự phòng)
install_pytorch_pip() {
    echo -e "${YELLOW}Cài PyTorch với pip thay vì conda (ổn định hơn với kết nối không ổn định)...${NC}"
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
}

# Thử cài PyTorch với conda trước, nếu thất bại thì dùng pip
echo "Đang cài đặt PyTorch với CUDA 12.1..."
if ! install_pytorch_conda; then
    echo -e "${YELLOW}Cài đặt PyTorch với conda thất bại sau nhiều lần thử.${NC}"
    echo "Chuyển sang cài đặt với pip (ổn định hơn)..."
    install_pytorch_pip
fi

echo "=========================================="
echo "3. Upgrade pip"
echo "=========================================="
# Retry cho pip upgrade
for i in {1..3}; do
    if pip install --upgrade pip; then
        break
    else
        echo "Retry pip upgrade (lần $i)..."
        sleep 5
    fi
done

echo "=========================================="
echo "4. Cài đặt các dependencies từ requirements_training.txt"
echo "=========================================="
# Lấy đường dẫn script hiện tại
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Hàm cài requirements với retry
install_requirements() {
    local req_file=$1
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Đang cài đặt từ $req_file (lần $attempt/$max_attempts)..."
        if pip install -r "$req_file"; then
            echo -e "${GREEN}✓ Cài đặt từ $req_file thành công${NC}"
            return 0
        else
            echo -e "${YELLOW}Lỗi khi cài đặt (lần $attempt). Đợi 5 giây trước khi thử lại...${NC}"
            sleep 5
            attempt=$((attempt + 1))
        fi
    done
    
    echo -e "${YELLOW}Cảnh báo: Không thể cài đặt từ $req_file sau $max_attempts lần thử${NC}"
    return 1
}

if [ -f "requirements_training.txt" ]; then
    install_requirements "requirements_training.txt"
else
    echo -e "${YELLOW}Cảnh báo: Không tìm thấy requirements_training.txt${NC}"
    echo "Đang cài đặt từ requirements.txt..."
    if [ -f "requirements.txt" ]; then
        install_requirements "requirements.txt"
    else
        echo -e "${YELLOW}Không tìm thấy requirements.txt. Vui lòng kiểm tra lại.${NC}"
    fi
fi

echo "=========================================="
echo "5. Clone LLaMA-Factory nếu chưa có"
echo "=========================================="
if [ ! -d "train/LLaMA-Factory" ]; then
    echo "Đang clone LLaMA-Factory..."
    mkdir -p train
    cd train
    # Retry cho git clone
    for i in {1..3}; do
        if git clone https://github.com/hiyouga/LLaMA-Factory.git; then
            break
        else
            echo "Retry git clone (lần $i)..."
            sleep 5
        fi
    done
    cd LLaMA-Factory
    # Retry cho pip install
    for i in {1..3}; do
        if pip install -e .; then
            break
        else
            echo "Retry pip install LLaMA-Factory (lần $i)..."
            sleep 5
        fi
    done
    cd "$SCRIPT_DIR"
else
    echo "LLaMA-Factory đã tồn tại. Cập nhật..."
    cd train/LLaMA-Factory
    git pull || echo "Không thể pull, sử dụng version hiện có"
    # Retry cho pip install
    for i in {1..3}; do
        if pip install -e .; then
            break
        else
            echo "Retry pip install LLaMA-Factory (lần $i)..."
            sleep 5
        fi
    done
    cd "$SCRIPT_DIR"
fi

echo "=========================================="
echo "6. Tải NLTK data"
echo "=========================================="
python -c "import nltk; nltk.download('punkt')" || echo "Không thể tải NLTK data, có thể bỏ qua"

echo "=========================================="
echo "7. Kiểm tra cài đặt"
echo "=========================================="
echo "Kiểm tra Python version:"
python --version

echo ""
echo "Kiểm tra PyTorch và CUDA:"
python -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available()); print('CUDA version:', torch.version.cuda if torch.cuda.is_available() else 'N/A'); print('GPU name:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A')"

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Setup hoàn tất!${NC}"
echo "=========================================="
echo ""
echo "Để kích hoạt môi trường, chạy:"
echo "  conda activate ${ENV_NAME}"
echo ""
echo "Để train mô hình, chạy:"
echo "  bash train_local.sh"
echo ""

