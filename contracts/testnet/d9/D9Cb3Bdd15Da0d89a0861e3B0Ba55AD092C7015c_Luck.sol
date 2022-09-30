/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// File: contracts/L.sol


pragma solidity 0.8.9;

contract Luck {

    uint256 public latestDepositAmount = 0;
    address public latestDepositor;

    event UserDeposit(address who, uint256 amount);

    function deposit() external payable {
        if (latestDepositAmount == 0) {
            require(msg.value >= 0.01 ether, "Insufficient fund");
            
        } else {
            require(msg.value >= latestDepositAmount * 15 / 10, "Insufficient fund");
            payable(latestDepositor).transfer(msg.value);
        }

        latestDepositor = msg.sender;
        latestDepositAmount = msg.value;
        emit UserDeposit(latestDepositor, latestDepositAmount);
    }
}