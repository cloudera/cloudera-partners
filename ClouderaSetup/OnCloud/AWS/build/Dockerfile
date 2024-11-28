# MAINTAINER Avanish Tiwari <aktiwari@cloudera.com>
# Base Image 
FROM ubuntu:22.04

ARG TF_VER=1.9.3
ARG TF_QUICKSTART_VERSION=v0.8.5
# Directory for storing scripts.
RUN mkdir -p /opt/cdp-public-cloud-automation

# Setting Up Environment Variable.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV HOME_DIR="/opt/cdp-public-cloud-automation"
ENV TF_QUICKSTART_VERSION=${TF_QUICKSTART_VERSION}

# Installing Required Packages.
RUN apt-get update && \
    apt-get install -y jq wget git make unzip gcc build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev openssl libssl-dev libreadline-dev bzip2 libffi-dev curl libbz2-dev libdb-dev liblzma-dev libsqlite3-dev uuid-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz && \
    tar -xvf Python-3.10.9.tgz && \
    cd Python-3.10.9 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    cp /usr/local/bin/python3.10 /usr/bin/ && \
    rm -f /usr/bin/python && \
    ln -s /usr/bin/python3.10 /usr/bin/python && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    rm /Python-3.10.9.tgz && \
    rm get-pip.py && \
    rm -rf Python-3.10.9

RUN pip install --upgrade pip && \
    pip install setuptools_rust ansible-core==2.12.10 jmespath==1.0.1 awscli && \
    pip install git+https://github.com/cloudera-labs/cdpy@main#egg=cdpy && \
    #pip install git+https://github.com/cloudera-labs/cdpy@devel#egg=cdpy && \
    pip uninstall -y cdpcli-beta && pip install cdpcli && \
    ansible-galaxy collection install community.general -vv && \
    ansible-galaxy collection install git+https://github.com/cloudera-labs/cloudera.cloud.git,main
    #ansible-galaxy collection install git+https://github.com/cloudera-labs/cloudera.cloud.git,devel

# Install Terraform
RUN curl "https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip" -o "/tmp/terraform_${TF_VER}_linux_amd64.zip" && \
    unzip /tmp/terraform_${TF_VER}_linux_amd64.zip -d /usr/local/bin/ && \
    rm -rf /tmp/terraform_${TF_VER}_linux_amd64.zip

COPY cdp-wrkshps-quickstarts /opt/cdp-public-cloud-automation/cdp-wrkshps-quickstarts
COPY entrypoint/docker-entrypoint.sh /usr/local/bin/
COPY entrypoint/hol-functions.sh /usr/local/bin/
COPY entrypoint/default.py /usr/local/lib/python3.10/site-packages/ansible/plugins/callback/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR "$HOME_DIR"
#CMD ["/bin/bash"]
ENTRYPOINT ["docker-entrypoint.sh"]
