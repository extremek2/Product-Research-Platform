from fastapi import APIRouter
from pydantic import BaseModel
from app.tasks.crawl_task import crawl_task

router = APIRouter()

class CrawlRequest(BaseModel):
    keyword: str

@router.post("/trigger")
def trigger_crawl(req: CrawlRequest):
    task = crawl_task.apply_async(
        args=[req.keyword],
        queue="crawl"
    )
    return {"task_id": task.id, "keyword": req.keyword, "status": "queued"}

@router.get("/status/{task_id}")
def crawl_status(task_id: str):
    task = crawl_task.AsyncResult(task_id)
    return {"task_id": task_id, "status": task.status, "result": task.result}