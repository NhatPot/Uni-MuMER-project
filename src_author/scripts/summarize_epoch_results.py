"""
Script tổng hợp kết quả training từ các epoch
Hiển thị metrics từ mỗi checkpoint để so sánh
"""

import json
import os
import csv
from pathlib import Path
from typing import Dict, List, Optional

def load_trainer_state(output_dir: str) -> Optional[Dict]:
    """Load trainer_state.json từ output directory"""
    trainer_state_path = Path(output_dir) / "trainer_state.json"
    if trainer_state_path.exists():
        with open(trainer_state_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    return None

def load_eval_results(checkpoint_dir: str) -> Optional[Dict]:
    """Load eval_results.json từ checkpoint directory"""
    eval_results_path = Path(checkpoint_dir) / "eval_results.json"
    if eval_results_path.exists():
        with open(eval_results_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    return None

def find_all_checkpoints(output_dir: str) -> List[str]:
    """Tìm tất cả các checkpoint trong output directory"""
    output_path = Path(output_dir)
    checkpoints = []
    
    # Tìm các thư mục checkpoint-*
    for checkpoint_dir in sorted(output_path.glob("checkpoint-*")):
        if checkpoint_dir.is_dir():
            checkpoints.append(str(checkpoint_dir))
    
    return sorted(checkpoints, key=lambda x: int(x.split('-')[-1]) if x.split('-')[-1].isdigit() else 0)

def summarize_results(output_dir: str, save_csv: bool = True):
    """
    Tổng hợp kết quả từ tất cả các epoch
    
    Args:
        output_dir: Đường dẫn đến output directory
        save_csv: Có lưu kết quả ra file CSV không
    """
    output_path = Path(output_dir)
    
    print("=" * 80)
    print(f"Tổng hợp kết quả training từ: {output_dir}")
    print("=" * 80)
    
    # Load trainer_state.json
    trainer_state = load_trainer_state(output_dir)
    
    # Tìm tất cả checkpoints
    checkpoints = find_all_checkpoints(output_dir)
    
    if not checkpoints:
        print(f"Không tìm thấy checkpoint nào trong {output_dir}")
        return
    
    print(f"\nTìm thấy {len(checkpoints)} checkpoint(s):\n")
    
    # Thu thập dữ liệu từ các checkpoint
    results = []
    
    for checkpoint_dir in checkpoints:
        checkpoint_name = Path(checkpoint_dir).name
        eval_results = load_eval_results(checkpoint_dir)
        
        if eval_results:
            epoch = eval_results.get('epoch', 'N/A')
            eval_loss = eval_results.get('eval_loss', 'N/A')
            eval_perplexity = eval_results.get('eval_perplexity', 'N/A')
            eval_runtime = eval_results.get('eval_runtime', 'N/A')
            
            results.append({
                'checkpoint': checkpoint_name,
                'epoch': epoch,
                'eval_loss': eval_loss,
                'eval_perplexity': eval_perplexity,
                'eval_runtime': eval_runtime
            })
    
    # Nếu có trainer_state, lấy thêm thông tin
    if trainer_state:
        log_history = trainer_state.get('log_history', [])
        
        # Tìm các log entry có eval_loss
        for log_entry in log_history:
            if 'eval_loss' in log_entry:
                epoch = log_entry.get('epoch', 'N/A')
                eval_loss = log_entry.get('eval_loss', 'N/A')
                eval_perplexity = log_entry.get('eval_perplexity', 'N/A')
                
                # Tìm checkpoint tương ứng
                checkpoint_name = f"checkpoint-epoch-{epoch:.1f}" if isinstance(epoch, float) else f"checkpoint-{epoch}"
                
                # Cập nhật hoặc thêm vào results
                found = False
                for i, result in enumerate(results):
                    if abs(result.get('epoch', 0) - epoch) < 0.1 if isinstance(epoch, (int, float)) and isinstance(result.get('epoch'), (int, float)) else False:
                        results[i].update({
                            'eval_loss': eval_loss,
                            'eval_perplexity': eval_perplexity
                        })
                        found = True
                        break
                
                if not found:
                    results.append({
                        'checkpoint': checkpoint_name,
                        'epoch': epoch,
                        'eval_loss': eval_loss,
                        'eval_perplexity': eval_perplexity,
                        'eval_runtime': 'N/A'
                    })
    
    # Sắp xếp theo epoch
    results.sort(key=lambda x: x.get('epoch', 0) if isinstance(x.get('epoch'), (int, float)) else 0)
    
    # Hiển thị kết quả
    if results:
        print("\n" + "=" * 80)
        print("KẾT QUẢ THEO TỪNG EPOCH:")
        print("=" * 80)
        print(f"{'Checkpoint':<25} {'Epoch':<10} {'Eval Loss':<15} {'Eval Perplexity':<20}")
        print("-" * 80)
        
        for result in results:
            checkpoint = result['checkpoint']
            epoch = result.get('epoch', 'N/A')
            eval_loss = result.get('eval_loss', 'N/A')
            eval_perplexity = result.get('eval_perplexity', 'N/A')
            
            # Format số
            if isinstance(eval_loss, (int, float)):
                eval_loss_str = f"{eval_loss:.6f}"
            else:
                eval_loss_str = str(eval_loss)
            
            if isinstance(eval_perplexity, (int, float)):
                eval_perplexity_str = f"{eval_perplexity:.6f}"
            else:
                eval_perplexity_str = str(eval_perplexity)
            
            if isinstance(epoch, (int, float)):
                epoch_str = f"{epoch:.2f}"
            else:
                epoch_str = str(epoch)
            
            print(f"{checkpoint:<25} {epoch_str:<10} {eval_loss_str:<15} {eval_perplexity_str:<20}")
        
        # Tìm best model (eval_loss thấp nhất)
        valid_results = [r for r in results if isinstance(r.get('eval_loss'), (int, float))]
        if valid_results:
            best_result = min(valid_results, key=lambda x: x['eval_loss'])
            print("\n" + "=" * 80)
            print("BEST MODEL (Eval Loss thấp nhất):")
            print("=" * 80)
            print(f"Checkpoint: {best_result['checkpoint']}")
            print(f"Epoch: {best_result.get('epoch', 'N/A')}")
            print(f"Eval Loss: {best_result['eval_loss']:.6f}")
            print(f"Eval Perplexity: {best_result.get('eval_perplexity', 'N/A')}")
        
        # Lưu ra CSV nếu được yêu cầu
        if save_csv and results:
            csv_path = output_path / "epoch_results_summary.csv"
            with open(csv_path, 'w', newline='', encoding='utf-8') as f:
                if results:
                    writer = csv.DictWriter(f, fieldnames=results[0].keys())
                    writer.writeheader()
                    writer.writerows(results)
            print(f"\n✅ Đã lưu kết quả vào: {csv_path}")
    else:
        print("Không tìm thấy kết quả evaluation nào!")
        print("Đảm bảo rằng:")
        print("  1. Training đã chạy với do_eval: true")
        print("  2. eval_strategy: epoch đã được set")
        print("  3. Các checkpoint đã được lưu")
    
    # Hiển thị thông tin training tổng thể
    if trainer_state:
        print("\n" + "=" * 80)
        print("THÔNG TIN TRAINING TỔNG THỂ:")
        print("=" * 80)
        print(f"Total epochs: {trainer_state.get('epoch', 'N/A')}")
        print(f"Total steps: {trainer_state.get('global_step', 'N/A')}")
        print(f"Total training time: {trainer_state.get('training_time', 'N/A')}")
        print(f"Best metric: {trainer_state.get('best_metric', 'N/A')}")
        print(f"Best model checkpoint: {trainer_state.get('best_model_checkpoint', 'N/A')}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python summarize_epoch_results.py <output_dir> [--no-csv]")
        print("Example: python summarize_epoch_results.py saves/qwen2.5_vl-3b/lora/sft/standred/uni-mumer_crohme_local")
        sys.exit(1)
    
    output_dir = sys.argv[1]
    save_csv = "--no-csv" not in sys.argv
    
    if not os.path.exists(output_dir):
        print(f"Lỗi: Không tìm thấy thư mục {output_dir}")
        sys.exit(1)
    
    summarize_results(output_dir, save_csv)

