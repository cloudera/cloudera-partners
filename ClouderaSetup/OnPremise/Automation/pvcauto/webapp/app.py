# webapp/app.py

from flask import Flask, render_template, request
import subprocess, os, json, yaml, traceback
from datetime import datetime

app = Flask(__name__)

# Load deployments config
cfg_path = os.path.abspath(os.path.join(os.getcwd(), '..', 'config', 'deployments.yml'))
with open(cfg_path) as f:
    cfg = yaml.safe_load(f) or {}
DEPLOYMENTS = cfg.get('deployments', [])


@app.route('/')
def index():
    return render_template('index.html', deployments=DEPLOYMENTS)


@app.route('/deploy', methods=['POST'])
def deploy():
    # 1) Collect UI inputs
    ui = {
        'deployment_mode': request.form['deployment_mode'],
        'aws_access_key':  request.form['aws_access_key'],
        'aws_secret_key':  request.form['aws_secret_key'],
        'aws_region':      request.form.get('aws_region', 'us-east-1'),
        'key_name':        request.form['key_name']
    }

    # 2) Find matching deployment config
    dep = next((d for d in DEPLOYMENTS if d['name'] == ui['deployment_mode']), None)
    if not dep:
        return render_template('result.html', logs=f"⛔ Unknown mode: {ui['deployment_mode']}"), 400

    # 3) Build Terraform variable set
    data = {
        **ui,
        'ami_id':                dep['ami_id'],
        'instance_count':        dep['instance_count'],
        'vpc_id':                dep['vpc_id'],
        'required_elastic_ip':   dep['required_elastic_ip'],
        'master_count':          dep['master']['count'],
        'master_prefix':         dep['master']['prefix'],
        'master_type':           dep['master']['type'],
        'worker_count':          dep['worker']['count'],
        'worker_prefix':         dep['worker']['prefix'],
        'worker_type':           dep['worker']['type'],
        'data_service_count':    dep.get('data_service', {}).get('count', 0),
        'data_service_prefix':   dep.get('data_service', {}).get('prefix', ''),
        'data_service_type':     dep.get('data_service', {}).get('type', ''),
    }

    # 4) Write terraform.tfvars.json
    tf_dir = os.path.abspath(os.path.join(os.getcwd(), '..', 'infra', 'terraform'))
    tfvars_path = os.path.join(tf_dir, 'terraform.tfvars.json')
    with open(tfvars_path, 'w') as f:
        json.dump(data, f)

    # 5) Run Terraform init & apply
    init_proc  = subprocess.run(['terraform', 'init'], cwd=tf_dir, capture_output=True, text=True)
    apply_proc = subprocess.run(['terraform', 'apply', '-auto-approve'], cwd=tf_dir, capture_output=True, text=True)
    if apply_proc.returncode != 0:
        logs = f"⛔ Terraform apply failed:\nSTDOUT:\n{apply_proc.stdout}\nSTDERR:\n{apply_proc.stderr}"
        return render_template('result.html', logs=logs), 500

    # 6) Capture Terraform outputs
    try:
        out_proc = subprocess.run(['terraform', 'output', '-json'], cwd=tf_dir, capture_output=True, text=True, check=True)
        out_data       = json.loads(out_proc.stdout)
        public_ips     = out_data.get('instance_public_ips', {}).get('value', [])
        private_ips    = out_data.get('instance_private_ips', {}).get('value', [])
        instance_names = out_data.get('instance_names', {}).get('value', [])
    except Exception:
        logs = f"⛔ Terraform output error:\n{traceback.format_exc()}"
        return render_template('result.html', logs=logs), 500

    # 7) Build Ansible inventory & run playbook
    ans_dir = os.path.abspath(os.path.join(os.getcwd(), '..', 'infra', 'ansible'))
    inv_file = os.path.join(ans_dir, 'hosts.ini')
    with open(inv_file, 'w') as inv:
        inv.write('[ec2_instances]\n')
        for ip in public_ips:
            inv.write(
                f"{ip} ansible_user=ec2-user "
                f"ansible_private_key_file=~/.ssh/{ui['key_name']}.pem "
                "-o StrictHostKeyChecking=no\n"
            )

    ans_proc = subprocess.run(
        ['ansible-playbook', '-i', inv_file, 'playbook.yml'],
        cwd=ans_dir, capture_output=True, text=True
    )
    if ans_proc.returncode != 0:
        logs = f"⛔ Ansible failed:\nSTDOUT:\n{ans_proc.stdout}\nSTDERR:\n{ans_proc.stderr}"
        return render_template('result.html', logs=logs), 500

    # 8) Prepare filename and collate logs
    slug      = ui['deployment_mode'].lower().replace(' ', '')
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f"{slug}_{timestamp}.txt"
    logs      = "\n".join([init_proc.stdout, apply_proc.stdout, out_proc.stdout, ans_proc.stdout])

    # 9) Zip instance details into tuples of (name, public, private)
    instances = list(zip(instance_names, public_ips, private_ips))

    # 10) Render result page
    return render_template(
        'result.html',
        logs=logs,
        file_name=file_name,
        instances=instances,
        key_name=ui['key_name']
    )


if __name__ == '__main__':
    app.run()
