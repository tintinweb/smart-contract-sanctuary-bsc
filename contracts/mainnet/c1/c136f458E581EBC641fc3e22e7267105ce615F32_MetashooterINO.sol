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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

import './interfaces/ILockableStaking.sol';
import './interfaces/ITicketsCounter.sol';
import './interfaces/IStakingLockAgent.sol';

contract MetashooterINO is ERC721Holder, IStakingLockAgent {
    using EnumerableSet for EnumerableSet.AddressSet;

    ITicketsCounter public ticketsCounter;
    IERC20 public BUSD;
    IERC721 public nft;
    address public backend;
    address public admin;
    address public projectOwner;

    uint256 public constant INO_ID = 1;
    uint32 public constant REGISTRATION_START = 1656936000; // Jul 04 2022 12:00:00 GMT+0000
    uint32 public constant REGISTRATION_END = 1657281600; // Jul 08 2022 12:00:00 GMT+0000
    uint32 public constant MAX_ALLOCATIONS_FOR_TICKET = 3;
    uint32 public constant TOTAL_NFT_AMOUNT = 250;
    uint256 public constant BUSD_FOR_ALLOCATION = 200e18;

    uint256[] public nftIds; // number of nfts loaded before INO registration started
    bool public drawn = false; // to prevent double draw
    bool public cancelled = false; // Admin can cancel and let every user get all their busd back (unless user claimed tokens already)]
    uint256 public seed;

    struct UserInfo {
        uint16 index;
        uint256 tickets;
        uint256 allocations;
        bool claimed;
    }

    // participants
    EnumerableSet.AddressSet _participants;
    // array of userIndexes, amount of userIndexed in array = tickets amount purchased by user
    uint16[] _allocationsAt;

    mapping(address => UserInfo) public userInfos;

    event Drawn(uint256 indexed inoId, uint256 indexed seed);
    event Claimed(uint256 indexed inoId, address indexed user);
    event Cancelled(uint256 inoId, string reason);

    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }

    modifier onlyProjectOwner() {
        require(msg.sender == projectOwner, 'only project owner');
        _;
    }

    constructor(
        ITicketsCounter ticketsCounter_,
        IERC20 BUSD_,
        IERC721 nft_,
        address backend_,
        address admin_,
        address projectOwner_
    ) {
        ticketsCounter = ticketsCounter_;
        BUSD = BUSD_;
        nft = nft_;
        backend = backend_;
        admin = admin_;
        projectOwner = projectOwner_;
    }

    // 1 ticket == 1-3 NFT to buy
    function register(uint256 nftAmountToBuy_) external returns (uint16 userIndex) {
        require(!cancelled, 'cancelled');
        require(nftAmountToBuy_ > 0, 'no nft amount');
        require(block.timestamp >= REGISTRATION_START, 'registration not open yet');
        require(block.timestamp < REGISTRATION_END, 'registration is closed already');
        require(!_participants.contains(msg.sender), 'registered');
        uint256 participantsLength = _participants.length();
        require(participantsLength < type(uint16).max, 'participants limit');

        (
            uint256 tickets,
            ILockableStaking[] memory lockableStakings,
            uint256[] memory lockableAmounts
        ) = ticketsCounter.countTickets(msg.sender, REGISTRATION_END);
        require(tickets > 0, 'no tickets');
        require(
            tickets * MAX_ALLOCATIONS_FOR_TICKET >= nftAmountToBuy_,
            'too many nft to buy'
        );
        uint256 maxAmountToLock;
        uint256 maxDrawDate = REGISTRATION_END;
        for (uint256 i = 0; i < lockableStakings.length; ++i) {
            if (lockableStakings[i].lockInfo(msg.sender).amount > maxAmountToLock) {
                maxAmountToLock = lockableStakings[i].lockInfo(msg.sender).amount;
            }
            if (lockableAmounts[i] > maxAmountToLock) {
                maxAmountToLock = lockableAmounts[i];
            }
            if (lockableStakings[i].lockInfo(msg.sender).until > maxDrawDate) {
                maxDrawDate = lockableStakings[i].lockInfo(msg.sender).until;
            }
            lockableStakings[i].lockByAgent(
                msg.sender,
                maxDrawDate,
                maxAmountToLock,
                bytes32(INO_ID)
            );
        }

        BUSD.transferFrom(
            msg.sender,
            address(this),
            BUSD_FOR_ALLOCATION * nftAmountToBuy_
        );

        userIndex = uint16(participantsLength);
        _participants.add(msg.sender);

        userInfos[msg.sender] = UserInfo({
            index: userIndex,
            tickets: tickets,
            allocations: nftAmountToBuy_,
            claimed: false
        });
        for (uint256 i = 0; i < nftAmountToBuy_; i++) {
            _allocationsAt.push(userIndex);
        }
    }

    function claim(uint256[] memory boxIds, bytes memory _sig) external {
        require(_participants.contains(msg.sender), 'not registered');
        if (cancelled) {
            _retrieveBusd(msg.sender);
            return;
        }
        require(drawn, 'not drawn');
        require(
            verifySignature(msg.sender, address(this), INO_ID, boxIds, _sig),
            'wrong signature'
        );
        if (boxIds.length == 0) {
            _retrieveBusd(msg.sender);
        } else {
            _retrieveNFTs(msg.sender, boxIds);
        }
    }

    function _retrieveNFTs(address user, uint256[] memory boxIds) internal {
        require(!userInfos[user].claimed, 'already claimed');
        for (uint256 i = 0; i < boxIds.length; i++) {
            nft.safeTransferFrom(address(this), msg.sender, boxIds[i]);
        }
        userInfos[user].claimed = true;
        emit Claimed(INO_ID, user);
    }

    function _retrieveBusd(address user) internal {
        require(!userInfos[user].claimed, 'already claimed');
        BUSD.transfer(user, BUSD_FOR_ALLOCATION * userInfos[user].allocations);
        userInfos[user].claimed = true;
        emit Claimed(INO_ID, user);
    }

    function loadNft(uint256 tokenId_) external onlyProjectOwner {
        require(nftIds.length < TOTAL_NFT_AMOUNT, 'limit');
        nft.safeTransferFrom(msg.sender, address(this), tokenId_);
        nftIds.push(tokenId_);
    }

    function draw() external onlyAdmin {
        require(!drawn, 'drawn already');
        require(block.timestamp > REGISTRATION_END, 'registration stage now');
        require(
            nftIds.length >= _allocationsAt.length || nftIds.length == TOTAL_NFT_AMOUNT,
            'not all nfts are loaded on contract yet'
        );
        seed = uint256(keccak256(abi.encodePacked(block.timestamp)));
        drawn = true;
        emit Drawn(INO_ID, seed);
    }

    function cancelINO(string memory reason) external onlyAdmin {
        require(!cancelled, 'cancelled already');
        require(!drawn, 'seed drawn already');
        cancelled = true;
        emit Cancelled(INO_ID, reason);
    }

    function returnAccidentallySentTokens(IERC20 token_, address receiver_)
        external
        onlyAdmin
    {
        require(address(token_) != address(BUSD), 'Unable to withdraw main token');
        uint256 amount = token_.balanceOf(address(this));
        token_.transfer(receiver_, amount);
    }

    function returnLeftNfts(
        IERC721 nft_,
        uint256 tokenId_,
        address receiver_
    ) external onlyAdmin {
        nft_.safeTransferFrom(address(this), receiver_, tokenId_);
    }

    function changeBackend(address backend_) external onlyAdmin {
        backend = backend_;
    }

    function getParticipants() external view returns (address[] memory) {
        return _participants.values();
    }

    function isParticipant(address user) external view returns (bool) {
        return _participants.contains(user);
    }

    function getParticipantByIndex(uint16 index) external view returns (address) {
        return _participants.at(index);
    }

    function getAllocations() external view returns (uint16[] memory) {
        return _allocationsAt;
    }

    function getNFTIds() external view returns (uint256[] memory) {
        return nftIds;
    }

    function getInfoForDraw()
        external
        view
        returns (
            uint256,
            address[] memory,
            uint16[] memory,
            uint256[] memory,
            uint256
        )
    {
        return (INO_ID, _participants.values(), _allocationsAt, nftIds, seed);
    }

    function getInoDetails()
        external
        pure
        returns (
            uint32,
            uint32,
            uint32,
            uint32,
            uint256
        )
    {
        return (
            REGISTRATION_START,
            REGISTRATION_END,
            MAX_ALLOCATIONS_FOR_TICKET,
            TOTAL_NFT_AMOUNT,
            BUSD_FOR_ALLOCATION
        );
    }

    function exceptionalUnlockPossible(address user, bytes32 payload)
        external
        view
        override
        returns (bool)
    {
        return cancelled;
    }

    function verifySignature(
        address user_,
        address ino_,
        uint256 inoId_,
        uint256[] memory boxIds_,
        bytes memory sig_
    ) internal view returns (bool) {
        bytes32 hashedMessage = ethMessageHash(user_, ino_, inoId_, boxIds_);
        return recover(hashedMessage, sig_) == backend;
    }

    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param sig bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:" and hash the result
     */
    function ethMessageHash(
        address user_,
        address ino_,
        uint256 inoId_,
        uint256[] memory boxIds_
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    '\x19Ethereum Signed Message:\n32',
                    keccak256(abi.encodePacked(user_, ino_, inoId_, boxIds_))
                )
            );
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './IStakingLockAgent.sol';

interface ILockableStaking {
    struct LockInfo {
        uint256 until; // Date until which lock holds
        uint256 amount; // Minimum unwithdrawable amount. (MAX_UINT256 to fully lock)
        IStakingLockAgent agent;
        bytes32 payload;
    }

    function lockByAgent(
        address staker,
        uint256 until,
        uint256 amount,
        bytes32 payload
    ) external;

    function lockInfo(address user) external view returns (LockInfo memory);

    event LockAgentSet(address indexed agent, bool indexed value);
    event LockedByAgent(
        address indexed agent,
        address indexed staker,
        uint256 until,
        uint256 amount,
        bytes32 payload
    );
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IStakingLockAgent {
    function exceptionalUnlockPossible(address user, bytes32 payload)
        external
        view
        returns (bool);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './ILockableStaking.sol';

interface ITicketsCounter {
    function countTickets(address who, uint256 drawDate)
        external
        view
        returns (
            uint256 tickets,
            ILockableStaking[] memory lockableStakings,
            uint256[] memory lockableAmounts
        );
}