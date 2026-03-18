from abc import ABC, abstractmethod
from typing import List, Dict


# 나중에 도매꾹, 오너클랜 등 붙일 때 이 인터페이스만 구현하면 됨
class BaseCrawler(ABC):
    @abstractmethod
    def search(self, keyword: str) -> List[Dict]:
        """
        키워드로 상품 검색
        반환 형식: [{"title", "price", "seller", "url", "source"}, ...]
        """
        pass