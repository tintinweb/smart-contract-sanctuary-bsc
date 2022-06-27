/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }


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
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }
}
library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
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
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function burn(address addr_, uint amount_) external returns (bool);

    function checkHolder() external view returns (uint out);

    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface MAIN{
    function checkInvitor(address addr_) external view returns(address _in);
}
interface TOKEN{
    function checkMemberTotalTotal()external view returns(uint _reward);
}
interface LiuidityPool {
    function userInfo(address add_) external view returns(uint,uint,uint,uint,uint,bool );
}

contract Member is Ownable{
    using SafeMath for uint;
    LiuidityPool public liuidityPool;

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    IERC20 public pair;
    IERC20 public BYZ;
    TOKEN public token;
    address public bank;
    address public usdt;

    uint constant Acc = 1e18;
    uint public cycle = 86400 * 7;//周期7天

    uint public startTime;
    uint public cycleTime;

    uint public usdtThreshold=100 *1e18;
    uint public byzThreshold=100 *1e18;

    struct User{
        uint lastTime;
        uint LpAmount;
        uint claimed;//已领取数量
        address invitor;
        address user;
        uint node;
    }

    mapping(address =>EnumerableSet.AddressSet)  recommended;
    mapping(uint =>EnumerableSet.AddressSet)  levels;

    mapping (address => User) public userInfo;

    event AddInvitor(address indexed _sender,address indexed invitor);
    event UpgradeUser(address indexed _sender,uint indexed _node);
    event UPdateLP(address indexed _sender,uint indexed lp);

    function initLpPool(address bank_, address pair_, address BYZ_, uint startTime_,address liuidityPool_,address usdt_) public onlyOwner{
        pair = IERC20(pair_);
        BYZ = IERC20(BYZ_);
        token = TOKEN(BYZ_);
        liuidityPool = LiuidityPool(liuidityPool_);
        bank = bank_;
        startTime = startTime_;
        cycleTime = startTime_ + cycle;
        usdt=usdt_;
    }
    function setThreshold(uint usdtThreshold_,uint byzThreshold_) public onlyOwner{
        usdtThreshold=usdtThreshold_;
        byzThreshold=byzThreshold_;
    }

    function setCycle(uint cycle_) public onlyOwner{
        cycle = cycle_;
    }

    function setStarTime(uint time_) public onlyOwner{
         startTime = time_;
         cycleTime = startTime + cycle;
     }

    //用户累计领取
    uint public totalReward;
    uint public lastTotalReward;
    mapping(uint=>uint) public lastLevelCount;
    mapping(uint=>uint) public lastLevelReward;

    //用户提取上一周期收益
    function claimLastCycleReward()external{
        User memory user = userInfo[msg.sender];
        require(user.node >= 1 && user.node <= 4, "user level error");

        uint toClaim;
        if(block.timestamp  >= startTime){
            //每个周期的第一次领取
            uint lastReward = token.checkMemberTotalTotal();
            lastTotalReward = 0;//每个周期第一次领取重置
            lastLevelCount[1]=levels[1].length();
            lastLevelCount[2]=levels[2].length();
            lastLevelCount[3]=levels[3].length();
            lastLevelCount[4]=levels[4].length();

            if(levels[1].length()>0){
                lastLevelReward[1]=lastReward * 40 / 100;
                lastTotalReward = lastTotalReward.add(lastLevelReward[1]);
            }
            if(levels[2].length()>0){
                lastLevelReward[2]=lastReward * 30 / 100;
                lastTotalReward = lastTotalReward.add(lastLevelReward[2]);
            }
            if(levels[3].length()>0){
                lastLevelReward[3]=lastReward * 20 / 100;
                lastTotalReward = lastTotalReward.add(lastLevelReward[3]);
            }
            if(levels[4].length()>0){
                lastLevelReward[4]=lastReward * 10 / 100;
                lastTotalReward = lastTotalReward.add(lastLevelReward[4]);
            }
            if (block.timestamp - startTime >= cycle){
                startTime += cycle;
            }
        }

        require(userInfo[msg.sender].lastTime < startTime,"It's not time to collect");
        require(lastLevelCount[user.node] > 0,"lastLevelCount error");
        toClaim = lastLevelReward[user.node]/lastLevelCount[user.node];
        require(toClaim > 0 ,"toClaim error");
        lastTotalReward = lastTotalReward.sub(toClaim);
        totalReward = totalReward.add(toClaim);
        BYZ.safeTransfer(_msgSender(), toClaim);
        userInfo[msg.sender].claimed += toClaim;
        userInfo[msg.sender].lastTime = block.timestamp;
    }

    //计算当前收益-预估
    function calculateCurrentReward(address _address)public view returns(uint reward){
        //本次循环可领取
        User memory user = userInfo[_address];
        if(user.node<1){
            return reward;
        }
        uint currentTotalReward = token.checkMemberTotalTotal().sub(lastTotalReward);
        if(user.node == 1){
            reward = currentTotalReward*40/100/levels[1].length();
        }else if(user.node == 2){
            reward = currentTotalReward*30/100/levels[2].length();
        }else if(user.node == 3){
            reward = currentTotalReward*20/100/levels[3].length();
        }else if(user.node == 4){
            reward = currentTotalReward*10/100/levels[4].length();
        }
        
    }

    //计算上一轮收益
    function calculateLastReward(address _address)public view returns(uint reward){
        User memory user = userInfo[_address];
        if(user.node<1){
            return reward;
        }
        reward = lastLevelReward[user.node]/lastLevelCount[user.node];
    }

    struct CurrentPoolView{
        uint level;//等级
        uint unReward;//待领取代币数
        uint levelTotal;//等级人数
    }

    //返回当前相应等级池的
    function calculateCurrentPool()public view returns(CurrentPoolView[4] memory poolView){
        uint currentTotalReward = token.checkMemberTotalTotal().sub(lastTotalReward);
        poolView[0] = CurrentPoolView({
            level:1,unReward:currentTotalReward*40/100,levelTotal:levels[1].length()
        });
        poolView[1] = CurrentPoolView({
            level:2,unReward:currentTotalReward*30/100,levelTotal:levels[2].length()
        });
        poolView[2] = CurrentPoolView({
            level:3,unReward:currentTotalReward*20/100,levelTotal:levels[3].length()
        });
        poolView[3] = CurrentPoolView({
            level:4,unReward:currentTotalReward*10/100,levelTotal:levels[4].length()
        });
    }
    //-----------------------------收益 计算 END----------------------------------------

    //---------------------------------L-P---------------------------------
    function updaeteLP() public{
        userInfo[msg.sender].LpAmount=getUserLpAmount(msg.sender);
        emit UPdateLP(msg.sender, getUserLpAmount(msg.sender));
    }
    
    //---------------------------------check---------------------------------
    function addInvitor(address addr_) public returns(address _invitor) {
        require(userInfo[msg.sender].invitor == address(0) , 'already has a invitor!');
        require(addr_ != msg.sender, 'Duplicate address');
        userInfo[msg.sender].invitor = addr_;
        userInfo[msg.sender].LpAmount = getUserLpAmount(msg.sender);
        userInfo[msg.sender].user = msg.sender;
        recommended[addr_].add(msg.sender);
        _invitor = userInfo[addr_].invitor;
        emit AddInvitor(msg.sender,addr_ );
    }

    function getUsersRecommendedLen(address addr_) view external returns (uint256 len){
        len =  recommended[addr_].length();
    }

    function getUserRecommendedAt(address addr_,uint256 idx) view external returns (address userAddress){
        userAddress =  recommended[addr_].at(idx);
    }

    function RecommendeOf(address addr_,uint256 startIndex, uint256 endIndex) view external returns (address[] memory addr){
        uint256 len =  recommended[addr_].length();
        if (len == 0) {
            return addr;
        }
        if (endIndex == 0 || endIndex > len) {
            endIndex = len;
        }
        require(startIndex < endIndex, "invalid index");
        address[] memory result = new address[](endIndex - startIndex);
        for (uint256 i = startIndex; i != endIndex; ++i) {
            result[i - startIndex] =  recommended[addr_].at(i);
        }
        return result;
    }

    function getUserInfo(address addr_) view external returns (User memory addr){
        return userInfo[addr_];
    }

    function usersOf(address addr_,uint256 startIndex, uint256 endIndex) view external returns (User[] memory user){
        uint256 len =  recommended[addr_].length();
        if (len == 0) {
            return user;
        }
        if (endIndex == 0 || endIndex > len) {
            endIndex = len;
        }
        require(startIndex < endIndex, "invalid index");
        User[] memory result = new User[](endIndex - startIndex);
        for (uint256 i = startIndex; i != endIndex; ++i) {
            result[i - startIndex] =  userInfo[recommended[addr_].at(i)];
        }
        return result;
    }
    
    function getUserLpAmount(address addr_) view public returns (uint amount){
        (,,uint stakeAmount,,,)= liuidityPool.userInfo(addr_);
        uint  lpAmount= pair.balanceOf(addr_);
        return stakeAmount+lpAmount;
    }

    function getUserLpUsdtAndBYZ(address addr_) view public returns (uint amount){
        uint  totalSupplylp= pair.totalSupply();
        uint balance0 = IERC20(usdt).balanceOf(address(pair));
        uint balance1 = BYZ.balanceOf(address(pair));
        uint lpAmount = getUserLpAmount(addr_);
        uint amount0 = lpAmount.mul(balance0) / totalSupplylp;
        uint amount1 = lpAmount.mul(balance1) / totalSupplylp;
        return amount0*amount1;
    }

    function upgradeUser(address[] memory addr_) public{
        uint recommendedAddr = addr_.length;
        require(recommendedAddr==5||recommendedAddr==3,"address length err");
        if (recommendedAddr==5){
            for (uint i = 0; i < recommendedAddr; i++) {
                if (recommended[msg.sender].contains(addr_[i])){
                    if (getUserLpUsdtAndBYZ(addr_[i])>=usdtThreshold*byzThreshold){
                        continue;
                    }else{
                        revert("Insufficient amount of recommended person");
                    }
                }else{
                    revert("The recommended person does not exist");

                }
            }
            if (getUserLpUsdtAndBYZ(msg.sender)>=usdtThreshold*byzThreshold){
                if (userInfo[msg.sender].node<1) {
                    userInfo[msg.sender].node=1;
                    levels[1].add(msg.sender);
                    emit UpgradeUser(msg.sender,userInfo[msg.sender].node);
                }else{
                    revert("Cannot downgrade");
                }
            }else{
                revert("Insufficient threshold amount");
            }
        }else if(recommendedAddr==3){
            if (recommended[msg.sender].contains(addr_[0])&&recommended[msg.sender].contains(addr_[1])&&recommended[msg.sender].contains(addr_[2])){

                    if ( userInfo[msg.sender].node>=1&&userInfo[msg.sender].node<4){
                        uint256 minLevel = userInfo[addr_[0]].node;
                        if(userInfo[addr_[1]].node< minLevel){
                            minLevel = userInfo[addr_[1]].node;
                        }
                        if(userInfo[addr_[2]].node< minLevel){
                            minLevel = userInfo[addr_[2]].node;
                        }
                        if(minLevel < 1){
                            revert("minLevel non conformance");
                        }else if(minLevel == 4){
                            userInfo[msg.sender].node = 4;
                        }else{
                            userInfo[msg.sender].node = minLevel + 1;
                        }
                        uint256 old = userInfo[msg.sender].node;
                        levels[old].remove(msg.sender);
                        levels[userInfo[msg.sender].node].add(msg.sender);
                        emit UpgradeUser(msg.sender,userInfo[msg.sender].node);
                    }else{
                        revert("Grade non conformance");
                    }
            }else{
                revert("Referrals who do not belong to themselves");

            }
        }
    }
}