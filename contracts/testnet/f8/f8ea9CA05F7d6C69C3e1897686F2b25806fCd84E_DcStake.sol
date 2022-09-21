/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b >= 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract DcStake {
    address payable public treasury;
    mapping(address => uint256) public accountMiners;
    mapping(address => uint256) public claimedBNB;
    mapping(address => uint256) public lastClaim;
    mapping(address => address) public referralsA;

    struct StakeHolder {
        uint256 stakingAmount;
        uint256 stakingDate;
        uint256 stakingDuration;
        uint256 claimDate;
        uint256 expireDate;
        uint256 rewardAmount;
        bool isStaker;
    }

    mapping(address => mapping(uint => StakeHolder)) public stakeHolders;

    uint256[] internal stakePeriod = [7 days, 14 days, 28 days, 30 minutes];
    uint256[] internal rate = [200, 320, 440, 4];
    uint256 private decimals = 10**18;
    uint256 private totalRewardAmount;

    constructor(address payable _treasury) {
        treasury = _treasury;
    }

    function staking(uint _amount, uint256 _duration, address ref) public {
        if (ref == msg.sender) {
            ref = address(0);
        }
        if (referralsA[msg.sender] == address(0)) {
            referralsA[msg.sender] = ref;
        }
        require(_amount >= 10000, "Insufficient Stake Amount");
        require(_duration < 4, "Duration not match");

        StakeHolder storage s = stakeHolders[msg.sender][_duration];
        s.stakingAmount = _amount * decimals;
        s.stakingDate = block.timestamp;
        s.claimDate = block.timestamp;
        s.stakingDuration = stakePeriod[_duration];
        s.expireDate = s.stakingDate + s.stakingDuration;
        s.isStaker = true;
    }

    function calculateRewardA_(address account, uint256 _duration) public {
        StakeHolder storage s = stakeHolders[account][_duration];
        require(s.isStaker == true, "You are not staker.");
        bool status = (block.timestamp - s.claimDate) > 7 seconds
            ? true
            : false;
        require(status == true, "Invalid Claim Date");

        uint currentTime = block.timestamp >= s.expireDate ? s.expireDate : block.timestamp;
        uint256 _pastTime = currentTime - s.claimDate;
        require(_pastTime >= stakePeriod[_duration], "Invalid Claim Date");

        uint reward = s.stakingAmount*rate[_duration]/1000;

        s.claimDate = block.timestamp;
        s.isStaker = false;

        uint256 fee = devFee(reward);
        (bool sent1, ) = treasury.call{value: fee}("");
        require(sent1, "ETH transfer Fail");

        (bool sent, ) = account.call{value: reward - 2 * fee}("");
        require(sent, "ETH transfer Fail");
    }

    function calculateRewardD_(address account, uint256 _duration) public {
        StakeHolder storage s = stakeHolders[account][_duration];
        require(s.isStaker == true, "You are not staker.");
        bool status = (block.timestamp - s.claimDate) > 7 seconds
            ? true
            : false;
        require(status == true, "Invalid Claim Date");

        uint currentTime = block.timestamp >= s.expireDate
            ? s.expireDate
            : block.timestamp;
        uint256 _pastTime = currentTime - s.claimDate;
        require(_pastTime >= stakePeriod[_duration], "Invalid Claim Date");
        uint reward = rate[_duration]*s.stakingAmount/(1000);

        s.claimDate = block.timestamp;
        s.isStaker = false;

        uint256 fee = devFee(reward);
        (bool sent1, ) = treasury.call{value: fee}("");
        require(sent1, "ETH transfer Fail");

        (bool sent, ) = account.call{value: reward - 2 * fee}("");
        require(sent, "ETH transfer Fail");
    }

    function calculateRewardAll_(address account) public {
        totalRewardAmount = 0;
        calculateRewardA_(account, 0);
        calculateRewardA_(account, 1);
        calculateRewardA_(account, 2);
        calculateRewardD_(account, 3);
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return (amount * 5) / 100;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}