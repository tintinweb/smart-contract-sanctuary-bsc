/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// Sources flattened with hardhat v2.9.3 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT
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

// File @openzeppelin/contracts/access/[email protected]

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

// File @openzeppelin/contracts/utils/math/[email protected]

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

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

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

// File contracts/ido/bull/ido/import/invite/InviteStore.sol

pragma solidity ^0.8.0;

abstract contract InviteStore is Ownable {
    using SafeMath for uint256;

    // part 1: store
    struct InviteInfo {
        address self;
        address parent;
        address[] childs;
        uint256 childsLength;
        uint256 amountOfChildsInputUsdt;
    }
    // invite relation
    mapping(address => address) public inviteFroms;
    mapping(address => mapping(uint256 => address)) public inviteTos;
    // count
    mapping(address => uint256) public inviteToCountDirects; // direct childs count
    mapping(address => uint256) public inviteToAmountOfInputCoinDirects; // direct childs input coins amount
    // enumable
    address[] public invites; // work with methods : invitesLength() listInviteInfo()

    // reward config
    uint256 public rewardGenerates = 3;
    uint256[] public rewardBipsPerGen = [500, 300, 200];
    mapping(address => uint256) public inviteRewardsByUsdt;
}

// File contracts/ido/bull/ido/import/invite/InviteBase.sol

pragma solidity ^0.8.0;

abstract contract InviteBase is InviteStore {
    using SafeMath for uint256;

    function _inviteTotalBips() internal view returns (uint256) {
        uint256 t = 0;
        for (uint256 i = 0; i < rewardBipsPerGen.length; i++) {
            t += rewardBipsPerGen[i];
        }
        return t;
    }

    function _isInviteFromChild(address to, address from)
        internal
        returns (bool)
    {
        if (inviteToCountDirects[to] == 0) return false;
        for (uint256 i = 0; i < inviteToCountDirects[to]; i++) {
            if (inviteTos[to][i] == from) return true;
            if (_isInviteFromChild(inviteTos[to][i], from)) return true;
        }
        return false;
    }

    function _addInviteCount(
        address to,
        address from,
        uint256 amount_
    ) internal {
        if (from == address(0)) {
            return;
        }

        inviteTos[from][inviteToCountDirects[from]] = to;
        inviteToCountDirects[from] = inviteToCountDirects[from].add(1);
        inviteToAmountOfInputCoinDirects[
            from
        ] = inviteToAmountOfInputCoinDirects[from].add(amount_);

        if (inviteToCountDirects[from] == 1) {
            invites.push(from);
        }
    }
}

// File contracts/ido/bull/ido/import/invite/InviteAdmin.sol

pragma solidity ^0.8.0;

abstract contract InviteAdmin is InviteBase {
    // set
    function setRewardGenerates(uint256 gen_) public onlyOwner {
        rewardGenerates = gen_;
    }

    function setRewardBipsPerGen(uint256 genIdx_, uint256 bips_)
        public
        onlyOwner
    {
        if (genIdx_ < rewardBipsPerGen.length) {
            rewardBipsPerGen[genIdx_] = bips_;
        } else {
            rewardBipsPerGen.push(bips_);
        }
    }

    // get
    function invitesLength() public view returns (uint256) {
        return invites.length;
    }

    function listInviteInfo(uint256 pageStart, uint256 pageSize)
        public
        view
        returns (InviteInfo[] memory)
    {
        if (pageStart == 0 || invites.length == 0) {
            return new InviteInfo[](0);
        }
        uint256 pageEnd = pageStart + pageSize - 1;
        if (pageEnd > (invites.length - 1)) {
            pageEnd = invites.length - 1;
        }
        InviteInfo[] memory rs = new InviteInfo[](pageEnd - pageStart + 1);
        uint256 pageStartInit = pageStart;
        for (; pageStart <= pageEnd; pageStart++) {
            address[] memory childs = new address[](
                inviteToCountDirects[invites[pageStart]]
            );
            for (
                uint256 i = 0;
                i < inviteToCountDirects[invites[pageStart]];
                i++
            ) {
                childs[i] = inviteTos[invites[pageStart]][i];
            }
            rs[pageStart - pageStartInit] = InviteInfo(
                invites[pageStart],
                inviteFroms[invites[pageStart]],
                childs,
                inviteToCountDirects[invites[pageStart]],
                inviteToAmountOfInputCoinDirects[invites[pageStart]]
            );
        }
        return rs;
    }
}

// File contracts/ido/bull/ido/import/invite/Invite.sol

pragma solidity ^0.8.0;

contract Invite is InviteAdmin {
    function _setInviteFrom(
        address to,
        address from,
        uint256 amount_
    ) internal {
        require(to != address(0), "invite from or to zero");
        if (from == address(0) || from == to || _isInviteFromChild(to, from)) {
            return;
        }

        // console.log(to, from, inviteFroms[to]);
        if (inviteFroms[to] == address(0)) {
            inviteFroms[to] = from;
            _addInviteCount(to, from, amount_);
        } else {
            //ignore, had accept others invite
            return;
        }
    }
}

// File contracts/ido/bull/ido/BullIdoStore.sol

pragma solidity ^0.8.0;

abstract contract BullIdoStore is Invite {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant BIPS_BASE = 1e4;
    uint256 public constant PRICE_MULTIPLE = 1e6;
    // input
    address public usdt;
    // out
    address[] public receivers;
    uint256[] public receiverWeights;
    // enumable buyers
    struct BuyCount {
        address buyer;
        uint256 amountOfInputUsdt;
    }
    BuyCount[] public buyCounts;
    mapping(address => uint256) public buyIdxs; // addr=> index+1

    uint256 public timeOfStartInSeconds;
    uint256 public timeLengthInSeconds;
}

// File contracts/ido/bull/ido/BullIdoBase.sol

pragma solidity ^0.8.0;

abstract contract BullIdoBase is BullIdoStore {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function _isIdoActive() internal view returns (bool) {
        return
            block.timestamp >= timeOfStartInSeconds &&
            block.timestamp < timeOfStartInSeconds.add(timeLengthInSeconds);
    }

    function _initIdoActiveTime(uint256 start_, uint256 activeLen_) internal {
        timeOfStartInSeconds = start_;
        timeLengthInSeconds = activeLen_;
    }

    function _addBuyCountRecord(address addr_, uint256 amountOfUsdt_) internal {
        if (addr_ == address(0)) return;
        if (amountOfUsdt_ == 0) return;
        if (buyIdxs[addr_] == 0) {
            buyCounts.push(BuyCount(addr_, amountOfUsdt_));
            buyIdxs[addr_] = buyCounts.length;
        } else {
            buyCounts[buyIdxs[addr_] - 1].amountOfInputUsdt = buyCounts[
                buyIdxs[addr_] - 1
            ].amountOfInputUsdt.add(amountOfUsdt_);
        }
    }

    function _initReceiver(address receiver1_, address receiver2_) internal {
        receivers.push(receiver1_);
        receivers.push(receiver2_);
        receiverWeights.push(8700);
        receiverWeights.push(1300);
    }

    function _transferInputCoinToReceivers(uint256 amount_) internal {
        require(amount_ > 0, "amount zero");
        require(usdt != address(0), "input coin address zero");
        require(receivers.length > 0, "no receiver");
        uint256 amountOfRemain = amount_;
        for (uint256 i = 0; i < receivers.length; i++) {
            uint256 amt = amount_.mul(receiverWeights[i]).div(BIPS_BASE);
            if (amt == 0) continue;
            amountOfRemain = amountOfRemain.sub(amt);
            _safeTransferFrom(usdt, amt, receivers[i]);
        }
        if (amountOfRemain > 0) {
            _safeTransferFrom(
                usdt,
                amountOfRemain,
                receivers[receivers.length - 1]
            );
        }
    }

    function _transferInputCoinsToInviters(
        address buyer_,
        uint256 amount_,
        uint256 amountTotal_
    ) internal returns (uint256 _amountOfHadSend) {
        require(buyer_ != address(0), "address zero");
        require(usdt != address(0), "usdt address zero");
        if (amount_ == 0) {
            _amountOfHadSend = 0;
            return _amountOfHadSend;
        }

        uint256 effectGens = rewardGenerates;
        if (effectGens > rewardBipsPerGen.length) {
            effectGens = rewardBipsPerGen.length;
        }
        uint256 remainReward = amount_;
        address f = buyer_;
        for (uint256 i = 0; i < effectGens; i++) {
            f = inviteFroms[f];

            if (f == address(0)) break;
            uint256 amountTo = amountTotal_.mul(rewardBipsPerGen[i]).div(
                BIPS_BASE
            );
            remainReward = remainReward.sub(amountTo);
            inviteRewardsByUsdt[f] = inviteRewardsByUsdt[f].add(amountTo);

            _safeTransferFrom(usdt, amountTo, f);
        }
        _amountOfHadSend = amount_.sub(remainReward);
        return _amountOfHadSend;
    }

    function _safeTransferFrom(
        address coin,
        uint256 amount,
        address receiver
    ) internal {
        IERC20(coin).safeTransferFrom(_msgSender(), receiver, amount);
    }

    function _parse64BytesToUint256AndAddress(bytes memory data)
        internal
        pure
        returns (uint256 parsed, address parsedAddress)
    {
        assembly {
            parsed := mload(add(data, 32))
            parsedAddress := mload(add(data, 64))
        }
    }
}

// File contracts/ido/bull/ido/BullIdoAdmin.sol

pragma solidity ^0.8.0;

abstract contract BullIdoAdmin is BullIdoBase {
    using SafeMath for uint256;

    // set
    function setTimeOfStartInSeconds(uint256 start_) public onlyOwner {
        timeOfStartInSeconds = start_;
    }

    function setTimeLengthInSeconds(uint256 len_) public onlyOwner {
        timeLengthInSeconds = len_;
    }

    function setInputCoin(address usdt_) public onlyOwner {
        require(usdt_ != address(0), "address zero");
        usdt = usdt_;
    }

    function setReceiver(address addr_, uint256 weight_) public onlyOwner {
        require(addr_ != address(0), "address zero");
        for (uint256 i = 0; i < receivers.length; i++) {
            if (receivers[i] == addr_) {
                receiverWeights[i] = weight_;
                return;
            }
        }
        receivers.push(addr_);
        receiverWeights.push(weight_);
        return;
    }

    // get
    function isIdoActive() public view returns (bool) {
        return _isIdoActive();
    }

    function totalBuyers() public view returns (uint256) {
        return buyCounts.length;
    }

    function getAmountOfIuputUsdt(address addr_)
        external
        view
        returns (uint256)
    {
        if (addr_ == address(0)) return 0;
        if (buyIdxs[addr_] == 0) return 0;
        return buyCounts[buyIdxs[addr_] - 1].amountOfInputUsdt;
    }

    // buss
    function allowanceOfCoin(address coin)
        public
        view
        returns (uint256, address)
    {
        return (
            IERC20(coin).allowance(_msgSender(), address(this)),
            address(this)
        );
    }
}

// File contracts/ido/bull/ido/BullIdo.sol

pragma solidity ^0.8.0;

contract BullIdo is BullIdoAdmin {
    using SafeMath for uint256;

    constructor() {
        setInputCoin(0x55d398326f99059fF775485246999027B3197955);
        _initReceiver(
            0x09a8e13F2788008BAfb3d847d69F6Fd0f6c45372,
            0x98d4b08CedD71ac5bbBF44b97472dfa45f40Db21
        );
        _initIdoActiveTime(block.timestamp, 10 days);
    }

    // core
    function buy(uint256 amount_, address inviteFrom_) public {
        // check
        require(amount_ > 0, "args: amount zero");
        require(_isIdoActive(), "IDO not active time");
        uint256 amountOfInviteReward = amount_.mul(_inviteTotalBips()).div(
            BIPS_BASE
        );

        // apply
        _setInviteFrom(_msgSender(), inviteFrom_, amount_);
        uint256 amountOfHadSend = _transferInputCoinsToInviters(
            _msgSender(),
            amountOfInviteReward,
            amount_
        );
        uint256 amountOfRemain = amount_.sub(amountOfHadSend);
        _transferInputCoinToReceivers(amountOfRemain);
        _addBuyCountRecord(_msgSender(), amount_);
    }
}