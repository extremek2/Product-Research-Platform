from sqlalchemy import Column, BigInteger, Text, Numeric, Integer, Float, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from app.models.base import Base
from app.models.sku_master import SkuMaster
from app.models.retail_source import RetailSource


class RetailPopularProduct(Base):
    __tablename__ = "retail_popular_product"

    id             = Column(BigInteger, primary_key=True)
    source_id      = Column(BigInteger, ForeignKey("retail_source.id"))
    category       = Column(Text)
    search_keyword = Column(Text)
    title          = Column(Text, nullable=False)
    price          = Column(Numeric)
    review_count   = Column(Integer, default=0)
    purchase_count = Column(Integer, default=0)
    rank           = Column(Integer, default=0)
    brand          = Column(Text)
    model_number   = Column(Text)
    normalized_sku = Column(Text)
    sku_master_id  = Column(BigInteger, ForeignKey("sku_master.id"), nullable=True)
    seller         = Column(Text)
    url            = Column(Text)
    image_url      = Column(Text)
    rating         = Column(Float)
    raw_json       = Column(Text)
    collected_at   = Column(TIMESTAMP, server_default=func.now())
