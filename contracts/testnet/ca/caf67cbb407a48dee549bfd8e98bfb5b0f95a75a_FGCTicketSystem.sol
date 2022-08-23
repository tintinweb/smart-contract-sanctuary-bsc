/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


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

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


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

// File: contracts/raffle.sol


pragma solidity ^0.8.7;










contract FGCTicketSystem is
    VRFConsumerBaseV2,
    IERC721Receiver,
    Pausable,
    Ownable
{
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    bytes32 keyHash =
        0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 2200000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // Retrieve 100 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 100;

    uint256[] public s_randomWords;
    uint256 public s_requestId;

    address private SurpriseNFTAddress;
    uint256 private lastSupriseTokenIdTransfered;

    struct AwardERC721 {
        address addr;
        uint256 tokenId;
    }

    struct Range {
        uint256 minRange;
        uint256 maxRange;
        string Type;
        uint256 Rarity;
        uint256 NFTid;
    }

    Range[] public ranges;

    mapping(uint256 => AwardERC721[]) public NFTs;

    uint256 private RANGE_DIVIDER = 99999;
    uint256 private maxItems = 100;

    using SafeMath for uint256;

    address payable private factoryBeneficiary;
    address private Aggregator;

    AggregatorV3Interface internal priceFeed;
    //false means ChainLink getLatestPrice. true means price set by owner
    bool private priceFlag = false;
    uint256 private ownerPrice = 0;
    uint256 public ticketPrice = 10;

    // Mapping approvedContracts address
    mapping(address => bool) private approvedContracts;
    mapping(address => uint256) public playerTickets;
    mapping(address => string) public playerLastAward;

    uint256 randomListSize = 100;
    uint256 public randomIndex = 0;

    event NeedNewRandomRequest();
    event PlayerTicketBought(
        address player,
        uint256 ticketCount,
        uint256 ticketTotal
    );
    event PlayerRandomNumber(address player, uint256 randomNumber);
    event RequestNewRandomList(address player);

    event ERC721Won(
        address player,
        address contract_address,
        uint256 tokenId,
        string Type,
        uint256 Rarity,
        uint256 NFTid
    );
    event ERC721WonDelay(
        address player, 
        string Type,
        uint256 Rarity,
        uint256 NFTid
    );
    event TicketWon(address player, uint256 ticketCount, uint256 ticketTotal);
    event BadLuck(address player);

    constructor(uint64 subscriptionId, address payable _beneficiary, address _SurpriseNFTAddress)
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;

        factoryBeneficiary = _beneficiary;
        SurpriseNFTAddress = _SurpriseNFTAddress;

        /**
         * Network: Binance Smart Chain
         * Aggregator: BNB/USD
         * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
         */
        //mainet
        //Aggregator = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
        //priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);

        //test - 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        Aggregator = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setAggregatorV3Interface(address _Aggregator) public onlyOwner {
        Aggregator = _Aggregator;
        priceFeed = AggregatorV3Interface(Aggregator);
    }

    /**
     * @dev Pause crowdsale only by owner
     */
    function pause() public ownerOrApprovedByOwner {
        _pause();
    }

    /**
     * @dev Unpause crowdsale only by owner
     */
    function unpause() public ownerOrApprovedByOwner {
        _unpause();
    }

    /**
     * @dev _approvedRemoveContracts `to` to false
     *
     */
    function _approvedRemoveContracts(address to) public onlyOwner {
        approvedContracts[to] = false;
    }

    /**
     * @dev approvedContracts `to` to true
     *
     */
    function _approvedContracts(address to) public onlyOwner {
        approvedContracts[to] = true;
    }

    /**
     * @dev _getApprovedContracts
     *
     */
    function _getApprovedContracts(address to) public view returns (bool) {
        return approvedContracts[to];
    }

    modifier ownerOrApprovedByOwner() {
        require(
            msg.sender == owner() || _getApprovedContracts(msg.sender),
            "Not owner nor approved by owner"
        );
        _;
    }

    function setBeneficiaryAddress(address payable _factoryBeneficiary)
        public
        onlyOwner
    {
        factoryBeneficiary = _factoryBeneficiary;
    }

    function setTicketPrice(uint256 _ticketPrice)
        public
        ownerOrApprovedByOwner
    {
        ticketPrice = _ticketPrice;
    }

    function setOwnerPrice(uint256 _ownerPrice) public ownerOrApprovedByOwner {
        if (_ownerPrice == 0) {
            ownerPrice = uint256(getLatestPrice());
            priceFlag = false;
        } else {
            ownerPrice = _ownerPrice;
            priceFlag = true;
        }
    }

    function checkAmount(uint256 _value, uint256 _ticketCount)
        internal
        returns (bool)
    {
        if (!priceFlag) {
            ownerPrice = uint256(getLatestPrice());
        }

        require(ownerPrice > 1, "Wrong bnb price!");

        uint256 lowerPriceLimit = (_ticketCount *
            ticketPrice *
            1000000000000000000) / ownerPrice;

        if (_value >= lowerPriceLimit) {
            return true;
        } else {
            return false;
        }
    }

    //chianlink parnership airdrop
    function airdropTickets(
        address[] calldata _to,
        uint256[] calldata _ticketCount
    ) public ownerOrApprovedByOwner {
        require(
            _to.length == _ticketCount.length,
            "Receivers and IDs are different length"
        );
        for (uint256 i = 0; i < _to.length; i++) {
            playerTickets[_to[i]] =
                playerTickets[_to[i]] +
                _ticketCount[i];
        }
    }

    function removeUserArrayTickets(
        address[] calldata _to
    ) public ownerOrApprovedByOwner {
        for (uint256 i = 0; i < _to.length; i++) {
            playerTickets[_to[i]] = 0;
        }
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (uint256) {
        require(Aggregator != address(0), "Price Aggregator not set!");
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price).div(100000000);
    }

    function forwardFunds() external ownerOrApprovedByOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(factoryBeneficiary).call{
            value: balance,
            gas: 3000000
        }("");
    }

    function requestRandomWordsFGC() public ownerOrApprovedByOwner {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function buyTickets(uint256 ticketCount) public payable whenNotPaused {
        require(ticketCount > 0, "nft count is 0");
        require(checkAmount(msg.value, ticketCount), "Not enough BNB sent!");

        playerTickets[msg.sender] = playerTickets[msg.sender] + ticketCount;
        emit PlayerTicketBought(
            msg.sender,
            ticketCount,
            playerTickets[msg.sender]
        );

        uint256 balance = address(this).balance;
        (bool success, ) = payable(factoryBeneficiary).call{
            value: balance,
            gas: 3000000
        }("");
    }

    function getRandom() internal returns (uint256) {
        uint256 randomNumber = s_randomWords[randomIndex];
        randomIndex++;
        if (randomIndex == randomListSize) {
            randomIndex = 0;

            approvedContracts[msg.sender] = true;
            requestRandomWordsFGC();
            approvedContracts[msg.sender] = false;
            emit RequestNewRandomList(msg.sender);
        }

        return randomNumber;
    }

    function setRandomIndex(uint256 _randomIndex)
        public
        ownerOrApprovedByOwner
    {
        randomIndex = _randomIndex;
    }

    function setRandomListSize(uint256 _randomListSize)
        public
        ownerOrApprovedByOwner
    {
        randomListSize = _randomListSize;
    }

    function transferSurprise() internal {
        if(lastSupriseTokenIdTransfered < type(uint256).max) {
            IERC721(SurpriseNFTAddress).safeTransferFrom(
                address(this),
                msg.sender,
                lastSupriseTokenIdTransfered
            );
            lastSupriseTokenIdTransfered ++;
        } 
    }

    function startSpin() public whenNotPaused {
        require(playerTickets[msg.sender] > 0, "Not enough tickets!");

        playerTickets[msg.sender] = playerTickets[msg.sender] - 1;

        uint256 randomNumber = getRandom();
        emit PlayerRandomNumber(msg.sender, randomNumber);

        uint256 rangeIndex = returnRangeIndexFromRandom(randomNumber);
        string memory Type = ranges[rangeIndex].Type;
        playerLastAward[msg.sender] = Type;
        bytes32 _typeBytes = keccak256(bytes(Type));

        if (_typeBytes == keccak256(bytes("TICKET3"))) {
            playerTickets[msg.sender] = playerTickets[msg.sender] + 3;
            transferSurprise();
            emit TicketWon(msg.sender, 3, playerTickets[msg.sender]);
        } else if (_typeBytes == keccak256(bytes("TICKET2"))) {
            playerTickets[msg.sender] = playerTickets[msg.sender] + 2;
            transferSurprise();
            emit TicketWon(msg.sender, 2, playerTickets[msg.sender]);
        } else if (_typeBytes == keccak256(bytes("TICKET1"))) {
            playerTickets[msg.sender] = playerTickets[msg.sender] + 1;
            transferSurprise();
            emit TicketWon(msg.sender, 1, playerTickets[msg.sender]);
        } else if (_typeBytes == keccak256(bytes("BADLUCK"))) {
            transferSurprise();
            emit BadLuck(msg.sender);
        } else {
            if (checkValidERC721(rangeIndex)) {
                takeWinNFTs(rangeIndex);
            } else {
                emit ERC721WonDelay(msg.sender, Type, ranges[rangeIndex].Rarity, ranges[rangeIndex].NFTid);
            }
        }
    }

    //NFT region
    function returnRangeIndexFromRandom(uint256 number)
        internal
        view
        returns (uint256)
    {
        uint256 newNumber = number % RANGE_DIVIDER;

        for (uint256 i = 0; i < ranges.length; i++) {
            if (newNumber < ranges[i].maxRange) {
                return i;
            }
        }
        return 0;
    }

    function setRangeDivider(uint256 _maxRange) public ownerOrApprovedByOwner {
        RANGE_DIVIDER = _maxRange;
    }

    //upperLower (0/1) - 0 is minRange | 1 is maxRange
    function modifyRange(
        uint256 rangeIndex,
        uint256 upperLower,
        uint256 value,
        string memory Type,
        uint256 _Rarity,
        uint256 _NFTid
    ) public ownerOrApprovedByOwner {
        require(ranges.length > 0, "range elements count is 0");
        require(rangeIndex >= 0 && rangeIndex < ranges.length, "invalid Range");
        require(upperLower == 0 || upperLower == 1, "invalid upperLower");

        if (keccak256(bytes(Type)) != keccak256(bytes(""))) {
            ranges[rangeIndex].Type = Type;
        }
        if(_Rarity != 99) {
            ranges[rangeIndex].Rarity = _Rarity;
        }
        if(_NFTid > 0) {
            ranges[rangeIndex].NFTid = _NFTid;
        } 

        if (upperLower == 0) {
            ranges[rangeIndex].minRange = value;
            if (rangeIndex > 0) {
                ranges[rangeIndex - 1].maxRange = value - 1;
            }
        } else {
            ranges[rangeIndex].maxRange = value;
            if (rangeIndex < ranges.length) {
                ranges[rangeIndex + 1].minRange = value + 1;
            }
        }
    }

    // function addRange(
    //     uint256 lower,
    //     uint256 upper,
    //     string calldata _Type,
    //     uint256 _Rarity,
    //     uint256 _NFTid,
    //     AwardERC721[] calldata _NFTs
    // ) public ownerOrApprovedByOwner {
    //     ranges.push(Range({minRange: lower, maxRange: upper, Type: _Type, Rarity: _Rarity, NFTid: _NFTid}));
    //     uint256 index = ranges.length - 1;
    //     for (uint256 i = 0; i < _NFTs.length; i++) {
    //         NFTs[index].push(_NFTs[i]);
    //     }
    // }

    function addRangeStruct(
        Range calldata _range,
        AwardERC721[] calldata _NFTs
    ) public ownerOrApprovedByOwner {
        ranges.push(_range);
        uint256 index = ranges.length - 1;
        for (uint256 i = 0; i < _NFTs.length; i++) {
            NFTs[index].push(_NFTs[i]);
        }
    }

    function initStruct(Range[] calldata _range, AwardERC721[][] calldata _NFTs) public ownerOrApprovedByOwner {
        require(_range.length == _NFTs.length, 'invalid NFT array');

        for(uint256 i = 0; i < _range.length; i++) {
            addRangeStruct(_range[i], _NFTs[i]);
        }
    }

    function addAward721ListOnRangeIndex(
        uint256 rangeIndex,
        AwardERC721[] calldata _NFTs
    ) public ownerOrApprovedByOwner {
        for (uint256 i = 0; i < _NFTs.length; i++) {
            NFTs[rangeIndex].push(_NFTs[i]);
        }
    }

    function addAward721OnRangeIndex(
        uint256 rangeIndex,
        address NFTaddress,
        uint256 tokenId
    ) public ownerOrApprovedByOwner {
        NFTs[rangeIndex].push(
            AwardERC721({addr: NFTaddress, tokenId: tokenId})
        );
    }

    function modifyAward721OnRangeIndex(
        uint256 RangeIndex,
        uint256 NFTIndex,
        address NFTaddress,
        uint256 tokenId
    ) public ownerOrApprovedByOwner {
        NFTs[RangeIndex][NFTIndex].addr = NFTaddress;
        NFTs[RangeIndex][NFTIndex].tokenId = tokenId;
    }

    function takeWinNFTs(uint256 index) internal {
        address contract_address = NFTs[index][NFTs[index].length - 1].addr;
        uint256 token_id = NFTs[index][NFTs[index].length - 1].tokenId;

        IERC721(contract_address).safeTransferFrom(
            address(this),
            msg.sender,
            token_id
        );
        emit ERC721Won(
            msg.sender,
            contract_address,
            token_id,
            ranges[index].Type,
            ranges[index].Rarity,
            ranges[index].NFTid
        );
        NFTs[index].pop();
    }

    function checkValidERC721(uint256 RangeIndex) internal view returns (bool) {
        if (
            NFTs[RangeIndex].length > 0 &&
            NFTs[RangeIndex][NFTs[RangeIndex].length - 1].addr != address(0)
        ) {
            return true;
        }
        return false;
    }

    function withdrawNFTS(address to, address[] calldata NFTaddr, uint256[] calldata tokenId) public ownerOrApprovedByOwner {
        require(NFTaddr.length == tokenId.length, 'invalid sizes');
        for(uint256 i = 0; i < NFTaddr.length; i ++) {
            IERC721(NFTaddr[i]).safeTransferFrom(address(this), to, tokenId[i]);
        }
    }

    function removeRewardList(uint256 rewardIndex) public ownerOrApprovedByOwner {
        uint256 size = NFTs[rewardIndex].length;
        for(uint256 i = 0; i < size; i ++) {
            NFTs[rewardIndex].pop();
        }
    }
}