from flask import Flask, jsonify
from faker import Faker
import random

# Initialize Flask app and Faker
app = Flask(__name__)
fake = Faker()

# 1. Customer Class
class Customer:
    def __init__(self, customer_id):
        self.customer_id = customer_id
        self.first_name = fake.first_name()
        self.last_name = fake.last_name()
        self.email = fake.email()
        self.phone = fake.phone_number()
        self.dob = fake.date_of_birth()
        self.address = fake.address()
        self.city = fake.city()
        self.state = fake.state()
        self.postal_code = fake.zipcode()
        self.country = fake.country()
        self.status = random.choice(['Active', 'Inactive', 'Lead', 'Prospect'])
        self.source = random.choice(['Website', 'Referral', 'Campaign', 'Social Media'])
        self.created_at = fake.date_this_decade()
        self.updated_at = fake.date_this_year()

    def to_dict(self):
        return {
            'customer_id': self.customer_id,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'email': self.email,
            'phone': self.phone,
            'dob': str(self.dob),
            'address': self.address,
            'city': self.city,
            'state': self.state,
            'postal_code': self.postal_code,
            'country': self.country,
            'status': self.status,
            'source': self.source,
            'created_at': str(self.created_at),
            'updated_at': str(self.updated_at)
        }

# 2. Interaction Class
class Interaction:
    def __init__(self, interaction_id, customer_id):
        self.interaction_id = interaction_id
        self.customer_id = customer_id
        self.interaction_type = random.choice(['Call', 'Email', 'Meeting'])
        self.interaction_date = fake.date_this_year()
        self.notes = fake.text()
        self.created_at = fake.date_this_year()
        self.updated_at = fake.date_this_year()

    def to_dict(self):
        return {
            'interaction_id': self.interaction_id,
            'customer_id': self.customer_id,
            'interaction_type': self.interaction_type,
            'interaction_date': str(self.interaction_date),
            'notes': self.notes,
            'created_at': str(self.created_at),
            'updated_at': str(self.updated_at)
        }

# 3. Sale Class
class Sale:
    def __init__(self, sale_id, customer_id):
        self.sale_id = sale_id
        self.customer_id = customer_id
        self.product_id = random.randint(1, 50)  # Assuming 50 products
        self.sale_date = fake.date_this_year()
        self.quantity = random.randint(1, 10)
        self.total_amount = round(random.uniform(10.0, 500.0), 2)
        self.sale_status = random.choice(['Completed', 'Pending', 'Cancelled'])
        self.created_at = fake.date_this_year()
        self.updated_at = fake.date_this_year()

    def to_dict(self):
        return {
            'sale_id': self.sale_id,
            'customer_id': self.customer_id,
            'product_id': self.product_id,
            'sale_date': str(self.sale_date),
            'quantity': self.quantity,
            'total_amount': self.total_amount,
            'sale_status': self.sale_status,
            'created_at': str(self.created_at),
            'updated_at': str(self.updated_at)
        }

# 4. Product Class
class Product:
    def __init__(self, product_id):
        self.product_id = product_id
        self.product_name = fake.word()
        self.product_description = fake.text()
        self.price = round(random.uniform(10.0, 500.0), 2)
        self.category = fake.word()
        self.stock_quantity = random.randint(1, 100)
        self.created_at = fake.date_this_year()
        self.updated_at = fake.date_this_year()

    def to_dict(self):
        return {
            'product_id': self.product_id,
            'product_name': self.product_name,
            'product_description': self.product_description,
            'price': self.price,
            'category': self.category,
            'stock_quantity': self.stock_quantity,
            'created_at': str(self.created_at),
            'updated_at': str(self.updated_at)
        }

# 5. Activity Class
class Activity:
    def __init__(self, activity_id, customer_id):
        self.activity_id = activity_id
        self.customer_id = customer_id
        self.opportunity_id = random.randint(1, 20)
        self.activity_type = random.choice(['Call', 'Email', 'Meeting'])
        self.due_date = fake.date_this_year()
        self.status = random.choice(['Pending', 'Completed', 'Overdue'])
        self.notes = fake.text()
        self.created_at = fake.date_this_year()
        self.updated_at = fake.date_this_year()

    def to_dict(self):
        return {
            'activity_id': self.activity_id,
            'customer_id': self.customer_id,
            'opportunity_id': self.opportunity_id,
            'activity_type': self.activity_type,
            'due_date': str(self.due_date),
            'status': self.status,
            'notes': self.notes,
            'created_at': str(self.created_at),
            'updated_at': str(self.updated_at)
        }

# Dummy Data Generator
def generate_dummy_data(num_customers=5, num_interactions=10, num_sales=5, num_products=3, num_activities=5):
    customers = [Customer(customer_id=i) for i in range(1, num_customers + 1)]
    interactions = [Interaction(interaction_id=i, customer_id=random.randint(1, num_customers)) for i in range(1, num_interactions + 1)]
    sales = [Sale(sale_id=i, customer_id=random.randint(1, num_customers)) for i in range(1, num_sales + 1)]
    products = [Product(product_id=i) for i in range(1, num_products + 1)]
    activities = [Activity(activity_id=i, customer_id=random.randint(1, num_customers)) for i in range(1, num_activities + 1)]

    return {
        'customers': [customer.to_dict() for customer in customers],
        'interactions': [interaction.to_dict() for interaction in interactions],
        'sales': [sale.to_dict() for sale in sales],
        'products': [product.to_dict() for product in products],
        'activities': [activity.to_dict() for activity in activities]
    }

@app.route('/generate_data', methods=['GET'])
def generate_data():
    data = generate_dummy_data()
    return jsonify(data)

if __name__ == "__main__":
    app.run(debug=True)
