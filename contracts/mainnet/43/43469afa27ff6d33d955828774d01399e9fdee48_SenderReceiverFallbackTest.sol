/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

interface CallProxy {
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags
    ) external payable;

    function executor() external view returns (Executor executor);
}

interface Executor {
    function context() external view returns (address from, uint256 fromChainID, uint256 nonce);
}

contract SenderReceiverFallbackTest {

    address public immutable owner;
    address public immutable anycallContract;
    Executor public immutable executor;

    event Send(uint256 message, uint256 targetChainId, address targetContractAddress);
    event AnyExecuteContext(address from, uint256 fromChainID);
    event AnyFallbackContext(address from, uint256 fromChainID);
    event MessageReceived(uint256 message);
    event MessageFallback(address to, uint256 message);

    constructor(address _anycallContract) {
        owner = msg.sender;
        anycallContract = _anycallContract;
        executor = CallProxy(_anycallContract).executor();
    }

    function send(uint256 _message, uint256 _targetChainId, address _targetContractAddress) external payable {
        require(msg.sender == owner);

        emit Send(_message, _targetChainId, _targetContractAddress);

        bytes memory data = abi.encodeWithSelector(
            this.anyExecute.selector,
            _message
        );

        CallProxy(anycallContract).anyCall{value: msg.value}(
            _targetContractAddress,
            data,
            address(0), // no fallback
            _targetChainId,
            2 // fees paid on source chain
        );
    }

    function anyExecute(bytes calldata _data) external returns (bool success, bytes memory result) {
        require(
            msg.sender == anycallContract,
            "msg-sender"
        );

        bytes4 selector = bytes4(_data[:4]);

        if (selector == this.anyExecute.selector) {
            return _handleAnyExecute(_data[4:]);
        } else if (selector == this.anyFallback.selector) {
            (address fallbackTo, bytes memory fallbackData) = abi.decode(_data[4:], (address, bytes));

            this.anyFallback(fallbackTo, fallbackData);

            return (true, "");
        } else {
            return (false, "unknown selector");
        }
    }

    function anyFallback(address to, bytes calldata data) external {
        require(msg.sender == address(this), "AnycallClient: Must call from within this contract");

        require(bytes4(data[:4]) == this.anyExecute.selector, "AnycallClient: wrong fallback data");

        (address from, uint256 fromChainID, ) = executor.context();

        emit AnyFallbackContext(from, fromChainID);

        require(from == address(this), "AnycallClient: wrong context");

        (
            uint256 message
        ) = abi.decode(
            data[4:],
            (uint256)
        );

        emit MessageFallback(to, message);
    }

    function _handleAnyExecute(bytes calldata _data) private returns (bool success, bytes memory result) {
        (address from, uint256 fromChainID, ) = executor.context();

        emit AnyExecuteContext(from, fromChainID);

        (uint256 message) = abi.decode(_data, (uint256));

        emit MessageReceived(message);

        require(
            message != 101,
            "fail-on-purpose-require"
        );

        assert(message != 102);

        if (message == 103) {
            return (false, "fail-on-purpose-return");
        }

        return (true, "");
    }

    function cleanup() external {
        require(msg.sender == owner);

        payable(msg.sender).transfer(address(this).balance);
    }
}