# Hướng dẫn Train chỉ với Dataset CROHME

## 📊 Thông tin Dataset

Bạn đang train với **3 tập dữ liệu CROHME**:
- **CROHME 2014**: 986 samples
- **CROHME 2016**: 1147 samples  
- **CROHME 2019**: 1199 samples
- **Tổng cộng**: ~3,332 samples

## ✅ Đã cấu hình xong!

Config đã được cập nhật trong `train/Uni-MuMER-train-local.yaml`:
- ✅ Chỉ train với `crohme_2014, crohme_2016, crohme_2019`
- ✅ Output directory: `saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_only`
- ✅ Sử dụng LoRA + Quantization 4-bit (tiết kiệm memory)
- ✅ `num_train_epochs: 2.0` (có thể giảm xuống 1.0 nếu muốn train nhanh hơn)

## 🚀 Cách chạy

### Bước 1: Đảm bảo môi trường đã sẵn sàng
```bash
cd /home/nhat/Uni-MuMER-project/BaseLine
conda activate unimumer
```

### Bước 2: Chạy training
```bash
bash train_local.sh
```

## ⏱️ Thời gian train ước tính

Với ~3,332 samples:
- **Batch size**: 1
- **Gradient accumulation**: 16 (effective batch = 16)
- **Epochs**: 2.0
- **Số steps ước tính**: ~416 steps/epoch × 2 epochs = ~832 steps

**Thời gian ước tính**: 
- Với RTX 3070 (8GB): Khoảng **2-4 giờ** (tùy thuộc vào tốc độ xử lý ảnh)

## 📈 So sánh với bài báo

Sau khi train xong, bạn có thể:
1. **Đánh giá model** trên test set CROHME
2. **So sánh metrics** với kết quả trong bài báo:
   - Mean Edit Score
   - BLEU-4 Score
   - Character Error Rate (CER)
   - Exact Match Rate

## 🔧 Tùy chỉnh nhanh (nếu muốn train nhanh hơn để test)

Nếu muốn train nhanh hơn để kiểm tra pipeline, có thể sửa trong `train/Uni-MuMER-train-local.yaml`:

```yaml
# Giảm số epoch
num_train_epochs: 1.0  # Thay vì 2.0

# Hoặc giới hạn số samples (chỉ train 1 dataset)
dataset: crohme_2014  # Chỉ train với 2014 (986 samples)
```

## 📂 Output

Checkpoints sẽ được lưu tại:
```
saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_only/
```

Logs và TensorBoard:
- TensorBoard logs: `saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_only/logs/`
- Xem TensorBoard: `tensorboard --logdir saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_only/logs/`

## 📝 Lưu ý

- Training sẽ **nhanh hơn nhiều** so với train toàn bộ 13 datasets
- Kết quả sẽ **phù hợp để so sánh** với bài báo vì chỉ train trên CROHME
- Nếu muốn train lại với tất cả datasets, chỉ cần sửa lại `dataset:` trong config

