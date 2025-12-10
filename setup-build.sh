#!/bin/bash
# setup-build.sh - Setup script for SAMCO application build
# This script creates the necessary library and source physical files,
# then uploads IFS sources to those files.

set -e  # Exit on error

# Configuration
LIB=${1:-SAMCO}
PROJECT_DIR=$(pwd)

echo "=========================================="
echo "SAMCO Application Build Setup"
echo "=========================================="
echo "Target Library: $LIB"
echo "Project Directory: $PROJECT_DIR"
echo ""

# Function to run IBM i commands
run_system() {
  system "$1" 2>&1 || true
}

# Step 1: Create library if it doesn't exist
echo "Step 1: Creating library $LIB..."
run_system "CRTLIB LIB($LIB) TEXT('SAMCO Application')"
echo "✓ Library ready"
echo ""

# Step 2: Create source physical files
echo "Step 2: Creating source physical files..."

declare -A srcfiles=(
  ["QDDSSRC"]="DDS Source"
  ["QRPGLESRC"]="RPGLE Source"
  ["QRPGSRC"]="RPG Source"
  ["QCLSRC"]="CL Source"
  ["QCBLSRC"]="COBOL Source"
  ["QCMDSRC"]="Command Source"
  ["QSRVSRC"]="Service Program Binder Source"
  ["QBNDSRC"]="Binding Directory Source"
  ["QMSGFSRC"]="Message File Source"
  ["QPNLSRC"]="Panel Group Source"
  ["QSQLSRC"]="SQL Source"
  ["QDTASRC"]="Data Area Source"
  ["QTRGSRC"]="Trigger Source"
  ["QPROTOSRC"]="Prototype Source"
)

for srcfile in "${!srcfiles[@]}"; do
  text="${srcfiles[$srcfile]}"
  echo "  Creating $LIB/$srcfile..."
  run_system "CRTSRCPF FILE($LIB/$srcfile) RCDLEN(112) TEXT('$text')"
done

echo "✓ Source physical files created"
echo ""

# Step 3: Upload sources from IFS to source physical files
echo "Step 3: Uploading sources from IFS..."

upload_sources() {
  local srcdir=$1
  local srcfile=$2
  local count=0
  
  if [ ! -d "$srcdir" ]; then
    echo "  ⚠ Directory $srcdir not found, skipping..."
    return
  fi
  
  echo "  Uploading from $srcdir to $srcfile..."
  
  for file in "$srcdir"/*; do
    if [ -f "$file" ]; then
      # Extract member name (remove path and extension)
      filename=$(basename "$file")
      member="${filename%%.*}"
      
      # Upload to source physical file
      if system "CPYFRMSTMF FROMSTMF('$file') TOMBR('/QSYS.LIB/$LIB.LIB/$srcfile.FILE/$member.MBR') MBROPT(*REPLACE)" 2>/dev/null; then
        ((count++))
      else
        echo "    ⚠ Failed to upload $filename"
      fi
    fi
  done
  
  echo "    ✓ Uploaded $count members"
}

# Upload all source types
upload_sources "$PROJECT_DIR/SAMCO_SRC/QDDSSRC" "QDDSSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QRPGLESRC" "QRPGLESRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QRPGSRC" "QRPGSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QCLSRC" "QCLSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QCBLSRC" "QCBLSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QCMDSRC" "QCMDSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QSRVSRC" "QSRVSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QBNDSRC" "QBNDSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QMSGFSRC" "QMSGFSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QPNLSRC" "QPNLSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QSQLSRC" "QSQLSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QDTASRC" "QDTASRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QTRGSRC" "QTRGSRC"
upload_sources "$PROJECT_DIR/SAMCO_SRC/QPROTOSRC" "QPROTOSRC"

echo ""
echo "✓ Source upload complete!"
echo ""

# Step 4: Verify setup
echo "Step 4: Verifying setup..."
echo "  Checking library..."
if system "DSPLIB LIB($LIB)" >/dev/null 2>&1; then
  echo "    ✓ Library $LIB exists"
else
  echo "    ✗ Library $LIB not found"
  exit 1
fi

echo "  Checking source files..."
for srcfile in "${!srcfiles[@]}"; do
  if system "DSPFD FILE($LIB/$srcfile)" >/dev/null 2>&1; then
    member_count=$(system "DSPFD FILE($LIB/$srcfile) TYPE(*MBRLIST)" 2>/dev/null | grep -c "Member" || echo "0")
    echo "    ✓ $srcfile ($member_count members)"
  else
    echo "    ✗ $srcfile not found"
  fi
done

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review the uploaded sources:"
echo "     system \"DSPPFM FILE($LIB/QRPGLESRC)\""
echo ""
echo "  2. Build the application:"
echo "     gmake BUILDLIB=$LIB"
echo ""
echo "  3. Or build specific components:"
echo "     gmake database BUILDLIB=$LIB"
echo "     gmake programs BUILDLIB=$LIB"
echo ""
echo "  4. See all build options:"
echo "     gmake help"
echo ""

# Made with Bob
