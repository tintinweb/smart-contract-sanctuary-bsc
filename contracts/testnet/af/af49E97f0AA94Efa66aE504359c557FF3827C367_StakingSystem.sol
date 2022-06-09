//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Staking System (SS)
 * @author Erick Rivera
 * @notice Implements custom staking with ERC20 token and reward distribution.
 */
contract StakingSystem {

    /**
     * @notice Struct to store stake information
     */
    struct Stake {
        uint256 since;
        uint256 amount;
    }

    /**
     * @notice We require to know who are all the stakeholders.
     */
    address[] internal stakeholders;

    /**
     * @notice The stakes for each stakeholder.
     */
    mapping(address => Stake[]) internal stakes;

    /**
     * @notice The minimum amount of tokens to stake
     */
    uint256 public minAmountForStake =  0.0001 ether;  
    /**
     * @notice The token Interface 
     */
    IERC20 private TOKEN;

    /**
     * @notice The constructor for the Staking System.
     *
     */
    constructor(address tokenAddress) {
        TOKEN = IERC20(tokenAddress);
   }
   error notenougherror();

    // ---------- STAKES ----------

    /**
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint256 _stake) public {
        if(!(_stake >= minAmountForStake)){
            revert notenougherror();
        } 

        (bool isSh, ) = isStakeholder(msg.sender);
        if ( isSh == false){
            addStakeholder(msg.sender);
        } 

        TOKEN.transferFrom(msg.sender, address(this), _stake);
        stakes[msg.sender].push(Stake(block.timestamp, _stake));
    }

    /**
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function removeStake(uint256 _stake) public {
        // require( stakeOf(msg.sender) >= _stake, "Not enough stake to remove");
        if(!(stakeOf(msg.sender) >= _stake)){
            revert notenougherror();
        }
        // Calculate and distribute reward
        uint256 reward = calculateReward(msg.sender, _stake);
        int256 _StakesToRemove = int(_stake);
        for (uint256 i = stakes[msg.sender].length-1; i >= 0; i--) {
            int256 thisDifference = int(stakes[msg.sender][i].amount) - int(_StakesToRemove);
            if(thisDifference > 0 ){
                stakes[msg.sender][i].amount = uint(int(stakes[msg.sender][i].amount) - _StakesToRemove);
                _StakesToRemove = 0;
                break;
            } else if (thisDifference == 0){
                stakes[msg.sender][i].amount = uint(int(stakes[msg.sender][i].amount) - _StakesToRemove);
                _StakesToRemove = 0;
                stakes[msg.sender][i] = stakes[msg.sender][stakes[msg.sender].length - 1];
                stakes[msg.sender].pop();
                break;
            } else if (thisDifference < 0){
                int256 amount = int(stakes[msg.sender][i].amount);
                stakes[msg.sender][i].amount = 0;
                stakes[msg.sender][i] = stakes[msg.sender][stakes[msg.sender].length - 1];
                stakes[msg.sender].pop();
                _StakesToRemove = _StakesToRemove - amount;
            }
        }
        
        TOKEN.transfer(msg.sender, _stake + reward);
        if (stakeOf(msg.sender) == 0) removeStakeholder(msg.sender);
    }

    /**
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder) public view returns (uint256) {
        uint256 _totalStakesOf = 0;
        uint256 length = stakes[_stakeholder].length;
        for (uint256 i = 0; i < length; i++) {
            _totalStakesOf = _totalStakesOf + stakes[_stakeholder][i].amount;
        }
        return _totalStakesOf;
    }

    /**
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes() public view returns (uint256) {
        uint256 _totalStakes = 0;
        uint256 stakeholderLength = stakeholders.length;

        for (uint256 s = 0; s < stakeholderLength; s += 1) {
            uint256 stakesLength = stakes[stakeholders[s]].length;
            for (uint256 i = 0; i < stakesLength; i++) {
                _totalStakes = _totalStakes + stakes[stakeholders[s]][i].amount;
            }
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder,
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns (bool, uint256)
    {
        uint256 stakeholderLength = stakeholders.length;
        for (uint256 s = 0; s < stakeholderLength; s += 1) {
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
     * @notice A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder) internal {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    // ---------- REWARDS ----------

    /**
     * @notice A method to allow a stakeholder to check his rewards.
     * @param _stakeholder The stakeholder to check rewards for.
     */
    function rewardOf(address _stakeholder) public view returns (uint256) {
        (bool isSh, ) = isStakeholder(_stakeholder);
        if ( isSh == false){
            return 0;
        }
        return calculateReward(_stakeholder, stakeOf(_stakeholder));
    }

    /**
     * @notice A method to the aggregated rewards from all stakeholders.
     * @return uint256 The aggregated rewards from all stakeholders.
     */
    function totalRewards() public view returns (uint256) {
        uint256 _totalRewards = 0;
        uint256 stakeholderLength = stakeholders.length;
        for (uint256 s = 0; s < stakeholderLength; s += 1) {
            _totalRewards = _totalRewards + calculateReward(stakeholders[s], stakeOf(stakeholders[s]));
        }
        return _totalRewards;
    }

    /**
     * @notice A method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     * @param _stakeToCalculate The amount of stake to calculate rewards for.
     * @return uint256 The aggregated rewards from stakeholder's stakes.
     */
    function calculateReward(address _stakeholder, uint256 _stakeToCalculate)
        internal
        view
        returns (uint256)
    {
        int256 _stakesToCalculateRewardLeft = int(_stakeToCalculate);
        uint256 _reward = 0;
        
        for (uint256 i = stakes[_stakeholder].length - 1; i >= 0; i--) {
            int256 thisDifference = int(stakes[_stakeholder][i].amount) - _stakesToCalculateRewardLeft;
            if(thisDifference >= 0 ){
                _reward = calculateRewardPerStake(stakes[_stakeholder][i].since, uint(_stakesToCalculateRewardLeft));
                _stakesToCalculateRewardLeft = 0;
                break;
            } else if (thisDifference < 0){
                uint256 amount = stakes[_stakeholder][i].amount;
                _stakesToCalculateRewardLeft = _stakesToCalculateRewardLeft - int(amount);
                _reward = calculateRewardPerStake(stakes[_stakeholder][i].since, amount);
            }
        }
        return _reward;
    }

    /**
     * @notice A method that calculates the reward for each stake.
     * @param since The date when stake was submitted.
     * @param _stakeToCalculate The stake to calculate rewards for.
     * @return uint256 The reward calculated.
     */
    function calculateRewardPerStake(uint256 since, uint256 _stakeToCalculate)
        internal
        view
        returns (uint256)
    {
        uint256 _secondsSinceStake = uint256(int256(block.timestamp) - int256(since));
         
        uint256 currentPercentageRewardPerStakePerDay = ((50000000000000000000000000000000000000000 / totalStakes()) + 5) / 10;
        if( currentPercentageRewardPerStakePerDay >= 5479452054794520){
            return ((_stakeToCalculate * 5479452054794520 * _secondsSinceStake) / 86400000000000000000000);
            
        }
        return ((_stakeToCalculate * currentPercentageRewardPerStakePerDay * _secondsSinceStake) / 86400000000000000000000);
    }

    /**
     * @notice A method that calculates the current Annual Percentage Rate.
     * @return annualPercentageRate The Annual Percentage Rate calculated.
     */
    function getAPR() public view returns (uint annualPercentageRate) {
        if (totalStakes() == 0) {
            return 0;
        }
        annualPercentageRate = ((((50000000000000000000000000000000000000000/totalStakes()) + 5)/10)*365)/100;
        if( annualPercentageRate >= 20000000000000000){
            annualPercentageRate =  20000000000000000;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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