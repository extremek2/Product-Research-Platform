from typing import Dict, Type
from app.crawler.base import RetailCrawler, WholesaleCrawler

# 소매 크롤러 등록
RETAIL_CRAWLERS: Dict[str, Type[RetailCrawler]] = {}

# 도매 크롤러 등록
WHOLESALE_CRAWLERS: Dict[str, Type[WholesaleCrawler]] = {}


def register_retail(key: str):
    """소매 크롤러 등록 데코레이터"""
    def decorator(cls):
        RETAIL_CRAWLERS[key] = cls
        return cls
    return decorator


def register_wholesale(key: str):
    """도매 크롤러 등록 데코레이터"""
    def decorator(cls):
        WHOLESALE_CRAWLERS[key] = cls
        return cls
    return decorator


def get_retail_crawler(source_key: str) -> RetailCrawler:
    cls = RETAIL_CRAWLERS.get(source_key)
    if not cls:
        raise ValueError(f"등록되지 않은 소매 크롤러: {source_key}")
    return cls()


def get_wholesale_crawler(source_key: str) -> WholesaleCrawler:
    cls = WHOLESALE_CRAWLERS.get(source_key)
    if not cls:
        raise ValueError(f"등록되지 않은 도매 크롤러: {source_key}")
    return cls()


def list_retail_crawlers():
    return list(RETAIL_CRAWLERS.keys())


def list_wholesale_crawlers():
    return list(WHOLESALE_CRAWLERS.keys())
