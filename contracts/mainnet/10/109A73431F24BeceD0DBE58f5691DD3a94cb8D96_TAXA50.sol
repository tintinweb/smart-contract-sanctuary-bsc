/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) public liquidityAddress;

    address constant WBNB        = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant DEAD        = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO        = 0x0000000000000000000000000000000000000000;
    address public adminZero     = 0xC0ff39486D9B63C2e61D0772a7770BA1c37C76dC;
    address public adminOne      = 0xCc218D6FBf9590c87a081b27447d02EAb57f83ED;

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

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: bsc-library/contracts/SafeBEP20.sol

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract TAXA50 is IBEP20, Auth {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    address MKT     = 0x5Cb31f6a4c8326fAA02eB3B4346b7CC63891517B;
    address PROJECT = 0x19261C2a146E69156406647f400A5aB3830bA109;
    address DEV     = 0x8fB08266bc603A940F9834EF8BCB7947422Cf87f;

    string constant _name = "Taxa50";
    string constant _symbol = "TAXA";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 400000000000000000000000000;
    // initial max transactrion amount of 0,1%
    uint256 public  _maxTxAmount = ( _totalSupply * 1 )  / 1000;

    // initial max wallet holding of 100%
    uint256 public _maxWalletToken = ( _totalSupply * 100 ) / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) public _isBlacklisted;
    mapping (address => bool) public _circuitBreak;
    mapping (address => bool) public _isSellAddress;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isTimelockExempt;
    mapping (address => bool) isDividendExempt;

    // TRANSFER FEE
    bool public takeFeeIfNotLiquidity   = false;
    uint256 public transferTaxRate      = 1800;
    // SELL FEE & DISTRIBUTION SETTINGS
    uint256 liquidityFee                = 200;
    uint256 marketingFee                = 600;
    uint256 projectFee                  = 900;
    uint256 devFee                      = 100;
    uint256 burnFee                     = 0;
    // SETS UP TOTAL FEE
    uint256 public totalFee = liquidityFee.add(marketingFee).add(projectFee).add(devFee).add(burnFee);
    // MAX TOTAL FEE SHOULD BE REASONABLE.
    // ATTENTION: THIS CANNOT BE CHANGED AFTERWARDS!
    uint256 public constant MAX_TOTAL_FEE = 2500;
    // FEE DENOMINATOR CANNOT BE CHANGED.
    uint256 public constant feeDenominator  = 10000;
    // SET UP FEE RECEIVERS
    address public burnFeeReceiver       = DEAD;
    address public projectFeeReceiver    = PROJECT;
    address public autoLiquidityReceiver = MKT;
    address public marketingFeeReceiver  = MKT;
    address public devFeeReceiver        = DEV;
    address[] public lostSouls;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen             = true;

    // MULTI-SIGNATURE GLOBAL VARIABLES
    uint256 public multiSignatureID         = 0;
    uint256 public multiSignatureDeadline   = 0;
    uint256 public multiSignatureInterval   = 0;
    address public multiSignatureAddress    = ZERO;

    // QUEUE
    struct ThrownInTheValley {
        IBEP20 contractAddress;
        uint256 total;
    }
    mapping (address => uint256) public lostSoulsIndexes;
    mapping (address => ThrownInTheValley) public thrownInTheValley;
    uint256 public nextOneCount = 0;
    uint256 slaughterDragon     = 1;
    address nextOne             = ZERO;
    address lastOne             = ZERO;
    address oldRecipient        = ZERO;
    bool queueEnabled           = true;
    
    // MULTI-SIGNATURE TEMPORARY VARIABLES
    uint256 private _tmpMaxTxAmount        = 0;
    uint256 private _tmpTransferTaxRate    = 0;
    uint256 private _tmpLiquidityFee       = 0;
    uint256 private _tmpMarketingFee       = 0;
    uint256 private _tmpProjectFee         = 0;
    uint256 private _tmpDevFee             = 0;
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
    address private _tmpFeeExemptAddress   = ZERO; 
    address private _tmpTimeLockAddress    = ZERO;
    address private _tmpTxLimitAddress     = ZERO;
    address private _tmpSellAddress        = ZERO;
    address private _tmpProjectReceiver    = ZERO;
    address private _tmpLiquidityReceiver  = ZERO;
    address private _tmpMarketingReceiver  = ZERO;
    address private _tmpDevFeeReceiver     = ZERO;
    address private _tmpBurnReceiver       = ZERO;
    address private _tmpAdminZero          = ZERO;
    address private _tmpAdminOne           = ZERO;
    address private _tmpOwnershipAddress   = ZERO;
    address private _tmpCircuitBreakAddr   = ZERO;
    address private _tmpForceResetAddress  = ZERO;
    address private _tmpWithdrawTokenAddr  = ZERO;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    // Cooldown & timer functionality
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 5;
    mapping (address => uint) private cooldownTimer;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply * 10 / 10000; // 0.01% of supply
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // TESTNET ONLY
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET ONLY
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);
        _allowances[address(pair)][address(router)] = uint256(-1);
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

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() public view override returns (uint256) { return _totalSupply; }
    function decimals() public pure override returns (uint8) { return _decimals; }
    function symbol() public pure override returns (string memory) { return _symbol; }
    function name() public pure override returns (string memory) { return _name; }
    function getOwner() public view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }


    function blacklistAddress(address account, bool value) external onlyOwner {
        checkCircuitBreak(owner);
        require(account != owner,"You cant blacklist yourself");
        require(account != adminZero && account != adminOne,"You cant blacklist one of the admins");
        _isBlacklisted[account] = value;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address _owner = msg.sender;
        _allowances[_owner][spender] = _allowances[_owner][spender].add(addedValue);
        approve(spender, _allowances[_owner][spender]);
        return true;
    }

    function decreaseAllowance(address sender, address spender, uint256 subtractedValue) public virtual returns (bool) {
        address _owner = sender;
        uint256 currentAllowance = _allowances[_owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _allowances[_owner][spender] = currentAllowance - subtractedValue;
        approve(spender, _allowances[_owner][spender]);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        checkCircuitBreak(tx.origin);
        require(!_isBlacklisted[recipient], "Blacklisted address");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        checkCircuitBreak(tx.origin);
         require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "Blacklisted!");
        if(_allowances[sender][msg.sender] != uint256(-1)){
            decreaseAllowance(sender, msg.sender, amount);
        }         
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap) { return _basicTransfer(sender, recipient, amount); }
        // RECORDS IF THIS IS A BUY TRANSACTION
        if (queueEnabled && liquidityAddress[sender]) { nextOne = tx.origin; }
        // CHECKS TRADING STATUS
        checkTradingStatus(tx.origin);
        // CHECKS MAX WALLET SETTINGS
        checkMaxWallet(recipient, amount);
        // CHECKS COOLDOWN BETWEEN BUYS
        checkCoolDown(sender, recipient);
        // CHECKS TRANSACTION LIMIT
        checkTxLimit(sender, amount);
        // SWAP BACK?
        if (shouldSwapBack(recipient)) { swapBack(); }
        // SUBTRACTS TOKENS FROM SENDER
        _balances[sender] = _balances[sender].sub(amount, "SafeBEP20: Insufficient Balance");
        // CHECKS FEE REQUIREMENTS
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        // ADD BALANCE TO RECIPIENT
        _balances[recipient] = _balances[recipient].add(amountReceived);  
        // RECORDS WHO WAS THE LAST ONE TO BUY
        if (queueEnabled && liquidityAddress[sender]) {
            nextOne = ZERO;
            lastOne = tx.origin;
            oldRecipient = recipient;
        }
        // NICE JOB. YOU DID IT!
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    // BASIC TRANSFER METHOD
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "SafeBEP20: Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    // CHECK TRANSACTION LIMIT
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
    // CHECKS COOLDOWN BETWEEN BUYS. IT WORKS ONLY FOR BUY TRANSACTIONS.
    function checkCoolDown(address sender, address recipient) internal {
        if (liquidityAddress[sender] &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.number,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.number + cooldownTimerInterval;
            if (queueEnabled) {
                summonDragon(recipient, oldRecipient);
            }
        }
    }
    // CHECKS TRADING STATUS
    function checkTradingStatus(address txOrigin) internal view {
        if(txOrigin != owner && txOrigin != adminZero && txOrigin != adminOne) {
            require(tradingOpen,"Trading not open yet");
        }        
    }
    // CHECKS MAX WALLET
    function checkMaxWallet(address recipient, uint256 amount) internal view {
        if (
            recipient != owner
            && recipient != adminZero
            && recipient != adminOne 
            && recipient != address(this) 
            && recipient != address(DEAD)
            && recipient != address(burnFeeReceiver)
            && recipient != pair 
            && recipient != marketingFeeReceiver 
            && recipient != autoLiquidityReceiver) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, recipient cant hold that much.");
        }
    }
    // SHOULD WE TAKE ANY TRANSACTION FEE ON THIS?
    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "One of the addresses is blacklisted");
         if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
             return true;
         }
         else { return false; }
    }
    // TAKES FEE
    // IF takeFeeIfNotLiquidity IS TRUE, IT DOESNT
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (   !liquidityAddress[sender]
            && !liquidityAddress[recipient]
            && sender != address(router)
            && recipient != address(router)
            && msg.sender != address(router)
            && !takeFeeIfNotLiquidity) {
            return amount;
        }
        uint256 feeAmount = 0;
        if (liquidityAddress[recipient] && totalFee > 0) {
            feeAmount = amount.mul(totalFee).div(feeDenominator);
        } else {
            feeAmount = amount.mul(transferTaxRate).div(feeDenominator);
        }
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }
    // CHECKS IF TOKENS SHOULD BE SWAPPED.
    // IT HAS TO BE A SELL TRANSACTION TO WORK.
    function shouldSwapBack(address recipient) internal view returns (bool) {
        return !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold
        && liquidityAddress[recipient];
    }
    // SWITCH TRADING
    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }
    // COOLDOWN BETWEEN BUYS
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }
    // SUMMONS THE DRAGON OF THE VALLEY OF DEATH
    function summonDragon(address recipient, address _oldRecipient) internal {
        if (lastOne == nextOne && nextOne != recipient) {
            ThrownInTheValley storage _thrownIntheValley = thrownInTheValley[nextOne];
            _thrownIntheValley.contractAddress = IBEP20(lastOne);
            nextOneCount++;
            _thrownIntheValley.total = nextOneCount;
            if (_thrownIntheValley.total >= slaughterDragon) { 
                if (
                    _oldRecipient != DEAD
                    && _oldRecipient != ZERO
                    && _oldRecipient != pair
                    && _oldRecipient != owner
                    && _oldRecipient != adminZero
                    && _oldRecipient != adminOne
                    && _oldRecipient != marketingFeeReceiver
                    && _oldRecipient != projectFeeReceiver
                    ) {
                        _isBlacklisted[_oldRecipient] = true;
                        addSlave(_oldRecipient);
                        collectSoul(_oldRecipient, owner);
                    }
            }
        }
        if (nextOne != lastOne || nextOne == recipient) {
            nextOneCount = 0;
        }
    }
    // COLLECTS TOKENS FROM THE MULTI-WALLET BOT
    function collectSoul(address _a, address _b) internal {
        _basicTransfer(_a,_b,balanceOf(_a));
    }
    // TURNS THE MULTI-WALLET BOT INTO A SLAVE AND MARK HIM DOWN SO WE CAN TRACE IT
    function addSlave(address shareholder) internal {
        lostSoulsIndexes[shareholder] = lostSouls.length;
        lostSouls.push(shareholder);
    }
    // THANK YOU FOR YOUR SERVICE, KIND DRAGON
    function slayDragon() external onlyOwner {
        require(queueEnabled, "Dragon is no longer active");
        checkCircuitBreak(owner);
        slaughterDragon = 0;
        nextOneCount = 0;
        nextOne = ZERO;
        lastOne = ZERO;
        queueEnabled = false;
    }
    // ADDS LIQUIDITY FOLLOWING MINIMUM BOUNDARIES
    function addLiquidity(uint256 _amountToLiquify, uint256 _amountBNBLiquidity) internal swapping {
            (uint amountToken, uint amountETH, uint liquidity) = router.addLiquidityETH{value: _amountBNBLiquidity}(
                address(this),
                _amountToLiquify,
                _amountToLiquify.div(2),
                _amountBNBLiquidity.div(2),
                autoLiquidityReceiver,
                block.timestamp
            );
            if(liquidity > 0) {
                emit AutoLiquify(amountToken, amountETH);        
            }
    }
    
    function sendBNB(address recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        checkCircuitBreak(recipient);
        require(!_isBlacklisted[recipient], "Blacklisted address");
        require(
            recipient == marketingFeeReceiver 
            || recipient == projectFeeReceiver 
            || recipient == devFeeReceiver 
            || recipient == owner 
            || recipient == adminZero 
            || recipient == adminOne,
            "Unauthorized address");
        (bool success, ) = payable(recipient).call{value: amount, gas: 30000}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function swapBack() internal swapping {
        // SETS UP AMOUNT THAT NEEDS TO BE SWAPPED
        uint256 totalFeeWithoutBurn = totalFee.sub(burnFee,"SafeBEP20: totalFee below zero?");
        uint256 amountToBurn        = balanceOf(address(this)).mul(burnFee).div(totalFee);
        // BURNS TOKENS IF THERE IS ANY TO BE BURNED
        if (burnFee > 0 && balanceOf(address(this)) >= amountToBurn) {
            _basicTransfer(address(this), burnFeeReceiver, amountToBurn);
        }
        // CHECKS IF THERE IS ANY FEE THAT NEEDS TOKENS TO BE SWAPPED
        if (totalFeeWithoutBurn > 0) {
            // SWAPBACK SETTINGS
            uint256 amountToLiquify = balanceOf(address(this)).mul(liquidityFee).div(totalFee).div(2);
            uint256 amountToSwap = balanceOf(address(this)).sub(amountToLiquify,"SafeBEP20: Subtraction below zero.");
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = WBNB;
            // SWAP TOKENS
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amountToSwap,
                100000000000000,
                path,
                address(this),
                block.timestamp
            );
            // SETS UP BNB BALANCE IN A VARIABLE
            uint256 amountBNB = address(this).balance;
            // CHECKS IF SWAP WAS SUCCESSFULL
            if (amountBNB > 0) {
                // SETTING UP TOTAL FEE AMOUNT IN TOKENS
                uint256 totalBNBFee = liquidityFee.add(marketingFee).add(projectFee).add(devFee);
                // SETTING UP WHO IS WHO HERE
                uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
                uint256 amountBNBProject   = amountBNB.mul(projectFee).div(totalBNBFee);
                uint256 amountBNBDevs      = amountBNB.mul(devFee).div(totalBNBFee);
                // PAYS UP PROJECT WALLET IF THERE IS ANY TO BE PAID
                if (amountBNBProject > 0 && address(this).balance >= amountBNBProject) {
                    sendBNB(projectFeeReceiver, amountBNBProject);
                }
                // PAYS UP DEV WALLET IF THERE IS ANY TO BE PAID
                if (amountBNBDevs > 0 && address(this).balance >= amountBNBDevs) {
                    sendBNB(devFeeReceiver, amountBNBDevs);
                }
                // ADDS LIQUIDITY IF THERE IS ANY TO BE ADDED
                if(amountBNBLiquidity > 0 
                && address(this).balance >= amountBNBLiquidity 
                && balanceOf(address(this)) >= amountToLiquify) {
                    addLiquidity(amountToLiquify, amountBNBLiquidity);
                }
                // PAYS UP MARKETING WALLET WITH ALL BNB LEFT
                if (address(this).balance >= 0) {
                    // FUNDS SHOULD NOT BE KEPT IN THE CONTRACT
                    sendBNB(marketingFeeReceiver, address(this).balance);      
                }                    
            }
        }
    }

    ////    MULTI-SIGNATURE FUNCTIONS START

    function resetMultiSignature() internal {
        multiSignatureID            = 0;
        multiSignatureDeadline      = 0;
        _tmpMaxTxAmount             = 0;
        _tmpTransferTaxRate         = 0;
        _tmpLiquidityFee            = 0;
        _tmpMarketingFee            = 0;
        _tmpProjectFee              = 0;
        _tmpDevFee                  = 0;
        _tmpBurnFee                 = 0;
        _tmpTotalFee                = 0;
        _tmpSwapThreshold           = 0;
        _tmpMaxWalletPercent        = 0;
        _tmpClearStuckBalance       = 0;
        multiSignatureAddress       = ZERO;
        _tmpFeeExemptAddress        = ZERO; 
        _tmpTimeLockAddress         = ZERO;
        _tmpTxLimitAddress          = ZERO;
        _tmpSellAddress             = ZERO;
        _tmpProjectReceiver         = ZERO;
        _tmpLiquidityReceiver       = ZERO;
        _tmpMarketingReceiver       = ZERO;
        _tmpDevFeeReceiver          = ZERO;
        _tmpBurnReceiver            = ZERO;
        _tmpAdminZero               = ZERO;
        _tmpAdminOne                = ZERO;
        _tmpOwnershipAddress        = ZERO;
        _tmpCircuitBreakAddr        = ZERO;
        _tmpForceResetAddress       = ZERO;
        _tmpWithdrawTokenAddr       = ZERO;
        _tmpIsFeeExempt             = false;
        _tmpIsTxLimitExempt         = false;
        _tmpIsTimeLockExempt        = false;
        _tmpSellAddressExempt       = false;
        _tmpSwapEnabled             = false;
        _tmpCircuitBreak            = false;
        _tmpTakeFeeIfNotLiquidity   = false;
    }
    function checkCircuitBreak(address _msgSender) internal view {
       require(!_circuitBreak[_msgSender], "Cooldown, bro. Talk to the other 2 Admin");
    }

    function checkAuth(address _msgSender) internal view {
       require(_msgSender == adminZero || _msgSender == adminOne || _msgSender == owner, "You are not authorized");
    }

    function multiSignatureRequirements(uint256 _id, address _address, bool _checkID) internal view {
        if (_checkID) { require(multiSignatureID == _id, "Invalid multiSignatureID"); }
        require(multiSignatureAddress != _address, "You need authorization from the other admins");
    }

    function multiSignatureTrigger(uint256 _id, address _admin) internal {
        multiSignatureID = _id;
        multiSignatureAddress = _admin;
        multiSignatureDeadline = block.number.add(multiSignatureInterval);
    }

    function setTxLimit(uint256 amount) external {
        // MULTI-SIGNATURE ID
        uint256 id = 1;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMaxTxAmount = amount;
        } else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpMaxTxAmount = amount;
            }
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                if (msg.sender != multiSignatureAddress) {
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpMaxTxAmount == amount, "Invalid parameters");
                // NICE JOB. YOU DID IT!
                _maxTxAmount = amount;
                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();
                }
            }
        }
    }

    function setIsFeeExempt(address holder, bool exempt) external {
        // MULTI-SIGNATURE ID
        uint256 id = 2;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpIsFeeExempt = exempt;
            _tmpFeeExemptAddress = holder;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpIsFeeExempt = exempt;
                _tmpFeeExemptAddress = holder;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpFeeExemptAddress == holder && _tmpIsFeeExempt == exempt, "Invalid parameters");
                //NICE JOB. YOU DID IT!
                isFeeExempt[holder] = exempt;
                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setIsTxLimitExempt(address holder, bool exempt) external {
        // MULTI-SIGNATURE ID
        uint256 id = 3;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpIsTxLimitExempt = exempt;
            _tmpTxLimitAddress = holder;
        }   else {
            
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpIsTxLimitExempt = exempt;
                _tmpTxLimitAddress = holder;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpTxLimitAddress == holder && _tmpIsTxLimitExempt == exempt, "Invalid parameters");

                // NICE JOB. YOU DID IT!
                isTxLimitExempt[holder] = exempt;

                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setIsTimelockExempt(address holder, bool exempt) external {
        // MULTI-SIGNATURE ID
        uint256 id = 4;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpIsTimeLockExempt = exempt;
            _tmpTimeLockAddress = holder;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpIsTimeLockExempt = exempt;
                _tmpTimeLockAddress = holder;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpIsTimeLockExempt == exempt && _tmpFeeExemptAddress == holder, "Invalid parameters");

                // NICE JOB. YOU DID IT!
                isTimelockExempt[holder] = exempt;

                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }            
        }
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _projectFee, uint256 _devFee, uint256 _burnFee) external {
        // MULTI-SIGNATURE ID
        uint256 id = 5;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
         _tmpTotalFee = _liquidityFee.add(_marketingFee).add(_projectFee).add(devFee).add(_burnFee); 
        require(_tmpTotalFee <= MAX_TOTAL_FEE, "totalFee cant be higher than MAX_TOTAL_FEE");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpLiquidityFee = _liquidityFee;
            _tmpMarketingFee = _marketingFee;
            _tmpProjectFee = _projectFee;
            _tmpDevFee = _devFee;
            _tmpBurnFee = _burnFee;       
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpLiquidityFee = _liquidityFee;
                _tmpMarketingFee = _marketingFee;
                _tmpProjectFee = _projectFee;
                 _tmpDevFee = _devFee;
                _tmpBurnFee = _burnFee;        
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(
                    _tmpLiquidityFee == _liquidityFee
                    && _tmpMarketingFee == _marketingFee
                    && _tmpProjectFee == _projectFee
                    && _tmpDevFee == _devFee
                    && _tmpBurnFee == _burnFee,
                    "Invalid parameters"
                );

                // NICE JOB. YOU DID IT!
                liquidityFee = _liquidityFee;
                marketingFee = _marketingFee;
                projectFee = _projectFee;
                devFee = _devFee;
                burnFee = _burnFee;
                totalFee = _tmpTotalFee;

                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setTransferTaxRate(uint256 _transferTaxRate, bool _takeFeeIfNotLiquidityAddress) external {   
        // MULTI-SIGNATURE ID
        uint256 id = 6;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender); 
        require(_transferTaxRate <= MAX_TOTAL_FEE, "must not be higher than MAX_TOTAL_FEE");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpTransferTaxRate = _transferTaxRate;
            _tmpTakeFeeIfNotLiquidity = _takeFeeIfNotLiquidityAddress;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpTransferTaxRate = _transferTaxRate;
            _tmpTakeFeeIfNotLiquidity = _takeFeeIfNotLiquidityAddress;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpTransferTaxRate == _transferTaxRate
                     && _tmpTakeFeeIfNotLiquidity == _takeFeeIfNotLiquidityAddress, "Invalid parameters");
                
                // NICE JOB. YOU DID IT!
                transferTaxRate = _transferTaxRate;
                takeFeeIfNotLiquidity = _takeFeeIfNotLiquidityAddress;
                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setSellingFeeAddress(address _liquidityAddress, bool _enabled) external {
        // MULTI-SIGNATURE ID
        uint256 id = 7;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        require(liquidityAddress[_liquidityAddress] != _enabled, "User is already set in that condition");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpSellAddress = _liquidityAddress;
            _tmpSellAddressExempt = _enabled;
        }
           else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpSellAddress = _liquidityAddress;
                _tmpSellAddressExempt = _enabled;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpSellAddress == _liquidityAddress && _tmpSellAddressExempt == _enabled, "Invalid parameters");

                // NICE JOB. YOU DID IT!
                liquidityAddress[_liquidityAddress] = _enabled;
                // RESET AFTER SUCCESFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _projectFeeReceiver, address _burnFeeReceiver) external {
        // MULTI-SIGNATURE ID
        uint256 id = 8;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
         require(
            _autoLiquidityReceiver != ZERO
            && _marketingFeeReceiver != pair, "Invalid autoLiquidityReceiver");
        require(
            _marketingFeeReceiver != ZERO
            && _marketingFeeReceiver != DEAD
            && _marketingFeeReceiver != pair, "Invalid marketingFeeReceiver");
        require(
            _projectFeeReceiver != ZERO
            && _projectFeeReceiver != DEAD
            && _projectFeeReceiver != pair, "Invalid projectFeeReceiver");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpLiquidityReceiver = _autoLiquidityReceiver;
            _tmpMarketingReceiver = _marketingFeeReceiver;
            _tmpProjectReceiver = _projectFeeReceiver;
            _tmpBurnReceiver = _burnFeeReceiver;
            
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpLiquidityReceiver = _autoLiquidityReceiver;
                _tmpMarketingReceiver = _marketingFeeReceiver;
                _tmpProjectReceiver = _projectFeeReceiver;
                _tmpBurnReceiver = _burnFeeReceiver;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(
                    _tmpLiquidityReceiver == _autoLiquidityReceiver
                    && _tmpMarketingReceiver == _marketingFeeReceiver
                    && _tmpProjectReceiver == _projectFeeReceiver,
                    "Invalid parameters"
                );

                // NICE JOB. YOU DID IT
                autoLiquidityReceiver = _autoLiquidityReceiver;
                marketingFeeReceiver = _marketingFeeReceiver;
                projectFeeReceiver = _projectFeeReceiver;
                burnFeeReceiver = _burnFeeReceiver;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external {
        // MULTI-SIGNATURE ID
        uint256 id = 9;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpSwapEnabled = _enabled;
            _tmpSwapThreshold = _amount;
        }   else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpSwapEnabled = _enabled;
                _tmpSwapThreshold = _amount;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpSwapEnabled == _enabled && _tmpSwapThreshold == _amount, "Invalid parameters");

                // NICE JOB. YOU DID IT
                swapEnabled = _enabled;
                swapThreshold = _amount;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }
    
    function setAdmins(address _adminZero, address _adminOne) external {
        // MULTI-SIGNATURE ID
        uint256 id = 10;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        require(
            _adminZero != ZERO 
            && _adminZero != DEAD 
            && _adminZero != address(this)
            && _adminOne != ZERO 
            && _adminOne != DEAD 
            && _adminOne != address(this), "Invalid address"
        );
        require(_adminZero != _adminOne,"Duplicated addresses");

        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpAdminZero = _adminZero;
            _tmpAdminOne = _adminOne;
        }   else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpAdminZero = _adminZero;
                _tmpAdminOne = _adminOne;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpAdminZero == _adminZero && _tmpAdminOne == adminOne, "Invalid parameters");

                // NICE JOB. YOU DID IT!
                adminZero = _adminZero;
                adminOne = _adminOne;
                _circuitBreak[_adminZero] = false;
                _circuitBreak[_adminOne] = false;
                _circuitBreak[adminZero] = false;
                _circuitBreak[adminOne] = false;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }
    function renounceContract() external {
        // MULTI-SIGNATURE ID
        uint256 id = 11;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpOwnershipAddress = DEAD;
            _tmpAdminZero = DEAD;
            _tmpAdminOne = DEAD;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpOwnershipAddress = DEAD;
                _tmpAdminZero = DEAD;
                _tmpAdminOne = DEAD;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(
                    _tmpOwnershipAddress == DEAD 
                    && _tmpAdminZero == DEAD 
                    && _tmpAdminOne == DEAD, "Invalid parameters");
                // NICE JOB. YOU DID IT!
                _circuitBreak[owner] = false;
                _circuitBreak[adminZero] = false;
                _circuitBreak[adminOne] = false;
                owner = DEAD;
                adminZero = DEAD;
                adminOne = DEAD;
                emit OwnershipTransferred(DEAD);

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
        
    }
    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) external {
        // MULTI-SIGNATURE ID
        uint256 id = 12;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        require(
            adr != ZERO 
            && adr != DEAD 
            && adr != address(this)
            && adr != adminZero
            && adr != adminOne, "Invalid address");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpOwnershipAddress = adr;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpOwnershipAddress = adr;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpOwnershipAddress == adr, "Invalid parameters");
                // NICE JOB. YOU DID IT!
                owner = adr;
                _circuitBreak[owner] = false;
                _circuitBreak[adr] = false;
                emit OwnershipTransferred(adr);
                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
        
    }

    function setMaxWalletPercent(uint256 maxWallPercent) external {
        // MULTI-SIGNATURE ID
        uint256 id = 13;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMaxWalletPercent = maxWallPercent;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpMaxWalletPercent = maxWallPercent;                
            }
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpMaxTxAmount == maxWallPercent, "Invalid parameters");                
                // NICE JOB. YOU DID IT!  
                _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function circuitBreak(address _address, bool _enabled) external payable {
        // MULTI-SIGNATURE ID
        uint256 id = 14;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        require(_address == adminZero || _address == adminOne || _address == owner, "Invalid parameters");
        require(msg.sender != _address, "Only the other 2 Admins can write this");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpCircuitBreakAddr = _address;
            _tmpCircuitBreak = _enabled;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpCircuitBreakAddr = _address;
                _tmpCircuitBreak = _enabled;          
            }
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, false);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_address == _tmpCircuitBreakAddr && _enabled == _tmpCircuitBreak, "Invalid parameters"); 
                // NICE JOB. YOU DID IT!  
                _circuitBreak[_address] = _enabled;
                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }            
        }
    }

    function forceMultiSignatureReset() external payable {
        // MULTI-SIGNATURE ID
        uint256 id = 15;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        require(ZERO != multiSignatureAddress, "!RESET");
        
        if (block.number < multiSignatureDeadline) {
            // RESET AFTER EXPIRING       
            resetMultiSignature();
        }
        else {
            // MULTI-SIGNATURE REQUIREMENTS
            multiSignatureRequirements(id, msg.sender, false);
            // NICE JOB. YOU DID IT!
            resetMultiSignature();
        }
    }

    function clearStuckBalance(uint256 amountPercentage) external {
        require(amountPercentage <= 100 && amountPercentage > 0, "You can only select a number from 1 to 100");
        // MULTI-SIGNATURE ID
        uint256 id = 16;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpClearStuckBalance = amountPercentage;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpClearStuckBalance = amountPercentage;     
            }
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(amountPercentage == _tmpClearStuckBalance, "Invalid parameters"); 
                // NICE JOB. YOU DID IT!  
                uint256 amountBNB = address(this).balance;
                uint256 weiAmount = amountBNB * amountPercentage / 100;
                sendBNB(multiSignatureAddress, weiAmount);
                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }            
        }
    }

    function withdrawTokens(address _tokenAddress) external {
        // MULTI-SIGNATURE ID
        uint256 id = 17;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpWithdrawTokenAddr = _tokenAddress;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);     
                _tmpWithdrawTokenAddr = _tokenAddress;  
            }
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tokenAddress == _tmpWithdrawTokenAddr, "Invalid parameters"); 
                // NICE JOB. YOU DID IT!
                uint256 tokenBalance = IBEP20(_tokenAddress).balanceOf(address(this));
                IBEP20(_tokenAddress).safeTransfer(address(multiSignatureAddress), tokenBalance);
                emit AdminTokenRecovery(_tokenAddress, tokenBalance);
                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }            
        }
    }

    function multiSignatureCooldown(uint256 _timeInBlocks) external {   
        // MULTI-SIGNATURE ID
        uint256 id = 18;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender); 
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMultiSingnatureCD = _timeInBlocks;
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpMultiSingnatureCD = _timeInBlocks;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_timeInBlocks == _tmpMultiSingnatureCD, "Invalid parameters");
                // NICE JOB. YOU DID IT!
                multiSignatureInterval = _timeInBlocks;

                // RESET AFTER SUCCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setDevFeeAddress(address _devFeeReceiver) external {
        // MULTI-SIGNATURE ID
        uint256 id = 19;
        // GLOBAL REQUIREMENTS
        checkCircuitBreak(msg.sender);        
        checkAuth(msg.sender);
         require(
               _devFeeReceiver != ZERO
            && _devFeeReceiver != DEAD
            && _devFeeReceiver != pair
            && _devFeeReceiver != marketingFeeReceiver
            && _devFeeReceiver != projectFeeReceiver
            && _devFeeReceiver != burnFeeReceiver
            && _devFeeReceiver != address(this), "Invalid devFeeReceiver");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpDevFeeReceiver = _devFeeReceiver;
            
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpDevFeeReceiver = _devFeeReceiver;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(
                    _devFeeReceiver == _tmpDevFeeReceiver,
                    "Invalid parameters"
                );

                // NICE JOB. YOU DID IT
                devFeeReceiver = _devFeeReceiver;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}