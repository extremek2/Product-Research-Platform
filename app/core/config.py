import os

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://product_user:product_pass@localhost:5432/product_db"
)