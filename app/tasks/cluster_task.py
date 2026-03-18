from app.celery.celery_app import celery_app
from app.pipeline.cluster_pipeline import run_cluster_pipeline


@celery_app.task(bind=True, max_retries=3)
def cluster_task(self):
    try:
        count = run_cluster_pipeline()
        return {"clusters_saved": count}
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)