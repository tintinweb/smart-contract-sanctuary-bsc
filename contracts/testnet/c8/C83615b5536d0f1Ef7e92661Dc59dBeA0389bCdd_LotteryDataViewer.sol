/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;



// Part: OpenZeppelin/[email protected]/Address

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

// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

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

// Part: OpenZeppelin/[email protected]/ReentrancyGuard

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

// Part: OpenZeppelin/[email protected]/SafeMath

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// Part: smartcontractkit/[email protected]/VRFConsumerBaseV2

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// Part: smartcontractkit/[email protected]/VRFCoordinatorV2Interface

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// Part: IFountain

interface IFountain is IERC20 {
    function removeLiquidity(
        uint256 amount,
        uint256 min_bnb,
        uint256 min_tokens
    ) external returns (uint256, uint256);

    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 busd_amount
    ) external returns (uint256);

    function txs(address owner) external view returns (uint256);

    function getLiquidityToReserveInputPrice(uint256 amount)
        external
        view
        returns (uint256, uint256);

    function getBnbToLiquidityInputPrice(uint256 bnb_sold)
        external
        view
        returns (uint256, uint256);

    function tokenBalance() external view returns (uint256);

    function bnbBalance() external view returns (uint256);

    function tokenAddress() external view returns (address);

    function getTokenToBnbOutputPrice(uint256 bnb_bought)
        external
        view
        returns (uint256);

    function getTokenToBnbInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256);

    function getBnbToTokenOutputPrice(uint256 tokens_bought)
        external
        view
        returns (uint256);

    function getBnbToTokenInputPrice(uint256 bnb_sold)
        external
        view
        returns (uint256);

    function tokenToBnbSwapOutput(uint256 bnb_bought, uint256 max_tokens)
        external
        returns (uint256);

    function tokenToBnbSwapInput(uint256 tokens_sold, uint256 min_bnb)
        external
        returns (uint256);

    function bnbToTokenSwapOutput(uint256 tokens_bought)
        external
        payable
        returns (uint256);

    function bnbToTokenSwapInput(uint256 min_tokens, uint256 busd_amount)
        external
        payable
        returns (uint256);

    function getOutputPrice(
        uint256 output_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) external view returns (uint256);

    function getInputPrice(
        uint256 input_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) external view returns (uint256);
}

// Part: OpenZeppelin/[email protected]/IERC20Metadata

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

// Part: OpenZeppelin/[email protected]/Ownable

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

// Part: OpenZeppelin/[email protected]/SafeERC20

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

// Part: DevCut

abstract contract DevCut is Ownable {
    uint256 public devAmount;
    event UpdateCut(uint256 _old, uint256 _new);

    function updateDevCut(uint256 _newAmount) external onlyOwner {
        require(_newAmount < 50 * 1e10, "Invalid");
        emit UpdateCut(devAmount, _newAmount);
        devAmount = _newAmount;
    }
}

// Part: OpenZeppelin/[email protected]/ERC20

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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

// Part: OpenZeppelin/[email protected]/ERC20Burnable

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// Part: LotteryV2

/**
 * @title  Bitcrush's lottery game
 * @author Bitcrush Devs
 * @notice Simple Lottery contract, matches winning numbers from left to right.
 *
 *
 *
 */
contract LotteryV2 is VRFConsumerBaseV2, ReentrancyGuard, DevCut {
    // Libraries
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using SafeERC20 for ERC20Burnable;

    // Contracts
    // Contracts
    ERC20Burnable public immutable token;
    ERC20 public immutable busd;
    IFountain public pol;
    address public devAddress; //Address to send Ticket cut to.

    // Data Structures
    struct RoundInfo {
        uint256 totalTickets;
        uint256 ticketsClaimed;
        uint32 winnerNumber;
        uint256 pool;
        uint256 endTime;
        uint256[7] distribution;
        uint256 burn;
        uint256 totalWinners;
        uint256[6] winnerDigits;
        uint256 ticketValue; // in BUSD
    }

    struct TicketView {
        uint256 id;
        uint256 round;
        uint256 ticketNumber;
    }

    struct NewTicket {
        uint32 ticketNumber;
        uint256 round;
    }

    struct ClaimRounds {
        uint256 roundId;
        uint256 nonWinners;
        uint256 winners;
    }

    struct RoundTickets {
        uint256 totalTickets;
        uint256 firstTicketId;
    }

    struct Claimer {
        address claimer;
        uint256 percent;
    }
    // This struct defines the values to be stored on a per Round basis
    struct BonusCoin {
        address bonusToken;
        uint256 bonusAmount;
        uint256 bonusClaimed;
        uint256 bonusMaxPercent; // accumulated percentage of winners for a round
    }

    struct Partner {
        uint256 spread;
        uint256 id;
        bool set;
    }

    // VRF Specific
    bytes32 internal keyHashVRF;
    VRFCoordinatorV2Interface internal COORDINATOR;
    uint64 internal immutable susId;
    uint32 internal callbackGasLimit = 800_000;
    uint16 internal requestConfirmations = 3;

    /// Timestamp Specific
    uint256 constant SECONDS_PER_DAY = 24 hours;
    uint256 constant SECONDS_PER_HOUR = 1 hours;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;
    // CONSTANTS
    uint256 constant ONE100PERCENT = 1e8;
    uint256 constant ONE__PERCENT = 1e10;
    uint256 constant PERCENT_BASE = 1e12;
    uint32 constant WINNER_BASE = 1000000; //6 digits are necessary
    uint256 constant distributionShare = 5 * ONE__PERCENT;
    // Variables
    bool public currentIsActive = false;
    bool public pause = false;
    uint256 public currentRound = 0;
    uint256 public roundEnd;
    uint256 public ticketValue = 5 ether; //Value of Ticket value in BUSD

    uint256 public burnThreshold = 10 * ONE__PERCENT;
    // Fee Distributions
    /// @dev these values are used with PERCENT_BASE as 100%
    uint256 public match6 = 40 * ONE__PERCENT;
    uint256 public match5 = 20 * ONE__PERCENT;
    uint256 public match4 = 10 * ONE__PERCENT;
    uint256 public match3 = 5 * ONE__PERCENT;
    uint256 public match2 = 3 * ONE__PERCENT;
    uint256 public match1 = 2 * ONE__PERCENT;
    uint256 public noMatch = 2 * ONE__PERCENT;
    uint256 public burn = 18 * ONE__PERCENT;
    uint256 public claimFee = 75 * ONE100PERCENT; // This is deducted from the no winners 2%
    // Mappings
    mapping(uint256 => RoundInfo) public roundInfo; //Round Info
    mapping(uint256 => BonusCoin) public bonusCoins; //Track bonus partner coins to distribute
    mapping(uint256 => mapping(uint256 => uint256)) public holders; // ROUND => DIGITS => #OF HOLDERS
    mapping(address => uint256) public exchangeableTickets;
    mapping(address => Partner) public partnerSplit;
    // NEW IMPLEMENTATION
    mapping(address => mapping(uint256 => NewTicket)) public userNewTickets; // User => ticketId => ticketData
    mapping(address => mapping(uint256 => RoundTickets))
        public userRoundTickets; // User => Last created ticket Id
    mapping(address => uint256) public userTotalTickets; // User => Last created ticket Id
    mapping(address => uint256) public userLastTicketClaimed; // User => Last ticket claimed Id
    mapping(address => uint256) public bonusTokenIndex;
    mapping(uint256 => uint256) public initPool;

    mapping(uint256 => Claimer) private claimers; // Track claimers to autosend claiming Bounty

    mapping(address => bool) public thirdPartyTokenBuyers; // Allowed to buy ticket
    mapping(address => bool) public operators; //Operators allowed to execute certain functions

    address[] private partners;
    address[] public bonusAddresses;

    uint8[] public endHours = [18];
    uint8 public endHourIndex;
    // EVENTS
    event FundedBonusCoins(
        address indexed _partner,
        uint256 _amount,
        uint256 _startRound,
        uint256 _numberOfRounds
    );
    event FundPool(uint256 indexed _round, uint256 _amount);
    event OperatorChanged(address indexed operators, bool active_status);
    event RoundStarted(
        uint256 indexed _round,
        address indexed _starter,
        uint256 _timestamp
    );
    event TicketBought(
        uint256 indexed _round,
        address indexed _user,
        uint256 _ticketAmounts
    );
    event OtherTokenBought(
        address indexed buyer,
        uint256 indexed _round,
        address indexed _user,
        uint256 _ticketAmounts
    );
    event SelectionStarted(
        uint256 indexed _round,
        address _caller,
        uint256 _requestId
    );
    event WinnerPicked(
        uint256 indexed _round,
        uint256 _winner,
        uint256 _requestId
    );
    event TicketsRewarded(address _rewardee, uint256 _ticketAmount);
    event UpdateTicketValue(uint256 _timeOfUpdate, uint256 _newValue);
    event PartnerUpdated(address indexed _partner);
    event PercentagesChanged(
        address indexed owner,
        string percentName,
        uint256 newPercent
    );
    event LogEvent(uint256 _data, string _annotation);
    event AuditLog(address _data, string _annotation);
    // MODIFIERS
    modifier operatorOnly() {
        require(
            operators[msg.sender] == true || msg.sender == owner(),
            "Sorry Only Operators"
        );
        _;
    }

    /// @dev Select the appropriate VRF Coordinator and LINK Token addresses
    constructor(
        address _token,
        address _pol,
        address _busd,
        uint64 suscriptionId,
        address _coordinator
    ) VRFConsumerBaseV2(_coordinator) {
        // VRF Init
        if (block.chainid == 56) {
            keyHashVRF = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7; // MAINNET HASH
        } else if (block.chainid == 97) {
            keyHashVRF = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314; // TESTNET HASH
        }
        COORDINATOR = VRFCoordinatorV2Interface(_coordinator);
        pol = IFountain(_pol);
        token = ERC20Burnable(_token);
        busd = ERC20(_busd);
        susId = suscriptionId;
        operators[msg.sender] = true;

        devAddress = msg.sender;
        bonusAddresses.push(_token);
        bonusTokenIndex[_token] = 0;
        devAmount = 10 * ONE__PERCENT;
    }

    // External functions
    /// @notice Buy Tickets to participate in current round from a partner
    /// @param _ticketNumbers takes in an array of uint values as the ticket number to buy
    /// @param _partnerId the id of the partner to send the funds to if 0, no partner is checked.
    function buyWithToken(uint32[] calldata _ticketNumbers, uint256 _partnerId)
        external
        nonReentrant
    {
        /// get amount of tickets to Buy at ticketPrice
        uint256 toBuy = _ticketNumbers.length;
        require(toBuy > 0 && toBuy <= 100, "Limit");
        require(
            currentIsActive == true && block.timestamp < roundEnd,
            "Not ok"
        );
        // Check if User has funds for ticket
        //get price from POL
        uint256 price = roundInfo[currentRound].ticketValue * toBuy;
        price = pol.getBnbToTokenInputPrice(price);
        token.safeTransferFrom(msg.sender, address(this), price);
        // Get devCut in BUSD (from POL)
        uint256 devCut = (price * devAmount) / PERCENT_BASE;
        price -= devCut;
        token.approve(address(pol), devCut);
        pol.tokenToBnbSwapInput(devCut, 1);
        devCut = busd.balanceOf(address(this));
        // Split with partner when necessary, funds sent from this contract
        splitWithPartner(devCut, _partnerId, true);

        // Create Tickets
        // Add Tickets to respective Mappings
        for (uint256 i = 0; i < _ticketNumbers.length; i++) {
            createTicket(msg.sender, _ticketNumbers[i], currentRound, i);
        }
        increaseVals(price, toBuy, msg.sender);
    }

    /// @notice buy tickets using BUSD
    /// @param _ticketNumbers array of number of tickets to buy
    /// @param _partnerId the id of the partner to send the funds to if 0, no partner is checked.
    function buyWithBUSD(uint24[] calldata _ticketNumbers, uint256 _partnerId)
        external
        nonReentrant
    {
        /// get amount of tickets to Buy at ticketPrice
        uint256 toBuy = _ticketNumbers.length;
        require(toBuy > 0 && toBuy <= 100, "Limit");
        require(
            currentIsActive == true && block.timestamp < roundEnd,
            "Round not active"
        );
        uint256 price = roundInfo[currentRound].ticketValue * toBuy;
        /// send cut to TreasuryDevWallet & partners
        uint256 devCut = (price * devAmount) / PERCENT_BASE;
        splitWithPartner(devCut, _partnerId, false);
        price -= devCut;
        /// transfer BUSD to contract
        busd.safeTransferFrom(msg.sender, address(this), price);
        /// convert rest to TOKEN
        price = busd.balanceOf(address(this));
        busd.approve(address(pol), price);
        uint256 tokenSwapped = pol.bnbToTokenSwapInput(1, price);
        /// BUYS AND SETS TICKETS FOR MSG.SENDER
        // Create Tickets
        for (uint8 i = 0; i < toBuy; i++) {
            createTicket(msg.sender, _ticketNumbers[i], currentRound, i);
        }
        increaseVals(tokenSwapped, toBuy, msg.sender);
    }

    /// @notice sets the tickets from partner contract,
    /// @param _ticketNumbers array of number of tickets to buy
    /// @param funded the amount of STAKE added to the Pool
    function buyWithPartnerToken(
        uint24[] calldata _ticketNumbers,
        uint256 funded,
        address _buyer
    ) external nonReentrant {
        // caller is approved address
        require(thirdPartyTokenBuyers[msg.sender], "Invalid Caller");
        // We're trusting that previous contract made the necessary checks for
        // the tickets they are buying in and sent STAKE to pool
        // and sent the dev cut to dev

        roundInfo[currentRound].pool += funded;
        emit FundPool(currentRound, funded);

        uint256 toBuy = _ticketNumbers.length;
        // create tickets and sets them for the required user
        if (userRoundTickets[msg.sender][currentRound].firstTicketId == 0) {
            userRoundTickets[msg.sender][currentRound]
                .firstTicketId = userTotalTickets[msg.sender].add(1);
        }
        userTotalTickets[msg.sender] += toBuy;
        userRoundTickets[msg.sender][currentRound].totalTickets += toBuy;
        for (uint8 i = 0; i < toBuy; i++) {
            createTicket(_buyer, _ticketNumbers[i], currentRound, i);
        }
        emit OtherTokenBought(msg.sender, currentRound, _buyer, toBuy);
        roundInfo[currentRound].totalTickets += toBuy;
    }

    /// @notice add/remove/edit partners
    /// @param _partnerAddress the address where funds will go to.
    /// @param _split the negotiated split percentage. Value goes from 0 to 90.
    /// @dev their ID doesn't change, nor is it removed once partnership ends.
    function editPartner(address _partnerAddress, uint8 _split)
        external
        operatorOnly
    {
        require(_split <= 90, "split is high");
        Partner storage _p = partnerSplit[_partnerAddress];
        if (_p.id == 0) {
            partners.push(_partnerAddress);
            _p.id = partners.length;
        }
        _p.spread = _split;
        _p.set = _split > 0;
        emit PartnerUpdated(_partnerAddress);
    }

    /// @notice retrieve a provider wallet ID
    /// @param _checkAddress the address to check
    /// @return _id the ID of the provider
    function getProviderId(address _checkAddress)
        external
        view
        returns (uint256 _id)
    {
        Partner storage partner = partnerSplit[_checkAddress];
        if (partner.set) return 0;
        _id = partner.id;
    }

    /// @notice Give Redeemable Tickets to a particular user
    /// @param _rewardee Address the tickets will be awarded to
    /// @param ticketAmount number of tickets awarded
    function rewardTicket(address _rewardee, uint256 ticketAmount)
        external
        operatorOnly
    {
        exchangeableTickets[_rewardee] += ticketAmount;
        emit TicketsRewarded(_rewardee, ticketAmount);
    }

    /// @notice Exchange awarded tickets for the current round
    /// @param _ticketNumbers array of numbers to add to the caller as tickets
    function exchangeForTicket(uint32[] calldata _ticketNumbers) external {
        require(
            currentIsActive == true && block.timestamp < roundEnd,
            "Round not active"
        );
        uint256 toExchange = _ticketNumbers.length;
        require(
            toExchange > 0 && toExchange <= exchangeableTickets[msg.sender],
            "invalid exchange amount"
        );
        if (userRoundTickets[msg.sender][currentRound].firstTicketId == 0) {
            userRoundTickets[msg.sender][currentRound]
                .firstTicketId = userTotalTickets[msg.sender].add(1);
        }
        for (uint256 exchange = 0; exchange < toExchange; exchange++) {
            createTicket(
                msg.sender,
                _ticketNumbers[exchange],
                currentRound,
                exchange
            );
            exchangeableTickets[msg.sender] -= 1;
        }
        userTotalTickets[msg.sender] += toExchange;
        roundInfo[currentRound].totalTickets += toExchange;
        emit TicketBought(currentRound, msg.sender, toExchange);
    }

    /// @notice Start of new Round. This function is only needed for the first round, next rounds will be automatically started once the winner number is received
    function firstStart() external operatorOnly {
        require(currentRound == 0, "First Round only");
        calcNextHour();
        startRound();
        // Rollover all of pool zero at start
        initPool[currentRound] = roundInfo[0].pool;
        roundInfo[currentRound].pool = roundInfo[0].pool;
        roundInfo[currentRound].endTime = roundEnd;
        roundInfo[currentRound].distribution = [
            noMatch,
            match1,
            match2,
            match3,
            match4,
            match5,
            match6
        ];
        roundInfo[currentRound].ticketValue = ticketValue;
        pause = false;
    }

    /// @notice Ends current round
    /// @dev WIP - the end of the round will always happen at set intervals
    function endRound() external {
        require(
            currentIsActive == true &&
                block.timestamp > roundInfo[currentRound].endTime,
            "Round active"
        );
        currentIsActive = false;
        calcNextHour();
        RoundInfo storage nextRound = roundInfo[currentRound + 1];
        nextRound.endTime = roundEnd;
        claimers[currentRound] = Claimer(msg.sender, 0);
        // Request Random Number for Winner
        uint256 rqId = COORDINATOR.requestRandomWords(
            keyHashVRF,
            susId,
            requestConfirmations,
            callbackGasLimit,
            1
        );
        emit SelectionStarted(currentRound, msg.sender, rqId);
    }

    /// @notice Add or remove operator
    /// @param _operator address to add / remove operator
    function toggleOperator(address _operator) external operatorOnly {
        bool operatorIsActive = operators[_operator];
        if (operatorIsActive) {
            operators[_operator] = false;
        } else {
            operators[_operator] = true;
        }
        emit OperatorChanged(_operator, operators[msg.sender]);
    }

    // SETTERS
    /// @notice Change the claimer's fee
    /// @param _fee the value of the new fee
    /// @dev Fee cannot be greater than noMatch percentage ( since noMatch percentage is the amount given out to nonWinners )
    function setClaimerFee(uint256 _fee) external onlyOwner {
        require(_fee.mul(ONE100PERCENT) < noMatch, "Invalid fee amount");
        claimFee = _fee.mul(ONE100PERCENT);
        emit PercentagesChanged(
            msg.sender,
            "claimFee",
            _fee.mul(ONE100PERCENT)
        );
    }

    /// @notice Set the token that will be used as a Bonus for a particular round
    /// @param _partnerToken Token address
    /// @param _round round where this token applies
    function setBonusCoin(
        address _partnerToken,
        uint256 _amount,
        uint256 _round,
        uint256 _roundAmount
    ) external operatorOnly {
        require(_roundAmount > 0, "Need at least 1");
        require(_round > currentRound, "No past rounds");
        require(
            _partnerToken != address(0) &&
                bonusCoins[_round].bonusToken == address(0),
            "issue with address"
        );
        if (bonusTokenIndex[_partnerToken] == 0) {
            bonusTokenIndex[_partnerToken] = bonusAddresses.length;
            bonusAddresses.push(_partnerToken);
        }
        ERC20 bonusToken = ERC20(_partnerToken);
        uint256 spreadAmount = _amount.div(_roundAmount);
        uint256 totalAmount = spreadAmount.mul(_roundAmount); //get the actual total to take into account division issues
        bonusToken.safeTransferFrom(msg.sender, address(this), totalAmount);
        for (
            uint256 rounds = _round;
            rounds < _round.add(_roundAmount);
            rounds++
        ) {
            require(
                bonusCoins[rounds].bonusToken == address(0),
                "Already has bonus"
            );
            // Uses the claimFee as the base since that will always be distributed to the claimer.
            bonusCoins[rounds] = BonusCoin(_partnerToken, spreadAmount, 0, 0);
        }
        emit FundedBonusCoins(_partnerToken, _amount, _round, _roundAmount);
    }

    /// @notice Set the ticket value
    /// @param _newValue the new value of the ticket
    /// @dev Ticket value MUST BE IN WEI format, minimum is left as greater than 1 due to the deflationary nature of CRUSH
    function setTicketValue(uint256 _newValue) external onlyOwner {
        require(_newValue <= 100 ether && _newValue > 1, "exceeds MAX");
        ticketValue = _newValue;
        emit UpdateTicketValue(block.timestamp, _newValue);
    }

    /// @notice Edit the times array
    /// @param _newTimes Array of hours when Lottery will end
    /// @dev adding a sorting algorithm would be nice but honestly we have too much going on to add that in. So help us out and add your times sorted
    function setEndHours(uint8[] calldata _newTimes) external operatorOnly {
        require(_newTimes.length > 0, "need time");
        for (uint256 i = 0; i < _newTimes.length; i++) {
            require(_newTimes[i] < 24, "wrong time");
            if (i > 0)
                require(_newTimes[i] > _newTimes[i - 1], "Help out sort times");
        }
        endHours = _newTimes;
    }

    /// @notice Setup the burn threshold
    /// @param _threshold new threshold in percent amount
    /// @dev setting the minimum threshold as 0 will always burn, setting max as 50
    function setBurnThreshold(uint256 _threshold) external onlyOwner {
        require(_threshold <= 50, "Out of range");
        burnThreshold = _threshold * ONE__PERCENT;
    }

    /// @notice toggle pause state of lottery
    /// @dev if the round is over and the lottery is unpaused then the round is started
    function togglePauseStatus() external onlyOwner {
        pause = !pause;
        if (currentIsActive == false && !pause) {
            startRound();
        }
        emit LogEvent(pause ? 1 : 0, "Pause Status Changed");
    }

    /// @notice Destroy contract and retrieve funds
    /// @dev This function is meant to retrieve funds in case of non usage and/or upgrading in the future.
    function crushTheContract() external onlyOwner {
        require(pause, "not paused");
        require(block.timestamp > roundEnd.add(2629743), "Wait no activity");
        // Transfer Held CRUSH
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
        // Transfer held Link
        // Transfer Held Bonus Tokens
        for (uint256 i = 1; i < bonusAddresses.length; i++) {
            ERC20 bonusToken = ERC20(bonusAddresses[i]);
            bonusToken.safeTransfer(
                msg.sender,
                bonusToken.balanceOf(address(this))
            );
        }
        selfdestruct(payable(msg.sender));
    }

    /// @notice Set the distribution percentage amounts... all amounts must be given for this to work
    /// @param _newDistribution array of distribution amounts
    /// @dev we expect all values to sum 100 and that all items are given. The new distribution only applies to next rounds
    /// @dev all values are in the one onehundreth percentile amount.
    /// @dev expected order [ jackpot, match5, match4, match3, match2, match1, noMatch, burn]
    function setDistributionPercentages(uint256[] calldata _newDistribution)
        external
        onlyOwner
    {
        require(
            _newDistribution[7] > 0 && _newDistribution.length == 8,
            "Wrong configs"
        );
        match6 = _newDistribution[0].mul(ONE100PERCENT);
        match5 = _newDistribution[1].mul(ONE100PERCENT);
        match4 = _newDistribution[2].mul(ONE100PERCENT);
        match3 = _newDistribution[3].mul(ONE100PERCENT);
        match2 = _newDistribution[4].mul(ONE100PERCENT);
        match1 = _newDistribution[5].mul(ONE100PERCENT);
        noMatch = _newDistribution[6].mul(ONE100PERCENT);
        burn = _newDistribution[7].mul(ONE100PERCENT);
        require(
            match6
                .add(match5)
                .add(match4)
                .add(match3)
                .add(match2)
                .add(match1)
                .add(noMatch)
                .add(burn) == PERCENT_BASE,
            "Numbers don't add up"
        );
        emit PercentagesChanged(msg.sender, "jackpot", match6);
        emit PercentagesChanged(msg.sender, "match5", match5);
        emit PercentagesChanged(msg.sender, "match4", match4);
        emit PercentagesChanged(msg.sender, "match3", match3);
        emit PercentagesChanged(msg.sender, "match2", match2);
        emit PercentagesChanged(msg.sender, "match1", match1);
        emit PercentagesChanged(msg.sender, "noMatch", noMatch);
        emit PercentagesChanged(msg.sender, "burnPercent", burn);
    }

    /// @notice Claim all tickets for selected Rounds
    /// @param _rounds the round info to look at
    /// @param _ticketIds array of ticket Ids that will be claimed
    /// @param _matches array of match per ticket Id
    /// @dev _ticketIds and _matches have to be same length since they are matched 1-to-1
    function claimAllPendingTickets(
        ClaimRounds[] calldata _rounds,
        uint256[] calldata _ticketIds,
        uint256[] calldata _matches
    ) external {
        require(
            _ticketIds.length == _matches.length,
            "Arrays need to be the same"
        );
        require(_rounds.length > 0, "Need to claim something");
        uint256 claims = userLastTicketClaimed[msg.sender];
        require(
            _rounds[0].roundId > userNewTickets[msg.sender][claims].round,
            "Can't claim past rounds"
        );
        uint256 ticketIdCounter;
        uint256[] memory partnerBonusTokens = new uint256[](
            bonusAddresses.length
        );
        for (uint256 i = 0; i < _rounds.length; i++) {
            require(
                _rounds[i].roundId < currentRound,
                "Can't claim current round tickets"
            );
            require(
                _rounds[i].nonWinners.add(_rounds[i].winners) ==
                    userRoundTickets[msg.sender][_rounds[i].roundId]
                        .totalTickets,
                "Missing Tickets, all rounds claimed equally"
            );
            require(
                _rounds[i].winners <= _ticketIds.length,
                "round must have all tickets"
            );
            uint256 roundId = _rounds[i].roundId;
            uint256 winners = _rounds[i].winners;
            uint256 nonWinners = _rounds[i].nonWinners;
            RoundInfo storage roundChecked = roundInfo[roundId];
            BonusCoin storage roundBonus = bonusCoins[roundId];
            uint256 matchReduction = getNoMatchAmount(roundId);
            if (nonWinners > 0) {
                partnerBonusTokens[0] = partnerBonusTokens[0].add(
                    getFraction(
                        roundChecked.pool,
                        matchReduction.mul(nonWinners),
                        roundChecked
                            .totalTickets
                            .sub(roundChecked.totalWinners)
                            .mul(PERCENT_BASE)
                    )
                );
                if (roundBonus.bonusToken != address(0)) {
                    partnerBonusTokens[
                        bonusTokenIndex[roundBonus.bonusToken]
                    ] = partnerBonusTokens[
                        bonusTokenIndex[roundBonus.bonusToken]
                    ].add(
                            nonWinners.mul(
                                getBonusReward(
                                    roundChecked.totalTickets.sub(
                                        roundChecked.totalWinners
                                    ),
                                    roundBonus,
                                    matchReduction
                                )
                            )
                        );
                }
            }
            if (winners > 0) {
                for (uint256 j = 0; j < winners; j++) {
                    uint256 ticketId = _ticketIds[j + ticketIdCounter];
                    if (j == 0 && ticketIdCounter == 0)
                        require(ticketId > claims, "Ticket already claimed");
                    if (j > 0 || ticketIdCounter > 0)
                        require(
                            ticketId > _ticketIds[j + ticketIdCounter - 1],
                            "sort tickets, claim once"
                        );
                    uint256 matchBatch = _matches[j + ticketIdCounter];
                    uint256 distributedAmount = checkTicketRequirements(
                        ticketId,
                        matchBatch,
                        roundChecked
                    );
                    partnerBonusTokens[0] = partnerBonusTokens[0].add(
                        distributedAmount
                    );
                    if (roundBonus.bonusToken != address(0)) {
                        partnerBonusTokens[
                            bonusTokenIndex[roundBonus.bonusToken]
                        ] = partnerBonusTokens[
                            bonusTokenIndex[roundBonus.bonusToken]
                        ].add(
                                getBonusReward(
                                    holders[roundId][
                                        roundChecked.winnerDigits[
                                            matchBatch - 1
                                        ]
                                    ],
                                    roundBonus,
                                    roundChecked.distribution[matchBatch]
                                )
                            );
                    }
                }
                ticketIdCounter = ticketIdCounter.add(winners);
            }
            claims = claims.add(nonWinners).add(winners);
        }
        userLastTicketClaimed[msg.sender] = claims;
        if (partnerBonusTokens[0] > 0) {
            token.safeTransfer(msg.sender, partnerBonusTokens[0]);
        }
        if (bonusAddresses.length > 1) {
            for (uint256 p = 1; p < bonusAddresses.length; p++) {
                if (partnerBonusTokens[p] == 0) continue;
                ERC20 bonusContract = ERC20(bonusAddresses[p]);
                uint256 availableFunds = bonusContract.balanceOf(address(this));
                if (availableFunds > 0) {
                    if (partnerBonusTokens[p] > availableFunds)
                        bonusContract.safeTransfer(msg.sender, availableFunds);
                    else
                        bonusContract.safeTransfer(
                            msg.sender,
                            partnerBonusTokens[p]
                        );
                }
            }
        }
    }

    // External functions that are view
    /// @notice Get Tickets for the caller for during a specific round
    /// @param _round The round to query
    function getUserRoundTickets(uint256 _round, address _user)
        external
        view
        returns (NewTicket[] memory)
    {
        RoundTickets storage roundReview = userRoundTickets[_user][_round];
        NewTicket[] memory tickets = new NewTicket[](roundReview.totalTickets);
        for (uint256 i = 0; i < roundReview.totalTickets; i++)
            tickets[i] = userNewTickets[_user][
                roundReview.firstTicketId.add(i)
            ];
        return tickets;
    }

    /// @notice Get a specific round's distribution percentages
    /// @param _round the round to check
    /// @dev this is necessary since solidity doesn't return the nested array in a struct when calling the variable containing the struct
    function getRoundDistribution(uint256 _round)
        external
        view
        returns (uint256[7] memory distribution)
    {
        distribution[0] = roundInfo[_round].distribution[0];
        distribution[1] = roundInfo[_round].distribution[1];
        distribution[2] = roundInfo[_round].distribution[2];
        distribution[3] = roundInfo[_round].distribution[3];
        distribution[4] = roundInfo[_round].distribution[4];
        distribution[5] = roundInfo[_round].distribution[5];
        distribution[6] = roundInfo[_round].distribution[6];
    }

    /// @notice Get all Claimable Tickets
    /// @return TicketView array
    /// @dev this is specific to UI, returns ID and ROUND number in order to make the necessary calculations.
    function ticketsToClaim() external view returns (TicketView[] memory) {
        uint256 claimableTickets = userTotalTickets[msg.sender].sub(
            userLastTicketClaimed[msg.sender]
        );
        if (claimableTickets == 0) return new TicketView[](0);
        TicketView[] memory pendingTickets = new TicketView[](claimableTickets);
        for (uint256 i = 0; i < claimableTickets; i++) {
            NewTicket storage viewTicket = userNewTickets[msg.sender][
                userLastTicketClaimed[msg.sender].add(i + 1)
            ];
            pendingTickets[i] = TicketView(
                userLastTicketClaimed[msg.sender].add(i + 1),
                viewTicket.round,
                viewTicket.ticketNumber
            );
        }
        return pendingTickets;
    }

    // Public functions
    /// @notice Add funds to pool directly, only applies funds to currentRound
    /// @param _amount the amount of TOKEN to transfer from current account to current Round
    /// @dev Approve needs to be run beforehand so the transfer can succeed.
    function addToPool(uint256 _amount) public {
        token.safeTransferFrom(msg.sender, address(this), _amount);
        roundInfo[currentRound].pool = roundInfo[currentRound].pool.add(
            _amount
        );
        emit FundPool(currentRound, _amount);
    }

    // Internal functions
    function increaseVals(
        uint256 _pool,
        uint256 _tickets,
        address _user
    ) internal {
        /// add to Pool
        roundInfo[currentRound].pool += _pool;
        roundInfo[currentRound].totalTickets += _tickets;
        userRoundTickets[_user][currentRound].totalTickets += _tickets;
        if (userRoundTickets[_user][currentRound].firstTicketId == 0) {
            userRoundTickets[_user][currentRound]
                .firstTicketId = userTotalTickets[_user].add(1);
        }
        userTotalTickets[_user] += _tickets;
        emit FundPool(currentRound, _pool);
        emit TicketBought(currentRound, _user, _tickets);
    }

    /// @notice Split with Partner
    /// @param devCut the amount to split
    /// @param _partnerId Id of the partner to send the funds to
    /// @param fromSelf if tokens are sent from contract or from the caller - used for third party token buys
    /// @dev _partnerId is base 1 and should be base 0
    function splitWithPartner(
        uint256 devCut,
        uint256 _partnerId,
        bool fromSelf
    ) internal {
        if (_partnerId > 0) {
            require(_partnerId <= partners.length, "Partner Id doesn't exist");
            Partner storage _p = partnerSplit[partners[_partnerId - 1]];
            require(_p.set, "Partnership ended");
            uint256 toPartner = (devCut * _p.spread) / 100;
            if (fromSelf) {
                busd.safeTransfer(partners[_partnerId - 1], toPartner);
                busd.safeTransfer(devAddress, devCut - toPartner);
            } else {
                busd.safeTransferFrom(
                    msg.sender,
                    partners[_partnerId - 1],
                    toPartner
                );
                busd.safeTransferFrom(
                    msg.sender,
                    devAddress,
                    devCut - toPartner
                );
            }
        } else {
            if (fromSelf) busd.safeTransfer(devAddress, devCut);
            else busd.safeTransferFrom(msg.sender, devAddress, devCut);
        }
    }

    /// @notice Get the percentage to use for non winners difference after claimer fee
    /// @param _round the round to get the info from.
    function getNoMatchAmount(uint256 _round)
        internal
        view
        returns (uint256 _matchReduction)
    {
        _matchReduction = roundInfo[_round].distribution[0].sub(
            claimers[_round].percent
        );
    }

    /// @notice Set the next start hour and next hour index
    /// @dev if next hour goes over the alleged next round necessary, it skips it and goes to the next available hour
    function calcNextHour() internal {
        uint256 tempEnd = roundEnd;
        uint8 newIndex = endHourIndex;
        while (tempEnd <= block.timestamp) {
            newIndex = newIndex + 1 >= endHours.length ? 0 : newIndex + 1;
            tempEnd = setNextRoundEndTime(
                block.timestamp,
                endHours[newIndex],
                newIndex != 0 || endHourIndex < newIndex,
                uint8(endHours.length)
            );
        }
        roundEnd = tempEnd;
        endHourIndex = newIndex;
    }

    /// @notice Adds the ticket to chain
    /// @param ticketOwner the owner of the ticket
    /// @param _ticketNumber the number playing
    /// @param _round the round currently being played
    /// @param _ticketCount the ticket id offset
    /// @dev Depending on how many tickets, the gas usage for this function can be quite high.
    function createTicket(
        address ticketOwner,
        uint32 _ticketNumber,
        uint256 _round,
        uint256 _ticketCount
    ) internal {
        assembly {
            let currentTicket := add(
                mod(_ticketNumber, WINNER_BASE),
                WINNER_BASE
            )
            // save ticket to userNewTickets
            mstore(0, ticketOwner)
            mstore(32, userTotalTickets.slot)
            let baseOffset := keccak256(0, 64)
            let secondaryVal := add(
                add(sload(keccak256(0, 64)), 1),
                _ticketCount
            )
            mstore(0, ticketOwner)
            mstore(32, userNewTickets.slot)
            baseOffset := keccak256(0, 64)
            mstore(0, secondaryVal)
            mstore(32, baseOffset)
            sstore(keccak256(0, 64), currentTicket)
            sstore(add(keccak256(0, 64), 1), _round)
            // Get base again
            mstore(0, _round)
            mstore(32, holders.slot)
            baseOffset := keccak256(0, 64)
            // save 6
            mstore(0, currentTicket)
            mstore(32, baseOffset)
            let offset := keccak256(0, 64)
            secondaryVal := sload(offset)
            sstore(offset, add(secondaryVal, 1))
            // save 5
            currentTicket := div(currentTicket, 10)
            mstore(0, currentTicket)
            mstore(32, baseOffset)
            offset := keccak256(0, 64)
            secondaryVal := sload(offset)
            sstore(offset, add(secondaryVal, 1))
            // save 4
            currentTicket := div(currentTicket, 10)
            mstore(0, currentTicket)
            mstore(32, baseOffset)
            offset := keccak256(0, 64)
            secondaryVal := sload(offset)
            sstore(offset, add(secondaryVal, 1))
            // save 3
            currentTicket := div(currentTicket, 10)
            mstore(0, currentTicket)
            mstore(32, baseOffset)
            offset := keccak256(0, 64)
            secondaryVal := sload(offset)
            sstore(offset, add(secondaryVal, 1))
            // save 2
            currentTicket := div(currentTicket, 10)
            mstore(0, currentTicket)
            mstore(32, baseOffset)
            offset := keccak256(0, 64)
            secondaryVal := sload(offset)
            sstore(offset, add(secondaryVal, 1))
            // save 1
            currentTicket := div(currentTicket, 10)
            mstore(0, currentTicket)
            mstore(32, baseOffset)
            offset := keccak256(0, 64)
            secondaryVal := sload(offset)
            sstore(offset, add(secondaryVal, 1))
        }
    }

    function getWinnerHolders(uint256 _round)
        external
        view
        returns (uint256[6] memory _digitHolders)
    {
        uint256[6] memory wD = roundInfo[_round].winnerDigits;
        for (uint8 i = 0; i < 6; i++) {
            // Holders are already adjusted
            uint256 _cHolder = holders[_round][wD[5 - i]];
            _digitHolders[5 - i] = _cHolder;
        }
    }

    /// @notice Get bonus reward amount based on holders and match amount
    /// @param _holders amount of holders
    /// @param bonus The bonus token data, used to obtain the bonus amount and maxpercent
    /// @param _match The percentage matched
    /// @return bonusAmount total amount to be distributed
    function getBonusReward(
        uint256 _holders,
        BonusCoin storage bonus,
        uint256 _match
    ) internal view returns (uint256 bonusAmount) {
        if (_holders == 0) return 0;
        if (bonus.bonusToken != address(0)) {
            if (_match == 0) return 0;
            bonusAmount = getFraction(
                bonus.bonusAmount,
                _match,
                bonus.bonusMaxPercent
            ).div(_holders);
            return bonusAmount;
        }
        return 0;
    }

    /// @notice Function that starts a round, it's only internal since it's for use of VRF
    /// @dev distribution array is setup on a round basis as to simplify matching
    function startRound() internal {
        require(currentIsActive == false, "Current Round is not over");
        require(pause == false, "Lottery is paused");
        // Add new Round
        unchecked {
            currentRound++;
        }
        currentIsActive = true;
        RoundInfo storage newRound = roundInfo[currentRound];
        newRound.distribution = [
            noMatch,
            match1,
            match2,
            match3,
            match4,
            match5,
            match6
        ];
        newRound.ticketValue = ticketValue;
        emit RoundStarted(currentRound, msg.sender, block.timestamp);
    }

    /// @notice function that calculates distribution and transfers rewards to claimer
    /// @dev From calculations on calculateRollover fn, it transfers the claimer fee to claimer and the distributes rewards to bankroll
    /// @dev finally it sets the pool amount in the next round
    function distributeTokens() internal {
        RoundInfo storage thisRound = roundInfo[currentRound];
        (
            uint256 rollOver,
            uint256 burnAmount,
            uint256 forClaimer
        ) = calculateRollover();
        // Transfer Amount to Claimer
        Claimer storage roundClaimer = claimers[currentRound];
        if (forClaimer > 0)
            token.safeTransfer(roundClaimer.claimer, forClaimer);
        if (bonusCoins[currentRound].bonusToken != address(0)) {
            ERC20 bonusTokenContract = ERC20(
                bonusCoins[currentRound].bonusToken
            );
            bonusTokenContract.safeTransfer(
                roundClaimer.claimer,
                getBonusReward(
                    1,
                    bonusCoins[currentRound],
                    roundClaimer.percent
                )
            );
        }

        // BURN AMOUNT
        if (burnAmount > 0) {
            token.burn(burnAmount);
            thisRound.burn = burnAmount;
        }
        initPool[currentRound + 1] = rollOver;
        roundInfo[currentRound + 1].pool = rollOver;
        if (!pause) startRound();
    }

    /// @notice checks for winner holders and returns distribution info
    /// @return _rollover the amount to be rolled over to next round
    /// @return _burn the amount to burn
    /// @return _forClaimer the claimer fee
    function calculateRollover()
        internal
        returns (
            uint256 _rollover,
            uint256 _burn,
            uint256 _forClaimer
        )
    {
        RoundInfo storage info = roundInfo[currentRound];
        _rollover = 0;
        // for zero match winners
        BonusCoin storage roundBonusCoin = bonusCoins[currentRound];
        uint256[6] memory winnerDigits = getDigits(info.winnerNumber);
        uint256 totalMatchHolders = 0;

        for (uint8 i = 0; i < 6; i++) {
            uint256 digitToCheck = winnerDigits[5 - i];
            uint256 matchHolders = holders[currentRound][digitToCheck];
            if (matchHolders > 0) {
                if (i == 0) totalMatchHolders = matchHolders;
                else {
                    matchHolders -= totalMatchHolders;
                    totalMatchHolders += matchHolders;
                    holders[currentRound][digitToCheck] = matchHolders;
                }
                if (matchHolders > 0) {
                    _forClaimer += info.distribution[6 - i];
                    roundBonusCoin.bonusMaxPercent =
                        roundBonusCoin.bonusMaxPercent +
                        info.distribution[6 - i];
                }
            } else
                _rollover += getFraction(
                    info.pool,
                    info.distribution[6 - i],
                    PERCENT_BASE
                );
        }
        _forClaimer = (_forClaimer * claimFee) / PERCENT_BASE;
        uint256 nonWinners = info.totalTickets - totalMatchHolders;
        info.totalWinners = totalMatchHolders;
        info.winnerDigits = winnerDigits;
        // Are there any noMatch tickets
        if (nonWinners == 0)
            _rollover += getFraction(
                info.pool,
                info.distribution[0].sub(_forClaimer),
                PERCENT_BASE
            );
        else roundBonusCoin.bonusMaxPercent += info.distribution[0];
        if (
            getFraction(initPool[currentRound], burnThreshold, PERCENT_BASE) <=
            info.pool - initPool[currentRound]
        ) _burn = getFraction(info.pool, burn, PERCENT_BASE);
        else {
            _burn = 0;
            _rollover += getFraction(info.pool, burn, PERCENT_BASE);
        }
        claimers[currentRound].percent = _forClaimer;
        _forClaimer = getFraction(info.pool, _forClaimer, PERCENT_BASE);
    }

    /// @notice Function that gets called by VRF to deliver number and distribute claimer reward
    /// @param requestId id of VRF request
    /// @param randomWords Random number array delivered by VRF
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        RoundInfo storage info = roundInfo[currentRound];
        info.winnerNumber = standardTicketNumber(
            uint24(randomWords[0]),
            WINNER_BASE
        );
        distributeTokens();
        emit WinnerPicked(currentRound, info.winnerNumber, requestId);
    }

    /// @notice Function to get the fraction amount from a value
    /// @param _amount total to be fractioned
    /// @param _percent percentage to be applied
    /// @param _base  percentage base, most cases will use PERCENT_BASE since percentage is not used as 100
    /// @return fraction -> the result of the fraction computation
    function getFraction(
        uint256 _amount,
        uint256 _percent,
        uint256 _base
    ) internal pure returns (uint256 fraction) {
        fraction = _amount.mul(_percent).div(_base);
    }

    /// @notice Get all participating digits from number
    /// @param _ticketNumber the ticket number to extract digits from
    /// @return digits Array of 6, each with the matching pattern
    function getDigits(uint256 _ticketNumber)
        internal
        pure
        returns (uint256[6] memory digits)
    {
        digits[0] = _ticketNumber / 100000; // WINNER_BASE
        digits[1] = _ticketNumber / 10000;
        digits[2] = _ticketNumber / 1000;
        digits[3] = _ticketNumber / 100;
        digits[4] = _ticketNumber / 10;
        digits[5] = _ticketNumber;
    }

    /// @notice requirements to check per round and calculate distributed amount
    /// @param _ticketId the ticket Id to check
    /// @param _matchBatch the matching amount of the ticket Id
    /// @param _currentRound round to check
    /// @return _distributedAmount Total amount to be distributed
    function checkTicketRequirements(
        uint256 _ticketId,
        uint256 _matchBatch,
        RoundInfo storage _currentRound
    ) internal view returns (uint256 _distributedAmount) {
        require(
            userNewTickets[msg.sender][_ticketId].ticketNumber > 0,
            "!exists"
        );
        require(_matchBatch > 0 && _matchBatch < 7, "minimum match 1");
        require(
            getDigits(userNewTickets[msg.sender][_ticketId].ticketNumber)[
                _matchBatch - 1
            ] == getDigits(_currentRound.winnerNumber)[_matchBatch - 1],
            "Not owner|wrong data"
        );

        uint256 batchDistribution = _currentRound.distribution[_matchBatch];
        uint256 batchHolders = holders[
            userNewTickets[msg.sender][_ticketId].round
        ][_currentRound.winnerDigits[_matchBatch - 1]];
        return
            getFraction(_currentRound.pool, batchDistribution, PERCENT_BASE)
                .div(batchHolders);
    }

    /// @notice convert a number into the ticket range
    /// @param _ticketNumber any number, the used values are the least significant digits
    /// @param _base base of the ticket, usually WINNER_BASE
    /// @return uint32 with ticket number value
    function standardTicketNumber(uint32 _ticketNumber, uint32 _base)
        internal
        pure
        returns (uint32)
    {
        uint32 ticketNumber = (_ticketNumber % _base) + _base;
        return ticketNumber;
    }

    /// @notice Gets the next hour at the specific hour this is fixed from previous iteration
    /// @param _currentTimestamp the timestamp to verify
    /// @param _hour the new hour
    /// @param _sameDay if the time is set for the same day
    /// @param _timesPerDay times per day the lottery is played.
    function setNextRoundEndTime(
        uint256 _currentTimestamp,
        uint256 _hour,
        bool _sameDay,
        uint8 _timesPerDay
    ) internal pure returns (uint256 _endTimestamp) {
        uint256 nextDay = _sameDay
            ? _currentTimestamp
            : SECONDS_PER_DAY.add(_currentTimestamp);
        (uint256 year, uint256 month, uint256 day) = timestampToDateTime(
            nextDay
        );
        _endTimestamp = timestampFromDateTime(year, month, day, _hour, 0, 0);
        if (_endTimestamp - _currentTimestamp > SECONDS_PER_DAY / _timesPerDay)
            _endTimestamp = timestampFromDateTime(
                year,
                month,
                day - 1,
                _hour,
                0,
                0
            );
    }

    function updateDevAddress(address _newDev) external onlyOwner {
        require(_newDev != address(0)); // dev: Zero Address
        devAddress = _newDev;
        emit AuditLog(devAddress, "Update Dev");
    }

    // -------------------------------------------------------------------`
    // Timestamp fns taken from BokkyPooBah's DateTime Library
    //
    // Gas efficient Solidity date and time library
    //
    // https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
    //
    // Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
    //
    // GNU Lesser General Public License 3.0
    // https://www.gnu.org/licenses/lgpl-3.0.en.html
    // ----------------------------------------------------------------------------
    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {
        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }

    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days = _day -
            32075 +
            (1461 * (_year + 4800 + (_month - 14) / 12)) /
            4 +
            (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
            12 -
            (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
            4 -
            OFFSET19700101;

        _days = uint256(__days);
    }
}

// File: LotteryViewer.sol

contract LotteryDataViewer {
    LotteryV2 public lottery;

    struct RoundInfo {
        uint256 totalTickets;
        uint256 ticketsClaimed;
        uint32 winnerNumber;
        uint256 pool;
        uint256 endTime;
        uint256 burn;
        uint256 totalWinners;
        uint256 ticketValue; // in BUSD
    }

    constructor(address _lot) {
        lottery = LotteryV2(_lot);
    }

    function getCurrentRound()
        public
        view
        returns (
            uint256 current,
            uint256 totalTickets,
            uint256 ticketsClaimed,
            uint32 winnerNumber,
            uint256 pool,
            uint256 endTime,
            uint256 burn,
            uint256 totalWinners,
            uint256 ticketValue
        )
    {
        current = lottery.currentRound();
        (
            totalTickets,
            ticketsClaimed,
            winnerNumber,
            pool,
            endTime,
            burn,
            totalWinners,
            ticketValue
        ) = lottery.roundInfo(current);
    }

    function getCurrentDistribution() public view returns (uint256[7] memory) {
        uint256 current = lottery.currentRound();
        return lottery.getRoundDistribution(current);
    }
}