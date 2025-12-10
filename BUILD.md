# Building the SAMCO Application with IBM i Bob

This document explains how to build the SAMCO application using IBM i Bob (Better Object Builder).

## Prerequisites

1. **Install IBM i Bob** on your IBM i system:
   ```bash
   yum install ibmi-bob
   ```

2. **Install GNU Make** (if not already installed):
   ```bash
   yum install make-gnu
   ```

3. **Clone the repository** to your IBM i system (or upload the source files)

## Quick Start

### 1. Upload Source to IBM i

First, you need to get your source code onto the IBM i system. You have several options:

#### Option A: Using Git (Recommended)
```bash
# SSH into your IBM i system
ssh user@youribmi

# Clone the repository
cd /home/youruser
git clone https://github.com/bmarolleau/ibmi-samco.git
cd ibmi-samco
```

#### Option B: Using VS Code with Code for IBM i Extension
- Use the "Upload to IFS" feature in VS Code
- Upload the entire project directory to `/home/youruser/ibmi-samco`

### 2. Create the Build Library

Before building, create the library where objects will be compiled:

```bash
system "CRTLIB LIB(SAMCO) TEXT('SAMCO Application')"
```

Or for a development library:
```bash
system "CRTLIB LIB(SAMCODEV) TEXT('SAMCO Development')"
```

### 3. Upload Source to Source Physical Files

The build process expects source to be in source physical files. Create them:

```bash
# Navigate to your project directory
cd /home/youruser/ibmi-samco

# Create source physical files in the library
system "CRTSRCPF FILE(SAMCO/QDDSSRC) RCDLEN(112) TEXT('DDS Source')"
system "CRTSRCPF FILE(SAMCO/QRPGLESRC) RCDLEN(112) TEXT('RPGLE Source')"
system "CRTSRCPF FILE(SAMCO/QRPGSRC) RCDLEN(112) TEXT('RPG Source')"
system "CRTSRCPF FILE(SAMCO/QCLSRC) RCDLEN(112) TEXT('CL Source')"
system "CRTSRCPF FILE(SAMCO/QCBLSRC) RCDLEN(112) TEXT('COBOL Source')"
system "CRTSRCPF FILE(SAMCO/QCMDSRC) RCDLEN(112) TEXT('Command Source')"
system "CRTSRCPF FILE(SAMCO/QSRVSRC) RCDLEN(112) TEXT('Service Program Binder Source')"
system "CRTSRCPF FILE(SAMCO/QBNDSRC) RCDLEN(112) TEXT('Binding Directory Source')"
system "CRTSRCPF FILE(SAMCO/QMSGFSRC) RCDLEN(112) TEXT('Message File Source')"
system "CRTSRCPF FILE(SAMCO/QPNLSRC) RCDLEN(112) TEXT('Panel Group Source')"
system "CRTSRCPF FILE(SAMCO/QSQLSRC) RCDLEN(112) TEXT('SQL Source')"
system "CRTSRCPF FILE(SAMCO/QDTASRC) RCDLEN(112) TEXT('Data Area Source')"
```

### 4. Copy IFS Source to Source Physical Files

Use the `CPYFRMSTMF` command to copy source from IFS to source members:

```bash
# Example script to copy all sources
# You can create a CL program or shell script for this

# Copy DDS sources
for file in SAMCO_SRC/QDDSSRC/*; do
  member=$(basename "$file" | cut -d. -f1)
  system "CPYFRMSTMF FROMSTMF('$file') TOMBR('/QSYS.LIB/SAMCO.LIB/QDDSSRC.FILE/$member.MBR') MBROPT(*REPLACE)"
done

# Copy RPGLE sources
for file in SAMCO_SRC/QRPGLESRC/*; do
  member=$(basename "$file" | cut -d. -f1)
  system "CPYFRMSTMF FROMSTMF('$file') TOMBR('/QSYS.LIB/SAMCO.LIB/QRPGLESRC.FILE/$member.MBR') MBROPT(*REPLACE)"
done

# Repeat for other source types...
```

**Alternative**: Use the provided helper script (see below).

### 5. Build the Application

Once source files are in place, run the build:

```bash
# Build everything to SAMCO library
gmake

# Or build to a different library
gmake BUILDLIB=SAMCODEV

# Build only database objects
gmake database

# Build only programs
gmake programs

# See all available targets
gmake help
```

## Build Targets

The makefile provides several targets for building different parts of the application:

- `all` (default) - Build entire application
- `database` - Build all database objects (files, tables, views)
- `programs` - Build all programs and service programs
- `binding-dirs` - Build binding directories
- `message-files` - Build message files
- `data-areas` - Build data areas
- `physical-files` - Build physical files
- `logical-files` - Build logical files
- `display-files` - Build display files
- `print-files` - Build print files
- `sql-objects` - Build SQL objects (tables, views, procedures, etc.)
- `modules` - Build RPGLE modules
- `service-programs` - Build service programs
- `bound-programs` - Build bound programs
- `commands` - Build commands
- `menus` - Build menus and panel groups
- `triggers` - Build triggers

## Build Order

The build system automatically handles dependencies and builds objects in the correct order:

1. Binding directories
2. Message files
3. Data areas
4. Physical files
5. Logical files
6. Display files
7. Print files
8. SQL objects (tables, views, sequences, UDFs, procedures)
9. RPGLE modules
10. Service programs
11. Bound programs (RPG, RPGLE, CL, COBOL)
12. Commands
13. Menus and panel groups
14. Triggers

## Customizing the Build

### Change Target Library

```bash
gmake BUILDLIB=MYLIB
```

### Build Specific Object Types

```bash
# Build only display files
gmake display-files

# Build only RPGLE programs
gmake bound-programs
```

### Parallel Builds

Bob supports parallel builds for faster compilation:

```bash
# Build with 4 parallel jobs
gmake -j4
```

## Helper Script: Upload Sources

Create a shell script `upload-sources.sh` to automate copying IFS sources to source physical files:

```bash
#!/bin/bash
# upload-sources.sh - Upload IFS sources to source physical files

LIB=${1:-SAMCO}

echo "Uploading sources to library $LIB..."

# Function to upload sources
upload_sources() {
  local srcdir=$1
  local srcfile=$2
  
  for file in $srcdir/*; do
    if [ -f "$file" ]; then
      member=$(basename "$file" | cut -d. -f1)
      echo "Uploading $member to $srcfile..."
      system "CPYFRMSTMF FROMSTMF('$(pwd)/$file') TOMBR('/QSYS.LIB/$LIB.LIB/$srcfile.FILE/$member.MBR') MBROPT(*REPLACE)" 2>/dev/null
    fi
  done
}

# Upload all source types
upload_sources "SAMCO_SRC/QDDSSRC" "QDDSSRC"
upload_sources "SAMCO_SRC/QRPGLESRC" "QRPGLESRC"
upload_sources "SAMCO_SRC/QRPGSRC" "QRPGSRC"
upload_sources "SAMCO_SRC/QCLSRC" "QCLSRC"
upload_sources "SAMCO_SRC/QCBLSRC" "QCBLSRC"
upload_sources "SAMCO_SRC/QCMDSRC" "QCMDSRC"
upload_sources "SAMCO_SRC/QSRVSRC" "QSRVSRC"
upload_sources "SAMCO_SRC/QBNDSRC" "QBNDSRC"
upload_sources "SAMCO_SRC/QMSGFSRC" "QMSGFSRC"
upload_sources "SAMCO_SRC/QPNLSRC" "QPNLSRC"
upload_sources "SAMCO_SRC/QSQLSRC" "QSQLSRC"
upload_sources "SAMCO_SRC/QDTASRC" "QDTASRC"

echo "Upload complete!"
```

Make it executable and run:
```bash
chmod +x upload-sources.sh
./upload-sources.sh SAMCO
```

## Troubleshooting

### "gmake: command not found"
Install GNU Make:
```bash
yum install make-gnu
```

### "bob: command not found"
Install IBM i Bob:
```bash
yum install ibmi-bob
```

### Compilation Errors
- Check that all source files are properly uploaded to source physical files
- Verify the library exists: `system "DSPLIB LIB(SAMCO)"`
- Check for missing dependencies (e.g., display files must exist before programs that use them)
- Review the compile listing: `system "DSPSPLF"`

### Source Not Found
Ensure source physical files exist and contain the source members:
```bash
system "DSPFD FILE(SAMCO/QRPGLESRC)"
system "DSPPFM FILE(SAMCO/QRPGLESRC)"
```

## CI/CD Integration

The build system can be integrated into CI/CD pipelines. See `azure-pipelines.yml` for an example Azure DevOps pipeline configuration.

### Example CI/CD Steps:
1. Clone repository on IBM i
2. Create/clean build library
3. Upload sources to source physical files
4. Run `gmake` to build
5. Run tests (if applicable)
6. Deploy to production library

## Additional Resources

- [IBM i Bob Documentation](https://github.com/IBM/ibmi-bob)
- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
- [IBM i Open Source](https://ibmi-oss-docs.readthedocs.io/)

## Support

For issues or questions:
- Check the build logs
- Review compilation messages with `DSPSPLF`
- Consult IBM i Bob documentation
- Contact your system administrator