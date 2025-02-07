# MAINTAINER Avanish Tiwari <aktiwari@cloudera.com>
# MAINTAINER Kuldeep Sahu <ksahu@cloudera.com>
# Base Image 
FROM ubuntu:24.04

ARG TF_VER=1.10.5
ARG TF_QUICKSTART_VERSION=v0.9.1
# Directory for storing scripts.
RUN mkdir -p /opt/cdp-public-cloud-automation

# Setting Up Environment Variable.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    HOME_DIR="/opt/cdp-public-cloud-automation" \
    TF_QUICKSTART_VERSION=${TF_QUICKSTART_VERSION} \
    DEBIAN_FRONTEND=noninteractive

# Installing Required Packages.
#RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa && \
RUN apt-get update && apt-get install -y jq wget git make unzip gcc build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev openssl libssl-dev libreadline-dev \
    bzip2 libffi-dev curl libbz2-dev libdb-dev liblzma-dev libsqlite3-dev uuid-dev python3.12 python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get install -y certbot python3-certbot-dns-route53 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip config set global.break-system-packages true && \
    #pip3 install --upgrade pip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip && \
    pip3 install setuptools_rust ansible-core==2.16.8 jmespath==1.0.1 && \
    pip3 install git+https://github.com/cloudera-labs/cdpy@main#egg=cdpy && \
    #pip3 install git+https://github.com/cloudera-labs/cdpy@devel#egg=cdpy && \
    pip3 uninstall -y cdpcli-beta && pip install cdpcli && \
    ansible-galaxy collection install community.general -vv && \
    #ansible-galaxy collection install git+https://github.com/cloudera-labs/cloudera.cloud.git,devel
    ansible-galaxy collection install git+https://github.com/cloudera-labs/cloudera.cloud.git,main

# Install Terraform
RUN curl "https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip" -o "/tmp/terraform_${TF_VER}_linux_amd64.zip" && \
    unzip /tmp/terraform_${TF_VER}_linux_amd64.zip -d /usr/local/bin/ && \
    rm -rf /tmp/terraform_${TF_VER}_linux_amd64.zip

COPY cdp-wrkshps-quickstarts /opt/cdp-public-cloud-automation/cdp-wrkshps-quickstarts
COPY entrypoint/docker-entrypoint.sh /usr/local/bin/
COPY entrypoint/hol-functions.sh /usr/local/bin/
COPY entrypoint/default.py /usr/local/lib/python3.12/dist-packages/ansible/plugins/callback/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR "$HOME_DIR"
#CMD ["/bin/bash"]
ENTRYPOINT ["docker-entrypoint.sh"]