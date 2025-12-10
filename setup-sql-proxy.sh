#!/bin/bash
# Second Brain - Cloud SQL Proxy Setup
# Sets up Cloud SQL Proxy for local database access
# Usage: ./setup-sql-proxy.sh

echo "========================================"
echo "  Cloud SQL Proxy Setup"
echo "========================================"
echo ""

# Source the environment configuration
if [ -f "./second-brain-setup.sh" ]; then
    source ./second-brain-setup.sh
else
    echo "❌ Error: second-brain-setup.sh not found"
    exit 1
fi

# Check if database instance is ready
echo "Checking database status..."
DB_STATUS=$(gcloud sql instances describe $DB_INSTANCE --format="value(state)" 2>/dev/null)

if [ "$DB_STATUS" != "RUNNABLE" ]; then
    echo "❌ Database instance is not ready yet"
    echo "   Current status: $DB_STATUS"
    echo ""
    echo "Wait for the database to finish creating, then run this script again."
    echo "Check status with: gcloud sql instances list"
    exit 1
fi

echo "✅ Database instance is RUNNABLE"
echo ""

# Check if Cloud SQL Proxy is already installed
if command -v cloud-sql-proxy > /dev/null 2>&1; then
    echo "✅ Cloud SQL Proxy is already installed"
    PROXY_VERSION=$(cloud-sql-proxy --version 2>&1 | head -n1)
    echo "   Version: $PROXY_VERSION"
else
    echo "Installing Cloud SQL Proxy..."
    
    # Download the proxy
    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
    
    # Make it executable
    chmod +x cloud_sql_proxy
    
    # Move to user bin
    mkdir -p ~/bin
    mv cloud_sql_proxy ~/bin/
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/bin:$PATH"
    fi
    
    echo "✅ Cloud SQL Proxy installed to ~/bin/cloud_sql_proxy"
fi

echo ""
echo "Creating proxy startup script..."

# Create a convenient script to start the proxy
cat > start-sql-proxy.sh << EOF
#!/bin/bash
# Start Cloud SQL Proxy
# This must be running for local Rails development to connect to Cloud SQL

echo "Starting Cloud SQL Proxy..."
echo "Connection: $DB_CONNECTION_NAME"
echo ""
echo "Keep this terminal open while developing."
echo "Press Ctrl+C to stop the proxy."
echo ""

cloud-sql-proxy $DB_CONNECTION_NAME &
PROXY_PID=\$!

echo "✅ Cloud SQL Proxy started (PID: \$PROXY_PID)"
echo ""
echo "Now you can run: cd second-brain-rails && rails server"
echo ""

# Wait for Ctrl+C
trap "echo ''; echo 'Stopping proxy...'; kill \$PROXY_PID; exit 0" INT
wait \$PROXY_PID
EOF

chmod +x start-sql-proxy.sh

echo "✅ Proxy startup script created: start-sql-proxy.sh"
echo ""

echo "========================================"
echo "  Cloud SQL Proxy Setup Complete!"
echo "========================================"
echo ""
echo "To connect to your database locally:"
echo "  1. Start the proxy: ./start-sql-proxy.sh"
echo "  2. Keep that terminal open"
echo "  3. In another terminal, run Rails commands"
echo ""
echo "The proxy will make your Cloud SQL database available at:"
echo "  /cloudsql/$DB_CONNECTION_NAME"
echo ""
