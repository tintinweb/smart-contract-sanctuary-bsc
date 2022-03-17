// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./NoLossLotteryLogic.sol";

/**
 * No loss lottery for awarding ERC1155 tokens.
 */
contract NoLossLotteryERC1155 is NoLossLotteryLogic, ERC1155HolderUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    IERC1155Upgradeable private _awardToken;
    uint256 private _awardTokenId;
    uint256 private _awardsPerTicket;
    address private _awardPool;

    function initialize(
        string memory name_,
        uint256 endTime_,
        IERC20Upgradeable paymentToken_,
        uint256 pricePerTicket_,
        uint256 maxTicketsPerPlayer_,
        uint256[] memory tieredTickets_,
        uint256[] memory tieredAwards_,
        address paymentTarget_,
        address owner_
    ) public virtual initializer {
        __NoLossLotteryLogic_init(
            name_, endTime_, paymentToken_, pricePerTicket_, maxTicketsPerPlayer_,
            tieredTickets_, tieredAwards_, paymentTarget_, owner_
        );
        __ERC1155Holder_init();
    }

    function awardToken() public view returns (IERC1155Upgradeable) {
        return _awardToken;
    }

    function awardTokenId() public view returns (uint256) {
        return _awardTokenId;
    }

    function awardsPerTicket() public view returns (uint256) {
        return _awardsPerTicket;
    }

    function awardPool() public view returns (address) {
        return _awardPool;
    }

    function setAwards(
        IERC1155Upgradeable awardToken_,
        uint256 awardTokenId_,
        uint256 awardsPerTicket_,
        address awardPool_
    ) public onlyOwner {
        require(awardsPerTicket_ > 0, "Award per ticket must be more than 0");
        require(awardPool_ != address(0), "Award pool cannot be zero address");

        _awardToken = awardToken_;
        _awardTokenId = awardTokenId_;
        _awardsPerTicket = awardsPerTicket_;
        _awardPool = awardPool_;
    }

    /**
     * Funds this lottery with awards from pool.
     */
    function _secureAwards() internal virtual override {
        uint256 winningTicketCount = MathUpgradeable.min(currentTieredAwards(), ticketCount());
        uint256 awardAmount = _awardsPerTicket * winningTicketCount;

        _awardToken.safeTransferFrom(_awardPool, address(this), _awardTokenId, awardAmount, "");
    }

    /**
     * Returns true if this contract has all the awards already.
     */
    function _awardsAvailable() internal virtual override view returns (bool) {
        uint256 winningTicketCount = MathUpgradeable.min(currentTieredAwards(), ticketCount());
        uint256 awardAmount = _awardsPerTicket * winningTicketCount;

        return (_awardToken.balanceOf(address(this), _awardTokenId) == awardAmount);
    }

    // /**
    //  * Funds this lottery with awards.
    //  */
    // function fundAwards(
    //     IERC1155Upgradeable awardPool_,
    //     uint256 awardId_,
    //     uint256 awardPerTicket_,
    //     address unclaimedAwardTarget_
    // ) public onlyOwner {
    //     require(_awardPerTicket == 0, "Lottery already funded");
    //     require(awardPerTicket_ > 0, "Award per ticket must be more than 0");
        
    //     _awardPool = awardPool_;
    //     _awardId = awardId_;
    //     _awardPerTicket = awardPerTicket_;
    //     _unclaimedAwardTarget = unclaimedAwardTarget_;

    //     uint256 fundAmount = _awardPerTicket * maxWinners();
    //     _awardPool.safeTransferFrom(msg.sender, address(this), _awardId, fundAmount, "");
    // }

    // function _awardsAvailable() internal virtual override view returns (bool) {
    //     return _awardToken.balanceOf(address(this), _awardId) == _awardPerTicket * maxWinners();
    // }

    // /**
    //  * Return unclaimed awards.
    //  * Eg, in case there are less tickets sold than the max/expected number of winners.
    //  */
    // function _returnUnclaimedAwards() internal virtual override {
    //     uint256 unclaimedAwardAmount = (maxWinners() - winningTicketCount()) * _awardPerTicket;
    //     _awardPool.safeTransferFrom(address(this), _unclaimedAwardTarget, _awardId, unclaimedAwardAmount, "");
    // }

    /**
     * Send award to player.
     */
    function _award(address player, uint256 ticketCount) internal virtual override {
        uint256 awardAmount = ticketCount * _awardsPerTicket;
        _awardToken.safeTransferFrom(address(this), player, _awardTokenId, awardAmount, "");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[41] private __gap; //TODO
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
library EnumerableSetUpgradeable {
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

        (bool success, ) = recipient.call{value: amount}("");
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

        (bool success, bytes memory returndata) = target.call{value: value}(data);
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./LotteryStorage.sol";
import "./LotteryConfig.sol";

// import "hardhat/console.sol";

/**
 * Logic contract for no loss lottery.
 *   - It allows players to buy tickets.
 *   - It uses the delay call service contract to pick winners when the lottery ends.
 *   - It awards winners, refunds non-winners, and returns unclaimed awards.
 *
 * @dev Must implement _awardWinners() and _returnUnclaimedAwards().
 */
abstract contract NoLossLotteryLogic is LotteryConfig, LotteryStorage, PausableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    //TODO: delay call service contract
    //TODO: RNG service contract

    enum LotteryState {
        STARTED,
        CLOSED,
        SECURING_AWARDS,
        PICKING_WINNERS,
        WINNERS_PICKED
    }
    LotteryState private _state;

    mapping(address => bool) private _playerClaims; // player address to whether they have claimed their winning tickets
    mapping(address => bool) private _playerRefunds; // player address to whether they have refunded their non-winning tickets

    event StateChanged(LotteryState newState);

    event TicketsBought(address player, uint256 count);

    event TicketsClaimed(address player, uint256 winningTicketCount);

    event TicketsRefunded(address player, uint256 nonWinningTicketCount);

    function __NoLossLotteryLogic_init(
        string memory name_,
        uint256 endTime_,
        IERC20Upgradeable paymentToken_,
        uint256 pricePerTicket_,
        uint256 maxTicketsPerPlayer_,
        uint256[] memory tieredTickets_,
        uint256[] memory tieredAwards_,
        address paymentTarget_,
        address owner_
    ) internal onlyInitializing {
        // init base contracts
        __TwoStageOwnable_init_unchained(owner_);
        __LotteryConfig_init_unchained(
            name_, endTime_, paymentToken_, pricePerTicket_, maxTicketsPerPlayer_,
            tieredTickets_, tieredAwards_, paymentTarget_, owner_
        );
        __LotteryStorage_init_unchained();
        __Pausable_init_unchained();

        __NoLossLotteryLogic_init_unchained(
            name_, endTime_, paymentToken_, pricePerTicket_, maxTicketsPerPlayer_,
            tieredTickets_, tieredAwards_, paymentTarget_, owner_
        );
    }

    function __NoLossLotteryLogic_init_unchained(
        string memory,
        uint256,
        IERC20Upgradeable,
        uint256,
        uint256,
        uint256[] memory,
        uint256[] memory,
        address,
        address
    ) internal onlyInitializing {
        _setState(LotteryState.STARTED);
    }

    function state() public view returns (LotteryState) {
        return _state;
    }

    function isOpen() public view returns (bool) {
        return _state == LotteryState.STARTED && block.timestamp < endTime();
    }

    function _setState(LotteryState newState) internal {
        _state = newState;
        emit StateChanged(_state);
    }

    function canTransitState() public view returns (bool) {
        if (_state == LotteryState.STARTED) {
            return true; // TODO
            // return block.timestamp >= endTime();
        } else if (_state == LotteryState.CLOSED) {
            return ticketCount() > 0;
        } else if (_state == LotteryState.SECURING_AWARDS) {
            return _awardsAvailable();
        } else if (_state == LotteryState.PICKING_WINNERS) {
            return winningTicketCount() > 0;
        }
        return false;
    }

    function transitState() public whenNotPaused {
        require(canTransitState(), "Cannot transit to next state");
        
        if (_state == LotteryState.STARTED) {
            _close();
        } else if (_state == LotteryState.CLOSED) {
            _checkSecureAwards();
        } else if (_state == LotteryState.SECURING_AWARDS) {
            _pickWinners();
        } else if (_state == LotteryState.PICKING_WINNERS) {
            _setState(LotteryState.WINNERS_PICKED);
        }
    }

    function _close() private whenNotPaused {
        _setState(LotteryState.CLOSED);
        if (canTransitState())
            transitState();
    }

    function _checkSecureAwards() private whenNotPaused {
        _setState(LotteryState.SECURING_AWARDS);

        _secureAwards();

        if (canTransitState())
            transitState();
    }

    /**
     * @dev Implement this to secure the awards.
     */
    function _secureAwards() internal virtual;

    /**
     * @dev Implement this to return check if this contract is funded with awards.
     */
    function _awardsAvailable() internal virtual view returns (bool);

    // function test(uint256 count) public returns (uint256) {
    //     PlayerData[] memory players = new PlayerData[](count);
    //     players[0].ticketCount++;
    //     // uint256[] memory a;
    //     // a[0] = 123;
    //     _setState(LotteryState.PICKING_WINNERS);
    //     return count;
    // }

    /**
     * Picks the winners.
     */
    function _pickWinners() private {
        // require(state() == LotteryState.STARTED, "Lottery is not open");
        // require(block.timestamp >= endTime(), "Lottery end time not reached");

        // _beforePickWinners();

        _setState(LotteryState.PICKING_WINNERS);

        //TODO
        uint256 randomNumber = block.timestamp;
        uint256 tixCount = ticketCount();
        uint256 winTixCount = MathUpgradeable.min(currentTieredAwards(), tixCount);
        uint256 tixLeft = winTixCount;
        uint256 playerCount = _players.length;
        uint256 dupCount = 0;

        while (tixLeft > 0) {
            uint256 tixId = uint256(keccak256(abi.encode(randomNumber, tixLeft, dupCount))) % tixCount;
            // console.log("tixId", tixId, tixLeft);

            for (uint256 i=0; i<playerCount; i++) {
                address player = _players[i];
                // PlayerData storage playerData = _playerData[player];
                // uint256 playerTixCount = playerData.ticketCount;
                uint256 playerTixCount = _playerTicketCounts[player];
                // console.log(" player", i, playerTixCount, tixId);
                if (tixId < playerTixCount) {
                    uint256 playerWinningTixCount = _winnerTicketCounts[player];
                    uint256 playerNonWinningTixCount = playerTixCount - playerWinningTixCount;
                    if (playerNonWinningTixCount > 0) {
                        uint256 playerWinTixCount = (
                            uint256(keccak256(abi.encode(randomNumber, player, tixLeft))) %
                            ((MathUpgradeable.min(playerNonWinningTixCount, tixLeft * playerTixCount / tixCount) / 1) + 1)
                        ) + 1;
                        playerWinTixCount = MathUpgradeable.min(playerWinTixCount, playerNonWinningTixCount);
                        playerWinTixCount = MathUpgradeable.min(playerWinTixCount, tixLeft);
                        // uint256 playerWinTixCount = 1;
                        // console.log("  playerWinTixCount", playerNonWinningTixCount, playerWinTixCount);
                        // _addPlayerWinningTicketCount(player, playerWinTixCount);
                        _winnerTicketCounts[player] = playerWinningTixCount + playerWinTixCount;
                        // _playerData[player] = playerData;
                        tixLeft -= playerWinTixCount;
                    } else {
                        // console.log("***dupCount", dupCount);
                        dupCount++;
                    }
                    break;
                }

                tixId -= playerTixCount;
            }
        }
        // do {
        //     uint256 roundTixCount = tixLeft;
        //     for (uint256 i=0; i < playerCount && tixLeft > 0; i++) {
        //         address player = _players.at(i);
        //         uint256 playerWinningTicketCount = MathUpgradeable.min(ticketCountOf(player), tixLeft);
        //         _addPlayerWinningTicketCount(player, playerWinningTicketCount);
        //         tixLeft -= playerWinningTicketCount;
        //     }
        // } while (tixLeft > 0);

        _setState(LotteryState.WINNERS_PICKED);

        // transfer payments from winners to target
        paymentToken().safeTransfer(paymentTarget(), pricePerTicket() * winningTicketCount());

        // return all unclaimed awards back to where it came from
        // _returnUnclaimedAwards();

        // _afterPickWinners();
    }

        /**
     * @dev Hook that is called before picking winners.
     */
    function _beforePickWinners() internal virtual {}

    /**
     * @dev Hook that is called after picking winners.
     */
    function _afterPickWinners() internal virtual {}

    /**
     * @dev Implement this to return unclaimed awards.
     * Eg, in case there are less tickets sold than the max/expected number of winners.
     */
    // function _returnUnclaimedAwards() internal virtual;

    function currentTier() public view returns (uint256) {
        uint256[] memory tiers = tieredTickets();
        uint256 i = 1;
        for (; i<tiers.length && ticketCount() >= tiers[i]; i++) {}
        i--;
        return i;
    }

    function currentTieredAwards() public view returns (uint256) {
        return tieredAwards()[currentTier()];
    }

    /**
     * Player buys a specific number of tickets.
     * 
     * @dev The total price of the tickets in the payment token will be transferred from the player.
     * So, player must approve at least that much payment token to this contract first.
     */
    function buyTickets(uint256 count) external whenNotPaused {
        address player = msg.sender;
        require(isOpen(), "Lottery is closed");
        require(count > 0, "Ticket count must be positive");
        require(
            (maxTicketsPerPlayer() == 0) || (ticketCountOf(player) + count <= maxTicketsPerPlayer()),
            "Player ticket limit reached"
        );
        
        // _beforeBuyTickets(player, count);

        // get payment
        paymentToken().safeTransferFrom(player, address(this), pricePerTicket() * count);

        // mint the tickets
        _mintTickets(player, count);

        emit TicketsBought(player, count);

        // _afterBuyTickets(player, count);
    }
    
    /**
     * @dev Hook that is called before any ticket buy.
     */
    function _beforeBuyTickets(
        address player,
        uint256 count
    ) internal virtual {}

    /**
     * @dev Hook that is called after any ticket buy.
     */
    function _afterBuyTickets(
        address player,
        uint256 count
    ) internal virtual {}

    function ticketsClaimed(address player) public view returns (bool) {
        return _playerClaims[player];
    }

    function ticketsRefunded(address player) public view returns (bool) {
        return _playerRefunds[player];
    }

    /**
     * Player claims awards for winning tickets.
     */
    function claimTickets() external whenNotPaused {
        address player = msg.sender;
        require(state() == LotteryState.WINNERS_PICKED, "Winners are not picked yet");
        require(!_playerClaims[player], "Player already claimed tickets");

        uint256 winningTicketCount = winningTicketCountOf(player);
        require(winningTicketCount > 0, "Player has no winning tickets");

        // _beforeClaimTickets(player, winningTicketCount);

        _playerClaims[player] = true;
        _award(player, winningTicketCount);

        emit TicketsClaimed(player, winningTicketCount);

        // _afterClaimTickets(player, winningTicketCount);
    }

    /**
     * @dev Implement this to award winners tokens or NFTs.
     */
    function _award(address player, uint256 ticketCount) internal virtual;
    
    /**
     * @dev Hook that is called before any ticket claim.
     */
    function _beforeClaimTickets(
        address player,
        uint256 count
    ) internal virtual {}

    /**
     * @dev Hook that is called after any ticket claim.
     */
    function _afterClaimTickets(
        address player,
        uint256 count
    ) internal virtual {}


    /**
     * Player refunds non-winning tickets.
     */
    function refundTickets() external whenNotPaused {
        address player = msg.sender;
        require(state() == LotteryState.WINNERS_PICKED, "Winners are not picked yet");
        require(!_playerRefunds[player], "Player already refunded tickets");

        uint256 ticketCount = ticketCountOf(player);
        uint256 winningTicketCount = winningTicketCountOf(player);
        uint256 nonWinningTicketCount = ticketCount - winningTicketCount;
        require(nonWinningTicketCount > 0, "Player has no non-winning tickets");

        // _beforeRefundTickets(player, nonWinningTicketCount);

        _playerRefunds[player] = true;
        paymentToken().safeTransfer(player, pricePerTicket() * nonWinningTicketCount);

        emit TicketsRefunded(player, nonWinningTicketCount);

        // _afterRefundTickets(player, nonWinningTicketCount);
    }

    /**
     * @dev Hook that is called before any ticket refund.
     */
    function _beforeRefundTickets(
        address player,
        uint256 count
    ) internal virtual {}

    /**
     * @dev Hook that is called after any ticket refund.
     */
    function _afterRefundTickets(
        address player,
        uint256 count
    ) internal virtual {}


    /**
     * Pause for emergency use only.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * Unpause after emergency is gone.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[41] private __gap; //TODO
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
interface IERC165Upgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * Storage contract for lottery runtime vars.
 * Similar to ERC721, each player can buy tickets, each ticket corresponds to a NFT ID.
 */
abstract contract LotteryStorage is Initializable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    // struct PlayerData {
    //     // address wallet;
    //     uint48 ticketCount;
    //     uint48 winningTicketCount;
    // }

    address[] internal _players;
    // mapping(address => PlayerData) internal _playerData;

    uint256 private _ticketCount;
    // EnumerableSetUpgradeable.AddressSet internal _players; // address of all players
    mapping(address => uint256) internal _playerTicketCounts; // player address to ticket count

    uint256 private _winningTicketCount;
    uint256 private _winnerCount;
    mapping(address => uint256) internal _winnerTicketCounts; // winner address to winning ticket count

    function __LotteryStorage_init() internal onlyInitializing {
        __LotteryStorage_init_unchained();
    }

    function __LotteryStorage_init_unchained() internal onlyInitializing {
    }

    function ticketCount() public view returns (uint256) {
        return _ticketCount;
    }

    function playerCount() public view returns (uint256) {
        return _players.length;
    }

    function ticketCountOf(address owner) public view returns (uint256) {
        return _playerTicketCounts[owner];
        // return _playerData[owner].ticketCount;
    }

    function winningTicketCount() public view returns (uint256) {
        return _winningTicketCount;
    }

    function winnerCount() public view returns (uint256) {
        return _winnerCount;
    }

    function winningTicketCountOf(address owner) public view returns (uint256) {
        return _winnerTicketCounts[owner];
        // return _playerData[owner].winningTicketCount;
    }

    /**
     * @dev Mints a specific number of tickets for a player.
     */
    function _mintTickets(address player, uint256 count) internal {
        // _players.add(player);
        if (_playerTicketCounts[player] == 0)
            _players.push(player);
        _playerTicketCounts[player] += count;
        // _playerData[player].ticketCount += uint48(count); //TODO
        _ticketCount += count;
    }

    function _addPlayerWinningTicketCount(address player, uint256 count) internal {
        if (_winnerTicketCounts[player] == 0)
        // if (_playerData[player].winningTicketCount == 0)
            _winnerCount++;
        _winnerTicketCounts[player] += count;
        // _playerData[player].winningTicketCount += uint48(count); //TODO
        _winningTicketCount += count;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[41] private __gap; //TODO
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../utils/TwoStageOwnable.sol";

/**
 * Storage contract for lottery configs vars.
 */
abstract contract LotteryConfig is TwoStageOwnableUpgradeable {
    // configs
    string private _name; // name of the lottery
    uint256 private _endTime; // end time in unix timestamp in secs
    IERC20Upgradeable private _paymentToken; // the ERC20 token to get payment from
    uint256 private _pricePerTicket; // price of payment token per ticket
    uint256 private _maxTicketsPerPlayer; // max tickets each player can buy
    uint256[] private _tieredTickets; // 
    uint256[] private _tieredAwards; //
    address private _paymentTarget; // when lottery is closed, send the payments from winners to this address

    function __LotteryConfig_init(
        string memory name_,
        uint256 endTime_,
        IERC20Upgradeable paymentToken_,
        uint256 pricePerTicket_,
        uint256 maxTicketsPerPlayer_,
        uint256[] memory tieredTickets_,
        uint256[] memory tieredAwards_,
        address paymentTarget_,
        address owner_
    ) internal onlyInitializing {
        __TwoStageOwnable_init_unchained(owner_);
        __LotteryConfig_init_unchained(
            name_, endTime_, paymentToken_, pricePerTicket_, maxTicketsPerPlayer_,
            tieredTickets_, tieredAwards_, paymentTarget_, owner_
        );
    }

    function __LotteryConfig_init_unchained(
        string memory name_,
        uint256 endTime_,
        IERC20Upgradeable paymentToken_,
        uint256 pricePerTicket_,
        uint256 maxTicketsPerPlayer_,
        uint256[] memory tieredTickets_,
        uint256[] memory tieredAwards_,
        address paymentTarget_,
        address
    ) internal onlyInitializing {
        require(tieredTickets_.length > 0, "Must have at least one tier");
        require(tieredTickets_.length == tieredAwards_.length, "Ticket and award tiers must match");
        require(tieredTickets_[0] == 0, "First tier tickets must be zero");

        for (uint256 i=1; i<tieredTickets_.length; i++) {
            require(tieredTickets_[i] > tieredTickets_[i-1], "Incorrect tiered tickets config");
            require(tieredAwards_[i] > tieredAwards_[i-1], "Incorrect tiered awards config");
        }

        _name = name_;
        _endTime = endTime_;
        _paymentToken = paymentToken_;
        _pricePerTicket = pricePerTicket_;
        _maxTicketsPerPlayer = maxTicketsPerPlayer_;
        _tieredTickets = tieredTickets_;
        _tieredAwards = tieredAwards_;
        _paymentTarget = paymentTarget_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function endTime() public view returns (uint256) {
        return _endTime;
    }

    // function _setEndTime(uint256 endTime_) internal onlyOwner {
    //     _endTime = endTime_;
    // }

    function paymentToken() public view returns (IERC20Upgradeable) {
        return _paymentToken;
    }

    function pricePerTicket() public view returns (uint256) {
        return _pricePerTicket;
    }

    function maxTicketsPerPlayer() public view returns (uint256) {
        return _maxTicketsPerPlayer;
    }

    function setMaxTicketsPerPlayer(uint256 maxTicketsPerPlayer_) public onlyOwner {
        _maxTicketsPerPlayer = maxTicketsPerPlayer_;
    }

    function tieredTickets() public view returns (uint256[] memory) {
        return _tieredTickets;
    }

    function tieredAwards() public view returns (uint256[] memory) {
        return _tieredAwards;
    }

    function setPaymentTarget(address target) public onlyOwner {
        _paymentTarget = target;
    }

    function paymentTarget() public view returns (address) {
        return _paymentTarget;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[41] private __gap; //TODO
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract TwoStageOwnableUpgradeable is Initializable {
    address public nominatedOwner;
    address public owner;

    event OwnerChanged(address newOwner);
    event OwnerNominated(address nominatedOwner);

    function __TwoStageOwnable_init(address _owner) internal onlyInitializing {
        __TwoStageOwnable_init_unchained(_owner);
    }

    function __TwoStageOwnable_init_unchained(address _owner) internal onlyInitializing {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        owner = nominatedOwner;
        nominatedOwner = address(0);
        emit OwnerChanged(owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}