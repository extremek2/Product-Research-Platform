import re


BRAND_MAP = {

    "xiaomi": "xiaomi",
    "샤오미": "xiaomi",
    "mi": "xiaomi",

    "samsung": "samsung",
    "삼성": "samsung",

    "lg": "lg",
    "엘지": "lg"
}


def normalize_title(title: str):

    text = title.lower()

    text = remove_special(text)

    text = normalize_brand(text)

    text = normalize_spaces(text)

    return text


def remove_special(text):

    text = re.sub(r"\[.*?\]", "", text)

    text = re.sub(r"[^\w\s가-힣]", " ", text)

    return text


def normalize_brand(text):

    for key, value in BRAND_MAP.items():

        text = text.replace(key, value)

    return text


def normalize_spaces(text):

    text = re.sub(r"\s+", " ", text)

    return text.strip()