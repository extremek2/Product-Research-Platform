from fastapi import APIRouter
from pydantic import BaseModel
from app.tasks.wholesale_task import crawl_wholesale_domeggook

router = APIRouter()

class WholesaleRequest(BaseModel):
    keyword: str

@router.post("/domeggook/trigger")
def trigger_domeggook(req: WholesaleRequest):
    task = crawl_wholesale_domeggook.apply_async(
        args=[req.keyword],
        queue="crawl"
    )
    return {"task_id": task.id, "keyword": req.keyword, "status": "queued"}

@router.get("/domeggook/status/{task_id}")
def domeggook_status(task_id: str):
    task = crawl_wholesale_domeggook.AsyncResult(task_id)
    return {"task_id": task_id, "status": task.status, "result": task.result}
