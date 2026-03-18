import os

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://product_user:product_pass@localhost:5432/product_db"
)
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
NAVER_CLIENT_ID = os.getenv("NAVER_CLIENT_ID", "")
NAVER_CLIENT_SECRET = os.getenv("NAVER_CLIENT_SECRET", "")