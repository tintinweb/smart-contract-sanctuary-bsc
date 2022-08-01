/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

//  SPDX-License-Identifier: MIT
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

// File: @openzeppelin\contracts\access\Ownable.sol

//  : MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

//  : MIT
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

// File: @openzeppelin\contracts\utils\math\SafeMath.sol

//  : MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// File: @chainlink\contracts\src\v0.8\interfaces\VRFCoordinatorV2Interface.sol

//  : MIT
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

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// File: @chainlink\contracts\src\v0.8\VRFConsumerBaseV2.sol

//  : MIT
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

// File: ..\node_modules\@chainlink\contracts\src\v0.8\KeeperBase.sol

//  : MIT
pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: ..\node_modules\@chainlink\contracts\src\v0.8\interfaces\KeeperCompatibleInterface.sol

//  : MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink\contracts\src\v0.8\KeeperCompatible.sol

//  : MIT
pragma solidity ^0.8.0;


abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// File: contracts\Migrations.sol

//  : MIT


pragma solidity ^0.8.0;






contract Lottery is VRFConsumerBaseV2, Ownable, KeeperCompatibleInterface {    
    using SafeMath for uint256;

    //
    IERC20 public _token;
    
    //
    struct UserInfo {
        uint256 depositAmount; 
        uint256 depositTickets;
        uint256 holdAmount;
        uint256 holdTickets;
        uint256 tickets; 
        address addr;
    }
    
    // Rounds
    struct Round {
        uint256 startBlock;
        uint256 endBlock; 
        uint256 endBlock2;
        uint256 Id;
        
        uint256 depositMultiplier;
        uint256 holdMultiplier;
        
        uint256 totalTickets;
        
        uint256[] winnerRatios;
        uint256[] indexWinners;

        uint256[] randomResult;
        uint256 depositAmount;
        
        uint256 winnerPayoutRatio;
        
        uint256 numPlayers;
        mapping (uint256 => UserInfo) players;
        mapping (address => uint256) playerIndex; //+1
    }
    
    uint256 public _numRounds = 0;
    mapping (uint256 => Round) public _rounds;
    
    enum RoundState { START, ACTIVE, END }
    RoundState public _activeRoundState = RoundState.START;
    uint256 public _endRoundState;
    
    uint256 public _pIndex;
    uint256 public _numberOfPlayersToProcessAtStart = 10;
    uint256 public _numberOfPlayersToProcessAtEnd   = 30;
    
    uint256 VRF_WAITING_BLOCKS      = 280; // 24 hours
    uint256 _lastVRFRequestId;
    uint256 _lastVRFRequestBlockNumber;
    
    uint256  _sumTickets;
    uint256[] _randomTickets;
    
    // Round parameters
    uint256 public _roundDuration               = 30*24*60*20; // blocks
    
    uint256 public _roundDepositMultiplier      = 50;
    uint256 public _roundHoldMultiplier         = 10;
    
    uint256[] public _roundWinnerRatios;
    
    // 
    uint256 public _roundWinnerPayoutRatio      = 80; // percent
    
    // Auto Pool
    uint256 public _autoPoolBalance; 
    address[] public _autoPoolUsers; 
    mapping (address => uint256) public _autoPoolUserIndex; // +1
    mapping (address => uint256) public _autoPoolUserJoiningAmount; 
    mapping (address => uint256) public _autoPoolUserBalance; 
    
    //
    uint256 public _minJoiningAmount            = 1500 * 10**18;
    uint256 public _minAutoJoiningAmount        = 4000 * 10**18;
    
    // 
    address public _operationAddress;
    
    //
    bool public _isGamePaused = false;
    bool public _informToPauseTheGame = false;       
    
    // ChainLink VRF
    VRFCoordinatorV2Interface public immutable CHAINLINKVRF_COORDINATOR;
    bytes32 _chainLinkVRFKeyHash;  // The gas lane to use, which specifies the maximum gas price to bump to.
    uint32 _chainLinkVRFCallbackGasLimit = 100000;    
    uint16 _chainLinkVRFRequestConfirmations = 15;
    uint64 public _chainLinkVRFSubscriptionId;

    // Events
    event AutoPoolDeposited(address indexed user, uint256 amount);
    event AutoPoolWithdrawal(address indexed user, uint256 amount);
    
    event PlayerDeposited(address indexed user, uint256 indexed roundId, bool isAuto, uint256 amount);
    event PlayerUpdated(address indexed user, uint256 indexed roundId,
        uint256 depositAmount, uint256 depositTickets, uint256 holdAmount, uint256 holdTickets, uint256 tickets);
    
    event Awarded(address indexed winner, uint256 indexed roundId, uint256 amount);
    event OperationTransferred(uint256 indexed roundId, uint256 amount);
    
    //
    constructor(IERC20 token, address chainLinkVRFCoordinator, bytes32 chainLinkVRFKeyHash, uint64 chainLinkVRFSubscriptionId, address operationAddress) 
        VRFConsumerBaseV2(chainLinkVRFCoordinator)         
    {
        _token = token;
        
        //
        CHAINLINKVRF_COORDINATOR = VRFCoordinatorV2Interface(chainLinkVRFCoordinator);
        _chainLinkVRFSubscriptionId = chainLinkVRFSubscriptionId;
        _chainLinkVRFKeyHash = chainLinkVRFKeyHash;
        //
        _operationAddress = operationAddress;
        
        //
        _roundWinnerRatios.push(50);
        _roundWinnerRatios.push(30);
        _roundWinnerRatios.push(20);
        
        // Init 1st round
        initNewRound();
    }   

   function updateChainLinkVRF(bytes32 keyHash, uint64 subscriptionId,
        uint32 callbackGasLimit, uint16 requestConfirmations) external onlyOwner() {
        if (keyHash != 0) {
            _chainLinkVRFKeyHash = keyHash;        
        }

        if (subscriptionId > 0) {
            _chainLinkVRFSubscriptionId = subscriptionId;        
        }
        
        if (callbackGasLimit > 0) {
            _chainLinkVRFCallbackGasLimit = callbackGasLimit;
        }
        
        if (requestConfirmations > 0) {
            _chainLinkVRFRequestConfirmations = requestConfirmations;
        }        
   }

   function updateRoundParameters(uint256 roundDuration,
        uint256 depositMultiplier, uint256 holdMultiplier,
        uint256 winnerRatio,
        uint256 ppNumberAtStart, uint256 ppNumberAtEnd) external onlyOwner() {               

        if (roundDuration > 0) {
            _roundDuration = roundDuration;
            return;
        }

        if (depositMultiplier > 0) {
            _roundDepositMultiplier = depositMultiplier;
        }

        if (holdMultiplier > 0) {
            _roundHoldMultiplier = holdMultiplier;
        }
        
        //
        if (winnerRatio>0) {
            require((winnerRatio >= 80) && (winnerRatio <= 100));            
            _roundWinnerPayoutRatio     = winnerRatio;
        }
        
        //
        if (ppNumberAtStart > 0) {
            _numberOfPlayersToProcessAtStart = ppNumberAtStart;
        }

        if (ppNumberAtEnd > 0) {
            _numberOfPlayersToProcessAtEnd = ppNumberAtEnd;
        }
    }

    function updateMinAmountAndAddress(uint8 command, uint256 amount, address addr) external onlyOwner() {        
        if (command==0) {            
            require(amount>0);
            _minJoiningAmount = amount;
        } else if (command==1) {
            require(amount>0);
            _minAutoJoiningAmount = amount;
        } else if (command==3) {
            _operationAddress = addr;
        }
    }      

    function cudWinner(uint8 command, uint256 pos, uint256 ratio) external onlyOwner() {
        if (command==0) { 
            // create
            require(_roundWinnerRatios.length < 3);
            _roundWinnerRatios.push(ratio);            
            require(sumRoundRatioWinners()<=100);
        } else if (command==1) { 
            // update
            require(_roundWinnerRatios.length-1 >= pos);
            _roundWinnerRatios[pos] = ratio;            
            require(sumRoundRatioWinners()<=100);
        } else if (command==2) { 
            // delete
            require(_roundWinnerRatios.length > 1);
            _roundWinnerRatios.pop();
        }
    }  
    
    function sumRoundRatioWinners() private view returns (uint256 sum) {
        sum = 0;
        
        for (uint256 i=0; i<_roundWinnerRatios.length; i++)
        {
            sum+=_roundWinnerRatios[i];
        }
    }      
    
    function getRoundWinnerRatios(uint256 Id) external view returns (uint256[] memory) {
        require(Id<_numRounds);
        return (_rounds[Id].winnerRatios);
    }
    
    function getRoundIndexWinners(uint256 Id) external view returns (uint256[] memory) {
        require(Id<_numRounds);
        return (_rounds[Id].indexWinners);
    }  
    
    function getRoundPlayerInfo(uint256 Id, address userAddress) external view returns (
        uint256 depositAmount, uint256 depositTickets, uint256 holdAmount, uint256 holdTickets, uint256 tickets) {
        require(Id<_numRounds);
        Round storage round = _rounds[Id];
        uint256 index = round.playerIndex[userAddress];
        if (index > 0) {
            --index;
            UserInfo storage player = round.players[index];
            return (player.depositAmount, player.depositTickets, 
                    player.holdAmount, player.holdTickets, player.tickets);
        }
        else {
            return (0,0,0,0,0);
        }
    }

    function getRoundPlayerInfo2(uint256 Id, uint256 index) external view returns (address addr,
        uint256 depositAmount, uint256 depositTickets, uint256 holdAmount, uint256 holdTickets, uint256 tickets) {
        require(Id < _numRounds);        
        Round storage round = _rounds[Id];
        require(index < round.numPlayers);   
        UserInfo storage player = round.players[index];
        return (player.addr,
            player.depositAmount, player.depositTickets, 
            player.holdAmount, player.holdTickets, player.tickets);        
    }

    function getRoundPlayerAddress(uint256 Id, uint256 playerIndex) external view returns (address) {
        require(Id<_numRounds);
        Round storage round = _rounds[Id];
        require(playerIndex < round.numPlayers);
        UserInfo storage player = round.players[playerIndex];
        return player.addr;
    }
    
    function getAutoPoolUsersLength() external view returns (uint256) {
        return _autoPoolUsers.length;
    }

    function hasUserJoinedRound(uint256 roundId, address addr) public view returns (bool) {
        if (roundId < _numRounds) {
            if (_rounds[roundId].playerIndex[addr] > 0) {
                return true;
            }
        }
        
        return false;
    }

    function hasUserJoinedActiveRound(address addr) external view returns (bool){
        return hasUserJoinedRound(_numRounds-1, addr);        
    }    
    
    // Auto Pool    
    function depositToAutoPool(uint256 amount) external {        
        // check balance        
        require((amount > 0) && (_token.balanceOf(_msgSender()) >= amount));
        
        // transfer
        _token.transferFrom(_msgSender(), address(this), amount);
        
        //
        _autoPoolUserBalance[_msgSender()] += amount;
        _autoPoolBalance += amount;
        
        // Enable auto join
        if (_autoPoolUserBalance[_msgSender()] >= _autoPoolUserJoiningAmount[_msgSender()] &&
            _autoPoolUserJoiningAmount[_msgSender()] >= _minAutoJoiningAmount)
        {
            enableAutoJoin(_msgSender());
        }
        
        //
        emit AutoPoolDeposited(_msgSender(), amount);
    }
    
    function withdrawFromAutoPool(uint256 amount) external {
        require((amount > 0) && 
                (amount <= _autoPoolUserBalance[_msgSender()]) &&
                (amount <= _autoPoolBalance) &&
                (amount <= _token.balanceOf(address(this))));
                
        // transfer tokens
        _token.transfer(_msgSender(), amount);
        
        // 
        _autoPoolUserBalance[_msgSender()] -= amount;
        _autoPoolBalance -= amount;

        // Disable auto join
        if (_autoPoolUserBalance[_msgSender()] < _autoPoolUserJoiningAmount[_msgSender()])
        {
            disableAutoJoin(_msgSender());
        }
                
        //
        emit AutoPoolWithdrawal(_msgSender(), amount);
    }
    
    function userUpdateAutoPoolJoiningAmount(uint256 amount) external {
        
        require(_token.totalSupply() >= amount);
        
        _autoPoolUserJoiningAmount[_msgSender()] = amount;
        
        // Enable auto join
        if (amount >= _minAutoJoiningAmount && _autoPoolUserBalance[_msgSender()]>= amount)
        {
            enableAutoJoin(_msgSender());
        }
    }
    
    function enableAutoJoin(address userAddress) private {
        
        if (_autoPoolUserIndex[userAddress]==0) {  
            _autoPoolUsers.push(userAddress);
            _autoPoolUserIndex[userAddress] = _autoPoolUsers.length;
        }
    }
    
    function disableAutoJoin(address userAddress) private {
        
        uint256 indexOfUser = _autoPoolUserIndex[userAddress];
        
        if (indexOfUser>0) {
        
            indexOfUser--; // index in array
            
            if (indexOfUser < _autoPoolUsers.length - 1)
            {
                address addrLastElement = _autoPoolUsers[_autoPoolUsers.length-1];
                
                // Move the last element into the place to delete
                _autoPoolUsers[indexOfUser] = addrLastElement;
                
                // update index of last element
                _autoPoolUserIndex[addrLastElement] = indexOfUser + 1;
            }
            
            // update index of user to zero
            _autoPoolUserIndex[userAddress] = 0;
            
            // Remove the last element
            _autoPoolUsers.pop();
        }
    }      
    
    function isUserInAutoPool(address userAddress) public view returns (bool) {
        return (_autoPoolUserIndex[userAddress] > 0);
    }
    
    // Init new round
    function initNewRound() private {        
        uint256 roundId = _numRounds++;
        
        Round storage newRound = _rounds[roundId];
        newRound.startBlock = block.number;
        newRound.endBlock = block.number + _roundDuration;
        newRound.endBlock2 = newRound.endBlock;
        newRound.Id = roundId;
        newRound.depositMultiplier = _roundDepositMultiplier;
        newRound.holdMultiplier = _roundHoldMultiplier;
        newRound.winnerPayoutRatio = _roundWinnerPayoutRatio;
        
        //
        for (uint256 i = 0; i < _roundWinnerRatios.length; i++) {
            newRound.winnerRatios.push(_roundWinnerRatios[i]);
        }       
        
        //        
        if (_informToPauseTheGame) {
            _informToPauseTheGame = false;
            _isGamePaused = true;
            _pIndex = 0;
            _activeRoundState = RoundState.ACTIVE;
        } else {
            _pIndex = (_autoPoolUsers.length > 0 ? _autoPoolUsers.length : 0 );
            _activeRoundState = (_pIndex == 0 ? RoundState.ACTIVE : RoundState.START);
        }
    }
    
    function controlTheGame(uint8 command) external onlyOwner() {
        if (command==0) { // Pause            
            _informToPauseTheGame = !_informToPauseTheGame;
        } else if (command==1) {// Resume
            require(_isGamePaused);
            _isGamePaused = false;       
            _informToPauseTheGame = false;     
        } else { // Force to end active round
            require(_activeRoundState == RoundState.ACTIVE);
        
            //
            Round storage round = _rounds[_numRounds-1];
            round.endBlock = block.number;
        }        
    }    

    function userJoinActiveRound(uint256 depositAmount) external {
        
        require(_isGamePaused == false, "Game is paused.");
        require(depositAmount > 0, "Amount is zero.");
        
        //
        require(_activeRoundState == RoundState.ACTIVE, "Cannot join at this state.");
        
        //
        Round storage round = _rounds[_numRounds-1];
        
        //
        require(block.number < round.endBlock, "Cannot join at this block.");
        
        //
        if (round.playerIndex[_msgSender()] == 0) {
            require(depositAmount >= _minJoiningAmount, "Deposit amount is less than minimum joining amount.");    
        }       
        
        // check balance
        uint256 balance = _token.balanceOf(_msgSender());
        require(balance >= depositAmount, "Balance is not enough.");
        
        // transfer the fee
        _token.transferFrom(_msgSender(), address(this), depositAmount);
        
        round.depositAmount += depositAmount;
        
        // add/update player of the round
        if (round.playerIndex[_msgSender()] > 0) {
            // update 
            UserInfo storage player = round.players[round.playerIndex[_msgSender()]-1];
            player.depositAmount += depositAmount;
            
            // add tickets for newly deposited amount
            uint256 newDepositTickets = depositAmount*round.depositMultiplier;
            player.depositTickets += newDepositTickets;
            player.tickets += newDepositTickets;
            round.totalTickets += newDepositTickets;
            
            //
            emit PlayerUpdated(_msgSender(), round.Id, 
                player.depositAmount, player.depositTickets, player.holdAmount, player.holdTickets, player.tickets);
        }
        else {
            // add player 
            uint256 holdDuration = ((round.endBlock>=block.number?round.endBlock-block.number:0)*100) / (round.endBlock-round.startBlock);
            uint256 remainingBalance = (balance-depositAmount) + _autoPoolUserBalance[_msgSender()];
            
            //
            round.players[round.numPlayers] = UserInfo({
                addr: _msgSender(),
                depositAmount: depositAmount,
                depositTickets: depositAmount*round.depositMultiplier,
                holdAmount: remainingBalance,
                holdTickets: remainingBalance*round.holdMultiplier*holdDuration/100,
                tickets: 0
            });

            //
            UserInfo storage player = round.players[round.numPlayers];
            player.tickets = player.depositTickets + player.holdTickets;
            round.totalTickets += player.tickets;
            
            //
            ++round.numPlayers;
            round.playerIndex[_msgSender()] = round.numPlayers;
            
            //
            emit PlayerUpdated(_msgSender(), round.Id, 
                player.depositAmount, player.depositTickets, player.holdAmount, player.holdTickets, player.tickets);
        }
        
        //
        emit PlayerDeposited(_msgSender(), round.Id, false, depositAmount);
    }    

    // KEEPER
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = hasWork();
        performData = "";
    }

    function performUpkeep(bytes calldata /* performData */) external override {        
        if (hasWork()==false) {
            return;
        }

        //
        Round storage round = _rounds[_numRounds-1];
        
        //
        if (_activeRoundState == RoundState.START) {                       
            // Start of round
            uint256 countPlayer = _numberOfPlayersToProcessAtStart;
            
            uint256 mRoundTotalTickets = round.totalTickets;
            uint256 mRoundDepositAmount = round.depositAmount;
            uint256 mRoundNumberPlayers = round.numPlayers;
            uint256 mRoundIndex = _pIndex;
            
            // Not overflow
            if (_autoPoolUsers.length>0)
            {
                if (mRoundIndex > _autoPoolUsers.length) {
                    mRoundIndex = _autoPoolUsers.length;
                }
            } else {
                _pIndex = 0;
                _activeRoundState = RoundState.ACTIVE;
                                
                return;
            }
            
            //
            uint256 joiningAmount;
            uint256 autoPoolUserBalance;
            
            //
            while (countPlayer>0 && mRoundIndex>0) {
                
                address addr = _autoPoolUsers[mRoundIndex-1];
                
                // check if this address is started
                if (round.playerIndex[addr]>0) {
                    if (mRoundIndex>1) {
                        --mRoundIndex;
                        continue;
                    } else {
                        mRoundIndex = 0;
                        break;
                    }
                }
                
                // meet the requirements?
                joiningAmount = _autoPoolUserJoiningAmount[addr];
                autoPoolUserBalance = _autoPoolUserBalance[addr];
                
                if (autoPoolUserBalance < joiningAmount || joiningAmount < _minAutoJoiningAmount) {
                    
                    disableAutoJoin(addr);
                    
                    //
                    if (mRoundIndex>1) {
                        --mRoundIndex;
                        continue;
                    } else {
                        mRoundIndex = 0;
                        break;
                    }
                }
                
                //
                autoPoolUserBalance -= joiningAmount;
                
                //
                require(_autoPoolBalance >= joiningAmount, "Auto Pool balance is not enough");
                _autoPoolBalance -= joiningAmount;
                
                //
                _autoPoolUserBalance[addr] = autoPoolUserBalance;
                mRoundDepositAmount += joiningAmount;
                
                //
                uint256 balance = _token.balanceOf(addr) + autoPoolUserBalance;
                
                // add player
                round.players[mRoundNumberPlayers] = UserInfo({
                    addr: addr,
                    depositAmount: joiningAmount,
                    depositTickets: joiningAmount*round.depositMultiplier,
                    holdAmount: balance,
                    holdTickets: balance*round.holdMultiplier,
                    tickets: 0
                });
                
                //
                UserInfo storage player = round.players[mRoundNumberPlayers];
                
                //
                player.tickets = player.depositTickets + player.holdTickets;
                mRoundTotalTickets += player.tickets;
                
                //
                ++mRoundNumberPlayers;
                round.playerIndex[addr] = mRoundNumberPlayers;
                
                //
                --countPlayer;
                
                //
                emit PlayerDeposited(addr, round.Id, true, joiningAmount);
                emit PlayerUpdated(addr, round.Id, 
                    player.depositAmount, player.depositTickets, player.holdAmount, player.holdTickets, player.tickets);
                
                //
                if (mRoundIndex>1) {
                    --mRoundIndex;
                } else {
                    mRoundIndex = 0;
                    break;
                }
            }
            
            //
            round.totalTickets = mRoundTotalTickets;
            round.depositAmount = mRoundDepositAmount;
            round.numPlayers = mRoundNumberPlayers;
            _pIndex = mRoundIndex;
            
            // 
            if (mRoundIndex==0) {
                _activeRoundState = RoundState.ACTIVE;
            }            
        } 
        else if (_activeRoundState == RoundState.ACTIVE) {
            // 
            _activeRoundState = RoundState.END;
            
            //
            _pIndex = round.numPlayers;
            _endRoundState = 0;            
        }
        else if (_activeRoundState == RoundState.END) {
            // End of round
            if (round.numPlayers==0) { // no player
                initNewRound();                
                return;
            }
            
            //
            if (_endRoundState==0) { // State 0: check balance of players
                uint256 countPlayer = _numberOfPlayersToProcessAtEnd;
                
                uint256 mRoundTotalTickets = round.totalTickets;
                uint256 mRoundIndex = _pIndex;
                uint256 holdTickets;
                
                while (countPlayer>0 && mRoundIndex>0) {
                    //
                    UserInfo storage player = round.players[mRoundIndex-1];
                    holdTickets = player.holdTickets;
                    
                    if (holdTickets > 0) {
                        // check balance
                        uint256 balance = _token.balanceOf(player.addr) + _autoPoolUserBalance[player.addr];
                        
                        if (balance < player.holdAmount) {
                            // reset hold tickets due to player does not hold token as the first deposit
                            player.tickets          -= holdTickets;
                            mRoundTotalTickets      -= holdTickets;
                            player.holdTickets      = 0;
                            
                            //
                            emit PlayerUpdated(player.addr, round.Id, 
                                player.depositAmount, player.depositTickets, player.holdAmount, player.holdTickets, player.tickets);
                        }
                    }
                    
                    //
                    --countPlayer;
                    --mRoundIndex;
                }
                
                round.totalTickets = mRoundTotalTickets;
                _pIndex = mRoundIndex;
                
                //
                if (mRoundIndex==0) {
                    round.endBlock2 = block.number;
                    _lastVRFRequestBlockNumber = 0;
                    _endRoundState = 1;
                }                
            }
            else if (_endRoundState==1) { // State 1: get random numbers based on total tickets. Random number:  [0, total tickets-1]
                
                if (round.randomResult.length == 0) {
                    //
                    if (block.number > _lastVRFRequestBlockNumber + VRF_WAITING_BLOCKS) {                        
                        _lastVRFRequestId = CHAINLINKVRF_COORDINATOR.requestRandomWords(
                            _chainLinkVRFKeyHash,
                            _chainLinkVRFSubscriptionId,
                            _chainLinkVRFRequestConfirmations,
                            _chainLinkVRFCallbackGasLimit,
                            uint32(round.winnerRatios.length)
                        );
                        
                        _lastVRFRequestBlockNumber = block.number;
                    }
                }
                else {
                    // 
                    _endRoundState = 2;
                    _pIndex = round.numPlayers;
                    _sumTickets = 0;
                    
                    //
                    delete _randomTickets;                    

                    for (uint256 i = 0; i < round.winnerRatios.length; i++) {
                        _randomTickets.push(round.randomResult[i] % round.totalTickets);
                    }
                    
                    sortDesc(_randomTickets, int(0), int(_randomTickets.length-1), false, round.players);                    
                }
                
            } 
            else if (_endRoundState==2) { // State 2: Find winners based on random ticket numbers
                
                require(_randomTickets.length > 0);
            
                uint256 countPlayer = _numberOfPlayersToProcessAtEnd;
                uint256 mRoundIndex = _pIndex;
                uint256 sumTickets = _sumTickets;
                uint256 idx;
                
                while (countPlayer>0 && mRoundIndex>0) {
                    idx = mRoundIndex-1;
                    
                    //
                    sumTickets += round.players[idx].tickets;
                    
                    while (_randomTickets.length>0) {
                        if (sumTickets > _randomTickets[_randomTickets.length-1]) {
                            // found a winner
                            round.indexWinners.push(idx);
                            _randomTickets.pop();
                        }
                        else
                        {
                            break;
                        }
                    }
                    
                    // finish ?
                    if (_randomTickets.length==0) {
                        --countPlayer;
                        mRoundIndex=0;                        
                        break;
                    }
                    
                    //
                    --countPlayer;
                    --mRoundIndex;
                }
                
                //
                _pIndex = mRoundIndex;
                _sumTickets = sumTickets;
                
                // finished
                if (mRoundIndex==0) {
                    _endRoundState = 3;
                }                
            } 
            else if (_endRoundState==3) { // State 3: Reward
                
                require(round.indexWinners.length > 0);

                // Sort winners based on tickets descending
                sortDesc(round.indexWinners, int(0), int(round.indexWinners.length-1), true, round.players);
                
                // 
                uint256 balance = _token.balanceOf(address(this));
                uint256 pBalance = balance.sub(_autoPoolBalance);
                uint256 rBalance = pBalance.sub(round.depositAmount);
                
                // Reward winners
                uint256 winnersAmount = round.depositAmount * round.winnerPayoutRatio / 100;
                uint256 oneWinnerAmount;
                
                for (uint256 i=0; i < round.indexWinners.length && i < round.winnerRatios.length; i++) {
                    oneWinnerAmount = winnersAmount*round.winnerRatios[i]/100;
                    _token.transfer(round.players[round.indexWinners[i]].addr, oneWinnerAmount);
                    
                    //
                    emit Awarded(round.players[round.indexWinners[i]].addr, round.Id, oneWinnerAmount);
                }
                
               
               
                // Transfer to Operation Wallet
                uint256 operationAmount = rBalance +
                    round.depositAmount * (100 - round.winnerPayoutRatio) / 100;
                    
                if (operationAmount>0) {
                    _token.transfer(_operationAddress, operationAmount);
                    emit OperationTransferred(round.Id, operationAmount);
                }
                
                // Start a new round
                initNewRound();
            }
        }        
    }
    
    function hasWork() private view returns (bool) {
        
        if (_isGamePaused) {
            return false;
        }

        Round storage round = _rounds[_numRounds-1];
        
        //
        if (_activeRoundState == RoundState.START)
        {
            if (_pIndex>0) {
                return true;
            }
        } 
        else if (_activeRoundState == RoundState.ACTIVE) {
            if (round.endBlock <= block.number) {
                return true;    
            }
        }
        else  {            
            if (round.numPlayers>0) {
                if (_endRoundState<=3) {
                    if (_endRoundState==1) {
                        if ((round.randomResult.length == 0 && block.number > _lastVRFRequestBlockNumber + VRF_WAITING_BLOCKS) ||
                            (round.randomResult.length > 0)) {
                            return true;
                        }
                        else {
                            return false;
                        }
                    }
                    else {
                        return true;
                    }
                }
            }
            else {
                return true;
            }
        }
            
        //
        return false;
    }

    /**
     * Callback function used by VRF Coordinator
     */      
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        if (_lastVRFRequestId == requestId) {
            _rounds[_numRounds-1].randomResult = randomWords;
        }
    }

    // SORTING    
    function sortDesc(uint[] storage arr, int left, int right, bool usePlayerTickets, mapping (uint256 => UserInfo) storage players) private {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = (usePlayerTickets ? players[arr[uint(left + (right - left) / 2)]].tickets : arr[uint(left + (right - left) / 2)]);
        while (i < j) {
            if (usePlayerTickets) {
                while (players[arr[uint(i)]].tickets > pivot) i++;
                while (players[arr[uint(j)]].tickets < pivot) j--;
            }
            else {
                while (arr[uint(i)] > pivot) i++;
                while (arr[uint(j)] < pivot) j--;
            }
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j) {
            sortDesc(arr, left, j, usePlayerTickets, players);
        }

        if (i < right) {
            sortDesc(arr, i, right, usePlayerTickets, players);
        }
    }
}