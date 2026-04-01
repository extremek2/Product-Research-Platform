import requests
import json
from typing import List
from app.crawler.base import RetailCrawler, RetailProduct
from app.crawler.registry import register_retail
from app.core.config import NAVER_CLIENT_ID, NAVER_CLIENT_SECRET


@register_retail("naver_shopping")
class NaverShoppingCrawler(RetailCrawler):
    """
    네이버 쇼핑 검색 API v2
    - 인기순 상품 수집
    - 키워드 검색
    """
    BASE_URL = "https://openapi.naver.com/v1/search/shop.json"

    @property
    def source_key(self) -> str:
        return "naver_shopping"

    def get_popular(
        self,
        category: str,
        display: int = 50,
        page: int = 1,
    ) -> List[RetailProduct]:
        """카테고리 키워드로 인기순 검색"""
        return self.search(
            keyword=category,
            sort="sim",     # 정확도순 (인기 상품 노출)
            display=display,
            page=page,
        )

    def search(
        self,
        keyword: str,
        sort: str = "sim",
        display: int = 50,
        page: int = 1,
    ) -> List[RetailProduct]:
        """
        sort 옵션:
          sim  - 정확도순
          date - 날짜순
          asc  - 가격 낮은순
          dsc  - 가격 높은순
        """
        headers = {
            "X-Naver-Client-Id":     NAVER_CLIENT_ID,
            "X-Naver-Client-Secret": NAVER_CLIENT_SECRET,
        }
        params = {
            "query":   keyword,
            "display": min(display, 100),  # 최대 100
            "start":   (page - 1) * display + 1,
            "sort":    sort,
        }

        resp = requests.get(self.BASE_URL, headers=headers, params=params, timeout=10)
        resp.raise_for_status()

        data = resp.json()
        items = data.get("items", [])

        results = []
        for idx, item in enumerate(items):
            results.append(RetailProduct(
                source=        self.source_key,
                source_id=     item.get("productId", ""),
                title=         self._clean_title(item.get("title", "")),
                price=         int(item.get("lprice", 0)),
                review_count=  int(item.get("reviewCount", 0)),
                purchase_count=0,  # 네이버 API 미제공
                rank=          (page - 1) * display + idx + 1,
                brand=         item.get("brand", "") or None,
                category=      keyword,
                url=           item.get("link", ""),
                image_url=     item.get("image", ""),
                seller=        item.get("mallName", "") or None,
                raw_json=      json.dumps(item, ensure_ascii=False),
            ))

        return results

    def _clean_title(self, title: str) -> str:
        """HTML 태그 제거"""
        import re
        return re.sub(r'<[^>]+>', '', title).strip()
