from app.db.database import SessionLocal
from app.models.source_product import SourceProduct
from app.models.product import Product
from app.normalization.product_normalizer import normalize_title
from app.crawler.naver_shopping import NaverShoppingCrawler


def run_crawl_pipeline(keyword: str) -> int:
    """
    키워드 → 크롤링 → source_product 저장 → product 변환
    저장된 건수 반환
    """
    crawler = NaverShoppingCrawler()
    raw_items = crawler.search(keyword)

    db = SessionLocal()
    try:
        saved = 0
        for item in raw_items:
            # 중복 체크
            exists = db.query(SourceProduct).filter_by(
                source=item["source"],
                source_product_id=item["source_product_id"]
            ).first()
            if exists:
                continue

            # 1. source_product 저장 (원본)
            source = SourceProduct(
                source=item["source"],
                source_product_id=item["source_product_id"],
                title=item["title"],
                price=item["price"],
                seller=item["seller"],
                url=item["url"],
                raw_json=item["raw_json"],
            )
            db.add(source)
            db.flush()  # source.id 생성

            # 2. product 변환 (정규화된 대표 상품)
            product = Product(
                title=normalize_title(item["title"]),
                brand=_extract_brand(item["title"]),
                category=None,      # 추후 카테고리 분류 로직 추가
                source=item["source"],
            )
            db.add(product)
            saved += 1

        db.commit()
        return saved
    finally:
        db.close()


def _extract_brand(title: str) -> str:
    """타이틀에서 브랜드 추출 (정규화 맵 기반)"""
    from app.normalization.product_normalizer import BRAND_MAP
    title_lower = title.lower()
    for key, value in BRAND_MAP.items():
        if key in title_lower:
            return value
    return None
