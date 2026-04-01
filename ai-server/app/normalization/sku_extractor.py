import re
from typing import Optional
from dataclasses import dataclass


@dataclass
class SkuResult:
    brand: Optional[str] = None
    model_number: Optional[str] = None
    category: Optional[str] = None
    color: Optional[str] = None
    variant: Optional[str] = None
    normalized_sku: Optional[str] = None
    confidence: float = 0.0
    extraction_method: str = "RULE"


BRAND_MAP = {
    "roborock": "roborock", "로보락": "roborock",
    "dreame": "dreame", "드리미": "dreame",
    "narwal": "narwal", "나르왈": "narwal",
    "everybot": "everybot", "에브리봇": "everybot",
    "xiaomi": "xiaomi", "샤오미": "xiaomi",
    "samsung": "samsung", "삼성": "samsung",
    "lg": "lg", "엘지": "lg",
    "dyson": "dyson", "다이슨": "dyson",
    "irobot": "irobot", "아이로봇": "irobot",
    "ecovacs": "ecovacs", "에코백스": "ecovacs",
    "proscenic": "proscenic",
    "ninja": "ninja", "닌자": "ninja",
    "cuisinart": "cuisinart", "쿠진아트": "cuisinart",
    "cosori": "cosori", "코소리": "cosori",
    "phillips": "philips", "philips": "philips", "필립스": "philips",
    "cuckoo": "cuckoo", "쿠쿠": "cuckoo",
    "stanley": "stanley", "스탠리": "stanley",
    "yeti": "yeti", "예티": "yeti",
    "3m": "3m",
    "tefal": "tefal", "테팔": "tefal",
    "instant": "instantpot", "인스턴트팟": "instantpot",
    "gourmia": "gourmia",
    "nuwave": "nuwave",
    "chefman": "chefman",
}

# 브랜드가 아닌 것들 (대폭 확장)
NOT_BRAND = {
    # 수식어/마케팅
    "당일", "무료", "특가", "정품", "국내", "신제품", "최저가",
    "고급", "프리미엄", "최신", "인기", "베스트", "추천",
    "대용량", "소용량", "업소용", "가정용", "휴대용",
    # 숫자/단위
    "1개", "2개", "3개", "4개", "5개", "10개",
    "1세트", "2세트", "3세대", "2세대", "1세대",
    # 제품 카테고리
    "로봇청소기", "청소기", "에어프라이어", "공기청정기",
    "냄비", "프라이팬", "텀블러", "가습기", "선풍기",
    "전기밥솥", "밥솥", "블렌더", "믹서기", "토스터",
    "커피머신", "커피메이커", "전기포트", "전기주전자",
    # 소재/재질
    "스텐", "스테인리스", "실리콘", "유리", "플라스틱",
    "원목", "나무", "세라믹", "코팅", "논스틱",
    "친환경", "무독성", "천연",
    # 형태/모양
    "원형", "사각", "타원", "직사각",
    "대형", "중형", "소형", "미니",
    # 음식/요리
    "통구이", "에어프라이어팟", "한지", "기름종이",
    "스페인산", "국산", "수입산",
    # 기타 흔한 명사
    "크린랩", "제이씨", "리빙밸류",  # 실제론 브랜드일 수 있으나 신뢰도 낮음
    "무선", "스마트", "자동", "전자",
    "문턱", "도어턱", "경사로", "액세서리",
    "세트", "단품", "구성",
}

NOISE_PATTERNS = [
    r'\[.*?\]', r'\(.*?\)',
    r'\+.*$',
    r'최저가|특가|한정|당일|무료배송|정품|공식',
    r'당일출발|빠른배송|로켓배송',
    r'20\d{2}년형?|25년형?|신제품',
    r'1\+1|1\+2',
    r'\d+개입|\d+매|\d+팩|\d+롤',  # 수량 표기
]

MODEL_PATTERNS = [
    r'[A-Z]\d+[A-Z]?\s*(?:maxv|ultra|pro|plus|max|gen\d)?(?:\s*ultra)?',
    r'[A-Z]{1,3}\d+[A-Z]*',
    r'[A-Z]{2,3}-[A-Z0-9]+',
    r'\d+[A-Z]\d+[A-Z]',
    r'[gG]\d{3,4}',
]

COLOR_MAP = {
    "화이트": "화이트", "white": "화이트", "흰색": "화이트",
    "블랙": "블랙", "black": "블랙", "검정": "블랙",
    "그레이": "그레이", "gray": "그레이", "grey": "그레이",
    "실버": "실버", "silver": "실버",
    "골드": "골드", "gold": "골드",
    "레드": "레드", "red": "레드",
    "블루": "블루", "blue": "블루",
}

VARIANT_MAP = {
    "물통형": "물통형", "직배수형": "직배수형",
    "자동급배수": "자동급배수", "물걸레": "물걸레",
    "올인원": "올인원", "단품": "단품",
}


def _extract_brand_from_map(text: str) -> Optional[str]:
    for keyword, brand in BRAND_MAP.items():
        pattern = r'(?<![a-zA-Z가-힣])' + re.escape(keyword) + r'(?![a-zA-Z가-힣])'
        if re.search(pattern, text, re.IGNORECASE):
            return brand
    return None


def _extract_brand_from_position(clean_title: str) -> Optional[str]:
    """
    위치 기반 브랜드 추출 - 엄격한 조건 적용
    영문 브랜드명만 허용 (한글은 오추출 위험 높음)
    """
    tokens = clean_title.strip().split()
    if not tokens:
        return None

    first = tokens[0]

    # 제외 목록
    if first in NOT_BRAND or first.lower() in NOT_BRAND:
        return None

    # 너무 짧거나 숫자만
    if len(first) < 2 or first.isdigit():
        return None

    # 모델번호 패턴이면 스킵
    if re.match(r'^[A-Z]\d+', first, re.IGNORECASE):
        return None

    # 숫자 포함된 한글은 스킵 (예: "한지기름종이-5개")
    if re.search(r'\d', first) and re.search(r'[가-힣]', first):
        return None

    # 특수문자 포함이면 스킵
    if re.search(r'[-_/]', first):
        return None

    # 영문만 허용 (한글 위치 기반 추출은 오류 너무 많음)
    if re.match(r'^[a-zA-Z]+$', first):
        return first.lower()

    return None  # 한글 브랜드는 위치 기반으로 추출 안 함


def extract_sku(title: str, search_keyword: str = None) -> SkuResult:
    result = SkuResult()

    clean = title
    for pattern in NOISE_PATTERNS:
        clean = re.sub(pattern, "", clean, flags=re.IGNORECASE)
    clean = re.sub(r'\s+', ' ', clean).strip()
    text = clean.lower()

    # 브랜드 추출 (맵 우선, 위치 기반은 영문만)
    brand = _extract_brand_from_map(text)
    if brand:
        result.brand = brand
        result.confidence += 0.4
    else:
        brand = _extract_brand_from_position(clean)
        if brand:
            result.brand = brand
            result.confidence += 0.2

    # 모델번호
    for pattern in MODEL_PATTERNS:
        match = re.search(pattern, clean, re.IGNORECASE)
        if match:
            model = match.group().strip()
            if len(model) >= 3 and model.lower() not in ['pro', 'max', 'gen']:
                result.model_number = model.upper().replace(' ', '')
                result.confidence += 0.3
                break

    # 색상
    for keyword, color in COLOR_MAP.items():
        if keyword.lower() in text:
            result.color = color
            result.confidence += 0.1
            break

    # 옵션
    for keyword, variant in VARIANT_MAP.items():
        if keyword in text:
            result.variant = variant
            result.confidence += 0.1
            break

    if search_keyword:
        result.category = search_keyword

    # SKU 생성 (브랜드 or 모델번호 있을 때만)
    parts = []
    if result.brand:        parts.append(result.brand)
    if result.model_number: parts.append(result.model_number)
    if result.variant:      parts.append(result.variant)
    if result.color:        parts.append(result.color)

    if result.brand or result.model_number:
        result.normalized_sku = "-".join(parts)
    elif search_keyword:
        from app.normalization.product_normalizer import normalize_title
        result.normalized_sku = f"{search_keyword}-{normalize_title(clean)[:30]}"
        result.confidence = 0.1

    return result
