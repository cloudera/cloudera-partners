from faker import Faker
import random
from datetime import datetime, timedelta

faker = Faker()

# Function to generate a random date between two dates
def random_date(start_year=2019):
    current_date = datetime.today()
    start_date = datetime(start_year, 1, 1)
    delta = current_date - start_date
    random_days = random.randint(0, delta.days)
    return (start_date + timedelta(days=random_days)).strftime('%Y-%m-%d')

# Function to generate dummy data for NPS Responses table
def generate_nps_responses():
    score = random.randint(0, 10)
    response = {
        "ResponseID": random.randint(1, 99),
        "CustomerID": random.randint(1, 99),
        "SurveyDate": random_date(2019),
        "Score": score,
        "Comment": faker.sentence(),
        "SatisfactionLevel": "Promoter" if score >= 9 else "Passive" if score >= 7 else "Detractor",
        "SurveyChannel": random.choice(["Email", "SMS", "Phone", "Online Banking"])
    }
    return response
