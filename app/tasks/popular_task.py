from app.celery.celery_app import celery_app
from app.crawler.registry import get_retail_crawler
from app.pipeline.popular_pipeline import run_popular_pipeline


@celery_app.task(bind=True, max_retries=3)
def crawl_popular_products(self, category: str, source_key: str = "naver_shopping"):
    """
    인기 상품 수집 태스크
    1. 크롤러로 인기순 상품 수집
    2. SKU 추출
    3. retail_popular_product 저장
    """
    try:
        crawler = get_retail_crawler(source_key)
        products = crawler.get_popular(category=category, display=50)
        saved = run_popular_pipeline(
            category=category,
            source_key=source_key,
            products=products,
        )
        return {
            "category":   category,
            "source":     source_key,
            "fetched":    len(products),
            "saved":      saved,
        }
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)
