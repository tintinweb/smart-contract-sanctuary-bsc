/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

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

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, Ownable, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);

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

library AddressUpgradeable {
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

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(
            _initializing ? _isConstructor() : !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}

contract ResearchLab is OwnableUpgradeable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        IERC20 lpToken;             // Address of the LP token contract
        uint256 amount;             // How many LP tokens the user has provided.
        uint256 bridgedAmount;      // Amount of LP tokens bridged from existing contract
        uint256 depositTime;        // Time of the deposit
        uint256 depositBlock;       // Block number when deposited
        uint256 pendingUnlocked;    // Amount of pending reward to be withdrawn
        uint256 pendingLocked;      // Amount of pending reward to be withdrawn
        uint256 lockedAmount;       // Amount of locked rewards
        uint256 vestedAmount;       // Amount of rewards set aside for the vesting period after all eras are done
        uint lastRewardBlock;       // Last block that rewards were viewed or withdrawn
        uint previousRewardBlock;   // Previous block that rewards were viewed or withdrawn
    }

    // Emergency Withdraw details
    struct EmergencyInfo {
        uint256 amount;             // Amount lost due to emergency withdraw
    }

    // The ECTO TOKEN!
    IERC20 public ecto;
    
    // Deposit Fee address
    address public feeAddress;
    
    // Fund Manager address
    address public fundmanager;
    
    // Fund Manager address
    address public bridgeManager;

    // Mining Contract address
    address public rewardsMiningAddress;

    // Conversion Contract address
    address private convertFromAddress;
    
    // Conversion Contract total pool
    //uint256 private convertFromTotalPool;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    
    // Mapping for acceptable pool token
    struct PoolToken {
        IERC20 lpToken;
        uint256 poolWeight;
    }
    PoolToken[] public poolToken;
    mapping(address => bool) public poolTokenExists;

    // Mapping for emergency withdraw funds
    mapping(address => EmergencyInfo) public emergencyInfo;

    // Mapping for the allocated rewards per era
    mapping (uint => uint256) public rewardAllocated;

    // Number of eras
    uint256 public numberOfEras = 0;
    
    // Number of blocks per era
    uint256 public blocksPerEra = 0;

    // Number of blocks per vesting
    uint256 public blocksPerVesting = 0;

    // Start time of the pool
    uint256 public startTime = 0;

    // Start block of the pool
    uint256 public startBlock = 0;

    // Last block when last update was ran
    //uint256 public lastBlockUpdate = 0;

    // Enable the deposit bridge
    bool public enableBridge = false;

    // Total pool bridged over
    //uint256[] private bridgedValue;

    // Total local deposit
    //uint256[] private localValue;

    // Percentage precision of the eras
    uint256 private eraPerecent = 100;
    
    // Percentage precision of the weight
    uint256 private weightPercent = 1000;

    event Deposit(address indexed user, uint pid, uint256 amount);
    event Withdraw(address indexed user, uint256 amount, uint256 pendingUnlocked, uint256 pendingLocked);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event DepositFund(uint256 amount);
    event WithdrawFund(uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetFundmanager(address indexed user, address indexed newAddress);
    event SetMiningAddress(address indexed user, address indexed newAddress);
    event SetConvertFromAddress(address indexed user, address indexed newAddress);

    function init(
            IERC20 _ecto,
            address _fundmanager,
            address _feeAddress
        ) public initializer {

        __Ownable_init();
        ecto = _ecto;
        fundmanager = _fundmanager;
        feeAddress = _feeAddress;

        rewardAllocated[0] = 0;
        rewardAllocated[1] = 59600000000000000000000000;
        rewardAllocated[2] = 29800000000000000000000000;
        rewardAllocated[3] = 22350000000000000000000000;
        rewardAllocated[4] = 18625000000000000000000000;
        rewardAllocated[5] = 14900000000000000000000000;
        rewardAllocated[6] = 11175000000000000000000000;
        rewardAllocated[7] = 8195000000000000000000000;
        rewardAllocated[8] = 6705000000000000000000000;
        rewardAllocated[9] = 5215000000000000000000000;
        rewardAllocated[10] = 4470000000000000000000000;
        rewardAllocated[11] = 3725000000000000000000000;
        rewardAllocated[12] = 2980000000000000000000000;
        rewardAllocated[13] = 2235000000000000000000000;
        rewardAllocated[14] = 2086000000000000000000000;
        rewardAllocated[15] = 1937000000000000000000000;
        rewardAllocated[16] = 1788000000000000000000000;
        rewardAllocated[17] = 1639000000000000000000000;
        rewardAllocated[18] = 1490000000000000000000000;
        rewardAllocated[19] = 745000000000000000000000;
        rewardAllocated[20] = 149000000000000000000000;
        rewardAllocated[21] = 0;
    }
    
    // Set the number of eras in the pool
    function setNumberOfEras(uint256 _numberOfEras) public onlyOwner() {
        numberOfEras = _numberOfEras;
    }

    // Set the blocks per era
    function setBlocksPerEra(uint256 _blocksPerEra) public onlyOwner() {
        blocksPerEra = _blocksPerEra;
    }

    // Set the blocks per vesting
    function setBlocksPerVesting(uint256 _blocksPerVesting) public onlyOwner() {
        blocksPerVesting = _blocksPerVesting;
    }
    
    // Set the blocks per vesting
    function enableDepositBridge(bool _enable) public onlyOwner() {
        enableBridge = _enable;
    }

    // Add the lp tokens that can be used within the contract
    function addTokenAddress(IERC20 _lpToken, uint256 _poolWeight) public onlyOwner {
        require(!poolTokenExists[address(_lpToken)], "LP Token already exists!");
        
        poolToken.push(
            PoolToken({
                lpToken: _lpToken,
                poolWeight: _poolWeight
            })
        );

        poolTokenExists[address(_lpToken)] = true;
    }
    
    // Update the lp token pools
    function updateTokenWeight(uint256 _pid, uint256 _poolWeight) public onlyOwner {
      require(_poolWeight>0, "_poolWeight must be greater than 0");
      
      poolToken[_pid].poolWeight = _poolWeight;
    }

    // Get the pool value of a specific token
    function getTokenPoolValue(uint256 _pid) public view returns (uint256 tokenPoolAlloc, uint256 poolWeight) {
        tokenPoolAlloc = poolToken[_pid].lpToken.balanceOf(address(this));
        poolWeight = poolToken[_pid].poolWeight;
    }

    // Calculate the pool value
    function getTotalPoolValue() public view returns (uint256 totalPoolAlloc) {
        for (uint256 i=0; i < poolToken.length; i++) { 
            totalPoolAlloc = totalPoolAlloc.add(poolToken[i].lpToken.balanceOf(address(this)));
        }
    }

    // Calculate the pool value
    function getTotalPoolValueWeighted() public view returns (uint256 totalPoolAlloc) {
      for (uint256 i=0; i < poolToken.length; i++) { 
        totalPoolAlloc = totalPoolAlloc.add(poolToken[i].lpToken.balanceOf(address(this)).mul(weightPercent).div(weightPercent.sub(poolToken[i].poolWeight)));
      }
    }

    // Get the era number
    function getEraNumber(uint256 blockNumber) public view returns(uint256) {
      return blockNumber.sub(startBlock).div(blocksPerEra).add(1);
    }

    // Get the current era number
    function getCurrentEraNumber() public view returns(uint256) {
      uint256 eraNumber = 0;

      if (startBlock > 0) {
        eraNumber = block.number.sub(startBlock).div(blocksPerEra).add(1);
      }

      return eraNumber; 
    }

    // Start the pool
    function startPool() public onlyOwner {
        require(blocksPerEra > 0, "blocksPerEra: Not set");
        require(numberOfEras > 0, "numberOfEras: Not set");

        startBlock = block.number;
        startTime = block.timestamp;
        //lastBlockUpdate = startBlock;
    }

    // Start the pool
    function updateStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
        //lastBlockUpdate = startBlock;
    }
    
    // Update the fund manager of the contract
    function updateFundmanager(address _fundmanager) public onlyOwner{
        fundmanager = _fundmanager;
        emit SetFundmanager(msg.sender, _fundmanager);
    }

    // Update the fee address for the pool fees
    function setFeeAddress(address _feeAddress) public onlyOwner{
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }
    
    // Update the address for rewards mining contract
    function setMiningAddress(address _rewardsMiningAddress) public onlyOwner{
        rewardsMiningAddress = _rewardsMiningAddress;
        emit SetMiningAddress(msg.sender, _rewardsMiningAddress);
    }

    // Update the address for rewards mining contract
    function setConvertFromAddress(address _convertFromAddress) public onlyOwner{
        convertFromAddress = _convertFromAddress;
        emit SetConvertFromAddress(msg.sender, _convertFromAddress);
    }

    /*// Update the address for rewards mining contract
    function setConvertFromTotalPool(uint256 _totalPool) public onlyOwner{
        convertFromTotalPool = _totalPool;
    }*/

    // Update the fund manager of the contract
    function updateBridgeManager(address _bridgeManager) public onlyOwner{
        bridgeManager = _bridgeManager;
    }

    // Deposit LP tokens into the pool
    function updateUser(uint256 _pid, address _userAddress, uint256 _amount, uint256 _oDepositTime, uint256 _oDepositBlock, uint256 _oLastRewardBlock) public nonReentrant {
        require(enableBridge, "Bridge must be enabled");
        require(bridgeManager==msg.sender, "Users can only be added by the bridge manager");
        
        UserInfo storage user = userInfo[_pid][_userAddress];
        
        user.lpToken = poolToken[_pid].lpToken;
        user.bridgedAmount = _amount;
        user.depositTime = _oDepositTime;
        user.depositBlock = _oDepositBlock;
        user.lastRewardBlock = _oLastRewardBlock;
    }

    // Deposit LP tokens into the pool
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");

        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 blockNumber = block.number;
        uint256 blockTime = block.timestamp;
        uint256[] memory rewardsByEra;

        poolToken[_pid].lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        /*if (user.bridgedAmount > 0 && user.amount < user.bridgedAmount) {
            if ((user.amount + _amount) <= user.bridgedAmount) {
              user.amount = user.amount.add(_amount);  
            } else {
              if (startTime>0) {
                pendingRewardsCalc(_pid, msg.sender, blockNumber);
              }
              user.depositTime = blockTime;
              user.depositBlock = blockNumber;
              user.amount = user.amount.add(_amount);  
            }
        } else */
        if (user.amount > 0) {
            if (startTime>0) {
              rewardsByEra = pendingRewardsCalc(_pid, msg.sender, blockNumber);
            }
            user.depositTime = blockTime;
            user.depositBlock = blockNumber;
            user.amount = user.amount.add(_amount);
        } else {
            user.lpToken = poolToken[_pid].lpToken;
            user.amount = _amount;
            user.depositTime = blockTime;
            user.depositBlock = blockNumber;
            /*user.pendingUnlocked = 0;
            user.pendingLocked = 0;
            user.lockedAmount = 0;
            user.vestedAmount = 0;*/
            user.lastRewardBlock = blockNumber;
        }

        //localValue[_pid] = localValue[_pid].add(_amount);

        emit Deposit(msg.sender, _pid, _amount);
    }

    // Deposit LP tokens into the pool
    function depositBridge(uint256 _pid, uint256 _amount, uint256 _oDepositTime, uint256 _oDepositBlock, uint256 _oPendingUnlocked, uint256 _oPendingLocked, uint256 _oLockedAmount, uint256 _oLastRewardBlock) public nonReentrant {
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        require(user.amount == 0, "User already used");
        require(user.bridgedAmount == 0, "Bridge deposit already used");
        require(_amount > 0, "Amount must be greater than 0");
        require(enableBridge == true, "Bridge is not enabled");
        //require(address(_oAddress) == address(convertFromAddress), "Incorrect convert from address");

        poolToken[_pid].lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        
        user.lpToken = poolToken[_pid].lpToken;
        user.amount = _amount;
        user.bridgedAmount = _amount;
        user.depositTime = _oDepositTime;
        user.depositBlock = _oDepositBlock;
        user.pendingUnlocked = _oPendingUnlocked;
        user.pendingLocked = _oPendingLocked;
        user.lockedAmount = _oLockedAmount;
        user.vestedAmount = _oLockedAmount;
        user.lastRewardBlock = _oLastRewardBlock;
        user.previousRewardBlock = _oLastRewardBlock;

        emit Deposit(msg.sender, _pid, _amount);
    }

    // Calculate the pending rewards
    function pendingRewardsCalc(uint256 _pid, address _user, uint256 _blockNumber) private returns (uint256[] memory rewardsByEra) {
        if (startTime == 0) {return rewardsByEra;}

        UserInfo storage user = userInfo[_pid][_user];
        (uint256 rewardValueUnlocked, uint256 rewardValueLocked,uint256 adjVested) = (0,0,0); 
        //uint256[2][] memory rewardsByEra;
        
        if (user.lastRewardBlock < startBlock.add(numberOfEras.mul(blocksPerEra)).add(blocksPerVesting)) {
          (rewardValueUnlocked, rewardValueLocked, rewardsByEra, adjVested) = pendingRewards(_pid, _user);
        }
        
        if (user.pendingUnlocked == 0) {
          user.previousRewardBlock = user.lastRewardBlock;
        }

        user.pendingUnlocked = user.pendingUnlocked.add(rewardValueUnlocked);
        user.pendingLocked = user.pendingLocked.add(rewardValueLocked);

        if(adjVested>0){
          user.vestedAmount = user.vestedAmount.add(adjVested);
        }

        user.lastRewardBlock = _blockNumber;

        return rewardsByEra;
    }


    // Calculate and display the pending rewards
    //function pendingRewards(uint256 _pid, address _user) public view returns (uint256 availableUnlockedRewards, uint256 availableLockedRewards, uint256[2][] memory rewardsByEra, uint256 adjVested) {
    function pendingRewards(uint256 _pid, address _user) public view returns (uint256 availableUnlockedRewards, uint256 availableLockedRewards, uint256[] memory rewardsByEra, uint256 adjVested) {
        if (startTime == 0) {return (uint256(0),uint256(0),rewardsByEra,uint256(0));}

        UserInfo storage user = userInfo[_pid][_user];
        uint256 blockNumber = block.number;
        uint256 currentEra = getEraNumber(blockNumber);
        uint256 lastRewardBlock = user.lastRewardBlock > startBlock ? user.lastRewardBlock : startBlock;
        
        {
        if (currentEra <= numberOfEras) {
          
          (availableUnlockedRewards, availableLockedRewards, rewardsByEra) = calculateRewardPerEra(currentEra, lastRewardBlock, blockNumber, _pid, user.amount);

        } else {
          uint256 vestingStartBlock = startBlock.add(numberOfEras.mul(blocksPerEra));

          if (lastRewardBlock < vestingStartBlock) {
            //(availableUnlockedRewards, availableLockedRewards) = calculateRewardPerEra(numberOfEras, lastRewardBlock, (vestingStartBlock-1), _pid, user.amount);
            (availableUnlockedRewards, availableLockedRewards, rewardsByEra) = calculateRewardPerEra(numberOfEras, lastRewardBlock, (vestingStartBlock), _pid, user.amount);
            adjVested = availableLockedRewards;
          } else {
            (availableUnlockedRewards, availableLockedRewards, rewardsByEra, adjVested) = (0,0,rewardsByEra,0);
          }
          
          uint256 rewardPerBlock = user.vestedAmount.add(availableLockedRewards).div(blocksPerVesting);
          uint256 blockStart = vestingStartBlock < lastRewardBlock ? lastRewardBlock : vestingStartBlock;
          //uint256 blockMax = vestingStartBlock.add(blocksPerVesting-1) < blockNumber ? vestingStartBlock.add(blocksPerVesting-1) : blockNumber;
          uint256 blockMax = vestingStartBlock.add(blocksPerVesting) < blockNumber ? vestingStartBlock.add(blocksPerVesting) : blockNumber;

          availableUnlockedRewards = availableUnlockedRewards.add(blockMax.sub(blockStart).mul(rewardPerBlock));

          rewardsByEra = calculateLockedRewardPerEra(vestingStartBlock, lastRewardBlock, blockMax, user.vestedAmount.add(availableLockedRewards), rewardsByEra);

          if(blockNumber<(vestingStartBlock.add(blocksPerVesting))) {
            //availableLockedRewards = vestingStartBlock.add(blocksPerVesting-1).sub(blockMax).mul(rewardPerBlock);
            availableLockedRewards = vestingStartBlock.add(blocksPerVesting).sub(blockMax).mul(rewardPerBlock);
          } else {
            availableLockedRewards = 0;
          }
        }
        }

        return (availableUnlockedRewards, availableLockedRewards, rewardsByEra, adjVested);
    }

    // Calculate the rewards per era 
    //function calculateRewardPerEra(uint256 _endEra, uint256 _lastRewardBlock, uint256 _blockNumber, uint256 _pid, uint256 _userAmount) private view returns(uint256 unlockedRewards, uint256 lockedRewards, uint256[2][] memory rewardsByEra) {
    function calculateRewardPerEra(uint256 _endEra, uint256 _lastRewardBlock, uint256 _blockNumber, uint256 _pid, uint256 _userAmount) private view returns(uint256 unlockedRewards, uint256 lockedRewards, uint256[] memory rewardsByEra) {
      uint256 lastRewardEra = getEraNumber(_lastRewardBlock);
      uint256 endBlock = 0;
      uint256 totalRewards = 0;
      uint256 totalPoolValue = getTotalPoolValueWeighted();
      //uint256[2][] memory rewardsByEra = new uint256[2][](_endEra.sub(lastRewardEra).add(1));


      for (uint256 i=lastRewardEra; i<=_endEra;i++) {
        //endBlock = _blockNumber < startBlock.add(i.mul(blocksPerEra)).sub(1) ? _blockNumber : startBlock.add(i.mul(blocksPerEra)).sub(1);
        endBlock = _blockNumber < startBlock.add(i.mul(blocksPerEra)) ? _blockNumber : startBlock.add(i.mul(blocksPerEra));
        totalRewards = endBlock.sub(_lastRewardBlock).mul(rewardAllocated[i].div(blocksPerEra));
        unlockedRewards = unlockedRewards.add(totalRewards.mul(i.mul(5)).div(eraPerecent));
        lockedRewards = lockedRewards.add(totalRewards.mul(eraPerecent.sub(i.mul(5))).div(eraPerecent));
        //_lastRewardBlock = endBlock.add(1);
        rewardsByEra[i]=(unlockedRewards);
        _lastRewardBlock = endBlock;
      }

      unlockedRewards = (_userAmount.mul(weightPercent).div(weightPercent.sub(poolToken[_pid].poolWeight))).mul(unlockedRewards).div(totalPoolValue);
      lockedRewards = (_userAmount.mul(weightPercent).div(weightPercent.sub(poolToken[_pid].poolWeight))).mul(lockedRewards).div(totalPoolValue);
      
      return(unlockedRewards, lockedRewards, rewardsByEra);
    }

    // Calculate the rewards per era 
    function calculateLockedRewardPerEra(uint256 _startBlock, uint256 _lastRewardBlock, uint256 _currentBlock, uint256 _totalVested, uint256[] memory rewardsByEra) private view returns(uint256[] memory totalByEra) {
      uint256 receivedLocked = _startBlock.add(blocksPerVesting).div(_totalVested).mul(_lastRewardBlock.sub(_startBlock));
      uint256 lockedPerEra = 0;
      
      for (uint256 i=1; i<=getEraNumber(_currentBlock-1); i++) {
        lockedPerEra = _totalVested.div(950).mul(100-(i.mul(5)));

        if(lockedPerEra>receivedLocked) {
            lockedPerEra = lockedPerEra.sub(receivedLocked);
            receivedLocked = 0;
        } else {
            receivedLocked = receivedLocked.sub(lockedPerEra);
            lockedPerEra = 0;
        }

        totalByEra[i] = rewardsByEra[i].add(lockedPerEra);
      }

      return(totalByEra);
    }

    // Find the withdraw fee percentage
    function getWithdrawFeePercent(address _user, uint256 _pid) public view returns(uint) {
        UserInfo storage user = userInfo[_pid][_user];
        uint256 userDepositTime =  user.depositTime > startTime ? user.depositTime : startTime;

        uint256 lastedTime = block.timestamp - userDepositTime;
        uint _feePercent;
        if(lastedTime < 1 minutes) 
            _feePercent = 50;
        else if(lastedTime < 7 minutes)
            _feePercent = 25;
        else if(lastedTime < 14 minutes)
            _feePercent = 15;
        else if (lastedTime >= 14 minutes)
            _feePercent = 0;
        return _feePercent;
    }

    // Withdraw LP tokens and rewards from pool
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        
        uint256 blockNumber = block.number;
        uint256[] memory rewardsByEra;
        
        //updateEra();
        rewardsByEra = pendingRewardsCalc(_pid, msg.sender, blockNumber);

        uint256 pendingUnlocked = user.pendingUnlocked;
        uint256 pendingLocked = user.pendingLocked;
        uint withdrawFeePercent = getWithdrawFeePercent(msg.sender, _pid);
        uint256 currentEra = getEraNumber(blockNumber);

        if(currentEra <= 20) {
          if (pendingUnlocked >0) {
            safeFundTransfer(msg.sender, pendingUnlocked);
            user.pendingUnlocked = 0;
          }
          if (pendingLocked > 0) {
            user.lockedAmount = user.lockedAmount.add(pendingLocked);
            user.vestedAmount = user.lockedAmount;
            user.pendingLocked = 0;
          }
          user.lastRewardBlock = blockNumber;
          user.previousRewardBlock = blockNumber;
        } else {
          if (pendingUnlocked >0) {
            safeFundTransfer(msg.sender, pendingUnlocked);
            user.pendingUnlocked = 0;
          }
          if (pendingLocked > 0) {
            user.lockedAmount = pendingLocked;
            user.pendingLocked = 0;
          }
          user.lastRewardBlock = blockNumber;
          user.previousRewardBlock = blockNumber;
        }
        
        for(uint256 i=1; i<=numberOfEras;i++) {
            rewardAllocated[i] = rewardAllocated[i].sub(rewardsByEra[i]);
        }

        if (_amount>0) {
            if(withdrawFeePercent > 0){
                user.lpToken.safeTransfer(address(msg.sender), _amount.mul(100 - withdrawFeePercent).div(100));
                user.lpToken.safeTransfer(feeAddress, _amount.mul(withdrawFeePercent).div(100));
            }
            else{
                user.lpToken.safeTransfer(address(msg.sender), _amount);
            }
            user.amount = user.amount.sub(_amount);
            if (user.bridgedAmount > _amount) {
              user.bridgedAmount = user.bridgedAmount.sub(_amount);
            } else {
              user.bridgedAmount = 0;
            }
        }

        emit Withdraw(msg.sender, _amount, pendingUnlocked, pendingLocked);
    }

    // Withdraw all funds
    function withdrawAll(uint256 _pid) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        withdraw(_pid, user.amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        // UserInfo storage user = userInfo[msg.sender];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "nothing to withdraw");

        EmergencyInfo storage emergInfo = emergencyInfo[msg.sender];
        emergInfo.amount = user.pendingUnlocked.add(user.pendingLocked).add(user.lockedAmount);

        uint256 amount = user.amount;
        user.amount = 0;
        user.bridgedAmount = 0;
        user.depositTime = 0;
        user.depositBlock = 0;
        user.pendingUnlocked = 0;
        user.pendingLocked = 0;
        user.lockedAmount = 0;
        user.vestedAmount = 0;
        user.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }

    // Get the pool value of a specific token
    function getEmergencyWithdrawDetails(address _user) public view returns (uint256 amount) {
        EmergencyInfo storage emergInfo = emergencyInfo[_user];
        amount = emergInfo.amount;
    }

    // Deposit the reward fund
    function depositFund(uint256 _amount) external {
        require(msg.sender == fundmanager, "Only the authorized fund manager can deposit");
        ecto.safeTransferFrom(address(msg.sender), address(this), _amount);
        emit DepositFund(_amount);
    }
    
    // Withdraw the reward fund
    function withdrawFund(uint256 _amount) external {
        require(msg.sender == fundmanager, "Only the authorized fund manager can withdraw");
        safeFundTransfer(msg.sender, _amount);
        emit WithdrawFund(_amount);
    }
    
    // Safe ecto transfer function, just in case if rounding error causes pool to not have enough ECTOs.
    function safeFundTransfer(address _to, uint256 _amount) internal {
        uint256 rewardBal = ecto.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > rewardBal) {
            transferSuccess = ecto.transfer(_to, rewardBal);
        } else {
            transferSuccess = ecto.transfer(_to, _amount);
        }
        require(transferSuccess, "safeFundTransfer: transfer failed");
    }

    // Transfer locked rewards to based on the mining contract
    function safeLockedTransfer(address _to, uint256 _pid, uint256 _amount) external {
        require(msg.sender == rewardsMiningAddress, "Sorry you dont have permission to mine");
        UserInfo storage user = userInfo[_pid][_to];
        bool transferSuccess = false;

        if (_amount <= user.lockedAmount) {
          transferSuccess = ecto.transfer(_to, _amount);
          user.lockedAmount = user.lockedAmount.sub(_amount);
          user.vestedAmount = user.lockedAmount;
        } else {
          transferSuccess = ecto.transfer(_to, _amount);
          user.lockedAmount = 0;
          user.vestedAmount = 0;
        }

        require(transferSuccess, "safeLockedTransfer: transfer failed");

    }

}