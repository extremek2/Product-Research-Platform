from typing import List
from app.db.database import SessionLocal
from app.models.retail_source import RetailSource
from app.models.retail_popular_product import RetailPopularProduct
from app.models.sku_master import SkuMaster
from app.normalization.sku_extractor import extract_sku
from app.normalization.product_normalizer import normalize_title
from app.crawler.base import RetailProduct


def run_popular_pipeline(
    category: str,
    source_key: str,
    products: List[RetailProduct],
) -> int:
    db = SessionLocal()
    try:
        source = db.query(RetailSource).filter_by(source_key=source_key).first()
        if not source:
            return 0

        saved = 0
        for product in products:
            # 중복 체크 (같은 소스 + source_id)
            exists = db.query(RetailPopularProduct).filter_by(
                source_id=source.id,
                title=normalize_title(product.title),
            ).first()
            if exists:
                continue

            # SKU 추출
            sku_result = extract_sku(product.title, search_keyword=category)

            # sku_master 조회 or 생성
            sku_master = None
            if sku_result.normalized_sku:
                sku_master = db.query(SkuMaster).filter_by(
                    normalized_sku=sku_result.normalized_sku
                ).first()
                if not sku_master:
                    sku_master = SkuMaster(
                        normalized_sku=     sku_result.normalized_sku,
                        brand=              sku_result.brand,
                        model_number=       sku_result.model_number,
                        category=           sku_result.category,
                        color=              sku_result.color,
                        variant=            sku_result.variant,
                        extraction_confidence= sku_result.confidence,
                        extraction_method=  sku_result.extraction_method,
                    )
                    db.add(sku_master)
                    db.flush()

            record = RetailPopularProduct(
                source_id=      source.id,
                category=       category,
                search_keyword= category,
                title=          normalize_title(product.title),
                price=          product.price,
                review_count=   product.review_count,
                purchase_count= product.purchase_count,
                rank=           product.rank,
                brand=          sku_result.brand or product.brand,
                model_number=   sku_result.model_number,
                normalized_sku= sku_result.normalized_sku,
                sku_master_id=  sku_master.id if sku_master else None,
                seller=         product.seller,
                url=            product.url,
                image_url=      product.image_url,
                rating=         product.rating,
                raw_json=       product.raw_json,
            )
            db.add(record)
            saved += 1

        db.commit()
        return saved
    finally:
        db.close()
