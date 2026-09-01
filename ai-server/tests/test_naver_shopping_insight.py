import unittest
from unittest.mock import Mock

from app.crawler.naver_shopping_insight import (
    NaverShoppingInsightClient,
    NaverShoppingInsightError,
)


class NaverShoppingInsightClientTest(unittest.TestCase):
    def test_requires_api_hub_credentials(self):
        with self.assertRaises(ValueError):
            NaverShoppingInsightClient(client_id="", client_secret="")

    def test_category_request_uses_api_hub_headers_and_timeout(self):
        response = Mock()
        response.raise_for_status.return_value = None
        response.json.return_value = {
            "results": [{"title": "패션의류", "data": [{"ratio": 42.0}]}]
        }
        session = Mock()
        session.post.return_value = response
        client = NaverShoppingInsightClient(
            client_id="id", client_secret="secret", timeout=3.0, session=session
        )

        result = client._get_category_scores(
            {"패션의류": "50000000"}, "2026-01-01", "2026-05-31"
        )

        self.assertEqual(result[0]["avg_ratio"], 42.0)
        _, kwargs = session.post.call_args
        self.assertEqual(kwargs["timeout"], 3.0)
        self.assertEqual(kwargs["headers"]["X-NCP-APIGW-API-KEY-ID"], "id")
        self.assertEqual(kwargs["json"]["category"][0]["param"], ["50000000"])

    def test_wraps_transport_errors(self):
        session = Mock()
        session.post.side_effect = __import__("requests").Timeout("timeout")
        client = NaverShoppingInsightClient(
            client_id="id", client_secret="secret", session=session
        )

        with self.assertRaises(NaverShoppingInsightError):
            client._get_category_scores(
                {"패션의류": "50000000"}, "2026-01-01", "2026-05-31"
            )


if __name__ == "__main__":
    unittest.main()
