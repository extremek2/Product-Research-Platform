from fastapi import APIRouter
from app.api.v1 import cluster, trend, wholesale

router = APIRouter(prefix="/api/v1")
router.include_router(cluster.router,   prefix="/cluster",   tags=["cluster"])
router.include_router(trend.router,     prefix="/trend",     tags=["trend"])
router.include_router(wholesale.router, prefix="/wholesale", tags=["wholesale"])
