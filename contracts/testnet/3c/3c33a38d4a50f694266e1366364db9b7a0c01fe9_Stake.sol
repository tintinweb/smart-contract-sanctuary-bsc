/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 * @dev Interface of the BEP20 standard as defined in the BIP.
 */
interface IBEP20 {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
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

    struct PoolStruct {
        address tokenAddress;
        address rewardAddress;
        uint256 rewardPer;
        uint256 referralPer;
        uint256 lockPeriod;
        uint256 time;
    }

    struct UserStruct{
        bool isExist;
        address referral;       
    }

    struct StackStruct {
        uint256 amount;
        uint256 stackTime;
        uint256 unstakeTime;
        uint256 poolId;
    }

    mapping(address => UserStruct)public userDetails;
    mapping (address => StackStruct[]) public stakeDetails;
    PoolStruct[] public pool;

    event Stacked(address staker, uint256 poolId, uint256 amount, address referral, uint256 time);
    event UnStacked(address staker, uint256 poolId, uint256 amount, uint256 time);
    event Harvested(address staker, uint256 poolId, uint256 amount, uint256 time);
    event PoolCreation (address tokenAddress, address rewardAddress, uint256 rewardPer, uint256 lockPeriod, uint256 time);
    
    function createPool(address _tokenAddress, address _rewardAddress, uint256 _rewardPer, uint256 _lockPeriod, uint256 _referralPer) public onlyOwner returns (bool){
        require(_tokenAddress != address(0), "Invalid Address");
        require(_rewardPer > 0, "Reward per must be greater than 0");
        PoolStruct memory poolInfo;
        poolInfo = PoolStruct({
            tokenAddress : _tokenAddress,
            rewardAddress: _rewardAddress,
            rewardPer    : _rewardPer,
            lockPeriod   : _lockPeriod,
            referralPer  : _referralPer,
            time         : block.timestamp
        });
        pool.push(poolInfo);
        emit PoolCreation(_tokenAddress, _rewardAddress, _rewardPer, _lockPeriod, block.timestamp);
        return true;
    }

    function staking(uint256 _amount, uint256 _poolId, address _referral) public  returns(bool) {
        require(msg.sender != _referral, "Staker and referral address must not same");
        require (IBEP20(pool[_poolId].tokenAddress).allowance(msg.sender, address(this)) >= _amount, "Token not approved");  
        IBEP20(pool[_poolId].tokenAddress).transferFrom(msg.sender, address(this), _amount);     
        if(!userDetails[msg.sender].isExist){
            UserStruct memory userInfo;
            userInfo = UserStruct({
                isExist : true,
                referral : _referral
            });
            userDetails[msg.sender] = userInfo;
            if(_referral != address(0)){
                IBEP20(pool[_poolId].tokenAddress).transferFrom(address(this), _referral, _amount * pool[_poolId].referralPer / 100);
            }
        }
        StackStruct memory stackerinfo;
        stackerinfo = StackStruct({
            amount: _amount,
            stackTime : block.timestamp,
            unstakeTime : block.timestamp + pool[_poolId].lockPeriod,
            poolId : _poolId
        });       
        stakeDetails[msg.sender].push(stackerinfo);
        emit Stacked(msg.sender, _poolId, _amount, _referral, block.timestamp);
        return true;
    }


    function unstaking(uint256 _stakingId) public returns (bool){        
        require(stakeDetails[msg.sender][_stakingId].stackTime != 0, "Token not exist");
        require(stakeDetails[msg.sender][_stakingId].unstakeTime <= block.timestamp, "Token can unstake after locking period");      
        stakeDetails[msg.sender][_stakingId] = stakeDetails[msg.sender][stakeDetails[msg.sender].length-1];
        stakeDetails[msg.sender].pop();
        if(stakeDetails[msg.sender].length == 0){
            delete userDetails[msg.sender];
        }
        IBEP20(pool[stakeDetails[msg.sender][_stakingId].poolId].tokenAddress).transfer(msg.sender, stakeDetails[msg.sender][_stakingId].amount);
        emit UnStacked(msg.sender, stakeDetails[msg.sender][_stakingId].poolId, stakeDetails[msg.sender][_stakingId].amount, block.timestamp);
        return true;
    }

    function viewStakeLength(address _account) public view returns(uint256) {
        return stakeDetails[_account].length;
    }

    function viewPoolLength() public view returns(uint256){
        return pool.length;
    }

    function transferTokens(uint256 _amount, address _token) public onlyOwner{
        require(IBEP20(_token).balanceOf(address(this)) > _amount , "Not Enough Tokens");
        IBEP20(_token).transfer(owner(), _amount);
    } 
}