# 🎯 Conda Commands - Hướng Dẫn Nhanh

## 📌 Các Lệnh Conda Cơ Bản

### 1. Kiểm tra Conda
```bash
conda --version
conda info
```

### 2. Tạo Môi Trường
```bash
conda create -n unimumer python=3.10 -y
```

### 3. Kích Hoạt Môi Trường
```bash
conda activate unimumer
```
**Sau khi kích hoạt, bạn sẽ thấy `(unimumer)` ở đầu dòng terminal**

### 4. Deactivate (Thoát)
```bash
conda deactivate
```

### 5. Xem Danh Sách Môi Trường
```bash
conda env list
# hoặc
conda info --envs
```

### 6. Xem Packages Đã Cài
```bash
conda activate unimumer
conda list
# hoặc
pip list
```

---

## 🚀 Setup Cho Dự Án Uni-MuMER

### Cách 1: Tự Động (Khuyến nghị)
```bash
cd "/home/nhat/Uni-MuMER-project/src_author"
bash setup_conda_step_by_step.sh
```

### Cách 2: Thủ Công
```bash
# 1. Tạo môi trường
conda create -n unimumer python=3.10 -y

# 2. Kích hoạt
conda activate unimumer

# 3. Cài PyTorch
conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia -y

# 4. Cài dependencies
pip install --upgrade pip
pip install -r requirements.txt

# 5. Tải NLTK data
python -c "import nltk; nltk.download('punkt')"
```

---

## ✅ Kiểm Tra Sau Khi Setup

```bash
# Kích hoạt môi trường
conda activate unimumer

# Kiểm tra Python
python --version

# Kiểm tra PyTorch và GPU
python -c "import torch; print('CUDA:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A')"
```

---

## 💻 Sử Dụng Hàng Ngày

### Bắt đầu làm việc:
```bash
conda activate unimumer
cd "/home/nhat/Uni-MuMER-project/src_author"
```

### Chạy code:
```bash
python scripts/vllm_infer.py ...
```

### Kết thúc:
```bash
conda deactivate  # (tùy chọn)
```

---

## 🔧 Quản Lý Packages

### Cài package mới:
```bash
conda activate unimumer
pip install package_name
```

### Xóa package:
```bash
conda activate unimumer
pip uninstall package_name -y
```

### Backup môi trường:
```bash
conda activate unimumer
pip freeze > requirements_backup.txt
```

---

## 🗑️ Xóa Môi Trường

```bash
# Thoát môi trường trước
conda deactivate

# Xóa môi trường
conda env remove -n unimumer
```

---

## ⚠️ Lưu Ý Quan Trọng

1. **LUÔN kích hoạt môi trường trước khi chạy code:**
   ```bash
   conda activate unimumer  # ← KHÔNG QUÊN!
   ```

2. **Kiểm tra môi trường đang active:**
   ```bash
   echo $CONDA_DEFAULT_ENV
   # Hoặc xem dòng đầu terminal có (unimumer) không
   ```

3. **Nếu terminal mới, luôn kích hoạt lại:**
   ```bash
   conda activate unimumer
   ```

---

## 📚 Đọc Thêm

- Chi tiết đầy đủ: `HUONG_DAN_CONDA.md`
- Quick Start: `QUICK_START_RTX3070.md`

