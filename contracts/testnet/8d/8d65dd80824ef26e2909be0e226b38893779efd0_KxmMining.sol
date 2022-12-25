/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT
// File: contracts/interfaces/IKxmCommunity.sol


pragma solidity ^0.8.0;

interface IKxmCommunity {
    /// @notice 绑定上级
    /// @param _superior 上级地址
    function bindSuperior(address _superior) external;

    /// @notice 获取用户信息
    /// @return level 用户级别
    /// @return superior 上级地址
    /// @return teamCount 团队人数
    /// @return directCount 直推人数
    function getUserInfo() external view returns(uint8 level, address superior, uint256 teamCount, uint256 directCount);
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

// File: contracts/Maintenance.sol


pragma solidity ^0.8.0;



contract Maintenance is Ownable {
    address private MaintenanceAddress;

    modifier onlyMaintenance() {
        require(MaintenanceAddress == _msgSender(), "Maintenance: not MaintenanceAddress");
        _;
    }

    function getMaintenanceAddress() public view onlyOwner returns(address) {
        return MaintenanceAddress;
    }

    function setMaintenanceAddress(address _address) public onlyOwner {
        MaintenanceAddress = _address;
    }
}
// File: contracts/KxmAddress.sol


pragma solidity ^0.8.0;


contract KxmAddress is Ownable {
    // 平台地址
    address private platformAddress;

    event SetPlatformAddress(address oldAttr, address newAddr);

    function _getPlatformAddress() internal view returns(address) {
        return platformAddress;
    }

    function getPlatformAddress() external view onlyOwner returns(address) {
        return platformAddress;
    }

    function _setPlatformAddress(address _address) internal {
        address oldAttr = platformAddress;
        platformAddress = _address;
        emit SetPlatformAddress(oldAttr, _address);
    }

    function setPlatformAddress(address _address) external onlyOwner {
        _setPlatformAddress(_address);
    }



    // 平台地址2
    address private platformAddress2;

    event SetPlatformAddress2(address oldAttr, address newAddr);

    function _getPlatformAddress2() internal view returns(address) {
        return platformAddress2;
    }

    function getPlatformAddress2() external view onlyOwner returns(address) {
        return platformAddress2;
    }

    function _setPlatformAddress2(address _address) internal {
        address oldAttr = platformAddress2;
        platformAddress2 = _address;
        emit SetPlatformAddress2(oldAttr, _address);
    }

    function setPlatformAddress2(address _address) external onlyOwner {
        _setPlatformAddress2(_address);
    }

    // 平台地址3
    address private platformAddress3;

    event SetPlatformAddress3(address oldAttr, address newAddr);

    function _getPlatformAddress3() internal view returns(address) {
        return platformAddress3;
    }

    function getPlatformAddress3() external view onlyOwner returns(address) {
        return platformAddress3;
    }

    function _setPlatformAddress3(address _address) internal {
        address oldAttr = platformAddress3;
        platformAddress3 = _address;
        emit SetPlatformAddress3(oldAttr, _address);
    }

    function setPlatformAddress3(address _address) external onlyOwner {
        _setPlatformAddress3(_address);
    }
}
// File: contracts/interfaces/IKxmMining.sol


pragma solidity ^0.8.0;

interface IKxmMining {
    function reserve() external;
    function join() external;
}
// File: contracts/interfaces/IPancakeswapV2Pair.sol



pragma solidity ^0.8.0;


interface IPancakeswapV2Pair {
    
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/interfaces/IPancakeswapV2Router01.sol



pragma solidity ^0.8.0;

interface IPancakeswapV2Router01 {
    
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

// File: contracts/interfaces/IPancakeswapV2Router02.sol



pragma solidity ^0.8.0;


interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
    
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

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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

        /// @solidity memory-safe-assembly
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
     * @dev Returns the number of values in the set. O(1).
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: contracts/KxmCommunity.sol


pragma solidity ^0.8.0;





contract KxmCommunity is IKxmCommunity, Context, Ownable {
    address immutable public TOP_INVITE_ADDRESS;

    struct Player {
        address addr;
        uint8 level;
        address superior;
        uint256 teamCount;
        uint256 directRecommendHasJoin;
        EnumerableSet.AddressSet directRecommend;
    }

    mapping(address => Player) players;

    modifier onlyBindSuperior() {
        require(players[_msgSender()].superior != address(0) || _msgSender() == TOP_INVITE_ADDRESS, "User: Not bound to superior");
        _;
    }

    /// @notice 绑定上级
    /// @param player player
    /// @param superior 上级地址
    event BindSuperior(address player, address superior);

    constructor(address _topInviteAddr) {
        TOP_INVITE_ADDRESS = _topInviteAddr;
    }

    function multiSetUserLevel(address[] calldata _addresses, uint8[] calldata _levels) external onlyOwner {
        require(_addresses.length == _levels.length,"Users: The number of parameters is not equal");
        for (uint i = 0; i < _addresses.length; i++) {
            _grantLevel(_addresses[i], _levels[i]);
        }
    }

    function _grantLevel(address _address, uint8 _level) internal {
        players[_address].level = _level;
    }

    function _getUserLevel(address _address) internal view returns(uint8) {
        return players[_address].level;
    }

    function _getSuperior(address _address) internal view returns(address) {
        return players[_address].superior;
    }

    function multiBindSuperior(address[] calldata _addresses, address[] calldata _superiors) external onlyOwner {
        require(_addresses.length == _superiors.length,"Users: The number of parameters is not equal");
        for (uint i = 0; i < _addresses.length; i++) {
            require(_superiors[i] != address(0), "superior is the zero address");
            require(_addresses[i] != TOP_INVITE_ADDRESS, "Top-level users cannot bind superiors");
            require(players[_addresses[i]].superior == address(0), "already bound to a superior");
            require(_superiors[i] == TOP_INVITE_ADDRESS || players[_superiors[i]].superior != address(0), "The inviter has not bound the superior");

            players[_addresses[i]].superior = _superiors[i];
            EnumerableSet.add(players[_superiors[i]].directRecommend, _addresses[i]);
            _incTeamCount(_addresses[i]);

            emit BindSuperior(_addresses[i], _superiors[i]);
        }
    }

    /// @notice 绑定上级
    /// @param _superior 上级地址
    function bindSuperior(address _superior) external {
        require(_superior != address(0), "superior is the zero address");
        require(_msgSender() != TOP_INVITE_ADDRESS, "Top-level users cannot bind superiors");
        require(players[_msgSender()].superior == address(0), "already bound to a superior");
        require(_superior == TOP_INVITE_ADDRESS || players[_superior].superior != address(0), "The inviter has not bound the superior");

        players[_msgSender()].superior = _superior;
        EnumerableSet.add(players[_superior].directRecommend, _msgSender());
        _incTeamCount(_msgSender());

        emit BindSuperior(_msgSender(), _superior);
    }

    function _incTeamCount(address _address) private {
        address currentAddress = _address;
        address superior;
        do {
            superior = _getSuperior(currentAddress);
            if (superior != address(0)) {
               players[superior].teamCount++;
            }
            currentAddress = superior;
        } while (currentAddress != address(0));
    }

    /// @notice 获取用户信息
    /// @return level 用户级别
    /// @return superior 上级地址
    /// @return teamCount 团队人数
    /// @return directCount 直推人数
    function getUserInfo() public view returns(uint8 level, address superior, uint256 teamCount, uint256 directCount) {
        level = players[_msgSender()].level;
        superior = players[_msgSender()].superior;
        teamCount = players[_msgSender()].teamCount;
        directCount = EnumerableSet.length(players[_msgSender()].directRecommend);
    }
}
// File: @openzeppelin/contracts/utils/structs/EnumerableMap.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableMap.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableMap.js.

pragma solidity ^0.8.0;


/**
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
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * The following map types are supported:
 *
 * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
 * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
 * - `bytes32 -> bytes32` (`Bytes32ToBytes32Map`) since v4.6.0
 * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
 * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableMap.
 * ====
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Bytes32ToBytes32Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToBytes32Map storage map, bytes32 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Bytes32ToBytes32Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32ToBytes32Map storage map, uint256 index) internal view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToBytes32Map storage map, bytes32 key) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        Bytes32ToBytes32Map storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || contains(map, key), errorMessage);
        return value;
    }

    // UintToUintMap

    struct UintToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToUintMap storage map,
        uint256 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key)));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToUintMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(key), errorMessage));
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        UintToAddressMap storage map,
        uint256 key,
        address value
    ) internal returns (bool) {
        return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        UintToAddressMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (address) {
        return address(uint160(uint256(get(map._inner, bytes32(key), errorMessage))));
    }

    // AddressToUintMap

    struct AddressToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return remove(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return contains(map._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        AddressToUintMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, bytes32(uint256(uint160(key))), errorMessage));
    }

    // Bytes32ToUintMap

    struct Bytes32ToUintMap {
        Bytes32ToBytes32Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Bytes32ToUintMap storage map,
        bytes32 key,
        uint256 value
    ) internal returns (bool) {
        return set(map._inner, key, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Bytes32ToUintMap storage map, bytes32 key) internal returns (bool) {
        return remove(map._inner, key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool) {
        return contains(map._inner, key);
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(Bytes32ToUintMap storage map) internal view returns (uint256) {
        return length(map._inner);
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
    function at(Bytes32ToUintMap storage map, uint256 index) internal view returns (bytes32, uint256) {
        (bytes32 key, bytes32 value) = at(map._inner, index);
        return (key, uint256(value));
    }

    /**
     * @dev Tries to returns the value associated with `key`. O(1).
     * Does not revert if `key` is not in the map.
     */
    function tryGet(Bytes32ToUintMap storage map, bytes32 key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = tryGet(map._inner, key);
        return (success, uint256(value));
    }

    /**
     * @dev Returns the value associated with `key`. O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(Bytes32ToUintMap storage map, bytes32 key) internal view returns (uint256) {
        return uint256(get(map._inner, key));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(
        Bytes32ToUintMap storage map,
        bytes32 key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(get(map._inner, key, errorMessage));
    }
}

// File: @openzeppelin/contracts/utils/math/SafeCast.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// File: @openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/DoubleEndedQueue.sol)
pragma solidity ^0.8.4;


/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `Bytes32Deque`. Other types can be cast to and from `bytes32`. This data structure can only be
 * used in storage, and not in memory.
 * ```
 * DoubleEndedQueue.Bytes32Deque queue;
 * ```
 *
 * _Available since v4.6._
 */
library DoubleEndedQueue {
    /**
     * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
     */
    error Empty();

    /**
     * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
     */
    error OutOfBounds();

    /**
     * @dev Indices are signed integers because the queue can grow in any direction. They are 128 bits so begin and end
     * are packed in a single storage slot for efficient access. Since the items are added one at a time we can safely
     * assume that these 128-bit indices will not overflow, and use unchecked arithmetic.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * Indices are in the range [begin, end) which means the first item is at data[begin] and the last item is at
     * data[end - 1].
     */
    struct Bytes32Deque {
        int128 _begin;
        int128 _end;
        mapping(int128 => bytes32) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue.
     */
    function pushBack(Bytes32Deque storage deque, bytes32 value) internal {
        int128 backIndex = deque._end;
        deque._data[backIndex] = value;
        unchecked {
            deque._end = backIndex + 1;
        }
    }

    /**
     * @dev Removes the item at the end of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popBack(Bytes32Deque storage deque) internal returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        value = deque._data[backIndex];
        delete deque._data[backIndex];
        deque._end = backIndex;
    }

    /**
     * @dev Inserts an item at the beginning of the queue.
     */
    function pushFront(Bytes32Deque storage deque, bytes32 value) internal {
        int128 frontIndex;
        unchecked {
            frontIndex = deque._begin - 1;
        }
        deque._data[frontIndex] = value;
        deque._begin = frontIndex;
    }

    /**
     * @dev Removes the item at the beginning of the queue and returns it.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function popFront(Bytes32Deque storage deque) internal returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        value = deque._data[frontIndex];
        delete deque._data[frontIndex];
        unchecked {
            deque._begin = frontIndex + 1;
        }
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function front(Bytes32Deque storage deque) internal view returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 frontIndex = deque._begin;
        return deque._data[frontIndex];
    }

    /**
     * @dev Returns the item at the end of the queue.
     *
     * Reverts with `Empty` if the queue is empty.
     */
    function back(Bytes32Deque storage deque) internal view returns (bytes32 value) {
        if (empty(deque)) revert Empty();
        int128 backIndex;
        unchecked {
            backIndex = deque._end - 1;
        }
        return deque._data[backIndex];
    }

    /**
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
     * `length(deque) - 1`.
     *
     * Reverts with `OutOfBounds` if the index is out of bounds.
     */
    function at(Bytes32Deque storage deque, uint256 index) internal view returns (bytes32 value) {
        // int256(deque._begin) is a safe upcast
        int128 idx = SafeCast.toInt128(int256(deque._begin) + SafeCast.toInt256(index));
        if (idx >= deque._end) revert OutOfBounds();
        return deque._data[idx];
    }

    /**
     * @dev Resets the queue back to being empty.
     *
     * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
     * out on potential gas refunds.
     */
    function clear(Bytes32Deque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    /**
     * @dev Returns the number of items in the queue.
     */
    function length(Bytes32Deque storage deque) internal view returns (uint256) {
        // The interface preserves the invariant that begin <= end so we assume this will not overflow.
        // We also assume there are at most int256.max items in the queue.
        unchecked {
            return uint256(int256(deque._end) - int256(deque._begin));
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     */
    function empty(Bytes32Deque storage deque) internal view returns (bool) {
        return deque._end <= deque._begin;
    }
}

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

// File: contracts/interfaces/IKxmToken.sol


pragma solidity ^0.8.0;


interface IKxmToken is IERC20 {
    function burn(uint256 amount) external;
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

// File: contracts/libraries/KxmLibrary.sol


pragma solidity ^0.8.0;


library KxmLibrary {
    using SafeMath for uint;

    uint8 constant BEP20_DECIMAL = 18;
    uint256 constant BEP20_BASEUINT = 10 ** BEP20_DECIMAL;

    // user level
    uint8 constant USER_LEVEL_V1 = 1;
    uint8 constant USER_LEVEL_V2 = 2;  
    uint8 constant USER_LEVEL_V3 = 3;
    uint8 constant USER_LEVEL_V4 = 4;   
    uint8 constant USER_LEVEL_V5 = 5;
    uint8 constant USER_LEVEL_V6 = 6;   
    uint8 constant USER_LEVEL_V7 = 7;
    uint8 constant USER_LEVEL_V8 = 8;

    uint8 constant V1_DIRECT_COUNT = 2; // 

    uint256 constant TO_PLATFORM_AWARD2 = 5 * BEP20_BASEUINT / 10;
    uint256 constant TO_PLATFORM_AWARD3 = 2 * BEP20_BASEUINT / 10;

    // 管理奖（USDT）
    uint256 constant MANAGEMENT_AWARD_V1 = 5 * BEP20_BASEUINT / 10;
    uint256 constant MANAGEMENT_AWARD_V2 = 1 * BEP20_BASEUINT;
    uint256 constant MANAGEMENT_AWARD_V3 = 15 * BEP20_BASEUINT / 10;
    uint256 constant MANAGEMENT_AWARD_V4 = 18 * BEP20_BASEUINT / 10;
    uint256 constant MANAGEMENT_AWARD_V5 = 21 * BEP20_BASEUINT / 10;
    uint256 constant MANAGEMENT_AWARD_V6 = 24 * BEP20_BASEUINT / 10;
    uint256 constant MANAGEMENT_AWARD_V7 = 27 * BEP20_BASEUINT / 10;
    uint256 constant MANAGEMENT_AWARD_V8 = 3 * BEP20_BASEUINT;

    // 平级奖比例（百分比）
    uint8 constant PINGJI_AWARD_RATIO_V1 = 0;
    uint8 constant PINGJI_AWARD_RATIO_V2 = 10;
    uint8 constant PINGJI_AWARD_RATIO_V3 = 10;
    uint8 constant PINGJI_AWARD_RATIO_V4 = 10;
    uint8 constant PINGJI_AWARD_RATIO_V5 = 10;
    uint8 constant PINGJI_AWARD_RATIO_V6 = 10;
    uint8 constant PINGJI_AWARD_RATIO_V7 = 10;
    uint8 constant PINGJI_AWARD_RATIO_V8 = 10;

    uint256 constant PINGJI_AWARD_TOTAL = 3 * BEP20_BASEUINT / 10;

    uint256 constant DIRECT_RECOMMEND_USDT = 1 * BEP20_BASEUINT;    
    
    // reserve
    uint256 constant RESERVE_USDT_AMOUNT = 30 * BEP20_BASEUINT;
    uint256 constant RESERVE_USDT_PKG = 20 * BEP20_BASEUINT;
    uint256 constant RESERVE_USDT_BURN = 5 * BEP20_BASEUINT;
    uint32 constant RESERVE_DAYS = 6;
    uint32 constant RESERVE_DAY_COUNT = 8;

    struct ReservePlayer {
        address player;
        uint32[RESERVE_DAYS + 1] dayCount;
        uint32 startTime;
        uint32 endTime;
    }

    // join
    uint256 constant JOIN_USDT_AMOUNT = 100 * BEP20_BASEUINT;
    uint256 constant JOIN_USDT_BACK = 105 * BEP20_BASEUINT;
    uint256 constant JOIN_LAST_USER_ASSETPKG = 200 * BEP20_BASEUINT; 

    struct AssetPakege {
        uint256 totalAmount;
        uint256 unReleaseAmount;
        uint256 releasedAmount;
        uint256 receiveAmount;
        uint32 lastReleaseTime;
    }

    function getManageAward(uint8 level) public pure returns(uint256) {
        if (level == USER_LEVEL_V1) {
            return MANAGEMENT_AWARD_V1;
        } else if (level == USER_LEVEL_V2) {
            return MANAGEMENT_AWARD_V2;
        } else if (level == USER_LEVEL_V3) {
            return MANAGEMENT_AWARD_V3;
        } else if (level == USER_LEVEL_V4) {
            return MANAGEMENT_AWARD_V4;
        } else if (level == USER_LEVEL_V5) {
            return MANAGEMENT_AWARD_V5;
        } else if (level == USER_LEVEL_V6) {
            return MANAGEMENT_AWARD_V6;
        } else if (level == USER_LEVEL_V7) {
            return MANAGEMENT_AWARD_V7;
        } else if (level == USER_LEVEL_V8) {
            return MANAGEMENT_AWARD_V8;
        } else {
            return 0;
        }
    }

    function getPingjiRatio(uint8 level) public pure returns(uint256) {
        if (level == USER_LEVEL_V1) {
            return PINGJI_AWARD_RATIO_V1;
        } else if (level == USER_LEVEL_V2) {
            return PINGJI_AWARD_RATIO_V2;
        } else if (level == USER_LEVEL_V3) {
            return PINGJI_AWARD_RATIO_V3;
        } else if (level == USER_LEVEL_V4) {
            return PINGJI_AWARD_RATIO_V4;
        } else if (level == USER_LEVEL_V5) {
            return PINGJI_AWARD_RATIO_V5;
        } else if (level == USER_LEVEL_V6) {
            return PINGJI_AWARD_RATIO_V6;
        } else if (level == USER_LEVEL_V7) {
            return PINGJI_AWARD_RATIO_V7;
        } else if (level == USER_LEVEL_V8) {
            return PINGJI_AWARD_RATIO_V8;
        } else {
            return 0;
        }
    }

    function getDayCounts() public pure returns(uint32[] memory) {
        uint32[] memory dayCount = new uint32[](RESERVE_DAYS);
        for (uint i = 0; i < RESERVE_DAYS; i++) {
            dayCount[i] = RESERVE_DAY_COUNT;
        }
        return dayCount;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function encodeAddr(address _address) public pure returns(bytes32) {
        return bytes32(abi.encode(_address));
    }

    function decodeAddr(bytes32 data) public pure returns(address) {
        return abi.decode(abi.encodePacked(data), (address));
    }
}
// File: contracts/KxmMining.sol


pragma solidity ^0.8.0;














contract KxmMining is KxmCommunity, KxmAddress, Maintenance {
    using SafeMath for uint;

    IPancakeswapV2Router02 immutable _pancakeswapV2Router02;
    IPancakeswapV2Pair immutable _pancakeswapV2Pair;
    IKxmToken immutable _kxmToken;
    IERC20 immutable _usdtToken;

    mapping (address => uint256) selfBuyAmount;      // 个人业绩
    mapping (address => uint256) teamBuyAmount;      // 团队业绩
    mapping (address => uint256) directIncome;
    mapping (address => uint256) manageIncome;

    mapping (address => KxmLibrary.ReservePlayer) reservePlayers;

    mapping (address => KxmLibrary.AssetPakege) assetPackage;
    EnumerableSet.AddressSet assetPackageMember;

    uint256 constant PACKAGE_AMOUNT = 200 * 10**18;
    uint256 constant PACKAGE_RELEASE_AMOUNT = 2 * 10**18;
    mapping (address => uint256[]) assetPackageValue;

    mapping (address => EnumerableMap.AddressToUintMap) playersMaxLevel;

    DoubleEndedQueue.Bytes32Deque miningQueue;

    event TransferAssetPackage(address indexed from, address indexed to, uint256 amount);
    event ReleaseAssetPackage(address indexed _address, uint256 amount, uint256 amountKxm);

    constructor(address _topInviteAddress) KxmCommunity(_topInviteAddress) {
        // bsc testnet
        _pancakeswapV2Router02 = IPancakeswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        _pancakeswapV2Pair = IPancakeswapV2Pair(0xe17B4A7918b5fC65B354A254a9e24e42B07194a0);
        _kxmToken = IKxmToken(0x5d3422863eFd2E360DF79b81797fD7A631ADA779);
        _usdtToken = IERC20(0x1ED66aCD7CFe15F44901F40Ec159fA3ff34757FA);

        // bsc mainnet
        // _pancakeswapV2Router02 = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // _pancakeswapV2Pair = IPancakeswapV2Pair(0xF2d577dd14574B7515CCaeC38562a0D952122A3c);
        // _kxmToken = IKxmToken(0xbC7823A8A01db4ef1338482ED8ca8b28a187D2c5);
        // _usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        
        // ganache
        // _pancakeswapV2Router02 = IPancakeswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // _pancakeswapV2Pair = IPancakeswapV2Pair(0x3A1D24185614838F615f896adCD151b410b01138);
        // _kxmToken = IKxmToken(0x6ac61cb908793D6310B1d521D2E8C5B9a51F012F);
        // _usdtToken = IERC20(0x02B2e5Bd1A5A09Cd4Bbb89947670E21FA75ddb98);
        // _pancakeswapV2Router02 = IPancakeswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // _pancakeswapV2Pair = IPancakeswapV2Pair(0x3A1D24185614838F615f896adCD151b410b01138);
        // _kxmToken = IKxmToken(0xe468d677FBE405129aeAc898e91164200C696c37);
        // _usdtToken = IERC20(0xa6e833269C4bbbCe5f1625dD5D1e1bFd4dB3b694);



        _setPlatformAddress(address(1));
        _setPlatformAddress2(address(2));
        _setPlatformAddress3(address(3));
        setMaintenanceAddress(owner());

        // _setPlatformAddress(0xcA20120501B29D9B6797db1A5410885Ef1B8B8b8);
        // _setPlatformAddress2(0x2A9D41708f26770EBD3b0C7cce46d317b482EF8e);
        // _setPlatformAddress3(0x39f2de77dafB90cD7A5cab480Ee396a2807501F4);
        // setMaintenanceAddress(0xE8e207E90b30528fe2F697faC03fA487e0c9a7cA);
    }

    function _checkReserve(address _address) private view returns(bool) {
        return reservePlayers[_address].endTime + 86400 > block.timestamp;
    }

    /// @notice 获取个人，团队业绩
    /// @return selfPerformance 个人业绩
    /// @return teamPerformance 团队业绩
    /// @return _directIncome 直推收益
    /// @return _manageIncome 团队收益
    function getPerformance() external view returns(uint256 selfPerformance, uint256 teamPerformance, uint256 _directIncome, uint256 _manageIncome) {
        selfPerformance = selfBuyAmount[_msgSender()];
        teamPerformance = teamBuyAmount[_msgSender()];
        _directIncome = directIncome[_msgSender()];
        _manageIncome = manageIncome[_msgSender()];
    }

    /// @notice 预约
    function reserve() external onlyBindSuperior {
        require(reservePlayers[_msgSender()].endTime < block.timestamp, "Already reserve");
        uint256 kxmPrice = getUsdtToKxmPrice();
        uint256 kxmAmount = KxmLibrary.RESERVE_USDT_AMOUNT.mul(kxmPrice).div(KxmLibrary.BEP20_BASEUINT);
        require(_kxmToken.allowance(_msgSender(), address(this)) >= kxmAmount, "KxmMining: insufficient allowance");
        _kxmToken.transferFrom(_msgSender(), address(this), kxmAmount);
        if (assetPackage[_getSuperior(_msgSender())].unReleaseAmount > 0) {
            _releaseTotal(_getSuperior(_msgSender()), KxmLibrary.RESERVE_USDT_PKG);
            _kxmToken.burn(kxmAmount);
        } else {
            _kxmToken.burn(kxmAmount);
        }
        
        _upgradeLevel(reservePlayers[_msgSender()].startTime);

        reservePlayers[_msgSender()].player = _msgSender();
        reservePlayers[_msgSender()].startTime = uint32(block.timestamp);
        reservePlayers[_msgSender()].endTime = uint32(block.timestamp + KxmLibrary.RESERVE_DAYS * 24*60*60);
        reservePlayers[_msgSender()].dayCount = [uint32(0),8,8,8,8,8,8];
    }

    /// @notice 获取预约信息
    /// @return startTime 预约开始时间
    /// @return endTime   预约结束时间
    /// @return dayCount  今日剩余可参与次数
    function getReserveInfo() external view returns(uint32 startTime, uint32 endTime, uint32 dayCount) {
        startTime = reservePlayers[_msgSender()].startTime;
        endTime = reservePlayers[_msgSender()].endTime;
        if (block.timestamp < endTime) {
            uint256 day = (block.timestamp - startTime) / 1 days + 1;
            dayCount = reservePlayers[_msgSender()].dayCount[day];
        } else {
            dayCount = 0;
        }
    }

    /// @notice 参与
    function join() external {
        require(block.timestamp < reservePlayers[_msgSender()].endTime, "no appointment");
        uint256 day = (block.timestamp - reservePlayers[_msgSender()].startTime) / 1 days + 1;
        uint32 dayCount = reservePlayers[_msgSender()].dayCount[day];
        require(dayCount > 0, "The remaining number of participations must be greater than 0");
        require(_usdtToken.allowance(_msgSender(), address(this)) >= KxmLibrary.JOIN_USDT_AMOUNT, "KxmMining: insufficient allowance");
        _usdtToken.transferFrom(_msgSender(), address(this), KxmLibrary.JOIN_USDT_AMOUNT);

        reservePlayers[_msgSender()].dayCount[day]--;
        _addSelfAmount(_msgSender(), KxmLibrary.JOIN_USDT_AMOUNT);
        _addTeamAmount(_msgSender(), KxmLibrary.JOIN_USDT_AMOUNT);
        _mining();
        _directRecommendAward();
        _managementAward();
        _usdtToken.transfer(_getPlatformAddress2(), KxmLibrary.TO_PLATFORM_AWARD2);
        _usdtToken.transfer(_getPlatformAddress3(), KxmLibrary.TO_PLATFORM_AWARD3);        
    }

    event EManageAward(address indexed _address, uint8 level, uint256 amount);

    function _managementAward() private {
        address currentAddress = _msgSender();
        uint8 currentLevel = _getUserLevel(_msgSender());
        address superior;
        bool canPingji = true;
        uint256 manageToPlatform = KxmLibrary.getManageAward(KxmLibrary.USER_LEVEL_V8);
        uint256 pingjiToPlatform = KxmLibrary.PINGJI_AWARD_TOTAL;
        uint256 manageAmount;
        uint256 pingjiAmount;
        uint256 userAmount = KxmLibrary.getManageAward(currentLevel);

        do {
            superior = _getSuperior(currentAddress);
            if (canPingji == true) {
                canPingji = false;
                if (currentLevel > 0) {
                    pingjiAmount = manageAmount.mul(KxmLibrary.getPingjiRatio(currentLevel)).div(100);
                    if (pingjiAmount > 0 && _pingjiAward(currentAddress, currentLevel, pingjiAmount)) {
                        pingjiToPlatform = pingjiToPlatform.sub(pingjiAmount);
                    }
                }
            }

            if (_getUserLevel(superior) > currentLevel) {
                canPingji = true;
                manageAmount = KxmLibrary.getManageAward(_getUserLevel(superior)).sub(userAmount);
                userAmount = KxmLibrary.getManageAward(_getUserLevel(superior));
                if (_checkReserve(superior)) {
                    manageToPlatform -= manageAmount;
                    _usdtToken.transfer(superior, manageAmount);
                    manageIncome[superior] += manageAmount;
                    emit EManageAward(superior, _getUserLevel(superior), manageAmount);
                }
                currentLevel = _getUserLevel(superior);
            }
            currentAddress = superior;
        } while (currentAddress != address(0));

        if (manageToPlatform > 0 || pingjiToPlatform > 0) {
            _usdtToken.transfer(_getPlatformAddress(), manageToPlatform.add(pingjiToPlatform));
        }
    }

    event EPingjiAward(address indexed sourceAddr, address indexed _address, uint8 level, uint256 amount);

    function _pingjiAward(address _address, uint8 level, uint256 amount) internal returns(bool) {
        address currentAddress = _address;
        address superior;
        bool loop = true;
        bool isPingji = false;

        do {
            superior = _getSuperior(currentAddress);
            if (_getUserLevel(superior) > level) {
                break;
            }
            if (_getUserLevel(superior) == level) {
                loop = false;
                isPingji = true;
                if (_checkReserve(superior)) {
                    _usdtToken.transfer(superior, amount); 
                    manageIncome[superior] += amount;
                    emit EPingjiAward(_address, superior, level, amount);
                }
            }
            currentAddress = superior;
        } while (loop == true && currentAddress != address(0));    
        return isPingji;
    }

    event EDirectRecommendAward(address indexed _address, uint256 amount);

    function _directRecommendAward() private {
        address superior = _getSuperior(_msgSender());
        if (_checkReserve(superior) && superior != address(0)) {
            _usdtToken.transfer(superior, KxmLibrary.DIRECT_RECOMMEND_USDT);
            directIncome[superior] += KxmLibrary.DIRECT_RECOMMEND_USDT;
            emit EDirectRecommendAward(superior, KxmLibrary.DIRECT_RECOMMEND_USDT);
        } else {
            _usdtToken.transfer(_getPlatformAddress(), KxmLibrary.DIRECT_RECOMMEND_USDT);
        }
    }

    function _upgradeLevel(uint256 currentSelfBuyAmount) internal {
        address upgradeUser;
        address superior = _getSuperior(_msgSender());        
        if (currentSelfBuyAmount == 0 && players[superior].directRecommendHasJoin < KxmLibrary.V1_DIRECT_COUNT) {
            players[_getSuperior(_msgSender())].directRecommendHasJoin++;
            if (players[superior].directRecommendHasJoin == KxmLibrary.V1_DIRECT_COUNT) {
                // v1
                if (_checkReserve(superior)) {
                    _updateLevel(superior, KxmLibrary.USER_LEVEL_V1);
                }
                // v2
                upgradeUser = superior;
                for (uint8 _level = 2; _level <= 8; _level++) {
                    upgradeUser = _upgradeLevel(upgradeUser, _level, _level - 1);
                    if (upgradeUser == address(0)) {
                        break;
                    }
                }
            }
        }
    }

    function _upgradeLevel(address _address, uint8 _level, uint8 _flevel) internal returns(address upgradeUser) {
        address superior = _getSuperior(_address);
        uint256 playersMaxLevelCount;
        uint256 _mlevel;
        uint256 userCount;

        do {
            userCount = 0;
            playersMaxLevelCount = EnumerableMap.length(playersMaxLevel[superior]);
            if (
                superior != address(0) 
                && _getUserLevel(superior) < _level
                && playersMaxLevelCount >= 2
                ) {
                for (uint i = 0; i < playersMaxLevelCount; i++) {
                    (,_mlevel) = EnumerableMap.at(playersMaxLevel[superior], i);
                    if (_mlevel >= _flevel) {
                        userCount++;
                    }
                    if (userCount == 2) {
                        if (_checkReserve(superior)) {
                            _updateLevel(superior, _level);
                        }
                        if (upgradeUser == address(0)) {
                            upgradeUser = superior;
                        }
                        break;
                    }
                }
            }
            superior = _getSuperior(superior);
        } while (superior != address(0));
    }

    function _updateLevel(address _address, uint8 _level) internal {
        _grantLevel(_address, _level);
        address currentAddress = _address;
        address superior = _getSuperior(_address);
        while (superior != address(0)) {
            if (
                _level >= _getUserLevel(superior) 
            ) {
                if (            
                    !EnumerableMap.contains(playersMaxLevel[superior], currentAddress)
                    || EnumerableMap.get(playersMaxLevel[superior], currentAddress) < _level
                ) {
                    EnumerableMap.set(playersMaxLevel[superior], currentAddress, _level);
                }
            }
            currentAddress = superior;
            superior = _getSuperior(currentAddress);
        }
    }

    function updateLevel(address _address, uint8 _level) external {
        _updateLevel(_address, _level);
    }

    function _addSelfAmount(address _address, uint256 amount) internal {
        selfBuyAmount[_address] += amount;
    }

    function _addTeamAmount(address _address, uint256 amount) internal {
        address currentAddress = _address;
        address superior;
        do {
            superior = _getSuperior(currentAddress);
            if (superior != address(0)) {
                teamBuyAmount[superior] += amount;
            }
            currentAddress = superior;
        } while (superior != address(0));
    }

    /// @notice 获取资产包信息
    /// @param  _address 用户地址
    /// @return unReleaseAmount 待释放金额 usdt
    /// @return releasedAmount  已释放金额 kxm
    /// @return receiveAmount  已领取金额 kxm
    /// @return totalAmount    总资产 usdt
    /// @return lastReleaseTime 最后释放时间
    function getAssetPackage(address _address) public view returns(uint256 unReleaseAmount, uint256 releasedAmount, uint256 receiveAmount, uint256 totalAmount, uint32 lastReleaseTime) {
        unReleaseAmount = assetPackage[_address].unReleaseAmount;
        releasedAmount = assetPackage[_address].releasedAmount;
        receiveAmount = assetPackage[_address].receiveAmount;
        totalAmount = assetPackage[_address].totalAmount;
        lastReleaseTime = assetPackage[_address].lastReleaseTime;
    }

    /// @notice 获取资产包信息
    /// @return unReleaseAmount 待释放金额 usdt
    /// @return releasedAmount  已释放金额 kxm
    /// @return receiveAmount  已领取金额 kxm
    /// @return totalAmount    总资产 usdt
    /// @return lastReleaseTime 最后释放时间
    function getAssetPackage() public view returns(uint256 unReleaseAmount, uint256 releasedAmount, uint256 receiveAmount, uint256 totalAmount, uint32 lastReleaseTime) {
        (unReleaseAmount, releasedAmount, receiveAmount, totalAmount, lastReleaseTime) = getAssetPackage(_msgSender());
    }

    function assetPakageAmount(address _address) external view returns(uint256) {
        uint256 plen = assetPackageValue[_address].length;
        uint256 totalAmount;
        for (uint256 index = 0; index < plen; index++) {
            totalAmount += assetPackageValue[_address][index];
        }
        return totalAmount;
    }

    function _mining() private {
        if (!DoubleEndedQueue.empty(miningQueue)) {
            address prevPlayer = KxmLibrary.decodeAddr(DoubleEndedQueue.back(miningQueue));
            _usdtToken.transfer(prevPlayer, KxmLibrary.JOIN_USDT_BACK);
        }

        if (DoubleEndedQueue.length(miningQueue) == 9) {
            DoubleEndedQueue.clear(miningQueue);
            // 第10个人获得200U价值的资产包
            _addAssetPackage(_msgSender(), KxmLibrary.JOIN_LAST_USER_ASSETPKG);
            assetPackage[_msgSender()].totalAmount += KxmLibrary.JOIN_LAST_USER_ASSETPKG;
        } else {
            DoubleEndedQueue.pushBack(miningQueue, KxmLibrary.encodeAddr(_msgSender()));
        }
    }

    function _addAssetPackage(address _address, uint256 amount) internal {
        uint256 plen = amount / PACKAGE_AMOUNT;
        for (uint256 index = 0; index < plen; index++) {
            assetPackageValue[_address].push(PACKAGE_AMOUNT);
        }
        if (amount % PACKAGE_AMOUNT > 0) {
            assetPackageValue[_address].push(amount % PACKAGE_AMOUNT);
        }
        assetPackage[_address].unReleaseAmount += amount;
        EnumerableSet.add(assetPackageMember, _address);
    }

    function multiAddAssetPackage(address[] calldata _addresses, uint256 amount) external {
        for (uint index = 0; index < _addresses.length; index++) {
            _addAssetPackage(_addresses[index], amount);
            assetPackage[_addresses[index]].totalAmount += amount;
        }
    }

    /// @notice 获取拥有资产包的人数
    /// @return uint256 拥有资产包的人数
    function getAssetPackageMemberLength() public view returns(uint256) {
        return EnumerableSet.length(assetPackageMember);
    }

    /// @notice 获取拥有资产包的人
    /// @return address 拥有资产包的人
    function getAssetPackageMember(uint256 index) public view returns(address) {
        return EnumerableSet.at(assetPackageMember, index);
    }

    /// @notice 每天释放资产包
    function releaseAssetPackage(address _address) public onlyMaintenance {
        uint ts;
        if (assetPackage[_address].lastReleaseTime == 0) {
            ts = block.timestamp + 86400 - (block.timestamp % 86400) - 28800;
        } else {
            ts = assetPackage[_address].lastReleaseTime + 86400;
        }
        // ts = block.timestamp;
        if (assetPackage[_address].lastReleaseTime < ts) {
            _releaseOne(_address);
            assetPackage[_address].lastReleaseTime = uint32(ts);
        }
    }

    /// @notice 批量每天释放资产包 
    function multiReleaseAssetPackage(address[] calldata _address) public onlyMaintenance {
        uint256 _addrLength = _address.length;
        for (uint i = 0; i < _addrLength; i++) {
            releaseAssetPackage(_address[i]);
        }
    }

    function _releaseTotal(address _address, uint256 amount) internal {
        uint256 totalRelease;
        uint256 plen = assetPackageValue[_address].length;
        for (uint256 index = 0; index < plen; index++) {
            if (assetPackageValue[_address][index] == 0) {
                continue;
            }
            if (assetPackageValue[_address][index] >= amount - totalRelease) {
                assetPackageValue[_address][index] -= amount - totalRelease;
                totalRelease = amount;
            } else {
                totalRelease += assetPackageValue[_address][index];
                assetPackageValue[_address][index] = 0;
            }

            if (totalRelease == amount) {
                break;
            }
        }
        assetPackage[_address].unReleaseAmount -= totalRelease;
        uint256 amountKxm = totalRelease.mul(getUsdtToKxmPrice()).div(KxmLibrary.BEP20_BASEUINT);
        assetPackage[_address].releasedAmount += amountKxm;
        emit ReleaseAssetPackage(_address, totalRelease, amountKxm);
        if (assetPackage[_address].unReleaseAmount == 0) {
            EnumerableSet.remove(assetPackageMember, _address);
        }
    }

    function _releaseOne(address _address) internal {
        uint256 totalRelease;
        uint256 plen = assetPackageValue[_address].length;
        for (uint256 index = 0; index < plen; index++) {
            if (assetPackageValue[_address][index] == 0) {
                continue;
            }
            if (assetPackageValue[_address][index] > PACKAGE_RELEASE_AMOUNT) {
                assetPackageValue[_address][index] -= PACKAGE_RELEASE_AMOUNT;
                totalRelease += PACKAGE_RELEASE_AMOUNT;
            } else {
                totalRelease += assetPackageValue[_address][index];
                assetPackageValue[_address][index] = 0;
            }
        }
        assetPackage[_address].unReleaseAmount -= totalRelease;
        uint256 amountKxm = totalRelease.mul(getUsdtToKxmPrice()).div(KxmLibrary.BEP20_BASEUINT);
        assetPackage[_address].releasedAmount += amountKxm;
        emit ReleaseAssetPackage(_address, totalRelease, amountKxm);
        if (assetPackage[_address].unReleaseAmount == 0) {
            EnumerableSet.remove(assetPackageMember, _address);
        }
    }

    /// @notice 转让全部资产包
    function transferAssetPackageAll(address to) external {
        uint256 plen = assetPackageValue[_msgSender()].length;
        for (uint256 index = 0; index < plen; index++) {
            assetPackageValue[to].push(assetPackageValue[_msgSender()][index]);
            assetPackageValue[_msgSender()][index] = 0;
        }
        assetPackage[to].unReleaseAmount += assetPackage[_msgSender()].unReleaseAmount;
        EnumerableSet.add(assetPackageMember, to);
        assetPackage[_msgSender()].unReleaseAmount = 0;
        EnumerableSet.remove(assetPackageMember, _msgSender());
    }

    /// @notice 领取全部资产包
    function receiveAssetPackageAll() external {
        (,uint256 releasedAmount,,,) = getAssetPackage(_msgSender());
        _kxmToken.transfer(_msgSender(), releasedAmount);
        assetPackage[_msgSender()].releasedAmount -= releasedAmount;
        assetPackage[_msgSender()].receiveAmount += releasedAmount;
    }

    /// @notice 获取kxm价格 1 kxm / usdt
    function getKxmPrice() public view returns(uint256) {
        (uint _reserve0, uint _reserve1,) = _pancakeswapV2Pair.getReserves();
        uint256 kxmprice = _pancakeswapV2Router02.getAmountOut(1000000000000000000, _reserve1, _reserve0);
        return kxmprice.mul(9995).div(10000);
        // (uint res0, uint res1) = (4737827092024940349546144, 25074744242778760552098000);
        // return KxmLibrary.getAmountOut(1000000000000000000, res0, res1);
    }

    /// @notice 获取USDT价格 1 usdt / kxm
    function getUsdtToKxmPrice() public view returns(uint256) {
        (uint _reserve0, uint _reserve1,) = _pancakeswapV2Pair.getReserves();
        uint256 kxmprice = _pancakeswapV2Router02.getAmountOut(1000000000000000000, _reserve0, _reserve1);
        return kxmprice.mul(9995).div(10000);
        // (uint res0, uint res1) = (25074744242778760552098000, 4737827092024940349546144);
        // return KxmLibrary.getAmountOut(1000000000000000000, res0, res1);
    }

    function withdrawUsdt(uint256 amount) public onlyOwner {
        _usdtToken.transfer(owner(), amount);
    }

    function withdrawKxm(uint256 amount) public onlyOwner {
        _kxmToken.transfer(owner(), amount);
    }
}