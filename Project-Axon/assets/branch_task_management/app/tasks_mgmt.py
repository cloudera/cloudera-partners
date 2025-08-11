import random
from faker import Faker
from app.history import HistoryStore

# Initialize Faker
fake = Faker()

# Predefined banking-related terms for tasks and single branch projects
BANKING_TASKS = [
    "Loan Processing",
    "Account Management",
    "Fraud Detection",
    "Customer Service",
    "Compliance Check",
    "KYC Verification",
    "Transaction Monitoring"
]

BRANCH_PROJECTS = [
    "Main Branch Operations",
    "Main Branch Customer Support",
    "Main Branch Loan Processing",
    "Main Branch Compliance",
    "Main Branch Fraud Detection",
    "Main Branch KYC Verification",
    "Main Branch Account Management"
]

history_store = HistoryStore()

def generate_unique_data(generator_func, history_store, table_name):
    while True:
        data = generator_func()
        if history_store.is_unique(table_name, data):
            history_store.add(table_name, data)
            return data

def generate_project():
    return {
        "project_id": random.randint(1, 100),
        "project_name": random.choice(BRANCH_PROJECTS),
        "description": fake.sentence(),
        "start_date": fake.date_this_year().isoformat(),
        "end_date": fake.date_this_year().isoformat(),
        "created_at": fake.date_time().isoformat()
    }

def generate_task():
    project = generate_unique_data(generate_project, history_store, "projects")
    return {
        "task_id": random.randint(1, 1000),
        "task_name": random.choice(BANKING_TASKS),
        "branch_id": (branch_id := random.randint(1, 99)),
        "project_id": project["project_id"],
        "assigned_to": fake.random_int(min=1, max=100),
        "status": random.choice(["To Do", "In Progress", "Completed", "Blocked"]),
        "priority": random.choice(["Low", "Medium", "High", "Critical"]),
        "due_date": fake.date_this_year().isoformat(),
        "created_at": fake.date_this_year().isoformat(),
        "updated_at": fake.date_this_year().isoformat()
    }

def generate_comment():
    task = generate_unique_data(generate_task, history_store, "tasks")
    return {
        "comment_id": random.randint(1, 1000),
        "task_id": task["task_id"],
        "comment": fake.sentence(),
        "commented_by": fake.random_int(min=1, max=100),
        "created_at": fake.date_this_year().isoformat()
    }

#def generate_task_history():
#    task = generate_unique_data(generate_task, history_store, "tasks")
#    return {
#        "history_id": random.randint(1, 1000),
#        "task_id": task["task_id"],
#        "field_changed": "status",
#        "old_value": random.choice(["To Do", "In Progress", "Completed", "Blocked"]),
#        "new_value": random.choice(["To Do", "In Progress", "Completed", "Blocked"]),
#        "changed_by": fake.random_int(min=1, max=100),
#        "changed_at": fake.date_this_year().isoformat()
#    }

def generate_notification():
    task = generate_unique_data(generate_task, history_store, "tasks")
    return {
        "notification_id": random.randint(1, 1000),
        "user_id": fake.random_int(min=1, max=100),
        "task_id": task["task_id"],
        "message": fake.sentence(),
        "is_read": fake.boolean(),
        "created_at": fake.date_this_year().isoformat()
    }

