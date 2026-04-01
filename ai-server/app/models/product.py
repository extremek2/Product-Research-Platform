from sqlalchemy import Column, BigInteger, Text, TIMESTAMP
from sqlalchemy.sql import func

from app.models.base import Base


class Product(Base):

    __tablename__ = "product"

    id = Column(BigInteger, primary_key=True)

    title = Column(Text, nullable=False)

    brand = Column(Text)

    category = Column(Text)

    source = Column(Text)

    created_at = Column(TIMESTAMP, server_default=func.now())