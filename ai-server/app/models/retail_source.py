from sqlalchemy import Column, BigInteger, Text, Boolean, Integer, TIMESTAMP
from sqlalchemy.sql import func
from app.models.base import Base


class RetailSource(Base):
    __tablename__ = "retail_source"

    id           = Column(BigInteger, primary_key=True)
    name         = Column(Text, nullable=False)
    source_key   = Column(Text, unique=True, nullable=False)
    crawler_type = Column(Text, default="API")
    is_active    = Column(Boolean, default=True)
    priority     = Column(Integer, default=0)
    rate_limit   = Column(Integer, default=1)
    created_at   = Column(TIMESTAMP, server_default=func.now())
