from flask import Blueprint, jsonify
from app.models.hrms import *
from app.utils.logger import setup_logging

logger = setup_logging()

hrms_routes = Blueprint('hrms_routes', __name__)

@hrms_routes.route('/hrms', methods=['GET'])
def hrm_api_overview():
    api_endpoints = {
        "hrms_employees": "/hrms/employee",
        "hrms_attendance": "/hrms/attendance",
        "hrms_performance": "/hrms/performance",
        "hrms_time_tracking": "/hrms/time_tracking"
    }
    return jsonify(api_endpoints)

@hrms_routes.route('/hrms/employee', methods=['GET'])
def generate_employee():
    employee = HRMSEmployee()
    data = employee.to_dict()
    logger.info(f"Generated HRMS employee data: {data}")
    return jsonify(data)

@hrms_routes.route('/hrms/attendance', methods=['GET'])
def generate_attendance():
    attendance = HRMSAttendance()
    data = attendance.to_dict()
    logger.info(f"Generated HRMS attendance data: {data}")
    return jsonify(data)

@hrms_routes.route('/hrms/performance', methods=['GET'])
def generate_performance():
    performance = HRMSPerformance()
    data = performance.to_dict()
    logger.info(f"Generated HRMS performance data: {data}")
    return jsonify(data)

@hrms_routes.route('/hrms/time_tracking', methods=['GET'])
def generate_time_tracking():
    time_tracking = HRMSTimeTracking()
    data = time_tracking.to_dict()
    logger.info(f"Generated HRMS time tracking data: {data}")
    return jsonify(data)