// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDrFrankenstein {
    struct UserInfoDrFrankenstien {
        uint256 amount;                 // How many LP tokens the user has provided.
        uint256 rewardDebt;             // Reward debt. See explanation below.
        uint256 tokenWithdrawalDate;    // Date user must wait until before early withdrawal fees are lifted.
        // User grave info
        uint256 rugDeposited;               // How many rugged tokens the user deposited.
        bool paidUnlockFee;                 // true if user paid the unlock fee.
        uint256  nftRevivalDate;            // Date user must wait until before harvesting their nft.
    }

    struct PoolInfoDrFrankenstein {
        address lpToken;                        // Address of LP token contract.
        uint256 allocPoint;                     // How many allocation points assigned to this pool. ZMBEs to distribute per block.
        uint256 lastRewardBlock;                // Last block number that ZMBEs distribution occurs.
        uint256 accZombiePerShare;              // Accumulated ZMBEs per share, times 1e12. See below.
        uint256 minimumStakingTime;             // Duration a user must stake before early withdrawal fee is lifted.
        // Grave variables
        bool isGrave;                           // True if pool is a grave (provides nft rewards).
        bool requiresRug;                       // True if grave require a rugged token deposit before unlocking.
        address ruggedToken;                    // Address of the grave's rugged token (casted to IGraveStakingToken over IBEP20 to save space).
        address nft;                            // Address of reward nft.
        uint256 unlockFee;                      // Unlock fee (In BUSD, Chainlink Oracle is used to convert fee to current BNB value).
        uint256 minimumStake;                   // Minimum amount of lpTokens required to stake.
        uint256 nftRevivalTime;                 // Duration a user must stake before they can redeem their nft reward.
        uint256 unlocks;                        // Number of times a grave is unlocked
    }

    function poolLength() external view returns (uint256);
    function userInfo(uint pid, address userAddress) external view returns (UserInfoDrFrankenstien memory);
    function poolInfo(uint pid) external view returns (PoolInfoDrFrankenstein memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (uint);
    function unlockFeeInBnb(uint) external view returns (uint);
    function usdToBnb(uint) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IRugZombieNft {
    function totalSupply() external view returns (uint256);
    function reviveRug(address _to) external returns(uint);
    function transferOwnership(address newOwner) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function owner() external view returns (address);
    function approve(address to, uint256 tokenId) external;
    function balanceOf(address _owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
pragma solidity ^0.8.4;

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

import "../includes/access/Ownable.sol";
import "../includes/interfaces/IRugZombieNft.sol";
import "../includes/interfaces/IUniswapV2Router02.sol";
import "../includes/interfaces/IPriceConsumerV3.sol";
import "../includes/interfaces/IDrFrankenstein.sol";
import "../includes/token/BEP20/IBEP20.sol";

import "../includes/vrf/VRFConsumerBaseV2.sol";
import "../includes/vrf/VRFCoordinatorV2Interface.sol";import "../includes/utils/ReentrancyGuard.sol";

contract TombOverlayV2 is Ownable, VRFConsumerBaseV2, ReentrancyGuard {
    uint32 public vrfGasLimit = 50000;  // Gas limit for VRF callbacks
    uint16 public vrfConfirms = 3;      // Number of confirmations for VRF randomness returns
    uint32 public vrfWords    = 1;      // Number of random words to get back from VRF

    uint public bracketBStart = 500;      // The percentage of the pool required to be in the second bracket
    uint public bracketCStart = 1000;      // The percentage of the pool required to be in the third bracket

    struct UserInfo {
        uint256 lastNftMintDate;    // The next date the NFT is available to mint
        bool    isMinting;          // Flag for if the user is currently minting
        uint    randomNumber;       // The random number that is returned from Chainlink
    }

    struct PoolInfo {
        uint            poolId;             // The DrFrankenstein pool ID for this overlay pool
        uint256         mintingTime;        // The time it takes to mint the reward NFT
        uint256         mintTimeFromStake;  // The time it takes to mint the reward NFT based on the staking timer from DrF
        IRugZombieNft   commonReward;       // The common reward NFT
        IRugZombieNft   uncommonReward;     // The uncommon reward NFT
        IRugZombieNft   rareReward;         // The rare reward NFT
        IRugZombieNft   legendaryReward;    // The legendary reward NFT
        BracketOdds[]   odds;               // The odds brackets for the pool
    }

    struct BracketOdds {
        uint commonTop;
        uint uncommonTop;
        uint rareTop;
    }

    struct RandomRequest {
        uint poolId;
        address user;
    }

    PoolInfo[]          public  poolInfo;               // The array of pools
    IDrFrankenstein     public  drFrankenstein;         // Dr Frankenstein - the man, the myth, the legend
    IPriceConsumerV3    public  priceConsumer;          // Price consumer for Chainlink Oracle
    VRFCoordinatorV2Interface   public vrfCoordinator;  // Coordinator for requesting randomness
    address             payable treasury;               // Wallet address for the treasury
    bytes32             public  keyHash;                // The Chainlink VRF keyhash
    uint64              public  vrfSubId;               // Chainlink VRF subscription ID
    uint256             public  mintingFee;             // The fee charged in BNB to cover Chainlink costs
    IRugZombieNft       public  topPrize;               // The top prize NFT

    // Mapping of request IDs to requests
    mapping (uint => RandomRequest) public randomRequests;

    // Mapping of user info to address mapped to each pool
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    event MintNft(address indexed to, uint date, address nft, uint indexed id, uint random);
    event FulfillRandomness(uint indexed poolId, address indexed userId, uint randomNumber);

    // Constructor for constructing things
    constructor(
        address _drFrankenstein,
        address payable _treasury,
        address _priceConsumer,
        uint256 _mintingFee,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _vrfSubId,
        address _topPrize
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        drFrankenstein = IDrFrankenstein(_drFrankenstein);
        treasury = _treasury;
        priceConsumer = IPriceConsumerV3(_priceConsumer);
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        mintingFee = _mintingFee;
        keyHash = _keyHash;
        vrfSubId = _vrfSubId;
        topPrize = IRugZombieNft(_topPrize);
    }

    // Modifier to ensure a user can start minting
    modifier canStartMinting(uint _pid) {
        UserInfo memory user = userInfo[_pid][msg.sender];
        PoolInfo memory pool = poolInfo[_pid];
        IDrFrankenstein.UserInfoDrFrankenstien memory tombUser = drFrankenstein.userInfo(pool.poolId, msg.sender);
        require(_pid <= poolInfo.length - 1, 'Overlay: Pool does not exist');
        require(tombUser.amount > 0, 'Overlay: You are not staked in the pool');
        require(!user.isMinting, 'Overlay: You already have a pending minting request');
        require(block.timestamp >= (user.lastNftMintDate + pool.mintingTime) &&
            block.timestamp >= (tombUser.tokenWithdrawalDate + pool.mintTimeFromStake),
            'Overlay: Minting time has not elapsed');
        _;
    }

    // Modifier to ensure a user's pending minting request is ready
    modifier canFinishMinting(uint _pid) {
        UserInfo memory user = userInfo[_pid][msg.sender];
        require(user.isMinting && user.randomNumber > 0, 'Overlay: Minting is not ready');
        _;
    }

    // Function to add a pool
    function addPool(
        uint _poolId,
        uint256 _mintingTime,
        uint256 _mintTimeFromStake,
        address _commonNft,
        address _uncommonNft,
        address _rareNft,
        address _legendaryNft
    ) public onlyOwner() {
        poolInfo.push();
        uint id = poolInfo.length - 1;

        poolInfo[id].poolId = _poolId;
        poolInfo[id].mintingTime = _mintingTime;
        poolInfo[id].mintTimeFromStake = _mintTimeFromStake;
        poolInfo[id].commonReward = IRugZombieNft(_commonNft);
        poolInfo[id].uncommonReward = IRugZombieNft(_uncommonNft);
        poolInfo[id].rareReward = IRugZombieNft(_rareNft);
        poolInfo[id].legendaryReward = IRugZombieNft(_legendaryNft);

        // Lowest bracket: 70% common, 15% uncommon, 10% rare, 5% legendary, 0% mythic
        poolInfo[id].odds.push(BracketOdds({
        commonTop: 7000,
        uncommonTop: 8500,
        rareTop: 9500
        }));

        // Middle bracket: 50% common, 25% uncommon, 15% rare, 10% legendary, 0% mythic
        poolInfo[id].odds.push(BracketOdds({
        commonTop: 5000,
        uncommonTop: 7500,
        rareTop: 9000
        }));

        // Top bracket: 20% common, 30% uncommon, 30% rare, 20% legendary, 0% mythic
        poolInfo[id].odds.push(BracketOdds({
        commonTop: 2000,
        uncommonTop: 5000,
        rareTop: 8000
        }));
    }

    // Uses ChainLink Oracle to convert from USD to BNB
    function mintingFeeInBnb() public view returns(uint) {
        return priceConsumer.usdToBnb(mintingFee);
    }

    // Function to set the common reward NFT for a pool
    function setCommonRewardNft(uint _pid, address _nft) public onlyOwner() {
        poolInfo[_pid].commonReward = IRugZombieNft(_nft);
    }

    // Function to set the uncommon reward NFT for a pool
    function setUncommonRewardNft(uint _pid, address _nft) public onlyOwner() {
        poolInfo[_pid].uncommonReward = IRugZombieNft(_nft);
    }

    // Function to set the rare reward NFT for a pool
    function setRareRewardNft(uint _pid, address _nft) public onlyOwner() {
        poolInfo[_pid].rareReward = IRugZombieNft(_nft);
    }

    // Function to set the legendary reward NFT for a pool
    function setLegendaryRewardNft(uint _pid, address _nft) public onlyOwner() {
        poolInfo[_pid].legendaryReward = IRugZombieNft(_nft);
    }

    // Function to set the minting time for a pool
    function setMintingTime(uint _pid, uint256 _mintingTime) public onlyOwner() {
        poolInfo[_pid].mintingTime = _mintingTime;
    }

    // Function to set the mint time from staking timer for a pool
    function setMintTimeFromStake(uint _pid, uint256 _mintTimeFromStake) public onlyOwner() {
        poolInfo[_pid].mintTimeFromStake = _mintTimeFromStake;
    }

    // Function to set the price consumer
    function setPriceConsumer(address _priceConsumer) public onlyOwner() {
        priceConsumer = IPriceConsumerV3(_priceConsumer);
    }

    // Function to set the treasury address
    function setTreasury(address _treasury) public onlyOwner() {
        treasury = payable(_treasury);
    }

    // Function to set the start of the second bracket
    function setBracketBStart(uint _value) public onlyOwner() {
        bracketBStart = _value;
    }

    // Function to set the start of the third bracket
    function setBracketCStart(uint _value) public onlyOwner() {
        bracketCStart = _value;
    }

    // Function to set the minting fee
    function setmintingFee(uint256 _fee) public onlyOwner() {
        mintingFee = _fee;
    }

    // Function to change the top prize NFT
    function setTopPrize(address _nft) public onlyOwner() {
        topPrize = IRugZombieNft(_nft);
    }

    // Function to set the odds for a pool
    function setPoolOdds(
        uint _pid,
        uint _bracket,
        uint _commonTop,
        uint _uncommonTop,
        uint _rareTop
    ) public onlyOwner() {
        BracketOdds memory odds = BracketOdds({
        commonTop: _commonTop,
        uncommonTop: _uncommonTop,
        rareTop: _rareTop
        });
        poolInfo[_pid].odds[_bracket] = odds;
    }

    // Function to get the number of pools
    function poolCount() public view returns(uint) {
        return poolInfo.length;
    }

    // Function to get a user's NFT mint date
    function nftMintTime(uint _pid, address _userAddress) public view returns (uint256) {
        UserInfo memory user = userInfo[_pid][_userAddress];
        PoolInfo memory pool = poolInfo[_pid];
        IDrFrankenstein.UserInfoDrFrankenstien memory tombUser = drFrankenstein.userInfo(pool.poolId, _userAddress);

        if (tombUser.amount == 0) {
            return 2**256 - 1;
        } else if (block.timestamp >= (user.lastNftMintDate + pool.mintingTime) && block.timestamp >= (tombUser.tokenWithdrawalDate + pool.mintTimeFromStake)) {
            return 0;
        } else if (block.timestamp <= (tombUser.tokenWithdrawalDate + pool.mintTimeFromStake)) {
            return (tombUser.tokenWithdrawalDate + pool.mintTimeFromStake) - block.timestamp;
        } else {
            return (user.lastNftMintDate + pool.mintingTime) - block.timestamp;
        }
    }

    // Function to start minting a NFT
    function startMinting(uint _pid) public payable nonReentrant canStartMinting(_pid) returns (uint) {
        require(msg.value >= mintingFeeInBnb(), 'Minting: Insufficient BNB for minting fee');
        UserInfo storage user = userInfo[_pid][msg.sender];

        safeTransfer(treasury, msg.value);

        user.isMinting = true;
        user.randomNumber = 0;

        RandomRequest memory request = RandomRequest(_pid, msg.sender);
        uint id = vrfCoordinator.requestRandomWords(keyHash, vrfSubId, vrfConfirms, vrfGasLimit, vrfWords);
        randomRequests[id] = request;
        return id;
    }

    // Function to finish minting a NFT
    function finishMinting(uint _pid) public canFinishMinting(_pid) returns (uint, uint) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        IDrFrankenstein.PoolInfoDrFrankenstein memory tombPool = drFrankenstein.poolInfo(pool.poolId);
        IDrFrankenstein.UserInfoDrFrankenstien memory tombUser = drFrankenstein.userInfo(pool.poolId, msg.sender);

        if (block.timestamp < (tombUser.tokenWithdrawalDate + pool.mintTimeFromStake)) {
            user.isMinting = false;
            require(false, 'Overlay: Stake change detected - minting cancelled');
        }

        IBEP20 lptoken = IBEP20(tombPool.lpToken);

        uint poolTotal = lptoken.balanceOf(address(drFrankenstein));
        uint percentOfPool = calcBasisPoints(poolTotal, tombUser.amount);
        BracketOdds memory userOdds;

        if (percentOfPool < bracketBStart) {
            userOdds = pool.odds[0];
        } else if (percentOfPool < bracketCStart) {
            userOdds = pool.odds[1];
        } else {
            userOdds = pool.odds[2];
        }

        uint rarity;
        IRugZombieNft nft;
        if (user.randomNumber <= userOdds.commonTop) {
            nft = pool.commonReward;
            rarity = 0;
        } else if (user.randomNumber <= userOdds.uncommonTop) {
            nft = pool.uncommonReward;
            rarity = 1;
        } else if (user.randomNumber <= userOdds.rareTop) {
            nft = pool.rareReward;
            rarity = 2;
        } else if (user.randomNumber == 10000) {
            nft = topPrize;
            rarity = 3;
        } else {
            nft = pool.legendaryReward;
            rarity = 3;
        }

        uint tokenId = nft.reviveRug(msg.sender);
        user.lastNftMintDate = block.timestamp;
        user.isMinting = false;
        user.randomNumber = 0;
        emit MintNft(msg.sender, block.timestamp, address(nft), tokenId, user.randomNumber);
        return (rarity, tokenId);
    }

    // Function to handle Chainlink VRF callback
    function fulfillRandomWords(uint _requestId, uint[] memory _randomNumbers) internal override {
        RandomRequest memory request = randomRequests[_requestId];
        uint randomNumber = (_randomNumbers[0] % 10000) + 1;
        userInfo[request.poolId][request.user].randomNumber = randomNumber;
        emit FulfillRandomness(request.poolId, request.user, randomNumber);
    }

    // Get basis points (percentage) of _portion relative to _amount
    function calcBasisPoints(uint _amount, uint  _portion) public pure returns(uint) {
        if(_portion == 0 || _amount == 0) {
            return 0;
        } else {
            uint _basisPoints = (_portion * 10000) / _amount;
            return _basisPoints;
        }
    }

    // Must be called with in function with ReentrancyGuard
    function safeTransfer(address _recipient, uint _amount) private {
        (bool _success, ) = _recipient.call{value: _amount}("");
        require(_success, "Transfer failed.");
    }
}