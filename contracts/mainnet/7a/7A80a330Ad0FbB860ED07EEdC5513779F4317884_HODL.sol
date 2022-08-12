/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: Unlicensed
//
//   __    __     ______     _____       __
//  |  |  |  |   /  __  \   |      \    |  |
//  |  |__|  |  |  |  |  |  |   _   \   |  |
//  |   __   |  |  |  |  |  |  |_)   |  |  |
//  |  |  |  |  |  `--'  |  |       /   |  |____
//  |__|  |__|   \______/   |_____ /    |_______|
//
//

pragma solidity 0.8.16;

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
   * @param ticketsToDraw - The number of uint256 random values you'd like to receive
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
    uint32 ticketsToDraw
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

pragma solidity 0.8.16;

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
 * @dev callbackGasLimit, ticketsToDraw),
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


pragma solidity 0.8.16;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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

interface IWBNB {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    receive() external payable;

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}

pragma solidity 0.8.16;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

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
contract Ownable is Context, Initializable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {}

    function initOwner(address owner_) public initializer {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

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

interface IPancakePair {
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
        uint256 amountETHDesired,
        uint256 amountAMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountETH,
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
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountETH);

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
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountETH);

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
    /*
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountETH);
    */
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

// File: contracts/protocols/bep/Utils.sol

pragma solidity 0.8.16;

library Utils {
    using SafeMath for uint256;
   
    function calculateBNBReward(
        uint256 currentBalance,
        uint256 currentBNBPool,
        uint256 totalSupply,
        uint256 rewardHardcap
    ) public pure returns (uint256) {
        uint256 bnbPool = currentBNBPool > rewardHardcap ? rewardHardcap : currentBNBPool;
        return bnbPool.mul(currentBalance).div(totalSupply);
    }

    function calculateTopUpClaim(
        uint256 currentRecipientBalance,
        uint256 basedRewardCycleBlock,
        uint256 threshHoldTopUpRate,
        uint256 amount
    ) public pure returns (uint256) {
        uint256 rate = amount.mul(100).div(currentRecipientBalance);

        if (rate >= threshHoldTopUpRate) {
            uint256 incurCycleBlock = basedRewardCycleBlock
                .mul(rate)
                .div(100);

            if (incurCycleBlock >= basedRewardCycleBlock) {
                incurCycleBlock = basedRewardCycleBlock;
            }

            return incurCycleBlock;
        }

        return 0;
    }

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
        public
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function swapETHForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmount
        }(
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function swapTokensForTokens(
        address routerAddress,
        address recipient,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // make the swap
        pancakeRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ethAmount, // wbnb input
            0, // accept any amount of BNB
            path,
            address(recipient),
            block.timestamp + 360
        );
    }

    function getAmountsout(uint256 amount, address routerAddress)
        public
        view
        returns (uint256 _amount)
    {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = address(this);

        // fetch current rate
        uint256[] memory amounts = pancakeRouter.getAmountsOut(amount, path);
        return amounts[1];
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) public {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 360
        );
    }
    
    /**
    * @dev Returns the stacked amount of rewards. 
    *
    * First add reflections to the amount of stacked tokens. If the stackingRate is 0
    * stacking was started before refelctions were implemented into the contract. 
    * 
    * Then calculate the reward and check with the stacking limit.
    *
    *   "Scared money don't make money" - Billy Napier 
    */
    function calcStacked(HODLStruct.stacking memory tmpstacking, uint256 totalsupply, uint256 currentRate, uint256 stackingRate) public view returns (uint256) {
        uint256 reward;
        uint256 amount;

        uint256 stackedTotal = 1E6 + (block.timestamp-tmpstacking.tsStartStacking).mul(1E6) / tmpstacking.cycle;
        uint256 stacked = stackedTotal.div(1E6);
        uint256 rest = stackedTotal-stacked.mul(1E6);
        
        uint256 initialBalance = address(this).balance;

        if (stackingRate > 0)
        {
            amount = tmpstacking.amount * stackingRate / currentRate;
        } else {
            amount = tmpstacking.amount;
        }
        
        if (initialBalance >= tmpstacking.hardcap)
        {
            reward = uint256(tmpstacking.hardcap) * amount / totalsupply * stackedTotal / 1E6;
            if (reward >= initialBalance) reward = 0;

            if (reward == 0 || initialBalance.sub(reward) < tmpstacking.hardcap)
            {
                reward = initialBalance - calcReward(initialBalance, totalsupply /amount, stacked, 15);
                reward += initialBalance.sub(reward) * amount / totalsupply * rest / 1E6;
            }
        } else {
            reward = initialBalance - calcReward(initialBalance, totalsupply / amount, stacked, 15); 
            reward += initialBalance.sub(reward) * amount / totalsupply * rest / 1E6;
        }

        return reward > tmpstacking.stackingLimit ? uint256(tmpstacking.stackingLimit) : reward;
    }

    /** 
    * @dev Computes `k * (1+1/q) ^ N`, with precision `p`. The higher
    * the precision, the higher the gas cost. To prevent overflows devide
    * exponent into 3 exponents with max n^10
    */
    function calcReward(uint256 coefficient, uint256 factor, uint256 exponent, uint256 precision) public pure returns (uint256) {
        
        precision = exponent < precision ? exponent : precision;
        if (exponent > 100) {
            precision = 30;
        }
        if (exponent > 200) exponent = 200;

        uint256 reward = coefficient;
        uint256 calcExponent = exponent * (exponent-1) / 2;
        uint256 calcFactor_1 = 1;
        uint256 calcFactor_2 = 1;
        uint256 calcFactor_3 = 1;
        uint256 i;

        for (i = 2; i <= precision; i += 2){
            if (i > 20) {
                calcFactor_1 = factor**10;
                calcFactor_2 = calcFactor_1;
                 calcFactor_3 = factor**(i-20);
            }
            else if (i > 10) {
                calcFactor_1 = factor**10;
                calcFactor_2 = factor**(i-10);
                calcFactor_3 = 1;
            }
            else {
                calcFactor_1 = factor**i;
                calcFactor_2 = 1;
                calcFactor_3 = 1;
            }
            reward += coefficient * calcExponent / calcFactor_1 / calcFactor_2 / calcFactor_3;
            calcExponent = i == exponent ? 0 : calcExponent * (exponent-i) * (exponent-i-1) / (i+1) / (i+2);  
        }
        
        calcExponent = exponent;

        for (i = 1; i <= precision; i += 2){
            if (i > 20) {
                calcFactor_1 = factor**10;
                calcFactor_2 = calcFactor_1;
                calcFactor_3 = factor**(i-20);
            }
            else if (i > 10) {
                calcFactor_1 = factor**10;
                calcFactor_2 = factor**(i-10);
                calcFactor_3 = 1;
            }
            else {
                calcFactor_1 = factor**i;
                calcFactor_2 = 1;
                calcFactor_3 = 1;
            }
            reward -= coefficient * calcExponent / calcFactor_1 / calcFactor_2 / calcFactor_3;
            calcExponent = i == exponent ? 0 : calcExponent * (exponent-i) * (exponent-i-1) / (i+1) / (i+2);  
        }

        return reward;
    }

    function _getValues(uint256 tAmount, uint256 currentRate, uint256 _taxFee, uint256 _liquidityFee)
        public
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        )
    {
        (
            tTransferAmount,
            tFee,
            tLiquidity
        ) = _getTValues(tAmount, _taxFee, _liquidityFee);
        (rAmount, rTransferAmount, rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            currentRate
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount,uint256 _taxFee, uint256 _liquidityFee)
        private
        pure
        returns (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        )
    {      
        tFee = tAmount.mul(_taxFee).div(10**3);
        tLiquidity = tAmount.mul(_liquidityFee).div(10**3);
        tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

}

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(
            IPancakeFactory(factory).getPair(tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountETH) {
        require(amountA > 0, "PancakeLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "PancakeLibrary: INSUFFICIENT_LIQUIDITY"
        );
        amountETH = amountA.mul(reserveB) / reserveA;
    }

}

// File: contracts/protocols/bep/ReentrancyGuard.sol

pragma solidity 0.8.16;

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

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

// File: contracts/protocols/HODL.sol

pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

contract HODL is Context, IBEP20, Ownable, ReentrancyGuard, VRFConsumerBaseV2 {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxTx;

    // trace BNB claimed rewards and reinvest value
    mapping(address => uint256) public userClaimedBNB;
    uint256 public totalClaimedBNB;

    mapping(address => uint256) public userreinvested;
    uint256 public totalreinvested;

    // trace gas fees distribution
    uint256 private totalgasfeesdistributed;
    mapping(address => uint256) private userrecievedgasfees;

    address public deadAddress;

    address[] private _excluded;

    uint256 private MAX;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    IPancakeRouter02 public pancakeRouter;
    address public pancakePair;

    bool private _inSwapAndLiquify;

    uint256 private daySeconds;

    struct WalletAllowance {
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => WalletAllowance) userWalletAllowance;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event ClaimBNBSuccessfully(
        address recipient,
        uint256 ethReceived,
        uint256 nextAvailableClaimDate
    );

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor() VRFConsumerBaseV2(vrfCoordinator){
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }

    mapping(address => bool) isBlacklisted;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "Err"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "Err"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Err");
        (uint256 rAmount, , , , , ) = Utils._getValues(tAmount, _getRate(), _taxFee, _liquidityFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Err");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = Utils._getValues(tAmount, _getRate(), _taxFee, _liquidityFee);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = Utils._getValues(tAmount, _getRate(), _taxFee, _liquidityFee);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(rAmount <= _rTotal,"Err");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) external onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Pancake router.');
        require(!_isExcluded[account], "Err");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Err");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function includeExcludeFromFee(address account, bool _enable) external onlyOwner {
        _isExcludedFromFee[account] = _enable;
    }

    //to receive BNB from pancakeRouter when swapping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getRate() public view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rLottery = rLiquidity.mul(taxes.lottery).div(_Taxes);
        rLiquidity -= rLottery;
        _rOwned[lotterywallet] += rLottery;
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**3);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256){
        return _amount.mul(_liquidityFee).div(10**3);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0) && spender != address(0), "Err");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0) && to != address(0), "Err");
        require(amount > 0, "Err");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            reflectionFeesDisabled
        ) {
            takeFee = false;
        }

        // take sell fee
        if (
            pairAddresses[to] &&
            from != address(this) &&
            from != owner()
        ) {
            /*
            *   "If you can't hold, you won't be rich" - CZ
            */
            ensureMaxTxAmount(from, to, amount);          
            _taxFee = selltax.mul(_Reflection).div(100); 
            _liquidityFee = selltax.mul(_Taxes).div(100);
            if (!_inSwapAndLiquify) {
                swapAndLiquify(from, to);
            }
        }
        
        // take buy fee
        else if (
            pairAddresses[from] && to != address(this) && to != owner()
        ) {
            _taxFee = buytax.mul(_Reflection).div(100);
            _liquidityFee = buytax.mul(_Taxes).div(100);
            if (LotteryEnabled && amount >= LotteryThreshold) {
                LotteryTickets.push(HODLStruct.LotteryTicket(to,0,false,balanceOf(lotterywallet),block.timestamp));
                TicketNumbers[to].push(LotteryTickets.length-1);
                pendingLotteryTickets++;
                totalLotteryTickets++;
                if  (totalLotteryTickets % AddCommunityTicket == 0)
                {
                    LotteryTickets.push(HODLStruct.LotteryTicket(address(this),0,false,balanceOf(lotterywallet),block.timestamp));
                    TicketNumbers[address(this)].push(LotteryTickets.length-1);
                    pendingLotteryTickets++;
                    totalLotteryTickets++;
                }
                if ((pendingLotteryTickets-requestedRandomNumbers) >= ticketsToDraw) {
                    requestRandomWords(ticketsToDraw);
                    requestedRandomNumbers += ticketsToDraw;
                }
            }
        }
        
        // take transfer fee
        else {
            if (takeFee && from != owner() && from != address(this)) {
                _taxFee = transfertax.mul(_Reflection).div(100);
                _liquidityFee = transfertax.mul(_Taxes).div(100);
            }
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        // top up claim cycle for recipient and sender
        topUpClaimCycleAfterTransfer(sender, recipient, amount);

        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = Utils._getValues(amount, _getRate(), _taxFee, _liquidityFee);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(amount);
        } 
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        } 

        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);

        if (!takeFee) restoreAllFee();
    }

    // Innovation for protocol by HODL Team
    uint256 public rewardCycleBlock;
    uint256 private reserve_2;
    uint256 public threshHoldTopUpRate;
    uint256 public _maxTxAmount;
    uint256 public bnbStackingLimit;
    mapping(address => uint256) public nextAvailableClaimDate;
    bool public swapAndLiquifyEnabled;
    uint256 private reserve_5;
    uint256 private reserve_6;

    bool public reflectionFeesDisabled;

    uint256 private _taxFee;
    uint256 private _previousTaxFee;

    // Lottery
    uint256 public LotteryThreshold;
    uint256 public totalLotteryTickets;
    uint256 public LotteryWinningChance;
    uint256 public pendingLotteryTickets;
    uint256 public ticketsToDraw;
    uint256 public AddCommunityTicket;
    uint256 public communityTicketsWinningChance;
    uint256 public burnPercentage;
    uint256 public requestedRandomNumbers;
    //Chainlink
    uint256 private callbackGasLimit;
    uint256 private requestConfirmations;
    uint256 private s_subscriptionId;

    uint256 public selltax;
    uint256 public buytax;
    uint256 public transfertax;

    uint256 public claimBNBLimit;
    uint256 public reinvestLimit;
    uint256 private reserve_1;

    address public lotterywallet;
    address private teamwallet;
    address public marketingwallet;
    address public stackingWallet;
    
    uint256 private _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public minTokenNumberToSell; 
    uint256 public minTokenNumberUpperlimit;

    uint256 public rewardHardcap;

    Taxes public taxes;
    
    struct Taxes {
        uint256 bnbReward;
        uint256 liquidity;
        uint256 marketing;
        uint256 reflection;
        uint256 lottery;
    }

    uint256 private _Reflection;
    uint256 private _Taxes;

    address public triggerwallet;

    mapping(address => bool) public pairAddresses;

    address public HodlMasterChef;

    mapping(address => uint256) private firstBuyTimeStamp;

    mapping(address => HODLStruct.stacking) public rewardStacking;
    bool public stackingEnabled;

    mapping(address => uint256) private stackingRate;

    //Lottery
    bool public     LotteryEnabled;
    HODLStruct.LastLotteryWin public    lastLotteryWinner;
    HODLStruct.LotteryTicket[] public   LotteryTickets;
    mapping(address => uint[]) private   TicketNumbers;

    //Chainlink
    VRFCoordinatorV2Interface COORDINATOR;
    address private vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 private keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;

    event changeValue(string tag, uint256 _value);
    event changeEnable(string tag, bool _enable);
    event changeAddress(string tag, address _address);

    event StartStacking(
        address sender,
        uint256 amount
    );
    event LotteryWin(address _wallet, uint256 amount);
    event CommunityWin(uint256 amount);

    function setExcludeFromMaxTx(address _address, bool value) external onlyOwner{
        _isExcludedFromMaxTx[_address] = value;
    }

    /*
    *   "Rome was not built in a day" - John Heywood
    */
    function calculateBNBReward(address ofAddress) external view returns (uint256){
        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(deadAddress)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        
        return Utils.calculateBNBReward(
                balanceOf(address(ofAddress)),
                address(this).balance,
                totalsupply,
                rewardHardcap
            );
    }

    /** @dev Function to claim the rewards.
    *   First calculate the rewards with checking rewardhardcap and current pool
    *   Depending on user selected percentage pay reward in bnb or reinvest in tokens
    *
    *   "Keep building. That's how you prove them wrong." - David Gokhstein     
    */
    function redeemRewards(uint256 perc) external isHuman nonReentrant {
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: too early");
        require(balanceOf(msg.sender) > 0, "Error: no Hodl");

        uint256 totalsupply = uint256(_tTotal)
            .sub(balanceOf(deadAddress)) // exclude burned wallet
            .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        uint256 currentBNBPool = address(this).balance;

        uint256 reward = currentBNBPool > rewardHardcap ? rewardHardcap.mul(balanceOf(msg.sender)).div(totalsupply) : currentBNBPool.mul(balanceOf(msg.sender)).div(totalsupply);

        uint256 rewardreinvest;
        uint256 rewardBNB;

        if (perc == 100) {
            require(reward > claimBNBLimit, "Reward below gas fee");
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {
            
            require(reward > reinvestLimit, "Reward below gas fee");

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;

            uint256 rAmount = expectedtoken * _getRate();
        
            if (_isExcluded[msg.sender]) { 
                _rOwned[msg.sender] += rAmount;
                _tOwned[msg.sender] += expectedtoken;
                _rOwned[address(this)] -= rAmount;
            } else {
                _rOwned[msg.sender] += rAmount;
                _rOwned[address(this)] -= rAmount;
            }
            emit Transfer(address(this), msg.sender, expectedtoken);

        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            // send bnb to user
            (bool success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Err");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }

    /* @dev Top up next claim date of sender and recipient. 
    */
    function topUpClaimCycleAfterTransfer(address _sender, address _recipient, uint256 amount) private {
        //_recipient
        uint256 currentBalance = balanceOf(_recipient);
        if ((_recipient == owner() && nextAvailableClaimDate[_recipient] == 0) || currentBalance == 0 || _sender == HodlMasterChef) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
        } else {
            nextAvailableClaimDate[_recipient] += Utils.calculateTopUpClaim(
                                                currentBalance,
                                                rewardCycleBlock,
                                                threshHoldTopUpRate,
                                                amount);
            if (nextAvailableClaimDate[_recipient] > block.timestamp + rewardCycleBlock) {
                nextAvailableClaimDate[_recipient] = block.timestamp + rewardCycleBlock;
            }
        }

        //sender
        if (_recipient != HodlMasterChef) {
            currentBalance = balanceOf(_sender);
            if ((_sender == owner() && nextAvailableClaimDate[_sender] == 0) || currentBalance == 0) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
            } else {
                nextAvailableClaimDate[_sender] += Utils.calculateTopUpClaim(
                                                    currentBalance,
                                                    rewardCycleBlock,
                                                    threshHoldTopUpRate,
                                                    amount);
                if (nextAvailableClaimDate[_sender] > block.timestamp + rewardCycleBlock) {
                    nextAvailableClaimDate[_sender] = block.timestamp + rewardCycleBlock;
                }                                     
            }
        }
    }

    /* @dev Function to ensure that in the last 24h not more tokens selled 
    *   than defined in _maxTxAmount
    */
    function ensureMaxTxAmount(address from, address to, uint256 amount) private {
        if (
            _isExcludedFromMaxTx[from] == false && // default will be false
            _isExcludedFromMaxTx[to] == false // default will be false
        ) {
                WalletAllowance storage wallet = userWalletAllowance[from];

                if (block.timestamp > wallet.timestamp.add(daySeconds)) {
                    wallet.timestamp = 0;
                    wallet.amount = 0;
                }

                uint256 totalAmount = wallet.amount.add(amount);

                require(
                    totalAmount <= _maxTxAmount,
                    "Error"
                );

                if (wallet.timestamp == 0) {
                    wallet.timestamp = block.timestamp;
                }

                wallet.amount = totalAmount;
        }
    }

    /* @dev Function that swaps tokens from the contract for bnb
    *   Bnb is split up due to taxes and send to the specified wallets
    *
    *       "They talk, we build" - Josh from StaySAFU
    */
    function swapAndLiquify(address from, address to) private lockTheSwap {

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 initialBalance = address(this).balance;

        if (contractTokenBalance >= minTokenNumberUpperlimit &&
            initialBalance <= rewardHardcap &&
            swapAndLiquifyEnabled &&
            from != pancakePair &&
            !(from == address(this) && to == address(pancakePair))
            ) {   
                doSwapAndLiquify(initialBalance);       
            }
    }

    /* @dev Same as swapAndLiquify but manually called by the owner
    *   or the triggerWallet.
    */
    function triggerSwapAndLiquify() external lockTheSwap {
        require(((_msgSender() == address(triggerwallet)) || (_msgSender() == owner())) && swapAndLiquifyEnabled, "Error");
        doSwapAndLiquify(address(this).balance);
    }

    /* @dev Function to swap Tokens from the contract to BNB.
    *   Used to fill the pools. Triggered by any sell or manually by the owner.
    */
    function doSwapAndLiquify(uint256 initialBalance) private {

        Utils.swapTokensForEth(address(pancakeRouter), minTokenNumberToSell);       
        uint256 deltaBalance = address(this).balance.sub(initialBalance);

        if (taxes.marketing > 0) {
            // send marketing rewards
            (bool sent, ) = payable(address(marketingwallet)).call{value: deltaBalance.mul(taxes.marketing).div(_Taxes)}("");
            require(sent, "Error");
        }

        if (taxes.liquidity > 0) {
            // add liquidity to pancake
            uint256 liquidityToken = minTokenNumberToSell.mul(taxes.liquidity).div(_Taxes);
            Utils.addLiquidity(
                address(pancakeRouter),
                owner(),
                liquidityToken,
                deltaBalance.mul(taxes.liquidity).div(_Taxes)
            ); 
            emit SwapAndLiquify(liquidityToken, deltaBalance, liquidityToken);
        }    
    }

    /* @dev Send any amount of HODL from the contract to a new address.
    */
    function migrateToken(address _newadress, uint256 _amount) external onlyOwner{
        _tokenTransfer(address(this), _newadress, _amount, false);
    }

    /* @dev Send any amount of WBNB from the contract to a new address.
    */
    function migrateWBnb(address _newadress, uint256 _amount) external onlyOwner {
        IWBNB(payable(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c))).transfer(_newadress,_amount);
    }

    /* @dev Send any amount of BNB from the contract to a new address.
    */
    function migrateBnb(address payable _newadd, uint256 amount) external onlyOwner{
        require(_newadd != address(0), "Error");
        (bool success, ) = address(_newadd).call{value: amount}("");
        require(success, "Error");
    }

    /* @dev Function to change any numeric variable. 
    * _var defines the variable and _value is the new value.
    */
    function changeAnyValue(uint8 _var, uint256 _value) external onlyOwner {
        if (_var == 1) {
            require(_value <= 110, "Err");
            selltax = _value;
            emit changeValue("sell tax", _value);  
        } else if (_var == 2) {
            require(_value <= 110, "Err");
            buytax = _value;
            emit changeValue("buy tax", _value);
        } else if (_var == 3) {
            require(_value <= 110, "Err");
            transfertax = _value;
            emit changeValue("transfer tax", _value);
        } else if (_var == 4) {
            require(_value <= minTokenNumberUpperlimit, "Error");
            minTokenNumberToSell = _value;
            emit changeValue("MinTokenNumberToSell", _value);
        } else if (_var == 5) {
            require(_value >= minTokenNumberToSell, "Err");
            minTokenNumberUpperlimit = _value;
            emit changeValue("MinTokenNumberUpperLimit", _value);
        } else if (_var == 6) {
            require(_value >= 1e18, "Err");
            rewardHardcap = _value;
            emit changeValue("RewardHardcap", _value);
        } else if (_var == 7) {
            require(_value <= 1e16, "Err"); //0.01bnb
            claimBNBLimit = _value;
            emit changeValue("ClaimBNBLimit", _value);
        } else if (_var == 8) {
            require(_value <= 1e16, "Err"); //0.01bnb
            reinvestLimit = _value;
            emit changeValue("ReinvestLimit", _value);
        } else if (_var == 9) {
            require(_value >= 1e16, "Err"); //min 0.01bnb
            bnbStackingLimit = _value;
            emit changeValue("BNBstackingLimit", _value);
        } else if (_var == 10) {
            LotteryThreshold = _value;
            emit changeValue("LotteryThreshold", _value);
        } else if (_var == 11) {
            require(_value > 0, "Err");
            LotteryWinningChance = _value;
            emit changeValue("LotteryWinningChance", _value);
        } else if (_var == 12) {
            require(_value > 0, "Err");
            communityTicketsWinningChance = _value;
            emit changeValue("CommunityWinningChance", _value);
        } else if (_var == 13) {
            require(_value > 0, "Err");
            ticketsToDraw = _value;
        } else if (_var == 14) {
            threshHoldTopUpRate = _value;
            emit changeValue("ThreshHoldTopUpRate", _value);
        } else if (_var == 15) {
            require(_value >= 86400, "Err"); //min 1 day
            rewardCycleBlock = _value;
        } else if (_var == 16) {
            require(_value <= 100 && _value > 0, "Error");
            _maxTxAmount = _tTotal.mul(_value).div(100000);
            emit changeValue("maxTxAmount", _value);
        } else if (_var == 17) {
            require(_value >= 100000, "Err");
            callbackGasLimit = _value;
            emit changeValue("callbackGasLimit", _value);
        } else if (_var == 18) {
            AddCommunityTicket = _value;
            emit changeValue("AddCommunityTicket", _value);
        }
    }

    /* @dev Function to change any address variable. 
    * _var defines the variable and _newaddress is the new address.
    */
    function changeAnyAddress(uint8 _var, address payable _newaddress) external onlyOwner {
        require(_newaddress != address(0), "Error");
        if (_var == 1) {
            marketingwallet = _newaddress;
            emit changeAddress("Marketingwallet", _newaddress);
        } else if (_var == 2) {
            triggerwallet = _newaddress;
            emit changeAddress("Triggerwallet", _newaddress);
        } else if (_var == 3) {
            HodlMasterChef = _newaddress;
            emit changeAddress("HodlMasterChef", _newaddress);
        } else if (_var == 4) {
            stackingWallet = _newaddress;
            emit changeAddress("Stackingwallet", _newaddress);
        } else if (_var == 5) {
            lotterywallet = _newaddress;
            emit changeAddress("Lotterywallet", _newaddress);
        }
    }

    /* @dev Function to change any bool variable. 
    * _var defines the variable and _enable is the new value.
    */
    function enableDisableAnyFunction(uint8 _var, bool _enable) external onlyOwner {
        if (_var == 1) {
            stackingEnabled = _enable;
            emit changeEnable("Stacking", _enable);
        } else if (_var == 2) {
            LotteryEnabled = _enable;
            emit changeEnable("Lottery", _enable);
        } else if (_var == 3) {
            reflectionFeesDisabled = _enable;
            emit changeEnable("reflectionFees", _enable);
        } else if (_var == 4) {
            swapAndLiquifyEnabled = _enable;
            emit changeEnable("SwapAndLiquify", _enable);
        }
    }

    /* @dev Function to change the current taxes. 
    */
    function changeTaxes(uint256 bnbReward, uint256 liquidity, uint256 marketing, uint256 reflection, uint256 lottery) external onlyOwner {
        require(bnbReward + liquidity + marketing + reflection + lottery == 100, "Not 100");
        taxes = Taxes(bnbReward, liquidity, marketing, reflection, lottery);
        _Reflection = taxes.reflection;
        _Taxes = taxes.bnbReward.add
                      (taxes.marketing).add
                      (taxes.liquidity).add
                      (taxes.lottery);
    }
    
    /*  @dev Enable/Disable if address is a HODL Pair address
    */
    function updatePairAddress(address _pairAddress, bool _enable) external onlyOwner {
        pairAddresses[_pairAddress] = _enable;
    }
    
    /*  @dev Function to start rward stacking. the whole tokens (minus 1) are sent to the
    *   stacking wallet. While stacking is enabled the bnb reward is accumulated.
    *   Once the user stops stacking the amount it sent back plus the accumulated reward.
    *
    *       "HODL Bears to ride Bulls" - Adam Roberts
    */
    function startStacking() external {
        
        uint96 balance = uint96(balanceOf(msg.sender)-1E9);

        require(stackingEnabled && !rewardStacking[msg.sender].enabled, "Not available");
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "Error: too early");
        require(balance > 15000000000000000, "Error: Wrong amount");

        rewardStacking[msg.sender] = HODLStruct.stacking(
            true, 
            uint64(rewardCycleBlock), 
            uint64(block.timestamp), 
            uint96(bnbStackingLimit), 
            uint96(balance), 
            uint96(rewardHardcap));

        uint256 currentRate = _getRate();
        stackingRate[msg.sender] = currentRate;

        uint256 rBalance = balance * currentRate;

        if (_isExcluded[msg.sender]) { 
            _tOwned[msg.sender] -= balance;
            _rOwned[msg.sender] -= rBalance;
            _rOwned[stackingWallet] += rBalance;
        } else {
            _rOwned[msg.sender] -= rBalance;
            _rOwned[stackingWallet] += rBalance;
        }
        //_tokenTransfer(msg.sender, stackingWallet, balance, false);
        emit Transfer(msg.sender, stackingWallet, balance);
        emit StartStacking(msg.sender, balance);
    }
    
    /*  @dev Calculate the amount of stacked reward
    */
    function getStacked(address _address) public view returns (uint256) {
        HODLStruct.stacking memory tmpStack =  rewardStacking[_address];
        if (tmpStack.enabled) {
            uint256 totalsupply = uint256(_tTotal)
                .sub(balanceOf(deadAddress)) // exclude burned wallet
                .sub(balanceOf(address(pancakePair))); // exclude liquidity wallet
        
            return Utils.calcStacked(tmpStack, totalsupply, _getRate(), stackingRate[msg.sender]);
        }
        return 0;
    }

    /* @dev Technically same function as 'redeemReward' but with stacked amount and 
    *  stacked claim cycles. Reward is calculated with function getStacked.
    *   
    *   "Max pain before gain in crypto" - Travladd
    *
    *   Reflections are added before amount is sent back to the user
    */
    function stopStackingAndClaim(uint256 perc) external nonReentrant {

        HODLStruct.stacking memory tmpstacking = rewardStacking[msg.sender];

        require(tmpstacking.enabled, "Err");
        uint256 amount;
        uint256 rewardBNB;
        uint256 rewardreinvest;
        uint256 reward = getStacked(msg.sender);
        uint256 currentRate =  _getRate();

        if (perc == 100) {
            rewardBNB = reward;
        } else if (perc == 0) {     
            rewardreinvest = reward;
        } else {
            rewardBNB = reward.mul(perc).div(100);
            rewardreinvest = reward.sub(rewardBNB);
        }

        // BNB REINVEST
        if (perc < 100) {

            // Re-InvestTokens
            uint256 expectedtoken = Utils.getAmountsout(rewardreinvest, address(pancakeRouter));

            // update reinvest rewards
            userreinvested[msg.sender] += expectedtoken;
            totalreinvested += expectedtoken;

            uint256 rExpected = expectedtoken * currentRate;
        
            if (_isExcluded[msg.sender]) { 
                _rOwned[msg.sender] += rExpected;
                _tOwned[msg.sender] += expectedtoken;
                _rOwned[address(this)] -= rExpected;
            } else {
                _rOwned[msg.sender] += rExpected;
                _rOwned[address(this)] -= rExpected;
            }
            emit Transfer(address(this), msg.sender, expectedtoken);

        }

        // BNB CLAIM
        if (rewardBNB > 0) {
            // send bnb to user
            (bool success, ) = address(msg.sender).call{value: rewardBNB}("");
            require(success, "Err");

            // update claimed rewards
            userClaimedBNB[msg.sender] += rewardBNB;
            totalClaimedBNB += rewardBNB;
        }

        uint256 rate = stackingRate[msg.sender];

        if (rate > 0)
        {
            amount = tmpstacking.amount * rate / currentRate;
        } else {
            amount = tmpstacking.amount;
        }

        uint256 rAmount = amount * currentRate;
        
        if (_isExcluded[msg.sender]) { 
            _rOwned[msg.sender] += rAmount;
            _tOwned[msg.sender] += amount;
            _rOwned[stackingWallet] -= rAmount;
        } else {
            _rOwned[msg.sender] += rAmount;
            _rOwned[stackingWallet] -= rAmount;
        }
        emit Transfer(stackingWallet, msg.sender, amount);

        HODLStruct.stacking memory tmpStack;
        rewardStacking[msg.sender] = tmpStack;

        // update rewardCycleBlock
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycleBlock;
        emit ClaimBNBSuccessfully(msg.sender,reward,nextAvailableClaimDate[msg.sender]);
    }

    /* @dev Chainlink function to fulfill random numbers. Is the number below a set limit
    *   the user wins and the tokens from the lottery wallet are transfered to him. A percentage
    *   of the pool is burned.
    *   After the normal draw community tickets are drawn. IF the community wins all tokens from
    *   the lottery pool are sent out as reflection. 
    */
    function fulfillRandomWords(
        uint256,
        uint256[] memory drawnNumbers
    ) internal override {

        uint256 startTicket = totalLotteryTickets-pendingLotteryTickets;
        uint256 currentRate = _getRate();
        uint256 tLotteryAmount;
        uint256 rLotteryAmount;
        uint16 i;
        uint16 number;
        bool won;
        bool community;
        uint16 toEvalute = (uint16)(drawnNumbers.length);

        for(i = 0; i < toEvalute; i++)
        {
            number = (uint16)(drawnNumbers[i] % 1000) + 1;
            HODLStruct.LotteryTicket storage tmpTicket = LotteryTickets[startTicket+i];
            tmpTicket.Number = number;

            community = (tmpTicket.Wallet == address(this)) && (number <= communityTicketsWinningChance);    
            won = community || ((tmpTicket.Wallet != address(this)) && (number <= LotteryWinningChance));
            
            if (won) {
                tmpTicket.Won = true;
                tLotteryAmount = _rOwned[lotterywallet] / currentRate;
                if (tLotteryAmount > tmpTicket.PossibleWinAmount) tLotteryAmount = tmpTicket.PossibleWinAmount;
                //Burn tokens
                tLotteryAmount = burnTokens(tLotteryAmount, currentRate);
                rLotteryAmount = tLotteryAmount * currentRate;
                address winner = tmpTicket.Wallet;

                if (community) {
                    //Reflect tokens
                    _reflectFee(rLotteryAmount, tLotteryAmount);
                    emit CommunityWin(tLotteryAmount);
                } else {
                    //Payout lotterywin
                    _rOwned[winner] += rLotteryAmount;
                    emit Transfer(lotterywallet, winner, tLotteryAmount);
                    emit LotteryWin(winner, tLotteryAmount);
                }
                _rOwned[lotterywallet] -= rLotteryAmount;
                //Set last winner
                lastLotteryWinner = HODLStruct.LastLotteryWin(winner, tLotteryAmount, block.timestamp);
            }
            
        }
        pendingLotteryTickets -= toEvalute;
        requestedRandomNumbers -= toEvalute;
    }

    /* @dev Function to burn a specific amount of tokens
    */
    function burnTokens(uint256 tAmount, uint256 currentRate) private returns(uint256) {
        //Burn tokens
        //Calculate
        uint256 tBurnTokens = tAmount * burnPercentage / (10**3);
        uint256 rBurnTokens = tBurnTokens * currentRate;
        //Burn
        _rOwned[deadAddress] += rBurnTokens;
        _rOwned[lotterywallet] -= rBurnTokens;
        emit Transfer(lotterywallet, deadAddress, tBurnTokens);

        return (tAmount - tBurnTokens);
    }

    /* @dev External view function to show the latest Lotterytickets of a givin wallet
    */
    function getAllTickets(address wallet) external view returns(HODLStruct.LotteryTicket[] memory) {
        HODLStruct.LotteryTicket[] memory ret = new HODLStruct.LotteryTicket[](TicketNumbers[wallet].length);
        for (uint i = 0; i < TicketNumbers[wallet].length; i++) {
            ret[i] = LotteryTickets[TicketNumbers[wallet][i]];
        }
        return ret;
    }

    /* @dev Chainlink function to request random numbers
    */
    function requestRandomWords(uint256 amount) private {
        // Will revert if subscription is not set and funded.
        COORDINATOR.requestRandomWords(
        keyHash,
        (uint16)(s_subscriptionId),
        (uint16)(requestConfirmations),
        (uint32)(callbackGasLimit),
        (uint32)(amount)
        );
    }

    /* @dev External function to request random numbers manually
    *   Needed in case of a failed request.
    */
    function evaluatePendingLottery(uint32 _amount) external onlyOwner {
        requestRandomWords(_amount);
    }
    
}

library HODLStruct {
    struct stacking {
        bool enabled;
        uint64 cycle;
        uint64 tsStartStacking;
        uint96 stackingLimit;
        uint96 amount;
        uint96 hardcap;   
    }
 
    struct LotteryTicket {
        address Wallet;
        uint16 Number;
        bool Won;  
        uint256 PossibleWinAmount;
        uint256 TimeStamp; 
    }

    struct LastLotteryWin {
        address Winner;
        uint256 Amount;
        uint256 TimeStamp;
    }
}