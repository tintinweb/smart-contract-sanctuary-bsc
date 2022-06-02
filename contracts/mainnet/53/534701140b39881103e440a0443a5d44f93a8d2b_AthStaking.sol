/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
// By interacting with this code you are accepting the following TOS: https://bit.ly/3zdHPPv
pragma solidity ^0.8.0;

// Link to bep20 token smart contract 
interface IBEP20Token {

    // Transfer tokens on behalf
    function transferFrom(
      address _from,
      address _to,
      uint256 _value
    ) external returns (bool success);
    
    // Transfer tokens
    function transfer(
      address _to,
      uint256 _value
    ) external returns (bool success);

}

/**
 * @title AthenaBank staking contract Version 1.0
 *
 * @author AthenaBank
 */
contract AthStaking {
    // Address of AthStaking owner
    address public owner;
    
    // Address of ATH token contract
    address public immutable athToken;

    // Address of treasury
    address public immutable treasury;

    // Number of staking levels
    uint8 public immutable levels;

    // Deposit fee defined in terms of percentage
    uint8 public depositFee;

    // Locking period defined in terms of seconds
    uint32 public lockingPeriodInSeconds;

    // Records ATH token staking data
    struct AthData {
        uint256 balance;
        uint256 lockedAmount;
        uint32 lastUpdated;
        uint8 level; 
    }

    /**
     * @dev Returns staking data for given address
     */
    mapping(address => AthData) public athBalance;

    /**
     * @dev Returns minimum ATH token required for given level
     */ 
    mapping(uint8 => uint256) public minAthRequired;

    /**
	 * @dev Fired in transferOwnership() when ownership is transferred
	 *
	 * @param previousOwner an address of previous owner
	 * @param newOwner an address of new owner
	 */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
	 * @dev Fired in setDepositFee() when fee is revised by an owner
	 *
	 * @param previousFee previous fee in terms of percentage
	 * @param newFee new fee in terms of percentage
	 */
    event FeeChanged(uint8 previousFee, uint8 newFee);

    /**
	 * @dev Fired in setLockingPeriod() when locking period is revised by an owner
	 *
	 * @param previousPeriod previous period defined in seconds
	 * @param newPeriod new period defined in seconds
	 */
    event LockingPeriodChanged(uint32 previousPeriod, uint32 newPeriod);

    /**
	 * @dev Fired in deposit() when ATH token staked by an address
	 *
	 * @param staker address of staker
	 * @param amount amount of ATH token staked
     * @param fee deposit fee paid to treasury
     * @param level assigned ATH level based on staking amount
	 */
    event Stake(address indexed staker, uint256 amount, uint256 fee, uint8 level);

    /**
	 * @dev Fired in withdraw() when ATH token unstaked by an address
	 *
	 * @param staker address of staker
	 * @param amount amount of ATH token unstaked
	 */
    event Unstake(address indexed staker, uint256 amount);

    /**
	 * @dev Creates/deploys AthenaBank staking contract Version 1.0
	 *
	 * @param ath_ address of ATH token smart contract
	 * @param treasury_ address of treasury account
	 * @param levels_ number of staking levels
     * @param depositFee_ deposit fee in terms of percentage
     * @param lockingPeriodInSeconds_ locking period in terms of seconds
     * @param levelBounds_ minimum ATH required for each level
	 */
    constructor(
        address ath_,
        address treasury_,
        uint8 levels_,
        uint8 depositFee_,
        uint32 lockingPeriodInSeconds_,
        uint256[] memory levelBounds_
    ) {
        require(levelBounds_.length == levels_, "Invalid Inputs");

        //---Setup smart contract internal state---//
        owner = msg.sender;
        athToken = ath_;
        treasury = treasury_;
        levels = levels_;
        depositFee = depositFee_;
        lockingPeriodInSeconds = lockingPeriodInSeconds_;

        for(uint8 i = 1; i <= levels_; i++) {
            minAthRequired[i] = levelBounds_[i - 1];
        }
    }

    // To check if accessed by owner
    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    /**
	 * @dev Returns ATH level of given address
	 *
	 * @notice returns zero in case of locking period is over
	 * @param user_ address of staker
	 */
    function athLevel(address user_) external view returns(uint256 level) {
        if(block.timestamp - athBalance[user_].lastUpdated > lockingPeriodInSeconds) {
            level = 0;
        } else {
            level = athBalance[user_].level;
        }
    }

    /**
	 * @dev Transfer ownership to given address
	 *
	 * @notice restricted function, should be called by owner only
	 * @param newOwner_ address of new owner
	 */
    function transferOwnership(address newOwner_) external onlyOwner {
        // Update owner address
        owner = newOwner_;
    
        // Emit an event
        emit OwnershipTransferred(msg.sender, newOwner_);
    }

    /**
	 * @dev Sets new deposit fee
	 *
	 * @notice restricted function, should be called by owner only
	 * @param fee_ deposit fee defined in percentage of deposited amount
	 */
    function setDepostFee(uint8 fee_) external onlyOwner {
        require(fee_ >= 0 && fee_ <=100, "Invalid Input");

        // Emit an event
        emit FeeChanged(depositFee, fee_);

        // Update deposit fee
        depositFee = fee_;
    }

    /**
	 * @dev Sets locking period
	 *
	 * @notice restricted function, should be called by owner only
	 * @param lockingPeriod_ locking period defined in seconds
	 */
    function setLockingPeriod(uint32 lockingPeriod_) external onlyOwner {
        // Emit an event
        emit LockingPeriodChanged(lockingPeriodInSeconds, lockingPeriod_);
        
        // Update locking period
        lockingPeriodInSeconds = lockingPeriod_;
    }

    /**
	 * @dev Deposits ATH tokens to the contract
	 *
	 * @param amount_ number of ATH tokens to be deposited
	 * @param level_ index of level for which amount is deposited
	 */
    function deposit(uint256 amount_, uint8 level_) external {
        require(level_ > 0 && level_ <= levels, "Invalid Level");

        require(
            amount_ + athBalance[msg.sender].balance == minAthRequired[level_] && amount_ > 0,
            "Invalid amount"
        );

        // Check if locking period is running
        if(athBalance[msg.sender].lastUpdated != 0) {
            require(
                block.timestamp - athBalance[msg.sender].lastUpdated <= lockingPeriodInSeconds,
                "Locking period is over"
            );
        }

        // Calculate deposit fee
        uint256 _fee = (amount_ * depositFee) / 100;

        // Transfer locking amount to AthStaking contract
        IBEP20Token(athToken).transferFrom(msg.sender, address(this), amount_ - _fee);

        // Check if fee is non zero
        if(_fee > 0) {
            // Transfer fee to treasury account
            IBEP20Token(athToken).transferFrom(msg.sender, treasury, _fee);
        }

        // Increment ATH balance by given amount
        athBalance[msg.sender].balance += amount_;

        // Increment ATH locking amount
        athBalance[msg.sender].lockedAmount += (amount_ - _fee);

        // Record deposit time
        athBalance[msg.sender].lastUpdated = uint32(block.timestamp);

        // Record index of ATH level
        athBalance[msg.sender].level = level_;

        // Emit an event
        emit Stake(msg.sender, amount_, _fee, level_);
    }

    /**
	 * @dev Withdraws ATH tokens from the contract
	 *
	 * @notice withdrwal can be done after locking period gets over
	 */
    function withDraw() external {
        require(
            block.timestamp - athBalance[msg.sender].lastUpdated > lockingPeriodInSeconds,
            "Locking period is not over yet"
        );

        // Transfer locked ATH amount to staker
        IBEP20Token(athToken).transfer(msg.sender, athBalance[msg.sender].lockedAmount);

        // Emit an event
        emit Unstake(msg.sender, athBalance[msg.sender].lockedAmount);

        // Remove staking data for given address
        delete athBalance[msg.sender];
    }
}