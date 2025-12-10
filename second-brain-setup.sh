#!/bin/bash
# Second Brain App Setup Script
# Run this script to configure your environment for Second Brain development and deployment
# Usage: source second-brain-setup.sh

echo "========================================"
echo "  Second Brain App Environment Setup"
echo "========================================"
echo ""

# Project Configuration
export PROJECT_ID="second-brain-app-ore"
export REGION="us-central1"
export ZONE="us-central1-a"
export EXPECTED_ACCOUNT="ore.asonibare@gmail.com"

# Check current account
CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null)

echo "Current account: $CURRENT_ACCOUNT"
echo "Expected account: $EXPECTED_ACCOUNT"
echo ""

if [ "$CURRENT_ACCOUNT" != "$EXPECTED_ACCOUNT" ]; then
    echo "⚠️  Account mismatch detected!"
    echo "Switching to $EXPECTED_ACCOUNT..."
    echo ""
    
    # Check if the expected account is already authenticated
    if gcloud auth list --filter="account:$EXPECTED_ACCOUNT" --format="value(account)" 2>/dev/null | grep -q "$EXPECTED_ACCOUNT"; then
        echo "Account $EXPECTED_ACCOUNT is already authenticated. Switching..."
        gcloud config set account $EXPECTED_ACCOUNT
    else
        echo "Account $EXPECTED_ACCOUNT is not authenticated. Please login..."
        gcloud auth login $EXPECTED_ACCOUNT
    fi
    echo ""
fi

# Database Configuration
export DB_INSTANCE="second-brain-db"
export DB_CONNECTION_NAME="second-brain-app-ore:us-central1:second-brain-db"
export DB_NAME="second_brain_production"
export DB_USER="second_brain_app"

# App Engine Configuration
export APP_ENGINE_REGION="us-central"

# Cloud Storage Configuration
export STORAGE_BUCKET_NAME="second-brain-app-ore-attachments"

# VPC Configuration (if needed for Cloud SQL private IP)
export VPC_NETWORK="second-brain-network"
export VPC_CONNECTOR="second-brain-connector"

# Artifact Registry (for container images if using Cloud Run)
export ARTIFACT_REGISTRY_LOCATION="us-central1"
export ARTIFACT_REGISTRY_REPO="second-brain-images"

# Rails Configuration
export RAILS_ENV="production"
export RAILS_MASTER_KEY=""  # TODO: Set this after generating Rails app

# Set gcloud project
echo "Setting gcloud project to: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Set default region
echo "Setting default region to: $REGION"
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Verify configuration
echo ""
echo "Environment variables set:"
echo "  PROJECT_ID: $PROJECT_ID"
echo "  REGION: $REGION"
echo "  ZONE: $ZONE"
echo ""
echo "Database:"
echo "  Instance: $DB_INSTANCE"
echo "  Connection: $DB_CONNECTION_NAME"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""
echo "Storage:"
echo "  Bucket: $STORAGE_BUCKET_NAME"
echo ""
echo "VPC:"
echo "  Network: $VPC_NETWORK"
echo "  Connector: $VPC_CONNECTOR"
echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "You can now run gcloud commands without specifying --project or --region"
echo "Example: gcloud sql instances list"
echo ""