from app.celery.celery_app import celery_app
from app.crawler.naver_crawler import crawl_products
import time

@celery_app.task
def crawl_task():
    print("Start crawling...")
    crawl_products()  # DB에 Product 저장
    print("Crawling finished.")

if __name__ == "__main__":
    while True:
        print("Crawling...")
        # 작업 로직
        time.sleep(60)