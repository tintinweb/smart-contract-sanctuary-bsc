//SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "../interfaces/IStakedSoccerStarNftV2.sol";
import "../interfaces/IStakedDividendTracker.sol";
import "../lib/SafeMath.sol";

contract StakedRewardUiDataProvider {
    using SafeMath for uint;

    IStakedSoccerStarNftV2 staked;
    IStakedDividendTracker dividend;

    constructor(address _staked, address _dividend){
        require((address(0) != _staked) && (address(0) != _dividend), "INVALID_ADDRESS");
        staked = IStakedSoccerStarNftV2(_staked);
        dividend = IStakedDividendTracker(_dividend);
    }

    // get unclamined rewards
    function getUnClaimedRewards(address user) 
    public view returns(uint amount){
        return staked.getUnClaimedRewards(user).add(dividend.dividendOf(user));
    }

    // get unclamined rewards
    function getUnClaimedRewardOfToken(uint tokenId) 
    public view returns(uint amount){
        return staked.getUnClaimedRewardsByToken(tokenId).add(dividend.dividendOfToken(tokenId));
    }

    // Claim rewards
    function claimRewards() public{
        staked.claimRewardsOnbehalfOf(msg.sender);
        dividend.withdrawDividendOnbehalfOf(msg.sender);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IStakedSoccerStarNftV2 {
    struct TokenStakedInfo {
        address owner;
        uint tokenId;
        uint unclaimed;
        uint cooldown;
    }

    // Trigred to stake a nft card
    event Stake(address sender, uint tokenId);

    // Triggered when redeem the staken
    event Redeem(address sender, uint  tokenId);

    // Triggered after unfrozen peroid
    event Withdraw(address sender, uint  tokenId);

    // Triggered when reward is taken
    event ClaimReward(address sender, uint tokenId, uint amount);

    function getTokenOwner(uint tokenId) external view returns(address);

    // protocol to udpate the star level
    function updateStarlevel(uint tokenId, uint starLevel) external;

    // user staken the spcified token
    function stake(uint tokenId) external;

    // user staken multiple tokens
    function stake(uint[] memory tokenIds) external;

    // user redeem the spcified token
    function redeem(uint tokenId) external;

    // user withdraw the spcified token
    function withdraw(uint tokenId) external;

    // Get unclaimed rewards by the specified tokens
    function getUnClaimedRewardsByToken(uint tokenId) 
    external view returns(uint);

    // Get unclaimed rewards by a set of the specified tokens
    function getUnClaimedRewardsByTokens(uint[] memory tokenIds) 
    external view returns(uint[] memory amount);
    
    // Get unclaimed rewards 
    function getUnClaimedRewards(address user) 
    external view returns(uint amount);

    // Claim rewards
    function claimRewards() external;

    function claimRewardsOnbehalfOf(address to) external;

    // Get user stake info by page
    function getUserStakedInfoByPage(address user,uint pageSt, uint pageSz) 
    external view returns(TokenStakedInfo[] memory userStaked);

    // Check if the specified token is staked
    function isStaked(uint tokenId) external view returns(bool);

    // Check if the specified token is unfreezing
    function isUnfreezing(uint tokenId) external view returns(bool);

    function transferOwnershipNFT(uint tokenId, address to) external;

    // Check if the specified token is withdrawable
    function isWithdrawAble(uint tokenId) external view returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IStakedDividendTracker {
    function dividendOfToken(uint tokenId) external view returns(uint256);
    function dividendOf(address user) external view returns(uint256);
    function withdrawDividendOnbehalfOf(address to) external;
    function withdrawDividend() external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


/**
 * @dev From https://github.com/OpenZeppelin/openzeppelin-contracts
 * Wrappers over Solidity's arithmetic operations with added overflow
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
    using SafeMath for uint;

    uint constant internal PRECISION = 1e18;

  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
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
    require(c / a == b, 'SafeMath: multiplication overflow');

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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
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
   * - The divisor cannot be zero.
   */
  function precisionDiv(uint256 a, uint256 b)internal pure returns (uint256) {
     a = a.mul(PRECISION);
     a = div(a, b);
     return div(a, PRECISION);
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
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
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
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }

  function exp(uint256 a, uint256 n) internal pure returns(uint256){
    require(n >= 0, "SafeMath: n less than 0");
    uint256 result = 1;
    for(uint256 i = 0; i < n; i++){
        result = result.mul(10);
    }
    return a.mul(result);
  }
}