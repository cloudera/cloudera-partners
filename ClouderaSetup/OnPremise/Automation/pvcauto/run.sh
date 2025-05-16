#!/usr/bin/env bash
set -e

# 0) Detect OS & install libyaml & venv support
OS="$(uname)"
echo "Detected OS: $OS"

if [[ "$OS" == "Darwin" ]]; then
  echo "🔧 Installing libyaml via Homebrew…"
  brew install libyaml || true
elif [[ "$OS" == "Linux" ]]; then
  if command -v apt-get &>/dev/null; then
    echo "🔧 Installing libyaml-dev & python3-venv via apt…"
    sudo apt-get update
    sudo apt-get install -y libyaml-dev python3-venv python3-pip
  elif command -v yum &>/dev/null; then
    echo "🔧 Installing libyaml-devel & python3-venv via yum…"
    sudo yum install -y libyaml-devel python3-venv python3-pip
  else
    echo "Please install libyaml-dev and python3-venv manually."
    exit 1
  fi
else
  echo "Unsupported OS: $OS"
  exit 1
fi

# 1) Enter webapp & setup virtualenv
cd webapp
if [ ! -d newvenv ]; then
  echo "Creating Python newvenv..."
  python3 -m venv newvenv
fi
source newvenv/bin/activate

# 2) Upgrade pip, setuptools & wheel
echo "Upgrading pip, setuptools, and wheel…"
pip install --upgrade pip setuptools wheel

# 3) Install requirements via pre-built wheels only
echo "Installing Python requirements (binary wheels only)…"
pip install --only-binary=:all: -r requirements.txt

# 4) Ensure Terraform & Ansible are on PATH (adjust if needed)
export PATH="$PATH"

# 5) Disable Ansible host-key checking
export ANSIBLE_HOST_KEY_CHECKING=False

# 6) Launch Flask
export FLASK_APP=app.py
export FLASK_DEBUG=1
echo "Starting Flask on http://0.0.0.0:5000"
flask run --host=0.0.0.0 --port=5000
