#!/usr/bin/env bash
set -euo pipefail

REGION=eu-central-1 VPC_ID=vpc-0dce2564 SECURITY_GROUP_ID=sg-04dc7ac600748292c KEY_PAIR_ID=key-0060a586767f2a423 WORKSHOP_LABEL=PXL-workshop NAME=PXL-ftp
usage() { echo "Usage: $0 ADMIN_USERNAME ADMIN_PASSWORD" >&2; exit 1; }
[[ $# -eq 2 && -n $1 && -n $2 ]] || usage
ADMIN_USERNAME=$1 ADMIN_PASSWORD=$2
ADMIN_USERNAME_B64=$(printf %s "$ADMIN_USERNAME" | base64 | tr -d '\r\n')
ADMIN_PASSWORD_B64=$(printf %s "$ADMIN_PASSWORD" | base64 | tr -d '\r\n')
KEY_NAME=$(aws ec2 describe-key-pairs --region "$REGION" --key-pair-ids "$KEY_PAIR_ID" --query 'KeyPairs[0].KeyName' --output text)
SUBNET_ID=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" 'Name=map-public-ip-on-launch,Values=true' --query 'Subnets[?AvailableIpAddressCount > `0`].SubnetId | [0]' --output text)
[[ -n "$KEY_NAME" && "$KEY_NAME" != None && -n "$SUBNET_ID" && "$SUBNET_ID" != None ]] || { echo "No key pair or public subnet found" >&2; exit 1; }

existing=$(aws ec2 describe-instances --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Label,Values=$WORKSHOP_LABEL" "Name=tag:Role,Values=ftp" 'Name=instance-state-name,Values=pending,running,stopping,stopped' --query 'Reservations[].Instances[].InstanceId' --output text)
[[ -z "$existing" || "$existing" == None ]] || { echo "Skipping $NAME ($existing)"; exit 0; }

if ! output=$(aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SECURITY_GROUP_ID" --ip-permissions 'IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=[{CidrIp=0.0.0.0/0,Description=PXL workshop file UI}]' 2>&1); then
  [[ "$output" == *InvalidPermission.Duplicate* ]] || { echo "$output" >&2; exit 1; }
fi

USER_DATA=$(cat <<'EOF'
#!/bin/bash
set -euo pipefail
ADMIN_USERNAME=$(printf %s __ADMIN_USERNAME_B64__ | base64 -d)
ADMIN_PASSWORD=$(printf %s __ADMIN_PASSWORD_B64__ | base64 -d)
dnf install -y curl-minimal jq nginx
curl -fsSLo /tmp/sftpgo.rpm https://github.com/drakkan/sftpgo/releases/download/v2.7.6/sftpgo-2.7.6-1.x86_64.rpm
echo '9cee947508fbb6737692e66fc6f6dad3f89a5b578b9710501ee84aba596a97e6  /tmp/sftpgo.rpm' | sha256sum -c -
dnf install -y /tmp/sftpgo.rpm
chmod 0755 /srv/sftpgo
install -d -o sftpgo -g sftpgo -m 0755 /srv/sftpgo/data/public
cat >/etc/sftpgo/env.d/workshop.env <<'ENV'
SFTPGO_DATA_PROVIDER__CREATE_DEFAULT_ADMIN=true
SFTPGO_COMMON__UMASK=022
SFTPGO_SFTPD__BINDINGS__0__PORT=0
SFTPGO_FTPD__BINDINGS__0__ADDRESS=127.0.0.1
SFTPGO_FTPD__BINDINGS__0__PORT=2121
SFTPGO_HTTPD__BINDINGS__0__ADDRESS=127.0.0.1
SFTPGO_HTTPD__BINDINGS__0__PORT=8080
SFTPGO_HTTPD__WEB_ROOT=/admin
ENV
printf 'SFTPGO_DEFAULT_ADMIN_USERNAME=%q\nSFTPGO_DEFAULT_ADMIN_PASSWORD=%q\n' "$ADMIN_USERNAME" "$ADMIN_PASSWORD" >>/etc/sftpgo/env.d/workshop.env
cat >/etc/nginx/nginx.conf <<'NGINX'
events {}
http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  server {
    listen 80 default_server;
    server_name _;
    location = /admin { return 301 /admin/web/client/; }
    location /admin/ {
      proxy_pass http://127.0.0.1:8080;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
    location / {
      root /srv/sftpgo/data/public;
      autoindex on;
    }
  }
}
NGINX
systemctl enable sftpgo
systemctl restart sftpgo
for attempt in {1..30}; do curl -sS http://127.0.0.1:8080/ -o /dev/null && break; sleep 1; done
curl -sS http://127.0.0.1:8080/ -o /dev/null
TOKEN=$(curl -fsS --user "$ADMIN_USERNAME:$ADMIN_PASSWORD" http://127.0.0.1:8080/api/v2/token | jq -r .access_token)
jq -n --arg username "$ADMIN_USERNAME" --arg password "$ADMIN_PASSWORD" '{username:$username,password:$password,status:1,home_dir:"/srv/sftpgo/data/public",permissions:{"/":["*"]}}' | curl -fsS -X POST http://127.0.0.1:8080/api/v2/users -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' --data-binary @-
systemctl enable nginx
systemctl restart nginx
EOF
)
USER_DATA=${USER_DATA//__ADMIN_USERNAME_B64__/$ADMIN_USERNAME_B64}
USER_DATA=${USER_DATA//__ADMIN_PASSWORD_B64__/$ADMIN_PASSWORD_B64}

echo "Creating VM $NAME"
instance_id=$(MSYS_NO_PATHCONV=1 aws ec2 run-instances --region "$REGION" --image-id 'resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64' --instance-type t2.small --subnet-id "$SUBNET_ID" --associate-public-ip-address --security-group-ids "$SECURITY_GROUP_ID" --key-name "$KEY_NAME" --user-data "$USER_DATA" --tag-specifications "ResourceType=instance,Tags=[{Key=Label,Value=$WORKSHOP_LABEL},{Key=Role,Value=ftp},{Key=Name,Value=$NAME}]" --query 'Instances[0].InstanceId' --output text)
echo "VM $NAME created with id $instance_id"
echo "Provisioning Nginx and SFTPGo; wait about one minute before using the VM."
