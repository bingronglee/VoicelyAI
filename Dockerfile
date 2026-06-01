FROM python:3.12-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    sox \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用程式
COPY app.py .
COPY entrypoint.sh .
COPY recorder.html .

# 建立资料目录
RUN mkdir -p /app/data

# 非 root 使用者
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app

# ENTRYPOINT 以 root 执行，修正权限后再降级为 appuser
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["python", "app.py"]

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1
