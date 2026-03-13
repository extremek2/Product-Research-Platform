from app.db.database import SessionLocal
from app.models.source_product import SourceProduct


def save_source_products(products):

    db = SessionLocal()

    try:

        for p in products:

            item = SourceProduct(
                source=p["source"],
                source_product_id=p["id"],
                title=p["title"],
                price=p["price"],
                url=p["url"],
                seller=p.get("seller"),
                raw_json=str(p)
            )

            db.add(item)

        db.commit()

    finally:

        db.close()