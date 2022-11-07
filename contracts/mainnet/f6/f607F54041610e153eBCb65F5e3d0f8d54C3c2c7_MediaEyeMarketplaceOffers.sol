/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// Sources flattened with hardhat v2.4.3 https://hardhat.org

// File @openzeppelin/contracts/proxy/[email protected]

// SPDX-License-Identifier: MIT AND Apache-2.0

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// File contracts/Airdrops/AirDropFactory.sol

pragma solidity ^0.8.0;

interface AirDrop {
    function initialize(
        address _owner,
        address _tokenContract,
        bytes32 _merkleRoot,
        bool _cancelable
    ) external;
}

contract AirDropFactory {
    event AirdropDeployed(address addr);

    function createAirdrop(
        address _implementation,
        address _owner,
        address _tokenContract,
        bytes32 _merkleRoot,
        bool _cancelable
    ) external returns (address clone) {
        clone = Clones.clone(_implementation);
        AirDrop(clone).initialize(
            _owner,
            _tokenContract,
            _merkleRoot,
            _cancelable
        );
        emit AirdropDeployed(clone);
    }
}


// File @openzeppelin/contracts/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]


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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/utils/[email protected]


pragma solidity ^0.8.0;

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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


pragma solidity ^0.8.0;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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


// File @openzeppelin/contracts/utils/introspection/[email protected]


pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC721/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}


// File @openzeppelin/contracts/token/ERC1155/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


// File @openzeppelin/contracts/token/ERC721/[email protected]


pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC721/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// File @openzeppelin/contracts/token/ERC1155/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/utils/introspection/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]


pragma solidity ^0.8.0;


/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


// File @openzeppelin/contracts/token/ERC1155/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}


// File @openzeppelin/contracts/utils/[email protected]


pragma solidity ^0.8.0;

/*
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


// File @openzeppelin/contracts/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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


// File @openzeppelin/contracts/access/[email protected]


pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// File @openzeppelin/contracts/utils/structs/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


// File @openzeppelin/contracts/security/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
     * by making the `nonReentrant` function external, and make it call a
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


// File contracts/curatedAirdrops/MediaEyeCuratedAirdrops.sol

pragma solidity ^0.8.0;










contract MediaEyeCuratedAirdrops is
    ERC721Holder,
    ERC1155Holder,
    AccessControl,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    Counters.Counter private _airdropIds;
    EnumerableSet.AddressSet private paymentMethods;

    address payable public feeWallet;

    struct Airdrop {
        AirdropType airdropType;
        bool promoCode;
        address contractAddress;
        address owner;
        bytes32 merkleRoot;
        uint256 startTime;
        uint256 endTime;
        uint256[] tokenIds;
        uint256[] maxTokenAmounts;
        bool featured;
        bool finished;
        mapping(address => bool) collected;
        mapping(string => bool) promoCollected;
        mapping(address => mapping(uint256 => bool)) collectedNfts;
        mapping(string => mapping(uint256 => bool)) promoCollectedNfts;
    }

    enum AirdropType {
        ERC20,
        ERC721,
        ERC1155
    }

    event StartAirdrop(
        uint256 airdropId,
        uint256 startTime,
        uint256 endTime,
        bool featured
    );

    event AirdropEnded(uint256 airdropId);
    event AirdropTransfer(uint256 id, address addr, uint256 num);
    event Airdrop721Transfer(uint256 id, address addr, uint256 tokenId);
    event Airdrop1155Transfer(
        uint256 id,
        address addr,
        uint256[] tokenId,
        uint256[] num
    );
    event TokenAmountsChanged(address paymentMethod, uint256 tokenAmounts);
    event PaymentAdded(address paymentMethod, uint256 tokenAmounts);
    event PaymentRemoved(address paymentMethod);
    event FeeWalletChanged(address newFeeWallet);

    mapping(uint256 => Airdrop) public airdrops;
    mapping(address => uint256) public paymentMethodAmounts;

    constructor(
        address _owner,
        address[] memory _admins,
        address payable _feeWallet,
        address[] memory _paymentMethods,
        uint256[] memory _initialTokenAmounts
    ) {
        require(
            _initialTokenAmounts.length == _paymentMethods.length,
            "MediaEyeAirdrops: There must be amounts for each payment method."
        );

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        feeWallet = _feeWallet;

        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            paymentMethods.add(_paymentMethods[i]);
            paymentMethodAmounts[_paymentMethods[i]] = _initialTokenAmounts[i];
        }
    }

    /********************** Get methods ********************************/

    // Get number of payment methods accepted
    function getNumPaymentMethods() external view returns (uint256) {
        return paymentMethods.length();
    }

    // Returns true if is accepted payment method
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool)
    {
        return paymentMethods.contains(_paymentMethod);
    }

    /********************** Owner update methods ********************************/

    /**
     * @dev Update fee wallet
     *
     * Params:
     * _newFeeWallet: new fee wallet
     */
    function updateFeeWallet(address payable _newFeeWallet) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "MediaEyeAirdrops: Sender is not an owner."
        );
        feeWallet = _newFeeWallet;
        emit FeeWalletChanged(_newFeeWallet);
    }

    /********************** Admin update methods ********************************/

    /**
     * @dev Add single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to add
     */
    function addPaymentMethod(uint256 _newTokenAmount, address _paymentMethod)
        external
    {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        require(
            !paymentMethods.contains(_paymentMethod),
            "MediaEyeAirdrops: Payment method is already accepted."
        );
        paymentMethods.add(_paymentMethod);
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit PaymentAdded(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Removes single payment method
     *
     * Params:
     * _paymentMethod: the payment method to remove
     */
    function removePaymentMethod(address _paymentMethod) external {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeAirdrops: Payment method does not exist."
        );
        paymentMethods.remove(_paymentMethod);
        delete paymentMethodAmounts[_paymentMethod];
        emit PaymentRemoved(_paymentMethod);
    }

    /**
     * @dev Update Price Amounts for multiple payment method
     *
     * Params:
     * _newTokenAmounts: new token amounts for multiple payment method
     * _paymentMethods: order of the tokenAmounts to set
     */
    function updateMultipleTokenAmounts(
        uint256[] memory _newTokenAmounts,
        address[] memory _paymentMethods
    ) external {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        require(
            _newTokenAmounts.length == _paymentMethods.length,
            "MediaEyeAirdrops: There must be amounts for each payment method"
        );
        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            require(
                paymentMethods.contains(_paymentMethods[i]),
                "MediaEyeAirdrops: One of the payment method does not exist."
            );
            paymentMethodAmounts[_paymentMethods[i]] = _newTokenAmounts[i];
            emit TokenAmountsChanged(_paymentMethods[i], _newTokenAmounts[i]);
        }
    }

    /********************** Airdrop ********************************/

    function startAirdrop(
        AirdropType _airdropType,
        bool _promoCode,
        address _contractAddress,
        bytes32 _merkleRoot,
        uint256 _startTime,
        uint256 _endTime,
        uint256[] memory _tokenIds,
        uint256[] memory _maxTokenAmounts,
        address _paymentMethod,
        bool _feature
    ) external payable nonReentrant {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeAirdrops: Payment method does not exist."
        );

        require(
            _startTime < _endTime && _startTime > block.timestamp,
            "MediaEyeAirdrops: Start time must be in the future."
        );

        require(
            _tokenIds.length == _maxTokenAmounts.length,
            "MediaEyeAirdrops: There must be ids and amounts for each token"
        );

        uint256 price = paymentMethodAmounts[_paymentMethod];

        if (_paymentMethod == address(0)) {
            require(
                msg.value == price,
                "MediaEyeAirdrops: Incorrect transaction value."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
        } else {
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        }

        _airdropIds.increment();
        Airdrop storage newAirdrop = airdrops[_airdropIds.current()];
        newAirdrop.airdropType = _airdropType;
        newAirdrop.promoCode = _promoCode;
        newAirdrop.contractAddress = _contractAddress;
        newAirdrop.owner = msg.sender;
        newAirdrop.merkleRoot = _merkleRoot;
        newAirdrop.startTime = _startTime;
        newAirdrop.endTime = _endTime;
        newAirdrop.tokenIds = _tokenIds;
        newAirdrop.maxTokenAmounts = _maxTokenAmounts;
        newAirdrop.featured = _feature;

        if (_airdropType == AirdropType.ERC20) {
            require(
                _maxTokenAmounts.length == 1 && _maxTokenAmounts[0] > 0,
                "MediaEyeAirdrops: erc20"
            );
            IERC20(_contractAddress).transferFrom(
                msg.sender,
                address(this),
                _maxTokenAmounts[0]
            );
        } else if (_airdropType == AirdropType.ERC1155) {
            IERC1155(_contractAddress).safeBatchTransferFrom(
                msg.sender,
                address(this),
                _tokenIds,
                _maxTokenAmounts,
                ""
            );
        } else if (_airdropType == AirdropType.ERC721) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                require(
                    _maxTokenAmounts[i] == 1,
                    "MediaEyeAirdrops: There must be only one token per id for 721"
                );
                IERC721(_contractAddress).safeTransferFrom(
                    msg.sender,
                    address(this),
                    _tokenIds[i]
                );
            }
        }

        emit StartAirdrop(
            _airdropIds.current(),
            _startTime,
            _endTime,
            _feature
        );
    }

    function setRoot(uint256 _id, bytes32 _merkleRoot) external {
        require(
            (msg.sender == airdrops[_id].owner ||
                hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "Only admins and owner of an airdrop can set root"
        );
        Airdrop storage airdrop = airdrops[_id];
        require(
            airdrop.startTime > block.timestamp,
            "MediaEyeAirdrops: Airdrop has already started."
        );
        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        airdrop.merkleRoot = _merkleRoot;
    }

    function checkCollected(uint256 _id, address _who)
        external
        view
        returns (bool)
    {
        return airdrops[_id].collected[_who];
    }

    function checkAirdropFinished(uint256 _id) external view returns (bool) {
        return airdrops[_id].finished;
    }

    function nextAirdropId() external view returns (uint256) {
        return _airdropIds.current() + 1;
    }

    function contractTokenBalance(
        AirdropType _type,
        address _token,
        uint256 _id
    ) external view returns (uint256) {
        if (_type == AirdropType.ERC20) {
            return IERC20(_token).balanceOf(address(this));
        } else if (_type == AirdropType.ERC1155) {
            return IERC1155(_token).balanceOf(address(this), _id);
        } else if (_type == AirdropType.ERC721) {
            return IERC721(_token).balanceOf(address(this));
        } else {
            return 0;
        }
    }

    function contractTokenBalanceById(uint256 _id)
        external
        view
        returns (uint256[] memory)
    {
        return airdrops[_id].maxTokenAmounts;
    }

    function contractTokenIdsById(uint256 _id)
        external
        view
        returns (uint256[] memory)
    {
        return airdrops[_id].tokenIds;
    }

    function endAirdrop(uint256 _id) external returns (bool) {
        Airdrop storage airdrop = airdrops[_id];
        require(
            airdrop.endTime < block.timestamp,
            "this aidrop has not ended yet"
        );
        // only owner
        require(
            msg.sender == airdrop.owner,
            "Only owner of an airdrop can end the airdrop"
        );

        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        airdrop.finished = true;

        if (
            airdrop.airdropType == AirdropType.ERC20 &&
            airdrop.maxTokenAmounts[0] > 0
        ) {
            IERC20(airdrop.contractAddress).transfer(
                airdrop.owner,
                airdrop.maxTokenAmounts[0]
            );
        } else if (airdrop.airdropType == AirdropType.ERC1155) {
            IERC1155(airdrop.contractAddress).safeBatchTransferFrom(
                address(this),
                airdrop.owner,
                airdrop.tokenIds,
                airdrop.maxTokenAmounts,
                ""
            );
        } else if (airdrop.airdropType == AirdropType.ERC721) {
            for (uint256 i = 0; i < airdrop.tokenIds.length; i++) {
                if (airdrop.maxTokenAmounts[i] == 1) {
                    IERC721(airdrop.contractAddress).safeTransferFrom(
                        address(this),
                        airdrop.owner,
                        airdrop.tokenIds[i]
                    );
                }
            }
        }

        emit AirdropEnded(_id);
        return true;
    }

    function claimERC20Tokens(
        uint256 _id,
        bytes32[] memory _proof,
        address _who,
        string memory _promoCode,
        uint256 _amount
    ) external returns (bool success) {
        Airdrop storage airdrop = airdrops[_id];

        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        require(
            airdrop.airdropType == AirdropType.ERC20,
            "MediaEyeAirdrops: Airdrop is not ERC20"
        );

        require(_amount > 0, "User must collect an amount greater than 0");
        require(
            airdrop.maxTokenAmounts[0] >= _amount,
            "The airdrop does not have enough balance for this withdrawal"
        );
        if (airdrop.promoCode) {
            require(
                airdrop.promoCollected[_promoCode] != true,
                "promo code has already collected from this airdrop"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndNumTokens(address(0), _promoCode, _amount)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.promoCollected[_promoCode] = true;
        } else {
            require(
                airdrop.collected[_who] != true,
                "User has already collected from this airdrop"
            );
            require(
                msg.sender == _who,
                "Only the recipient can receive for themselves"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndNumTokens(_who, "", _amount)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.collected[_who] = true;
        }

        airdrop.maxTokenAmounts[0] = airdrop.maxTokenAmounts[0] - _amount;

        if (
            IERC20(airdrop.contractAddress).transfer(msg.sender, _amount) ==
            true
        ) {
            emit AirdropTransfer(_id, msg.sender, _amount);
            return true;
        }
        // throw if transfer fails, no need to spend gas
        require(false);
    }

    function claimERC721Tokens(
        uint256 _id,
        bytes32[] memory _proof,
        address _who,
        string memory _promoCode,
        uint256 _tokenId
    ) external returns (bool success) {
        Airdrop storage airdrop = airdrops[_id];

        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        require(
            airdrop.airdropType == AirdropType.ERC721,
            "MediaEyeAirdrops: Airdrop is not ERC721"
        );

        if (airdrop.promoCode) {
            require(
                airdrop.promoCollectedNfts[_promoCode][_tokenId] != true,
                "promo code has already collected from this airdrop"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndTokenId(address(0), _promoCode, _tokenId)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.promoCollectedNfts[_promoCode][_tokenId] = true;
        } else {
            require(
                airdrop.collectedNfts[_who][_tokenId] != true,
                "User has already collected from this airdrop"
            );
            require(
                msg.sender == _who,
                "Only the recipient can receive for themselves"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndTokenId(_who, "", _tokenId)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.collectedNfts[_who][_tokenId] = true;
        }

        IERC721(airdrop.contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
        emit Airdrop721Transfer(_id, msg.sender, _tokenId);
        return true;
    }

    function claimERC1155Tokens(
        uint256 _id,
        bytes32[] memory _proof,
        address _who,
        string memory _promoCode,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) external returns (bool success) {
        Airdrop storage airdrop = airdrops[_id];

        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        require(
            _tokenIds.length == _amounts.length,
            "tokenIds and amounts length mismatch"
        );

        require(
            airdrop.airdropType == AirdropType.ERC1155,
            "MediaEyeAirdrops: Airdrop is not ERC1155"
        );

        if (airdrop.promoCode) {
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressTokenIdsAndAmount(
                        address(0),
                        _promoCode,
                        _tokenIds,
                        _amounts
                    )
                )
            ) {
                require(false, "Invalid proof");
            }
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                require(
                    airdrop.promoCollectedNfts[_promoCode][_tokenIds[i]] !=
                        true,
                    "promo code has already collected from this airdrop"
                );
                airdrop.promoCollectedNfts[_promoCode][_tokenIds[i]] = true;
            }
        } else {
            require(
                msg.sender == _who,
                "Only the recipient can receive for themselves"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressTokenIdsAndAmount(
                        _who,
                        "",
                        _tokenIds,
                        _amounts
                    )
                )
            ) {
                require(false, "Invalid proof");
            }
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                require(
                    airdrop.collectedNfts[_who][_tokenIds[i]] != true,
                    "User has already collected from this airdrop"
                );
                airdrop.collectedNfts[_who][_tokenIds[i]] = true;
            }
        }

        IERC1155(airdrop.contractAddress).safeBatchTransferFrom(
            address(this),
            msg.sender,
            _tokenIds,
            _amounts,
            ""
        );
        emit Airdrop1155Transfer(_id, msg.sender, _tokenIds, _amounts);
        return true;
    }

    function addressToAsciiString(address x)
        internal
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(40);
        uint256 x_int = uint256(uint160(address(x)));

        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(x_int / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uintToStr(uint256 i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
            bstr[(k--) - 1] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }

    function leafFromAddressAndNumTokens(
        address _account,
        string memory _promo,
        uint256 _amount
    ) internal pure returns (bytes32) {
        string memory prefix = "0x";
        string memory space = " ";
        bytes memory leaf = "";

        if (_account != address(0)) {
            leaf = abi.encodePacked(
                prefix,
                addressToAsciiString(_account),
                space,
                uintToStr(_amount)
            );
        } else {
            leaf = abi.encodePacked(prefix, _promo, space, uintToStr(_amount));
        }

        return bytes32(sha256(leaf));
    }

    function leafFromAddressAndTokenId(
        address _account,
        string memory _promo,
        uint256 _tokenId
    ) internal pure returns (bytes32) {
        string memory prefix = "0x";
        string memory space = " ";
        bytes memory leaf = "";

        if (_account != address(0)) {
            leaf = abi.encodePacked(
                prefix,
                addressToAsciiString(_account),
                space,
                uintToStr(_tokenId)
            );
        } else {
            leaf = abi.encodePacked(prefix, _promo, space, uintToStr(_tokenId));
        }

        return bytes32(sha256(leaf));
    }

    function leafFromAddressTokenIdsAndAmount(
        address _account,
        string memory _promo,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) internal pure returns (bytes32) {
        require(
            _tokenIds.length == _amounts.length,
            "tokenIds and amounts length mismatch"
        );

        bytes memory leaf = "";
        string memory prefix = "0x";
        string memory space = " ";
        string memory comma = ",";

        if (_account != address(0)) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                leaf = abi.encodePacked(
                    leaf,
                    leaf.length > 2 ? comma : "",
                    prefix,
                    addressToAsciiString(_account),
                    space,
                    uintToStr(_tokenIds[i]),
                    space,
                    uintToStr(_amounts[i])
                );
            }
        } else {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                leaf = abi.encodePacked(
                    leaf,
                    leaf.length > 2 ? comma : "",
                    prefix,
                    _promo,
                    space,
                    uintToStr(_tokenIds[i]),
                    space,
                    uintToStr(_amounts[i])
                );
            }
        }

        return bytes32(sha256(leaf));
    }

    function checkProof(
        uint256 _id,
        bytes32[] memory _proof,
        bytes32 hash
    ) internal view returns (bool) {
        bytes32 el;
        bytes32 h = hash;

        for (
            uint256 i = 0;
            _proof.length != 0 && i <= _proof.length - 1;
            i += 1
        ) {
            el = _proof[i];

            if (h < el) {
                h = sha256(abi.encodePacked(h, el));
            } else {
                h = sha256(abi.encodePacked(el, h));
            }
        }

        return h == airdrops[_id].merkleRoot;
    }

    // override supportsInterface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File @openzeppelin/contracts/utils/math/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


// File @chainlink/contracts/src/v0.8/interfaces/[email protected]

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


// File contracts/curatedAirdrops/MediaEyeCuratedAirdropsV2.sol

pragma solidity ^0.8.0;












contract MediaEyeCuratedAirdropsV2 is
    ERC721Holder,
    ERC1155Holder,
    AccessControl,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using SafeCast for int256;

    bytes32 internal immutable _DOMAIN_SEPARATOR;
    bytes32 internal AIRDROP_SIGNATURE_TYPEHASH =
        0x26bdbdbef90222d4cc75fda7c0d2739b888afde7556e5bff4a1146a6daa1a717;
    // keccak256(
    //     "Airdrop(uint256 airdropId,bytes32 merkleRoot)"
    // );

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    Counters.Counter private _airdropIds;
    EnumerableSet.AddressSet private paymentMethods;

    address payable public feeWallet;
    address public operator;
    AggregatorV3Interface internal priceFeed;
    bool public invertedAggregator;

    TokenAmounts public baseUSDTokenAmounts;

    struct Airdrop {
        AirdropType airdropType;
        bool promoCode;
        address contractAddress;
        address owner;
        bytes32 merkleRoot;
        uint256 startTime;
        uint256 endTime;
        uint256[] tokenIds;
        uint256[] maxTokenAmounts;
        bool featured;
        bool rooted;
        bool finished;
        mapping(address => bool) collected;
        mapping(string => bool) promoCollected;
        mapping(address => mapping(uint256 => bool)) collectedNfts;
        mapping(string => mapping(uint256 => bool)) promoCollectedNfts;
    }

    struct AirdropInfo {
        uint256 airdropId;
        AirdropType airdropType;
        bool promoCode;
        address contractAddress;
        address owner;
        uint256 startTime;
        uint256 endTime;
        uint256[] tokenIds;
        uint256[] maxTokenAmounts;
        bool featured;
        string data;
    }

    struct TokenAmounts {
        uint256 airdropPricePerDay;
        bool chainlinkFeed;
        bool stableCoin;
        uint256 tokenDecimals;
    }

    struct RootSignature {
        bool isValid;
        uint256 airdropId;
        bytes32 merkleRoot;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    enum AirdropType {
        ERC20,
        ERC721,
        ERC1155
    }

    event StartAirdrop(AirdropInfo airdropInfo);

    event AirdropEnded(uint256 airdropId);
    event AirdropTransfer(uint256 id, address addr, uint256 num);
    event Airdrop721Transfer(uint256 id, address addr, uint256 tokenId);
    event Airdrop1155Transfer(
        uint256 id,
        address addr,
        uint256[] tokenId,
        uint256[] num
    );
    event TokenAmountsChanged(address paymentMethod, TokenAmounts tokenAmounts);
    event PaymentAdded(address paymentMethod, TokenAmounts tokenAmounts);
    event PaymentRemoved(address paymentMethod);
    event FeeWalletChanged(address newFeeWallet);

    mapping(uint256 => Airdrop) public airdrops;
    mapping(address => TokenAmounts) public paymentMethodAmounts;

    constructor(
        address _owner,
        address[] memory _admins,
        address payable _feeWallet,
        address _operator,
        address[] memory _paymentMethods,
        TokenAmounts[] memory _initialTokenAmounts,
        TokenAmounts memory _baseUSDTokenAmounts,
        address _priceFeedAggregator,
        bool _invertedAggregator
    ) {
        require(
            _initialTokenAmounts.length == _paymentMethods.length,
            "MediaEyeAirdrops: There must be amounts for each payment method."
        );

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("MediaEyeCuratedAirdrops"),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        feeWallet = _feeWallet;

        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            paymentMethods.add(_paymentMethods[i]);
            paymentMethodAmounts[_paymentMethods[i]] = _initialTokenAmounts[i];
        }

        baseUSDTokenAmounts = _baseUSDTokenAmounts;
        priceFeed = AggregatorV3Interface(_priceFeedAggregator);
        invertedAggregator = _invertedAggregator;
        operator = _operator;
    }

    /********************** Get methods ********************************/

    // Get number of payment methods accepted
    function getNumPaymentMethods() external view returns (uint256) {
        return paymentMethods.length();
    }

    // Returns true if is accepted payment method
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool)
    {
        return paymentMethods.contains(_paymentMethod);
    }

    /********************** Price Feed ********************************/

    function getRoundData() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();

        return price.toUint256();
    }

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) public view returns (uint256) {
        require(_baseDecimals > 0 && _baseDecimals <= 18, "Invalid _decimals");
        require(
            _queryDecimals > 0 && _queryDecimals <= 18,
            "Invalid _decimals"
        );

        uint256 roundData = getRoundData();
        uint256 roundDataDecimals = priceFeed.decimals();
        uint256 query = 0;

        if (_convertToNative) {
            if (_invertedAggregator) {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            } else {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            }
        } else {
            if (_invertedAggregator) {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            } else {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            }
        }

        if (_baseDecimals > _queryDecimals) {
            uint256 decimals = _baseDecimals - _queryDecimals;
            query = query / (10**decimals);
        } else if (_baseDecimals < _queryDecimals) {
            uint256 decimals = _queryDecimals - _baseDecimals;
            query = query * (10**decimals);
        }
        return query;
    }

    /********************** Owner update methods ********************************/

    /**
     * @dev Update fee wallet
     *
     * Params:
     * _newFeeWallet: new fee wallet
     */
    function updateFeeWallet(address payable _newFeeWallet) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "MediaEyeAirdrops: Sender is not an owner."
        );
        feeWallet = _newFeeWallet;
        emit FeeWalletChanged(_newFeeWallet);
    }

    /********************** Admin update methods ********************************/

    /**
     * @dev Update subscriptionadmin address
     *
     * Params:
     * _address: new subscriptionadmin address
     */
    function setOperatorAddress(address _address) external {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        operator = _address;
    }

    /**
     * @dev Update subscription typehash
     *
     * Params:
     * _typeHash: new typehash
     */
    function setAirdropHash(bytes32 _typeHash) external {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        AIRDROP_SIGNATURE_TYPEHASH = _typeHash;
    }

    /**
     * @dev Update price feed aggregator address
     *
     * Params:
     * _aggregator: new aggregator address
     * _inverted: whether the aggregator is inverted
     */
    function setPriceFeedAggregator(address _aggregator, bool _inverted)
        external
    {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        priceFeed = AggregatorV3Interface(_aggregator);
        invertedAggregator = _inverted;
    }

    /**
     * @dev Update mediator address
     *
     * Params:
     * _baseUSDTokenAmounts: price in usd for each category
     */
    function setBaseUSDTokenAmounts(TokenAmounts memory _baseUSDTokenAmounts)
        external
    {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        baseUSDTokenAmounts = _baseUSDTokenAmounts;
    }

    /**
     * @dev Add single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to add
     */
    function addPaymentMethod(
        TokenAmounts memory _newTokenAmount,
        address _paymentMethod
    ) external {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        require(
            !paymentMethods.contains(_paymentMethod),
            "MediaEyeAirdrops: Payment method is already accepted."
        );
        paymentMethods.add(_paymentMethod);
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit PaymentAdded(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Removes single payment method
     *
     * Params:
     * _paymentMethod: the payment method to remove
     */
    function removePaymentMethod(address _paymentMethod) external {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeAirdrops: Payment method does not exist."
        );
        paymentMethods.remove(_paymentMethod);
        delete paymentMethodAmounts[_paymentMethod];
        emit PaymentRemoved(_paymentMethod);
    }

    /**
     * @dev Update Price Amounts for multiple payment method
     *
     * Params:
     * _newTokenAmounts: new token amounts for multiple payment method
     * _paymentMethods: order of the tokenAmounts to set
     */
    function updateMultipleTokenAmounts(
        TokenAmounts[] memory _newTokenAmounts,
        address[] memory _paymentMethods
    ) external {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeAirdrops: Sender is not an admin."
        );
        require(
            _newTokenAmounts.length == _paymentMethods.length,
            "MediaEyeAirdrops: There must be amounts for each payment method"
        );
        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            require(
                paymentMethods.contains(_paymentMethods[i]),
                "MediaEyeAirdrops: One of the payment method does not exist."
            );
            paymentMethodAmounts[_paymentMethods[i]] = _newTokenAmounts[i];
            emit TokenAmountsChanged(_paymentMethods[i], _newTokenAmounts[i]);
        }
    }

    /********************** Airdrop ********************************/

    function startAirdrop(
        AirdropType _airdropType,
        bool _promoCode,
        address _contractAddress,
        bytes32 _merkleRoot,
        uint256 _startTime,
        uint256 _numDays,
        uint256[] memory _tokenIds,
        uint256[] memory _maxTokenAmounts,
        address _paymentMethod,
        bool _feature,
        string memory _data
    ) external payable nonReentrant {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeAirdrops: Payment method does not exist."
        );

        require(
            _startTime > block.timestamp && _numDays > 0,
            "MediaEyeAirdrops: Start time must be in the future."
        );

        require(
            _tokenIds.length == _maxTokenAmounts.length,
            "MediaEyeAirdrops: There must be ids and amounts for each token"
        );

        uint256 price = 0;
        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];

        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            price = convertPrice(
                (baseUSDTokenAmounts.airdropPricePerDay * _numDays),
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeAirdrops: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = msg.sender.call{value: msg.value - price}(
                    ""
                );
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            price = baseUSDTokenAmounts.airdropPricePerDay * _numDays;
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        } else {
            price = tokenAmount.airdropPricePerDay * _numDays;
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        }

        _airdropIds.increment();
        Airdrop storage newAirdrop = airdrops[_airdropIds.current()];
        newAirdrop.airdropType = _airdropType;
        newAirdrop.promoCode = _promoCode;
        newAirdrop.contractAddress = _contractAddress;
        newAirdrop.owner = msg.sender;
        newAirdrop.merkleRoot = _merkleRoot;
        newAirdrop.startTime = _startTime;
        newAirdrop.endTime = _startTime + (_numDays * 86400);
        newAirdrop.tokenIds = _tokenIds;
        newAirdrop.maxTokenAmounts = _maxTokenAmounts;
        newAirdrop.featured = _feature;

        if (_airdropType == AirdropType.ERC20) {
            require(
                _maxTokenAmounts.length == 1 && _maxTokenAmounts[0] > 0,
                "MediaEyeAirdrops: erc20"
            );
            IERC20(_contractAddress).transferFrom(
                msg.sender,
                address(this),
                _maxTokenAmounts[0]
            );
        } else if (_airdropType == AirdropType.ERC1155) {
            IERC1155(_contractAddress).safeBatchTransferFrom(
                msg.sender,
                address(this),
                _tokenIds,
                _maxTokenAmounts,
                ""
            );
        } else if (_airdropType == AirdropType.ERC721) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                require(
                    _maxTokenAmounts[i] == 1,
                    "MediaEyeAirdrops: There must be only one token per id for 721"
                );
                IERC721(_contractAddress).safeTransferFrom(
                    msg.sender,
                    address(this),
                    _tokenIds[i]
                );
            }
        }

        AirdropInfo memory newAirdropInfo;
        newAirdropInfo.airdropId = _airdropIds.current();
        newAirdropInfo.airdropType = _airdropType;
        newAirdropInfo.promoCode = _promoCode;
        newAirdropInfo.contractAddress = _contractAddress;
        newAirdropInfo.owner = msg.sender;
        newAirdropInfo.startTime = _startTime;
        newAirdropInfo.endTime = _startTime + (_numDays * 86400);
        newAirdropInfo.tokenIds = _tokenIds;
        newAirdropInfo.maxTokenAmounts = _maxTokenAmounts;
        newAirdropInfo.featured = _feature;
        newAirdropInfo.data = _data;

        emit StartAirdrop(newAirdropInfo);
    }

    function setRoot(uint256 _id, bytes32 _merkleRoot) external {
        require(
            (msg.sender == airdrops[_id].owner ||
                hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "Only admins and owner of an airdrop can set root"
        );
        Airdrop storage airdrop = airdrops[_id];
        require(
            airdrop.startTime > block.timestamp,
            "MediaEyeAirdrops: Airdrop has already started."
        );
        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        airdrop.merkleRoot = _merkleRoot;
    }

    function checkCollected(uint256 _id, address _who)
        external
        view
        returns (bool)
    {
        return airdrops[_id].collected[_who];
    }

    function checkAirdropFinished(uint256 _id) external view returns (bool) {
        return airdrops[_id].finished;
    }

    function nextAirdropId() external view returns (uint256) {
        return _airdropIds.current() + 1;
    }

    function contractTokenBalance(
        AirdropType _type,
        address _token,
        uint256 _id
    ) external view returns (uint256) {
        if (_type == AirdropType.ERC20) {
            return IERC20(_token).balanceOf(address(this));
        } else if (_type == AirdropType.ERC1155) {
            return IERC1155(_token).balanceOf(address(this), _id);
        } else if (_type == AirdropType.ERC721) {
            return IERC721(_token).balanceOf(address(this));
        } else {
            return 0;
        }
    }

    function contractTokenBalanceById(uint256 _id)
        external
        view
        returns (uint256[] memory)
    {
        return airdrops[_id].maxTokenAmounts;
    }

    function contractTokenIdsById(uint256 _id)
        external
        view
        returns (uint256[] memory)
    {
        return airdrops[_id].tokenIds;
    }

    function endAirdrop(uint256 _id) external returns (bool) {
        Airdrop storage airdrop = airdrops[_id];
        require(
            airdrop.endTime < block.timestamp,
            "this aidrop has not ended yet"
        );
        // only owner
        require(
            msg.sender == airdrop.owner,
            "Only owner of an airdrop can end the airdrop"
        );

        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        airdrop.finished = true;

        if (
            airdrop.airdropType == AirdropType.ERC20 &&
            airdrop.maxTokenAmounts[0] > 0
        ) {
            IERC20(airdrop.contractAddress).transfer(
                airdrop.owner,
                airdrop.maxTokenAmounts[0]
            );
        } else if (airdrop.airdropType == AirdropType.ERC1155) {
            IERC1155(airdrop.contractAddress).safeBatchTransferFrom(
                address(this),
                airdrop.owner,
                airdrop.tokenIds,
                airdrop.maxTokenAmounts,
                ""
            );
        } else if (airdrop.airdropType == AirdropType.ERC721) {
            for (uint256 i = 0; i < airdrop.tokenIds.length; i++) {
                if (airdrop.maxTokenAmounts[i] == 1) {
                    IERC721(airdrop.contractAddress).safeTransferFrom(
                        address(this),
                        airdrop.owner,
                        airdrop.tokenIds[i]
                    );
                }
            }
        }

        emit AirdropEnded(_id);
        return true;
    }

    function _checkRooted(RootSignature memory _root) internal {
        // verify signature
        bytes32 structHash = keccak256(
            abi.encode(
                AIRDROP_SIGNATURE_TYPEHASH,
                _root.airdropId,
                _root.merkleRoot
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
        );
        require(
            ecrecover(digest, _root.v, _root.r, _root.s) == operator,
            "invalid root signature"
        );
        airdrops[_root.airdropId].rooted = true;
        airdrops[_root.airdropId].merkleRoot = _root.merkleRoot;
    }

    function claimERC20Tokens(
        uint256 _id,
        bytes32[] memory _proof,
        address _who,
        string memory _promoCode,
        uint256 _amount,
        RootSignature memory _root
    ) external returns (bool success) {
        if (_root.isValid) {
            require(
                !airdrops[_id].rooted,
                "MediaEyeAirdrops: Airdrop already rooted."
            );
            _checkRooted(_root);
        }
        Airdrop storage airdrop = airdrops[_id];
        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        require(
            airdrop.airdropType == AirdropType.ERC20,
            "MediaEyeAirdrops: Airdrop is not ERC20"
        );

        require(_amount > 0, "User must collect an amount greater than 0");
        require(
            airdrop.maxTokenAmounts[0] >= _amount,
            "The airdrop does not have enough balance for this withdrawal"
        );
        if (airdrop.promoCode) {
            require(
                airdrop.promoCollected[_promoCode] != true,
                "promo code has already collected from this airdrop"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndNumTokens(address(0), _promoCode, _amount)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.promoCollected[_promoCode] = true;
        } else {
            require(
                airdrop.collected[_who] != true,
                "User has already collected from this airdrop"
            );
            require(
                msg.sender == _who,
                "Only the recipient can receive for themselves"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndNumTokens(_who, "", _amount)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.collected[_who] = true;
        }

        airdrop.maxTokenAmounts[0] = airdrop.maxTokenAmounts[0] - _amount;

        if (
            IERC20(airdrop.contractAddress).transfer(msg.sender, _amount) ==
            true
        ) {
            emit AirdropTransfer(_id, msg.sender, _amount);
            return true;
        }
        // throw if transfer fails, no need to spend gas
        require(false);
    }

    function claimERC721Tokens(
        uint256 _id,
        bytes32[] memory _proof,
        address _who,
        string memory _promoCode,
        uint256 _tokenId,
        RootSignature memory _root
    ) external returns (bool success) {
        if (_root.isValid) {
            require(
                !airdrops[_id].rooted,
                "MediaEyeAirdrops: Airdrop already rooted."
            );
            _checkRooted(_root);
        }
        Airdrop storage airdrop = airdrops[_id];

        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        require(
            airdrop.airdropType == AirdropType.ERC721,
            "MediaEyeAirdrops: Airdrop is not ERC721"
        );

        if (airdrop.promoCode) {
            require(
                airdrop.promoCollectedNfts[_promoCode][_tokenId] != true,
                "promo code has already collected from this airdrop"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndTokenId(address(0), _promoCode, _tokenId)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.promoCollectedNfts[_promoCode][_tokenId] = true;
        } else {
            require(
                airdrop.collectedNfts[_who][_tokenId] != true,
                "User has already collected from this airdrop"
            );
            require(
                msg.sender == _who,
                "Only the recipient can receive for themselves"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressAndTokenId(_who, "", _tokenId)
                )
            ) {
                require(false, "Invalid proof");
            }
            airdrop.collectedNfts[_who][_tokenId] = true;
        }

        IERC721(airdrop.contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );
        emit Airdrop721Transfer(_id, msg.sender, _tokenId);
        return true;
    }

    function claimERC1155Tokens(
        uint256 _id,
        bytes32[] memory _proof,
        address _who,
        string memory _promoCode,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts,
        RootSignature memory _root
    ) external returns (bool success) {
        if (_root.isValid) {
            require(
                !airdrops[_id].rooted,
                "MediaEyeAirdrops: Airdrop already rooted."
            );
            _checkRooted(_root);
        }
        Airdrop storage airdrop = airdrops[_id];

        require(
            !airdrop.finished,
            "MediaEyeAirdrops: Airdrop has already finished."
        );

        require(
            _tokenIds.length == _amounts.length,
            "tokenIds and amounts length mismatch"
        );

        require(
            airdrop.airdropType == AirdropType.ERC1155,
            "MediaEyeAirdrops: Airdrop is not ERC1155"
        );

        if (airdrop.promoCode) {
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressTokenIdsAndAmount(
                        address(0),
                        _promoCode,
                        _tokenIds,
                        _amounts
                    )
                )
            ) {
                require(false, "Invalid proof");
            }
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                require(
                    airdrop.promoCollectedNfts[_promoCode][_tokenIds[i]] !=
                        true,
                    "promo code has already collected from this airdrop"
                );
                airdrop.promoCollectedNfts[_promoCode][_tokenIds[i]] = true;
            }
        } else {
            require(
                msg.sender == _who,
                "Only the recipient can receive for themselves"
            );
            if (
                !checkProof(
                    _id,
                    _proof,
                    leafFromAddressTokenIdsAndAmount(
                        _who,
                        "",
                        _tokenIds,
                        _amounts
                    )
                )
            ) {
                require(false, "Invalid proof");
            }
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                require(
                    airdrop.collectedNfts[_who][_tokenIds[i]] != true,
                    "User has already collected from this airdrop"
                );
                airdrop.collectedNfts[_who][_tokenIds[i]] = true;
            }
        }

        IERC1155(airdrop.contractAddress).safeBatchTransferFrom(
            address(this),
            msg.sender,
            _tokenIds,
            _amounts,
            ""
        );
        emit Airdrop1155Transfer(_id, msg.sender, _tokenIds, _amounts);
        return true;
    }

    function addressToAsciiString(address x)
        internal
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(40);
        uint256 x_int = uint256(uint160(address(x)));

        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(x_int / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uintToStr(uint256 i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
            bstr[(k--) - 1] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }

    function leafFromAddressAndNumTokens(
        address _account,
        string memory _promo,
        uint256 _amount
    ) internal pure returns (bytes32) {
        string memory prefix = "0x";
        string memory space = " ";
        bytes memory leaf = "";

        if (_account != address(0)) {
            leaf = abi.encodePacked(
                prefix,
                addressToAsciiString(_account),
                space,
                uintToStr(_amount)
            );
        } else {
            leaf = abi.encodePacked(prefix, _promo, space, uintToStr(_amount));
        }

        return bytes32(sha256(leaf));
    }

    function leafFromAddressAndTokenId(
        address _account,
        string memory _promo,
        uint256 _tokenId
    ) internal pure returns (bytes32) {
        string memory prefix = "0x";
        string memory space = " ";
        bytes memory leaf = "";

        if (_account != address(0)) {
            leaf = abi.encodePacked(
                prefix,
                addressToAsciiString(_account),
                space,
                uintToStr(_tokenId)
            );
        } else {
            leaf = abi.encodePacked(prefix, _promo, space, uintToStr(_tokenId));
        }

        return bytes32(sha256(leaf));
    }

    function leafFromAddressTokenIdsAndAmount(
        address _account,
        string memory _promo,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) internal pure returns (bytes32) {
        require(
            _tokenIds.length == _amounts.length,
            "tokenIds and amounts length mismatch"
        );

        bytes memory leaf = "";
        string memory prefix = "0x";
        string memory space = " ";
        string memory comma = ",";

        if (_account != address(0)) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                leaf = abi.encodePacked(
                    leaf,
                    leaf.length > 2 ? comma : "",
                    prefix,
                    addressToAsciiString(_account),
                    space,
                    uintToStr(_tokenIds[i]),
                    space,
                    uintToStr(_amounts[i])
                );
            }
        } else {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                leaf = abi.encodePacked(
                    leaf,
                    leaf.length > 2 ? comma : "",
                    prefix,
                    _promo,
                    space,
                    uintToStr(_tokenIds[i]),
                    space,
                    uintToStr(_amounts[i])
                );
            }
        }

        return bytes32(sha256(leaf));
    }

    function checkProof(
        uint256 _id,
        bytes32[] memory _proof,
        bytes32 hash
    ) internal view returns (bool) {
        bytes32 el;
        bytes32 h = hash;

        for (
            uint256 i = 0;
            _proof.length != 0 && i <= _proof.length - 1;
            i += 1
        ) {
            el = _proof[i];

            if (h < el) {
                h = sha256(abi.encodePacked(h, el));
            } else {
                h = sha256(abi.encodePacked(el, h));
            }
        }

        return h == airdrops[_id].merkleRoot;
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    // override supportsInterface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File contracts/interfaces/IChainlinkPriceFeeds.sol

pragma solidity ^0.8.0;

interface IChainlinkPriceFeeds {

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) external view returns (uint256);
}


// File contracts/libraries/MediaEyeOrders.sol

pragma solidity ^0.8.0;

library MediaEyeOrders {
    enum NftTokenType {
        ERC1155,
        ERC721
    }

    enum SubscriptionTier {
        Unsubscribed,
        LevelOne,
        LevelTwo
    }

    struct SubscriptionSignature {
        bool isValid;
        UserSubscription userSubscription;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct UserSubscription {
        address userAddress;
        MediaEyeOrders.SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    struct Listing {
        uint256 listingId;
        Nft[] nfts;
        address payable seller;
        uint256 timestamp;
        Split split;
    }

    struct Chainlink {
        address tokenAddress;
        uint256 tokenDecimals;
        address nativeAddress;
        uint256 nativeDecimals;
        IChainlinkPriceFeeds priceFeed;
        bool invertedAggregator;
    }

    struct AuctionConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
        address _mediaEyeCharities;
        Chainlink _chainlink;
    }

    struct OfferConstructor {
        address _owner;
        address[] _admins;
        address payable _treasuryWallet;
        uint256 _basisPointFee;
        address _feeContract;
        address _mediaEyeMarketplaceInfo;
    }

    struct AuctionAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        address _newCharityContract;
        MediaEyeOrders.Chainlink _chainlink;
        uint256 _basisPointFee;
        bool _check;
        address _newInfoContract;
    }

    struct OfferAdmin {
        address payable _newTreasuryWallet;
        address _newFeeContract;
        uint256 _basisPointFee;
        address _newInfoContract;
    }

    struct AuctionInput {
        MediaEyeOrders.Nft[] nfts;
        MediaEyeOrders.AuctionPayment[] auctionPayments;
        MediaEyeOrders.PaymentChainlink chainlinkPayment;
        uint8 setRoyalty;
        uint256 royalty;
        MediaEyeOrders.Split split;
        AuctionTime auctionTime;
        MediaEyeOrders.SubscriptionSignature subscriptionSignature;
        MediaEyeOrders.Feature feature;
        string data;
    }

    struct AuctionTime {
        uint256 startTime;
        uint256 endTime;
    }

    struct Auction {
        uint256 auctionId;
        Nft[] nfts;
        address seller;
        uint256 startTime;
        uint256 endTime;
        Split split;
    }

    struct Royalty {
        address payable artist;
        uint256 royaltyBasisPoint;
    }

    struct Split {
        address payable recipient;
        uint256 splitBasisPoint;
        address payable charity;
        uint256 charityBasisPoint;
    }

    struct ListingPayment {
        address paymentMethod;
        uint256 price;
    }

    struct PaymentChainlink {
        bool isValid;
        address quoteAddress;
    }

    struct Feature {
        bool feature;
        address paymentMethod;
        uint256 numDays;
        uint256 id;
        address[] tokenAddresses;
        uint256[] tokenIds;
        uint256 price;
    }

    struct AuctionPayment {
        address paymentMethod;
        uint256 initialPrice;
        uint256 buyItNowPrice;
    }

    struct AuctionSignature {
        uint256 auctionId;
        uint256 price;
        address bidder;
        address paymentMethod;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct OfferSignature {
        Nft nft;
        uint256 price;
        address offerer;
        address paymentMethod;
        uint256 expiry;
        address charityAddress;
        uint256 charityBasisPoint;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Nft {
        NftTokenType nftTokenType;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 nftNumTokens;
    }
}


// File contracts/interfaces/IMarketplaceInfo.sol

pragma solidity ^0.8.0;

interface IMarketplaceInfo {
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool);

    function getRoyalty(address _nftTokenAddress, uint256 _nftTokenId)
        external
        view
        returns (MediaEyeOrders.Royalty memory);

    function getSoldStatus(address _nftTokenAddress, uint256 _nftTokenId)
        external
        view
        returns (bool);

    function setRoyalty(
        address _nftTokenAddress,
        uint256 _nftTokenId,
        uint256 _royalty,
        address _caller
    ) external;

    function setSoldStatus(address _nftTokenAddress, uint256 _nftTokenId)
        external;
}


// File contracts/interfaces/ISubscriptionTier.sol

pragma solidity ^0.8.0;

interface ISubscriptionTier {
    enum SubscriptionTier {
        Unsubscribed,
        LevelOne,
        LevelTwo
    }

    struct UserSubscription {
        address userAddress;
        SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    struct Featured {
        uint256 startTime;
        uint256 numDays;
        uint256 featureType;
        address contractAddress;
        uint256 listingId;
        uint256 auctionId;
        uint256 id;
        address featuredBy;
        uint256 price;
    }

    function getUserSubscription(address account)
        external
        view
        returns (UserSubscription memory);

    function checkUserSubscription(address _user)
        external
        view
        returns (uint256);

    function checkUserSubscriptionBySig(
        MediaEyeOrders.UserSubscription memory _userSubscription,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint256);

    function payFeatureFee(
        address _paymentMethod,
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        Featured memory _featured
    ) external payable;
}


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/token/ERC1155/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


// File @openzeppelin/contracts-upgradeable/token/ERC1155/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts-upgradeable/token/ERC1155/extensions/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
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


// File @openzeppelin/contracts-upgradeable/proxy/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/utils/introspection/[email protected]


pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC1155/[email protected]


pragma solidity ^0.8.0;







/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal initializer {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
    uint256[47] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC1155/extensions/[email protected]


pragma solidity ^0.8.0;


/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155SupplyUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Supply_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC1155Supply_init_unchained();
    }

    function __ERC1155Supply_init_unchained() internal initializer {
    }
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates weither any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155SupplyUpgradeable.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_mint}.
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual override {
        super._mint(account, id, amount, data);
        _totalSupply[id] += amount;
    }

    /**
     * @dev See {ERC1155-_mintBatch}.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._mintBatch(to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; ++i) {
            _totalSupply[ids[i]] += amounts[i];
        }
    }

    /**
     * @dev See {ERC1155-_burn}.
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual override {
        super._burn(account, id, amount);
        _totalSupply[id] -= amount;
    }

    /**
     * @dev See {ERC1155-_burnBatch}.
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual override {
        super._burnBatch(account, ids, amounts);
        for (uint256 i = 0; i < ids.length; ++i) {
            _totalSupply[ids[i]] -= amounts[i];
        }
    }
    uint256[49] private __gap;
}


// File contracts/others/ERC1155Strings.sol

// pragma solidity ^0.8.0;

library ERC1155Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}


// File contracts/lazymint/MediaEyeLazyMint1155.sol

pragma solidity ^0.8.0;




/**
 * @dev {ERC1155} token, including:
 *
 *  - deploy with upgradeability, replaced constructors with initializer functions
 *  - a minter role that allows for token minting (creation)
 *  - must be level 2 subscribed to change minters/roles
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles
 *
 */

contract MediaEyeLazyMint1155 is ERC1155SupplyUpgradeable {
    using ERC1155Strings for uint256;
    using SafeERC20 for IERC20;

    string public baseTokenURI;
    address public owner;
    address public paymentMethod;
    PriceInflation public priceInflation;

    uint256 public numLimitedEditions;
    mapping(uint256 => LimitedEdition) public limitedEditions;
    mapping(uint256 => uint256) public limitedEditionsById;

    mapping(uint256 => uint256) public sold;

    uint256 public numSold;
    uint256 public numTotalNFTs;
    uint256 public numTiers;
    mapping(uint256 => Tier) public tiers;

    struct PriceInflation {
        uint256 incrementCount;
        InflationType inflationType;
        uint256 amount;
    }

    enum InflationType {
        Percent,
        Fixed,
        None
    }

    struct Tier {
        string name;
        uint256 supply;
        uint256 basePrice;
        uint256 currPrice;
        uint256 startingTokenId;
        uint256 endingTokenId;
    }

    struct LimitedEdition {
        uint256 tokenId;
        uint256 basePrice;
        uint256 currPrice;
    }

    struct Mints {
        address to;
        uint256[] amounts;
        bytes data;
        string[] tokenDatum;
        string[] metadataURIs;
    }

    event MediaEyeLazyMintERC1155Initialized(
        address tokenAddress,
        address owner,
        uint256 timestamp,
        string initialBaseURI
    );

    event MediaEyeLazyMintERC1155(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256[] amounts,
        address minter,
        uint256 timestamp,
        bytes data
    );

    /**
     * @dev Grants `MINTER_ROLE`
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     */

    function initialize(
        address _owner,
        string memory _initialBaseURI,
        address _paymentMethod,
        PriceInflation memory _priceInflation,
        LimitedEdition[] memory _limitedEditions,
        uint256 _numTotalNFTs,
        Tier[] memory _tiers
    ) external initializer {
        require(_tiers.length > 0, "Must have at least one tier");

        __ERC1155_init(_initialBaseURI);
        owner = _owner;
        paymentMethod = _paymentMethod;

        if (_priceInflation.inflationType != InflationType.None) {
            require(
                _priceInflation.incrementCount > 0,
                "Must have a positive increment count"
            );
            require(
                _priceInflation.amount > 0,
                "Must have a positive inflation amount"
            );
        }

        priceInflation = _priceInflation;
        numLimitedEditions = _limitedEditions.length;
        for (uint256 i = 0; i < _limitedEditions.length; i++) {
            require(
                _limitedEditions[i].basePrice > 0 &&
                    _limitedEditions[i].basePrice ==
                    _limitedEditions[i].currPrice,
                "LE Base price must be greater than 0 and equal to curr"
            );
            limitedEditions[i] = _limitedEditions[i];
            limitedEditionsById[_limitedEditions[i].tokenId] = i;
        }

        numTotalNFTs = _numTotalNFTs;
        numTiers = _tiers.length;

        uint256 index = 0;
        for (uint256 i = 0; i < _tiers.length; i++) {
            require(_tiers[i].supply > 0, "Tier must have a positive supply");
            require(
                _tiers[i].basePrice > 0 &&
                    _tiers[i].basePrice == _tiers[i].currPrice,
                "Base price must be greater than 0 and equal curr price"
            );
            require(
                _tiers[i].startingTokenId > index,
                "Tier starting token ID must be greater than previous tier ending token ID"
            );
            tiers[i] = _tiers[i];
            index = _tiers[i].endingTokenId;
        }

        emit MediaEyeLazyMintERC1155Initialized(
            address(this),
            _owner,
            block.timestamp,
            _initialBaseURI
        );
    }

    // Get Creator
    function getCreator(uint256 _tokenId) external view returns (address) {
        return owner;
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 _id) public view override returns (string memory) {
        string memory baseURI = super.uri(_id);
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, _id.toString()))
                : "";
    }

    function _incrementPrice() internal {
        if (priceInflation.inflationType == InflationType.None) {
            return;
        } else if (priceInflation.inflationType == InflationType.Fixed) {
            for (uint256 i = 0; i < numTiers; i++) {
                tiers[i].currPrice += priceInflation.amount;
            }
            for (uint256 i = 0; i < numLimitedEditions; i++) {
                limitedEditions[i].currPrice += priceInflation.amount;
            }
        } else if (priceInflation.inflationType == InflationType.Percent) {
            for (uint256 i = 0; i < numTiers; i++) {
                tiers[i].currPrice += ((tiers[i].currPrice *
                    priceInflation.amount) / 100);
            }
            for (uint256 i = 0; i < numLimitedEditions; i++) {
                limitedEditions[i].currPrice += ((limitedEditions[i].currPrice *
                    priceInflation.amount) / 100);
            }
        }
    }

    function buy(
        address _to,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts,
        uint256[] memory _tiers,
        bytes memory _data
    ) public returns (uint256[] memory) {
        require(
            (_tokenIds.length == _tiers.length) &&
                (_tokenIds.length == _amounts.length),
            "Must have same number of token IDs, amounts and tiers"
        );

        require(_tokenIds.length > 0, "Must have at least one token ID");

        uint256 totalPrice = 0;
        uint256 currPrice;

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                _amounts[i] <= tiers[_tiers[i]].supply - sold[_tokenIds[i]],
                "Token already sold out"
            );
            // check if limited edition
            currPrice = limitedEditions[limitedEditionsById[_tokenIds[i]]]
                .currPrice;
            if (currPrice == 0) {
                require(
                    _tokenIds[i] >= tiers[_tiers[i]].startingTokenId &&
                        _tokenIds[i] <= tiers[_tiers[i]].endingTokenId,
                    "id not in tier"
                );
                currPrice = tiers[_tiers[i]].currPrice;
            }
            if (priceInflation.inflationType != InflationType.None) {
                uint256 inflateBy = _amounts[i] / priceInflation.incrementCount;
                uint256 remainder = _amounts[i] % priceInflation.incrementCount;
                uint256 currNumTillIncrement = priceInflation.incrementCount -
                    (numSold % priceInflation.incrementCount);
                if (remainder >= currNumTillIncrement) {
                    inflateBy += 1;
                }
                for (uint256 j = 0; j < inflateBy; j++) {
                    _incrementPrice();
                }
            }
            numSold += _amounts[i];
            sold[_tokenIds[i]] += _amounts[i];
            totalPrice += currPrice * _amounts[i];
        }

        if (paymentMethod == address(0)) {
            (bool success, ) = address(this).call{value: totalPrice}("");
            require(success, "Payment method not set");
        } else {
            IERC20(paymentMethod).transferFrom(
                msg.sender,
                address(this),
                totalPrice
            );
        }

        if (_tokenIds.length == 1) {
            _mint(_to, _tokenIds[0], _amounts[0], _data);
        } else {
            _mintBatch(_to, _tokenIds, _amounts, _data);
        }

        emit MediaEyeLazyMintERC1155(
            address(this),
            _tokenIds,
            _amounts,
            _to,
            block.timestamp,
            _data
        );

        return _tokenIds;
    }

    function setURI(string memory _newUri) external {
        require(msg.sender == owner, "must be owner to set new uri");
        _setURI(_newUri);
    }
}


// File @openzeppelin/contracts-upgradeable/token/ERC721/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}


// File @openzeppelin/contracts-upgradeable/token/ERC721/[email protected]


pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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


// File @openzeppelin/contracts-upgradeable/token/ERC721/extensions/[email protected]


pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
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


// File @openzeppelin/contracts-upgradeable/utils/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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


// File @openzeppelin/contracts-upgradeable/token/ERC721/[email protected]


pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

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
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
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
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

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
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
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
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
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
    uint256[44] private __gap;
}


// File @openzeppelin/contracts-upgradeable/token/ERC721/extensions/[email protected]


pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File @openzeppelin/contracts-upgradeable/token/ERC721/extensions/[email protected]


pragma solidity ^0.8.0;



/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal initializer {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
    uint256[46] private __gap;
}


// File contracts/lazymint/MediaEyeLazyMint721.sol

pragma solidity ^0.8.0;




/**
 * @dev {ERC721} token, including:
 *
 *  - deploy with upgradeability, replaced constructors with initializer functions
 *  - a minter role that allows for token minting (creation)
 *  - must be level 2 subscribed to change minters/roles
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles
 *
 */

contract MediaEyeLazyMint721 is ERC721EnumerableUpgradeable {
    using SafeERC20 for IERC20;

    string public baseTokenURI;
    address public owner;
    address public paymentMethod;
    PriceInflation public priceInflation;

    uint256 public numLimitedEditions;
    mapping(uint256 => LimitedEdition) public limitedEditions;
    mapping(uint256 => uint256) public limitedEditionsById;

    mapping(uint256 => uint256) public sold;

    uint256 public numSold;
    uint256 public numTotalNFTs;
    uint256 public numTiers;
    mapping(uint256 => Tier) public tiers;

    struct PriceInflation {
        uint256 incrementCount;
        InflationType inflationType;
        uint256 amount;
    }

    enum InflationType {
        Percent,
        Fixed,
        None
    }

    struct Tier {
        string name;
        uint256 basePrice;
        uint256 currPrice;
        uint256 startingTokenId;
        uint256 endingTokenId;
    }

    struct LimitedEdition {
        uint256 tokenId;
        uint256 basePrice;
        uint256 currPrice;
    }

    event MediaEyeLazyMintERC721Initialized(
        address tokenAddress,
        address owner,
        uint256 timestamp,
        string name,
        string symbol,
        string initialBaseURI
    );

    event MediaEyeLazyMintERC721Mint(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256 amount,
        address minter,
        uint256 timestamp
    );

    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _initialBaseURI,
        address _paymentMethod,
        PriceInflation memory _priceInflation,
        LimitedEdition[] memory _limitedEditions,
        uint256 _numTotalNFTs,
        Tier[] memory _tiers
    ) external initializer {
        require(_tiers.length > 0, "Must have at least one tier");

        __ERC721_init(_name, _symbol);
        baseTokenURI = _initialBaseURI;

        owner = _owner;
        paymentMethod = _paymentMethod;

        if (_priceInflation.inflationType != InflationType.None) {
            require(
                _priceInflation.incrementCount > 0,
                "Must have a positive increment count"
            );
            require(
                _priceInflation.amount > 0,
                "Must have a positive inflation amount"
            );
        }

        priceInflation = _priceInflation;

        numLimitedEditions = _limitedEditions.length;
        for (uint256 i = 0; i < _limitedEditions.length; i++) {
            require(
                _limitedEditions[i].basePrice > 0 &&
                    _limitedEditions[i].basePrice ==
                    _limitedEditions[i].currPrice,
                "LE Base price must be greater than 0 and equal to curr"
            );
            limitedEditions[i] = _limitedEditions[i];
            limitedEditionsById[_limitedEditions[i].tokenId] = i;
        }

        numTotalNFTs = _numTotalNFTs;
        numTiers = _tiers.length;

        uint256 index = 0;
        for (uint256 i = 0; i < _tiers.length; i++) {
            require(
                _tiers[i].basePrice > 0 &&
                    _tiers[i].basePrice == _tiers[i].currPrice,
                "Base price must be greater than 0 and equal curr price"
            );
            require(
                _tiers[i].startingTokenId > index,
                "Tier starting token ID must be greater than previous tier ending token ID"
            );
            tiers[i] = _tiers[i];
            index = _tiers[i].endingTokenId;
        }

        emit MediaEyeLazyMintERC721Initialized(
            address(this),
            owner,
            block.timestamp,
            _name,
            _symbol,
            _initialBaseURI
        );
    }

    function getCreator(uint256 _tokenId) external view returns (address) {
        return owner;
    }

    // function getCurrPrice(uint256 _tier, uint256 _tokenId, uint256 _precision)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     uint256 basePrice = limitedEditions[_tokenId];
    //     if (basePrice == 0) {
    //         require(
    //             _tokenId >= tiers[_tier].startingTokenId &&
    //                 _tokenId <= tiers[_tier].endingTokenId,
    //             "id not in tier"
    //         );
    //         basePrice = tiers[_tier].basePrice;
    //     }
    //     if (priceInflation.inflationType == InflationType.None) {
    //         return basePrice;
    //     } else if (priceInflation.inflationType == InflationType.Fixed) {
    //         return
    //             basePrice + (priceInflation.multiplier * priceInflation.amount);
    //     } else if (priceInflation.inflationType == InflationType.Percent) {
    //         return _fracExp(
    //             basePrice,
    //             100/priceInflation.amount,
    //             priceInflation.multiplier,
    //             _precision
    //         );
    //     }
    // }

    // function getCurrPrice(uint256 _tier, uint256 _tokenId)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     uint256 currPrice = limitedEditions[_tokenId].currPrice;
    //     if (currPrice == 0) {
    //         require(
    //             _tokenId >= tiers[_tier].startingTokenId &&
    //                 _tokenId <= tiers[_tier].endingTokenId,
    //             "id not in tier"
    //         );
    //         currPrice = tiers[_tier].currPrice;
    //     }
    //     if (priceInflation.inflationType == InflationType.None) {
    //         return currPrice;
    //     } else if (priceInflation.inflationType == InflationType.Fixed) {
    //         return
    //             basePrice + (priceInflation.multiplier * priceInflation.amount);
    //     } else if (priceInflation.inflationType == InflationType.Percent) {
    //         return _fracExp(
    //             basePrice,
    //             100/priceInflation.amount,
    //             priceInflation.multiplier,
    //             _precision
    //         );
    //     }
    // }

    // Computes `k * (1+1/q) ^ N`, with precision `p`. The higher
    // the precision, the higher the gas cost. It should be
    // something around the log of `n`. When `p == n`, the
    // precision is absolute (sans possible integer overflows). <edit: NOT true, see comments>
    // Much smaller values are sufficient to get a great approximation.
    // function _fracExp(
    //     uint256 k,
    //     uint256 q,
    //     uint256 n,
    //     uint256 p
    // ) internal view returns (uint256) {
    //     uint256 s = 0;
    //     uint256 N = 1;
    //     uint256 B = 1;
    //     for (uint256 i = 0; i < p; ++i) {
    //         s += (k * N) / B / (q**i);
    //         N = N * (n - i);
    //         B = B * (i + 1);
    //     }
    //     return s;
    // }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function _incrementPrice() internal {
        if (priceInflation.inflationType == InflationType.None) {
            return;
        } else if (priceInflation.inflationType == InflationType.Fixed) {
            for (uint256 i = 0; i < numTiers; i++) {
                tiers[i].currPrice += priceInflation.amount;
            }
            for (uint256 i = 0; i < numLimitedEditions; i++) {
                limitedEditions[i].currPrice += priceInflation.amount;
            }
        } else if (priceInflation.inflationType == InflationType.Percent) {
            for (uint256 i = 0; i < numTiers; i++) {
                tiers[i].currPrice += ((tiers[i].currPrice *
                    priceInflation.amount) / 100);
            }
            for (uint256 i = 0; i < numLimitedEditions; i++) {
                limitedEditions[i].currPrice += ((limitedEditions[i].currPrice *
                    priceInflation.amount) / 100);
            }
        }
    }

    function mint(
        address _to,
        uint256[] memory _tokenIds,
        uint256[] memory _tiers
    ) public returns (uint256[] memory) {
        require(
            _tokenIds.length == _tiers.length,
            "Must have same number of token IDs and tiers"
        );

        require(
            _tokenIds.length > 0,
            "Must have at least one token ID and tier"
        );
        uint256 totalPrice = 0;
        uint256 currPrice;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(sold[_tokenIds[i]] == 0, "Token already sold");
            // check if limited edition
            currPrice = limitedEditions[limitedEditionsById[_tokenIds[i]]]
                .currPrice;
            if (currPrice == 0) {
                require(
                    _tokenIds[i] >= tiers[_tiers[i]].startingTokenId &&
                        _tokenIds[i] <= tiers[_tiers[i]].endingTokenId,
                    "id not in tier"
                );
                currPrice = tiers[_tiers[i]].currPrice;
            }
            numSold += 1;
            sold[_tokenIds[i]] += 1;
            totalPrice += currPrice;
            if (
                priceInflation.inflationType != InflationType.None &&
                numSold % priceInflation.incrementCount == 0
            ) {
                _incrementPrice();
            }
        }

        if (paymentMethod == address(0)) {
            (bool success, ) = address(this).call{value: totalPrice}("");
            require(success, "Payment method not set");
        } else {
            IERC20(paymentMethod).transferFrom(
                msg.sender,
                address(this),
                totalPrice
            );
        }

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _safeMint(_to, _tokenIds[i]);
        }

        emit MediaEyeLazyMintERC721Mint(
            address(this),
            _tokenIds,
            _tokenIds.length,
            _to,
            block.timestamp
        );

        return _tokenIds;
    }
}


// File contracts/lazymint/MediaEyeLazyMintFactory.sol

pragma solidity ^0.8.0;




interface LazyMintCollection {
    enum InflationType {
        Percent,
        Fixed,
        None
    }
    struct PriceInflation {
        uint256 incrementCount;
        LazyMintCollection.InflationType inflationType;
        uint256 amount;
    }

    struct LimitedEdition {
        uint256 tokenId;
        uint256 basePrice;
        uint256 currPrice;
    }

    struct Tier {
        string name;
        uint256 basePrice;
        uint256 currPrice;
        uint256 startingTokenId;
        uint256 endingTokenId;
    }

    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        address paymentMethod,
        LazyMintCollection.PriceInflation memory priceInflation,
        LazyMintCollection.LimitedEdition[] memory limitedEditions,
        uint256 numTotalNFTs,
        LazyMintCollection.Tier[] memory tiers
    ) external;

    function initialize(
        address owner,
        string memory baseTokenURI,
        address paymentMethod,
        LazyMintCollection.PriceInflation memory priceInflation,
        LazyMintCollection.LimitedEdition[] memory limitedEditions,
        uint256 numTotalNFTs,
        LazyMintCollection.Tier[] memory tiers
    ) external;
}

contract LazyMintFactory is AccessControl {
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address public lazyMint721Implementation;
    address public lazyMint1155Implementation;
    address public feeContract;
    bool public subscriptionCheckActive;

    event LazyMint721Deployed(
        address addr,
        string name,
        string symbol,
        address owner,
        address paymentMethod
    );

    event LazyMint1155Deployed(
        address addr,
        address owner,
        address paymentMethod
    );

    constructor(
        address _owner,
        address[] memory _admins,
        address _ERC721Implementation,
        address _ERC1155Implementation,
        address _feeContract
    ) {
        lazyMint721Implementation = _ERC721Implementation;
        lazyMint1155Implementation = _ERC1155Implementation;
        feeContract = _feeContract;

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        subscriptionCheckActive = true;
    }

    function createLazyMint721Collection(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        address _paymentMethod,
        LazyMintCollection.PriceInflation memory _priceInflation,
        LazyMintCollection.LimitedEdition[] memory _limitedEditions,
        uint256 _numTotalNFTs,
        LazyMintCollection.Tier[] memory _tiers,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature
    ) external returns (address clone) {
        require(msg.sender == _owner, "collection owner must be sender");

        if (subscriptionCheckActive) {
            uint256 tier = 0;
            if (_subscriptionSignature.isValid) {
                require(
                    _subscriptionSignature.userSubscription.userAddress ==
                        msg.sender,
                    "signature check must be for sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _subscriptionSignature.userSubscription,
                        _subscriptionSignature.v,
                        _subscriptionSignature.r,
                        _subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    _owner
                );
            }
            require(
                tier > 0,
                "MediaEyeLazyMintFactory: must be subscribed to start a collection."
            );
        }

        clone = Clones.clone(lazyMint721Implementation);

        LazyMintCollection(clone).initialize(
            _owner,
            _name,
            _symbol,
            _baseTokenURI,
            _paymentMethod,
            _priceInflation,
            _limitedEditions,
            _numTotalNFTs,
            _tiers
        );

        emit LazyMint721Deployed(clone, _name, _symbol, _owner, _paymentMethod);
    }

    function createLazyMint1155Collection(
        address _owner,
        string memory _baseTokenURI,
        address _paymentMethod,
        LazyMintCollection.PriceInflation memory _priceInflation,
        LazyMintCollection.LimitedEdition[] memory _limitedEditions,
        uint256 _numTotalNFTs,
        LazyMintCollection.Tier[] memory _tiers,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature
    ) external returns (address clone) {
        require(msg.sender == _owner, "collection owner must be sender");

        if (subscriptionCheckActive) {
            uint256 tier = 0;
            if (_subscriptionSignature.isValid) {
                require(
                    _subscriptionSignature.userSubscription.userAddress ==
                        msg.sender,
                    "signature check must be for sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _subscriptionSignature.userSubscription,
                        _subscriptionSignature.v,
                        _subscriptionSignature.r,
                        _subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    _owner
                );
            }
            require(
                tier > 0,
                "MediaEyeLazyMintFactory: must be subscribed to start a collection."
            );
        }

        clone = Clones.clone(lazyMint1155Implementation);

        LazyMintCollection(clone).initialize(
            _owner,
            _baseTokenURI,
            _paymentMethod,
            _priceInflation,
            _limitedEditions,
            _numTotalNFTs,
            _tiers
        );

        emit LazyMint1155Deployed(clone, _owner, _paymentMethod);
    }

    function updateERC721Implementation(address _newERC721Implementation)
        external
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeLazyMintFactory: must have owner or admin role to change 721 implementation."
        );
        lazyMint721Implementation = _newERC721Implementation;
    }

    function updateERC1155Implementation(address _newERC1155Implementation)
        external
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeLazyMintFactory: must have owner or admin role to change 1155 implementation."
        );
        lazyMint1155Implementation = _newERC1155Implementation;
    }

    function updateFeeContract(address _newFeeContract) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeLazyMintFactory: must have owner or admin role to change fee contract."
        );
        feeContract = _newFeeContract;
    }
}


// File contracts/MediaEyeCanvas.sol

// update for chainlink
// update to factory
// maybe future feature
pragma solidity ^0.8.0;





// 100 plots wide, 100 plots tall
// 2000x2000px canvas, total 4 million pixels
// users can buy i

contract MediaEyeCanvas is AccessControl, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    uint256 public numTotalBlocks;
    uint256 public numBlocksPerRow;
    uint256 public numBlocksPerColumn;

    uint256 public numBlocksSold;

    // uint256 public numRowsAndColumns;
    uint256 public charityBasisPoint;
    uint256 public feeBasisPoint;

    address payable public feeWallet;
    address payable public feeWallet2;

    struct Block {
        uint256 rowId;
        uint256 columnId;
    }

    // owner of block, 0 address means not purchased
    // row>column
    mapping(uint256 => mapping(uint256 => address)) public blockOwner;

    // number of blocks owned by address
    mapping(address => uint256) public blocksOwned;

    mapping(address => uint256) public charityPaymentByAddress;

    // accepted paymentMethods
    EnumerableSet.AddressSet private paymentMethods;
    // token amounts of each payment method
    mapping(address => uint256) public paymentMethodAmounts;

    event BlocksPurchased(
        address owner,
        Block[] blocksPurchased,
        address paymentMethod,
        uint256 totalCost
    );

    event TokenAmountsChanged(
        address paymentMethod,
        uint256 paymentMethodAmount
    );
    event PaymentAdded(address paymentMethod, uint256 paymentMethodAmount);
    event PaymentRemoved(address paymentMethod);
    event FeeWalletChanged(address newFeeWallet);

    /********************** MODIFIERS ********************************/

    // only admin or owner
    modifier onlyAdmin() {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeCanvas: Sender is not an admin."
        );
        _;
    }

    // only owner
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "MediaEyeCanvas: Sender is not an owner."
        );
        _;
    }

    /**
     * @dev Stores and sets up the owners and admins, setting up feewallets, payment methods and payments. Stores initial canvas details.
     *
     * Params:
     * _owner: the address of the owner
     * _admins: addresses of the admins
     * _feeWallet: address to send fees to
     * _feeWallet2: address to send remainder of fees to
     * _paymentMethods: initial payment methods to accept
     * _initialTokenAmounts: amounts for each fee for each payment method
     * _numRowBlocks: the total amount of blocks per row
     * _numColumnBlocks: the total amount of blocks per column
     * _charityBasisPoint: percentage of fees to allocate to charity
     */
    constructor(
        address _owner,
        address[] memory _admins,
        address payable _feeWallet,
        address payable _feeWallet2,
        address[] memory _paymentMethods,
        uint256[] memory _initialTokenAmounts,
        uint256 _numRowBlocks,
        uint256 _numColumnBlocks,
        uint256 _charityBasisPoint
    ) {
        require(
            _initialTokenAmounts.length == _paymentMethods.length,
            "MediaEyeCanvas: There must be amounts for each payment method."
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);

        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }

        feeWallet = _feeWallet;
        feeWallet2 = _feeWallet2;

        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            paymentMethods.add(_paymentMethods[i]);
            paymentMethodAmounts[_paymentMethods[i]] = _initialTokenAmounts[i];
        }

        numBlocksPerRow = _numRowBlocks;
        numBlocksPerColumn = _numColumnBlocks;
        numTotalBlocks = numBlocksPerRow * numBlocksPerColumn;

        charityBasisPoint = _charityBasisPoint;
        feeBasisPoint = 1000;
    }

    /********************** Get methods ********************************/

    // Get number of payment methods accepted
    function getNumPaymentMethods() external view returns (uint256) {
        return paymentMethods.length();
    }

    // Returns true if is accepted payment method
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool)
    {
        return paymentMethods.contains(_paymentMethod);
    }

    /********************** Owner update methods ********************************/

    /**
     * @dev Update fee wallet
     *
     * Params:
     * _newFeeWallet: new fee wallet
     */
    function updateFeeWallet(address payable _newFeeWallet) external onlyOwner {
        feeWallet = _newFeeWallet;
        emit FeeWalletChanged(_newFeeWallet);
    }

    /********************** Admin update methods ********************************/

    /**
     * @dev Add single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to add
     */
    function addPaymentMethod(uint256 _newTokenAmount, address _paymentMethod)
        external
        onlyAdmin
    {
        require(
            !paymentMethods.contains(_paymentMethod),
            "MediaEyeCanvas: Payment method is already accepted."
        );
        paymentMethods.add(_paymentMethod);
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit PaymentAdded(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Removes single payment method
     *
     * Params:
     * _paymentMethod: the payment method to remove
     */
    function removePaymentMethod(address _paymentMethod) external onlyAdmin {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeCanvas: Payment method does not exist."
        );
        paymentMethods.remove(_paymentMethod);
        delete paymentMethodAmounts[_paymentMethod];
        emit PaymentRemoved(_paymentMethod);
    }

    /**
     * @dev Update Price Amounts for single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to change amountf or
     */
    function updateSingleTokenAmount(
        uint256 _newTokenAmount,
        address _paymentMethod
    ) external onlyAdmin {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeCanvas: Payment method does not exist."
        );
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit TokenAmountsChanged(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Update Price Amounts for multiple payment method
     *
     * Params:
     * _newTokenAmounts: new token amounts for multiple payment method
     * _paymentMethods: order of the tokenAmounts to set
     */
    function updateMultipleTokenAmounts(
        uint256[] memory _newTokenAmounts,
        address[] memory _paymentMethods
    ) external onlyAdmin {
        require(
            _newTokenAmounts.length == _paymentMethods.length,
            "MediaEyeCanvas: There must be amounts for each payment method"
        );
        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            require(
                paymentMethods.contains(_paymentMethods[i]),
                "MediaEyeCanvas: One of the payment method does not exist."
            );
            paymentMethodAmounts[_paymentMethods[i]] = _newTokenAmounts[i];
            emit TokenAmountsChanged(_paymentMethods[i], _newTokenAmounts[i]);
        }
    }

    function buyBlocks(
        Block[] memory _blocks,
        address _paymentMethod,
        address _owner
    ) external payable nonReentrant {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeCanvas: Payment method does not exist."
        );
        require(
            _blocks.length > 0 &&
                _blocks.length <= (numTotalBlocks - numBlocksSold),
            "MediaEyeCanvas: Must purchase at least one block and canvas not sold out."
        );
        for (uint256 i = 0; i < _blocks.length; i++) {
            require(
                _blocks[i].rowId > 0 &&
                    _blocks[i].rowId <= numBlocksPerRow &&
                    _blocks[i].columnId > 0 &&
                    _blocks[i].columnId <= numBlocksPerColumn,
                "MediaEyeCanvas: Valid row and column ids."
            );
            require(
                blockOwner[_blocks[i].rowId][_blocks[i].columnId] == address(0),
                "MediaEyeCanvas: Block already purchased"
            );
            blockOwner[_blocks[i].rowId][_blocks[i].columnId] = _owner;
        }

        uint256 totalCost = paymentMethodAmounts[_paymentMethod] *
            _blocks.length;
        uint256 payoutToCharity = (totalCost * charityBasisPoint) / 10000;
        uint256 payoutToFeeWallet2 = (totalCost * feeBasisPoint) / 10000;
        uint256 payoutToFeeWallet = (totalCost *
            (10000 - charityBasisPoint - feeBasisPoint)) / 10000;

        numBlocksSold = numBlocksSold + _blocks.length;
        charityPaymentByAddress[_paymentMethod] =
            charityPaymentByAddress[_paymentMethod] +
            payoutToCharity;
        blocksOwned[_owner] = blocksOwned[_owner] + _blocks.length;

        if (_paymentMethod == address(0)) {
            require(
                msg.value == totalCost,
                "MediaEyeCanvas: Incorrect transaction value."
            );
            (bool feeSent, ) = feeWallet.call{value: payoutToFeeWallet}("");
            require(feeSent, "MediaEyeCanvas: fee payment failed.");
            (bool fee2Sent, ) = feeWallet2.call{value: payoutToFeeWallet2}("");
            require(fee2Sent, "MediaEyeCanvas: fee2 payment failed.");
        } else {
            require(
                msg.value == 0,
                "MediaEyeCanvas: Incorrect transaction value."
            );
            IERC20(_paymentMethod).safeTransferFrom(
                msg.sender,
                address(this),
                payoutToCharity
            );
            IERC20(_paymentMethod).safeTransferFrom(
                msg.sender,
                feeWallet,
                payoutToFeeWallet
            );
            IERC20(_paymentMethod).safeTransferFrom(
                msg.sender,
                feeWallet2,
                payoutToFeeWallet2
            );
        }

        emit BlocksPurchased(_owner, _blocks, _paymentMethod, totalCost);
    }

    function updateFeeWallet2(address payable _newFeeWallet2) external {
        require(msg.sender == feeWallet2, "MediaEyeCanvas: Wrong caller.");
        feeWallet2 = _newFeeWallet2;
    }

    /********************** CHARITY FUNDS ********************************/
    /**
     * @dev Admin withdraw tokens for a single payment method to charities
     *
     * Params:
     * _paymentMethod: the token type to withdraw
     * _amount: amount to transfer, if amount is 0, it defaults to current max amount
     * _charities: charity addresses to send to, equal split amongst all of them
     */
    function withdrawPaymentToCharity(
        address _paymentMethod,
        uint256 _amountPerCharity,
        address[] memory _charities
    ) external onlyAdmin {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeCanvas: Payment method does not exist."
        );
        require(
            _charities.length > 0,
            "MediaEyeCanvas: Must specify at least one charity"
        );
        require(
            _amountPerCharity > 0 &&
                (_amountPerCharity * _charities.length) <=
                charityPaymentByAddress[_paymentMethod],
            "MediaEyeCanvas: Amount must be less than charity amount."
        );

        charityPaymentByAddress[_paymentMethod] =
            charityPaymentByAddress[_paymentMethod] -
            (_amountPerCharity * _charities.length);

        if (_paymentMethod == address(0)) {
            for (uint256 i = 0; i < _charities.length; i++) {
                (bool charitySent, ) = _charities[i].call{
                    value: _amountPerCharity
                }("");
                require(charitySent, "MediaEyeCanvas: charity payment failed.");
            }
        } else {
            for (uint256 i = 0; i < _charities.length; i++) {
                IERC20(_paymentMethod).safeTransfer(
                    _charities[i],
                    _amountPerCharity
                );
            }
        }
    }
}


// File contracts/MediaEyeChainlinkFeed.sol

pragma solidity ^0.8.0;


/**
 * Network: Ethereum
 * Aggregator: ETH/USD
 * Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
 * Decimals: 8
 */
/**
 * Network: BSC
 * Aggregator: BUSD/BNB
 * Address: 0x87Ea38c9F24264Ec1Fff41B04ec94a97Caf99941
 * Decimals: 18
 */
/**
 * Network: FTM
 * Aggregator: FTM/USD
 * Address: 0xf4766552D15AE4d256Ad41B6cf2933482B0680dc
 * Decimals: 8
 */

contract MediaEyeChainlinkFeed {
    using SafeCast for int256;
    AggregatorV3Interface internal priceFeed;

    constructor(address _aggregator) {
        priceFeed = AggregatorV3Interface(_aggregator);
    }

    function getRoundData() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();

        return price.toUint256();
    }

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) public view returns (uint256) {
        require(_baseDecimals > 0 && _baseDecimals <= 18, "Invalid _decimals");
        require(
            _queryDecimals > 0 && _queryDecimals <= 18,
            "Invalid _decimals"
        );

        uint256 roundData = getRoundData();
        uint256 roundDataDecimals = priceFeed.decimals();
        uint256 query = 0;

        if (_convertToNative) {
            if (_invertedAggregator) {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            } else {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            }
        } else {
            if (_invertedAggregator) {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            } else {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            }
        }

        if (_baseDecimals > _queryDecimals) {
            uint256 decimals = _baseDecimals - _queryDecimals;
            query = query / (10**decimals);
        } else if (_baseDecimals < _queryDecimals) {
            uint256 decimals = _queryDecimals - _baseDecimals;
            query = query * (10**decimals);
        }
        return query;
    }
}


// File contracts/MediaEyeCharities.sol

pragma solidity ^0.8.0;


contract MediaEyeCharities is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    EnumerableSet.AddressSet private charities;

    event CharitiesAdded(address[] charities);

    event CharitiesRemoved(address[] charities);

    modifier onlyAdmin() {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        _;
    }


    /**
     * @dev Constructor
     *
     * Params:
     * _owner: address of the owner
     * _admins: addresses of initial admins
     * _charities: initial charities to accept
     */
     
    constructor(
        address _owner,
        address[] memory _admins,
        address[] memory _charities
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        for (uint256 i = 0; i < _charities.length; i++) {
            charities.add(_charities[i]);
        }
    }

    /**
     * @dev Adds charities
     *
     * Params:
     * _charities: the addresses of the charities to add
     */
    function addCharities(address[] memory _charities) external onlyAdmin {
        for (uint256 i = 0; i < _charities.length; i++) {
            require(!charities.contains(_charities[i]), "charity");
            charities.add(_charities[i]);
        }
        emit CharitiesAdded(_charities);
    }

    /**
     * @dev Removes charities
     *
     * Params:
     * _charities: the addresses of the charities to remove
     */
    function removeCharities(address[] memory _charities) external onlyAdmin {
        for (uint256 i = 0; i < _charities.length; i++) {
            require(charities.contains(_charities[i]), "charity");
            charities.remove(_charities[i]);
        }
        emit CharitiesRemoved(_charities);
    }

    /********************** Get Functions ********************************/

    // Get number of charities
    function getNumCharities() external view returns (uint256) {
        return charities.length();
    }

    // Get if is charity
    function isCharity(address _charity) external view returns (bool) {
        return charities.contains(_charity);
    }
}


// File contracts/MediaEyeCollectionFactory.sol

pragma solidity ^0.8.0;






interface Collection {
    struct ERC721Mints {
        address to;
        string[] tokenDatum;
        string[] metadataURIs;
    }

    struct ERC1155Mints {
        address to;
        uint256[] amounts;
        bytes data;
        string[] tokenDatum;
        string[] metadataURIs;
    }

    function initialize(
        address owner,
        address[] memory minters,
        string memory name,
        string memory symbol,
        ERC721Mints memory mints,
        address feeContract
    ) external;

    function initialize(
        address owner,
        address[] memory minters,
        ERC1155Mints memory mints,
        address feeContract
    ) external;
}

contract CollectionFactory is AccessControl {
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    using MediaEyeOrders for MediaEyeOrders.Feature;
    using SafeERC20 for IERC20;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address public erc721Implementation;
    address public erc1155Implementation;
    address public feeContract;
    bool public subscriptionCheckActive;

    event ERC721CollectionDeployed(
        address addr,
        string name,
        string symbol,
        address owner,
        address[] minters,
        string tokenData,
        Collection.ERC721Mints mints
    );
    event ERC1155CollectionDeployed(
        address addr,
        address owner,
        address[] minters,
        string tokenData,
        Collection.ERC1155Mints mints
    );

    constructor(
        address _owner,
        address[] memory _admins,
        address _ERC721Implementation,
        address _ERC1155Implementation,
        address _feeContract
    ) {
        erc721Implementation = _ERC721Implementation;
        erc1155Implementation = _ERC1155Implementation;
        feeContract = _feeContract;
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        subscriptionCheckActive = true;
    }

    function createERC721Collection(
        address _owner,
        address[] memory _minters,
        string memory _name,
        string memory _symbol,
        Collection.ERC721Mints memory _mints,
        string calldata _tokenData,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature,
        MediaEyeOrders.Feature memory _featureCollection
    ) external payable returns (address clone) {
        require(msg.sender == _owner, "collection owner must be sender");
        if (subscriptionCheckActive) {
            uint256 tier = 0;
            if (_subscriptionSignature.isValid) {
                require(
                    _subscriptionSignature.userSubscription.userAddress ==
                        msg.sender,
                    "signature check must be for sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _subscriptionSignature.userSubscription,
                        _subscriptionSignature.v,
                        _subscriptionSignature.r,
                        _subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    _owner
                );
            }
            require(
                tier > 0,
                "MediaEyeCollectionFactory: must be subscribed to start a collection."
            );
            if (tier == 1) {
                require(
                    _minters.length == 0,
                    "MediaEyeCollectionFactory: must be subscribed to level 2 to start a group collection."
                );
            }
        }

        clone = Clones.clone(erc721Implementation);
        Collection(clone).initialize(
            _owner,
            _minters,
            _name,
            _symbol,
            _mints,
            feeContract
        );
        if (_featureCollection.feature) {
            if (_featureCollection.paymentMethod != address(0)) {
                IERC20(_featureCollection.paymentMethod).transferFrom(
                    msg.sender,
                    feeContract,
                    _featureCollection.price
                );
            }
            ISubscriptionTier.Featured memory featured = ISubscriptionTier
                .Featured(
                    0,
                    _featureCollection.numDays,
                    2,
                    clone,
                    0,
                    0,
                    _featureCollection.id,
                    _owner,
                    _featureCollection.price
                );
            ISubscriptionTier(feeContract).payFeatureFee{value: msg.value}(
                _featureCollection.paymentMethod,
                _featureCollection.tokenAddresses,
                _featureCollection.tokenIds,
                featured
            );
        }

        emit ERC721CollectionDeployed(
            clone,
            _name,
            _symbol,
            _owner,
            _minters,
            _tokenData,
            _mints
        );
    }

    function createERC1155Collection(
        address _owner,
        address[] memory _minters,
        Collection.ERC1155Mints memory _mints,
        string calldata _tokenData,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature,
        MediaEyeOrders.Feature memory _featureCollection
    ) external payable returns (address clone) {
        require(msg.sender == _owner, "collection owner must be sender");
        if (subscriptionCheckActive) {
            uint256 tier = 0;
            if (_subscriptionSignature.isValid) {
                require(
                    _subscriptionSignature.userSubscription.userAddress ==
                        msg.sender,
                    "signature check must be for sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _subscriptionSignature.userSubscription,
                        _subscriptionSignature.v,
                        _subscriptionSignature.r,
                        _subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    _owner
                );
            }
            require(
                tier > 0,
                "MediaEyeCollectionFactory: must be subscribed to start a collection."
            );
            if (tier == 1) {
                require(
                    _minters.length == 0,
                    "MediaEyeCollectionFactory: must be subscribed to level 2 to start a group collection."
                );
            }
        }

        clone = Clones.clone(erc1155Implementation);
        Collection(clone).initialize(_owner, _minters, _mints, feeContract);

        if (_featureCollection.feature) {
            if (_featureCollection.paymentMethod != address(0)) {
                IERC20(_featureCollection.paymentMethod).transferFrom(
                    msg.sender,
                    feeContract,
                    _featureCollection.price
                );
            }
            ISubscriptionTier(feeContract).payFeatureFee{value: msg.value}(
                _featureCollection.paymentMethod,
                _featureCollection.tokenAddresses,
                _featureCollection.tokenIds,
                ISubscriptionTier.Featured(
                    0,
                    _featureCollection.numDays,
                    3,
                    clone,
                    0,
                    0,
                    _featureCollection.id,
                    _owner,
                    _featureCollection.price
                )
            );
        }

        emit ERC1155CollectionDeployed(
            clone,
            _owner,
            _minters,
            _tokenData,
            _mints
        );
    }

    function updateERC721Implementation(address _newERC721Implementation)
        external
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change 721 implementation."
        );
        erc721Implementation = _newERC721Implementation;
    }

    function updateERC1155Implementation(address _newERC1155Implementation)
        external
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change 1155 implementation."
        );
        erc1155Implementation = _newERC1155Implementation;
    }

    function updateFeeContract(address _newFeeContract) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change fee contract."
        );
        feeContract = _newFeeContract;
    }

    function updateSubscriptionCheck(bool _check) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                hasRole(ROLE_ADMIN, _msgSender()),
            "MediaEyeCollectionFactory: must have owner or admin role to change subscription check."
        );
        subscriptionCheckActive = _check;
    }
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]


pragma solidity ^0.8.0;





/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}


// File @openzeppelin/contracts-upgradeable/utils/structs/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


// File @openzeppelin/contracts-upgradeable/access/[email protected]


pragma solidity ^0.8.0;




/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
    uint256[49] private __gap;
}


// File contracts/MediaEyeERC1155.sol

pragma solidity ^0.8.0;




/**
 * @dev {ERC1155} token, including:
 *
 *  - deploy with upgradeability, replaced constructors with initializer functions
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles
 *
 */

contract MediaEyeERC1155 is
    ERC1155SupplyUpgradeable,
    AccessControlEnumerableUpgradeable
{
    using Counters for Counters.Counter;
    using ERC1155Strings for uint256;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    Counters.Counter private _tokenIdTracker;

    mapping(uint256 => address) public creators;
    mapping(uint256 => string) private tokenURIs;

    event MediaEyeERC1155Mint(
        address tokenAddress,
        uint256 tokenID,
        uint256 amount,
        address minter,
        uint256 timestamp,
        string tokenData,
        string metadataURI
    );

    event MediaEyeERC1155MintBatch(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256[] amounts,
        address minter,
        uint256 timestamp,
        string[] tokenDatum,
        string[] metadataURIs
    );

    event MediaEyeBurnBatchNft1155(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256[] amounts,
        address burner,
        uint256 timestamp
    );

    /**
     * @dev Grants `ROLE_ADMIN`
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs ipfs hash.
     */

    function initialize(address _owner, address[] memory _admins)
        external
        initializer
    {
        __ERC1155_init("ipfs://");

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);

        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
    }

    // Get Creator
    function getCreator(uint256 _tokenId) external view returns (address) {
        return creators[_tokenId];
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 _id) public view override returns (string memory) {
        string memory baseURI = super.uri(_id);
        string memory tokenURI = tokenURIs[_id];

        // If there is no baseURI URI, return the token URI.
        if (bytes(baseURI).length == 0) {
            return tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(tokenURI).length > 0) {
            return string(abi.encodePacked(baseURI, tokenURI));
        }

        return baseURI;
    }

    function mint(
        address _to,
        uint256 _amount,
        bytes memory _data,
        string memory _tokenData,
        string memory _metadataURI
    ) external returns (uint256) {
        uint256 tokenId = _tokenIdTracker.current();
        creators[tokenId] = _to;
        _mint(_to, tokenId, _amount, _data);
        tokenURIs[tokenId] = _metadataURI;

        emit MediaEyeERC1155Mint(
            address(this),
            tokenId,
            _amount,
            _to,
            block.timestamp,
            _tokenData,
            _metadataURI
        );

        _tokenIdTracker.increment();
        return tokenId;
    }

    function mintBatch(
        address _to,
        uint256[] memory _amounts,
        bytes memory _data,
        string[] memory _tokenDatum,
        string[] memory _metadataURIs
    ) external returns (uint256[] memory) {
        require(
            _amounts.length == _tokenDatum.length &&
                _amounts.length == _metadataURIs.length,
            "MediaEyeERC1155: batch amounts must match"
        );
        uint256[] memory tokenIds = new uint256[](_amounts.length);
        for (uint256 i = 0; i < _amounts.length; i++) {
            tokenIds[i] = _tokenIdTracker.current();
            tokenURIs[tokenIds[i]] = _metadataURIs[i];
            creators[tokenIds[i]] = _to;
            _tokenIdTracker.increment();
        }
        _mintBatch(_to, tokenIds, _amounts, _data);
        emit MediaEyeERC1155MintBatch(
            address(this),
            tokenIds,
            _amounts,
            _to,
            block.timestamp,
            _tokenDatum,
            _metadataURIs
        );
        return tokenIds;
    }

    function burnBatch(uint256[] memory _ids, uint256[] memory _amounts)
        external
    {
        _burnBatch(msg.sender, _ids, _amounts);
        emit MediaEyeBurnBatchNft1155(
            address(this),
            _ids,
            _amounts,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerableUpgradeable, ERC1155Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File @openzeppelin/contracts-upgradeable/security/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}


// File contracts/MediaEyeERC1155Collection.sol

pragma solidity ^0.8.0;







/**
 * @dev {ERC1155} token, including:
 *
 *  - deploy with upgradeability, replaced constructors with initializer functions
 *  - a minter role that allows for token minting (creation)
 *  - must be level 2 subscribed to change minters/roles
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles
 *
 */

contract MediaEyeERC1155Collection is
    ERC1155SupplyUpgradeable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Counters for Counters.Counter;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    using ERC1155Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address public feeContract;

    Counters.Counter private _tokenIdTracker;

    mapping(uint256 => address) public creators;
    mapping(uint256 => string) private tokenURIs;

    struct Mints {
        address to;
        uint256[] amounts;
        bytes data;
        string[] tokenDatum;
        string[] metadataURIs;
    }

    event MediaEyeERC1155Initialized(
        address tokenAddress,
        address owner,
        address[] minters,
        uint256 timestamp
    );

    event MediaEyeERC1155Mint(
        address tokenAddress,
        uint256 tokenID,
        uint256 amount,
        address minter,
        uint256 timestamp,
        string tokenData,
        string metadataURI
    );

    event MediaEyeERC1155MintBatch(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256[] amounts,
        address minter,
        uint256 timestamp,
        string[] tokenDatum,
        string[] metadataURIs
    );

    event MediaEyeBurnBatchNft1155(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256[] amounts,
        address burner,
        uint256 timestamp
    );

    event MediaEyeCollectionRole(
        address tokenAddress,
        bytes32 role,
        address account,
        uint256 timestamp,
        bool isGranted
    );

    /**
     * @dev Grants `MINTER_ROLE`
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     */

    function initialize(
        address _owner,
        address[] memory _minters,
        Mints memory _mints,
        address _feeContract
    ) external initializer {
        __ERC1155_init("ipfs://");
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(DEFAULT_ADMIN_ROLE, address(this));

        for (uint256 i = 0; i < _minters.length; i++) {
            _setupRole(MINTER_ROLE, _minters[i]);
        }

        _setupRole(MINTER_ROLE, _owner);
        _setupRole(MINTER_ROLE, msg.sender);

        feeContract = _feeContract;

        emit MediaEyeERC1155Initialized(
            address(this),
            _owner,
            _minters,
            block.timestamp
        );
        require(
            _mints.amounts.length == _mints.tokenDatum.length &&
                _mints.amounts.length == _mints.metadataURIs.length,
            "lengths"
        );

        if (_mints.amounts.length == 1) {
            mint(
                _mints.to,
                _mints.amounts[0],
                _mints.data,
                _mints.tokenDatum[0],
                _mints.metadataURIs[0]
            );
        } else if (_mints.amounts.length > 1) {
            mintBatch(
                _mints.to,
                _mints.amounts,
                _mints.data,
                _mints.tokenDatum,
                _mints.metadataURIs
            );
        }
    }

    // Get Creator
    function getCreator(uint256 _tokenId) external view returns (address) {
        return creators[_tokenId];
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 _id) public view override returns (string memory) {
        string memory baseURI = super.uri(_id);
        string memory tokenURI = tokenURIs[_id];

        // If there is no baseURI URI, return the token URI.
        if (bytes(baseURI).length == 0) {
            return tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(tokenURI).length > 0) {
            return string(abi.encodePacked(baseURI, tokenURI));
        }

        return baseURI;
    }

    function mint(
        address _to,
        uint256 _amount,
        bytes memory _data,
        string memory _tokenData,
        string memory _metadataURI
    ) public returns (uint256) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "MediaEyeERC1155: must have minter role to mint"
        );

        uint256 tokenId = _tokenIdTracker.current();
        creators[tokenId] = _to;
        _mint(_to, tokenId, _amount, _data);
        tokenURIs[tokenId] = _metadataURI;

        emit MediaEyeERC1155Mint(
            address(this),
            tokenId,
            _amount,
            _to,
            block.timestamp,
            _tokenData,
            _metadataURI
        );

        _tokenIdTracker.increment();
        return tokenId;
    }

    function mintBatch(
        address _to,
        uint256[] memory _amounts,
        bytes memory _data,
        string[] memory _tokenDatum,
        string[] memory _metadataURIs
    ) public returns (uint256[] memory) {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "MediaEyeERC1155: must have minter role to mint"
        );

        require(
            _amounts.length == _tokenDatum.length &&
                _amounts.length == _metadataURIs.length,
            "MediaEyeERC1155: batch amounts must match"
        );
        uint256[] memory tokenIds = new uint256[](_amounts.length);
        for (uint256 i = 0; i < _amounts.length; i++) {
            tokenIds[i] = _tokenIdTracker.current();
            tokenURIs[tokenIds[i]] = _metadataURIs[i];
            creators[tokenIds[i]] = _to;
            _tokenIdTracker.increment();
        }
        _mintBatch(_to, tokenIds, _amounts, _data);
        emit MediaEyeERC1155MintBatch(
            address(this),
            tokenIds,
            _amounts,
            _to,
            block.timestamp,
            _tokenDatum,
            _metadataURIs
        );
        return tokenIds;
    }

    function burnBatch(uint256[] memory _ids, uint256[] memory _amounts)
        external
    {
        _burnBatch(msg.sender, _ids, _amounts);
        emit MediaEyeBurnBatchNft1155(
            address(this),
            _ids,
            _amounts,
            msg.sender,
            block.timestamp
        );
    }

    function grantRole(bytes32 role, address account) public override {
        require(
            msg.sender == address(this),
            "MediaEyeERC1155: must be called internally"
        );
        super.grantRole(role, account);
        emit MediaEyeCollectionRole(
            address(this),
            role,
            account,
            block.timestamp,
            true
        );
    }

    function grantRoleBySig(
        bytes32 role,
        address account,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature
    ) public nonReentrant onlyRole(getRoleAdmin(role)) {
        uint256 tier = 0;
        if (_subscriptionSignature.isValid) {
            require(
                msg.sender ==
                    _subscriptionSignature.userSubscription.userAddress,
                "subscription info must be of sender"
            );
            tier = ISubscriptionTier(feeContract).checkUserSubscriptionBySig(
                _subscriptionSignature.userSubscription,
                _subscriptionSignature.v,
                _subscriptionSignature.r,
                _subscriptionSignature.s
            );
        } else {
            tier = ISubscriptionTier(feeContract).checkUserSubscription(
                msg.sender
            );
        }
        require(
            tier > 1,
            "MediaEyeERC1155: must be subscribed to level 2 to change roles."
        );
        bytes memory _data = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            role,
            account
        );
        (bool success, ) = address(this).call(_data);
        require(success);
    }

    function revokeRole(bytes32 role, address account) public override {
        require(
            msg.sender == address(this),
            "MediaEyeERC1155: must be called internally"
        );
        super.revokeRole(role, account);
        emit MediaEyeCollectionRole(
            address(this),
            role,
            account,
            block.timestamp,
            false
        );
    }

    function revokeRoleBySig(
        bytes32 role,
        address account,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature
    ) public nonReentrant onlyRole(getRoleAdmin(role)) {
        uint256 tier = 0;
        if (_subscriptionSignature.isValid) {
            require(
                msg.sender ==
                    _subscriptionSignature.userSubscription.userAddress,
                "subscription info must be of sender"
            );
            tier = ISubscriptionTier(feeContract).checkUserSubscriptionBySig(
                _subscriptionSignature.userSubscription,
                _subscriptionSignature.v,
                _subscriptionSignature.r,
                _subscriptionSignature.s
            );
        } else {
            tier = ISubscriptionTier(feeContract).checkUserSubscription(
                msg.sender
            );
        }
        require(
            tier > 1,
            "MediaEyeERC1155: must be subscribed to level 2 to change roles."
        );
        bytes memory _data = abi.encodeWithSignature(
            "revokeRole(bytes32,address)",
            role,
            account
        );
        (bool success, ) = address(this).call(_data);
        require(success);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerableUpgradeable, ERC1155Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File contracts/MediaEyeERC721.sol

pragma solidity ^0.8.0;



/**
 * @dev {ERC721} token, including:
 *
 *  - deploy with upgradeability, replaced constructors with initializer functions
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles
 *
 */

contract MediaEyeERC721 is
    ERC721EnumerableUpgradeable,
    AccessControlEnumerableUpgradeable
{
    using Counters for Counters.Counter;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    Counters.Counter private _tokenIdTracker;
    string public baseTokenURI;
    mapping(uint256 => string) private tokenURIs;

    mapping(uint256 => address) public creators;

    event MediaEyeERC721Mint(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256 amount,
        address minter,
        uint256 timestamp,
        string[] tokenDatas,
        string[] metadataURIs
    );

    event MediaEyeBurnNft721(
        address tokenAddress,
        uint256 tokenID,
        address burner,
        uint256 timestamp
    );

    /**
     * @dev Grants `MINTER_ROLE`
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     */

    function initialize(
        address _owner,
        address[] memory _admins,
        string memory _name,
        string memory _symbol
    ) external initializer {
        __ERC721_init(_name, _symbol);
        baseTokenURI = "ipfs://";

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);

        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
    }

    // Get Creator
    function getCreator(uint256 _tokenId) external view returns (address) {
        return creators[_tokenId];
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
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
        string memory tokenURIById = tokenURIs[tokenId];

        // If there is no baseURI URI, return the token URI.
        if (bytes(baseURI).length == 0) {
            return tokenURIById;
        }
        // If both are set, concatenate the baseURI and tokenURIById (via abi.encodePacked).
        if (bytes(tokenURIById).length > 0) {
            return string(abi.encodePacked(baseURI, tokenURIById));
        }

        return baseURI;
    }

    function mint(
        address _to,
        string[] memory _tokenDatum,
        string[] memory _metadataURIs
    ) external returns (uint256[] memory) {
        require(
            _metadataURIs.length == _tokenDatum.length,
            "metadataUris/data must be the same length"
        );

        uint256[] memory tokenIds = new uint256[](_tokenDatum.length);

        for (uint256 i = 0; i < _tokenDatum.length; i++) {
            tokenIds[i] = _tokenIdTracker.current();
            creators[tokenIds[i]] = _to;
            tokenURIs[tokenIds[i]] = _metadataURIs[i];
            _safeMint(_to, _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }

        emit MediaEyeERC721Mint(
            address(this),
            tokenIds,
            _tokenDatum.length,
            _to,
            block.timestamp,
            _tokenDatum,
            _metadataURIs
        );

        return tokenIds;
    }

    function burn(uint256 _id) external {
        require(ownerOf(_id) == msg.sender, "caller is not owner");
        _burn(_id);
        emit MediaEyeBurnNft721(
            address(this),
            _id,
            msg.sender,
            block.timestamp
        );
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(
            AccessControlEnumerableUpgradeable,
            ERC721EnumerableUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File contracts/MediaEyeERC721Collection.sol

pragma solidity ^0.8.0;






/**
 * @dev {ERC721} token, including:
 *
 *  - deploy with upgradeability, replaced constructors with initializer functions
 *  - a minter role that allows for token minting (creation)
 *  - must be level 2 subscribed to change minters/roles
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles
 *
 */

contract MediaEyeERC721Collection is
    ERC721EnumerableUpgradeable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Counters for Counters.Counter;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address public feeContract;

    Counters.Counter private _tokenIdTracker;
    string public baseTokenURI;
    mapping(uint256 => string) private tokenURIs;

    mapping(uint256 => address) public creators;

    struct Mints {
        address to;
        string[] tokenDatum;
        string[] metadataURIs;
    }

    event MediaEyeERC721Initialized(
        address tokenAddress,
        address owner,
        address[] minters,
        uint256 timestamp,
        string name,
        string symbol
    );

    event MediaEyeERC721Mint(
        address tokenAddress,
        uint256[] tokenIDs,
        uint256 amount,
        address minter,
        uint256 timestamp,
        string[] tokenDatum,
        string[] metadataURIs
    );

    event MediaEyeCollectionRole(
        address tokenAddress,
        bytes32 role,
        address account,
        uint256 timestamp,
        bool isGranted
    );

    event MediaEyeBurnNft721(
        address tokenAddress,
        uint256 tokenID,
        address burner,
        uint256 timestamp
    );

    /**
     * @dev Grants `MINTER_ROLE`
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     */

    function initialize(
        address _owner,
        address[] memory _minters,
        string memory _name,
        string memory _symbol,
        Mints memory _mints,
        address _feeContract
    ) external initializer {
        __ERC721_init(_name, _symbol);
        baseTokenURI = "ipfs://";

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(DEFAULT_ADMIN_ROLE, address(this));

        for (uint256 i = 0; i < _minters.length; i++) {
            _setupRole(MINTER_ROLE, _minters[i]);
        }

        _setupRole(MINTER_ROLE, _owner);
        _setupRole(MINTER_ROLE, msg.sender);

        feeContract = _feeContract;

        emit MediaEyeERC721Initialized(
            address(this),
            _owner,
            _minters,
            block.timestamp,
            _name,
            _symbol
        );

        if (
            _mints.to != address(0) &&
            _mints.tokenDatum.length > 0 &&
            _mints.metadataURIs.length > 0
        ) {
            mint(_mints.to, _mints.tokenDatum, _mints.metadataURIs);
        }
    }

    // Get Creator
    function getCreator(uint256 _tokenId) external view returns (address) {
        return creators[_tokenId];
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
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
        string memory tokenURIById = tokenURIs[tokenId];

        // If there is no baseURI URI, return the token URI.
        if (bytes(baseURI).length == 0) {
            return tokenURIById;
        }
        // If both are set, concatenate the baseURI and tokenURIById (via abi.encodePacked).
        if (bytes(tokenURIById).length > 0) {
            return string(abi.encodePacked(baseURI, tokenURIById));
        }

        return baseURI;
    }

    function mint(
        address _to,
        string[] memory _tokenDatum,
        string[] memory _metadataURIs
    ) public returns (uint256[] memory) {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "MediaEyeERC721: must have minter role to mint"
        );

        require(
            _tokenDatum.length == _metadataURIs.length,
            "tokenDatum and metadataURIs must be the same length"
        );

        uint256[] memory tokenIds = new uint256[](_tokenDatum.length);

        for (uint256 i = 0; i < _tokenDatum.length; i++) {
            tokenIds[i] = _tokenIdTracker.current();
            creators[tokenIds[i]] = _to;
            tokenURIs[tokenIds[i]] = _metadataURIs[i];
            _safeMint(_to, _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }

        emit MediaEyeERC721Mint(
            address(this),
            tokenIds,
            _tokenDatum.length,
            _to,
            block.timestamp,
            _tokenDatum,
            _metadataURIs
        );

        return tokenIds;
    }

    function burn(uint256 _id) external {
        require(ownerOf(_id) == msg.sender, "caller is not owner");
        _burn(_id);
        emit MediaEyeBurnNft721(
            address(this),
            _id,
            msg.sender,
            block.timestamp
        );
    }

    function grantRole(bytes32 role, address account) public override {
        require(
            msg.sender == address(this),
            "MediaEyeERC721: must be called internally"
        );
        super.grantRole(role, account);
        emit MediaEyeCollectionRole(
            address(this),
            role,
            account,
            block.timestamp,
            true
        );
    }

    function grantRoleBySig(
        bytes32 role,
        address account,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature
    ) public nonReentrant onlyRole(getRoleAdmin(role)) {
        uint256 tier = 0;
        if (_subscriptionSignature.isValid) {
            require(
                msg.sender ==
                    _subscriptionSignature.userSubscription.userAddress,
                "subscription info must be of sender"
            );
            tier = ISubscriptionTier(feeContract).checkUserSubscriptionBySig(
                _subscriptionSignature.userSubscription,
                _subscriptionSignature.v,
                _subscriptionSignature.r,
                _subscriptionSignature.s
            );
        } else {
            tier = ISubscriptionTier(feeContract).checkUserSubscription(
                msg.sender
            );
        }
        require(
            tier > 1,
            "MediaEyeERC721: must be subscribed to level 2 to change roles."
        );
        bytes memory _data = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            role,
            account
        );
        (bool success, ) = address(this).call(_data);
        require(success);
    }

    function revokeRole(bytes32 role, address account) public override {
        require(
            msg.sender == address(this),
            "MediaEyeERC721: must be called internally"
        );
        super.revokeRole(role, account);
        emit MediaEyeCollectionRole(
            address(this),
            role,
            account,
            block.timestamp,
            false
        );
    }

    function revokeRoleBySig(
        bytes32 role,
        address account,
        MediaEyeOrders.SubscriptionSignature memory _subscriptionSignature
    ) public nonReentrant onlyRole(getRoleAdmin(role)) {
        uint256 tier = 0;
        if (_subscriptionSignature.isValid) {
            require(
                msg.sender ==
                    _subscriptionSignature.userSubscription.userAddress,
                "subscription info must be of sender"
            );
            tier = ISubscriptionTier(feeContract).checkUserSubscriptionBySig(
                _subscriptionSignature.userSubscription,
                _subscriptionSignature.v,
                _subscriptionSignature.r,
                _subscriptionSignature.s
            );
        } else {
            tier = ISubscriptionTier(feeContract).checkUserSubscription(
                msg.sender
            );
        }
        require(
            tier > 1,
            "MediaEyeERC721: must be subscribed to level 2 to change roles."
        );
        bytes memory _data = abi.encodeWithSignature(
            "revokeRole(bytes32,address)",
            role,
            account
        );
        (bool success, ) = address(this).call(_data);
        require(success);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(
            AccessControlEnumerableUpgradeable,
            ERC721EnumerableUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File contracts/interfaces/IMediaEyeSubscriptionMediator.sol

pragma solidity ^0.8.0;

interface IMediaEyeSubscriptionMediator {
    function subscribeByMediator(address account, uint256 startTimestamp, uint256 endTimestamp, bool tier) external;
    function subscribeLevelOne(address account, uint256 startTimestamp, uint256 endTimestamp) external;
}


// File contracts/MediaEyeFee.sol

pragma solidity ^0.8.0;







contract MediaEyeFee is AccessControl {
    using SafeCast for int256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionTier;
    using MediaEyeOrders for MediaEyeOrders.UserSubscription;

    bytes32 internal immutable _DOMAIN_SEPARATOR;
    bytes32 internal SUBSCRIPTION_SIGNATURE_TYPEHASH =
        0x8f46388099841dd51e9fe2125176aa86d3a6c9d0a3a9a4988781ba98423514dd;
    // keccak256(
    //     "UserSubscription(address userAddress,uint8 subscriptionTier,uint256 startTime,uint256 endTime)"
    // );
    address public operator;
    AggregatorV3Interface internal priceFeed;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    bytes32 public constant ROLE_CALLER = keccak256("ROLE_CALLER");

    address public mediator;
    address payable public feeWallet;
    bool public ambCheck;

    struct Featured {
        uint256 startTime;
        uint256 numDays;
        uint256 featureType;
        address contractAddress;
        uint256 listingId;
        uint256 auctionId;
        uint256 id;
        address featuredBy;
        uint256 price;
    }

    TokenAmounts public baseUSDTokenAmounts;
    bool public invertedAggregator;

    struct TokenAmounts {
        uint256 uploadOneAmount;
        uint256 uploadTwoAmount;
        uint256 uploadThreeAmount;
        uint256 uploadFourAmount;
        uint256 featureAmountPerDay;
        uint256 subscribeOneAmount;
        uint256 subscribeTwoAmount;
        uint256 subscribeOne90Amount;
        uint256 subscribeTwo90Amount;
        bool chainlinkFeed;
        bool stableCoin;
        uint256 tokenDecimals;
    }

    EnumerableSet.AddressSet private paymentMethods;

    enum UploadTier {
        LevelOne,
        LevelTwo,
        LevelThree,
        LevelFour
    }

    enum SubscriptionDuration {
        Duration1,
        Duration2
    }

    // amount required for fees
    mapping(address => TokenAmounts) public paymentMethodAmounts;

    mapping(address => MediaEyeOrders.UserSubscription) public subscriptions;

    event UploadPaid(
        uint256 uploadId,
        UploadTier uploadTier,
        address userAddress,
        uint256 price
    );

    event FeaturePaid(
        address[] tokenAddresses,
        uint256[] tokenIds,
        Featured featured,
        uint256 startTime,
        uint256 endTime,
        address purchaser
    );

    event SubscriptionPaid(MediaEyeOrders.UserSubscription userSubscription);

    event SubscriptionByBridge(
        MediaEyeOrders.UserSubscription userSubscription
    );

    event SubscriptionByAdmin(MediaEyeOrders.UserSubscription userSubscription);

    event TokenAmountsChanged(address paymentMethod, TokenAmounts tokenAmounts);

    event PaymentAdded(address paymentMethod, TokenAmounts tokenAmounts);

    event PaymentRemoved(address paymentMethod);

    event FeeWalletChanged(address newFeeWallet);

    /********************** MODIFIERS ********************************/

    // only admin or owner
    modifier onlyAdmin() {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeFee: Sender is not an admin."
        );
        _;
    }

    // only owner
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "MediaEyeFee: Sender is not an owner."
        );
        _;
    }

    // only from mediator
    modifier onlyMediator() {
        require(
            msg.sender == mediator,
            "MediaEyeFee: GovernanceReceiverMediator::executeTransaction: Call must come from bridge."
        );
        _;
    }

    /**
     * @dev Stores and sets up the owners and admins, setting up feewallet, payment methods and payments. Stores initial feature details.
     *
     * Params:
     * _owner: the address of the owner
     * _admins: addresses of the admins
     * _operator: address of the subscription admin to verify signature
     * _feeWallet: address to withdraw fees to
     * _paymentMethods: initial payment methods to accept
     * _initialTokenAmounts: amounts for each fee for each payment method
     * _baseUSDTokenAmounts: price in usd for each category
     * _priceFeedAggregator: the address of the price feed aggregator
     * _invertedAggregator: whether the aggregator is inverted
     */
    constructor(
        bool _ambCheck,
        address _owner,
        address[] memory _admins,
        address _operator,
        address payable _feeWallet,
        address[] memory _paymentMethods,
        TokenAmounts[] memory _initialTokenAmounts,
        TokenAmounts memory _baseUSDTokenAmounts,
        address _priceFeedAggregator,
        bool _invertedAggregator
    ) {
        require(
            _initialTokenAmounts.length == _paymentMethods.length,
            "MediaEyeFee: There must be amounts for each payment method."
        );

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("MediaEyeFee"),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setRoleAdmin(ROLE_CALLER, ROLE_ADMIN);

        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }

        feeWallet = _feeWallet;

        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            paymentMethods.add(_paymentMethods[i]);
            paymentMethodAmounts[_paymentMethods[i]] = _initialTokenAmounts[i];
        }

        ambCheck = _ambCheck;

        baseUSDTokenAmounts = _baseUSDTokenAmounts;
        priceFeed = AggregatorV3Interface(_priceFeedAggregator);
        invertedAggregator = _invertedAggregator;
        operator = _operator;
    }

    /********************** Price Feed ********************************/

    function getRoundData() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();

        return price.toUint256();
    }

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) public view returns (uint256) {
        require(_baseDecimals > 0 && _baseDecimals <= 18, "Invalid _decimals");
        require(
            _queryDecimals > 0 && _queryDecimals <= 18,
            "Invalid _decimals"
        );

        uint256 roundData = getRoundData();
        uint256 roundDataDecimals = priceFeed.decimals();
        uint256 query = 0;

        if (_convertToNative) {
            if (_invertedAggregator) {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            } else {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            }
        } else {
            if (_invertedAggregator) {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            } else {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            }
        }

        if (_baseDecimals > _queryDecimals) {
            uint256 decimals = _baseDecimals - _queryDecimals;
            query = query / (10**decimals);
        } else if (_baseDecimals < _queryDecimals) {
            uint256 decimals = _queryDecimals - _baseDecimals;
            query = query * (10**decimals);
        }
        return query;
    }

    /********************** Get methods ********************************/

    // Get number of payment methods accepted
    function getNumPaymentMethods() external view returns (uint256) {
        return paymentMethods.length();
    }

    // Get user subscription
    function getUserSubscription(address _account)
        external
        view
        returns (MediaEyeOrders.UserSubscription memory)
    {
        return subscriptions[_account];
    }

    // Returns true if is accepted payment method
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool)
    {
        return paymentMethods.contains(_paymentMethod);
    }

    /********************** Owner update methods ********************************/

    /**
     * @dev Update fee wallet
     *
     * Params:
     * _newFeeWallet: new fee wallet
     */
    function updateFeeWallet(address payable _newFeeWallet) external onlyOwner {
        feeWallet = _newFeeWallet;
        emit FeeWalletChanged(_newFeeWallet);
    }

    /********************** Admin update methods ********************************/

    /**
     * @dev Update mediator address
     *
     * Params:
     * _mediator: new mediator address
     */
    function setMediator(address _mediator) external onlyAdmin {
        mediator = _mediator;
    }

    /**
     * @dev Update subscription typehash
     *
     * Params:
     * _typeHash: new typehash
     */
    function setSubscriptionHash(bytes32 _typeHash) external onlyAdmin {
        SUBSCRIPTION_SIGNATURE_TYPEHASH = _typeHash;
    }

    /**
     * @dev Update price feed aggregator address
     *
     * Params:
     * _aggregator: new aggregator address
     * _inverted: whether the aggregator is inverted
     */
    function setPriceFeedAggregator(address _aggregator, bool _inverted)
        external
        onlyAdmin
    {
        priceFeed = AggregatorV3Interface(_aggregator);
        invertedAggregator = _inverted;
    }

    /**
     * @dev Update mediator address
     *
     * Params:
     * _baseUSDTokenAmounts: price in usd for each category
     */
    function setBaseUSDTokenAmounts(TokenAmounts memory _baseUSDTokenAmounts)
        external
        onlyAdmin
    {
        baseUSDTokenAmounts = _baseUSDTokenAmounts;
    }

    /**
     * @dev Update subscriptionadmin address
     *
     * Params:
     * _address: new subscriptionadmin address
     */
    function setOperatorAddress(address _address) external onlyAdmin {
        operator = _address;
    }

    /**
     * @dev Add single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to add
     */
    function addPaymentMethod(
        TokenAmounts memory _newTokenAmount,
        address _paymentMethod
    ) external onlyAdmin {
        require(
            !paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method is already accepted."
        );
        paymentMethods.add(_paymentMethod);
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit PaymentAdded(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Removes single payment method
     *
     * Params:
     * _paymentMethod: the payment method to remove
     */
    function removePaymentMethod(address _paymentMethod) external onlyAdmin {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );
        paymentMethods.remove(_paymentMethod);
        delete paymentMethodAmounts[_paymentMethod];
        emit PaymentRemoved(_paymentMethod);
    }

    /**
     * @dev Update Price Amounts for single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to change amountf or
     */
    function updateSingleTokenAmount(
        TokenAmounts memory _newTokenAmount,
        address _paymentMethod
    ) external onlyAdmin {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit TokenAmountsChanged(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Update Price Amounts for multiple payment method
     *
     * Params:
     * _newTokenAmounts: new token amounts for multiple payment method
     * _paymentMethods: order of the tokenAmounts to set
     */
    function updateMultipleTokenAmounts(
        TokenAmounts[] memory _newTokenAmounts,
        address[] memory _paymentMethods
    ) external onlyAdmin {
        require(
            _newTokenAmounts.length == _paymentMethods.length,
            "MediaEyeFee: There must be amounts for each payment method"
        );
        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            require(
                paymentMethods.contains(_paymentMethods[i]),
                "MediaEyeFee: One of the payment method does not exist."
            );
            paymentMethodAmounts[_paymentMethods[i]] = _newTokenAmounts[i];
            emit TokenAmountsChanged(_paymentMethods[i], _newTokenAmounts[i]);
        }
    }

    function subscribeByAdmin(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 tier
    ) external onlyAdmin {
        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[account];
        newUserSubscription.userAddress = account;
        if (tier == 0) {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelOne;
        } else {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelTwo;
        }
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        emit SubscriptionByAdmin(newUserSubscription);
    }

    /**
     * @dev Update amb bool
     *
     * Params:
     * _ambBool: boolean to set amb
     */
    function setAmb(bool _ambBool) external onlyAdmin {
        ambCheck = _ambBool;
    }

    /********************** Check Subscription ********************************/
    function checkUserSubscription(address _user)
        external
        view
        returns (uint256)
    {
        MediaEyeOrders.UserSubscription memory userSubscription = subscriptions[
            _user
        ];
        if (
            userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelOne &&
            userSubscription.endTime > block.timestamp &&
            userSubscription.startTime < block.timestamp
        ) {
            return 1;
        } else if (
            userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelTwo &&
            userSubscription.endTime > block.timestamp &&
            userSubscription.startTime < block.timestamp
        ) {
            return 2;
        } else {
            return 0;
        }
    }

    function checkUserSubscriptionBySig(
        MediaEyeOrders.UserSubscription memory _userSubscription,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (uint256) {
        // verify signature
        bytes32 structHash = keccak256(
            abi.encode(
                SUBSCRIPTION_SIGNATURE_TYPEHASH,
                _userSubscription.userAddress,
                _userSubscription.subscriptionTier,
                _userSubscription.startTime,
                _userSubscription.endTime
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
        );
        if (ecrecover(digest, v, r, s) != operator) {
            return 0;
        }
        if (
            _userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelOne &&
            _userSubscription.endTime > block.timestamp &&
            _userSubscription.startTime < block.timestamp
        ) {
            return 1;
        } else if (
            _userSubscription.subscriptionTier ==
            MediaEyeOrders.SubscriptionTier.LevelTwo &&
            _userSubscription.endTime > block.timestamp &&
            _userSubscription.startTime < block.timestamp
        ) {
            return 2;
        } else {
            return 0;
        }
    }

    /********************** PAY ********************************/

    /**
     * @dev user pays upload fees
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _uploadTier: tier of the uploaded content, based on size, 20/50/100/200 mb
     * _uploadId: id of upload
     */
    function payUploadFee(
        address _paymentMethod,
        UploadTier _uploadTier,
        uint256 _uploadId
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );
        uint256 price = 0;
        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];
        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            if (_uploadTier == UploadTier.LevelOne) {
                price = baseUSDTokenAmounts.uploadOneAmount;
            } else if (_uploadTier == UploadTier.LevelTwo) {
                price = baseUSDTokenAmounts.uploadTwoAmount;
            } else if (_uploadTier == UploadTier.LevelThree) {
                price = baseUSDTokenAmounts.uploadThreeAmount;
            } else if (_uploadTier == UploadTier.LevelFour) {
                price = baseUSDTokenAmounts.uploadFourAmount;
            }
            // get price from chainlink feed
            price = convertPrice(
                price,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = msg.sender.call{value: msg.value - price}(
                    ""
                );
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            if (_uploadTier == UploadTier.LevelOne) {
                price = baseUSDTokenAmounts.uploadOneAmount;
            } else if (_uploadTier == UploadTier.LevelTwo) {
                price = baseUSDTokenAmounts.uploadTwoAmount;
            } else if (_uploadTier == UploadTier.LevelThree) {
                price = baseUSDTokenAmounts.uploadThreeAmount;
            } else if (_uploadTier == UploadTier.LevelFour) {
                price = baseUSDTokenAmounts.uploadFourAmount;
            }
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        } else {
            if (_uploadTier == UploadTier.LevelOne) {
                price = tokenAmount.uploadOneAmount;
            } else if (_uploadTier == UploadTier.LevelTwo) {
                price = tokenAmount.uploadTwoAmount;
            } else if (_uploadTier == UploadTier.LevelThree) {
                price = tokenAmount.uploadThreeAmount;
            } else if (_uploadTier == UploadTier.LevelFour) {
                price = tokenAmount.uploadFourAmount;
            }
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        }
        emit UploadPaid(_uploadId, _uploadTier, msg.sender, price);
    }

    /**
     * @dev user pays feature fees
     * user must be trying to feature within a certain time before the feature start time
     * there can only be a set number of features for each category
     * the same nft can only be featured once every 30 day period by a user
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _category: the category to feature into
     * _tokenAddress: address of the token to feature
     * _tokenId: id of the token to feature
     * _startTime: proposed start time, must be a multiple of the base Start blocktime
     */
    function payFeatureFee(
        address _paymentMethod,
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        Featured memory _featured
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );

        require(
            _featured.startTime == 0 || _featured.startTime >= block.timestamp,
            "MediaEyeFee: Can only feature within possible time frame."
        );

        require(
            _featured.numDays > 0,
            "MediaEyeFee: Can only feature for a positive number of days."
        );

        uint256 price = 0;
        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];
        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            // get price from chainlink feed
            price = convertPrice(
                baseUSDTokenAmounts.featureAmountPerDay * _featured.numDays,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = _featured.featuredBy.call{
                    value: msg.value - price
                }("");
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            price = baseUSDTokenAmounts.featureAmountPerDay * _featured.numDays;
            require(
                price == _featured.price,
                "MediaEyeFee: Incorrect transaction value."
            );
            if (hasRole(ROLE_CALLER, msg.sender)) {
                IERC20(_paymentMethod).transfer(feeWallet, price);
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        } else {
            price = tokenAmount.featureAmountPerDay * _featured.numDays;
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                require(
                    price == _featured.price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                if (hasRole(ROLE_CALLER, msg.sender)) {
                    IERC20(_paymentMethod).transfer(feeWallet, price);
                } else {
                    IERC20(_paymentMethod).transferFrom(
                        msg.sender,
                        feeWallet,
                        price
                    );
                }
            }
        }

        uint256 startTime = _featured.startTime;
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        uint256 endTime = startTime + (_featured.numDays * 1 days);

        emit FeaturePaid(
            _tokenAddresses,
            _tokenIds,
            _featured,
            startTime,
            endTime,
            _featured.featuredBy
        );
    }

    /**
     * @dev user pays subscription fees for tier one
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _duration: 30 days or 90 days
     */
    function paySubscriptionLevelOneFee(
        address _paymentMethod,
        SubscriptionDuration _duration
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );

        require(
            _duration == SubscriptionDuration.Duration1 ||
                _duration == SubscriptionDuration.Duration2,
            "MediaEyeFee: Duration must match."
        );

        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = 0;
        uint256 price = 0;

        if (_duration == SubscriptionDuration.Duration1) {
            endTimestamp = block.timestamp + 30 days;
        } else if (_duration == SubscriptionDuration.Duration2) {
            endTimestamp = block.timestamp + 90 days;
        }
        if (subscriptions[msg.sender].endTime > block.timestamp) {
            require(
                subscriptions[msg.sender].subscriptionTier ==
                    MediaEyeOrders.SubscriptionTier.LevelOne,
                "MediaEyeFee: User is subscribed already to a higher tier."
            );
            startTimestamp = subscriptions[msg.sender].startTime;
            if (_duration == SubscriptionDuration.Duration1) {
                endTimestamp =
                    subscriptions[msg.sender].endTime +
                    43800 minutes;
            } else if (_duration == SubscriptionDuration.Duration2) {
                endTimestamp =
                    subscriptions[msg.sender].endTime +
                    131400 minutes;
            }
        }

        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];
        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeOneAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeOne90Amount;
            }
            // get price from chainlink feed
            price = convertPrice(
                price,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = msg.sender.call{value: msg.value - price}(
                    ""
                );
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeOneAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeOne90Amount;
            }
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        } else {
            if (_duration == SubscriptionDuration.Duration1) {
                price = tokenAmount.subscribeOneAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = tokenAmount.subscribeOne90Amount;
            }
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        }

        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[msg.sender];
        newUserSubscription.userAddress = msg.sender;
        newUserSubscription.subscriptionTier = MediaEyeOrders
            .SubscriptionTier
            .LevelOne;
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        if (ambCheck) {
            IMediaEyeSubscriptionMediator(mediator).subscribeByMediator(
                msg.sender,
                startTimestamp,
                endTimestamp,
                false
            );
        }

        emit SubscriptionPaid(newUserSubscription);
    }

    //call to subscribe via mediator
    function subscribeByBridge(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlyMediator {
        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[account];
        newUserSubscription.userAddress = account;
        if (tier == false) {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelOne;
        } else {
            newUserSubscription.subscriptionTier = MediaEyeOrders
                .SubscriptionTier
                .LevelTwo;
        }
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        emit SubscriptionByBridge(newUserSubscription);
    }

    /**
     * @dev user pays subscription fees for tier two
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _duration: 30 days or 90 days
     */
    function paySubscriptionLevelTwoFee(
        address _paymentMethod,
        SubscriptionDuration _duration
    ) external payable {
        require(
            paymentMethods.contains(_paymentMethod),
            "MediaEyeFee: Payment method does not exist."
        );

        require(
            _duration == SubscriptionDuration.Duration1 ||
                _duration == SubscriptionDuration.Duration2,
            "MediaEyeFee: Duration must match."
        );

        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = 0;
        uint256 price = 0;

        if (_duration == SubscriptionDuration.Duration1) {
            endTimestamp = block.timestamp + 43800 minutes;
        } else if (_duration == SubscriptionDuration.Duration2) {
            endTimestamp = block.timestamp + 131400 minutes;
        }

        if (subscriptions[msg.sender].endTime > block.timestamp) {
            if (
                subscriptions[msg.sender].subscriptionTier ==
                MediaEyeOrders.SubscriptionTier.LevelTwo
            ) {
                startTimestamp = subscriptions[msg.sender].startTime;
                if (_duration == SubscriptionDuration.Duration1) {
                    endTimestamp =
                        subscriptions[msg.sender].endTime +
                        43800 minutes;
                } else if (_duration == SubscriptionDuration.Duration2) {
                    endTimestamp =
                        subscriptions[msg.sender].endTime +
                        131400 minutes;
                }
            }
        }
        TokenAmounts memory tokenAmount = paymentMethodAmounts[_paymentMethod];

        if (tokenAmount.chainlinkFeed && _paymentMethod == address(0)) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeTwoAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeTwo90Amount;
            }
            // get price from chainlink feed
            price = convertPrice(
                price,
                baseUSDTokenAmounts.tokenDecimals,
                18,
                invertedAggregator,
                true
            );
            require(
                msg.value >= price,
                "MediaEyeFee: Not enough native tokens to pay fee."
            );
            (bool priceSent, ) = feeWallet.call{value: price}("");
            require(priceSent, "transfer fail.");
            if (msg.value > price) {
                (bool diffSent, ) = msg.sender.call{value: msg.value - price}(
                    ""
                );
                require(diffSent, "return transfer fail.");
            }
        } else if (tokenAmount.stableCoin) {
            if (_duration == SubscriptionDuration.Duration1) {
                price = baseUSDTokenAmounts.subscribeTwoAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = baseUSDTokenAmounts.subscribeTwo90Amount;
            }
            IERC20(_paymentMethod).transferFrom(msg.sender, feeWallet, price);
        } else {
            if (_duration == SubscriptionDuration.Duration1) {
                price = tokenAmount.subscribeTwoAmount;
            } else if (_duration == SubscriptionDuration.Duration2) {
                price = tokenAmount.subscribeTwo90Amount;
            }
            if (_paymentMethod == address(0)) {
                require(
                    msg.value == price,
                    "MediaEyeFee: Incorrect transaction value."
                );
                (bool priceSent, ) = feeWallet.call{value: price}("");
                require(priceSent, "transfer fail.");
            } else {
                IERC20(_paymentMethod).transferFrom(
                    msg.sender,
                    feeWallet,
                    price
                );
            }
        }

        MediaEyeOrders.UserSubscription
            storage newUserSubscription = subscriptions[msg.sender];
        newUserSubscription.userAddress = msg.sender;
        newUserSubscription.subscriptionTier = MediaEyeOrders
            .SubscriptionTier
            .LevelTwo;
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        if (ambCheck) {
            IMediaEyeSubscriptionMediator(mediator).subscribeByMediator(
                msg.sender,
                startTimestamp,
                endTimestamp,
                true
            );
        }

        emit SubscriptionPaid(newUserSubscription);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }
}


// File contracts/MediaEyeFeeVault.sol

pragma solidity ^0.8.0;



interface NativeToken {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}

contract MediaEyeFeeVault is AccessControl {
    using SafeERC20 for IERC20;
    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    NativeToken public nativeToken;
    address public eyeAddress;
    address public cohortAddress;
    address payable public topUsersDistributionAddress;
    address payable public feeWallet;
    // basis points out of 10000 (10000 = 100%)
    uint256 public constant feeBasisPoint = 5000;
    uint256 public cohortFeeBasisPoint = 4000;
    uint256 public topUsersFeeBasisPoint = 1000;

    event FeeWalletChanged(address newFeeWallet);
    event CohortAddressUpdated(address newCohortAddress);
    event EyeAddressUpdated(address newEyeAddress);
    event TopUsersDistributionAddressUpdated(
        address newTopUsersDistributionAddress
    );
    event BasisUpdated(
        uint256 newCohortBasisPoint,
        uint256 newTopUsersBasisPoint
    );

    /********************** MODIFIERS ********************************/

    // only admin or owner
    modifier onlyAdmin() {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "MediaEyeFeeVault: Sender is not an admin."
        );
        _;
    }

    // only owner
    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "MediaEyeFeeVault: Sender is not an owner."
        );
        _;
    }

    /**
     * @dev Stores and sets up the owners and admins, sets up initial regular payment methods.
     *
     * Params:
     * _owner: the address of the owner
     * _admins: addresses of the admins
     * _paymentMethods: initial payment methods to accept
     * _cohortAddress: address of the cohort contract
     * _feeWallet: address of the fee wallet
     * _nativeTokenAddress: address of the native token
     * _topUsersDistribution: address of top users distribution address
     */
    constructor(
        address _owner,
        address[] memory _admins,
        address _cohortAddress,
        address payable _feeWallet,
        address _nativeTokenAddress,
        address payable _topUsersDistribution,
        address _eyeAddress
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);

        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }

        cohortAddress = _cohortAddress;
        topUsersDistributionAddress = _topUsersDistribution;
        feeWallet = _feeWallet;
        nativeToken = NativeToken(_nativeTokenAddress);
        eyeAddress = _eyeAddress;
    }

    receive() external payable {}

    /********************** Owner update methods ********************************/

    /**
     * @dev Update fee wallet
     *
     * Params:
     * _newFeeWallet: new fee wallet
     */
    function updateFeeWallet(address payable _newFeeWallet) external onlyOwner {
        feeWallet = _newFeeWallet;
        emit FeeWalletChanged(_newFeeWallet);
    }

    /********************** Admin update methods ********************************/

    /**
     * @dev Updates cohort and top user basis points
     *
     * Params:
     * _cohort: new basis point for cohorts
     * _topUsers: new basis point for top users
     */
    function updateBasisPoints(uint256 _cohort, uint256 _topUsers)
        external
        onlyAdmin
    {
        require(
            _cohort + _topUsers + feeBasisPoint == 10000,
            "MediaEyeFeeVault: Basis points must add up to 100%."
        );
        cohortFeeBasisPoint = _cohort;
        topUsersFeeBasisPoint = _topUsers;
        emit BasisUpdated(_cohort, _topUsers);
    }

    /**
     * @dev Updates cohort contract address
     *
     * Params:
     * _cohort: new cohort address
     */
    function updateCohortAddress(address _cohort) external onlyAdmin {
        cohortAddress = _cohort;
        emit CohortAddressUpdated(_cohort);
    }

    /**
     * @dev Updates eye contract address
     *
     * Params:
     * _eye: new eye address
     */
    function updateEyeAddress(address _eye) external onlyAdmin {
        eyeAddress = _eye;
        emit EyeAddressUpdated(_eye);
    }

    /**
     * @dev Updates top users distribution address
     *
     * Params:
     * _topUsers: new cohort address
     */
    function updateTopUsersDistributionAddress(address payable _topUsers)
        external
        onlyAdmin
    {
        topUsersDistributionAddress = _topUsers;
        emit TopUsersDistributionAddressUpdated(_topUsers);
    }

    /********************** VAULT ********************************/
    /**
     * @dev Withdraw fees from vault to wallet, cohort, and top users distribution
     *
     * 50% of fees admin can withdraw
     * 50% of fees goes to cohort and top users distribution
     * all 50% eye tokens are sent to cohort
     * initial: 20% of the 50% goes to the top users distribution, 80% to cohort for all other tokens
     * Params:
     * _paymentMethods: array of payment methods
     */
    function sendFees(address[] memory _paymentMethods)
        external
        payable
        onlyAdmin
    {
        require(
            _paymentMethods.length > 0,
            "MediaEyeFeeVault: No payment methods provided."
        );

        uint256 payoutToAdmin = 0;
        uint256 payoutToCohort = 0;
        uint256 payoutToTopUsers = 0;

        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            if (_paymentMethods[i] == address(0) && address(this).balance > 0) {
                payoutToAdmin = (address(this).balance * feeBasisPoint) / 10000;
                payoutToCohort =
                    (address(this).balance * cohortFeeBasisPoint) /
                    10000;
                payoutToTopUsers = (address(this).balance -
                    payoutToAdmin -
                    payoutToCohort);

                // send fees
                (bool adminSent, ) = feeWallet.call{value: payoutToAdmin}("");
                require(adminSent, "native admin.");

                // swap to wrapped token and send to cohort
                nativeToken.deposit{value: payoutToCohort}();
                nativeToken.transfer(cohortAddress, payoutToCohort);

                // wrap to wrapped token and send to top users
                nativeToken.deposit{value: payoutToTopUsers}();
                nativeToken.transfer(
                    topUsersDistributionAddress,
                    payoutToTopUsers
                );
            } else if (
                _paymentMethods[i] == eyeAddress &&
                contractTokenBalance(_paymentMethods[i]) > 0
            ) {
                payoutToAdmin =
                    (contractTokenBalance(_paymentMethods[i]) * feeBasisPoint) /
                    10000;
                payoutToCohort = (contractTokenBalance(_paymentMethods[i]) -
                    payoutToAdmin);
              
                // send fees
                IERC20(_paymentMethods[i]).transfer(feeWallet, payoutToAdmin);
                IERC20(_paymentMethods[i]).transfer(
                    cohortAddress,
                    payoutToCohort
                );
            } else if (
                _paymentMethods[i] != address(0) &&
                contractTokenBalance(_paymentMethods[i]) > 0
            ) {
                payoutToAdmin =
                    (contractTokenBalance(_paymentMethods[i]) * feeBasisPoint) /
                    10000;
                payoutToCohort =
                    (contractTokenBalance(_paymentMethods[i]) *
                        cohortFeeBasisPoint) /
                    10000;
                payoutToTopUsers = (contractTokenBalance(_paymentMethods[i]) -
                    payoutToAdmin -
                    payoutToCohort);

                // send fees
                IERC20(_paymentMethods[i]).transfer(feeWallet, payoutToAdmin);
                IERC20(_paymentMethods[i]).transfer(
                    cohortAddress,
                    payoutToCohort
                );
                IERC20(_paymentMethods[i]).transfer(
                    topUsersDistributionAddress,
                    payoutToTopUsers
                );
            }
        }
    }

    function contractTokenBalance(address _token)
        public
        view
        returns (uint256)
    {
        return IERC20(_token).balanceOf(address(this));
    }

    function contractNativeBalance() external view returns (uint256) {
        return address(this).balance;
    }
}


// File contracts/interfaces/IMinter.sol

pragma solidity ^0.8.0;

interface IMinter {
    function getCreator(uint256 _tokenId)
        external
        view
        returns (address);
}


// File contracts/MediaEyeMarketplaceAuctions.sol

pragma solidity ^0.8.0;














contract MediaEyeMarketplaceAuction is
    ERC721Holder,
    ERC1155Holder,
    AccessControl,
    ReentrancyGuard
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using MediaEyeOrders for MediaEyeOrders.NftTokenType;
    using MediaEyeOrders for MediaEyeOrders.Auction;
    using MediaEyeOrders for MediaEyeOrders.Royalty;
    using MediaEyeOrders for MediaEyeOrders.Split;
    using MediaEyeOrders for MediaEyeOrders.AuctionPayment;
    using MediaEyeOrders for MediaEyeOrders.AuctionSignature;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    using MediaEyeOrders for MediaEyeOrders.Nft;
    using MediaEyeOrders for MediaEyeOrders.PaymentChainlink;
    using MediaEyeOrders for MediaEyeOrders.Feature;
    using MediaEyeOrders for MediaEyeOrders.Chainlink;
    using MediaEyeOrders for MediaEyeOrders.AuctionInput;
    using MediaEyeOrders for MediaEyeOrders.AuctionConstructor;
    using MediaEyeOrders for MediaEyeOrders.AuctionAdmin;

    Counters.Counter private _auctionIds;

    MediaEyeOrders.Chainlink internal chainlink;

    // auctionId => chainlinkQuoteAddress
    mapping(uint256 => MediaEyeOrders.PaymentChainlink)
        public saleChainlinkAddresses;

    bytes32 internal immutable _DOMAIN_SEPARATOR;
    bytes32 internal constant AUCTION_SIGNATURE_TYPEHASH =
        0x7c2b28064b716ef2c60aca1167ff09b3fc82e38d55d4cbc1e93ae42c3cfcfd7a;
    // keccak256(
    //     "AuctionSignature(uint256 auctionId,uint256 price,address bidder,address paymentMethod)"
    // );

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address payable public treasuryWallet;
    IMarketplaceInfo public mediaEyeMarketplaceInfo;
    address public mediaEyeCharities;
    address public feeContract;
    uint256 public basisPointFee;
    bool public subscriptionCheckActive;

    // auctionId => paymentMethod = priceAmount
    mapping(uint256 => mapping(address => uint256))
        public auctionInitialAmounts;
    mapping(uint256 => mapping(address => uint256))
        public auctionBuyItNowAmounts;

    mapping(uint256 => MediaEyeOrders.Auction) public auctions;
    EnumerableSet.UintSet private auctionIds;

    event AuctionCreated(
        MediaEyeOrders.Auction auction,
        MediaEyeOrders.AuctionPayment[] auctionPayments,
        MediaEyeOrders.PaymentChainlink chainlinkPayment,
        string data
    );
    event AuctionFinished(uint256 auctionId);
    event AuctionCancelled(uint256 auctionId);
    event AuctionUpdated(
        uint256 auctionId,
        MediaEyeOrders.AuctionPayment[] auctionPayments,
        MediaEyeOrders.PaymentChainlink chainlinkPayment
    );
    event AuctionClaimed(
        uint256 auctionId,
        address winner,
        address seller,
        uint256 price,
        address paymentMethod
    );

    /**
     * @dev Constructor
     *
     * Params:
     * _owner: address of the owner
     * _admins: addresses of initial admins
     * _treasuryWallet: address of treasury wallet
     * _basisPointFee: initial basis point fee
     * _feeContract: contract of MediaEyeFee
     * _mediaEyeMarketplaceInfo: address of info
     * _mediaEyeCharities: address of charities
     * _chainlink: chainlink info
     */
    constructor(MediaEyeOrders.AuctionConstructor memory _auctionConstructor) {
        require(_auctionConstructor._treasuryWallet != address(0));
        require(_auctionConstructor._basisPointFee <= 500);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("MediaEyeMarketplace"),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _auctionConstructor._owner);
        for (uint256 i = 0; i < _auctionConstructor._admins.length; i++) {
            _setupRole(ROLE_ADMIN, _auctionConstructor._admins[i]);
        }

        treasuryWallet = _auctionConstructor._treasuryWallet;
        feeContract = _auctionConstructor._feeContract;

        basisPointFee = _auctionConstructor._basisPointFee;
        mediaEyeMarketplaceInfo = IMarketplaceInfo(
            _auctionConstructor._mediaEyeMarketplaceInfo
        );
        mediaEyeCharities = _auctionConstructor._mediaEyeCharities;

        chainlink = _auctionConstructor._chainlink;
        subscriptionCheckActive = true;
    }

    /********************** Owner Functions ********************************/
    /**
     * @dev Update constants/contracts.
     *
     */

    function updateConstantsByAdmin(
        MediaEyeOrders.AuctionAdmin memory _auctionAdmin
    ) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        chainlink = _auctionAdmin._chainlink;

        require(_auctionAdmin._basisPointFee <= 500, "fee");
        basisPointFee = _auctionAdmin._basisPointFee;
        subscriptionCheckActive = _auctionAdmin._check;
        if (_auctionAdmin._newInfoContract != address(0)) {
            mediaEyeMarketplaceInfo = IMarketplaceInfo(
                _auctionAdmin._newInfoContract
            );
        }
        if (_auctionAdmin._newTreasuryWallet != address(0)) {
            treasuryWallet = _auctionAdmin._newTreasuryWallet;
        }
        if (_auctionAdmin._newFeeContract != address(0)) {
            feeContract = _auctionAdmin._newFeeContract;
        }
        if (_auctionAdmin._newCharityContract != address(0)) {
            mediaEyeCharities = _auctionAdmin._newCharityContract;
        }
    }

    /********************** Get Functions ********************************/

    // Get number of auctions
    function getNumAuctions() external view returns (uint256) {
        return auctionIds.length();
    }

    /**
     * @dev Get auction ID at index
     *
     * Params:
     * index: index of ID
     */
    function getAuctionIds(uint256 index) external view returns (uint256) {
        return auctionIds.at(index);
    }

    /**
     * @dev Get auction correlated to index
     *
     * Params:
     * index: index of ID
     */
    function getAuctionAtIndex(uint256 index)
        external
        view
        returns (MediaEyeOrders.Auction memory)
    {
        return auctions[auctionIds.at(index)];
    }

    /********************MARKETPLACE***********************/

    /**
     * @dev Create a new auction
     *
     * Params:
     * _auctionInput.nfts: nfts to auction
     * _auctionInput.auctionPayments: payment methods to accept and initial price/ buy it now (optional)
     * _auctionInput.chainlinkPayment: payment methods to accept pricefeeds (optional)
     * _auctionInput.setRoyalty: if we set royalty (creator only)
     * _auctionInput.royalty: royalty amount to original seller
     * _auctionInput.split: how to split the revenue if any
     * _auctionInput.auctionTime: auction start and end time
     * _auctionInput.subscriptionSignature: subscription signature (optional)
     * _auctionInput.feature: feature (optional)
     */

    function startAuction(MediaEyeOrders.AuctionInput memory _auctionInput)
        external
        payable
        nonReentrant
    {
        require(
            _auctionInput.auctionPayments.length > 0 &&
                _auctionInput.nfts.length > 0,
            "length"
        );
        require(
            _auctionInput.auctionTime.endTime >
                _auctionInput.auctionTime.startTime &&
                _auctionInput.auctionTime.endTime > block.timestamp,
            "time"
        );
        require(
            _auctionInput.split.splitBasisPoint +
                _auctionInput.split.charityBasisPoint <=
                10000,
            "over"
        );

        if (_auctionInput.nfts.length > 1 && subscriptionCheckActive) {
            uint256 tier = 0;
            if (_auctionInput.subscriptionSignature.isValid) {
                require(
                    msg.sender ==
                        _auctionInput
                            .subscriptionSignature
                            .userSubscription
                            .userAddress,
                    "sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _auctionInput.subscriptionSignature.userSubscription,
                        _auctionInput.subscriptionSignature.v,
                        _auctionInput.subscriptionSignature.r,
                        _auctionInput.subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    msg.sender
                );
            }
            require(tier > 0, "subscription");
        }

        uint256 auctionId = _auctionIds.current();

        // save payment methods
        for (uint256 i = 0; i < _auctionInput.auctionPayments.length; i++) {
            require(
                mediaEyeMarketplaceInfo.isPaymentMethod(
                    _auctionInput.auctionPayments[i].paymentMethod
                ),
                "payment"
            );
            if (_auctionInput.auctionPayments[i].paymentMethod == address(0)) {
                require(
                    _auctionInput.auctionPayments[i].buyItNowPrice > 0 ||
                        _auctionInput.auctionPayments[i].paymentMethod ==
                        _auctionInput.chainlinkPayment.quoteAddress,
                    "invalid"
                );
                auctionBuyItNowAmounts[auctionId][
                    _auctionInput.auctionPayments[i].paymentMethod
                ] = _auctionInput.auctionPayments[i].buyItNowPrice;
            } else {
                require(
                    _auctionInput.auctionPayments[i].initialPrice > 0 ||
                        _auctionInput.auctionPayments[i].paymentMethod ==
                        _auctionInput.chainlinkPayment.quoteAddress,
                    "price"
                );
                auctionInitialAmounts[auctionId][
                    _auctionInput.auctionPayments[i].paymentMethod
                ] = _auctionInput.auctionPayments[i].initialPrice;

                if (_auctionInput.auctionPayments[i].buyItNowPrice > 0) {
                    auctionBuyItNowAmounts[auctionId][
                        _auctionInput.auctionPayments[i].paymentMethod
                    ] = _auctionInput.auctionPayments[i].buyItNowPrice;
                }
            }
        }

        // save chainlink payment
        if (_auctionInput.chainlinkPayment.isValid) {
            // check if the opposite address is a payment method
            if (
                _auctionInput.chainlinkPayment.quoteAddress ==
                chainlink.nativeAddress
            ) {
                require(
                    auctionBuyItNowAmounts[auctionId][chainlink.tokenAddress] >
                        0,
                    "payment"
                );
            } else {
                require(
                    _auctionInput.chainlinkPayment.quoteAddress ==
                        chainlink.tokenAddress,
                    "impossible"
                );
                require(
                    auctionBuyItNowAmounts[auctionId][chainlink.nativeAddress] >
                        0,
                    "payment"
                );
            }
            saleChainlinkAddresses[auctionId] = _auctionInput.chainlinkPayment;
        }

        address compareRoyaltyRecipient;

        if (_auctionInput.setRoyalty == 0) {
            compareRoyaltyRecipient = mediaEyeMarketplaceInfo
                .getRoyalty(
                    _auctionInput.nfts[0].nftTokenAddress,
                    _auctionInput.nfts[0].nftTokenId
                )
                .artist;
        }

        MediaEyeOrders.Auction storage auction = auctions[auctionId];

        for (uint256 i = 0; i < _auctionInput.nfts.length; i++) {
            if (_auctionInput.setRoyalty != 0) {
                mediaEyeMarketplaceInfo.setRoyalty(
                    _auctionInput.nfts[i].nftTokenAddress,
                    _auctionInput.nfts[i].nftTokenId,
                    _auctionInput.royalty,
                    msg.sender
                );
            } else {
                // check if royalty payments are the same for all in bundle
                require(
                    _auctionInput.royalty ==
                        mediaEyeMarketplaceInfo
                            .getRoyalty(
                                _auctionInput.nfts[i].nftTokenAddress,
                                _auctionInput.nfts[i].nftTokenId
                            )
                            .royaltyBasisPoint &&
                        compareRoyaltyRecipient ==
                        mediaEyeMarketplaceInfo
                            .getRoyalty(
                                _auctionInput.nfts[i].nftTokenAddress,
                                _auctionInput.nfts[i].nftTokenId
                            )
                            .artist,
                    "royalties"
                );
            }

            // transfer
            if (
                _auctionInput.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                require(_auctionInput.nfts[i].nftNumTokens == 1, "ERC721");
                IERC721(_auctionInput.nfts[i].nftTokenAddress).safeTransferFrom(
                        msg.sender,
                        address(this),
                        _auctionInput.nfts[i].nftTokenId
                    );
            } else if (
                _auctionInput.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC1155
            ) {
                IERC1155(_auctionInput.nfts[i].nftTokenAddress)
                    .safeTransferFrom(
                        msg.sender,
                        address(this),
                        _auctionInput.nfts[i].nftTokenId,
                        _auctionInput.nfts[i].nftNumTokens,
                        ""
                    );
            }
            auction.nfts.push(_auctionInput.nfts[i]);
        }

        auction.auctionId = auctionId;
        auction.seller = msg.sender;
        auction.startTime = _auctionInput.auctionTime.startTime;
        auction.endTime = _auctionInput.auctionTime.endTime;
        auction.split = _auctionInput.split;

        if (_auctionInput.feature.feature) {
            if (_auctionInput.feature.paymentMethod != address(0)) {
                IERC20(_auctionInput.feature.paymentMethod).transferFrom(
                    msg.sender,
                    feeContract,
                    _auctionInput.feature.price
                );
            }
            ISubscriptionTier(feeContract).payFeatureFee{value: msg.value}(
                _auctionInput.feature.paymentMethod,
                _auctionInput.feature.tokenAddresses,
                _auctionInput.feature.tokenIds,
                ISubscriptionTier.Featured(
                    0,
                    _auctionInput.feature.numDays,
                    5,
                    address(0),
                    0,
                    auctionId,
                    _auctionInput.feature.id,
                    msg.sender,
                    _auctionInput.feature.price
                )
            );
        }

        auctionIds.add(auctionId);
        _auctionIds.increment();

        emit AuctionCreated(
            auctions[auctionId],
            _auctionInput.auctionPayments,
            _auctionInput.chainlinkPayment,
            _auctionInput.data
        );
    }

    /**
     * @dev Remove a auction
     *
     * Params:
     * _auctionId: auction ID
     */
    function cancelOrUpdateAuction(uint256 _auctionId) external nonReentrant {
        require(auctionIds.contains(_auctionId), "auction");
        MediaEyeOrders.Auction memory auction = auctions[_auctionId];
        require(msg.sender == auction.seller, "auctioner");

        for (uint256 i = 0; i < auction.nfts.length; i++) {
            if (
                auction.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                IERC721(auction.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    auction.seller,
                    auction.nfts[i].nftTokenId,
                    ""
                );
            } else if (
                auction.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC1155
            ) {
                IERC1155(auction.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    auction.seller,
                    auction.nfts[i].nftTokenId,
                    auction.nfts[i].nftNumTokens,
                    ""
                );
            }

            auctionIds.remove(_auctionId);
            emit AuctionCancelled(_auctionId);
        }
    }

    function auctionBuyItNow(
        uint256 _auctionId,
        MediaEyeOrders.ListingPayment memory _paymentMethod
    ) external payable nonReentrant {
        require(auctionIds.contains(_auctionId), "null");

        if (_paymentMethod.paymentMethod == address(0)) {
            require(msg.value == _paymentMethod.price, "native");
        } else {
            require(msg.value == 0, "msgvalue");
        }

        uint256 price = 0;
        uint256 convertedPrice = 0;

        // check if chainlink
        if (
            saleChainlinkAddresses[_auctionId].isValid &&
            _paymentMethod.paymentMethod ==
            saleChainlinkAddresses[_auctionId].quoteAddress
        ) {
            // calculate price
            if (_paymentMethod.paymentMethod == address(0)) {
                price = auctionBuyItNowAmounts[_auctionId][
                    chainlink.tokenAddress
                ];
                require(price > 0, "chainlink");
                convertedPrice = chainlink.priceFeed.convertPrice(
                    price,
                    chainlink.tokenDecimals,
                    chainlink.nativeDecimals,
                    chainlink.invertedAggregator,
                    true
                );
                // check tolerance
                require(msg.value >= convertedPrice, "payment");
                if (msg.value > convertedPrice) {
                    (bool diffSent, ) = msg.sender.call{
                        value: msg.value - convertedPrice
                    }("");
                    require(diffSent, "transfer");
                }
            } else {
                require(
                    _paymentMethod.paymentMethod == chainlink.tokenAddress,
                    "impossible"
                );
                price = auctionBuyItNowAmounts[_auctionId][
                    chainlink.nativeAddress
                ];
                require(price > 0, "chainlink");
                convertedPrice = chainlink.priceFeed.convertPrice(
                    price,
                    chainlink.nativeDecimals,
                    chainlink.tokenDecimals,
                    chainlink.invertedAggregator,
                    false
                );
                // check tolerance
                require(_paymentMethod.price >= convertedPrice, "payment");
            }
        } else {
            price = auctionBuyItNowAmounts[_auctionId][
                _paymentMethod.paymentMethod
            ];
            require(price > 0 && _paymentMethod.price == price, "payment");
            convertedPrice = _paymentMethod.price;
        }

        MediaEyeOrders.Auction memory auction = auctions[_auctionId];

        _sendPayments(
            auction.nfts[0].nftTokenAddress,
            auction.nfts[0].nftTokenId,
            payable(auction.seller),
            _paymentMethod.paymentMethod,
            convertedPrice,
            auction.split,
            msg.sender
        );

        for (uint256 i = 0; i < auction.nfts.length; i++) {
            if (
                !mediaEyeMarketplaceInfo.getSoldStatus(
                    auction.nfts[i].nftTokenAddress,
                    auction.nfts[i].nftTokenId
                )
            ) {
                mediaEyeMarketplaceInfo.setSoldStatus(
                    auction.nfts[i].nftTokenAddress,
                    auction.nfts[i].nftTokenId
                );
            }
            if (
                auction.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                IERC721(auction.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    auction.nfts[i].nftTokenId,
                    ""
                );
            } else {
                IERC1155(auction.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    auction.nfts[i].nftTokenId,
                    auction.nfts[i].nftNumTokens,
                    ""
                );
            }
        }
        auctionIds.remove(_auctionId);

        emit AuctionClaimed(
            _auctionId,
            msg.sender,
            auction.seller,
            convertedPrice,
            _paymentMethod.paymentMethod
        );
        emit AuctionFinished(_auctionId);
    }

    function _sendPayments(
        address _tokenAddress,
        uint256 _tokenId,
        address payable _sellerAddress,
        address paymentMethod,
        uint256 price,
        MediaEyeOrders.Split memory _split,
        address _payer
    ) internal {
        // royalties are the same for each in the bundle
        MediaEyeOrders.Royalty memory royalty = mediaEyeMarketplaceInfo
            .getRoyalty(_tokenAddress, _tokenId);
        uint256 payoutToTreasury = (price * basisPointFee) / 10000;
        uint256 payoutToCreator = 0;
        uint256 payoutToCharity = 0;
        uint256 payoutToSecondarySeller = 0;
        if (royalty.royaltyBasisPoint > 0) {
            payoutToCreator = (price * royalty.royaltyBasisPoint) / 10000;
        }

        // payout to Charity/sellers
        uint256 remainingPayout = (price *
            (10000 - basisPointFee - royalty.royaltyBasisPoint)) / 10000;
        if (_split.charityBasisPoint > 0 && _split.charity != address(0)) {
            payoutToCharity =
                (remainingPayout * _split.charityBasisPoint) /
                10000;
        }
        if (_split.splitBasisPoint > 0 && _split.recipient != address(0)) {
            payoutToSecondarySeller =
                (remainingPayout * _split.splitBasisPoint) /
                10000;
        }

        uint256 payoutToSeller = (remainingPayout *
            (10000 - _split.charityBasisPoint - _split.splitBasisPoint)) /
            10000;

        if (paymentMethod == address(0)) {
            (bool treasurySent, ) = treasuryWallet.call{
                value: payoutToTreasury
            }("");
            require(treasurySent, "treasury");
            if (payoutToCreator > 0) {
                (bool royaltySent, ) = royalty.artist.call{
                    value: payoutToCreator
                }("");
                require(royaltySent, "royalty");
            }
            if (payoutToCharity > 0) {
                (bool charitySent, ) = _split.charity.call{
                    value: payoutToCharity
                }("");
                require(charitySent, "charity");
            }
            if (payoutToSecondarySeller > 0) {
                (bool secondarySellerSent, ) = _split.recipient.call{
                    value: payoutToSecondarySeller
                }("");
                require(secondarySellerSent, "seller2");
            }
            if (payoutToSeller > 0) {
                (bool sellerSent, ) = _sellerAddress.call{
                    value: payoutToSeller
                }("");
                require(sellerSent, "seller");
            }
        } else {
            IERC20(paymentMethod).transferFrom(
                _payer,
                treasuryWallet,
                payoutToTreasury
            );
            if (payoutToCreator > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    royalty.artist,
                    payoutToCreator
                );
            }
            if (payoutToCharity > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _split.charity,
                    payoutToCharity
                );
            }
            if (payoutToSecondarySeller > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _split.recipient,
                    payoutToSecondarySeller
                );
            }
            if (payoutToSeller > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _sellerAddress,
                    payoutToSeller
                );
            }
        }
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    function sellerClaimBySig(
        MediaEyeOrders.AuctionSignature memory _auctionSignature
    ) external {
        require(auctionIds.contains(_auctionSignature.auctionId), "auction");
        require(_auctionSignature.paymentMethod != address(0), "payment");
        uint256 initialPrice = auctionInitialAmounts[
            _auctionSignature.auctionId
        ][_auctionSignature.paymentMethod];
        require(
            (_auctionSignature.price != 0 &&
                _auctionSignature.price >= initialPrice),
            "price"
        );

        require(
            msg.sender == auctions[_auctionSignature.auctionId].seller,
            "auctioner"
        );
        // Check if signature is valid

        bytes32 structHash = keccak256(
            abi.encode(
                AUCTION_SIGNATURE_TYPEHASH,
                _auctionSignature.auctionId,
                _auctionSignature.price,
                _auctionSignature.bidder,
                _auctionSignature.paymentMethod
            )
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
        );
        require(
            ecrecover(
                digest,
                _auctionSignature.v,
                _auctionSignature.r,
                _auctionSignature.s
            ) == _auctionSignature.bidder,
            "signature"
        );
        // The seller is responsible for transfering their NFT to bidder and receiving the token
        _sellClaim(_auctionSignature, auctions[_auctionSignature.auctionId]);
    }

    function _sellClaim(
        MediaEyeOrders.AuctionSignature memory _auctionSignature,
        MediaEyeOrders.Auction memory _auction
    ) internal {
        MediaEyeOrders.Royalty memory royalty = mediaEyeMarketplaceInfo
            .getRoyalty(
                _auction.nfts[0].nftTokenAddress,
                _auction.nfts[0].nftTokenId
            );

        uint256 payoutToTreasury = (_auctionSignature.price * basisPointFee) /
            10000;
        uint256 payoutToCreator = 0;
        uint256 payoutToCharity = 0;
        uint256 payoutToSecondarySeller = 0;
        if (royalty.royaltyBasisPoint > 0) {
            payoutToCreator =
                (_auctionSignature.price * royalty.royaltyBasisPoint) /
                10000;
        }

        // payout to Charity/sellers
        uint256 remainingPayout = (_auctionSignature.price *
            (10000 - basisPointFee - royalty.royaltyBasisPoint)) / 10000;
        if (
            _auction.split.charityBasisPoint > 0 &&
            _auction.split.charity != address(0)
        ) {
            payoutToCharity =
                (remainingPayout * _auction.split.charityBasisPoint) /
                10000;
        }
        if (
            _auction.split.splitBasisPoint > 0 &&
            _auction.split.recipient != address(0)
        ) {
            payoutToSecondarySeller =
                (remainingPayout * _auction.split.splitBasisPoint) /
                10000;
        }
        uint256 payoutToSeller = (remainingPayout *
            (10000 -
                _auction.split.charityBasisPoint -
                _auction.split.splitBasisPoint)) / 10000;

        IERC20(_auctionSignature.paymentMethod).transferFrom(
            _auctionSignature.bidder,
            treasuryWallet,
            payoutToTreasury
        );
        if (payoutToCreator > 0) {
            IERC20(_auctionSignature.paymentMethod).transferFrom(
                _auctionSignature.bidder,
                royalty.artist,
                payoutToCreator
            );
        }
        if (payoutToCharity > 0) {
            IERC20(_auctionSignature.paymentMethod).transferFrom(
                _auctionSignature.bidder,
                _auction.split.charity,
                payoutToCharity
            );
        }
        if (payoutToSecondarySeller > 0) {
            IERC20(_auctionSignature.paymentMethod).transferFrom(
                _auctionSignature.bidder,
                _auction.split.recipient,
                payoutToSecondarySeller
            );
        }
        if (payoutToSeller > 0) {
            IERC20(_auctionSignature.paymentMethod).transferFrom(
                _auctionSignature.bidder,
                _auction.seller,
                payoutToSeller
            );
        }

        for (uint256 i = 0; i < _auction.nfts.length; i++) {
            if (
                !mediaEyeMarketplaceInfo.getSoldStatus(
                    _auction.nfts[i].nftTokenAddress,
                    _auction.nfts[i].nftTokenId
                )
            ) {
                mediaEyeMarketplaceInfo.setSoldStatus(
                    _auction.nfts[i].nftTokenAddress,
                    _auction.nfts[i].nftTokenId
                );
            }
            if (
                _auction.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                IERC721(_auction.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    _auctionSignature.bidder,
                    _auction.nfts[i].nftTokenId,
                    ""
                );
            } else {
                IERC1155(_auction.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    _auctionSignature.bidder,
                    _auction.nfts[i].nftTokenId,
                    _auction.nfts[i].nftNumTokens,
                    ""
                );
            }
        }
        auctionIds.remove(_auctionSignature.auctionId);

        emit AuctionClaimed(
            _auctionSignature.auctionId,
            _auctionSignature.bidder,
            _auction.seller,
            _auctionSignature.price,
            _auctionSignature.paymentMethod
        );
        emit AuctionFinished(_auctionSignature.auctionId);
    }

    // override supportsInterface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File contracts/MediaEyeMarketplaceInfo.sol

pragma solidity ^0.8.0;




contract MediaEyeMarketplaceInfo is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    using MediaEyeOrders for MediaEyeOrders.Royalty;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    bytes32 public constant ROLE_SETTER = keccak256("ROLE_SETTER");

    EnumerableSet.AddressSet private paymentMethods;
    mapping(address => address) public chainlinkAggregator;

    uint256 public maxRoyaltyBasisPoint;

    mapping(address => mapping(uint256 => MediaEyeOrders.Royalty))
        public royalties;
    mapping(address => mapping(uint256 => bool)) public sold;

    event RoyaltySet(
        address nftTokenAddresses,
        uint256 nftTokenIds,
        address recipient,
        uint256 royaltyAmount
    );

    event PaymentAdded(address paymentMethod);

    event PaymentRemoved(address paymentMethod);

    modifier onlyAdmin() {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        _;
    }

    modifier onlySetter() {
        require(hasRole(ROLE_SETTER, msg.sender), "setter");
        _;
    }

    /**
     * @dev Constructor
     *
     * Params:
     * _owner: address of the owner
     * _admins: addresses of initial admins
     * _setters: addresses of marketplace setters
     * _paymentMethods: initial payment methods to accept
     * _maxRoyaltyBasisPoint: max allowed for royalty
     */
    constructor(
        address _owner,
        address[] memory _admins,
        address[] memory _setters,
        address[] memory _paymentMethods,
        uint256 _maxRoyaltyBasisPoint
    ) {
        require(_maxRoyaltyBasisPoint <= 2500, "Max royalties");

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        for (uint256 i = 0; i < _setters.length; i++) {
            _setupRole(ROLE_SETTER, _setters[i]);
        }
        _setRoleAdmin(ROLE_SETTER, ROLE_ADMIN);
        for (uint256 i = 0; i < _paymentMethods.length; i++) {
            paymentMethods.add(_paymentMethods[i]);
        }
        maxRoyaltyBasisPoint = _maxRoyaltyBasisPoint;
    }

    /**
     * @dev Add single payment method
     *
     * Params:
     * _paymentMethod: the payment method to add
     */
    function addPaymentMethod(address _paymentMethod) external onlyAdmin {
        require(!paymentMethods.contains(_paymentMethod), "Payment method");
        paymentMethods.add(_paymentMethod);
        emit PaymentAdded(_paymentMethod);
    }

    /**
     * @dev Removes single payment method
     *
     * Params:
     * _paymentMethod: the payment method to remove
     */
    function removePaymentMethod(address _paymentMethod) external onlyAdmin {
        require(paymentMethods.contains(_paymentMethod), "Payment method");
        paymentMethods.remove(_paymentMethod);
        emit PaymentRemoved(_paymentMethod);
    }

    /**
     * @dev updates the maximum royalty percentage that artists can set
     *
     * Params:
     * _basisPoint: basis point, must be less than 2500 (25%)
     */
    function updateMaxRoyaltyBasisPoint(uint256 _basisPoint)
        external
        onlyAdmin
    {
        require(_basisPoint <= 2500, "Max royalties");
        maxRoyaltyBasisPoint = _basisPoint;
    }

    /********************** Get Functions ********************************/

    // Get number of listings
    function getNumPaymentMethods() external view returns (uint256) {
        return paymentMethods.length();
    }

    // Get if is payment method
    function isPaymentMethod(address _paymentMethod)
        external
        view
        returns (bool)
    {
        return paymentMethods.contains(_paymentMethod);
    }

    /**
     * @dev gets royalties for existing erc721/1155
     *
     * Params:
     * _nftTokenAddress: address of token to list
     * _nftTokenId: id of token
     */
    function getRoyalty(address _nftTokenAddress, uint256 _nftTokenId)
        external
        view
        returns (MediaEyeOrders.Royalty memory)
    {
        return royalties[_nftTokenAddress][_nftTokenId];
    }

    // get sold
    /**
     * @dev Gets sold status for existing erc721/1155
     *
     * Params:
     * _nftTokenAddress: address of token to list
     * _nftTokenId: id of token
     */
    function getSoldStatus(address _nftTokenAddress, uint256 _nftTokenId)
        external
        view
        returns (bool)
    {
        return sold[_nftTokenAddress][_nftTokenId];
    }

    /**
     * @dev Sets royalties for existing erc721/1155
     *
     * Params:
     * _nftTokenAddress: address of token to list
     * _nftTokenId: id of token
     * _royalty: royalty amount for secondary sales (creator only)
     */
    function setRoyalty(
        address _nftTokenAddress,
        uint256 _nftTokenId,
        uint256 _royalty,
        address _caller
    ) external onlySetter {
        require(_royalty <= maxRoyaltyBasisPoint, "max royalty");
        require(!sold[_nftTokenAddress][_nftTokenId], "sold");
        address minter = IMinter(_nftTokenAddress).getCreator(_nftTokenId);
        require(minter == _caller, "minter only");
        royalties[_nftTokenAddress][_nftTokenId] = MediaEyeOrders.Royalty(
            payable(minter),
            _royalty
        );

        emit RoyaltySet(_nftTokenAddress, _nftTokenId, minter, _royalty);
    }

    /**
     * @dev Sets sold status for existing erc721/1155
     *
     * Params:
     * _nftTokenAddress: address of token to list
     * _nftTokenId: id of token
     */
    function setSoldStatus(address _nftTokenAddress, uint256 _nftTokenId)
        external
        onlySetter
    {
        require(!sold[_nftTokenAddress][_nftTokenId], "sold");
        sold[_nftTokenAddress][_nftTokenId] = true;
    }
}


// File contracts/MediaEyeMarketplaceListings.sol

pragma solidity ^0.8.0;
















contract MediaEyeMarketplaceListing is
    ERC721Holder,
    ERC1155Holder,
    AccessControl,
    ReentrancyGuard
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using SafeCast for int256;
    using Counters for Counters.Counter;
    using MediaEyeOrders for MediaEyeOrders.NftTokenType;
    using MediaEyeOrders for MediaEyeOrders.Listing;
    using MediaEyeOrders for MediaEyeOrders.Royalty;
    using MediaEyeOrders for MediaEyeOrders.Split;
    using MediaEyeOrders for MediaEyeOrders.ListingPayment;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    using MediaEyeOrders for MediaEyeOrders.Nft;
    using MediaEyeOrders for MediaEyeOrders.PaymentChainlink;
    using MediaEyeOrders for MediaEyeOrders.Feature;

    Counters.Counter private _listingIds;

    struct Chainlink {
        address tokenAddress;
        uint256 tokenDecimals;
        address nativeAddress;
        uint256 nativeDecimals;
        AggregatorV3Interface priceFeed;
        bool invertedAggregator;
    }
    Chainlink internal chainlink;

    struct ListingInput {
        MediaEyeOrders.Nft[] nfts;
        MediaEyeOrders.ListingPayment[] listingPayments;
        MediaEyeOrders.PaymentChainlink chainlinkPayment;
        uint8 setRoyalty;
        uint256 royalty;
        MediaEyeOrders.Split split;
        MediaEyeOrders.SubscriptionSignature subscriptionSignature;
        MediaEyeOrders.Feature feature;
        string data;
    }

    // listingId => chainlinkQuoteAddress
    mapping(uint256 => MediaEyeOrders.PaymentChainlink)
        public saleChainlinkAddresses;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address payable public treasuryWallet;
    IMarketplaceInfo public mediaEyeMarketplaceInfo;
    address public mediaEyeCharities;
    address public feeContract;
    uint256 public basisPointFee;
    bool public subscriptionCheckActive;

    // listingId => paymentMethod = priceAmount
    mapping(uint256 => mapping(address => uint256)) public salePaymentAmounts;

    mapping(uint256 => MediaEyeOrders.Listing) public listings;
    EnumerableSet.UintSet private listingIds;

    event ListingCreated(
        MediaEyeOrders.Listing listing,
        MediaEyeOrders.ListingPayment[] listingPayments,
        MediaEyeOrders.PaymentChainlink chainlinkPayment,
        string data
    );
    event ListingFinished(uint256 listingId);
    event ListingCancelled(uint256 listingId);
    event ListingUpdated(
        uint256 listingId,
        MediaEyeOrders.ListingPayment[] listingPayments,
        MediaEyeOrders.PaymentChainlink chainlinkPayment
    );
    event Sale(
        uint256 listingId,
        address buyer,
        address seller,
        uint256 saleAmount,
        uint256 pricePer,
        uint256 totalPrice,
        address paymentMethod
    );

    /**
     * @dev Constructor
     *
     * Params:
     * _owner: address of the owner
     * _admins: addresses of initial admins
     * _treasuryWallet: address of treasury wallet
     * _basisPointFee: initial basis point fee
     * _feeContract: contract of MediaEyeFee
     * _mediaEyeMarketplaceInfo: address of info
     * _mediaEyeCharities: address of charities
     * _chainlink: chainlink info
     */
    constructor(
        address _owner,
        address[] memory _admins,
        address payable _treasuryWallet,
        uint256 _basisPointFee,
        address _feeContract,
        address _mediaEyeMarketplaceInfo,
        address _mediaEyeCharities,
        Chainlink memory _chainlink
    ) {
        require(_treasuryWallet != address(0));
        require(_basisPointFee <= 500, "Max fee");

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }

        treasuryWallet = _treasuryWallet;
        feeContract = _feeContract;

        basisPointFee = _basisPointFee;
        mediaEyeMarketplaceInfo = IMarketplaceInfo(_mediaEyeMarketplaceInfo);
        mediaEyeCharities = _mediaEyeCharities;

        chainlink = _chainlink;
        subscriptionCheckActive = true;
    }

    /********************** Price Feed ********************************/

    function getRoundData() public view returns (uint256) {
        (, int256 price, , , ) = chainlink.priceFeed.latestRoundData();

        return price.toUint256();
    }

    function convertPrice(
        uint256 _baseAmount,
        uint256 _baseDecimals,
        uint256 _queryDecimals,
        bool _invertedAggregator,
        bool _convertToNative
    ) public view returns (uint256) {
        require(_baseDecimals > 0 && _baseDecimals <= 18, "Invalid _decimals");
        require(
            _queryDecimals > 0 && _queryDecimals <= 18,
            "Invalid _decimals"
        );

        uint256 roundData = getRoundData();
        uint256 roundDataDecimals = chainlink.priceFeed.decimals();
        uint256 query = 0;

        if (_convertToNative) {
            if (_invertedAggregator) {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            } else {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            }
        } else {
            if (_invertedAggregator) {
                query = (_baseAmount * (10**roundDataDecimals)) / roundData;
            } else {
                query = (_baseAmount * roundData) / (10**roundDataDecimals);
            }
        }

        if (_baseDecimals > _queryDecimals) {
            uint256 decimals = _baseDecimals - _queryDecimals;
            query = query / (10**decimals);
        } else if (_baseDecimals < _queryDecimals) {
            uint256 decimals = _queryDecimals - _baseDecimals;
            query = query * (10**decimals);
        }
        return query;
    }

    /********************** Owner Functions ********************************/

    /**
     * @dev Update constants/contracts. enter 0 address if you dont want to change a param
     *
     * Params:
     * _newTreasuryWallet: new treasury wallet
     * _newCharityContract: new MediaEyeCharity contract
     */
    function updateConstantsByOwner(
        address payable _newTreasuryWallet,
        address _newCharityContract
    ) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "owner");
        if (_newTreasuryWallet != address(0)) {
            treasuryWallet = _newTreasuryWallet;
        }
        if (_newCharityContract != address(0)) {
            mediaEyeCharities = _newCharityContract;
        }
    }

    /********************** Admin Functions ********************************/

    /**
     * @dev Update price feed aggregator address
     *
     */
    function setChainlink(Chainlink memory _chainlink) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        chainlink = _chainlink;
    }

    /**
     * @dev Update fee contract address
     *
     */
    function setFeeContract(address _feeContract) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        feeContract = _feeContract;
    }

    /**
     * @dev updates the basis point fee
     *
     * Params:
     * _basisPointFee: basis point fee, fee must be less than 500 (5%)
     */
    function updateBasisPointFee(uint256 _basisPointFee) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        require(_basisPointFee <= 500, "Max fee");
        basisPointFee = _basisPointFee;
    }

    function updateSubscriptionCheck(bool _check) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        subscriptionCheckActive = _check;
    }

    /**
     * @dev updates the marketplace info
     *
     * Params:
     * _newInfoContract: new info contract
     */
    function updateMarketplaceInfo(address _newInfoContract) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        if (_newInfoContract != address(0)) {
            mediaEyeMarketplaceInfo = IMarketplaceInfo(_newInfoContract);
        }
    }

    /********************** Get Functions ********************************/

    // Get number of listings
    function getNumListings() external view returns (uint256) {
        return listingIds.length();
    }

    /**
     * @dev Get listing ID at index
     *
     * Params:
     * index: index of ID
     */
    function getListingIds(uint256 index) external view returns (uint256) {
        return listingIds.at(index);
    }

    /**
     * @dev Get listing correlated to index
     *
     * Params:
     * index: index of ID
     */
    function getListingAtIndex(uint256 index)
        external
        view
        returns (MediaEyeOrders.Listing memory)
    {
        return listings[listingIds.at(index)];
    }

    /********************MARKETPLACE***********************/

    /**
     * @dev Create a new listing
     *
     * Params:
     * _listingInput.nfts: nfts to list
     * _listingInput.listingPayments: price accepted for accepted payment methods
     * _listingInput.chainlinkPayment: addresses for base and quote currencies (optional)
     * _listingInput.setRoyalty: if we set royalty (creator only)
     * _listingInput.royalty: royalty amount to either set or confirm
     * _listingInput.split: how to split revenue if any
     * _listingInput.subscriptionSignature: signature of subscription (optional)
     * _listingInput.feature: if we feature the listing (optional)
     */
    function createListing(ListingInput memory _listingInput)
        external
        payable
        nonReentrant
    {
        require(
            _listingInput.listingPayments.length > 0 &&
                _listingInput.nfts.length > 0,
            "length"
        );

        require(
            _listingInput.split.splitBasisPoint +
                _listingInput.split.charityBasisPoint <=
                10000,
            "total payout over 100%"
        );

        if (_listingInput.nfts.length > 1 && subscriptionCheckActive) {
            uint256 tier = 0;
            if (_listingInput.subscriptionSignature.isValid) {
                require(
                    msg.sender ==
                        _listingInput
                            .subscriptionSignature
                            .userSubscription
                            .userAddress,
                    "subscription info must be of sender"
                );
                tier = ISubscriptionTier(feeContract)
                    .checkUserSubscriptionBySig(
                        _listingInput.subscriptionSignature.userSubscription,
                        _listingInput.subscriptionSignature.v,
                        _listingInput.subscriptionSignature.r,
                        _listingInput.subscriptionSignature.s
                    );
            } else {
                tier = ISubscriptionTier(feeContract).checkUserSubscription(
                    msg.sender
                );
            }
            require(tier > 0, "subscription");
        }

        uint256 listingId = _listingIds.current();

        // save payment methods
        for (uint256 i = 0; i < _listingInput.listingPayments.length; i++) {
            require(
                mediaEyeMarketplaceInfo.isPaymentMethod(
                    _listingInput.listingPayments[i].paymentMethod
                ),
                "payment"
            );
            require(
                _listingInput.listingPayments[i].price > 0 ||
                    _listingInput.listingPayments[i].paymentMethod ==
                    _listingInput.chainlinkPayment.quoteAddress,
                "invalid price"
            );
            salePaymentAmounts[listingId][
                _listingInput.listingPayments[i].paymentMethod
            ] = _listingInput.listingPayments[i].price;
        }

        // save chainlink payment
        if (_listingInput.chainlinkPayment.isValid) {
            // check if the opposite address is a payment method
            if (
                _listingInput.chainlinkPayment.quoteAddress ==
                chainlink.nativeAddress
            ) {
                require(
                    salePaymentAmounts[listingId][chainlink.tokenAddress] > 0,
                    "chainlink payment"
                );
            } else {
                require(
                    _listingInput.chainlinkPayment.quoteAddress ==
                        chainlink.tokenAddress,
                    "impossible chainlink payment"
                );
                require(
                    salePaymentAmounts[listingId][chainlink.nativeAddress] > 0,
                    "chainlink payment"
                );
            }
            saleChainlinkAddresses[listingId] = _listingInput.chainlinkPayment;
        }

        address compareRoyaltyRecipient;

        if (_listingInput.setRoyalty == 0) {
            compareRoyaltyRecipient = mediaEyeMarketplaceInfo
                .getRoyalty(
                    _listingInput.nfts[0].nftTokenAddress,
                    _listingInput.nfts[0].nftTokenId
                )
                .artist;
        }

        MediaEyeOrders.Listing storage listing = listings[listingId];

        for (uint256 i = 0; i < _listingInput.nfts.length; i++) {
            if (_listingInput.setRoyalty != 0) {
                mediaEyeMarketplaceInfo.setRoyalty(
                    _listingInput.nfts[i].nftTokenAddress,
                    _listingInput.nfts[i].nftTokenId,
                    _listingInput.royalty,
                    msg.sender
                );
            } else {
                // check if royalty payments and royalty creators are the same for all in bundle
                require(
                    _listingInput.royalty ==
                        mediaEyeMarketplaceInfo
                            .getRoyalty(
                                _listingInput.nfts[i].nftTokenAddress,
                                _listingInput.nfts[i].nftTokenId
                            )
                            .royaltyBasisPoint &&
                        compareRoyaltyRecipient ==
                        mediaEyeMarketplaceInfo
                            .getRoyalty(
                                _listingInput.nfts[i].nftTokenAddress,
                                _listingInput.nfts[i].nftTokenId
                            )
                            .artist,
                    "royalties unmatched"
                );
            }

            if (
                _listingInput.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                require(
                    _listingInput.nfts[i].nftNumTokens == 1,
                    "ERC721 Amount"
                );
                IERC721(_listingInput.nfts[i].nftTokenAddress).safeTransferFrom(
                        msg.sender,
                        address(this),
                        _listingInput.nfts[i].nftTokenId
                    );
            } else if (
                _listingInput.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC1155
            ) {
                IERC1155(_listingInput.nfts[i].nftTokenAddress)
                    .safeTransferFrom(
                        msg.sender,
                        address(this),
                        _listingInput.nfts[i].nftTokenId,
                        _listingInput.nfts[i].nftNumTokens,
                        ""
                    );
            }
            listing.nfts.push(_listingInput.nfts[i]);
        }

        listing.listingId = listingId;
        listing.seller = payable(msg.sender);
        listing.timestamp = block.timestamp;
        listing.split = _listingInput.split;

        if (_listingInput.feature.feature) {
            if (_listingInput.feature.paymentMethod != address(0)) {
                IERC20(_listingInput.feature.paymentMethod).transferFrom(
                    msg.sender,
                    feeContract,
                    _listingInput.feature.price
                );
            }
            ISubscriptionTier(feeContract).payFeatureFee{value: msg.value}(
                _listingInput.feature.paymentMethod,
                _listingInput.feature.tokenAddresses,
                _listingInput.feature.tokenIds,
                ISubscriptionTier.Featured(
                    0,
                    _listingInput.feature.numDays,
                    4,
                    address(0),
                    listingId,
                    0,
                    _listingInput.feature.id,
                    msg.sender,
                    _listingInput.feature.price
                )
            );
        }

        listingIds.add(listingId);
        _listingIds.increment();

        emit ListingCreated(
            listings[listingId],
            _listingInput.listingPayments,
            _listingInput.chainlinkPayment,
            _listingInput.data
        );
    }

    /**
     * @dev Remove a listing
     *
     * Params:
     * _listingId: listing ID
     */
    function cancelListing(uint256 _listingId) external nonReentrant {
        require(listingIds.contains(_listingId), "nonexistent listing.");
        MediaEyeOrders.Listing memory listing = listings[_listingId];
        require(msg.sender == listing.seller, "owner listing");

        for (uint256 i = 0; i < listing.nfts.length; i++) {
            if (
                listing.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                IERC721(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    listing.seller,
                    listing.nfts[i].nftTokenId
                );
            } else if (
                listing.nfts[i].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC1155
            ) {
                IERC1155(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                    address(this),
                    listing.seller,
                    listing.nfts[i].nftTokenId,
                    listing.nfts[i].nftNumTokens,
                    ""
                );
            }
        }
        listingIds.remove(_listingId);

        emit ListingCancelled(_listingId);
    }

    /**
     * @dev Update a listing prce
     *
     * Params:
     * _listingId: listing ID
     */
    function updateListing(
        uint256 _listingId,
        MediaEyeOrders.ListingPayment[] memory _listingPayments,
        MediaEyeOrders.PaymentChainlink memory _chainlinkPayment
    ) external nonReentrant {
        require(listingIds.contains(_listingId), "nonexistent listing.");
        MediaEyeOrders.Listing memory listing = listings[_listingId];
        require(msg.sender == listing.seller, "owner listing");

        // save payment methods, set price to 0 to remove payment method
        for (uint256 i = 0; i < _listingPayments.length; i++) {
            require(
                mediaEyeMarketplaceInfo.isPaymentMethod(
                    _listingPayments[i].paymentMethod
                ),
                "payment"
            );
            salePaymentAmounts[_listingId][
                _listingPayments[i].paymentMethod
            ] = _listingPayments[i].price;
        }

        // save chainlink payment
        if (_chainlinkPayment.isValid) {
            // if valid
            // check if the opposite address is a payment method
            if (_chainlinkPayment.quoteAddress == chainlink.nativeAddress) {
                require(
                    salePaymentAmounts[_listingId][chainlink.tokenAddress] > 0,
                    "chainlink payment"
                );
            } else {
                require(
                    _chainlinkPayment.quoteAddress == chainlink.tokenAddress,
                    "impossible chainlink payment"
                );
                require(
                    salePaymentAmounts[_listingId][chainlink.nativeAddress] > 0,
                    "chainlink payment"
                );
            }
        }
        // set chainlink payment
        saleChainlinkAddresses[_listingId] = _chainlinkPayment;

        emit ListingUpdated(_listingId, _listingPayments, _chainlinkPayment);
    }

    /**
     * @dev Buy a token
     *
     * Params:
     * _listingId: listing ID
     * _amount: amount tokens to buy (amount = 1 for any bundles)
     * _paymentMethod: method of payment and total price
     */
    function buyTokens(
        uint256 _listingId,
        uint256 _amount,
        MediaEyeOrders.ListingPayment memory _paymentMethod
    ) external payable nonReentrant {
        require(listingIds.contains(_listingId), "nonexistent listing");
        require(_amount > 0, "amount");
        if (_paymentMethod.paymentMethod == address(0)) {
            require(msg.value == _paymentMethod.price, "native msgvalue");
        } else {
            require(msg.value == 0, "msgvalue");
        }

        uint256 price = 0;
        uint256 convertedPrice = 0;

        // check if chainlink
        if (
            saleChainlinkAddresses[_listingId].isValid &&
            _paymentMethod.paymentMethod ==
            saleChainlinkAddresses[_listingId].quoteAddress
        ) {
            // calculate price
            if (_paymentMethod.paymentMethod == address(0)) {
                price = salePaymentAmounts[_listingId][chainlink.tokenAddress];
                require(price > 0, "chainlink payment");
                convertedPrice = convertPrice(
                    price * _amount,
                    chainlink.tokenDecimals,
                    chainlink.nativeDecimals,
                    chainlink.invertedAggregator,
                    true
                );
                // check tolerance
                require(
                    msg.value >= convertedPrice,
                    "native payment not enough"
                );
                if (msg.value > convertedPrice) {
                    (bool diffSent, ) = msg.sender.call{
                        value: msg.value - convertedPrice
                    }("");
                    require(diffSent, "return transfer fail.");
                }
            } else {
                require(
                    _paymentMethod.paymentMethod == chainlink.tokenAddress,
                    "impossible chainlink payment"
                );
                price = salePaymentAmounts[_listingId][chainlink.nativeAddress];
                require(price > 0, "chainlink payment");
                convertedPrice = convertPrice(
                    price * _amount,
                    chainlink.nativeDecimals,
                    chainlink.tokenDecimals,
                    chainlink.invertedAggregator,
                    false
                );
                // check tolerance
                require(
                    _paymentMethod.price >= convertedPrice,
                    "chainlink payment not enough"
                );
            }
        } else {
            price = salePaymentAmounts[_listingId][
                _paymentMethod.paymentMethod
            ];
            require(
                price > 0 && _paymentMethod.price == price * _amount,
                "payment"
            );
            convertedPrice = _paymentMethod.price;
        }

        MediaEyeOrders.Listing storage listing = listings[_listingId];

        // if not a bundle, can buy any amount
        if (listing.nfts.length == 1) {
            require(listing.nfts[0].nftNumTokens >= _amount, "soldout");
        } else if (listing.nfts.length > 1) {
            require(_amount == 1, "bundles amount");
        }

        _sendPayments(
            listing.nfts[0].nftTokenAddress,
            listing.nfts[0].nftTokenId,
            listing.seller,
            _paymentMethod.paymentMethod,
            convertedPrice,
            listing.split,
            msg.sender
        );

        if (listing.nfts.length == 1) {
            listing.nfts[0].nftNumTokens -= _amount;
            if (
                listing.nfts[0].nftTokenType ==
                MediaEyeOrders.NftTokenType.ERC721
            ) {
                IERC721(listing.nfts[0].nftTokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    listing.nfts[0].nftTokenId,
                    ""
                );
            } else {
                IERC1155(listing.nfts[0].nftTokenAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    listing.nfts[0].nftTokenId,
                    _amount,
                    ""
                );
            }
            if (listing.nfts[0].nftNumTokens == 0) {
                listingIds.remove(_listingId);
                emit ListingFinished(_listingId);
            }
            if (
                !mediaEyeMarketplaceInfo.getSoldStatus(
                    listing.nfts[0].nftTokenAddress,
                    listing.nfts[0].nftTokenId
                )
            ) {
                mediaEyeMarketplaceInfo.setSoldStatus(
                    listing.nfts[0].nftTokenAddress,
                    listing.nfts[0].nftTokenId
                );
            }
        } else if (listing.nfts.length > 1) {
            for (uint256 i = 0; i < listing.nfts.length; i++) {
                if (
                    listing.nfts[i].nftTokenType ==
                    MediaEyeOrders.NftTokenType.ERC721
                ) {
                    IERC721(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                        address(this),
                        msg.sender,
                        listing.nfts[i].nftTokenId,
                        ""
                    );
                } else {
                    IERC1155(listing.nfts[i].nftTokenAddress).safeTransferFrom(
                        address(this),
                        msg.sender,
                        listing.nfts[i].nftTokenId,
                        listing.nfts[i].nftNumTokens,
                        ""
                    );
                }
                if (
                    !mediaEyeMarketplaceInfo.getSoldStatus(
                        listing.nfts[i].nftTokenAddress,
                        listing.nfts[i].nftTokenId
                    )
                ) {
                    mediaEyeMarketplaceInfo.setSoldStatus(
                        listing.nfts[i].nftTokenAddress,
                        listing.nfts[i].nftTokenId
                    );
                }
            }
            listingIds.remove(_listingId);
            emit ListingFinished(_listingId);
        }

        emit Sale(
            _listingId,
            msg.sender,
            listing.seller,
            _amount,
            convertedPrice / _amount,
            convertedPrice,
            _paymentMethod.paymentMethod
        );
    }

    function _sendPayments(
        address _tokenAddress,
        uint256 _tokenId,
        address payable _sellerAddress,
        address paymentMethod,
        uint256 price,
        MediaEyeOrders.Split memory _split,
        address _payer
    ) internal {
        // royalties are the same for each in the bundle
        MediaEyeOrders.Royalty memory royalty = mediaEyeMarketplaceInfo
            .getRoyalty(_tokenAddress, _tokenId);
        uint256 payoutToTreasury = (price * basisPointFee) / 10000;
        uint256 payoutToCreator = 0;
        uint256 payoutToCharity = 0;
        uint256 payoutToSecondarySeller = 0;
        if (royalty.royaltyBasisPoint > 0) {
            payoutToCreator = (price * royalty.royaltyBasisPoint) / 10000;
        }

        // payout to Charity/sellers
        uint256 remainingPayout = (price *
            (10000 - basisPointFee - royalty.royaltyBasisPoint)) / 10000;
        if (_split.charityBasisPoint > 0 && _split.charity != address(0)) {
            payoutToCharity =
                (remainingPayout * _split.charityBasisPoint) /
                10000;
        }
        if (_split.splitBasisPoint > 0 && _split.recipient != address(0)) {
            payoutToSecondarySeller =
                (remainingPayout * _split.splitBasisPoint) /
                10000;
        }

        uint256 payoutToSeller = (remainingPayout *
            (10000 - _split.charityBasisPoint - _split.splitBasisPoint)) /
            10000;

        if (paymentMethod == address(0)) {
            (bool treasurySent, ) = treasuryWallet.call{
                value: payoutToTreasury
            }("");
            require(treasurySent, "treasury.");
            if (payoutToCreator > 0) {
                (bool royaltySent, ) = royalty.artist.call{
                    value: payoutToCreator
                }("");
                require(royaltySent, "royalty");
            }
            if (payoutToCharity > 0) {
                (bool charitySent, ) = _split.charity.call{
                    value: payoutToCharity
                }("");
                require(charitySent, "charity");
            }
            if (payoutToSecondarySeller > 0) {
                (bool secondarySellerSent, ) = _split.recipient.call{
                    value: payoutToSecondarySeller
                }("");
                require(secondarySellerSent, "seller2");
            }
            if (payoutToSeller > 0) {
                (bool sellerSent, ) = _sellerAddress.call{
                    value: payoutToSeller
                }("");
                require(sellerSent, "seller");
            }
        } else {
            IERC20(paymentMethod).transferFrom(
                _payer,
                treasuryWallet,
                payoutToTreasury
            );
            if (payoutToCreator > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    royalty.artist,
                    payoutToCreator
                );
            }
            if (payoutToCharity > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _split.charity,
                    payoutToCharity
                );
            }
            if (payoutToSecondarySeller > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _split.recipient,
                    payoutToSecondarySeller
                );
            }
            if (payoutToSeller > 0) {
                IERC20(paymentMethod).transferFrom(
                    _payer,
                    _sellerAddress,
                    payoutToSeller
                );
            }
        }
    }

    // override supportsInterface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File contracts/MediaEyeMarketplaceOffers.sol

pragma solidity ^0.8.0;












contract MediaEyeMarketplaceOffers is AccessControl, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using MediaEyeOrders for MediaEyeOrders.NftTokenType;
    using MediaEyeOrders for MediaEyeOrders.Auction;
    using MediaEyeOrders for MediaEyeOrders.Royalty;
    using MediaEyeOrders for MediaEyeOrders.Split;
    using MediaEyeOrders for MediaEyeOrders.AuctionPayment;
    using MediaEyeOrders for MediaEyeOrders.OfferSignature;
    using MediaEyeOrders for MediaEyeOrders.SubscriptionSignature;
    using MediaEyeOrders for MediaEyeOrders.Nft;
    using MediaEyeOrders for MediaEyeOrders.PaymentChainlink;
    using MediaEyeOrders for MediaEyeOrders.Feature;
    using MediaEyeOrders for MediaEyeOrders.AuctionInput;
    using MediaEyeOrders for MediaEyeOrders.OfferConstructor;
    using MediaEyeOrders for MediaEyeOrders.OfferAdmin;

    bytes32 internal immutable _DOMAIN_SEPARATOR;

    bytes32 internal constant OFFER_SIGNATURE_TYPEHASH =
        0x4b0bbb64026d94dee3a5b616178787d6cff0aff1a9d30424566e7b056bcec5b1;
    // keccak256(
    //     "OfferSignature(address nftAddress,uint256 tokenId,uint256 supply,uint256 price,address offerer,address paymentMethod,uint256 expiry)"
    // );

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
    address payable public treasuryWallet;
    IMarketplaceInfo public mediaEyeMarketplaceInfo;
    address public mediaEyeCharities;
    address public feeContract;
    uint256 public basisPointFee;

    mapping(bytes32 => bool) public isCancelled;

    event MediaEyeOfferClaimed(
        MediaEyeOrders.Nft nft,
        address offerer,
        address seller,
        uint256 price,
        address paymentMethod
    );

    /**
     * @dev Constructor
     *
     * Params:
     * _owner: address of the owner
     * _admins: addresses of initial admins
     * _treasuryWallet: address of treasury wallet
     * _basisPointFee: initial basis point fee
     * _feeContract: contract of MediaEyeFee
     * _mediaEyeMarketplaceInfo: address of info
     * _mediaEyeCharities: address of charities
     * _chainlink: chainlink info
     */
    constructor(MediaEyeOrders.OfferConstructor memory _offerConstructor) {
        require(_offerConstructor._treasuryWallet != address(0));
        require(_offerConstructor._basisPointFee <= 500);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256("MediaEyeMarketplace"),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _offerConstructor._owner);
        for (uint256 i = 0; i < _offerConstructor._admins.length; i++) {
            _setupRole(ROLE_ADMIN, _offerConstructor._admins[i]);
        }

        treasuryWallet = _offerConstructor._treasuryWallet;
        feeContract = _offerConstructor._feeContract;

        basisPointFee = _offerConstructor._basisPointFee;
        mediaEyeMarketplaceInfo = IMarketplaceInfo(
            _offerConstructor._mediaEyeMarketplaceInfo
        );
    }

    /********************** Owner Functions ********************************/
    /**
     * @dev Update constants/contracts.
     *
     */

    function updateConstantsByAdmin(
        MediaEyeOrders.OfferAdmin memory _offerAdmin
    ) external {
        require(
            hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "admin"
        );
        if (_offerAdmin._basisPointFee > 0) {
            require(_offerAdmin._basisPointFee <= 500, "fee");
            basisPointFee = _offerAdmin._basisPointFee;
        }
        if (_offerAdmin._newInfoContract != address(0)) {
            mediaEyeMarketplaceInfo = IMarketplaceInfo(
                _offerAdmin._newInfoContract
            );
        }
        if (_offerAdmin._newTreasuryWallet != address(0)) {
            treasuryWallet = _offerAdmin._newTreasuryWallet;
        }
        if (_offerAdmin._newFeeContract != address(0)) {
            feeContract = _offerAdmin._newFeeContract;
        }
    }

    /********************MARKETPLACE***********************/

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    function offerClaim(MediaEyeOrders.OfferSignature memory _offerSignature)
        external
    {
        require(_offerSignature.paymentMethod != address(0), "payment");
        require(_offerSignature.expiry >= block.timestamp, "expired");

        // Check if signature is valid

        bytes32 structHash = keccak256(
            abi.encode(
                OFFER_SIGNATURE_TYPEHASH,
                _offerSignature.nft.nftTokenAddress,
                _offerSignature.nft.nftTokenId,
                _offerSignature.nft.nftNumTokens,
                _offerSignature.price,
                _offerSignature.offerer,
                _offerSignature.paymentMethod,
                _offerSignature.expiry
            )
        );

        require(
            !isCancelled[structHash],
            "offer is already claimed or cancelled"
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
        );
        require(
            ecrecover(
                digest,
                _offerSignature.v,
                _offerSignature.r,
                _offerSignature.s
            ) == _offerSignature.offerer,
            "signature"
        );
        // The claimer is responsible for transfering their NFT to offerer and receiving the token
        _sellClaim(_offerSignature);
    }

    function _sellClaim(MediaEyeOrders.OfferSignature memory _offerSignature)
        internal
    {
        MediaEyeOrders.Royalty memory royalty = mediaEyeMarketplaceInfo
            .getRoyalty(
                _offerSignature.nft.nftTokenAddress,
                _offerSignature.nft.nftTokenId
            );

        uint256 payoutToTreasury = (_offerSignature.price * basisPointFee) /
            10000;
        uint256 payoutToCreator = 0;
        uint256 payoutToCharity = 0;
        if (royalty.royaltyBasisPoint > 0) {
            payoutToCreator =
                (_offerSignature.price * royalty.royaltyBasisPoint) /
                10000;
        }

        // payout to Charity/sellers
        uint256 remainingPayout = (_offerSignature.price *
            (10000 - basisPointFee - royalty.royaltyBasisPoint)) / 10000;
        if (
            _offerSignature.charityBasisPoint > 0 &&
            _offerSignature.charityAddress != address(0)
        ) {
            payoutToCharity =
                (remainingPayout * _offerSignature.charityBasisPoint) /
                10000;
        }
        uint256 payoutToSeller = (remainingPayout *
            (10000 - _offerSignature.charityBasisPoint)) / 10000;

        IERC20(_offerSignature.paymentMethod).transferFrom(
            _offerSignature.offerer,
            treasuryWallet,
            payoutToTreasury
        );
        if (payoutToCreator > 0) {
            IERC20(_offerSignature.paymentMethod).transferFrom(
                _offerSignature.offerer,
                royalty.artist,
                payoutToCreator
            );
        }
        if (payoutToCharity > 0) {
            IERC20(_offerSignature.paymentMethod).transferFrom(
                _offerSignature.offerer,
                _offerSignature.charityAddress,
                payoutToCharity
            );
        }
        if (payoutToSeller > 0) {
            IERC20(_offerSignature.paymentMethod).transferFrom(
                _offerSignature.offerer,
                msg.sender,
                payoutToSeller
            );
        }

        if (
            !mediaEyeMarketplaceInfo.getSoldStatus(
                _offerSignature.nft.nftTokenAddress,
                _offerSignature.nft.nftTokenId
            )
        ) {
            mediaEyeMarketplaceInfo.setSoldStatus(
                _offerSignature.nft.nftTokenAddress,
                _offerSignature.nft.nftTokenId
            );
        }
        if (
            _offerSignature.nft.nftTokenType ==
            MediaEyeOrders.NftTokenType.ERC721
        ) {
            IERC721(_offerSignature.nft.nftTokenAddress).safeTransferFrom(
                msg.sender,
                _offerSignature.offerer,
                _offerSignature.nft.nftTokenId,
                ""
            );
        } else {
            IERC1155(_offerSignature.nft.nftTokenAddress).safeTransferFrom(
                msg.sender,
                _offerSignature.offerer,
                _offerSignature.nft.nftTokenId,
                _offerSignature.nft.nftNumTokens,
                ""
            );
        }

        emit MediaEyeOfferClaimed(
            _offerSignature.nft,
            _offerSignature.offerer,
            msg.sender,
            _offerSignature.price,
            _offerSignature.paymentMethod
        );
    }
}


// File contracts/MediaEyeMerkle.sol

pragma solidity ^0.8.0;


contract MediaEyeMerkleDistributor {
    using Counters for Counters.Counter;
    Counters.Counter private _airdropIds;

    struct Airdrop {
        address owner;
        bytes32 merkleRoot;
        bool cancelable;
        uint256 tokenAmount;
        mapping(address => bool) collected;
    }

    IERC20 tokenContract;

    event StartAirdrop(uint256 airdropId);
    event AirdropTransfer(uint256 id, address addr, uint256 num);

    mapping(uint256 => Airdrop) public airdrops;

    constructor(IERC20 _tokenContract) {
        tokenContract = _tokenContract;
    }

    function startAirdrop(
        bytes32 _merkleRoot,
        bool _cancelable,
        uint256 _tokenAmount
    ) public {
        _airdropIds.increment();
        Airdrop storage newAirdrop = airdrops[_airdropIds.current()];
        newAirdrop.owner = msg.sender;
        newAirdrop.merkleRoot = _merkleRoot;
        newAirdrop.cancelable = _cancelable;
        newAirdrop.tokenAmount = _tokenAmount;

        tokenContract.transferFrom(msg.sender, address(this), _tokenAmount);
        emit StartAirdrop(_airdropIds.current());
    }

    function setRoot(uint256 _id, bytes32 _merkleRoot) public {
        require(
            msg.sender == airdrops[_id].owner,
            "Only owner of an airdrop can set root"
        );
        airdrops[_id].merkleRoot = _merkleRoot;
    }

    function collected(uint256 _id, address _who) public view returns (bool) {
      return airdrops[_id].collected[_who];
    }

    function nextAirdropId() public view returns (uint256) {
      return _airdropIds.current() + 1;
    }

    function contractTokenBalance() public view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }

    function contractTokenBalanceById(uint256 _id)
        public
        view
        returns (uint256)
    {
        return airdrops[_id].tokenAmount;
    }

    function endAirdrop(uint256 _id) public returns (bool) {
        require(airdrops[_id].cancelable, "this presale is not cancelable");
        // only owner
        require(
            msg.sender == airdrops[_id].owner,
            "Only owner of an airdrop can end the airdrop"
        );
        require(airdrops[_id].tokenAmount > 0, "Airdrop has no balance left");
        // require(airdrops[_id].startTime <= block.timestamp - 43800 minutes, "Must wait 1 month before ending airdrop"); // 1 month
        uint256 transferAmount = airdrops[_id].tokenAmount;
        airdrops[_id].tokenAmount = 0;
        require(
            tokenContract.transferFrom(
                address(this),
                airdrops[_id].owner,
                transferAmount
            ),
            "Unable to transfer remaining balance"
        );
        return true;
    }

    function getTokens(
        uint256 _id,
        bytes32[] memory _proof,
        address _who,
        uint256 _amount
    ) public returns (bool success) {
        Airdrop storage airdrop = airdrops[_id];

        require(
            airdrop.collected[_who] != true,
            "User has already collected from this airdrop"
        );
        require(_amount > 0, "User must collect an amount greater than 0");
        require(
            airdrop.tokenAmount >= _amount,
            "The airdrop does not have enough balance for this withdrawal"
        );
        require(
            msg.sender == _who,
            "Only the recipient can receive for themselves"
        );

        if (
            !checkProof(_id, _proof, leafFromAddressAndNumTokens(_who, _amount))
        ) {
            // throw if proof check fails, no need to spend gas
            require(false, "Invalid proof");
            // return false;
        }

        airdrop.tokenAmount = airdrop.tokenAmount - _amount;
        airdrop.collected[_who] = true;

        if (tokenContract.transferFrom(address(this), _who, _amount) == true) {
            emit AirdropTransfer(_id, _who, _amount);
            return true;
        }
        // throw if transfer fails, no need to spend gas
        require(false);
    }

    function addressToAsciiString(address x)
        internal
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(40);
        uint256 x_int = uint256(uint160(address(x)));

        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(x_int / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uintToStr(uint256 i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
            bstr[(k--) - 1] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }

    function leafFromAddressAndNumTokens(address _account, uint256 _amount)
        internal
        pure
        returns (bytes32)
    {
        string memory prefix = "0x";
        string memory space = " ";

        bytes memory leaf = abi.encodePacked(
            prefix,
            addressToAsciiString(_account),
            space,
            uintToStr(_amount)
        );

        return bytes32(sha256(leaf));
    }

    function checkProof(
        uint256 _id,
        bytes32[] memory _proof,
        bytes32 hash
    ) internal view returns (bool) {
        bytes32 el;
        bytes32 h = hash;

        for (
            uint256 i = 0;
            _proof.length != 0 && i <= _proof.length - 1;
            i += 1
        ) {
            el = _proof[i];

            if (h < el) {
                h = sha256(abi.encodePacked(h, el));
            } else {
                h = sha256(abi.encodePacked(el, h));
            }
        }

        return h == airdrops[_id].merkleRoot;
    }
}


// File hardhat/[email protected]

pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}


// File contracts/old/testAMB/TestMediaEyeSubscription.sol

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;




contract MediaEyeFees is AccessControl {
    bytes32 public constant ROLE_OWNER = keccak256("ROLE_OWNER");
    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    address mediator;
    address payable public feeWallet;

    IERC20 EYE;
    IERC20 BUSD;
    IERC20 USDT;

    struct TokenAmounts {
        uint256 uploadOneAmount;
        uint256 uploadTwoAmount;
        uint256 uploadThreeAmount;
        uint256 uploadFourAmount;
        uint256 featureAmount;
        uint256 subscribeOneAmount;
        uint256 subscribeTwoAmount;
    }

    enum PaymentMethod {
        Eye,
        Busd,
        Usdt,
        Native
    }

    enum UploadTier {
        LevelOne,
        LevelTwo,
        LevelThree,
        LevelFour
    }

    enum SubscriptionTier {
        LevelOne,
        LevelTwo
    }

    struct UserSubscription {
        address userAddress;
        SubscriptionTier subscriptionTier;
        uint256 startTime;
        uint256 endTime;
    }

    // amount in contract
    mapping(PaymentMethod => uint256) public contractTokenAmounts;

    // amount required for fees
    mapping(PaymentMethod => TokenAmounts) public paymentMethodAmounts;

    mapping(address => UserSubscription) public subscriptions;

    event UploadPaid(
        uint256 uploadId,
        UploadTier uploadTier,
        address userAddress
    );

    event FeaturePaid(uint256 featureId, address userAddress);

    event SubscriptionPaid(UserSubscription userSubscription);

    event TokenAmountsChanged(
        PaymentMethod paymentMethod,
        TokenAmounts tokenAmounts
    );

    event FeeWalletChanged(address newFeeWallet);

    /********************** MODIFIERS ********************************/

    modifier onlyAdmin() {
        require(
            (hasRole(ROLE_ADMIN, msg.sender) ||
                hasRole(ROLE_OWNER, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "Sender is not an admin"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            (hasRole(ROLE_OWNER, msg.sender) ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender)),
            "Sender is not an owner"
        );
        _;
    }

    modifier sufficientRole(bytes32 role) {
        _checkSufficientRole(role, _msgSender());
        _;
    }

    modifier onlyMediator() {
        require(
            msg.sender == mediator,
            "GovernanceReceiverMediator::executeTransaction: Call must come from bridge"
        );
        _;
    }

    /**
     * @dev Stores the token contracts, and allows users with the admin role to
     * grant/revoke the admin role from other users. Stores initial fee prices.
     *
     * Params:
     * _EYETokenAddress: the address of the eye token contract
     * _admin: address of the first admin
     * _paymentMethods: order of the TokenAmounts to initialize
     * _initialTokenAmounts: amounts for each fee for each payment method
     */
    constructor(
        address _EYETokenAddress,
        address _BUSDTokenAddress,
        address _USDTTokenAddress,
        address _owner,
        address[] memory _admins,
        address payable _feeWallet,
        PaymentMethod[] memory _paymentMethods,
        TokenAmounts[] memory _initialTokenAmounts
    ) {
        require(
            _initialTokenAmounts.length == 4,
            "There must be initial amounts for each payment method"
        );
        require(
            _initialTokenAmounts.length == _paymentMethods.length,
            "There must be amounts for each payment method"
        );
        _setupRole(ROLE_OWNER, _owner);
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(ROLE_ADMIN, _admins[i]);
        }
        _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);
        _setRoleAdmin(ROLE_OWNER, ROLE_OWNER);

        feeWallet = _feeWallet;

        EYE = IERC20(_EYETokenAddress);
        BUSD = IERC20(_BUSDTokenAddress);
        USDT = IERC20(_USDTTokenAddress);

        for (uint256 i = 0; i < 4; i++) {
            paymentMethodAmounts[_paymentMethods[i]] = _initialTokenAmounts[i];
        }
    }

    /********************** Update Token Amounts ********************************/

    /**
     * @dev Update Price Amounts for single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to change amountf or
     */
    function updateSingleTokenAmount(
        TokenAmounts memory _newTokenAmount,
        PaymentMethod _paymentMethod
    ) external onlyAdmin {
        require(
            _paymentMethod == PaymentMethod.Eye ||
                _paymentMethod == PaymentMethod.Busd ||
                _paymentMethod == PaymentMethod.Usdt ||
                _paymentMethod == PaymentMethod.Native,
            "Invalid payment method."
        );
        paymentMethodAmounts[_paymentMethod] = _newTokenAmount;
        emit TokenAmountsChanged(_paymentMethod, _newTokenAmount);
    }

    /**
     * @dev Update Price Amounts for multiple payment method
     *
     * Params:
     * _newTokenAmounts: new token amounts for multiple payment method
     * _paymentMethods: order of the tokenAmounts to set
     */
    function updateMultipleTokenAmounts(
        TokenAmounts[] memory _newTokenAmounts,
        PaymentMethod[] memory _paymentMethods
    ) external onlyAdmin {
        require(
            _newTokenAmounts.length == _paymentMethods.length,
            "There must be amounts for each payment method"
        );
        for (uint256 i = 0; i < _newTokenAmounts.length; i++) {
            paymentMethodAmounts[_paymentMethods[i]] = _newTokenAmounts[i];
            emit TokenAmountsChanged(_paymentMethods[i], _newTokenAmounts[i]);
        }
    }

    /**
     * @dev Update Price Amounts for single payment method
     *
     * Params:
     * _newTokenAmount: new token amounts for single payment method
     * _paymentMethod: the payment method to change amountf or
     */
    function updateFeeWallet(address payable _newFeeWallet) external onlyOwner {
        feeWallet = _newFeeWallet;
        emit FeeWalletChanged(_newFeeWallet);
    }

    function setMediator(address _mediator) external onlyOwner {
        mediator = _mediator;
    }

    /********************** PAY ********************************/

    /**
     * @dev user pays upload fees
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _uploadTier: tier of the uploaded content, based on size, 20/50/100/200 mb
     * _uploadId: id of upload
     */
    function payUploadFee(
        PaymentMethod _paymentMethod,
        UploadTier _uploadTier,
        uint256 _uploadId
    ) external payable {
        require(
            _paymentMethod == PaymentMethod.Eye ||
                _paymentMethod == PaymentMethod.Busd ||
                _paymentMethod == PaymentMethod.Usdt ||
                _paymentMethod == PaymentMethod.Native,
            "Invalid payment method."
        );

        require(
            _uploadTier == UploadTier.LevelOne ||
                _uploadTier == UploadTier.LevelTwo ||
                _uploadTier == UploadTier.LevelThree ||
                _uploadTier == UploadTier.LevelFour,
            "Invalid payment method."
        );

        uint256 price = 0;
        if (_uploadTier == UploadTier.LevelOne) {
            price = paymentMethodAmounts[_paymentMethod].uploadOneAmount;
        } else if (_uploadTier == UploadTier.LevelTwo) {
            price = paymentMethodAmounts[_paymentMethod].uploadTwoAmount;
        } else if (_uploadTier == UploadTier.LevelThree) {
            price = paymentMethodAmounts[_paymentMethod].uploadThreeAmount;
        } else if (_uploadTier == UploadTier.LevelFour) {
            price = paymentMethodAmounts[_paymentMethod].uploadFourAmount;
        }

        if (_paymentMethod == PaymentMethod.Eye) {
            EYE.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Busd) {
            BUSD.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Usdt) {
            USDT.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Native) {
            require(msg.value == price, "Incorrect transaction value.");
        }

        contractTokenAmounts[_paymentMethod] =
            contractTokenAmounts[_paymentMethod] +
            price;

        emit UploadPaid(_uploadId, _uploadTier, msg.sender);
    }

    /**
     * @dev user pays feature fees
     *
     * Params:
     * _paymentMethod: type of payment Method
     * _featureId: id of feature
     */
    function payFeatureFee(PaymentMethod _paymentMethod, uint256 _featureId)
        external
        payable
    {
        require(
            _paymentMethod == PaymentMethod.Eye ||
                _paymentMethod == PaymentMethod.Busd ||
                _paymentMethod == PaymentMethod.Usdt ||
                _paymentMethod == PaymentMethod.Native,
            "Invalid payment method."
        );

        uint256 price = paymentMethodAmounts[_paymentMethod].featureAmount;
        if (_paymentMethod == PaymentMethod.Eye) {
            EYE.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Busd) {
            BUSD.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Usdt) {
            USDT.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Native) {
            require(msg.value == price, "Incorrect transaction value.");
        }

        contractTokenAmounts[_paymentMethod] =
            contractTokenAmounts[_paymentMethod] +
            price;

        emit FeaturePaid(_featureId, msg.sender);
    }

    /**
     * @dev user pays subscription fees for tier one
     *
     * Params:
     * _paymentMethod: type of payment Method
     */
    function paySubscriptionLevelOneFee(PaymentMethod _paymentMethod)
        external
        payable
    {
        require(
            _paymentMethod == PaymentMethod.Eye ||
                _paymentMethod == PaymentMethod.Busd ||
                _paymentMethod == PaymentMethod.Usdt ||
                _paymentMethod == PaymentMethod.Native,
            "Invalid payment method."
        );

        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = block.timestamp + 43800 minutes;
        if (subscriptions[msg.sender].endTime > block.timestamp) {
            require(
                subscriptions[msg.sender].subscriptionTier ==
                    SubscriptionTier.LevelOne,
                "user is subscribed already to a higher tier."
            );
            startTimestamp = subscriptions[msg.sender].startTime;
            endTimestamp = subscriptions[msg.sender].endTime + 43800 minutes;
        }

        uint256 price = paymentMethodAmounts[_paymentMethod].subscribeOneAmount;

        if (_paymentMethod == PaymentMethod.Eye) {
            EYE.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Busd) {
            BUSD.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Usdt) {
            USDT.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Native) {
            require(msg.value == price, "Incorrect transaction value.");
        }

        UserSubscription storage newUserSubscription = subscriptions[
            msg.sender
        ];
        newUserSubscription.userAddress = msg.sender;
        newUserSubscription.subscriptionTier = SubscriptionTier.LevelOne;
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        contractTokenAmounts[_paymentMethod] =
            contractTokenAmounts[_paymentMethod] +
            price;

        IMediaEyeSubscriptionMediator(mediator).subscribeLevelOne(
            msg.sender,
            startTimestamp,
            endTimestamp
        );

        emit SubscriptionPaid(newUserSubscription);
    }

    //call to subscribe via mediator
    function subscribeLevelOneByBridge(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) external onlyMediator {
        UserSubscription storage newUserSubscription = subscriptions[account];
        newUserSubscription.userAddress = account;
        newUserSubscription.subscriptionTier = SubscriptionTier.LevelOne;
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        emit SubscriptionPaid(newUserSubscription);
    }

    /**
     * @dev user pays subscription fees for tier two
     *
     * Params:
     * _paymentMethod: type of payment Method
     */
    function paySubscriptionLevelTwoFee(PaymentMethod _paymentMethod)
        external
        payable
    {
        require(
            _paymentMethod == PaymentMethod.Eye ||
                _paymentMethod == PaymentMethod.Busd ||
                _paymentMethod == PaymentMethod.Usdt ||
                _paymentMethod == PaymentMethod.Native,
            "Invalid payment method."
        );

        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = block.timestamp + 43800 minutes;
        if (subscriptions[msg.sender].endTime > block.timestamp) {
            if (
                subscriptions[msg.sender].subscriptionTier ==
                SubscriptionTier.LevelTwo
            ) {
                startTimestamp = subscriptions[msg.sender].startTime;
                endTimestamp =
                    subscriptions[msg.sender].endTime +
                    43800 minutes;
            }
        }

        uint256 price = paymentMethodAmounts[_paymentMethod].subscribeTwoAmount;

        if (_paymentMethod == PaymentMethod.Eye) {
            EYE.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Busd) {
            BUSD.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Usdt) {
            USDT.transferFrom(msg.sender, address(this), price);
        } else if (_paymentMethod == PaymentMethod.Native) {
            require(msg.value == price, "Incorrect transaction value.");
        }

        UserSubscription storage newUserSubscription = subscriptions[
            msg.sender
        ];
        newUserSubscription.userAddress = msg.sender;
        newUserSubscription.subscriptionTier = SubscriptionTier.LevelTwo;
        newUserSubscription.startTime = startTimestamp;
        newUserSubscription.endTime = endTimestamp;

        contractTokenAmounts[_paymentMethod] =
            contractTokenAmounts[_paymentMethod] +
            price;

        emit SubscriptionPaid(newUserSubscription);
    }

    /********************** WITHDRAW FUNDS ********************************/
    /**
     * @dev Admin withdraw tokens for a single payment method
     *
     * Params:
     * _paymentMethod: the token type to withdraw
     */
    function withdrawSingleToken(PaymentMethod _paymentMethod)
        external
        onlyAdmin
    {
        require(
            _paymentMethod == PaymentMethod.Eye ||
                _paymentMethod == PaymentMethod.Busd ||
                _paymentMethod == PaymentMethod.Usdt ||
                _paymentMethod == PaymentMethod.Native,
            "Invalid payment method."
        );
        uint256 amount = contractTokenAmounts[_paymentMethod];
        require(amount > 0, "total fees should be greater than 0");

        if (_paymentMethod == PaymentMethod.Eye) {
            EYE.transfer(feeWallet, amount);
        } else if (_paymentMethod == PaymentMethod.Busd) {
            BUSD.transfer(feeWallet, amount);
        } else if (_paymentMethod == PaymentMethod.Usdt) {
            USDT.transfer(feeWallet, amount);
        } else if (_paymentMethod == PaymentMethod.Native) {
            feeWallet.transfer(amount);
        }

        contractTokenAmounts[_paymentMethod] = 0;
    }

    /**
     * @dev Admin withdraw all tokens
     *
     */
    function withdrawAllTokens() external onlyAdmin {
        if (contractTokenAmounts[PaymentMethod.Eye] > 0) {
            EYE.transfer(feeWallet, contractTokenAmounts[PaymentMethod.Eye]);
            contractTokenAmounts[PaymentMethod.Eye] = 0;
        }
        if (contractTokenAmounts[PaymentMethod.Busd] > 0) {
            BUSD.transfer(feeWallet, contractTokenAmounts[PaymentMethod.Busd]);
            contractTokenAmounts[PaymentMethod.Busd] = 0;
        }
        if (contractTokenAmounts[PaymentMethod.Usdt] > 0) {
            USDT.transfer(feeWallet, contractTokenAmounts[PaymentMethod.Usdt]);
            contractTokenAmounts[PaymentMethod.Usdt] = 0;
        }
        if (contractTokenAmounts[PaymentMethod.Native] > 0) {
            feeWallet.transfer(contractTokenAmounts[PaymentMethod.Native]);
            contractTokenAmounts[PaymentMethod.Native] = 0;
        }
    }

    /********************** ADD ADMINS ********************************/
    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role or owner role.
     */
    function grantRole(bytes32 role, address account)
        public
        override
        sufficientRole(role)
    {
        _setupRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account)
        public
        override
        sufficientRole(role)
    {
        if (hasRole(ROLE_OWNER, msg.sender)) {
            _setRoleAdmin(ROLE_ADMIN, ROLE_OWNER);
            super.revokeRole(role, account);
            _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);
        } else if (hasRole(ROLE_ADMIN, msg.sender)) {
            super.revokeRole(role, account);
        }
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role` or if caller is not sender.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkSufficientRole(bytes32 role, address account) internal view {
        if (
            !hasRole(getRoleAdmin(role), account) &&
            !hasRole(ROLE_OWNER, account)
        ) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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


// File @openzeppelin/contracts/token/ERC20/[email protected]


pragma solidity ^0.8.0;



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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
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


// File contracts/others/TokenLocker.sol


pragma solidity ^0.8.0;


contract TokenLocker {
    using SafeMath for uint256;

    address owner;

    struct TokenLock {
        address tokenAddress;
        uint256 lockDate; // the date the token was locked
        uint256 amount; // the amount of tokens locked
        uint256 unlockDate; // the date the token can be withdrawn
        uint256 lockID; // lockID nonce per uni pair
        address owner;
        bool retrieved; // false if lock already retreieved
    }

    // Mapping of user to their locks
    mapping(address => mapping(uint256 => TokenLock)) public locks;

    // Num of locks for each user
    mapping(address => uint256) public numLocks;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function lockTokens(
        address tokenAddress,
        uint256 amount,
        uint256 time
    ) external returns (bool) {
        ERC20 token = ERC20(tokenAddress);
        TokenLock memory tokenLock;
        tokenLock.tokenAddress = tokenAddress;
        tokenLock.lockDate = block.timestamp;
        tokenLock.amount = amount;
        tokenLock.unlockDate = block.timestamp.add(time);
        tokenLock.lockID = numLocks[msg.sender];
        tokenLock.owner = msg.sender;
        tokenLock.retrieved = false;

        // Transferring token to smart contract
        token.transferFrom(msg.sender, address(this), amount);

        locks[msg.sender][numLocks[msg.sender]] = tokenLock;
        numLocks[msg.sender]++;

        return true;
    }

    function getLock(uint256 lockId)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            address,
            bool
        )
    {
        return (
            locks[msg.sender][lockId].tokenAddress,
            locks[msg.sender][lockId].lockDate,
            locks[msg.sender][lockId].amount,
            locks[msg.sender][lockId].unlockDate,
            locks[msg.sender][lockId].lockID,
            locks[msg.sender][lockId].owner,
            locks[msg.sender][lockId].retrieved
        );
    }

    function getNumLocks() external view returns (uint256) {
        return numLocks[msg.sender];
    }

    function unlockTokens(uint256 lockId) external returns (bool) {
        // Make sure lock exists
        require(lockId < numLocks[msg.sender], "Lock doesn't exist");
        // Make sure lock is still locked
        require(
            locks[msg.sender][lockId].retrieved == false,
            "Lock was already unlocked"
        );
        // Make sure tokens can be unlocked
        require(
            locks[msg.sender][lockId].unlockDate <= block.timestamp,
            "Tokens can't be unlocked yet"
        );

        ERC20 token = ERC20(locks[msg.sender][lockId].tokenAddress);
        token.transfer(msg.sender, locks[msg.sender][lockId].amount);
        locks[msg.sender][lockId].retrieved = true;

        return true;
    }

    function changeOwner(address newOwner, uint256 lockId)
        external
        returns (bool)
    {
        // Make sure lock exists
        require(lockId < numLocks[msg.sender], "Lock doesn't exist");
        // Make sure lock is still locked
        require(
            locks[msg.sender][lockId].retrieved == false,
            "Lock was already unlocked"
        );

        TokenLock memory tokenLock;
        tokenLock.tokenAddress = locks[msg.sender][lockId].tokenAddress;
        tokenLock.lockDate = locks[msg.sender][lockId].lockDate;
        tokenLock.amount = locks[msg.sender][lockId].amount;
        tokenLock.unlockDate = locks[msg.sender][lockId].unlockDate;
        tokenLock.lockID = numLocks[newOwner];
        tokenLock.owner = newOwner;
        tokenLock.retrieved = false;

        locks[newOwner][numLocks[newOwner]] = tokenLock;
        numLocks[newOwner]++;

        // If lock ownership is transferred its retrieved
        locks[msg.sender][lockId].retrieved = true;
    }
}


// File contracts/test/TestERC20.sol

pragma solidity ^0.8.0;


contract Token is ERC20 {

    constructor(uint256 initialSupplyMantissa) ERC20("Media Eye", "EYE") {
        _mint(msg.sender, initialSupplyMantissa);
    }

    function mint(address mintTo, uint256 mintAmountMantissa) external {
        _mint(mintTo, mintAmountMantissa);
    }
}


// File contracts/libraries/TestOrders.sol

pragma solidity ^0.8.0;

library TestOrders {
    enum NftTokenType {
        ERC1155,
        ERC721
    }

    struct Listing {
        uint256 listingId;
        Nft[] nfts;
        string label;
        address payable seller;
        uint256 timestamp;
        Split split;
    }

    struct Split {
        address payable recipient;
        uint256 splitBasisPoint;
        address payable charity;
        uint256 charityBasisPoint;
    }

    struct ListingPayment {
        address paymentMethod;
        uint256 price;
    }

    struct Nft {
        NftTokenType nftTokenType;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 nftNumTokens;
    }
}


// File contracts/test/TestList.sol

pragma solidity ^0.8.0;











contract TestList is
    ERC721Holder,
    ERC1155Holder,
    AccessControl,
    ReentrancyGuard
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using TestOrders for TestOrders.Listing;
    using TestOrders for TestOrders.Split;
    using TestOrders for TestOrders.ListingPayment;

    Counters.Counter private _listingIds;
    mapping(uint256 => TestOrders.Listing) public listings;

    enum NftTokenType {
        ERC1155,
        ERC721
    }

    struct Nft {
        NftTokenType nftTokenType;
        address nftTokenAddress;
        uint256 nftTokenId;
        uint256 nftNumTokens;
    }

    event ListingCreated(
        TestOrders.Listing listing,
        TestOrders.ListingPayment[] listingPayments
    );

    event TestEmit(uint256 one, uint256 two, uint256 three);

    event TestEmit2(Nft nft);

    event TestEmit3(Nft[] nfts);

    struct ListingPayment {
        address paymentMethod;
        uint256 price;
    }

    event TestEmitPayment1(ListingPayment[] listingPayments);

    event TestEmitPayment2(ListingPayment listingPayment);

    function testEmit() external {
        emit TestEmit(1, 2, 3);
    }

    function testEmit2(Nft[] memory _nfts) external {
        emit TestEmit2(_nfts[0]);
    }

    function testEmit3(Nft[] memory _nfts) external {
        emit TestEmit3(_nfts);
    }

    // function createListing(
    //     string calldata _label,
    //     Nft[] memory _nfts,
    //     TestOrders.ListingPayment[] memory _listingPayments,
    //     TestOrders.Split memory _split
    // ) external nonReentrant {
    //     require(_listingPayments.length > 0 && _nfts.length > 0, "length");

    //     uint256 listingId = _listingIds.current();
    //     TestOrders.Listing storage listing = listings[listingId];

    //     for (uint256 i = 0; i < _nfts.length; i++) {
    //         listing.nfts.push(_nfts[i]);
    //     }

    //     listing.listingId = listingId;
    //     listing.label = _label;
    //     listing.seller = payable(msg.sender);
    //     listing.timestamp = block.timestamp;
    //     listing.split = _split;

    //     _listingIds.increment();

    //     emit ListingCreated(listings[listingId], _listingPayments);
    // }

    // override supportsInterface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Receiver, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


contract ERC1155AirDrop {
    address payable owner;
    bytes32 public merkleRoot;
    bool public cancelable;
    bool isInitialized = false;

    // address of contract, having "transfer" function
    // airdrop contract must have ENOUGH TOKENS in its balance to perform transfer
    IERC1155 tokenContract;

    // fix already minted addresses
    mapping(address => mapping(uint256 => bool)) public spent;
    event AirdropTransfer(address addr, uint256 id, uint256 num);

    modifier isCancelable() {
        require(cancelable, "forbidden action");
        _;
    }

    function initialize(
        address _owner,
        address _tokenContract,
        bytes32 _merkleRoot,
        bool _cancelable
    ) external {
        require(!isInitialized, "Airdrop already initialized!");

        owner = payable(_owner);
        tokenContract = IERC1155(_tokenContract);
        merkleRoot = _merkleRoot;
        cancelable = _cancelable;

        isInitialized = true;
    }

    function setRoot(bytes32 _merkleRoot) external {
        require(msg.sender == owner);
        merkleRoot = _merkleRoot;
    }

    function contractTokenBalance(uint256 id) external view returns (uint256) {
        return tokenContract.balanceOf(address(this), id);
    }

    function selfDestruct() external isCancelable returns (bool) {
        // only owner
        require(msg.sender == owner);
        selfdestruct(owner);
        return true;
    }

    function addressToAsciiString(address x)
        internal
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(40);
        uint256 x_int = uint256(uint160(address(x)));

        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(x_int / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uintToStr(uint256 i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
            bstr[(k--) - 1] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }

    function leafFromAddressTokenIdsAndAmount(
        address _account,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) internal pure returns (bytes32) {
        require(
            _tokenIds.length == _amounts.length,
            "tokenIds and amounts length mismatch"
        );

        bytes memory leaf = "";
        string memory prefix = "0x";
        string memory space = " ";
        string memory comma = ",";

        // file with addresses and tokens have this format: "0x123...DEF 999 666",
        // where 999 - token id and 666 - num tokens
        // function simply calculates hash of such a string, given the target
        // address, token ids and num tokens

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            leaf = abi.encodePacked(
                leaf,
                leaf.length > 2 ? comma : "",
                prefix,
                addressToAsciiString(_account),
                space,
                uintToStr(_tokenIds[i]),
                space,
                uintToStr(_amounts[i])
            );
        }

        return bytes32(sha256(leaf));
    }

    // function bytes32ToString(bytes32 _bytes32)
    //     public
    //     pure
    //     returns (string memory)
    // {
    //     uint8 i = 0;
    //     while (i < 32 && _bytes32[i] != 0) {
    //         i++;
    //     }
    //     bytes memory bytesArray = new bytes(i);
    //     for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
    //         bytesArray[i] = _bytes32[i];
    //     }
    //     return string(bytesArray);
    // }

    function getTokensByMerkleProof(
        bytes32[] memory _proof,
        address _who,
        uint256[] calldata _tokenIds,
        uint256[] calldata _amounts
    ) external returns (bool success) {
        require(
            _tokenIds.length == _amounts.length,
            "tokenIds and amounts length mismatch"
        );
        // require(msg.sender = _who); // makes not possible to mint tokens for somebody, uncomment for more strict version

        if (
            !checkProof(
                _proof,
                leafFromAddressTokenIdsAndAmount(_who, _tokenIds, _amounts)
            )
        ) {
            // throw if proof check fails, no need to spend gaz
            require(false, "Invalid proof");
            // return false;
        }

        tokenContract.safeBatchTransferFrom(
            owner,
            _who,
            _tokenIds,
            _amounts,
            ""
        );

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(spent[_who][_tokenIds[i]] == false);
            spent[_who][_tokenIds[i]] = true;
            emit AirdropTransfer(_who, _tokenIds[i], _amounts[i]);
        }
        return true;
    }

    function checkProof(bytes32[] memory proof, bytes32 hash)
        internal
        view
        returns (bool)
    {
        bytes32 el;
        bytes32 h = hash;

        for (
            uint256 i = 0;
            proof.length != 0 && i <= proof.length - 1;
            i += 1
        ) {
            el = proof[i];

            if (h < el) {
                h = sha256(abi.encodePacked(h, el));
            } else {
                h = sha256(abi.encodePacked(el, h));
            }
        }

        return h == merkleRoot;
    }
}


// File contracts/Airdrops/ERC20AirDrop.sol

/**
 * Copyright (C) 2018  Smartz, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
 */

pragma solidity ^0.8.0;

contract ERC20AirDrop {
    address payable owner;
    bytes32 public merkleRoot;
    bool public cancelable;
    bool isInitialized = false;

    // address of contract, having "transfer" function
    // airdrop contract must have ENOUGH TOKENS in its balance to perform transfer
    IERC20 tokenContract;

    // fix already minted addresses
    mapping(address => bool) public spent;
    event AirdropTransfer(address addr, uint256 num);

    modifier isCancelable() {
        require(cancelable, "forbidden action");
        _;
    }

    function initialize(
        address _owner,
        address _tokenContract,
        bytes32 _merkleRoot,
        bool _cancelable
    ) external {
        require(!isInitialized, "Airdrop already initialized!");

        owner = payable(_owner);
        tokenContract = IERC20(_tokenContract);
        merkleRoot = _merkleRoot;
        cancelable = _cancelable;

        isInitialized = true;
    }

    function setRoot(bytes32 _merkleRoot) external {
        require(msg.sender == owner);
        merkleRoot = _merkleRoot;
    }

    function contractTokenBalance() external view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }

    function claimRestOfTokensAndSelfDestruct()
        external
        isCancelable
        returns (bool)
    {
        // only owner
        require(msg.sender == owner);
        // require(tokenContract.balanceOf(address(this)) >= 0);
        require(
            tokenContract.transfer(
                owner,
                tokenContract.balanceOf(address(this))
            )
        );
        selfdestruct(owner);
        return true;
    }

    function addressToAsciiString(address x)
        internal
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(40);
        uint256 x_int = uint256(uint160(address(x)));

        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(x_int / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uintToStr(uint256 i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
            bstr[(k--) - 1] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }

    function leafFromAddressAndNumTokens(address _account, uint256 _amount)
        internal
        pure
        returns (bytes32)
    {
        string memory prefix = "0x";
        string memory space = " ";

        // file with addresses and tokens have this format: "0x123...DEF 999",
        // where 999 - num tokens
        // function simply calculates hash of such a string, given the target
        // address and num tokens

        bytes memory leaf =
            abi.encodePacked(
                prefix,
                addressToAsciiString(_account),
                space,
                uintToStr(_amount)
            );

        return bytes32(sha256(leaf));
    }

    // function bytes32ToString(bytes32 _bytes32)
    //     public
    //     pure
    //     returns (string memory)
    // {
    //     uint8 i = 0;
    //     while (i < 32 && _bytes32[i] != 0) {
    //         i++;
    //     }
    //     bytes memory bytesArray = new bytes(i);
    //     for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
    //         bytesArray[i] = _bytes32[i];
    //     }
    //     return string(bytesArray);
    // }

    function getTokensByMerkleProof(
        bytes32[] memory _proof,
        address _who,
        uint256 _amount
    ) external returns (bool success) {
        require(spent[_who] != true);
        require(_amount > 0);
        // require(msg.sender = _who); // makes not possible to mint tokens for somebody, uncomment for more strict version

        if (!checkProof(_proof, leafFromAddressAndNumTokens(_who, _amount))) {
            // throw if proof check fails, no need to spend gaz
            require(false, "Invalid proof");
            // return false;
        }

        spent[_who] = true;

        if (tokenContract.transferFrom(owner, _who, _amount) == true) {
            emit AirdropTransfer(_who, _amount);
            return true;
        }
        // throw if transfer fails, no need to spend gaz
        require(false);
    }

    function checkProof(bytes32[] memory proof, bytes32 hash)
        internal
        view
        returns (bool)
    {
        bytes32 el;
        bytes32 h = hash;

        for (
            uint256 i = 0;
            proof.length != 0 && i <= proof.length - 1;
            i += 1
        ) {
            el = proof[i];

            if (h < el) {
                h = sha256(abi.encodePacked(h, el));
            } else {
                h = sha256(abi.encodePacked(el, h));
            }
        }

        return h == merkleRoot;
    }
}


// File contracts/Airdrops/ERC721AirDrop.sol

pragma solidity ^0.8.0;

contract ERC721AirDrop {
    address payable owner;
    bytes32 public merkleRoot;
    bool public cancelable;
    bool isInitialized = false;

    // address of contract, having "transfer" function
    // airdrop contract must have ENOUGH TOKENS in its balance to perform transfer
    IERC721 tokenContract;

    // fix already minted addresses
    mapping(address => mapping(uint256 => bool)) public spent;
    event AirdropTransfer(address addr, uint256 num);

    modifier isCancelable() {
        require(cancelable, "forbidden action");
        _;
    }

    function initialize(
        address _owner,
        address _tokenContract,
        bytes32 _merkleRoot,
        bool _cancelable
    ) external {
        require(!isInitialized, "Airdrop already initialized!");

        owner = payable(_owner);
        tokenContract = IERC721(_tokenContract);
        merkleRoot = _merkleRoot;
        cancelable = _cancelable;

        isInitialized = true;
    }

    function setRoot(bytes32 _merkleRoot) external {
        require(msg.sender == owner);
        merkleRoot = _merkleRoot;
    }

    function contractTokenBalance() external view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }

    function selfDestruct() external isCancelable returns (bool) {
        // only owner
        require(msg.sender == owner);
        selfdestruct(owner);
        return true;
    }

    function addressToAsciiString(address x)
        internal
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(40);
        uint256 x_int = uint256(uint160(address(x)));

        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(x_int / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function uintToStr(uint256 i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
            bstr[(k--) - 1] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }
        return string(bstr);
    }

    function leafFromAddressAndTokenId(address _account, uint256 _tokenId)
        internal
        pure
        returns (bytes32)
    {
        string memory prefix = "0x";
        string memory space = " ";

        // file with addresses and tokens have this format: "0x123...DEF 999",
        // where 999 - token id
        // function simply calculates hash of such a string, given the target
        // address and token id

        bytes memory leaf =
            abi.encodePacked(
                prefix,
                addressToAsciiString(_account),
                space,
                uintToStr(_tokenId)
            );

        return bytes32(sha256(leaf));
    }

    // function bytes32ToString(bytes32 _bytes32)
    //     public
    //     pure
    //     returns (string memory)
    // {
    //     uint8 i = 0;
    //     while (i < 32 && _bytes32[i] != 0) {
    //         i++;
    //     }
    //     bytes memory bytesArray = new bytes(i);
    //     for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
    //         bytesArray[i] = _bytes32[i];
    //     }
    //     return string(bytesArray);
    // }

    function getTokensByMerkleProof(
        bytes32[] memory _proof,
        address _who,
        uint256 _tokenId
    ) external returns (bool success) {
        require(spent[_who][_tokenId] == false);
        // require(msg.sender = _who); // makes not possible to mint tokens for somebody, uncomment for more strict version

        if (!checkProof(_proof, leafFromAddressAndTokenId(_who, _tokenId))) {
            // throw if proof check fails, no need to spend gaz
            require(false, "Invalid proof");
            // return false;
        }

        spent[_who][_tokenId] = true;

        tokenContract.safeTransferFrom(owner, _who, _tokenId);
        emit AirdropTransfer(_who, _tokenId);
        return true;
    }

    function checkProof(bytes32[] memory proof, bytes32 hash)
        internal
        view
        returns (bool)
    {
        bytes32 el;
        bytes32 h = hash;

        for (
            uint256 i = 0;
            proof.length != 0 && i <= proof.length - 1;
            i += 1
        ) {
            el = proof[i];

            if (h < el) {
                h = sha256(abi.encodePacked(h, el));
            } else {
                h = sha256(abi.encodePacked(el, h));
            }
        }

        return h == merkleRoot;
    }
}


// File contracts/amb/MediaEyeForeignMediator.sol

pragma solidity ^0.8.0;



contract MediaEyeForeignMediator {
    address public bridge;
    address public xdaiMediator;
    address public mediaEyeSubscription;
    address public admin;
    uint256 public gasLimit;
    uint256 public sendCounter;
    uint256 public receiveCounter;

    modifier adminOnly() {
        require(
            msg.sender == admin,
            "GovernanceSenderMediator::adminOnly: can only be called by admin"
        );
        _;
    }

    modifier onlyBridgeReceive() {
        require(
            msg.sender == bridge,
            "GovernanceReceiverMediator::executeTransaction: Call must come from bridge"
        );
        require(
            IAMB(bridge).messageSender() == xdaiMediator,
            "GovernanceReceiverMediator::queueTransaction: Call must come from mediator"
        );
        _;
    }

    modifier onlySubscription() {
        require(
            msg.sender == mediaEyeSubscription,
            "GovernanceReceiverMediator::executeTransaction: Call must come from media eye subscription"
        );
        _;
    }

    constructor(address _admin) {
        admin = _admin;
    }

    function init(
        address _bridge,
        address _xdaiMediator,
        address _mediaEyeSubscription
    ) external {
        bridge = _bridge;
        xdaiMediator = _xdaiMediator;
        mediaEyeSubscription = _mediaEyeSubscription;
        gasLimit = IAMB(bridge).maxGasPerTx() - 1;
    }

    function setMediaEyeSubscription(address _mediaEyeSubscription)
        external
        adminOnly
    {
        mediaEyeSubscription = _mediaEyeSubscription;
    }

    function setXdaiContract(address _xdaiContract) external adminOnly {
        xdaiMediator = _xdaiContract;
    }

    function setBridgeContract(address _bridge) external adminOnly {
        bridge = _bridge;
    }

    function setGasLimit(uint256 _gasLimit) external adminOnly {
        gasLimit = _gasLimit;
    }

    function subscribeByMediator(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlySubscription {
        bytes4 methodSelector = IMediaEyeSubRecieverMed(address(0))
            .subscribeFromForeignRelay
            .selector;
        bytes memory data = abi.encodeWithSelector(
            methodSelector,
            account,
            startTimestamp,
            endTimestamp,
            tier
        );
        IAMB(bridge).requireToPassMessage(xdaiMediator, data, gasLimit);
        sendCounter++;
    }

    function subscribeByBridge(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlyBridgeReceive {
        IMediaEyeSubscription(mediaEyeSubscription).subscribeByBridge(
            account,
            startTimestamp,
            endTimestamp,
            tier
        );
        receiveCounter++;
    }
}


// File contracts/amb/MediaEyeHomeMediator.sol

pragma solidity ^0.8.0;

interface IMediaEyeSubRecieverMed {
    function subscribeFromHomeRelay(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external;
    function subscribeFromForeignRelay(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external;
    function subscribeByBridge(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external;
}

interface IMediaEyeSubscription {
    function subscribeByBridge(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external;

    // function testCounter(
    //     address account,
    //     uint256 startTimestamp,
    //     uint256 endTimestamp
    // ) external;
}



contract MediaEyeHomeMediator {
    address public bridge;
    address public xdaiMediator;
    address public mediaEyeSubscription;
    address public admin;
    uint256 public gasLimit;
    uint256 public sendCounter;
    uint256 public receiveCounter;

    modifier adminOnly() {
        require(
            msg.sender == admin,
            "GovernanceSenderMediator::adminOnly: can only be called by admin"
        );
        _;
    }

    modifier onlyBridgeReceive() {
        require(
            msg.sender == bridge,
            "GovernanceReceiverMediator::executeTransaction: Call must come from bridge"
        );
        // require(
        //     IAMB(bridge).messageSender() == xdaiMediator,
        //     "GovernanceReceiverMediator::queueTransaction: Call must come from mediator"
        // );
        _;
    }

    modifier onlySubscription() {
        require(
            msg.sender == mediaEyeSubscription,
            "GovernanceReceiverMediator::executeTransaction: Call must come from media eye subscription"
        );
        _;
    }

    constructor(address _admin) {
        admin = _admin;
    }

    function init(
        address _bridge,
        address _xdaiMediator,
        address _mediaEyeSubscription
    ) external {
        bridge = _bridge;
        xdaiMediator = _xdaiMediator;
        mediaEyeSubscription = _mediaEyeSubscription;
        gasLimit = IAMB(bridge).maxGasPerTx() - 1;
    }

    function setMediaEyeSubscription(address _mediaEyeSubscription)
        external
        adminOnly
    {
        mediaEyeSubscription = _mediaEyeSubscription;
    }

    function setXdaiContract(address _xdaiContract) external adminOnly {
        xdaiMediator = _xdaiContract;
    }

    function setBridgeContract(address _bridge) external adminOnly {
        bridge = _bridge;
    }

    function setGasLimit(uint256 _gasLimit) external adminOnly {
        gasLimit = _gasLimit;
    }

    function subscribeByMediator(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlySubscription {
        bytes4 methodSelector = IMediaEyeSubRecieverMed(address(0))
            .subscribeFromHomeRelay
            .selector;
        // bytes4 methodSelector = IMediaEyeSubscription(address(0)).testCounter.selector;
        bytes memory data = abi.encodeWithSelector(
            methodSelector,
            account,
            startTimestamp,
            endTimestamp,
            tier
        );
        IAMB(bridge).requireToPassMessage(xdaiMediator, data, gasLimit);
        sendCounter++;
    }

    function subscribeByBridge(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlyBridgeReceive {
        IMediaEyeSubscription(mediaEyeSubscription).subscribeByBridge(
            account,
            startTimestamp,
            endTimestamp,
            tier
        );
        receiveCounter++;
    }
}


// File contracts/amb/MediaEyeXdaiMediator.sol

pragma solidity ^0.8.0;



contract MediaEyeXdaiMediator {
    address public bridge;
    address public mediatorOnHomeSide;
    address public mediatorOnForeignSide;
    address public invoker;
    address public admin;
    uint256 public gasLimit;
    uint256 public homeCounter;
    uint256 public foreignCounter;
    // uint256 public counter;

    struct Subscription {
        address account;
        uint256 startTimestamp;
        uint256 endTimestamp;
        bool tier;
        Chain chain;
    }

    enum Chain {
        Home,
        Foreign
    }

    Subscription[] public subscriptions;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Sender is not admin");
        _;
    }

    modifier onlyInvoker() {
        require(msg.sender == invoker, "Sender is not Invoker");
        _;
    }

    modifier onlyBridgeFromHome() {
        require(
            msg.sender == bridge,
            "GovernanceReceiverMediator::executeTransaction: Call must come from bridge"
        );
        // require(
        //     IAMB(bridge).messageSender() == mediatorOnHomeSide,
        //     "GovernanceReceiverMediator::queueTransaction: Call must come from mediator"
        // );
        _;
    }

    modifier onlyBridgeFromForeign() {
        require(
            msg.sender == bridge,
            "GovernanceReceiverMediator::executeTransaction: Call must come from bridge"
        );
        // require(
        //     IAMB(bridge).messageSender() == mediatorOnForeignSide,
        //     "GovernanceReceiverMediator::queueTransaction: Call must come from mediator"
        // );
        _;
    }

    constructor(address _admin, address _invoker) {
        admin = _admin;
        invoker = _invoker;
    }

    function getAllSubscriptions() external view returns (Subscription[] memory) {
        return subscriptions;
    }

    function init(
        address _bridge,
        address _mediatorOnHomeSide,
        address _mediatorOnForeignSide
    ) external {
        bridge = _bridge;
        mediatorOnHomeSide = _mediatorOnHomeSide;
        mediatorOnForeignSide = _mediatorOnForeignSide;
        gasLimit = IAMB(bridge).maxGasPerTx() - 1;
    }

    function setHomeMediatorContract(address _mediatorOnHomeSide)
        external
        onlyAdmin
    {
        mediatorOnHomeSide = _mediatorOnHomeSide;
    }

    function setForeignMediatorContract(address _mediatorOnForeignSide)
        external
        onlyAdmin
    {
        mediatorOnForeignSide = _mediatorOnForeignSide;
    }

    function setBridgeContract(address _bridge) external onlyAdmin {
        bridge = _bridge;
    }

    function setGasLimit(uint256 _gasLimit) external onlyAdmin {
        gasLimit = _gasLimit;
    }

    function setInvoker(address _invoker) external onlyAdmin {
        invoker = _invoker;
    }

    // function testCounter(
    //     address account,
    //     uint256 startTimestamp,
    //     uint256 endTimestamp
    // ) external {
    //     counter++;
    // }

    function subscribeFromHomeRelay(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlyBridgeFromHome {
        homeCounter++;
        subscriptions.push(
            Subscription(
                account,
                startTimestamp,
                endTimestamp,
                tier,
                Chain.Home
            )
        );
    }

    function subscribeFromForeignRelay(
        address account,
        uint256 startTimestamp,
        uint256 endTimestamp,
        bool tier
    ) external onlyBridgeFromForeign {
        foreignCounter++;
        subscriptions.push(
            Subscription(
                account,
                startTimestamp,
                endTimestamp,
                tier,
                Chain.Foreign
            )
        );
    }

    function invokeSubscribe() external {
        bytes4 methodSelector = IMediaEyeSubRecieverMed(address(0))
            .subscribeByBridge
            .selector;
        bytes memory data;
        for (uint256 i = 0; i < subscriptions.length; i++) {
            data = abi.encodeWithSelector(
                methodSelector,
                subscriptions[i].account,
                subscriptions[i].startTimestamp,
                subscriptions[i].endTimestamp,
                subscriptions[i].tier
            );
            if (subscriptions[i].chain == Chain.Home) {
                IAMB(bridge).requireToPassMessage(
                    mediatorOnForeignSide,
                    data,
                    gasLimit
                );
            } else {
                IAMB(bridge).requireToPassMessage(
                    mediatorOnHomeSide,
                    data,
                    gasLimit
                );
            }
        }
        delete subscriptions;
    }
}


// File contracts/interfaces/IAMB.sol

pragma solidity ^0.8.0;

interface IAMB {
    function messageSender() external view returns (address);

    function maxGasPerTx() external view returns (uint256);

    function transactionHash() external view returns (bytes32);

    function messageId() external view returns (bytes32);

    function messageSourceChainId() external view returns (bytes32);

    function messageCallStatus(bytes32 _messageId) external view returns (bool);

    function failedMessageDataHash(bytes32 _messageId)
        external
        view
        returns (bytes32);

    function failedMessageReceiver(bytes32 _messageId)
        external
        view
        returns (address);

    function failedMessageSender(bytes32 _messageId)
        external
        view
        returns (address);

    function requireToPassMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);

    function requireToConfirmMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);

    function sourceChainId() external view returns (uint256);

    function destinationChainId() external view returns (uint256);
}