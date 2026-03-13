from app.celery.celery_app import celery_app

from app.clustering.cluster_engine import build_clusters
from app.pipeline.cluster_pipeline import save_clusters

from app.db.database import SessionLocal
from app.models.product import Product


@celery_app.task
def cluster_task():

    db = SessionLocal()

    try:

        products = db.query(Product).all()

        clusters = build_clusters(products)

        save_clusters(clusters)

    finally:

        db.close()