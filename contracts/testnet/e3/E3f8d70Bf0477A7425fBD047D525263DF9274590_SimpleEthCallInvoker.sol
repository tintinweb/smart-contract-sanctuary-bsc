// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./interfaces/IERC20.sol";
import "./BasicAMBInformationReceiver.sol";

contract SimpleEthCallInvoker is BasicAMBInformationReceiver {
    mapping(bytes32 => uint256) public response;

    constructor(IHomeAMB _bridge) AMBInformationReceiverStorage(_bridge) {
    }
    
    function sendRemoteEthCall(bytes memory _data) internal {
        bytes32 selector = keccak256("eth_call(address,bytes)");
        lastMessageId = bridge.requireToGetInformation(selector, _data);
        status[lastMessageId] = Status.Pending;
    }
    
    function requestTotalSupply(IERC20 _ctoken) external {
        bytes memory method = abi.encodeWithSelector(IERC20(address(0)).totalSupply.selector);
        bytes memory data = abi.encode(_ctoken, method);
        sendRemoteEthCall(data);
    }

    function requestBalanceOf(IERC20 _ctoken, address _owner) external {
        bytes memory method = abi.encodeWithSelector(IERC20(address(0)).balanceOf.selector, _owner);
        bytes memory data = abi.encode(_ctoken, method);
        sendRemoteEthCall(data);
    }
    
    function unwrap(bytes memory _result) pure internal returns(bytes memory unwrapped_response) {
        unwrapped_response = abi.decode(_result, (bytes));
    }
    
    function onResultReceived(bytes32 _messageId, bytes memory _result) internal override {
        bytes memory unwrapped = unwrap(_result);
        require(unwrapped.length == 32);
        response[_messageId] = abi.decode(unwrapped, (uint256));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

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
pragma solidity ^0.8.2;

interface IAMBInformationReceiver {
    function onInformationReceived(bytes32 messageId, bool status, bytes calldata result) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

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
pragma solidity ^0.8.2;

interface IHomeAMB {
    function requireToGetInformation(bytes32 _requestSelector, bytes calldata _data) external returns (bytes32);
}