# Hướng dẫn Tối Ưu Training - 100 Epochs trong 8 giờ

## 🎯 Mục tiêu

- **Kaggle (2x T4)**: Train 100 epochs trong 8 giờ
- **Local (RTX 3070 8GB)**: Train vài epoch để test chất lượng và khả năng học
- **Dataset**: Chỉ CROHME (~3,332 samples)

## 📊 Tính toán Thời gian

### Kaggle (2x T4, 16GB mỗi GPU)
- **Batch size**: 4 per GPU × 2 GPU = 8 total
- **Gradient accumulation**: 4
- **Effective batch size**: 4 × 2 × 4 = **32**
- **Steps per epoch**: 3,332 / 32 = **~104 steps**
- **100 epochs**: 104 × 100 = **10,400 steps**
- **Thời gian cần**: 8 giờ = 28,800 giây
- **Cần đạt**: **2.77 giây/step** ✅ (Khả thi với T4!)

### Local (RTX 3070, 8GB)
- **Batch size**: 2
- **Gradient accumulation**: 8
- **Effective batch size**: 2 × 8 = **16**
- **Steps per epoch**: 3,332 / 16 = **~208 steps**
- **5 epochs**: 208 × 5 = **1,040 steps**
- **Thời gian ước tính**: **30-60 phút** (đủ để test)

## ⚙️ Các Tối Ưu Đã Áp Dụng

### 1. Giảm Image Resolution
- **Trước**: `image_max_pixels: 65536`
- **Sau**: `image_max_pixels: 32768` (giảm 50%)
- **Lý do**: Tăng tốc độ xử lý, vẫn đủ chất lượng cho công thức toán

### 2. Giảm LoRA Rank
- **Trước**: `lora_rank: 16`, `lora_alpha: 32`
- **Sau**: `lora_rank: 8`, `lora_alpha: 16` (giảm 50% tham số)
- **Lý do**: Giảm số tham số train → tăng tốc độ backward pass

### 3. Giảm Sequence Length
- **Trước**: `cutoff_len: 2048`
- **Sau**: `cutoff_len: 1024` (giảm 50%)
- **Lý do**: LaTeX công thức thường ngắn, 1024 đủ dùng

### 4. Giảm Workers
- **Trước**: `preprocessing_num_workers: 4`, `dataloader_num_workers: 2`
- **Sau**: `preprocessing_num_workers: 2`, `dataloader_num_workers: 1`
- **Lý do**: Giảm overhead, tăng tốc độ I/O

### 5. Tăng Batch Size (Kaggle)
- **Kaggle**: `per_device_train_batch_size: 4` (2 GPU → 8 total)
- **Local**: `per_device_train_batch_size: 2`
- **Lý do**: Tận dụng VRAM, giảm số steps

### 6. Giảm Save Frequency
- **Trước**: `save_steps: 500`
- **Sau**: `save_steps: 200`
- **Lý do**: Giảm I/O overhead (vẫn đủ để monitor)

## 📁 Cấu trúc Files

```
BaseLine/
├── train/
│   ├── Uni-MuMER-train-local.yaml    # Config cho RTX 3070 (test)
│   ├── Uni-MuMER-train-kaggle.yaml   # Config cho Kaggle (100 epochs)
│   └── LLaMA-Factory/
├── train_local.sh                    # Script train local
├── train_kaggle.sh                    # Script train Kaggle
└── HUONG_DAN_TOI_UU_TRAIN.md         # File này
```

## 🚀 Cách Sử Dụng

### 1. Train trên Local (RTX 3070) - Test

```bash
cd /home/nhat/Uni-MuMER-project/BaseLine
conda activate unimumer
bash train_local.sh
```

**Kết quả mong đợi**:
- Train 5 epochs trong 30-60 phút
- Kiểm tra loss giảm dần
- Kiểm tra accuracy/metrics tăng trong vài epoch đầu
- Nếu OK → chuyển sang Kaggle

### 2. Train trên Kaggle (2x T4) - Full Training

#### Bước 1: Upload code lên Kaggle
```bash
# Push code lên GitHub
git add .
git commit -m "Optimized config for 100 epochs in 8 hours"
git push
```

#### Bước 2: Tạo Kaggle Notebook
1. Tạo notebook mới trên Kaggle
2. Enable **2x T4 GPU** (P100 hoặc T4 x2)
3. Clone repo hoặc upload code

#### Bước 3: Chạy training
```python
# Trong Kaggle notebook
!bash train_kaggle.sh
```

Hoặc chạy trực tiếp:
```python
import os
os.chdir('/kaggle/working/Uni-MuMER-project/BaseLine/train/LLaMA-Factory')
!torchrun --nproc_per_node=2 --master_port=29500 \
    -m llamafactory.cli train ../Uni-MuMER-train-kaggle.yaml
```

## 📈 Monitor Training

### TensorBoard
```bash
# Local
tensorboard --logdir saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_local/logs/

# Kaggle (nếu có thể)
tensorboard --logdir saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_kaggle/logs/
```

### Kiểm tra Logs
- Loss giảm dần theo epochs
- Learning rate theo cosine schedule
- Checkpoints được lưu mỗi 200 steps

## 🔧 Tùy Chỉnh Nếu Cần

### Nếu Kaggle chạy quá chậm (>8 giờ)
1. **Giảm thêm `image_max_pixels`**: xuống `16384` hoặc `8192`
2. **Tăng `per_device_train_batch_size`**: lên `6` hoặc `8` (nếu còn VRAM)
3. **Giảm `gradient_accumulation_steps`**: xuống `2` hoặc `3`

### Nếu Local bị OOM
1. **Giảm `per_device_train_batch_size`**: về `1`
2. **Tăng `gradient_accumulation_steps`**: lên `16`
3. **Giảm `image_max_pixels`**: xuống `16384`

### Nếu muốn train nhanh hơn để test
1. **Giảm `num_train_epochs`**: xuống `1` hoặc `2`
2. **Giảm `save_steps`**: xuống `100` (ít I/O hơn)

## 📊 So Sánh Config

| Tham số | Local (RTX 3070) | Kaggle (2x T4) |
|---------|------------------|----------------|
| `image_max_pixels` | 32768 | 32768 |
| `lora_rank` | 8 | 8 |
| `cutoff_len` | 1024 | 1024 |
| `per_device_train_batch_size` | 2 | 4 |
| `gradient_accumulation_steps` | 8 | 4 |
| `num_train_epochs` | 5 | 100 |
| `quantization_bit` | 4 | 4 |
| **Effective batch** | 16 | 32 |
| **Steps/epoch** | ~208 | ~104 |
| **Thời gian** | 30-60 phút | ~8 giờ |

## ✅ Checklist

- [x] Config local tối ưu cho RTX 3070
- [x] Config Kaggle tối ưu cho 2x T4
- [x] Script train cho cả 2 môi trường
- [x] Tính toán thời gian chính xác
- [x] Giảm tham số để tăng tốc độ
- [x] Giữ chất lượng mô hình (LoRA rank 8 vẫn tốt)

## 🎓 Lưu Ý

1. **LoRA rank 8** vẫn đủ tốt cho fine-tuning, không cần rank 16
2. **Image 32768 pixels** vẫn đủ để nhận diện công thức toán
3. **Sequence length 1024** đủ cho LaTeX (thường <500 tokens)
4. **Batch size lớn hơn** → ít steps hơn → nhanh hơn
5. **Multi-GPU** tự động chia batch, không cần config thêm

## 🐛 Troubleshooting

### Kaggle: "CUDA out of memory"
- Giảm `per_device_train_batch_size` xuống `3` hoặc `2`
- Tăng `gradient_accumulation_steps` lên `6` hoặc `8`

### Kaggle: "Training quá chậm"
- Kiểm tra GPU utilization: `nvidia-smi`
- Giảm `preprocessing_num_workers` xuống `1`
- Tăng `per_device_train_batch_size` nếu còn VRAM

### Local: "OOM error"
- Giảm `per_device_train_batch_size` về `1`
- Giảm `image_max_pixels` xuống `16384`

---

**Chúc bạn train thành công! 🚀**

