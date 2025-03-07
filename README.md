# How to run
1. Run with:
    ```
    docker build -t gradio-diffusion .
    docker run --gpus all -p 7860:7860 -v $(pwd)/output:/app/gradio_outputs -v $(pwd)/loras:/app/loras --rm gradio-diffusion
    ```
2. Connect to http://localhost:7860