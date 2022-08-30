// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import './libraries/GoosebumpsLibrary.sol';
import './libraries/OrderedEnumerableMap.sol';
import './interfaces/IGoosebumpsRouterPairs.sol';
import './utils/Ownable.sol';

contract GoosebumpsRouterPairs is IGoosebumpsRouterPairs, Ownable {
    using OrderedEnumerableMap for OrderedEnumerableMap.AddressToBytes32Map;

    address public override feeAggregator;

    OrderedEnumerableMap.AddressToBytes32Map private factories;
    mapping(address => uint256) public lpFees;

    event LogSetFeeAggregator(address indexed aggregator);
    event LogSetFactory(address indexed factory, bytes32 initHash, bool newFactory);
    event LogRemoveFactory(address indexed factory);
    event LogSetLPFee(address indexed factory, uint256 lpFee);

    modifier validFactory(address factory) {
        require(hasFactory(factory), 'GoosebumpsRouterPairs: INVALID_FACTORY');
        _;
    }

    constructor(address _aggregator) {
        require(_aggregator != address(0), "GoosebumpsRouterPairs: ZERO_ADDRESS");
        feeAggregator = _aggregator;
    }

    // **** LIBRARY FUNCTIONS ****
    function pairFor(address factory, address tokenA, address tokenB) external view override returns (address pair) 
    {
        return GoosebumpsLibrary.pairFor(factory, getInitHash(factory), tokenA, tokenB);
    }
    function getReserves(address factory, address tokenA, address tokenB) 
        external view override returns (uint256 reserveA, uint256 reserveB)
    {
        return GoosebumpsLibrary.getReserves(factory, getInitHash(factory), tokenA, tokenB);
    }
    function getAmountOut(address factory, uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external view override returns (uint256 amountOut, uint256 fee)
    {
        (fee, amountIn) = IFeeAggregator(feeAggregator).calculateFeeAndAmountOut(amountIn);
        amountOut = GoosebumpsLibrary.getAmountOut(amountIn, reserveIn, reserveOut, getLPFee(factory));
    }
    function getAmountOut(
        address factory,
        bool feePayed,
        uint256 amountIn, 
        uint256 reserveIn,
        uint256 reserveOut
    ) external view override returns (uint256 amountOut, uint256 fee)
    {
        if (!feePayed) {
            (fee, amountIn) = IFeeAggregator(feeAggregator).calculateFeeAndAmountOut(amountIn);
        }
        amountOut = GoosebumpsLibrary.getAmountOut(amountIn, reserveIn, reserveOut, getLPFee(factory));
    }
    /**
     * Note totalAmountIn = amountIn + fee
     */
    function getAmountIn(address factory, uint256 amountOut, uint256 reserveIn, uint256 reserveOut)
        external view override returns (uint256 amountIn, uint256 fee) 
    {
        amountIn = GoosebumpsLibrary.getAmountIn(amountOut, reserveIn, reserveOut, getLPFee(factory));
        (fee,) = IFeeAggregator(feeAggregator).calculateFeeAndAmountIn(amountIn);
    }
    /**
     * Note totalAmountIn = amountIn + fee
     */
    function getAmountIn(
        address factory,
        bool feePayed,
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view override returns (uint256 amountIn, uint256 fee) 
    {
        amountIn = GoosebumpsLibrary.getAmountIn(amountOut, reserveIn, reserveOut, getLPFee(factory));
        if (!feePayed) {
            (fee,) = IFeeAggregator(feeAggregator).calculateFeeAndAmountIn(amountIn);
        }
    }
    function getAmountsOut(address[] calldata _factories, uint256 amountIn, address[] calldata path)
        external view override returns (uint256[] memory amounts, uint256 feeAmount) 
    {
        (bytes32[] memory hashes, uint256[] memory fees) = getInitHashesAndFees(_factories);
        return GoosebumpsLibrary.getAmountsOut(feeAggregator, _factories, hashes, amountIn, path, fees);
    }
    function getAmountsIn(address[] calldata _factories, uint256 amountOut, address[] calldata path)
        external view override returns (uint256[] memory amounts, uint256 feeAmount) 
    {
        (bytes32[] memory hashes, uint256[] memory fees) = getInitHashesAndFees(_factories);
        return GoosebumpsLibrary.getAmountsIn(feeAggregator, _factories, hashes, amountOut, path, fees);
    }

    function getInitHashesAndFees(address[] memory _factories) internal view 
        returns (bytes32[] memory, uint256[] memory) 
    {
        bytes32[] memory hashes = new bytes32[](_factories.length);
        uint256[] memory fees = new uint256[](_factories.length);
        for(uint256 idx = 0; idx < _factories.length; idx++) {
            hashes[idx] = getInitHash(_factories[idx]);
            fees[idx] = getLPFee(_factories[idx]);
        }
        return (hashes, fees);
    }
    function getInitHash(address factory) validFactory(factory) internal view returns (bytes32) 
    {
        return factories.get(factory);
    }
    function getLPFee(address factory) validFactory(factory) internal view returns (uint256) 
    {
        return lpFees[factory];
    }
    
    function setFeeAggregator(address aggregator) external override onlyMultiSig {
        require(aggregator != address(0), "GoosebumpsRouterPairs: ZERO_ADDRESS");
        require(aggregator != feeAggregator, "GoosebumpsRouterPairs: SAME_ADDRESS");
        feeAggregator = aggregator;

        emit LogSetFeeAggregator(aggregator);
    }
    function setFactory(address _factory, bytes32 initHash) external override onlyMultiSig {
        require(_factory != address(0), "GoosebumpsRouterPairs: ZERO_ADDRESS");
        // if new Factory, return true, if only set `initHash`, return false.
        bool newFactory = factories.set(_factory, initHash);

        emit LogSetFactory(_factory, initHash, newFactory);
    }
    function removeFactory(address _factory) external override onlyMultiSig {
        require(_factory != address(0), "GoosebumpsRouterPairs: ZERO_ADDRESS");
        require(factories.remove(_factory), "GoosebumpsRouterPairs: NOT_FOUND");

        emit LogRemoveFactory(_factory);
    }
    function hasFactory(address _factory) public override view returns (bool) {
        return factories.contains(_factory);
    }
    function allFactories() external override view returns (address[] memory) {
        address[] memory _allFactories = new address[](factories.length());
        for(uint256 idx = 0; idx < factories.length(); idx++) {
            (address factory,) = factories.at(idx);
            _allFactories[idx] = factory;
        }
        return _allFactories;
    }
    function setLPFee(address _factory, uint256 _lpFee) external override onlyMultiSig {
        require(_factory != address(0), "GoosebumpsRouterPairs: ZERO_ADDRESS");
        require(lpFees[_factory] != _lpFee, "GoosebumpsRouterPairs: SAME_VALUE");
        lpFees[_factory] = _lpFee;

        emit LogSetLPFee(_factory, _lpFee);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import '../interfaces/IGoosebumpsPair.sol';
import '../interfaces/IFeeAggregator.sol';

library GoosebumpsLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'GoosebumpsLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'GoosebumpsLibrary: ZERO_ADDRESS');
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) internal pure returns (uint256 amountB) {
        require(amountA > 0, 'GoosebumpsLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'GoosebumpsLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA * reserveB / reserveA;
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, bytes32 initPairHash, address tokenA, address tokenB) 
        internal pure returns (address pair) 
    {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint256(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                initPairHash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, bytes32 initPairHash, address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1,) = IGoosebumpsPair(pairFor(factory, initPairHash, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut, uint256 lpFee) 
        internal pure returns (uint256 amountOut)
    {
        require(amountIn > 0, 'GoosebumpsLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'GoosebumpsLibrary: INSUFFICIENT_LIQUIDITY');
        amountIn = amountIn * (10000 - lpFee);
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn * 10000 + amountIn;
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut, uint256 lpFee) 
        internal pure returns (uint256 amountIn)
    {
        require(amountOut > 0, 'GoosebumpsLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'GoosebumpsLibrary: INSUFFICIENT_LIQUIDITY');
        uint256 numerator = reserveIn * amountOut * 10000;
        uint256 denominator = (reserveOut - amountOut) * (10000 - lpFee);
        amountIn = numerator / denominator + 1;
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address feeAggregator,
        address[] memory factories,
        bytes32[] memory initPairHashes,
        uint256 amountIn,
        address[] memory path,
        uint256[] memory lpFees
    ) internal view returns (uint256[] memory amounts, uint256 feeAmount) {
        require(path.length >= 2, 'GoosebumpsLibrary: INVALID_PATH');
        amounts = new uint256[](path.length);
        (feeAmount, amounts[0]) = IFeeAggregator(feeAggregator).calculateFeeAndAmountOut(amountIn);
        for (uint256 i = 0; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = 
                getReserves(factories[i], initPairHashes[i], path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, lpFees[i]);
        }
    }

    /**
     * Note performs chained getAmountIn calculations on any number of pairs.
     *      totalAmountIn = amounts[0] + feeAmount
     */
    function getAmountsIn(
        address feeAggregator,
        address[] memory factories,
        bytes32[] memory initPairHashes,
        uint256 amountOut,
        address[] memory path,
        uint256[] memory lpFees
    ) internal view returns (uint256[] memory amounts, uint256 feeAmount) {
        require(path.length >= 2, 'GoosebumpsLibrary: INVALID_PATH');
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = 
                getReserves(factories[i - 1], initPairHashes[i - 1], path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, lpFees[i - 1]);
        }
        (feeAmount,) = IFeeAggregator(feeAggregator).calculateFeeAndAmountIn(amounts[0]);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

/**
 * Extension method on the OpenZeppeling EnumerableMap type
 * 
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using OrderedEnumerableMap for Map.AddressToBytes32Map;
 *
 *     // Declare a set state variable
 *     Map.AddressToBytes32Map private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`AddressToBytes32Map`) are
 * supported.
 */
library OrderedEnumerableMap {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct MapExtensions {
        // Storage of map keys and values
        MapEntry[] _entries;

        // Position of the entry defined by a key in the `entries` array, plus 1
        // because index 0 means a key is not in the map.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(MapExtensions storage map, bytes32 key, bytes32 value) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            // The entry is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(MapExtensions storage map, bytes32 key) private returns (bool) {
        // We read and store the key's index to prevent multiple reads from the same storage slot
        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)
            uint256 toDeleteIndex = keyIndex - 1;
            for (uint256 i = toDeleteIndex; i < map._entries.length-1; i++) {
                map._indexes[map._entries[i + 1]._key] = i;
                map._entries[i] = map._entries[i + 1];
            }
            delete map._entries[map._entries.length - 1];
            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(MapExtensions storage map, bytes32 key) private view returns (bool) {
        return map._indexes[key] != 0;
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(MapExtensions storage map) private view returns (uint256) {
        return map._entries.length;
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(MapExtensions storage map, uint256 index) private view returns (bytes32, bytes32) {
        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(MapExtensions storage map, bytes32 key) private view returns (bytes32) {
        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    // AddressToBytes32Map

    struct AddressToBytes32Map {
        MapExtensions _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(AddressToBytes32Map storage map, address key, bytes32 value) internal returns (bool) {
        return _set(map._inner, bytes32(uint256(uint160(key))), value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToBytes32Map storage map, address key) internal returns (bool) {
        return _remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToBytes32Map storage map, address key) internal view returns (bool) {
        return _contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToBytes32Map storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressToBytes32Map storage map, uint256 index) internal view returns (address, bytes32) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (address(uint160(uint256(key))), value);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToBytes32Map storage map, address key) internal view returns (bytes32) {
        return _get(map._inner, bytes32(uint256(uint160(key))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IGoosebumpsRouterPairs {
    function feeAggregator() external returns (address);

    function pairFor(address factory, address tokenA, address tokenB) external view returns (address pair);
    function getReserves(address factory, address tokenA, address tokenB) 
        external view returns (uint256 reserveA, uint256 reserveB);
    function getAmountOut(address factory, uint256 amountIn, 
        uint256 reserveIn, uint256 reserveOut) 
        external view returns (uint256 amountOut, uint256 fee);
    function getAmountOut(address factory, bool feePayed, uint256 amountIn, 
        uint256 reserveIn, uint256 reserveOut)
        external view returns (uint256 amountOut, uint256 fee);
    function getAmountIn(address factory, uint256 amountOut, 
        uint256 reserveIn, uint256 reserveOut) 
        external view returns (uint256 amountIn, uint256 fee);
    function getAmountIn(address factory, bool feePayed, uint256 amountOut, 
        uint256 reserveIn, uint256 reserveOut) 
        external view returns (uint256 amountIn, uint256 fee);
    function getAmountsOut(address[] calldata _factories, uint256 amountIn, address[] calldata path) 
        external view returns (uint256[] memory amounts, uint256 feePayed);
    function getAmountsIn(address[] calldata _factories, uint256 amountOut, address[] calldata path) 
        external view returns (uint256[] memory amounts, uint256 feePayed);

    function setFeeAggregator(address aggregator) external;
    function setFactory(address _factory, bytes32 initHash) external;
    function removeFactory(address _factory) external;
    function hasFactory(address _factory) external view returns (bool);
    function allFactories() external view returns (address[] memory);
    function setLPFee(address _factory, uint256 fee) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.7;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyMultiSig`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    /**
     * @dev Must be Multi-Signature Wallet.
     */
    address private _multiSigOwner;

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
    modifier onlyMultiSig() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _multiSigOwner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyMultiSig` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyMultiSig {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyMultiSig {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _multiSigOwner;
        _multiSigOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IGoosebumpsPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IFeeAggregator {
    function calculateFeeAndAmountOut(uint256 amountIn) external view returns (uint256 fee, uint256 amountOut);
    function calculateFeeAndAmountIn(uint256 amountOut) external view returns (uint256 fee, uint256 amountIn);
    function setGoosebumpsFee(uint256 fee) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.7;

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
}