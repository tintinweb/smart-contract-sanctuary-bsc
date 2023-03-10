// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Faucet {
    mapping(address => uint256) private _freezeTimes;

    uint256 private constant _balanceForRequest = 50000000000000000; // 0.05 BNB 
    uint256 private constant _maxRequestAmount = 20000000000000000; // 0.02 BNB

    event FundsRequested(address indexed requester, uint256 amount);
    event BalanceRequirementChecked(address indexed requester, uint256 balance);
    event FreezeTimeChecked(address indexed requester, uint256 freezeTime);
    event FreezeTimeNotElapsed(address indexed requester, uint256 remainingTime);
    event BalanceExceedsRequirement(address indexed requester, uint256 balance);

    function requestTokens() public {
        if (_freezeTimes[msg.sender] > block.timestamp) {
            uint256 remainingTime = _freezeTimes[msg.sender] - block.timestamp;
            emit FreezeTimeNotElapsed(msg.sender, remainingTime);
            return;
        }

        if (msg.sender.balance >= _balanceForRequest) {
            emit BalanceExceedsRequirement(msg.sender, _balanceForRequest);
            return;
        }

        require(address(this).balance >= _maxRequestAmount, "Faucet is out of tokens.");

        (bool success, ) = payable(msg.sender).call{value: _maxRequestAmount, gas: gasleft() / 2}("");
        require(success, "Transfer failed.");

        _freezeTimes[msg.sender] = block.timestamp + 1 days;
        emit FundsRequested(msg.sender, _maxRequestAmount);
    }

    function deposit() public payable {}

    function checkBalanceRequirement() public returns (uint256) {
        emit BalanceRequirementChecked(msg.sender, _balanceForRequest);
        return _balanceForRequest;
    }

    function checkFreezeTime() public returns (uint256) {
        emit FreezeTimeChecked(msg.sender, _freezeTimes[msg.sender]);
        return _freezeTimes[msg.sender];
    }
}