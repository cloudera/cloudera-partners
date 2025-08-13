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

# Normalize status to lowercase for case-insensitive matching
existing_status_lower=$(echo "$existing_cluster_status" | tr '[:upper:]' '[:lower:]')

if [[ "$existing_status_lower" == "running" ]]; then
  echo "✅ Compute cluster '$cluster_name' is already RUNNING. Skipping creation."

elif [[ "$existing_status_lower" == "creating" ]]; then
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

    # Convert to lowercase for comparison
    current_status_lower=$(echo "$current_status" | tr '[:upper:]' '[:lower:]')

    if [[ "$current_status_lower" == "running" ]]; then
      echo "✅ Compute cluster '$cluster_name' is now RUNNING."
      break
    elif [[ "$current_status_lower" == *"failed"* ]]; then
      echo "❌ Compute cluster creation FAILED with status: $current_status"
      exit 1
    fi

    sleep 30
  done

  if [[ "$current_status_lower" != "running" ]]; then
    echo "❌ Timeout Error: Compute cluster did not reach RUNNING state."
    exit 1
  fi
fi

