from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def root():
    return {"message": "product research platform running"}