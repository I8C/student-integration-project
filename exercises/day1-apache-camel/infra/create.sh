#!/usr/bin/env bash
set -euo pipefail

REGION=eu-central-1 VPC_ID=vpc-0dce2564 SECURITY_GROUP_ID=sg-04dc7ac600748292c KEY_PAIR_ID=key-0060a586767f2a423 WORKSHOP_LABEL=PXL-workshop
usage() { echo "Usage: $0 COUNT [--teacher]" >&2; exit 1; }
[[ ${1:-} =~ ^([0-9]|[1-9][0-9])$ ]] || usage
COUNT=$1; TEACHER=${2:-}; [[ -z "$TEACHER" || "$TEACHER" == --teacher ]] || usage

KEY_NAME=$(aws ec2 describe-key-pairs --region "$REGION" --key-pair-ids "$KEY_PAIR_ID" --query 'KeyPairs[0].KeyName' --output text)
SUBNET_ID=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" 'Name=map-public-ip-on-launch,Values=true' --query 'Subnets[?AvailableIpAddressCount > `0`].SubnetId | [0]' --output text)
[[ -n "$KEY_NAME" && "$KEY_NAME" != None && -n "$SUBNET_ID" && "$SUBNET_ID" != None ]] || { echo "No key pair or public subnet found" >&2; exit 1; }

create() {
  local name=$1 role=$2 existing instance_id
  existing=$(aws ec2 describe-instances --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Label,Values=$WORKSHOP_LABEL" "Name=tag:Name,Values=$name" 'Name=instance-state-name,Values=pending,running,stopping,stopped' --query 'Reservations[].Instances[].InstanceId' --output text)
  [[ -z "$existing" || "$existing" == None ]] || { echo "Skipping $name ($existing)"; return; }
  echo "Creating VM $name"
  instance_id=$(MSYS_NO_PATHCONV=1 aws ec2 run-instances --region "$REGION" --image-id 'resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64' --instance-type t2.small --subnet-id "$SUBNET_ID" --associate-public-ip-address --security-group-ids "$SECURITY_GROUP_ID" --key-name "$KEY_NAME" --user-data $'#!/bin/bash\ndnf install -y java-21-amazon-corretto-devel coreutils\ncommand -v java\ncommand -v nohup' --tag-specifications "ResourceType=instance,Tags=[{Key=Label,Value=$WORKSHOP_LABEL},{Key=Role,Value=$role},{Key=Name,Value=$name}]" --query 'Instances[0].InstanceId' --output text)
  echo "VM $name created with id $instance_id"
}

for ((number = 1; number <= COUNT; number++)); do printf -v suffix '%02d' "$number"; create "PXL-student$suffix" student; done
if [[ "$TEACHER" == --teacher ]]; then create PXL-teacher teacher; fi
