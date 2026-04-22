from app.db.database import SessionLocal
from app.models.wholesale_product import WholesaleProduct, WholesaleSource
from app.models.sku_master import SkuMaster
from app.normalization.product_normalizer import normalize_title
from app.normalization.sku_extractor import extract_sku
from app.normalization.product_classifier import classify_product, ProductType
from sqlalchemy import func

SOURCE_NAME_MAP = {
    "domeggook": "도매꾹",
    "domeme":    "도매매",
}


def _get_category_avg_price(db, keyword: str) -> float:
    result = db.query(func.avg(WholesaleProduct.price)).filter(
        WholesaleProduct.search_keyword == keyword,
        WholesaleProduct.price > 0
    ).scalar()
    return float(result) if result else 0


def run_wholesale_pipeline(keyword: str, items: list) -> int:
    db = SessionLocal()
    try:
        keyword_tokens  = set(keyword.lower().split())
        category_avg    = _get_category_avg_price(db, keyword)
        saved           = 0
        skipped         = 0

        for item in items:
            source_name = SOURCE_NAME_MAP.get(item.source, item.source)
            source      = db.query(WholesaleSource).filter_by(name=source_name).first()
            if not source:
                continue

            # 중복 체크
            title_normalized = normalize_title(item.title)
            exists = db.query(WholesaleProduct).filter_by(
                title=title_normalized,
                price=item.price,
            ).first()
            if exists:
                continue

            # 관련성 필터
            if not any(token in item.title.lower() for token in keyword_tokens):
                continue

            # 상품 분류
            product_type, confidence, reason = classify_product(
                title=item.title,
                price=item.price,
                category=keyword,
                category_avg_price=category_avg if category_avg > 0 else None,
            )
            if product_type == ProductType.ACCESSORY:
                skipped += 1
                continue

            # SKU 추출
            sku_result = extract_sku(item.title, search_keyword=keyword)

            # sku_master 조회 or 생성
            sku_master = None
            if sku_result.normalized_sku:
                sku_master = db.query(SkuMaster).filter_by(
                    normalized_sku=sku_result.normalized_sku
                ).first()
                if not sku_master:
                    sku_master = SkuMaster(
                        normalized_sku=        sku_result.normalized_sku,
                        brand=                 sku_result.brand,
                        model_number=          sku_result.model_number,
                        category=              sku_result.category,
                        color=                 sku_result.color,
                        variant=               sku_result.variant,
                        extraction_confidence= sku_result.confidence,
                        extraction_method=     sku_result.extraction_method,
                    )
                    db.add(sku_master)
                    db.flush()

            product = WholesaleProduct(
                source_id=        source.id,
                source_product_id=item.source_id,
                sku_master_id=    sku_master.id if sku_master else None,
                trade_type=       item.trade_type,
                title=            title_normalized,
                price=            item.price,
                currency=         item.currency,
                moq=              item.moq,
                supplier=         item.seller,
                country=          item.country,
                normalized_sku=   sku_result.normalized_sku,
                brand=            sku_result.brand,
                model_number=     sku_result.model_number,
                search_keyword=   keyword,
                url=              item.url,
                raw_json=         item.raw_json,
            )
            db.add(product)
            saved += 1

        db.commit()
        print(f"[pipeline] saved={saved}, skipped={skipped}")
        return saved
    finally:
        db.close()
