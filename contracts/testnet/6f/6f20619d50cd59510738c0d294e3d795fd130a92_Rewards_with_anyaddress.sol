/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: whitelist1.sol


pragma solidity >=0.8.15;


// Send out ERC20 Rewards
contract Rewards_with_anyaddress {
  
    address rewardToken = 0x407B1f03d85637be5e4C99cd7e24fbc5f8b3C1Aa; // Kovan WETH

    mapping(address => uint) public startTS;

    uint public deployedTS;
    uint public rewardsPerDay = 5e18; // wei, 18 decimals
    uint public totalParticipants;

    constructor() {
        deployedTS = block.timestamp;
    }

    function addMe() public {
        // logic to decide who deserves rewards
        if (startTS[msg.sender] == 0) totalParticipants += 1;
        startTS[msg.sender] = block.timestamp;
        
    }

    function claimRewards() public {
        require(startTS[msg.sender] != 0, "No record of user account");
        uint rewardAmount = (block.timestamp - startTS[msg.sender]) * rewardsPerDay / 1 days / totalParticipants;
        startTS[msg.sender] = block.timestamp;
        IERC20(rewardToken).transfer(msg.sender, rewardAmount);
    }

    function userEarnings(address _user) public view returns(uint256) {
        if (startTS[_user] == 0) return 0;
        uint rewardAmount = (block.timestamp - startTS[_user]) * rewardsPerDay / 1 days / totalParticipants;
        return rewardAmount;
    }
}