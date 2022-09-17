// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

import "./RNGInterface.sol";

contract RNGChainlink is RNGInterface, VRFConsumerBase, Ownable {
  event KeyHashSet(bytes32 keyHash);
  event FeeSet(uint256 fee);
  event VrfCoordinatorSet(address indexed vrfCoordinator);
  event VRFRequested(uint256 indexed requestId, bytes32 indexed chainlinkRequestId);

  /// @dev The keyhash used by the Chainlink VRF
  bytes32 public keyHash;

  /// @dev The request fee of the Chainlink VRF
  uint256 public fee;

  /// @dev A counter for the number of requests made used for request ids
  uint32 public requestCount;

  /// @dev A list of random numbers from past requests mapped by request id
  mapping(uint32 => uint256) internal randomNumbers;

  /// @dev A list of blocks to be locked at based on past requests mapped by request id
  mapping(uint32 => uint32) internal requestLockBlock;

  /// @dev A mapping from Chainlink request ids to internal request ids
  mapping(bytes32 => uint32) internal chainlinkRequestIds;

  /// @dev Public constructor
  constructor(address _vrfCoordinator, address _link) VRFConsumerBase(_vrfCoordinator, _link) {
    emit VrfCoordinatorSet(_vrfCoordinator);
  }

  function getLink() external view returns (address) {
    return address(LINK);
  }

  /// @notice Allows governance to set the VRF keyhash
  /// @param _keyhash The keyhash to be used by the VRF
  function setKeyhash(bytes32 _keyhash) external onlyOwner {
    keyHash = _keyhash;

    emit KeyHashSet(keyHash);
  }

  /// @notice Allows governance to set the fee per request required by the VRF
  /// @param _fee The fee to be charged for a request
  function setFee(uint256 _fee) external onlyOwner {
    fee = _fee;

    emit FeeSet(fee);
  }

  /// @notice Gets the last request id used by the RNG service
  /// @return requestId The last request id used in the last request
  function getLastRequestId() external view override returns (uint32 requestId) {
    return requestCount;
  }

  /// @notice Gets the Fee for making a Request against an RNG service
  /// @return feeToken The address of the token that is used to pay fees
  /// @return requestFee The fee required to be paid to make a request
  function getRequestFee() external view override returns (address feeToken, uint256 requestFee) {
    return (address(LINK), fee);
  }

  /// @notice Sends a request for a random number to the 3rd-party service
  /// @dev Some services will complete the request immediately, others may have a time-delay
  /// @dev Some services require payment in the form of a token, such as $LINK for Chainlink VRF
  /// @return requestId The ID of the request used to get the results of the RNG service
  /// @return lockBlock The block number at which the RNG service will start generating time-delayed randomness.  The calling contract
  /// should "lock" all activity until the result is available via the `requestId`
  function requestRandomNumber() external override returns (uint32 requestId, uint32 lockBlock) {
    lockBlock = uint32(block.number);

    // collect fee for payment
    require(LINK.transferFrom(msg.sender, address(this), fee), "RNGChainlink/fee-transfer-failed");

    // send request (costs fee)
    requestId = _requestRandomness();

    requestLockBlock[requestId] = lockBlock;

    emit RandomNumberRequested(requestId, msg.sender);
  }

  /// @notice Checks if the request for randomness from the 3rd-party service has completed
  /// @dev For time-delayed requests, this function is used to check/confirm completion
  /// @param requestId The ID of the request used to get the results of the RNG service
  /// @return isCompleted True if the request has completed and a random number is available, false otherwise
  function isRequestComplete(uint32 requestId) external view override returns (bool isCompleted) {
    return randomNumbers[requestId] != 0;
  }

  /// @notice Gets the random number produced by the 3rd-party service
  /// @param requestId The ID of the request used to get the results of the RNG service
  /// @return randomNum The random number
  function randomNumber(uint32 requestId) external view override returns (uint256 randomNum) {
    return randomNumbers[requestId];
  }

  /// @dev Requests a new random number from the Chainlink VRF
  /// @dev The result of the request is returned in the function `fulfillRandomness`
  function _requestRandomness() internal returns (uint32 requestId) {
    // Get next request ID
    requestId = _getNextRequestId();

    // Complete request
    bytes32 vrfRequestId = requestRandomness(keyHash, fee);
    chainlinkRequestIds[vrfRequestId] = requestId;

    emit VRFRequested(requestId, vrfRequestId);
  }

  /// @notice Callback function used by VRF Coordinator
  /// @dev The VRF Coordinator will only send this function verified responses.
  /// @dev The VRF Coordinator will not pass randomness that could not be verified.
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint32 internalRequestId = chainlinkRequestIds[requestId];

    // Store random value
    randomNumbers[internalRequestId] = randomness;

    emit RandomNumberCompleted(internalRequestId, randomness);
  }

  /// @dev Gets the next consecutive request ID to be used
  /// @return requestId The ID to be used for the next request
  function _getNextRequestId() internal returns (uint32 requestId) {
    requestCount++;
    requestId = requestCount;
  }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

/**
 * @title Random Number Generator Interface
 * @notice Provides an interface for requesting random numbers from 3rd-party RNG services (Chainlink VRF, Starkware VDF, etc..)
 */
interface RNGInterface {
  /**
   * @notice Emitted when a new request for a random number has been submitted
   * @param requestId The indexed ID of the request used to get the results of the RNG service
   * @param sender The indexed address of the sender of the request
   */
  event RandomNumberRequested(uint32 indexed requestId, address indexed sender);

  /**
   * @notice Emitted when an existing request for a random number has been completed
   * @param requestId The indexed ID of the request used to get the results of the RNG service
   * @param randomNumber The random number produced by the 3rd-party service
   */
  event RandomNumberCompleted(uint32 indexed requestId, uint256 randomNumber);

  /**
   * @notice Gets the last request id used by the RNG service
   * @return requestId The last request id used in the last request
   */
  function getLastRequestId() external view returns (uint32 requestId);

  /**
   * @notice Gets the Fee for making a Request against an RNG service
   * @return feeToken The address of the token that is used to pay fees
   * @return requestFee The fee required to be paid to make a request
   */
  function getRequestFee() external view returns (address feeToken, uint256 requestFee);

  /**
   * @notice Sends a request for a random number to the 3rd-party service
   * @dev Some services will complete the request immediately, others may have a time-delay
   * @dev Some services require payment in the form of a token, such as $LINK for Chainlink VRF
   * @return requestId The ID of the request used to get the results of the RNG service
   * @return lockBlock The block number at which the RNG service will start generating time-delayed randomness.
   * The calling contract should "lock" all activity until the result is available via the `requestId`
   */
  function requestRandomNumber() external returns (uint32 requestId, uint32 lockBlock);

  /**
   * @notice Checks if the request for randomness from the 3rd-party service has completed
   * @dev For time-delayed requests, this function is used to check/confirm completion
   * @param requestId The ID of the request used to get the results of the RNG service
   * @return isCompleted True if the request has completed and a random number is available, false otherwise
   */
  function isRequestComplete(uint32 requestId) external view returns (bool isCompleted);

  /**
   * @notice Gets the random number produced by the 3rd-party service
   * @param requestId The ID of the request used to get the results of the RNG service
   * @return randomNum The random number
   */
  function randomNumber(uint32 requestId) external returns (uint256 randomNum);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";

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
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
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
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}