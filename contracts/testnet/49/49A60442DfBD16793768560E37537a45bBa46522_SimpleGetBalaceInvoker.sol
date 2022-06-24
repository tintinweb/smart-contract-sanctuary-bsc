// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./BasicAMBInformationReceiver.sol";

contract SimpleGetBalaceInvoker is BasicAMBInformationReceiver {
    mapping(bytes32 => uint256) public response;

    constructor(IHomeAMB _bridge) AMBInformationReceiverStorage(_bridge) {
    }
    
    function requestBalance(address _account) external {
        bytes32 selector = keccak256("eth_getBalance(address)");
        bytes memory data = abi.encode(_account);
        lastMessageId = bridge.requireToGetInformation(selector, data);
        status[lastMessageId] = Status.Pending;
    }

    function onResultReceived(bytes32 _messageId, bytes memory _result) internal override {
        require(_result.length == 32);
        response[_messageId] = abi.decode(_result, (uint256));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./interfaces/IAMBInformationReceiver.sol";
import "./AMBInformationReceiverStorage.sol";

abstract contract BasicAMBInformationReceiver is IAMBInformationReceiver, AMBInformationReceiverStorage {
    function onInformationReceived(bytes32 _messageId, bool _status, bytes memory _result) external override {
        require(msg.sender == address(bridge));
        if (_status) {
            onResultReceived(_messageId, _result);
        }
        status[_messageId] = _status ? Status.Ok : Status.Failed;
    }
    
    function onResultReceived(bytes32 _messageId, bytes memory _result) virtual internal;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IAMBInformationReceiver {
    function onInformationReceived(bytes32 messageId, bool status, bytes calldata result) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./interfaces/IHomeAMB.sol";

contract AMBInformationReceiverStorage {
    IHomeAMB immutable bridge;
    
    enum Status {
        Unknown,
        Pending,
        Ok,
        Failed
    }
    
    mapping(bytes32 => Status) public status;
    bytes32 public lastMessageId;
    
    constructor(IHomeAMB _bridge) {
        bridge = _bridge;
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IHomeAMB {
    function requireToGetInformation(bytes32 _requestSelector, bytes calldata _data) external returns (bytes32);
}