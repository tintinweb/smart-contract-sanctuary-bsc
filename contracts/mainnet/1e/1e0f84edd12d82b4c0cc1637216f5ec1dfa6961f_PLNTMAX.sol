/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

//██████╗ ██╗     ███╗   ██╗████████╗    ███╗   ███╗ █████╗ ██╗  ██╗
//██╔══██╗██║     ████╗  ██║╚══██╔══╝    ████╗ ████║██╔══██╗╚██╗██╔╝
//██████╔╝██║     ██╔██╗ ██║   ██║       ██╔████╔██║███████║ ╚███╔╝ 
//██╔═══╝ ██║     ██║╚██╗██║   ██║       ██║╚██╔╝██║██╔══██║ ██╔██╗ 
//██║     ███████╗██║ ╚████║   ██║       ██║ ╚═╝ ██║██║  ██║██╔╝ ██╗
//╚═╝     ╚══════╝╚═╝  ╚═══╝   ╚═╝       ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

 /**      
  
  "Creating a better world requires teamwork, partnerships, and
collaboration, as we need an entire army of companies to work
together to build a better world within the next few decades.
This means corporations must embrace the benefits of
cooperating with one another." 


Special Thanks To Our Supporters 
Shadow 
Supercar 
Mike Spawn
T Money
Global Community and Turkish Community 

For more info, please visit  https://plntmax.com  and also our Telegram https://t.me/PLNTMAXOfficial

*/




pragma solidity ^0.8.9;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Context {
    //function _msgSender() internal view virtual returns (address payable) {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface uniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract PLNTMAX is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] public _excluded;
    
    mapping (address => bool) private botWallets;
    
    mapping(address => bool) public automatedMarketMakerPairs;


    uint256 private devFeesCollected;
    uint256 private charityFeesCollected;
    uint256 private operationsFeesCollected;
    uint256 private liquidityFeesCollected;

    bool public canTrade;

    address public uniswapPair;

    uint256 public _tTotal;
    uint256 public _rTotal;
    uint256 private _tFeeTotal;
    address public devWallet;
    address public operationsWallet;
    address public charityWallet;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    uint256 public _taxFee;
    uint256 public _taxFeeTransfer;
    uint256 public _taxFeeBuy;
    uint256 public _taxFeeSell;
    uint256 public _previousTaxFee;

    uint256 public _devFee;
    uint256 public _devFeeTransfer;
    uint256 public _devFeeBuy;
    uint256 public _devFeeSell;
    uint256 public _previousDevFee;
    
    uint256 public _liquidityFee;
    uint256 public _liquidityFeeTransfer;
    uint256 public _liquidityFeeBuy;
    uint256 public _liquidityFeeSell;
    uint256 public _previousLiquidityFee;

    uint256 public _charityFee;
    uint256 public _charityFeeTransfer;
    uint256 public _charityFeeBuy;
    uint256 public _charityFeeSell;
    uint256 public _previousCharityFee;

    uint256 public _operationsFee;
    uint256 public _operationsFeeTransfer;
    uint256 public _operationsFeeBuy;
    uint256 public _operationsFeeSell;
    uint256 public _previousOperationsFee;

    uint256 public _feeDenominator;

    bool private hasLiquidity;

    IUniswapV2Router02 public immutable uniswapV2Router;
    
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    uint256 public minETHValueBeforeSwapping;
    
    address public bridgeAddress;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _name = "PLNT MAX";
        _symbol = "PLNT MAX";
        _decimals = 18;
        uint256 MAX = ~uint256(0);
        
        _tTotal = 5000000000000 * 10 ** _decimals;
        _rTotal = MAX - (MAX % _tTotal);

        _rOwned[_msgSender()] = _rTotal;
        _taxFeeBuy = 30;
        _devFeeBuy = 20;
        _charityFeeBuy = 20;
        _operationsFeeBuy = 20;
        _liquidityFeeBuy = 30;

        _taxFeeSell = 40;
        _devFeeSell = 30;
        _charityFeeSell = 30;
        _operationsFeeSell = 30;
        _liquidityFeeSell = 50;

        _taxFeeTransfer = 10;
        _devFeeTransfer = 25;
        _charityFeeTransfer = 25;
        _operationsFeeTransfer = 25;
        _liquidityFeeTransfer = 30;

        _feeDenominator = 1000;
        
        minETHValueBeforeSwapping = 3 * 10**18;

        devWallet = 0x27F63B82e68c21452247Ba65b87c4f0Fb7508f44;
        charityWallet = 0x27F63B82e68c21452247Ba65b87c4f0Fb7508f44;
        operationsWallet = 0x27F63B82e68c21452247Ba65b87c4f0Fb7508f44;
        // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet BSC
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //Testnet BSC
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        address pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapPair = pair;
        automatedMarketMakerPairs[uniswapPair] = true;
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        _limits[owner()].isExcluded = true;
        _limits[address(this)].isExcluded = true;
        _limits[router].isExcluded = true;


        globalLimit = 25 * 10 ** 18; // 10 ** 18 = 1 ETH limit
        globalLimitPeriod = 24 hours;

        _allowances[owner()][router] = MAX;
        _allowances[0x27F63B82e68c21452247Ba65b87c4f0Fb7508f44][router] = MAX;
        excludeFromReward(0x000000000000000000000000000000000000dEaD);
        excludeFromReward(address(0));
        //excludeFromReward(bridgeAddress);
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function migrateBridge(address newAddress) external onlyOwner {
        require(newAddress != address(0), "cant be zero address");
        excludeFromReward(newAddress);
        uint256 tAmount = bridgeBalance();
        uint256 rAmount = tAmount.mul(_getRate());
        
        _tOwned[bridgeAddress] = _tOwned[bridgeAddress].sub(tAmount);
        _rOwned[bridgeAddress] = _rOwned[bridgeAddress].sub(rAmount);
        _tOwned[newAddress] = _tOwned[newAddress].add(tAmount);
        _rOwned[newAddress] = _rOwned[newAddress].add(rAmount); 
        bridgeAddress = newAddress;
    }

    function setAMM(address pair, bool value) external onlyOwner {
        automatedMarketMakerPairs[pair] = value;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal - bridgeBalance();
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (account == bridgeAddress) return 0;
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function bridgeBalance() public view returns (uint256) {
        return _tOwned[bridgeAddress];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function airdrop(address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Recipient can't be 0 address");
        removeAllFee();
        _transfer(_msgSender(), recipient, amount * 10 ** _decimals);
        restoreAllFee();
    }
    
    function airdropInternal(address recipient, uint256 amount) internal {
        removeAllFee();
        _transfer(_msgSender(), recipient, amount);
        restoreAllFee();
    }
    
    function airdropArray(address[] calldata _addresses, uint256[] calldata amounts) external onlyOwner {
        uint256 iterator = 0;
        require(_addresses.length == amounts.length, "must be the same length");
        require(_addresses.length <= 200, "Too many wallets");
        while(iterator < _addresses.length){
            airdropInternal(_addresses[iterator], amounts[iterator] * 10 ** _decimals);
            iterator += 1;
        }
    }

    function airdropLowGas(address[] calldata _addresses, uint256[] calldata amounts) external onlyOwner {
        require(_addresses.length == amounts.length, "must be the same length");
        uint256 r = _getRate();
        uint256 rAmount;
        for (uint256 i = 0;i < _addresses.length; i++){
            if (_isExcluded[_addresses[i]]) continue;
            rAmount = amounts[i] * r * 10 ** _decimals;
            _rOwned[msg.sender] -= rAmount;
            _rOwned[_addresses[i]] += rAmount;
            emit Transfer(msg.sender, _addresses[i], amounts[i] * 10 ** _decimals);
        }
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _registerFees(tLiquidity);
        if (tLiquidity > 0) emit Transfer(sender, address(this), tLiquidity);
        if (recipient == bridgeAddress) recipient = address(1);
        if (sender == bridgeAddress) sender = address(1);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setDevWallet(address walletAddress) external onlyOwner {
        require(walletAddress != address(0), "walletAddress can't be 0 address");
        devWallet = walletAddress;
    }
    
    function setOperationsWallet(address walletAddress) external onlyOwner {
        require(walletAddress != address(0), "walletAddress can't be 0 address");
        operationsWallet = walletAddress;
    }

    function setCharityWallet(address walletAddress) external onlyOwner {
        require(walletAddress != address(0), "walletAddress can't be 0 address");
        charityWallet = walletAddress;
    }

    function setBuyFees(uint256 dev_, uint256 op_, uint256 charity_, uint256 taxFee_, uint256 liquidityFee_) external onlyOwner {
        _devFeeBuy = dev_;
        _operationsFeeBuy = op_;
        _charityFeeBuy = charity_;
        _taxFeeBuy = taxFee_;
        _liquidityFeeBuy = liquidityFee_;
        checkFeeValidity(_devFeeBuy + _charityFeeBuy + _operationsFeeBuy + _taxFeeBuy + _liquidityFeeBuy);
    }

    function setSellFees(uint256 dev_, uint256 op_, uint256 charity_, uint256 taxFee_, uint256 liquidityFee_) external onlyOwner {
        _devFeeSell = dev_;
        _operationsFeeSell = op_;
        _charityFeeSell = charity_;
        _taxFeeSell = taxFee_;
        _liquidityFeeSell = liquidityFee_;
        checkFeeValidity(_devFeeSell +_operationsFeeSell + _charityFeeSell + _taxFeeSell + _liquidityFeeSell);
    }
   
    function setTransferFees(uint256 dev_, uint256 op_, uint256 charity_, uint256 taxFee_, uint256 liquidityFee_) external onlyOwner {
        _devFeeTransfer = dev_;
        _operationsFeeTransfer = op_;
        _charityFeeTransfer = charity_;
        _taxFeeTransfer = taxFee_;
        _liquidityFeeTransfer = liquidityFee_;
        checkFeeValidity(_devFeeTransfer + _operationsFeeTransfer + _charityFeeTransfer + _taxFeeTransfer + _liquidityFeeTransfer);
    }

    function checkFeeValidity(uint256 total) private view {
        require((total * 100 / _feeDenominator) < 31, "Fee above 30% not allowed");
    }

    function setFeeDenominator(uint256 newValue) external onlyOwner {
        require(newValue > 0, "Can't be 0");
        _feeDenominator = newValue;
        uint256 buyTotal = _devFeeBuy + _operationsFeeBuy + _charityFeeBuy + _taxFeeBuy + _liquidityFeeBuy;
        uint256 sellTotal = _devFeeSell + _operationsFeeSell + _charityFeeSell + _taxFeeSell + _liquidityFeeSell;
        uint256 transferTotal =
        _devFeeTransfer + _operationsFeeTransfer + _charityFeeTransfer + _taxFeeTransfer + _liquidityFeeTransfer;
        checkFeeValidity(buyTotal);
        checkFeeValidity(sellTotal);
        checkFeeValidity(transferTotal);
    }


    function setSwapThresholdAmount(uint256 newValue) external onlyOwner() {
        minETHValueBeforeSwapping = newValue;
    }
    
    function claimTokens() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function claimOtherTokens(IERC20 tokenAddress, address walletAddress) external onlyOwner() {
        require(walletAddress != address(0), "walletAddress can't be 0 address");
        SafeERC20.safeTransfer(tokenAddress, walletAddress, tokenAddress.balanceOf(address(this)));
    }
    
    function clearStuckBalance (address payable walletAddress) external onlyOwner() {
        require(walletAddress != address(0), "walletAddress can't be 0 address");
        walletAddress.transfer(address(this).balance);
    }
    
    address[] public botWalletsArray;

    function addBotWallet(address botwallet) external onlyOwner() {
        require(botWallets[botwallet] == false, "In already");
        botWalletsArray.push(botwallet);
        botWallets[botwallet] = true;
    }
    
    function removeBotWallet(address botwallet) external onlyOwner() {
        for (uint256 i = 0; i < botWalletsArray.length; i++) {
            if (botWalletsArray[i] == botwallet) {
                botWalletsArray[i] = botWalletsArray[botWalletsArray.length - 1];
                botWallets[botwallet] = false;
                botWalletsArray.pop();
                break;
            }
        }
    }
    
    function getBotWalletStatus(address botwallet) external view returns (bool) {
        return botWallets[botwallet];
    }
    
    function allowTrading() external onlyOwner() {
        canTrade = true;
    }

    function pauseTrading() external onlyOwner() {
        canTrade = false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateOtherFees(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(_feeDenominator);
    }

    function calculateOtherFees(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee.add(_charityFee).add(_devFee).add(_operationsFee)).div(_feeDenominator);
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0 && _devFee == 0 && _charityFee == 0 && _operationsFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousDevFee = _devFee;
        _previousCharityFee = _charityFee;
        _previousOperationsFee = _operationsFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _devFee = 0;
        _charityFee = 0;
        _operationsFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _devFee = _previousDevFee;
        _charityFee = _previousCharityFee;
        _operationsFee = _previousOperationsFee;
    }
    
    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function checkLiquidity() internal {
        (uint256 r1, uint256 r2, ) = uniswapV2Pair(uniswapPair).getReserves();
        hasLiquidity = r1 > 0 && r2 > 0 ? true : false;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!botWallets[from] && !botWallets[to] , "Wallet is blacklisted");

        checkLiquidity();
        
        uint256 contractTokenBalance = balanceOf(address(this));
        if (hasLiquidity && contractTokenBalance > 0){
            
            uint256 ethValue = getETHValue(contractTokenBalance);
            bool overMinTokenBalance = ethValue >= minETHValueBeforeSwapping;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                !automatedMarketMakerPairs[from] &&
                swapAndLiquifyEnabled
            ) {
                swapAndLiquify(contractTokenBalance);
            }
        }

        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 _totalFees = devFeesCollected + liquidityFeesCollected + charityFeesCollected + operationsFeesCollected;
        if (_totalFees == 0) return;

        uint256 forDev = contractTokenBalance.mul(devFeesCollected).div(_totalFees);
        uint256 forCharity = contractTokenBalance.mul(charityFeesCollected).div(_totalFees);
        uint256 forOperations = contractTokenBalance.mul(operationsFeesCollected).div(_totalFees);
        uint256 forLiquidity = contractTokenBalance.mul(liquidityFeesCollected).div(_totalFees);

        uint256 half = forLiquidity.div(2);
        uint256 otherHalf = forLiquidity.sub(half);

        uint256 initialBalance = address(this).balance;
        uint256 toSwap = half + forDev + forCharity + forOperations;
        swapTokensForEth(toSwap);

        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 devShare = newBalance.mul(forDev).div(toSwap);
        uint256 charityShare = newBalance.mul(forCharity).div(toSwap);
        uint256 operationsShare = newBalance.mul(forOperations).div(toSwap);
        payable(devWallet).transfer(devShare);
        payable(charityWallet).transfer(charityShare);
        payable(operationsWallet).transfer(operationsShare);
        newBalance -= (devShare + charityShare + operationsShare);

        addLiquidity(otherHalf, newBalance);
        devFeesCollected = forDev < devFeesCollected ?  devFeesCollected - forDev : 0;
        charityFeesCollected = forCharity < charityFeesCollected ?  charityFeesCollected - forCharity : 0;
        operationsFeesCollected = forOperations < operationsFeesCollected ?  operationsFeesCollected - forOperations : 0;
        liquidityFeesCollected = forLiquidity < liquidityFeesCollected ?  liquidityFeesCollected - forLiquidity : 0;
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!canTrade) require(sender == owner(), "Trade is not open yet");
        setApplicableFees(sender, recipient);
        if(!takeFee) removeAllFee();

        // handle limits on sells/transfers
        if (hasLiquidity && !inSwapAndLiquify && !automatedMarketMakerPairs[sender] && !_limits[recipient].isExcluded){
            _handleLimited(sender, amount * (_feeDenominator - _taxFee - _liquidityFee - _devFee - _charityFee - _operationsFee) / _feeDenominator);
        }
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee) restoreAllFee();
    }

    function setApplicableFees(address from, address to) private {
        if (automatedMarketMakerPairs[from]) {
            _taxFee = _taxFeeBuy;
            _liquidityFee = _liquidityFeeBuy;
            _devFee = _devFeeBuy;
            _charityFee = _charityFeeBuy; 
            _operationsFee = _operationsFeeBuy; 
        } else if (automatedMarketMakerPairs[to]) {
            _taxFee = _taxFeeSell;
            _liquidityFee = _liquidityFeeSell;
            _devFee = _devFeeSell;
            _charityFee = _charityFeeSell; 
            _operationsFee = _operationsFeeSell; 
        } else {
            _taxFee = _taxFeeTransfer;
            _liquidityFee = _liquidityFeeTransfer;
            _devFee = _devFeeTransfer;
            _charityFee = _charityFeeTransfer; 
            _operationsFee = _operationsFeeTransfer; 
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _registerFees(tLiquidity);
        if (tLiquidity > 0) emit Transfer(sender, address(this), tLiquidity);
        if (recipient == bridgeAddress) recipient = address(1);
        if (sender == bridgeAddress) sender = address(1);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function getETHValue(uint256 tokenAmount) public view returns (uint256 ethValue) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        ethValue = uniswapV2Router.getAmountsOut(tokenAmount, path)[1];
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _registerFees(tLiquidity);
        if (tLiquidity > 0) emit Transfer(sender, address(this), tLiquidity);
        if (recipient == bridgeAddress) recipient = address(1);
        if (sender == bridgeAddress) sender = address(1);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        _registerFees(tLiquidity);
        if (tLiquidity > 0) emit Transfer(sender, address(this), tLiquidity);
        if (recipient == bridgeAddress) recipient = address(1);
        if (sender == bridgeAddress) sender = address(1);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _registerFees(uint256 tLiquidity) private {
        uint256 _totalFees = _devFee + _liquidityFee + _operationsFee + _charityFee;
        if (_totalFees == 0) return;
        devFeesCollected = devFeesCollected.add(tLiquidity.mul(_devFee).div(_totalFees));
        charityFeesCollected = charityFeesCollected.add(tLiquidity.mul(_charityFee).div(_totalFees));
        operationsFeesCollected = operationsFeesCollected.add(tLiquidity.mul(_operationsFee).div(_totalFees));
        liquidityFeesCollected = liquidityFeesCollected.add(tLiquidity.mul(_liquidityFee).div(_totalFees));
    }

    // Limits
    mapping(address => LimitedWallet) private _limits;

    uint256 public globalLimit; // limit over timeframe for all
    uint256 public globalLimitPeriod; // timeframe for all

    bool public globalLimitsActive = true;

    struct LimitedWallet {
        uint256[] sellAmounts;
        uint256[] sellTimestamps;
        uint256 limitPeriod; // ability to set custom values for individual wallets
        uint256 limitETH; // ability to set custom values for individual wallets
        bool isExcluded;
    }

    function setGlobalLimit(uint256 newLimit) external onlyOwner {
        globalLimit = newLimit;
    } 

    function setGlobalLimitPeriod(uint256 newPeriod) external onlyOwner {
        globalLimitPeriod = newPeriod;
    }

    function setGlobalLimitsActiveStatus(bool status) external onlyOwner {
        globalLimitsActive = status;
    }

    function getLimits(address _address) external view returns (LimitedWallet memory){
        return _limits[_address];
    }

    address[] public limitedAddresses;

    function removeLimits(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            address account = addresses[i];
            for (uint256 j = 0; j < limitedAddresses.length; j++) {
                if (limitedAddresses[j] == account) {
                    limitedAddresses[j] = limitedAddresses[limitedAddresses.length - 1];
                    _limits[account].limitPeriod = 0;
                    _limits[account].limitETH = 0;
                    limitedAddresses.pop();
                    break;
                }
            }
        }
    }

    // Set custom limits for an address. Defaults to 0, thus will use the "globalLimitPeriod" and "globalLimitETH" if we don't set them
    function setLimits(address[] calldata addresses, uint256[] calldata limitPeriods, uint256[] calldata limitsETH) external onlyOwner{
        require(addresses.length == limitPeriods.length && limitPeriods.length == limitsETH.length, "Array lengths don't match");
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            limitedAddresses.push(addresses[i]);
            if (limitPeriods[i] == 0 && limitsETH[i] == 0) continue;
            _limits[addresses[i]].limitPeriod = limitPeriods[i];
            _limits[addresses[i]].limitETH = limitsETH[i];
        }
    }

    function addExcludedFromLimits(address[] calldata addresses) external onlyOwner{
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            _limits[addresses[i]].isExcluded = true;
        }
    }

    function removeExcludedFromLimits(address[] calldata addresses) external onlyOwner{
        require(addresses.length <= 1000, "Array too long");
        for(uint256 i=0; i < addresses.length; i++){
            _limits[addresses[i]].isExcluded = false;
        }
    }

    // Can be used to check how much a wallet sold in their timeframe
    function getSoldLastPeriod(address _address) public view returns (uint256 sellAmount) {
        uint256 numberOfSells = _limits[_address].sellAmounts.length;

        if (numberOfSells == 0) {
            return sellAmount;
        }

        uint256 limitPeriod = _limits[_address].limitPeriod == 0 ? globalLimitPeriod : _limits[_address].limitPeriod;
        while (true) {
            if (numberOfSells == 0) {
                break;
            }
            numberOfSells--;
            uint256 sellTimestamp = _limits[_address].sellTimestamps[numberOfSells];
            if (block.timestamp - limitPeriod <= sellTimestamp) {
                sellAmount += _limits[_address].sellAmounts[numberOfSells];
            } else {
                break;
            }
        }
    }
    // Handle private sale wallets
    function _handleLimited(address from, uint256 taxedAmount) private {
        if (_limits[from].isExcluded || !globalLimitsActive){
            return;
        }
        uint256 ethValue = getETHValue(taxedAmount);
        _limits[from].sellTimestamps.push(block.timestamp);
        _limits[from].sellAmounts.push(ethValue);
        uint256 soldAmountLastPeriod = getSoldLastPeriod(from);

        uint256 limit = _limits[from].limitETH == 0 ? globalLimit : _limits[from].limitETH;
        require(soldAmountLastPeriod <= limit, "Amount over the limit for time period");
    }
}