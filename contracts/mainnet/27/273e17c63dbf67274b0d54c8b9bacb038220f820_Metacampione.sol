pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

// contract Stakeable { }
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * Available since v3.4.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * Available since v3.4.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * Available since v3.4.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * Available since v3.4.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * Available since v3.4.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

     function percent(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c / 100;
  }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Metacampione is ERC20, ERC20Burnable, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public yieldBearingTokenBalance;
    
    uint256 public yieldBearingTokenIndex = 10000000000;
    uint256 lastYieldUpdate;
    /// rewardsPerSecond are number of tokens * e18 d available per secon for staking rewards
    uint256 rewardsPerSecond;
    uint256 public TotalYieldBearingTokens;
    bool private openedStaking;
    
    constructor() ERC20("METACAMPIONE", "MCA") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
        rewardsPerSecond = 48 * 10 ** decimals();
        openedStaking = false;
    }
    
    modifier stakingOpened() {
        require(openedStaking == true, "Staking is not opened yet!");
        _;
    }
    function initializeStaking() public onlyOwner {
        openedStaking = true;
    }

    function stake(uint256 _amount) public stakingOpened {
     
      require(_amount <= balanceOf(msg.sender), "Cannot stake more than you own");
      require(_amount >= 10 ** decimals() && _amount >= yieldBearingTokenIndex, "Minimum stake amount not");
      
        _stake(_amount);
                
        
    }

//22:33:30 2,880 per min

    function unStake(uint256 _amount)  public {
      require(_amount <= stakedAmount(msg.sender), "Cannot unstake more than you own");
      require(_amount >= 10 ** decimals() && _amount >= yieldBearingTokenIndex, "Minimum unstake amount not reached");
      _withdrawStake(_amount);
    
    }
      function unStakeAll()  public {
        uint256  _amount = stakedAmount(msg.sender);
       require(_amount >= 10 ** decimals() && _amount >= yieldBearingTokenIndex, "Minimum unstake amount not reached");
      _withdrawStake(_amount);
    
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function _withdrawStake(uint256 _amount) internal { 
        updateYieldTokenIndex();
        yieldBearingTokenBalance[msg.sender] = yieldBearingTokenBalance[msg.sender].sub(_amount.div(yieldBearingTokenIndex));
        TotalYieldBearingTokens = TotalYieldBearingTokens.sub(_amount.div(yieldBearingTokenIndex));
        _mint(msg.sender, _amount);
}
function _stake(uint256 _amount) internal { 
    
     if ( TotalYieldBearingTokens == 0 ) { lastYieldUpdate = block.timestamp; } 
     else {updateYieldTokenIndex() ;}
     _burn(msg.sender, _amount);
     yieldBearingTokenBalance[msg.sender] = yieldBearingTokenBalance[msg.sender].add(_amount.div(yieldBearingTokenIndex));
     TotalYieldBearingTokens = TotalYieldBearingTokens.add(_amount.div(yieldBearingTokenIndex));


}

function stakedAmount(address _account) internal returns (uint256) {
    updateYieldTokenIndex();
    return yieldBearingTokenBalance[_account].mul(yieldBearingTokenIndex);
}

function lastKnownStakedAmount(address _account) public view returns (uint256) {

    return yieldBearingTokenBalance[_account].mul(yieldBearingTokenIndex);
}

function updateYieldTokenIndex() internal {
    require(TotalYieldBearingTokens > 0, "No stakes created yet");
    
    

    yieldBearingTokenIndex = yieldBearingTokenIndex.add((rewardsPerSecond.mul(block.timestamp.sub(lastYieldUpdate))).div(TotalYieldBearingTokens));
    lastYieldUpdate = block.timestamp; 

}
}