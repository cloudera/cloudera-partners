from fastapi import FastAPI
from .generator import generate_counter_service_record

app = FastAPI()

@app.get("/api/counter_service")
def get_counter_service_record():
    return generate_counter_service_record()

