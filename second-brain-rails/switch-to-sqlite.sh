#!/bin/bash
set -e

echo "======================================"
echo "Switching to SQLite for Local Development"
echo "======================================"

cd ~/Code/second-brain-app/second-brain-rails

echo ""
echo "Step 1: Updating database.yml for SQLite..."
echo "======================================"

cat > config/database.yml << 'YAML'
# SQLite. Versions 3.8.0 and up are supported.
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem "sqlite3"
#
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: storage/development.sqlite3

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: storage/test.sqlite3

production:
  <<: *default
  database: storage/production.sqlite3
YAML

echo "✓ Updated database.yml for SQLite"

echo ""
echo "Step 2: Ensuring sqlite3 gem is in Gemfile..."
echo "======================================"

if ! grep -q "gem ['\"]sqlite3['\"]" Gemfile; then
    echo "Adding sqlite3 to Gemfile..."
    # Add after the ruby version line
    sed -i '/^ruby /a gem "sqlite3", ">= 2.1"' Gemfile
    echo "✓ Added sqlite3 gem"
else
    echo "✓ sqlite3 gem already in Gemfile"
fi

echo ""
echo "Step 3: Installing gems..."
bundle install

echo ""
echo "Step 4: Creating SQLite databases..."
echo "======================================"

mkdir -p storage
bin/rails db:create
echo "✓ Databases created"

echo ""
echo "Step 5: Running migrations..."
echo "======================================"

bin/rails db:migrate
echo "✓ Migrations complete"

echo ""
echo "Step 6: Checking database status..."
echo "======================================"

bin/rails runner "
puts 'Database connection: ' + (ActiveRecord::Base.connection.active? ? '✓ Connected' : '✗ Failed')
puts 'Tables:'
ActiveRecord::Base.connection.tables.each do |table|
  count = ActiveRecord::Base.connection.execute(\"SELECT COUNT(*) FROM #{table}\").first['COUNT(*)']
  puts \"  - #{table}: #{count} records\"
end
"

echo ""
echo "======================================"
echo "✓ SQLite Setup Complete!"
echo "======================================"
echo ""
echo "Database location: storage/development.sqlite3"
echo ""
echo "Benefits of SQLite for local dev:"
echo "  • No server setup needed"
echo "  • File-based (easy backup)"
echo "  • Fast for development"
echo "  • Perfect for testing VEPS features"
echo ""
echo "For production, you can still use Cloud SQL"
echo "Just update production section in database.yml"
echo ""