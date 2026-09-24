#!/usr/bin/env bash
set -euo pipefail

REGION=eu-central-1 VPC_ID=vpc-0dce2564 WORKSHOP_LABEL=PXL-workshop KEY_FILE="$(cd "$(dirname "$0")/.." && pwd)/assets/PXL-key.pem"
echo -e "NAME\tEC2_STATE\tJAVA_PROCESS"
while IFS=$'\t' read -r name state dns; do
  java=unknown
  if [[ "$state" != running ]]; then java=no; elif [[ -z "$dns" || "$dns" == None ]]; then java=unknown
  else
    if ssh -n -i "$KEY_FILE" -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new "ec2-user@$dns" "pgrep -f '[j]ava' >/dev/null"; then java=yes
    else case $? in 1) java=no ;; *) java=unknown ;; esac
    fi
  fi
  printf '%s\t%s\t%s\n' "$name" "$state" "$java"
done < <(aws ec2 describe-instances --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Label,Values=$WORKSHOP_LABEL" 'Name=instance-state-name,Values=pending,running,stopping,stopped' --query 'Reservations[].Instances[][Tags[?Key==`Name`]|[0].Value,State.Name,PublicDnsName]' --output text | tr -d '\r' | sort)
