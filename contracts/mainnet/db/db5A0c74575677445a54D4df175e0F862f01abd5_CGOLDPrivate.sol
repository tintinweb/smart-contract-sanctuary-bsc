// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {ISellToken} from './ISellToken.sol';
import {SafeMath} from './SafeMath.sol';
import './ReentrancyGuard.sol';
/**
 * @title Time Locked, Validator, Executor Contract
 * @dev Contract
 * - Validate Proposal creations/ cancellation
 * - Validate Vote Quorum and Vote success on proposal
 * - Queue, Execute, Cancel, successful proposals' transactions.
 **/


contract CGOLDPrivate is ReentrancyGuard {
  using SafeMath for uint256;
  // Todo : Update when deploy to production

  address public IDOAdmin;
  address public IDO_TOKEN;
  address public OLD_SELL_CONTRACT;
  uint256 public constant DECIMAL_18 = 10**18;
  uint256 public constant RATE_DIVIDER = 1000000000;
  uint256 public constant STEP_1_DAY = 86400;

  uint256[] public PLANS_PERCENTS = [6,	0,	0,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	5,	4];
  uint256[] public PLANS_DAYS     = [0,	30,	60,	90,	120,	150,	180,	210,	240,	270,	300,	330,	360,	390,	420,	450,	480,	510,	540,	570,	600,	630];

  uint256 public tokenRate;
  uint256 public f1_rate;

  mapping(address => address) public referrers;
  mapping(address => uint256) public buyerAmount;
  mapping(address => uint256) public claimedAmount;
  mapping(address => uint256) public refAmount;
  uint256 public unlockPercent = 0;
  uint256 public totalBuyIDO=0;
  uint256 public totalRewardIDO=0;
  uint256 public timeStart=0;
  uint256 public totalUser=0;

  uint256 public minimumBuyAmount = DECIMAL_18/10; //0.1 BNB
  uint256 public maximumBuyAmount = 20 * DECIMAL_18; //20 BNB


  bool public _paused = false;
  bool public _paused_a = false;
  
  event NewReferral(address indexed user, address indexed ref, uint8 indexed level);
  event SellIDO(address indexed user, uint256 indexed sell_amount, uint256 indexed buy_amount);
  event RefReward(address indexed user, uint256 indexed reward_amount, uint8 indexed level);
  event claimAt(address indexed user, uint256 indexed claimAmount);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event UpdateRefUser(address indexed account, address indexed newRefaccount);

  modifier onlyIDOAdmin() {
    require(msg.sender == IDOAdmin, 'INVALID IDO ADMIN');
    _;
  }

    

  constructor() public {
    IDOAdmin  = tx.origin;
    IDO_TOKEN = 0x7572E6b8DEBFe25b9a179027C8457B053980FA28;
    timeStart = 1656349200;//Claim at Tue Jun 28 2022 00:00:00 GMT+0700 (Indochina Time)
    tokenRate = (4 * RATE_DIVIDER / 100000)/290; 
    f1_rate   = 10;
  }

   fallback() external {
    }

    receive() payable external {
        
    }

    function pause() public onlyIDOAdmin {
      _paused=true;
    }

    function unpause() public onlyIDOAdmin {
      _paused=false;
    }

    
    modifier ifPaused(){
      require(_paused,"");
      _;
    }

    modifier ifNotPaused(){
      require(!_paused,"");
      _;
    }  
  
  /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyIDOAdmin {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal onlyIDOAdmin {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(IDOAdmin, newOwner);
        IDOAdmin = newOwner;
    }
  /**
   * @dev 
   */
  function updateRefUser(address account, address newRefAccount) public onlyIDOAdmin {
        referrers[account] = newRefAccount;
        emit UpdateRefUser(account, newRefAccount);
  }

  /**
   * @dev Withdraw IDO Token to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawToken(address recipient, address token) public onlyIDOAdmin {
        IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
  }


  function receivedAmount(address recipient) external view returns (uint256){
    if (buyerAmount[recipient] == 0&&refAmount[recipient] == 0){
      return 0;
    }  
    return _receivedAmount(recipient);
  }

  function userInfo (address account) public view returns(
        uint256 amount,
        uint256 amountClaimed,
        uint256 amountBonus,
        uint256 claimAble,
        address reff
        ) {
        return (buyerAmount[account],claimedAmount[account],refAmount[account],_receivedAmount(account),referrers[account]);
  }

  function planInfo (address account, uint256 plan) public view returns(
        uint256 amount,
        uint256 refamount,
        uint256 time,
        uint256 percent,
        bool claimAble
        ) {
        if(plan < PLANS_DAYS.length){
          uint256 amountPlan = buyerAmount[account] * PLANS_PERCENTS[plan] / 100 ;
          uint256 refamountPlan = refAmount[account] * PLANS_PERCENTS[plan] / 100 ;
          uint256 timePlan = timeStart + PLANS_DAYS[plan] * STEP_1_DAY ;
          bool isClaim = false;
          if( timePlan < block.timestamp )
          {
              isClaim = true;
          }
          return (amountPlan,refamountPlan,timePlan,PLANS_PERCENTS[plan],isClaim);
        }
        else{
            return (0,0,0,0,false);
        }    
  }

  function _receivedAmount(address recipient) internal view returns (uint256){
    uint256 totalAmount=0;
    for (uint256 i = 0; i < PLANS_DAYS.length; i++) {
        if( timeStart + PLANS_DAYS[i] * STEP_1_DAY < block.timestamp ){
            totalAmount += buyerAmount[recipient] * PLANS_PERCENTS[i] / 100;
            totalAmount += refAmount[recipient] * PLANS_PERCENTS[i] / 100;
        }
    }
    return totalAmount - claimedAmount[recipient];
  }

  /**
   * @dev Update rate for refferal
   */
  function updateRateRef(uint256 _f1_rate) public onlyIDOAdmin {
    f1_rate = _f1_rate;
  }


  /**
   * @dev Update is enable
   */
  function updateTime(uint256 _timeStart) public onlyIDOAdmin {
    timeStart = _timeStart;
  }

  /**
   * @dev Update rate
   */
  function updateRate(uint256 rate) public onlyIDOAdmin {
    tokenRate = rate;
  }

  /**
   * @dev Update minimumBuyAmount
   */
  function updateMinBuy(uint256 _minimumBuyAmount) public onlyIDOAdmin {
    minimumBuyAmount = _minimumBuyAmount;
  }

  /**
   * @dev Update maximumBuyAmount
   */
  function updateMaxBuy(uint256 _maximumBuyAmount) public onlyIDOAdmin {
    maximumBuyAmount = _maximumBuyAmount;
  }

  /**
   * @dev Withdraw IDO BNB to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
  function withdrawBNB(address payable recipient) public onlyIDOAdmin {
    _safeTransferBNB(recipient, address(this).balance);
  }

  /**
   * @dev 
   * @param recipient recipient of the transfer
   */
  function updateAddLock(address recipient, uint256 _lockAmount) public onlyIDOAdmin {
    buyerAmount[recipient] += _lockAmount;
  }

  function updateRefUser(address recipient, uint256 _lockAmount) public onlyIDOAdmin {
    buyerAmount[recipient] += _lockAmount;
  }

  /**
   * @dev 
   * @param recipient recipient of the transfer
   */
  function updateSubLock(address recipient, uint256 _lockAmount) public onlyIDOAdmin {
    require(buyerAmount[recipient] >= _lockAmount , "Sorry: input data");
    buyerAmount[recipient] -= _lockAmount;
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


  /**
   * @dev claim aridrop
   */
   
   function ClaimCGOLD() public returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        require(buyerAmount[msg.sender] >0 , "Sorry: no token to claim ");
        uint256 balanceToken = IERC20(IDO_TOKEN).balanceOf(address(this));
        uint256 amountClaim= _receivedAmount(msg.sender);
        require(balanceToken >= amountClaim, "Sorry: no tokens to release");    
        IERC20(IDO_TOKEN).transfer(msg.sender,amountClaim);
        claimedAmount[msg.sender] += amountClaim;
        emit claimAt(msg.sender,amountClaim);
        return amountClaim;
   }


  /**
   * @dev execute buy Token
   **/
  function buyCGOLD(address _referrer) public payable ifNotPaused returns (uint256) {
    // solhint-disable-next-line not-rely-on-time
    uint256 buy_amount = msg.value;
    require(buy_amount >= minimumBuyAmount, "Minium buy CGOLD");
    require(buy_amount <= maximumBuyAmount, "Maxium buy CGOLD");
    require(tokenRate >0 , "Check the rate ");
    uint256 sold_amount = buy_amount * RATE_DIVIDER / tokenRate;
    require(IERC20(IDO_TOKEN).balanceOf(address(this)) >= sold_amount, "Check the token sell balance");

    address recipient = msg.sender;
    if (referrers[msg.sender] == address(0)
        && _referrer != address(0)
        && msg.sender != _referrer
        && msg.sender != referrers[_referrer]) {
        referrers[msg.sender] = _referrer;
        emit NewReferral(_referrer, msg.sender, 1);
        if (referrers[_referrer] != address(0)) {
            emit NewReferral(referrers[_referrer], msg.sender, 2);
        }
    }
    if(buyerAmount[recipient] == 0){
      totalUser += 1;
    }
    buyerAmount[recipient] += sold_amount;
    totalBuyIDO += sold_amount;
    emit SellIDO(msg.sender, sold_amount, buy_amount);
    // send ref reward
    if (referrers[msg.sender] != address(0) && f1_rate > 0 ){
        uint256 f1_reward = buy_amount * f1_rate / 100;
        refAmount[referrers[msg.sender]] += f1_reward;
        totalRewardIDO += f1_reward;
        emit RefReward(referrers[msg.sender] , f1_reward, 1);
    }
    return sold_amount;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        
        _notEntered = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface ISellToken {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function receivedAmount(address recipient) external view returns (uint256);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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