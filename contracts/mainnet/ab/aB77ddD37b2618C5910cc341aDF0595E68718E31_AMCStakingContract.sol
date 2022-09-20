// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract AMCStakingContract {

    event StakeAmountUpdated(uint256 amount);
    event Staking(address userAddress, uint256 amount);
    event Withdraw(address userAddress, uint256 withdrawAmount, uint256 rewardAmount);

    address public owner;
    IERC20 public stakingToken;
    IERC20 public  rewardToken;

    uint256 public minStakeAmount = 100000 * 10 ** 18 ;
    uint256 public rewardPercentage = 6;
    uint256 public feeDenominator = 1000000;

    struct UserDetail {
        uint256 amount;
        uint256 initialTime;
        uint256 rewardAmount;
        uint256 withdrawAmount;
        bool status;
    }

    mapping(address => UserDetail) private users;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: Caller is not owner");
        _;
    }

    constructor (IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        owner = msg.sender;
    }

    function stake(
        uint256 amount
    ) external returns(bool) {
        require(amount >= minStakeAmount, "amount should be greater than or equal to minimum stake amount");
        require(!(users[msg.sender].status), "user already exist");
        uint256 rAmount = users[msg.sender].rewardAmount;
        uint256 wAmount = users[msg.sender].withdrawAmount;
        users[msg.sender] = UserDetail(
            amount,
            block.timestamp,
            rAmount,
            wAmount,
            true
        );
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staking(msg.sender, amount);
        return true;
    }

    function getRewards(
        address account
    ) public view returns(uint256) {
        uint256 timeDiff = block.timestamp - users[account].initialTime;
        uint256 rewardAmount = (users[account].amount * rewardPercentage * timeDiff / 365 days) / feeDenominator;
        return rewardAmount;
    }

    function withdraw(
    ) external returns(bool) {
        require(users[msg.sender].status, "user not exist");
        uint256 rewardAmount = getRewards(msg.sender);
        stakingToken.transfer(msg.sender, users[msg.sender].amount);
        rewardToken.transfer(msg.sender, rewardAmount);
        uint256 rAmount = rewardAmount + users[msg.sender].rewardAmount;
        uint256 wAmount = users[msg.sender].withdrawAmount;
        users[msg.sender] = UserDetail(
            0,
            block.timestamp,
            rAmount,
            users[msg.sender].withdrawAmount += wAmount,
            false
        );
        emit Withdraw(msg.sender, users[msg.sender].amount, rewardAmount);
        return true;
    }

    function getUserDetails(address account) external view returns(UserDetail memory, uint256 rewardAmount) {
        uint256 reward = getRewards(account);
        return (users[account], reward);
    }

    function setMinStakeAmount(uint256 amount) external onlyOwner returns(bool) {
        require(amount != 0, "amount should be greater then zero");
        minStakeAmount = amount;
        emit StakeAmountUpdated(amount);
        return true;
    }

    function setFeeAndDenominator(uint256 fee, uint256 _denominator) external onlyOwner {
        rewardPercentage = fee;
        feeDenominator = _denominator;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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