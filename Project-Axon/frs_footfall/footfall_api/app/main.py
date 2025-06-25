from fastapi import FastAPI
from app.generators import (
    generate_footfall_sensor_record,
    generate_footfall_summary_record,
    generated_dates_set  # <- Import the set
)

app = FastAPI(
    title="Footfall Data Generator API",
    description="API that returns randomly generated footfall sensor and summary data.",
    version="1.0.0"
)

@app.get("/footfall/sensor", tags=["Sensor Data"])
def get_sensor_data():
    return generate_footfall_sensor_record()

@app.get("/footfall/summary", tags=["Summary Data"])
def get_summary_data():
    data = generate_footfall_summary_record()
    if data is None:
        return {"message": "No more unique dates available."}
    return data

@app.post("/footfall/summary/reset", tags=["Summary Data"])
def reset_summary_data():
    generated_dates_set.clear()
    return {"status": "Reset successful"}

