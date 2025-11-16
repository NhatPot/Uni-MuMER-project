# 📊 Hướng Dẫn Theo Dõi Accuracy

Hướng dẫn chi tiết về cách theo dõi và đánh giá accuracy trong quá trình training.

## 📋 Mục Lục

1. [Accuracy trong Terminal](#accuracy-trong-terminal)
2. [Hiển Thị Epoch Summary](#hiển-thị-epoch-summary)
3. [Xem Kết Quả Sau Training](#xem-kết-quả-sau-training)
4. [Tính Accuracy Từ Checkpoint](#tính-accuracy-từ-checkpoint)
5. [So Sánh Metrics](#so-sánh-metrics)

---

## 🎯 Accuracy trong Terminal

### Tự động hiển thị

Khi training với `compute_hmer_accuracy: true`, accuracy sẽ tự động hiển thị trong logs:

```
{'loss': 0.0573, 'grad_norm': 1.09, 'learning_rate': 0.00038, 'epoch': 1.97}
{'eval_loss': 0.045, 'eval_perplexity': 1.046, 
 'hmer_exact_match_rate': 0.7234,      # ← 72.34% chính xác!
 'hmer_accuracy': 0.7234,                # ← Alias
 'hmer_avg_edit_distance': 0.1234,      # ← Trung bình 12.34% cần sửa
 'epoch': 1.97}
```

### Metrics được tính

1. **`hmer_exact_match_rate`**: Tỷ lệ predictions khớp 100% với ground truth
2. **`hmer_avg_edit_distance`**: Khoảng cách chỉnh sửa trung bình (càng thấp càng tốt)

### Cấu hình

Đã được thêm vào config:
```yaml
compute_hmer_accuracy: true  # Hiển thị accuracy trực tiếp trong logs
```

---

## 📊 Hiển Thị Epoch Summary

### Tự động hiển thị box đẹp

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

### Điều kiện hiển thị

- ✅ Có evaluation (`do_eval: true`)
- ✅ `eval_strategy: epoch` hoặc `steps`
- ✅ Có ít nhất một metric: `eval_loss`, `hmer_exact_match_rate`

---

## 📁 Xem Kết Quả Sau Training

### Cấu trúc files

```
saves/.../uni-mumer_crohme_local/
├── checkpoint-1/
│   └── eval_results.json  # ← Kết quả epoch 1
├── checkpoint-2/
│   └── eval_results.json  # ← Kết quả epoch 2
├── trainer_state.json     # ← Tổng hợp tất cả
└── epoch_results_summary.csv  # ← Tổng hợp (sau khi chạy script)
```

### Xem từng epoch

```bash
# Xem kết quả epoch 1
cat saves/.../checkpoint-1/eval_results.json | python -m json.tool
```

### Tổng hợp tất cả epochs

```bash
cd /home/nhat/Uni-MuMER-project/BaseLine
conda activate unimumer

# Tổng hợp kết quả
python scripts/summarize_epoch_results.py saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_local
```

**Output mẫu**:
```
================================================================================
KẾT QUẢ THEO TỪNG EPOCH:
================================================================================
Checkpoint                Epoch      Eval Loss       Eval Perplexity    
--------------------------------------------------------------------------------
checkpoint-1              1.00       0.052000        1.053000            
checkpoint-2              2.00       0.045000        1.046000            
checkpoint-3              3.00       0.038000        1.039000            

================================================================================
BEST MODEL (Eval Loss thấp nhất):
================================================================================
Checkpoint: checkpoint-3
Epoch: 3.0
Eval Loss: 0.028000
```

---

## 🔍 Tính Accuracy Từ Checkpoint

### Sử dụng script

```bash
cd /home/nhat/Uni-MuMER-project/BaseLine
conda activate unimumer

# Tính accuracy từ checkpoint
python scripts/calculate_accuracy.py saves/.../checkpoint-400
```

**Output**:
```
Tìm thấy 1 file predictions
Đang tính accuracy từ: checkpoint-400/eval_predictions.json
  Total samples: 333
  Exact matches: 267
  Accuracy (EMR): 0.8012 (80.12%)
  Avg Edit Distance: 0.0234
```

---

## 📈 So Sánh Metrics

### Metrics quan trọng

1. **Eval Loss**: Càng thấp càng tốt
2. **Eval Perplexity**: Càng thấp càng tốt
3. **Exact Match Rate**: Càng cao càng tốt (1.0 = 100%)
4. **Avg Edit Distance**: Càng thấp càng tốt (0.0 = hoàn hảo)

### Phân tích xu hướng

**Trường hợp tốt**:
```
Epoch 1: eval_loss = 0.052, accuracy = 0.65
Epoch 2: eval_loss = 0.045, accuracy = 0.72  ← Cải thiện ✅
Epoch 3: eval_loss = 0.038, accuracy = 0.78  ← Cải thiện ✅
```
→ **Model đang học tốt!**

**Trường hợp overfitting**:
```
Epoch 1: eval_loss = 0.052, accuracy = 0.65
Epoch 2: eval_loss = 0.045, accuracy = 0.72  ← Cải thiện ✅
Epoch 3: eval_loss = 0.050, accuracy = 0.71  ← Eval loss tăng ⚠️
```
→ **Có thể dừng ở epoch 2!**

---

## 💡 Tips

1. **Theo dõi xu hướng**: Accuracy nên tăng dần theo epochs
2. **So sánh với eval_loss**: Nếu accuracy tăng nhưng eval_loss giảm → tốt ✅
3. **Early stopping**: Nếu accuracy không tăng sau vài epochs → có thể dừng sớm
4. **Best model**: Chọn checkpoint có accuracy cao nhất hoặc eval_loss thấp nhất

---

## 🐛 Troubleshooting

### Không thấy accuracy trong logs?

1. Kiểm tra config: `compute_hmer_accuracy: true`
2. Kiểm tra evaluation: `do_eval: true` và `eval_strategy: epoch`
3. Accuracy chỉ hiển thị sau mỗi evaluation

### Accuracy = 0 hoặc rất thấp?

- Bình thường ở epoch đầu (model chưa học được nhiều)
- Kiểm tra data format
- Kiểm tra tokenization

---

**Xem thêm**: `HUONG_DAN_TRAIN.md` để biết cách train chi tiết.

