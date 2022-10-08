/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

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


/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

// -----License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

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



// File: @openzeppelin/contracts/access/Ownable.sol

// ----License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface INft {
     function mintTo(address recipient,uint level_) external;
     function level(uint id) external view returns(uint number);
}


/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol

// -----License-Identifier: MIT

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




contract IDO is Ownable{


    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet whiteList;

    address  public _usdt;

    //代币地址
    address public _sat = 0xe4e9D9fA5953986906555709BfC2312E85fA6eD3;
    //nft地址
    address public _nft = 0xf0e14d66e89a9c8aC2DF8248fd10EF87F244D7f4;

    //总私募人数
    uint public _totalCount;

     //合伙人人数
    uint public _totalUnionCount;
    //总私募余额
    uint public _totalAmount;
    //启动时间
    uint256 public _startTime =1663121091;
    //结束时间
    uint256 public _endTime =1667224800;

    //每份ido额度对应多少代币
    uint256 public _tokenExchangeRate;

    //收款地址
    address public _collectionAddr = 0x5667D7243677038010d4333CA5b93a0DC3F26eE7;


    struct User {
        //上级地址
        address partnerAddr;
        //下级地址
        address[] invitees;
        uint256 claim;
        uint256 alreadyClaim;
        bool isAir; 
        bool isPartner;
        uint256 bindTime;

    }

    mapping(address => User) _users;

    constructor(){
        _usdt = 0xF456836633e0893290BF33874803e00eD936Fe7f;
        whiteList.add(0x5667D7243677038010d4333CA5b93a0DC3F26eE7);

    }



    function setConfig(
         //start time
        uint256 startTime_,
        //end time
        uint256 endTime_
    
    ) onlyOwner external {
         _startTime = startTime_;
        _endTime = endTime_;
    }


    address[] public alreadyIdo;




    function invest(address inviter ) external {
        require(block.timestamp < _endTime && block.timestamp >_startTime, "already stop");
        require(!whiteList.contains(msg.sender),"The address is whitelist");
        require(_users[inviter].isPartner,"The address not partner");
        
        require( !_users[msg.sender].isAir , "Received");
        dividend( _collectionAddr, 10e18);
        alreadyIdo.push(msg.sender);
     
        _users[msg.sender].claim = 10e18;
         //His superiors are going to deposit him in
        _users[inviter].invitees.push(msg.sender);
        //Store the upper-level address of the current address
        _users[msg.sender].partnerAddr = inviter;
        _users[msg.sender].bindTime = block.timestamp;
            
        _users[msg.sender].isAir = true;
        _totalAmount+=10e18;
        _totalCount+=1;
    }

    function investUnion(address inviter ) external {
        require(block.timestamp < _endTime && block.timestamp >_startTime, "already stop");
        require( !_users[msg.sender].isAir , "Received");
        require(_users[inviter].isPartner||whiteList.contains(msg.sender),"The address not partner");
        dividend( _collectionAddr, 100e18);
        alreadyIdo.push(msg.sender);
         _totalAmount+=100e18;
        _users[msg.sender].claim = 100e18;
         //His superiors are going to deposit him in
        _users[inviter].invitees.push(msg.sender);
        //Store the upper-level address of the current address
        _users[msg.sender].partnerAddr = inviter;
        _users[msg.sender].bindTime = block.timestamp;
        _users[msg.sender].isPartner = true ;
        _users[msg.sender].isAir = true;
        _totalUnionCount += 1 ;
        _totalCount+=1;
    }






    function dividend(address to ,uint256 amount) private{
        IERC20(_usdt).transferFrom(msg.sender,to, amount );
    }


    function getAllList(address[] memory addr ) public view returns( User[] memory user){
        User[] memory users = new User[](addr.length);
        for(uint i;i<addr.length;i++){
            users[i]=_users[addr[i]];
        }
        return users;
    }

    function userInfo(address account) external view returns(
       User memory user
    ){
        return(_users[account]);
    }


    function alreadyIdoInfo(uint start_,uint end_) external view returns(
       uint start,uint end,uint total,address[] memory a ,uint[] memory buyTime
    ){
        if(alreadyIdo.length<end_){
            end_ = alreadyIdo.length;
        }
        if(alreadyIdo.length< start_){
            start_ = alreadyIdo.length;
            end_ = alreadyIdo.length;
        }
        a = new address[](end_-start_);
        buyTime = new uint[](end_-start_);
        for(uint i;i<end_-start_;i++){
            a[i] = alreadyIdo[alreadyIdo.length -start_-i-1 ]  ;
            buyTime[i] = _users[  alreadyIdo[alreadyIdo.length - start_-i-1 ]].bindTime ;
        }
        return(start_, end_,alreadyIdo.length,a, buyTime);
    }



    

    function configDetail() external view returns( 
         //Start Time
        uint256 startTime_,
        //End Time
        uint256 endTime_,
       
        //How many tokens are corresponding to each ido quota
        uint256 tokenExchangeRate_,
        //Payment address
        address collectionAddr_
        ){
        return (_startTime,_endTime,_tokenExchangeRate,_collectionAddr);
    }


    function claimToken() external {
         IERC20(_sat).transfer(msg.sender, _users[msg.sender].claim*_tokenExchangeRate);
        _users[msg.sender].alreadyClaim += _users[msg.sender].claim*_tokenExchangeRate;
        _users[msg.sender].claim = 0;
      
    }
    mapping(address => mapping(uint => bool ) ) public nftAlreadyClaim;
    function claimNFT(uint lev) external {

        address addr = msg.sender;
        if(lev==0 &&  _users[addr].invitees.length >=inveNum && _users[addr].isAir ){//receive ordinary
          INft(_nft).mintTo(addr,0);
            nftAlreadyClaim[msg.sender][0]=true ;
        }

        if(lev==1&& _users[addr].invitees.length >=inveNum && whiteDsList[addr] && _users[addr].isAir ){//Receive a community leader
           INft(_nft).mintTo(addr,1);
           nftAlreadyClaim[msg.sender][1]=true ;
        }
         if(lev==2&&  _users[addr].invitees.length >=inveNum && whiteFhzList[addr] && _users[addr].isAir ){//Receive a squad leader
           INft(_nft).mintTo(addr,2);
           nftAlreadyClaim[msg.sender][2]=true ;
        }
       
      
    }

     

    mapping(address=>bool) whiteFhzList;

    mapping(address=>bool) whiteDsList;
    

    function viewClaimNFT(address addr) view external returns(uint[] memory cc ) {
        cc = new uint[](3);
        if(_users[addr].invitees.length >=inveNum && _users[addr].isAir&&nftAlreadyClaim[addr][0]==false ){//get captain
            cc[0]=1;
        }else if (nftAlreadyClaim[msg.sender][0]==true){
             cc[0]=2;
        }
        if( _users[addr].invitees.length >=inveNum && whiteDsList[addr] && _users[addr].isAir &&nftAlreadyClaim[addr][1]==false ){//Receive a community leader
            cc[1]=1;
        }else if(nftAlreadyClaim[msg.sender][1]==true){
            cc[1]=2;
        }
        if(_users[addr].invitees.length >=inveNum && whiteFhzList[addr] && _users[addr].isAir&&nftAlreadyClaim[addr][2]==false ){//Receive a squad leader
            cc[2]=1;
        }else if(nftAlreadyClaim[msg.sender][2]==true){
            cc[3]=2;
        }
    }






    function viewWhite()view public returns(address[] memory addrs){
        return whiteList.values();
    }


    function isWhiteList( address addr) view public returns(bool b){
        return whiteList.contains(addr);
    }

    function batchAddFhz(address[] memory addrs,bool value) onlyOwner external {
        for(uint i ; i<addrs.length;i++){
            whiteFhzList[addrs[i]] = value;
        }
    }

    uint inveNum = 1 ;
    function setInveNum(uint value) onlyOwner external {
        inveNum = value;
    }


    function batchAddDs(address[] memory addrs,bool value) onlyOwner external {
        for(uint i ; i<addrs.length;i++){
            whiteDsList[addrs[i]] = value;
        }
    }

    function whiteListAddDs(address[] memory addrs) onlyOwner external {
        for(uint i ; i<addrs.length;i++){
            whiteList.add(addrs[i]);
        }
    }


    


    function setTokenExchangeRate(uint tokenExchangeRate_) onlyOwner external {
        _tokenExchangeRate =  tokenExchangeRate_ ;
    }

    function setCollecAddr(address value) onlyOwner external {
        _collectionAddr =  value ;
    }


    function setSat(address sat_) onlyOwner external {
         _sat = sat_;
    }
    

    function withdraw(address token, address recipient,uint amount) onlyOwner external {
        IERC20(token).transfer(recipient, amount);
    }

    function withdrawBNB() onlyOwner external {
        payable(owner()).transfer(address(this).balance);
    }


    function setNft( address nft_) onlyOwner external {
          _nft = nft_;
    }

}