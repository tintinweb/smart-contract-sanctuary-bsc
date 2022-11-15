// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ConfirmedOwnerWithProposal.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/OwnableInterface.sol";

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAllowed {
    function isCustomFeeReceiverOrSender(address sender, address receiver)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function WBNB() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
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

    function addLiquidityBNB(
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

    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPermit {
    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./libs/IPermit.sol";
import "./libs/IDEX.sol";
import "./libs/guard.sol";
import "./libs/IAllowed.sol";

contract Lottery is VRFConsumerBaseV2, Ownable, ReentrancyGuard {
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    address public gasAddress;

    mapping(address => uint256) public gasForHostingAmount;
    mapping(address => uint256) public gasForEntriesAmount;
    mapping(address => uint256) public gasForEndLotteryAmount;
    mapping(address => uint256) public gasForBurnAmount;
    mapping(address => uint256) public gasForDistributeAmount;
    address public router;
    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyhash;

    // rto burn fee and maxHostFee
    uint256 public burnFee = 2;
    uint256 public maxHostFee = 20;

    uint256 public feeForLink = 300000000000000;

    mapping(address => bool) public allowedTokens;

    address public rtoAddress;

    struct Premium {
        uint256 index;
        string name;
        uint256 price;
        bool exists;
    }

    mapping(uint256 => Premium) public premium;
    mapping(string => uint256[]) public premiumBuys;
    address public premiumAddressFee;
    address public premiumPayToken;

    struct Host {
        uint256 amountPerNumber;
        uint256 maxBetsPerAddress;
        address token;
        address hostAddress;
        uint256 hostFee;
        uint256[] winnerPercentages;
        LOTTERY_STATE state;
        uint256 totalEntriesAmount;
        uint256 deadline;
        // string[] memory socials;
    }

    struct UserEntry {
        address user;
        bool entered;
    }

    struct Winners {
        bool isEnd;
        address winner1;
        address winner2;
        address winner3;
        uint256 num1;
        uint256 num2;
        uint256 num3;
        uint256 amount1;
        uint256 amount2;
        uint256 amount3;
    }
    mapping(string => Winners) public winners;
    mapping(string => Host) public games;
    mapping(string => bool) public isChallengeExists;
    mapping(uint256 => string) public requestToChallenge;
    mapping(string => uint256) public challengeToRequest;
    mapping(string => uint256[]) public allEntries;
    mapping(string => mapping(uint256 => UserEntry)) public entriesOwnedByUser;
    mapping(string => mapping(address => uint256[]))
        public allEntriesOwnedByUser;

    mapping(address => uint256) public forBurn;

    address private _manager;
    modifier onlyMananger() {
        require(msg.sender == _manager, "Ownable: only mananger can call");
        _;
    }

    // cl
    VRFCoordinatorV2Interface private COORDINATOR;
    uint64 public subscriptionId;
    uint256[] public requestIds;
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    uint32 public callbackGasLimit = 2000000;
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    uint256 public minDeadlineSec = 86400;
    uint256 public maxDeadlineSec = 604800;

    bool public isAutomaticDistribution = false;

    IAllowed private calc =
        IAllowed(0xE7F325D73cF851b2FaEC0037ED359e4920deC28d);

    // 0
    // 1
    // 2
    constructor(
        address _vrfCoordinator,
        bytes32 _keyhash,
        uint64 _subscriptionId
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        keyhash = _keyhash;
        subscriptionId = _subscriptionId;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    }

    /// @dev Setting the version as a function so that it can be overriden
    function version() public pure virtual returns (string memory) {
        return "1";
    }

    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function setAddPremium(
        uint256 index,
        string memory name,
        uint256 price,
        bool exists
    ) external onlyOwner {
        premium[index] = Premium(index, name, price, exists);
    }

    function setPremium(address _feeAddress, address _token)
        external
        onlyOwner
    {
        premiumAddressFee = _feeAddress;
        premiumPayToken = _token;
    }

    function setAllowedTokens(address _token, bool allow) external onlyOwner {
        allowedTokens[_token] = allow;
    }

    function setManager(address _new_men) external onlyOwner {
        _manager = _new_men;
    }

    function setCalcContract(address _calc) external onlyOwner {
        calc = IAllowed(_calc);
    }

    function updateCBFee(uint32 _fee) external onlyOwner {
        callbackGasLimit = _fee;
    }

    function setRTOContract(address _rto) external onlyOwner {
        rtoAddress = _rto;
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;
    }

    function setGasAddress(address _gasAddr) external onlyOwner {
        gasAddress = _gasAddr;
    }

    function setAutoDistribution(bool _auto) external onlyOwner {
        isAutomaticDistribution = _auto;
    }

    function setMinMaxDeadline(uint256 _min, uint256 _max) external onlyOwner {
        minDeadlineSec = _min;
        maxDeadlineSec = _max;
    }

    function resetGasFees(address _token) external onlyOwner {
        gasForEndLotteryAmount[_token] = 0;
        gasForEntriesAmount[_token] = 0;
        gasForHostingAmount[_token] = 0;
    }

    function hostLottery(
        string memory challengeId,
        uint256 deadlineInSeconds,
        uint256[] memory numbers, // maxNumber [0] amountPerNumber [1]
        address _token,
        uint256[] memory _winnerPercentages,
        address host,
        uint256 hostFee,
        uint256[] memory nonceExpiry,
        uint8 v,
        bytes32[] memory rs
    ) external nonReentrant {
        uint256 startGas = gasleft();
        _hostLottery(
            challengeId,
            deadlineInSeconds,
            numbers,
            _token,
            _winnerPercentages,
            host,
            hostFee,
            nonceExpiry,
            v,
            rs
        );
        gasForHostingAmount[_token] =
            (startGas - gasleft() + 21000) *
            tx.gasprice;
    }

    function _hostLottery(
        string memory challengeId,
        uint256 deadlineInSeconds,
        uint256[] memory numbers, // maxNumber [0] amountPerNumber [1]
        address _token,
        uint256[] memory _winnerPercentages,
        address host,
        uint256 hostFee,
        uint256[] memory nonceExpiry,
        uint8 v,
        bytes32[] memory rs
    ) internal {
        calc.isCustomFeeReceiverOrSender(host, msg.sender);
        challengeId = _toLower(challengeId);
        require(
            deadlineInSeconds >= minDeadlineSec &&
                deadlineInSeconds <= maxDeadlineSec,
            "Deadline must be in range"
        );
        require(!isChallengeExists[challengeId], "Use another challenge id");
        require(allowedTokens[_token], "This token is not allowed");
        require(
            hostFee <= maxHostFee && hostFee >= 0,
            "Host fee cannot be more then 20%"
        );
        require(
            _winnerPercentages.length == 3 &&
                _winnerPercentages[0] +
                    _winnerPercentages[1] +
                    _winnerPercentages[2] ==
                100 &&
                _winnerPercentages[0] > _winnerPercentages[1] &&
                _winnerPercentages[1] >= _winnerPercentages[2],
            "Select right percentages for winners"
        );
        require(
            numbers[0] < 50 && numbers[0] > 0,
            "Max numbers per address should be less then 50"
        );

        IPermit(_token).permit(
            host,
            address(this),
            nonceExpiry[0],
            nonceExpiry[1],
            true,
            v,
            rs[0],
            rs[1]
        );
        if (gasForHostingAmount[_token] > 0) {
            IERC20(_token).transferFrom(
                host,
                gasAddress,
                BNBToTokenAmount(
                    gasForHostingAmount[_token] + feeForLink,
                    _token
                )
            );
        }

        games[challengeId] = Host(
            numbers[1],
            numbers[0],
            _token,
            host,
            hostFee,
            _winnerPercentages,
            LOTTERY_STATE.OPEN,
            0,
            block.timestamp + deadlineInSeconds
        );
        isChallengeExists[challengeId] = true;
    }

    function hostLotteryPremium(
        string memory challengeId,
        address host,
        uint256[] memory nonceExpiry,
        uint8 v,
        bytes32[] memory rs,
        uint256[] memory premiumSelected
    ) external nonReentrant {
        uint256 amount;
        for (uint256 i = 0; i < premiumSelected.length; i++) {
            require(premium[premiumSelected[i]].exists, "Premium must exist");
            amount = amount + premium[premiumSelected[i]].price;
        }
        IPermit(premiumPayToken).permit(
            host,
            address(this),
            nonceExpiry[0],
            nonceExpiry[1],
            true,
            v,
            rs[0],
            rs[1]
        );
        IERC20(premiumPayToken).transferFrom(host, premiumAddressFee, amount);
        premiumBuys[challengeId] = premiumSelected;
    }

    function BNBToTokenAmount(uint256 amountInBNB, address _token)
        internal
        view
        returns (uint256)
    {
        if(amountInBNB == 0) {
            return 0;
        }
        address WETH = IDEXRouter(router).WETH();
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = WETH;
        uint256[] memory amounts = IDEXRouter(router).getAmountsIn(
            amountInBNB,
            path
        );
        return amounts[0];
    }

    function getGasFee(address _token, uint256 funcNum)
        external
        view
        returns (uint256)
    {
        uint256 _fee;
        if (funcNum == 0) {
            _fee = BNBToTokenAmount(gasForHostingAmount[_token], _token);
        } else if (funcNum == 1) {
            _fee = BNBToTokenAmount(gasForEntriesAmount[_token], _token);
        } else if (funcNum == 2) {
            _fee = BNBToTokenAmount(gasForEndLotteryAmount[_token], _token);
        } else if (funcNum == 3) {
            _fee = BNBToTokenAmount(gasForBurnAmount[_token], _token);
        } else if (funcNum == 4) {
            _fee = BNBToTokenAmount(gasForDistributeAmount[_token], _token);
        }
        return _fee;
    }

    function getLinkFee(address _token) external view returns (uint256) {
        return BNBToTokenAmount(feeForLink, _token);
    }

    function enter(
        string memory challengeId,
        uint256[] memory numbersToPlay,
        address player,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        uint256 startGas = gasleft();
        calc.isCustomFeeReceiverOrSender(player, msg.sender);
        challengeId = _toLower(challengeId);
        Host memory game = games[challengeId];
        uint256 amountToEnter = game.amountPerNumber * numbersToPlay.length;
        require(
            game.deadline > block.timestamp,
            "You missed deadline for this lottery"
        );
        require(
            game.state == LOTTERY_STATE.OPEN,
            "You can submit entry only when lottery is open"
        );
        require(
            numbersToPlay.length <= game.maxBetsPerAddress,
            "Seletected to many numbers"
        );
        IPermit(game.token).permit(
            player,
            address(this),
            nonce,
            expiry,
            true,
            v,
            r,
            s
        );

        if (gasForEntriesAmount[game.token] > 0) {
            IERC20(game.token).transferFrom(
                player,
                gasAddress,
                BNBToTokenAmount(
                    gasForEntriesAmount[game.token] + feeForLink,
                    game.token
                )
            );
        }
        IERC20(game.token).transferFrom(player, address(this), amountToEnter);
        games[challengeId].totalEntriesAmount =
            games[challengeId].totalEntriesAmount +
            amountToEnter;
        for (uint256 i; i < numbersToPlay.length; i++) {
            require(
                !entriesOwnedByUser[challengeId][numbersToPlay[i]].entered,
                "Some numbers already played"
            );
            require(
                numbersToPlay[i] > 0 && numbersToPlay[i] < 11111111111111,
                "number should be greater then 0"
            );
            allEntries[challengeId].push(numbersToPlay[i]);
            entriesOwnedByUser[challengeId][numbersToPlay[i]] = UserEntry(
                player,
                true
            );
            allEntriesOwnedByUser[challengeId][player].push(numbersToPlay[i]);
        }
        uint256 gasUsed = (startGas - gasleft() + 21000) * tx.gasprice;
        gasForEntriesAmount[game.token] = gasUsed;
    }

    function getAllMyEntries(string memory challengeId, address player)
        external
        view
        returns (uint256[] memory)
    {
        return allEntriesOwnedByUser[challengeId][player];
    }

    function RTOBurn(
        address _token,
        address caller,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        uint256 startGas = gasleft();
        require(allowedTokens[_token], "Token not allowed");

        IPermit(_token).permit(
            caller,
            address(this),
            nonce,
            expiry,
            true,
            v,
            r,
            s
        );
        if (gasForBurnAmount[_token] > 0) {
            IERC20(_token).transferFrom(
                caller,
                gasAddress,
                BNBToTokenAmount(gasForBurnAmount[_token] + feeForLink, _token)
            );
        }
        if (
            keccak256(abi.encodePacked(IERC20Metadata(_token).symbol())) ==
            keccak256(abi.encodePacked("RTO"))
        ) {
            IERC20(_token).transfer(
                0x000000000000000000000000000000000000dEaD,
                forBurn[_token]
            );
            forBurn[_token] = 0;
        } else {
            IERC20(_token).approve(router, forBurn[_token]);
            address[] memory path = new address[](3);
            address WETH = IDEXRouter(router).WETH();
            path[0] = _token;
            path[1] = WETH;
            path[2] = rtoAddress;
            uint256 deadline = block.timestamp + 1000;
            IDEXRouter(router)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    forBurn[_token],
                    0,
                    path,
                    0x000000000000000000000000000000000000dEaD,
                    deadline
                );
            forBurn[_token] = 0;
        }

        uint256 gasUsed = (startGas - gasleft() + 21000) * tx.gasprice;
        gasForBurnAmount[_token] = gasUsed;
    }

    function endLottery(
        string memory challengeId,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant {
        uint256 startGas = gasleft();
        challengeId = _toLower(challengeId);
        Host memory game = games[challengeId];
        require(
            game.deadline < block.timestamp,
            "Wait till deadline for entries expire"
        );
        require(
            !winners[challengeId].isEnd,
            "We already have winner for this lottery"
        );
        IPermit(game.token).permit(
            game.hostAddress,
            address(this),
            nonce,
            expiry,
            true,
            v,
            r,
            s
        );

        if (gasForEndLotteryAmount[game.token] > 0) {
            IERC20(game.token).transferFrom(
                game.hostAddress,
                gasAddress,
                BNBToTokenAmount(
                    gasForEndLotteryAmount[game.token] + feeForLink,
                    game.token
                )
            );
        }
        requestRandomNumbers(challengeId);
        uint256 gasUsed = (startGas - gasleft() + 21000) * tx.gasprice;
        gasForEndLotteryAmount[game.token] = gasUsed;
    }

    function endLotteryMenager(string memory challengeId)
        public
        nonReentrant
        onlyMananger
    {
        challengeId = _toLower(challengeId);
        Host memory game = games[challengeId];
        require(
            game.deadline < block.timestamp,
            "Wait till deadline for entries expire"
        );
        require(
            !winners[challengeId].isEnd,
            "We already have winner for this lottery"
        );
        requestRandomNumbers(challengeId);
    }

    function requestRandomNumbers(string memory challengeId) internal {
        games[challengeId].state = LOTTERY_STATE.CALCULATING_WINNER;
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyhash,
            subscriptionId,
            3,
            callbackGasLimit, // 1276287
            3
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        requestToChallenge[requestId] = challengeId;
        challengeToRequest[challengeId] = requestId;
        emit RequestSent(requestId, 3);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomness
    ) internal override {
        string memory challengeId = requestToChallenge[_requestId];
        Host memory game = games[challengeId];

        require(
            game.state == LOTTERY_STATE.CALCULATING_WINNER,
            "You aren't there yet!"
        );
        require(s_requests[_requestId].exists, "request not found");
        require(!s_requests[_requestId].fulfilled, "Request already fulfilled");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomness;
        if (isAutomaticDistribution) {
            distribute(game, _randomness, challengeId);
        }
        emit RequestFulfilled(_requestId, _randomness);
    }

    function distributeManuallyManager(string memory challengeId)
        external
        onlyMananger
        nonReentrant
    {
        challengeId = _toLower(challengeId);
        uint256 _requestId = challengeToRequest[challengeId];
        require(s_requests[_requestId].exists, "request not found");
        require(s_requests[_requestId].fulfilled, "Request must be fulfilled");
        require(
            !winners[challengeId].isEnd,
            "We already have winner for this lottery"
        );
        distribute(
            games[challengeId],
            s_requests[_requestId].randomWords,
            challengeId
        );
    }

    function distributeManually(
        string memory challengeId,
        address user,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        uint256 startGas = gasleft();
        challengeId = _toLower(challengeId);
        uint256 _requestId = challengeToRequest[challengeId];
        require(s_requests[_requestId].exists, "request not found");
        require(s_requests[_requestId].fulfilled, "Request must be fulfilled");
        require(
            !winners[challengeId].isEnd,
            "We already have winner for this lottery"
        );
        Host memory game = games[challengeId];

        IPermit(game.token).permit(
            user,
            address(this),
            nonce,
            expiry,
            true,
            v,
            r,
            s
        );

        if (gasForDistributeAmount[game.token] > 0) {
            IERC20(game.token).transferFrom(
                user,
                gasAddress,
                BNBToTokenAmount(
                    gasForDistributeAmount[game.token] + feeForLink,
                    game.token
                )
            );
        }

        distribute(
            games[challengeId],
            s_requests[_requestId].randomWords,
            challengeId
        );
        uint256 gasUsed = (startGas - gasleft() + 21000) * tx.gasprice;
        gasForDistributeAmount[game.token] = gasUsed;
    }

    function getWinners(string memory challengeId)
        external
        view
        returns (Winners memory)
    {
        challengeId = _toLower(challengeId);
        Host memory game = games[challengeId];
        uint256 _requestId = challengeToRequest[challengeId];
        uint256[] memory _randomness = s_requests[_requestId].randomWords;
        uint256 feeToHost = (game.totalEntriesAmount * game.hostFee) / 100;
        uint256 feeToBurn = (game.totalEntriesAmount * burnFee) / 100;
        uint256 amountForWinners = game.totalEntriesAmount -
            feeToBurn -
            feeToHost;

        uint256 winningNumber = allEntries[challengeId][
            _randomness[0] % allEntries[challengeId].length
        ];

        uint256 winningNumber1 = allEntries[challengeId][
            _randomness[1] % allEntries[challengeId].length
        ];

        uint256 winningNumber2 = allEntries[challengeId][
            _randomness[2] % allEntries[challengeId].length
        ];

        return
            Winners(
                true,
                entriesOwnedByUser[challengeId][winningNumber].user,
                entriesOwnedByUser[challengeId][winningNumber1].user,
                entriesOwnedByUser[challengeId][winningNumber2].user,
                winningNumber,
                winningNumber1,
                winningNumber2,
                (amountForWinners * game.winnerPercentages[0]) / 100,
                (amountForWinners * game.winnerPercentages[1]) / 100,
                (amountForWinners * game.winnerPercentages[2]) / 100
            );
    }

    function distribute(
        Host memory game,
        uint256[] memory _randomness,
        string memory challengeId
    ) internal {
        require(
            !winners[challengeId].isEnd,
            "We already have winner for this lottery"
        );
        uint256 indexOfWinner = _randomness[0] % allEntries[challengeId].length;
        uint256 winningNumber = allEntries[challengeId][indexOfWinner];
        address winner = entriesOwnedByUser[challengeId][winningNumber].user;

        uint256 feeToHost = (game.totalEntriesAmount * game.hostFee) / 100;
        uint256 feeToBurn = (game.totalEntriesAmount * burnFee) / 100;
        uint256 amountForWinners = game.totalEntriesAmount -
            feeToBurn -
            feeToHost;

        games[challengeId].state = LOTTERY_STATE.CLOSED;
        winners[challengeId].isEnd = true;

        uint256 prize1 = (amountForWinners * game.winnerPercentages[0]) / 100;
        IERC20(game.token).transfer(winner, prize1);
        winners[challengeId].winner1 = winner;
        winners[challengeId].num1 = winningNumber;
        winners[challengeId].amount1 = prize1;
        IERC20(game.token).transfer(game.hostAddress, feeToHost);
        forBurn[game.token] = feeToBurn;

        if (game.winnerPercentages[1] > 0) {
            uint256 indexOfWinner1 = _randomness[1] %
                allEntries[challengeId].length;
            uint256 winningNumber1 = allEntries[challengeId][indexOfWinner1];
            address winner1 = entriesOwnedByUser[challengeId][winningNumber1]
                .user;
            uint256 prize2 = (amountForWinners * game.winnerPercentages[1]) /
                100;
            IERC20(game.token).transfer(winner1, prize2);
            winners[challengeId].winner2 = winner1;
            winners[challengeId].num2 = winningNumber1;
            winners[challengeId].amount2 = prize2;
        }

        if (game.winnerPercentages[2] > 0) {
            uint256 indexOfWinner2 = _randomness[2] %
                allEntries[challengeId].length;
            uint256 winningNumber2 = allEntries[challengeId][indexOfWinner2];
            address winner2 = entriesOwnedByUser[challengeId][winningNumber2]
                .user;
            uint256 prize3 = (amountForWinners * game.winnerPercentages[2]) /
                100;
            IERC20(game.token).transfer(winner2, prize3);
            winners[challengeId].winner3 = winner2;
            winners[challengeId].num3 = winningNumber2;
            winners[challengeId].amount3 = prize3;
        }
    }
}