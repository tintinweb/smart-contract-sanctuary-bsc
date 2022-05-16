// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IERC20.sol";
import "./Ownable.sol";

contract LockCypher is Ownable {
    uint256 public tokensLock;
    uint256 public withdrawnTokens;
    uint256 public initialTime;
    uint256 public number_of_withdrawals = 0;
    uint256 public timeWeek = 7 days;

    IERC20 cypherToken;

    constructor (address cypherAddress) {
        cypherToken = IERC20(cypherAddress);
        initialTime = block.timestamp;
    }

    function lockTokens(uint256 _lock) public payable onlyOwner {
        require(cypherToken.transferFrom(msg.sender, address(this), _lock), "You do not have the necessary tokens");
        tokensLock = _lock;
        withdrawnTokens = 0;
    }

    function withdrawTokens() public payable onlyOwner() {
        require(withdrawnTokens < tokensLock, "Not enough tokens");
        require(block.timestamp > initialTime + (timeWeek * number_of_withdrawals), "It is not time to withdraw.");

        uint256 balanceCypher = cypherToken.balanceOf(address(this));
        uint256 onePercentageCypher = tokensLock / 100;
        require(balanceCypher > 0, "Not enough tokens");

        if (onePercentageCypher < balanceCypher) {
            require(cypherToken.transfer(msg.sender, onePercentageCypher), "Not balance");
            withdrawnTokens += onePercentageCypher;
        } else {
            require(cypherToken.transfer(msg.sender, balanceCypher), "Not balance");
            withdrawnTokens += balanceCypher;
        }

        number_of_withdrawals++;
    }
}