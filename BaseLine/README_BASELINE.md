# 🚀 Uni-MuMER Baseline - Cải Tiến Hiệu Suất Training

[![Uni-MuMER](https://img.shields.io/badge/Uni--MuMER-NeurIPS'25%20Spotlight-red)](https://github.com/BFlameSwift/Uni-MuMER)
[![LoRA](https://img.shields.io/badge/LoRA-4bit%20Quantization-green)](https://arxiv.org/abs/2106.09685)
[![GPU](https://img.shields.io/badge/GPU-RTX%203070%208GB-blue)]()

> **Fork và cải tiến từ [Uni-MuMER](https://github.com/BFlameSwift/Uni-MuMER)** - Tối ưu để train trên GPU nhỏ và cải thiện monitoring

## 📋 Tổng Quan

Repository này là một **baseline cải tiến** của [Uni-MuMER](https://github.com/BFlameSwift/Uni-MuMER) với các mục tiêu:

- ✅ **Giảm yêu cầu tài nguyên**: Train trên GPU 8GB (RTX 3070) thay vì GPU lớn
- ✅ **Tăng tốc độ**: Đạt 100 epochs trong 8 giờ trên Kaggle (2x T4)
- ✅ **Cải thiện monitoring**: Hiển thị accuracy trực tiếp trong terminal
- ✅ **Tối ưu workflow**: Scripts tự động và hướng dẫn chi tiết

## 🎯 So Sánh với Repository Gốc

| Tính năng | Repository Gốc | Baseline Cải Tiến |
|-----------|----------------|-------------------|
| **Phương pháp** | Full Fine-tuning | **LoRA + 4-bit Quantization** |
| **Memory yêu cầu** | ~25GB VRAM | **~4-6GB VRAM** ✅ |
| **GPU tối thiểu** | A100/H100 | **RTX 3070 (8GB)** ✅ |
| **Tham số train** | 100% (3B params) | **~1-2% (vài triệu params)** ✅ |
| **Monitoring** | Chỉ eval_loss | **Accuracy + Epoch Summary** ✅ |
| **Tốc độ** | Chưa tối ưu | **100 epochs/8 giờ** ✅ |
| **Scripts** | Cơ bản | **Tự động hóa đầy đủ** ✅ |

## 🚀 Tính Năng Chính

### 1. LoRA + 4-bit Quantization

Chuyển đổi từ Full Fine-tuning sang **LoRA (Low-Rank Adaptation) + 4-bit Quantization**:

- **Giảm 80% memory**: Từ ~25GB xuống ~4-6GB
- **Giảm 98% tham số train**: Chỉ train adapter layers
- **Tăng tốc độ**: Nhanh hơn do ít tham số cần update
- **Giữ chất lượng**: LoRA rank 8 vẫn đạt hiệu suất tốt

```yaml
finetuning_type: lora
lora_rank: 8
quantization_bit: 4
quantization_method: bnb
```

### 2. Tối Ưu Tốc Độ Training

**Mục tiêu**: Train 100 epochs trong 8 giờ trên Kaggle (2x T4)

**Các tối ưu**:
- Giảm image resolution: `32768 pixels` (giảm 50%)
- Giảm LoRA rank: `8` (giảm 50% tham số)
- Giảm sequence length: `1024` (giảm 50%)
- Tối ưu batch size: Effective batch = 32 (Kaggle)

**Kết quả**: ✅ Đạt mục tiêu!

### 3. Custom HMER Accuracy Metric

Tạo metric riêng cho HMER để hiển thị **Exact Match Rate** trực tiếp trong training logs:

```python
# Tự động hiển thị trong logs
{'eval_loss': 0.045, 'hmer_exact_match_rate': 0.7234, 'hmer_avg_edit_distance': 0.1234}
```

**Lợi ích**:
- Theo dõi accuracy real-time
- Không cần chạy inference riêng
- Dễ so sánh giữa các epochs

### 4. Epoch Display Callback

Hiển thị kết quả đẹp mắt sau mỗi epoch:

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
================================================================================
```

### 5. Scripts Hỗ Trợ

- **`train_local.sh`**: Script train trên local với kiểm tra đầy đủ
- **`train_kaggle.sh`**: Script train trên Kaggle với multi-GPU
- **`scripts/calculate_accuracy.py`**: Tính accuracy từ checkpoint
- **`scripts/summarize_epoch_results.py`**: Tổng hợp kết quả từ tất cả epochs

## 📦 Cài Đặt

### Quick Start

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/Uni-MuMER-project.git
cd Uni-MuMER-project/BaseLine

# 2. Setup môi trường
bash setup_conda_local.sh

# 3. Giải nén dữ liệu
unzip data.zip -d .

# 4. Train
conda activate unimumer
bash train_local.sh
```

### Yêu Cầu

- **GPU**: RTX 3070 (8GB) hoặc tương đương
- **RAM**: 16GB+ (khuyến nghị 32GB+)
- **Conda**: Miniconda hoặc Anaconda
- **CUDA**: 12.1+

## 🏋️ Training

### Local (RTX 3070)

```bash
conda activate unimumer
bash train_local.sh
```

**Config**: `train/Uni-MuMER-train-local.yaml`
- 5 epochs để test
- Batch size: 2, Gradient accumulation: 8
- LoRA rank: 8, Quantization: 4-bit

### Kaggle (2x T4)

```bash
bash train_kaggle.sh
```

**Config**: `train/Uni-MuMER-train-kaggle.yaml`
- 100 epochs (mục tiêu: 8 giờ)
- Batch size: 4 per GPU × 2 GPU
- Multi-GPU training tự động

## 📊 Monitoring

### Xem Accuracy trong Terminal

Accuracy tự động hiển thị khi training với `compute_hmer_accuracy: true`:

```
{'hmer_exact_match_rate': 0.7234, 'hmer_accuracy': 0.7234, 'hmer_avg_edit_distance': 0.1234}
```

### Tổng Hợp Kết Quả

```bash
# Tổng hợp tất cả epochs
python scripts/summarize_epoch_results.py saves/.../uni-mumer_crohme_local

# Tính accuracy từ checkpoint
python scripts/calculate_accuracy.py saves/.../checkpoint-400
```

## 📈 Kết Quả

### Hiệu Suất Training

| Metric | Gốc | Cải Tiến |
|--------|-----|----------|
| **Memory** | ~25GB | **~4-6GB** ✅ |
| **Tham số train** | 3B (100%) | **Vài triệu (1-2%)** ✅ |
| **Tốc độ** | Chưa tối ưu | **100 epochs/8h** ✅ |
| **GPU yêu cầu** | A100/H100 | **RTX 3070** ✅ |

### Monitoring

- ✅ Accuracy hiển thị trực tiếp trong logs
- ✅ Epoch summary đẹp mắt, dễ đọc
- ✅ Scripts tự động tính và tổng hợp
- ✅ Dễ phát hiện overfitting/underfitting

## 📚 Tài Liệu

- **`HUONG_DAN_TRAIN.md`**: Hướng dẫn training đầy đủ
- **`HUONG_DAN_ACCURACY.md`**: Hướng dẫn theo dõi accuracy
- **`QUICK_START.md`**: Hướng dẫn nhanh
- **`CONDA_COMMANDS.md`**: Lệnh Conda tham khảo

## 🔧 Cấu Trúc Project

```
BaseLine/
├── train/
│   ├── Uni-MuMER-train-local.yaml    # Config cho RTX 3070
│   ├── Uni-MuMER-train-kaggle.yaml  # Config cho Kaggle 2x T4
│   └── LLaMA-Factory/                # Training framework (modified)
│       └── src/llamafactory/train/
│           ├── sft/
│           │   ├── hmer_metric.py           # Custom HMER accuracy metric
│           │   └── workflow.py              # Modified để tích hợp metric
│           └── callbacks_epoch_display.py   # Epoch display callback
├── scripts/
│   ├── calculate_accuracy.py         # Tính accuracy từ checkpoint
│   ├── summarize_epoch_results.py    # Tổng hợp kết quả epochs
│   └── eval_metrics_calculator.py    # Evaluation metrics
├── train_local.sh                    # Script train local
├── train_kaggle.sh                   # Script train Kaggle
└── data/                             # Datasets (CROHME, HME100K, ...)
```

## 🎯 Mục Tiêu Cải Tiến

1. ✅ **Giảm yêu cầu tài nguyên**: Train trên GPU 8GB
2. ✅ **Tăng tốc độ**: 100 epochs trong 8 giờ
3. ✅ **Cải thiện monitoring**: Accuracy real-time
4. ✅ **Tăng tính tiện dụng**: Scripts tự động, hướng dẫn chi tiết

## 📝 Citation

Nếu sử dụng code này, vui lòng cite cả repository gốc và cải tiến:

```bibtex
@article{li2025unimumer,
  title = {Uni-MuMER: Unified Multi-Task Fine-Tuning of Vision-Language Model for Handwritten Mathematical Expression Recognition},
  author = {Li, Yu and Jiang, Jin and Zhu, Jianhua and Peng, Shuai and Wei, Baole and Zhou, Yuxuan and Gao, Liangcai},
  year = {2025},
  journal={arXiv preprint arXiv:2505.23566},
}
```

## 🙏 Acknowledgements

- **Repository gốc**: [BFlameSwift/Uni-MuMER](https://github.com/BFlameSwift/Uni-MuMER)
- **LLaMA-Factory**: [hiyouga/LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory)
- **LoRA**: [LoRA: Low-Rank Adaptation of Large Language Models](https://arxiv.org/abs/2106.09685)

## 📄 License

Apache-2.0 License (giống repository gốc)

---

**⭐ Nếu project này hữu ích, hãy star repository!**

**📧 Liên hệ**: [Email của bạn]

**🔗 Repository gốc**: https://github.com/BFlameSwift/Uni-MuMER

