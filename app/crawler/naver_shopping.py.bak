import requests
import re
from typing import List, Dict
from app.crawler.base import BaseCrawler
from app.core.config import NAVER_CLIENT_ID, NAVER_CLIENT_SECRET


class NaverShoppingCrawler(BaseCrawler):
    BASE_URL = "https://openapi.naver.com/v1/search/shop.json"

    def __init__(self):
        self.headers = {
            "X-Naver-Client-Id": NAVER_CLIENT_ID,
            "X-Naver-Client-Secret": NAVER_CLIENT_SECRET,
        }

    def search(self, keyword: str, display: int = 20) -> List[Dict]:
        params = {
            "query": keyword,
            "display": display,
            "sort": "sim",
        }
        resp = requests.get(self.BASE_URL, headers=self.headers, params=params)
        resp.raise_for_status()
        items = resp.json().get("items", [])
        return [self._parse(item) for item in items]

    def _parse(self, item: dict) -> Dict:
        return {
            "source": "naver_shopping",
            "source_product_id": item.get("productId", ""),
            "title": re.sub(r"<[^>]+>", "", item.get("title", "")),
            "price": int(item.get("lprice", 0)),
            "seller": item.get("mallName", ""),
            "url": item.get("link", ""),
            "raw_json": str(item),
        }