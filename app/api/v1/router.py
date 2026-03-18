from fastapi import APIRouter
from app.api.v1 import crawl, cluster, trend

router = APIRouter(prefix="/api/v1")
router.include_router(crawl.router,   prefix="/crawl",   tags=["crawl"])
router.include_router(cluster.router, prefix="/cluster", tags=["cluster"])
router.include_router(trend.router,   prefix="/trend",   tags=["trend"])
