from app.celery.celery_app import celery_app
from app.crawler.domeggook_crawler import DomeggookCrawler
from app.pipeline.wholesale_pipeline import run_wholesale_pipeline


@celery_app.task(bind=True, max_retries=3)
def crawl_wholesale_domeggook(self, keyword: str):
    """도매꾹 + 도매매 통합 수집"""
    try:
        crawler = DomeggookCrawler()
        items = crawler.search_all(keyword, display=50)
        saved = run_wholesale_pipeline(keyword, items)
        return {"keyword": keyword, "saved": saved, "total_fetched": len(items)}
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)
