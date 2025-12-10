#!/bin/bash
# Second Brain - Rails App Setup Script
# Generates a new Rails 8 application configured for GCP
# Usage: ./setup-rails-app.sh

echo "========================================"
echo "  Rails App Setup"
echo "========================================"
echo ""

# Source the environment configuration
if [ -f "./second-brain-setup.sh" ]; then
    source ./second-brain-setup.sh
else
    echo "❌ Error: second-brain-setup.sh not found"
    exit 1
fi

# Check if Rails app already exists
if [ -d "second-brain-rails" ]; then
    echo "⚠️  WARNING: Rails app directory 'second-brain-rails' already exists!"
    echo ""
    echo "This script will:"
    echo "  ❌ DELETE the entire 'second-brain-rails' directory"
    echo "  ❌ Remove all code, migrations, and any work you've done"
    echo "  ✅ Create a completely fresh Rails application"
    echo ""
    echo "If you want to keep your existing app and just update configuration,"
    echo "exit this script (Ctrl+C) and manually update the files."
    echo ""
    read -p "Are you ABSOLUTELY SURE you want to DELETE and recreate? (yes/NO): " CONFIRM
    
    if [ "$CONFIRM" = "yes" ]; then
        echo ""
        echo "⚠️  Last chance! Type the directory name to confirm deletion:"
        read -p "Type 'second-brain-rails' to confirm: " DIR_CONFIRM
        
        if [ "$DIR_CONFIRM" = "second-brain-rails" ]; then
            echo ""
            echo "🗑️  Removing existing directory..."
            rm -rf second-brain-rails
            echo "✅ Directory removed"
        else
            echo "❌ Confirmation failed. Aborting for safety."
            exit 1
        fi
    else
        echo ""
        echo "❌ Aborted. Your existing app is safe."
        echo ""
        echo "Options:"
        echo "  1. Rename it: mv second-brain-rails second-brain-rails.old"
        echo "  2. Delete manually: rm -rf second-brain-rails"
        echo "  3. Update configuration manually in your existing app"
        exit 1
    fi
    echo ""
fi

echo "Creating new Rails 8 application..."
echo "  Name: second-brain-rails"
echo "  Database: PostgreSQL"
echo "  API: No (full-stack app with views)"
echo ""

# Create Rails app with PostgreSQL
rails new second-brain-rails \
    --database=postgresql \
    --css=tailwind \
    --skip-test \
    --javascript=importmap

if [ $? -ne 0 ]; then
    echo "❌ Failed to create Rails app"
    exit 1
fi

echo "✅ Rails app created"
echo ""

cd second-brain-rails

echo "Configuring database connection..."

# Load DB password if it exists
if [ -f "../.db-credentials" ]; then
    source ../.db-credentials
else
    echo "⚠️  Warning: .db-credentials not found, you'll need to set DB_PASSWORD manually"
    DB_PASSWORD=""
fi

# Update database.yml for Cloud SQL
cat > config/database.yml << EOF
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: second_brain_development
  username: <%= ENV['DB_USER'] || 'second_brain_app' %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] || 'localhost' %>

test:
  <<: *default
  database: second_brain_test
  username: <%= ENV['DB_USER'] || 'second_brain_app' %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] || 'localhost' %>

production:
  <<: *default
  database: <%= ENV['DB_NAME'] || 'second_brain_production' %>
  username: <%= ENV['DB_USER'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  # For Cloud SQL, use unix socket
  host: <%= ENV['DB_HOST'] || '/cloudsql/${DB_CONNECTION_NAME}' %>
EOF

echo "✅ Database configuration updated"
echo ""

echo "Adding required gems..."

# Add gems to Gemfile
cat >> Gemfile << 'EOF'

# Google Cloud Storage for attachments
gem 'google-cloud-storage', '~> 1.47', require: false

# Markdown rendering for notes
gem 'redcarpet', '~> 3.6'

# Pagination
gem 'kaminari', '~> 1.2'
EOF

echo "✅ Gemfile updated"
echo ""

echo "Installing gems..."

# Install gems to local vendor/bundle directory (not system-wide)
bundle config set --local path 'vendor/bundle'
bundle install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install gems"
    exit 1
fi

echo "✅ Gems installed"
echo ""

echo "========================================"
echo "  Rails App Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. cd second-brain-rails"
echo "  2. Wait for database to finish provisioning"
echo "  3. Run: rails db:create db:migrate"
echo "  4. Run: rails server"
echo ""
echo "Your Rails app is in: ./second-brain-rails"
echo ""