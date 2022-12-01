pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
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
}

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface ICrossRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface ICrossFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    /*************/
    function isPairDelisted(address _address) external view returns (bool);

    function changePairListingStatus(address _address, bool _value) external;

    function isDAOAdmin(address _address) external view returns (bool);

    function killswitch() external;

    function changeDexFeeStatus(
        address _address,
        address _pairAddress,
        uint256 _amount
    ) external;

    function dexFee(address _address, address _pairAddress)
        external
        view
        returns (uint256);

    function isTradingHalted() external view returns (bool);

    /*************/

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// File: contracts\interfaces\ICrossRouter02.sol

interface ICrossRouter02 is ICrossRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ICrossPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /*************/
    function CRSSPricecheckStatus(
        bool _isActive0,
        bool _isActive1,
        bool _isActiveL
    ) external;

    /*************/
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        address from,
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface ICrssReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission)
        external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    function getOutstandingCommission(address _referrer)
        external
        view
        returns (uint256 amount);

    function debitOutstandingCommission(address _referrer, uint256 _debit)
        external;

    function getTotalComission(address _referrer)
        external
        view
        returns (uint256);

    function updateOperator(address _newPayer) external;
}

interface ICRSS is IERC20 {
    /* */
    function changeTransferFeeExclusionStatus(address target, bool value)
        external;

    function killswitch() external;

    function mintFarm(uint256 _amount) external;

    event SwapAndLiquify(
        uint256 crssPart,
        uint256 crssForEthPart,
        uint256 ethPart,
        uint256 liquidity
    );

    event TradingHalted(uint256 timestamp);
    event TradingResumed(uint256 timestamp);
    event TransferFeeExclusionStatusUpdated(address target, bool value);
    /* */
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface ICRSSEmission {
    function setRewardPerBlock(uint256 _amountPerBlock) external;
}

interface ICrossLPFarm {
    function changeBlockReward(uint256 _amount, bool _withUpdate) external;
}

// Farm distributes the ERC20 rewards based on staked LP to each user.
//
// Cloned from https://github.com/SashimiProject/sashimiswap/blob/master/contracts/MasterChef.sol
// Modified by LTO Network to work for non-mintable ERC20.
contract CrossLPFarm is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 lastDepositTime;
        bool isCompounding; //user setting which gives users rewards in LP token instead of CRSS
        //system behind it is made in a way that contract converts CRSS rewards attributed to compounding subpool to LP token in bulk,
        // because a single conversion of any ERC20 token to LP token is between 270-700k gas if no tokens involve custom transfer functions
        //depending on pool swap treshold and average claimed reward amount every 10-100000th claim rewards function call will include the bulk reward swap gas
        //those users will pay around 3-5% lower gas fee, than if they manually compounded and they dont pay compound fee, users who got their rewards converted
        //for free will pay a fixed 5% compound fee on their rewards
        //
        // We do some fancy math here. Basically, any point in time, the amount of ERC20s
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accERC20PerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accERC20PerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ERC20s to distribute per block.
        uint256 lastRewardBlock; // Last block number that ERC20s distribution occurs.
        uint256 accERC20PerShare; // Accumulated ERC20s per share, times 1e36.
        /******** */
        uint256 compoundRewards; //current amount of CRSS value for compunding in this pool,
        // this CRSS token amount is converted to LP token of the pool in question once swap treshold is reached
        //these two are required to correctly split CRSS token rewards, otherwise compounding would get less,
        // as comp rewards that might be stored in contract will go towards non compounding reward pool
        uint256 compoundingTokens; // total number of deposited LP tokens in compound
        uint256 nonCompoundingTokens; //total number of deposited LP tokens not compounded
        uint256 endBlock;

        /******** */
    }
    // The total amount of CRSS that was minted to the contract and allocated towards a specific pool
    uint256 public crssDistributed = 0;
    // ERC20 tokens rewarded per block.
    uint256 public rewardPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    //stores a router for each token so auto-compound can correctly ajdust for any different token on the same chain
    mapping(address => address) public tokenToRouter;
    //amount off crss required to initiate conversion from CRSS => LP token
    mapping(uint256 => uint256) public poolSwapTreshold;
    mapping(uint256 => uint256) public poolDepositFee;
    //determines min wait time before withdrawing after deposit, 0 means its turned off
    mapping(uint256 => uint256) public poolLocktime;
    mapping(address => uint256) public userVestTimes;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    /******** */
    address[] public contractAddresses; //0 for crss token, 1 for vesting, 2 for crss router, 3 for pcs router, 4 for control center, 5 for accountant, 6 for CRSS factory

    uint256 public startBlock;

    //this calculates deposit fee in reverse for gas savings, 10000 value means user is excluded from fees, 100 is 1% fee, 1 is 0.01%
    //if 0, pool deposit fee is applied
    mapping(address => uint256) public userAdjustedDeposit;

    event PoolUpdated(
        PoolInfo pool,
        uint256 lockTime,
        uint256 swapTreshold,
        uint256 depositFee
    );
    event PoolCreated(
        PoolInfo pool,
        uint256 lockTime,
        uint256 swapTreshold,
        uint256 depositFee
    );
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(address[] memory _contractAddresses, uint256 _rewardPerBlock) {
        for (uint256 i = 0; i < _contractAddresses.length; i++) {
            contractAddresses.push(_contractAddresses[i]);
        }
        startBlock = block.timestamp;
        rewardPerBlock = _rewardPerBlock;
    }

    // Number of LP pools
    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        uint256 _depositFee,
        uint256 _swapTreshold,
        uint256 _lockTime,
        uint256 _endBlock,
        address _router,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        uint256 index = poolLength();
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accERC20PerShare: 0,
                compoundRewards: 0,
                compoundingTokens: 0,
                nonCompoundingTokens: 0,
                endBlock: _endBlock
            })
        );

        poolDepositFee[index] = _depositFee;
        poolSwapTreshold[index] = _swapTreshold;
        poolLocktime[index] = _lockTime;

        tokenToRouter[address(_lpToken)] = _router;
        emit PoolCreated(
            poolInfo[poolInfo.length - 1],
            _lockTime,
            _swapTreshold,
            _depositFee
        );
    }

    // Update the given pool's ERC20 allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _depositFee,
        uint256 _lockTime,
        uint256 _swapTreshold,
        uint256 _endBlock,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].endBlock = _endBlock;
        poolDepositFee[_pid] = _depositFee;
        poolSwapTreshold[_pid] = _swapTreshold;
        poolLocktime[_pid] = _lockTime;
        emit PoolUpdated(poolInfo[_pid], _lockTime, _swapTreshold, _depositFee);
    }

    //mass update of all pools just before changing reward per block is very important in order not to give higher rewards than intended in updatePool()
    function changeBlockReward(uint256 _amount, bool _withUpdate) external {
        // require(msg.sender == contractAddresses[0]);
        if (_withUpdate) {
            massUpdatePools();
        }

        rewardPerBlock = _amount;
    }

    function getCorePoolInfo(uint256 _pid)
        public
        view
        returns (PoolInfo memory)
    {
        return poolInfo[_pid];
    }

    function getAdditionalPoolInfo(uint256 _pid)
        public
        view
        returns (
            uint256 depositFee,
            uint256 swapTreshold,
            uint256 lockTime
        )
    {
        return (
            poolDepositFee[_pid],
            poolSwapTreshold[_pid],
            poolLocktime[_pid]
        );
    }

    function getPoolDepositFee(uint256 _pid) public view returns (uint256) {
        return poolDepositFee[_pid];
    }

    function getPoolLocktime(uint256 _pid) public view returns (uint256) {
        return poolLocktime[_pid];
    }

    function poolFundedUntil(uint256 _pid) public view returns (uint256) {
        return poolInfo[_pid].endBlock - block.number;
    }

    function isUserCompounding(uint256 _pid, address _address)
        public
        view
        returns (bool)
    {
        return userInfo[_pid][_address].isCompounding;
    }

    function userPending(address _user, uint256 _pid)
        public
        view
        returns (uint256 pendingReward)
    {
        if (userInfo[_pid][_user].isCompounding == true) {
            pendingReward = getPendingCompoundRewards(_pid, _user);
        } else {
            pendingReward = pending(_pid, _user);
        }
    }

    function extendedWithdraw(uint256 _pid, uint256 _amount) public {
        if (userInfo[_pid][msg.sender].isCompounding) {
            compoundWithdraw(_pid, _amount);
        } else {
            withdraw(_pid, _amount);
        }
    }

    function extendedDeposit(uint256 _pid, uint256 _amount) public {
        require(
            ICrossFactory(contractAddresses[6]).isPairDelisted(
                address(poolInfo[_pid].lpToken)
            ) != true,
            "CRSSf:Pair delisted"
        );
        if (userInfo[_pid][msg.sender].isCompounding) {
            compoundDeposit(_pid, _amount);
        } else {
            deposit(_pid, _amount);
        }
    }

    function claimRewards(uint256 _pid, uint256 _vestTime) public {
        /* uint256 userVestTime = _vestTime;
        if (_vestTime == 0) {
            userVestTime = userInfo[_pid][msg.sender].defaultVest;
        } else {*/
        require(
            _vestTime % 2629800 == 0 && _vestTime / 2629800 <= 12,
            "fCRSS:Wrong vest time selected"
        );

        if (userInfo[_pid][msg.sender].isCompounding) {
            claimCompoundRewards(_pid, msg.sender, _vestTime);
        } else {
            normalClaimRewards(_pid, msg.sender, _vestTime);
        }
    }

    function massClaim(uint256[] memory _pids, uint256 _vestTime) public {
        require(
            _vestTime % 2629800 == 0 && _vestTime / 2629800 <= 12,
            "fCRSS:Wrong vest time selected"
        );
        for (uint256 i = 0; i < _pids.length; i++) {
            if (isUserCompounding(_pids[i], msg.sender)) {
                claimCompoundRewards(_pids[i], msg.sender, _vestTime);
            } else {
                normalClaimRewards(_pids[i], msg.sender, _vestTime);
            }
        }
    }

    // View function to see deposited LP for a user.
    function deposited(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_pid][_user];
        return user.amount;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // View function to see pending ERC20s for a user.
    function pending(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accERC20PerShare = pool.accERC20PerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 blockNumber = block.number;

        if (blockNumber > pool.lastRewardBlock && lpSupply != 0) {
            uint256 nrOfBlocks = (blockNumber).sub(pool.lastRewardBlock);
            uint256 erc20Reward = nrOfBlocks
                .mul(rewardPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accERC20PerShare = accERC20PerShare.add(
                erc20Reward.mul(1e36).div(lpSupply)
            );
        }

        return user.amount.mul(accERC20PerShare).div(1e36).sub(user.rewardDebt);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];

        uint256 currentBlock = block.number;
        if (pool.endBlock <= currentBlock) {
            return;
        }
        if (currentBlock <= pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = currentBlock;
            return;
        }

        uint256 compoundedLpTokens = pool.compoundingTokens;
        uint256 nonCompoundedLpTokens = pool.nonCompoundingTokens;
        uint256 totalActiveDeposit = compoundedLpTokens + nonCompoundedLpTokens;

        uint256 nrOfBlocks = currentBlock.sub(pool.lastRewardBlock);
        uint256 totalCrssReward = nrOfBlocks
            .mul(rewardPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);
        uint256 nonCompoundReward = totalCrssReward
            .mul(nonCompoundedLpTokens)
            .div(totalActiveDeposit);
        uint256 compoundReward = totalCrssReward.mul(compoundedLpTokens).div(
            totalActiveDeposit
        );
        ICRSS(contractAddresses[0]).mintFarm(
            compoundReward + nonCompoundReward
        );
        pool.accERC20PerShare = pool.accERC20PerShare.add(
            nonCompoundReward.mul(1e36).div(nonCompoundedLpTokens)
        );
        pool.compoundRewards += compoundReward;
        pool.lastRewardBlock = block.number;
    }

    function claimCompoundRewards(
        uint256 _pid,
        address _user,
        uint256 _vestPeriod
    ) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 compoundRewards = IERC20(address(pool.lpToken)).balanceOf(
            address(this)
        ) -
            pool.compoundingTokens -
            pool.nonCompoundingTokens;

        uint256 userReward = (user.amount * compoundRewards) /
            pool.compoundingTokens;
        if (userReward > 0) {
            ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                _user,
                userReward,
                address(pool.lpToken),
                uint64(block.timestamp),
                uint32(_vestPeriod)
            );
        }
        user.rewardDebt =
            (user.amount * (compoundRewards - userReward)) /
            pool.compoundingTokens;
    }

    function normalClaimRewards(
        uint256 _pid,
        address _user,
        uint256 _vestTime
    ) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        updatePool(_pid);
        uint256 pendingAmount = user
            .amount
            .mul(pool.accERC20PerShare)
            .div(1e36)
            .sub(user.rewardDebt);

        if (pendingAmount > 0) {
            ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                _user,
                pendingAmount,
                contractAddresses[0],
                uint64(block.timestamp),
                uint32(_vestTime)
            );
        }

        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
    }

    function switchCollectOption(uint256 _pid, address _user) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            msg.sender == _user || msg.sender == address(this),
            "CRSSf:Only farm and user"
        );
        updatePool(_pid);
        uint256 depositedAmount = user.amount;

        if (user.isCompounding) {
            uint256 lpRewards = IERC20(pool.lpToken).balanceOf(address(this)) -
                (pool.nonCompoundingTokens) -
                (pool.compoundingTokens);
            uint256 userReward = (depositedAmount * lpRewards) /
                pool.compoundingTokens;

            if (lpRewards > 0) {
                uint256 oneMonth = 6 * 6 * 24 * 3044;
                //  uint256 userVestingPeriod = user.defaultVest == 0
                //      ? oneMonth
                //     : user.defaultVest;
                ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                        _user,
                        userReward,
                        address(pool.lpToken),
                        uint64(block.timestamp),
                        uint32(oneMonth)
                    );

                if (depositedAmount > 0) {
                    pool.compoundingTokens -= depositedAmount;
                    pool.nonCompoundingTokens += depositedAmount;
                }
                user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(
                    1e36
                );
                user.isCompounding == false;
            } else {
                uint256 pendingAmount = user
                    .amount
                    .mul(pool.accERC20PerShare)
                    .div(1e36)
                    .sub(user.rewardDebt);
                if (pendingAmount > 0) {
                    uint256 oneMonth = 6 * 6 * 24 * 3044;
                    ICrossVesting(contractAddresses[1])
                        .initiateFarmVestingInstance(
                            _user,
                            pendingAmount,
                            contractAddresses[0],
                            uint64(block.timestamp),
                            uint32(oneMonth)
                        );
                    //erc20.transfer(vestingContract, pendingAmount);
                }
                if (depositedAmount > 0) {
                    pool.compoundingTokens += depositedAmount;
                    pool.nonCompoundingTokens -= depositedAmount;
                }

                lpRewards =
                    IERC20(pool.lpToken).balanceOf(address(this)) -
                    (pool.nonCompoundingTokens) -
                    (pool.compoundingTokens);
                user.rewardDebt =
                    (user.amount * (lpRewards)) /
                    pool.compoundingTokens;

                user.isCompounding == true;
            }
        }
    }

    // Deposit LP tokens to Farm for ERC20 allocation.
    function deposit(uint256 _pid, uint256 _amount) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (pool.endBlock <= block.number) {
            return;
        }
        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pendingAmount = user
                .amount
                .mul(pool.accERC20PerShare)
                .div(1e36)
                .sub(user.rewardDebt);
            if (pendingAmount > 0) {
                uint256 userVestingPeriod;
                ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                        msg.sender,
                        pendingAmount,
                        contractAddresses[0],
                        uint64(block.timestamp),
                        uint32(userVestingPeriod)
                    );
            }
        }

        uint256 adjustedAmount = _amount;
        uint256 depositTaxAmount = userAdjustedDeposit[msg.sender] == 0
            ? poolDepositFee[_pid]
            : _amount - ((_amount * userAdjustedDeposit[msg.sender]) / 10000);
        adjustedAmount -= depositTaxAmount;

        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            pool.nonCompoundingTokens += adjustedAmount;
            user.amount += adjustedAmount;
            if (depositTaxAmount > 0) {
                IERC20(pool.lpToken).transfer(
                    contractAddresses[5],
                    depositTaxAmount
                );
            }
        }
        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function compoundDeposit(uint256 _pid, uint256 _amount) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (pool.endBlock <= block.number) {
            return;
        }
        updatePool(_pid);

        uint256 lpRewards = IERC20(address(pool.lpToken)).balanceOf(
            address(this)
        ) -
            pool.compoundingTokens -
            pool.nonCompoundingTokens;
        uint256 userReward = (user.amount * lpRewards) / pool.compoundingTokens;
        uint256 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)

        if (userReward > 0) {
            ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                msg.sender,
                userReward,
                address(pool.lpToken),
                uint64(block.timestamp),
                uint32(oneMonth)
            );
        }
        uint256 adjustedAmount = _amount;
        uint256 depositTaxAmount = userAdjustedDeposit[msg.sender] == 0
            ? poolDepositFee[_pid]
            : _amount - ((_amount * userAdjustedDeposit[msg.sender]) / 10000);
        adjustedAmount -= depositTaxAmount;

        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            pool.compoundingTokens += adjustedAmount;
            user.amount += adjustedAmount;
            if (depositTaxAmount > 0) {
                IERC20(pool.lpToken).transfer(
                    contractAddresses[5],
                    depositTaxAmount
                );
            }
        }

        user.rewardDebt =
            (user.amount * (lpRewards - userReward)) /
            pool.compoundingTokens;

        emit Deposit(msg.sender, _pid, _amount);
    }

    function getPendingCompoundRewards(uint256 _pid, address _user)
        public
        view
        returns (uint256 reward)
    {
        UserInfo memory user = userInfo[_pid][_user];
        if (user.isCompounding == true) {
            PoolInfo memory pool = poolInfo[_pid];
            uint256 userPercentage = (user.amount * (10**18)) /
                pool.compoundingTokens;
            uint256 compoundRewards = IERC20(address(pool.lpToken)).balanceOf(
                address(this)
            ) -
                pool.compoundingTokens -
                pool.nonCompoundingTokens;
            reward = (userPercentage * compoundRewards) / (10**18);
            return reward;
        } else return 0;
    }

    // Withdraw LP tokens from Farm.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "CRSSf:Withdraw exceeds balance");
        updatePool(_pid);
        uint256 pendingAmount = user
            .amount
            .mul(pool.accERC20PerShare)
            .div(1e36)
            .sub(user.rewardDebt);
        if (pendingAmount > 0) {
            uint256 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)

            ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                msg.sender,
                pendingAmount,
                contractAddresses[0],
                uint64(block.timestamp),
                uint32(oneMonth)
            );
            //erc20.transfer(vestingContract, pendingAmount);
        }
        if (_amount > 0) {
            user.amount -= _amount;
            pool.nonCompoundingTokens -= _amount;

            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function compoundWithdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "CRSSf:Withdraw exceeds balance");
        updatePool(_pid);
        uint256 lpReward = IERC20(pool.lpToken).balanceOf(address(this)) -
            pool.compoundingTokens -
            pool.nonCompoundingTokens;
        uint256 pendingAmount = (user.amount * lpReward) /
            pool.compoundingTokens -
            user.rewardDebt;
        if (pendingAmount > 0) {
            uint256 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)

            ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                msg.sender,
                pendingAmount,
                address(pool.lpToken),
                uint64(block.timestamp),
                uint32(oneMonth)
            );
        }
        if (_amount > 0) {
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            user.amount = user.amount.sub(_amount);
            pool.compoundingTokens -= _amount;
        }

        user.rewardDebt = ((user.amount * (lpReward - pendingAmount)) /
            pool.compoundingTokens);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /*
    function getCompoundPercent(uint256 _pid) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        address lpTkn = address(pool.lpToken);
        uint256 totalLp = IERC20(lpTkn).balanceOf(address(this));
        return (pool.compoundingTokens * 10000) / totalLp;
    }

    function claimCompoundedRewards(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);
        uint256 pendingAmount = getPendingCompoundRewards(_pid, msg.sender);
        if (pendingAmount > 0) {
            uint256 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)
            uint256 userVestingPeriod = user.defaultVest == 0
                ? oneMonth
                : user.defaultVest;
            ICrossVesting(contractAddresses[1]).initiateFarmVestingInstance(
                msg.sender,
                pendingAmount,
                contractAddresses[0],
                uint64(block.timestamp),
                uint32(userVestingPeriod)
            );
        }

        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
    }*/

    /* function bulkCompound(uint256 _pid, uint256 _amount) public {
        require(
            msg.sender == address(this) || msg.sender == owner(),
            "CRSSf:Only contract and owner"
        );
        PoolInfo storage pool = poolInfo[_pid];
        address lpAddress = address(pool.lpToken);
        // uint256 lpRewardBalance = pool.lpToken.balanceOf(address(this)) -
        //     pool.compoundingTokens;
        (address tokenA, address tokenB) = (
            ICrossPair(lpAddress).token0(),
            ICrossPair(lpAddress).token1()
        );

        address crssToken = contractAddresses[0];
        if (tokenA == crssToken || tokenB == crssToken) {
            address tokenAddress = tokenA == crssToken ? tokenB : tokenA;
            uint256 half = _amount.div(2);
            swapCross(
                _amount - half,
                tokenAddress,
                tokenToRouter[tokenAddress]
            );
            getNewLP(
                tokenA,
                tokenB,
                IERC20(tokenAddress).balanceOf(address(this)),
                half
            );
        } else {
            address wBnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;

            //address wBnb = ICrossRouter02(contractAddresses[2]).WETH();
            if (tokenToRouter) swapCrssForBnb(_amount, tokenToRouter[wBnb]);

            uint256 halfNewBalance = IERC20(wBnb).balanceOf(address(this)) / 2;
            swapCross(halfNewBalance, tokenA, tokenToRouter[tokenA]);
            swapCross(halfNewBalance, tokenB, tokenToRouter[tokenB]);
            getNewLP(
                tokenA,
                tokenB,
                IERC20(tokenA).balanceOf(address(this)),
                IERC20(tokenB).balanceOf(address(this))
            );
        }
    }*/

    /*function bulkSwap(uint256 _pid, uint256 _amount) public {
        require(
            msg.sender == address(this) || msg.sender == owner(),
            "CRSSf:Only contract and owner"
        );
        PoolInfo storage pool = poolInfo[_pid];
        address lpAddress = address(pool.lpToken);
        // uint256 lpRewardBalance = pool.lpToken.balanceOf(address(this)) -
        //     pool.compoundingTokens;
        (address tokenA, address tokenB) = (
            ICrossPair(lpAddress).token0(),
            ICrossPair(lpAddress).token1()
        );
        address crssToken = contractAddresses[0];

        if (tokenA == crssToken || tokenB == crssToken) {
            address tokenAddress = tokenA == crssToken ? tokenB : tokenA;

            swapCross(_amount, tokenAddress, tokenToRouter[tokenAddress]);
        } else {
            uint256 half = _amount.div(2);
            swapCross(half, tokenA, tokenToRouter[tokenA]);
            swapCross(_amount - half, tokenB, tokenToRouter[tokenB]);
        }
    }*/

    /*function swapCross(
        uint256 _amount,
        address _toToken,
        address _router
    ) public {
        if (_router == crssRouter) {
            _swapCross(_amount, _toToken); //crssrouter)
        } else if (_router == pcsRouter) {
            _swapCrossPcs(_amount, _toToken);
        } else if (_router == bsRouter) {
            _swapCrossBS(_amount, _toToken);
        }
    }

    function swapBnbForToken(
        uint256 _amount,
        address _toToken,
        address _router
    ) public {
        if (_router == crssRouter) {
            _swapBnbForToken(_amount, _toToken); //crssrouter)
        } else if (_router == pcsRouter) {
            _swapBnbForTokenPcs(_amount, _toToken);
        } else if (_router == bsRouter) {
            _swapBnbForTokenBs(_amount, _toToken);
        }
    }*/

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Transfer ERC20 and update the required ERC20 to payout all rewards
    function erc20Transfer(address _to, uint256 _amount) internal {
        IERC20(contractAddresses[0]).transfer(_to, _amount);
        crssDistributed += _amount;
    }

    /********* */
    modifier OnlyControlCenter() {
        require(msg.sender == contractAddresses[4], "CRSS:Only control center");
        _;
    }

    function updatePoolDepositFee(uint256 _pid, uint256 _newFee)
        external
        OnlyControlCenter
    {
        require(_newFee <= 1000, "CRSS:Max deposit fee is 10%");
        poolDepositFee[_pid] = _newFee;
    }

    function depositFeeExclusionStatus(address _address, uint256 _value)
        external
        OnlyControlCenter
    {
        require(
            userAdjustedDeposit[_address] != _value,
            "CRSS:Already set value"
        );
        userAdjustedDeposit[_address] = _value;
    }

    function updateControlCenter(address _newAddress)
        external
        OnlyControlCenter
    {
        require(contractAddresses[4] != _newAddress, "CRSS:Already set value");
        contractAddresses[4] = _newAddress;
    }

    function changeRouter(address _token, address _router)
        public
        OnlyControlCenter
    {
        tokenToRouter[_token] = _router;
    }

    function updateContractAddress(uint256 _id, address _address)
        public
        OnlyControlCenter
    {
        contractAddresses[_id] = _address;
    }
    /********* */
}

interface IsCRSS is IERC20 {
    function enter(uint256 _amount) external;

    function leave(uint256 _amount) external;

    function enterFor(uint256 _amount, address _to) external;

    function killswitch() external;

    function setCompoundingEnabled(bool _enabled) external;

    function setMaxTxAndWalletBPS(uint256 _pid, uint256 bps) external;

    function rescueToken(address _token, uint256 _amount) external;

    function rescueETH(uint256 _amount) external;

    function excludeFromDividends(address account, bool excluded) external;

    function upgradeDividend(address payable newDividendTracker) external;

    function impactFeeStatus(bool _value) external;

    function setImpactFeeReceiver(address _feeReceiver) external;

    function CRSStoSCRSS(uint256 _crssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    function sCRSStoCRSS(uint256 _sCrssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    event TradingHalted(uint256 timestamp);
    event TradingResumed(uint256 timestamp);
}

// SPDX-License-Identifier: GPL-2.0-or-later
/*library CrossLibrary {
    function swapCross(
        uint256 _amount,
        address _toToken,
        address _router
    ) public {
        if (_router == crssRouter) {
            _swapCross(_amount, _toToken); //crssrouter)
        } else if (_router == pcsRouter) {
            _swapCrossPcs(_amount, _toToken);
        } else if (_router == bsRouter) {
            _swapCrossBS(_amount, _toToken);
        }
    }

    function swapBnbForToken(
        uint256 _amount,
        address _toToken,
        address _router
    ) public {
        if (_router == crssRouter) {
            _swapBnbForToken(_amount, _toToken); //crssrouter)
        } else if (_router == pcsRouter) {
            _swapBnbForTokenPcs(_amount, _toToken);
        } else if (_router == bsRouter) {
            _swapBnbForTokenBs(_amount, _toToken);
        }
    }

    function swapCross(uint256 _amount, address _toToken) private {
        address[] memory path = new address[](2);

        path[0] = contractAddresses[0];
        path[1] = _toToken;
        try
            ICrossRouter02(_router)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    _amount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                )
        {} catch {
            return;
        }
    }

    function getNewLP(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    ) public {
        address native = ICrossRouter02(contractAddresses[2]).WETH();
        if (_tokenA != native && _tokenB != native) {
            ICrossRouter02(tokenToRouter[_tokenA]).addLiquidity(
                _tokenA,
                _tokenB,
                _amountA,
                _amountB,
                0,
                0,
                address(this),
                block.timestamp + 300
            );
        } else {
            address token0 = _tokenA == native ? _tokenB : _tokenA;
            ICrossRouter02(tokenToRouter[token0]).addLiquidityETH(
                token0,
                _amountA,
                0,
                0,
                address(this),
                block.timestamp + 300
            );
        }
    }

    function swapCrssForBnb(uint256 _amount, address _router) private {
        address[] memory path = new address[](2);

        path[0] = contractAddresses[0];
        path[1] = ICrossRouter02(_router).WETH();
        try
            ICrossRouter02(_router)
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    _amount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                )
        {} catch {
            return;
        }
    }

    function swapCrssForBnbPcs(uint256 _amount, address _router) private {
        address[] memory path = new address[](2);

        path[0] = contractAddresses[0];rssReferral
        path[1] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        try
            IPancakeRouter02(_router)
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    _amount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                )
        {} catch {
            return;
        }
    }
}*/
pragma solidity ^0.8.0;

interface ICrossVesting {
    function initiateFarmVestingInstance(
        address _address,
        uint256 _amount,
        address _tokenAddress,
        uint64 _startTimestamp,
        uint32 _vestingPeriod
    ) external;
}

contract CrosswiseVesting is ReentrancyGuard {
    struct VestingInstance {
        uint256 tokenAmount;
        address tokenAddress; //these 3 take 1 memory slot
        uint64 startTimestamp;
        uint32 vestingPeriod;
    }
    address public referralContract;
    address public crssAddress;
    address public sCrssAddress;
    address public accountant;
    address public controlCenter;
    uint256 public minVestingPeriod;
    uint256 public totalCrssVesting;
    uint256 public compoundFee; //5% or 500
    mapping(address => VestingInstance[]) public userVesting;
    mapping(uint256 => uint256) public rewardMultiplier;
    mapping(address => uint256) public referralRewards;
    //uint256 private exponentialRate = 3718888; //3.72
    event UserFarmVest(address user, address token, uint256 amount);
    event BulkCollect(address user, uint256 userReward, uint256 numOfClaimed);
    event CrossFarmVest(address user, uint256 amount);

    constructor() {
        initiateRewardMultiplier(
            [
                1000,
                1156,
                1245,
                1389,
                1549,
                1728,
                1928,
                2151,
                2400,
                2678,
                2988,
                3333
            ]
        );
        compoundFee = 500;
    }

    function claimAllRewards() public nonReentrant {
        for (uint256 i = 0; i < userVesting[msg.sender].length; i++) {
            if (
                userVesting[msg.sender][i].vestingPeriod +
                    userVesting[msg.sender][i].startTimestamp <=
                block.timestamp
            ) {
                VestingInstance memory vestingInstance = userVesting[
                    msg.sender
                ][i];
                uint256 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)
                uint256 rewardsMultiplier = rewardMultiplier[
                    vestingInstance.vestingPeriod / oneMonth
                ];
                uint256 adjustedReward = (rewardsMultiplier *
                    vestingInstance.tokenAmount) / 3333;
                if (vestingInstance.tokenAddress != crssAddress) {
                    uint256 userCompoundFee = (adjustedReward * compoundFee) /
                        10000;
                    IERC20(vestingInstance.tokenAddress).transfer(
                        accountant,
                        userCompoundFee
                    );
                    adjustedReward -= userCompoundFee;
                } else {
                    totalCrssVesting -= vestingInstance.tokenAmount;
                }
                IERC20(vestingInstance.tokenAddress).transfer(
                    msg.sender,
                    adjustedReward * rewardsMultiplier
                );
                userVesting[msg.sender][i] = userVesting[msg.sender][
                    userVesting[msg.sender].length - 1
                ];
                //delete userStakes[msg.sender][userStakingInstances - 1];
                userVesting[msg.sender].pop();
            }
        }
    }

    function initiateFarmVestingInstance(
        address _address,
        uint256 _amount,
        address _tokenAddress,
        uint64 _startTimestamp,
        uint32 _vestingPeriod
    ) public {
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        userVesting[_address].push(
            VestingInstance({
                tokenAmount: _amount,
                tokenAddress: _tokenAddress,
                startTimestamp: _startTimestamp,
                vestingPeriod: _vestingPeriod
            })
        );
        if (_address == crssAddress) {
            totalCrssVesting += _amount;
            emit CrossFarmVest(msg.sender, _amount);
            address referrer = ICrssReferral(referralContract).getReferrer(
                _address
            );
            if (referrer != address(0)) {
                uint32 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)
                uint256 rewardsMultiplier = rewardMultiplier[
                    uint256(_vestingPeriod / oneMonth)
                ];
                uint256 adjustedReward = (rewardsMultiplier * _amount) / 3333;
                referralRewards[referrer] += (adjustedReward / 100);
            }
        }

        emit UserFarmVest(_address, _tokenAddress, _amount);
    }

    function initiateRewardMultiplier(uint16[12] memory _multiplier) public {
        /* require(
            msg.sender == address(this),
            "vCRSS:Called once during contract creation"
        );*/
        for (uint256 i = 0; i < _multiplier.length; i++) {
            uint256 multiplier = uint256(_multiplier[i]);
            rewardMultiplier[i + 1] = multiplier;
        }
    }

    function getMultiplier(uint256 _numOfMonths) public view returns (uint256) {
        return rewardMultiplier[_numOfMonths];
    }

    function getRewardMultipler(uint256 _numOfMonths, uint256 _reward)
        public
        view
        returns (uint256)
    {
        return rewardMultiplier[_numOfMonths] * _reward;
    }

    function getPendingReferral(address _referrer)
        public
        view
        returns (uint256)
    {
        return referralRewards[_referrer];
    }

    function claimRewards(uint256 _pid) public nonReentrant {
        VestingInstance storage vestingInstance = userVesting[msg.sender][_pid];
        uint32 currentTimestamp = uint32(block.timestamp);
        uint32 vestingDuration = currentTimestamp -
            uint32(vestingInstance.startTimestamp);
        uint32 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)
        //REMOVED FOR TESTING
        /*
        require(
            vestingDuration >= vestingInstance.vestingPeriod,
            "CRSS: Rewards not unlocked yet "
        );*/
        uint256 rewardsMultiplier = rewardMultiplier[
            uint256(vestingInstance.vestingPeriod / oneMonth)
        ];
        uint256 adjustedReward = (rewardsMultiplier *
            vestingInstance.tokenAmount) / 3333;
        if (vestingInstance.tokenAddress != crssAddress) {
            uint256 userCompoundFee = (adjustedReward * compoundFee) / 10000;
            IERC20(vestingInstance.tokenAddress).transfer(
                accountant,
                userCompoundFee
            );
            adjustedReward -= userCompoundFee;
        } else {
            totalCrssVesting -= vestingInstance.tokenAmount;
            address referrer = ICrssReferral(referralContract).getReferrer(
                msg.sender
            );
            if (referrer != address(0)) {
                referralRewards[referrer] -= (adjustedReward / 100);
            }
        }
        IERC20(vestingInstance.tokenAddress).transfer(
            msg.sender,
            adjustedReward
        );
        userVesting[msg.sender][_pid] = userVesting[msg.sender][
            userVesting[msg.sender].length - 1
        ];
        //delete userStakes[msg.sender][userStakingInstances - 1];
        userVesting[msg.sender].pop();
    }

    function claimRewardsToVault(uint256 _pid) public nonReentrant {
        VestingInstance storage vestingInstance = userVesting[msg.sender][_pid];
        require(
            vestingInstance.tokenAddress == crssAddress,
            "vCRSS:Only CRSS rewards"
        );
        uint64 currentTimestamp = uint64(block.timestamp);
        uint64 vestingDuration = currentTimestamp -
            vestingInstance.startTimestamp;
        uint64 oneMonth = 6 * 6 * 24 * 3044; //1 month == 30.44 days (30.4375)
        //REMOVED FOR TESTING
        /*require(
            vestingDuration >= vestingInstance.vestingPeriod,
            "CRSS: Rewards not unlocked yet "
        );*/
        uint256 adjustedReward = vestingInstance.tokenAmount *
            rewardMultiplier[vestingInstance.vestingPeriod / oneMonth];
        if (
            IERC20(crssAddress).allowance(address(this), sCrssAddress) <
            adjustedReward
        ) {
            IERC20(crssAddress).approve(sCrssAddress, type(uint256).max);
        }

        IsCRSS(sCrssAddress).enterFor(adjustedReward, msg.sender);
        totalCrssVesting -= vestingInstance.tokenAmount;

        userVesting[msg.sender][_pid] = userVesting[msg.sender][
            userVesting[msg.sender].length - 1
        ];
        userVesting[msg.sender].pop();
    }

    function changeCompoundFee(uint256 _newFee) public {
        require(msg.sender == controlCenter, "vCRSS:Only Control center");
        require(compoundFee <= 2000, "vCRSS:Max percentage is 20%");
        compoundFee = _newFee;
    }

    //////FOR TESTING
    /*function unlockVestings(address _user) public {
        for (uint256 i = 0; i < userVesting[_user].length; i++) {
            userVesting[_user][i].startTimestamp = 0;
        }
    }*/

    /* function claimAllSameType(address _tokenAddress) public nonReentrant {
        address user = msg.sender;
        //StakingObject[] memory userArray = userStakes[user];
        //goes through all existing user staking instances, claims all rewards from instances whose timelock period has expired
        uint256 userReward = 0;
        uint256 numOfClaimed = 0;
        //check each user staking instance for claimable funds
        for (uint256 i = 0; i < userVesting[user].length; i) {
            VestingInstance memory userObject = userVesting[user][i];
            if (
                userObject.tokenAddress == _tokenAddress &&
                userObject.startTimestamp + userObject.vestingPeriod <=
                block.timestamp
            ) {
                userReward += uint256(userObject.tokenAmount);

                numOfClaimed++;
                //deletes array slot of each claimed staking instance, for optimization and security reasons
                //mint reward tokens to user, transfer user's originally staked tokens back to them
                userVesting[user][i] = userVesting[user][
                    userVesting[user].length - 1
                ];
                //delete userStakes[msg.sender][userStakingInstances - 1];
                userVesting[user].pop();
            } else i++;
        }

        require(userReward > 0, "No unlocked rewards to claim");

        IERC20(_tokenAddress).transfer(user, userReward);
        emit BulkCollect(user, userReward, numOfClaimed);
    }*/
}