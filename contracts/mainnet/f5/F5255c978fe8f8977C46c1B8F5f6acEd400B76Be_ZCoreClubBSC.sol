// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.6.0) (utils/cryptography/MerkleProof.sol)
pragma solidity 0.6.12;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 *
 * WARNING: You should avoid using leaf values that are 64 bytes long prior to
 * hashing, or use a hash function other than keccak256 for hashing leaves.
 * This is because the concatenation of a sorted pair of internal nodes in
 * the merkle tree could be reinterpreted as a leaf value.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    /**
     * @dev Returns true if a `leafs` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, `proofs` for each leaf must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Then
     * 'proofFlag' designates the nodes needed for the multi proof.
     *
     * _Available since v4.7._
     */
    function multiProofVerify(
        bytes32 root,
        bytes32[] memory leafs,
        bytes32[] memory proofs,
        bool[] memory proofFlag
    ) internal pure returns (bool) {
        return processMultiProof(leafs, proofs, proofFlag) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merkle tree up
     * from `leaf` using the multi proof as `proofFlag`. A multi proof is
     * valid if the final hash matches the root of the tree.
     *
     * _Available since v4.7._
     */
    function processMultiProof(
        bytes32[] memory leafs,
        bytes32[] memory proofs,
        bool[] memory proofFlag
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leafs` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leafsLen = leafs.length;
        uint256 proofsLen = proofs.length;
        uint256 totalHashes = proofFlag.length;

        // Check proof validity.
        require(leafsLen + proofsLen - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proofs` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leafsLen ? leafs[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlag[i] ? leafPos < leafsLen ? leafs[leafPos++] : hashes[hashPos++] : proofs[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        return hashes[totalHashes - 1];
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

pragma solidity 0.6.12;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity 0.6.12;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

pragma solidity ^0.6.2;

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
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.6.0;

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


pragma solidity 0.6.12;

interface ZCoreWhitelist {
      function isUserWhiteListed(address _user) external view returns (bool);
}

pragma solidity 0.6.12;

interface IUniswapRouterETH {

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
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
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
        ) external payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


pragma solidity 0.6.12;

contract ZCoreClubBSC is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event Minted(address indexed User, uint256 Amount);
    event MintedEth(address indexed User, uint256 Amount, bytes32 indexed Hash);
    
    bytes32 public merkleRoot;
    mapping(address => uint) public users;
    mapping(address => uint) public usersMinted;
    mapping(address => bool) public whitelistClaimed;
    mapping(address => uint) public referrals;

    address public whitelist = address(0x4049e37DdE0d61aDB6DB94b18966b9319e65E487); // whitelist    
    address public dev = address(0x7F221FAFAb5B01E43e400CF640630FF0E561A7eC); // dev

    uint public MAX_BUY = 10000; // MAX BUY
    uint256 public ZEFI_PRICE = 3000000000000000000000;
    uint256 public REF_GAIN = 1000000000000000;
    address constant public zefi = address(0x0288D3E353fE2299F11eA2c2e1696b4A648eCC07); // ZEFI
    address constant public dead = address(0x000000000000000000000000000000000000dEaD); // burn

    address constant public noref = address(0x0000000000000000000000000000000000000000);

    address constant public zbo = address(0x7D3550d0B0aC3590834cA6103907CD6Dd41318f8);
    address constant public eth = address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
    address constant public wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address constant public busd = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address constant public unirouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Pancakeswap v2



    uint public totalSold = 0;
    uint public totalMintedEth = 0;
    bool public paused = false;
    bool public whitelistMintEnabled = false;


    constructor() public {
        IERC20(zefi).safeApprove(unirouter, uint(-1));
        IERC20(eth).safeApprove(unirouter, uint(-1));
        IERC20(wbnb).safeApprove(unirouter, uint(-1));
    }


    function getPriceUsd(address _want, uint256 _amount) external view returns(uint){

        address[] memory path;
            path = new address[](3);
            path[0] = _want;
            path[1] = wbnb;
            path[2] = busd;

        uint256[] memory _amounts = IUniswapRouterETH(unirouter).getAmountsOut(_amount, path);
        uint256 _token_price = _amounts[2];

        return _token_price;

    }


    function getPriceWithToken(address _want, uint256 _amount) external view returns(uint){

        address[] memory path;
            path = new address[](3);
            path[0] = _want;
            path[1] = wbnb;
            path[2] = zefi;

        uint256 _value = ZEFI_PRICE.mul(_amount);
        uint256[] memory _amounts = IUniswapRouterETH(unirouter).getAmountsIn(_value, path);
        uint256 _token_price = _amounts[0];

        return _token_price;
        
    }


    function buy(uint256 _amount, address _referral) public {
        require(!paused, "The contract is paused!");
        require(!whitelistMintEnabled, "The whitelist sale is enabled!");

        uint userbuy = users[msg.sender];
        require((userbuy + _amount) <= MAX_BUY, "MAX BUY: Maximum allowed per wallet exceeded!");

        uint256 _value = 0;

        _value = ZEFI_PRICE.mul(_amount);
        IERC20(zefi).safeTransferFrom(msg.sender, address(this), _value);


        /* 50% ZEFI     : burn */
        /* 50% buy ETH  : pay fees to mint NFT */

        if(_referral == noref){

            uint256 _zefiBal = IERC20(zefi).balanceOf(address(this));
            address[] memory pathEth;
                pathEth = new address[](3);
                pathEth[0] = zefi;
                pathEth[1] = wbnb;
                pathEth[2] = eth;
            IUniswapRouterETH(unirouter).swapExactTokensForTokens(_zefiBal.mul(1000).div(2000), 0, pathEth, dev, block.timestamp);

        }else{


            uint256 _zefiBal = IERC20(zefi).balanceOf(address(this));
            address[] memory pathEth;
                pathEth = new address[](3);
                pathEth[0] = zefi;
                pathEth[1] = wbnb;
                pathEth[2] = eth;
            IUniswapRouterETH(unirouter).swapExactTokensForTokens(_zefiBal.mul(1000).div(2000), 0, pathEth, address(this), block.timestamp);

            IERC20(eth).safeTransfer(_referral, REF_GAIN.mul(_amount));
            uint thisref = referrals[_referral];
            referrals[_referral] = thisref + _amount;            
            uint256 _newEthBalA = IERC20(eth).balanceOf(address(this));
            IERC20(eth).safeTransfer(dev, _newEthBalA);

        }

        uint256 _newZefiBal = IERC20(zefi).balanceOf(address(this));
        IERC20(zefi).safeTransfer(dead, _newZefiBal);
        
        users[msg.sender] = userbuy + _amount;
        totalSold = totalSold + _amount;

        emit Minted(msg.sender, _amount);
    }



    function buyWithToken(address _want, uint256 _amount, address _referral) public {
        require(!paused, "The contract is paused!");
        require(!whitelistMintEnabled, "The whitelist sale is enabled!");

        if(IERC20(_want).allowance(address(this), unirouter) == 0){
            IERC20(_want).safeApprove(unirouter, uint(-1));
        }

        uint userbuy = users[msg.sender];
        require((userbuy + _amount) <= MAX_BUY, "MAX BUY: Maximum allowed per wallet exceeded!");


        address[] memory path;
            path = new address[](3);
            path[0] = _want;
            path[1] = wbnb;
            path[2] = zefi;

        uint256 _value = ZEFI_PRICE.mul(_amount);
        uint[] memory _amounts = IUniswapRouterETH(unirouter).getAmountsIn(_value, path);
        uint256 _token_price = _amounts[0];
        
        IERC20(_want).safeTransferFrom(msg.sender, address(this), _token_price);
        


        /* 50% buy ZEFI : burn */
        /* 50% buy ETH  : pay fees to mint NFT */
        uint256 _wantBal = IERC20(_want).balanceOf(address(this));
        address[] memory pathWbnb;
            pathWbnb = new address[](2);
            pathWbnb[0] = _want;
            pathWbnb[1] = wbnb;
        IUniswapRouterETH(unirouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(_wantBal, 0, pathWbnb, address(this), block.timestamp);


        uint256 _wbnbBal = IERC20(wbnb).balanceOf(address(this));
        address[] memory pathZefi;
            pathZefi = new address[](2);
            pathZefi[0] = wbnb;
            pathZefi[1] = zefi;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_wbnbBal.mul(1000).div(2000), 0, pathZefi, dead, block.timestamp);


if(_referral == noref){
        uint256 _newWbnbBal = IERC20(wbnb).balanceOf(address(this));
        address[] memory pathEth;
            pathEth = new address[](2);
            pathEth[0] = wbnb;
            pathEth[1] = eth;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_newWbnbBal, 0, pathEth, dev, block.timestamp);
}else{
        uint256 _newWbnbBal = IERC20(wbnb).balanceOf(address(this));
        address[] memory pathEth;
            pathEth = new address[](2);
            pathEth[0] = wbnb;
            pathEth[1] = eth;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_newWbnbBal, 0, pathEth, address(this), block.timestamp);
        IERC20(eth).safeTransfer(_referral, REF_GAIN.mul(_amount));
        uint thisref = referrals[_referral];
        referrals[_referral] = thisref + _amount;
        uint256 _newEthBalA = IERC20(eth).balanceOf(address(this));
        IERC20(eth).safeTransfer(dev, _newEthBalA);        
}

        users[msg.sender] = userbuy + _amount;
        totalSold = totalSold + _amount;

        emit Minted(msg.sender, _amount);
    }


    function buyWithZbo(uint256 _amount, address _referral) public {
        require(!paused, "The contract is paused!");
        require(!whitelistMintEnabled, "The whitelist sale is enabled!");

        if(IERC20(zbo).allowance(address(this), unirouter) == 0){
            IERC20(zbo).safeApprove(unirouter, uint(-1));
        }

        uint userbuy = users[msg.sender];
        require((userbuy + _amount) <= MAX_BUY, "MAX BUY: Maximum allowed per wallet exceeded!");


        address[] memory path;
            path = new address[](3);
            path[0] = zbo;
            path[1] = wbnb;
            path[2] = zefi;

        uint256 _value = ZEFI_PRICE.mul(_amount);
        uint[] memory _amounts = IUniswapRouterETH(unirouter).getAmountsIn(_value, path);
        uint256 _token_price = _amounts[0];
        
        IERC20(zbo).safeTransferFrom(msg.sender, address(this), _token_price);
        

        /* 50% buy ZBO : burn */
        /* 50% buy ETH  : pay fees to mint NFT */
        uint256 _wantBal = IERC20(zbo).balanceOf(address(this));
        address[] memory pathWbnb;
            pathWbnb = new address[](2);
            pathWbnb[0] = zbo;
            pathWbnb[1] = wbnb;
        IUniswapRouterETH(unirouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(_wantBal.mul(1000).div(2000), 0, pathWbnb, address(this), block.timestamp);


        uint256 _newWantBal = IERC20(zbo).balanceOf(address(this));
        IERC20(zbo).safeTransfer(dead, _newWantBal);


if(_referral == noref){
        uint256 _newWbnbBal = IERC20(wbnb).balanceOf(address(this));
        address[] memory pathEth;
            pathEth = new address[](2);
            pathEth[0] = wbnb;
            pathEth[1] = eth;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_newWbnbBal, 0, pathEth, dev, block.timestamp);
}else{
        uint256 _newWbnbBal = IERC20(wbnb).balanceOf(address(this));
        address[] memory pathEth;
            pathEth = new address[](2);
            pathEth[0] = wbnb;
            pathEth[1] = eth;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_newWbnbBal, 0, pathEth, address(this), block.timestamp);
        IERC20(eth).safeTransfer(_referral, REF_GAIN.mul(_amount));
        uint thisref = referrals[_referral];
        referrals[_referral] = thisref + _amount;
        uint256 _newEthBalA = IERC20(eth).balanceOf(address(this));
        IERC20(eth).safeTransfer(dev, _newEthBalA);        
}

        users[msg.sender] = userbuy + _amount;
        totalSold = totalSold + _amount;

        emit Minted(msg.sender, _amount);
    }



    function buyWhiteList(uint256 _amount) public {
        
        require(whitelistMintEnabled, "The whitelist sale is not enabled!");
        require(!whitelistClaimed[msg.sender], "Address already claimed!");

        bool _iswhitelist =  ZCoreWhitelist(whitelist).isUserWhiteListed(msg.sender);
        require(_iswhitelist, 'User not is whitelisted!');    
    
        // bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        // require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof!");
        whitelistClaimed[msg.sender] = true;

        uint userbuy = users[msg.sender];
        require((userbuy + _amount) <= MAX_BUY, "MAX BUY: Maximum allowed per wallet exceeded!");

        uint256 _value = 0;

        _value = ZEFI_PRICE.mul(_amount);
        IERC20(zefi).safeTransferFrom(msg.sender, address(this), _value);


        /* 50% ZEFI     : burn */
        /* 50% buy ETH  : pay fees to mint NFT */

        uint256 _zefiBal = IERC20(zefi).balanceOf(address(this));
        address[] memory pathEth;
            pathEth = new address[](3);
            pathEth[0] = zefi;
            pathEth[1] = wbnb;
            pathEth[2] = eth;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_zefiBal.mul(1000).div(2000), 0, pathEth, dev, block.timestamp);

        uint256 _newZefiBal = IERC20(zefi).balanceOf(address(this));
        IERC20(zefi).safeTransfer(dead, _newZefiBal);
        
        users[msg.sender] = userbuy + _amount;
        totalSold = totalSold + _amount;

        emit Minted(msg.sender, _amount);
    }



    function buyWithTokenWhiteList(address _want, uint256 _amount) public {
        
        require(whitelistMintEnabled, "The whitelist sale is not enabled!");
        require(!whitelistClaimed[msg.sender], "Address already claimed!");

        bool _iswhitelist =  ZCoreWhitelist(whitelist).isUserWhiteListed(msg.sender);
        require(_iswhitelist, 'User not is whitelisted!');
        
        // bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        // require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof!");
        whitelistClaimed[msg.sender] = true;

        if(IERC20(_want).allowance(address(this), unirouter) == 0){
            IERC20(_want).safeApprove(unirouter, uint(-1));
        }

        uint userbuy = users[msg.sender];
        require((userbuy + _amount) <= MAX_BUY, "MAX BUY: Maximum allowed per wallet exceeded!");


        address[] memory path;
            path = new address[](3);
            path[0] = _want;
            path[1] = wbnb;
            path[2] = zefi;

        uint256 _value = ZEFI_PRICE.mul(_amount);
        uint[] memory _amounts = IUniswapRouterETH(unirouter).getAmountsIn(_value, path);
        uint256 _token_price = _amounts[0];
        
        IERC20(_want).safeTransferFrom(msg.sender, address(this), _token_price);
        


        /* 50% buy ZEFI : burn */
        /* 50% buy ETH  : pay fees to mint NFT */
        uint256 _wantBal = IERC20(_want).balanceOf(address(this));
        address[] memory pathWbnb;
            pathWbnb = new address[](2);
            pathWbnb[0] = _want;
            pathWbnb[1] = wbnb;
        IUniswapRouterETH(unirouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(_wantBal, 0, pathWbnb, address(this), block.timestamp);


        uint256 _wbnbBal = IERC20(wbnb).balanceOf(address(this));
        address[] memory pathZefi;
            pathZefi = new address[](2);
            pathZefi[0] = wbnb;
            pathZefi[1] = zefi;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_wbnbBal.mul(1000).div(2000), 0, pathZefi, dead, block.timestamp);


        uint256 _newWbnbBal = IERC20(wbnb).balanceOf(address(this));
        address[] memory pathEth;
            pathEth = new address[](2);
            pathEth[0] = wbnb;
            pathEth[1] = eth;
        IUniswapRouterETH(unirouter).swapExactTokensForTokens(_newWbnbBal, 0, pathEth, dev, block.timestamp);        


        users[msg.sender] = userbuy + _amount;
        totalSold = totalSold + _amount;

        emit Minted(msg.sender, _amount);
    }



    function mintETH(uint256[] calldata _mintAmount, address[] calldata _receiver, bytes32 _hash) external onlyOwner {
        require(_mintAmount.length == _receiver.length, "Index: wrong");
        for(uint i = 0; i < _mintAmount.length; i++) {
            uint oldAmount = usersMinted[_receiver[i]];
            usersMinted[_receiver[i]] = oldAmount + _mintAmount[i];
            totalMintedEth = totalMintedEth + _mintAmount[i];
            emit MintedEth(_receiver[i], _mintAmount[i], _hash);
        }
    }  


    function burn() external onlyOwner {
        uint256 zefiBal = IERC20(zefi).balanceOf(address(this));
        if (zefiBal > 0) {
            IERC20(zefi).transfer(dead, zefiBal);
        }          
    }    

    function getUserBuy(address _user) public view returns(uint) {
        return users[_user];
    }


    /**
     * @dev Rescues random funds stuck that the strat can't handle.
     * @param _token address of the token to rescue.
     */
    function inCaseTokensGetStuck(address _token) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, amount);
    }

    function setZefiPrice(uint256 _newprice) external onlyOwner{
        ZEFI_PRICE = _newprice;
    }

    function setRefValue(uint256 _newref) external onlyOwner{
        REF_GAIN = _newref;
    }    

    function setMaxBuy(uint _newbuy) external onlyOwner{
        MAX_BUY = _newbuy;
    }  

    function setDev(address _dev) external onlyOwner{
        dev = _dev;
    }   

    function setWhitelist(address _whitelist) external onlyOwner{
        whitelist = _whitelist;
    }       

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setWhitelistMintEnabled(bool _state) public onlyOwner {
        whitelistMintEnabled = _state;
    }

}