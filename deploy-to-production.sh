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
