// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IExchangeRateHelper.sol";
import "./interfaces/IERC20Extended.sol";

contract DCash is IERC721Receiver, Ownable {
  using SafeMath for uint256;

  /**
   * @dev
   * @param pairId - The unique Id
   * @param token1 - The first token address of the pair
   * @param token2 - The second token address of the pair
   * @param tokenPercent - 0 through 10000. If it is set to 5000, then 50% of usdCost to lock to the pair will be paid in token1,
   *  and 50% in token2. if it is set to 80% then 80% is paid in token1, and 20% is paid in token2
   * @param nft - The nft address of the pair
   * @param nftPercent - Admin determines what percent discount of token1 or token2 cost should apply. defaults to 10000 (100%)
   * @param earlyUnlock - If true, `earlyUnlock` function is allowed for the pair
   * @param earlyUnlockFeePercent - Defaults to 1000 (10%). This percent of token1 and token2 will be sent to feeWallet upon `earlyUnlock` call for the pair
   * @param lockPeriod - Admin can input amount of seconds users must wait before they can unlock from the pair after locking
   * @param feeAddress - The address the `lockFee` and `earlyUnlockFee` goes to
   * @param deactivated - The flag to show if the pair is activated/deactivated
   */
  struct Pair {
    uint256 pairId;
    address token1;
    address token2;
    uint256 tokenPercent;
    address nft;
    uint256 nftPercent;
    bool earlyUnlock;
    uint256 earlyUnlockFeePercent;
    uint256 lockPeriod;
    address feeAddress;
    bool deactivated;
  }

  /**
   * @dev Stores the locked information of the user
   * @param lockId - The unique Id. We use the user address because we allow 1 lock per address
   * @param account - The owner address of the lock
   * @param tierId - The tierId of the lock which determines the cost
   * @param pairId - The pairId you supply for the lock
   * @param nft - The nft address you deposited which is same to the nft address of the pair.
   *  If address(0) passes, it means that user doesn't want discount by nft
   * @param nftId - The token Id
   * @param nftDiscount - determines whether to use nft or not. In case of use, it will specify which token nftPercent discount applies to
   *  0 = no nft in use,
   *  1 = nft in use, nftPercent discount applies on token1 cost
   *	2 = nft in use, nftPercent discount applies on token2 cost
   * @param token1Amount - The token1 amount user has in the system
   * @param token2Amount - The token2 amount user has in the system
   * @param feeAmountInToken1 - The paid lockFee in token1
   * @param feeAmountInToken2 - The paid lockFee in token2
   * @param startTime - The timestamp that the lock starts at
   * @param endTime - The timestamp that the lock ends in
   * @param locked - true/false
   */
  struct Lock {
    address lockId;
    uint8 tierId;
    uint256 pairId;
    address nft;
    uint256 nftId;
    uint8 nftDiscount;
    uint256 token1Amount;
    uint256 token2Amount;
    uint256 feeAmountInToken1;
    uint256 feeAmountInToken2;
    uint256 startTime;
    uint256 endTime;
    bool locked;
  }

  /**
   * @dev Stores the tier information which includes `cost` and `feePercent`
   * @param id - The tier id
   * @param cost - Tier cost in USD
   * @param feePercent - The fee percent user needs to pay to lock. 10000 means 100%
   */
  struct Tier {
    uint8 id;
    uint256 cost;
    uint256 feePercent;
  }

  /**
   * Stores the number of pair added by the owner;
   */
  uint256 public pairCount;

  /**
   * @dev The helper used to calculate the exchangeRate of the token
   */
  IExchangeRateHelper public exchangeRateHelper;

  /**
   * @dev Indicates whether the system is paused or unpaused
   */
  bool public paused;

  /**
   * @dev Maximum values
   */
  uint256 public MAX_TOKEN_PERCENT = 10000;
  uint256 public MAX_NFT_PERCENT = 10000;
  uint256 public MAX_UNLOCK_FEE_PERCENT = 10000;
  uint256 public MAX_TIER_COUNT = 8;
  uint256 public MAX_FEE_PERCENT = 10000;

  /**
   * @dev Mapping of tierId to tierCost
   */
  mapping(uint8 => Tier) public tiers;

  /**
   * @dev Mapping of pairId to Pair
   */
  mapping(uint256 => Pair) public pairs;

  /**
   * @dev Mapping of lockId to Lock
   */
  mapping(address => Lock) private locks;

  /**
   * @dev Emitted when the owner updates the exchangeRateHelper address
   */
  event ExchangeRateHelperUpdated(
    address indexed oldHelper,
    address indexed newHelper
  );

  /**
   * @dev Emitted when a tier is updated
   * @param tierId - The tier id you're going to update for
   * @param cost - The cost you're going to put
   * @param feePercent - The fee percent you're going to put
   */
  event TierUpdated(uint8 indexed tierId, uint256 cost, uint256 feePercent);

  /**
   * @dev Emitted when a new pair is added
   */
  event PairAdded(
    uint256 indexed pairId,
    address token1,
    address token2,
    uint256 tokenPercent,
    address nft,
    uint256 nftPercent,
    bool earlyUnlock,
    uint256 earlyUnlockFeePercent,
    uint256 lockPeriod,
    address feeAddress
  );

  /**
   * @dev Emitted when the pair is updated
   */
  event PairUpdated(
    uint256 indexed pairId,
    address token1,
    address token2,
    uint256 tokenPercent,
    address nft,
    uint256 nftPercent,
    bool earlyUnlock,
    uint256 earlyUnlockFeePercent,
    uint256 lockPeriod,
    address feeAddress
  );

  /**
   * @dev Emmitted when the pair is deactivated
   */
  event PairDeactivated(uint256 indexed pairId);

  /**
   * @dev Emitted when user locks up
   * @param lockId - The lock Id which is generated automatically whenever there is a new lock
   * @param tierId - The tierId you would like to receive
   * @param pairId - The pair you would like to select for the tier
   * @param nft - The address you pass, or address(0) if none
   * @param nftId - The tokenId of the nft. If `nft` is address(0), ignores this value
   * @param nftDiscount - determines whether to use nft or not. In case of use, it will specify which token nftPercent discount applies to
   * @param token1Amount - The amount in token1 deposited to the system
   * @param feeAmountInToken1 - The fee amount in token1
   * @param token1Rate - The exchange rate of token1
   * @param token2Amount - The amount in token2 deposited to the system
   * @param feeAmountInToken2 = The fee amount in token2
   * @param token2Rate - The exchange rate of token2
   */
  event Locked(
    address indexed lockId,
    uint8 tierId,
    uint256 pairId,
    address nft,
    uint256 nftId,
    uint8 nftDiscount,
    uint256 token1Amount,
    uint256 feeAmountInToken1,
    uint256 token1Rate,
    uint256 token2Amount,
    uint256 feeAmountInToken2,
    uint256 token2Rate
  );

  /**
   * @dev Emitted when user unlocks
   * @param lockId - The lock Id you would like to unlock
   * @param earlyUnlock - Indicates if it is the normal/early unlock.
   */
  event Unlocked(address indexed lockId, bool earlyUnlock);

  /**
   * @dev Emitted when use upgrades to
   * @param lockId - The lock Id you would like to upgrade for
   * @param tierId - The tier Id you would like to upgrade to
   * @param token1Amount - The token1 amount you pay to upgrade
   * @param token2Amount - The token2 amount you pay to upgrade
   * @param paidFeeInToken1 - The token1 amount you pay for lockingFee
   * @param paidFeeInToken2 - The  token2 amount you pay for lockingFee
   * @param token1Rate - The exchange rate of token1
   * @param token2Rate - The exchange rate of token2
   */
  event Upgraded(
    address indexed lockId,
    uint8 tierId,
    uint256 token1Amount,
    uint256 token2Amount,
    uint256 paidFeeInToken1,
    uint256 paidFeeInToken2,
    uint256 token1Rate,
    uint256 token2Rate
  );

  modifier whenNotPaused() {
    require(!paused, "Paused");
    _;
  }

  constructor(address _exchangeRateHelper) {
    exchangeRateHelper = IExchangeRateHelper(_exchangeRateHelper);
    _initTierCosts();
  }

  ///============= Owner Functions =============///

  /**
   * @dev Adds a new pair
   */
  function addPair(
    address token1,
    address token2,
    uint256 tokenPercent,
    address nft,
    uint256 nftPercent,
    bool earlyUnlock,
    uint256 earlyUnlockFeePercent,
    uint256 lockPeriod,
    address feeAddress
  ) external onlyOwner {
    require(tokenPercent < MAX_TOKEN_PERCENT, "Invalid token percent");
    require(nftPercent <= MAX_NFT_PERCENT, "Invalid nft percent");
    require(
      earlyUnlockFeePercent < MAX_UNLOCK_FEE_PERCENT,
      "Invalid earlyUnlock percent"
    );
    pairs[pairCount] = Pair({
      pairId: pairCount,
      token1: token1,
      token2: token2,
      tokenPercent: tokenPercent,
      nft: nft,
      nftPercent: nftPercent,
      earlyUnlock: earlyUnlock,
      earlyUnlockFeePercent: earlyUnlockFeePercent,
      lockPeriod: lockPeriod,
      feeAddress: feeAddress,
      deactivated: false
    });

    emit PairAdded(
      pairCount,
      token1,
      token2,
      tokenPercent,
      nft,
      nftPercent,
      earlyUnlock,
      earlyUnlockFeePercent,
      lockPeriod,
      feeAddress
    );
    pairCount++;
  }

  /**
   * @dev Updates the pair
   */
  function setPair(
    uint256 pairId,
    address token1,
    address token2,
    uint256 tokenPercent,
    address nft,
    uint256 nftPercent,
    bool earlyUnlock,
    uint256 earlyUnlockFeePercent,
    uint256 lockPeriod,
    address feeAddress
  ) external onlyOwner {
    require(pairId < pairCount, "Invalid Pair");
    require(tokenPercent < MAX_TOKEN_PERCENT, "Invalid token percent");
    require(nftPercent <= MAX_NFT_PERCENT, "Invalid nft percent");
    require(
      earlyUnlockFeePercent < MAX_UNLOCK_FEE_PERCENT,
      "Invalid earlyUnlock percent"
    );

    Pair storage pair = pairs[pairId];
    pair.token1 = token1;
    pair.token2 = token2;
    pair.tokenPercent = tokenPercent;
    pair.nft = nft;
    pair.nftPercent = nftPercent;
    pair.earlyUnlock = earlyUnlock;
    pair.earlyUnlockFeePercent = earlyUnlockFeePercent;
    pair.lockPeriod = lockPeriod;
    pair.feeAddress = feeAddress;

    emit PairUpdated(
      pairId,
      token1,
      token2,
      tokenPercent,
      nft,
      nftPercent,
      earlyUnlock,
      earlyUnlockFeePercent,
      lockPeriod,
      feeAddress
    );
  }

  /**
   * @dev Pauses/UnPauses the system
   * @param _paused - The status you're going to make the system
   */
  function setPaused(bool _paused) external onlyOwner {
    require(paused != _paused, "alreaady_set");
    paused = _paused;
  }

  /**
   * @dev Deactivates the pair. This function is called by the owner
   *   which basically disables new locks. If `deactivated` is true, locked user can call `unlock`
   *   even if they have not elapsed their lock time.
   * @param pairId - The pair id you're going to deactivate
   */
  function deactivatePair(uint256 pairId) external onlyOwner {
    require(pairId < pairCount, "Invalid pairId");
    Pair storage pair = pairs[pairId];
    pair.deactivated = true;

    emit PairDeactivated(pairId);
  }

  /**
   * @dev Deactivates the user's lock. It basically resets user's lock values to 0 and sends the assets back to the user
   * @param account - The address you're going to deactivate for
   */
  function deactivateUser(address account) external onlyOwner {
    _unlock(account, false);
  }

  /**
   * @dev Admin can unlock on behalf of the user. It sends all user's locked assets back to them and resets lock values to 0.
   *    This is for in the case a user forgets about a expired lock and never claims. so user's lock period must be passed.
   */
  function adminEndUserLockUp(address account) external onlyOwner {
    _unlock(account, true);
  }

  /**
   * @dev Updates the address of exchangeRateHelper
   * @param _exchangeRateHelper - The address you're going to update with
   */
  function setExchangeRateHelper(address _exchangeRateHelper)
    external
    onlyOwner
    whenNotPaused
  {
    require(address(exchangeRateHelper) != _exchangeRateHelper, "already_set");
    emit ExchangeRateHelperUpdated(
      address(exchangeRateHelper),
      _exchangeRateHelper
    );
    exchangeRateHelper = IExchangeRateHelper(_exchangeRateHelper);
  }

  /**
   * @dev Sets the cost and fee percent for a tier
   * @param tierId - The unique id to update
   * @param cost - The new cost for a tier
   * @param feePercent - The new fee percent you're going to set
   */
  function setTierCost(
    uint8 tierId,
    uint256 cost,
    uint256 feePercent
  ) external onlyOwner {
    require(tierId <= MAX_TIER_COUNT, "Invalid tierId");
    require(feePercent < MAX_FEE_PERCENT, "FeePercent reached to maximum");
    Tier storage tier = tiers[tierId];
    tier.cost = cost;
    tier.feePercent = feePercent;

    emit TierUpdated(tierId, cost, feePercent);
  }

  ///============= View Functions =============///

  /**
   * @dev Gets the lockup information for a user
   * @param account - The address you're going to get the lockup information for
   * {pairId, tierId, token1Amount, token2Amount, nft[true/false], nft address, nftId, allowEarly[true/false], endTime, locked[true/false]}
   */
  function getUserLock(address account)
    external
    view
    returns (
      uint256 pairId,
      uint8 tierId,
      uint256 token1Amount,
      uint256 token2Amount,
      bool nft,
      address nftAddress,
      uint256 nftId,
      bool earlyUnlock,
      uint256 lockEndtime
    )
  {
    Lock memory userLock = locks[account];

    tierId = (userLock.endTime < block.timestamp ||
      pairs[userLock.pairId].deactivated)
      ? 0
      : userLock.tierId;
    pairId = userLock.pairId;
    token1Amount = userLock.token1Amount;
    token2Amount = userLock.token2Amount;
    nft = userLock.nft != address(0) ? true : false;
    nftAddress = userLock.nft;
    nftId = userLock.nftId;
    earlyUnlock = earlyUnlock;
    lockEndtime = userLock.endTime;
  }

  ///============= Public Functions =============///

  /**
   * @dev User deposits tokens and receives the corresponding tier
   * @param tierId - The tierId you would like to receive
   * @param pairId - The pair you would like to select for the tier
   * @param nft - The address you pass, or address(0) if none
   * @param nftId - The tokenId of the nft. If `nft` is address(0), ignores this value
   * @param nftDiscount - determines whether to use nft or not. In case of use, it will specify which token nftPercent discount applies to
   *      0 = no nft in use,
   *      1 = nft in use, nftPercent discount applies on token1 cost
   *	    2 = nft in use, nftPercent discount applies on token2 cost
   */
  function lockUp(
    uint8 tierId,
    uint256 pairId,
    address nft,
    uint256 nftId,
    uint8 nftDiscount
  ) public whenNotPaused {
    require(tierId <= MAX_TIER_COUNT && tierId > 0, "Invalid tierId");
    require(pairId < pairCount, "Invalid pairId");

    require(!locks[msg.sender].locked, "Already locked");
    Pair memory pair = pairs[pairId];
    require(!pair.deactivated, "Pair deactivated");
    Tier memory tier = tiers[tierId];
    uint256 tierCostForToken1 = tier.cost.mul(pair.tokenPercent).div(10000);
    uint256 tierCostForToken2 = tier.cost.sub(tierCostForToken1);

    if (nft != address(0)) {
      require(pair.nft == nft, "NFT address mismatch");
      require(IERC721(nft).ownerOf(nftId) == msg.sender, "!owner");
      IERC721(nft).safeTransferFrom(msg.sender, address(this), nftId);

      if (nftDiscount == 1) {
        // used on token1 cost
        tierCostForToken1 = tierCostForToken1.sub(
          tierCostForToken1.mul(pair.nftPercent).div(10000)
        );
      } else if (nftDiscount == 2) {
        // used on token2 cost
        tierCostForToken2 = tierCostForToken2.sub(
          tierCostForToken2.mul(pair.nftPercent).div(10000)
        );
      }
    }

    _createLockUp(
      tier,
      pair,
      tierCostForToken1,
      tierCostForToken2,
      nft,
      nftId,
      nft != address(0) ? nftDiscount : 0
    );
  }

  /**
   * @dev Upgrades the lock to a high-level tier
   * @param tierId - The tierId you would like to upgrade to
   */
  function upgradeLockUp(uint8 tierId) public whenNotPaused {
    Lock storage userLock = locks[msg.sender];

    require(userLock.locked, "need to lock first");
    require(tierId > userLock.tierId, "should upgrade to the higher levels");

    uint256 diffCost = tiers[tierId].cost.sub(tiers[userLock.tierId].cost);
    uint256 tierCostForToken1 = tiers[tierId]
      .cost
      .mul(pairs[userLock.pairId].tokenPercent)
      .div(10000);
    uint256 tierCostForToken2 = tiers[tierId].cost.sub(tierCostForToken1);
    uint256 diffCostInToken1 = diffCost
      .mul(pairs[userLock.pairId].tokenPercent)
      .div(10000);
    uint256 diffCostInToken2 = diffCost.sub(tierCostForToken1);

    if (userLock.nftDiscount == 1) {
      // used on token1 cost
      diffCostInToken1 = diffCostInToken1.sub(
        diffCostInToken1.mul(pairs[userLock.pairId].nftPercent).div(10000)
      );
    } else if (userLock.nftDiscount == 2) {
      // used on token2 cost
      diffCostInToken2 = diffCostInToken2.sub(
        diffCostInToken2.mul(pairs[userLock.pairId].nftPercent).div(10000)
      );
    }

    _updateLockUp(
      userLock,
      tiers[tierId],
      pairs[userLock.pairId],
      diffCostInToken1 == 0 ? 0 : tierCostForToken1,
      diffCostInToken2 == 0 ? 0 : tierCostForToken2,
      diffCostInToken1,
      diffCostInToken2
    );
  }

  /**
   * @dev Withdraws the tokens and resets its tier.
   */
  function unlock() public {
    _unlock(msg.sender, true);
  }

  /**
   * @dev Withdraws the tokens and resets its tier ealier than unlock time.
   */
  function forceUnlock() public {
    _forceUnlock(msg.sender);
  }

  ///============= Internal Functions =============///

  /**
   * @dev Initializes tiers mapping
   */
  function _initTierCosts() internal {
    tiers[0] = Tier({ id: 0, cost: 0, feePercent: 0 });
    tiers[1] = Tier({ id: 1, cost: 100e18, feePercent: 500 });
    tiers[2] = Tier({ id: 2, cost: 280e18, feePercent: 400 });
    tiers[3] = Tier({ id: 3, cost: 600e18, feePercent: 350 });
    tiers[4] = Tier({ id: 4, cost: 1400e18, feePercent: 300 });
    tiers[5] = Tier({ id: 5, cost: 2600e18, feePercent: 250 });
    tiers[6] = Tier({ id: 6, cost: 5400e18, feePercent: 200 });
    tiers[7] = Tier({ id: 7, cost: 12000e18, feePercent: 175 });
    tiers[8] = Tier({ id: 8, cost: 22000e18, feePercent: 150 });
  }

  /**
   * @dev Creates a lock with `tierId` and `pairId`
   */
  function _createLockUp(
    Tier memory tier,
    Pair memory pair,
    uint256 token1Cost,
    uint256 token2Cost,
    address nft,
    uint256 nftId,
    uint8 nftDiscount
  ) internal {
    (uint256 token1Rate, uint256 token1Amount) = _getTokenAmount(
      pair.token1,
      token1Cost
    );
    (uint256 token2Rate, uint256 token2Amount) = _getTokenAmount(
      pair.token2,
      token2Cost
    );
    uint256 token1AmountForLockFee = token1Amount.mul(tier.feePercent).div(
      10000
    );
    uint256 token2AmountForLockFee = token2Amount.mul(tier.feePercent).div(
      10000
    );
    if (token1Amount > 0) {
      _transferAsset(
        pair.token1,
        token1Amount,
        token1AmountForLockFee,
        pair.feeAddress
      );
    }

    if (token2Amount > 0) {
      _transferAsset(
        pair.token2,
        token2Amount,
        token2AmountForLockFee,
        pair.feeAddress
      );
    }

    locks[msg.sender] = Lock({
      lockId: msg.sender,
      tierId: tier.id,
      pairId: pair.pairId,
      nft: nft,
      nftId: nftId,
      nftDiscount: nftDiscount,
      token1Amount: token1Amount.sub(token1AmountForLockFee),
      token2Amount: token2Amount.sub(token2AmountForLockFee),
      feeAmountInToken1: token1AmountForLockFee,
      feeAmountInToken2: token2AmountForLockFee,
      startTime: block.timestamp,
      endTime: block.timestamp.add(pair.lockPeriod),
      locked: true
    });

    emit Locked(
      msg.sender,
      tier.id,
      pair.pairId,
      nft,
      nftId,
      nftDiscount,
      token1Amount,
      token1AmountForLockFee,
      token1Rate,
      token2Amount,
      token2AmountForLockFee,
      token2Rate
    );
  }

  /**
   * @dev Upgrades user's lock. It basically works like regular _createLockUp
   *   excepts the amount of token1, token2 and lockFee that user charges
   */
  function _updateLockUp(
    Lock storage userLock,
    Tier memory tier,
    Pair memory pair,
    uint256 token1Cost,
    uint256 token2Cost,
    uint256 diffCostInToken1,
    uint256 diffCostInToken2
  ) internal {
    (, uint256 token1AmountForUpdate) = _getTokenAmount(
      pair.token1,
      diffCostInToken1
    );

    (, uint256 token2AmountForUpdate) = _getTokenAmount(
      pair.token2,
      diffCostInToken2
    );

    uint256 token1AmountForLockFee = _getFeeAmount(
      pair.token1,
      token1Cost,
      tier.feePercent,
      userLock.feeAmountInToken1
    );
    uint256 token2AmountForLockFee = _getFeeAmount(
      pair.token2,
      token2Cost,
      tier.feePercent,
      userLock.feeAmountInToken2
    );

    if (diffCostInToken1 > 0) {
      _transferAsset(
        pair.token1,
        token1AmountForUpdate,
        token1AmountForLockFee,
        pair.feeAddress
      );
    }

    if (diffCostInToken2 > 0) {
      _transferAsset(
        pair.token2,
        token2AmountForUpdate,
        token2AmountForLockFee,
        pair.feeAddress
      );
    }

    userLock.tierId = tier.id;
    userLock.token1Amount = userLock
      .token1Amount
      .add(token1AmountForUpdate)
      .sub(token1AmountForLockFee);
    userLock.token2Amount = userLock
      .token2Amount
      .add(token2AmountForUpdate)
      .sub(token2AmountForLockFee);
    userLock.feeAmountInToken1 = userLock.feeAmountInToken1.add(
      token1AmountForLockFee
    );
    userLock.feeAmountInToken2 = userLock.feeAmountInToken2.add(
      token2AmountForLockFee
    );
    userLock.startTime = block.timestamp;
  }

  /**
   * @dev Withdraws the tokens and resets its tier.
   */
  function _unlock(address account, bool lockPeriodCheck) internal {
    Lock storage userLock = locks[account];
    Pair memory userPair = pairs[userLock.pairId];
    require(userLock.locked, "!locked");
    if (!userPair.deactivated && lockPeriodCheck) {
      require(userLock.endTime < block.timestamp, "wait until the lock ends");
    }

    if (userLock.token1Amount > 0) {
      IERC20(userPair.token1).transfer(account, userLock.token1Amount);
    }
    if (userLock.token2Amount > 0) {
      IERC20(userPair.token2).transfer(account, userLock.token2Amount);
    }
    if (userLock.nft != address(0)) {
      require(
        IERC721(userLock.nft).ownerOf(userLock.nftId) == address(this),
        "!owner"
      );
      IERC721(userLock.nft).safeTransferFrom(
        address(this),
        account,
        userLock.nftId
      );
    }

    userLock.lockId = address(0);
    userLock.tierId = 0;
    userLock.pairId = 0;
    userLock.nft = address(0);
    userLock.nftId = 0;
    userLock.nftDiscount = 0;
    userLock.token1Amount = 0;
    userLock.token2Amount = 0;
    userLock.feeAmountInToken1 = 0;
    userLock.feeAmountInToken2 = 0;
    userLock.startTime = 0;
    userLock.endTime = 0;
    userLock.locked = false;

    emit Unlocked(account, false);
  }

  /**
   * @dev Withdraws the tokens and resets its tier ealier than unlock time.
   */
  function _forceUnlock(address account) internal {
    Lock storage userLock = locks[account];
    Pair memory userPair = pairs[userLock.pairId];
    require(userLock.locked, "!locked");
    require(userPair.earlyUnlock, "EarlyUnlock is not allowed for this pair");
    require(
      userLock.startTime.add(userPair.lockPeriod) > block.timestamp,
      "can't unlock"
    );
    if (userLock.token1Amount > 0) {
      uint256 feeAmountInToken1 = userLock
        .token1Amount
        .mul(userPair.earlyUnlockFeePercent)
        .div(10000);
      IERC20(userPair.token1).transfer(userPair.feeAddress, feeAmountInToken1);
      IERC20(userPair.token1).transfer(
        account,
        userLock.token1Amount.sub(feeAmountInToken1)
      );
    }
    if (userLock.token2Amount > 0) {
      uint256 feeAmountInToken2 = userLock
        .token2Amount
        .mul(userPair.earlyUnlockFeePercent)
        .div(10000);
      IERC20(userPair.token2).transfer(userPair.feeAddress, feeAmountInToken2);
      IERC20(userPair.token2).transfer(
        account,
        userLock.token2Amount.sub(feeAmountInToken2)
      );
    }
    if (userLock.nft != address(0)) {
      require(
        IERC721(userLock.nft).ownerOf(userLock.nftId) == address(this),
        "!owner"
      );
      IERC721(userLock.nft).safeTransferFrom(
        address(this),
        account,
        userLock.nftId
      );
    }

    userLock.lockId = address(0);
    userLock.tierId = 0;
    userLock.pairId = 0;
    userLock.nft = address(0);
    userLock.nftId = 0;
    userLock.nftDiscount = 0;
    userLock.token1Amount = 0;
    userLock.token2Amount = 0;
    userLock.feeAmountInToken1 = 0;
    userLock.feeAmountInToken2 = 0;
    userLock.startTime = 0;
    userLock.endTime = 0;
    userLock.locked = false;

    emit Unlocked(account, true);
  }

  /**
   * Transfers asset from user to the contract
   * @param token - The adddres of asset you're going to transfer from user
   * @param tokenAmount - The token amount to transfer from user
   * @param feeAmount - The fee amount which is transferred to the fee address.
   */
  function _transferAsset(
    address token,
    uint256 tokenAmount,
    uint256 feeAmount,
    address feeAddress
  ) internal {
    require(tokenAmount > feeAmount, "what the fuck!");
    uint256 oldBalance = IERC20(token).balanceOf(address(this));
    IERC20(token).transferFrom(msg.sender, address(this), tokenAmount);
    uint256 newBalance = IERC20(token).balanceOf(address(this));
    require(
      newBalance.sub(oldBalance) == tokenAmount,
      "Doesn't support fee token"
    );
    IERC20(token).transfer(feeAddress, feeAmount);
  }

  /**
   * @dev Gets the tokenAmount for usdValue
   * @param token - The token address you're going to get amount for
   * @param usdValue - The cost in usd
   * @return - exchangeRate & tokenAmount
   */
  function _getTokenAmount(address token, uint256 usdValue)
    internal
    view
    returns (uint256, uint256)
  {
    uint256 exchangeRate = exchangeRateHelper.getExchangeRate(token);
    require(exchangeRate > 0, "not_listed");
    uint256 decimals = uint256(IERC20Extended(token).decimals());
    return (exchangeRate, usdValue.mul(10**decimals).div(exchangeRate));
  }

  /**
   * @dev Gets the tokenAmount for usdValue
   * @param token - The token address you're going to get amount for
   * @param usdValue - The cost in usd
   * @param feePercent - The fee percentage
   * @param basicFee - The fee amount already paid so it acutally needs to be eliminated
   * @return - exchangeRate & feeAmount
   */
  function _getFeeAmount(
    address token,
    uint256 usdValue,
    uint256 feePercent,
    uint256 basicFee
  ) internal view returns (uint256) {
    uint256 exchangeRate = exchangeRateHelper.getExchangeRate(token);
    require(exchangeRate > 0, "not_listed");
    uint256 decimals = uint256(IERC20Extended(token).decimals());
    uint256 tokenAmount = usdValue.mul(10**decimals).div(exchangeRate);
    uint256 feeAmount = tokenAmount.mul(feePercent).div(10000).sub(basicFee);

    return feeAmount;
  }

  /**
   * @dev It is called whenever ERC721 token is deposited to the contract
   */
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }
}

// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Extended {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IExchangeRateHelper {
    /**
     * @notice Get the price of a token
     * @param token The token you're going to get the price of
     * @return The asset price mantissa (scaled by 1e18). Zero means the price is unavailable.
     */
    function getExchangeRate(address token) external view returns (uint256);
}