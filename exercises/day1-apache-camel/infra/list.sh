#!/usr/bin/env bash
set -euo pipefail

REGION=eu-central-1 VPC_ID=vpc-0dce2564 WORKSHOP_LABEL=PXL-workshop
echo -e "NAME\tROLE\tPUBLIC_DNS\tAPPLICATION_URL"
aws ec2 describe-instances --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Label,Values=$WORKSHOP_LABEL" 'Name=instance-state-name,Values=pending,running,stopping,stopped' --query 'Reservations[].Instances[][Tags[?Key==`Name`]|[0].Value,Tags[?Key==`Role`]|[0].Value,PublicDnsName]' --output text |
  awk '{ url = ($3 == "None" || $3 == "" ? "" : "http://" $3 ($2 == "ftp" ? "" : ":8080")); printf "%s\t%s\t%s\t%s\n", $1, $2, $3, url }' |
  sort
