from sqlalchemy import Column, BigInteger, ForeignKey
from sqlalchemy import Integer, Float, Text, TIMESTAMP
from sqlalchemy.sql import func

from app.models.base import Base


class ProductSnapshot(Base):

    __tablename__ = "product_snapshot"

    id = Column(BigInteger, primary_key=True)

    product_id = Column(
        BigInteger,
        ForeignKey("product.id")
    )

    price = Column(Integer)

    rating = Column(Float)

    review_count = Column(Integer)

    seller_name = Column(Text)

    crawled_at = Column(TIMESTAMP, server_default=func.now())