#!/bin/bash

set -e

# Input: workshop name
workshop_name=$1
env_name="${workshop_name}-cdp-env"

echo "🔧 Checking default compute cluster status for environment: $env_name"

default_cluster_status=$(cdp compute list-clusters | jq -r --arg env_name "$env_name" '
  .clusters[]
  | select(.isDefault == true and .envName == $env_name)
  | .status
')

if [[ "$default_cluster_status" != "RUNNING" && "$default_cluster_status" != "CREATING" ]]; then
  echo "⚙️ Initializing default compute cluster..."
  cdp environments initialize-aws-compute-cluster --cli-input-json file://updated-convert-v2-env.json
fi

echo "⏳ Waiting for default compute cluster to reach RUNNING state..."
for i in {1..60}; do
  default_cluster_status=$(cdp compute list-clusters | jq -r --arg env_name "$env_name" '
    .clusters[]
    | select(.isDefault == true and .envName == $env_name)
    | .status
  ')

  echo "   ➤ Attempt $i: Status = $default_cluster_status"

  if [[ "$default_cluster_status" == "RUNNING" ]]; then
    echo "✅ Default compute cluster is now RUNNING."
    break
  elif [[ "$default_cluster_status" == "FAILED" ]]; then
    echo "❌ Default compute cluster initialization FAILED."
    exit 1
  fi
  sleep 30
done

if [[ "$default_cluster_status" != "RUNNING" ]]; then
  echo "❌ Timeout Error: Default cluster did not reach RUNNING state after 30 minutes."
  exit 1
fi
