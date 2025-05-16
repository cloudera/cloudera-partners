# CLOUDERA PVC INSTANCE DEPLOYER

A Flask web UI + Terraform + Ansible toolchain to provision EC2 clusters (master/worker/data-service) in AWS, fully driven by a YAML config.

---

##  Overview

- Define one or more **Deployment Types** in `config/deployments.yml`.
- Each type specifies counts, prefixes & instance-types for master, worker & optional data-service nodes.
- Flask UI collects your AWS credentials & key-pair name, then invokes Terraform & Ansible under the hood.
- Result page flips to show public/private IPs + SSH commands, and auto-downloads the raw logs.

---

##  Prerequisites

- **macOS** (Intel or Apple Silicon)  
- **Homebrew** (https://brew.sh)  
- **Git**  
- **AWS Account** with an Access Key & Secret Key  
- **SSH key pair** already created in AWS and available as `~/.ssh/<KEY_NAME>.pem`  

---

##  Installation

1. **Clone the repo**

   ```bash
   git clone https://github.com/your-org/aws_ec2_deployer_project.git
   cd aws_ec2_deployer_project

2. **Install system tools
    brew update
    brew install terraform ansible python@3.12 libyaml

3. **Setup Python
    cd webapp
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt

4. **Make launcher scripts executable
    cd ..
    chmod +x run.sh

5. **Configuration
    Open config/deployments.yml and define your deployment types:
    ```deployments:
        - name: "CAI Express"
            ami_id: "ami-0c94855ba95c71c99"
            instance_count: 4
            vpc_id: ""                # empty → create/default VPC
            required_elastic_ip: false

            master:
            count: 1
            prefix: "master-"
            type: "t2.medium"

            worker:
            count: 2
            prefix: "worker-"
            type: "t2.small"

            data_service:
            count: 1
            prefix: "data-"
            type: "t2.large"


6. **Ensure your SSH key exists locally:
    ls ~/.ssh/<KEY_NAME>.pem

7. **Run the Web UI
    ./run.sh
