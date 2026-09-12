import ast
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]

# Temporary debt allowlist. Entries must only be removed as migrations complete.
LEGACY_PYTHON_CORE_TABLES = {
    "product",
    "product_cluster",
    "product_cluster_item",
    "retail_popular_product",
    "retail_source",
    "sku_master",
    "source_product",
    "wholesale_product",
    "wholesale_source",
}

LEGACY_BROWSER_FASTAPI_FILES = {
    Path("frontend/src/pages/ResearchPage.js"),
}


def sqlalchemy_table_names():
    names = set()
    model_root = REPOSITORY_ROOT / "ai-server/app/models"
    for path in model_root.glob("*.py"):
        tree = ast.parse(path.read_text(), filename=str(path))
        for node in ast.walk(tree):
            if not isinstance(node, ast.Assign):
                continue
            if not any(
                isinstance(target, ast.Name) and target.id == "__tablename__"
                for target in node.targets
            ):
                continue
            if isinstance(node.value, ast.Constant) and isinstance(node.value.value, str):
                names.add(node.value.value)
    return names


def browser_fastapi_files():
    markers = ("REACT_APP_AI_API_URL", "VITE_AI_API_URL", "localhost:8000")
    matches = set()
    frontend_root = REPOSITORY_ROOT / "frontend/src"
    for path in frontend_root.rglob("*"):
        if path.suffix not in {".js", ".jsx", ".ts", ".tsx"}:
            continue
        if any(marker in path.read_text() for marker in markers):
            matches.add(path.relative_to(REPOSITORY_ROOT))
    return matches


class P0ArchitectureBoundaryTest(unittest.TestCase):
    def test_python_does_not_map_additional_core_tables(self):
        unexpected = sqlalchemy_table_names() - LEGACY_PYTHON_CORE_TABLES
        self.assertEqual(
            unexpected,
            set(),
            f"새 코어 테이블을 Python SQLAlchemy에 매핑하지 마세요: {unexpected}",
        )

    def test_browser_does_not_add_more_fastapi_dependencies(self):
        unexpected = browser_fastapi_files() - LEGACY_BROWSER_FASTAPI_FILES
        self.assertEqual(
            unexpected,
            set(),
            f"브라우저는 Spring Core API만 호출해야 합니다: {unexpected}",
        )


if __name__ == "__main__":
    unittest.main()
