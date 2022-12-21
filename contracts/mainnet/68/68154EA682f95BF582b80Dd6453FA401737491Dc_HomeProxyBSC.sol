/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAMB {
    function requireToPassMessage(
        address _contract,
        bytes memory _data,
        uint256 _gas
    ) external returns (bytes32);

    function maxGasPerTx() external view returns (uint256);

    function messageSender() external view returns (address);

    function messageSourceChainId() external view returns (bytes32);

    function messageId() external view returns (bytes32);
}

interface IHomeProxy {
  
    function receiveArbitrationRequest() external;

    function handleNotifiedRequest() external;
}

interface IForeignProxy {

    function requestArbitration() external;

    function receiveArbitrationAcknowledgement() external;
}

contract HomeProxyBSC is IHomeProxy {
    enum Status {
        None,
        Received,
        Relayed
    }

    IAMB public immutable amb;
    address public foreignProxy;
    bytes32 public immutable foreignChainId;
    Status public status;

    /* Modifiers */

    modifier onlyForeignProxy() {
        require(msg.sender == address(amb), "Only AMB allowed");
        require(amb.messageSourceChainId() == foreignChainId, "Only foreign chain allowed");
        require(amb.messageSender() == foreignProxy, "Only foreign proxy allowed");
        _;
    }

    constructor(
        IAMB _amb,
        uint256 _foreignChainId
    ) {
        amb = _amb;
        foreignChainId = bytes32(_foreignChainId);
    }

    function receiveArbitrationRequest() external override onlyForeignProxy {
        status = Status.Received;
    }

    function handleNotifiedRequest() external override {
        bytes4 selector = IForeignProxy.receiveArbitrationAcknowledgement.selector;
        bytes memory data = abi.encodeWithSelector(selector);
        amb.requireToPassMessage(foreignProxy, data, amb.maxGasPerTx());

        status = Status.Relayed;
    }

    function setDefault() external {
        status = Status.None;
    }

    function setForeignProxy(address _foreignProxy) external {
        foreignProxy = _foreignProxy;
    }
}