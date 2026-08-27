from sqlalchemy import Column, BigInteger, Text, Numeric, Integer, Boolean, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from app.models.base import Base
from app.models.sku_master import SkuMaster


class WholesaleSource(Base):
    __tablename__ = "wholesale_source"

    id           = Column(BigInteger, primary_key=True)
    name         = Column(Text, nullable=False)
    source_key   = Column(Text, unique=True, nullable=False)
    country      = Column(Text, default="KR")
    base_url     = Column(Text)
    crawler_type = Column(Text)
    is_active    = Column(Boolean, default=True)
    created_at   = Column(TIMESTAMP, server_default=func.now())


class WholesaleProduct(Base):
    __tablename__ = "wholesale_product"

    id                = Column(BigInteger, primary_key=True)
    sku_master_id     = Column(BigInteger, ForeignKey("sku_master.id"), nullable=True)
    source_id         = Column(BigInteger, ForeignKey("wholesale_source.id"))
    source_product_id = Column(Text)
    trade_type        = Column(Text, default="PURCHASE")
    title             = Column(Text, nullable=False)
    price             = Column(Numeric)
    currency          = Column(Text, default="KRW")
    moq               = Column(Integer, default=1)
    supplier          = Column(Text)
    country           = Column(Text, default="KR")
    normalized_sku    = Column(Text)
    brand             = Column(Text)
    model_number      = Column(Text)
    search_keyword    = Column(Text)          # ← 추가
    url               = Column(Text)
    raw_json          = Column(Text)
    collected_at      = Column(TIMESTAMP, server_default=func.now())
