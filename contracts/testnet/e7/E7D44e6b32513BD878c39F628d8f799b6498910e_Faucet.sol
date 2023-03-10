// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Faucet {

    uint256 private constant _balanceForRequest = 0.05 ether;  
    uint256 private constant _requestAmount = 0.02 ether; 

    mapping(address => uint256) private _freezeTimes;

    event FundsSent(address indexed to, uint256 amount);

    function requestFunds(address payable recipient) external {
        require(msg.sender.balance < _balanceForRequest, "You have enough BNB for test");
        require(_freezeTimes[msg.sender] < block.timestamp, "Your account is currently frozen.");
        require(address(this).balance >= _requestAmount, "Insufficient balance in faucet");

        (bool sent, ) = recipient.call{ value: _requestAmount, gas: gasleft() }("");
        require(sent, "Failed to send funds");

        _freezeTimes[msg.sender] = block.timestamp + 1 days;
        emit FundsSent(recipient, _requestAmount);
    }

    function recieve() public payable {}
}