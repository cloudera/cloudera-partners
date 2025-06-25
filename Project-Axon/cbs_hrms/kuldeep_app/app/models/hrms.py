from faker import Faker
import random
from datetime import datetime

fake = Faker()

# --- HRMS Tables ---

# 18. hrms_employees
class HRMSEmployee:
    def __init__(self):
        self.employee_id = fake.random_int(min=1, max=99)
        self.first_name = fake.first_name()
        self.last_name = fake.last_name()
        self.email = fake.email()
        self.phone = fake.phone_number()
        self.department = random.choice(['Sales', 'Operations', 'IT', 'Finance', 'HR'])
        self.position = random.choice(['Manager', 'Associate', 'Director', 'Executive', 'Teller', 'Customer Service'])
        self.hire_date = fake.date_this_decade().strftime("%Y-%m-%d")  # Keep as DATE format
        self.salary = round(random.uniform(25000, 120000), 2)
        self.employee_status = random.choice(['Active', 'Inactive'])
        self.branch_id = fake.random_int(min=1, max=99)
        self.created_at = fake.date_time_this_decade().strftime("%Y-%m-%d %H:%M:%S")  # Formatted timestamp
        self.updated_at = fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S")  # Formatted timestamp

    def to_dict(self) -> dict:
        return {
            'employee_id': self.employee_id,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'email': self.email,
            'phone': self.phone,
            'department': self.department,
            'position': self.position,
            'hire_date': self.hire_date,  # Kept in DATE format
            'salary': self.salary,
            'employee_status': self.employee_status,
            'branch_id': self.branch_id,
            'created_at': self.created_at,
            'updated_at': self.updated_at
        }

# 19. hrms_attendance
class HRMSAttendance:
    def __init__(self):
        self.attendance_id = fake.random_int(min=1, max=99)
        self.employee_id = fake.random_int(min=1, max=99)
        self.attendance_date = fake.date_this_month().strftime("%Y-%m-%d")  # Keep as DATE format
        self.attendance_status = random.choice(['Present', 'Absent'])
        self.created_at = fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S")  # Formatted timestamp

    def to_dict(self) -> dict:
        return {
            'attendance_id': self.attendance_id,
            'employee_id': self.employee_id,
            'attendance_date': self.attendance_date,  # Kept in DATE format
            'attendance_status': self.attendance_status,
            'created_at': self.created_at
        }
    
# 27. hrms_time_tracking
class HRMSTimeTracking:
    def __init__(self):
        self.time_tracking_id = fake.random_int(min=1, max=99)
        self.employee_id = fake.random_int(min=1, max=99)
        self.tracking_date = fake.date_this_month().strftime("%Y-%m-%d")  # Keep as DATE format
        self.hours_worked = round(random.uniform(4, 10), 2)
        self.overtime_hours = round(random.uniform(0, 3), 2)
        self.time_tracking_status = random.choice(['Approved', 'Pending', 'Rejected'])
        self.created_at = fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S")  # Formatted timestamp

    def to_dict(self) -> dict:
        return {
            'time_tracking_id': self.time_tracking_id,
            'employee_id': self.employee_id,
            'tracking_date': self.tracking_date,  # Kept in DATE format
            'hours_worked': self.hours_worked,
            'overtime_hours': self.overtime_hours,
            'time_tracking_status': self.time_tracking_status,
            'created_at': self.created_at
        }

# 21. hrms_performance
class HRMSPerformance:
    def __init__(self):
        self.performance_id = fake.random_int(min=1, max=99)
        self.employee_id = fake.random_int(min=1, max=99)
        self.performance_rating = random.choice([1, 2, 3, 4, 5])
        self.review_date = fake.date_this_year().strftime("%Y-%m-%d")  # Keep as DATE format
        self.comments = fake.text(max_nb_chars=150)
        self.created_at = fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S")  # Formatted timestamp

    def to_dict(self) -> dict:
        return {
            'performance_id': self.performance_id,
            'employee_id': self.employee_id,
            'performance_rating': self.performance_rating,
            'review_date': self.review_date,  # Kept in DATE format
            'comments': self.comments,
            'created_at': self.created_at
        }
