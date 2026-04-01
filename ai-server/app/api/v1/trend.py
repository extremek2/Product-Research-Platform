from fastapi import APIRouter
from app.tasks.trend_task import trend_task

router = APIRouter()

@router.post("/trigger")
def trigger_trend():
    task = trend_task.apply_async(queue="crawl")
    return {"task_id": task.id, "status": "queued"}

@router.get("/status/{task_id}")
def trend_status(task_id: str):
    task = trend_task.AsyncResult(task_id)
    return {"task_id": task_id, "status": task.status, "result": task.result}
