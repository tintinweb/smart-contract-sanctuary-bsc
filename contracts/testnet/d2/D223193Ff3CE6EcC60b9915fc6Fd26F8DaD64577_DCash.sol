/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// File @openzeppelin/contracts/token/ERC721/[email protected]

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


// File @openzeppelin/contracts/token/ERC20/[email protected]


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


// File @openzeppelin/contracts/utils/introspection/[email protected]


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


// File @openzeppelin/contracts/token/ERC721/[email protected]


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/access/[email protected]


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


// File @openzeppelin/contracts/utils/math/[email protected]


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


// File contracts/interfaces/IExchangeRateHelper.sol


pragma solidity ^0.8.0;

interface IExchangeRateHelper {
    /**
     * @notice Get the price of a token
     * @param token The token you're going to get the price of
     * @return The asset price mantissa (scaled by 1e18). Zero means the price is unavailable.
     */
    function getExchangeRate(address token) external view returns (uint256);
}


// File contracts/DCash.sol








contract DCash is IERC721Receiver, Ownable {
    using SafeMath for uint256;

    /**
     * @dev
     * @param pairId - The unique Id
     * @param token1 - The first token address of the pair
     * @param token2 - The second token address of the pair
     * @param tokenPercent - 0 through 10000. If it is set to 5000, then 50% of usdCost to stake to the pair will be paid in token1,
     *  and 50% in token2. if it is set to 80% then 80% is paid in token1, and 20% is paid in token2
     * @param nft - The nft address of the pair
     * @param nftPercent - Admin determines what percent discount of token1 or token2 cost should apply. defaults to 10000 (100%)
     * @param earlyUnstake - If true, `earlyUnstake` function is allowed for the pair
     * @param earlyUnstakeFeePercent - Defaults to 1000 (10%). This percent of token1 and token2 will be sent to feeWallet upon `earlyUnstake` call for the pair
     * @param lockPeriod - Admin can input amount of seconds users must wait before they can unstake from the pair after staking
     * @param feeAddress - The address the `stakeFee` and `earlyUnstakeFee` goes to
     */
    struct Pair {
        uint256 pairId;
        address token1;
        address token2;
        uint256 tokenPercent;
        address nft;
        uint256 nftPercent;
        bool earlyUnstake;
        uint256 earlyUnstakeFeePercent;
        uint256 lockPeriod;
        address feeAddress;
    }

    /**
     * @dev Stores the staked information of the user
     * @param stakeId - The unique Id. We use the user address because we allow 1 stake per address
     * @param account - The owner address of the stake
     * @param tierId - The tierId of the stake which determines the cost
     * @param pairId - The pairId you supply for the stake
     * @param nft - The nft address you deposited which is same to the nft address of the pair.
     *  If address(0) passes, it means that user doesn't want discount by nft
     * @param nftId - The token Id
     * @param nftDiscount - determines whether to use nft or not. In case of use, it will specify which token nftPercent discount applies to
     *  0 = no nft in use,
     *  1 = nft in use, nftPercent discount applies on token1 cost
     *	2 = nft in use, nftPercent discount applies on token2 cost
     * @param token1Amount - The token1 amount user has in the system
     * @param token2Amount - The token2 amount user has in the system
     * @param feeAmountInToken1 - The paid stakeFee in token1
     * @param feeAmountInToken2 - The paid stakeFee in token2
     * @param startTime - The timestamp that the lock starts at
     * @param staked - true/false
     */
    struct Stake {
        address stakeId;
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
        bool staked;
    }

    /**
     * @dev Stores the tier information which includes `cost` and `feePercent`
     * @param id - The tier id
     * @param cost - Tier cost in USD
     * @param feePercent - The fee percent user needs to pay to stake. 10000 means 100%
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
    uint256 public MAX_UNSTAKE_FEE_PERCENT = 10000;
    uint256 public MAX_TIER_COUNT = 8;

    /**
     * @dev Mapping of tierId to tierCost
     */
    mapping(uint8 => Tier) public tiers;

    /**
     * @dev Mapping of pairId to Pair
     */
    mapping(uint256 => Pair) public pairs;

    /**
     * @dev Mapping of stakeId to Stake
     */
    mapping(address => Stake) public stakes;

    /**
     * @dev Emitted when the owner updates the exchangeRateHelper address
     */
    event ExchangeRateHelperUpdated(
        address indexed oldHelper,
        address indexed newHelper
    );

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
        bool earlyUnstake,
        uint256 earlyUnstakeFeePercent,
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
        bool earlyUnstake,
        uint256 earlyUnstakeFeePercent,
        uint256 lockPeriod,
        address feeAddress
    );

    /**
     * @dev Emitted when user stakes
     * @param stakeId - The stake Id which is generated automatically whenever there is a new stake
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
    event Staked(
        address indexed stakeId,
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
     * @dev Emitted when user unstakes
     * @param stakeId - The stake Id you would like to unstake
     * @param earlyUnstake - Indicates if it is the normal/early unstake.
     */
    event Unstaked(address indexed stakeId, bool earlyUnstake);

    /**
     * @dev Emitted when use upgrades to
     * @param stakeId - The stake Id you would like to upgrade for
     * @param tierId - The tier Id you would like to upgrade to
     * @param token1Amount - The token1 amount you pay to upgrade
     * @param token2Amount - The token2 amount you pay to upgrade
     * @param paidFeeInToken1 - The token1 amount you pay for stakingFee
     * @param paidFeeInToken2 - The  token2 amount you pay for stakingFee
     * @param token1Rate - The exchange rate of token1
     * @param token2Rate - The exchange rate of token2
     */
    event Upgraded(
        address indexed stakeId,
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
        _setTierCosts();
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
        bool earlyUnstake,
        uint256 earlyUnstakeFeePercent,
        uint256 lockPeriod,
        address feeAddress
    ) external onlyOwner {
        require(tokenPercent < MAX_TOKEN_PERCENT, "Invalid token percent");
        require(nftPercent < MAX_NFT_PERCENT, "Invalid nft percent");
        require(
            earlyUnstakeFeePercent < MAX_UNSTAKE_FEE_PERCENT,
            "Invalid earlyUnstake percent"
        );
        pairs[pairCount] = Pair({
            pairId: pairCount,
            token1: token1,
            token2: token2,
            tokenPercent: tokenPercent,
            nft: nft,
            nftPercent: nftPercent,
            earlyUnstake: earlyUnstake,
            earlyUnstakeFeePercent: earlyUnstakeFeePercent,
            lockPeriod: lockPeriod,
            feeAddress: feeAddress
        });

        emit PairAdded(
            pairCount,
            token1,
            token2,
            tokenPercent,
            nft,
            nftPercent,
            earlyUnstake,
            earlyUnstakeFeePercent,
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
        bool earlyUnstake,
        uint256 earlyUnstakeFeePercent,
        uint256 lockPeriod,
        address feeAddress
    ) external onlyOwner {
        require(pairId < pairCount, "Invalid Pair");
        require(tokenPercent < MAX_TOKEN_PERCENT, "Invalid token percent");
        require(nftPercent < MAX_NFT_PERCENT, "Invalid nft percent");
        require(
            earlyUnstakeFeePercent < MAX_UNSTAKE_FEE_PERCENT,
            "Invalid earlyUnstake percent"
        );

        Pair storage pair = pairs[pairId];
        pair.token1 = token1;
        pair.token2 = token2;
        pair.tokenPercent = tokenPercent;
        pair.nft = nft;
        pair.nftPercent = nftPercent;
        pair.earlyUnstake = earlyUnstake;
        pair.earlyUnstakeFeePercent = earlyUnstakeFeePercent;
        pair.lockPeriod = lockPeriod;
        pair.feeAddress = feeAddress;

        emit PairUpdated(
            pairId,
            token1,
            token2,
            tokenPercent,
            nft,
            nftPercent,
            earlyUnstake,
            earlyUnstakeFeePercent,
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
     * @dev Updates the address of exchangeRateHelper
     * @param _exchangeRateHelper - The address you're going to update with
     */
    function setExchangeRateHelper(address _exchangeRateHelper)
        external
        onlyOwner
        whenNotPaused
    {
        require(
            address(exchangeRateHelper) != _exchangeRateHelper,
            "already_set"
        );
        emit ExchangeRateHelperUpdated(
            address(exchangeRateHelper),
            _exchangeRateHelper
        );
        exchangeRateHelper = IExchangeRateHelper(_exchangeRateHelper);
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
    function stake(
        uint8 tierId,
        uint256 pairId,
        address nft,
        uint256 nftId,
        uint8 nftDiscount
    ) public whenNotPaused {
        require(tierId < MAX_TIER_COUNT, "Invalid tierId");
        require(pairId < pairCount, "Invalid pairId");
        require(!stakes[msg.sender].staked, "Already staked");
        Pair memory pair = pairs[pairId];
        if (nft != address(0)) {
            require(pair.nft == nft, "NFT address mismatch");
            require(IERC721(nft).ownerOf(nftId) == msg.sender, "!owner");
            IERC721(nft).safeTransferFrom(msg.sender, address(this), nftId);
        }

        Tier memory tier = tiers[tierId];
        uint256 tierCostForToken1 = tier.cost.mul(pair.tokenPercent).div(10000);
        uint256 tierCostForToken2 = tier.cost.sub(tierCostForToken1);

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

        _createStake(
            tier,
            pair,
            tierCostForToken1,
            tierCostForToken2,
            nft,
            nftId,
            nftDiscount
        );
    }

    /**
     * @dev Upgrades the stake to a high-level tier
     * @param tierId - The tierId you would like to upgrade to
     */
    function upgradeStake(uint8 tierId) public whenNotPaused {
        Stake storage userStake = stakes[msg.sender];

        require(userStake.staked, "need to stake first");
        require(
            tierId > userStake.tierId,
            "should upgrade to the higher levels"
        );

        uint256 diffCost = tiers[tierId].cost.sub(tiers[userStake.tierId].cost);
        uint256 tierCostForToken1 = tiers[tierId]
            .cost
            .mul(pairs[userStake.pairId].tokenPercent)
            .div(10000);
        uint256 tierCostForToken2 = tiers[tierId].cost.sub(tierCostForToken1);
        uint256 diffCostInToken1 = diffCost
            .mul(pairs[userStake.pairId].tokenPercent)
            .div(10000);
        uint256 diffCostInToken2 = diffCost.sub(tierCostForToken1);

        if (userStake.nftDiscount == 1) {
            // used on token1 cost
            diffCostInToken1 = diffCostInToken1.sub(
                diffCostInToken1.mul(pairs[userStake.pairId].nftPercent).div(
                    10000
                )
            );
        } else if (userStake.nftDiscount == 2) {
            // used on token2 cost
            diffCostInToken2 = diffCostInToken2.sub(
                diffCostInToken2.mul(pairs[userStake.pairId].nftPercent).div(
                    10000
                )
            );
        }

        _updateStake(
            userStake,
            tiers[tierId],
            pairs[userStake.pairId],
            tierCostForToken1,
            tierCostForToken2,
            diffCostInToken1,
            diffCostInToken2
        );
    }

    /**
     * @dev Withdraws the tokens and resets its tier.
     */
    function unStake() public {
        Stake storage userStake = stakes[msg.sender];
        Pair memory userPair = pairs[userStake.pairId];
        require(userStake.staked, "!staked");
        require(
            userStake.startTime.add(userPair.lockPeriod) < block.timestamp,
            "wait until the lock ends"
        );
        if (userStake.token1Amount > 0) {
            IERC20(userPair.token1).transfer(
                msg.sender,
                userStake.token1Amount
            );
        }
        if (userStake.token2Amount > 0) {
            IERC20(userPair.token2).transfer(
                msg.sender,
                userStake.token2Amount
            );
        }
        if (userStake.nft != address(0)) {
            require(
                IERC721(userStake.nft).ownerOf(userStake.nftId) ==
                    address(this),
                "!owner"
            );
            IERC721(userStake.nft).safeTransferFrom(
                address(this),
                msg.sender,
                userStake.nftId
            );
        }

        userStake.staked = false;

        emit Unstaked(msg.sender, false);
    }

    /**
     * @dev Withdraws the tokens and resets its tier ealier than unlock time.
     */
    function forceUnstake() public {
        Stake storage userStake = stakes[msg.sender];
        Pair memory userPair = pairs[userStake.pairId];
        require(userStake.staked, "!staked");
        require(
            userPair.earlyUnstake,
            "EarlyUnstake is not allowed for this pair"
        );
        require(
            userStake.startTime.add(userPair.lockPeriod) > block.timestamp,
            "can't unstake"
        );
        if (userStake.token1Amount > 0) {
            uint256 feeAmountInToken1 = userStake
                .token1Amount
                .mul(userPair.earlyUnstakeFeePercent)
                .div(10000);
            IERC20(userPair.token1).transfer(
                userPair.feeAddress,
                feeAmountInToken1
            );
            IERC20(userPair.token1).transfer(
                msg.sender,
                userStake.token1Amount.sub(feeAmountInToken1)
            );
        }
        if (userStake.token2Amount > 0) {
            uint256 feeAmountInToken2 = userStake
                .token2Amount
                .mul(userPair.earlyUnstakeFeePercent)
                .div(10000);
            IERC20(userPair.token2).transfer(
                userPair.feeAddress,
                feeAmountInToken2
            );
            IERC20(userPair.token2).transfer(
                msg.sender,
                userStake.token2Amount.sub(feeAmountInToken2)
            );
        }
        if (userStake.nft != address(0)) {
            require(
                IERC721(userStake.nft).ownerOf(userStake.nftId) ==
                    address(this),
                "!owner"
            );
            IERC721(userStake.nft).safeTransferFrom(
                address(this),
                msg.sender,
                userStake.nftId
            );
        }

        userStake.staked = false;

        emit Unstaked(msg.sender, true);
    }

    ///============= Internal Functions =============///

    /**
     * @dev Initializes tiers mapping
     */
    function _setTierCosts() internal {
        tiers[0] = Tier({id: 0, cost: 100e18, feePercent: 500});
        tiers[1] = Tier({id: 1, cost: 280e18, feePercent: 400});
        tiers[2] = Tier({id: 2, cost: 600e18, feePercent: 350});
        tiers[3] = Tier({id: 3, cost: 1400e18, feePercent: 300});
        tiers[4] = Tier({id: 4, cost: 2600e18, feePercent: 250});
        tiers[5] = Tier({id: 5, cost: 5400e18, feePercent: 200});
        tiers[6] = Tier({id: 6, cost: 12000e18, feePercent: 175});
        tiers[7] = Tier({id: 7, cost: 22000e18, feePercent: 150});
    }

    /**
     * @dev Creates a stake with `tierId` and `pairId`
     */
    function _createStake(
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
        uint256 token1AmountForStakeFee = token1Amount.mul(tier.feePercent).div(
            10000
        );
        uint256 token2AmountForStakeFee = token2Amount.mul(tier.feePercent).div(
            10000
        );
        if (token1Amount > 0) {
            _transferAsset(
                pair.token1,
                token1Amount,
                token1AmountForStakeFee,
                pair.feeAddress
            );
        }

        if (token2Amount > 0) {
            _transferAsset(
                pair.token2,
                token2Amount,
                token2AmountForStakeFee,
                pair.feeAddress
            );
        }

        stakes[msg.sender] = Stake({
            stakeId: msg.sender,
            tierId: tier.id,
            pairId: pair.pairId,
            nft: nft,
            nftId: nftId,
            nftDiscount: nftDiscount,
            token1Amount: token1Amount.sub(token1AmountForStakeFee),
            token2Amount: token2Amount.sub(token2AmountForStakeFee),
            feeAmountInToken1: token1AmountForStakeFee,
            feeAmountInToken2: token2AmountForStakeFee,
            startTime: block.timestamp,
            staked: true
        });

        emit Staked(
            msg.sender,
            tier.id,
            pair.pairId,
            nft,
            nftId,
            nftDiscount,
            token1Amount,
            token1AmountForStakeFee,
            token1Rate,
            token2Amount,
            token2AmountForStakeFee,
            token2Rate
        );
    }

    /**
     * @dev Upgrades user's stake. It basically works like regular _createStake
     *   excepts the amount of token1, token2 and stakeFee that user charges
     */
    function _updateStake(
        Stake memory userStake,
        Tier memory tier,
        Pair memory pair,
        uint256 token1Cost,
        uint256 token2Cost,
        uint256 diffCostInToken1,
        uint256 diffCostInToken2
    ) internal {
        (uint256 token1Rate, uint256 token1AmountForStakeFee) = _getFeeAmount(
            pair.token1,
            token1Cost,
            tier.feePercent,
            userStake.feeAmountInToken1
        );
        (uint256 token2Rate, uint256 token2AmountForStakeFee) = _getFeeAmount(
            pair.token2,
            token2Cost,
            tier.feePercent,
            userStake.feeAmountInToken2
        );

        if (diffCostInToken1.div(token1Rate) > 0) {
            _transferAsset(
                pair.token1,
                diffCostInToken1.div(token1Rate),
                token1AmountForStakeFee,
                pair.feeAddress
            );
        }

        if (diffCostInToken2.div(token2Rate) > 0) {
            _transferAsset(
                pair.token2,
                diffCostInToken2.div(token2Rate),
                token2AmountForStakeFee,
                pair.feeAddress
            );
        }

        userStake.tierId = tier.id;
        userStake.token1Amount = userStake
            .token1Amount
            .add(diffCostInToken1.div(token1Rate))
            .sub(token1AmountForStakeFee);
        userStake.token2Amount = userStake
            .token2Amount
            .add(diffCostInToken2.div(token2Rate))
            .sub(token2AmountForStakeFee);
        userStake.feeAmountInToken1 = userStake.feeAmountInToken1.add(
            token1AmountForStakeFee
        );
        userStake.feeAmountInToken2 = userStake.feeAmountInToken2.add(
            token2AmountForStakeFee
        );
        userStake.startTime = block.timestamp;

        emit Upgraded(
            msg.sender,
            tier.id,
            diffCostInToken1.div(token1Rate).sub(token1AmountForStakeFee),
            diffCostInToken2.div(token2Rate).sub(token2AmountForStakeFee),
            token1AmountForStakeFee,
            token2AmountForStakeFee,
            token1Rate,
            token2Rate
        );
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
        return (exchangeRate, usdValue.mul(1e18).div(exchangeRate));
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
    ) internal view returns (uint256, uint256) {
        uint256 exchangeRate = exchangeRateHelper.getExchangeRate(token);
        require(exchangeRate > 0, "not_listed");
        uint256 tokenAmount = usdValue.mul(1e18).div(exchangeRate);
        uint256 feeAmount = tokenAmount.mul(feePercent).div(10000).sub(
            basicFee
        );

        return (exchangeRate, feeAmount);
    }

    /**
     * @dev It is called whenever ERC721 token is deposited to the contract
     */
    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Invalid Sender!");
        return IERC721Receiver.onERC721Received.selector;
    }
}