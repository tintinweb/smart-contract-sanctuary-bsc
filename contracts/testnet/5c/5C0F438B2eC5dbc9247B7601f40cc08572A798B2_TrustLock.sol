// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";



abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract TrustLock is ReentrancyGuard {  
    

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    struct LockedAmount {
        uint256 id;
        uint256 startTS;
        uint256 endTS;
        uint256 amountToUnlock;
        bool claimed;
        uint256 claimedTS;
        uint256 claimedPart;
        address allowedClaimAddress;
    }


    struct Lock {
        string description;
        address token;
        bool isLiquidity;
        address owner;
        bool setupFinished;
        bool cancelled;
        uint256 lockedAmountsCount;
        uint256 totalTokens;
        address pair0;
        address pair1;
        uint256 id;
        uint256 decimals0;
        string symbol0;
        string symbol1;
        string name0;
        string name1;
    }
    mapping(uint256 => mapping(uint256 => LockedAmount)) lockedAmounts;
    mapping(address => uint256) totalTokenAmounts;

    EnumerableSet.AddressSet private liquidityLockedAddresses;
    EnumerableSet.AddressSet private normalLockedAddresses;


    mapping(uint256 => Lock) private locks;

    uint256 public lockCounter = 0;


    mapping(address => EnumerableSet.UintSet) private tokenLocks;
    mapping(address => EnumerableSet.UintSet) private userLocks;

    event LockCreated (
        address indexed token,
        uint256 totalAmount,
        string description,
        uint256 indexed lockId,
        bool indexed isLiquidity
   );

    event LockUpdated (
        address indexed token,
        uint256 totalAmount,
        string description,
        uint256 indexed lockId
   );

   event LockCancelled (
        address indexed token,
        uint256 lockId
   );

  event OwnerTransferred (
        address indexed token,
        uint256 indexed lockId,
        address newOwner
   );

  event SetupFinished (
        address indexed token,
        uint256 indexed lockId
   );

   event AmountClaimed (
        uint256 lockId,
        address indexed tokenReceiver,
        uint256 amount,
        uint256 amountId,
        bool safeTransfer
   );

   event AmountClaimedPartially (
        uint256 lockId,
        address indexed tokenReceiver,
        uint256 amount,
        uint256 amountId,
        bool safeTransfer
   );




    constructor() {
    
    }


    function safeTokenTransfer(address tokenAddress, address sender, address recipient, uint256 amount) internal {
        IERC20 Itoken = IERC20(tokenAddress);
        if( address(this) == sender) {
            Itoken.approve(address(this), MAX_INT);
        }
        uint256 oldRecipientBalance = Itoken.balanceOf(recipient);
        Itoken.transferFrom(sender, recipient, amount);
        uint256 newRecipientBalance = Itoken.balanceOf(recipient);
        require(
            newRecipientBalance - oldRecipientBalance == amount,
            "Transfer was not successfull"
        );
    }

    function getTotalLocks() public view returns(uint256 total) {
        return lockCounter;
    }

    function getLockedAmount(uint256 lockId, uint256 index) public view returns (LockedAmount memory _lockedAmounts) {
        return lockedAmounts[lockId][index];
    }

    function getLockedAmounts(uint256 lockId, uint256 from, uint256 to) public view returns (LockedAmount[] memory _lockedAmounts) {

        if( to > locks[lockId].lockedAmountsCount) {
            to = locks[lockId].lockedAmountsCount;
        }

        uint256 length = to - from;
        LockedAmount[] memory amountsReturn = new LockedAmount[](length);

        uint256 counter = 0;
        for (from; from < to; from++) {
            amountsReturn[counter] = lockedAmounts[lockId][from];
            counter++;
        }
        return amountsReturn;
    }

    function getTotalLPAddressCount() public view returns (uint256) {
        return liquidityLockedAddresses.length();
    }

    function getTotalNormalAddressCount() public view returns (uint256) {
        return normalLockedAddresses.length();
    }

    function _findLocksFromArray(EnumerableSet.UintSet storage arrayToSearch, uint256 start,uint256 end) private view returns(Lock[] memory) {
        if (end > arrayToSearch.length()) {
            end = arrayToSearch.length();
        }
        uint256 length = end - start;
        Lock[] memory locksToReturn = new Lock[](length);
        uint256 currentIndex = 0;
        for (uint256 i = start; i < end; i++) {
            locksToReturn[currentIndex] = getLockById(arrayToSearch.at(i));
            currentIndex++;
        }
        return locksToReturn;   
    }

    function getTotalLocksForToken(
        address token
    ) public view returns (uint256 total) {
        return tokenLocks[token].length();
    }


    function getTotalLocksForUser(
        address userAddress
    ) public view returns (uint256 total) {
        return userLocks[userAddress].length();
    }

    function getLocksForToken(
        address token,
        uint256 start,
        uint256 end
    ) public view returns (Lock[] memory) {
        return _findLocksFromArray(tokenLocks[token], start, end);
    }

    function getLocksForUser(
        address userAddress,
        uint256 start,
        uint256 end
    ) public view returns (Lock[] memory) {
        return _findLocksFromArray(userLocks[userAddress], start, end);
    }

    function getLockById(uint256 lockId) public view returns (Lock memory) {
        return locks[lockId];
    }

    function transferOwnership(uint256 lockId, address newOwner) public nonReentrant {
        require(locks[lockId].owner == msg.sender,"You are not owner");
        require(!locks[lockId].setupFinished, "Cannot delete lock, because it is finished");
        require(!locks[lockId].cancelled, "Cannot update lock, because it is cancelled");
        locks[lockId].owner = msg.sender;
        emit OwnerTransferred(locks[lockId].token, lockId, newOwner);
    }

    function setupFinished(uint256 lockId) external nonReentrant {
        require(locks[lockId].owner == msg.sender,"You are not owner");
        require(!locks[lockId].setupFinished, "Cannot finish lock, because it is finished");
        require(!locks[lockId].cancelled, "Cannot finish lock, because it is cancelled");
        locks[lockId].setupFinished = true;
        emit SetupFinished(locks[lockId].token, lockId);
    }


    function deleteLock(uint256 lockId) public nonReentrant {
        require(locks[lockId].owner == msg.sender,"You are not owner");
        require(!locks[lockId].setupFinished, "Cannot delete lock, because it is finished");
        require(!locks[lockId].cancelled, "Cannot delete lock, because it is cancelled");
        for(uint256 oldDataIndex = 0; oldDataIndex < locks[lockId].lockedAmountsCount; oldDataIndex++) {
            userLocks[lockedAmounts[lockId][oldDataIndex].allowedClaimAddress].remove(lockId);
            delete lockedAmounts[lockId][oldDataIndex];
        }

        totalTokenAmounts[locks[lockId].token] = totalTokenAmounts[locks[lockId].token] - locks[lockId].totalTokens;        

        if( totalTokenAmounts[locks[lockId].token] == 0) {
            if( locks[lockId].isLiquidity) {
                liquidityLockedAddresses.remove(locks[lockId].token);
            }
            else{
                normalLockedAddresses.remove(locks[lockId].token);
            }
        }

        userLocks[msg.sender].remove(lockId);
        tokenLocks[locks[lockId].token].remove(lockId);
        locks[lockId].cancelled = true;
        safeTokenTransfer(locks[lockId].token, address(this), msg.sender,  locks[lockId].totalTokens);
        locks[lockId].totalTokens = 0;

        emit LockCancelled(locks[lockId].token, lockId);

    }


    function claimTokens(uint256 lockId,uint256 amountId, bool doSafeTransfer) public nonReentrant {
        require(lockedAmounts[lockId][amountId].allowedClaimAddress == msg.sender,"You are not allowed to claim");
        require(locks[lockId].setupFinished, "Cannot claim, lock have not finished setup");
        require(!lockedAmounts[lockId][amountId].claimed,"Already claimed");
        require(lockedAmounts[lockId][amountId].endTS < block.timestamp,"Please wait");
        require(lockedAmounts[lockId][amountId].amountToUnlock > 0, "no Amount");

        lockedAmounts[lockId][amountId].claimed = true;
        lockedAmounts[lockId][amountId].claimedTS = block.timestamp;
        if( doSafeTransfer) {
            safeTokenTransfer(locks[lockId].token, address(this), msg.sender,  lockedAmounts[lockId][amountId].amountToUnlock);
        }
        else {
            IERC20 Itoken = IERC20(locks[lockId].token);
            Itoken.approve(address(this), MAX_INT);
            Itoken.transferFrom(address(this), msg.sender, lockedAmounts[lockId][amountId].amountToUnlock);
        }
        emit AmountClaimed(lockId, msg.sender, lockedAmounts[lockId][amountId].amountToUnlock, amountId, doSafeTransfer);
    }

    function claimTokensPartAmount(uint256 lockId,uint256 amountId, bool doSafeTransfer, uint256 amount ) public nonReentrant {
        require(lockedAmounts[lockId][amountId].allowedClaimAddress == msg.sender,"You are not allowed to claim");
        require(locks[lockId].setupFinished, "Cannot claim, lock have not finished setup");
        require(!lockedAmounts[lockId][amountId].claimed,"Already claimed");
        require(lockedAmounts[lockId][amountId].endTS < block.timestamp,"Please wait");
        require(amount > 0, "Bad amount, zero");
        require(lockedAmounts[lockId][amountId].amountToUnlock != amount, "Cannot partially claim exact remaining amount, use claimTokens() instead");
        require(lockedAmounts[lockId][amountId].amountToUnlock > amount, "Bad amount");

        if( doSafeTransfer) {
            safeTokenTransfer(locks[lockId].token, address(this), msg.sender,  lockedAmounts[lockId][amountId].amountToUnlock);
        }
        else {
            IERC20 Itoken = IERC20(locks[lockId].token);
            Itoken.approve(address(this), MAX_INT);
            Itoken.transferFrom(address(this), msg.sender, lockedAmounts[lockId][amountId].amountToUnlock);
        }
        lockedAmounts[lockId][amountId].amountToUnlock = lockedAmounts[lockId][amountId].amountToUnlock - amount;
        lockedAmounts[lockId][amountId].claimedPart = lockedAmounts[lockId][amountId].claimedPart + amount;
        emit AmountClaimedPartially(lockId, msg.sender, lockedAmounts[lockId][amountId].amountToUnlock, amountId, doSafeTransfer);

    }

    function setNewEndTSAtLockAllAmounts(uint256 lockId, uint256 newReleaseTS) public {
        require(locks[lockId].setupFinished, "Cannot update lock, because it not finished");
        require(!locks[lockId].cancelled, "Cannot update lock, because it is cancelled");
        for(uint256 a = 0; a < locks[lockId].lockedAmountsCount; a++) {
            if(lockedAmounts[lockId][a].allowedClaimAddress == msg.sender && 
            newReleaseTS >= lockedAmounts[lockId][a].endTS && 
            !lockedAmounts[lockId][a].claimed) {
                lockedAmounts[lockId][a].endTS = newReleaseTS;
            }
        }
    }

    function setNewEndTSAtLockAmountIndex(uint256 lockId, uint256 newReleaseTS, uint256 amountIndex) public {
        require(locks[lockId].setupFinished, "Cannot update lock, because it not finished");
        require(!locks[lockId].cancelled, "Cannot update lock, because it is cancelled");
        require(locks[lockId].lockedAmountsCount > amountIndex, "Bad Index");

        if(lockedAmounts[lockId][amountIndex].allowedClaimAddress == msg.sender && 
            newReleaseTS >= lockedAmounts[lockId][amountIndex].endTS && 
            !lockedAmounts[lockId][amountIndex].claimed) {
            lockedAmounts[lockId][amountIndex].endTS = newReleaseTS;
        }
    }

    function updateLock(uint256 lockId, uint256[] memory amounts, address[] memory addresses, uint256[] memory releaseTS, string memory description) public nonReentrant {
        require(locks[lockId].owner == msg.sender,"You are not owner");
        require(!locks[lockId].setupFinished, "Cannot update lock, because it is finished");
        require(!locks[lockId].cancelled, "Cannot update lock, because it is cancelled");
    
        require(amounts.length > 0 && amounts.length == addresses.length && amounts.length == releaseTS.length && amounts.length <= 100, "Bad lengths");

        for(uint256 oldDataIndex = 0; oldDataIndex < locks[lockId].lockedAmountsCount; oldDataIndex++) {
            userLocks[lockedAmounts[lockId][oldDataIndex].allowedClaimAddress].remove(lockId);
            delete lockedAmounts[lockId][oldDataIndex];
        }
        uint256 totalTokensNeeded = 0;
        for(uint256 a = 0; a < amounts.length; a++) {
            require(releaseTS[a] > block.timestamp, "Bad timestamp");
            require(amounts[a] > 0, "Bad amount");
            lockedAmounts[lockId][a].id = a;
            lockedAmounts[lockId][a].startTS = block.timestamp;
            lockedAmounts[lockId][a].endTS = releaseTS[a];
            lockedAmounts[lockId][a].amountToUnlock = amounts[a];
            lockedAmounts[lockId][a].claimed = false;
            lockedAmounts[lockId][a].claimedTS = 0;
            lockedAmounts[lockId][a].allowedClaimAddress = addresses[a];
            totalTokensNeeded = totalTokensNeeded + amounts[a];                        
            userLocks[addresses[a]].add(lockId);
        }

        if( totalTokensNeeded != locks[lockId].totalTokens){
            if( totalTokensNeeded > locks[lockId].totalTokens)
            {
                safeTokenTransfer(locks[lockId].token, msg.sender, address(this), totalTokensNeeded - locks[lockId].totalTokens);
            }
            else{
                safeTokenTransfer(locks[lockId].token, address(this), msg.sender,  locks[lockId].totalTokens - totalTokensNeeded);
            }
            totalTokenAmounts[locks[lockId].token] = totalTokenAmounts[locks[lockId].token] + totalTokensNeeded - locks[lockId].totalTokens;        
            locks[lockId].totalTokens = totalTokensNeeded;
        }

        locks[lockId].description = description;
        locks[lockId].lockedAmountsCount = amounts.length;

    

        emit LockUpdated(locks[lockId].token, totalTokensNeeded, description, lockId);

    }

    function isLiquidityToken(address target) public view returns (bool) {
        if (target.code.length == 0) {
            return false;
        }

        IUniswapV2Pair pairContract = IUniswapV2Pair(target);

        address token0;
        address token1;

        try pairContract.token0() returns (address _token0) {
            token0 = _token0;
        } catch (bytes memory) {
            return false;
        }

        try pairContract.token1() returns (address _token1) {
            token1 = _token1;
        } catch (bytes memory) {
            return false;
        }
        return target == IUniswapV2Factory(IUniswapV2Pair(target).factory()).getPair(token0, token1);
    }

    function createLiquidityLock(address tokenAddress, uint256 amount, address addr, uint256 releaseTS, string memory description) external returns (uint256 _newId) {
        uint256[] memory _amnt = new uint256[](1);
        _amnt[0] = amount;
        address[] memory _addr = new address[](1);
        _addr[0] = addr;
        uint256[] memory _rel = new uint256[](1);
        _rel[0] = releaseTS;
        return createLock(tokenAddress, _amnt, _addr, _rel, description, true);
    }

    function createLock(address tokenAddress, uint256[] memory amounts, address[] memory addresses, uint256[] memory releaseTS, string memory description, bool isLiquidityPoolToken) public nonReentrant returns (uint256 _newId) {
        require(amounts.length > 0 && amounts.length == addresses.length && amounts.length == releaseTS.length && amounts.length <= 100, "Bad lengths");
        

        uint256 totalTokensNeeded = 0;
        uint256 newLockId = lockCounter;
        userLocks[msg.sender].add(newLockId);
        tokenLocks[tokenAddress].add(newLockId);
 
        for(uint256 a = 0; a < amounts.length; a++) {
            require(releaseTS[a] > block.timestamp, "Bad timestamp");
            require(amounts[a] > 0, "Bad amount");
            lockedAmounts[newLockId][a].id = a;
            lockedAmounts[newLockId][a].startTS = block.timestamp;
            lockedAmounts[newLockId][a].endTS = releaseTS[a];
            lockedAmounts[newLockId][a].amountToUnlock = amounts[a];
            lockedAmounts[newLockId][a].claimed = false;
            lockedAmounts[newLockId][a].claimedTS = 0;
            lockedAmounts[newLockId][a].allowedClaimAddress = addresses[a];
            totalTokensNeeded = totalTokensNeeded + amounts[a];                        
            userLocks[addresses[a]].add(newLockId);
        }

        safeTokenTransfer(tokenAddress, msg.sender, address(this), totalTokensNeeded);


        locks[newLockId].id = newLockId;
        locks[newLockId].token = tokenAddress;
        locks[newLockId].owner = msg.sender;
        locks[newLockId].totalTokens = totalTokensNeeded;
        locks[newLockId].description = description;
        locks[newLockId].isLiquidity = isLiquidityPoolToken;


        locks[newLockId].lockedAmountsCount = amounts.length;



        totalTokenAmounts[tokenAddress] = totalTokenAmounts[tokenAddress] + totalTokensNeeded;
        if( isLiquidityPoolToken && isLiquidityToken(tokenAddress)) {
            liquidityLockedAddresses.add(tokenAddress);
            address token0;
            address token1;
            IUniswapV2Pair pairContract = IUniswapV2Pair(tokenAddress);

            try pairContract.token0() returns (address _token0) {
                token0 = _token0;
            } catch (bytes memory) {
            }

            try pairContract.token1() returns (address _token1) {
                token1 = _token1;
            } catch (bytes memory) {
            }
            locks[newLockId].pair0 = token0;
            locks[newLockId].pair1 = token1;

            tokenLocks[token0].add(newLockId);
            tokenLocks[token1].add(newLockId);

            ERC20 TCLiquidity = ERC20(tokenAddress);
            locks[newLockId].decimals0 = TCLiquidity.decimals();
            

            ERC20 TC0 = ERC20(token0);
            locks[newLockId].symbol0 = TC0.symbol();
            locks[newLockId].name0 = TC0.name();

            ERC20 TC1 = ERC20(token1);
            locks[newLockId].symbol1 = TC1.symbol();
            locks[newLockId].name1 = TC1.name();
        }
        else{
            normalLockedAddresses.add(tokenAddress);
            ERC20 TC = ERC20(tokenAddress);
            locks[newLockId].symbol0 = TC.symbol();
            locks[newLockId].name0 = TC.name();
            locks[newLockId].decimals0 = TC.decimals();
        }
        lockCounter = lockCounter + 1;

        emit LockCreated(tokenAddress, totalTokensNeeded, description, newLockId, isLiquidityPoolToken);
        return newLockId;
    }

}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
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
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}