from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

SERVICE_TYPES = [
    "Cash Withdrawal", "Cash Deposit", "Loan Inquiry",
    "Account Opening", "Cheque Deposit", "Balance Inquiry"
]

STATUSES = ["Completed", "Pending", "Escalated", "Cancelled"]

def generate_random_datetime(start_year=2021, end_year=2025):
    start = datetime(start_year, 1, 1)
    end = datetime(end_year, 12, 31, 23, 59)
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=random_seconds)

def generate_counter_service_record():
    record_time = generate_random_datetime()
    queue_minutes = random.randint(2, 20)
    service_minutes = random.randint(5, 30)
    total_minutes = queue_minutes + service_minutes

    return {
        "CounterID": random.randint(10000, 99999),
        "BranchID": random.randint(1, 99),
        "Service_ticket_id": random.randint(10000000, 99999999),
        "ServiceType": random.choice(SERVICE_TYPES),
        "CustomerID": random.randint(1, 99),
        "QueueTime": f"{queue_minutes} minutes",
        "ServiceTime": f"{service_minutes} minutes",
        "TotalTime": f"{total_minutes} minutes",
        "TellerID": f"TELL-{random.randint(100, 999)}",
        "Status": random.choices(STATUSES, weights=[70, 15, 10, 5], k=1)[0],
        "Record_Date": record_time.date().isoformat(),
        "TimeStamp": record_time.time().isoformat(timespec="seconds")
    }

