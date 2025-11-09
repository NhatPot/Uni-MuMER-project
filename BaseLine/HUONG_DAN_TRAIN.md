# 📚 Hướng Dẫn Train Uni-MuMER

Hướng dẫn chi tiết để train mô hình Uni-MuMER trên máy local và sau đó tiếp tục trên Kaggle.

## 🖥️ Cấu Hình Máy Của Bạn

- **CPU**: Intel E5-2680v4
- **GPU**: NVIDIA RTX 3070 (8GB VRAM)
- **RAM**: 144GB
- **OS**: Linux

## 📋 Bước 1: Setup Môi Trường Conda (Local)

### Cách 1: Tự động (Khuyến nghị)

```bash
cd "/home/nhat/Uni-MuMER-project/BaseLine"
bash setup_conda_local.sh
```

Script này sẽ:
- Tạo môi trường conda `unimumer` với Python 3.10
- Cài đặt PyTorch với CUDA 12.1
- Cài đặt tất cả dependencies từ `requirements_training.txt`
- Clone và cài đặt LLaMA-Factory
- Tải NLTK data

### Cách 2: Thủ công

```bash
# 1. Tạo môi trường
conda create -n unimumer python=3.10 -y

# 2. Kích hoạt
conda activate unimumer

# 3. Cài PyTorch
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y

# 4. Upgrade pip
pip install --upgrade pip

# 5. Cài dependencies
cd "/home/nhat/Uni-MuMER-project/BaseLine"
pip install -r requirements_training.txt

# 6. Clone LLaMA-Factory
mkdir -p train
cd train
git clone https://github.com/hiyouga/LLaMA-Factory.git
cd LLaMA-Factory
pip install -e .
cd ../..
```

## 📦 Bước 2: Chuẩn Bị Dữ Liệu

1. **Giải nén dữ liệu** (nếu chưa có):
   ```bash
   cd "/home/nhat/Uni-MuMER-project/BaseLine"
   unzip data.zip -d .
   ```

2. **Kiểm tra cấu trúc dữ liệu**:
   ```
   data/
   ├── CROHME/
   ├── CROHME2023/
   ├── HME100K/
   ├── Im2LaTeXv2/
   ├── MathWriting/
   └── MNE/
   ```

## 🏋️ Bước 3: Train Vài Epoch Trên Local

### Chạy training:

```bash
cd "/home/nhat/Uni-MuMER-project/BaseLine"
conda activate unimumer
bash train_local.sh
```

Hoặc chạy trực tiếp:

```bash
conda activate unimumer
cd train/LLaMA-Factory
llamafactory-cli train ../Uni-MuMER-train-local.yaml
```

### Cấu hình cho RTX 3070:

File `train/Uni-MuMER-train-local.yaml` đã được tối ưu cho RTX 3070:
- `per_device_train_batch_size: 1` (nhỏ để tránh OOM)
- `gradient_accumulation_steps: 16` (effective batch size = 16)
- `num_train_epochs: 2.0` (train vài epoch)
- Không dùng DeepSpeed (không cần cho single GPU)

### Monitor training:

Training logs sẽ được lưu tại:
- TensorBoard: `train/LLaMA-Factory/saves/qwen2.5_vl-3b/full/sft/standred/uni-mumer_local/`
- Checkpoints: Tương tự, mỗi 500 steps

Xem TensorBoard:
```bash
conda activate unimumer
cd train/LLaMA-Factory
tensorboard --logdir saves/qwen2.5_vl-3b/full/sft/standred/uni-mumer_local
```

## 📤 Bước 4: Push Lên GitHub

### 4.1. Khởi tạo Git (nếu chưa có)

```bash
cd "/home/nhat/Uni-MuMER-project"
git init
git add .
git commit -m "Initial commit: Uni-MuMER training setup"
```

### 4.2. Tạo repository trên GitHub

1. Đăng nhập GitHub
2. Tạo repository mới (ví dụ: `Nhan-Dien-Ky-Tu-Toan-Hoc`)
3. **KHÔNG** khởi tạo với README, .gitignore, hoặc license

### 4.3. Push code lên GitHub

```bash
# Thêm remote (thay YOUR_USERNAME bằng username của bạn)
git remote add origin https://github.com/YOUR_USERNAME/Nhan-Dien-Ky-Tu-Toan-Hoc.git

# Push code
git branch -M main
git push -u origin main
```

### 4.4. Tạo .gitignore (nếu chưa có)

Tạo file `.gitignore` trong thư mục gốc:

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv

# Conda
.conda/

# Data
data/
*.zip
*.tar.gz

# Model checkpoints
saves/
checkpoints/
*.pt
*.pth
*.bin
*.safetensors

# Logs
logs/
lightning_logs/
tensorboard_logs/
*.log

# Jupyter
.ipynb_checkpoints/
*.ipynb_checkpoints

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# LLaMA-Factory
train/LLaMA-Factory/
```

**Lưu ý**: Không push dữ liệu và checkpoints lên GitHub (quá lớn). Chỉ push code và config.

## 🚀 Bước 5: Train Trên Kaggle

### 5.1. Tạo Kaggle Notebook

1. Đăng nhập [Kaggle](https://www.kaggle.com/)
2. Vào **Notebooks** → **New Notebook**
3. Chọn **GPU** accelerator (P100 hoặc T4 trở lên)

### 5.2. Sử dụng Notebook Setup

1. **Upload notebook** `UniMER_Kaggle_Setup.ipynb` lên Kaggle
2. Hoặc **tạo notebook mới** và copy nội dung từ `UniMER_Kaggle_Setup.ipynb`

### 5.3. Chỉnh sửa notebook

Trong cell clone repository, thay `YOUR_USERNAME` bằng username GitHub của bạn:

```python
# Clone repo
!git clone https://github.com/YOUR_USERNAME/Nhan-Dien-Ky-Tu-Toan-Hoc.git
```

### 5.4. Chạy notebook

1. Chạy từng cell theo thứ tự
2. Notebook sẽ:
   - Cài đặt Miniconda
   - Tạo môi trường Python 3.10
   - Clone repository từ GitHub
   - Cài đặt dependencies
   - Chạy training

### 5.5. Resume từ checkpoint (nếu cần)

Nếu bạn đã train vài epoch trên local, có thể upload checkpoint lên Kaggle dataset và resume:

```python
# Trong notebook, sau khi clone repo
# Copy checkpoint từ Kaggle dataset
!cp -r /kaggle/input/unimer-checkpoints/checkpoint-XXXX /kaggle/working/Nhan-Dien-Ky-Tu-Toan-Hoc/BaseLine/train/LLaMA-Factory/saves/...

# Sau đó resume training
# Sửa Uni-MuMER-train.yaml: resume_from_checkpoint: saves/.../checkpoint-XXXX
```

## 📊 Bước 6: Đánh Giá Mô Hình

Sau khi training xong, đánh giá mô hình:

```bash
# Trên Kaggle hoặc local
conda activate unimumer
cd "/home/nhat/Uni-MuMER-project/BaseLine"

# Đánh giá trên tất cả test sets
bash eval/eval_all.sh -m saves/qwen2.5_vl-3b/full/sft/standred/uni-mumer_full -s test1 -b 32768

# Hoặc đánh giá từng dataset
bash eval/eval_crohme.sh -m saves/... -b 32768
bash eval/eval_hme100k.sh -m saves/... -b 32768
```

## 🔧 Troubleshooting

### Lỗi OOM (Out of Memory)

Nếu gặp lỗi OOM trên RTX 3070:
1. Giảm `per_device_train_batch_size` xuống 1
2. Tăng `gradient_accumulation_steps`
3. Giảm `image_max_pixels` trong config
4. Sử dụng gradient checkpointing (nếu LLaMA-Factory hỗ trợ)

### Lỗi CUDA

```bash
# Kiểm tra CUDA version
nvidia-smi
python -c "import torch; print(torch.version.cuda)"

# Nếu không khớp, cài lại PyTorch với đúng CUDA version
conda activate unimumer
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
```

### Lỗi khi clone LLaMA-Factory

```bash
# Xóa và clone lại
rm -rf train/LLaMA-Factory
cd train
git clone https://github.com/hiyouga/LLaMA-Factory.git
cd LLaMA-Factory
pip install -e .
```

## 📝 Lưu Ý Quan Trọng

1. **Luôn kích hoạt môi trường conda** trước khi chạy:
   ```bash
   conda activate unimumer
   ```

2. **Không push dữ liệu và checkpoints** lên GitHub (quá lớn)

3. **Lưu checkpoints thường xuyên** để có thể resume

4. **Monitor GPU usage**:
   ```bash
   watch -n 1 nvidia-smi
   ```

5. **Training trên RTX 3070 sẽ chậm hơn** so với A100 trên Kaggle, nhưng vẫn có thể train được

## 🎯 Tóm Tắt Workflow

```
Local Machine (RTX 3070)
├── Setup conda environment
├── Train vài epoch (2-3 epochs)
└── Push code lên GitHub
    │
    └──> Kaggle
        ├── Clone từ GitHub
        ├── Resume từ checkpoint (nếu có)
        ├── Train tiếp đến khi hoàn chỉnh
        └── Đánh giá mô hình
```

## 📞 Hỗ Trợ

Nếu gặp vấn đề, kiểm tra:
- Logs trong `train/LLaMA-Factory/saves/.../`
- TensorBoard logs
- GPU memory usage với `nvidia-smi`

