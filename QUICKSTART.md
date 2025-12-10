# SAMCO Build System - Quick Start Guide

## TL;DR - Get Building Fast

### On IBM i (SSH Session)

```bash
# 1. Clone the repo
git clone https://github.com/bmarolleau/ibmi-samco.git
cd ibmi-samco

# 2. Setup (creates library, uploads sources)
./setup-build.sh SAMCO

# 3. Build everything
gmake

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

2. **Make** (`gmake`):
   - Reads Rules.mk for compilation rules
   - Builds objects in correct dependency order
   - Compiles only what's needed (incremental builds)

## Common Commands

```bash
# Build everything
gmake

# Build to different library
gmake BUILDLIB=SAMCODEV

# Build only database objects
gmake database

# Build only programs
gmake programs

# Build with 4 parallel jobs (faster!)
gmake -j4

# See all available targets
gmake help

# Re-setup after source changes
./setup-build.sh SAMCO
gmake
```

## Build Targets Explained

| Target | What It Builds |
|--------|----------------|
| `all` | Everything (default) |
| `database` | Files, tables, views |
| `programs` | All programs and service programs |
| `physical-files` | Physical files only |
| `logical-files` | Logical files only |
| `display-files` | Display files only |
| `modules` | RPGLE modules only |
| `service-programs` | Service programs only |
| `bound-programs` | Bound programs only |
| `sql-objects` | SQL tables, views, procedures |

## Typical Workflows

### Initial Setup
```bash
./setup-build.sh SAMCO
gmake
```

### After Changing a Program
```bash
# Option 1: Re-upload and rebuild everything
./setup-build.sh SAMCO
gmake

# Option 2: Upload just the changed file
system "CPYFRMSTMF FROMSTMF('SAMCO_SRC/QRPGLESRC/COU200.PGM.RPGLE') \
        TOMBR('/QSYS.LIB/SAMCO.LIB/QRPGLESRC.FILE/COU200.MBR') \
        MBROPT(*REPLACE)"
gmake SAMCO_SRC/QRPGLESRC/COU200.PGM.RPGLE
```

### Development vs Production
```bash
# Development
./setup-build.sh SAMCODEV
gmake BUILDLIB=SAMCODEV

# Production
./setup-build.sh SAMCO
gmake BUILDLIB=SAMCO
```

### Clean Build
```bash
# Delete library and rebuild from scratch
system "DLTLIB LIB(SAMCO)"
./setup-build.sh SAMCO
gmake
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

### "gmake: command not found"
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

### Build Specific File
```bash
# Build just one program
gmake SAMCO_SRC/QRPGLESRC/COU200.PGM.RPGLE

# Build just one display file
gmake SAMCO_SRC/QDDSSRC/COU200D.DSPF
```

### Parallel Builds
```bash
# Use 8 parallel jobs for faster builds
gmake -j8
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
4. Run `./setup-build.sh` and `gmake`

## CI/CD Integration

The build system works great in CI/CD pipelines:

```yaml
# Example Azure DevOps pipeline
steps:
- script: |
    ssh ibmiuser@youribmi "cd /home/ibmiuser/ibmi-samco && \
                           ./setup-build.sh SAMCODEV && \
                           gmake BUILDLIB=SAMCODEV"
  displayName: 'Build on IBM i'
```

## Next Steps

- Read [BUILD.md](BUILD.md) for comprehensive documentation
- Explore [Rules.mk](Rules.mk) to understand compilation rules
- Check [makefile](makefile) to see build targets
- Customize for your environment

## Getting Help

1. Run `gmake help` to see all targets
2. Check [BUILD.md](BUILD.md) for detailed troubleshooting
3. Review IBM i Bob documentation: https://github.com/IBM/ibmi-bob
4. Check compilation messages: `system "DSPSPLF"`

---

**Happy Building! 🚀**