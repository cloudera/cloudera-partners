#!/bin/bash

set -e

workshop_name=$1
env_name="${workshop_name}-cdp-env"
cluster_name="${workshop_name}-compute-cluster"

echo "🔧 Checking compute cluster: $cluster_name"

existing_cluster_status=$(cdp compute list-clusters | jq -r --arg name "$cluster_name" '
  .clusters[]
  | select(.clusterName == $name)
  | .status
')

if [[ "$existing_cluster_status" == "RUNNING" ]]; then
  echo "✅ Compute cluster '$cluster_name' is already RUNNING. Skipping creation."

elif [[ "$existing_cluster_status" == "CREATING" ]]; then
  echo "ℹ️ Compute cluster '$cluster_name' is already being created. Skipping creation."

else
  echo "🚀 Creating compute cluster: $cluster_name"
  cdp compute create-cluster --environment "$env_name" --name "$cluster_name"

  echo "⏳ Waiting for compute cluster '$cluster_name' to reach RUNNING state..."
  for i in {1..60}; do
    current_status=$(cdp compute list-clusters | jq -r --arg name "$cluster_name" '
      .clusters[]
      | select(.clusterName == $name)
      | .status
    ')

    echo "   ➤ Attempt $i: Status = $current_status"

    if [[ "$current_status" == "RUNNING" ]]; then
      echo "✅ Compute cluster '$cluster_name' is now RUNNING."
      break
    elif [[ "$current_status" == "FAILED" ]]; then
      echo "❌ Compute cluster creation FAILED."
      exit 1
    fi
    sleep 30
  done

  if [[ "$current_status" != "RUNNING" ]]; then
    echo "❌ Timeout Error: Compute cluster did not reach RUNNING state."
    exit 1
  fi
fi
