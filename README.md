# FirmwareUpdate
The FirmwareUpdate plugin provides an interface for FirmwareUpdate.

## Versions
`org.rdk.FirmwareUpdate.1`

## Methods:
```
curl --req POST --data '{"jsonrpc":"2.0","id":"3","method": "Controller.1.activate", "params": {"callsign":"org.rdk.FirmwareUpdate"}}' http://127.0.0.1:9998/jsonrpc

curl -H 'content-type:text/plain;' --data-binary '{"jsonrpc": 2.0, "id": 0, "method": "org.rdk.FirmwareUpdate.getUpdateState"}' http://127.0.0.1:9998/jsonrpc

curl -H 'content-type:text/plain;' --data-binary '{"jsonrpc": 2.0, "id": 1, "method": "org.rdk.FirmwareUpdate.setAutoReboot", "params": {"enable": true}}' http://127.0.0.1:9998/jsonrpc

curl -H 'content-type:text/plain;' --data-binary '{"jsonrpc": 2.0, "id": 2, "method": "org.rdk.FirmwareUpdate.updateFirmware", "params": {"firmwareFilepath": "", "firmwareType": ""}}' http://127.0.0.1:9998/jsonrpc

```

## Responses:
```
getUpdateState
{
    "jsonrpc": 2.0,
    "id": 0,
    "result": {
        "state": "VALIDATION_FAILED",
        "substate": "NOT_APPLICABLE"
    }
}

setAutoReboot
{
    "jsonrpc": 2.0,
    "id": 1,
    "method": "org.rdk.FirmwareUpdate.setAutoReboot",
    "params": {
        "enable": true
    }
}
updateFirmware
{
    "jsonrpc": 2.0,
    "id": 2,
    "method": "org.rdk.FirmwareUpdate.updateFirmware",
    "params": {
        "firmwareFilepath": "",
        "firmwareType": ""
    }
}
```

## Events
```
onFlashingStateChange

This notification is raised between flashing started state and flashing succeeded/failed.

onUpdateStateChange

notify Firmware update state change.

```
