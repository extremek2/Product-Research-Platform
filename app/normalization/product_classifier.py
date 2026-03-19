import re
from typing import Tuple
from enum import Enum


class ProductType(Enum):
    MAIN_PRODUCT = "MAIN"       # 본품
    ACCESSORY = "ACCESSORY"     # 액세서리/부품
    CONSUMABLE = "CONSUMABLE"   # 소모품
    UNKNOWN = "UNKNOWN"         # 판별 불가 → LLM 대상


# ─── 블랙리스트 (부품/액세서리 신호) ────────────────────────
BLACKLIST_KEYWORDS = {
    # 부품류
    "부품", "부속", "부속품", "예비품", "교체", "교환",
    "브러쉬", "브러시", "사이드브러쉬", "메인브러쉬",
    "필터", "헤파필터", "집진",
    "먼지통", "먼지봉투", "먼지컵",
    "배터리", "충전기", "어댑터",
    "호환", "전용",
    # 소모품류
    "종이호일", "기름종이", "유산지", "호일",
    "물걸레패드", "걸레패드", "극세사패드",
    # 수납/거치류
    "수납장", "거치대", "선반", "정리함", "보관함",
    "케이스", "커버", "보호필름",
    # 기타 액세서리
    "경사로", "문턱", "도어턱", "도어턱받침",
    "조립", "나사", "볼트",
}

# ─── 화이트리스트 (본품 신호) ────────────────────────────────
WHITELIST_KEYWORDS = {
    "본체", "본품", "정품",
    "풀구성", "풀세트", "올인원",
    "세트구성",
}

# ─── 카테고리별 가격 기준 ────────────────────────────────────
# (최소 본품 가격, 이상치 배율)
CATEGORY_PRICE_CONFIG = {
    "로봇청소기": {"min_main": 80000,  "outlier_ratio": 0.3},
    "에어프라이어": {"min_main": 30000, "outlier_ratio": 0.3},
    "공기청정기": {"min_main": 50000,  "outlier_ratio": 0.3},
    "청소기":     {"min_main": 30000,  "outlier_ratio": 0.3},
    "냄비":       {"min_main": 8000,   "outlier_ratio": 0.2},
    "프라이팬":   {"min_main": 8000,   "outlier_ratio": 0.2},
    "텀블러":     {"min_main": 5000,   "outlier_ratio": 0.2},
    "견과류":     {"min_main": 3000,   "outlier_ratio": 0.15},
}


def classify_product(
    title: str,
    price: int,
    category: str = None,
    category_avg_price: float = None,
) -> Tuple[ProductType, float, str]:
    """
    상품이 본품인지 부품/액세서리인지 판별

    Returns:
        (ProductType, confidence, reason)
    """
    title_lower = title.lower()

    # 1단계: 화이트리스트 체크 (본품 신호)
    for kw in WHITELIST_KEYWORDS:
        if kw in title_lower:
            return ProductType.MAIN_PRODUCT, 0.9, f"화이트리스트: {kw}"

    # 2단계: 블랙리스트 체크 (부품 신호)
    for kw in BLACKLIST_KEYWORDS:
        if kw in title_lower:
            return ProductType.ACCESSORY, 0.9, f"블랙리스트: {kw}"

    # 3단계: 절대 가격 기준 체크
    if category and category in CATEGORY_PRICE_CONFIG:
        config = CATEGORY_PRICE_CONFIG[category]
        min_main = config["min_main"]

        if price < min_main:
            return ProductType.ACCESSORY, 0.8, f"가격 하한선 미달: {price} < {min_main}"

    # 4단계: 이상치 탐지 (카테고리 평균가 대비)
    if category_avg_price and category_avg_price > 0:
        config = CATEGORY_PRICE_CONFIG.get(category, {})
        outlier_ratio = config.get("outlier_ratio", 0.2)

        if price < category_avg_price * outlier_ratio:
            return ProductType.ACCESSORY, 0.75, \
                f"이상치: {price} < 평균가({category_avg_price:.0f})의 {outlier_ratio*100:.0f}%"

    # 5단계: 판별 불가 → LLM 대상
    return ProductType.UNKNOWN, 0.5, "규칙으로 판별 불가"


def should_use_llm(product_type: ProductType, confidence: float) -> bool:
    """LLM 판별이 필요한지 여부"""
    return product_type == ProductType.UNKNOWN and confidence <= 0.5
