# Use NVIDIA CUDA base image with Python 3.10
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PATH="/root/.local/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3.10-dev python3-pip git curl wget \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3.10 is the default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    python3 -m pip install --upgrade pip

# Create a virtual environment
WORKDIR /app
RUN python3 -m venv venv

# Activate virtual environment
ENV PATH="/app/venv/bin:$PATH"

# Install PyTorch with CUDA 12.4 support
RUN pip install torch==2.5.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu124

# Copy dependency files
COPY requirements.txt /app/requirements.txt

RUN  pip install --upgrade pip setuptools wheel

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install optional acceleration libraries
RUN pip install --no-cache-dir flash-attn==2.7.2.post1 \
    sageattention==1.0.6 \
    xformers==0.0.29

# Clone and install Sage Attention 2 (optional)
# RUN git clone https://github.com/thu-ml/SageAttention /app/sageattention && \
#     cd /app/sageattention && pip install -e .

# Copy the application code
COPY . /app

# Create an output directory
RUN mkdir -p /app/output

# Set the output directory as a volume for persistence
VOLUME [ "/app/output" ]

VOLUME [ "/app/loras" ]

# Expose port for Gradio
EXPOSE 7860

# Set default environment variables for Gradio
ENV SERVER_NAME="0.0.0.0"
ENV SERVER_PORT="7860"

# Entrypoint to run the Gradio app
ENTRYPOINT ["python", "gradio_server.py"]

