/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// Team earn contract
contract TeamEarn is Ownable {
    address public owner2;                     // sign address.
    mapping(uint256 => bool) public nonceUsed; // nonce only one.


    constructor(address owner2_) {
        owner2 = owner2_;
    }

    event BackendTransferToken(address token, address user, uint256 amount, uint256 nonce, uint256 canTakedTime);

    // set owner2.
    function setOwner2(address newOwner2) public onlyOwner {
        require(newOwner2 != address(0), "0 address error");
        owner2 = newOwner2;
    }

    // take token.
    function takeToken(address token, address to, uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransfer(token, to, value);
    }

    // sign take token.
    // data: (this contract address, token address, user address, token amount, random nonce, start time).
    function backendTransferToken(address _token,address _to,uint256 _amount,uint256 _nonce,uint256 canTakedTime,bytes memory _signature) public {
        // only myself
        require(msg.sender == _to, "not you");
        require(block.timestamp > canTakedTime, "time not arrived");

        bytes32 hashData = keccak256(abi.encodePacked(address(this),_token,_to,_amount,_nonce,canTakedTime));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashData));
        address signer = recoverSigner(messageHash, _signature);
        require(signer == owner2, "Signer is not owner2");
        require(signer != address(0), "Signer is 0 address");
        require(!nonceUsed[_nonce], "nonce used");
        nonceUsed[_nonce] = true;

        // transfer
        TransferHelper.safeTransfer(_token, _to, _amount);

        // emit
        emit BackendTransferToken(_token, _to, _amount, _nonce, canTakedTime);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}