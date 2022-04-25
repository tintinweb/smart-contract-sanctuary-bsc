/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address _address) external view returns (uint256);
}

contract BilidlyFaucet {
    uint256 constant public waitTime = 24 hours;

    mapping(address => uint256) nextAccessTime;

    function allowedToWithdraw(address _address) public view returns (bool) {
        return block.timestamp >= nextAccessTime[_address];
    }

    // pass in array of token addresses and the amount array to send, with a receiving address
    function sendMultiTokens(address[] memory _tokenAddresses, address _address) public {
        if(nextAccessTime[_address] > 0) {
            require(allowedToWithdraw(_address), "please wait 24 hours");
        }
        require(_address != address(0));
        
        nextAccessTime[_address] = block.timestamp + waitTime;

        for(uint i=0; i<_tokenAddresses.length; i++) {
            uint amount = ERC20(_tokenAddresses[i]).balanceOf(address(this)) / 100;
            if (amount > 0) {
                ERC20(_tokenAddresses[i]).transfer(_address, amount);
            }
        }
    }
}