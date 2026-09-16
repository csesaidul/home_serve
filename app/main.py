from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "HomeServe API is running successfully!"}