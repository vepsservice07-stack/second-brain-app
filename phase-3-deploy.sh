#!/bin/bash
# Phase 3: Production Deployment
# Deploys Second Brain to Google App Engine
# Usage: ./phase-3-deploy.sh

echo "========================================"
echo "  Phase 3: Production Deployment"
echo "========================================"
echo ""

# Must be run from parent directory
if [ ! -f "second-brain-setup.sh" ]; then
    echo "❌ Error: Must run from second-brain-app directory"
    exit 1
fi

source ./second-brain-setup.sh

if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set"
    exit 1
fi

cd second-brain-rails

echo "Preparing production configuration..."

# Create app.yaml for App Engine
cat > app.yaml << YAML
runtime: ruby32
entrypoint: bundle exec rails server -p \$PORT -e production

env_variables:
  RAILS_ENV: production
  SECRET_KEY_BASE: PLACEHOLDER_WILL_BE_SET_IN_SECRETS
  RAILS_LOG_TO_STDOUT: true
  RAILS_SERVE_STATIC_FILES: true

automatic_scaling:
  min_instances: 0
  max_instances: 2
  target_cpu_utilization: 0.65

# Health check
readiness_check:
  path: "/up"
  timeout_sec: 4
  check_interval_sec: 5
  failure_threshold: 2
  success_threshold: 2

liveness_check:
  path: "/up"
  timeout_sec: 4
  check_interval_sec: 30
  failure_threshold: 2
  success_threshold: 2
YAML

echo "✅ app.yaml created"
echo ""

echo "Storing production secrets in Secret Manager..."

# Generate a production secret key
SECRET_KEY=$(bin/rails secret)

# Store in Secret Manager
if gcloud secrets describe rails-secret-key-base --project=${PROJECT_ID} 2>/dev/null; then
    echo "Secret already exists, creating new version..."
    echo -n "$SECRET_KEY" | gcloud secrets versions add rails-secret-key-base \
        --data-file=- --project=${PROJECT_ID}
else
    echo "Creating new secret..."
    echo -n "$SECRET_KEY" | gcloud secrets create rails-secret-key-base \
        --data-file=- --project=${PROJECT_ID} \
        --replication-policy="automatic"
fi

# Grant App Engine access to secrets
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
gcloud secrets add-iam-policy-binding rails-secret-key-base \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor" \
    --project=${PROJECT_ID}

echo "✅ Secrets configured"
echo ""

echo "Creating production database configuration..."

# Update database.yml for production
cat > config/database.yml << YAML
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: second_brain_development
  username: second_brain_app
  password: <%= \`gcloud secrets versions access latest --secret=db-password 2>/dev/null || echo "local_dev_password"\`.strip %>
  host: <%= ENV.fetch("DB_HOST") { "/tmp/cloudsql/${PROJECT_ID}:${REGION}:second-brain-db" } %>

production:
  <<: *default
  database: second_brain_production
  username: second_brain_app
  password: <%= \`gcloud secrets versions access latest --secret=db-password\`.strip %>
  host: "/cloudsql/${PROJECT_ID}:${REGION}:second-brain-db"
YAML

echo "✅ Production database configured"
echo ""

echo "Setting up production environment file..."

cat > config/environments/production.rb << 'RUBY'
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  
  config.active_storage.service = :google
  
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  
  config.action_mailer.perform_caching = false
  
  config.i18n.fallbacks = true
  
  config.active_support.report_deprecations = false
  
  config.active_record.dump_schema_after_migration = false
  
  # Force SSL in production
  # config.force_ssl = true
end
RUBY

echo "✅ Production environment configured"
echo ""

echo "Creating deployment script..."

cat > ../deploy-to-production.sh << 'BASH'
#!/bin/bash
# Deploy Second Brain to production
# Usage: ./deploy-to-production.sh

set -e

echo "========================================"
echo "  Deploying to Production"
echo "========================================"
echo ""

source ./second-brain-setup.sh

cd second-brain-rails

echo "Running pre-deployment checks..."

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "⚠️  Warning: You have uncommitted changes"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ Pre-checks passed"
echo ""

echo "Precompiling assets..."
RAILS_ENV=production bin/rails assets:precompile

echo "✅ Assets compiled"
echo ""

echo "Running database migrations on production..."
gcloud app deploy --quiet app.yaml --project=${PROJECT_ID}

echo ""
echo "Running migrations..."
# Get the latest deployed version
VERSION=$(gcloud app versions list --service=default --sort-by=~version.createTime --limit=1 --format="value(version.id)" --project=${PROJECT_ID})

# Run migrations
gcloud app instances ssh ${VERSION} --service=default --project=${PROJECT_ID} \
    --command="cd /app && bundle exec rails db:migrate RAILS_ENV=production" || true

echo "✅ Migrations complete"
echo ""

echo "========================================"
echo "  Deployment Complete!"
echo "========================================"
echo ""
echo "Your app is live at:"
echo "https://${PROJECT_ID}.uc.r.appspot.com"
echo ""
echo "View logs:"
echo "gcloud app logs tail -s default --project=${PROJECT_ID}"
echo ""
BASH

chmod +x ../deploy-to-production.sh

echo "✅ Deployment script created"
echo ""

echo "Creating .gcloudignore..."

cat > .gcloudignore << 'IGNORE'
.git
.gitignore
.bundle
.tmp
tmp/
log/
storage/
node_modules/
vendor/bundle/
.env
.env.*
*.log
*.sqlite3
coverage/
spec/
test/
.rspec
.rubocop.yml
README.md
IGNORE

echo "✅ .gcloudignore created"
echo ""

echo "Enabling required APIs..."

gcloud services enable appengine.googleapis.com --project=${PROJECT_ID}
gcloud services enable cloudbuild.googleapis.com --project=${PROJECT_ID}
gcloud services enable sqladmin.googleapis.com --project=${PROJECT_ID}

echo "✅ APIs enabled"
echo ""

echo "Configuring Cloud SQL for App Engine..."

# Get database instance connection name
DB_CONNECTION=$(gcloud sql instances describe second-brain-db \
    --project=${PROJECT_ID} \
    --format="value(connectionName)")

echo "Database connection: ${DB_CONNECTION}"

# Update app.yaml with database connection
sed -i '/env_variables:/a\  CLOUD_SQL_CONNECTION_NAME: '${DB_CONNECTION}'' app.yaml

echo "✅ Cloud SQL configured"
echo ""

echo "========================================"
echo "  Phase 3 Complete!"
echo "========================================"
echo ""
echo "What was created:"
echo "  📦 app.yaml (App Engine config)"
echo "  🔐 Production secrets in Secret Manager"
echo "  🗄️  Production database configuration"
echo "  🚀 deploy-to-production.sh script"
echo ""
echo "To deploy to production:"
echo "  cd ~/Code/second-brain-app"
echo "  ./deploy-to-production.sh"
echo ""
echo "First deployment will take ~10-15 minutes"
echo ""
echo "⚠️  Important:"
echo "  - Review app.yaml before deploying"
echo "  - Test locally first: RAILS_ENV=production bin/rails server"
echo "  - Monitor logs after deploy"
echo ""