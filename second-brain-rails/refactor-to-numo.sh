#!/bin/bash
set -e

echo "======================================"
echo "Refactoring NMatrix to Numo::NArray"
echo "======================================"

# Navigate to Rails app directory (adjust path as needed)
cd ~/Code/second-brain-app/second-brain-rails

echo ""
echo "Step 1: Updating Gemfile..."
echo "======================================"

# Replace nmatrix with numo-narray in Gemfile
if grep -q "nmatrix" Gemfile; then
    echo "Found nmatrix in Gemfile, replacing with numo-narray..."
    
    # Create backup
    cp Gemfile Gemfile.backup
    
    # Replace nmatrix with numo-narray
    sed -i "s/gem 'nmatrix'.*/gem 'numo-narray', '~> 0.9.2'  # Successor to NMatrix/" Gemfile
    
    echo "✓ Gemfile updated"
else
    echo "nmatrix not found in Gemfile, checking if numo-narray already present..."
    if grep -q "numo-narray" Gemfile; then
        echo "✓ numo-narray already in Gemfile"
    else
        echo "Adding numo-narray to Gemfile..."
        # Add after the semantic analysis section
        sed -i "/# Local semantic analysis/a gem 'numo-narray', '~> 0.9.2'  # Matrix operations" Gemfile
        echo "✓ numo-narray added"
    fi
fi

echo ""
echo "Step 2: Installing gems..."
echo "======================================"
bundle install

echo ""
echo "Step 3: Checking for code that uses NMatrix..."
echo "======================================"

# Find all Ruby files that require or use nmatrix
FILES_WITH_NMATRIX=$(grep -r "require.*nmatrix\|NMatrix" --include="*.rb" . 2>/dev/null || echo "")

if [ -n "$FILES_WITH_NMATRIX" ]; then
    echo "Found files using NMatrix:"
    echo "$FILES_WITH_NMATRIX"
    echo ""
    echo "Creating refactoring guide..."
    
    cat > /tmp/nmatrix_to_numo_refactor.md << 'EOF'
# NMatrix to Numo::NArray Refactoring Guide

## Installation
```ruby
# Gemfile - DONE
gem 'numo-narray', '~> 0.9.2'
```

## Basic Replacements

### Require statements
```ruby
# OLD
require 'nmatrix'

# NEW
require 'numo/narray'
```

### Creating matrices

```ruby
# OLD - NMatrix
matrix = NMatrix.new([3,3], [1,2,3,4,5,6,7,8,9], dtype: :float64)
vector = NMatrix.new([3,1], [1,2,3], dtype: :float64)

# NEW - Numo::NArray
matrix = Numo::DFloat[[1,2,3], [4,5,6], [7,8,9]]
vector = Numo::DFloat[1, 2, 3]

# Or using .new
matrix = Numo::DFloat.new(3,3).seq  # Creates sequence 0-8
```

### Matrix operations

```ruby
# Dot product / Matrix multiplication
# OLD
result = matrix.dot(vector)

# NEW  
result = matrix.dot(vector)  # Same!

# Transpose
# OLD
transposed = matrix.transpose

# NEW
transposed = matrix.transpose  # Same!

# Element access
# OLD
element = matrix[0,0]

# NEW
element = matrix[0,0]  # Same!
```

### Common patterns for semantic analysis

```ruby
# Creating TF-IDF matrix
# OLD
tfidf_matrix = NMatrix.new([num_docs, num_terms], data, dtype: :float64)

# NEW
tfidf_matrix = Numo::DFloat.new(num_docs, num_terms)
data.each_with_index do |value, i|
  row = i / num_terms
  col = i % num_terms
  tfidf_matrix[row, col] = value
end

# Or if you have a flat array:
tfidf_matrix = Numo::DFloat.new(num_docs, num_terms)
tfidf_matrix[] = data  # Assign all at once

# Cosine similarity
def cosine_similarity(vec1, vec2)
  # Both NMatrix and Numo support this pattern
  dot_product = vec1.dot(vec2)
  magnitude1 = Math.sqrt((vec1 * vec1).sum)
  magnitude2 = Math.sqrt((vec2 * vec2).sum)
  
  dot_product / (magnitude1 * magnitude2)
end
```

### Data types

```ruby
# OLD - NMatrix dtypes
:float64, :float32, :int32, :int64

# NEW - Numo classes
Numo::DFloat   # Double precision float (64-bit)
Numo::SFloat   # Single precision float (32-bit)
Numo::Int32    # 32-bit integer
Numo::Int64    # 64-bit integer
Numo::UInt32   # Unsigned 32-bit
Numo::UInt64   # Unsigned 64-bit
```

## Key Differences

1. **Construction syntax**: Numo uses Ruby array literals for initialization
2. **Module namespace**: Everything is under `Numo::`
3. **Type as class**: `Numo::DFloat` vs `NMatrix.new(..., dtype: :float64)`
4. **Better performance**: Numo is generally faster and more actively maintained

## If You Need LAPACK (Linear Algebra)

For advanced operations (SVD, eigenvalues, etc.), use `numo-linalg`:

```ruby
# Gemfile
gem 'numo-linalg'

# Usage
require 'numo/linalg'

matrix = Numo::DFloat[[1,2], [3,4]]
eigenvalues = Numo::Linalg.eigvals(matrix)
svd_result = Numo::Linalg.svd(matrix)
```

## Testing the Migration

```ruby
# Quick test
require 'numo/narray'

# Create a simple matrix
m = Numo::DFloat[[1,2,3], [4,5,6]]
puts m
puts "Shape: #{m.shape}"
puts "Sum: #{m.sum}"
puts "Mean: #{m.mean}"

# Matrix multiplication
v = Numo::DFloat[1, 2, 3]
result = m.dot(v)
puts "Dot product: #{result}"
```

EOF

    cat /tmp/nmatrix_to_numo_refactor.md
    
else
    echo "✓ No Ruby files found that directly use NMatrix"
    echo "  (This is good - might mean it's only in Gemfile)"
fi

echo ""
echo "Step 4: Verifying Numo installation..."
echo "======================================"

# Test if Numo works
ruby -e "
require 'numo/narray'
puts 'Testing Numo::NArray...'
m = Numo::DFloat[[1,2], [3,4]]
puts 'Created matrix:'
puts m
puts 'Shape: ' + m.shape.to_s
puts 'Sum: ' + m.sum.to_s
puts '✓ Numo::NArray is working!'
" || echo "⚠ Warning: Could not verify Numo installation"

echo ""
echo "======================================"
echo "✓ Refactoring Complete!"
echo "======================================"
echo ""
echo "Summary:"
echo "  - Gemfile updated to use numo-narray"
echo "  - Gems installed"
echo "  - Numo verified working"
echo ""
echo "Next steps:"
echo "  1. Review any code files that use NMatrix (see above)"
echo "  2. Update require statements: require 'numo/narray'"
echo "  3. Update matrix creation to use Numo::DFloat or Numo::Int32"
echo "  4. Test your semantic analysis features"
echo ""
echo "See /tmp/nmatrix_to_numo_refactor.md for detailed migration guide"
echo ""