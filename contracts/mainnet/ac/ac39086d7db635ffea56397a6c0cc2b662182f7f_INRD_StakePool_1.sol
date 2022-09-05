/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable  {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        _owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface Token {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function decimals() external view returns(uint256);

}


contract INRD_StakePool_1 is Ownable,ReentrancyGuard {
    
    using SafeMath for uint;

    struct User {
        uint256 poolBal;
        uint40 pool_deposit_time;
        uint256 total_deposits;
        uint256 pool_payouts;
        uint256 rewardEarned;
        uint256 rewardUnWithdrawed;
    }
    
    address public tokenAddr;
    uint256 public PoolBalance;
    uint256 public tokenDecimal;
    uint256 public poolNumber = 1;
    uint256 public poolMinStake = 100;
    uint256 public poolMaxStake = 25000000;
    uint256 public poolRewardPercent = 10;
    uint256 public earlyPenalty = 30;
    uint256 public fullMaturityTime = 30 days; 
    uint256 public totaldays = 30;

   

    mapping(address => User) public users;

    event TokenTransfer(address beneficiary, uint amount);
    event PoolTransfer(address beneficiary, uint amount);
    event RewardClaimed(address beneficiary, uint amount);
    
    mapping (address => uint256) public balances;


    constructor(address _tokenAddr) {
        tokenAddr = _tokenAddr;
        tokenDecimal = Token(tokenAddr).decimals();
    }
    
    /* Recieve Accidental BNB Transfers */
    receive() payable external {
        _owner.transfer(msg.value);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }


    /* Stake Token Function */
    function PoolStake(uint256  _amount) external nonReentrant returns (bool) {
        
        require(_amount <= Token(tokenAddr).balanceOf(msg.sender),"Token Balance of user is less");
        require(_amount >= poolMinStake * (10**tokenDecimal),"Token lower than minimum limit");
        require(_amount <= poolMaxStake * (10**tokenDecimal),"Token higher than maximum limit");
        require(Token(tokenAddr).transferFrom(msg.sender,address(this), _amount),"BEP20: Amount Transfer Failed Check id Amount is Approved");

        if(users[msg.sender].poolBal > 0){
            uint256 daysCompleted = ((block.timestamp).sub(users[msg.sender].pool_deposit_time)).div(1 days);
            require(daysCompleted>= (totaldays/2), "Should wait half time of full maturity before restaking");
            claimPoolTopup();
        }

        PoolBalance += _amount;
        users[msg.sender].poolBal += _amount;
        users[msg.sender].total_deposits += _amount;
        users[msg.sender].pool_deposit_time = uint40(block.timestamp);
        uint256 stakeRewards = (((users[msg.sender].poolBal * poolRewardPercent) / 100) / 360) * totaldays;
        users[msg.sender].rewardUnWithdrawed = stakeRewards; 
        
        emit PoolTransfer(msg.sender, _amount);
        return true;
    }

   function rewardsAccumulated(address _userAdd) external view returns(uint256){
        uint256 reward = users[_userAdd].rewardUnWithdrawed;
        if(block.timestamp > (users[_userAdd].pool_deposit_time + fullMaturityTime)){
            return reward;
        }else{
            return (reward/fullMaturityTime) * ((block.timestamp - users[_userAdd].pool_deposit_time) / 1 seconds) ;
        }
    }
    
    /* Claims Principal Token and Rewards Collected */
    function claimPool() external nonReentrant returns(bool){
        
        require(users[msg.sender].poolBal > 0,"There is no deposit for this address in Pool");

        uint256 amount = users[msg.sender].poolBal;
        uint256 reward = users[msg.sender].rewardUnWithdrawed;
        uint256 accumulatedReward;
        uint256 daysCompleted = ((block.timestamp).sub(users[msg.sender].pool_deposit_time)).div(1 days);

        if(block.timestamp < (users[msg.sender].pool_deposit_time + fullMaturityTime)){
            accumulatedReward = (((amount * poolRewardPercent) / 100) / 360) * daysCompleted;
            reward = accumulatedReward.sub((accumulatedReward).mul(earlyPenalty).div(100));
        }

        users[msg.sender].rewardUnWithdrawed = 0;
        users[msg.sender].poolBal = 0;
        users[msg.sender].pool_deposit_time = 0;
        users[msg.sender].pool_payouts += amount;
        users[msg.sender].rewardEarned += reward;

        require(Token(tokenAddr).transfer(msg.sender, amount),"Cannot Transfer Principal Funds");
        if(reward>0){
            require(Token(tokenAddr).transfer(msg.sender, reward),"Cannot Transfer Reward Funds");
        }

        emit RewardClaimed(msg.sender, reward);
        emit TokenTransfer(msg.sender, amount);

        return true;            
    }

    function claimPoolTopup() internal returns(bool){
        
        uint256 amount = users[msg.sender].poolBal;
        uint256 reward = users[msg.sender].rewardUnWithdrawed;
        uint256 accumulatedReward;
        uint256 daysCompleted = ((block.timestamp).sub(users[msg.sender].pool_deposit_time)).div(1 days);

        if(block.timestamp < (users[msg.sender].pool_deposit_time + fullMaturityTime)){
            accumulatedReward = (((amount * poolRewardPercent) / 100) / 360) * daysCompleted;
            reward = accumulatedReward;
        }

        users[msg.sender].rewardUnWithdrawed = 0;
        users[msg.sender].pool_deposit_time = 0;
        users[msg.sender].rewardEarned += reward;

        if(reward>0){
            require(Token(tokenAddr).transfer(msg.sender, reward),"Cannot Transfer Reward Funds");
        }

        emit RewardClaimed(msg.sender, reward);
        return true;            
    }

    
    /* Check Token Balance inside Contract */
    function tokenBalance() external view returns (uint256){
        return Token(tokenAddr).balanceOf(address(this));
    }

    /* Check BSC Balance inside Contract */
    function bnbBalance() external view returns (uint256){
        return address(this).balance;
    }

    function retrieveBnbStuck(address payable wallet) external onlyOwner() nonReentrant returns(bool){
        wallet.transfer(address(this).balance);
        return true;
    }

    function retrieveBEP20TokenStuck(address _tokenAddr,uint256 amount,address toWallet) external onlyOwner() nonReentrant returns(bool){
        Token(_tokenAddr).transfer(toWallet, amount);
        return true;
    }


    /* Calculate Remaining Staking Claim time of Users */
    function stakeTimeRemaining(address _userAdd) public view returns (uint256){
        if(users[_userAdd].pool_deposit_time > 0){
            uint256 stakeTime = users[_userAdd].pool_deposit_time + fullMaturityTime;
            if(stakeTime > block.timestamp){
                return (stakeTime - block.timestamp);
            }else{
                return 0;
            }
        }else{
            return 0;
        }
    }

    /* Admin function to update the pool Min Stake */
    function updatePoolMinStake(uint256 amount) external onlyOwner() returns(bool){
        poolMinStake = amount;
        return true;
    }

    /* Admin function to update the pool Max Stake */
    function updatePoolMaxStake(uint256 amount) external onlyOwner() returns(bool){
        poolMaxStake = amount;
        return true;
    }
    
    /* Maturity Date */
    function maturityDate(address userAdd) public view returns(uint256){
        return (users[userAdd].pool_deposit_time + fullMaturityTime);
    }

}