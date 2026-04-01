from sqlalchemy import Column, BigInteger, Text, TIMESTAMP
from sqlalchemy.sql import func

from app.models.base import Base


class ProductCluster(Base):

    __tablename__ = "product_cluster"

    id = Column(BigInteger, primary_key=True)

    cluster_name = Column(Text)

    created_at = Column(
        TIMESTAMP,
        server_default=func.now()
    )