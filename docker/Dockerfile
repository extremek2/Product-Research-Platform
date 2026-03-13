FROM python:3.11

WORKDIR /app

# OS 패키지 업데이트 및 postgresql-client 설치
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -v -r requirements.txt

COPY . .

# entrypoint 등록
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# 기본 실행 커맨드는 docker-compose.yml에서 설정
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]