from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class RetailProduct:
    """표준화된 소매 상품 데이터"""
    source:         str
    source_id:      str
    title:          str
    price:          int
    review_count:   int = 0
    purchase_count: int = 0
    rank:           int = 0
    brand:          str = None
    category:       str = None
    url:            str = None
    image_url:      str = None
    rating:         float = None
    seller:         str = None
    raw_json:       str = None


@dataclass
class WholesaleProduct:
    """표준화된 도매 상품 데이터"""
    source:         str
    source_id:      str
    title:          str
    price:          int
    currency:       str = "KRW"
    moq:            int = 1
    seller:         str = None
    country:        str = "KR"
    url:            str = None
    shipping_type:  str = None
    shipping_fee:   int = 0
    trade_type:     str = "CONSIGNMENT"
    raw_json:       str = None


class RetailCrawler(ABC):
    """소매 크롤러 추상 클래스 - 모든 소매 크롤러가 구현해야 함"""

    @property
    @abstractmethod
    def source_key(self) -> str:
        """크롤러 식별키 (registry 등록키와 동일)"""
        pass

    @abstractmethod
    def get_popular(
        self,
        category: str,
        display: int = 50,
        page: int = 1,
    ) -> List[RetailProduct]:
        """카테고리별 인기순 상품 조회"""
        pass

    @abstractmethod
    def search(
        self,
        keyword: str,
        sort: str = "popular",
        display: int = 50,
        page: int = 1,
    ) -> List[RetailProduct]:
        """키워드 검색"""
        pass


class WholesaleCrawler(ABC):
    """도매 크롤러 추상 클래스"""

    @property
    @abstractmethod
    def source_key(self) -> str:
        pass

    @abstractmethod
    def search(
        self,
        keyword: str,
        display: int = 50,
        page: int = 1,
    ) -> List[WholesaleProduct]:
        pass
