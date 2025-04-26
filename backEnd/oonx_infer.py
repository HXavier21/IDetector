import os
import glob
import argparse
import numpy as np
from PIL import Image
import onnxruntime as ort

class ONNXInference:
    def __init__(self, onnx_path, provider='CPU'):
        """
        :param onnx_path: ONNX模型路径
        :param provider: 推理设备 ('CPU' 或 'CUDA')
        """
        # 初始化ONNX Runtime会话
        providers = ['CUDAExecutionProvider', 'CPUExecutionProvider'] if provider == 'CUDA' else ['CPUExecutionProvider']
        self.session = ort.InferenceSession(onnx_path, providers=providers)
        
        # 获取输入输出信息
        self.input_name = self.session.get_inputs()[0].name
        self.input_shape = self.session.get_inputs()[0].shape
        self.output_name = self.session.get_outputs()[0].name
        
        print(f"[INIT] 输入尺寸: {self.input_shape} | 设备: {provider}")

    def preprocess(self, image_path):
        """预处理流程 (需与训练时完全一致)"""
        # 1. 读取图像
        img = Image.open(image_path).convert('RGB')
        
        # 2. Resize和CenterCrop
        # Resize到256并保持比例
        img = self.resize_keep_ratio(img, 256)
        # CenterCrop到224x224
        img = self.center_crop(img, 224)
        
        # 3. 转换为numpy数组并归一化
        img_array = np.array(img).astype(np.float32) / 255.0
        
        # 标准化（使用float32计算）
        mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
        std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
        img_array = (img_array - mean) / std
        
        # 调整维度并确保类型
        img_array = img_array.transpose(2, 0, 1).astype(np.float32)
        return np.expand_dims(img_array, axis=0)

    @staticmethod
    def resize_keep_ratio(img, target_size):
        """保持长宽比的Resize"""
        width, height = img.size
        scale = target_size / min(width, height)
        new_size = (int(width * scale), int(height * scale))
        return img.resize(new_size, Image.BILINEAR)

    @staticmethod
    def center_crop(img, crop_size):
        """中心裁剪"""
        width, height = img.size
        left = (width - crop_size) // 2
        top = (height - crop_size) // 2
        right = left + crop_size
        bottom = top + crop_size
        return img.crop((left, top, right, bottom))

    def infer(self, image_path):
        """单张图像推理"""
        # 预处理
        input_tensor = self.preprocess(image_path)
        
        # 推理
        outputs = self.session.run(
            [self.output_name],
            {self.input_name: input_tensor}
        )
        
        # 后处理 (sigmoid激活)
        prob = 1 / (1 + np.exp(-outputs[0][0]))
        return float(prob)

    def batch_infer(self, folder_path):
        """批量推理整个文件夹"""
        # 获取所有图片路径
        img_paths = sorted(glob.glob(os.path.join(folder_path, "*.jpg")) +
                          glob.glob(os.path.join(folder_path, "*.png")) +
                          glob.glob(os.path.join(folder_path, "*.JPEG")))
        # code/py/dire/lsun_bedroom_release/adm
        results = []
        for path in img_paths:
            prob = self.infer(path)
            results.append((os.path.basename(path), prob))
        return results

def run_inference(model_path, input_path, device="CPU"):
    inferencer = ONNXInference(model_path, provider=device)

    if os.path.isfile(input_path):
        prob = inferencer.infer(input_path)
        print(f"\n[RESULT] 图像: {os.path.basename(input_path)} | 概率: {prob:.4f}")
        return prob
    elif os.path.isdir(input_path):
        results = inferencer.batch_infer(input_path)
        print("\n批量推理结果:")
        for name, prob in results:
            print(f"{name:<30} | 概率: {prob:.4f}")
        return results
    else:
        raise ValueError("无效的输入路径")
