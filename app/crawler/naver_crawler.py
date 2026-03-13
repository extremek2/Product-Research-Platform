# app/crawler/naver_crawler.py

from app.pipeline.product_pipeline import normalize_products

def crawl_products():
    # 샘플 데이터 (실제 크롤러/스크래핑 데이터로 교체 가능)
    sample_products = [
        {
            "title": "샤오미 로봇청소기 S10",
            "price": 329000,
            "rating": 4.7,
            "review_count": 1500,
            "seller": "smartstore"
        },
        {
            "title": "로보락 S8",
            "price": 699000,
            "rating": 4.8,
            "review_count": 2100,
            "seller": "coupang"
        }
    ]

    # 정규화
    normalized_products = normalize_products(sample_products)

    # 현재는 정규화된 데이터만 반환
    return normalized_products