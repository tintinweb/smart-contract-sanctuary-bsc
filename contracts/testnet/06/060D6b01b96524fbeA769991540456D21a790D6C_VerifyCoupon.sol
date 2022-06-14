/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerifyCoupon {

    event CouponClaimed (bytes32 hashedMessage, address claimant, uint timestamp);

    mapping (bytes32 => bool ) claimed;
    address constant admin = 0x24F60a0F0790b2c96b8Efc218c7187941ba3cdfd;//admin address here

    function claimCoupon(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) external {
        require (!claimed[_hashedMessage],"coupon already claimed");
        require (verifyMessage(_hashedMessage, _v, _r, _s),"Invalid signature or incorrect hash");
        claimed[_hashedMessage] = true;
        //your logic for the copon here
        emit CouponClaimed(_hashedMessage, msg.sender, block.timestamp);
    }
    
    function verifyMessage(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer == admin;
    }

    function getHash(string memory str) public pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix,str));
        //return keccak256(abi.encodePacked(prefix, str));
    }

    function getSigner(bytes32 _hashedMessage, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }
}