# Use python as base image
FROM python:3.8-buster

# Use working directory /app/model
WORKDIR /app

# Copy and install required packages
COPY . .

RUN apt update && apt install git libgl1-mesa-glx -y

RUN git clone https://github.com/ultralytics/yolov5

RUN pip install -r yolov5/requirements.txt

RUN pip install flask

# Set env variables for Cloud Run
ENV PORT 5000

# Run flask app
CMD ["python", "app.py"]