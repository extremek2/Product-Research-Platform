from app.db.database import SessionLocal
from app.models.product import Product
from app.models.product_cluster import ProductCluster
from app.models.product_cluster_item import ProductClusterItem
from app.clustering.cluster_engine import build_clusters


def run_cluster_pipeline() -> int:
    """
    product 전체 → 클러스터링 → 저장
    저장된 클러스터 수 반환
    """
    db = SessionLocal()
    try:
        products = db.query(Product).all()
        if not products:
            print("No products to cluster.")
            return 0

        clusters = build_clusters(products)

        # 기존 클러스터 초기화 후 재저장
        db.query(ProductClusterItem).delete()
        db.query(ProductCluster).delete()
        db.flush()

        for cluster_id, items in clusters.items():
            cluster = ProductCluster(
                cluster_name=f"cluster_{cluster_id}"
            )
            db.add(cluster)
            db.flush()

            for product in items:
                item = ProductClusterItem(
                    cluster_id=cluster.id,
                    product_id=product.id,
                    confidence_score=1.0,
                )
                db.add(item)

        db.commit()
        return len(clusters)
    finally:
        db.close()
