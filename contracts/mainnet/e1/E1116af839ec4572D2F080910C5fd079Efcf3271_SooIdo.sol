// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./PriceLibrary.sol";
import "./SafeERC20.sol";
import './IERC20.sol';
import './Ownable.sol';


contract SooIdo is Ownable {
    using SafeMath for uint256;

    struct user {
        uint256 id;
        uint256 level;
        address referrer;
    }

    uint256 public userCount;
    
    address public factory;
    address public dead = 0x000000000000000000000000000000000000dEaD;

    IERC20 public sooToken;
    IERC20 public usdtToken;

    uint256 public endblock;

    mapping(address => address[]) public myChilders;        // 我的直推
    mapping(address => address[]) public buyChildens;          // 直推购买地址
    mapping(address => uint256) public userSoo;     // 用户待领取IDO

    EnumerableSet.AddressSet private buyers;        // 购买IDO地址

    mapping(address => user) public Users;
    mapping(uint256 => address) public index2User;

    event Register(address indexed _userAddr, address indexed _referrer);
    event Ido(address indexed _userAddr);
    event WithdrawSoo(address indexed _userAddr, uint256 _amount);


    constructor() public {
        userCount = userCount.add(1);
        Users[dead].id = userCount;
        index2User[userCount] = dead;

        emit Register(dead, address(0));
    }


    function setSooToken(IERC20 _sooToken) onlyOwner public {
        sooToken = _sooToken;
    }

    function setUsdtToken(IERC20 _usdtToken) onlyOwner public {
        usdtToken = _usdtToken;
    }

    function setEndblock(uint256 _endblock) onlyOwner public {
        endblock = _endblock;
    }


    function register(address _referrer) public {
        require(!Address.isContract(msg.sender), "contract address is forbidden");
        require(!isExists(msg.sender), "user exists");
        require(isExists(_referrer), "referrer not exists");

        user storage regUser = Users[msg.sender];
        userCount = userCount.add(1);
        regUser.id = userCount;
        index2User[userCount] = msg.sender;
        regUser.referrer = _referrer;
        
        myChilders[_referrer].push(msg.sender);
        emit Register(msg.sender, _referrer);
    }


    function getMyChilders(address _userAddr) public view returns (address[] memory) {
        return myChilders[_userAddr];
    }

    function isExists(address _userAddr) view public returns (bool) {
        return Users[_userAddr].id != 0;
    }


    function ido() public {
        require(isExists(msg.sender), "user not exists");
        require(usdtToken.balanceOf(msg.sender) >= 100 * 1e18,  "usdt is not enough");
        if(EnumerableSet.contains(buyers, msg.sender))
        {
            return ;
        }

        usdtToken.transfer(address(this), 100 * 1e18);
        userSoo[msg.sender] = 10 * 1e18;

        address refAddr = Users[msg.sender].referrer;
        buyChildens[refAddr].push(msg.sender);

        EnumerableSet.add(buyers, msg.sender);
        emit Ido(msg.sender);
    }


    function withdrawalToken(address _tokenAddress, address _to, uint256 _amount) onlyOwner public { 
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(_to, _amount);
    }


    function withdrawSoo() public {
        if(block.number <= endblock) {
            return;
        }
        sooToken.transfer(msg.sender, 10 * 1e18);
        userSoo[msg.sender] = 0;

        emit WithdrawSoo(msg.sender, 10 * 1e18);

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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
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
        return address(uint256(_at(set._inner, index)));
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
}