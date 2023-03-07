/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @title Time Locked, Validator, Executor Contract
 * @dev Contract
 * - Validate Proposal creations/ cancellation
 * - Validate Vote Quorum and Vote success on proposal
 * - Queue, Execute, Cancel, successful proposals' transactions.
 **/

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
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

library SafeMath {
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
}
contract FUND_Vote{
  using SafeMath for uint256;
  //using IERC20 for IERC20;
  
  // Todo : Update when deploy to production

  address public admin1;
  address public admin2;
  address public releaseToAddress;
  address public owner;

  uint256 public vote1=0;
  uint256 public vote2=0;
  

  event ClaimAt(address indexed token,address indexed userAddress, uint256 indexed claimAmount);
  event ReceiveAddressTransferred(address indexed previousOwner, address indexed newOwner);
  event AdminVote(address indexed adminAddress, uint256 indexed vote);

  modifier onlyAmin() {
    require(msg.sender == admin1 || msg.sender == admin2  , 'INVALID ADMIN');
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner  , 'INVALID OWNER');
    _;
  }

  //constructor(address _tokenLock, address _releaseToAddress, address _admin1, address _admin2, address _admin3) public {
  constructor() public {    
    owner = tx.origin;
    // Mainnet
    releaseToAddress = 0xd8128852FE9D8720b6989F2fC61219D1635Ef654;
    admin1 = 0x93eD4C6b6035eaA4d27a4E4aB501D9f5F54EcB5d;
    admin2 = 0xd8128852FE9D8720b6989F2fC61219D1635Ef654;
   
  }

    
    /**
     * @dev vote releaseToAddress of the contract to a new releaseToAddress .
     * Can only be called by the current admin .
     */
    function vote(uint256 v) public onlyAmin {
        if(msg.sender==admin1)
        {
            vote1 = v;
            emit AdminVote(msg.sender,vote1);
            
        }
        if(msg.sender==admin2)
        {
            vote2 = v;
            emit AdminVote(msg.sender,vote2);
        }
    
    }
/**
     * @dev vote releaseToAddress of the contract to a new releaseToAddress .
     * Can only be called by the current admin .
     */
    function unvote() public onlyAmin {
        if(msg.sender==admin1)
        {
            vote1 = 0;
            emit AdminVote(msg.sender,vote1);
            
        }
        if(msg.sender==admin2)
        {
            vote2 = 0;
            emit AdminVote(msg.sender,vote2);
            
        }
        
    }
  
    /**
     * @dev Transfers releaseToAddress of the contract to a new releaseToAddress .
     * Can only be called by the current admin .
     */
    function transferReleaseToAddress(address newReleaseToAddress) public onlyAmin {
        require(vote1 == 1 && vote2 == 1 , "Function need 2 vote from admin"); 
        _transferReleaseToAddress(newReleaseToAddress);
        vote1 = 0;
        vote2 = 0;
        
    }

    /**
     * @dev Transfers releaseToAddress of the contract to a new releaseToAddress .
     */
    function _transferReleaseToAddress(address newReleaseToAddress) internal onlyAmin {
        require(newReleaseToAddress != address(0), 'Ownable: new owner is the zero address');
        emit ReceiveAddressTransferred(releaseToAddress, newReleaseToAddress);
        releaseToAddress = newReleaseToAddress;
    }
  


   /**
   * @dev Withdraw IDO BNB to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawBNB(address recipient) public onlyOwner {
     _safeTransferBNB(recipient, address(this).balance);
  }

  
  
  /**
   * @dev transfer ETH to an address, revert if it fails.
   * @param to recipient of the transfer
   * @param value the amount to send
   */
  function _safeTransferBNB(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, 'BNB_TRANSFER_FAILED');
  }
  
   
   function ClaimBEP20(address token, uint256 value ) public onlyAmin returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        require(vote1 == value && vote2 == value , "Function need 2 vote from admin"); 
        IERC20(token).transfer(releaseToAddress, value * 10**18 );
        emit ClaimAt(token , releaseToAddress, value * 10**18);
        return value;
   }
  
}