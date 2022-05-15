// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./../config/IConfig.sol";
import "./../utils/Caller.sol";
import "./../utils/SafeMath.sol";
import "./../utils/Random.sol";
import "./../utils/EnumerableSet.sol";
import "./INFTOpenBox.sol";

contract NFTOpenBox is INFTOpenBox, Caller {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    IConfig public config;
    mapping(address => address) private boxToken;
    mapping(address => address) private nftToken;
    mapping(address => EnumerableSet.UintSet) private tokenId;

    constructor(IConfig config_) {
        _setConfig(config_);
    }

    function setConfig(IConfig config_) external onlyCaller {
        _setConfig(config_);
    }

    function _setConfig(IConfig config_) private {
        config = config_;
    }

    function addToken(address boxToken_, uint256[] memory tokenId_)
        external
        override
        onlyCaller
    {
        EnumerableSet.UintSet storage _tokenId = tokenId[boxToken_];
        for (uint256 i = 0; i < tokenId_.length; i++) {
            _tokenId.addUintSet(tokenId_[i]);
        }
    }

    function removeToken(address boxToken_, uint256 tokenId_)
        external
        override
        onlyCaller
    {
        tokenId[boxToken_].removeUintSet(tokenId_);
    }

    function getTokenLength(address boxToken_)
        external
        view
        override
        returns (uint256)
    {
        return tokenId[boxToken_].lengthUintSet();
    }

    function getTokenByIndex(address boxToken_, uint256 index)
        external
        view
        returns (uint256)
    {
        return tokenId[boxToken_].atUintSet(index);
    }

    function getToken(address boxToken_)
        external
        view
        override
        returns (uint256[] memory)
    {
        return tokenId[boxToken_].valuesUintSet();
    }

    function openBox(address boxToken_) external override {
        IApproveProxy approveProxy = config.getApproveProxy();
        approveProxy.transferFromERC20(
            boxToken[boxToken_],
            msg.sender,
            config.getBurn(),
            1
        );
        uint256 index = Random.randomUint256().mod(
            tokenId[boxToken_].lengthUintSet(),
            "1100"
        );
        uint256 tokenId_ = tokenId[boxToken_].atUintSet(index);
        tokenId[boxToken_].removeUintSet(index);
        approveProxy.transferFromERC721(
            nftToken[boxToken_],
            config.getMintBoxNFT(),
            msg.sender,
            tokenId_
        );
        emit OpenBoxEvent(
            boxToken_, //盲盒代币合约地址
            nftToken[boxToken_], //NFT合约地址
            tokenId_, //NFT Token Id
            msg.sender, //当事人
            block.timestamp //开发时间
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./../proxy/IApproveProxy.sol";
import "./../list/IList.sol";
import "./../asset/IAsset.sol";

// TODO 子恒
// 实现Config.sol
interface IConfig {
    // 资产授权合约，必须非0地址，非法要报错
    function getApproveProxy() external view returns (IApproveProxy);

    // 铸造的BoxToken NFT托管地址，必须是普通地址，必须非0地址，非法要报错
    function getMintBoxNFT() external view returns (address);

    // 燃烧地址，必须是普通地址，防止ERC721等某些币的特殊支持燃烧机制，必须非0地址，非法要报错
    function getBurn() external view returns (address);

    // 白名单合约，必须非0地址，非法要报错
    function getList() external view returns (IList);

    // 用户资产托管合约，必须非0地址，非法要报错
    function getAsset() external view returns (IAsset);

    // NFT默认平台创作者，必须是普通地址，必须非0地址，非法要报错
    function getNFTCreator() external view returns (address);

    // 盲盒售卖费地址，必须是普通地址，必须非0地址，非法要报错
    function getBoxSaleFee() external view returns (address);

    // NFT合成费地址，必须是普通地址，必须非0地址，非法要报错
    function getNFTComposeFee() external view returns (address);

    // NFT交易市场-平台费地址(必须是普通地址，必须非0地址)、平台费率(0<= x < 100)、创作者费率(0<= x < 100)，非法要报错
    function getNFTTradePlatformFeeAndPlatformFeeRateAndCreatorFeeRate()
        external
        view
        returns (
            uint256,
            address,
            uint256
        );

    function getAddressByAddress(address key) external view returns (address);

    function getUint256ByAddress(address key) external view returns (uint256);

    function getAddressByUint256(uint256 key) external view returns (address);

    function getUint256ByUint256(uint256 key) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

// 调用者
contract Caller is Ownable {
    bool private init;
    mapping(address => bool) public caller;

    modifier onlyCaller() {
        require(caller[msg.sender], "1049");
        _;
    }

    function initOwner(address owner, address caller_) external {
        require(address(0) == Ownable.owner() && !init, "1102");
        init = true;
        _transferOwnership(owner);
        caller[caller_] = true;
    }

    function setCaller(address account, bool state) external onlyOwner {
        if (state) {
            caller[account] = state;
        } else {
            delete caller[account];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

// 数学安全库
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            require(c >= a, errorMessage);
            return c;
        }
    }

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

    function mul(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            if (a == 0) return 0;
            uint256 c = a * b;
            require(c / a == b, errorMessage);
            return c;
        }
    }

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

// 随机数
library Random {
    function randomUint256() internal returns (uint256) {
        return
            block.timestamp +
            block.number +
            block.gaslimit +
            gasleft() +
            uint256(uint160(msg.sender)) +
            msg.value +
            tx.gasprice;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity 0.8.1;

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
    function _addSet(Set storage set, bytes32 value) private returns (bool) {
        if (!_containsSet(set, value)) {
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
    function _removeSet(Set storage set, bytes32 value) private returns (bool) {
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
    function _containsSet(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _lengthSet(Set storage set) private view returns (uint256) {
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
    function _atSet(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
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
    function _valuesSet(Set storage set)
        private
        view
        returns (bytes32[] memory)
    {
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
    function addBytes32Set(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _addSet(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function removeBytes32Set(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _removeSet(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function containsBytes32Set(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _containsSet(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function lengthBytes32Set(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {
        return _lengthSet(set._inner);
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
    function atBytes32Set(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _atSet(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function valuesBytes32Set(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _valuesSet(set._inner);
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
    function addAddressSet(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _addSet(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function removeAddressSet(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _removeSet(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function containsAddressSet(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _containsSet(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function lengthAddressSet(AddressSet storage set)
        internal
        view
        returns (uint256)
    {
        return _lengthSet(set._inner);
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
    function atAddressSet(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_atSet(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function valuesAddressSet(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _valuesSet(set._inner);
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
    function addUintSet(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _addSet(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function removeUintSet(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _removeSet(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function containsUintSet(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _containsSet(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function lengthUintSet(UintSet storage set)
        internal
        view
        returns (uint256)
    {
        return _lengthSet(set._inner);
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
    function atUintSet(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_atSet(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function valuesUintSet(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _valuesSet(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface INFTOpenBox {
    // 开盲盒事件
    event OpenBoxEvent(
        address boxToken, //盲盒代币合约地址
        address nftToken, //NFT合约地址
        uint256 tokenId, //NFT Token Id
        address taker, //当事人
        uint256 ts //开发时间
    );

    function addToken(address boxToken, uint256[] memory tokenId) external;

    function removeToken(address boxToken, uint256 tokenId) external;

    function getTokenLength(address boxToken) external view returns (uint256);

    function getToken(address boxToken)
        external
        view
        returns (uint256[] memory);

    function openBox(address boxToken) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

// 用户授权
// 因为有的合约未实现销毁接口，故不在这里实现代理销毁
interface IApproveProxy {
    function transferFromERC20(
        address token,
        address from,
        address to,
        uint256 amount
    ) external;

    function transferFromERC721(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IList {
    function getStateV1(address account) external view returns (bool);

    function getStateV2(uint16 id, address account)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IAsset {
    function claimMainOrERC20(
        address token,
        address to,
        uint256 amount
    ) external;

    function claimERC721(
        address token,
        address to,
        uint256 tokenId
    ) external;
}

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