from fastapi import FastAPI
from app.api.v1.router import router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Product Research Platform")
app.include_router(router)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok"}