#!/bin/bash
# Second Brain - Database Setup Script
# Creates Cloud SQL PostgreSQL instance
# Usage: ./setup-database.sh

echo "========================================"
echo "  Database Setup"
echo "========================================"
echo ""

# Source the environment configuration
if [ -f "./second-brain-setup.sh" ]; then
    source ./second-brain-setup.sh
else
    echo "❌ Error: second-brain-setup.sh not found"
    echo "Please run from the project directory"
    exit 1
fi

echo "Creating Cloud SQL PostgreSQL instance..."
echo "  Instance name: $DB_INSTANCE"
echo "  Region: $REGION"
echo "  Database: $DB_NAME"
echo ""

echo "Creating Cloud SQL PostgreSQL instance..."
echo "  Instance name: $DB_INSTANCE"
echo "  Region: $REGION"
echo "  Database: $DB_NAME"
echo ""

# Check if instance already exists
if gcloud sql instances describe $DB_INSTANCE --format="value(name)" 2>/dev/null | grep -q "$DB_INSTANCE"; then
    echo "✅ Cloud SQL instance '$DB_INSTANCE' already exists"
    INSTANCE_EXISTS=true
else
    # Create the Cloud SQL instance
    echo "⏳ Creating instance (this takes 5-10 minutes)..."
    gcloud sql instances create $DB_INSTANCE \
        --database-version=POSTGRES_15 \
        --tier=db-f1-micro \
        --region=$REGION \
        --root-password=$(openssl rand -base64 32) \
        --storage-type=SSD \
        --storage-size=10GB \
        --backup-start-time=03:00

    if [ $? -eq 0 ]; then
        echo "✅ Cloud SQL instance created successfully"
        INSTANCE_EXISTS=true
    else
        echo "❌ Failed to create Cloud SQL instance"
        exit 1
    fi
fi

echo ""
# Check if database already exists
if gcloud sql databases describe $DB_NAME --instance=$DB_INSTANCE --format="value(name)" 2>/dev/null | grep -q "$DB_NAME"; then
    echo "✅ Database '$DB_NAME' already exists"
else
    echo "Creating database '$DB_NAME'..."
    gcloud sql databases create $DB_NAME \
        --instance=$DB_INSTANCE
    echo "✅ Database '$DB_NAME' created"
fi

echo ""
# Check if user already exists
if gcloud sql users list --instance=$DB_INSTANCE --format="value(name)" 2>/dev/null | grep -q "^$DB_USER$"; then
    echo "✅ Database user '$DB_USER' already exists"
    echo "⚠️  Using existing user (password not changed)"
    DB_PASSWORD="<existing-password-not-changed>"
else
    echo "Creating database user '$DB_USER'..."
    DB_PASSWORD=$(openssl rand -base64 32)
    gcloud sql users create $DB_USER \
        --instance=$DB_INSTANCE \
        --password=$DB_PASSWORD
    echo "✅ Database user '$DB_USER' created"
fi

echo ""
echo "========================================"
echo "  Database Setup Complete!"
echo "========================================"
echo ""
echo "Database Details:"
echo "  Instance: $DB_INSTANCE"
echo "  Connection: $DB_CONNECTION_NAME"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"

if [ "$DB_PASSWORD" != "<existing-password-not-changed>" ]; then
    echo "  Password: $DB_PASSWORD"
    echo ""
    echo "⚠️  IMPORTANT: Save this password!"
    echo "Add to your environment:"
    echo "  export DB_PASSWORD='$DB_PASSWORD'"
    echo ""
    
    # Save password to a secure file
    echo "export DB_PASSWORD='$DB_PASSWORD'" > .db-credentials
    chmod 600 .db-credentials
    echo "✅ Credentials saved to .db-credentials (keep this secure!)"
else
    echo "  Password: (not changed - using existing)"
    echo ""
    echo "⚠️  User already exists - password was not changed"
    echo "If you need the password, check your .db-credentials file"
fi
echo ""