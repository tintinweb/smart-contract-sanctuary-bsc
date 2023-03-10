/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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

abstract contract Ownable is Context {
    address private _owner;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private governments;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function addGovernment(address government) public onlyOwner {
        governments.add(government);
    }

    function deletedGovernment(address government) public onlyOwner {
        governments.remove(government);
    }

    function getGovernment(uint256 index) public view returns (address) {
        return governments.at(index);
    }

    function isGovernment(address account) public view returns (bool){
        return governments.contains(account);
    }

    function getGovernmentLength() public view returns (uint256) {
        return governments.length();
    }

    modifier onlyGovernment() {
        require(isGovernment(_msgSender()), "Ownable: caller is not the Government");
        _;
    }

    modifier onlyController(){
        require(_msgSender() == owner() || isGovernment(_msgSender()), "Ownable: caller is not the controller");
        _;
    }

}

interface IHTC{
    function balanceOf(address account) external view returns (uint256);
    function totalHTC() external view returns (uint256);
    function minusHTCAmount( address recipient , uint256 amount) external;
}

interface IERC20 {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

struct Pool{
    address _rewardToken;
    address _htc;
    uint256 _totalSupply;
    uint256 _price;
    uint256 _startTime;
    uint256 _rewardTokenTotal;
}

contract LotteryHtc is Ownable {
    address private rewardToken;
    uint256 private totalSupply;
    uint256 private price;
    address private funAddress;
    address private htc;
    mapping(bytes32 => bool) hashList;
    address [] private lotteryAccount;
    uint256 private startTime;
    uint256 private rewardTokenTotal;
    uint256 private random;
    uint256 private endBlock;
    mapping(address => uint256[]) accountPostions;
    uint256 private winnerPosition;
    uint256[] lotteryPositions;

    event Lottery(address to,uint256 amount,uint256 timestamp,string data,uint256[]lotteryPositions,bytes32 msghash,bytes32 r,bytes32 s,uint8 v);
    event Open(address operator,uint256 time,address token,uint256 amount,address winner,uint256 winPosition);

    constructor (address _funAddress,address _rewardToken,address _htc,uint256 _totalSupply,uint256 _price,uint256 _startTime,uint256 _rewardTokenTotal){
        rewardToken = _rewardToken;
        totalSupply = _totalSupply;
        price = _price;
        funAddress = _funAddress;
        htc = _htc;
        startTime =_startTime;
        rewardTokenTotal = _rewardTokenTotal;
        random = block.timestamp;
    }

    function lottery(address to,uint256 amount,uint256 timestamp,string memory data,bytes32 msghash,bytes32 r,bytes32 s,uint8 v) public {
        require(block.timestamp>=startTime,"this lottery is not start");
        require(totalSupply >= lotteryAccount.length+amount,"this lottery is end");
        require(block.timestamp<=timestamp);
        require(msg.sender == to);
        require(!hashList[msghash],"the hash has used");
        address _funAddress = ecrecover(msghash, v, r, s);
        require(funAddress == _funAddress,"data is wrong");
        string memory signDataStr = string(abi.encodePacked(string(abi.encodePacked("0x",addressToStr(to))),uint2str(amount),uint2str(timestamp),data));
        
        bytes32 signData  =keccak256(abi.encodePacked(signDataStr));
        bytes32 signResult = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",signData));
   

        require(signResult == msghash,"data is wrong");
        hashList[msghash] = true;
        require(amount>0,"amount must >0");
        uint256 balance = IHTC(htc).balanceOf(msg.sender);

        require(balance>=price*amount,"htc balance not enough");
        IHTC(htc).minusHTCAmount(msg.sender,price*amount);
        delete lotteryPositions;
        for(uint256 i=0;i<amount;i++){
            lotteryAccount.push(msg.sender);
            accountPostions[msg.sender].push(lotteryAccount.length -1);
            lotteryPositions.push(lotteryAccount.length -1);
        }

        random +=1;

        if(lotteryAccount.length == totalSupply){
            endBlock = block.number+18 ;
        }

        emit Lottery( to, amount, timestamp, data,lotteryPositions, msghash, r, s, v);

    }

    function open() public onlyController {
       uint256 length = lotteryAccount.length;
       require(length>0);

       uint256 position =  uint256(keccak256(abi.encodePacked(block.timestamp,endBlock,random,msg.sender,funAddress))) % length;
       address account = lotteryAccount[position];
        winnerPosition = position; 
        if(rewardToken == address(0)){
            payable(account).transfer(rewardTokenTotal);
        }else{
            IERC20(rewardToken).transfer(account,rewardTokenTotal);
        }

        emit Open(msg.sender,block.timestamp,rewardToken,rewardTokenTotal,account,winnerPosition);
    }

    function getAccountLotteryPositions(address account) public view returns(uint256[]memory){
        return accountPostions[account];
    }

    function getEndBlock() public view returns (uint256) {
        return endBlock;
    }

    function getWinnerPosistion() public view returns(uint256){
       return winnerPosition;
    }

    function getPoolBalance(address token) public view  returns(uint256) {
        if(token == address(0)){
            return address(0).balance;
        }else{
            return IERC20(token).balanceOf(address(this));
        }
    }

    function withdraw(address token,address account) public onlyController {
        if(token == address(0)){
            payable(account).transfer(address(0).balance);
        }else{
            IERC20(token).transfer(account,IERC20(token).balanceOf(address(this)));
        }
    }

    function getPoolInfo() public view returns (Pool memory){
        Pool memory pool = Pool({
        _rewardToken:rewardToken,
        _htc:htc,
        _totalSupply:totalSupply,
        _price:price,
        _startTime:startTime,
        _rewardTokenTotal:rewardTokenTotal
        });
        return pool;
    }

    function getLotteryAmountLength() public view returns (uint256) {
        return lotteryAccount.length;
    }

    function getLotteryByIndex(uint256 index) public view returns (address) {
        return lotteryAccount[index];
    }

    function uint2str(uint256 _i) private pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }

    function setFunAddress(address _funAddress) public onlyController {
        funAddress = _funAddress;
    }

    function addressToStr(address account) private pure returns (string memory) {
       bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(account)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    

    function containsHash(bytes32 hash) public view returns (bool) {
        return hashList[hash];
    }

    function char(bytes1 b) private pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}