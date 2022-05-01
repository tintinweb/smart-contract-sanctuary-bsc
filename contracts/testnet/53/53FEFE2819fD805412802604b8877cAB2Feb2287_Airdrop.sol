/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SignTool {
    function genMsg(
        address _address,
        uint256 _amount,
        uint256 _deadline,
        uint256 _nonce
    ) internal pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(_address, _amount, _deadline, _nonce));
    }

    function check(
        address _address,
        uint256 _amount,
        uint256 _deadline,
        uint256 _nonce,
        bytes memory _sig
    ) internal pure returns (address) {
        return
            recoverSigner(genMsg(_address, _amount, _deadline, _nonce), _sig);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8,
            bytes32,
            bytes32
        )
    {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
    address owner;
    address tokenAddress;
    mapping(address => uint256) public nonces;

    constructor(address _owner,address _tokenAddress) {
        owner = _owner;
        tokenAddress = _tokenAddress;
    }

    event RewardPaid(address indexed user, uint256 indexed amount);

    function getReward(
        uint256 _amount,
        uint256 _deadline,
        bytes memory _sig
    ) external {
        require(block.timestamp < _deadline, "Time out");
        address sigUser = SignTool.check(
            msg.sender,
            _amount,
            _deadline,
            nonces[msg.sender],
            _sig
        );
        require(sigUser == owner, "Authorization error");

        nonces[msg.sender]++;
        // IERC20(tokenAddress).transfer(msg.sender, _amount);

        emit RewardPaid(msg.sender, _amount);
    }
}