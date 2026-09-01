from datetime import datetime, timedelta
from app.celery.celery_app import celery_app
from app.crawler.naver_shopping_insight import NaverShoppingInsightClient


@celery_app.task(bind=True, max_retries=3)
def trend_task(self):
    try:
        # 최근 30일 트렌드
        end_date = datetime.now().strftime("%Y-%m-%d")
        start_date = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")

        client = NaverShoppingInsightClient()
        keywords = client.get_trending_keywords(
            start_date=start_date,
            end_date=end_date,
            top_categories=3,   # 상위 3개 카테고리
            top_keywords=5,     # 카테고리당 5개 키워드
        )

        if not keywords:
            print("[trend_task] 수집된 키워드 없음")
            return {"keywords": [], "triggered": 0}

        print(f"[trend_task] 최종 키워드: {keywords}")

        # Shopping Insight는 클릭 트렌드만 제공한다. 종료된 네이버 쇼핑
        # 상품 검색 API를 여기서 연쇄 호출하지 않는다.
        return {
            "keywords": keywords,
            "triggered": 0,
            "product_collection": "disabled",
        }

    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)
