from sqlalchemy import Column, BigInteger, ForeignKey
from sqlalchemy import Float

from app.models.base import Base


class ProductClusterItem(Base):

    __tablename__ = "product_cluster_item"

    id = Column(BigInteger, primary_key=True)

    cluster_id = Column(
        BigInteger,
        ForeignKey("product_cluster.id")
    )

    product_id = Column(
        BigInteger,
        ForeignKey("product.id")
    )

    confidence_score = Column(Float)