from fastapi import APIRouter
from app.tasks.cluster_task import cluster_task

router = APIRouter()

@router.post("/trigger")
def trigger_cluster():
    task = cluster_task.apply_async(queue="cluster")
    return {"task_id": task.id, "status": "queued"}

@router.get("/status/{task_id}")
def cluster_status(task_id: str):
    task = cluster_task.AsyncResult(task_id)
    return {"task_id": task_id, "status": task.status, "result": task.result}