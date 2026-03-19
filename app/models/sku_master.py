from sqlalchemy import Column, BigInteger, Text, Float, Boolean, TIMESTAMP
from sqlalchemy.sql import func
from app.models.base import Base


class SkuMaster(Base):
    __tablename__ = "sku_master"

    id                    = Column(BigInteger, primary_key=True)
    normalized_sku        = Column(Text, unique=True)
    brand                 = Column(Text)
    model_number          = Column(Text)
    category              = Column(Text)
    color                 = Column(Text)
    variant               = Column(Text)
    extraction_confidence = Column(Float, default=0)
    extraction_method     = Column(Text, default="RULE")
    verified              = Column(Boolean, default=False)
    created_at            = Column(TIMESTAMP, server_default=func.now())
    updated_at            = Column(TIMESTAMP, server_default=func.now())
