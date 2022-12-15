/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT
    pragma solidity 0.8.9;

interface IERC20 {
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
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


    contract Vesting is  Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public vestingID;
    mapping(uint256 => VestingDetails) public idToVesting;
    mapping(address => uint256[]) public userVests;
    mapping(address => uint256) public userTgeAmount;
    mapping(address => uint256) public tgeAmountReleased;
    mapping(address => bool) public allowedToCall;
    address public astorToken;
    uint256 public totalTokensVested;
    uint256 public totalTokensUnvested;
    uint256 public totalTgeAmount;
    uint256 public totalTgeAmountReleased;
    uint256 public cliff = 7890000;
    uint256 public teamCliff = 15780000;
    uint256 public advisorCliff = 7890000;
    uint256 public phase2TgeAmount = 500;
    uint256 public phase3TgeAmount = 750;
    uint256 public phase4TgeAmount = 1000;
    uint256 public phase5TgeAmount = 1250;
    uint256 public phase1VestTime = 12;
    uint256 public phase2VestTime = 10;
    uint256 public phase3VestTime = 8;
    uint256 public phase4VestTime = 6;
    uint256 public phase5VestTime = 5;
    uint256 public advisorVestTime = 24;
    uint256 public teamVestTime = 48;
    uint256 public advisorAmount = 60000000000000000000000000;
    uint256 public teamAmount = 287090571000000000000000000;
    uint256 public advisorAmountAdded;
    uint256 public teamAmountAdded;
    
    address[] public allUsers;
    mapping(address => bool) public added;



    struct VestingDetails{

        uint256 tokensDeposited;
        uint256 tokensWithdrawn;
        uint256 startTime;
        uint256 endTime;
        uint256 releasePerEpoch;
        uint256 epoch;
        address owner;
        uint256 phase;
        uint256 lockId;
        bool isActive;
    }
    
    event Vested(uint256 indexed id, address indexed user);
    event Unvested(uint256 indexed id, uint256 amount);
    event TgeAmountReleased(address indexed user, uint256 amount);
    constructor(address token) {
       astorToken = token;
    }


    function vestTokenIco(address user, uint256 amount, uint256 phase) public returns(uint256 id){
        require(allowedToCall[msg.sender],"Access Denied");
        if(added[user] == false){
           allUsers.push(user);
           added[user] = true;
        }
        vestingID.increment();
        id = vestingID.current();
        (uint256 tgeAmount, uint256 vestAmount, uint256 releasePerEpoch, uint256 endTime) = getAmounts(amount, phase);
        userTgeAmount[user] += tgeAmount;
        totalTgeAmount += tgeAmount;
        totalTokensVested += vestAmount;
        idToVesting[id] = VestingDetails({
        tokensDeposited : vestAmount,
        tokensWithdrawn: 0,
        startTime : cliff + block.timestamp,
        endTime : endTime,
        releasePerEpoch : releasePerEpoch,
        epoch : 2630000,
        owner : user,
        phase : phase,
        lockId : id,
        isActive : true
        });
        userVests[user].push(id);
        emit Vested(id, user);
        return(id);
    }

    function getAmounts(uint256 totalAmount, uint256 phase) public view returns
    (uint256 tgeAmount, uint256 vestAmount, uint256 releasePerEpoch, uint256 endTime){
       if(phase == 1){

          tgeAmount = 0;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase1VestTime;
          endTime = cliff + block.timestamp + phase1VestTime * 2630000;
                
       }
       else if(phase == 2){

          tgeAmount = (totalAmount*phase2TgeAmount)/10000;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase2VestTime;
          endTime = cliff + block.timestamp + phase2VestTime * 2630000;
           
       }
       else if(phase == 3){
          tgeAmount = (totalAmount*phase3TgeAmount)/10000;
          tgeAmount = 0;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase3VestTime;
          endTime = cliff + block.timestamp + phase3VestTime * 2630000;
       }
       else if(phase == 4){
           
          tgeAmount = (totalAmount*phase4TgeAmount)/10000;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase4VestTime;
          endTime = cliff + block.timestamp + phase4VestTime * 2630000;
       }
       else if(phase == 5){
          tgeAmount = (totalAmount*phase5TgeAmount)/10000;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase5VestTime;
          endTime = block.timestamp + phase5VestTime * 2630000;
       }
   }

    function unvestAllTokens(address user) external {
       require(msg.sender == user|| msg.sender == owner(),"Not allowed to unvest"); 
       uint256 totalVests = userVests[user].length;
       for(uint256 i =0; i< totalVests;i++){
          if(idToVesting[userVests[user][i]].isActive){
            unvestToken(userVests[user][i], user);
          }
       }
    }

    function unvestToken(uint256 id, address user) public returns(uint256 amountUnvested){
        require(msg.sender == user || msg.sender == address(this) || msg.sender == owner(),"Not allowed to unvest");
        require(block.timestamp > idToVesting[id].startTime + idToVesting[id].epoch, "WindowClosed");
        uint256 endTimestamp;
        if(block.timestamp > idToVesting[id].endTime){
           endTimestamp = idToVesting[id].endTime;
        }
        else{
           endTimestamp = block.timestamp;
        }
        uint256 eligibleEpoch = (endTimestamp - idToVesting[id].startTime)/ idToVesting[id].epoch;
        uint256 calculatedAmount = (eligibleEpoch * idToVesting[id].releasePerEpoch) - 
        idToVesting[id].tokensWithdrawn;
        IERC20(astorToken).transfer(idToVesting[id].owner, calculatedAmount); 
        idToVesting[id].tokensWithdrawn += calculatedAmount; 
        totalTokensUnvested += calculatedAmount;
        if(idToVesting[id].tokensDeposited == idToVesting[id].tokensWithdrawn){
           idToVesting[id].isActive == false;
        } 
   
        emit Unvested(id, calculatedAmount);
        return(calculatedAmount);
    }

    function updateAllowed(address user, bool allowed) external onlyOwner{
        allowedToCall[user] = allowed;
    }

    function distributeTgeAmount() external onlyOwner{
       uint256 totalUsers = allUsers.length;
       for(uint256 i =0; i< totalUsers; i++){
          if(userTgeAmount[allUsers[i]]>0){
           IERC20(astorToken).transfer(allUsers[i],userTgeAmount[allUsers[i]]);
           tgeAmountReleased[allUsers[i]] += userTgeAmount[allUsers[i]];
           totalTgeAmountReleased += userTgeAmount[allUsers[i]];
           emit TgeAmountReleased(allUsers[i],userTgeAmount[allUsers[i]]);
           userTgeAmount[allUsers[i]] = 0;
          }
       }
   }

   function addAdvisorVest(address user, uint256 amount) external onlyOwner{
   require(advisorAmountAdded + amount <= advisorAmount,"Limit Exceeded");
   advisorAmountAdded += amount;
   if(added[msg.sender] == false){
           allUsers.push(msg.sender);
        }
        vestingID.increment();
        uint256 id = vestingID.current();
        totalTokensVested += amount;
        idToVesting[id] = VestingDetails({
        tokensDeposited : amount,
        tokensWithdrawn: 0,
        startTime : advisorCliff + block.timestamp,
        endTime : advisorCliff + block.timestamp + advisorVestTime * 2630000,
        releasePerEpoch : amount/advisorVestTime,
        epoch : 2630000,
        owner : user,
        phase : 0,
        lockId : id,
        isActive : true
        });
        userVests[user].push(id);
        emit Vested(id, user);

   } 

   function addTeamVest(address user, uint256 amount) external onlyOwner{
   require(teamAmountAdded + amount <= teamAmount,"Limit Exceeded");
   teamAmountAdded += amount;
   if(added[msg.sender] == false){
           allUsers.push(msg.sender);
        }
        vestingID.increment();
        uint256 id = vestingID.current();
        totalTokensVested += amount;
        idToVesting[id] = VestingDetails({
        tokensDeposited : amount,
        tokensWithdrawn: 0,
        startTime : teamCliff + block.timestamp,
        endTime : teamCliff + block.timestamp + teamVestTime * 2630000,
        releasePerEpoch : amount/teamVestTime,
        epoch : 2630000,
        owner : user,
        phase : 0,
        lockId : id,
        isActive : true
        });
        userVests[user].push(id);
        emit Vested(id, user);

   } 

   function amountUnlocked(address user) external view returns(uint256 amount){
       uint256 totalVests = userVests[user].length;
       for(uint256 i =0; i< totalVests;i++){
         if(idToVesting[userVests[user][i]].isActive){
            uint256 endTimestamp;
        if(block.timestamp > idToVesting[i].endTime){
           endTimestamp = idToVesting[i].endTime;
        }
        else{
           endTimestamp = block.timestamp;
        }
        uint256 eligibleEpoch = (endTimestamp - idToVesting[i].startTime)/ idToVesting[i].epoch;
        amount += (eligibleEpoch * idToVesting[i].releasePerEpoch) - 
        idToVesting[i].tokensWithdrawn;
          }
       }
   }

    function updateAstorToken(address token) external onlyOwner{
        astorToken = token;
    }



}