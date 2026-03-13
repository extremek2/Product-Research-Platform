# app/pipeline/cluster_pipeline.py

from app.db.database import SessionLocal
from app.models.product_cluster import ProductCluster  # 클러스터 테이블 모델

def save_clusters(clusters: dict):
    db = SessionLocal()
    try:
        for cluster_id, products in clusters.items():
            cluster_record = ProductCluster(cluster_id=cluster_id)
            db.add(cluster_record)
            db.flush()  # cluster_id 생성
            
            for product in products:
                cluster_record.products.append(product)
        
        db.commit()
    finally:
        db.close()