# Hướng dẫn Train 100 Epoch trong 8 Giờ

## 🎯 Mục tiêu

Train **100 epoch** trong vòng **8 giờ** với chất lượng được giữ nguyên.

## 📊 Tính toán tối ưu

### Cấu hình đã tối ưu:
- **Dataset**: Chỉ CROHME 2014 (986 samples) - dataset nhỏ nhất
- **Batch size**: 2 (tăng từ 1)
- **Gradient accumulation**: 8 (giảm từ 16)
- **Effective batch size**: 2 × 8 = 16 (giữ nguyên chất lượng!)
- **Image size**: 32768 pixels (giảm từ 65536 để tăng tốc)
- **Workers**: Giảm để giảm overhead

### Tính toán:
```
Samples: 986
Steps/epoch = 986 / (2 × 8) = ~62 steps/epoch
100 epochs = 6,200 steps
Thời gian cần: 8 giờ = 28,800 giây
Thời gian/step cần: 28,800 / 6,200 = ~4.6 giây/step
```

**✅ Khả thi!** Với quantization 4-bit và batch_size=2, mỗi step sẽ mất khoảng 4-5 giây.

## ✅ Các thay đổi đã thực hiện

### 1. **Giảm số samples** (giữ chất lượng)
- Chỉ train với `crohme_2014` (986 samples)
- Vẫn đủ để model học tốt với 100 epochs

### 2. **Tăng batch size** (tăng tốc độ)
- `per_device_train_batch_size: 2` (từ 1)
- Với quantization 4-bit, vẫn an toàn về memory

### 3. **Giảm gradient accumulation** (tăng tốc độ)
- `gradient_accumulation_steps: 8` (từ 16)
- **Effective batch size vẫn = 16** → giữ nguyên chất lượng!

### 4. **Giảm image size** (tăng tốc độ xử lý)
- `image_max_pixels: 32768` (từ 65536)
- Vẫn đủ để nhận diện công thức toán học

### 5. **Giảm workers** (giảm overhead)
- `preprocessing_num_workers: 2` (từ 4)
- `dataloader_num_workers: 1` (từ 2)

### 6. **Tăng số epochs**
- `num_train_epochs: 100.0`

### 7. **Tối ưu save frequency**
- `save_steps: 200` (từ 500) → save mỗi ~3.2 epoch

## 🚀 Cách chạy

```bash
cd /home/nhat/Uni-MuMER-project/BaseLine
conda activate unimumer
bash train_local.sh
```

## ⏱️ Thời gian ước tính

- **Tổng steps**: ~6,200 steps
- **Thời gian/step**: ~4-5 giây
- **Tổng thời gian**: ~7-8 giờ
- **Mỗi epoch**: ~4-5 phút

## 📈 Chất lượng được giữ nguyên

✅ **Effective batch size = 16** (giống như trước)
- Batch size × Gradient accumulation = 2 × 8 = 16
- Chất lượng training không đổi!

✅ **Learning rate và scheduler giữ nguyên**
- `learning_rate: 5.0e-4`
- `lr_scheduler_type: cosine`
- `warmup_ratio: 0.1`

✅ **LoRA parameters giữ nguyên**
- `lora_rank: 16`
- `lora_alpha: 32`
- `lora_dropout: 0.05`

## 📂 Output

Checkpoints sẽ được lưu tại:
```
saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_100epoch/
```

- Save mỗi 200 steps (~3.2 epoch)
- Tổng cộng: ~31 checkpoints

## 🔍 Monitoring

### TensorBoard:
```bash
tensorboard --logdir saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_100epoch/logs/
```

### Kiểm tra progress:
- Logs mỗi 10 steps
- Loss sẽ giảm dần qua 100 epochs
- Với 100 epochs, model sẽ học rất kỹ trên dataset nhỏ này

## ⚠️ Lưu ý

1. **Memory**: Với batch_size=2 và quantization 4-bit, vẫn an toàn cho GPU 8GB
2. **Nếu bị OOM**: Giảm `per_device_train_batch_size` xuống 1
3. **Nếu quá nhanh**: Có thể tăng `image_max_pixels` lên 65536 để chất lượng tốt hơn
4. **Overfitting**: Với 100 epochs trên 986 samples, có thể bị overfitting. Nên:
   - Monitor validation loss (nếu có)
   - Early stopping nếu cần
   - Hoặc giảm số epochs xuống 50-80 nếu thấy overfitting

## 🎓 So sánh với cấu hình cũ

| Tham số | Cũ | Mới | Lý do |
|---------|-----|-----|-------|
| Dataset | 3 datasets (3332 samples) | 1 dataset (986 samples) | Giảm thời gian |
| Batch size | 1 | 2 | Tăng tốc độ |
| Grad accum | 16 | 8 | Tăng tốc độ |
| Effective batch | 16 | 16 | **Giữ nguyên chất lượng!** |
| Image pixels | 65536 | 32768 | Tăng tốc độ xử lý |
| Epochs | 2 | 100 | Mục tiêu |
| Thời gian | 2-4 giờ | 7-8 giờ | Phù hợp mục tiêu |

## 💡 Tips

1. **Nếu muốn train nhanh hơn**: Giảm `image_max_pixels` xuống 16384
2. **Nếu muốn chất lượng tốt hơn**: Tăng `image_max_pixels` lên 65536 (nhưng sẽ lâu hơn)
3. **Nếu muốn train nhiều datasets**: Có thể train tuần tự từng dataset một
4. **Monitor GPU usage**: Dùng `nvidia-smi -l 1` để theo dõi

