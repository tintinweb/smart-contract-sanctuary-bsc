/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

pragma solidity ^0.6.0;


library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

        if (valueIndex != 0) {// Equivalent to contains(set, value)
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
            set._indexes[lastvalue] = toDeleteIndex + 1;
            // All indexes are 1-based

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
   * @dev Returns the number of values on the set. O(1).
   */
    function _lengthMemory(Set memory set) private pure returns (uint256) {
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
    * @dev Returns the number of values on the set. O(1).
    */
    function lengthMemory(UintSet memory set) internal pure returns (uint256) {
        return _lengthMemory(set._inner);
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

    function atMemory(UintSet memory set, uint256 index) internal pure returns (uint256) {
        require(set._inner._values.length > index, "EnumerableSet: index out of bounds");
        return uint256(set._inner._values[index]);
    }
}


interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function getTokenLevel(uint256 tokenId) external view returns (uint256);

}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns (bytes4);
}

interface IReferrer {
    function getReferrer(address _addr) external view returns (address);

    function addMintReward(address child, uint256 amount) external;

    function addExchangeReward(address child, uint256 amount, uint256 amount2) external;

    function addStakingReward(address child, uint256 amount, uint256 amount2) external;

    function setOperator(address _addr) external;
}

interface ITokenPool {
    function setOperator(address _addr) external;
}

contract Ownable {
    address private owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor()public{
        owner = msg.sender;
    }

    function CurrentOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract nftStaking is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.UintSet;
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) public returns (bytes4){
        require(tx.origin == _from, "illegal operation owner");
        //        stake(_from, _tokenId);
        return 0x150b7a02;
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    address emptyAddress = 0x0000000000000000000000000000000000000000;
    address tokenAddress = 0x874E5AC50aBFfe0f60f9FB6f7A28f75FB878279d;//TODO 修改代币地址
    IERC721  nftToken = IERC721(0x42bA5f5354FC7888B52EcC631E2f9E476C8E6E88);//TODO 修改nft地址
    IReferrer mReferrer = IReferrer(0x6E447A395027982D04B9d18064209C951fd0e1e8);//TODO 修改推荐关系地址
    address tokenPoolAddress = 0xc70E6f8308F52cF66e0eE047c0b25Ec270329Bd2;//TODO 修改代币池子地址
    uint256 one_token = 1e18;//TODO 修改代币精度
    uint256[] level_token_arr = [500 * one_token, 1000 * one_token, 1500 * one_token, 2500 * one_token, 5000 * one_token];
    uint256[] level_reward_min_arr = [75, 155, 250, 460, 1000];
    uint256[] level_reward_max_arr = [86, 210, 320, 540, 1150];
    uint256 one_hour = 60 * 60;//TODO 修改一小时有多少秒
    uint256 reward_limit_time = 168 * one_hour;

    uint8 STATUS_VALID = 1;
    uint8 STATUS_EXIT = 2;
    uint8 STATUS_EXPIRE = 3;

    struct Order {
        uint256 tokenId;
        uint256 initTime;
        uint256 lastTime;
        uint256 reward;
        uint8 status;//1 valid, 2已退出，3满4小时
    }

    mapping(uint256 => Order) orderMap;
    mapping(address => EnumerableSet.UintSet) userTokenIdMap;


    constructor()public{

        mReferrer.setOperator(address(this));
        ITokenPool(tokenPoolAddress).setOperator(address(this));

    }

    function getUser(address _addr) public view returns (uint256){
        return userTokenIdMap[_addr].length();
    }

    function getStakeList(address _addr, uint256 startIndex, uint256 endIndex) public view returns (uint256[]memory tokenIdArr, uint256[]memory lastTimeArr, uint256[]memory levelArr, uint256[] memory rewardArr){
        require(startIndex <= endIndex, "s<=e");
        require(endIndex < userTokenIdMap[_addr].length(), "end Max");
        uint len = endIndex.sub(startIndex).add(1);

        tokenIdArr = new uint256[](len);
        lastTimeArr = new uint256[](len);
        levelArr = new uint256[](len);
        rewardArr = new uint256[](len);
        uint index;
        for (; startIndex <= endIndex; startIndex++) {
            Order memory order = orderMap[userTokenIdMap[_addr].atMemory(startIndex)];
            tokenIdArr[index] = order.tokenId;
            lastTimeArr[index] = order.lastTime;
            levelArr[index] = nftToken.getTokenLevel(order.tokenId);
            rewardArr[index] = order.reward;
            index++;
        }
    }

    function getTokenLevel(uint256 tokenId) internal view returns (uint256){
        uint l = nftToken.getTokenLevel(tokenId);
        require(l > 0, "invalid ID");
        return l - 1;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nftToken.ownerOf(_tokenId) == _claimant);
    }


    function stake(uint256 tokenId) public {
        require(_owns(msg.sender, tokenId), "ownerOf");

        nftToken.safeTransferFrom(msg.sender, address(this), tokenId);
        safeTransferFrom(tokenAddress, msg.sender, address(this), level_token_arr[getTokenLevel(tokenId)]);

        uint256 level = getTokenLevel(tokenId);
        uint256 tokenAmount = _randomToken(level_reward_min_arr[level], level_reward_max_arr[level]);

        Order storage order = orderMap[tokenId];
        order.tokenId = tokenId;
        order.initTime = now;
        order.lastTime = now;
        order.reward = tokenAmount;
        order.status = STATUS_VALID;

        userTokenIdMap[msg.sender].add(tokenId);
    }

    function getReward(uint256 tokenId) public {
        require(userTokenIdMap[msg.sender].contains(tokenId), "invalid oid");

        Order storage order = orderMap[tokenId];
        require(order.status == STATUS_VALID, "status 1");
        require(now.sub(order.lastTime) >= reward_limit_time, "t");
        order.lastTime = now;


        safeTransferFrom(tokenAddress, tokenPoolAddress, msg.sender, order.reward);
        _sendRefReward(order.reward);

        uint256 level = getTokenLevel(tokenId);
        uint256 tokenAmount = _randomToken(level_reward_min_arr[level], level_reward_max_arr[level]);
        order.reward = tokenAmount;

    }

    function _sendRefReward(uint256 amount) internal {
        mReferrer.addStakingReward(msg.sender, amount.mul(5).div(100), amount.mul(3).div(100));
        //        IERC20 token = IERC20(tokenAddress);
        //        address r1 = mReferrer.getReferrer(msg.sender);
        //        if (r1 != emptyAddress) {
        //            {
        //                uint256 a1 = amount.mul(5).div(100);
        //                if (token.balanceOf(tokenPoolAddress) >= a1) {
        //                    safeTransferFrom(tokenAddress, tokenPoolAddress, r1, a1);
        //                }
        //            }
        //
        //            address r2 = mReferrer.getReferrer(r1);
        //            if (r1 != emptyAddress) {
        //                uint256 a2 = amount.mul(3).div(100);
        //                if (token.balanceOf(tokenPoolAddress) >= a2) {
        //                    safeTransferFrom(tokenAddress, tokenPoolAddress, r2, a2);
        //                }
        //            }
        //
        //        }
    }

    function exit(uint256 tokenId) public {
        require(userTokenIdMap[msg.sender].contains(tokenId), "invalid oid");

        Order storage order = orderMap[tokenId];
        require(order.status == STATUS_VALID, "status 1");
        order.status = STATUS_EXIT;

        userTokenIdMap[msg.sender].remove(tokenId);
        uint256 level = getTokenLevel(order.tokenId);
        if (now.sub(order.lastTime) >= reward_limit_time) {
            safeTransferFrom(tokenAddress, tokenPoolAddress, msg.sender, order.reward);
            _sendRefReward(order.reward);
        }
        //
        safeTransfer(tokenAddress, msg.sender, level_token_arr[level]);
        nftToken.safeTransferFrom(address(this), msg.sender, order.tokenId);
    }


    function _randomToken(uint min, uint max) internal returns (uint256){
        uint ran = _randomNum();
        uint n = ran.mod(max.sub(min)).add(min);
        return n.mul(one_token);
    }

    uint256 NONCE_MAX = uint(- 1).sub(100);
    uint256 nonceCall;

    function _randomNum() internal returns (uint256){
        nonceCall = nonceCall.add(1);
        if (nonceCall >= NONCE_MAX) {
            nonceCall = 111;
        }
        return uint(keccak256(abi.encodePacked(now, msg.sender, uint160(msg.sender) - 56, nonceCall)));
    }
}