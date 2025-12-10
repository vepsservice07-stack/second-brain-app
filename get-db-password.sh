#!/bin/bash
# Retrieve database password from Secret Manager

source ./second-brain-setup.sh > /dev/null 2>&1

gcloud secrets versions access latest --secret="db-password" --project=$PROJECT_ID
