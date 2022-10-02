/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

/// @title bit library
/// @notice old school bit bits
library bits {

    /// @notice check if only a specific bit is set
    /// @param slot the bit storage slot
    /// @param bit the bit to be checked
    /// @return return true if the bit is set
    function only(uint slot, uint bit) internal pure returns (bool) {
        return slot == bit;
    }

    /// @notice checks if all bits ares set and cleared
    function all(uint slot, uint set_, uint cleared_) internal pure returns (bool) {
        return all(slot, set_) && !all(slot, cleared_);
    }

    /// @notice checks if any of the bits_ are set
    /// @param slot the bit storage to slot
    /// @param bits_ the or list of bits_ to slot
    /// @return true of any of the bits_ are set otherwise false
    function any(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) != 0;
    }

    /// @notice checks if any of the bits are set and all of the bits are cleared
    function check(uint slot, uint set_, uint cleared_) internal pure returns(bool) {
        return slot != 0 ?  ((set_ == 0 || any(slot, set_)) && (cleared_ == 0 || !all(slot, cleared_))) : (set_ == 0 || any(slot, set_));
    }

    /// @notice checks if all of the bits_ are set
    /// @param slot the bit storage
    /// @param bits_ the list of bits_ required
    /// @return true if all of the bits_ are set in the sloted variable
    function all(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) == bits_;
    }

    /// @notice set bits_ in this storage slot
    /// @param slot the storage slot to set
    /// @param bits_ the list of bits_ to be set
    /// @return a new uint with bits_ set
    /// @dev bits_ that are already set are not cleared
    function set(uint slot, uint bits_) internal pure returns(uint) {
        return slot | bits_;
    }

    function toggle(uint slot, uint bits_) internal pure returns (uint) {
        return slot ^ bits_;
    }

    function isClear(uint slot, uint bits_) internal pure returns(bool) {
        return !all(slot, bits_);
    }

    /// @notice clear bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared
    function clear(uint slot, uint bits_) internal pure returns(uint) {
        return slot & ~(bits_);
    }

    /// @notice clear & set bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared and set
    function reset(uint slot, uint bits_) internal pure returns(uint) {
        slot = clear(slot, type(uint).max);
        return set(slot, bits_);
    }

}

/// @notice Emitted when a check for
error FlagsInvalid(address account, uint256 set, uint256 cleared);

/// @title UsingFlags contract
/// @notice Use this contract to implement unique permissions or attributes
/// @dev you have up to 255 flags you can use. Be careful not to use the same flag more than once. Generally a preferred approach is using
///      pure virtual functions to implement the flags in the derived contract.
abstract contract UsingFlags {
    /// @notice a helper library to check if a flag is set
    using bits for uint256;
    event FlagsChanged(address indexed, uint256, uint256);

    /// @notice checks of the required flags are set or cleared
    /// @param account_ the account to check
    /// @param set_ the flags that must be set
    /// @param cleared_ the flags that must be cleared
    modifier requires(address account_, uint256 set_, uint256 cleared_) {
        if (!(_getFlags(account_).check(set_, cleared_))) revert FlagsInvalid(account_, set_, cleared_);
        _;
    }

    /// @notice getFlags returns the currently set flags
    /// @param account_ the account to check
    function getFlags(address account_) public virtual view returns (uint256) {
        return _getFlags(account_);
    }

    function _getFlags(address account_) internal virtual view returns (uint256) {
        return _getFlagStorage()[account_];
    }

    /// @notice set and clear flags for the given account
    /// @param account_ the account to modify flags for
    /// @param set_ the flags to set
    /// @param clear_ the flags to clear
    function _setFlags(address account_, uint256 set_, uint256 clear_) internal virtual {
        uint256 before = _getFlags(account_);
        _getFlagStorage()[account_] = _getFlags(account_).set(set_).clear(clear_);
        emit FlagsChanged(account_, before, _getFlags(account_));
    }

    function _checkFlags(address account_, uint set_, uint cleared_) internal view returns (bool) {
        return _getFlags(account_).check(set_, cleared_);
    }

    /// @notice get the storage for flags
    function _getFlagStorage() internal view virtual returns (mapping(address => uint256) storage);
}

abstract contract UsingDefaultFlags is UsingFlags {
    using bits for uint256;

    struct DefaultFlags {
        uint initializedFlag;
        uint transferDisabledFlag;
        uint providerFlag;
        uint serviceFlag;
        uint networkFlag;
        uint serviceExemptFlag;
        uint adminFlag;
        uint blockedFlag;
        uint routerFlag;
        uint feeExemptFlag;
        uint servicesDisabledFlag;
        uint permitsEnabledFlag;
    }

    /// @notice the value of the initializer flag
    function _INITIALIZED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 255;
    }

    function _TRANSFER_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _INITIALIZED_FLAG() >> 1;
    }

    function _PROVIDER_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_DISABLED_FLAG() >> 1;
    }

    function _SERVICE_FLAG() internal pure virtual returns (uint256) {
        return _PROVIDER_FLAG() >> 1;
    }

    function _NETWORK_FLAG() internal pure virtual returns (uint256) {
        return _SERVICE_FLAG() >> 1;
    }

    function _SERVICE_EXEMPT_FLAG() internal pure virtual returns(uint256) {
        return _NETWORK_FLAG() >> 1;
    }

    function _ADMIN_FLAG() internal virtual pure returns (uint256) {
        return _SERVICE_EXEMPT_FLAG() >> 1;
    }

    function _BLOCKED_FLAG() internal pure virtual returns (uint256) {
        return _ADMIN_FLAG() >> 1;
    }

    function _ROUTER_FLAG() internal pure virtual returns (uint256) {
        return _BLOCKED_FLAG() >> 1;
    }

    function _FEE_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _ROUTER_FLAG() >> 1;
    }

    function _SERVICES_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return _FEE_EXEMPT_FLAG() >> 1;
    }

    function _PERMITS_ENABLED_FLAG() internal pure virtual returns (uint256) {
        return _SERVICES_DISABLED_FLAG() >> 1;
    }

    function _TOKEN_FLAG() internal pure virtual returns (uint256) {
        return _PERMITS_ENABLED_FLAG() >> 1;
    }

    function _isFeeExempt(address account_) internal view virtual returns (bool) {
        return _checkFlags(account_, _FEE_EXEMPT_FLAG(), 0);
    }

    function _isFeeExempt(address from_, address to_) internal view virtual returns (bool) {
        return _isFeeExempt(from_) || _isFeeExempt(to_);
    }

    function _isServiceExempt(address from_, address to_) internal view virtual returns (bool) {
        return _checkFlags(from_, _SERVICE_EXEMPT_FLAG(), 0) || _checkFlags(to_, _SERVICE_EXEMPT_FLAG(), 0);
    }

    function defaultFlags() external view returns (DefaultFlags memory) {
        return DefaultFlags(
            _INITIALIZED_FLAG(),
            _TRANSFER_DISABLED_FLAG(),
            _PROVIDER_FLAG(),
            _SERVICE_FLAG(),
            _NETWORK_FLAG(),
            _SERVICE_EXEMPT_FLAG(),
            _ADMIN_FLAG(),
            _BLOCKED_FLAG(),
            _ROUTER_FLAG(),
            _FEE_EXEMPT_FLAG(),
            _SERVICES_DISABLED_FLAG(),
            _PERMITS_ENABLED_FLAG()
        );
    }
}

error AdminRequired();

abstract contract UsingAdmin is UsingDefaultFlags {
    using bits for uint256;

    modifier requiresAdmin() {
        if (!_isAdmin(msg.sender)) revert AdminRequired();
        _;
    }

    function _initializeAdmin(address admin_) internal virtual {
        _setFlags(admin_, _ADMIN_FLAG(), 0);
    }

    function setFlags(address account_, uint256 set_, uint256 clear_) external requires(msg.sender, _ADMIN_FLAG(), 0) {
        _setFlags(account_, set_, clear_);
    }

    function _isAdmin(address account_) internal view returns (bool) {
        return _getFlags(account_).all(_ADMIN_FLAG());
    }

}

library collections {
    using bits for uint16;
    using collections for CircularSet;
    using collections for Dict;
    using collections for DictItem;
    using collections for AddressSet;

    error KeyExists();
    error KeyError();

    struct AddressSet {
        address[] items;
        mapping(address => uint) indices;
    }

    function add(AddressSet storage set_, address item_) internal {
        if (set_.contains(item_)) revert KeyExists();
        set_.items.push(item_);
        set_.indices[item_] = set_.items.length;
    }

    function replace(AddressSet storage set_, address oldItem_, address newItem_) internal {
        if (set_.indices[oldItem_] == 0) {
            revert KeyError();
        }
        set_.items[set_.indices[oldItem_] - 1] = newItem_;
        set_.indices[newItem_] = set_.indices[oldItem_];
        set_.indices[oldItem_] = 0;
    }

    function pop(AddressSet storage set_) internal returns (address) {
        address last = set_.items[set_.length() - 1];
        delete set_.indices[last];
        return last;
    }

    function get(AddressSet storage set_, uint index_) internal view returns (address) {
        return set_.items[index_];
    }

    function length(AddressSet storage set_) internal view returns (uint) {
        return set_.items.length;
    }

    function remove(AddressSet storage set_, address item_) internal  {
        if (set_.indices[item_] == 0) {
            revert KeyError();
        }
        uint index = set_.indices[item_];
        if (index != set_.length()) {
            set_.items[index - 1] = set_.items[set_.length() - 1];
            set_.indices[set_.items[index - 1]] = index;
        }
        set_.items.pop();
        set_.indices[item_] = 0;
    }

    function clear(AddressSet storage set_) internal {
        for (uint i=0; i < set_.length(); i++) {
            address key = set_.items[i];
            set_.indices[key] = 0;
        }
        delete set_.items;
    }

    function contains(AddressSet storage set_, address item_) internal view returns (bool) {
        return set_.indices[item_] > 0;
    }

    function indexOf(AddressSet storage set_, address item_) internal view returns (uint) {
        return set_.indices[item_] - 1;
    }

    struct CircularSet {
        uint[] items;
        mapping(uint => uint) indices;
        uint iter;
    }

    function add(CircularSet storage set_, uint item_) internal {
        if (set_.contains(item_)) revert KeyExists();
        set_.items.push(item_);
        set_.indices[item_] = set_.items.length;
    }

    function add(CircularSet storage set_, address item_) internal {
        add(set_, uint(uint160(item_)));
    }

    function replace(CircularSet storage set_, uint oldItem_, uint newItem_) internal {
        if (set_.indices[oldItem_] == 0) {
            revert KeyError();
        }
        set_.items[set_.indices[oldItem_] - 1] = newItem_;
        set_.indices[newItem_] = set_.indices[oldItem_];
        set_.indices[oldItem_] = 0;
    }

    function replace(CircularSet storage set_, address oldItem_, address newItem_) internal {
        set_.replace(uint(uint160(oldItem_)), uint(uint160(newItem_)));
    }

    function pop(CircularSet storage set_) internal returns (uint) {
        uint last = set_.items[set_.length() - 1];
        delete set_.indices[last];
        return last;
    }

    function get(CircularSet storage set_, uint index_) internal view returns (uint) {
        return set_.items[index_];
    }

    function getAsAddress(CircularSet storage set_, uint index_) internal view returns (address) {
        return address(uint160(get(set_, index_)));
    }

    function next(CircularSet storage set_) internal returns (uint) {
        uint item =  set_.items[set_.iter++];
        if (set_.iter >= set_.length()) {
            set_.iter = 0;
        }
        return item;
    }

    function current(CircularSet storage set_) internal view returns (uint) {
        return set_.items[set_.iter];
    }

    function currentAsAddress(CircularSet storage set_) internal view returns (address) {
        return address(uint160(set_.items[set_.iter]));
    }

    function nextAsAddress(CircularSet storage set_) internal returns (address) {
        return address(uint160(next(set_)));
    }

    function length(CircularSet storage set_) internal view returns (uint) {
        return set_.items.length;
    }

    function remove(CircularSet storage set_, uint item_) internal  {
        if (set_.indices[item_] == 0) {
            revert KeyError();
        }
        uint index = set_.indices[item_];
        if (index != set_.length()) {
            set_.items[index - 1] = set_.items[set_.length() - 1];
            set_.indices[set_.items[index - 1]] = index;
        }
        set_.items.pop();
        set_.indices[item_] = 0;
        if (set_.iter == index) {
            set_.iter = set_.length();
        }
    }

    function remove(CircularSet storage set_, address item_) internal  {
        remove(set_, uint(uint160(item_)));
    }

    function clear(CircularSet storage set_) internal {
        for (uint i=0; i < set_.length(); i++) {
            uint key = set_.items[i];
            set_.indices[key] = 0;
        }
        delete set_.items;
        set_.iter = 0;
    }

    function itemsAsAddresses(CircularSet storage set_) internal view returns (address[] memory) {
        address[] memory items = new address[](set_.length());
        for (uint i = 0; i < set_.length(); i++) {
            items[i] = address(uint160(set_.items[i]));
        }
        return items;
    }

    function contains(CircularSet storage set_, uint item_) internal view returns (bool) {
        return set_.indices[item_] > 0;
    }

    function contains(CircularSet storage set_, address item_) internal view returns (bool) {
        return set_.contains(uint(uint160(item_)));
    }

    function indexOf(CircularSet storage set_, address item_) internal view returns (uint) {
        return set_.indices[uint(uint160(item_))] - 1;
    }

    struct DictItem {
        bytes32 key;
        uint value;
    }

    struct Dict {
        DictItem[] items;
        mapping(bytes32 => uint) indices;
    }

    function set(DictItem storage keyValue, bytes32 key, uint value) internal {
        (keyValue.key, keyValue.value) = (key, value);
    }

    function set(DictItem storage keyValue, uint value) internal {
        keyValue.value = value;
    }

    function _set(Dict storage dct, bytes32 key, uint value) private returns (uint index) {
        dct.items.push();
        index = dct.indices[key] = dct.items.length;
        dct.items[index-1].set(key, value);
    }

    function _update(Dict storage dct, bytes32 key, uint value) private returns (uint index) {
        index = dct.indices[key] - 1;
        dct.items[index].value = value;
    }

    function set(Dict storage dct, bytes32 key, uint value) internal returns (uint) {
        if (!dct.hasKey(key)) {
            return _set(dct, key, value);
        } else {
            return _update(dct, key, value);
        }
    }

    function values(Dict storage dct) internal view returns (uint[] memory) {
        uint size = dct.length();
        uint[] memory dctValues = new uint[](size);
        for (uint i = 0; i < size; i++) {
            dctValues[i] = dct.items[i].value;
        }
        return dctValues;
    }

    function keys(Dict storage dct) internal view returns (bytes32[] memory) {
        uint size = dct.length();
        bytes32[] memory dctKeys = new bytes32[](size);
        for (uint i = 0; i < size; i++) {
            dctKeys[i] = dct.items[i].key;
        }
        return dctKeys;
    }

    function length(Dict storage dct) internal view returns (uint){
        return dct.items.length;
    }

    function set(Dict storage dct, address key, uint value) internal {
        dct.set(bytes32(uint256(uint160(key))), value);
    }

    function set(Dict storage dct, uint key, uint value) internal {
        dct.set(bytes32(key), value);
    }

    function set(Dict storage dct, bytes32 key, address value) internal {
        dct.set(key, uint256(uint160(value)));
    }

    function set(Dict storage dct, bytes32 key, bytes32 value) internal {
        dct.set(key, uint256(value));
    }

    function set(Dict storage dct, uint key, address value) internal {
        dct.set(bytes32(key), uint(uint160(value)));
    }

    function set(Dict storage dct, uint key, bytes32 value) internal {
        dct.set(bytes32(key), value);
    }

    function set(Dict storage dct, address key, bytes32 value) internal {
        dct.set(key, uint256(value));
    }

    function get(Dict storage dct, bytes32 key) internal view returns (uint) {
        return dct.items[dct.indices[key] - 1].value;
    }

    function cross(Dict storage dct, bytes32 key, uint value) internal {
        uint index = dct.set(key, value);
        dct.set(value, key);
    }

    function get(Dict storage dct, bytes32 key, uint value) internal view returns (uint) {
        uint index = dct.indices[key];
        return index > 0 ? dct.items[index - 1].value : value;
    }

    function get(Dict storage dct, uint key) internal view returns (uint) {
        return dct.get(bytes32(key));
    }

    function get(Dict storage dct, address key) internal view returns (uint) {
        return dct.get(bytes32(uint256(uint160(key))));
    }

    function get(Dict storage dct, address key, uint value) internal view returns (uint) {
        return dct.get(bytes32(uint256(uint160(key))), value);
    }

    function update(Dict storage dct, DictItem calldata item) internal {
        dct.set(item.key, item.value);
    }

    function getAddress(Dict storage dct, bytes32 key) internal view returns (address) {
        return address(uint160(dct.getAddress(key)));
    }

    function getAddress(Dict storage dct, bytes32 key, address value) internal view returns (address) {
        uint index = dct.indices[key];
        return index > 0 ? address(uint160(dct.items[index - 1].value)) : value;
    }

    function getAddress(Dict storage dct, uint key) internal view returns (address) {
        return dct.getAddress(bytes32(key));
    }

    function getAddress(Dict storage dct, uint key, address value) internal view returns (address) {
        return dct.getAddress(bytes32(key), value);
    }

    function getAddress(Dict storage dct, address key) internal view returns (address) {
        return dct.getAddress(bytes32(uint256(uint160(key))));
    }

    function getAddress(Dict storage dct, address key, address value) internal view returns (address) {
        return dct.getAddress(bytes32(uint256(uint160(key))), value);
    }

    function getBytes32(Dict storage dct, bytes32 key) internal view returns (bytes32) {
        return bytes32(dct.get(key));
    }

    function getBytes32(Dict storage dct, bytes32 key, bytes32 value) internal view returns (bytes32) {
        uint index = dct.indices[key];
        return index > 0 ? bytes32(dct.items[index - 1].value) : value;
    }

    function getBytes32(Dict storage dct, uint key) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(key));
    }

    function getBytes32(Dict storage dct, uint key, bytes32 value) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(key), value);
    }

    function getBytes32(Dict storage dct, address key) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(uint256(uint160(key))));
    }

    function getBytes32(Dict storage dct, address key, bytes32 value) internal view returns (bytes32) {
        return dct.getBytes32(bytes32(uint256(uint160(key))), value);
    }

    function hasKey(Dict storage dct, bytes32 key) internal view returns (bool) {
        return dct.indices[key] > 0;
    }

    function hasKey(Dict storage dct, uint key) internal view returns (bool) {
        return dct.hasKey(bytes32(key));
    }

    function hasKey(Dict storage dct, address key) internal view returns (bool) {
        return dct.hasKey(uint256(uint160(key)));
    }

    function update(Dict storage dct, DictItem[] memory pairs) internal {
        for (uint i = 0; i < pairs.length; i++) {
            dct.set(pairs[i].key, pairs[i].value);
        }
    }

    function del(Dict storage dct, bytes32 key) internal {
        uint index = dct.indices[key];
        require(index > 0, "dict: key error");

        dct.items[index - 1] = dct.items[dct.items.length - 1];
        dct.items.pop();
    }

    function del(Dict storage dct, uint key) internal {
        dct.del(bytes32(key));
    }

    function del(Dict storage dct, address key) internal {
        dct.del(bytes32(uint256(uint160(key))));
    }
}

/// @title UsingFlagsWithStorage contract
/// @dev use this when creating a new contract
abstract contract UsingFlagsWithStorage is UsingFlags {
    using bits for uint256;

    /// @notice the mapping to store the flags
    mapping(address => uint256) internal _flags;

    function _getFlagStorage() internal view override returns (mapping(address => uint256) storage) {
        return _flags;
    }
}

abstract contract UsingPrecision {
   uint24 constant DEFAULT_PRECISION = 10 ** 5; // 000.000

   function _getPrecisionStorage() internal view virtual returns (uint24) {
      return DEFAULT_PRECISION;
   }

   function _setPrecisionStorage(uint24 precision_) internal virtual {}
}

contract AffinityState {
    uint128 constant _SERVICE_ERROR_STATE = 1 << 127; // 127
    uint128 constant _SERVICE_COMPLETE_STATE = _SERVICE_ERROR_STATE >> 1; // 126
    uint128 constant _LP_INJECTED_STATE = _SERVICE_COMPLETE_STATE >> 1; // 125
    uint128 constant _SWAP_TOKENS_STATE = _LP_INJECTED_STATE >> 1; // 124
    uint128 constant _SWAP_REWARD_STATE = _SWAP_TOKENS_STATE >> 1; // 123
    uint128 constant _DISTRIBUTED_REWARDS_STATE = _SWAP_REWARD_STATE >> 1 ; // 122
    uint128 constant _BUY_STATE = _DISTRIBUTED_REWARDS_STATE >> 1;  // 121
    uint128 constant _SELL_STATE = _BUY_STATE >> 1; // 120
    uint128 constant _BURN_FAILED_STATE = _SELL_STATE >> 1 ; // 119
    uint128 constant _BURN_TOKENS_STATE = _BURN_FAILED_STATE >> 1; // 118
    uint128 constant _FEE_EXEMPT_STATE = _BURN_TOKENS_STATE >> 1; // 117
    uint128 constant _SERVICE_EXEMPT_STATE = _FEE_EXEMPT_STATE >> 1; // 116

}

abstract contract AffinityFlags is UsingFlags, UsingDefaultFlags, UsingAdmin, UsingPrecision, AffinityState {
    using bits for uint256;

    struct Flags {
        uint transferLimitDisabled;
        uint lpPair;
        uint rewardExempt;
        uint transferLimitExempt;
        uint sellLimitPerTxDisabled;
        uint sellLimitPerPeriodDisabled;
        uint rewardDistributionDisabled;
        uint rewardSwapDisabled;
        uint sellLimitExempt;
    }

    function _TRANSFER_LIMIT_DISABLED_FLAG() internal pure virtual returns (uint256) {
        return 1 << 128;
    }

    function _LP_PAIR_FLAG() internal pure virtual returns (uint256) {
        return _TRANSFER_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _LP_PAIR_FLAG() >> 1;
    }

    function _TRANSFER_LIMIT_EXEMPT_FLAG() internal pure virtual returns (uint256) {
        return _REWARD_EXEMPT_FLAG() >> 1;
    }

    function _PER_TX_SELL_LIMIT_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _TRANSFER_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _24HR_SELL_LIMIT_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _PER_TX_SELL_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_DISTRIBUTION_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _24HR_SELL_LIMIT_DISABLED_FLAG() >> 1;
    }

    function _REWARD_SWAP_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _REWARD_DISTRIBUTION_DISABLED_FLAG() >> 1;
    }

    function _LP_INJECTION_DISABLED_FLAG() internal pure virtual returns(uint256) {
        return _REWARD_SWAP_DISABLED_FLAG() >> 1;  // 117
    }

    function _SELL_LIMIT_EXEMPT_FLAG() internal pure virtual returns(uint256) {
        return _LP_INJECTION_DISABLED_FLAG() >> 1;  // 116
    }

    function _isLPPair(address from_, address to_) internal view virtual returns (bool) {
        return _isLPPair(from_) || _isLPPair(to_);
    }

    function _isLPPair(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_LP_PAIR_FLAG(), 0);
    }

    function _isTransferLimitEnabled() internal view virtual returns (bool) {
        return _getFlags(address(this)).check(0, _TRANSFER_LIMIT_DISABLED_FLAG());
    }

    function _isRewardExempt(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_REWARD_EXEMPT_FLAG(), 0);
    }

    function _isTransferLimitExempt(address account_) internal view virtual returns (bool) {
        return _isTransferLimitEnabled() && _getFlags(account_).check(_TRANSFER_LIMIT_EXEMPT_FLAG(), 0);
    }

    function _isRouter(address account_) internal view virtual returns (bool) {
        return _getFlags(account_).check(_ROUTER_FLAG(), 0);
    }

    function flags() external view returns (Flags memory) {
        return Flags(
            _TRANSFER_DISABLED_FLAG(),
            _LP_PAIR_FLAG(),
            _REWARD_EXEMPT_FLAG(),
            _TRANSFER_LIMIT_DISABLED_FLAG(),
            _PER_TX_SELL_LIMIT_DISABLED_FLAG(),
            _24HR_SELL_LIMIT_DISABLED_FLAG(),
            _REWARD_DISTRIBUTION_DISABLED_FLAG(),
            _REWARD_SWAP_DISABLED_FLAG(),
            _SELL_LIMIT_EXEMPT_FLAG()
        );
    }

}

contract AffinityFlagsWithStorage is UsingFlagsWithStorage, AffinityFlags {
    using bits for uint256;

}

interface UsingAdminInterface {
    function setFlags(address account_, uint256 set_, uint256 clear_) external;
    function getFlags(address account_) external view returns (uint256);
}

interface UsingServiceInterface is UsingAdminInterface {
    function withdraw(address to_) external;
    function setTransferFee(address account_, uint128 sendingFee_, uint128 receivingFee_) external;
}

interface AffinityTokenInterface is UsingAdminInterface {
    function burn(uint256 amount_) external;
    function pause() external;
    function unpause() external;
    function setProvider(address provider_) external;
}

interface AffinityBurnServiceInterface is UsingAdminInterface {

}

interface AffinityMarketingServiceInterface is UsingServiceInterface {
}

interface AffinityRewardServiceInterface is UsingAdminInterface{
    function getDistributionRates() external view returns (uint256, uint256, uint256);
    function getMaxedSelectableRewards() external view returns (uint256);
    function setMaxedSelectableRewards(uint256 amount_) external;
    function addAccounts(address[] calldata accounts_) external;
    function removeAccounts(address[] calldata accounts_) external;
    function setRewardRouter(address rewardToken_, address router_) external;
    function setDistributions(uint80 distributionsPerBuy_, uint80 distributionsPerSell_, uint80 distributionsPerTransfer_) external;
    function replaceReward(address oldRewardToken_, address newRewardToken_, uint ratio_, address router_) external;
    function addReward(address rewardToken_, uint[] calldata ratio_, address router_) external;
    function claim(address account_) external;
    function selectRewards(address[] calldata rewards_) external;
    function selected(address account_) external view returns (address[] memory);
    function selectable() external view returns (address[] memory);
    function distribute(uint count_) external;
}

interface AffinitySwapInterface is IUniswapV2Router02, UsingAdminInterface {
    struct SellLimits {
        uint txSellLimitPerHolder;
        uint sellLimitPer24hrs;
    }
    function withdrawTokens(address token_, address to_, uint amount_) external;
    function setSellLimitPerTx(uint txSellLimitPerHolder_) external;
    function set24hrSellLimitPerHolder(uint sellLimitPer24hrs_) external;
    function getSellLimits() external view returns (SellLimits memory);
    function withdraw(address to_) external;
}

contract AffinityAdmin is UsingAdmin, AffinityFlagsWithStorage {
    using collections for collections.AddressSet;
    using bits for uint256;

    collections.AddressSet _services;

    mapping(uint => collections.AddressSet) _flaggedAccounts;

    struct TransferFees {
        uint128 sendingFee;
        uint128 receivingFee;
    }

    constructor(address marketingService_, address rewardService_, address swapService_, address burnService_, address liquidityService_, address token_) {
        _initializeAdmin(msg.sender);
        _services.add(marketingService_);
        _services.add(rewardService_);
        _services.add(swapService_);
        _services.add(burnService_);
        _services.add(token_);
        _services.add(liquidityService_);
    }

    function pauseTransfers() external requiresAdmin {
        token().pause();
    }

    function unpauseTransfers() external requiresAdmin {
        token().unpause();
    }

    function exemptAccountFromFees(address account_, address[] calldata services_) external requiresAdmin {
        for(uint i = 0; i < services_.length; i++) {
            UsingAdminInterface(services_[i]).setFlags(account_, _FEE_EXEMPT_FLAG(), 0);
        }
    }

    function blockAccount(address account_) external requiresAdmin {
        if (isBlocked(account_)) {
            revert("Account already blocked");
        }
        token().setFlags(account_, _BLOCKED_FLAG(), 0);
        _flaggedAccounts[_BLOCKED_FLAG()].add(account_);
    }

    function unblockAccount(address account_) external requiresAdmin {
        if (!isBlocked(account_)) {
            revert("Account not blocked");
        }
        token().setFlags(account_, 0, _BLOCKED_FLAG());
        _flaggedAccounts[_BLOCKED_FLAG()].remove(account_);
    }

    function isBlocked(address account_) public view returns (bool) {
        return token().getFlags(account_).any(_BLOCKED_FLAG());
    }

    function exemptAccountFromRewards(address account_) external requiresAdmin {
        rewardService().setFlags(account_, _REWARD_EXEMPT_FLAG(), 0);
        _flaggedAccounts[_REWARD_EXEMPT_FLAG()].add(account_);
    }

    function unexemptAccountFromRewards(address account_) external requiresAdmin {
        rewardService().setFlags(account_, 0, _REWARD_EXEMPT_FLAG());
        _flaggedAccounts[_REWARD_EXEMPT_FLAG()].remove(account_);
    }

    function isExemptedFromRewards(address account_) public view returns (bool) {
        return rewardService().getFlags(account_).any(_REWARD_EXEMPT_FLAG());
    }

    function set24hrSellLimitPerHolder(uint sellLimitPer24hrs_) external requiresAdmin {
        swapService().set24hrSellLimitPerHolder(sellLimitPer24hrs_);
    }

    function setMarketingFee(address[] calldata pairs_, uint128 buyFee_, uint128 sellFee_) external requiresAdmin {
        for(uint i = 0; i < pairs_.length; i++) {
            marketingService().setTransferFee(pairs_[i], buyFee_, sellFee_);
        }
    }

    function setSellLimitPerTx(uint txSellLimitPerHolder_) external requiresAdmin {
        swapService().setSellLimitPerTx(txSellLimitPerHolder_);
    }

    function withdraw() external requiresAdmin {
        swapService().withdraw(msg.sender);
    }

    function destroy() external requiresAdmin {
        selfdestruct(payable(msg.sender));
    }

    function balance() external view returns (uint) {
        return address(_swapService()).balance + address(_marketingService()).balance;
    }

    function getSellLimits() external view returns (AffinitySwapInterface.SellLimits memory) {
        return swapService().getSellLimits();
    }

    function getFlaggedAccounts(uint flag_) external view returns (address[] memory) {
        return _flaggedAccounts[flag_].items;
    }

    function marketingService() public view returns (AffinityMarketingServiceInterface) {
        return AffinityMarketingServiceInterface(_marketingService());
    }

    function rewardService() public view returns (AffinityRewardServiceInterface) {
        return AffinityRewardServiceInterface(_rewardService());
    }

    function swapService() public view returns (AffinitySwapInterface) {
        return AffinitySwapInterface(_swapService());
    }

    function burnService() public view returns (AffinityBurnServiceInterface) {
        return AffinityBurnServiceInterface(_burnService());
    }

    function token() public view returns (AffinityTokenInterface) {
        return AffinityTokenInterface(_token());
    }

    function _marketingService() internal view returns (address) {
        return _services.get(0);
    }

    function _rewardService() internal view returns (address) {
        return _services.get(1);
    }

    function _swapService() internal view returns (address) {
        return _services.get(2);
    }

    function _burnService() public view returns (address) {
        return _services.get(3);
    }

    function _token() internal view returns (address) {
        return _services.get(4);
    }

    function _liquidityService() internal view returns (address) {
        return _services.get(5);
    }

}