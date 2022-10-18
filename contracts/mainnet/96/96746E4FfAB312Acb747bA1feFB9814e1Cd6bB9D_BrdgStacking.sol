/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

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

contract BrdgStacking is Ownable{

  
    struct userStack {
        uint256 amount;
        uint256 lockAt;
        bool isSet;
        bool claimed;

    }
    mapping(address => userStack) public usersStack;
    mapping(uint256 => address) public stackers;
    address public brgToken;
    uint256 public lockAmount;
    uint256 public startAt;
    uint256 public unlockTime;
    uint256 public maxLocks = 200;
    uint256 public lockCount;
    event LockAsset(address indexed user, uint256 amount);
    event Claimed(address indexed user ,  uint256 amount);
    event unLockTimeUpdated( uint256 unLockTime);
    event lockAmountUpdated( uint256 prevAmount, uint256 newAmount);
    
    constructor(address _brgToken , uint256 _unlockTime, uint256 _lockAmount){
        brgToken = _brgToken;
        unlockTime = block.timestamp + (_unlockTime * 1 days);
        startAt = block.timestamp;
        lockAmount = _lockAmount;
    }
    function updateLockAmount(uint256 amount ) public onlyOwner {
        require(amount > 0 && amount != lockAmount , "invalid value");
        lockAmountUpdated(lockAmount , amount);
        lockAmount = amount;

    }
      function ExtendUnlockTime(uint256 _days ) public onlyOwner {
        require(_days > 0  , "invalid value");
        unlockTime += _days * 1 days;
        unLockTimeUpdated(unlockTime);

    }

    function lockAsset() public  {
        require(!usersStack[msg.sender].isSet  ,"already  stacked");
        require(lockCount < maxLocks  ,"already  stacked");
        require( processedPayment(lockAmount) , "Amount Error");
        usersStack[msg.sender] = userStack(lockAmount ,block.timestamp , true , false);
    
        stackers[lockCount++] = msg.sender;
        emit LockAsset(msg.sender,  lockAmount);
     
    }
    
    
     
    function checkUserLock(address user) public view returns(bool ,uint256) {
         return(usersStack[user].isSet ,usersStack[user].amount);
    }
     function claim() public {
         require(block.timestamp - startAt >= unlockTime , "not yet time");
         require(usersStack[msg.sender].isSet || !usersStack[msg.sender].claimed , "no lock available");
         usersStack[msg.sender].claimed = true;
        payoutUser(msg.sender , usersStack[msg.sender].amount);
        emit Claimed(msg.sender  ,usersStack[msg.sender].amount);

        
    }
  
    function payoutUser(address  recipient , uint256 amount) private{
       require(recipient != address(0) , "invalid reciever");
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