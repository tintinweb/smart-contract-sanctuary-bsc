// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// File: @openzeppelin/contracts/access/Ownable.sol
 


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
    constructor ()  {
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
     * @dev Transfers owanership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

contract BrdgVesting is Ownable{
    struct lock {
        uint256 intervals;
        uint256 period;
        bool recallable;
        bool isSet;
    }
    struct userLock {
        uint256 lockID;
        uint256 amount;
        uint256 claimed;
        uint256 lastclaimedAt;
        uint256 harvestCount;
        uint256 startTime;
        bool isSet;
        bool completed;

    }
    address brgToken;
    uint256 public lockIds;
    mapping(uint256 => lock) public locks;
    mapping(address => uint256) public userLockCount;
    mapping(address => mapping(uint256 => userLock)) public userLocks;
    constructor(address _brgToken){
        brgToken = _brgToken;
    }
    function addLock(uint256 interval , uint256 period , bool recallable) public onlyOwner {
        require(interval > 0 && period > 0 ,"input error");
        locks[lockIds++] = lock(interval , period , recallable ,true);
    }
    function lockAsset(uint256 lockId , address user, uint256 amount ,uint256 startIn) public onlyOwner {
        require(locks[lockId].isSet ,"invalid LockID");
        require( processedPayment(amount) , "amount Error");
        uint256 start = block.timestamp + startIn;
        userLocks[user][userLockCount[user]++] = userLock(lockId , amount , 0, start, 0 , start, true, false); 
     
    }
     function batchlock(uint256 lockId , address[] calldata users, uint256[] calldata amounts ,uint256 startIn) public onlyOwner {
        require(locks[lockId].isSet ,"invalid LockID");
        require(users.length == amounts.length , "data mistmatch");
        uint256 total;
        for(uint256  count ; count <amounts.length ; count++){
            require(amounts[count] != 0 , "invalidValue");
            total += amounts[count];
        }
        require( processedPayment(total) , "amount Error");

        uint256 start = block.timestamp + startIn;

        
     for(uint256  i ; i <users.length ; i++){
           userLocks[users[i]][userLockCount[users[i]]++] = userLock(lockId , amounts[i] , 0, start, 0 , start, true, false);
        }
    }
    function available(address user,uint256 id) public view returns(uint256) {
         require(userLocks[user][id].isSet && !userLocks[user][id].completed ,"Id Error");
         uint256 currentInterval = block.timestamp -  userLocks[msg.sender][id].lastclaimedAt;
         uint256 times =  currentInterval / locks[userLocks[msg.sender][id].lockID].intervals ;
         if(times == 0){
             return  0;
         }
        if(times + userLocks[msg.sender][id].harvestCount > locks[userLocks[msg.sender][id].lockID].period){
            times = locks[userLocks[msg.sender][id].lockID].period - userLocks[msg.sender][id].harvestCount;
        }
         return times * userLocks[msg.sender][id].amount / locks[userLocks[msg.sender][id].lockID].period;
    }
     function recallLock(address user , uint256 id ) public onlyOwner{
        require(userLocks[user][id].isSet && !userLocks[user][id].completed ,"Id Error");
        require(locks[userLocks[user][id].lockID].recallable , "none reversible");
        uint256 recallValue = userLocks[user][id].amount - userLocks[user][id].claimed;
        payoutUser(owner() , recallValue);
        userLocks[user][id].completed = true;
        
    }
    function harvest(uint256 id) public {
         require(userLocks[msg.sender][id].isSet && !userLocks[msg.sender][id].completed ,"Id Error");
         uint256 currentInterval = block.timestamp -  userLocks[msg.sender][id].lastclaimedAt;
         uint256 times =  currentInterval / locks[userLocks[msg.sender][id].lockID].intervals ;
         require(times > 0, "no yet time");
        if(times + userLocks[msg.sender][id].harvestCount > locks[userLocks[msg.sender][id].lockID].period){
            times = locks[userLocks[msg.sender][id].lockID].period - userLocks[msg.sender][id].harvestCount;
        }
         uint256 availableToClaim  = times * userLocks[msg.sender][id].amount /  locks[userLocks[msg.sender][id].lockID].period;
         require(userLocks[msg.sender][id].claimed + availableToClaim <= userLocks[msg.sender][id].amount , "excessAmount");

         userLocks[msg.sender][id].claimed += availableToClaim;
         userLocks[msg.sender][id].harvestCount += times;
         userLocks[msg.sender][id].lastclaimedAt = block.timestamp;
         payoutUser(msg.sender , availableToClaim);
         if(userLocks[msg.sender][id].harvestCount >= locks[userLocks[msg.sender][id].lockID].period ||userLocks[msg.sender][id].claimed >= userLocks[msg.sender][id].amount ){
         userLocks[msg.sender][id].completed = true;
         }

    }
    function payoutUser(address  recipient , uint256 amount) private{
       require(recipient != address(0) , "A_z");
             IERC20(brgToken).transfer(recipient , amount);
        
    }
    // internal fxn used to process incoming payments 
    function processedPayment( uint256 amount ) internal returns (bool) {
        
            IERC20 token = IERC20(brgToken);
            if(token.allowance(_msgSender(), address(this)) >= amount  ){
               token.transferFrom(_msgSender() , address(this) , amount);
               return true;
            }else{
                return false;
            }
        
    }

}