/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Staking is a contract who is ment to be inherited by other
 * contracts to have staking capabilities
 */

contract Staking {

  /**
   * @dev storing each stake info. where user is the owner of the stake
   * amount is the stake value, since is a timestamp when staking begins,
   * and claimable is the  accumulated staking rewards*/
  struct Stake{
    address user;
    uint256 amount;
    uint256 since;
    uint256 claimable;
  }

  /**
   * @dev Stakers with active Stakes
   */
  struct Stakeholder{
    address user;
    Stake[] address_stakes;
  }

  /**
   * @dev Gives a Snapshot of StakingSummary of a specific account
   */
  struct StakingSummary{
    uint256 totalAmount;
    Stake[] stakes;
  }

  /**
   * @dev rewardPerHour is 0.1% for each staked token
   */
  uint256 internal rewardPerHour = 1000;
  /**
   * @dev an array of all stakes executed in the contract by all stakeholers
   */
  Stakeholder[] internal stakeholders;

  /**
   * @dev mapping the staker address(key/index) to the Stake in the stakes array
  */
  mapping(address => uint256) internal stakes;

  event Staked(address indexed user, uint256 amount, uint index, uint256 timestamp);

  constructor() {
    stakeholders.push();
  }

  function _addStakeholder(address staker) internal returns (uint256) {
    // Push an empty item to the array to make space for stakholder
    stakeholders.push();
    // Calculate the index of the last item in the array
    uint userIndex = stakeholders.length - 1;
    // Assign address to the new stakeholder
    stakeholders[userIndex].user = staker;
    // add the index to the stakeholders
    stakes[staker] = userIndex;
    return userIndex;
  }
  /**
   * @dev _Stake is used to make a stake for an sender. It will remove the amount 
   * staked from the stakers account and place those tokens inside a stake container StakeID 
   */
  function _stake(uint256 _amount) internal{
    // Simple check so that user does not stake 0
    require(_amount > 0, "Cannot stake nothing");
    // Mappings in solidity creates all values, but empty, so we can just check the address
    uint256 index = stakes[msg.sender];
    // block.timestamp = timestamp of the current block in seconds since the epoch
    uint256 timestamp = block.timestamp;
    // See if the staker already has a staked index or if its the first time
    if(index == 0){
      // This stakeholder stakes for the first time
      // We need to add him to the stakeHolders and also map it into the Index of the stakes
      // The index returned will be the index of the stakeholder in the stakeholders array
      index = _addStakeholder(msg.sender);
    }
    // Use the index to push a new Stake
    // push a newly created Stake with the current block timestamp.
    stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp,0));
    // Emit an event that the stake has occured
    emit Staked(msg.sender, _amount, index,timestamp);
  }

  /**
   * @dev calculateStakeReward is used to calculate how much a user should be rewarded for 
   * their stakes and the duration the stake has been active
   */
  function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256){
    // First calculate how long the stake has been active
    // Use current seconds since epoch - the seconds since epoch the stake was made
    // The output will be duration in SECONDS ,
    // We will reward the user 0.1% per Hour So thats 0.1% per 3600 seconds
    // the alghoritm is  seconds = block.timestamp - stake seconds (block.timestap - _stake.since)
    // hours = Seconds / 3600 (seconds /3600) 3600 is an variable in Solidity names hours
    // we then multiply each token by the hours staked , then divide by the rewardPerHour rate 
    return (((block.timestamp - _current_stake.since) / 1 hours) * _current_stake.amount) / rewardPerHour;
  }

  /**
   * @notice
   * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
   * Notice index of the stake is the users stake counter, starting at 0 for the first stake
   * Will return the amount to MINT onto the acount
   * Will also calculateStakeReward and reset timer
   */
  function _withdrawStake(uint256 amount, uint256 index) internal returns(uint256){
    // Grab user_index which is the index to use to grab the Stake[]
    uint256 user_index = stakes[msg.sender];
    Stake memory current_stake = stakeholders[user_index].address_stakes[index];
    require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

    // Calculate available Reward first before we start modifying data
    uint256 reward = calculateStakeReward(current_stake);
    // Remove by subtracting the money unstaked 
    current_stake.amount = current_stake.amount - amount;
    // If stake is empty, 0, then remove it from the array of stakes
    if(current_stake.amount == 0){
      delete stakeholders[user_index].address_stakes[index];
    }else {
      // If not empty then replace the value of it
      stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
      // Reset timer of stake
      stakeholders[user_index].address_stakes[index].since = block.timestamp;
    }
    return amount+reward;
  }

  /**
   * @dev hasStake is used to check if a account has stakes and the total amount 
   * along with all the seperate stakes
   */
  function hasStake(address _staker) public view returns(StakingSummary memory){
    uint256 totalStakeAmount;
    StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
    for (uint256 s=0; s< summary.stakes.length; s+= 1){
      uint256 availableRewards = calculateStakeReward(summary.stakes[s]);
      summary.stakes[s].claimable = availableRewards;
      totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
    }
    summary.totalAmount = totalStakeAmount;
    return summary;
  }

}