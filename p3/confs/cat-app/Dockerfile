FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ARG APP_VERSION=v1
ENV APP_VERSION=${APP_VERSION}

EXPOSE 8888

CMD ["python", "app.py"]