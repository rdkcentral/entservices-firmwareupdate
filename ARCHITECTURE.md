# FirmwareUpdate Plugin Architecture

## Overview

The FirmwareUpdate plugin is built on the WPEFramework (Thunder) platform, providing secure and reliable firmware update capabilities for RDK devices. The architecture follows a modular design with clear separation between plugin interfaces, implementation logic, and system integration.

## System Architecture

### High-Level Components

```
┌─────────────────────────────────────────────────────────────┐
│                    WPEFramework Controller                   │
├─────────────────────────────────────────────────────────────┤
│                    JSON-RPC Interface                       │
├─────────────────────────────────────────────────────────────┤
│  FirmwareUpdate Plugin (org.rdk.FirmwareUpdate)            │
│  ┌───────────────┐    ┌─────────────────────────────────┐   │
│  │ Plugin Proxy  │    │   Implementation (Out-of-Proc)  │   │
│  │ - Registration│    │   - Business Logic              │   │
│  │ - Interface   │◄──►│   - System Integration          │   │
│  │ - Events      │    │   - IARM Communication          │   │
│  └───────────────┘    └─────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                    Helper Utilities                         │
│  ┌─────────────┐ ┌──────────────┐ ┌─────────────────────┐   │
│  │ Utils::IARM │ │ Utils::File  │ │ Utils::JsonRPC      │   │
│  └─────────────┘ └──────────────┘ └─────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                   System Integration                        │
│  ┌─────────────┐ ┌──────────────┐ ┌─────────────────────┐   │
│  │ IARM Bus    │ │ Device Props │ │ Maintenance MGR     │   │
│  └─────────────┘ └──────────────┘ └─────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. Plugin Interface Layer (`FirmwareUpdate.h/cpp`)
- **Purpose**: Thunder framework plugin registration and JSON-RPC interface
- **Key Features**:
  - Implements `PluginHost::IPlugin` for lifecycle management
  - Provides JSON-RPC endpoint `org.rdk.FirmwareUpdate`
  - Handles client connections and notifications
  - Version: 1.0.0 (Major.Minor.Patch)

#### 2. Implementation Layer (`FirmwareUpdateImplementation.h/cpp`)
- **Purpose**: Core business logic and system integration
- **Key Features**:
  - Implements `Exchange::IFirmwareUpdate` interface
  - Thread-safe firmware update operations
  - Progress monitoring and state management
  - IARM bus integration for system events

#### 3. Helper Utilities (`helpers/`)
- **UtilsLogging.h**: Standardized logging with thread ID tracking
- **UtilsIarm.h**: IARM bus initialization and communication
- **UtilsJsonRpc.h**: JSON-RPC response handling utilities
- **UtilsFile.h**: File system operations and validation
- **UtilsController.h**: Controller interface utilities

## Plugin Architecture Patterns

### 1. Interface-Implementation Separation
```cpp
// Plugin acts as a proxy
class FirmwareUpdate : public PluginHost::IPlugin {
    Exchange::IFirmwareUpdate* _firmwareUpdate; // Out-of-process impl
};

// Implementation contains business logic
class FirmwareUpdateImplementation : public Exchange::IFirmwareUpdate {
    // Core functionality
};
```

### 2. Event-Driven Architecture
- **Notification System**: Implements observer pattern for state changes
- **Event Types**:
  - `OnUpdateStateChange`: Firmware update state transitions
  - `OnFlashingStateChange`: Progress updates during flashing

### 3. Thread-Safe Operations
- **Atomic Operations**: `std::atomic<bool>` for flash state tracking
- **Mutex Protection**: `std::mutex` for critical sections
- **Thread Management**: Dedicated flash thread for non-blocking operations

## Data Flow

### Firmware Update Process
```
Client Request → JSON-RPC → Plugin → Implementation → System
     ↓
State Events ← Notifications ← Progress Monitor ← Flash Thread
```

1. **Request Handling**: JSON-RPC calls routed to implementation
2. **Validation**: Firmware path and type validation
3. **Flash Thread**: Asynchronous flashing with progress updates
4. **State Management**: Atomic state tracking and notifications
5. **Event Broadcasting**: State changes sent to registered clients

## Integration Points

### System Services Integration
- **IARM Bus**: Inter-process communication with system services
- **System Manager**: Device state management and reboot coordination
- **Maintenance Manager**: Update scheduling and maintenance windows
- **Device Properties**: Hardware configuration and capabilities

### File System Integration
- **Configuration Files**: `/etc/device.properties`, `/etc/include.properties`
- **Status Files**: `/tmp/FirmwareUpdateStatus.txt`, `/opt/fwdnldstatus.txt`
- **Temporary Storage**: `/tmp/USBCopy` for firmware staging

## Build System Architecture

### CMake Structure
- **Root CMakeLists.txt**: Main build configuration with plugin option
- **Plugin CMakeLists.txt**: Plugin-specific build rules
- **Dependencies**: WPEFramework plugins, IARM bus, device services

### Configuration Management
```cmake
if(PLUGIN_FIRMWAREUPDATE)
    add_subdirectory(plugin)
endif()
```

### Namespace Compliance
Uses `${NAMESPACE}` variable for framework independence:
```cmake
find_package(${NAMESPACE}Plugins REQUIRED)
target_link_libraries(${MODULE_NAME} PRIVATE ${NAMESPACE}Plugins::${NAMESPACE}Plugins)
```

## Security Considerations

### Access Control
- **Security Token**: Optional token-based authentication (can be disabled via `DISABLE_SECURITY_TOKEN`)
- **File Permissions**: Secure handling of firmware files and temporary storage
- **Process Isolation**: Out-of-process implementation for security boundaries

### State Validation
- **Atomic State Management**: Prevents race conditions during updates
- **Progress Validation**: Ensures update integrity throughout process
- **Error Handling**: Comprehensive error states and recovery mechanisms

## Testing Architecture

### Multi-Level Testing
- **L1 Tests**: Unit tests for core functionality (`Tests/L1Tests/`)
- **L2 Tests**: Integration tests with system components (`Tests/L2Tests/`)
- **Mock Framework**: Comprehensive mocking for system dependencies

### Test Coverage
- Firmware update scenarios (success/failure paths)
- State management and notifications
- File system operations and validation
- IARM bus communication

## Extensibility

### Plugin Framework Benefits
- **Hot-pluggable**: Can be enabled/disabled via build configuration
- **Version Management**: Semantic versioning with API compatibility
- **Configuration Driven**: Runtime behavior controlled via `.conf` files
- **Interface Abstraction**: Clean separation between interface and implementation

This architecture ensures maintainability, testability, and secure firmware update operations while leveraging the full capabilities of the WPEFramework ecosystem.