from faker import Faker
import random
import uuid
from datetime import datetime, timedelta

faker = Faker()

# Function to generate a random date within a range
def random_date(start_year=2019):
    today = datetime.today()
    start_date = datetime(start_year, 1, 1)
    delta = today - start_date
    random_days = random.randint(0, delta.days)
    return (start_date + timedelta(days=random_days)).strftime('%Y-%m-%d')                                                                                                                                                  

# Function to generate dummy data for CampaignDetails table
def generate_campaign_details():
    start_date = datetime.today() - timedelta(days=random.randint(0, 365))  # Past year
    end_date = start_date + timedelta(days=random.randint(7, 90))  # Between 7 to 90 days after start

    # Ensuring dates are within valid range (2019 - today)
    start_date = max(start_date, datetime(2019, 1, 1))
    end_date = min(end_date, datetime.today())

    campaign = {
        "CampaignID": random.randint(1, 100),
        "CampaignName": f"{faker.company()} Loan Offer",
        "StartDate": start_date.strftime('%Y-%m-%d'),
        "EndDate": end_date.strftime('%Y-%m-%d'),
        "Budget": round(random.uniform(10000, 500000), 2),
        "Status": random.choice(["Active", "Completed", "Pending"]),
        "Channel": random.choice(["Bank Website", "Email", "SMS", "In-Branch"]),
        "SeasonID": random.randint(1, 4)
    }
    return campaign

# Function to generate dummy data for CampaignPerformance table
def generate_campaign_performance(campaign):
    performance = {
        "PerformanceID": str(uuid.uuid4()),
        "CampaignID": campaign["CampaignID"],
        "TotalResponses": random.randint(1000, 50000),
        "ClickThroughRate": round(random.uniform(1.5, 15.0), 2),
        "ConversionRate": round(random.uniform(0.5, 10.0), 2),
        "RevenueGenerated": round(random.uniform(5000, 200000), 2),
        "AverageScore": round(random.uniform(3.0, 9.5), 2),
        "SalesVolume": random.randint(100, 10000)
    }
    return performance

# Function to generate dummy data for SalesSeasonality table
def generate_sales_seasonality():
    seasons = ["Summer", "Festive", "Off-Peak", "Winter"]
    season_data = {
        "SeasonID": random.randint(1, 4),
        "SeasonName": random.choice(seasons),
        "RevenueGenerated": round(random.uniform(100000, 5000000), 2),
        "SalesVolume": random.randint(5000, 100000),
        "CustomerRetentionRate": round(random.uniform(50.0, 90.0), 2)
    }
    return season_data

# Function to generate dummy data for CustomerCampaign table
def generate_customer_campaign():
    enrolled_at = datetime.today() - timedelta(days=random.randint(0, 365))  # Past year
    enrolled_at = max(enrolled_at, datetime(datetime.today().year, 1, 1))  # Ensure it's within this year

    customer_campaign = {
        "customer_campaign_id": random.randint(1, 99),
        "customer_id": random.randint(1, 99),
        "campaign_id": random.randint(1, 99),
        "enrolled_at": enrolled_at.strftime('%Y-%m-%d')
    }
    return customer_campaign
