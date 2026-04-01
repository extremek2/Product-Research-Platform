from sqlalchemy import Column, BigInteger, Text, Float, Integer, TIMESTAMP
from sqlalchemy.sql import func
from app.models.base import Base


class TrendAnalysis(Base):
    __tablename__ = "trend_analysis"

    id                   = Column(BigInteger, primary_key=True)
    keyword              = Column(Text, nullable=False)
    category             = Column(Text)
    naver_search_trend   = Column(Float, default=0)
    naver_shopping_trend = Column(Float, default=0)
    google_trend         = Column(Float, default=0)
    trend_type           = Column(Text, default="UNKNOWN")
    peak_month           = Column(Integer)
    momentum             = Column(Float, default=0)
    volatility           = Column(Float, default=0)
    confidence           = Column(Float, default=0)
    raw_data             = Column(Text)
    analyzed_at          = Column(TIMESTAMP, server_default=func.now())
