from faker import Faker
import random
import uuid
from datetime import datetime, timedelta

faker = Faker()

# Function to generate a random date within a range
def random_date(start_date, end_date):
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return start_date + timedelta(days=random_days)

# Function to generate CallCenterInteraction dummy data
def generate_call_center_interaction():
    # Generate a single call center interaction instead of two
    interaction = {
        "InteractionID": faker.random_int(min=1, max=99),
        "CustomerID": faker.random_int(min=1, max=99),
        "AgentID": faker.random_int(min=1, max=99),
        "InteractionTime": faker.date_time_this_year().isoformat(),
        "InteractionDate": faker.date_this_year().isoformat(), 
        "CallType": random.choice(["Complaint", "Inquiry", "Request"]),
        "Duration": random.randint(1, 60),  # Call duration in minutes
        "SatisfactionRating": random.randint(1, 5),  # Satisfaction rating (1-5)
        "IssueResolved": random.choice(["Yes", "No"])  # Issue resolved (Yes/No)
    }
    return interaction

# Function to generate Customer Complaint dummy data
# Function to generate Customer Complaint dummy data
def generate_customer_complaint():
    # Generate a valid complaint date between 2019 and today
    complaint_date = random_date(datetime(2019, 1, 1), datetime.today())

    resolution_start = complaint_date + timedelta(days=random.randint(1, 10))
    resolution_end = resolution_start + timedelta(days=random.randint(1, 20))

    # Ensure resolution dates do not go beyond today
    resolution_start = min(resolution_start, datetime.today())
    resolution_end = min(resolution_end, datetime.today())

    resolution_time = (resolution_end - resolution_start).days if resolution_end else None

    complaint = {
        "ComplaintID": faker.random_int(min=1, max=99),
        "CustomerID": faker.random_int(min=1, max=99),
        "ComplaintDate": complaint_date.date().isoformat(),
        "ComplaintType": random.choice(["Service", "Product", "Billing"]),
        "ComplaintStatus": random.choice(["Pending", "Resolved"]),
        "ResolutionStartDate": resolution_start.date().isoformat() if resolution_start else None,
        "ResolutionEndDate": resolution_end.date().isoformat() if resolution_end else None,
        "ResolutionTime": resolution_time if resolution_end else None,
        "ResolutionDetails": faker.sentence() if resolution_end else "Resolution in progress"
    }
    return complaint
