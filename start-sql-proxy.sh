#!/bin/bash
# Start Cloud SQL Proxy
# This must be running for local Rails development to connect to Cloud SQL

source ./second-brain-setup.sh > /dev/null 2>&1

echo "Starting Cloud SQL Proxy..."
echo "Connection: $DB_CONNECTION_NAME"
echo ""
echo "Keep this terminal open while developing."
echo "Press Ctrl+C to stop the proxy."
echo ""

mkdir -p /tmp/cloudsql

cloud_sql_proxy -dir=/tmp/cloudsql $DB_CONNECTION_NAME &
PROXY_PID=$!

echo "✅ Cloud SQL Proxy started (PID: $PROXY_PID)"
echo ""
echo "Now you can run: cd second-brain-rails && rails server"
echo ""

# Wait for Ctrl+C
trap "echo ''; echo 'Stopping proxy...'; kill $PROXY_PID; exit 0" INT
wait $PROXY_PID
