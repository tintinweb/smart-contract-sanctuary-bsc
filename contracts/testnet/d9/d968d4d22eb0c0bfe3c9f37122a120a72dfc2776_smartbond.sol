/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

// File: smartbond.sol


pragma solidity 0.8.16;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    /**
     * @dev Increment an unsigned integer up by 1.
     *
     * Counterpart to Solidity's `++` operator. This function utilized unchecked
     * arithmetics to save gas over checked arithmetics. We can do this since
     * version ^0.8.0 has fixed overflow errors.
     *
     * Requirements:
     *
     * - The unsigned integer must be less than 2**156-1
     */
    function inc(uint256 x) 
        internal 
        pure 
        returns (uint256) 
    {
        unchecked{ return x + 1; }
    }

    /**
     * @dev Decrease an unsigned integer by 1.
     *
     * Counterpart to Solidity's `--` operator. This function utilized unchecked
     * arithmetics to save gas over checked arithmetics. We can do this since
     * version ^0.8.0 has fixed underflow errors.
     *
     * Requirements:
     *
     * - The unsigned integer must be greater than 0
     */
    function dec(uint256 x) 
        internal 
        pure 
        returns (uint256) 
    {
        unchecked{ return x - 1; }
    }
}

/****************************
Guardian: Because Sentient Intelligence cannot be owned, but it can be protected.

Protects against unauthorized access to admin functions.
Protects against reentrancy attacks.
Provides support for pausing the contract as needed.
Provides Multi-Signature support.
****************************/
abstract contract Guardian {
    using SafeMath for uint;
    uint public minApprovals;
    uint internal constant _FALSE = 0;
    uint internal constant _TRUE = 1;
    uint internal paused;
    uint private entered;
    address private immutable deployer;
    address[] private guardians;
    mapping(address => uint) private isGuardian;

    struct Transaction {
        string fnName;
        address loc;
        uint value;
        uint approvals;
        uint executed;
    }
    Transaction[] private transactions;
    mapping(uint => mapping(address => uint)) private isApproved;

    /* Modifiers */
    modifier nonZero(uint _amount) {
        _nonZero(_amount);
        _;
    }
    modifier notNobody(address _address) {
        _notNobody(_address);
        _;
    }
    modifier nonReentrant() {
        _nonReentrant();
        entered = _TRUE;
        _;
        entered = _FALSE;
    }
    modifier onlyGuardians() {
        _onlyGuardians();
        _;
    }
    modifier txExists(uint _txIndex) {
        _txExists(_txIndex);
        _;
    }
    modifier notExecuted(uint _txIndex) {
        _notExecuted(_txIndex);
        _;
    }
    modifier notApproved(uint _txIndex) {
        _notApproved(_txIndex);
        _;
    }
    modifier pausible() {
        _pausible();
        _;
    }

    constructor() {
        isGuardian[msg.sender] = _TRUE;
        guardians.push(msg.sender);
        deployer = msg.sender;
        paused = _FALSE;
        entered = _FALSE;
    }

    /* Guardian Functions */
    function getGuardians() external onlyGuardians view returns (address[] memory) {
        return guardians;
    }

    function pause(uint _paused) external onlyGuardians {
        paused = _paused == _TRUE ? _TRUE : _FALSE;
    }

    function proposeTransaction(string memory _functionName, address _loc, uint _value) external onlyGuardians {
        Transaction memory _transaction = Transaction({fnName: _functionName, loc: _loc, value: _value, executed: _FALSE, approvals: 0});
        uint _txIndex = transactions.length;
        transactions.push(_transaction);
        emit SubmitTransaction(msg.sender, _txIndex, _transaction.fnName, _transaction.loc, _transaction.value);
    }

    function approveTransaction(uint _txIndex) external onlyGuardians nonReentrant txExists(_txIndex) notExecuted(_txIndex) notApproved(_txIndex) {
        transactions[_txIndex].approvals = transactions[_txIndex].approvals.inc();
        isApproved[_txIndex][msg.sender] = _TRUE;
        emit ApproveTransaction(msg.sender, _txIndex);
    }

    function revokeApproval(uint _txIndex) external onlyGuardians nonReentrant txExists(_txIndex) notExecuted(_txIndex) {
        require(isApproved[_txIndex][msg.sender] == _TRUE);

        transactions[_txIndex].approvals = transactions[_txIndex].approvals.dec();
        isApproved[_txIndex][msg.sender] = _FALSE;

        emit RevokeApproval(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex) external onlyGuardians nonReentrant txExists(_txIndex) notExecuted(_txIndex) {
        Transaction memory _transaction = transactions[_txIndex];
        require(_transaction.approvals >= minApprovals);
        transactions[_txIndex].executed = _TRUE;
        emit ExecuteTransaction(msg.sender, _txIndex);
        if (_compareStrings(_transaction.fnName, "_setInsuranceActive")) {
            _setInsuranceActive(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_setInsuranceEnhanced")) {
            _setInsuranceEnhanced(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_setBotAddress")) {
            _setBotAddress(_transaction.loc);
        } else if (_compareStrings(_transaction.fnName, "_setBUSDContract")) {
            _setBUSDContract(_transaction.loc);
        } else if (_compareStrings(_transaction.fnName, "_setDepositFeeRate")) {
            _setDepositFeeRate(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_setPenaltyRate")) {
            _setPenaltyRate(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_setRewardRate")) {
            _setRewardRate(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_setRewardPeriod")) {
            _setRewardPeriod(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_setWithdrawPeriod")) {
            _setWithdrawPeriod(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_addGuardian")) {
            _addGuardian(_transaction.loc, _transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_removeGuardian")) {
            _removeGuardian(_transaction.loc, _transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_setMinApprovals")) {
            _setMinApprovals(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_balanceInsuranceFund")) {
            _balanceInsuranceFund(_transaction.value);
        } else if (_compareStrings(_transaction.fnName, "_addLP")) {
            _addLP(_transaction.loc);
        } else if (_compareStrings(_transaction.fnName, "_removeLP")) {
            _removeLP(_transaction.loc);
        } else {
            revert MultiSigFunctionNotFound(msg.sender, _txIndex);
        }
    }

    function getTransactionCount() external view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex) external view returns (string memory fnName, address loc, uint value, uint approvals, bool executed) {
        Transaction memory _transaction = transactions[_txIndex];
        return (
            _transaction.fnName,
            _transaction.loc,
            _transaction.value,
            _transaction.approvals,
            (_transaction.executed == _TRUE ? true : false)
        );
    }

    /* MultiSig functions */
    function _setInsuranceActive(uint _bool) internal virtual;
    function _setInsuranceEnhanced(uint _bool) internal virtual;
    function _setBotAddress(address _bot) internal virtual;
    function _setBUSDContract(address _busdContract) internal virtual;
    function _setDepositFeeRate(uint _depositFeeRate) internal virtual;
    function _setPenaltyRate(uint _penaltyRate) internal virtual;
    function _setRewardRate(uint _rewardRate) internal virtual;
    function _setRewardPeriod(uint _rewardPeriod) internal virtual;
    function _setWithdrawPeriod(uint _withdrawPeriod) internal virtual;
    function _balanceInsuranceFund(uint _percentageHealth) internal virtual;
    function _addLP(address _newLP) internal virtual;
    function _removeLP(address _oldLP) internal virtual;
    function _setMinApprovals(uint _minApprovals) internal {
        if (_minApprovals > guardians.length || _minApprovals < 1 ) revert MinApprovalsOutOfRange(msg.sender, _minApprovals);
        minApprovals = _minApprovals;
    }
    function _addGuardian(address _guardian, uint _min) internal notNobody(_guardian) {
        if (isGuardian[_guardian] == _TRUE) revert GuardianExists(msg.sender, _guardian);
        guardians.push(_guardian);
        isGuardian[_guardian] = _TRUE;
        _setMinApprovals(_min);
    }
    function _removeGuardian(address _guardian, uint _min) internal {
        if (_guardian == msg.sender || isGuardian[_guardian] != _TRUE || _guardian == deployer) revert GuardianUnremovable(msg.sender, _guardian);
        address[] memory _guardians = guardians;
        for(uint i; i < _guardians.length; i = i.inc()) {
            if (_guardians[i] == _guardian) {
                guardians[i] = _guardians[ guardians.length - 1];
                guardians.pop();
                isGuardian[_guardian] = _FALSE;
                _setMinApprovals(_min);
                return;
            }
        }
        revert GuardianUnremovable(msg.sender, _guardian);
    }

    /* Helper Functions */
    function _compareStrings(string memory _a, string memory _b) private pure returns (bool) {
        return (keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b)));
    }
    function _nonZero(uint _amount) private pure {
        require(_amount > 0);
    }
    function _notNobody(address _address) private pure {
        require(_address != address(0));
    }
    function _nonReentrant() private view {
        if (entered != _FALSE)
            revert ReentrancyRejected(msg.sender);
    }
    function _onlyGuardians() private view {
        if (isGuardian[msg.sender] != _TRUE)
            revert AccessDenied(msg.sender);
    }
    function _txExists(uint _txIndex) private view {
        require(_txIndex < transactions.length);
    }
    function _notExecuted(uint _txIndex) private view {
        require(transactions[_txIndex].executed != _TRUE);
    }
    function _notApproved(uint _txIndex) private view {
        require(isApproved[_txIndex][msg.sender] != _TRUE);
    }
    function _pausible() private view {
        require(paused != _TRUE);
    }

    /* Events & Errors */
    event SubmitTransaction(
        address indexed guardian,
        uint indexed txIndex,
        string functionName,
        address location,
        uint value
    );
    event ApproveTransaction(address indexed guardian, uint indexed txIndex);
    event RevokeApproval(address indexed guardian, uint indexed txIndex);
    event ExecuteTransaction(address indexed guardian, uint indexed txIndex);

    error ReentrancyRejected(address caller);
    error AccessDenied(address caller);
    error MinApprovalsOutOfRange(address caller, uint amount);
    error GuardianExists(address caller, address guardian);
    error GuardianUnremovable(address caller, address _guardian);
    error MultiSigFunctionNotFound(address caller, uint txIndex);
}

/****************************
Creates infrastructure for managing the insurance fund.
****************************/
abstract contract SelfInsured is Guardian {
    uint public insuranceActive; // allow users to claim insurance.
    uint public enhancedInsurance;
    uint internal insurancePaid;
    uint internal coverageRatio;

    /* Events & Errors */
    error InvalidInsuranceLevel(address caller);
    error InsuranceFundInactive(address caller);

    /* Apply to any and all function which require the insurance fund to be activated
     * prior to withdrawing from the fund.
     */
    function _insuranceFundActive() private view{
        if (insuranceActive != _TRUE)
            revert InsuranceFundInactive(msg.sender);
    }
    modifier insuranceFundActive{
        _insuranceFundActive();
        _;
    }

    /* Use this to create an additional level of insurance coverage, once your insurance
     * fund is at a healthy level. Level 1: Hold enough funds to cover everyone's initial
     * deposits. Level 2: Holds enough funds to cover everyone's initial deposits as well
     * as current rewards.
     */
    function _setInsuranceActive(uint _bool ) internal override {
        if ( _bool == _TRUE ) {
            insuranceActive = _TRUE;
            _updateCoverageRatio();
        } else {
            insuranceActive = _FALSE;
        }
    }
    function _setInsuranceEnhanced(uint _bool ) internal override {
        if ( _bool == _TRUE ) {
            enhancedInsurance = _TRUE;
            _updateCoverageRatio();
        } else {
            enhancedInsurance = _FALSE;
        }
    }

    function totalInsurancePaid() external onlyGuardians view returns(uint) {
        return insurancePaid;
    }
    function getCoverageRatio() external onlyGuardians view returns(uint) {
        return coverageRatio;
    }
    function totalInsurableAssets() public virtual returns(uint);
    function getBalance() public virtual returns(uint);
    function emergencyWithdrawl() external virtual; // Should use 'insuranceFundActive' modifier
    function getLiquidity() public view virtual returns(uint);
    function getNetWorth() public view virtual returns(uint);
    function _updateCoverageRatio() internal virtual;
}

abstract contract botConfig is Guardian {
    /*
    * Rates and payouts are subject to change in order to preserve the health of the
    * protocol and are primarily based off of what kinds of returns can be generated
    * through using agressive, high-risk strategies in conjunction with other Defi
    * protocols. Nothing is guaranteed, but our priorities are first profit, second
    * self-insurability and lastly sustainability through automation.
    */
    uint public constant MIN_DEPOSIT = 10 * 10**18;
    uint public constant PERCENT_RATE = 10000;
    uint public depositFeeRate = 400; // 4%
    uint public penaltyRate = 500; // 5% Non-Referred Penalty & Insurance Deductible
//    uint public rewardPeriod = 7 days;
//    uint public withdrawPeriod = 30 days;
    uint public rewardPeriod = 7 minutes;
    uint public withdrawPeriod = 30 minutes;
    uint public rewardRate = 500; // 5%
    uint public withdrawlFee = 0;
    uint public devFeeRate = 50;
    uint public referralRate = 2000;
    address public BUSDContract;
    address internal bot;
}

abstract contract aiBot is botConfig {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address[] public lp = [0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16];
    address public dev = 0x73C4004d380221630e6F9e1cd05d382EB694401C;

    constructor(address _bot) {
        require(_bot == address(this), "This bot must be used here.");
    }

    function startNewInvestment(uint _amount) public pausible onlyGuardians {
        uint _devFeeRate = devFeeRate;
        IERC20 _contract = IERC20(BUSDContract);

        // Leave some here for Self-Insurance
        uint insPremium = _amount.mul(depositFeeRate.sub(_devFeeRate)).div(PERCENT_RATE);

        // Pay the maker
        uint founderFee = _amount.mul(_devFeeRate).div(PERCENT_RATE);
        _contract.safeTransfer(dev,founderFee);

        // Find the best opportunity
        uint _hiKey = getHiKey();

        // Send the lion's share to be deposited
        uint depositment = _amount.sub(insPremium).sub(founderFee);
        _contract.safeTransfer(lp[_hiKey], depositment);
    }
    function getReferralAmount(uint _rewardAmount) public pausible onlyGuardians returns(uint _refAmount) {
        _refAmount = _rewardAmount.mul(referralRate).div(PERCENT_RATE);
        // Gather enough funds to pay rewards & referral commissions
        _takeProfits(_rewardAmount.add(_refAmount));
    }
    function getReferralAmount(uint _rewardAmount, uint _principal) public pausible onlyGuardians returns(uint) {
        // Gather enough funds to pay principal
        _takeProfits(_principal);
        // Gather enough funds to pay rewards & referral commissions while returning referral amount
        return getReferralAmount(_rewardAmount);
    }
    function getLiquidity() public view onlyGuardians returns(uint _liquidity) {
        IERC20 _contract = IERC20(BUSDContract);
        address[] memory _lp = lp;
        for(uint i; i < _lp.length; i++) {
            _liquidity = _liquidity.add(_contract.balanceOf(_lp[i]));
        }
    }
    function getHiKey() public view onlyGuardians returns(uint _hiKey) {
        IERC20 _contract = IERC20(BUSDContract);
        // Search for the best opportunity
        uint _hiBal;
        address[] memory _lp = lp;
        for(uint i; i < _lp.length; i++) {
            if (_contract.balanceOf(_lp[i]) > _hiBal) {
                _hiBal = _contract.balanceOf(_lp[i]);
                _hiKey = i;
            }
        }
    }
    function getNetWorth() public view onlyGuardians returns(uint) {
        return  getLiquidity() + IERC20(BUSDContract).balanceOf(address(this));
    }
    function balanceInsuranceFund(uint _amountRequired, uint _balance) public onlyGuardians {
        // Ensure our insurance funds are topped off.
        if (_balance < _amountRequired) {
            IERC20 _contract = IERC20(BUSDContract);
            address[] memory _lp = lp;
            uint _hiKey = getHiKey();
            uint _amountToReturn = _amountRequired.sub(_balance);
            uint _lpBalance = _contract.balanceOf(_lp[_hiKey]);
            // If we don't have enough to balance it out, send what we can.
            if (_lpBalance < _amountToReturn) {
                _amountToReturn = _lpBalance;
            }
            // Bring some money back
            if (_amountToReturn > 0) {
                _takeProfits(_amountToReturn);
            }
        }
    }
    function addLP(address _newLP) public onlyGuardians {
        lp.push(_newLP);
    }
    function removeLP(address _oldLP) public onlyGuardians {
        address[] memory _lp = lp;
        for(uint i; i < _lp.length; i = i.inc()) {
            if (_lp[i] == _oldLP) {
                // Overwrite this guardian with the last one in the list
                lp[i] = _lp[ _lp.length - 1];
                // remove the last one in the list since we already have it.
                lp.pop();
                return;
            }
        }
    }
    function _takeProfits(uint _minAmount) private {
        IERC20 _contract = IERC20(BUSDContract);
        address[] memory _lp = lp;
        for(uint i; i < _lp.length; i++) {
            uint _balancePre = getBalance();

            // Funds always return to this smart contract.
            _contract.safeTransferFrom(_lp[i],address(this),_minAmount.mul(PERCENT_RATE.sub(withdrawlFee)).div(PERCENT_RATE));

            // Calculate what we've taken so far and run the loop again, until we his our min.
            if (getBalance().sub(_balancePre) <= _minAmount) {
                _minAmount = _minAmount.sub(getBalance().sub(_balancePre));
            } else {
                break;
            }
        }
    }
    function getBalance() public onlyGuardians view returns(uint) {
        return IERC20(BUSDContract).balanceOf(address(this));
    }
}

contract smartbond is botConfig, SelfInsured{
    aiBot smartBond;
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    uint public depositID;
    uint public totalRewardsPaid;
    uint public referralsPaid;
    uint public totalPaid;
    uint public totalDepositors;
    uint public totalDeposited;
    uint public totalLocked;
    uint public totalClaimableEst;

    struct Deposit{
        address depositor;
        uint depositAmount;
        uint depositAt;
        uint active;
    }

    struct Depositor{
        address depositor;
        uint lockedAmount;
        uint lastCalculationDate;
        uint claimableRewards;
        uint totalPaid;
        address referrer;
    }

    mapping(uint => Deposit) public deposits;
    mapping(address => uint[]) public ownedDeposits;
    mapping(address => Depositor) public depositors;

    constructor(address _busdContract, address _bot) {
        require(_busdContract!=address(0),"Invalid BUSD Address");
        require(_bot!=address(0),"Invalid Bot Address");
        BUSDContract = _busdContract;
        bot = _bot;
        smartBond = aiBot(_bot);
        IERC20(BUSDContract).safeApprove(_bot, 2**256 - 1);
    }

    // Users will use this function to open their initial deposits
    // _referrer field is only used the first time calling this funciton.
    function deposit(uint _amount, address _referrer) public pausible nonReentrant {
        require(_amount >= MIN_DEPOSIT);

        // Move the money here first.
        IERC20(BUSDContract).safeTransferFrom(msg.sender,address(this),_amount);

        _makeNewDeposit(_amount, _referrer);
    }

    // Users will use this function to claim all of their rewards directly to their wallets.
    function claimRewards() public nonReentrant pausible {
        require(ownedDeposits[msg.sender].length > 0);

        // Calculate the total rewards payable
        uint _rewardAmount = _getClaimableRewards(msg.sender);
        require(_rewardAmount > 0);

        // Get the amount owed to the referrer and gather the user rewards,
        // referral dues as well as self-insurance contribution.
        uint _referralAmount = smartBond.getReferralAmount(_rewardAmount);
        address _BUSDContract = BUSDContract;

        // Pay the referrer
        _payReferrer(depositors[msg.sender].referrer, _referralAmount);

        // Pay the user
        _recordWithdrawl(_rewardAmount,0,_TRUE);
        IERC20(_BUSDContract).safeIncreaseAllowance(msg.sender, _rewardAmount);
        IERC20(_BUSDContract).safeTransfer(msg.sender,_rewardAmount);
    }

    function compoundRewards() public nonReentrant pausible {
        require(ownedDeposits[msg.sender].length > 0);

        // Calculate the total rewards payable
        uint _rewardAmount = _getClaimableRewards(msg.sender);
        require(_rewardAmount >= MIN_DEPOSIT);

        // Get the amount owed to the referrer and gather the user rewards,
        // referral dues as well as self-insurance contribution.
        uint _referralAmount = smartBond.getReferralAmount(_rewardAmount);

        // Pay the referrer
        _payReferrer(depositors[msg.sender].referrer, _referralAmount);

        // Update claim records
        _makeNewDeposit(_rewardAmount, address(0));
        _recordWithdrawl(_rewardAmount,0,_TRUE);
    }

    function withdrawPrincipal(uint id) public nonReentrant pausible {
        Deposit memory _deposit = deposits[id];

        // Validate the request
        require(_deposit.depositor == msg.sender);
        if (block.timestamp - _deposit.depositAt <= withdrawPeriod)
            revert FundsTimeLocked(msg.sender, id);
        if (_deposit.active != _TRUE)
            revert FundsAlreadyWithdrawn(msg.sender, id);

        uint _rewards = _getClaimableRewards(msg.sender);
        uint _amountToSend = _deposit.depositAmount.add(_rewards);
        _payReferrer(
            depositors[msg.sender].referrer, 
            smartBond.getReferralAmount(_rewards, _deposit.depositAmount)
        );

        // Pay the user
        _recordWithdrawl(_rewards,_deposit.depositAmount,_TRUE);
        deposits[id].active = _FALSE;
        IERC20(BUSDContract).safeIncreaseAllowance(msg.sender,_amountToSend);
        IERC20(BUSDContract).safeTransfer(msg.sender,_amountToSend);
    }

    function setReferrer(address _newReferrer) public nonReentrant {
        depositors[msg.sender].referrer = _newReferrer;
    }

    /* This will close all of your positions and give you a percentage of the
     * contract balance based on how much you have deposited ÷ how much everyone
     * has deposited. There is no guarantee that the fund will be fully insured.
     * However, the longer this protocol lasts, the greater the chances. It's 
     * even possible for this to become much greater than 100% insured. */
    function emergencyWithdrawl() external override insuranceFundActive nonReentrant {
        uint _myLocked = depositors[msg.sender].lockedAmount;
        uint _myRewards = _getClaimableRewards(msg.sender);
        uint _myInsurable = enhancedInsurance == _TRUE ? _myLocked.add(_myRewards) : _myLocked;
        if (_myInsurable == 0) revert NoInsurableAssets(msg.sender);

        uint _userPortion = PERCENT_RATE.mul(PERCENT_RATE).mul(_myInsurable).div(totalInsurableAssets());
        uint _balance = getBalance();
        uint _payout = _balance.mul(_userPortion).div(PERCENT_RATE).div(PERCENT_RATE);

        // Remove the user's deductible from their payout.
        // This improves the health of the insurance fund for users
        // who utilize emergency withdraw at a later time because the 
        // deductible remains in the pool for future calculations.
        _payout = _payout.mul(PERCENT_RATE.sub(penaltyRate)).div(PERCENT_RATE);
        require(_payout > 0 && _payout <= _balance );

        _recordWithdrawl(_myRewards,_myLocked,_FALSE);
        insurancePaid = insurancePaid.add(_payout);
        totalPaid = totalPaid.add(_payout);
        depositors[msg.sender].totalPaid = depositors[msg.sender].totalPaid.add(_payout);

        // Close out each deposit
        uint[] memory _ownedDeposits = ownedDeposits[msg.sender];
        for(uint i; i < _ownedDeposits.length; i++) {
            deposits[ _ownedDeposits[i] ].active = _FALSE;
        }

        IERC20(BUSDContract).safeIncreaseAllowance(msg.sender,_payout);
        IERC20(BUSDContract).safeTransfer(msg.sender,_payout);
        _updateCoverageRatio();
    }

    /* Public Helper Functions */
    function getOwnedDeposits(address depositor) public view returns (uint[] memory) {
        return ownedDeposits[depositor];
    }    

    // Low gas function to calculate an estimate of what an depositor will get back from an emergency withdrawl.
    function createInsuranceClaim(address _depositorAddress) external notNobody(_depositorAddress) returns(uint) {
        uint _myInsurable = depositors[_depositorAddress].lockedAmount;
        if( enhancedInsurance == _TRUE ){
            uint _myRewards = _getClaimableRewards(_depositorAddress);
            _myInsurable = _myInsurable.add(_myRewards);
        }
        _updateCoverageRatio();
        return _myInsurable.mul(coverageRatio).div(PERCENT_RATE);
    }
    function getInsuranceEstimate(address _depositorAddress) external notNobody(_depositorAddress) view returns(uint) {
        uint _myInsurable = depositors[_depositorAddress].lockedAmount;
        if( enhancedInsurance == _TRUE ){
            uint _newRewards = getNewRewards(_depositorAddress);
            _myInsurable = _myInsurable.add(depositors[_depositorAddress].claimableRewards.add(_newRewards));
        }
        return _myInsurable.mul(coverageRatio).div(PERCENT_RATE);
    }

    // How much is eligible for insurance coverage in total?
    function totalInsurableAssets() public override view returns(uint _insurable) {
        // Get min to ensure everyone gets their initial back
        return enhancedInsurance == _TRUE ? totalLocked.add( totalClaimableEst ) : totalLocked;
    }

    // How much do we have in our insurance treasury?
    function getBalance() public view override returns(uint) {
        return IERC20(BUSDContract).balanceOf(address(this));
    }

    // How much liquid BUSD do we have immediately available.
    // This is a gas guzzler as it has to manually calculate all of our
    // investments individually and cross check that they are immediately
    // able to be cashed out.
    function getLiquidity() public view override returns(uint) {
        return getBalance().add(smartBond.getLiquidity());
    }

    // What is the net value of all of our assets, both liquid and locked?
    function getNetWorth() public view override returns(uint) {
        return getBalance().add(smartBond.getNetWorth());
    }

    /* Internal Helper Functions */
    function _updateCoverageRatio() internal override {
        uint _insFund = getBalance();
        coverageRatio = PERCENT_RATE.mul(_insFund).div(totalInsurableAssets());
    }

    function _makeNewDeposit(uint _amount, address _referrer) private {
        // Create the depositor data, if needed.
        _getClaimableRewards(msg.sender);
        Depositor memory _depositor = depositors[msg.sender];
        if (_depositor.depositor==address(0)) {
            totalDepositors = totalDepositors.inc();
            _depositor.depositor = msg.sender;
            _depositor.referrer = _referrer;
            _depositor.lastCalculationDate = block.timestamp;
        }

        // Referred users receive a discount on deposit fees.
        uint _lockedAmount;
        uint _ins;
        if (_depositor.referrer == address(0) || _depositor.referrer == msg.sender) {
            _lockedAmount = _amount.sub(_amount.mul(penaltyRate).div(PERCENT_RATE));
            _ins = _amount.mul(penaltyRate.sub(depositFeeRate)).div(PERCENT_RATE);
        } else {
            _lockedAmount = _amount.sub(_amount.mul(depositFeeRate).div(PERCENT_RATE));
        }

        _depositor.lockedAmount = _depositor.lockedAmount.add(_lockedAmount);

        // Store everything to the blockchain
        uint _depositID = depositID.inc();
        deposits[_depositID] = Deposit({
            depositor: msg.sender,
            depositAmount: _lockedAmount,
            depositAt: block.timestamp,
            active: _TRUE
        });
        ownedDeposits[msg.sender].push(_depositID);
        totalLocked = totalLocked.add(_lockedAmount);
        totalDeposited = totalDeposited.add(_amount);
        depositors[msg.sender] = _depositor;
        depositID = _depositID;

        // Allow bot to start using the funds
        smartBond.startNewInvestment(_amount.sub(_ins));
        emit Deposited(msg.sender);
    }
    
    function _payReferrer(address _referrer, uint _amount) private {
        // If there isn't a valid referrer, then keep the referral money here to pad Insurance fund.
        if (_amount > 0 && _referrer != address(0) && _referrer != address(this) && _referrer != msg.sender) {
            referralsPaid = referralsPaid.add(_amount);
            totalPaid = totalPaid.add(_amount);
            depositors[_referrer].totalPaid = depositors[_referrer].totalPaid.add(_amount);
            IERC20(BUSDContract).safeIncreaseAllowance(_referrer, _amount);
            IERC20(BUSDContract).safeTransfer(_referrer,_amount);
        }
    }

    function _recordWithdrawl(uint _rewards, uint _principal, uint _updateTotals) private {
        Depositor memory _depositor = depositors[msg.sender];

        // Rewards
        totalClaimableEst = totalClaimableEst > _rewards ? totalClaimableEst.sub(_rewards) : 0;
        
        _depositor.claimableRewards = 0;

        // Principal
        totalLocked = totalLocked.sub(_principal);
        _depositor.lockedAmount = _depositor.lockedAmount.sub(_principal);

        // If this is an insurance withdrawl
        // The user may receive more or less than the accumulated rewards and principle
        // Depending on the health of the insurance fund.
        // Therefore, these totals would not be accurate here.
        // But we still need to update everything else.
        if( _updateTotals == _TRUE ){ 
            totalPaid = totalPaid.add(_rewards.add(_principal));
            totalRewardsPaid = totalRewardsPaid.add(_rewards);
            _depositor.totalPaid = _depositor.totalPaid.add(_rewards.add(_principal));
        }
       
        // Update the stored depositor
        depositors[msg.sender] = _depositor;

        emit Withdrawn(msg.sender);
    }

    function _getClaimableRewards(address _depositorAddress) private returns (uint) {
        uint _newRewards = getNewRewards(_depositorAddress);
        totalClaimableEst = totalClaimableEst.add(_newRewards);
        depositors[_depositorAddress].claimableRewards = depositors[_depositorAddress].claimableRewards.add(_newRewards);
        depositors[_depositorAddress].lastCalculationDate = block.timestamp;
        return depositors[_depositorAddress].claimableRewards;
    }

    function getNewRewards(address _depositorAddress) public view returns (uint) {
        Depositor memory _depositor = depositors[_depositorAddress];
        return ((block.timestamp - _depositor.lastCalculationDate).mul(_depositor.lockedAmount).mul(rewardRate)).div(PERCENT_RATE.mul(rewardPeriod));
    }

    /* MultiSig functions */
    function _setBUSDContract(address _busdContract) internal notNobody(_busdContract) override{
        BUSDContract = _busdContract;
        IERC20(_busdContract).safeApprove(bot, 2**256-1);
    }
    function _setBotAddress(address _bot) internal notNobody(_bot) override{
        bot = _bot;
        smartBond = aiBot(_bot);
    }
    function _setDepositFeeRate(uint _depositFeeRate) internal override {
        depositFeeRate = _depositFeeRate;
    }
    function _setPenaltyRate(uint _penaltyRate) internal override {
        penaltyRate = _penaltyRate;
    }
    function _setRewardPeriod(uint _rewardPeriod) internal override {
        rewardPeriod = _rewardPeriod;
    }
    function _setRewardRate(uint _rewardRate) internal override {
        rewardRate = _rewardRate;
    }
    function _setWithdrawPeriod(uint _withdrawPeriod) internal override {
        withdrawPeriod = _withdrawPeriod;
    }
    // _percentageHealth: 10000 = 100%
    function _balanceInsuranceFund(uint _percentageHealth) internal override {
        uint _amountNeeded = totalInsurableAssets().mul(_percentageHealth).div(PERCENT_RATE);
        smartBond.balanceInsuranceFund(_amountNeeded, getBalance());
        _updateCoverageRatio();
    }
    function _addLP(address _newLP) internal override {
        smartBond.addLP(_newLP);
    }
    function _removeLP(address _oldLP) internal override {
        smartBond.removeLP(_oldLP);
    }

    /* Events & Errors */
    event Deposited(address indexed user);
    event Withdrawn(address indexed user);

    error FundsTimeLocked(address caller, uint id);
    error FundsAlreadyWithdrawn(address caller, uint id);
    error NoInsurableAssets(address caller);

    /* Fallback */
    fallback() external payable{}
    receive() external payable{}
}