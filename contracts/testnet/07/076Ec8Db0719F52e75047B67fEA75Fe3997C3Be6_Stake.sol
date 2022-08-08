/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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

    ITRC20 private token; 

    bool private initialized = false;

    uint256 private pools = 0;

    struct UserStruct{
        bool isExist;
        address referral;       
    }

    struct StackStruct {
        uint256 amount;
        uint256 stackTime;
        uint256 unstakeTime;
        uint256 harvested;
        uint256 poolId;
    }

    mapping(address => UserStruct)public userDetails;
    mapping (address => StackStruct[]) public stakeDetails;
    mapping (uint256 => uint256) public pool;

    event UnStacked(address _staker, uint256 _poolId, uint256 _amount, uint256 _time);
    event Harvested(address _staker, uint256 _poolId, uint256 _amount, uint256 _time);
    event Stacked(address _staker, uint256 _poolId, uint256 amount, address _referral, uint256 _time);
   
    function initializeToken(address _token) onlyOwner public returns (bool) {
        require(!initialized, "Already Initialized");
        initialized = true;
        token = ITRC20(_token);
        return true;
    }
    

    function poolLength() public view returns(uint256){
        return pools;
    }

    function setPools(uint256[] memory _lockPeriod) public onlyOwner returns(bool){
        for(uint256 i = 0; i < _lockPeriod.length; i++){
            pool[pools] = _lockPeriod[i];
            pools++;
        }
        return true;
    }

    function staking(uint256 _amount, uint256 _poolId, address _referral) public  returns(bool) {
        require (ITRC20(token).allowance(msg.sender, address(this)) >= _amount, "Token not approved");       
        if(!userDetails[msg.sender].isExist){
            UserStruct memory userInfo;
            userInfo = UserStruct({
                isExist : true,
                referral : _referral
            });
            userDetails[msg.sender] = userInfo;
        }
        StackStruct memory stackerinfo;
        stackerinfo = StackStruct({
            amount: _amount,
            stackTime : block.timestamp,
            unstakeTime : block.timestamp + pool[_poolId],
            harvested: 0,
            poolId : _poolId
        });
        ITRC20(token).transferFrom(msg.sender, address(this), _amount);
        stakeDetails[msg.sender].push(stackerinfo);
        emit Stacked(msg.sender, _poolId, _amount, _referral, block.timestamp);
        return true;
    }


    function unstaking(uint256 _stakingId) public returns (bool){        
        require(stakeDetails[msg.sender][_stakingId].stackTime != 0, "Token not exist");
        require(stakeDetails[msg.sender][_stakingId].unstakeTime <= block.timestamp, "Token can unstake after locking period");
        ITRC20(token).transfer(msg.sender, stakeDetails[msg.sender][_stakingId].amount);
        if(getCurrentReward(msg.sender, _stakingId) > 0){
            _harvest(msg.sender, _stakingId);
        }
        stakeDetails[msg.sender][_stakingId] = stakeDetails[msg.sender][stakeDetails[msg.sender].length-1];
        stakeDetails[msg.sender].pop();
        if(stakeDetails[msg.sender].length == 0){
            delete userDetails[msg.sender];
        }
        emit UnStacked(msg.sender, stakeDetails[msg.sender][_stakingId].poolId, stakeDetails[msg.sender][_stakingId].amount, block.timestamp);
        return true;
    }

    function harvest(uint256 _stakingId) public  returns (bool) {
        _harvest(msg.sender, _stakingId);
        return true;
    }

    function _harvest(address _user, uint256 _stakingId) internal  {
        require(getCurrentReward(_user,_stakingId) > 0, "Nothing to harvest");
        uint256 harvestAmount = getCurrentReward(_user,_stakingId);
        stakeDetails[_user][_stakingId].harvested += harvestAmount;
        token.transfer(_user, harvestAmount);
        emit Harvested(_user, stakeDetails[msg.sender][_stakingId].poolId, harvestAmount, block.timestamp);
    }

    function getTotalReward(address _user, uint256 _stakingId) public view returns (uint256) {  
        return  (((block.timestamp - stakeDetails[_user][_stakingId].stackTime)) * stakeDetails[_user][_stakingId].amount *  10 / 100) / 1 minutes;
    }

    function getCurrentReward(address _user, uint256 _stakingId) public view returns (uint256) {
        if(stakeDetails[_user][_stakingId].amount != 0){
            return (getTotalReward(_user, _stakingId)) - (stakeDetails[_user][_stakingId].harvested);
        }else{
            return 0;
        }
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