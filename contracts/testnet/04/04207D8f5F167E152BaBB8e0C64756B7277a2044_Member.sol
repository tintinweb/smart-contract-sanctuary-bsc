/**
 *Submitted for verification at BscScan.com on 2022-06-22
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

    bool public status;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    IERC20 public pair;
    IERC20 public BYZ;
    TOKEN public token;
    address public bank;
    address public usdt;

    uint constant Acc = 1e18;
    uint public cycle = 86400 * 7;


    uint public invalidTime;
    uint public startTime;
    uint public cycleTime;

    uint public nowTotal;
    uint public lastTotal;
    uint public lastCycleReward;

    uint public lastlevel1Power;
    uint public lastlevel2Power;
    uint public lastlevel3Power;
    uint public lastlevel4Power;
    uint[] public Coe = [10, 20, 30, 40];
    uint public usdtThreshold=100 *1e18;
    uint public byzThreshold=100 *1e18;
    uint public Unlevel1Amount;
    uint public Unlevel2Amount;
    uint public Unlevel3Amount;
    uint public Unlevel4Amount;
    struct User{
        uint lastTime;
        uint LpAmount;

        uint claimed;
        bool inCycle;

        address invitor;
        address user;
        uint node;
    }
    mapping(address =>EnumerableSet.AddressSet)  recommended;
    mapping(uint =>EnumerableSet.AddressSet)  levels;

    mapping (address => User) public userInfo;

  
    event Declare(address indexed _sender, uint indexed _amount);
    event AddInvitor(address indexed _sender,address indexed invitor);
    event UpgradeUser(address indexed _sender,uint indexed _node);
    event UPdateLP(address indexed _sender,uint indexed lp);
    modifier check {
        nowTotal = token.checkMemberTotalTotal();
        if (block.timestamp  >= cycleTime){
            lastCycleReward = nowTotal - lastTotal;
            lastTotal = nowTotal;
            lastlevel1Power=levels[1].length();
            lastlevel2Power=levels[2].length();
            lastlevel3Power=levels[3].length();
            lastlevel4Power=levels[4].length();

            Unlevel1Amount=lastCycleReward* 40/100;
            Unlevel2Amount=lastCycleReward* 30/100;
            Unlevel3Amount=lastCycleReward* 20/100;
            Unlevel4Amount=lastCycleReward* 10/100;
            while (block.timestamp - startTime > cycle){
                startTime += cycle;
            }
            cycleTime = startTime + cycle;
            invalidTime = startTime - cycle;
        }
        _;
    }

    function initLpPool(address bank_, address pair_, address BYZ_, uint startTime_,address liuidityPool_,address usdt_) public onlyOwner{
        pair = IERC20(pair_);
        BYZ = IERC20(BYZ_);
        token = TOKEN(BYZ_);
        liuidityPool = LiuidityPool(liuidityPool_);
        bank = bank_;
        invalidTime = startTime_ - cycle;
        startTime = startTime_;
        cycleTime = startTime_ + cycle;
        status = true;
        usdt=usdt_;
    }
    function setThreshold(uint usdtThreshold_,uint byzThreshold_) public onlyOwner{
        usdtThreshold=usdtThreshold_;
        byzThreshold=byzThreshold_;
    }

    function setCycle(uint cycle_) public onlyOwner{
        cycle = cycle_;
        startTime = block.timestamp;
        cycleTime = startTime + cycle;

        nowTotal = token.checkMemberTotalTotal();
        lastCycleReward = nowTotal - lastTotal;
        lastTotal = nowTotal;
        lastlevel1Power=levels[1].length();
        lastlevel2Power=levels[2].length();
        lastlevel3Power=levels[3].length();
        lastlevel4Power=levels[4].length();

        Unlevel1Amount=lastCycleReward* 40/100;
        Unlevel2Amount=lastCycleReward* 30/100;
        Unlevel3Amount=lastCycleReward* 20/100;
        Unlevel4Amount=lastCycleReward* 10/100;


    }

    function setStarTime(uint time_) public onlyOwner{
         startTime = time_;
         cycleTime = startTime + cycle;

         nowTotal = token.checkMemberTotalTotal();
         lastCycleReward = nowTotal - lastTotal;
         lastTotal = nowTotal;
         lastlevel1Power=levels[1].length();
         lastlevel2Power=levels[2].length();
         lastlevel3Power=levels[3].length();
         lastlevel4Power=levels[4].length();

         Unlevel1Amount=lastCycleReward* 40/100;
         Unlevel2Amount=lastCycleReward* 30/100;
         Unlevel3Amount=lastCycleReward* 20/100;
         Unlevel4Amount=lastCycleReward* 10/100;
      

     }

    function safePull(address token_, address bank_, uint amount_) public onlyOwner {
        IERC20(token_).transfer(bank_, amount_);
    }



    //---------------------------------L-P---------------------------------


    function updaeteLP() public check returns(bool){
        userInfo[msg.sender].LpAmount=getUserLpAmount(msg.sender);

        emit UPdateLP(msg.sender, getUserLpAmount(msg.sender));
        return true;
    }


    function declare() public check {
        require(status, 'not open');
        require(userInfo[msg.sender].node > 0, "null amount");
      
        User storage user = userInfo[msg.sender];
        uint toClaim;

        if (!user.inCycle){
         
            user.lastTime = block.timestamp;

          
            user.inCycle = true;
        }else{
            if (user.lastTime >= invalidTime && user.lastTime < startTime){

                uint userNode=user.node;
                if (userNode==1){
                    toClaim = ( Acc / lastlevel1Power) * 40/100*lastCycleReward;
                    toClaim = toClaim / Acc;
                    Unlevel1Amount-=toClaim;
                }
                else if(userNode==2){
                    toClaim = ( Acc / lastlevel2Power) * 30/100*lastCycleReward;
                    toClaim = toClaim / Acc;
                    Unlevel2Amount-=toClaim;
                }
                else if(userNode==3){
                    toClaim = (Acc / lastlevel3Power) * 20/100*lastCycleReward;
                    toClaim = toClaim / Acc;
                    Unlevel3Amount-=toClaim;
                }
                else if(userNode==4){
                    toClaim = (Acc / lastlevel4Power) * 10/100*lastCycleReward;
                    toClaim = toClaim / Acc;
                    Unlevel4Amount-=toClaim;
                }
   
                BYZ.safeTransfer(_msgSender(), toClaim);
                userInfo[msg.sender].LpAmount=getUserLpAmount(msg.sender);
                user.claimed += toClaim;
                user.lastTime = block.timestamp;
     

            } else if (user.lastTime >= startTime && user.lastTime < cycleTime){

                user.lastTime = block.timestamp;
                userInfo[msg.sender].LpAmount=getUserLpAmount(msg.sender);


            } else if (user.lastTime < invalidTime){
                          user.lastTime = block.timestamp;
                userInfo[msg.sender].LpAmount=getUserLpAmount(msg.sender);

            }
        }
        emit Declare(msg.sender, toClaim);
    }

    //---------------------------------check---------------------------------

    function checkRe(address user) public view returns(uint){
        User storage _user = userInfo[user];
        uint x;
        uint _re;
        if (_user.lastTime < invalidTime){
            _re = 0;
        }else if (_user.lastTime >= invalidTime && _user.lastTime < startTime){
            uint userNode=_user.node;
            if (userNode==1){
                _re = ( Acc / lastlevel1Power) * 40/100*lastCycleReward/ Acc;
            }
            else if(userNode==2){
                _re = ( Acc / lastlevel2Power) * 30/100*lastCycleReward/ Acc;
            }
            else if(userNode==3){
                _re = ( Acc / lastlevel3Power) * 20/100*lastCycleReward/ Acc;
            }
            else if(userNode==4){
                _re = ( Acc / lastlevel4Power) * 10/100*lastCycleReward/ Acc;
            }
        }else if (_user.lastTime >= startTime && _user.lastTime < cycleTime){
            x=(token.checkMemberTotalTotal() - lastTotal);
            uint userNode=_user.node;
            if (userNode==1){
                _re = ( Acc / lastlevel1Power) * 40/100*x/ Acc;
            }
            else if(userNode==2){
                _re = ( Acc / lastlevel2Power) * 30/100*x/ Acc;
            }
            else if(userNode==3){
                _re = ( Acc / lastlevel3Power) * 20/100*x/ Acc;
            }
            else if(userNode==4){
                _re = ( Acc / lastlevel4Power) * 10/100*x/ Acc;
            }
        }
        return _re;
    }

    function addInvitor(address addr_) public returns(address _invitor) {
        require(userInfo[msg.sender].invitor == address(0) , 'already has a invitor!');
        require(addr_ != msg.sender, '?');
        userInfo[msg.sender].invitor = addr_;
        userInfo[msg.sender].LpAmount=getUserLpAmount(msg.sender);
        userInfo[msg.sender].user=msg.sender;
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

    function getUnassignedAmount(uint level) view external returns (uint){
        uint unAmount=0;
        if (level==1){
            unAmount= Unlevel1Amount;
        }else if  (level==2){
            unAmount=  Unlevel2Amount;
        }else if (level==3){
            unAmount=  Unlevel3Amount;
        }else if (level==4){
            unAmount=  Unlevel4Amount;
        }
        return unAmount;
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

    function upgradeUser(address[] memory addr_) public check returns (bool upgrade){
        uint recommendedAddr=addr_.length;
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
                    return true;
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
                            uint256 old = userInfo[msg.sender].node;
                            levels[old].remove(msg.sender);
                            levels[userInfo[msg.sender].node].add(msg.sender);
                            emit UpgradeUser(msg.sender,userInfo[msg.sender].node);
                            return true;
                        }else{
                            userInfo[msg.sender].node = minLevel + 1;
                            uint256 old = userInfo[msg.sender].node;
                            levels[old].remove(msg.sender);
                            levels[userInfo[msg.sender].node].add(msg.sender);
                            emit UpgradeUser(msg.sender,userInfo[msg.sender].node);
                            return true;
                        }
                        
                    }else{
                        revert("Grade non conformance");

                    }
            }else{
                revert("Referrals who do not belong to themselves");

            }
        }
        return false;
    }
}