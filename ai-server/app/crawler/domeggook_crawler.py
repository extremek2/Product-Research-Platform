import requests
from typing import List
from app.crawler.base import WholesaleCrawler, WholesaleProduct
from app.crawler.registry import register_wholesale
from app.core.config import DOMEGGOOK_API_KEY


@register_wholesale("domeggook")
class DomeggookCrawler(WholesaleCrawler):
    BASE_URL = "https://domeggook.com/ssl/api/"

    def __init__(self):
        self.api_key = DOMEGGOOK_API_KEY

    @property
    def source_key(self) -> str:
        return "domeggook"

    def search(self, keyword: str, display: int = 50) -> List[WholesaleProduct]:
        """도매꾹 검색"""
        return self._fetch(keyword=keyword, sort="se", size=display, market="dome")

    def search_supply(self, keyword: str, display: int = 50) -> List[WholesaleProduct]:
        """도매매 검색"""
        return self._fetch(keyword=keyword, sort="se", size=display, market="supply")

    def search_all(self, keyword: str, display: int = 50) -> List[WholesaleProduct]:
        """도매꾹 + 도매매 통합 검색"""
        dome   = self._fetch(keyword=keyword, sort="se", size=display, market="dome")
        supply = self._fetch(keyword=keyword, sort="se", size=display, market="supply")
        return dome + supply

    def _fetch(
        self,
        keyword: str = None,
        sort: str = "se",
        size: int = 50,
        page: int = 1,
        market: str = "dome",
        min_price: int = None,
        max_price: int = None,
        min_qty: int = None,
        max_qty: int = None,
        shipping: str = None,
        trusted_seller: bool = False,
    ) -> List[WholesaleProduct]:
        params = {
            "ver":    "4.1",
            "mode":   "getItemList",
            "aid":    self.api_key,
            "market": market,
            "om":     "json",
            "sz":     size,
            "pg":     page,
            "so":     sort,
        }

        if keyword:        params["kw"]  = keyword
        if min_price:      params["mnp"] = min_price
        if max_price:      params["mxp"] = max_price
        if min_qty:        params["mnq"] = min_qty
        if max_qty:        params["mxq"] = max_qty
        if shipping:       params["who"] = shipping
        if trusted_seller: params["sgd"] = "true"

        resp = requests.get(self.BASE_URL, params=params, timeout=10)
        resp.raise_for_status()

        data  = resp.json()
        items = data.get("domeggook", {}).get("list", {}).get("item", [])

        if isinstance(items, dict):
            items = [items]

        return [self._parse(item, market) for item in items]

    def _parse(self, item: dict, market: str = "dome") -> WholesaleProduct:
        deli   = item.get("deli", {})
        source = "domeggook" if market == "dome" else "domeme"
        return WholesaleProduct(
            source=        source,
            source_id=     str(item.get("no", "")),
            title=         item.get("title", ""),
            price=         int(item.get("price", 0)),
            currency=      "KRW",
            moq=           int(item.get("unitQty", 1)),
            seller=        item.get("id", ""),
            country=       "KR",
            url=           item.get("url", ""),
            shipping_type= deli.get("who", ""),
            shipping_fee=  int(deli.get("fee", 0) or 0),
            trade_type=    "CONSIGNMENT",
            raw_json=      str(item),
        )
