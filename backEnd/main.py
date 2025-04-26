import os
import traceback
from flask import Flask, Request, jsonify, request, send_from_directory
from oonx_infer import run_inference
import history_item

app = Flask(__name__, static_folder='flutter_web', static_url_path='')

@app.route('/')
def serve_flutter_app():
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/<path:path>')
def serve_static_file(path):
    return send_from_directory(app.static_folder, path)

@app.errorhandler(Exception)
def handle_exception(e):
    error_type = type(e).__name__
    error_message = str(e)
    error_traceback = traceback.format_exc()

    print(f"Error Type: {error_type}")
    print(f"Error Message: {error_message}")
    print(f"Traceback: {error_traceback}")

    response = {
        "error_type": error_type,
        "error_message": error_message,
        "traceback": error_traceback.splitlines()
    }
    return jsonify(response), 500

@app.route('/api/detect', methods=['POST'])
def detect_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file uploaded'}), 400
    
    image = request.files['image']
    image.save(f"./uploads/{image.filename}")
    
    prob = run_inference(
        model_path="./OONX/oonx_adm.onnx",
        input_path=f"./uploads/{image.filename}",
        device="CPU"
    )
    
    if prob > 0.009999:
        prob = 0.009999

    return jsonify({'probability': prob*100})

@app.route('/api/history', methods=['GET'])
def get_history():
    history = []
    for filename in os.listdir("./uploads"):
        if filename.endswith(".jpg") or filename.endswith(".png"):
            with open(f"./uploads/{filename}", "rb") as f:
                bytes_data = f.read()
            prob = run_inference(
                model_path="./OONX/oonx_adm.onnx",
                input_path=f"./uploads/{filename}",
                device="CPU"
            )
            history_item_obj = history_item.HistoryItem(filename, prob, bytes_data)
            history.append({
                'filename': history_item_obj.filename,
                'probability': history_item_obj.probability,
                'bytes': history_item_obj.bytes.decode('latin-1')  # Decode bytes to string
            })
    
    return jsonify({'history': history})

if __name__ == '__main__':
    app.run(debug=True)