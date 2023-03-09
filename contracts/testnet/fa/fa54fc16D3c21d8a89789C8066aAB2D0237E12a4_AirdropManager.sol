pragma solidity ^0.8.11;
    // SPDX-License-Identifier: MIT

    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes memory) {
            this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
            return msg.data;
        }
    }

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
    contract Ownable is Context {
        address private _owner;
        address private _previousOwner;
        uint256 private _lockTime;

        event OwnershipTransferred(
            address indexed previousOwner,
            address indexed newOwner
        );

        /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
        constructor() {
            address msgSender = _msgSender();
            _owner = msgSender;
            emit OwnershipTransferred(address(0), msgSender);
        }

        /**
        * @dev Returns the address of the current owner.
        */
        function owner() public view returns (address) {
            return _owner;
        }

        /**
        * @dev Throws if called by any account other than the owner.
        */
        modifier onlyOwner() {
            require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
            emit OwnershipTransferred(_owner, address(0));
            _owner = address(0);
        }

        /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        * Can only be called by the current owner.
        */
        function transferOwnership(address newOwner) public virtual onlyOwner {
            require(
                newOwner != address(0),
                "Ownable: new owner is the zero address"
            );
            emit OwnershipTransferred(_owner, newOwner);
            _owner = newOwner;
        }
    }
    interface PoolInit {
    
        function initialize(    address[] memory _admin,
            address _router,
            uint256[] memory listInfo,
            uint256[] memory poolInfo,
            uint256 lengthAdmin,
            address _token,
            address _poolOwner,
            uint8 _unsoldTokens,
            uint8 _type,
            string memory _desc,
            string[] memory _links,
            uint256[] memory _feeList,
            address _superAdmin,
            uint256 totalTokensNeed) external;
    }

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
        */
        function isContract(address account) internal view returns (bool) {
            // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
            // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
            // for accounts without code, i.e. `keccak256('')`
            bytes32 codehash;
            bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                codehash := extcodehash(account)
            }
            return (codehash != accountHash && codehash != 0x0);
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
            require(
                address(this).balance >= amount,
                "Address: insufficient balance"
            );

            // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
            (bool success, ) = recipient.call{value: amount}("");
            require(
                success,
                "Address: unable to send value, recipient may have reverted"
            );
        }

        /**
        * @dev Performs a Solidity function call using a low level `call`. A
        * plain`call` is an unsafe replacement for a function call: use this
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
        function functionCall(address target, bytes memory data)
            internal
            returns (bytes memory)
        {
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
            return _functionCallWithValue(target, data, 0, errorMessage);
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
            return
                functionCallWithValue(
                    target,
                    data,
                    value,
                    "Address: low-level call with value failed"
                );
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
            require(
                address(this).balance >= value,
                "Address: insufficient balance for call"
            );
            return _functionCallWithValue(target, data, value, errorMessage);
        }

        function _functionCallWithValue(
            address target,
            bytes memory data,
            uint256 weiValue,
            string memory errorMessage
        ) private returns (bytes memory) {
            require(isContract(target), "Address: call to non-contract");

            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory returndata) = target.call{value: weiValue}(
                data
            );
            if (success) {
                return returndata;
            } else {
                // Look for revert reason and bubble it up if present
                if (returndata.length > 0) {
                    // The easiest way to bubble the revert reason is using memory via assembly

                    // solhint-disable-next-line no-inline-assembly
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
    abstract contract ReentrancyGuard {
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

        constructor() {
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
    }
    interface IFactoryManager {
    function assignAirdropToOwner(address owner, address pool) external;
    function addUniquePool(address pool) external;
    function addUniqueParticipant(address participant) external;
    function addUserToPool(address user, address pool) external;
    function removeUserFromPool(address pool) external;
    }

    library Clones {
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

    contract PoolFactoryBase is Ownable, ReentrancyGuard {
    
    using Address for address payable;

    address public factoryManager;
    address public implementation;
    address public feeTo;
    uint256 public flatFee;

    event PoolCreated(
        address indexed owner,
        address indexed token
    );

    modifier enoughFee() {
        require(msg.value >= flatFee, "Flat fee");
        _;
    }

    constructor(address factoryManager_, address implementation_) {
        factoryManager = factoryManager_;
        implementation = implementation_;
        feeTo = msg.sender;
        flatFee = 1 ether;
    }

    function setImplementation(address implementation_) external onlyOwner {
        implementation = implementation_;
    }

    function setFeeTo(address feeReceivingAddress) external onlyOwner {
        feeTo = feeReceivingAddress;
    }

    function setFlatFee(uint256 fee) external onlyOwner {
        flatFee = fee;
    }

    function assignAirdropToOwner(address owner, address pool) internal {
        IFactoryManager(factoryManager).assignAirdropToOwner(owner, pool);
    }

    function addUniquePool(address pool) internal {
        IFactoryManager(factoryManager).addUniquePool(pool);
    }

    function addUniqueParticipant(address participant) internal {
        IFactoryManager(factoryManager).addUniqueParticipant(participant);
    }

    function addUserToPool(address user, address pool) internal {
        IFactoryManager(factoryManager).addUserToPool(user, pool);
    }

    function removeUserFromPool(address pool) internal {
        IFactoryManager(factoryManager).removeUserFromPool(pool);
    }


    function refundExcessiveFee() internal {
        uint256 refund = msg.value -flatFee;
        if (refund > 0) {
        payable(msg.sender).sendValue(refund);
        }
    }
    }
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

    
contract AirdropManager is Ownable, IFactoryManager {
    using EnumerableSet for EnumerableSet.AddressSet;


        EnumerableSet.AddressSet private airdropFactory;
        EnumerableSet.AddressSet private participants;
        
        mapping(address => address[]) private poolOf;
        address public feeAddress;
        address public lockAddress;
        EnumerableSet.AddressSet private listPools;

        mapping(address => mapping(address => bool)) private hasPool;
        mapping(address => bool) public isAdmin;
        address public superAdmin;
        mapping(address => bool) private isGenerated;

        uint256 public totalContributions;
        uint256 public uniqueParticipants;
        mapping(address => bool) public isUniqueParticipant;
        mapping(address => address[]) public userPool;
        EnumerableSet.AddressSet private uniquePools;

    uint public lengthPools = 0;
    modifier onlyAllowedAirdropFactory() {
        require(airdropFactory.contains(msg.sender), "Not a whitelisted airdrop factory");
        _;
    }
    modifier onlyOwnerOrSuperAdmin() {
        require(owner() == msg.sender || superAdmin == msg.sender,"Only owner or superadmin");
        _;
    }

    modifier onlyUniquePool() {
        require(uniquePools.contains(msg.sender), "Not a whitelisted pool");
        _;
    }


    function addUniquePool(address _pool) external onlyAllowedAirdropFactory {
        uniquePools.add(_pool);
        lengthPools = uniquePools.length();
    }

    function addUniqueParticipant(address _user) external onlyUniquePool{
        if (!isUniqueParticipant[_user]) {
            isUniqueParticipant[_user] = true;
            uniqueParticipants++;
        }
    }

    function addUserToPool(address _user, address _pool) external onlyUniquePool{
        if (userPool[_user].length == 0) {
            userPool[_user].push(_pool);
        } else {
            bool isExist = false;
            for (uint256 i = 0; i < userPool[_user].length; i++) {
                if (userPool[_user][i] == _pool) {
                    isExist = true;
                    break;
                }
            }
            if (!isExist) {
                userPool[_user].push(_pool);
            }
        }
    }

    function removeUserFromPool(address _pool) external onlyUniquePool{
        delete userPool[_pool];
    }

    function getUserPools(address _user) external view returns (address[] memory) {
        return userPool[_user];
    }

    function addParticipants(address wallet) public onlyAllowedAirdropFactory {
        participants.add(wallet);
    }

    function getLengthParticipants() public view returns (uint) {
        return participants.length();
    }

    function setSuperAdmin(address wallet) public onlyOwner {
        superAdmin = wallet;
    }
    function addMultipleWalletAdmin(address[] memory wallets, uint length) public onlyOwnerOrSuperAdmin {
        for(uint i = 0; i < length; i++) {
            isAdmin[wallets[i]] = true;
        }
    }

    function removeMultipleWalletAdmin(address[] memory wallets, uint length) public onlyOwnerOrSuperAdmin {
        for(uint i = 0; i < length; i++) {
            isAdmin[wallets[i]] = false;
        }
    }


    

    function setFeeAddress(address wallet) public onlyOwner {
        feeAddress = wallet;
    }

    function setAdmin(address wallet, bool value) public onlyOwnerOrSuperAdmin {
        isAdmin[wallet] = value;
    }

    

    function addAirdropFactory(address factory) public onlyOwner {
        airdropFactory.add(factory);
    }

    function addAirdropsFactory(address[] memory factories) external onlyOwner {
        for (uint256 i = 0; i < factories.length; i++) {
        addAirdropFactory(factories[i]);
        }
    }

    function removeAirdropFactory(address factory) external onlyOwner {
        airdropFactory.remove(factory);
    }

    function assignAirdropToOwner(address owner, address pool) 
        external override onlyAllowedAirdropFactory {
        require(!hasPool[owner][pool], "Airdrop already exists");
        poolOf[owner].push(address( pool));
        hasPool[owner][pool] = true;
        isGenerated[pool] = true;
        listPools.add(address(pool));
        
    }

    function getAllAirdrop() public view returns(address[] memory) {
        uint256 length = listPools.length();
        address[] memory pools = new address[](length);
        for (uint256 i = 0; i < length; i++) {
        pools[i] = listPools.at(i);
        }
        return pools;
    }

    function getAllowedFactories() public view returns (address[] memory) {
        uint256 length = airdropFactory.length();
        address[] memory factories = new address[](length);
        for (uint256 i = 0; i < length; i++) {
        factories[i] = airdropFactory.at(i);
        }
        return factories;
    }

    function isPoolGenerated(address poolAddr) external view returns (bool) {
        return isGenerated[poolAddr];
    }

    function getPool(address owner, uint256 index) external view returns (address) {

        return poolOf[owner][index];
    }

    function getAllPools(address owner) external view returns (address[] memory) {
        uint256 length = poolOf[owner].length;
        address[] memory poolAddrs = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            poolAddrs[i] = poolOf[owner][i];
        
        }
        return poolAddrs;
    }

    
    }