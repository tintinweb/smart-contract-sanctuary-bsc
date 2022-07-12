/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

pragma solidity 0.6.12;


// SPDX-License-Identifier: MIT
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Random {
    function draw4Digits(uint tokenId, uint256 _externalRandomNumber) external view returns (uint8[4] memory) {
        uint8 _maxNumber = 13; // random from 0 to 13
        bytes32 _blockhash = blockhash(block.number - 1);

        return [
            uint8(SafeMath.add(SafeMath.mod(uint256(keccak256(abi.encode(_blockhash, msg.sender , tokenId, _externalRandomNumber))),_maxNumber),1)),
            uint8(SafeMath.add(SafeMath.mod(uint256(keccak256(abi.encode(_blockhash, block.number, tokenId, _externalRandomNumber))),_maxNumber),1)),
            uint8(SafeMath.add(SafeMath.mod(uint256(keccak256(abi.encode(_blockhash, now, tokenId, _externalRandomNumber))),_maxNumber),1)),
            uint8(SafeMath.add(SafeMath.mod(uint256(keccak256(abi.encode(_blockhash, tokenId, _externalRandomNumber))),_maxNumber),1))
        ];
    }
}