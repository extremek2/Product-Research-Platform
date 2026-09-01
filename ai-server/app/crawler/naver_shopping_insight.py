import requests
from typing import Dict, List, Optional
from app.core.config import NAVER_API_HUB_CLIENT_ID, NAVER_API_HUB_CLIENT_SECRET


class NaverShoppingInsightError(RuntimeError):
    """NAVER Shopping Insight request failed."""


class NaverShoppingInsightClient:
    CATEGORIES_URL = "https://naverapihub.apigw.ntruss.com/shopping/v1/categories"
    KEYWORDS_URL   = "https://naverapihub.apigw.ntruss.com/shopping/v1/category/keywords"

    # 카테고리 최대 3개씩 묶어서 요청
    CATEGORY_GROUPS = [
        {
            "가전":     "50000803",
            "생활용품": "50000006",
            "주방용품": "50000004",
        },
        {
            "패션의류": "50000000",
            "식품":     "50000008",
            "스포츠":   "50000013",
        },
    ]

    # 카테고리별 후보 키워드 (keywords API로 트렌드 비교)
    CATEGORY_KEYWORDS = {
        "가전":     ["로봇청소기", "공기청정기", "에어컨", "냉장고", "세탁기"],
        "생활용품": ["칫솔", "샴푸", "세탁세제", "방향제", "휴지"],
        "주방용품": ["에어프라이어", "전기밥솥", "냄비", "프라이팬", "식기세척기"],
        "패션의류": ["티셔츠", "청바지", "원피스", "자켓", "운동화"],
        "식품":     ["단백질쉐이크", "비타민", "홍삼", "견과류", "그래놀라"],
        "스포츠":   ["요가매트", "헬스장갑", "러닝화", "덤벨", "폼롤러"],
    }

    def __init__(
        self,
        client_id: str = NAVER_API_HUB_CLIENT_ID,
        client_secret: str = NAVER_API_HUB_CLIENT_SECRET,
        timeout: float = 10.0,
        session: Optional[requests.Session] = None,
    ):
        if not client_id or not client_secret:
            raise ValueError(
                "NAVER_API_HUB_CLIENT_ID와 NAVER_API_HUB_CLIENT_SECRET이 필요합니다."
            )

        self.headers = {
            "X-NCP-APIGW-API-KEY-ID": client_id,
            "X-NCP-APIGW-API-KEY": client_secret,
            "Content-Type": "application/json",
        }
        self.timeout = timeout
        self.session = session or requests.Session()

    def _post(self, url: str, body: Dict) -> Dict:
        try:
            response = self.session.post(
                url,
                headers=self.headers,
                json=body,
                timeout=self.timeout,
            )
            response.raise_for_status()
            return response.json()
        except (requests.RequestException, ValueError) as exc:
            raise NaverShoppingInsightError(f"NAVER Shopping Insight 요청 실패: {exc}") from exc

    def get_trending_keywords(
        self,
        start_date: str,
        end_date: str,
        top_categories: int = 3,
        top_keywords: int = 3,
    ) -> List[str]:
        """
        1단계: 카테고리 트렌드 비교 → 상위 카테고리 선별
        2단계: 카테고리별 후보 키워드 트렌드 비교 → 인기 키워드 추출
        """

        # 1단계: 카테고리 트렌드 수집 (3개씩 나눠서 요청)
        all_category_scores = []
        category_errors = []
        for group in self.CATEGORY_GROUPS:
            try:
                scores = self._get_category_scores(
                    categories=group,
                    start_date=start_date,
                    end_date=end_date,
                )
                all_category_scores.extend(scores)
            except Exception as e:
                print(f"[datalab] 카테고리 트렌드 요청 실패: {e}")
                category_errors.append(e)
                continue

        if category_errors and not all_category_scores:
            raise NaverShoppingInsightError("모든 카테고리 트렌드 요청이 실패했습니다.") from category_errors[0]

        # ratio 높은 순 정렬 → 상위 카테고리 선별
        all_category_scores.sort(key=lambda x: x["avg_ratio"], reverse=True)
        top = all_category_scores[:top_categories]
        print(f"[datalab] 트렌드 상위 카테고리: {[c['name'] for c in top]}")

        # 2단계: 카테고리별 키워드 트렌드 비교
        all_keywords = []
        keyword_errors = []
        for category in top:
            try:
                keywords = self._get_top_keywords(
                    category_name=category["name"],
                    category_id=category["id"],
                    start_date=start_date,
                    end_date=end_date,
                    top_n=top_keywords,
                )
                print(f"[datalab] {category['name']} 인기 키워드: {keywords}")
                all_keywords.extend(keywords)
            except Exception as e:
                print(f"[datalab] {category['name']} 키워드 실패: {e}")
                keyword_errors.append(e)
                continue

        if keyword_errors and len(keyword_errors) == len(top):
            raise NaverShoppingInsightError("모든 키워드 트렌드 요청이 실패했습니다.") from keyword_errors[0]

        return list(dict.fromkeys(all_keywords))

    def _get_category_scores(
        self,
        categories: Dict[str, str],
        start_date: str,
        end_date: str,
    ) -> List[Dict]:
        body = {
            "startDate": start_date,
            "endDate": end_date,
            "timeUnit": "month",
            "category": [
                {"name": name, "param": [cid]}
                for name, cid in categories.items()
            ]
        }

        results = self._post(self.CATEGORIES_URL, body).get("results", [])

        scores = []
        for result in results:
            name = result.get("title")
            data = result.get("data", [])
            if not data:
                continue
            avg_ratio = sum(d.get("ratio", 0) for d in data) / len(data)
            scores.append({
                "name": name,
                "id": categories.get(name),
                "avg_ratio": avg_ratio,
            })
        return scores

    def _get_top_keywords(
        self,
        category_name: str,
        category_id: str,
        start_date: str,
        end_date: str,
        top_n: int = 3,
    ) -> List[str]:
        """
        카테고리별 후보 키워드들의 트렌드 비교 → 상위 top_n 반환
        """
        candidates = self.CATEGORY_KEYWORDS.get(category_name, [])
        if not candidates:
            return []

        body = {
            "startDate": start_date,
            "endDate": end_date,
            "timeUnit": "month",
            "category": category_id,
            "keyword": [
                {"name": kw, "param": [kw]}
                for kw in candidates
            ],
            "device": "",
            "gender": "",
            "ages": []
        }

        results = self._post(self.KEYWORDS_URL, body).get("results", [])

        keyword_scores = {}
        for result in results:
            keyword = result.get("title", "")
            data = result.get("data", [])
            if not data:
                continue
            avg_ratio = sum(d.get("ratio", 0) for d in data) / len(data)
            keyword_scores[keyword] = avg_ratio

        sorted_kws = sorted(keyword_scores.items(), key=lambda x: x[1], reverse=True)
        return [kw for kw, _ in sorted_kws[:top_n]]
