import io
import os
import json
from tempfile import NamedTemporaryFile
import tempfile
import torch

from flask import Flask, jsonify, request

from PIL import ImageFile

ImageFile.LOAD_TRUNCATED_IMAGES = True


model = torch.hub.load('./yolov5', 'custom', path='./best.pt', source='local')

model.eval()

app = Flask(__name__)


@app.route('/health')
def hello():
    return 'Hello World'


@app.route('/inference', methods=['POST'])
def inference():
    if request.method == 'POST':
        file = request.files['file']

        tempFile = NamedTemporaryFile(
            mode='w+b', suffix='.'+file.filename.split('.')[-1])

        print(tempFile.name)

        file.stream.seek(0)
        file.save(tempFile)
        results = model(tempFile.name)
        tempFile.close()
        return results.pandas().xyxy[0].to_json(orient="records")


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
