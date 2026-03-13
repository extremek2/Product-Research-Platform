from celery.schedules import crontab
from app.celery.celery_app import celery_app
from app.worker.crawler_worker import crawl_task
from app.worker.cluster_worker import cluster_task

# 매일 0시 크롤링, 클러스터링
celery_app.conf.beat_schedule = {
    "daily-crawl": {
        "task": "app.worker.crawler_worker.crawl_task",
        "schedule": crontab(hour=0, minute=0)
    },
    "daily-cluster": {
        "task": "app.worker.cluster_worker.cluster_task",
        "schedule": crontab(hour=1, minute=0)  # 크롤 후 1시간 뒤
    }
}