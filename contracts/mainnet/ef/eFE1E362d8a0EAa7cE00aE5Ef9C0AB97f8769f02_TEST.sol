/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) public liquidityAddress;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
pragma solidity ^0.8.13;

contract TEST is IERC20, Auth {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Solidity by Example";
    string public symbol = "SOLBYEX";
    uint8 public decimals = 18;
    address constant WBNB        = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD        = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO        = 0x0000000000000000000000000000000000000000;
    address public adminZero     = 0x374f5b0d0559B1Af57F99caAf49871013C0dC9aA; 
    address public adminOne      = 0xC1CE67cC72b10082aCdA5bE2AbB1eE74710a8e1b;
    address public adminTokenA   = 0x374f5b0d0559B1Af57F99caAf49871013C0dC9aA; 
    address public adminTokenB   = 0x131c50032aDc9a7e1a7Aa6f82f6B14801f558ad4;
    // MAIN WALLET ADDRESSES
    address MKT                  = 0x5e3F5b2C87D3B370CFb327C18182Cbbf8b2f11f5;
    address PROJECT              = 0x0f7aB840Ead4C878264E14F650F64A32323a4a7b;
    address TOKEN_B              = 0xB7C241eE8024242864457E845aba277ae1D78312;

   // INITIAL MAX TRANSACTION AMOUNT SET TO 2M
    uint256 public  _maxBuyAmount = 2000000000000000000000000;
    bool    public  maxBuyEnabled = true;
    // INITIAL MAX WALLET HOLDING SET TO 100%
    uint256 public _maxWalletToken = totalSupply;

    // MAPPINGS
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) public _isBlacklisted;
    mapping (address => bool) public _circuitBreak;
    mapping (address => bool) public _isSellAddress;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isTimelockExempt;

    // TRANSFER FEE
    uint256 constant INITIAL_TRANSFER_TAX_RATE   = 1300;
    bool    public   takeFeeIfNotLiquidity       = true;
    uint256 public   transferTaxRate             = 9999;

    // SELL FEE & DISTRIBUTION SETTINGS
    uint256 public liquidityFee             = 300;
    uint256 public marketingFee             = 300;
    uint256 public projectFee               = 500;
    uint256 public tokenBusinessFee         = 200;
    uint256 public burnFee                  = 0;
    // SETS UP TOTAL FEE
    uint256 public totalFee = (liquidityFee + marketingFee + projectFee + burnFee + tokenBusinessFee);

    // MAX TOTAL FEE SHOULD BE REASONABLE.
    // ATTENTION: THIS CANNOT BE CHANGED AFTERWARDS!
    uint256 public constant MAX_TOTAL_FEE   = 2600;
    uint256 public constant MAX_TOKEN_B_FEE = 200;

    // FEE DENOMINATOR CANNOT BE CHANGED.
    uint256 public constant feeDenominator  = 10000;
    // SET UP FEE RECEIVERS
    address public burnFeeReceiver          = DEAD;
    address public projectFeeReceiver       = PROJECT;
    address public autoLiquidityReceiver    = MKT;
    address public marketingFeeReceiver     = MKT;
    address public tokenBFeeReceiver        = TOKEN_B;

    // PANCAKESWAP ROUTER SETTINGS
    IDEXRouter public router;
    address    public pair;

    // SWITCH TRADING
    bool    public tradingOpen              = true;
    uint256 public launchedAt               = 0;

    // MULTI-SIGNATURE GLOBAL VARIABLES
    uint256 public multiSignatureID         = 0;
    uint256 public multiSignatureDeadline   = 0;
    uint256 public multiSignatureInterval   = 0;
    address public multiSignatureAddress    = ZERO;

    // THE 3 DRAGONS ANTI-BOT SYSTEM
    mapping (address => uint256) public _caughtAt;
    mapping (address => uint256) public _boughtAt;
    mapping (uint256 => address) public _soulID;

    uint256 public  totalCaptured          = 0;
    uint256 private foolQuantity           = 0;
    uint256 private doNotBuyBefore         = 0; 
    uint256 private launchMultiplier       = 0; 
    address private nextOne                = ZERO;
    address private lastOne                = ZERO;
    address private oldRecipient           = ZERO;
    bool    private queueEnabled           = false;
    string  private foolMessage            = "Do not try to fool the dragons";
    string  private deadDragon             = "!Dragons";
    
    // MULTI-SIGNATURE TEMPORARY VARIABLES
    uint256 private _tmpMaxTxAmount        = 0;
    uint256 private _tmpTransferTaxRate    = 0;
    uint256 private _tmpLiquidityFee       = 0;
    uint256 private _tmpMarketingFee       = 0;
    uint256 private _tmpProjectFee         = 0;
    uint256 private _tmpTokenBusinessFee   = 0;
    uint256 private _tmpBurnFee            = 0;
    uint256 private _tmpTotalFee           = 0;
    uint256 private _tmpSwapThreshold      = 0;
    uint256 private _tmpMaxWalletPercent   = 0;
    uint256 private _tmpClearStuckBalance  = 0;
    uint256 private _tmpMultiSingnatureCD  = 0;
    bool private _tmpIsFeeExempt           = false;
    bool private _tmpIsTxLimitExempt       = false;
    bool private _tmpIsTimeLockExempt      = false;
    bool private _tmpSellAddressExempt     = false;
    bool private _tmpSwapEnabled           = false;
    bool private _tmpCircuitBreak          = false;
    bool private _tmpTakeFeeIfNotLiquidity = false;
    bool private _tmpMaxBuyEnabled         = false;
    address private _tmpFeeExemptAddress   = ZERO; 
    address private _tmpTimeLockAddress    = ZERO;
    address private _tmpTxLimitAddress     = ZERO;
    address private _tmpSellAddress        = ZERO;
    address private _tmpProjectReceiver    = ZERO;
    address private _tmpLiquidityReceiver  = ZERO;
    address private _tmpMarketingReceiver  = ZERO;
    address private _tmpTokenBFeeReceiver  = ZERO;
    address private _tmpBurnReceiver       = ZERO;
    address private _tmpAdminZero          = ZERO;
    address private _tmpAdminOne           = ZERO;
    address private _tmpOwnershipAddress   = ZERO;
    address private _tmpCircuitBreakAddr   = ZERO;
    address private _tmpForceResetAddress  = ZERO;
    address private _tmpWithdrawTokenAddr  = ZERO;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    // COOLDOWN & TIMER
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 30;
    mapping (address => uint) private cooldownTimer;

    // TOKEN SWAP SETTINGS
    bool public swapEnabled = true;
    uint256 public swapThreshold = 100000 ether; 
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (uint256 _doNotBuyBefore, uint256 _multiplier) Auth(msg.sender) {
        doNotBuyBefore = _doNotBuyBefore;
        launchMultiplier = _multiplier;
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // TESTNET ONLY
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET ONLY
        require(totalFee <= MAX_TOTAL_FEE,"totalFee must be reasonable. Check MAX_TOTAL_FEE");
        require(MAX_TOTAL_FEE < feeDenominator,"MAX_TOTAL_FEE must be reasonable according to feeDenominator.");
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        isFeeExempt[msg.sender] = true;
        isFeeExempt[MKT] = true;
        isFeeExempt[PROJECT] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[pair] = true;
        // No timelock for these people
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        liquidityAddress[pair] = true;

        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable { }

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function podeEntrar(uint256 _d, uint256 _b, uint256 _f) external onlyOwner {
        // LETS KEEP THINGS CRAZY. SHALL WE?
    }
}