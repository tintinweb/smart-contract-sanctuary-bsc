/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// File: @openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
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

// File: LPStaking.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;





contract LPStakingECIOUSD is Ownable, ReentrancyGuard {
      // ************** Variables ******************** //
    uint256 private _totalSupply; // total staked amount
    uint256 public lastUpdateTime;
    uint256 private REWARD_PER_DAY = 1 * 1e6 * 1e18; // 1,000,000, ecio per day
    uint256 public REWARD_PER_SEC; // to be init || REWARD_PER_DAY / 86400;

    // ************** Structs ******************** //

    struct user_info{
        uint256 amount;
        uint256 rewarded;
    }
    struct locked_reward{
        uint256 unlockTime;
        uint256 lockedAmount;
    }
    // ************** MAPPINGs ******************** //

    mapping(address=>user_info) public UserInfo;
    address [] public userList;
    mapping(address=>locked_reward[]) public LockedReward;

    // ************** Connected Address ******************** //

    IERC20 public LP_TOKEN;
    IERC20 public ECIO_TOKEN;

    // ************** Event ******************** //

    event StakeEvent(address indexed account,uint256 indexed timestamp,uint256 amount);
    event UnStakeEvent(address indexed account,uint256 indexed timestamp,uint256 amount,uint256 reward);
    event UnStakeNowEvent(address indexed account,uint256 indexed timestamp,uint256 amount,uint256 reward,uint256 fee);
    event ClaimEvent(address indexed account,uint256 indexed timestamp,uint256 reward);

    // ************** Update Function ******************** //
    constructor (IERC20 _lpToken, IERC20 _ecioToken)  {
        LP_TOKEN=_lpToken;
        ECIO_TOKEN=_ecioToken;
        lastUpdateTime=block.timestamp;
        _totalSupply=0;
    }

    function updateLPAddress(IERC20 _address) public onlyOwner {
        LP_TOKEN = _address;
    }

    function updateEcioAddress(IERC20 _address) public onlyOwner {
        ECIO_TOKEN = _address;
    }

    // ************** View Functions ******************** //


    function checkUserLPBalance(address account) public view returns (uint256) {
        return LP_TOKEN.balanceOf(account);
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
    }
 //APR(%)
    function APRReturner(address _address) public view returns (uint256) {
        user_info storage user = UserInfo[_address];
        uint256 RPD = user.amount * (1e6) * (1e18) / _totalSupply;
        uint256 APR = RPD * 365 / (user.amount * (1e6));
        return APR / (1e12) + 100;
    }

    //APY(%)
    function APYReturner(address _address) public view returns (uint256) {
        user_info storage user = UserInfo[_address];
        uint256 RPD = user.amount * (1e6) * (1e18) / _totalSupply;
        uint256 MPR = RPD * 60 / (user.amount * (1e6));
        uint256 RMPR = MPR / (1e12) + 100;
        return RMPR * RMPR * RMPR * RMPR * RMPR * RMPR / (1e12);
    }

    function status(address _account,uint256 index) public view returns (string memory) {       

        if(LockedReward[_account][index].unlockTime>=block.timestamp)
        return "UNLOCKED";
        else return "LOCKED";
    }

    function duration(address _account, uint256 index) public view returns (uint256) {
        return LockedReward[_account][index].unlockTime-block.timestamp;
    }

    function lockedAmount(address _account, uint256 index) public view returns (uint256) {
        return LockedReward[_account][index].lockedAmount;
    }
    
    /************************* ACTION FUNCTIONS *****************************/
    function stake(uint amount) public
    {
        require(checkUserLPBalance(msg.sender)> amount);
        require(amount>0);
        LP_TOKEN.transferFrom(msg.sender,address(this), amount);
        if(_totalSupply>0)
            updatePool();
        _totalSupply+=amount;
        if(UserInfo[msg.sender].amount==0)
            userList.push(msg.sender);
        UserInfo[msg.sender].amount+=amount;
        lastUpdateTime=block.timestamp;        
    }

    function updatePool() internal
    {
        for (uint i=0;i<userList.length;i++)
        {
            uint256 duration_rewarded=REWARD_PER_SEC*(block.timestamp-lastUpdateTime)*UserInfo[userList[i]].amount/_totalSupply;
            UserInfo[userList[i]].rewarded+=duration_rewarded;
        }
    }

    function withDrawReward() public {
        uint256 unlockTime=block.timestamp+60 days;
        LockedReward[msg.sender].push(locked_reward(unlockTime,UserInfo[msg.sender].rewarded));
        UserInfo[msg.sender].rewarded=0;
    }

    function unStake() public {
        require(UserInfo[msg.sender].amount>0);
        updatePool();
        uint256 unlockTime=block.timestamp+60 days;
        LockedReward[msg.sender].push(locked_reward(unlockTime,UserInfo[msg.sender].rewarded));
        uint256 balance= UserInfo[msg.sender].amount;
        _totalSupply-=UserInfo[msg.sender].amount;
        lastUpdateTime=block.timestamp;
        UserInfo[msg.sender].amount=0;
        UserInfo[msg.sender].rewarded=0;
        require(balance>0);
        LP_TOKEN.transferFrom(address(this), msg.sender, balance);
        //delete element from userList
       removeUser(msg.sender);  
    }   
    function removeUser(address _account) internal{
        bool isFound=false;
        for(uint i=0;i<userList.length-1;i++)
        {
            if(userList[i]==_account)
                isFound=true;
            if(isFound==true)
                userList[i]=userList[i+1];
        }
        userList.pop();

    }
    /************************* Reward *******************************/
    function claim(uint256 index) public{
        require(LockedReward[msg.sender][index].unlockTime>block.timestamp);
        uint256 balance=LockedReward[msg.sender][index].lockedAmount;
        removeRewardItem(msg.sender,index);
        require(balance>0);
        ECIO_TOKEN.transferFrom(address(this),msg.sender,balance);
        
    } 
    function removeRewardItem(address _address,uint256 index) internal{
        for(uint256 i=index;i<LockedReward[_address].length-1;i++)
        {
            LockedReward[_address][i]=LockedReward[_address][i+1];
        }
        LockedReward[_address].pop();
    }
    function transferFee(address payable _to, uint256 _amount)
        public
        onlyOwner
    {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function transferToken(
        address _contractAddress,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_to, _amount);
    }
}