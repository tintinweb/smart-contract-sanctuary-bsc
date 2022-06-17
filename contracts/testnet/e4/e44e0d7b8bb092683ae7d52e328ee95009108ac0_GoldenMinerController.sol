/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

pragma solidity 0.8.13;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = 0x80f0309FEd2454D58FC11Ad27c2e9e97a4cb4121;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
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
        return 8;
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(type(IERC165).interfaceId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: address zero is not a valid owner"
        );
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract GoldenMinerNFT is ERC721URIStorage, Ownable {
    using SafeMath for uint256;

    event MinerCreated(
        address indexed user,
        uint256 minerId,
        uint256 rarity,
        uint256 image
    );
    event BoxOpened(address indexed user, uint256 cost, uint256 tokenId);

    // mapping
    mapping(uint256 => uint256) public CounterToMiner;
    mapping(uint256 => uint256) public MinerToUserIndex;
    mapping(address => uint256[]) public UserToMiners;
    mapping(uint256 => uint256) public MinerToRarity;
    mapping(address => mapping(uint256 => uint256)) public UserRarityCount;
    mapping(uint256 => uint256) public MinerToImage;

    //token payment
    address public GDM = 0xf5d4dB86BDac13dBB84fc1bdD9fd98BAbfcC801C;

    //recipient
    address public recipientAddress =
        0x80f0309FEd2454D58FC11Ad27c2e9e97a4cb4121;

    uint256 public presaleStartTime = 1650542400;
    uint256 public presaleEndTime = 1672544000;

    uint256[3] public boxsPrices;
    uint256[3] public boxSellMaxs;
    uint256[3][3] public boxRates;
    uint256 private minerHat;
    uint256 private minerSkirt;
    uint256 private minerShoe;

    //seed number
    uint256 private randNum = 0;
    uint256 public counter;

    constructor() ERC721("GoldenMinerNFT", "GDMN") {
        counter = 0;
        boxRates[0] = [60, 95, 100];
        boxRates[1] = [0, 70, 97];
        boxRates[2] = [0, 0, 80];

        boxsPrices = [18000, 37000, 60000];
        boxSellMaxs = [500, 300, 100];

        minerHat = 2;
        minerSkirt = 2;
        minerShoe = 2;
    }

    function setBoxsRate(
        uint256 boxId,
        uint256 normal,
        uint256 rare,
        uint256 legend,
        uint256 god
    ) public onlyOwner {
        require(normal + rare + legend + god == 100, "Unexpected ratings");
        boxRates[boxId - 1][0] = 100 - rare;
        boxRates[boxId - 1][1] = 100 - legend;
        boxRates[boxId - 1][2] = 100 - god;
    }

    function setBoxsPrice(uint256 boxId, uint256 price) public onlyOwner {
        boxsPrices[boxId - 1] = price;
    }

    function setBoxSellMax(uint256 boxId, uint256 num) public onlyOwner {
        boxSellMaxs[boxId - 1] = num;
    }

    function setStartTime(uint256 startTime) public onlyOwner {
        presaleStartTime = startTime;
    }

    function setEndTime(uint256 endTime) public onlyOwner {
        presaleEndTime = endTime;
    }

    function setMinerHat(uint256 num) public onlyOwner {
        minerHat = num;
    }

    function setMinerSkirt(uint256 num) public onlyOwner {
        minerSkirt = num;
    }

    function setMinerShoe(uint256 num) public onlyOwner {
        minerShoe = num;
    }

    function setRecipientAddress(address recipient) public onlyOwner {
        recipientAddress = recipient;
    }

    function setGDMAddress(address gdm) public onlyOwner {
        GDM = gdm;
    }

    function openBox(uint256 boxId) public returns (uint256) {
        //check time
        require(
            presaleStartTime < block.timestamp &&
                block.timestamp < presaleEndTime,
            "Presale is not open yet"
        );

        //check soldout
        require(boxSellMaxs[boxId - 1] >= 1, "Box is sold out");

        //decrease box
        boxSellMaxs[boxId - 1] -= 1;

        //get box price
        uint256 decimals = ERC20(GDM).decimals();
        uint256 price = boxsPrices[boxId - 1] * 10**decimals;

        //buy box
        ERC20(GDM).transferFrom(_msgSender(), recipientAddress, price);

        //get miner's rarity
        uint256 rarity = _getRarity(boxId);

        //open box
        uint256 minerId = _createMiner(msg.sender, rarity);

        emit BoxOpened(msg.sender, price, minerId);

        return minerId;
    }

    function _createMiner(address user, uint256 rarity)
        private
        returns (uint256)
    {
        counter++;
        uint256 minerId = _rand();

        //mint erc721
        _safeMint(user, minerId);

        CounterToMiner[counter] = minerId;
        MinerToUserIndex[minerId] = UserToMiners[user].length;
        MinerToRarity[minerId] = rarity;
        UserToMiners[user].push(minerId);
        UserRarityCount[user][rarity] += 1;

        uint256 hat = ((
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        (randNum++) * block.number,
                        msg.sender
                    )
                )
            )
        ) % minerHat) + 1;
        uint256 skirt = ((
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        (randNum++) * block.number,
                        msg.sender
                    )
                )
            )
        ) % minerSkirt) + 1;
        uint256 shoe = ((
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        (randNum++) * block.number,
                        msg.sender
                    )
                )
            )
        ) % minerShoe) + 1;

        MinerToImage[minerId] =
            (rarity * 10000) +
            (hat * 100) +
            (skirt * 10) +
            shoe;

        emit MinerCreated(user, minerId, rarity, MinerToImage[minerId]);
        return minerId;
    }

    function createMinerByOwner(address user, uint256 rarity)
        public
        onlyOwner
        returns (uint256)
    {
        return _createMiner(user, rarity);
    }

    function burn(uint256 tokenId) public virtual {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: you are not the owner nor approved!"
        );
        super._burn(tokenId);
    }

    function _getRarity(uint256 boxId) internal virtual returns (uint256) {
        uint256 number = (
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        (randNum++) * block.number,
                        msg.sender
                    )
                )
            )
        ) % 100;
        if (number >= boxRates[boxId - 1][2]) {
            return 4;
        }
        if (number >= boxRates[boxId - 1][1]) {
            return 3;
        }
        if (number >= boxRates[boxId - 1][0]) {
            return 2;
        }

        return 1;
    }

    function _rand() internal virtual returns (uint256) {
        uint256 number = (uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    (randNum++) * block.number,
                    msg.sender
                )
            )
        ) % (4 * 10**9)) + 1968769868;

        return number;
    }

    function getPresaleTime()
        public
        view
        returns (uint256[2] memory presaleTime)
    {
        presaleTime = [presaleStartTime, presaleEndTime];
        return presaleTime;
    }

    function getBoxPrices() public view returns (uint256[3] memory prices) {
        prices = boxsPrices;
        return prices;
    }

    function getBoxSellMaxs() public view returns (uint256[3] memory times) {
        times = boxSellMaxs;
        return times;
    }

    function getUserMiners(address user)
        public
        view
        returns (uint256[] memory tokenIds)
    {
        uint256 count;

        uint256[] memory tokenIds0 = new uint256[](
            uint256(UserToMiners[user].length)
        );

        for (uint256 i = 0; i < UserToMiners[user].length; i++) {
            if (UserToMiners[user][i] != 0) {
                tokenIds0[count] = UserToMiners[user][i];
                count++;
            }
        }

        tokenIds = new uint256[](uint256(count));

        for (uint256 i = 0; i < count; i++) {
            tokenIds[i] = tokenIds0[i];
        }

        return tokenIds;
    }

    function getBalance(address user) public view returns (uint256 balance) {
        balance = ERC20(GDM).balanceOf(user);
        return balance;
    }

    function getUserMinerImagesByPageNumber(address user, uint256 pageNumber)
        public
        view
        returns (uint256[10] memory imageIds)
    {
        uint256 num = UserToMiners[user].length;

        if (num > 0) {
            uint256[] memory allImageIds = new uint256[](uint256(num));

            uint256 count;

            for (uint256 i = 0; i < num; i++) {
                if (UserToMiners[user][i] == 0) {
                    count++;
                    continue;
                } else {
                    allImageIds[i - count] = MinerToImage[
                        UserToMiners[user][i]
                    ];
                }
            }

            uint256 start = (pageNumber - 1) * 10;

            uint256 end = start + 10;

            for (uint256 j = start; j < end; j++) {
                if (j < num && allImageIds[j] != 0) {
                    uint256 k = j - start;
                    imageIds[k] = allImageIds[j];
                }
            }

            return imageIds;
        }
    }

    function getMinerImages(address user)
        public
        view
        returns (uint256[] memory imageIds)
    {
        uint256[] memory tokenIds0 = getUserMiners(user);

        uint256 num = tokenIds0.length;

        imageIds = new uint256[](uint256(num));

        uint256 count;

        for (uint256 i = 0; i < num; i++) {
            if (tokenIds0[i] == 0) {
                count++;
                continue;
            } else {
                imageIds[i - count] = MinerToImage[UserToMiners[user][i]];
            }
        }

        return imageIds;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        uint256 index = MinerToUserIndex[tokenId];

        UserToMiners[from][index] = 0;

        MinerToUserIndex[tokenId] = UserToMiners[to].length;

        UserToMiners[to].push(tokenId);

        UserRarityCount[from][MinerToRarity[tokenId]] -= 1;

        UserRarityCount[to][MinerToRarity[tokenId]] += 1;

        return super._transfer(from, to, tokenId);
    }
}

contract GoldenMinerController is Ownable {
    using SafeMath for uint256;

    event MinerSellPosted(address indexed user, uint256 tokenId, uint256 price);
    event MinerSellCanceled(address indexed user, uint256 tokenId);
    event MinerBought(
        address indexed seller,
        address indexed buyer,
        uint256 tokenId,
        uint256 price
    );
    event PoolMinted(
        uint256 poolId,
        uint256 tokenId,
        uint256 coolDown,
        uint256 reward
    );
    event DynamiteBought(uint256 tokenId, uint256 amount, uint256 price);
    event CloverBought(uint256 tokenId, uint256 amount, uint256 price);

    struct Miner {
        uint256 tokenId;
        uint256 id;
        uint256 image;
        bool isOnsell;
        uint256 coolDown;
        uint256 dynamiteCount;
        uint256 cloverCount;
    }

    struct Sell {
        address onwerAddr;
        uint256 tokenId;
        uint256 image;
        uint256 price;
        bool sold;
    }

    struct Pool {
        uint256 id;
        uint256 minReward;
        uint256 maxReward;
        uint256 mintTime;
    }

    GoldenMinerNFT GDMN;
    //token payment
    address public _GDMN = 0x03a9A284E0495ae4c2af484b741A89480d26Ce00;
    address public GDM = 0xf5d4dB86BDac13dBB84fc1bdD9fd98BAbfcC801C;

    mapping(uint256 => Miner) private MinerToNFT;
    mapping(uint256 => Miner) private MinerStds;
    mapping(uint256 => uint256) private MinerToActivatedTime;
    mapping(uint256 => uint256) public MinerSource;

    mapping(uint256 => Sell) public MinerToSell;
    mapping(uint256 => uint256) public IndexToSell;
    uint256 public sellCount;

    address public rewardAddr = 0x80f0309FEd2454D58FC11Ad27c2e9e97a4cb4121;
    address public itemAddr = 0x80f0309FEd2454D58FC11Ad27c2e9e97a4cb4121;

    uint256 public poolCount;
    uint256 public dynamiteDecrease = 10;
    uint256 public cloverIncrease = 8;
    uint256 public dynamitePrice = 100;
    uint256 public cloverPrice = 200;
    mapping(uint256 => Pool) public Pools;
    mapping(uint256 => uint256) public RarityToCDDecrease;
    mapping(uint256 => uint256) public RarityToRewardIncrease;

    constructor() {
        GDMN = GoldenMinerNFT(_GDMN);

        MinerStds[1] = Miner(0, 1, 0, false, 0, 0, 0);
        MinerStds[2] = Miner(0, 2, 0, false, 0, 0, 0);
        MinerStds[3] = Miner(0, 3, 0, false, 0, 0, 0);
        MinerStds[4] = Miner(0, 4, 0, false, 0, 0, 0);

        Pools[1] = Pool(1, 60, 360, 7200);
        Pools[2] = Pool(2, 150, 270, 5200);
        Pools[3] = Pool(3, 250, 660, 15000);
        Pools[4] = Pool(4, 600, 1500, 48800);

        poolCount = 4;

        RarityToCDDecrease[1] = 0;
        RarityToCDDecrease[2] = 10;
        RarityToCDDecrease[3] = 30;
        RarityToCDDecrease[4] = 55;

        RarityToRewardIncrease[1] = 0;
        RarityToRewardIncrease[2] = 5;
        RarityToRewardIncrease[3] = 15;
        RarityToRewardIncrease[4] = 35;
    }

    function setGDM(address gdm) public onlyOwner {
        GDM = gdm;
    }

    function setGDMN(address gdmn) public onlyOwner {
        GDMN = GoldenMinerNFT(gdmn);
    }

    function setRarityToCDDecrease(uint256 poolId, uint256 per)
        public
        onlyOwner
    {
        require(poolId >= 1 && poolId <= poolCount, "Unexpected pool");

        RarityToCDDecrease[poolId] = per;
    }

    function setRarityToRewardIncrease(uint256 poolId, uint256 per)
        public
        onlyOwner
    {
        require(poolId >= 1 && poolId <= poolCount, "Unexpected pool");

        RarityToRewardIncrease[poolId] = per;
    }

    function setDynamiteDecrease(uint256 per) public onlyOwner {
        dynamiteDecrease = per;
    }

    function setCloverIncrease(uint256 per) public onlyOwner {
        cloverIncrease = per;
    }

    function setDynamitePrice(uint256 price) public onlyOwner {
        dynamitePrice = price;
    }

    function setCloverPrice(uint256 price) public onlyOwner {
        cloverPrice = price;
    }

    function setRewardAddr(address account) public onlyOwner {
        rewardAddr = account;
    }

    function setItemAddr(address account) public onlyOwner {
        itemAddr = account;
    }

    function setPool(
        uint256 poolId,
        uint256 minReward,
        uint256 maxReward,
        uint256 coolDown
    ) public onlyOwner {
        require(poolId >= 1 && poolId <= poolCount, "Unexpected pool");
        Pools[poolId] = Pool(poolId, minReward, maxReward, coolDown);
    }

    function addPool(
        uint256 minReward,
        uint256 maxReward,
        uint256 coolDown
    ) public onlyOwner {
        poolCount += 1;
        Pools[poolCount] = Pool(poolCount, minReward, maxReward, coolDown);
    }


    function getSells(uint256 size) public view returns (Sell[] memory sells) {
        Sell[] memory _sells = new Sell[](sellCount);
        for (uint256 i = 0; i < size; i++) {
            _sells[i] = MinerToSell[IndexToSell[i]];
        }
        return _sells;
    }

    function buyClover(uint256 tokenId, uint256 amount) public {
        require(amount > 0, "Unexpected amount");
        require(GDMN.ownerOf(tokenId) == msg.sender, "You are not owner");
        if (MinerToNFT[tokenId].tokenId == 0) {
            _activateMiner(tokenId);
        }

        uint256 decimals = ERC20(GDM).decimals();
        uint256 price = amount.mul(cloverPrice) * 10**decimals;
        ERC20(GDM).transferFrom(_msgSender(), itemAddr, price);

        MinerToNFT[tokenId].cloverCount += amount;

        emit CloverBought(tokenId, amount, price);
    }

    function buyDynamite(uint256 tokenId, uint256 amount) public {
        require(amount > 0, "Unexpected amount");
        require(GDMN.ownerOf(tokenId) == msg.sender, "You are not owner");
        if (MinerToNFT[tokenId].tokenId == 0) {
            _activateMiner(tokenId);
        }

        uint256 decimals = ERC20(GDM).decimals();
        uint256 price = amount.mul(dynamitePrice) * 10**decimals;
        ERC20(GDM).transferFrom(_msgSender(), itemAddr, price);

        MinerToNFT[tokenId].dynamiteCount += amount;

        emit DynamiteBought(tokenId, amount, price);
    }

    function mint(uint256 poolId, uint256 tokenId) public {
        require(poolId >= 1 && poolId <= poolCount, "Unexpected pool");

        require(GDMN.ownerOf(tokenId) == msg.sender, "You are not owner");

        if (MinerToNFT[tokenId].tokenId == 0) {
            _activateMiner(tokenId);
        }

        Miner memory userMiner = MinerToNFT[tokenId];

        require(
            userMiner.id != 0 && !userMiner.isOnsell,
            "This miner is unavailable"
        );

        require(userMiner.coolDown <= block.timestamp, "Miner is cooldown");

        Pool memory pool = Pools[poolId];
        uint256 userMinerRarity = GDMN.MinerToRarity(tokenId);

        //cool down
        uint256 takenTime = (
            pool.mintTime.mul(100 - RarityToCDDecrease[userMinerRarity])
        ).div(100);

        if (userMiner.dynamiteCount > 0) {
            takenTime = (takenTime.mul(100 - dynamiteDecrease)).div(100);
            MinerToNFT[tokenId].dynamiteCount -= 1;
        }

        MinerToNFT[tokenId].coolDown = block.timestamp.add(takenTime);
        //reward
        uint256 reward = pool.minReward.add(
            (
                uint256(
                    keccak256(abi.encodePacked(block.timestamp, msg.sender))
                )
            ) % pool.maxReward
        );
        uint256 decimals = ERC20(GDM).decimals();

        reward =
            reward.mul(100 + RarityToRewardIncrease[userMinerRarity]).div(100) *
            10**decimals;

        if (userMiner.cloverCount > 0) {
            reward = (reward.mul(100 + cloverIncrease)).div(100);
            MinerToNFT[tokenId].cloverCount -= 1;
        }

        ERC20(GDM).transferFrom(rewardAddr, _msgSender(), reward);

        emit PoolMinted(poolId, tokenId, userMiner.coolDown, reward);
    }

    function sellMinerCard(uint256 tokenId, uint256 price) public {
        require(GDMN.ownerOf(tokenId) == msg.sender, "You are not owner");
        require(GDMN.getApproved(tokenId) == address(this), "Not approved");

        if (MinerToNFT[tokenId].tokenId == 0) {
            _activateMiner(tokenId);
        }

        require(
            MinerToNFT[tokenId].id != 0 && !MinerToNFT[tokenId].isOnsell,
            "Unexpected miner"
        );
        require(price > 0, "Illegal price");

        MinerToSell[tokenId].tokenId = tokenId;
        MinerToSell[tokenId].image = MinerToNFT[tokenId].image;
        MinerToSell[tokenId].onwerAddr = msg.sender;
        MinerToSell[tokenId].price = price;
        MinerToSell[tokenId].sold = false;

        MinerToNFT[tokenId].isOnsell = true;
        IndexToSell[sellCount] = tokenId;
        sellCount += 1;

        emit MinerSellPosted(msg.sender, tokenId, price);
    }

    function cancelSellMinerCard(uint256 tokenId) public {
        require(GDMN.ownerOf(tokenId) == msg.sender, "You are not owner");

        require(
            MinerToNFT[tokenId].id != 0 &&
                MinerToNFT[tokenId].isOnsell &&
                MinerToSell[tokenId].price > 0,
            "Miner card not sell yet"
        );

        delete MinerToSell[tokenId];
        MinerToNFT[tokenId].isOnsell = false;
        sellCount -= 1;
        delete IndexToSell[sellCount];

        emit MinerSellCanceled(msg.sender, tokenId);
    }

    function buyMinerCard(uint256 tokenId) public {
        address ownerAddress = MinerToSell[tokenId].onwerAddr;

        require(
            ownerAddress != msg.sender &&
                MinerToNFT[tokenId].id != 0 &&
                MinerToNFT[tokenId].isOnsell &&
                MinerToSell[tokenId].price > 0,
            "Unexpected miner"
        );

        uint256 decimals = ERC20(GDM).decimals();

        uint256 price = MinerToSell[tokenId].price * 10**decimals;

        ERC20(GDM).transferFrom(_msgSender(), ownerAddress, price);
        MinerToNFT[tokenId].isOnsell = false;

        GDMN.transferFrom(ownerAddress, _msgSender(), tokenId);

        MinerToSell[tokenId].sold = true;
        MinerSource[tokenId] = 2;

        emit MinerBought(ownerAddress, msg.sender, tokenId, price);
    }

    function _activateMiner(uint256 tokenId) internal virtual {
        uint256 rarity = GDMN.MinerToRarity(tokenId);

        MinerToNFT[tokenId] = MinerStds[rarity];
        MinerToNFT[tokenId].tokenId = tokenId;
        MinerToNFT[tokenId].image = GDMN.MinerToImage(tokenId);
        MinerToNFT[tokenId].coolDown = block.timestamp;
        MinerToActivatedTime[tokenId] = block.timestamp;
        MinerSource[tokenId] = 1;
    }

    function getMiner(uint256 tokenId)
        public
        view
        returns (Miner memory miner)
    {
        if (MinerToNFT[tokenId].tokenId == 0) {
            miner = MinerStds[GDMN.MinerToRarity(tokenId)];
            miner.tokenId = tokenId;
            miner.image = GDMN.MinerToImage(tokenId);
        } else {
            miner = MinerToNFT[tokenId];
        }

        return miner;
    }

    function getUserMiners(address user)
        public
        view
        returns (Miner[] memory userMiners)
    {
        uint256[] memory userTokenIds = GDMN.getUserMiners(user);

        Miner[] memory myMiners = new Miner[](uint256(userTokenIds.length));

        uint256 tokenId;

        uint256 counter;

        for (uint256 i = 0; i < userTokenIds.length; i++) {
            tokenId = userTokenIds[i];

            if (tokenId != 0 && !MinerToNFT[tokenId].isOnsell) {
                myMiners[counter] = getMiner(tokenId);
                counter++;
            }
        }

        userMiners = new Miner[](uint256(counter));

        for (uint256 i = 0; i < counter; i++) {
            userMiners[i] = myMiners[i];
        }

        return userMiners;
    }

    function getUserMinersAvailable(address user)
        public
        view
        returns (Miner[] memory userMiners)
    {
        uint256[] memory userTokenIds = GDMN.getUserMiners(user);

        Miner[] memory myMiners = new Miner[](uint256(userTokenIds.length));

        uint256 counter;

        for (uint256 i = 0; i < userTokenIds.length; i++) {
            Miner memory myMiner = getMiner(userTokenIds[i]);
            if (!myMiner.isOnsell && myMiner.coolDown < block.timestamp) {
                myMiners[counter] = myMiner;
                counter++;
            }
        }


        userMiners = new Miner[](uint256(counter));

        for (uint256 i = 0; i < counter; i++) {
            userMiners[i] = myMiners[i];
        }

        return userMiners;
    }
}