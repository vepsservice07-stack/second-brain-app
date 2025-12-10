#!/bin/bash
# Second Brain - Store Secrets in Google Secret Manager
# Stores database password securely in GCP
# Usage: ./setup-secrets.sh

echo "========================================"
echo "  Google Secret Manager Setup"
echo "========================================"
echo ""

# Source the environment configuration
if [ -f "./second-brain-setup.sh" ]; then
    source ./second-brain-setup.sh
else
    echo "❌ Error: second-brain-setup.sh not found"
    exit 1
fi

# Enable Secret Manager API if not already enabled
echo "Enabling Secret Manager API..."
gcloud services enable secretmanager.googleapis.com

if [ $? -ne 0 ]; then
    echo "❌ Failed to enable Secret Manager API"
    exit 1
fi

echo "✅ Secret Manager API enabled"
echo ""

# Check if .db-credentials file exists
if [ ! -f ".db-credentials" ]; then
    echo "❌ Error: .db-credentials file not found"
    echo "The database setup script should have created this file."
    exit 1
fi

# Load the password from the credentials file
source .db-credentials

if [ -z "$DB_PASSWORD" ]; then
    echo "❌ Error: DB_PASSWORD not set in .db-credentials"
    exit 1
fi

echo "Creating secret for database password..."

# Check if secret already exists
if gcloud secrets describe db-password --project=$PROJECT_ID > /dev/null 2>&1; then
    echo "⚠️  Secret 'db-password' already exists"
    read -p "Do you want to add a new version? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$DB_PASSWORD" | gcloud secrets versions add db-password --data-file=-
        echo "✅ New secret version added"
    else
        echo "Skipping secret creation"
    fi
else
    # Create the secret
    echo "$DB_PASSWORD" | gcloud secrets create db-password \
        --replication-policy="automatic" \
        --data-file=-
    
    if [ $? -eq 0 ]; then
        echo "✅ Secret 'db-password' created"
    else
        echo "❌ Failed to create secret"
        exit 1
    fi
fi

echo ""
echo "Setting up IAM permissions..."

# Get the default compute service account
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "Granting access to: $COMPUTE_SA"

# Grant the compute service account access to read the secret
gcloud secrets add-iam-policy-binding db-password \
    --member="serviceAccount:$COMPUTE_SA" \
    --role="roles/secretmanager.secretAccessor"

echo "✅ IAM permissions configured"
echo ""

# Create a helper script to retrieve the secret
cat > get-db-password.sh << 'EOF'
#!/bin/bash
# Retrieve database password from Secret Manager

source ./second-brain-setup.sh > /dev/null 2>&1

gcloud secrets versions access latest --secret="db-password" --project=$PROJECT_ID
EOF

chmod +x get-db-password.sh

echo "✅ Created helper script: get-db-password.sh"
echo ""

echo "========================================"
echo "  Secret Manager Setup Complete!"
echo "========================================"
echo ""
echo "Your database password is now stored securely in Google Secret Manager"
echo ""
echo "To retrieve it:"
echo "  ./get-db-password.sh"
echo ""
echo "Or in Rails config:"
echo "  DB_PASSWORD=\$(gcloud secrets versions access latest --secret=db-password)"
echo ""
echo "You can now delete the .db-credentials file if you want:"
echo "  rm .db-credentials"
echo ""