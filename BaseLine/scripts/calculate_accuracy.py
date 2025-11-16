"""
Script tính Accuracy (Exact Match Rate) cho HMER trong quá trình training
Có thể chạy song song với training để monitor accuracy
"""

import json
import os
import sys
from pathlib import Path
import editdistance

def calculate_exact_match(pred: str, gt: str) -> bool:
    """Tính exact match (loại bỏ whitespace)"""
    pred_clean = pred.strip().replace(' ', '')
    gt_clean = gt.strip().replace(' ', '')
    return pred_clean == gt_clean

def calculate_accuracy_from_predictions(pred_file: str) -> dict:
    """
    Tính accuracy từ file predictions JSON
    
    Format file:
    [
        {
            "img_id": "...",
            "gt": "ground truth LaTeX",
            "pred": "predicted LaTeX",
            "image_path": "..."
        },
        ...
    ]
    """
    with open(pred_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    total = len(data)
    exact_matches = 0
    total_edit_distance = 0
    
    for item in data:
        pred = item.get('pred', '').strip()
        gt = item.get('gt', '').strip()
        
        if calculate_exact_match(pred, gt):
            exact_matches += 1
        
        # Tính edit distance
        pred_clean = pred.replace(' ', '')
        gt_clean = gt.replace(' ', '')
        if len(gt_clean) > 0:
            edit_dist = editdistance.eval(pred_clean, gt_clean)
            total_edit_distance += edit_dist / max(len(gt_clean), 1)
    
    accuracy = exact_matches / total if total > 0 else 0.0
    avg_edit_distance = total_edit_distance / total if total > 0 else 0.0
    
    return {
        'total_samples': total,
        'exact_matches': exact_matches,
        'accuracy': accuracy,
        'avg_edit_distance': avg_edit_distance
    }

def monitor_training_accuracy(checkpoint_dir: str, eval_results_file: str = None):
    """
    Monitor accuracy từ checkpoint directory
    
    Args:
        checkpoint_dir: Đường dẫn đến checkpoint (ví dụ: saves/.../checkpoint-400)
        eval_results_file: File JSON chứa eval results (nếu có)
    """
    checkpoint_path = Path(checkpoint_dir)
    
    # Tìm file predictions nếu có
    pred_files = list(checkpoint_path.glob('*_pred.json'))
    if not pred_files:
        # Kiểm tra trong thư mục cha
        parent_pred_files = list(checkpoint_path.parent.glob('*_pred.json'))
        if parent_pred_files:
            pred_files = parent_pred_files
    
    if pred_files:
        print(f"Tìm thấy {len(pred_files)} file predictions")
        for pred_file in pred_files:
            print(f"\nĐang tính accuracy từ: {pred_file}")
            results = calculate_accuracy_from_predictions(str(pred_file))
            print(f"  Total samples: {results['total_samples']}")
            print(f"  Exact matches: {results['exact_matches']}")
            print(f"  Accuracy (EMR): {results['accuracy']:.4f} ({results['accuracy']*100:.2f}%)")
            print(f"  Avg Edit Distance: {results['avg_edit_distance']:.4f}")
    else:
        print(f"Không tìm thấy file predictions trong {checkpoint_dir}")
        print("Chạy inference trước để tạo predictions")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python calculate_accuracy.py <checkpoint_dir> [eval_results_file]")
        print("Example: python calculate_accuracy.py saves/.../checkpoint-400")
        sys.exit(1)
    
    checkpoint_dir = sys.argv[1]
    eval_results_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    monitor_training_accuracy(checkpoint_dir, eval_results_file)

