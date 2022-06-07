// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../utils/Caller.sol";
import "./../utils/Fallback.sol";
import "./../utils/SafeMath.sol";
import "./../utils/EnumerableSet.sol";
import "./../config/IConfig.sol";
import "./../utils/TransferV1.sol";
import "./INFTPrimaryExchange.sol";

// 盲盒NFT公售
contract NFTPrimaryExchange is INFTPrimaryExchange, Caller, Fallback {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    IConfig public config;
    EnumerableSet.AddressSet private orderToken;
    mapping(address => OrderInfo) private order;
    mapping(address => EnumerableSet.UintSet) private orderTokenIds;
    mapping(address => mapping(address => uint256)) public takeAmount;

    constructor(IConfig config_) {
        _setConfig(config_);
    }

    function setConfig(IConfig config_) external onlyCaller {
        _setConfig(config_);
    }

    function _setConfig(IConfig config_) private {
        config = config_;
    }

    function getOrderLength() external view override returns (uint256) {
        return orderToken.lengthAddressSet();
    }

    function getOrderToken(uint256 index)
        external
        view
        override
        returns (address)
    {
        return orderToken.atAddressSet(index);
    }

    function getOrderTokenIdLength(address token)
        external
        view
        override
        returns (uint256)
    {
        return orderTokenIds[token].lengthUintSet();
    }

    function getOrderTokenId(address token, uint256 index)
        external
        view
        override
        returns (uint256)
    {
        return orderTokenIds[token].atUintSet(index);
    }

    function getOrder(address token)
        external
        view
        override
        returns (OrderInfo memory)
    {
        OrderInfo memory info = order[token];
        info.stockAmount = orderTokenIds[token].lengthUintSet();
        return info;
    }

    // 盲盒NFT普通公售
    function make(
        address token, //盲盒NFT合约
        uint256 maxTakeAmount, //单地址购买上线数量
        uint256 totalAmount, //盲盒NFT总售卖数量
        uint256[] memory tokenIds, //盲盒NFT TokenId
        address quoteToken, //报价代币合约
        uint256 quotePrice, //报价代币价格
        uint256 startBlock, //生效开始区块
        uint256 stopBlock //生效结束区块
    ) external override onlyCaller {
        require(startBlock < stopBlock && block.number < stopBlock, "1093");
        orderToken.addAddressSet(token);
        order[token] = OrderInfo(
            0,
            token,
            maxTakeAmount,
            0,
            totalAmount,
            quoteToken,
            quotePrice,
            startBlock,
            stopBlock
        );
        EnumerableSet.UintSet storage _tokenIds = orderTokenIds[token];
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _tokenIds.addUintSet(tokenIds[i]);
        }
        emit MakeEvent(
            0, //白名单业务
            token, //盲盒NFT合约
            tokenIds, //
            quoteToken, //报价代币合约
            quotePrice, //报价代币价格
            startBlock, //生效开始区块
            stopBlock //生效结束区块
        );
    }

    // 盲盒NFT普通购买
    function takeV1(address token, uint256 amount) external payable override {
        OrderInfo memory orderInfo = order[token];
        require(
            orderInfo.startBlock < block.number &&
                block.number < orderInfo.stopBlock,
            "1192"
        );
        require(
            0 < amount && amount <= orderTokenIds[token].lengthUintSet(),
            "1129"
        );
        uint256[] memory tokenIds = new uint256[](amount);
        EnumerableSet.UintSet storage _tokenIds = orderTokenIds[token];
        for (uint256 i = 0; i < amount; i++) {
            tokenIds[i] = _tokenIds.atUintSet(i);
        }
        _take(token, tokenIds);
    }

    function takeV2(address token, uint256[] memory tokenIds)
        external
        payable
        override
    {
        _take(token, tokenIds);
    }

    function _take(address token, uint256[] memory tokenIds) private {
        OrderInfo storage orderInfo = order[token];
        require(
            orderInfo.startBlock < block.number &&
                block.number < orderInfo.stopBlock,
            "1192"
        );

        require(
            0 < tokenIds.length &&
                tokenIds.length <= orderTokenIds[token].lengthUintSet(),
            "1129"
        );
        takeAmount[msg.sender][token] = takeAmount[msg.sender][token].add(
            tokenIds.length,
            "1111"
        );
        require(
            takeAmount[msg.sender][token] < orderInfo.maxTakeAmount,
            "1104"
        );
        IApproveProxy approveProxy = config.getApproveProxy();
        TransferV1.transferFromFlush(
            approveProxy,
            orderInfo.quoteToken,
            msg.sender,
            config.getBoxSaleFee(),
            tokenIds.length.mul(orderInfo.quotePrice, "1178"),
            "1113",
            "1114"
        );
        EnumerableSet.UintSet storage _tokenIds = orderTokenIds[token];
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(_tokenIds.removeUintSet(tokenIds[i]), "1166");
            approveProxy.transferFromERC721(
                token,
                config.getMintBoxNFT(),
                msg.sender,
                tokenIds[i]
            );
        }
        emit TakeEvent(
            orderInfo.list,
            orderInfo.token,
            tokenIds,
            orderInfo.quoteToken,
            tokenIds.length.mul(orderInfo.quotePrice, "1163"),
            msg.sender,
            block.timestamp
        );
    }

    // 盲盒NFT普通取消售卖
    function cancel(address token) external override onlyCaller {
        orderToken.removeAddressSet(token);
        delete order[token];
        delete orderTokenIds[token];
    }

    // 盲盒NFT普通取消售卖
    function cancel(address token, uint256 tokenId)
        external
        override
        onlyCaller
    {
        orderTokenIds[token].removeUintSet(tokenId);
    }
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

contract Fallback {
    fallback() external payable {}

    receive() external payable {}
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

import "./../proxy/IApproveProxy.sol";
import "./../list/IList.sol";
import "./../asset/IAsset.sol";

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

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./../proxy/IApproveProxy.sol";

// 安全转账库
library TransferV1 {
    using SafeERC20 for IERC20;

    function transfer_(
        address token,
        address to,
        uint256 amount
    ) internal {
        if (0 < amount) {
            if (address(0) == token) {
                (bool success, ) = to.call{value: amount}(new bytes(0));
                require(success, "1052");
            } else {
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }

    function transferFromStandard(
        IApproveProxy approveProxy,
        address token,
        address from,
        address to,
        uint256 amount,
        string memory errorMessage0,
        string memory errorMessage1
    ) internal {
        if (0 < amount) {
            if (address(0) == token) {
                require(amount <= msg.value, errorMessage0);
                (bool success, ) = to.call{value: amount}(new bytes(0));
                require(success, errorMessage1);
            } else {
                approveProxy.transferFromERC20(token, from, to, amount);
            }
        }
    }

    function transferFromFlush(
        IApproveProxy approveProxy,
        address token,
        address from,
        address to,
        uint256 amount,
        string memory errorMessage0,
        string memory errorMessage1
    ) internal {
        if (address(0) == token) {
            require(amount <= msg.value, errorMessage0);
            if (0 < msg.value) {
                (bool success, ) = to.call{value: msg.value}(new bytes(0));
                require(success, errorMessage1);
            }
        } else {
            approveProxy.transferFromERC20(token, from, to, amount);
            if (0 < msg.value) {
                (bool success, ) = to.call{value: msg.value}(new bytes(0));
                require(success, errorMessage1);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

// NFT公售
interface INFTPrimaryExchange {
    event MakeEvent(
        uint16 list, //白名单业务
        address indexed token, //盲盒NFT合约地址
        uint256[] totalIds,
        address indexed quoteToken, //报价代币合约
        uint256 quotePrice, //报价代币价格
        uint256 startBlock, //生效开始区块
        uint256 stopBlock //生效结束区块
    );

    // 成交事件
    event TakeEvent(
        uint16 list, //白名单业务
        address indexed token, //盲盒NFT合约地址
        uint256[] tokenId, //盲盒NFT TokenId
        address indexed quoteToken, //报价代币合约地址
        uint256 quoteAmount, //报价代币总数量
        address indexed taker, //购买人
        uint256 ts //成交时间
    );

    // 取消事件
    event CancelEvent(
        uint16 list, //白名单业务
        address indexed token, //盲盒NFT合约地址
        uint256 tokenId, //盲盒NFT TokenId
        uint256 ts //取消时间
    );

    //订单信息
    struct OrderInfo {
        uint16 list; //白名单业务
        address token; //盲盒NFT合约地址
        uint256 maxTakeAmount; //单地址购买上限数量
        uint256 stockAmount; //盲盒NFT总库存数量
        uint256 totalAmount; //盲盒NFT总售卖数量
        address quoteToken; //报价代币合约地址
        uint256 quotePrice; //报价代币价格
        uint256 startBlock; //生效开始区块
        uint256 stopBlock; //生效结束区块
    }

    function getOrderLength() external view returns (uint256);

    function getOrderToken(uint256 index) external view returns (address);

    function getOrderTokenIdLength(
        address token //盲盒NFT合约
    ) external view returns (uint256);

    function getOrderTokenId(
        address token, //盲盒NFT合约
        uint256 index
    ) external view returns (uint256);

    // 订单信息
    function getOrder(
        address token //盲盒NFT合约
    ) external view returns (OrderInfo memory);

    // 挂单
    function make(
        address token, //盲盒NFT合约
        uint256 maxTakeAmount, //单地址购买上线数量
        uint256 totalAmount, //盲盒NFT总售卖数量
        uint256[] memory tokenIds, //盲盒NFT TokenId
        address quoteToken, //报价代币合约
        uint256 quotePrice, //报价代币价格
        uint256 startBlock, //生效开始区块
        uint256 stopBlock //生效结束区块
    ) external;

    // 吃单
    function takeV1(
        address token, //盲盒NFT合约
        uint256 amount //吃单数量
    ) external payable;

    // 吃单
    function takeV2(
        address token, //盲盒NFT合约
        uint256[] memory tokenIds //吃单
    ) external payable;

    // 撤单
    function cancel(
        address token //盲盒NFT合约地址
    ) external;

    // 撤单
    function cancel(
        address token, //盲盒NFT合约地址
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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