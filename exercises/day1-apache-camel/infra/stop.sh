#!/usr/bin/env bash
set -euo pipefail

REGION=eu-central-1 VPC_ID=vpc-0dce2564 WORKSHOP_LABEL=PXL-workshop
[[ -z ${1:-} || ${1:-} == --teacher ]] || { echo "Usage: $0 [--teacher]" >&2; exit 1; }
ROLES=student; [[ ${1:-} == --teacher ]] && ROLES=student,teacher
instances=$(aws ec2 describe-instances --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Label,Values=$WORKSHOP_LABEL" "Name=tag:Role,Values=$ROLES" 'Name=instance-state-name,Values=running' --query 'Reservations[].Instances[].InstanceId' --output text)
[[ -z "$instances" || "$instances" == None ]] && { echo "No running $ROLES VMs labelled $WORKSHOP_LABEL found"; exit 0; }
echo "Stopping $ROLES VMs labelled $WORKSHOP_LABEL: $instances"
stopped=$(aws ec2 stop-instances --region "$REGION" --instance-ids $instances --query 'StoppingInstances[].InstanceId' --output text)
echo "Stop requested for VMs: $stopped"
