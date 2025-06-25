#!/bin/bash

nohup python3 branch_task_management/branch_mgmt_cp/app.py > branch_task_management/branch_mgmt_cp/output.log 2>&1 &
nohup python3 campaign_callcenter/run.py > campaign_callcenter/output.log 2>&1 &
nohup python3 cbs_hrms/kuldeep_app/run.py > cbs_hrms/kuldeep_app/output.log 2>&1 &
nohup python3 frs_footfall/fr_sys_data/run.py > frs_footfall/fr_sys_data/output.log 2>&1 &

# Start Footfall API (FastAPI with Uvicorn)
(cd frs_footfall/footfall_api && nohup uvicorn app.main:app --host 0.0.0.0 --port 5400 --reload > server.log 2>&1 &)

echo "All applications started successfully."
