# FirmwareUpdate Plugin Architecture

## Overview
The FirmwareUpdate plugin is a C++ implementation built on the WPEFramework (Thunder) platform that provides secure, reliable firmware update capabilities for RDK-based devices. It follows a layered architecture with clear separation of concerns between the plugin interface, business logic implementation, and system interaction layers.

## System Architecture

### Core Components

#### 1. Plugin Layer (`FirmwareUpdate.h/cpp`)
- **Purpose**: Thunder plugin interface and entry point
- **Responsibilities**:
  - Plugin lifecycle management (Initialize, Deinitialize)
  - JSON-RPC method registration and routing (`updateFirmware`, `getUpdateState`, `setAutoReboot`)
  - Event notification handling (`onUpdateStateChange`, `onFlashingStateChange`)
  - Interface aggregation between Thunder framework and implementation
  - Error handling and JSON-RPC error assessment
- **Key Classes**:
  - `FirmwareUpdate`: Main plugin class implementing `IPlugin` and JSON-RPC interfaces
  - `Notification`: Handles notifications for state changes and progress updates

#### 2. Implementation Layer (`FirmwareUpdateImplementation.h/cpp`)
- **Purpose**: Core business logic and firmware update operations
- **Responsibilities**:
  - Firmware validation and integrity checking
  - Multi-threaded firmware flashing operations
  - State machine management (validation, flashing, completion states)
  - IARM (Inter-Application Resource Manager) integration
  - RFC (Remote Feature Control) parameter management
  - System integration for firmware installation and device management
- **Key Classes**:
  - `FirmwareUpdateImplementation`: Main implementation of `IFirmwareUpdate` interface
  - `Job`: Dispatch mechanism for asynchronous operations and event handling

#### 3. Module Layer (`Module.h/cpp`)
- **Purpose**: Plugin module definition and Thunder integration
- **Responsibilities**:
  - Module registration with Thunder framework
  - Plugin metadata and versioning
  - Build system integration and dependency management

#### 4. Helper Utilities (`helpers/`)
- **Purpose**: Reusable utility components and abstractions
- **Components**:
  - `UtilsController.h`: Thunder plugin communication utilities
  - `UtilsLogging.h`: Standardized logging framework with thread-safe operations
  - `UtilsFile.h`: File system operations and integrity checks
  - `UtilsIarm.h`: IARM bus communication for device management
  - `UtilsJsonRpc.h`: JSON-RPC helper functions and parameter validation
  - `PluginInterfaceBuilder.h`: Interface creation and management

## Architecture Patterns

### Layered Architecture
The system follows a three-tier architecture:
1. **Presentation Layer**: JSON-RPC interface for external communication
2. **Business Logic Layer**: Core firmware update operations and state management
3. **Data Access Layer**: File system operations, device interaction, and configuration management

### State Machine Pattern
The firmware update process follows a well-defined state machine:
- **VALIDATION_FAILED** → **FLASHING_STARTED** → **FLASHING_SUCCEEDED/FLASHING_FAILED** → **WAITING_FOR_REBOOT**
- Comprehensive sub-state tracking for detailed error reporting and diagnostics

### Observer Pattern
Event-driven architecture for real-time status updates:
- State change notifications for monitoring systems
- Progress tracking during firmware installation
- Asynchronous event dispatch to prevent blocking operations

### Singleton Pattern
Centralized implementation instance management:
- Single point of access for firmware update operations
- Thread-safe instance management
- Resource sharing across multiple client connections

## Interface Architecture

### JSON-RPC Interface
**Endpoint**: `org.rdk.FirmwareUpdate`
**Methods**:
- `getUpdateState()`: Returns current firmware update status and sub-state
- `updateFirmware(firmwareFilepath, firmwareType)`: Initiates firmware update process
- `setAutoReboot(enable)`: Configures automatic reboot behavior

**Events**:
- `onUpdateStateChange(state, substate)`: Broadcast state transitions
- `onFlashingStateChange(percentageComplete)`: Real-time progress updates

### Thunder Framework Integration
- **IPlugin Interface**: Standard Thunder plugin lifecycle
- **IDispatcher Interface**: JSON-RPC method routing and parameter validation
- **IFirmwareUpdate Interface**: Core firmware update contract
- **IConfiguration Interface**: Plugin configuration management

## Security Architecture

### Validation Framework
- Pre-installation firmware integrity verification
- Compatibility checks against device specifications
- Secure file path validation to prevent directory traversal attacks

### Access Control
- Thunder framework security token integration
- Role-based access control for firmware update operations
- Secure communication channels for remote firmware delivery

## Threading Model

### Asynchronous Operations
- Background firmware download and installation
- Non-blocking JSON-RPC interface
- Progress monitoring through dedicated timer threads

### Thread Safety
- Mutex-protected critical sections for state management
- Atomic operations for progress tracking
- Thread-safe logging infrastructure

## Integration Points

### IARM Bus Integration
- Device property retrieval (device type, name, model)
- System state management and reboot coordination
- Cross-component communication for unified device management

### RFC System Integration
- Persistent configuration storage
- Remote parameter management
- Feature flag control for automatic reboot behavior

### System Integration
- Flash utility integration for low-level firmware writing
- Reboot coordination with system services
- Error reporting and diagnostic information collection

## Build and Deployment Architecture

### CMake Build System
- Modular component building with dependency management
- Cross-platform compatibility for various RDK device types
- Integrated testing framework for L1/L2 validation

### Plugin Configuration
- Dynamic plugin loading through Thunder framework
- Runtime configuration through JSON configuration files
- Environment-specific parameter injection during build

This architecture ensures scalability, maintainability, and reliability while providing a robust foundation for firmware update operations across diverse RDK device ecosystems.

### Thunder Framework Integration
```
Thunder Framework
       ↓
   IPlugin Interface ← FirmwareUpdate (Plugin Layer)
       ↓
   IFirmwareUpdate ← FirmwareUpdateImplementation (Business Logic)
       ↓
   System APIs (IARM, File System, Threading)
```

### API Interfaces
- **IFirmwareUpdate**: Core firmware update operations
- **IConfiguration**: Plugin configuration management
- **INotification**: Event notification system
- **JSON-RPC**: RESTful API endpoints

## Threading Model

### Asynchronous Operations
- **Main Thread**: Handles JSON-RPC requests and plugin lifecycle
- **Flash Thread**: Dedicated thread for firmware flashing operations (`flashThread`)
- **Dispatch System**: Event dispatching using Thunder's worker pool pattern
- **Thread Safety**: Mutex-based synchronization (`flashMutex`, `_adminLock`)

### State Management
- **Atomic Operations**: Thread-safe state tracking (`isFlashingInProgress`)
- **Event Dispatching**: Asynchronous notification system for state changes
- **Progress Tracking**: Real-time progress updates during firmware operations

## Data Flow

### Firmware Update Process
1. **Request Validation**: JSON-RPC endpoint validates parameters
2. **State Check**: Verify system readiness for firmware update
3. **Firmware Validation**: Check firmware file integrity and compatibility
4. **Asynchronous Execution**: Launch dedicated thread for flashing operation
5. **Progress Notifications**: Real-time updates via event system
6. **Completion Handling**: Final state updates and cleanup

### Event System
```
Implementation Layer → Job Dispatch → Thunder Framework → Client Notifications
```

## Configuration Management

### Plugin Configuration
- **Static Configuration**: Build-time settings via CMake (`FirmwareUpdate.config`)
- **Runtime Configuration**: Dynamic configuration through `IConfiguration` interface
- **Environment Variables**: System-level configuration options

### Dependency Management
- **CMake Build System**: Dependency resolution and build orchestration
- **Thunder Framework**: Core platform dependency
- **System Libraries**: IARM, threading, file system APIs

## Error Handling

### Error Propagation
- **JSON-RPC Errors**: Standardized error codes and messages
- **Internal Errors**: Comprehensive logging and error state management
- **Recovery Mechanisms**: Graceful handling of failure scenarios
- **Validation Layers**: Multi-level parameter and state validation

### Logging Framework
- **Structured Logging**: File, function, and line number tracking
- **Log Levels**: INFO, WARN, ERROR categories
- **Thread-Safe**: Multi-threaded logging support
- **System Integration**: Integration with system logging facilities

## Security Considerations

### Access Control
- **Plugin Activation**: Thunder framework security token validation
- **API Access**: Controlled access to firmware update operations
- **File System**: Secure handling of firmware files and temporary data

### Validation
- **Parameter Validation**: Comprehensive input validation for all APIs
- **Firmware Integrity**: Signature verification and compatibility checks
- **State Validation**: Secure state transitions and operation sequencing

## Testing Architecture

### Test Structure
- **L1 Tests**: Unit tests for individual components and methods
- **L2 Tests**: Integration tests for complete workflows
- **Mock Framework**: Comprehensive mocking for Thunder framework components
- **Test Utilities**: Shared test infrastructure and helper functions

### Test Coverage
- **API Testing**: All JSON-RPC methods and error conditions
- **Threading Tests**: Concurrent operation validation
- **State Machine Tests**: All state transitions and edge cases
- **Error Handling**: Exception and error path validation