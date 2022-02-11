/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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
        require(b > 0, errorMessage);
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


interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function totalSupply() external view returns (uint256);
}


contract WalletDistributor {
  using SafeMath for uint256;

  IERC20 public vToken;
  uint256 public currentPeriodIndex = 0;
  uint256 public periodTime = 30 days;
  uint256 currentPeriodStart;

  mapping(uint256 => uint256) public periodSharesRemoved;
  mapping(address => mapping (uint256 => bool)) public periodClaimed;

  constructor(address _vToken) public {
    vToken = IERC20(_vToken);
    currentPeriodStart = now;
  }

  // claim rewards per a certain period
  function claim() external {
    // update period index if need
    checkAndUpdatePeriod();
    // check if user claimed in this period
    require(!isClaimed(msg.sender), "Claimed, need wait");
    // get user share
    uint256 userShare = vToken.balanceOf(msg.sender);
    // calculate how much claim
    uint256 toClaim = toClaim(userShare);
    require(toClaim > 0, "Nothing claim");
    // set this user as claimed for this period
    periodClaimed[msg.sender][currentPeriodIndex] = true;
    // remove user share from total shares
    periodSharesRemoved[currentPeriodIndex] = periodSharesRemoved[currentPeriodIndex].add(userShare);
    // pay
    payable(msg.sender).transfer(toClaim);
  }

  // helper for update period
  function checkAndUpdatePeriod() internal {
    if(isNeedUpdatePeriod()){
      currentPeriodIndex = currentPeriodIndex + 1;
      currentPeriodStart = now;
    }
  }

  // VIEW functions

  // calculate how much user earn
  function earned(address user) public view returns(uint256){
    uint256 userShare = vToken.balanceOf(msg.sender);
    return toClaim(userShare);
  }

  // helper for calculate user earn by user share
  function toClaim(uint256 userShare) internal view returns(uint256){
    uint256 totalRewards = address(this).balance;
    uint256 sharesRemoved = periodSharesRemoved[currentPeriodIndex];

    uint256 totalShares = vToken.totalSupply().sub(sharesRemoved);

    if(totalRewards == 0 || userShare == 0){
      return 0;
    }else{
      return totalRewards.mul(userShare.div(10**9)).div(totalShares.div(10**9));
    }
  }

  // check if user claimed for this period
  function isClaimed(address user) public view returns(bool){
    return periodClaimed[msg.sender][currentPeriodIndex];
  }

  // check if need update period
  function isNeedUpdatePeriod() public view returns(bool){
    return now >= currentPeriodStart + periodTime;
  }

  // receive ETH
  fallback() external payable {}
}