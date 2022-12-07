//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ITrading.sol";
import "./IERCSimplified.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Trading is ITrading, Ownable {
  using TradingLibrary for TradingLibrary.TokenSet;
  using EnumerableSet for EnumerableSet.AddressSet;

  bytes4 public constant IERC721_INTEFACEID = 0x80ac58cd;
  address payable public immutable FEE_POOL;
  uint256 public immutable FEE;

  //EnumerableSet
  EnumerableSet.AddressSet private tokens;

  mapping(bytes32 => Offer) private nonceOffers;
  mapping(address => bytes32[]) private walletOffers;
  mapping(bytes32 => mapping(address => bool)) private offersSigned;

  receive() external payable {}

  fallback() external payable {}

  constructor(address payable pool, uint256 fee) {
    FEE_POOL = pool;
    FEE = fee;
  }

  function getNonce(
    address left,
    address right,
    TradingLibrary.TokenSet[] memory tokensLeft,
    TradingLibrary.TokenSet[] memory tokensRight,
    uint256 seed
  ) external pure returns (bytes32) {
    address[] memory tokensAddresses = new address[](
      tokensLeft.length + tokensRight.length
    );
    uint256[] memory tokensProps = new uint256[](
      tokensLeft.length + tokensRight.length
    );
    for (uint256 i = 0; i < tokensLeft.length; i++) {
      tokensAddresses[i] = tokensLeft[i].getAddress();
      tokensProps[i] = tokensLeft[i].getProp();
    }
    for (uint256 i = 0; i < tokensRight.length; i++) {
      tokensAddresses[i + tokensLeft.length] = tokensRight[i].getAddress();
      tokensProps[i + tokensLeft.length] = tokensRight[i].getProp();
    }
    return
      keccak256(
        abi.encodePacked(left, right, tokensAddresses, tokensProps, seed)
      );
  }

  function addERC(address token) external onlyOwner returns (bool) {
    require(
      token != address(0) && (_isValidERC721(token) || _isValidERC20(token)),
      "Trading: Invalid address"
    );
    emit AddERC(token, msg.sender);
    require(tokens.add(token), "Trading: ERC already added");
    return true;
  }

  function _isValidERC721(address token) private returns (bool) {
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSignature("supportsInterface(bytes4)", IERC721_INTEFACEID)
    );
    return success && abi.decode(data, (bool));
  }

  function _isValidERC20(address token) private returns (bool) {
    (bool success, ) = token.call(
      abi.encodeWithSignature("balanceOf(address)", address(this))
    );

    return success;
  }

  function removeERC(address token) external onlyOwner returns (bool) {
    emit RemoveERC(token, msg.sender);
    require(tokens.remove(token), "Trading: ERC missing");
    return true;
  }

  function getERCAllowed(address erc) external view returns (bool) {
    return tokens.contains(erc);
  }

  function getERCAllowedAll() external view returns (address[] memory) {
    return tokens.values();
  }

  function proceedOffer(
    bytes32 nonce_,
    address left,
    address right,
    TradingLibrary.TokenSet[] memory tokensLeft,
    TradingLibrary.TokenSet[] memory tokensRight
  ) external payable returns (bytes32) {
    Offer storage offer = nonceOffers[nonce_];
    require(msg.value == FEE, "Trading: trading fee should be sent");
    require(
      msg.sender == left || msg.sender == right,
      "Trading: Invalid sender"
    );
    if (offer.state == OfferState.None) {
      require(_isNewOfferValid(left, right), "Trading: Invalid new offer");
      offer.left = left;
      offer.right = right;
      for (uint256 i = 0; i < tokensLeft.length; i++) {
        require(
          tokens.contains(tokensLeft[i].getAddress()),
          "Trading: Invalid token"
        );
        offer.tokensLeft.push(tokensLeft[i]);
      }
      for (uint256 i = 0; i < tokensRight.length; i++) {
        require(
          tokens.contains(tokensRight[i].getAddress()),
          "Trading: Invalid token"
        );
        offer.tokensRight.push(tokensRight[i]);
      }
      offer.state = OfferState.Created;
      walletOffers[left].push(nonce_);
      walletOffers[right].push(nonce_);
      emit OfferCreated(nonce_, left, right, tokensLeft, tokensRight);
    } else if (offer.state == OfferState.Created) {
      require(
        _isExistingOfferValid(nonce_, left, right, tokensLeft, tokensRight),
        "Trading: Invalid offer"
      );
    } else {
      revert("Trading: Offer either finalized or canceled");
    }

    require(!offersSigned[nonce_][msg.sender], "Trading: Offer already signed");
    offersSigned[nonce_][msg.sender] = true;
    if (offersSigned[nonce_][left] == offersSigned[nonce_][right] == true) {
      offer.finalizedBlock = block.number;
      offer.state = OfferState.Finalized;
    }
    if (msg.sender == left) {
      for (uint256 i = 0; i < tokensLeft.length; i++) {
        IERCSimplified(tokensLeft[i].getAddress()).transferFrom(
          left,
          address(this),
          tokensLeft[i].getProp()
        );
      }
    } else {
      for (uint256 i = 0; i < tokensRight.length; i++) {
        IERCSimplified(tokensRight[i].getAddress()).transferFrom(
          right,
          address(this),
          tokensRight[i].getProp()
        );
      }
    }
    emit OfferSigned(nonce_, msg.sender);

    if (offersSigned[nonce_][left] == offersSigned[nonce_][right] == true) {
      emit OfferFinalized(nonce_);
      for (uint256 i = 0; i < tokensLeft.length; i++) {
        if (!_isValidERC721(tokensLeft[i].getAddress())) {
          IERC20Simplified(tokensLeft[i].getAddress()).transfer(
            right,
            tokensLeft[i].getProp()
          );
        } else {
          IERCSimplified(tokensLeft[i].getAddress()).transferFrom(
            address(this),
            right,
            tokensLeft[i].getProp()
          );
        }
      }
      for (uint256 i = 0; i < tokensRight.length; i++) {
        if (!_isValidERC721(tokensRight[i].getAddress())) {
          IERC20Simplified(tokensRight[i].getAddress()).transfer(
            left,
            tokensRight[i].getProp()
          );
        } else {
          IERCSimplified(tokensRight[i].getAddress()).transferFrom(
            address(this),
            left,
            tokensRight[i].getProp()
          );
        }
      }
      FEE_POOL.transfer(FEE * 2);
    }
    return nonce_;
  }

  function _isNewOfferValid(address left, address right)
    internal
    view
    returns (bool)
  {
    if (
      left == address(this) ||
      right == address(this) ||
      left == address(0) ||
      right == address(0) ||
      left == right
    ) return false;
    return true;
  }

  function _isExistingOfferValid(
    bytes32 nonce_,
    address left,
    address right,
    TradingLibrary.TokenSet[] memory tokensLeft,
    TradingLibrary.TokenSet[] memory tokensRight
  ) internal view returns (bool) {
    Offer memory offer = nonceOffers[nonce_];
    if (offer.left != left || offer.right != right) return false;
    for (uint256 i = 0; i < offer.tokensLeft.length; i++) {
      if (offer.tokensLeft[i].noteq(tokensLeft[i])) return false;
    }
    for (uint256 i = 0; i < offer.tokensRight.length; i++) {
      if (offer.tokensRight[i].noteq(tokensRight[i])) return false;
    }
    return true;
  }

  function cancelOffer(bytes32 nonce_) external returns (bytes32) {
    Offer storage offer = nonceOffers[nonce_];
    require(offer.state == OfferState.Created, "Trading: Invalid state");
    require(
      offer.left == msg.sender || offer.right == msg.sender,
      "Trading: Invalid sender"
    );

    offer.finalizedBlock = block.number;
    offer.state = OfferState.Canceled;

    if (offersSigned[nonce_][offer.left]) {
      payable(offer.left).transfer(FEE);
      for (uint256 i = 0; i < offer.tokensLeft.length; i++) {
        if (!_isValidERC721(offer.tokensLeft[i].getAddress())) {
          IERC20Simplified(offer.tokensLeft[i].getAddress()).transfer(
            offer.left,
            offer.tokensLeft[i].getProp()
          );
        } else {
          IERCSimplified(offer.tokensLeft[i].getAddress()).transferFrom(
            address(this),
            offer.left,
            offer.tokensLeft[i].getProp()
          );
        }
      }
    }
    if (offersSigned[nonce_][offer.right]) {
      payable(offer.right).transfer(FEE);
      for (uint256 i = 0; i < offer.tokensRight.length; i++) {
        if (!_isValidERC721(offer.tokensRight[i].getAddress())) {
          IERC20Simplified(offer.tokensRight[i].getAddress()).transfer(
            offer.right,
            offer.tokensRight[i].getProp()
          );
        } else {
          IERCSimplified(offer.tokensRight[i].getAddress()).transferFrom(
            address(this),
            offer.right,
            offer.tokensRight[i].getProp()
          );
        }
      }
    }
    emit OfferCancelled(nonce_);
    return nonce_;
  }

  function getWalletOffers(address wallet)
    external
    view
    returns (bytes32[] memory)
  {
    return walletOffers[wallet];
  }

  function getOffer(bytes32 nonce_) external view returns (Offer memory) {
    return nonceOffers[nonce_];
  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./TradingLibrary.sol";

interface ITrading {
  enum OfferState {
    None,
    Created,
    Finalized,
    Canceled
  }
  struct Offer {
    address left;
    address right;
    TradingLibrary.TokenSet[] tokensLeft;
    TradingLibrary.TokenSet[] tokensRight;
    uint256 finalizedBlock;
    OfferState state;
  }
  event AddERC(address erc, address setter);
  event RemoveERC(address erc, address setter);

  event OfferCreated(
    bytes32 nonce,
    address left,
    address right,
    TradingLibrary.TokenSet[] tokensLeft,
    TradingLibrary.TokenSet[] tokensRight
  );
  event OfferSigned(bytes32 nonce, address signer);
  event OfferFinalized(bytes32 nonce);
  event OfferCancelled(bytes32 nonce);

  function getNonce(
    address left,
    address right,
    TradingLibrary.TokenSet[] memory tokensLeft,
    TradingLibrary.TokenSet[] memory tokensRight,
    uint256 seed
  ) external pure returns (bytes32);

  function addERC(address erc721) external returns (bool);

  function removeERC(address erc20) external returns (bool);

  function getERCAllowed(address) external view returns (bool);

  function getERCAllowedAll() external view returns (address[] memory);

  function proceedOffer(
    bytes32 nonce,
    address left,
    address right,
    TradingLibrary.TokenSet[] memory tokensLeft,
    TradingLibrary.TokenSet[] memory tokensRight
  ) external payable returns (bytes32);

  function cancelOffer(bytes32 nonce_) external returns (bytes32);

  function getWalletOffers(address) external view returns (bytes32[] memory);

  function getOffer(bytes32) external view returns (Offer memory);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERCSimplified {
  function transferFrom(
    address from,
    address to,
    uint256 prop
  ) external;
}

interface IERC20Simplified is IERCSimplified {
  function transfer(address recipient, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/structs/EnumerableSet.sol)

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library TradingLibrary {
    struct ItemSet {
        bytes32[] _values;
    }

    function _eq(ItemSet memory _lhs, ItemSet memory _rhs)
        internal
        pure
        returns (bool)
    {
        if (_lhs._values.length != _rhs._values.length) return false;
        for (uint256 i = 0; i < _lhs._values.length; i++) {
            if (_lhs._values[i] != _rhs._values[i]) return false;
        }
        return true;
    }

    function _noteq(ItemSet memory _lhs, ItemSet memory _rhs)
        internal
        pure
        returns (bool)
    {
        return !_eq(_lhs, _rhs);
    }

    struct TokenSet {
        ItemSet _inner;
    }

    function eq(TokenSet memory lhs, TokenSet memory rhs)
        internal
        pure
        returns (bool)
    {
        return _eq(lhs._inner, rhs._inner);
    }

    function noteq(TokenSet memory lhs, TokenSet memory rhs)
        internal
        pure
        returns (bool)
    {
        return _noteq(lhs._inner, rhs._inner);
    }

    function tokenSetConstructor(address tokenAddress, uint256 tokenValue)
        external
        pure
        returns (TokenSet memory)
    {
        bytes32[] memory values = new bytes32[](2);
        values[0] = bytes32(uint256(uint160(tokenAddress)));
        values[1] = bytes32(tokenValue);
        return TokenSet(ItemSet(values));
    }

    function getAddress(TokenSet memory lhs) internal pure returns (address) {
        return address(uint160(uint256(lhs._inner._values[0])));
    }

    function getProp(TokenSet memory lhs) internal pure returns (uint256) {
        return uint256(lhs._inner._values[1]);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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