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
    ) external;
}

contract SenderTest {

    address public immutable anycallContract;

    event Send(uint256 message);

    constructor(address _anycallContract) {
        anycallContract = _anycallContract;
    }

    function send(uint256 _message, uint256 _targetChainId, address _targetContractAddress) external {
        emit Send(_message);

        CallProxy(anycallContract).anyCall(
            _targetContractAddress,
            abi.encode(_message),
            address(0), // no fallback
            _targetChainId,
            0
        );
    }
}