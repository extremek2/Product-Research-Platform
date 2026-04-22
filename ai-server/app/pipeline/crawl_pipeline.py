from app.db.database import SessionLocal
from app.models.source_product import SourceProduct
from app.models.product import Product
from app.normalization.product_normalizer import normalize_title
from app.crawler.naver_shopping_v2 import NaverShoppingCrawler


def run_crawl_pipeline(keyword: str) -> int:
    crawler = NaverShoppingCrawler()
    raw_items = crawler.search(keyword)
    db = SessionLocal()
    try:
        saved = 0
        for item in raw_items:
            # 중복 체크 (dataclass 접근 방식)
            exists = db.query(SourceProduct).filter_by(
                source=item.source,
                source_product_id=item.source_id
            ).first()
            if exists:
                continue

            source = SourceProduct(
                source=item.source,
                source_product_id=item.source_id,
                title=item.title,
                price=item.price,
                seller=item.seller,
                url=item.url,
                raw_json=item.raw_json,
            )
            db.add(source)
            db.flush()

            product = Product(
                title=normalize_title(item.title),
                brand=_extract_brand(item.title),
                category=item.category,
                source=item.source,
            )
            db.add(product)
            saved += 1

        db.commit()
        return saved
    finally:
        db.close()


def _extract_brand(title: str) -> str:
    from app.normalization.product_normalizer import BRAND_MAP
    title_lower = title.lower()
    for key, value in BRAND_MAP.items():
        if key in title_lower:
            return value
    return None
