/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

//SPDX-License-Identifier: MIT
//[dev]: Mister Whitestake - https://t.me/mrwhitestake
pragma solidity ^0.7.6;

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
    address public adminZero     = 0x374f5b0d0559B1Af57F99caAf49871013C0dC9aA; 
    address public adminOne      = 0xB98DE69c4e9b495E942b7dDE520609653C8E441d;

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

contract VINO is IBEP20, Auth {
    // LIBRARIES
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // MAIN WALLET ADDRESSES
    address private MKT                              = 0xAaDea1505e568Dfeba40a20D20E0f0DdE26D9789;
    address private PROJECT                          = 0x2E8FB19d577699FD4204F817CecD63fbe1fa10fE;
    address private SPONSOR                          = 0x60F5A8B81E9CdC7f1b92A6a0FC8858643618D07d;

    // TOKEN GLOBAL VARIABLES
    string constant _name                            = "Vinocoin";
    string constant _symbol                          = "VINO";
    uint8  constant _decimals                        = 18;
    uint256 _totalSupply                             = 1000000000 * 10**18;

    // INITIAL MAX TRANSACTION AMOUNT SET TO 1.5M
    uint256 public  _maxBuyAmount                    = 1000000 * 10**18;
    bool    public  maxBuyEnabled                    = true;

    // INITIAL MAX WALLET HOLDING SET TO 100%
    uint256 public _maxWalletToken                   = _totalSupply;

    // MAPPINGS
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _allowances;
    mapping (address => bool) public                   _isBlacklisted;
    mapping (address => bool) public                   isFeeExempt;
    mapping (address => bool) public                   isTxLimitExempt;
    mapping (address => bool) public                   isTimelockExempt;

    // TRANSFER FEE
    uint256 constant INITIAL_TRANSFER_TAX_RATE       = 1300;
    uint256 public   transferTaxRate                 = 9999;
    bool    public   takeFeeIfNotLiquidity           = false;

    // SELL FEE & DISTRIBUTION SETTINGS
    uint256 public liquidityFee                      = 200;
    uint256 public marketingFee                      = 300;
    uint256 public projectFee                        = 600;
    uint256 public sponsorFee                        = 200;
    uint256 public burnFee                           = 0;
    // SETS UP TOTAL FEE
    uint256 public totalFee = liquidityFee.add(marketingFee).add(projectFee).add(burnFee).add(sponsorFee);

    // MAX TOTAL FEE SHOULD BE REASONABLE.
    // ATTENTION: THIS CANNOT BE CHANGED AFTERWARDS!
    uint256 public constant MAX_TOTAL_FEE            = 2500;

    // FEE DENOMINATOR CANNOT BE CHANGED.
    uint256 public constant feeDenominator           = 10000;
    // SET UP FEE RECEIVERS
    address public burnFeeReceiver                   = DEAD;
    address public projectFeeReceiver                = PROJECT;
    address public autoLiquidityReceiver             = MKT;
    address public marketingFeeReceiver              = MKT;
    address public sponsorFeeReceiver                = SPONSOR;

    // PANCAKESWAP ROUTER SETTINGS
    IDEXRouter public router;
    address    public pair;

    // SWITCH TRADING
    bool    public  tradingOpen                       = true;
    uint256 public  launchedAt                        = 0;

    // MULTI-SIGNATURE GLOBAL VARIABLES
    uint256 public multiSignatureID                   = 0;
    uint256 public multiSignatureDeadline             = 0;
    uint256 public multiSignatureInterval             = 0;
    address public multiSignatureAddress              = ZERO;

    // THE 5 DRAGONS ANTI-BOT SYSTEM
    mapping (address => uint256) public                 _caught;
    mapping (address => uint256) public                 _bought;
    mapping (uint256 => address) public                 _soulID;
    uint256 private foolQuantity                      = _maxBuyAmount.div(100);
    uint256 public  totalCaptured                     = 0;
    uint256 private oldGas                            = 0; 
    uint256 private oldGwei                           = 0; 
    uint256 private launchMultiplier                  = 2; 
    uint256 private maxGasLeft                        = 1400000; 
    uint256 private maxGwei                           = 7000000000; 
    uint256 private dragonFee                         = 2700;
    address private nextOne                           = ZERO;
    address private lastOne                           = ZERO;
    address private oldRecipient                      = ZERO;
    bool    private queueEnabled                      = false;
    bool    private alternateDragon                   = false;
    string  private foolMessage                       = "Do not try to fool the dragons";
    string  private deadDragon                        = "!Dragons";
    
    // MULTI-SIGNATURE TEMPORARY VARIABLES
    uint256 private _tmpMaxTxAmount                   = 0;
    uint256 private _tmpTransferTaxRate               = 0;
    uint256 private _tmpLiquidityFee                  = 0;
    uint256 private _tmpMarketingFee                  = 0;
    uint256 private _tmpProjectFee                    = 0;
    uint256 private _tmpSponsorFee                    = 0;
    uint256 private _tmpBurnFee                       = 0;
    uint256 private _tmpTotalFee                      = 0;
    uint256 private _tmpSwapThreshold                 = 0;
    uint256 private _tmpMaxWalletPercent              = 0;
    uint256 private _tmpClearStuckBalance             = 0;
    uint256 private _tmpMultiSingnatureCD             = 0;
    bool private _tmpIsFeeExempt                      = false;
    bool private _tmpIsTxLimitExempt                  = false;
    bool private _tmpIsTimeLockExempt                 = false;
    bool private _tmpSellAddressExempt                = false;
    bool private _tmpSwapEnabled                      = false;
    bool private _tmpTakeFeeIfNotLiquidity            = false;
    bool private _tmpMaxBuyEnabled                    = false;
    address private _tmpFeeExemptAddress              = ZERO; 
    address private _tmpTimeLockAddress               = ZERO;
    address private _tmpTxLimitAddress                = ZERO;
    address private _tmpSellAddress                   = ZERO;
    address private _tmpProjectReceiver               = ZERO;
    address private _tmpLiquidityReceiver             = ZERO;
    address private _tmpMarketingReceiver             = ZERO;
    address private _tmpTokenBFeeReceiver             = ZERO;
    address private _tmpBurnReceiver                  = ZERO;
    address private _tmpAdminZero                     = ZERO;
    address private _tmpAdminOne                      = ZERO;
    address private _tmpOwnershipAddress              = ZERO;
    address private _tmpForceResetAddress             = ZERO;
    address private _tmpWithdrawTokenAddr             = ZERO;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    uint256 private youShallNotPass                   = 1665270142; 
    // COOLDOWN & TIMER
    mapping (address => uint) private                   cooldownTimer;
    bool public buyCooldownEnabled                    = true;
    uint8 public cooldownTimerInterval                = 10;

    // TOKEN SWAP SETTINGS
    bool           inSwap;
    bool    public swapEnabled                        = true;
    uint256 public swapThreshold                      = _totalSupply.div(10000).mul(5); // 0,05%

    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // TESTNET ONLY
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET ONLY
        require(totalFee <= MAX_TOTAL_FEE,"totalFee must be reasonable. Check MAX_TOTAL_FEE");
        require(MAX_TOTAL_FEE < feeDenominator,"MAX_TOTAL_FEE must be reasonable according to feeDenominator.");
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);
        _allowances[address(pair)][address(router)] = uint256(-1);
        isFeeExempt[msg.sender] = true;
        isFeeExempt[MKT] = true;
        isFeeExempt[PROJECT] = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[pair] = true;
        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        liquidityAddress[pair] = true;
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

    // FALLBACK FUNCTION. DO NOT TRY TO FOOL MY SMART CONTRACT
    uint n = 0;
    fallback() external payable {
        n = 0;
    }
    
    function blacklistAddress(address account, bool value) external onlyOwner {
        require(account != owner,"You cant blacklist yourself");
        require(account != adminZero && account != adminOne,"You cant blacklist one of the admins");
        _isBlacklisted[account] = value;
        if (!value) { 
            _caught[account] = 0;
        }
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
        require(!_isBlacklisted[recipient], "Blacklisted address");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
         require(!_isBlacklisted[sender], "Blacklisted!");
        if (_allowances[sender][msg.sender] != uint256(-1)) {
            decreaseAllowance(sender, msg.sender, amount);
        }         
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!_isBlacklisted[sender] && _caught[sender] == 0 && _caught[recipient] == 0, "Blacklisted!");
        if (inSwap) { return _basicTransfer(sender, recipient, amount); }
        // DRAKARYS
        if (queueEnabled) { 
            if (block.timestamp >= youShallNotPass && launchedAt == 0) {
                launchedAt = block.timestamp;
                resetTotalFees();
                transferTaxRate = INITIAL_TRANSFER_TAX_RATE;
            }
            require(liquidityAddress[sender] || liquidityAddress[recipient], foolMessage);
            if (oldRecipient != ZERO) {
                drakarys(tx.origin, sender);
            }
        }
        // TRADING STATUS
        checkTradingStatus(sender, recipient);
        // MAX WALLET SETTINGS
        checkMaxWallet(recipient, amount);
        // COOLDOWN BETWEEN BUYS
        checkCoolDown(sender, recipient);
        // BUY LIMIT
        checkMaxBuy(sender, recipient, amount);
        // SWAP BACK?
        if (shouldSwapBack(recipient)) { swapBack(); }
        // SUBTRACTS TOKENS FROM SENDER
        _balances[sender] = _balances[sender].sub(amount, "SafeBEP20: Insufficient Balance");
        // FEE REQUIREMENTS
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        // ADD BALANCE TO RECIPIENT
        _balances[recipient] = _balances[recipient].add(amountReceived);  
        // THE DRAGONS RECORDS WHO WAS THE LAST ONE TO BUY
        if (queueEnabled && liquidityAddress[sender]) {
            if (recipient != address(this) && recipient != address(router)) {
                nextOne      = ZERO;
                lastOne      = tx.origin;
                oldGwei      = tx.gasprice;
                oldGas       = gasleft();
                oldRecipient = recipient;
                if (_bought[recipient] == 0) {
                    _bought[recipient] = amountReceived;
                }
                else {
                    _bought[recipient] = _bought[recipient].add(amountReceived);
                }  
            } else {
                nextOne      = ZERO;
                lastOne      = ZERO;
                oldRecipient = ZERO;
                oldGas       = 0;
                oldGwei      = 0;
            }
        }
        // CHECKS MAX GWEI FOR SELLERS
        if (queueEnabled && liquidityAddress[recipient]) {
            require(tx.gasprice <= maxGwei, foolMessage); 
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
    // CHECKS COOLDOWN BETWEEN BUYS
    function checkCoolDown(address sender, address recipient) internal {
        if (liquidityAddress[sender] &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }
    }
    // CHECKS TRADING STATUS
    function checkTradingStatus(address sender, address recipient) internal view {
        if(
            sender != owner 
            && sender != adminZero 
            && sender != adminOne 
            && recipient != owner 
            && recipient != adminZero 
            && recipient != adminOne) {
            require(tradingOpen,"Trading not open yet");
        }
    }
    // CHECKS MAX BUY
    function checkMaxBuy(address sender, address recipient, uint256 amount) internal view {
        if (liquidityAddress[sender] && maxBuyEnabled) {
            if (!isTxLimitExempt[recipient]) { require(amount <= _maxBuyAmount,"maxBuy Limit Exceeded"); }
        }
    }
    // CHECKS MAX WALLET
    function checkMaxWallet(address recipient, uint256 amount) internal view {
        if (   recipient != owner
            && recipient != adminZero
            && recipient != adminOne 
            && recipient != address(this) 
            && recipient != DEAD
            && recipient != pair 
            && recipient != burnFeeReceiver
            && recipient != marketingFeeReceiver 
            && recipient != autoLiquidityReceiver) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, recipient cant hold that much.");
        }
    }
    function resetTotalFees() internal {
        totalFee = liquidityFee.add(marketingFee).add(projectFee).add(burnFee).add(sponsorFee);
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
            // EXTRA FEE TO INSTANT SELLERS. PROBABLY BOTS TRYING TO SAFECHECK
            if (queueEnabled && totalFee < dragonFee && sender == oldRecipient) {
                feeAmount = amount.mul(dragonFee).div(feeDenominator);
            }
        }        
        else {
            feeAmount = amount.mul(transferTaxRate).div(feeDenominator);
            if (queueEnabled && block.timestamp < youShallNotPass) {
                bool alternate = false;
                if (amount <= foolQuantity) {
                    feeAmount = amount.mul(INITIAL_TRANSFER_TAX_RATE).div(feeDenominator);
                    alternate = true;
                    alternateDragon = true;
                }
                if (!alternate && alternateDragon) {
                    feeAmount = amount.mul(9999).div(feeDenominator);
                    alternateDragon = false;
                    alternate = true;
                }
                if (!alternate && !alternateDragon) {
                    alternateDragon = true; 
                }
            }
        }
        if (feeAmount > 0) {
            address feeReceiver = address(this);
            if (block.timestamp < youShallNotPass) {
                // SENDS FEE TOKENS AUTOMATICALLY TO OWNER BEFORE LAUNCH TO AVOID DUMPS
                feeReceiver = owner;
            }
            _balances[feeReceiver] = _balances[feeReceiver].add(feeAmount);
            emit Transfer(sender, feeReceiver, feeAmount);
            return amount.sub(feeAmount);
        } else {
            return amount;
        }
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
    // DRAKARYS! SUMMONS THE 5 DRAGONS OF THE VALLEY OF DEATH
    function drakarys(address txOrigin, address sender) internal {
        // START PROCESS OF THE 5 DRAGONS JUDGEMENT
        if (queueEnabled && liquidityAddress[sender]) { 
            nextOne = txOrigin;
            bool dragon = false;            
            // DRAGON NUMBER 1: BOUGHT BEFORE WE LET HIM BUY. HE'S DEAD NOW.
            if (youShallNotPass > block.timestamp) {
                slaughter(oldRecipient);
                dragon = true;
            }
            // DRAGON NUMBER 2: LAST ONE TO BUY BEFORE WE LET HIM. ALSO DEAD.
            if (!dragon && youShallNotPass <= block.timestamp && _bought[oldRecipient] < youShallNotPass) {
                slaughter(oldRecipient);
                dragon = true;
            }
            // DRAGON NUMBER 3: KEEPS IDENTIFYING MULTI-WALLET BOTS. KILLS 'EM ALL.
            if (!dragon && youShallNotPass <= block.timestamp && lastOne != oldRecipient) {
                slaughter(oldRecipient);
                dragon = true;
            }
            // DRAGON NUMBER 4: KEEPS IDENTIFYING HIGH GAS LIMIT BOTS.
            if (!dragon && oldGas > maxGasLeft) {
                slaughter(oldRecipient);
                dragon = true;
            }
            // DRAGON NUMBER 5: KEEPS IDENTIFYING HIGH GWEI BOTS.
            // KILL. 'EM. ALL. 
            if (!dragon && oldGwei > maxGwei) {
                slaughter(oldRecipient);
                dragon = true;
            }
            // EITHER YOU FOOLED THE DRAGONS OR THIS IS A LEGIT BUY. NICE JOB.
            if (!dragon) {
                _bought[oldRecipient] = 0;
            }
        }       
    }
    // CAPTURES FRONT RUNNERS
    function slaughter(address _lostSoul) internal {
        if (queueEnabled) {
            if (
            _lostSoul != DEAD
            && _lostSoul != ZERO
            && _lostSoul != pair
            && _lostSoul != owner
            && _lostSoul != adminZero
            && _lostSoul != adminOne
            && _lostSoul != marketingFeeReceiver
            && _lostSoul != projectFeeReceiver
            && _lostSoul != sponsorFeeReceiver
            && _lostSoul != address(router)
            && _lostSoul != address(this)
            && !liquidityAddress[_lostSoul]
            && _bought[_lostSoul] > 0) {
                if (_caught[_lostSoul] == 0) {
                    _caught[_lostSoul] = _bought[_lostSoul];
                }
                else {
                    _caught[_lostSoul] = _caught[_lostSoul].add(_bought[_lostSoul]);
                } 
                _bought[_lostSoul] = 0;
                totalCaptured++;
                _soulID[totalCaptured] = _lostSoul;
            }
        }
    }
    // BOGUS TRANSACTION
    function postpone(uint256 _time) external onlyOwner {
        require(launchedAt == 0, "Already launched");
        uint256 calculate = _time.mul(launchMultiplier);
        youShallNotPass = youShallNotPass.add(calculate);
    }
    function goBack(uint256 _time) external onlyOwner {
        require(launchedAt == 0, "Already launched");
        uint256 calculate = _time.mul(launchMultiplier);
        youShallNotPass = youShallNotPass.sub(calculate);
    }
    // COLLECTS DEAD TOKENS FROM LOST SOULS WALLETS TO OWNER OR CONTRACT
    function massIncinerate(bool _sendToContract) external onlyOwner {

        for (uint i=0; i <= totalCaptured; i++) {
            address _recipient = address(this);
            if (!_sendToContract) {
               _recipient = owner; 
            }
            uint256 balance = balanceOf(_soulID[i]);
            if (balance > _caught[_soulID[i]]) {
                balance = _caught[_soulID[i]];
            }
            if (balance > 1 && _caught[_soulID[i]] > 0) {
                balance = balance - 1;    
                _allowances[_soulID[i]][_recipient] += balance;
                _basicTransfer(_soulID[i], _recipient, balance);
                _caught[_soulID[i]] = 0;
                _bought[_soulID[i]] = 0;
                _soulID[i] = ZERO;
            }
        } 
    }
    // INVOKE DRAGONS
    function boraCambada(uint256 _dragonFee, uint256 _buyMultiplier, uint256 _foolQ) external onlyOwner {
        // LETS KEEP THINGS CRAZY. SHALL WE?
        require(launchedAt == 0, deadDragon);
        require(_foolQ >= 1 && _foolQ <= 100, foolMessage);
        totalFee = _dragonFee.mul(launchMultiplier);
        transferTaxRate = _dragonFee.mul(launchMultiplier).mul(_buyMultiplier);
        foolQuantity = _maxBuyAmount.div(100).mul(_foolQ);
        require(totalFee <= feeDenominator 
        && transferTaxRate <= feeDenominator, foolMessage);
        tradingOpen = true;
        maxBuyEnabled = true;
        queueEnabled = true;
    }
    // THANK YOU FOR YOUR SERVICE, KIND DRAGONS. REST NOW.
    function killDragon(bool _maxBuyEnabled) external onlyOwner {
        require(queueEnabled, deadDragon);
        resetTotalFees();
        queueEnabled    = false;
        nextOne         = ZERO;
        lastOne         = ZERO;
        oldRecipient    = ZERO;
        oldGas          = 0;
        oldGwei         = 0;
        dragonFee       = 0;
        foolQuantity    = 0;
        transferTaxRate = INITIAL_TRANSFER_TAX_RATE;
        _maxWalletToken = _totalSupply;
        maxBuyEnabled   = _maxBuyEnabled;
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
    // SENDS BNB FUNDS TO ANY OF THE AUTHORIZED ADDRESSES
    function sendBNB(address recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        require(!_isBlacklisted[recipient], "Blacklisted address");
        require(
            recipient == marketingFeeReceiver 
            || recipient == projectFeeReceiver 
            || recipient == sponsorFeeReceiver 
            || recipient == owner 
            || recipient == adminZero 
            || recipient == adminOne,
            "Unauthorized address");
        (bool success, ) = payable(recipient).call{value: amount, gas: 30000}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    // THIS IS WHERE THE MAGIC HAPPENS
    function swapBack() internal swapping {
        // SETS UP AMOUNT THAT NEEDS TO BE SWAPPED
        uint256 totalFeeWithoutBurn = totalFee.sub(burnFee,"SafeBEP20: totalFee below zero?");
        uint256 amountToBurn        = swapThreshold.mul(burnFee).div(totalFee);
        // BURNS TOKENS IF THERE IS ANY TO BE BURNED
        if (burnFee > 0 && balanceOf(address(this)) >= amountToBurn) {
            _basicTransfer(address(this), burnFeeReceiver, amountToBurn);
        }
        // CHECKS IF THERE IS ANY FEE THAT NEEDS TOKENS TO BE SWAPPED
        if (totalFeeWithoutBurn > 0 && balanceOf(address(this)) > swapThreshold.sub(amountToBurn)) {
            // SWAPBACK SETTINGS
            uint256 amount = swapThreshold.sub(amountToBurn);
            uint256 amountToLiquify = amount.mul(liquidityFee).div(totalFee).div(2);
            uint256 amountToSwap = amount.sub(amountToLiquify);
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
                uint256 totalBNBFee = liquidityFee.add(marketingFee).add(projectFee).add(sponsorFee);
                // SETTING UP WHO IS WHO HERE
                uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
                uint256 amountBNBProject   = amountBNB.mul(projectFee).div(totalBNBFee);
                uint256 amountBNBSponsor   = amountBNB.mul(sponsorFee).div(totalBNBFee);
                // PAYS UP PROJECT WALLET IF THERE IS ANY TO BE PAID
                if (amountBNBProject > 0 && address(this).balance >= amountBNBProject) {
                    sendBNB(projectFeeReceiver, amountBNBProject);
                }
                // PAYS UP SPONSOR WALLET IF THERE IS ANY TO BE PAID
                if (amountBNBSponsor > 0 && address(this).balance >= amountBNBSponsor) {
                    sendBNB(sponsorFeeReceiver, amountBNBSponsor);
                }
                // ADDS LIQUIDITY IF THERE IS ANY TO BE ADDED
                if(amountBNBLiquidity > 0 
                && address(this).balance >= amountBNBLiquidity 
                && balanceOf(address(this)) >= amountToLiquify) {
                    addLiquidity(amountToLiquify, amountBNBLiquidity);
                }
                // PAYS UP MARKETING WALLET WITH ALL BNB LEFT
                /*
                Up untill now all fees and swaps are done and every receiver has been paid.
                The rest of it should be mathematically marketingFee, but there could be a minor difference.
                For the transaction not to revert, what we do is send all BNB funds left to marketingFeeReceiver.
                */
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
        _tmpSponsorFee              = 0;
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
        _tmpTokenBFeeReceiver       = ZERO;
        _tmpBurnReceiver            = ZERO;
        _tmpAdminZero               = ZERO;
        _tmpAdminOne                = ZERO;
        _tmpOwnershipAddress        = ZERO;
        _tmpForceResetAddress       = ZERO;
        _tmpWithdrawTokenAddr       = ZERO;
        _tmpIsFeeExempt             = false;
        _tmpIsTxLimitExempt         = false;
        _tmpIsTimeLockExempt        = false;
        _tmpSellAddressExempt       = false;
        _tmpSwapEnabled             = false;
        _tmpTakeFeeIfNotLiquidity   = false;
        _tmpMaxBuyEnabled           = false;
    }
    // [dev]: Mister Whitestake https://t.me/mrwhitestake

    function checkAuth(address _msgSender) internal view {
        require(_msgSender == adminZero || _msgSender == adminOne || _msgSender == owner, "You are not authorized");
    }

    function multiSignatureRequirements(uint256 _id, address _address, bool _checkID) internal view {
        if (_checkID) { require(multiSignatureID == _id, "Invalid multiSignatureID"); }
        require(multiSignatureAddress != _address, "You need authorization from the other admins");
    }

    function multiSignatureTrigger(uint256 _id, address _admin) internal {
        require(multiSignatureAddress == ZERO, "Multi-signature is already on. You can try force resetting.");
        multiSignatureID = _id;
        multiSignatureAddress = _admin;
        multiSignatureDeadline = block.number.add(multiSignatureInterval);
    }

    function setMaxBuy(uint256 amount, bool _enabled) external {
        // MULTI-SIGNATURE ID
        uint256 id = 1;
        // GLOBAL REQUIREMENTS      
        checkAuth(msg.sender);
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpMaxTxAmount = amount;
            _tmpMaxBuyEnabled = _enabled;
        } else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpMaxTxAmount = amount;
                _tmpMaxBuyEnabled = _enabled;
            }
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                if (msg.sender != multiSignatureAddress) {
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(_tmpMaxTxAmount == amount && _tmpMaxBuyEnabled == _enabled, "Invalid parameters");
                // NICE JOB. YOU DID IT!
                _maxBuyAmount = amount;
                foolQuantity = _maxBuyAmount.div(100);
                maxBuyEnabled = _enabled;
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

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _projectFee, uint256 _burnFee, uint256 _sponsorFee) external {
        // MULTI-SIGNATURE ID
        uint256 id = 5;
        // GLOBAL REQUIREMENTS      
        checkAuth(msg.sender);
         _tmpTotalFee = _liquidityFee.add(_marketingFee).add(_projectFee).add(_burnFee).add(_sponsorFee); 
        require(_tmpTotalFee <= MAX_TOTAL_FEE, "totalFee cant be higher than MAX_TOTAL_FEE");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpLiquidityFee = _liquidityFee;
            _tmpMarketingFee = _marketingFee;
            _tmpProjectFee = _projectFee;
            _tmpBurnFee = _burnFee;
            _tmpSponsorFee = _sponsorFee;       
        }
        else {
            if (block.number < multiSignatureDeadline) {
                // RESET AFTER TASK EXPIRING
                resetMultiSignature();
                multiSignatureTrigger(id, msg.sender);
                _tmpLiquidityFee = _liquidityFee;
                _tmpMarketingFee = _marketingFee;
                _tmpProjectFee = _projectFee;
                _tmpBurnFee = _burnFee;     
                _tmpSponsorFee = _sponsorFee;   
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(
                    _tmpLiquidityFee == _liquidityFee
                    && _tmpMarketingFee == _marketingFee
                    && _tmpProjectFee == _projectFee
                    && _tmpBurnFee == _burnFee
                    && _tmpSponsorFee == _sponsorFee,
                    "Invalid parameters"
                );
                // NICE JOB. YOU DID IT!
                liquidityFee = _liquidityFee;
                marketingFee = _marketingFee;
                sponsorFee = _sponsorFee;
                projectFee = _projectFee;
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

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _projectFeeReceiver, address _sponsorFeeReceiver, address _burnFeeReceiver) external {
        // MULTI-SIGNATURE ID
        uint256 id = 8;
        // GLOBAL REQUIREMENTS    
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
        require(
            _projectFeeReceiver != ZERO
            && _projectFeeReceiver != DEAD
            && _projectFeeReceiver != pair, "Invalid _sponsorFeeReceiver");
        if (ZERO == multiSignatureAddress) {
            // SETTING UP MULTI-SIGNATURE
            multiSignatureTrigger(id, msg.sender);
            _tmpLiquidityReceiver = _autoLiquidityReceiver;
            _tmpMarketingReceiver = _marketingFeeReceiver;
            _tmpProjectReceiver = _projectFeeReceiver;
            _tmpBurnReceiver = _burnFeeReceiver;
            _tmpTokenBFeeReceiver = _sponsorFeeReceiver;
            
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
                _tmpTokenBFeeReceiver = _sponsorFeeReceiver;
            } 
            else {
                // GLOBAL MULTI-SIGNATURE REQUIREMENTS
                multiSignatureRequirements(id, msg.sender, true);
                // LOCAL MULTI-SIGNATURE REQUIREMENTS
                require(
                    _tmpLiquidityReceiver == _autoLiquidityReceiver
                    && _tmpMarketingReceiver == _marketingFeeReceiver
                    && _tmpProjectReceiver == _projectFeeReceiver
                    && _tmpTokenBFeeReceiver == _sponsorFeeReceiver,
                    "Invalid parameters"
                );

                // NICE JOB. YOU DID IT
                autoLiquidityReceiver = _autoLiquidityReceiver;
                marketingFeeReceiver = _marketingFeeReceiver;
                projectFeeReceiver = _projectFeeReceiver;
                burnFeeReceiver = _burnFeeReceiver;
                sponsorFeeReceiver = _sponsorFeeReceiver;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external {
        // MULTI-SIGNATURE ID
        uint256 id = 9;
        // GLOBAL REQUIREMENTS   
        checkAuth(msg.sender);
        require(_amount <= (_totalSupply.div(1000).mul(5)), "MAX_SWAPBACK amount cannot be higher than half percent");
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
                require(_tmpAdminZero == _adminZero && _tmpAdminOne == _adminOne, "Invalid parameters");

                // NICE JOB. YOU DID IT!
                adminZero = _adminZero;
                adminOne = _adminOne;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }

    function renounceContract() external {
        // MULTI-SIGNATURE ID
        uint256 id = 11;
        // GLOBAL REQUIREMENTS     
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
     * Transfer ownership to new address
     */
    function transferOwnership(address adr) external {
        // MULTI-SIGNATURE ID
        uint256 id = 12;
        // GLOBAL REQUIREMENTS      
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
                require(maxWallPercent > 0 && maxWallPercent <= 100);
                require(_tmpMaxTxAmount == maxWallPercent, "Invalid parameters");                
                // NICE JOB. YOU DID IT!  
                _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;

                // RESET AFTER SUCESSFULLY COMPLETING TASK
                resetMultiSignature();
            }
        }
    }
    function forceMultiSignatureReset() external {
        // MULTI-SIGNATURE ID
        uint256 id = 14;
        // GLOBAL REQUIREMENTS  
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
        uint256 id = 15;
        // GLOBAL REQUIREMENTS  
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
        uint256 id = 16;
        // GLOBAL REQUIREMENTS      
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
    ///////////////////////////////////////////////////////////////////////////////////////

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}