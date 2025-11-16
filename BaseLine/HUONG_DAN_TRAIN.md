# 📚 Hướng Dẫn Train Uni-MuMER

Hướng dẫn chi tiết để train mô hình Uni-MuMER trên máy local và Kaggle.

## 📋 Mục Lục

1. [Setup Môi Trường](#setup-môi-trường)
2. [Chuẩn Bị Dữ Liệu](#chuẩn-bị-dữ-liệu)
3. [Training với LoRA + Quantization](#training-với-lora--quantization)
4. [Train Chỉ với CROHME](#train-chỉ-với-crohme)
5. [Tối Ưu Training (100 Epochs trong 8 giờ)](#tối-ưu-training)
6. [Hiển Thị Kết Quả Epoch](#hiển-thị-kết-quả-epoch)
7. [Train trên Kaggle](#train-trên-kaggle)
8. [Troubleshooting](#troubleshooting)

---

## 🖥️ Cấu Hình Máy

- **CPU**: Intel E5-2680v4
- **GPU**: NVIDIA RTX 3070 (8GB VRAM)
- **RAM**: 144GB
- **OS**: Linux

---

## 📋 Setup Môi Trường

### Cách 1: Tự động (Khuyến nghị)

```bash
cd "/home/nhat/Uni-MuMER-project/BaseLine"
bash setup_conda_local.sh
```

Script này sẽ:
- Tạo môi trường conda `unimumer` với Python 3.10
- Cài đặt PyTorch với CUDA 12.1
- Cài đặt tất cả dependencies
- Clone và cài đặt LLaMA-Factory

### Cách 2: Thủ công

Xem `CONDA_COMMANDS.md` để biết các lệnh conda chi tiết.

---

## 📦 Chuẩn Bị Dữ Liệu

1. **Giải nén dữ liệu**:
   ```bash
   cd "/home/nhat/Uni-MuMER-project/BaseLine"
   unzip data.zip -d .
   ```

2. **Kiểm tra cấu trúc**:
   ```
   data/
   ├── CROHME/
   ├── CROHME2023/
   ├── HME100K/
   ├── Im2LaTeXv2/
   ├── MathWriting/
   └── MNE/
   ```

---

## 🏋️ Training với LoRA + Quantization

### Tại sao dùng LoRA + Quantization?

| Phương pháp | Memory cần | Tham số train |
|------------|------------|---------------|
| Full Fine-tuning | ~25GB | 100% (3B params) |
| LoRA | ~8-10GB | ~1-2% (vài triệu params) |
| **LoRA + 4-bit Quantization** | **~4-6GB** | **~1-2%** ✅ |

**Quantization 4-bit** giảm model từ 6-7GB xuống ~3-4GB khi load!

### Cấu hình đã được tối ưu

File `train/Uni-MuMER-train-local.yaml`:
- ✅ `finetuning_type: lora`
- ✅ `quantization_bit: 4` (BitsAndBytes)
- ✅ `lora_rank: 8`, `lora_alpha: 16`
- ✅ `per_device_train_batch_size: 2`
- ✅ `gradient_accumulation_steps: 8`
- ✅ `compute_hmer_accuracy: true` (hiển thị accuracy trong terminal)

### Chạy Training

```bash
cd "/home/nhat/Uni-MuMER-project/BaseLine"
conda activate unimumer
bash train_local.sh
```

---

## 🎯 Train Chỉ với CROHME

Để train chỉ với dataset CROHME (so sánh với bài báo):

### Thông tin Dataset

- **CROHME 2014**: 986 samples
- **CROHME 2016**: 1147 samples  
- **CROHME 2019**: 1199 samples
- **Tổng cộng**: ~3,332 samples

### Config đã được cập nhật

File `train/Uni-MuMER-train-local.yaml`:
- ✅ `dataset: crohme_2014, crohme_2016, crohme_2019`
- ✅ `output_dir: .../uni-mumer_crohme_local`
- ✅ `num_train_epochs: 5.0` (test trên local)

### Thời gian train ước tính

- **Local (RTX 3070)**: 5 epochs ≈ 30-60 phút
- **Kaggle (2x T4)**: 100 epochs ≈ 8 giờ

---

## ⚡ Tối Ưu Training

### Mục tiêu: 100 Epochs trong 8 giờ (Kaggle)

### Các tối ưu đã áp dụng

1. **Giảm Image Resolution**: `image_max_pixels: 32768` (giảm 50%)
2. **Giảm LoRA Rank**: `lora_rank: 8` (giảm 50% tham số)
3. **Giảm Sequence Length**: `cutoff_len: 1024` (giảm 50%)
4. **Giảm Workers**: Giảm overhead I/O
5. **Tăng Batch Size**: Tận dụng VRAM (Kaggle: 4 per GPU × 2 GPU)

### Tính toán thời gian

**Kaggle (2x T4)**:
- Effective batch: 32
- Steps/epoch: ~104
- 100 epochs: 10,400 steps
- Cần: **2.77 giây/step** ✅ (Khả thi!)

**Local (RTX 3070)**:
- Effective batch: 16
- Steps/epoch: ~208
- 5 epochs: 1,040 steps
- Thời gian: **30-60 phút**

### Config Files

- **Local**: `train/Uni-MuMER-train-local.yaml` (test 5 epochs)
- **Kaggle**: `train/Uni-MuMER-train-kaggle.yaml` (100 epochs)

---

## 📊 Hiển Thị Kết Quả Epoch

### Tự động hiển thị trong terminal

Sau mỗi epoch evaluation, bạn sẽ thấy:

```
================================================================================
                            EPOCH 1.00 SUMMARY                             
================================================================================

📊 Training Metrics:
  • Loss:              0.0573
  • Learning Rate:     0.000381692

📈 Evaluation Metrics:
  • Eval Loss:         0.0450
  • Eval Perplexity:   1.0460

🎯 HMER Accuracy:
  • Exact Match Rate:  72.34% (0.7234)
  • Avg Edit Distance: 0.1234

⏱️  Progress: 19.1% (208/1045 steps)
================================================================================
```

### Xem kết quả từng epoch

```bash
# Tổng hợp tất cả epochs
python scripts/summarize_epoch_results.py saves/.../uni-mumer_crohme_local

# Xem kết quả epoch cụ thể
cat saves/.../checkpoint-3/eval_results.json | python -m json.tool
```

### Cấu trúc files sau training

```
saves/.../uni-mumer_crohme_local/
├── checkpoint-1/
│   └── eval_results.json  # ← Kết quả epoch 1
├── checkpoint-2/
│   └── eval_results.json  # ← Kết quả epoch 2
├── trainer_state.json     # ← Tổng hợp
└── epoch_results_summary.csv  # ← Tổng hợp (sau khi chạy script)
```

---

## 🚀 Train trên Kaggle

### Bước 1: Push code lên GitHub

```bash
cd "/home/nhat/Uni-MuMER-project"
git add .
git commit -m "Uni-MuMER training setup"
git push
```

### Bước 2: Tạo Kaggle Notebook

1. Đăng nhập [Kaggle](https://www.kaggle.com/)
2. Vào **Notebooks** → **New Notebook**
3. Chọn **2x T4 GPU** accelerator

### Bước 3: Chạy Training

Sử dụng notebook `UniMER_Kaggle_Setup.ipynb` hoặc chạy trực tiếp:

```bash
bash train_kaggle.sh
```

Hoặc trong Kaggle notebook:

```python
!bash train_kaggle.sh
```

---

## 🔧 Troubleshooting

### Lỗi OOM (Out of Memory)

1. Giảm `per_device_train_batch_size` xuống 1
2. Tăng `gradient_accumulation_steps`
3. Giảm `image_max_pixels` xuống 16384
4. Giảm `lora_rank` xuống 4

### Lỗi CUDA

```bash
# Kiểm tra CUDA version
nvidia-smi
python -c "import torch; print(torch.version.cuda)"

# Cài lại PyTorch nếu cần
conda activate unimumer
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia -y
```

### Training quá chậm

1. Giảm `preprocessing_num_workers` và `dataloader_num_workers`
2. Tăng `per_device_train_batch_size` nếu còn VRAM
3. Giảm `image_max_pixels`

---

## 📝 Lưu Ý Quan Trọng

1. **Luôn kích hoạt môi trường conda**:
   ```bash
   conda activate unimumer
   ```

2. **Monitor GPU usage**:
   ```bash
   watch -n 1 nvidia-smi
   ```

3. **Lưu checkpoints thường xuyên** để có thể resume

4. **Không push dữ liệu và checkpoints** lên GitHub (quá lớn)

---

## 🎯 Tóm Tắt Workflow

```
Local Machine (RTX 3070)
├── Setup conda environment
├── Train vài epoch (5 epochs) để test
└── Push code lên GitHub
    │
    └──> Kaggle (2x T4)
        ├── Clone từ GitHub
        ├── Train 100 epochs (8 giờ)
        └── Đánh giá mô hình
```

---

**Xem thêm**: `HUONG_DAN_ACCURACY.md` để biết cách theo dõi accuracy chi tiết.
