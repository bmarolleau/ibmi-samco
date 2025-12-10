# IBM i SAMCO Demo Application

Merlin Labs - SAMCO Application git repository

## Overview

SAMCO is a sample IBM i application demonstrating modern development practices including:
- RPG/RPGLE programs
- SQL integration
- Display files and menus
- Service programs
- Modern build automation with Bob (Better Object Builder)

## Quick Start

### Prerequisites

- IBM i system with SSH access
- Bob (Better Object Builder) installed (`yum install tobi`)
- Git (optional, for cloning)

### Building the Application

1. **Clone or upload the repository to your IBM i system:**
   ```bash
   git clone -b demo1 https://github.com/bmarolleau/ibmi-samco.git
   cd ibmi-samco
   ```

2. **Run the setup script:**
   ```bash
   ./setup-build.sh SAMCO
   ```
   This will:
   - Create the SAMCO library
   - Create source physical files
   - Upload IFS sources to source members

3. **Build the application:**
   ```bash
   makei
   ```
   Or build to a different library:
   ```bash
   makei BUILDLIB=SAMCODEV
   ```

### Build Options

```bash
makei              # Build everything
makei database     # Build database objects only
makei programs     # Build programs only
makei help         # Show all available targets
```

## Documentation

- **[BUILD.md](BUILD.md)** - Comprehensive build instructions
- **[Rules.mk](Rules.mk)** - Bob build rules configuration
- **[makefile](makefile)** - Main build script

## Project Structure

```
ibmi-samco/
├── SAMCO_SRC/           # Source code
│   ├── QDDSSRC/         # DDS (files, displays, prints)
│   ├── QRPGLESRC/       # RPGLE programs and modules
│   ├── QRPGSRC/         # RPG programs (fixed format)
│   ├── QCLSRC/          # CL programs
│   ├── QCBLSRC/         # COBOL programs
│   ├── QCMDSRC/         # Commands
│   ├── QSQLSRC/         # SQL objects
│   ├── QSRVSRC/         # Service program binders
│   ├── QBNDSRC/         # Binding directories
│   ├── QMSGFSRC/        # Message files
│   ├── QPNLSRC/         # Panel groups and menus
│   ├── QPROTOSRC/       # Prototypes and copy books
│   ├── QTRGSRC/         # Triggers
│   └── QDTASRC/         # Data areas
├── Rules.mk             # Bob build rules
├── makefile             # Main build script
├── setup-build.sh       # Setup automation script
├── BUILD.md             # Detailed build documentation
├── iproj.json           # Project configuration
└── README.md            # This file
```

## Application Components

### Database
- Physical files (CUSTOMER, ARTICLE, ORDER, etc.)
- Logical files for indexed access
- SQL tables and views
- Triggers for data validation

### Programs
- **Customer Management** (CUS200, CUS250, CUS300, CUS301)
- **Article Management** (ART200, ART201, ART202, ART250, ART300-302)
- **Order Processing** (ORD100-202, ORD500, ORD700, ORD900-901)
- **Provider Management** (PRO200-203, PRO250, PRO300-301)
- **Country Management** (COU200, COU300-301)
- **Parameter Management** (PAR200-201, PAR300)
- **Family Management** (FAM300-301)
- **Logging** (LOG100, LOG300)
- **Date Utilities** (DAT001-002)

### Service Programs
- FARTICLE - Article functions
- FCOUNTRY - Country functions
- FCUSTOMER - Customer functions
- FFAMILLY - Family functions
- FPROVIDER - Provider functions
- FPARAMETER - Parameter functions
- FVAT - VAT functions
- LOG - Logging functions

## Development

### Making Changes

1. Edit source files in the `SAMCO_SRC/` directories
2. Upload changes to IBM i:
   ```bash
   ./setup-build.sh SAMCODEV
   ```
3. Build the changed components:
   ```bash
   gmake BUILDLIB=SAMCODEV
   ```

### CI/CD

The project includes an Azure DevOps pipeline configuration (`azure-pipelines.yml`) that can be extended for automated builds and deployments.

## Troubleshooting

See [BUILD.md](BUILD.md) for detailed troubleshooting information.

Common issues:
- **"makei: command not found"** - Install Bob: `yum install tobi`
- **Compilation errors** - Check source physical files contain the correct source

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]

## Contact

Merlin Labs - SAMCO Application
