// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Faucet {

    uint256 private constant _balanceForRequest = 0.5 ether;  
    uint256 private constant _requestAmount = 0.3 ether; 

    mapping(address => uint256) private _freezeTimes;

    // declare an event for logging when BNBs are distributed
    event BNBsDistributed(address recipient, uint amount);

    // function to distribute BNBs to a user's wallet address
    function distributeBNBs(address payable recipient) public {
        // check that the recipient address is valid
        require(recipient != address(0), "Invalid address");
        require(msg.sender.balance < _balanceForRequest, "You have enough BNB for test");
        require(address(this).balance >= _requestAmount, "Insufficient balance in faucet");
        require(_freezeTimes[msg.sender] < block.timestamp, "Your account is currently frozen.");

        // transfer 1 BNB to the recipient address
        recipient.transfer(_requestAmount);

        _freezeTimes[msg.sender] = block.timestamp + 1 days;
        // emit an event for logging the distribution
        emit BNBsDistributed(recipient, _requestAmount);
    }
}