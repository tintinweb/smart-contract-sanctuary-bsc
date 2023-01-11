/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
 */
contract StakingDBT {
    IBEP20 private IBEP20Interface;

    /**
     * @notice Constructor since this contract is not ment to be used without inheritance
     * push once to stakeholders for it to work proplerly
     */
    constructor(address _tokenAddress) {
        // This push is needed so we avoid index 0 causing bug of index-1
        IBEP20Interface = IBEP20(_tokenAddress);
        stakeholders.push();
    }

    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder {
        address user;
        uint256 tier_level;
        uint256 amount;
        uint256 since;
    }
    
    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */
    struct StakingSummary {
        uint256 total_amount;
        uint256 tier_level;
        uint256 since;
    }

    /**
     * @notice
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;
    /**
     * @notice
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;
    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */

    event Staked( address indexed user, uint256 amount, uint256 timestamp );

    event Withdrawed( address indexed user, uint256 amount, uint256 timestamp );

    /**
     * @notice
      rewardPerHour is 1000 because it is used to represent 0.001, since we only use integer numbers
      This will give users 0.1% reward for each staked token / H
     */
    // uint256 internal rewardPerHour = 1000;

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256) {
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].user = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex;
    }

    /**
     * @notice _getTierLevel calc tier system level
     */
    function _getTierLevel(uint256 totalAmount, uint256 tokenPrice) internal returns (uint256) {
        uint256 tierLevel;
        if (totalAmount > 750 * tokenPrice) {
            tierLevel = 3;
        } else if (totalAmount > 300 * tokenPrice) {
            tierLevel = 2;
        } else if (totalAmount > 150 * tokenPrice) {
            tierLevel = 1;
        } else {
            tierLevel = 0;
        }
        return tierLevel;
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID
     */
    function _stake(uint256 _amount, uint256 tokenPrice) public {
        // Simple check so that user does not stake 0
        require(_amount > 0, "Cannot stake nothing");

        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        if (index == 0) {
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].amount = stakeholders[index].amount + _amount;

        stakeholders[index].tier_level = _getTierLevel(stakeholders[index].amount, tokenPrice);

        stakeholders[index].since = timestamp;

        // Emit an event that the stake has occured
        if(IBEP20Interface.transferFrom(msg.sender, address(this), _amount)){
            emit Staked(msg.sender, _amount, timestamp);
        }else{
            revert("Unable to transfer funds");
        }
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 _amount, uint256 tokenPrice) public
    {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        require(
            stakeholders[user_index].amount >= _amount,
            "Staking: Cannot withdraw more than you have staked"
        );

        // Remove by subtracting the money unstaked
        stakeholders[user_index].amount = stakeholders[user_index].amount - _amount;
        stakeholders[user_index].tier_level = _getTierLevel(stakeholders[user_index].amount, tokenPrice);
        stakeholders[user_index].since = timestamp;

        if(IBEP20Interface.transfer(msg.sender, _amount)){
            emit Withdrawed(msg.sender, _amount, timestamp);
        }else{
            revert("Unable to transfer funds");
        }
    }

    /**
     * @notice
     * hasStake is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function hasStake(address _staker) public view returns (StakingSummary memory)
    {
        StakingSummary memory summary = StakingSummary(stakeholders[stakes[_staker]].amount, stakeholders[stakes[_staker]].tier_level, stakeholders[stakes[_staker]].since);
        return summary;
    }
}