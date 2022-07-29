/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// File: @openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol


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

// File: contracts/minimums/libs/MinimumsLib.sol


pragma solidity 0.8.11;


library MinimumsLib {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    address internal constant ZERO_ADDRESS = address(0);

    struct Minimum {
     //   uint256 timestampStart; //ts start no need 
        //uint256 timestampEnd;   //ts end
        uint256 speedGradualUnlock;    
        uint256 amountGradualWithdrawn;
        //uint256 amountGradual;
        uint256 amountNoneGradual;
        //bool gradual;
    }

    struct Lockup {
        uint64 duration;
        //bool gradual; // does not used 
        bool exists;
    }

    struct UserStruct {
        EnumerableSetUpgradeable.UintSet minimumsIndexes;
        mapping(uint256 => Minimum) minimums;
        //mapping(uint256 => uint256) dailyAmounts;
        Lockup lockup;
    }


      /**
    * @dev adding minimum holding at sender during period from now to timestamp.
    *
    * @param amount amount.
    * @param intervalCount duration in count of intervals defined before
    * @param gradual true if the limitation can gradually decrease
    */
    function _minimumsAdd(
        UserStruct storage _userStruct,
        uint256 amount, 
        uint256 intervalCount,
        uint64 interval,
        bool gradual
    ) 
        // public 
        // onlyOwner()
        internal
        returns (bool)
    {
        uint256 timestampStart = getIndexInterval(block.timestamp, interval);
        uint256 timestampEnd = timestampStart + (intervalCount * interval);
        require(timestampEnd > timestampStart, "TIMESTAMP_INVALID");
        
        _minimumsClear(_userStruct, interval, false);
        
        _minimumsAddLow(_userStruct, timestampStart, timestampEnd, amount, gradual);
    
        return true;
        
    }
    
    /**
     * @dev removes all minimums from this address
     * so all tokens are unlocked to send
     *  UserStruct which should be clear restrict
     */
    function _minimumsClear(
        UserStruct storage _userStruct,
        uint64 interval
    )
        internal
        returns (bool)
    {
        return _minimumsClear(_userStruct, interval, true);
    }
    
    /**
     * from will add automatic lockup for destination address sent address from
     * @param duration duration in count of intervals defined before
     */
    function _automaticLockupAdd(
        UserStruct storage _userStruct,
        uint64 duration,
        uint64 interval
    )
        internal
    {
        _userStruct.lockup.duration = duration * interval;
        _userStruct.lockup.exists = true;
    }
    
    /**
     * remove automaticLockup from UserStruct
     */
    function _automaticLockupRemove(
        UserStruct storage _userStruct
    )
        internal
    {
        _userStruct.lockup.exists = false;
    }
    
    /**
    * @dev get sum minimum and sum gradual minimums from address for period from now to timestamp.
    *
    */
    function _getMinimum(
        UserStruct storage _userStruct
    ) 
        internal 
        view
        returns (uint256 amountLocked) 
    {
        
        uint256 mapIndex;
        uint256 tmp;
        for (uint256 i=0; i<_userStruct.minimumsIndexes.length(); i++) {
            mapIndex = _userStruct.minimumsIndexes.at(i);
            
            if (block.timestamp <= mapIndex) { // block.timestamp<timestampEnd
                tmp = _userStruct.minimums[mapIndex].speedGradualUnlock * (mapIndex - block.timestamp);
                
                amountLocked = amountLocked +
                                    (
                                        tmp < _userStruct.minimums[mapIndex].amountGradualWithdrawn 
                                        ? 
                                        0 
                                        : 
                                        tmp - (_userStruct.minimums[mapIndex].amountGradualWithdrawn)
                                    ) +
                                    (_userStruct.minimums[mapIndex].amountNoneGradual);
            }
        }
    }

    function _getMinimumList(
        UserStruct storage _userStruct
    ) 
        internal 
        view
        returns (uint256[][] memory ) 
    {
        
        uint256 mapIndex;
        uint256 tmp;
        uint256 len = _userStruct.minimumsIndexes.length();

        uint256[][] memory ret = new uint256[][](len);


        for (uint256 i=0; i<len; i++) {
            mapIndex = _userStruct.minimumsIndexes.at(i);
            
            if (block.timestamp <= mapIndex) { // block.timestamp<timestampEnd
                tmp = _userStruct.minimums[mapIndex].speedGradualUnlock * (mapIndex - block.timestamp);
                ret[i] = new uint256[](2);
                ret[i][1] = mapIndex;
                ret[i][0] = (
                                tmp < _userStruct.minimums[mapIndex].amountGradualWithdrawn 
                                ? 
                                0 
                                : 
                                tmp - _userStruct.minimums[mapIndex].amountGradualWithdrawn
                            ) +
                            _userStruct.minimums[mapIndex].amountNoneGradual;
            }
        }

        return ret;
    }
    
    /**
    * @dev clear expired items from mapping. used while addingMinimum
    *
    * @param deleteAnyway if true when delete items regardless expired or not
    */
    function _minimumsClear(
        UserStruct storage _userStruct,
        uint64 interval,
        bool deleteAnyway
    ) 
        internal 
        returns (bool) 
    {
        uint256 mapIndex = 0;
        uint256 len = _userStruct.minimumsIndexes.length();
        if (len > 0) {
            for (uint256 i=len; i>0; i--) {
                mapIndex = _userStruct.minimumsIndexes.at(i-1);
                if (
                    (deleteAnyway == true) ||
                    (getIndexInterval(block.timestamp, interval) > mapIndex)
                ) {
                    delete _userStruct.minimums[mapIndex];
                    _userStruct.minimumsIndexes.remove(mapIndex);
                }
                
            }
        }
        return true;
    }


        
    /**
     * added minimum if not exist by timestamp else append it
     * @param _userStruct destination user
     * @param timestampStart if empty get current interval or currente time. Using only for calculate gradual
     * @param timestampEnd "until time"
     * @param amount amount
     * @param gradual if true then lockup are gradually
     */
    //function _appendMinimum(
    function _minimumsAddLow(
        UserStruct storage _userStruct,
        uint256 timestampStart, 
        uint256 timestampEnd, 
        uint256 amount, 
        bool gradual
    )
        private
    {
        _userStruct.minimumsIndexes.add(timestampEnd);
        if (gradual == true) {
            // gradual
            _userStruct.minimums[timestampEnd].speedGradualUnlock = _userStruct.minimums[timestampEnd].speedGradualUnlock + 
                (
                amount / (timestampEnd - timestampStart)
                );
            //_userStruct.minimums[timestamp].amountGradual = _userStruct.minimums[timestamp].amountGradual.add(amount);
        } else {
            // none-gradual
            _userStruct.minimums[timestampEnd].amountNoneGradual = _userStruct.minimums[timestampEnd].amountNoneGradual + amount;
        }
    }
    
    /**
     * @dev reduce minimum by value  otherwise remove it 
     * @param _userStruct destination user struct
     * @param timestampEnd "until time"
     * @param value amount
     */
    function _reduceMinimum(
        UserStruct storage _userStruct,
        uint256 timestampEnd, 
        uint256 value,
        bool gradual
    )
        internal
    {
        
        if (_userStruct.minimumsIndexes.contains(timestampEnd) == true) {
            
            if (gradual == true) {
                
                _userStruct.minimums[timestampEnd].amountGradualWithdrawn = _userStruct.minimums[timestampEnd].amountGradualWithdrawn + value;
                
                uint256 left = (_userStruct.minimums[timestampEnd].speedGradualUnlock) * (timestampEnd - block.timestamp);
                if (left <= _userStruct.minimums[timestampEnd].amountGradualWithdrawn) {
                    _userStruct.minimums[timestampEnd].speedGradualUnlock = 0;
                    // delete _userStruct.minimums[timestampEnd];
                    // _userStruct.minimumsIndexes.remove(timestampEnd);
                }
            } else {
                if (_userStruct.minimums[timestampEnd].amountNoneGradual > value) {
                    _userStruct.minimums[timestampEnd].amountNoneGradual = _userStruct.minimums[timestampEnd].amountNoneGradual - value;
                } else {
                    _userStruct.minimums[timestampEnd].amountNoneGradual = 0;
                    // delete _userStruct.minimums[timestampEnd];
                    // _userStruct.minimumsIndexes.remove(timestampEnd);
                }
                    
            }
            
            if (
                _userStruct.minimums[timestampEnd].speedGradualUnlock == 0 &&
                _userStruct.minimums[timestampEnd].amountNoneGradual == 0
            ) {
                delete _userStruct.minimums[timestampEnd];
                _userStruct.minimumsIndexes.remove(timestampEnd);
            }
                
                
            
        }
    }
    
    /**
     * 
     
     * @param value amount
     */
    function minimumsTransfer(
        UserStruct storage _userStructFrom, 
        UserStruct storage _userStructTo, 
        bool isTransferToZeroAddress,
        //address to,
        uint256 value
    )
        internal
    {
        

        uint256 len = _userStructFrom.minimumsIndexes.length();
        uint256[] memory _dataList;
        //uint256 recieverTimeLeft;
    
        if (len > 0) {
            _dataList = new uint256[](len);
            for (uint256 i=0; i<len; i++) {
                _dataList[i] = _userStructFrom.minimumsIndexes.at(i);
            }
            _dataList = sortAsc(_dataList);
            
            uint256 iValue;
            uint256 tmpValue;
        
            for (uint256 i=0; i<len; i++) {
                
                if (block.timestamp <= _dataList[i]) {
                    
                    // try move none-gradual
                    if (value >= _userStructFrom.minimums[_dataList[i]].amountNoneGradual) {
                        iValue = _userStructFrom.minimums[_dataList[i]].amountNoneGradual;
                        value = value - iValue;
                    } else {
                        iValue = value;
                        value = 0;
                    }
                    
                    // remove from sender
                    _reduceMinimum(
                        _userStructFrom,
                        _dataList[i],//timestampEnd,
                        iValue,
                        false
                    );

                    // shouldn't add miniums for zero account.
                    // that feature using to drop minimums from sender
                    //if (to != ZERO_ADDRESS) {
                    if (!isTransferToZeroAddress) {
                        _minimumsAddLow(_userStructTo, block.timestamp, _dataList[i], iValue, false);
                    }
                    
                    if (value == 0) {
                        break;
                    }
                    
                    
                    // try move gradual
                    
                    // amount left in current minimums
                    tmpValue = _userStructFrom.minimums[_dataList[i]].speedGradualUnlock * (_dataList[i] - block.timestamp);
                        
                        
                    if (value >= tmpValue) {
                        iValue = tmpValue;
                        value = value - tmpValue;

                    } else {
                        iValue = value;
                        value = 0;
                    }
                    // remove from sender
                    _reduceMinimum(
                        _userStructFrom,
                        _dataList[i],//timestampEnd,
                        iValue,
                        true
                    );
                    // uint256 speed = iValue.div(
                        //     users[from].minimums[_dataList[i]].timestampEnd.sub(block.timestamp);
                        // );

                    // shouldn't add miniums for zero account.
                    // that feature using to drop minimums from sender
                    //if (to != ZERO_ADDRESS) {
                    if (!isTransferToZeroAddress) {
                        _minimumsAddLow(_userStructTo, block.timestamp, _dataList[i], iValue, true);
                    }
                    if (value == 0) {
                        break;
                    }
                    


                } // if (block.timestamp <= users[from].minimums[_dataList[i]].timestampEnd) {
            } // end for
            
   
        }
        
        // if (value != 0) {
            // todo 0: what this?
            // _appendMinimum(
            //     to,
            //     block.timestamp,//block.timestamp.add(minTimeDiff),
            //     value,
            //     false
            // );
        // }
     
        
    }

    /**
    * @dev gives index interval. here we deliberately making a loss precision(div before mul) to get the same index during interval.
    * @param ts unixtimestamp
    */
    function getIndexInterval(uint256 ts, uint64 interval) internal pure returns(uint256) {
        return ts / interval * interval;
    }
    
    // useful method to sort native memory array 
    function sortAsc(uint256[] memory data) private returns(uint[] memory) {
       quickSortAsc(data, int(0), int(data.length - 1));
       return data;
    }
    
    function quickSortAsc(uint[] memory arr, int left, int right) private {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSortAsc(arr, left, j);
        if (i < right)
            quickSortAsc(arr, i, right);
    }

 


}
// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC1820RegistryUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC1820Registry.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820RegistryUpgradeable {
    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     * @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     * @param account Address of the contract for which to update the cache.
     * @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not.
     * If the result is not cached a direct lookup on the contract address is performed.
     * If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     * {updateERC165Cache} with the contract address.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/token/ERC777/IERC777SenderUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Sender.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777TokensSender standard as defined in the EIP.
 *
 * {IERC777} Token holders can be notified of operations performed on their
 * tokens by having a contract implement this interface (contract holders can be
 * their own implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777SenderUpgradeable {
    /**
     * @dev Called by an {IERC777} token contract whenever a registered holder's
     * (`from`) tokens are about to be moved or destroyed. The type of operation
     * is conveyed by `to` being the zero address or not.
     *
     * This call occurs _before_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the pre-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// File: @openzeppelin/contracts-upgradeable/token/ERC777/IERC777Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

// File: @openzeppelin/contracts-upgradeable/token/ERC777/IERC777RecipientUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Recipient.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777RecipientUpgradeable {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// File: @openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// File: contracts/interfaces/ITrustedForwarder.sol


pragma solidity 0.8.11;

interface ITrustedForwarder {

    function isTrustedForwarder(address forwarder) external view returns(bool);
        

  

}

// File: @openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;



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

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


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

// File: @openzeppelin/contracts-upgradeable/token/ERC777/ERC777Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC777/ERC777.sol)

pragma solidity ^0.8.0;









/**
 * @dev Implementation of the {IERC777} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * Support for ERC20 is included in this contract, as specified by the EIP: both
 * the ERC777 and ERC20 interfaces can be safely used when interacting with it.
 * Both {IERC777-Sent} and {IERC20-Transfer} events are emitted on token
 * movements.
 *
 * Additionally, the {IERC777-granularity} value is hard-coded to `1`, meaning that there
 * are no special restrictions in the amount of tokens that created, moved, or
 * destroyed. This makes integration with ERC20 applications seamless.
 */
contract ERC777Upgradeable is Initializable, ContextUpgradeable, IERC777Upgradeable, IERC20Upgradeable {
    using AddressUpgradeable for address;

    IERC1820RegistryUpgradeable internal constant _ERC1820_REGISTRY = IERC1820RegistryUpgradeable(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // This isn't ever read from - it's only used to respond to the defaultOperators query.
    address[] private _defaultOperatorsArray;

    // Immutable, but accounts may revoke them (tracked in __revokedDefaultOperators).
    mapping(address => bool) private _defaultOperators;

    // For each account, a mapping of its operators and revoked default operators.
    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    // ERC20-allowances
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev `defaultOperators` may be an empty array.
     */
    function __ERC777_init(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) internal onlyInitializing {
        __ERC777_init_unchained(name_, symbol_, defaultOperators_);
    }

    function __ERC777_init_unchained(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;

        _defaultOperatorsArray = defaultOperators_;
        for (uint256 i = 0; i < defaultOperators_.length; i++) {
            _defaultOperators[defaultOperators_[i]] = true;
        }

        // register interfaces
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    /**
     * @dev See {IERC777-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC777-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {ERC20-decimals}.
     *
     * Always returns 18, as per the
     * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC777-granularity}.
     *
     * This implementation always returns `1`.
     */
    function granularity() public view virtual override returns (uint256) {
        return 1;
    }

    /**
     * @dev See {IERC777-totalSupply}.
     */
    function totalSupply() public view virtual override(IERC20Upgradeable, IERC777Upgradeable) returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of tokens owned by an account (`tokenHolder`).
     */
    function balanceOf(address tokenHolder) public view virtual override(IERC20Upgradeable, IERC777Upgradeable) returns (uint256) {
        return _balances[tokenHolder];
    }

    /**
     * @dev See {IERC777-send}.
     *
     * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        _send(_msgSender(), recipient, amount, data, "", true);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient}
     * interface if it is a contract.
     *
     * Also emits a {Sent} event.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    /**
     * @dev See {IERC777-burn}.
     *
     * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
     */
    function burn(uint256 amount, bytes memory data) public virtual override {
        _burn(_msgSender(), amount, data, "");
    }

    /**
     * @dev See {IERC777-isOperatorFor}.
     */
    function isOperatorFor(address operator, address tokenHolder) public view virtual override returns (bool) {
        return
            operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    /**
     * @dev See {IERC777-authorizeOperator}.
     */
    function authorizeOperator(address operator) public virtual override {
        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    /**
     * @dev See {IERC777-revokeOperator}.
     */
    function revokeOperator(address operator) public virtual override {
        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    /**
     * @dev See {IERC777-defaultOperators}.
     */
    function defaultOperators() public view virtual override returns (address[] memory) {
        return _defaultOperatorsArray;
    }

    /**
     * @dev See {IERC777-operatorSend}.
     *
     * Emits {Sent} and {IERC20-Transfer} events.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

    /**
     * @dev See {IERC777-operatorBurn}.
     *
     * Emits {Burned} and {IERC20-Transfer} events.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

    /**
     * @dev See {IERC20-allowance}.
     *
     * Note that operator and allowance concepts are orthogonal: operators may
     * not have allowance, and accounts with allowance may not be operators
     * themselves.
     */
    function allowance(address holder, address spender) public view virtual override returns (uint256) {
        return _allowances[holder][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Note that accounts cannot have allowance issued by their operators.
     */
    function approve(address spender, uint256 value) public virtual override returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Note that operator and allowance concepts are orthogonal: operators cannot
     * call `transferFrom` (unless they have allowance), and accounts with
     * allowance cannot call `operatorSend` (unless they are operators).
     *
     * Emits {Sent}, {IERC20-Transfer} and {IERC20-Approval} events.
     */
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _spendAllowance(holder, spender, amount);

        _move(spender, holder, recipient, amount, "", "");

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `operator`, `data` and `operatorData`.
     *
     * See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits {Minted} and {IERC20-Transfer} events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) internal virtual {
        _mint(account, amount, userData, operatorData, true);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If `requireReceptionAck` is set to true, and if a send hook is
     * registered for `account`, the corresponding function will be called with
     * `operator`, `data` and `operatorData`.
     *
     * See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits {Minted} and {IERC20-Transfer} events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        // Update state variables
        _totalSupply += amount;
        _balances[account] += amount;

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, requireReceptionAck);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Send tokens
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    /**
     * @dev Burn tokens
     * @param from address token holder address
     * @param amount uint256 amount of tokens to burn
     * @param data bytes extra information provided by the token holder
     * @param operatorData bytes extra information provided by the operator (if any)
     */
    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {
        require(from != address(0), "ERC777: burn from the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _beforeTokenTransfer(operator, from, address(0), amount);

        // Update state variables
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: burn amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _totalSupply -= amount;

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        _beforeTokenTransfer(operator, from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    /**
     * @dev See {ERC20-_approve}.
     *
     * Note that accounts cannot have allowance issued by their operators.
     */
    function _approve(
        address holder,
        address spender,
        uint256 value
    ) internal virtual {
        require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    /**
     * @dev Call from.tokensToSend() if the interface is registered
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     */
    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777SenderUpgradeable(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    /**
     * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
     * tokensReceived() was not registered for the recipient
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777RecipientUpgradeable(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC777: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes
     * calls to {send}, {transfer}, {operatorSend}, minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[41] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: contracts/access/TrustedForwarderUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity 0.8.11;



abstract contract TrustedForwarderUpgradeable is OwnableUpgradeable, ITrustedForwarder {

    address private _trustedForwarder;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __TrustedForwarder_init() internal onlyInitializing {
        __Ownable_init();
        _trustedForwarder = address(0);

    }


    /**
    * @dev setup trusted forwarder address
    * @param forwarder trustedforwarder's address to set
    * @custom:shortd setup trusted forwarder
    * @custom:calledby owner
    */
    function setTrustedForwarder(
        address forwarder
    ) 
        public 
        onlyOwner 
        //excludeTrustedForwarder 
    {
        require(owner() != forwarder, "FORWARDER_CAN_NOT_BE_OWNER");
        _trustedForwarder = forwarder;
    }
        
    /**
    * @dev checking if forwarder is trusted
    * @param forwarder trustedforwarder's address to check
    * @custom:shortd checking if forwarder is trusted
    */
    function isTrustedForwarder(
        address forwarder
    ) 
        external
        view 
        override
        returns(bool) 
    {
        return _isTrustedForwarder(forwarder);
    }

    /**
    * @dev implemented EIP-2771
    */
    function _msgSender(
    ) 
        internal 
        virtual
        override
        view 
        returns (address signer) 
    {
        signer = msg.sender;
        if (msg.data.length>=20 && _isTrustedForwarder(signer)) {
            assembly {
                signer := shr(96,calldataload(sub(calldatasize(),20)))
            }
        }    
    }

    function transferOwnership(
        address newOwner
    ) public 
        virtual 
        override 
        onlyOwner 
    {
        require(msg.sender != _trustedForwarder, "DENIED_FOR_FORWARDER");
        if (newOwner == _trustedForwarder) {
            _trustedForwarder = address(0);
        }
        super.transferOwnership(newOwner);
        
    }

    function _isTrustedForwarder(
        address forwarder
    ) 
        internal
        view 
        returns(bool) 
    {
        return forwarder == _trustedForwarder;
    }


  

}

// File: @openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File: @openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;






/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: contracts/interfaces/ICommunity.sol


pragma solidity ^0.8.0;

interface ICommunity {
    //function memberCount(string calldata role) external view returns(uint256);
    function getRoles(address member)external view returns(string[] memory);
    //function getMember(string calldata role) external view returns(address[] memory);
}
// File: contracts/interfaces/ICommunityRolesManagement.sol


pragma solidity ^0.8.11;

interface ICommunityRolesManagement {
    struct CommunitySettings {
        address addr;
        string adminRole;
        string redeemRole;
        string circulationRole;
    }

    function initialize(
        CommunitySettings calldata communitySettings,
        address admin
    ) external;   

    function getRedeemRole() external view returns(bytes32);
    
    function checkRedeemRole(address account) external view;
    function checkCirculationRole(address account) external view;

    
}

// File: contracts/CommunityRolesManagement.sol


pragma solidity 0.8.11;





contract CommunityRolesManagement is ICommunityRolesManagement, Initializable, AccessControlUpgradeable {

    bytes32 internal constant ADMIN_ROLE = "admin";
    bytes32 internal constant REDEEM_ROLE = "redeem";
    bytes32 internal constant CIRCULATION_ROLE = "circulate";

    
    struct Roles {
        address communityAddr;
        bytes32 adminRole;
        bytes32 redeemRole;
        bytes32 circulationRole;
    }

    Roles internal roles;

    function initialize(
        CommunitySettings calldata communitySettings_,
        address admin
    ) 
        initializer 
        external 
        override 
    {

        //setup 
        roles.communityAddr = communitySettings_.addr;
                
        if (roles.communityAddr == address(0)) {
            roles.adminRole = ADMIN_ROLE;
            roles.redeemRole = REDEEM_ROLE;
            roles.circulationRole = CIRCULATION_ROLE;
        } else {
            roles.adminRole = stringToBytes32(communitySettings_.adminRole);
            roles.redeemRole = stringToBytes32(communitySettings_.redeemRole);
            roles.circulationRole = stringToBytes32(communitySettings_.circulationRole);
        }
        
        _grantRole(roles.adminRole, admin);
        _setRoleAdmin(roles.redeemRole, roles.adminRole);
        _setRoleAdmin(roles.circulationRole, roles.adminRole);

        
    }

    function getRedeemRole(
    ) 
        external 
        view
        returns(bytes32)
    {
        return roles.redeemRole;
    }

    function checkRedeemRole(
        address account
    ) 
        external 
        view
    {
        _checkRole(roles.redeemRole, account);
    }

    function checkCirculationRole(
        address account
    ) 
        external
        view 
    {
        _checkRole(roles.circulationRole, account);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role, 
        address account
    ) 
        public 
        view 
        virtual 
        override 
        returns (bool) 
    {
        
        if (roles.communityAddr != address(0)) {

            // external call to community contract
            bytes32 keccakRole = keccak256(abi.encodePacked(role));
            bytes32 iKeccakRole;
            string[] memory communityRoles = ICommunity(roles.communityAddr).getRoles(account);

            for (uint256 i = 0; i < communityRoles.length; i++) {
                iKeccakRole = keccak256(abi.encodePacked(stringToBytes32(communityRoles[i])));
                if (keccakRole == iKeccakRole) {
                    return true;
                }
            }

        }
        return super.hasRole(role, account);
        
    }

    /**
     * convert string to bytes32
     * @param source string variable
     */
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }


}
// File: contracts/interfaces/IStructs.sol


pragma solidity ^0.8.11;

interface IStructs {
    struct StructAddrUint256 {
        address account;
        uint256 amount;
    }


}
// File: contracts/interfaces/ICommunityStakingPoolFactory.sol


pragma solidity ^0.8.0;


interface ICommunityStakingPoolFactory {
    
    
    struct InstanceInfo {
        address reserveToken;
        uint64 duration;
        uint64 bonusTokenFraction;
        address tradedToken;
        uint64 lpFraction;
        address lpFractionBeneficiary;
        uint64 numerator;
        uint64 denominator;
        bool exists;
        uint8 instanceType;
        address tokenErc20;
    }

    event InstanceCreated(address indexed tokenA, address indexed tokenB, address instance, uint instancesCount, address indexed erc20);

    function initialize(address impl, address implErc20) external;
    function getInstance(address reserveToken, address tradedToken, uint256 lockupIntervalCount) external view returns (address instance);
    function getInstanceErc20(address tokenErc20, uint256 lockupIntervalCount) external view returns (address instance);
    function instancesByIndex(uint index) external view returns (address instance);
    function instances() external view returns (address[] memory instances);
    function instancesCount() external view returns (uint);
    function produce(address reserveToken, address tradedToken, uint64 duration, uint64 bonusTokenFraction, IStructs.StructAddrUint256[] memory donations, uint64 lpFraction, address lpFractionBeneficiary, uint64 numerator, uint64 denominator) external returns (address instance);
    function produceErc20(address tokenErc20, uint64 duration, uint64 bonusTokenFraction, IStructs.StructAddrUint256[] memory donations, uint64 lpFraction, address lpFractionBeneficiary, uint64 numerator, uint64 denominator) external returns (address instance);
    function getInstanceInfoByPoolAddress(address addr) external view returns(InstanceInfo memory);
    function amountAfterSwapLP(address[] memory instancesToRedeem, uint256[] memory valuesToRedeem, address[][] memory swapPaths) external view returns(address, uint256);
}

// File: contracts/interfaces/ICommunityStakingPool.sol


pragma solidity ^0.8.0;


interface ICommunityStakingPool {
    
    function initialize(
        address stakingProducedBy_,
        address reserveToken_,
        address tradedToken_, 
        IStructs.StructAddrUint256[] memory donations_,
        uint64 lpFraction_,
        address lpFractionBeneficiary_
    ) external;
    /*
    function stake(address addr, uint256 amount) external;
    function getMinimum(address addr) external view returns(uint256);
    */
    function redeem(address account, uint256 amount) external;
    function redeemAndRemoveLiquidity(address account, uint256 amount) external;
}

// File: contracts/interfaces/ICommunityCoin.sol


pragma solidity ^0.8.0;

interface ICommunityCoin {
    
    function initialize(
        address poolImpl,
        address poolErc20Impl,
        address hook,
        address instancesImpl,
        uint256 discountSensitivity,
        address rolesManagementClone,
        address reserveToken,
        address tradedToken
    ) external;

    event InstanceCreated(address indexed tokenA, address indexed tokenB, address instance);
    event InstanceErc20Created(address indexed erc20token, address instance);

    function issueWalletTokens(address account, uint256 amount, uint256 priceBeforeStake) external;

}

// File: contracts/interfaces/IHook.sol


pragma solidity ^0.8.0;

interface IHook {
    function setupCaller() external;
    function claim(address account) external;
    function bonus(address instance, address account, uint64 duration, uint256 amount) external;
    function transferHook(address operator, address from, address to, uint256 amount) external returns(bool);


    
}
// File: contracts/CommunityCoinBase.sol


pragma solidity 0.8.11;







//import "./lib/PackedMapping32.sol";

//import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
//import "./interfaces/IERC20Dpl.sol";



//import "./minimums/upgradeable/MinimumsBaseUpgradeable.sol";



//import "hardhat/console.sol";


abstract contract CommunityCoinBase is 
    //OwnableUpgradeable, 
    TrustedForwarderUpgradeable,
    ICommunityCoin,
    ERC777Upgradeable, 
    
    //MinimumsBaseUpgradeable, 
    IERC777RecipientUpgradeable, 
    ReentrancyGuardUpgradeable
{
    using MinimumsLib for MinimumsLib.UserStruct;

    /**
    * strategy ENUM VARS used in calculation algos
    */
    enum Strategy{ UNSTAKE, UNSTAKE_AND_REMOVE_LIQUIDITY, REDEEM, REDEEM_AND_REMOVE_LIQUIDITY } 
    
    uint64 internal constant LOCKUP_INTERVAL = 24*60*60; // day in seconds
    uint64 internal constant LOCKUP_BONUS_INTERVAL = 1000*365*24*60*60; // 300 years in seconds
    uint64 internal constant FRACTION = 100000; // fractions are expressed as portions of this

    //uint64 public constant CIRCULATION_DURATION = 365*24*60*60; //year by default. will be used if circulation added to minimums

    IHook public hook; // hook used to bonus calculation

    ICommunityStakingPoolFactory public instanceManagment; // ICommunityStakingPoolFactory
    CommunityRolesManagement public rolesManagement; // ICommunityRolesManagement

    uint256 internal discountSensitivity;

    uint256 internal totalUnstakeable;
    uint256 internal totalRedeemable;
    //uint256 totalExtra;         // extra tokens minted by factory when staked

    address internal reserveToken;
    address internal tradedToken;

    // staked balance in instances. increase when stakes, descrease when unstake/redeem
    mapping(address => uint256) private _instanceStaked;

    //bytes32 private constant TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    //EnumerableSet.AddressSet private rewardTokensList;
    //mapping(address => uint256) public rewardTokenRatios;
    mapping(address => uint256) internal unstakeable;


    mapping(address => MinimumsLib.UserStruct) internal tokensLocked;
    mapping(address => MinimumsLib.UserStruct) internal tokensBonus;

    event RewardGranted(address indexed token, address indexed account, uint256 amount);
    event Staked(address indexed account, uint256 amount, uint256 priceBeforeStake);
   
    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * @param impl address of StakingPool implementation
    * @param implErc20 address of StakingPoolErc20 implementation
    * @param hook_ address of contract implemented IHook interface and used to calculation bonus tokens amount
    * @param communityCoinInstanceAddr address of contract that managed and cloned pools
    * @param discountSensitivity_ discountSensitivity value that manage amount tokens in redeem process. multiplied by `FRACTION`(10**5 by default)
    * @param rolesManagementAddr_ contract that would will manage roles(admin,redeem,circulate)
    * @param reserveToken_ address of reserve token. like a WETH, USDT,USDC, etc.
    * @param tradedToken_ address of traded token. usual it intercoin investor token
    * @custom:calledby StakingFactory contract 
    * @custom:shortd initializing contract. called by StakingFactory contract
    */
    function CommunityCoinBase__init(
        string memory tokenName,
        string memory tokenSymbol,
        address impl,
        address implErc20,
        address hook_,
        address communityCoinInstanceAddr,
        uint256 discountSensitivity_,
        address rolesManagementAddr_,
        address reserveToken_,
        address tradedToken_
    ) 
        onlyInitializing 
        internal 
    {
        //__Ownable_init();
        __TrustedForwarder_init();
        __ERC777_init(tokenName, tokenSymbol, (new address[](0)));

        //__AccessControl_init();
        __ReentrancyGuard_init();

        instanceManagment = ICommunityStakingPoolFactory(communityCoinInstanceAddr);//new ICommunityStakingPoolFactory(impl);
        instanceManagment.initialize(impl, implErc20);

        hook = IHook(hook_);

        discountSensitivity = discountSensitivity_;
        
        rolesManagement = CommunityRolesManagement(rolesManagementAddr_);

        reserveToken = reserveToken_;
        tradedToken = tradedToken_;

        // register interfaces
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    /**
    * @notice method to distribute tokens after user stake. called externally only by pool contract
    * @param account address of user that tokens will mint for
    * @param amount token's amount
    * @param priceBeforeStake price that was before adding liquidity in pool
    * @custom:calledby staking-pool
    * @custom:shortd distribute wallet tokens
    */
    function issueWalletTokens(
        address account, 
        uint256 amount, 
        uint256 priceBeforeStake
    ) 
        external 
        override
    {

        address instance = msg.sender; //here need a msg.sender as a real sender.

        // here need to know that is definetely StakingPool. because with EIP-2771 forwarder can call methods as StakingPool. 
        ICommunityStakingPoolFactory.InstanceInfo memory instanceInfo = instanceManagment.getInstanceInfoByPoolAddress(instance);
  
        require(instanceInfo.exists == true);
     
        uint256 bonusAmount = amount * instanceInfo.bonusTokenFraction / FRACTION;
        uint256 totalAmount = amount + bonusAmount;

        //forward conversion( LP -> СС)
        totalAmount = totalAmount * (10**instanceInfo.numerator) / (10**instanceInfo.denominator);
        bonusAmount = bonusAmount * (10**instanceInfo.numerator) / (10**instanceInfo.denominator);
        amount = amount * (10**instanceInfo.numerator) / (10**instanceInfo.denominator);

        _instanceStaked[instance] += totalAmount;


        if (address(hook) != address(0)) {
            hook.bonus(instance, account, instanceInfo.duration, amount);
        }
        //totalExtra += bonusAmount;
        
        unstakeable[account] += totalAmount;
        totalUnstakeable += totalAmount;
        
        // means extra tokens should not to include into unstakeable and totalUnstakeable, but part of them will be increase totalRedeemable
        // also keep in mind that user can unstake only unstakeable[account] which saved w/o bonusTokens, but minimums and mint with it.
        // it's provide to use such tokens like transfer but prevent unstake bonus in 1to1 after minimums expiring
        // amount += bonusAmount;


      
        _mint(account, totalAmount, "", "");
        emit Staked(account, totalAmount, priceBeforeStake);

        tokensLocked[account]._minimumsAdd(amount, instanceInfo.duration, LOCKUP_INTERVAL, false);
        tokensBonus[account]._minimumsAdd(bonusAmount, 1, LOCKUP_BONUS_INTERVAL, false);

    }
    
    /**
    * @notice method to adding tokens to circulation. called externally only by `CIRCULATION_ROLE`
    * @param amount token's amount
    * @custom:calledby `CIRCULATION_ROLE`
    * @custom:shortd distribute tokens
    */
    function addToCirculation(
        uint256 amount
    ) 
        external 
        nonReentrant
        //onlyRole(roles.circulationRole)
    {
        address account = _msgSender();

        rolesManagement.checkCirculationRole(account);
        
        _mint(account, amount, "", "");
        //_minimumsAdd(account, amount, CIRCULATION_DEFAULT, false);
    }

    /**
    * @notice method to removing tokens from circulation. called externally only by `CIRCULATION_ROLE`
    * @param amount token's amount
    * @custom:calledby `CIRCULATION_ROLE`
    * @custom:shortd remove tokens
    */
    function removeFromCirculation(
        uint256 amount
    ) 
        external 
        nonReentrant
        //onlyRole(roles.circulationRole)
    {
        address account = _msgSender();
        rolesManagement.checkCirculationRole(account);

        _burn(account, amount, "", "");
        //or
        //__redeem(account, account, amount, new address[](0), totalSupplyBefore, Strategy.REDEEM);
    }
  
    /**
    * @notice used to catch when used try to redeem by sending wallet tokens directly to contract
    * see more in {IERC777RecipientUpgradeable::tokensReceived}
    * @param operator address operator requesting the transfer
    * @param from address token holder address
    * @param to address recipient address
    * @param amount uint256 amount of tokens to transfer
    * @param userData bytes extra information provided by the token holder (if any)
    * @param operatorData bytes extra information provided by the operator (if any)
    * @custom:shortd part of {IERC777RecipientUpgradeable}
    */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) 
        external 
        override
    {

        require((_msgSender() == address(this) && to == address(this)), "own tokens permitted only");
        
        rolesManagement.checkRedeemRole(from);
        //_checkRole(roles.redeemRole, from);

        __redeem(address(this), from, amount, new address[](0), Strategy.REDEEM);
        
    }

    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    /**
    * @dev it's extended version for create instance pool available for owners only.
    * @param duration duration represented in amount of `LOCKUP_INTERVAL`
    * @param bonusTokenFraction fraction of bonus tokens multiplied by {CommunityStakingPool::FRACTION} that additionally distirbuted when user stakes
    * @param donations array of tuples donations. address,uint256. if array empty when coins will obtain sender, overwise donation[i].account  will obtain proportionally by ration donation[i].amount
    * @param lpFraction fraction of LP token multiplied by {CommunityStakingPool::FRACTION}. See more in {CommunityStakingPool::initialize}
    * @param lpFractionBeneficiary beneficiary's address which obtain lpFraction of LP tokens. if address(0) then it would be owner()
    * @param numerator used in conversion LP/CC
    * @param denominator used in conversion LP/CC
    * @return instance address of created instance pool `CommunityStakingPool`
    * @custom:calledby owner
    * @custom:shortd creation instance with extended options
    */
    function produce(
        uint64 duration, 
        uint64 bonusTokenFraction, 
        IStructs.StructAddrUint256[] memory donations,
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 numerator,
        uint64 denominator
    ) 
        public 
        onlyOwner() 
        returns (address instance) 
    {
        return _produce(duration, bonusTokenFraction, donations, lpFraction, lpFractionBeneficiary, numerator, denominator);
    }

    /**
    * @dev function for creation erc20 instance pool.
    * @param tokenErc20 address of erc20 token.
    * @param duration duration represented in amount of `LOCKUP_INTERVAL`
    * @param bonusTokenFraction fraction of bonus tokens multiplied by {CommunityStakingPool::FRACTION} that additionally distirbuted when user stakes
    * @param donations array of tuples donations. address,uint256. if array empty when coins will obtain sender, overwise donation[i].account  will obtain proportionally by ration donation[i].amount
    * @param lpFraction fraction of LP token multiplied by {CommunityStakingPool::FRACTION}. See more in {CommunityStakingPool::initialize}
    * @param lpFractionBeneficiary beneficiary's address which obtain lpFraction of LP tokens. if address(0) then it would be owner()
    * @return instance address of created instance pool `CommunityStakingPoolErc20`
    * @custom:shortd creation erc20 instance with simple options
    */
    function produce(       
        address tokenErc20, 
        uint64 duration, 
        uint64 bonusTokenFraction, 
        IStructs.StructAddrUint256[] memory donations, 
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 numerator, 
        uint64 denominator
    ) 
        public 
        onlyOwner() 
        returns (address instance) 
    {
        return _produce(tokenErc20, duration, bonusTokenFraction, donations, lpFraction, lpFractionBeneficiary, numerator, denominator);
    }

    /**
    * @notice method like redeem but can applicable only for own staked tokens that haven't transfer yet. so no need to have redeem role for this
    * @param amount The number of wallet tokens that will be unstaked.
    * @custom:shortd unstake own tokens
    */
    function unstake(
        uint256 amount
    ) 
        public 
        nonReentrant
    {
        address account = _msgSender();

        _validateUnstake(account, amount);
        
        _unstake(account, amount, new address[](0), Strategy.UNSTAKE);
        
    }

    function unstakeAndRemoveLiquidity(
        uint256 amount
    ) 
        public 
        nonReentrant
    {
        address account = _msgSender();

        _validateUnstake(account, amount);

        _unstake(account, amount, new address[](0), Strategy.UNSTAKE_AND_REMOVE_LIQUIDITY);
        
    }

    function _validateUnstake(
        address account, 
        uint256 amount
    ) 
        internal 
    {

        uint256 balance = balanceOf(account);
        
        require (amount <= balance, "INSUFFICIENT_BALANCE");
        
        uint256 locked = tokensLocked[account]._getMinimum();
        uint256 remainingAmount = balance - amount;
        require(locked <= remainingAmount, "STAKE_NOT_UNLOCKED_YET");

    }

    /**
    * @dev function has overloaded. wallet tokens will be redeemed from pools in order from deployed
    * @notice way to redeem via approve/transferFrom. Another way is send directly to contract. User will obtain uniswap-LP tokens
    * @param amount The number of wallet tokens that will be redeemed.
    * @custom:shortd redeem tokens
    */
    function redeem(
        uint256 amount
    ) 
        public
        nonReentrant
    {
        _redeem(_msgSender(), amount, new address[](0), Strategy.REDEEM);
    }

    /**
    * @dev function has overloaded. wallet tokens will be redeemed from pools in order from `preferredInstances`. tx reverted if amoutn is unsufficient even if it is enough in other pools
    * @notice way to redeem via approve/transferFrom. Another way is send directly to contract. User will obtain uniswap-LP tokens
    * @param amount The number of wallet tokens that will be redeemed.
    * @param preferredInstances preferred instances for redeem first
    * @custom:shortd redeem tokens with preferredInstances
    */
    function redeem(
        uint256 amount,
        address[] memory preferredInstances
    ) 
        public
        nonReentrant
    {
        _redeem(_msgSender(), amount, preferredInstances, Strategy.REDEEM);
    }

    /**
    * @dev function has overloaded. wallet tokens will be redeemed from pools in order from deployed
    * @notice way to redeem and remove liquidity via approve/transferFrom wallet tokens. User will obtain reserve and traded tokens back
    * @param amount The number of wallet tokens that will be redeemed.
    * @custom:shortd redeem tokens and remove liquidity
    */
    function redeemAndRemoveLiquidity(
        uint256 amount
    ) 
        public
        nonReentrant
    {
        _redeem(_msgSender(), amount, new address[](0), Strategy.REDEEM_AND_REMOVE_LIQUIDITY);
    }

    /**
    * @dev function has overloaded. wallet tokens will be redeemed from pools in order from `preferredInstances`. tx reverted if amoutn is unsufficient even if it is enough in other pools
    * @notice way to redeem and remove liquidity via approve/transferFrom wallet tokens. User will obtain reserve and traded tokens back
    * @param amount The number of wallet tokens that will be redeemed.
    * @param preferredInstances preferred instances for redeem first
    * @custom:shortd redeem tokens and remove liquidity with preferredInstances
    */
    function redeemAndRemoveLiquidity(
        uint256 amount,
        address[] memory preferredInstances
    ) 
        public
        nonReentrant
    {
        _redeem(_msgSender(), amount, preferredInstances, Strategy.REDEEM_AND_REMOVE_LIQUIDITY);
    }

    /**
    * @notice way to view locked tokens that still can be unstakeable by user
    * @param account address
    * @custom:shortd view locked tokens
    */
    function viewLockedWalletTokens(
        address account
    ) 
        public 
        view 
        returns (uint256 amount) 
    {
        amount = tokensLocked[account]._getMinimum()+tokensBonus[account]._getMinimum();
    }   

    function viewLockedWalletTokensList(
        address account
    ) 
        public 
        view 
        returns (uint256[][] memory, uint256[][] memory) 
    {
        return(
            tokensLocked[account]._getMinimumList(),
            tokensBonus[account]._getMinimumList()
        );
    }   

    function grantRole(bytes32 role, address account) onlyOwner() public {
        rolesManagement.grantRole(role, account);
    }
    
    function revokeRole(bytes32 role, address account) onlyOwner() public {
        rolesManagement.revokeRole(role, account);
    }

    /**
    * @dev calculate how much token user will obtain if redeem and remove liquidity token. 
    * There are steps:
    * 1. LP tokens swap to Reserved and Traded Tokens
    * 2. TradedToken swap to Reverved
    * 3. All Reserved tokens try to swap in order of swapPaths
    * @param account address which will be redeem funds from
    * @param amount liquidity tokens amount 
    * @param preferredInstances array of preferred Stakingpool instances which will be redeem funds from
    * @param swapPaths array of arrays uniswap swapPath
    * @return address destination address
    * @return uint256 destination amount
    */
    function simulateRedeemAndRemoveLiquidity(
        address account,
        uint256 amount, //amountLP,
        address[] memory preferredInstances,
        address[][] memory swapPaths
    )
        public 
        view 
        returns(address, uint256)
    {
        
        (address[] memory instancesToRedeem, uint256[] memory valuesToRedeem,/* uint256 len*/) = _poolStakesAvailable(
            account, 
            amount, 
            preferredInstances, 
            Strategy.REDEEM_AND_REMOVE_LIQUIDITY, 
            totalSupply()//totalSupplyBefore
        );

        return instanceManagment.amountAfterSwapLP(instancesToRedeem, valuesToRedeem, swapPaths);
    }

    function claim() public {
        if (address(hook) != address(0)) {
            hook.claim(_msgSender());
        }
    
    }
    
    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    
    function _produce(
        uint64 duration, 
        uint64 bonusTokenFraction,
        IStructs.StructAddrUint256[] memory donations,
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 numerator,
        uint64 denominator
    ) 
        internal
        returns (address instance) 
    {
        instance = instanceManagment.produce(
            reserveToken, 
            tradedToken, 
            duration, 
            bonusTokenFraction,
            donations,
            lpFraction, 
            lpFractionBeneficiary,
            numerator, 
            denominator
        );
        emit InstanceCreated(reserveToken, tradedToken, instance);
    }

    function _produce(
        address tokenErc20, 
        uint64 duration, 
        uint64 bonusTokenFraction,
        IStructs.StructAddrUint256[] memory donations,
        uint64 lpFraction,
        address lpFractionBeneficiary,
        uint64 numerator, 
        uint64 denominator
    ) 
        internal
        returns (address instance) 
    {
        instance = instanceManagment.produceErc20(
            tokenErc20, 
            duration, 
            bonusTokenFraction,
            donations, 
            lpFraction, 
            lpFractionBeneficiary,
            numerator,
            denominator
        );
        emit InstanceErc20Created(tokenErc20, instance);
    }

    function _unstake(
        address account,
        uint256 amount,
        address[] memory preferredInstances,
        Strategy strategy
    ) 
        internal 
    {
        uint256 totalSupplyBefore = _burn(account, amount);

        (address[] memory instancesList, uint256[] memory values, uint256 len) = _poolStakesAvailable(account, amount, preferredInstances, strategy, totalSupplyBefore);
        for (uint256 i = 0; i < len; i++) {
            _instanceStaked[instancesList[i]] -= values[i];

            proceedPool(
                account,
                instancesList[i],
                values[i],
                strategy,
                "Error when unstake"
            );
                        
        }

    }

    // create map of instance->amount or LP tokens that need to redeem
    function _poolStakesAvailable(
        address account,
        uint256 amount,
        address[] memory preferredInstances,
        Strategy strategy,
        uint256 totalSupplyBefore
    ) 
        internal 
        view
        returns(
            address[] memory instancesAddress, 
            uint256[] memory values,
            uint256 len
        ) 
    {
        ICommunityStakingPoolFactory.InstanceInfo memory instanceInfo;

        if (preferredInstances.length == 0) {
            preferredInstances = instanceManagment.instances();
        }

        instancesAddress = new address[](preferredInstances.length);
        values = new uint256[](preferredInstances.length);
        len = 0;
        uint256 amountToRedeem;

        uint256 amountLeft = amount;
        if (strategy == Strategy.REDEEM || strategy == Strategy.REDEEM_AND_REMOVE_LIQUIDITY) {
    
            // LPTokens =  WalletTokens * ratio;
            // ratio = A / (A + B * discountSensitivity);
            // где 
            // discountSensitivity - constant set in constructor
            // A = totalRedeemable across all pools
            // B = totalSupply - A - totalUnstakeable
            uint256 A = totalRedeemable;
            uint256 B = totalSupplyBefore - A - totalUnstakeable;
            // uint256 ratio = A / (A + B * discountSensitivity);
            // amountLeft =  amount * ratio; // LPTokens =  WalletTokens * ratio;

            // --- proposal from audit to keep precision after division
            // amountLeft = amount * A / (A + B * discountSensitivity / FRACTION);
            amountLeft = amountLeft * A * FRACTION;
            amountLeft = amountLeft / (A + B * discountSensitivity / FRACTION);
            amountLeft = amountLeft / FRACTION;

        }
        if (strategy == Strategy.UNSTAKE || strategy == Strategy.UNSTAKE_AND_REMOVE_LIQUIDITY) {
            require(totalSupplyBefore-tokensBonus[account]._getMinimum() >= amountLeft, "insufficient amount");
            // tokensLocked[account]._minimumsAdd(amount, instanceInfo.duration, LOCKUP_INTERVAL, false);
            // tokensBonus[account]._minimumsAdd(bonusAmount, instanceInfo.duration, LOCKUP_INTERVAL, false);
        }

        for (uint256 i = 0; i < preferredInstances.length; i++) {
            
            if (_instanceStaked[preferredInstances[i]] > 0) {
                if (strategy == Strategy.UNSTAKE || 
                    strategy == Strategy.UNSTAKE_AND_REMOVE_LIQUIDITY ) {
                    amountToRedeem = 
                        amountLeft > _instanceStaked[preferredInstances[i]]
                        ? 
                            _instanceStaked[preferredInstances[i]] > unstakeable[account]
                            ? 
                            unstakeable[account]
                            :
                            _instanceStaked[preferredInstances[i]]
                        : 
                        amountLeft;
                
                } else if (
                    strategy == Strategy.REDEEM || 
                    strategy == Strategy.REDEEM_AND_REMOVE_LIQUIDITY 
                ) {
                    amountToRedeem = 
                        amountLeft > _instanceStaked[preferredInstances[i]] 
                        ? 
                        _instanceStaked[preferredInstances[i]] 
                        : 
                        amountLeft
                        ;
                }
                
                if (amountToRedeem > 0) {

                    instancesAddress[len] = preferredInstances[i]; 
                    instanceInfo =  instanceManagment.getInstanceInfoByPoolAddress(preferredInstances[i]); // todo is exist there?
                    //backward conversion( СС -> LP)
                    values[len]  = amountToRedeem * (10**instanceInfo.denominator) / (10**instanceInfo.numerator);
                    
                    len += 1;

                    amountLeft -= amountToRedeem;
                }
            }

        }
        
        require(amountLeft == 0, "insufficient amount");

    }

    function _redeem(
        address account,
        uint256 amount,
        address[] memory preferredInstances,
        Strategy strategy
    ) 
        internal 
    {
        rolesManagement.checkRedeemRole(account);

        __redeem(account, account, amount, preferredInstances, strategy);
    }

    function _burn(
        address account,
        uint256 amount
    ) 
        internal 
        returns(uint256 totalSupplyBefore)
    {
        totalSupplyBefore = totalSupply();
        if (account != address(this)) {
            require(allowance(account, address(this))  >= amount, "Amount exceeds allowance");
        }
        _burn(account, amount, "", "");
    }
    
    function __redeem(
        address account2Burn,
        address account2Redeem,
        uint256 amount,
        address[] memory preferredInstances,
        Strategy strategy
    ) 
        internal 
    {

        uint256 totalSupplyBefore = _burn(account2Burn, amount);
        require (amount <= totalRedeemable, "INSUFFICIENT_BALANCE");
        (address[] memory instancesToRedeem, uint256[] memory valuesToRedeem, uint256 len) = _poolStakesAvailable(account2Redeem, amount, preferredInstances, strategy/*Strategy.REDEEM*/, totalSupplyBefore);

        for (uint256 i = 0; i < len; i++) {
            if (_instanceStaked[instancesToRedeem[i]] > 0) {
                _instanceStaked[instancesToRedeem[i]] -= valuesToRedeem[i];
                totalRedeemable -= valuesToRedeem[i];

                proceedPool(
                    account2Redeem,
                    instancesToRedeem[i],
                    valuesToRedeem[i],
                    strategy,
                    "Error when redeem in an instance"
                );
            }
        }
    }

    function proceedPool(address account,address pool, uint256 amount, Strategy strategy, string memory errmsg) internal {
        if (strategy == Strategy.REDEEM || strategy == Strategy.UNSTAKE) {

            try ICommunityStakingPool(pool).redeem(
                account, 
                amount
            ) {
                // _instanceStaked[pool] -= amount;
                // totalRedeemable -= amount;
            }
            catch {
                revert(errmsg);
            }
        } else if (strategy == Strategy.UNSTAKE_AND_REMOVE_LIQUIDITY || strategy == Strategy.REDEEM_AND_REMOVE_LIQUIDITY) {
            try ICommunityStakingPool(pool).redeemAndRemoveLiquidity(
                account, 
                amount
            ) {
                // _instanceStaked[pool] -= valuesToRedeem[i];
                // totalRedeemable -= valuesToRedeem[i];
            }
            catch {
                revert(errmsg);
            }
        // } else {
        //     revert("unknown strategy");
        }
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) 
        internal 
        virtual 
        override 
    {
        if (from !=address(0)) { // otherwise minted
            if (from == address(this) && to == address(0)) { // burnt by contract itself

            } else { 
                // todo 0:   add transferhook
                //  can return true/false
                // true = revert ;  false -pass tx 
                if (address(hook) != address(0)) {
                    require(hook.transferHook(operator, from, to, amount), "HOOK: TRANSFER_PREVENT");
                }

                uint256 balance = balanceOf(from);

                if (balance >= amount) {
               
                    uint256 remainingAmount = balance - amount;
                    
                    if (
                        to == address(0) || // if burnt
                        to == address(this) // if send directly to contract
                    ) {
                        //require(amount <= totalRedeemable, "STAKE_NOT_UNLOCKED_YET");
                    } else {
                        // else it's just transfer
                        // unstakeable[from] means as locked var. but not equal: locked can be less than unstakeable[from]
                        
                        
                        uint256 locked = tokensLocked[from]._getMinimum();
                        uint256 lockedBonus = tokensBonus[from]._getMinimum();
                        //else drop locked minimum, but remove minimums even if remaining was enough
                        //minimumsTransfer(account, ZERO_ADDRESS, (locked - remainingAmount))
                        if (locked+lockedBonus > 0 && locked+lockedBonus >= amount ) {
                            if (lockedBonus >= amount) {
                                tokensBonus[from].minimumsTransfer(tokensLocked[address(0)], true, amount);
                            } else {
                                uint256 left = amount;
                                if (lockedBonus > 0) {
                                    tokensBonus[from].minimumsTransfer(tokensLocked[address(0)], true, lockedBonus);
                                    left-= lockedBonus;
                                }
                                tokensLocked[from].minimumsTransfer(tokensLocked[address(0)], true, left);
                            }
                            
                        }
                        //-----------------------------------
                        // uint256 r = unstakeable[from] - remainingAmount;
                        // unstakeable[from] -= r;
                        // totalUnstakeable -= r;
                        // totalRedeemable += r;
                        // -------
                        // total supply should be equal sum of totalUnstakeable and totalRedeemable.
                        // it's works before owner will add some to circulate.
                        // circulation tokens is not part of unstakeable or redeemable. it's tokens emission mechanism.
                        // so any time when user transfer somth and have not enough unstakeable tokens, we will not calculate unstakeable and redeemable

                        if (unstakeable[from] >= remainingAmount) {
                            uint256 r = unstakeable[from] - remainingAmount;
                            // if (totalUnstakeable >= r) {
                            unstakeable[from] -= r;
                            totalUnstakeable -= r;
                            totalRedeemable += r;
                            // }
                        }
                    }
                    
                } else {
                    // insufficient balance error would be in {ERC777::_move}
                }
            }
        }
        super._beforeTokenTransfer(operator, from, to, amount);

    }

    /**
    * @dev implemented EIP-2771
    * @return signer return address of msg.sender. but consider EIP-2771 for trusted forwarder will return from msg.data payload
    */
    function _msgSender(
    ) 
        internal 
        view 
        virtual
        override(ContextUpgradeable, TrustedForwarderUpgradeable)
        returns (address signer) 
    {
        return TrustedForwarderUpgradeable._msgSender();
    }

    
    
}

// File: contracts/CommunityCoin.sol


pragma solidity 0.8.11;


contract CommunityCoin is CommunityCoinBase {

    /**
    * @param impl address of StakingPool implementation
    * @param implErc20 address of StakingPoolErc20 implementation
    * @param hook_ address of contract implemented IHook interface and used to calculation bonus tokens amount
    * @param communityCoinInstanceAddr address of contract that managed and cloned pools
    * @param discountSensitivity_ discountSensitivity value that manage amount tokens in redeem process. multiplied by `FRACTION`(10**5 by default)
    * @param rolesManagementAddr_ contract that would will manage roles(admin,redeem,circulate)
    * @param reserveToken_ address of reserve token. like a WETH, USDT,USDC, etc.
    * @param tradedToken_ address of traded token. usual it intercoin investor token
    * @custom:calledby StakingFactory contract 
    * @custom:shortd initializing contract. called by StakingFactory contract
    */
    function initialize(
        address impl,
        address implErc20,
        address hook_,
        address communityCoinInstanceAddr,
        uint256 discountSensitivity_,
        address rolesManagementAddr_,
        address reserveToken_,
        address tradedToken_
    ) 
        initializer 
        external 
        virtual
        override 
    {
        CommunityCoinBase__init(
            // "Staking Tokens", 
            // "STAKE", 
            string(abi.encodePacked(IERC777Upgradeable(tradedToken_).name(), " commnunity")), 
            string(abi.encodePacked(IERC777Upgradeable(tradedToken_).symbol(), " c")), 
            impl, 
            implErc20, 
            hook_, 
            communityCoinInstanceAddr, 
            discountSensitivity_, 
            rolesManagementAddr_, 
            reserveToken_, 
            tradedToken_
        );
    }
}