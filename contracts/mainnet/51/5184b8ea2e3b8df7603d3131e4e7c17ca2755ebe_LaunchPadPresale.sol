/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// File: interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router02 {
   function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

// File: interfaces/ILaunchPadFactory.sol

pragma solidity =0.8.4;

interface ILaunchPadFactory {
    
    event feeReceiverChanged(address indexed previousFeeReceiver, address indexed newFeeReceiver);
    event presaleCreated(
        address _token,
        uint256 _buyLimit, 
        uint256 _hardCap, 
        uint256 _tokensPerEth, 
        uint256 _durationTime, 
        bool _referrals, 
        string _presaleInfo
    );
    event presaleAborted(address _presale, uint256 _timestamp);
    event presaleWhitelisted(address _presale);

    function feeReceiver() external view returns (address);
    function router() external view returns (address);  
    function factory() external view returns (address);  
    function weth() external view returns (address);  

    function getPresaleOwner(address _presale) external view returns (address owner);
    function isWhiteListed(address _presale) external view returns (bool whitelisted);
    function getPresales(address _owner, uint256 _index) external view returns  (address presales);
    function getPresalesLenght(address _owner) external view returns (uint256 length);
    function getPresaleNonce(address _token) external view returns  (uint16 nonce);

    function allPresales(uint256) external view returns (address presale);
    function allPresalesLength() external view returns (uint256);


    function abortPresale(address payable _presale) external;
    function emergencyAbort(address payable _presale) external;    
    function changePresaleInfo(address payable _presale, string memory _presaleInfo) external;
    function setFeeReceiver(address _feeReceiver) external;
    function whiteListPresale(address _presale) external;

    function setMinimumHardCap(uint256 _minimumHardCap) external;
    function getNextPresaleAddress(address _token) external view returns (address _address);
    function calculatePresaleAddress(address _token, uint16 _nonce) external view returns (address _address);

    function createPresale(
        address _token, 
        uint256 _buyLimit,
        uint256 _hardCap, 
        uint256 _tokensPerEth,
        uint256 _durationTime, 
        bool _referrals,
        string memory _presaleInfo
    ) external;
}





// File: interfaces/Address.sol


// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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
// File: interfaces/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
// File: interfaces/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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
}

// File: LaunchPadDPLP.sol

pragma solidity ^0.8.0;






contract LaunchPadDPLP {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier hasDripped {
        if (dividendPool > 0) {
          uint256 secondsPassed = SafeMath.sub(block.timestamp, lastDripTime);
          uint256 dividends = secondsPassed.mul(dividendPool).div(dailyRate);

          if (dividends > dividendPool) {
            dividends = dividendPool;
          }

          profitPerShare = SafeMath.add(profitPerShare, (dividends * magnitude) / tokenSupply);
          dividendPool = dividendPool.sub(dividends);
          lastDripTime = block.timestamp;
        }
        _;
    }

    modifier onlyTokenHolders {
        require(myShares() > 0);
        _;
    }

    modifier onlyDivis {
        require(myRewards() > 0);
        _;
    }

    event onDonation(
        address indexed userAddress,
        uint256 tokens
    );

    event onStake(
        address indexed userAddress,
        uint256 incomingTokens,
        uint256 timestamp
    );

    event onUnstake(
        address indexed customerAddress,
        uint256 tokenRemoved,
        uint256 timestamp
    );

    event onReinvest(
        address indexed customerAddress,
        uint256 tokensReinvested
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 tokensWithdrawn
    );

    uint256 constant private magnitude = 2 ** 64;
    uint32 constant private dailyRate = 11520000; //0.75% a day
    uint8 constant private buyInFee = 75;
    uint8 constant private sellOutFee = 75;
    uint8 constant private vaultFee = 25;

    mapping(address => uint256) private tokenBalanceLedger;
    mapping(address => int256) private payoutsTo;

    uint256 public dividendPool = 0;
    uint256 public lastDripTime = block.timestamp;
    uint256 public totalDonation = 0;
    uint256 public totalVaultFundReceived = 0;
    uint256 public totalVaultFundCollected = 0;

    uint256 private tokenSupply = 0;
    uint256 private profitPerShare = 0;

    IERC20 public pair;
    ILaunchPadFactory launchPadFactory;

    constructor(address _launchPadFactory, address _pair) {
        launchPadFactory= ILaunchPadFactory(_launchPadFactory);
        pair = IERC20(_pair);
    }

    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }

    function donateToPool(uint256 _amount) public {
        require(_amount > 0 && tokenSupply > 0, "must be a positive value and have supply");
        pair.safeTransferFrom(msg.sender, address(this), _amount);
        totalDonation += _amount;
        dividendPool = dividendPool.add(_amount);
        emit onDonation(msg.sender, _amount);
    }

    function payVault() public {
        uint256 _tokensToPay = tokensToPay();
        require(_tokensToPay > 0);
        pair.safeTransfer(launchPadFactory.feeReceiver(), _tokensToPay);
        totalVaultFundReceived = totalVaultFundReceived.add(_tokensToPay);
    }

    function reinvest() hasDripped onlyDivis public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myRewards();
        payoutsTo[_customerAddress] +=  (int256) (_dividends.mul(magnitude));
        uint256 _tokens = purchaseTokens(_customerAddress, _dividends);
        emit onReinvest(_customerAddress, _tokens);
    }

    function withdraw() hasDripped onlyDivis public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myRewards();
        payoutsTo[_customerAddress] += (int256) (_dividends.mul(magnitude));
        pair.safeTransfer(_customerAddress, _dividends);
        emit onWithdraw(_customerAddress, _dividends);
    }

    function deposit(uint256 _amount) hasDripped public returns (uint256) {
        pair.safeTransferFrom(msg.sender, address(this), _amount);
        return purchaseTokens(msg.sender, _amount);
    }

    function _purchaseTokens(address _customerAddress, uint256 _incomingTokens) private returns(uint256) {
        uint256 _amountOfTokens = _incomingTokens;

        require(_amountOfTokens > 0 && _amountOfTokens.add(tokenSupply) > tokenSupply);

        tokenSupply = tokenSupply.add(_amountOfTokens);
        tokenBalanceLedger[_customerAddress] =  tokenBalanceLedger[_customerAddress].add(_amountOfTokens);

        int256 _updatedPayouts = (int256) (profitPerShare.mul(_amountOfTokens));
        payoutsTo[_customerAddress] += _updatedPayouts;

        return _amountOfTokens;
    }

    function purchaseTokens(address _customerAddress, uint256 _incomingTokens) private returns (uint256) {
        require(_incomingTokens > 0);

        uint256 _dividendFee = _incomingTokens.mul(buyInFee).div(1000);

        uint256 _vaultFee = _incomingTokens.mul(vaultFee).div(1000);

        uint256 _entryFee = _incomingTokens.mul(100).div(1000);
        uint256 _taxedTokens = _incomingTokens.sub(_entryFee);

        uint256 _amountOfTokens = _purchaseTokens(_customerAddress, _taxedTokens);

        dividendPool = dividendPool.add(_dividendFee);
        totalVaultFundCollected = totalVaultFundCollected.add(_vaultFee);

        emit onStake(_customerAddress, _amountOfTokens, block.timestamp);

        return _amountOfTokens;
    }

    function remove(uint256 _amountOfTokens) hasDripped onlyTokenHolders public {
        address _customerAddress = msg.sender;
        require(_amountOfTokens > 0 && _amountOfTokens <= tokenBalanceLedger[_customerAddress]);

        uint256 _dividendFee = _amountOfTokens.mul(sellOutFee).div(1000);
        uint256 _vaultFee = _amountOfTokens.mul(vaultFee).div(1000);
        uint256 _taxedTokens = _amountOfTokens.sub(_dividendFee).sub(_vaultFee);

        tokenSupply = tokenSupply.sub(_amountOfTokens);
        tokenBalanceLedger[_customerAddress] = tokenBalanceLedger[_customerAddress].sub(_amountOfTokens);

        int256 _updatedPayouts = (int256) ((profitPerShare.mul(_amountOfTokens)).add(_taxedTokens.mul(magnitude)));
        payoutsTo[_customerAddress] -= _updatedPayouts;

        dividendPool = dividendPool.add(_dividendFee);
        totalVaultFundCollected = totalVaultFundCollected.add(_vaultFee);
          
        emit onUnstake(_customerAddress, _taxedTokens, block.timestamp);
    }

    function totalTokenBalance() public view returns (uint256) {
        return pair.balanceOf(address(this));
    }

    function totalSupply() public view returns(uint256) {
        return tokenSupply;
    }

    function myShares() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return sharesOf(_customerAddress);
    }

    function myEstimateRewards() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return estimateRewardsOf(_customerAddress);
    }

    function estimateRewardsOf(address _customerAddress) public view returns (uint256) {
        uint256 _profitPerShare = profitPerShare;

        if (dividendPool > 0) {
          uint256 secondsPassed = 0;
       
          secondsPassed = SafeMath.sub(block.timestamp, lastDripTime);

          uint256 dividends = secondsPassed.mul(dividendPool).div(dailyRate);

          if (dividends > dividendPool) {
            dividends = dividendPool;
          }

          _profitPerShare = SafeMath.add(_profitPerShare, (dividends * magnitude) / tokenSupply);
        }

        return (uint256) ((int256) (_profitPerShare * tokenBalanceLedger[_customerAddress]) - payoutsTo[_customerAddress]) / magnitude;
    }

    function myRewards() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return rewardsOf(_customerAddress) ;
    }

    function rewardsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare * tokenBalanceLedger[_customerAddress]) - payoutsTo[_customerAddress]) / magnitude;
    }

    function sharesOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger[_customerAddress];
    }

    function tokensToPay() public view returns(uint256) {
        return totalVaultFundCollected.sub(totalVaultFundReceived);
    }
}

// File: libraries/UniswapV2Library.sol

pragma solidity >=0.5.0;


library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint256(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'71e6e31358ee16b3d9300fae77629fc40a171f4cc53183576ba7ba5fb318c931' // init code hash
            )))));
    }
}
//71e6e31358ee16b3d9300fae77629fc40a171f4cc53183576ba7ba5fb318c931 BSC
//3eb475f0bc063c4f457199bae925b27d909f4af70ef7db78ba734972fc1a8543 GLMR
//c5443539aede6901cfc8cbd4f358bb6c6524f2d1bd7ecd1f6ebea4d34498726d MOVR
// File: LaunchPadPresale.sol



pragma solidity =0.8.4;









contract LaunchPadPresale is Ownable {
  using SafeMath for uint;
  using Address for address;
  using SafeERC20 for IERC20;

  IERC20 public token;
  ILaunchPadFactory private launchPadFactory;

  mapping (address => uint256) public paidAmount;
  mapping (address => uint256) public referralBonuses;

  address payable private padswap;
  address public dplpFarm;
  uint256 public tokenDecimals;
  uint256 public hardCap;
  uint256 public softCap;
  uint256 public buyLimit;
  uint256 public tokensPerEth;
  uint256 public endsAt;
  bool public referrals;
  string public presaleInfo;

  bool public _isFinished;
  bool public _isAborted;


  event Buy (uint256 amount, uint256 tokens);
  event Claim (uint256 tokens);
  event Refund (uint256 tokens);


  constructor() {
    launchPadFactory = ILaunchPadFactory(msg.sender);
    padswap = payable(launchPadFactory.feeReceiver());
  }

  /*
  _token [address] address of the token being sold,
  _buyLimit [uint256] buy limit in eth with 18 decimals,
  _hardCap [uint256] hard cap in eth with 18 decimals 
  _tokensPerEth [uint256] tokens to eth ratio
  _endsAt [uint256] expiration timepresale duration in seconds from 12hrs to 7days
  _presaleInfo [string] info about the presale, 
  */
  function initializePresale(address _token, uint256 _buyLimit, uint256 _hardCap, uint256 _tokensPerEth, uint256 _endsAt, bool _referrals, string memory _presaleInfo) external onlyOwner {
    token = IERC20(_token);
    tokenDecimals = 10**token.decimals(); 
    endsAt = _endsAt;
    buyLimit = _buyLimit;
    hardCap = _hardCap;
    tokensPerEth = _tokensPerEth;
    referrals = _referrals;
    presaleInfo = _presaleInfo;
    softCap = hardCap.div(4); //25% of hardCap
  
    _isAborted = false;
    _isFinished = false;

    require(calculateChange(_hardCap) == 0, "ERROR: hardCap can't generate change!");
    require(calculateChange(_buyLimit) == 0, "ERROR: buyLimit can't generate change!");
    fundPresale();
  }
  //calculates the amount of tokens and transfers them
  function fundPresale() internal {
    uint256 _tokensToSell = hardCap.mul(tokensPerEth).mul(tokenDecimals).div(1e18);
    uint256 _tokensToReceive = _tokensToSell.mul(172).div(100); //72% more to add liquidity
    token.safeTransferFrom(tx.origin, address(this), _tokensToReceive);
    //tokens are transfered back and forth to make sure deflationary tokens have whitelisted the presale
    uint256 _balanceBefore = token.balanceOf(tx.origin); 
    token.safeTransfer(tx.origin, _tokensToReceive);
    token.safeTransferFrom(tx.origin, address(this), _tokensToReceive);
    uint256 _balanceAfter = token.balanceOf(tx.origin); 
    require(_balanceBefore == _balanceAfter, "ERROR: Deflationary tokens require whitelisting");
  }

  //presale has not been ended or reached expiration date
  function canBuy() public view returns (bool) {
    return _isFinished == false && endsAt > block.timestamp;
  }
  //presale has not been ended and has either reached its hardcap or expiration date
  function canEnd() public view returns (bool) {
    return _isFinished == false && (address(this).balance >= hardCap || endsAt <= block.timestamp);
  }
  //presale has been manually aborted or has not reached its soft cap and time has expired
  function isAborted() public view returns (bool) {
    return _isAborted == true || (_isFinished == false && address(this).balance < softCap && endsAt <= block.timestamp);
  }

  receive() external payable {
    //don't allow users to send funds directly to the contract
    revert();
  }

  function boughtTokensOf(address _address) public view returns (uint256 boughtTokens) { 
    boughtTokens = paidAmount[_address].mul(tokensPerEth).mul(tokenDecimals).div(1e18);
    
    return boughtTokens;
  }

  function calculateChange(uint256 _amount) public view returns (uint256 change) {
    uint256 _preciseAmount = _amount.mul(tokensPerEth).mul(tokenDecimals);
    uint256 _extraDecimals = _preciseAmount.mod(1e18);
    change = _extraDecimals.div(tokensPerEth).div(tokenDecimals);

    return change;
  }

  function buy (address _referral) external payable {
    require(canBuy(), "ERROR: This Presale is not active");
    require(!isAborted(), "ERROR: This Presale has been cancelled");
    require(address(this).balance <= hardCap, "ERROR: The amount you are trying to buy exceeds the hardcap");
    require(paidAmount[msg.sender] + msg.value <= buyLimit, "ERROR: You have reached your buy limit");
    require(!address(msg.sender).isContract() && msg.sender == tx.origin, "ERROR: Contracts are not allowed");
    uint256 _change = calculateChange(msg.value);
    uint256 _cost = msg.value.sub(_change);
    uint256 newPaidAmount = SafeMath.add(_cost, paidAmount[msg.sender]);
    paidAmount[msg.sender] = newPaidAmount;
    if(_change > 0){
      payable(msg.sender).transfer(_change);
    }
    if(referrals) {
      if(_referral == address(tx.origin)) {
        _referral = address(0); 
      }
      referralBonuses[_referral] += msg.value.div(100);
    }
    emit Buy(msg.value, msg.value.mul(tokensPerEth));
  }

  function claimTokens () external {
    //if _isFinished is false adds initialize the dplp
    if(!_isFinished) {
      initializeDPLP();
    } 
    //after the successfull initialization of the dplp _isFinished will be true
    require(_isFinished, "ERROR: This presale is still live");

    uint256 _tokensToClaim = boughtTokensOf(msg.sender);

    require(_tokensToClaim > 0, "ERROR: No tokens left to claim");
    
    paidAmount[msg.sender] = 0;
    token.safeTransfer(msg.sender, _tokensToClaim);

    emit Claim(_tokensToClaim);
  }

  function claimReferralBonus () external {
    require(_isFinished, "ERROR: Claims are not enabled yet");

    uint256 _bonusToClaim = referralBonuses[msg.sender];

    require(_bonusToClaim > 0, "ERROR: No bonuses left to claim");
    
    referralBonuses[msg.sender] = 0;
    payable(msg.sender).transfer(_bonusToClaim);

    //add event
  }

  function claimRefund () external {
    require(isAborted(), "ERROR: This presale has not been cancelled");
    
    uint256 _refundToClaim = paidAmount[msg.sender];

    require(_refundToClaim > 0, "ERROR: No refunds left to claim");
    
    address payable refundAddress = payable(msg.sender);
    paidAmount[msg.sender] = 0;
    refundAddress.transfer(_refundToClaim);

    emit Refund(_refundToClaim);
  }
  
  function initializeDPLP() public {
    require(canEnd(), "ERROR: This presale can't be ended yet");
    require(!isAborted(), "ERROR: This presale has been aborted");

    uint256 padswapShare;
    uint256 referralsShare;

    //80% dplp 16% devs, 4% padswap (3% if referrals are enabled)
    uint256 onePercent = address(this).balance.div(100);
    if(referrals) {
      padswapShare = onePercent.mul(3);
      referralsShare = onePercent;
      padswapShare = padswapShare.add(referralBonuses[address(0)]);
    } else {
      padswapShare = onePercent.mul(4);
      referralsShare = 0;
    }
    uint256 devShare = onePercent.mul(16);
    uint256 liquidityShare = onePercent.mul(80);

    //Set price 10% higher than presale
    uint newRate = tokensPerEth.mul(90).div(100);
    uint liquidityTokens = newRate.mul(liquidityShare).mul(tokenDecimals).div(1e18);

    if (liquidityTokens > token.balanceOf(address(this))) {
      liquidityTokens = token.balanceOf(address(this));
      liquidityShare = liquidityTokens.div(newRate);
    }

    require(newRate < tokensPerEth && liquidityTokens.mul(1e18).div(liquidityShare).div(tokenDecimals) == newRate, "ERROR: Invalid rate");

    //gets pair address before creation
    address pair = UniswapV2Library.pairFor(launchPadFactory.factory(), address(token), launchPadFactory.weth());

    //if a pair has already been created for the token during the presale all liquidity funds are going to be sent to padswap for manual adjustments
    bool pairIsContract = pair.isContract();
    uint256 pairSupply;
    if(pairIsContract) {
     pairSupply = IERC20(pair).totalSupply(); //check if the contract already has liquidity
    }
    if(pairIsContract && pairSupply > 0){
      token.safeTransfer(padswap, liquidityTokens);
      padswap.transfer(liquidityShare);
    } else {
      //create dplp contract
      LaunchPadDPLP dplp =  new LaunchPadDPLP(address(launchPadFactory), pair);
      dplpFarm = address(dplp);

      //Create padswap pair and add liquidity
      token.approve(launchPadFactory.router(), liquidityTokens);
      IUniswapV2Router02(launchPadFactory.router()).addLiquidityETH{value: liquidityShare}(
        address(token), 
        liquidityTokens, 
        0, 
        0, 
        address(this), 
        block.timestamp + 20 minutes
      );

      //donate liquidity to dplp
      uint256 lpBalance =  IERC20(pair).balanceOf(address(this));
      IERC20(pair).approve(address(dplp), lpBalance);
      //stakes 1e-18, dplp requires some stake before donation
      dplp.deposit(1);
      lpBalance = lpBalance.sub(1);
      dplp.donateToPool(lpBalance);
    }
    //Send dev funds
    address payable dev = payable (launchPadFactory.getPresaleOwner(address(this)));
    dev.transfer(devShare);

    //Send padswap funds
    padswap.transfer(padswapShare);

    //Ends presale
    _isFinished = true;
  }

  function changePresaleInfo(string memory _presaleInfo) external onlyOwner {
    require(!_isFinished, "ERROR: this presale has already ended");
    presaleInfo = _presaleInfo;
  }

  function abortPresale() external onlyOwner {
    require(!_isFinished, "ERROR: this presale has already ended");
    address _owner = launchPadFactory.getPresaleOwner(address(this));
    uint256 _tokensToSend = token.balanceOf(address(this));
    token.safeTransfer(_owner, _tokensToSend);
    _isAborted = true;
  }
//surpass any checks and aborts presale, can only be called by padswap, used for emergencies where some token might have some problem
  function emergencyAbort() external onlyOwner {
    _isAborted = true;
  }
}