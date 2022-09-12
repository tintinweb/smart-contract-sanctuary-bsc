/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

pragma solidity ^0.8.0;
// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


pragma solidity ^0.8.4;

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

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


pragma solidity ^0.8.0;

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
    function owner() internal view virtual returns (address) {
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

// File: @openzeppelin/contracts/utils/Address.sol


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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{value : value}(data);
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

contract FantomHouseEshare is VRFConsumerBaseV2, Ownable, ReentrancyGuard {
    VRFCoordinatorV2Interface COORDINATOR;
    using SafeERC20 for IERC20;

    // ChainLink VRF configs
    uint64 private s_subscriptionId = 333;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;

    // bsc mainnet
	// 200 gwei Key Hash    0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04
	// 500 gwei Key Hash    0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7
	// 1000 gwei Key Hash    0x17cd473250a9a479dc7f234c64332ed4bc8af9e8ded7556aa6e66d83da49f470
    bytes32 keyHash = 0x17cd473250a9a479dc7f234c64332ed4bc8af9e8ded7556aa6e66d83da49f470; // 1000 Gwei Limit

    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    uint256 maxBetPercent = 750000000000000000; // default 0.75%
    uint256 minBet = 100000000000000000; // default 0.1 Eshare (When Eshare was $300)

    uint256 payout = 1950000000000000000; // default 1.95x

    uint256 betFeePercent = 1500000000000000000; // default 1.5%
    uint256 bettingRefPercent = 100000000000000000; // default 0.1%

    uint256 minHouseDeposit = 50000000000000000000; // default 50 Eshare (Which was around $15000)
    uint256 housePoolDepositFeePercent = 500000000000000000; // default 0.5%
    uint256 houseDepositRefPercent = 100000000000000000; // default 0.1%
	
	uint256 timeNowWithdraw;
	uint256 timeNowBet;

    address treasuryWallet = 0xb42553Fea162318A380283285238A654D21FC13c;
    address private constant ESHARE_ADDRESS = 0xDB20F6A8665432CE895D724b417f77EcAC956550;
    IERC20 private eshare = IERC20(ESHARE_ADDRESS);

    struct RequestParams {
        address vrfCoordinator;
        bytes32 keyHash;
        uint32 callbackGasLimit;
        uint16 requestConfirmations;
        uint32 numWords;
    }

    struct Balance {
        bool existingUser;
        uint256 depositAmount;
        uint256 userContributionPortion;
    }

    struct Bet {
        uint256 pending;
        address user;
        uint256 id;
        uint256 amount;
        uint256 payout;
        uint256 block;
        address referral;
        uint256 headOrTail;
        uint256 resultHeadOrTail;
    }

    Balance housePoolBalance;
    Balance betTreasury;
    Balance depositTreasury;
    mapping(address => uint256) rewardPool;
    mapping(address => uint256) myTotalWaged;

    mapping(address => Balance) userHouseBalances;
    address[] depositors;

    event RequestedBet(uint256 indexed requestId, address indexed requestUser, uint256 predictedUserFace, uint256 betAmount);
    event ReceivedBetResult(uint256 userWon, uint256 indexed requestId, address indexed requestUser, uint256 response, uint256 sortedUserFace, uint256 predictedUserFace, uint256 betAmount, uint256 winMoney);

    uint256 pauseBet = 0;
    uint256 pauseHouseDeposit = 0;
    uint256 pauseHouseWithdraw = 1;

    mapping(address => uint256) depositRefEarned;
    mapping(address => uint256) betRefEarned;
    mapping(address => uint256) lastBetBlock;

    /// @notice Maps bets IDs to Bet information.
    mapping(uint256 => Bet) public bets;
    uint256[] ids;

    /// @notice Maps users addresses to bets IDs
    mapping(address => uint256[]) internal _userBets;
    uint256 startBetIdIndex;
	
    uint256 internal biggestBet;
    uint256 internal totalBettingVolume;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }

    // ChainLink VRF params
    function setRequestParameters(
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        bytes32 _keyHash,
        uint64 subscriptionId
    ) external onlyOwner() {
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        keyHash = _keyHash;
        s_subscriptionId = subscriptionId;
    }

    /* =================== Modifier =================== */
    modifier onlyTreasury() {
        require(msg.sender == treasuryWallet, "Only Treasury");
        _;
    }

    /* ========== VIEW FUNCTIONS ========== */
    function getBiggestBet() public view returns (uint256){
        return biggestBet;
    }

    function getTotalBettingVolume() public view returns (uint256){
        return totalBettingVolume;
    }	

    function isHouseDepositPaused() public view returns (uint256){
        return pauseHouseDeposit;
    }

    function isBetPaused() public view returns (uint256){
        return pauseBet;
    }

    function isHouseWithdrawPaused() public view returns (uint256){
        return pauseHouseWithdraw;
    }

    function getMinHouseDeposit() public view returns (uint256){
        return minHouseDeposit;
    }

    function getBetRefEarned(address _address) public view returns (uint256){
        return betRefEarned[_address];
    }

    function getDepositRefEarned(address _address) public view returns (uint256){
        return depositRefEarned[_address];
    }

    function getHouseDepositRefPercent() public view returns (uint256){
        return houseDepositRefPercent;
    }

    function getBettingRefPercent() public view returns (uint256){
        return bettingRefPercent;
    }

    function getMyTotalWaged(address _address) public view returns (uint256){
        return myTotalWaged[_address];
    }

    function getUserContributionPortion(address _address) public view returns (uint256){
        return userHouseBalances[_address].userContributionPortion;
    }

    function getRequestParams() public view returns (RequestParams memory){
        return RequestParams({
        vrfCoordinator : vrfCoordinator,
        keyHash : keyHash,
        callbackGasLimit : callbackGasLimit,
        requestConfirmations : requestConfirmations,
        numWords : numWords
        });
    }

    // Displays the Current Payout schedule.
    function getPayout() public view returns (uint256) {
        return payout;
    }

    // Displays the current house pool deposit fee.
    function getHousePoolDepositFeePercent() public view returns (uint256) {
        return housePoolDepositFeePercent;
    }

    // Displays the current bet fee.
    function getBetFeePercent() public view returns (uint256) {
        return betFeePercent;
    }

    // Displays the Current House Pool Balance.
    function getHousePoolBalance() public view returns (uint256) {
        return housePoolBalance.depositAmount;
    }

    // Displays the Current Max Bet amount.
    function getMaxBetPercent() public view returns (uint256){
        return maxBetPercent;
    }

    // Displays the Current Min Bet amount. (ex: 1.0000, etc)
    function getMinBet() public view returns (uint256){
        return minBet;
    }

    function getRewardPoolBalance(address _address) public view returns (uint256) {
        return rewardPool[_address];
    }

    // Takes Input of Wallet Address, displays the user’s House Pool Contribution Balance.
    function getUserHouseBalance(address _address) public view returns (uint256) {
        return userHouseBalances[_address].depositAmount;
    }

    // Takes input of Wallet Address, displays information / status of last 50 bets of the wallet.
    function getUserLastFiftyBetsHistory(address _address) public view returns (Bet [50] memory) {
        uint256[] memory userBetsIds = _userBets[_address];

        Bet[50] memory userBets;
        uint256 userBetsIndex = 0;
        for (uint256 i = userBetsIds.length; i > 0 && userBetsIndex < 50; i--) {
            userBets[userBetsIndex] = bets[userBetsIds[i - 1]];
            userBetsIndex++;
        }

        return userBets;
    }

    function getBetTreasuryBalance() public view returns (uint256) {
        return betTreasury.depositAmount;
    }

    function getDepositTreasuryBalance() public view returns (uint256) {
        return depositTreasury.depositAmount;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function depositHouse(uint256 _amount, address _referral) external {
        require(pauseHouseDeposit == 0, "House Deposit is not open now");
        require(_amount >= minHouseDeposit, "Smaller than minimum deposit amount");
        address _sender = msg.sender;
        if (_referral == _sender) revert("Referral shouldn't be same as sender");
        if (userHouseBalances[_sender].existingUser == false) {
            if (depositors.length > 50) {
                revert("Depositor club is already full! Please visit Discord for more information.");
            }
        }

        uint256 depositFeePercent;
        if (_referral == address(0)) {
            depositFeePercent = housePoolDepositFeePercent;
        } else {
            depositFeePercent = housePoolDepositFeePercent - houseDepositRefPercent;
            uint256 referralReward = houseDepositRefPercent * _amount / 1e18 / 100;
            rewardPool[_referral] += referralReward;
            depositRefEarned[_referral] += referralReward;
        }

        uint256 fee = depositFeePercent * _amount / 1e18 / 100;
        depositTreasury.depositAmount += fee;
        fee = housePoolDepositFeePercent * _amount / 1e18 / 100;
        uint256 amountAfterFee = _amount - fee;
        housePoolBalance.depositAmount += amountAfterFee;

        if (userHouseBalances[_sender].existingUser == false) {
            userHouseBalances[_sender].existingUser = true;
            depositors.push(_sender);
        }
        userHouseBalances[_sender].depositAmount += amountAfterFee;

        for (uint256 i = 0; i < depositors.length; i++) {
            address _depositor = depositors[i];
            if (userHouseBalances[_depositor].depositAmount > 0) {
                userHouseBalances[_depositor].userContributionPortion = calculateUserContributionPortion(_depositor);
            }
        }

        eshare.safeTransferFrom(_sender, address(this), _amount);
    }

    function withdrawHouse(uint256 _amount) external nonReentrant {
        require(pauseHouseWithdraw == 0, "House Withdraw is not open now");
        address _sender = msg.sender;
        require(_amount <= housePoolBalance.depositAmount, "exceed house pool amount");
        housePoolBalance.depositAmount -= _amount;

        uint256 _depositAmount = userHouseBalances[_sender].depositAmount;
        require(_amount <= _depositAmount, "exceed user house amount");

        userHouseBalances[_sender].depositAmount -= _amount;

        for (uint256 i = 0; i < depositors.length; i++) {
            if (housePoolBalance.depositAmount != 0) {
                address _depositor = depositors[i];
                userHouseBalances[_depositor].userContributionPortion = calculateUserContributionPortion(_depositor);
            }
        }
        eshare.safeTransfer(msg.sender, _amount);
    }

    function withdrawHouseAuto(uint256 _amount) external nonReentrant {
	    timeNowWithdraw = block.timestamp % 604800;
		// Requires now to be UTC Tuesday 00:00 ~ 04:00 AM
        require (432000 < timeNowWithdraw && timeNowWithdraw < 446400, "Withdrawal is only available UTC Tue 00:00 AM ~ 04:00 AM");

        address _sender = msg.sender;
        require(_amount <= housePoolBalance.depositAmount, "exceed house pool amount");
        housePoolBalance.depositAmount -= _amount;

        uint256 _depositAmount = userHouseBalances[_sender].depositAmount;
        require(_amount <= _depositAmount, "exceed user house amount");

        userHouseBalances[_sender].depositAmount -= _amount;

        for (uint256 i = 0; i < depositors.length; i++) {
            if (housePoolBalance.depositAmount != 0) {
                address _depositor = depositors[i];
                userHouseBalances[_depositor].userContributionPortion = calculateUserContributionPortion(_depositor);
            }
        }
        eshare.safeTransfer(msg.sender, _amount);
    }

    function withdrawReward(uint256 _amount) external nonReentrant {
        address _sender = msg.sender;
        uint256 reward = rewardPool[_sender];
        require(_amount <= reward, "reward amount");
        rewardPool[_sender] -= _amount;
        eshare.safeTransfer(msg.sender, _amount);
    }

    function claimBetTreasuryAll() external onlyTreasury nonReentrant {
        uint256 _amount = getBetTreasuryBalance();
        require(_amount > 0, "exceed amount");
        betTreasury.depositAmount -= _amount;
        eshare.safeTransfer(msg.sender, _amount);
    }

    function claimDepositTreasuryAll() external onlyTreasury nonReentrant {
        uint256 _amount = getDepositTreasuryBalance();
        require(_amount > 0, "exceed amount");
        depositTreasury.depositAmount -= _amount;
        eshare.safeTransfer(msg.sender, _amount);
    }

    // Takes input of MaxBet percentage Unit Number. Changes the % number that determines max bet amount.
    function setMaxBetPercent(uint256 _new) external onlyOwner {
        require(_new <= 5000000000000000000, "maximum bet amount can't be set larger than 5% of total house pool balance");
        maxBetPercent = _new;
    }

    // Takes input of MinBet Uint number.
    function setMinBet(uint256 _new) external onlyOwner {
        minBet = _new;
    }

    // Takes input of Payout Uint Number then divide by 100 as it's percentage, changes the Payout x.
    function setPayout(uint256 _new) external onlyOwner {
        require(_new <= 2000000000000000000 && _new >= 1850000000000000000, "payout must be between 1.85x and 2.00x");
        payout = _new;
    }

    // Takes input of Fee Uint Number then divide by 100 as it's percentage, changes the Fee taken from house deposit fee for Treasury.
    function setHousePoolDepositFeePercent(uint256 _new) external onlyOwner {
        require(_new <= 5000000000000000000 && _new >= 1000000000000000, "bet fee percent must be between 0.001% and 5%");
        housePoolDepositFeePercent = _new;
    }

    // Takes input of Fee Uint Number then divide by 100 as it's percentage, changes the Fee taken from bet for Treasury.
    function setBetFeePercent(uint256 _new) external onlyOwner {
        require(_new <= 5000000000000000000 && _new >= 1000000000000000, "bet fee percent must be between 0.001% and 5%");
        betFeePercent = _new;
    }

    function setTreasuryWallet(address _new) external onlyOwner {
        treasuryWallet = _new;
    }

    function refund() external nonReentrant {
        uint256 _betIdIndex;
        uint256 _length = ids.length;
        if ((ids.length - startBetIdIndex) > 77) {
            _length = startBetIdIndex + 77;
        }
        for (uint256 i = startBetIdIndex; i < _length; i++) {
            Bet memory _bet = bets[ids[i]];
			// 100 Block is about 5 minutes in BSC
            if (block.number >= _bet.block + 100) {
                if (_bet.pending == 1) {
                    bets[ids[i]].pending = 2;
                    rewardPool[_bet.user] += _bet.amount;
                }
                _betIdIndex = i;
            }
        }
        if (_betIdIndex != 0) {
            startBetIdIndex = _betIdIndex + 1;
        }
    }

    function bet(uint256 _betAmount, uint256 _faceSide, address _referral) external nonReentrant {
	
		timeNowBet = block.timestamp % 604800;
        require(timeNowBet < 431700 || timeNowBet > 446700, "Betting is disabled while withdrawal is enabled" );
		
		address _sender = msg.sender;
        uint256 _lastBetBlock = lastBetBlock[_sender];
        if (_lastBetBlock != 0 && block.number - _lastBetBlock < 2) {
            revert("You are placing bet too fast. Please wait at least 10 seconds.");
        }
        lastBetBlock[_sender] = block.number;

        require(pauseBet == 0, "pauseBet");
        require(_betAmount >= minBet, "smaller than minimum bet amount");
        require(_betAmount <= maxBetPercent * housePoolBalance.depositAmount / 1e18 / 100, "Larger than maximum bet amount");
        require(_faceSide == 0 || _faceSide == 1, "Face side must be 0 or 1");
        if (_referral == _sender) revert("Referral shouldn't be same as sender");

        eshare.safeTransferFrom(_sender, address(this), _betAmount);
        uint256 id = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        Bet memory newBet = Bet({
        pending : 1,
        user : _sender,
        id : id,
        amount : _betAmount,
        payout : 0,
        block : block.number,
        referral : _referral,
        headOrTail : _faceSide,
        resultHeadOrTail : 0
        });
        _userBets[_sender].push(id);
        bets[id] = newBet;
        ids.push(id);
		if (biggestBet < _betAmount) {
            biggestBet = _betAmount;
        }
        totalBettingVolume += _betAmount;
        emit RequestedBet(id, _sender, _faceSide, _betAmount);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        Bet storage _bet = bets[requestId];
        require(_bet.id == requestId, "request ID");
        require(msg.sender == vrfCoordinator, "Fulfillment only permitted by Coordinator");
        require(_bet.pending == 1, "bet should be pending");
        uint256 sortedFace = randomWords[0] % 2;
        //0 is Head, 1 is Cross
        uint256 playerPredict = _bet.headOrTail;
        address player = _bet.user;
        uint256 playerBetAmount = _bet.amount;

        uint256 userWon = 0;
        if (sortedFace == 0 && playerPredict == 0) {
            // user bet and result is Head
            userWon = 1;
        } else if (sortedFace == 1 && playerPredict == 1) {
            // user bet and result is Cross
            userWon = 1;
        } else {
            // user lost
            userWon = 0;
        }
        uint256 calculatedFee;
        uint256 winMoney = 0;
        address _referral = _bet.referral;
        if (_referral != address(0)) {
            uint256 _bettingRefPercent = bettingRefPercent;
            calculatedFee = playerBetAmount * (betFeePercent - _bettingRefPercent) / 1e18 / 100;
            uint256 referralReward = _bettingRefPercent * playerBetAmount / 1e18 / 100;
            rewardPool[_referral] += referralReward;
            betRefEarned[_referral] += referralReward;
        } else {
            calculatedFee = playerBetAmount * betFeePercent / 1e18 / 100;
        }
        betTreasury.depositAmount += calculatedFee;
        calculatedFee = playerBetAmount * betFeePercent / 1e18 / 100;
        uint256 payoutAppliedAmount = (payout * playerBetAmount / 1e18) - playerBetAmount;
        if (userWon == 1) {
            rewardPool[player] += payoutAppliedAmount + playerBetAmount;
            winMoney = payoutAppliedAmount + playerBetAmount;
            housePoolBalance.depositAmount -= payoutAppliedAmount + calculatedFee;
            for (uint256 i = 0; i < depositors.length; i++) {
                userHouseBalances[depositors[i]].depositAmount -= (payoutAppliedAmount + calculatedFee) * userHouseBalances[depositors[i]].userContributionPortion / 1e18;
            }
        } else {
            housePoolBalance.depositAmount += playerBetAmount - calculatedFee;
            for (uint256 i = 0; i < depositors.length; i++) {
                userHouseBalances[depositors[i]].depositAmount += (playerBetAmount - calculatedFee) * userHouseBalances[depositors[i]].userContributionPortion / 1e18;
            }
        }
        myTotalWaged[player] += playerBetAmount;

        _bet.resultHeadOrTail = sortedFace;
        _bet.payout = winMoney;
        _bet.pending = 0;

        emit ReceivedBetResult(userWon, requestId, player, randomWords[0], sortedFace, playerPredict, playerBetAmount, winMoney);
    }

    function z1_pauseBet() external onlyOwner {
        pauseBet = 1;
    }

    function z2_unpauseBet() external onlyOwner {
        pauseBet = 0;
    }

    function z3_pauseHouseDeposit() external onlyOwner {
        pauseHouseDeposit = 1;
    }

    function z4_unpauseHouseDeposit() external onlyOwner {
        pauseHouseDeposit = 0;
    }

    function z5_pauseHouseWithdraw() external onlyOwner {
        pauseHouseWithdraw = 1;
    }

    function z6_unpauseHouseWithdraw() external onlyOwner {
        pauseHouseWithdraw = 0;
    }

    function z7_emergencyReturn() external onlyOwner {
        uint256 _totalDepositors = z1_totalDepositors();
        if (_totalDepositors > 100) {
            returnDepositAndRemoveDepositor(50, true);
        } else if (_totalDepositors > 50) {
            returnDepositAndRemoveDepositor(25, true);
        } else {
            returnDepositAndRemoveDepositor(_totalDepositors, false);
            for (uint i = 0; i < _totalDepositors; i++) {
                depositors.pop();
            }
        }
    }

    function returnDepositAndRemoveDepositor(uint256 _length, bool _shouldRemoveDepositor) internal {
        for (uint i = 0; i < _length; i++) {
            address _depositor = depositors[i];
            uint256 _depositAmount = userHouseBalances[_depositor].depositAmount;
            eshare.safeTransfer(_depositor, _depositAmount);
            housePoolBalance.depositAmount -= _depositAmount;
            delete userHouseBalances[_depositor];
            if (_shouldRemoveDepositor) {
                removeDepositor(i);
            }
        }
    }

    function removeDepositor(uint256 index) internal {
        depositors[index] = depositors[depositors.length - 1];
        depositors.pop();
    }

    function z1_totalDepositors() public view returns (uint256) {
        return depositors.length;
    }

    function z2_totalBets() public view returns (uint256) {
        return ids.length;
    }

    function z3_betRefundedUpto() public view returns (uint256) {
        return startBetIdIndex;
    }

    function setBettingRefPercent(uint256 _new) external onlyOwner {
        require(_new <= 250000000000000000 && _new >= 100000000000000, "betting referral percent must be between 0.0001% and 0.25%");
        bettingRefPercent = _new;
    }

    function setHouseDepositRefPercent(uint256 _new) external onlyOwner {
        require(_new <= 250000000000000000 && _new >= 100000000000000, "house deposit referral percent must be between 0.0001% and 0.25%");
        houseDepositRefPercent = _new;
    }

    function setMinHouseDeposit(uint256 _new) external onlyOwner {
        minHouseDeposit = _new;
    }

    function calculateUserContributionPortion(address _address) internal view returns (uint256) {
        return 1e18 * userHouseBalances[_address].depositAmount / housePoolBalance.depositAmount;
    }
}