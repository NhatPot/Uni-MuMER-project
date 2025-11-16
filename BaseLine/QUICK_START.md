# 🚀 Quick Start - Train Uni-MuMER

Hướng dẫn nhanh để train Uni-MuMER trên máy local (RTX 3070) và tiếp tục trên Kaggle.

> 📚 **Xem hướng dẫn chi tiết**: `HUONG_DAN_TRAIN.md`  
> 📊 **Xem hướng dẫn accuracy**: `HUONG_DAN_ACCURACY.md`

## 📋 Bước 1: Setup Môi Trường (Local)

```bash
cd "/home/nhat/Uni-MuMER-project/BaseLine"
bash setup_conda_local.sh
```

## 🏋️ Bước 2: Train Vài Epoch (Local)

```bash
conda activate unimumer
bash train_local.sh
```

Training sẽ chạy 2 epochs với config tối ưu cho RTX 3070 (8GB VRAM).

## 📤 Bước 3: Push Lên GitHub

```bash
cd "/home/nhat/Uni-MuMER-project"
git init
git add .
git commit -m "Uni-MuMER training setup"
git remote add origin https://github.com/YOUR_USERNAME/Nhan-Dien-Ky-Tu-Toan-Hoc.git
git push -u origin main
```

**Lưu ý**: Thay `YOUR_USERNAME` bằng username GitHub của bạn.

## 🚀 Bước 4: Train Trên Kaggle

1. Upload notebook `UniMER_Kaggle_Setup.ipynb` lên Kaggle
2. Sửa cell clone repo: thay `YOUR_USERNAME` bằng username của bạn
3. Chạy notebook từ đầu đến cuối

## 📚 Chi Tiết

Xem file `HUONG_DAN_TRAIN.md` để biết chi tiết đầy đủ.

## ⚙️ Cấu Hình

- **Local**: `train/Uni-MuMER-train-local.yaml` (tối ưu cho RTX 3070)
- **Kaggle**: `train/Uni-MuMER-train.yaml` (cho GPU lớn hơn)

## 🔧 Troubleshooting

- **OOM Error**: Giảm `per_device_train_batch_size` trong config
- **CUDA Error**: Kiểm tra `nvidia-smi` và cài lại PyTorch
- **Import Error**: Đảm bảo đã kích hoạt môi trường: `conda activate unimumer`

