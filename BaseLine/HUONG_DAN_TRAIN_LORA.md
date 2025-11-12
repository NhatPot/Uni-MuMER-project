# Hướng dẫn Training với LoRA + Quantization 4-bit

## ✅ Đã cấu hình xong!

Config đã được chuyển từ **Full Fine-tuning** sang **LoRA + Quantization 4-bit** để tiết kiệm memory tối đa cho GPU 8GB.

## 📊 So sánh

| Phương pháp | Memory cần | Tham số train |
|------------|------------|---------------|
| Full Fine-tuning | ~25GB | 100% (3B params) |
| LoRA | ~8-10GB | ~1-2% (vài triệu params) |
| **LoRA + 4-bit Quantization** | **~4-6GB** | **~1-2% (vài triệu params)** ✅ |

**Quantization 4-bit** giảm model từ 6-7GB xuống ~3-4GB khi load!

## 🚀 Cách chạy

### Bước 1: Đảm bảo môi trường đã sẵn sàng

```bash
cd /home/nhat/Uni-MuMER-project/BaseLine
conda activate unimumer
```

### Bước 2: Kiểm tra GPU memory

```bash
nvidia-smi
```

### Bước 3: Chạy training

```bash
bash train_local.sh
```

Hoặc chạy trực tiếp:

```bash
cd train/LLaMA-Factory
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
llamafactory-cli train ../Uni-MuMER-train-local.yaml
```

## 📝 Các thay đổi đã thực hiện

1. ✅ `finetuning_type: lora` - Chuyển sang LoRA
2. ✅ `quantization_bit: 4` - **QUAN TRỌNG**: Quantization 4-bit để giảm memory khi load model
3. ✅ `quantization_method: bnb` - Sử dụng BitsAndBytes
4. ✅ `double_quantization: true` - Tiết kiệm thêm memory
5. ✅ `lora_rank: 16` - Rank của LoRA adapter
6. ✅ `lora_alpha: 32` - Scaling factor
7. ✅ `per_device_train_batch_size: 1` - Giữ = 1 để an toàn
8. ✅ `learning_rate: 5.0e-4` - Tăng LR cho LoRA (thường cao hơn full fine-tuning)
9. ✅ `image_max_pixels: 65536` - Giảm để đảm bảo đủ memory
10. ✅ Đã cài `bitsandbytes` package

## 📂 Output

Checkpoints sẽ được lưu tại:
```
saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_local/
```

## 🔍 Kiểm tra tiến trình

Training sẽ hiển thị:
- Loss giảm dần
- Memory usage (nên thấp hơn nhiều so với full fine-tuning)
- Checkpoints được lưu mỗi 500 steps

## ⚠️ Nếu vẫn bị OOM

Nếu vẫn gặp lỗi Out of Memory, thử:

1. Giảm `per_device_train_batch_size` xuống `1`
2. Giảm `image_max_pixels` xuống `65536`
3. Giảm `lora_rank` xuống `8`

## 📚 Tài liệu thêm

- LoRA paper: https://arxiv.org/abs/2106.09685
- LLaMA-Factory docs: https://github.com/hiyouga/LLaMA-Factory

