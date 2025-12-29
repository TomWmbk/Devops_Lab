#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_DEFAULT_REGION:-us-east-2}"
export AWS_DEFAULT_REGION="$REGION"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_DATA_FILE="$SCRIPT_DIR/user-data.sh"

# AMI AMAZON LINUX 2 à jour via SSM (évite les AMI obsolètes)
AMI_ID=$(aws ssm get-parameters \
  --region "$REGION" \
  --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --query 'Parameters[0].Value' --output text)

# Si un SG "sample-app" existe déjà, on le supprime pour éviter le Duplicate
EXISTING_SG=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --filters Name=group-name,Values=sample-app \
  --query 'SecurityGroups[0].GroupId' --output text)
if [ "$EXISTING_SG" != "None" ]; then
  aws ec2 delete-security-group --region "$REGION" --group-id "$EXISTING_SG" || true
fi

echo "🚀 Création Security Group: sample-app"
SG_ID=$(aws ec2 create-security-group \
  --region "$REGION" \
  --group-name "sample-app" \
  --description "Allow HTTP" \
  --query GroupId --output text)

aws ec2 authorize-security-group-ingress \
  --region "$REGION" \
  --group-id "$SG_ID" --protocol tcp --port 80 --cidr 0.0.0.0/0 >/dev/null

INSTANCE_TYPE="t3.micro"  # free-tier OK en us-east-2

echo "🚀 Lancement instance ($INSTANCE_TYPE) AMI=$AMI_ID"
INSTANCE_ID=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --security-group-ids "$SG_ID" \
  --user-data file://"$USER_DATA_FILE" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=sample-app}]' \
  --query 'Instances[0].InstanceId' --output text)

aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"
PUBLIC_IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo
echo "✅ Instance déployée !"
echo "Instance ID      : $INSTANCE_ID"
echo "Security Group ID: $SG_ID"
echo "Public IP        : $PUBLIC_IP"
echo "🌐 http://$PUBLIC_IP"
