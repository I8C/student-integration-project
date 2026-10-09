#!/usr/bin/env bash
set -euo pipefail

REGION=eu-central-1 VPC_ID=vpc-0dce2564 WORKSHOP_LABEL=PXL-workshop
ROLES=(student)
for option in "$@"; do case "$option" in --teacher) ROLES+=(teacher) ;; --ftp) ROLES+=(ftp) ;; *) echo "Usage: $0 [--teacher] [--ftp]" >&2; exit 1 ;; esac; done
ROLE_VALUES=$(IFS=,; echo "${ROLES[*]}")
instances=$(aws ec2 describe-instances --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Label,Values=$WORKSHOP_LABEL" "Name=tag:Role,Values=$ROLE_VALUES" 'Name=instance-state-name,Values=pending,running,stopping,stopped' --query 'Reservations[].Instances[].InstanceId' --output text)
[[ -z "$instances" || "$instances" == None ]] && { echo "No matching $ROLE_VALUES VMs labelled $WORKSHOP_LABEL found"; exit 0; }
echo "Terminating $ROLE_VALUES VMs labelled $WORKSHOP_LABEL: $instances"
terminated=$(aws ec2 terminate-instances --region "$REGION" --instance-ids $instances --query 'TerminatingInstances[].InstanceId' --output text)
echo "Termination requested for VMs: $instances"
