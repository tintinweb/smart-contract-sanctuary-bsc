/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the BIP.
 */
interface ITRC20 {
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
}


contract Stake is Ownable {

    ITRC20 private token;  

    bool private initialized = false;

    uint256[6] private rewardPer = [0, 0, 5, 7, 9, 11];

    struct StackStruct {
        uint256 amount;
        uint256 stakeTime;
        uint256 unStakeTime;
        uint256 harvested;
        uint8 stakeType;
    }

    uint256[6] private lockperiod = [9 minutes, 12 minutes, 18 minutes, 24 minutes, 30 minutes, 36 minutes]; 
    
    mapping (address => StackStruct[]) public stakeDetails;

    event Stacked(address _staker, uint256 _amount, uint8 _stakeType,  uint256 _time);
    event UnStacked(address _staker, uint256 _amount, uint256 _time);
    event Harvested(address _staker, uint256 _amount, uint256 _time);

    function initialize(address _token) onlyOwner public returns (bool) {
        require(!initialized, "Already Initialized");
        initialized = true;
        token = ITRC20(_token);
        return true;
    }

    function stake (uint256 _amount, uint8 _stakeType) public returns (bool) {
        require (token.allowance(msg.sender, address(this)) >= _amount, "Token not approved");
        token.transferFrom(msg.sender, address(this), _amount);
        StackStruct memory stackerinfo;    
        stackerinfo = StackStruct({
            amount: _amount,
            stakeTime: block.timestamp,
            unStakeTime : block.timestamp + lockperiod[_stakeType],
            harvested: 0,
            stakeType: _stakeType
        });
        stakeDetails[msg.sender].push(stackerinfo);
        emit Stacked(msg.sender, _amount, _stakeType, block.timestamp);
        return true;
    }

    function unstake (uint256 _depositId) public returns (bool) {
        require(_depositId <  stakeDetails[msg.sender].length, "TimeLockPool.withdraw: Stake does not exist");
        require (block.timestamp > stakeDetails[msg.sender][_depositId].unStakeTime, "Amount is in lock period");
        if(getCurrentReward(msg.sender,_depositId) > 0){
            _harvest(msg.sender, _depositId);
        }      
        token.transfer(msg.sender, stakeDetails[msg.sender][_depositId].amount);
        emit UnStacked(msg.sender, stakeDetails[msg.sender][_depositId].amount, block.timestamp);
        stakeDetails[msg.sender][_depositId] = stakeDetails[msg.sender][stakeDetails[msg.sender].length - 1];
        stakeDetails[msg.sender].pop();      
        return true;
    }

    function harvest(uint256 _depositId) public returns (bool) {
        _harvest(msg.sender, _depositId);
        return true;
    }

    function _harvest(address _user, uint256 _depositId) internal {
        require(getCurrentReward(_user,_depositId) > 0, "Nothing to harvest");
        uint256 harvestAmount = getCurrentReward(_user,_depositId);
        stakeDetails[_user][_depositId].harvested += harvestAmount;
        token.transfer(_user, harvestAmount);
        emit Harvested(_user, harvestAmount, block.timestamp);
    }

    function getRewardPer(uint8 _stakeType) public view returns (uint256) {      
        return rewardPer[_stakeType];
    }

    function getLockperiod(uint8 _stakeType) public view returns (uint256) {      
        return lockperiod[_stakeType];
    }

    function getTotalReward(address _user, uint256 _depositId) public view returns (uint256) {      
        return (((block.timestamp - stakeDetails[_user][_depositId].stakeTime)) * stakeDetails[_user][_depositId].amount * rewardPer[stakeDetails[_user][_depositId].stakeType] / 100) / 1 minutes;
    }

    function getCurrentReward(address _user, uint256 _depositId) public view returns (uint256) {
        if(stakeDetails[_user][_depositId].amount != 0){
            return (getTotalReward(_user, _depositId)) - (stakeDetails[_user][_depositId].harvested);
        }else{
            return 0;
        }
    }

    function changeAPYPer(uint256 _per, uint8 _stakeType) public onlyOwner returns (bool) {
        rewardPer[_stakeType] = _per;
        return true;
    }

    function getToken() public view returns (ITRC20) {
        return token;
    }

    function getStakeLength(address _account) public view returns(uint256) {
        return stakeDetails[_account].length;
    }

    function transferTokens(uint256 _amount) public onlyOwner{
        require(token.balanceOf(address(this)) > _amount , "Not Enough Tokens");
        token.transfer(owner(), _amount);
    } 
     
}