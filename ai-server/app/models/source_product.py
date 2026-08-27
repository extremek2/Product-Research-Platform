from sqlalchemy import Column, BigInteger, Text, Numeric, TIMESTAMP
from sqlalchemy.sql import func

from app.models.base import Base


class SourceProduct(Base):

    __tablename__ = "source_product"

    id = Column(BigInteger, primary_key=True)

    source = Column(Text)

    source_product_id = Column(Text)

    search_keyword = Column(Text)

    title = Column(Text)

    price = Column(Numeric)

    url = Column(Text)

    seller = Column(Text)

    raw_json = Column(Text)

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )
