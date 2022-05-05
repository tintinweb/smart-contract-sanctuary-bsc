/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity >= 0.7.0 < 0.9.0;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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


contract dexStake{
    /*
    ToDO 
    */
    address private tokenAddress; //token address used for stake
    address private SetterAddress; // setter of the rewards and contract
    uint256 private totalStaking = 0; // total tokens added for stake by users
    uint256 private totalRewards = 0; // total tokens added for reward by setter
    uint256 private totalRewardsWon = 0; // total tokens Rewards Retrieved by users
    uint256 private lockedpool = 0; // make a lock on the pool not to allow more stakes (allow other withdrawls, add rewards, etc)
    address private teamMember1;
    address private teamMember2;
    address private teamMember3;
    mapping(uint256 => address) private stakingAddress; //List with all addreses staking
    uint256 private StakingAddressCount = 1;
    mapping(address => uint256) private balances; //Total balance for the stake (not including rewards)
    mapping(address => uint256) private rewardWon; //Reward taken out from staking
    mapping(address => mapping (uint256 => uint256)) private rewards; //balance for reward to withdraw
    mapping(address => mapping (uint256 => uint256)) private amountStaked; //added time for stake
    mapping(address => mapping (uint256 => uint256)) private savedAmountStaked; //added time for stake
    mapping(address => mapping (uint256 => uint256)) private timeStake; //added time for stake
    mapping(address => uint256) stakeCount; //added time for stake
    mapping(address => mapping (uint256 => uint256)) private rewardAdd; //allowed
    mapping(address => mapping (address => uint256)) private teamAllow; //allowed
    //uint256 stakingperiod = 31536000; //1 year staking
    uint256 private stakingperiod = 31536000; //5 minutes staking period
    string name;

    event Staked(address indexed token, address indexed staker_, uint256 stakedAmount_, uint256 indexed _time);
    event EarlyWithdraw(address indexed token, address indexed staker_, uint256 stakedAmount_, uint256 indexed _time);
    event StakedOut(address indexed token, address indexed staker_, uint256 stakedAmount_, uint256 indexed _time);
    event RewardAdd(address indexed token, address indexed staker_, uint256 stakedAmount_);
    event RewardSet();
    event PoolLocked();
    event PoolUnlocked();


   constructor(address _tokenAddress, address _teamMember1, address _teamMember2, address _teamMember3,string memory _name, uint256 _stakingperiod){
        tokenAddress = _tokenAddress; 
        SetterAddress = msg.sender;
        teamMember1 = _teamMember1;  
        teamMember2 = _teamMember2;  
        teamMember3 = _teamMember3;  
        name = _name;
        stakingperiod = _stakingperiod;
       
    }

    //add reward by owner of the pool
    function addReward(uint _amount) _approvedByAnyTeam() public returns(bool){
        IERC20(tokenAddress).transferFrom(msg.sender, address(this) ,_amount);
        totalRewards += _amount;
        emit RewardAdd(tokenAddress, msg.sender, _amount);
        return true;
    }

    //stake tokens after aproval
    function stakeTokens(uint _amount ) _realAddress(msg.sender) _positive(_amount) _notlocked() public returns (bool){
        IERC20(tokenAddress).transferFrom(msg.sender, address(this) ,_amount);
        balances[msg.sender] += _amount;
        amountStaked[msg.sender][block.timestamp] = _amount;
        savedAmountStaked[msg.sender][block.timestamp] = _amount;
        if(stakeCount[msg.sender]<1){
            stakeCount[msg.sender] = 1;
            stakingAddress[StakingAddressCount] = msg.sender;
            StakingAddressCount++;
        }
        timeStake[msg.sender][stakeCount[msg.sender]] = block.timestamp;
        stakeCount[msg.sender]++;
        totalStaking+= _amount;
        emit Staked(tokenAddress, msg.sender, _amount, block.timestamp);
        return true;
    }

    //withdraw after staking ends
    function withdrawStake(uint256 _timestamp) _realAddress(msg.sender)  public returns(bool){
        require(stakeCount[msg.sender]>1,"You have no staked tokens");
        require(amountStaked[msg.sender][_timestamp]>0,"You have no staked rewards");
        require((_timestamp+stakingperiod) < block.timestamp,"Staking period not finished! Try early withdraw!");
        require(rewardAdd[msg.sender][_timestamp]==1,"Please wait! Reward has not been added!");
        uint256 totalamount = _totalamount(_timestamp);
        IERC20(tokenAddress).transfer(msg.sender,totalamount);
        balances[msg.sender] -= amountStaked[msg.sender][_timestamp];
        rewardWon[msg.sender] += rewards[msg.sender][_timestamp];
        totalStaking -= amountStaked[msg.sender][_timestamp];
        totalRewardsWon += rewards[msg.sender][_timestamp];
        amountStaked[msg.sender][_timestamp] = 0;
        //rewards[msg.sender][_timestamp] = 0;
        emit StakedOut(tokenAddress, msg.sender, totalamount, block.timestamp);
        return true;
    }

    //withdraw early with losing all rewards
    function earlyWithdraw(uint _timestamp) _realAddress(msg.sender) public returns(bool){
        require(stakeCount[msg.sender]>1,"You have no staked tokens");
        require(amountStaked[msg.sender][_timestamp]>0,"You have no staked rewards");
        uint256 totalamount = _totalamountWithoutReward(_timestamp);
        IERC20(tokenAddress).transfer(msg.sender,totalamount);
        totalStaking-= amountStaked[msg.sender][_timestamp];
        amountStaked[msg.sender][_timestamp] = 0;
        emit EarlyWithdraw(tokenAddress, msg.sender, totalamount, block.timestamp);
        return true;
    }
    
    //withdraw any funds that were added by mistake (different tokens)
    // failsafe with funds
    function withdrawAnyWrongTokenFunds(address _token) _realAddress(msg.sender) _realAddress(_token) _setter(msg.sender) _approvedByTeam(_token) public returns (bool){
        IERC20(_token).transfer(msg.sender,IERC20(_token).balanceOf(address(this)));
        return true;
    }

    //set rewards by owner
    function setRewards(address[] memory _address,uint256[] memory _timestamp,uint256[] memory _reward) _approvedByAnyTeam() public returns(bool){
        for(uint i=0;i<_address.length;i++){
            rewards[_address[i]][_timestamp[i]] = _reward[i];
            rewardAdd[_address[i]][_timestamp[i]] = 1;
        }
        emit RewardSet();
        return true;
    }

    function team1Allow(address _address) public returns(uint){
        require(msg.sender == teamMember1, "You need to be Member 1 of the team");
        teamAllow[_address][teamMember1] = 1;
        return teamAllow[_address][teamMember1];
    }
    function team2Allow(address _address) public returns(uint){
        require(msg.sender == teamMember2, "You need to be Member 2 of the team");
        teamAllow[_address][teamMember2] = 1;
        return teamAllow[_address][teamMember2];
    }
    function team3Allow(address _address) public returns(uint){
        require(msg.sender == teamMember3, "You need to be Member 3 of the team");
        teamAllow[_address][teamMember3] = 1;
        return teamAllow[_address][teamMember3];
    }

    function setLockedPool() _approvedByAnyTeam() public returns (bool){
        lockedpool = 1;
        emit PoolLocked();
        return true;
    }
    function setUnlockedPool() _approvedByAnyTeam() public returns (bool){
        lockedpool = 0;
        emit PoolUnlocked();
        return true;
    }

    function getName() public view returns(string memory){
        return name;
    }

    /*

        Get Functions for Staked Variables

    */

    //get full balanced for how many tokens are staked
    //todo
    function getStakedBalance(address _address) public view returns(uint){
        return balances[_address];
    }

    //get balance for every stake made
    //todo
    function getStakedBalanceByTimestamp(address _address, uint256 _time) public view returns(uint){
        return amountStaked[_address][_time];
    }
    
    //get balance for every stake made
    //todo
    function getSavedStakedBalanceByTimestamp(address _address, uint256 _time) public view returns(uint){
        return savedAmountStaked[_address][_time];
    }


    //get balance for every stake made
    //todo
    function getStakedTimestamp(address _address, uint256 _i) public view returns(uint ){
         return timeStake[_address][_i];
    }

    //get how many stakings is done by an address
    //todo
    function getStakedCount(address _address) public view returns(uint256){
        if(stakeCount[_address]>0){
            return stakeCount[_address];
        }else{
            return 0;
        }
        
    }

    //get total staking tokens count
    function getTotalStaking() public view returns (uint256){
        return totalStaking;
    }

    //get staking counter for addresses
    function getStakingAddressCount() public view returns(uint256){
        return StakingAddressCount;
    }
    
    //get staking address by id
    function getStakingAddress (uint _i) public view returns(address){
        return stakingAddress[_i];
    }

    //get staking address by id
    function getStakingPeriod() public view returns(uint256){
        return stakingperiod;
    }

    /*

        Get Functions for Reward Variables

    */

    //get reward by every stake
    function getRewardByTimestamp(address _address, uint256 _time) public view returns(uint){
        return rewards[_address][_time];
    }


     //get reward state added by every stake
    function getRewardAddByTimestamp(address _address, uint256 _time) public view returns(uint){
        return rewardAdd[_address][_time];
    }

     //get rewardWon added by every stake
    function getRewardWonByAddress(address _address) public view returns(uint){
        return rewardWon[_address];
    }
    
    //get total rewards added by now
    function getTotalRewards() public view returns(uint256){
        return totalRewards;
    }

    //get total rewards won
    function getTotalRewardsWon() public view returns(uint256){
        return totalRewardsWon;
    }

    //get total amount of rewards won by a single address
    function getRewardWon(address _address) public view returns(uint256){
        return rewardWon[_address];
    }

    /*
        Private Functions
    */

    function _totalamount(uint _timestamp) private view returns(uint){
        return amountStaked[msg.sender][_timestamp]+ rewards[msg.sender][_timestamp];
    }

    function _totalamountWithoutReward(uint _timestamp) private view returns(uint){
        return amountStaked[msg.sender][_timestamp];
    }

    /*

        Modifiers

    */
    modifier _realAddress(address addr) {
        require(addr != address(0), "Zero address");
        _;
    }

    modifier _positive(uint256 amount) {
        require(amount != 0, "Negative amount");
        _;
    }

    modifier _after(uint eventTime) {
        require(block.timestamp >= eventTime, "Bad timing for the request");
        _;
    }

    modifier _before(uint eventTime) {
        require(block.timestamp < eventTime, "Bad timing for the request");
        _;
    }
    modifier _setter(address _address) {
        require(_address==SetterAddress,"You don't have access to this funds");
        _;
    }
    modifier _notlocked() {
        require(lockedpool!=1,"Pool is locked!");
        _;
    }
    modifier _approvedByTeam(address _address) {
        require(teamAllow[_address][teamMember1]==1,"Team Member 1 needs to allow this");
        require(teamAllow[_address][teamMember2]==1,"Team Member 2 needs to allow this");
        require(teamAllow[_address][teamMember3]==1,"Team Member 3 needs to allow this");
        _;
    }
    modifier _approvedByAnyTeam() {
        if((msg.sender==teamMember1)||(msg.sender==teamMember2)||(msg.sender==teamMember3)||(msg.sender==SetterAddress)){

        }else{
            require(1==0,"Team member required to do this function");
        }
        _;
    }

}