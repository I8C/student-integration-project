#!/usr/bin/env bash
set -euo pipefail

REGION=eu-central-1 VPC_ID=vpc-0dce2564 WORKSHOP_LABEL=PXL-workshop
echo -e "NAME\tPUBLIC_DNS\tAPPLICATION_URL"
aws ec2 describe-instances --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Label,Values=$WORKSHOP_LABEL" 'Name=instance-state-name,Values=pending,running,stopping,stopped' --query 'Reservations[].Instances[][Tags[?Key==`Name`]|[0].Value,PublicDnsName]' --output text |
  awk '{ printf "%s\t%s\t%s\n", $1, $2, ($2 == "None" || $2 == "" ? "" : "http://" $2 ":8080") }' |
  sort
