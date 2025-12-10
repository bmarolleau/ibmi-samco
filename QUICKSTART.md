# SAMCO Build System - Quick Start Guide

## TL;DR - Get Building Fast

### On IBM i (SSH Session)

```bash
# 1. Clone the repo
git clone -b demo1 https://github.com/bmarolleau/ibmi-samco.git
cd ibmi-samco

# 2. Setup (creates library, uploads sources)
./setup-build.sh SAMCO

# 3. Build everything
makei build

# Done! Your application is compiled in library SAMCO
```

## What Just Happened?

The build system uses **IBM i Bob** (Better Object Builder) - a modern make-based build tool for IBM i.

### Files Created

- **Rules.mk** - Defines how to compile each object type (PF, RPGLE, DSPF, etc.)
- **makefile** - Orchestrates the build process and dependencies
- **setup-build.sh** - Automates library setup and source upload

### Build Process

1. **Setup script** (`setup-build.sh`):
   - Creates library (e.g., SAMCO)
   - Creates source physical files (QRPGLESRC, QDDSSRC, etc.)
   - Copies IFS sources to source members

2. **Make** (`makei`):
   - Reads Rules.mk for compilation rules
   - Builds objects in correct dependency order
   - Compiles only what's needed (incremental builds)

## Common Commands

```bash
# Build everything
makei build

# Build to different library
makei build BIN_LIB=SAMCODEV

# Compile specific file
makei compile -f qrpglesrc/COU200.PGM.RPGLE

# Build with 4 parallel jobs (faster!)
makei build -j4

# Re-setup after source changes
./setup-build.sh SAMCO
makei build
```

## Build Targets Explained

| Command | What It Does |
|---------|--------------|
| `makei build` | Build everything (default) |
| `makei build BIN_LIB=MYLIB` | Build to specific library |
| `makei compile -f <file>` | Compile specific file |
| `makei build -j4` | Build with 4 parallel jobs |

## Typical Workflows

### Initial Setup
```bash
./setup-build.sh SAMCO
makei
```

### After Changing a Program
```bash
# Option 1: Re-upload and rebuild everything
./setup-build.sh SAMCO
makei build

# Option 2: Upload just the changed file and compile it
system "CPYFRMSTMF FROMSTMF('SAMCO_SRC/QRPGLESRC/COU200.PGM.RPGLE') \
        TOMBR('/QSYS.LIB/SAMCO.LIB/QRPGLESRC.FILE/COU200.MBR') \
        MBROPT(*REPLACE)"
makei compile -f qrpglesrc/COU200.PGM.RPGLE
```

### Development vs Production
```bash
# Development
./setup-build.sh SAMCODEV
makei build BIN_LIB=SAMCODEV

# Production
./setup-build.sh SAMCO
makei build BIN_LIB=SAMCO
```

### Clean Build
```bash
# Delete library and rebuild from scratch
system "DLTLIB LIB(SAMCO)"
./setup-build.sh SAMCO
makei build
```

## Understanding the Build Order

Bob automatically builds in the correct order:

```
1. Binding Directories (needed by service programs)
2. Message Files
3. Data Areas
4. Physical Files (base tables)
5. Logical Files (indexes, views over PFs)
6. Display Files (screens)
7. Print Files (reports)
8. SQL Objects (tables, views, procedures)
9. Modules (building blocks for service programs)
10. Service Programs (reusable code libraries)
11. Programs (main executables)
12. Commands
13. Menus
14. Triggers
```

## Troubleshooting

### "makei: command not found"
```bash
yum install make-gnu
```

### "bob: command not found"
```bash
yum install ibmi-bob
```

### "Source member not found"
```bash
# Re-run setup to upload sources
./setup-build.sh SAMCO

# Verify sources uploaded
system "DSPPFM FILE(SAMCO/QRPGLESRC)"
```

### Compilation Error
```bash
# View the compile listing
system "DSPSPLF"

# Check specific object
system "DSPJOBLOG"
```

### "Library not found"
```bash
# Create the library
system "CRTLIB LIB(SAMCO) TEXT('SAMCO Application')"

# Or re-run setup
./setup-build.sh SAMCO
```

## Advanced Usage

### Compile Specific File
```bash
# Compile just one program
makei compile -f qrpglesrc/COU200.PGM.RPGLE

# Compile just one display file
makei compile -f qddssrc/COU200D.DSPF
```

### Parallel Builds
```bash
# Use 8 parallel jobs for faster builds
makei build -j8
```

### Custom Include Paths
Edit `Rules.mk` to add more include directories:
```makefile
INCLUDES := SAMCO_SRC/QPROTOSRC:SAMCO_SRC/QCOPYSRC
```

### Debug Builds
The build system already includes `DBGVIEW(*SOURCE)` for all programs.

### Override Compile Options
Edit the specific rule in `Rules.mk`, for example:
```makefile
SAMCO_SRC/QRPGLESRC/%.PGM.RPGLE: SAMCO_SRC/QRPGLESRC/%.PGM.RPGLE
	system "CRTBNDRPG PGM($(OBJLIB)/$*) SRCFILE($(BUILDLIB)/QRPGLESRC) \
	        SRCMBR($*) OPTION(*EVENTF) DBGVIEW(*LIST) OPTIMIZE(*FULL) \
	        INCDIR('$(INCLUDES)')"
```

## Integration with VS Code

If using Code for IBM i extension:

1. Upload project to IFS using "Upload to IFS"
2. Open SSH terminal in VS Code
3. Navigate to project directory
4. Run `./setup-build.sh` and `makei`

## CI/CD Integration

The build system works great in CI/CD pipelines:

```yaml
# Example Azure DevOps pipeline
steps:
- script: |
    ssh ibmiuser@youribmi "cd /home/ibmiuser/ibmi-samco && \
                           ./setup-build.sh SAMCODEV && \
                           makei BUILDLIB=SAMCODEV"
  displayName: 'Build on IBM i'
```

## Next Steps

- Read [BUILD.md](BUILD.md) for comprehensive documentation
- Explore [Rules.mk](Rules.mk) to understand compilation rules
- Check [makefile](makefile) to see build targets
- Customize for your environment

## Getting Help

1. Check [BUILD.md](BUILD.md) for detailed troubleshooting
2. Review Bob documentation: https://github.com/IBM/ibmi-bob
3. Check compilation messages: `system "DSPSPLF"`
4. View build logs in `.logs/` directory

---

**Happy Building! 🚀**