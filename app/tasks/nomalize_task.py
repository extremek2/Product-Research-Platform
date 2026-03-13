from app.celery.celery_app import celery_app

from app.pipeline.product_pipeline import normalize_products


@celery_app.task
def normalize_task():

    print("start normalize")

    normalize_products()