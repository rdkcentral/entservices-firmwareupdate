# RDK Services - Firmware Update

This repository contains the **FirmwareUpdate** plugin for RDK (Reference Design Kit) devices, providing firmware update capabilities through the Thunder/WPEFramework plugin architecture.

## Overview

The FirmwareUpdate plugin enables:
- Firmware update operations on RDK devices
- Integration with device settings (DS) and IARM Bus (optional)
- RESTful JSON-RPC API for firmware management

## Repository Structure

```
entservices-firmwareupdate/
├── FirmwareUpdate/          # FirmwareUpdate plugin source
├── helpers/                 # Shared utility functions
├── Tests/
│   ├── L1Tests/            # Unit tests
│   └── L2Tests/            # Integration tests
├── cmake/                   # CMake find modules
├── .github/workflows/       # CI/CD workflows
└── CMakeLists.txt          # Root build configuration
```

## Building

### Prerequisites

- CMake 3.16 or higher
- Thunder/WPEFramework (R4.4.1 or compatible)
- C++11 compatible compiler
- Optional: DeviceSettings (DS), IARMBus libraries

### Build Instructions

```bash
# Configure
cmake -S . -B build \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DPLUGIN_FIRMWAREUPDATE=ON \
  -DDS_FOUND=ON

# Build
cmake --build build -j$(nproc)

# Install
cmake --install build
```

### Build Options

- `PLUGIN_FIRMWAREUPDATE=ON` - Enable FirmwareUpdate plugin (default: ON)
- `DS_FOUND=ON` - Enable DeviceSettings integration (optional)
- `RDK_SERVICES_L1_TEST=ON` - Build L1 unit tests
- `RDK_SERVICE_L2_TEST=ON` - Build L2 integration tests
- `COMCAST_CONFIG=ON` - Enable Comcast-specific configurations

## Testing

### Running L1 Tests (Unit Tests)

```bash
cmake -S . -B build \
  -DRDK_SERVICES_L1_TEST=ON \
  -DPLUGIN_FIRMWAREUPDATE=ON

cmake --build build
ctest --test-dir build --output-on-failure
```

### Running L2 Tests (Integration Tests)

```bash
cmake -S . -B build \
  -DRDK_SERVICE_L2_TEST=ON \
  -DPLUGIN_FIRMWAREUPDATE=ON

cmake --build build
ctest --test-dir build --output-on-failure
```

## Integration

### Yocto/OpenEmbedded

To integrate into your Yocto build:

```bitbake
# In your recipe or layer
SRC_URI = "git://github.com/rdkcentral/entservices-firmwareupdate.git;protocol=https;branch=develop"

inherit cmake

DEPENDS = "wpeframework wpeframework-plugins"

EXTRA_OECMAKE += " \
    -DPLUGIN_FIRMWAREUPDATE=ON \
    -DCMAKE_BUILD_TYPE=Release \
"
```

## CI/CD

This repository includes GitHub Actions workflows for:
- **L1 Tests**: Unit test execution with coverage
- **L2 Tests**: Integration test execution
- **Coverity**: Static code analysis
- **Native Build**: Full build validation

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- GitHub Issues: https://github.com/rdkcentral/entservices-firmwareupdate/issues
- RDK Central: https://rdkcentral.com/
