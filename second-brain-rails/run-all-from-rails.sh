#!/bin/bash
set -e

echo "======================================"
echo "🧠 Running Cognitive Dyad Setup"
echo "From Correct Directory"
echo "======================================"
echo ""

# Navigate to Rails app
cd ~/Code/second-brain-app/second-brain-rails

echo "Current directory: $(pwd)"
echo ""

# Copy scripts to Rails directory if they're not there
if [ -f ~/Code/second-brain-app/cognitive-dyad-foundation.sh ]; then
  echo "Copying scripts from parent directory..."
  cp ~/Code/second-brain-app/cognitive-dyad-foundation.sh ./
  cp ~/Code/second-brain-app/cognitive-dyad-ui.sh ./
  cp ~/Code/second-brain-app/fix-controller.sh ./
  echo "✓ Scripts copied"
  echo ""
fi

# Run in correct order
echo "Step 1: Running foundation..."
bash cognitive-dyad-foundation.sh

echo ""
echo "Step 2: Running UI..."
bash cognitive-dyad-ui.sh

echo ""
echo "Step 3: Fixing controller..."
bash fix-controller.sh

echo ""
echo "======================================"
echo "✅ All Done!"
echo "======================================"
echo ""
echo "Now refresh your browser and view a note!"
echo ""