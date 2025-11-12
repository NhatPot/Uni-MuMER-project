# Hướng dẫn Training với LoRA

## ✅ Đã cấu hình xong!

Config đã được chuyển từ **Full Fine-tuning** sang **LoRA** để tiết kiệm memory cho GPU 8GB.

## 📊 So sánh

| Phương pháp | Memory cần | Tham số train |
|------------|------------|---------------|
| Full Fine-tuning | ~25GB | 100% (3B params) |
| **LoRA** | **~8-10GB** | **~1-2% (vài triệu params)** |

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
2. ✅ `lora_rank: 16` - Rank của LoRA adapter
3. ✅ `lora_alpha: 32` - Scaling factor
4. ✅ `per_device_train_batch_size: 2` - Tăng batch size (LoRA tiết kiệm memory)
5. ✅ `learning_rate: 5.0e-4` - Tăng LR cho LoRA (thường cao hơn full fine-tuning)
6. ✅ `image_max_pixels: 131072` - Tăng lại vì LoRA tiết kiệm memory

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

