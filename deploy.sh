#!/bin/bash

PROJECT_ID="gcp-vm-autoscaling-security"
REGION="us-central1"
YOUR_IP="49.36.213.4/32"

# Set project
gcloud config set project $PROJECT_ID

# Create Instance Template
gcloud compute instance-templates create compute-template-v1 \
    --machine-type=e2-medium \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --tags=http-server,ssh-access

# Create Managed Instance Group
gcloud compute instance-groups managed create gcp-web-mig \
    --base-instance-name=gcp-web-mig \
    --template=compute-template-v1 \
    --size=1 \
    --region=$REGION

# Enable Autoscaling
gcloud compute instance-groups managed set-autoscaling gcp-web-mig \
    --region=$REGION \
    --min-num-replicas=1 \
    --max-num-replicas=10 \
    --target-cpu-utilization=0.6

# Create Firewall Rule
gcloud compute firewall-rules create allow-ssh-restricted \
    --allow=tcp:22 \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --source-ranges=$YOUR_IP \
    --target-tags=ssh-access

gcloud compute firewall-rules create allow-http \
    --allow=tcp:80 \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

echo "Deployment Complete!"
