from app.celery.celery_app import celery_app

from app.crawler.naver_crawler import crawl_products
from app.pipeline.source_pipeline import save_source_products


@celery_app.task
def crawl_task():

    print("start crawl")

    products = crawl_products()

    save_source_products(products)