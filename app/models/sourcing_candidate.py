from sqlalchemy import Column, BigInteger, Text, Numeric, Integer, Float, TIMESTAMP, ForeignKey
from sqlalchemy.sql import func
from app.models.base import Base
from app.models.trend_analysis import TrendAnalysis


class SourcingCandidate(Base):
    __tablename__ = "sourcing_candidate"

    id                    = Column(BigInteger, primary_key=True)
    trend_analysis_id     = Column(BigInteger, ForeignKey("trend_analysis.id"), nullable=True)
    keyword               = Column(Text, nullable=False)
    category              = Column(Text)
    retail_min_price      = Column(Numeric)
    retail_avg_price      = Column(Numeric)
    retail_product_count  = Column(Integer, default=0)
    competition_level     = Column(Text, default="UNKNOWN")
    estimated_margin_rate = Column(Float)
    sourcing_status       = Column(Text, default="PENDING")
    memo                  = Column(Text)
    created_at            = Column(TIMESTAMP, server_default=func.now())
    updated_at            = Column(TIMESTAMP, server_default=func.now())
