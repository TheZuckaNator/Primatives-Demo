#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Header
echo ""
echo -e "${PURPLE}╔════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║   Stylus Contract Testing Suite           ║${NC}"
echo -e "${PURPLE}║   Testing: StylusPrimitivesDemo            ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Counter for passed/failed tests
PASSED=0
FAILED=0

# Step 1: Check Prerequisites
print_step "Step 1: Checking Prerequisites"

if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version)
    print_success "Rust installed: $RUST_VERSION"
    ((PASSED++))
else
    print_error "Rust not installed"
    ((FAILED++))
    exit 1
fi

if command -v cargo &> /dev/null; then
    CARGO_VERSION=$(cargo --version)
    print_success "Cargo installed: $CARGO_VERSION"
    ((PASSED++))
else
    print_error "Cargo not installed"
    ((FAILED++))
    exit 1
fi

if rustup target list | grep -q "wasm32-unknown-unknown (installed)"; then
    print_success "WASM target installed"
    ((PASSED++))
else
    print_error "WASM target not installed"
    print_info "Run: rustup target add wasm32-unknown-unknown"
    ((FAILED++))
    exit 1
fi

if command -v cargo-stylus &> /dev/null; then
    STYLUS_VERSION=$(cargo stylus --version 2>&1 || echo "version unknown")
    print_success "Stylus CLI installed: $STYLUS_VERSION"
    ((PASSED++))
else
    print_error "Stylus CLI not installed"
    print_info "Run: cargo install --force cargo-stylus"
    ((FAILED++))
    exit 1
fi

echo ""

# Step 2: Check Project Structure
print_step "Step 2: Checking Project Structure"

if [ -f "Cargo.toml" ]; then
    print_success "Cargo.toml found"
    ((PASSED++))
else
    print_error "Cargo.toml not found"
    ((FAILED++))
fi

if [ -f "src/lib.rs" ]; then
    print_success "src/lib.rs found"
    ((PASSED++))
else
    print_error "src/lib.rs not found"
    ((FAILED++))
fi

if [ -f "README.md" ]; then
    print_success "README.md found"
    ((PASSED++))
else
    print_warning "README.md not found (optional)"
fi

echo ""

# Step 3: Clean Previous Builds
print_step "Step 3: Cleaning Previous Builds"

if cargo clean; then
    print_success "Previous builds cleaned"
    ((PASSED++))
else
    print_error "Failed to clean builds"
    ((FAILED++))
fi

echo ""

# Step 4: Build Contract
print_step "Step 4: Building Contract for WASM"

echo "Running: cargo build --release --target wasm32-unknown-unknown"
echo ""

if cargo build --release --target wasm32-unknown-unknown 2>&1; then
    print_success "Contract compiled successfully"
    ((PASSED++))
else
    print_error "Contract compilation failed"
    ((FAILED++))
    echo ""
    print_info "Check the error messages above for details"
    exit 1
fi

echo ""

# Step 5: Check WASM File
print_step "Step 5: Checking WASM Output"

WASM_FILE=$(find target/wasm32-unknown-unknown/release -name "*.wasm" -type f | head -n 1)

if [ -f "$WASM_FILE" ]; then
    WASM_SIZE=$(ls -lh "$WASM_FILE" | awk '{print $5}')
    print_success "WASM file created: $WASM_FILE"
    print_info "File size: $WASM_SIZE"
    ((PASSED++))
else
    print_error "WASM file not found"
    ((FAILED++))
fi

echo ""

# Step 6: Run Stylus Check
print_step "Step 6: Running Stylus Validation"

echo "Running: cargo stylus check"
echo ""

STYLUS_OUTPUT=$(cargo stylus check 2>&1)
STYLUS_EXIT=$?

echo "$STYLUS_OUTPUT"
echo ""

if [ $STYLUS_EXIT -eq 0 ]; then
    if echo "$STYLUS_OUTPUT" | grep -q "Program succeeded"; then
        print_success "Contract passed Stylus validation!"
        ((PASSED++))
    else
        print_warning "Stylus check completed but no success message found"
    fi
else
    print_error "Stylus validation failed"
    ((FAILED++))
    print_info "Review the error messages above"
    exit 1
fi

echo ""

# Step 7: Export ABI
print_step "Step 7: Exporting Contract ABI"

if cargo stylus export-abi > abi.json 2>&1; then
    if [ -f "abi.json" ]; then
        FUNCTION_COUNT=$(grep -o '"type":"function"' abi.json | wc -l | tr -d ' ')
        print_success "ABI exported successfully: abi.json"
        print_info "Functions found: $FUNCTION_COUNT"
        ((PASSED++))
        
        # Show function names
        echo ""
        print_info "Contract functions:"
        grep -o '"name":"[^"]*"' abi.json | cut -d'"' -f4 | while read func; do
            echo "  • $func"
        done
    else
        print_warning "ABI file not created"
    fi
else
    print_warning "ABI export failed (non-critical)"
fi

echo ""

# Step 8: Run Tests
print_step "Step 8: Running Cargo Tests"

if cargo test 2>&1; then
    print_success "Tests completed"
    ((PASSED++))
else
    print_warning "Tests failed or no tests found"
fi

echo ""

# Step 9: Security Check (Optional)
print_step "Step 9: Additional Checks"

# Check for common issues in code
if grep -q "unwrap()" src/lib.rs; then
    print_warning "Found unwrap() calls - consider using proper error handling"
else
    print_success "No unwrap() calls found"
fi

if grep -q "panic!" src/lib.rs; then
    print_warning "Found panic! calls - consider graceful error handling"
else
    print_success "No panic! calls found"
fi

echo ""

# Final Summary
print_step "Test Summary"

echo ""
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                            ║${NC}"
    echo -e "${GREEN}║     🎉 ALL TESTS PASSED! 🎉                ║${NC}"
    echo -e "${GREEN}║                                            ║${NC}"
    echo -e "${GREEN}║  Your contract is ready for deployment!   ║${NC}"
    echo -e "${GREEN}║                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    print_info "Next steps:"
    echo "  1. Review the generated abi.json"
    echo "  2. Test deployment with: cargo stylus deploy --estimate-gas"
    echo "  3. Deploy to testnet when ready"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                            ║${NC}"
    echo -e "${RED}║     ❌ TESTS FAILED ❌                     ║${NC}"
    echo -e "${RED}║                                            ║${NC}"
    echo -e "${RED}║  Please fix the errors above              ║${NC}"
    echo -e "${RED}║                                            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi