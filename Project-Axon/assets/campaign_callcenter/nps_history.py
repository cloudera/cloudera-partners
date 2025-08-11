from flask import Flask, jsonify
from faker import Faker
import random
import uuid
import json
from datetime import datetime, timedelta

app = Flask(__name__)
faker = Faker()

# Function to generate a random date within a range
def random_date(start_date, end_date):
    delta = end_date - start_date
    random_days = random.randint(0, delta.days)
    return (start_date + timedelta(days=random_days)).strftime('%Y-%m-%d')

# Function to read the history store (JSON file) that holds previously generated IDs
def read_history_store():
    try:
        with open('history_store.json', 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        return {}

# Function to write the history store (JSON file) with newly generated IDs
def write_history_store(history):
    with open('history_store.json', 'w') as file:
        json.dump(history, file)

# Function to generate a unique NPS Response
def generate_unique_nps_response():
    history = read_history_store()  # Load history from the file
    
    while True:
        # Generate unique ResponseID and CustomerID
        response_id = random.randint(1, 99)
        customer_id = faker.random_int(min=1, max=99)
        
        # If the ResponseID has been generated before, regenerate it
        if response_id in history.get("ResponseIDs", []):
            continue
        else:
            # Add to history store and break the loop
            history.setdefault("ResponseIDs", []).append(response_id)
            history.setdefault("CustomerIDs", []).append(customer_id)
            write_history_store(history)  # Save the updated history
            break
    
    score = random.randint(0, 10)
    response = {
        "ResponseID": response_id,  # Unique ResponseID
        "CustomerID": customer_id,  # Unique CustomerID
        "SurveyDate": random_date(datetime.today() - timedelta(days=730), datetime.today()),  # Random survey date
        "Score": score,
        "Comment": faker.sentence(),  # Random comment related to banking services
        "SatisfactionLevel": "Promoter" if score >= 9 else "Passive" if score >= 7 else "Detractor",
        "SurveyChannel": random.choice(["Email", "SMS", "Phone", "Online Banking"])  # Random survey channel
    }
    
    return response

# Endpoint to generate a single unique NPS Response data (bank-related)
@app.route('/nps-responses', methods=['GET'])
def generate_nps_responses():
    response = generate_unique_nps_response()  # Generate a unique response
    return jsonify(response)

# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8200)  # Running the Flask app on port 8200
