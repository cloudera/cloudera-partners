from flask import Blueprint, jsonify
from app.tasks_mgmt import (
    generate_task, 
    generate_project, 
    generate_comment, 
#    generate_task_history, 
    generate_notification
)
from app.history import HistoryStore

api_bp = Blueprint('api', __name__)

history_store = HistoryStore()

@api_bp.route('/task', methods=['GET'])
def get_task():
    data = generate_task()
    return jsonify(data)

@api_bp.route('/project', methods=['GET'])
def get_project():
    data = generate_project()
    return jsonify(data)

@api_bp.route('/comment', methods=['GET'])
def get_comment():
    data = generate_comment()
    return jsonify(data)

#@api_bp.route('/task_history', methods=['GET'])
#def get_task_history():
#    data = generate_task_history()
#    return jsonify(data)

@api_bp.route('/notification', methods=['GET'])
def get_notification():
    data = generate_notification()
    return jsonify(data)

