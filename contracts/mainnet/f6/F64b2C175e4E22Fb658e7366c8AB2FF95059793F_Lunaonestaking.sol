// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "@openzeppelin/contracts/interfaces/IERC20.sol";


contract Lunaonestaking {

    event OwnershipTransferred(address owner, address newOwner);
    event FeeUpdated(uint256 previousFee, uint256 updatedFee);
    event StakeLimitUpdated(Stake);
    event Staking(address userAddress, uint256 level, uint256 amount);
    event Withdraw(address userAddress, uint256 withdrawAmount, uint256 rewardAmount);

    address public owner;
    IERC20 public token;
    uint256 public penaltyFeePermile;

    struct UserDetail {
        uint256 level;
        uint256 amount;
        uint256 initialTime;
        uint256 endTime;
        uint256 rewardAmount;
        uint256 withdrawAmount;
        bool status;
    }

    struct Stake {
        uint256 rewardPercent;
        uint256 stakeLimit;
    }

    mapping(address =>mapping(uint256 => UserDetail)) internal users;
    mapping(uint256 => Stake) internal stakingDetails;

    modifier onlyOwner() {
        require(owner == msg.sender,"Ownable: Caller is not owner");
        _;
    }

    constructor (IERC20 _token) {
        token = _token;
        stakingDetails[1] = Stake(10, 90 days);
        stakingDetails[2] = Stake(14, 180 days);
        stakingDetails[3] = Stake(18, 365 days);
        owner = msg.sender;  
    }


    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ownable: invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function updatePenaltyFee(uint256 fee) external onlyOwner {
        emit FeeUpdated(penaltyFeePermile, fee);
        penaltyFeePermile = fee;
    }

    function recoverBNB(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    function recoverToken(address tokenAddr,uint256 amount) external onlyOwner {
        IERC20(tokenAddr).transfer(owner, amount);
    }

    function stake(uint256 amount, uint256 level) external returns(bool) {
        require(level > 0 && level <= 3, "Invalid level");
        require(!(users[msg.sender][level].status),"user already exist");
        require( amount > 0, "invalid amount");
        users[msg.sender][level].amount = amount;
        users[msg.sender][level].level = level;
        users[msg.sender][level].endTime = block.timestamp + stakingDetails[level].stakeLimit;        
        users[msg.sender][level].initialTime = block.timestamp;
        users[msg.sender][level].status = true;
        token.transferFrom(msg.sender, address(this), amount);
        emit Staking(msg.sender, level, amount);
        return true;
    }


    function getRewards(address account, uint256 level) internal view returns(uint256) {
        if(users[account][level].endTime <= block.timestamp) {
            uint256 stakeAmount = users[account][level].amount;
            uint256 rewardRate = stakingDetails[level].rewardPercent;
            uint256 interval = block.timestamp - users[account][level].initialTime;
            uint256 rewardAmount = stakeAmount * interval * rewardRate / 365 days / 100;
            return rewardAmount;
        }
        else {
            return (0);
        }
    }

    function withdraw(uint256 level) external returns(bool) {
        require(level > 0 && level <= 3, "Invalid level");
        require(users[msg.sender][level].status, "user not exist");
        require(users[msg.sender][level].endTime <= block.timestamp, "staking end time is not reached ");
        uint256 rewardAmount = getRewards(msg.sender, level);
        uint256 amount = rewardAmount + users[msg.sender][level].amount;
        token.transfer(msg.sender, amount);
        uint256 rAmount = rewardAmount + users[msg.sender][level].rewardAmount;
        uint256 wAmount = amount + users[msg.sender][level].withdrawAmount;
        users[msg.sender][level] = UserDetail(0, 0, 0, 0, rAmount, wAmount, false);
        emit Withdraw(msg.sender, amount, rewardAmount);
        return true;
    }

    function emergencyWithdraw(uint256 level) external returns(uint256) {
        require(level > 0 && level <= 3, "Invalid level");
        require(users[msg.sender][level].status, "user not exist");
        uint256 stakedAmount = users[msg.sender][level].amount;
        uint256 penalty = stakedAmount * penaltyFeePermile / 100;
        token.transfer(msg.sender, stakedAmount - penalty);
        token.transfer(owner, penalty);
        uint256 rewardAmount = users[msg.sender][level].rewardAmount;
        uint256 withdrawAmount = users[msg.sender][level].withdrawAmount;
        users[msg.sender][level] = UserDetail(0, 0, 0, 0, rewardAmount, withdrawAmount, false);
        emit Withdraw(msg.sender, stakedAmount, 0);
        return stakedAmount;
    }

    function getUserDetails(address account, uint256 level) external view returns(UserDetail memory, uint256 rewardAmount) {
        uint256 reward = getRewards(account, level);
        return (users[account][level], reward);
    }

    function setStakeDetails(uint256 level, Stake memory _stakeDetails) external onlyOwner returns(bool) {
        require(level > 0 && level <= 3, "Invalid level");
        stakingDetails[level] = _stakeDetails;
        emit StakeLimitUpdated(stakingDetails[level]);
        return true;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";