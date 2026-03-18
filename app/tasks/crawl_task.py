from app.celery.celery_app import celery_app
from app.pipeline.crawl_pipeline import run_crawl_pipeline


@celery_app.task(bind=True, max_retries=3)
def crawl_task(self, keyword: str):
    try:
        saved = run_crawl_pipeline(keyword)
        return {"keyword": keyword, "saved": saved}
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)