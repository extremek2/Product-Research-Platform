from celery import Celery
from celery.schedules import crontab
import os

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")

celery_app = Celery(
    "tasks",
    broker=REDIS_URL,
    backend=REDIS_URL,
    include=[
        "app.tasks.trend_task",
        "app.tasks.crawl_task",
        "app.tasks.cluster_task",
    ]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="Asia/Seoul",
    enable_utc=True,
    broker_connection_retry_on_startup=True,  # 경고 제거
    task_routes={
        "app.tasks.trend_task.*":   {"queue": "crawl"},
        "app.tasks.crawl_task.*":   {"queue": "crawl"},
        "app.tasks.cluster_task.*": {"queue": "cluster"},
    },
    beat_schedule={
        # 1. 매일 23:50 트렌드 키워드 수집 → crawl_task 자동 발행
        "daily-trend": {
            "task": "app.tasks.trend_task.trend_task",
            "schedule": crontab(hour=23, minute=50),
            "options": {"queue": "crawl"},
        },
        # 2. 매일 01:00 클러스터링 (크롤링 완료 후)
        "daily-cluster": {
            "task": "app.tasks.cluster_task.cluster_task",
            "schedule": crontab(hour=1, minute=0),
            "options": {"queue": "cluster"},
        },
    },
)
