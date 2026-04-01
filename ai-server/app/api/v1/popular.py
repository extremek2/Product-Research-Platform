from fastapi import APIRouter
from pydantic import BaseModel
from app.tasks.popular_task import crawl_popular_products

router = APIRouter()

class PopularRequest(BaseModel):
    category:   str
    source_key: str = "naver_shopping"

@router.post("/trigger")
def trigger_popular(req: PopularRequest):
    task = crawl_popular_products.apply_async(
        args=[req.category, req.source_key],
        queue="crawl"
    )
    return {
        "task_id":  task.id,
        "category": req.category,
        "source":   req.source_key,
        "status":   "queued",
    }

@router.get("/status/{task_id}")
def popular_status(task_id: str):
    task = crawl_popular_products.AsyncResult(task_id)
    return {"task_id": task_id, "status": task.status, "result": task.result}
