/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

/**
// contracts/Faucet.sol
// SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.17;
interface IERC20 {
function transfer(address to, uint256 value) external returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Faucet {
uint256 constant public waitTime = 1440 minutes;
bool public isFaucetActive = true;
address public owner;
IERC20 public tokenInstance;
mapping(address => uint256) public lastAccessTime;


constructor(address _tokenInstance) {
    require(_tokenInstance != address(0));
    tokenInstance = IERC20(_tokenInstance);
    owner = msg.sender;
}

function requestTokens(uint8 _slice) public {
    require(allowedToWithdraw(msg.sender));
    require(isFaucetActive);
    uint256 tokenAmount;
    if(_slice == 1) {
        tokenAmount = 5 * 10**12;
    } else if(_slice == 2) {
        tokenAmount = 11 * 10**12;
    } else if(_slice == 3) {
        tokenAmount = 8 * 10**12;
    } else if(_slice == 4) {
        tokenAmount = 4 * 10**12;
    } else if(_slice == 5) {
        tokenAmount = 3 * 10**12;
    } else if(_slice == 6) {
        tokenAmount = 14 * 10**12;
    } else if(_slice == 7) {
        tokenAmount = 10 * 10**12;
    } else if(_slice == 8) {
        tokenAmount = 12 * 10**12;
    }
    tokenInstance.transfer(msg.sender, tokenAmount);
    lastAccessTime[msg.sender] = block.timestamp + waitTime;
}

function allowedToWithdraw(address _address) public view returns (bool) {
    if(lastAccessTime[_address] == 0) {
        return true;
    } else if(block.timestamp >= lastAccessTime[_address]) {
        return true;
    }
    return false;
}
    function stopFaucet() public {
        require(msg.sender == owner);
        isFaucetActive = false;
    }
    
    function activateFaucet() public {
        require(msg.sender == owner);
        isFaucetActive = true;
    }

}