//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IMetaAx.sol";
import "./IPair.sol";

contract MetaAxPresale is Ownable {
  using SafeMath for uint256;
  using Address for address;
  bool private constant TESTING = true;

  // structure represents general information of presale state
  struct PresaleStat {
    uint    remaining;      // lifetime of this pre-staking epoch
    uint    investorCount;  // total count of investors
    uint256 amountLimit;    // limits that can be be staked in the pre-staking priod
    uint256 curPrice;       // current actual price of token
    uint256 stakedMtax;     // total amount of staked MTAX token
    uint256 stakedBNB;      // total amount of staked BNB
    uint256 stakedLP;       // total amount of staked MTAX<->BNB LP token
    uint256 spentBonus;     // total amount of MTAX token used for bonus
  }
  // structure represents price policy
  struct PricePolicy {
    uint    publishN;         // Numberator of estimated token on the time of publishment
    uint    publishD;         // Denominator of estimated token on the time of publishment
    uint8   discount;         // discount rate of presale price
    uint8   discountL;        // price degree Low
    uint8   discountH;        // price degree High    
  }
  // structure represents lockout policy
  struct LockPolicy {
    uint    min;  // minimum period of lockout
    uint    max;  // maximum period of lockout
    uint    lockL;// Low lock level
    uint    lockM;// Meduim lock level
    uint    lockH;// High lock level
  }
  // structure represents investor's stake information
  struct Investor {
    uint256 amount;         // acmount of pre-staked MetaAx
    uint256 lp;             // acmount of staked LP token
    uint256 bnb;            // acmount of pre-staked BNB
    uint256 reservedAmount; // reserved amount of MTAX token
    uint256 reservedBNB;    // reserved amount of BNB coin
    uint256 reservedLP;     // reserved amount of LP token
    uint256 regTime;        // registration timestamp
    uint256 lockout;        // lock period
  }
  // agent policy
  struct AgentPolicy {
    uint8 bnbRewardPercent;
    uint8 mtaxRewardPercent;
  }
  // The token to be pre staked
  IMetaAX public metaAx; 
  // The token used to purchase MTAX
  IERC20 public tokenForPayment;
  // investor registration info
  mapping(address => Investor) private investors;
  mapping(uint => address) private investorList;
  // general state of presale context
  PresaleStat public ico = PresaleStat({
    remaining:      864000,
    investorCount:  0,
    amountLimit:    10000000000000000,
    curPrice:       0,
    stakedMtax:     0,
    stakedBNB:      0,
    stakedLP:       0,
    spentBonus:     0
  });
  // price policy
  PricePolicy public _price = PricePolicy({
    publishN:1,     // ETH
    publishD:50000, // MTAX
    discount:50, 
    discountL:30, 
    discountH:10
  });
  // lockout policy
  LockPolicy public _lock = LockPolicy({
    min:    0,
    max:    0,
    lockL:  60,
    lockM:  120,
    lockH:  300
  });
  // agent policy
  AgentPolicy[] public _agent;
  // timestamp of start/end of pre-staking epoch
  uint256 private startTime;
  uint256 public endTime;
  // referral map
  mapping(address => address) public referrals;
  // router & pair for liquidity
  IUniswapV2Router02 public uniswapV2Router;
  IPancakePair public pair;
  
  constructor (address payable mtaxToken, address payToken) public {
    metaAx = IMetaAX(mtaxToken);
    uniswapV2Router = metaAx.uniswapV2Router();
    address factoryAddr = uniswapV2Router.factory();
    IUniswapV2Factory factory = IUniswapV2Factory(factoryAddr);
    pair =  IPancakePair(factory.getPair(mtaxToken, payToken));
    tokenForPayment = IERC20(payToken);
    startTime = block.timestamp;
    endTime = startTime.add(ico.remaining);
    _agent.push(AgentPolicy({bnbRewardPercent:20, mtaxRewardPercent:10}));
    _agent.push(AgentPolicy({bnbRewardPercent:15, mtaxRewardPercent:8}));
    _agent.push(AgentPolicy({bnbRewardPercent:10, mtaxRewardPercent:5}));
    _agent.push(AgentPolicy({bnbRewardPercent:6, mtaxRewardPercent:2}));
    _agent.push(AgentPolicy({bnbRewardPercent:3, mtaxRewardPercent:1}));
  }

  /**
  * @dev Set the presale policy.
  * @param lifetime pre-staking duratation, on ellapsed this time, token will be published
  * @param cap max amount of tokens that can be presaled.
  */
  function setPresalePolicy(
    uint                lifetime,
    uint256             cap
  ) public onlyOwner {
    // maximum amount of pre-staking token
    ico.amountLimit = cap;
    ico.remaining = lifetime;
    
    // time duration of pre staking epoch
    startTime = block.timestamp;
    endTime = startTime.add(lifetime);
  }

  /**
  * @dev Set the agnet reward policy.
  * @param agentPolicies agent rewards info
  */
  function setAgentPolicy(AgentPolicy[] memory agentPolicies) public onlyOwner
  {
    delete _agent;
    for (uint i = 0; i < agentPolicies.length; i ++) {
        _agent.push(agentPolicies[i]);
    }
  }

  /**
  * @dev Set the price & discount policy.
  * @param publishN Numberator of publish price
  * @param publishD Denominator of publish price
  * @param discount normal discount percentage
  * @param discountL discount level low
  * @param discountH discount level high
  */
  function setDiscountPolicy(
    uint  publishN,
    uint  publishD,
    uint8 discount,
    uint8 discountL,
    uint8 discountH
    ) public onlyOwner
  {
    _price.publishN = publishN;
    _price.publishD = publishD;
    _price.discount = 100 - discount;
    _price.discountL = 100 - discountL;
    _price.discountH = 100 - discountH;
  }

  /**
  * @dev Set the lock policy.
  * @param lockL lock time level low
  * @param lockM lock time level medium
  * @param lockH lock time level high
  */
  function setLockPolicy(
    uint  lockL,
    uint  lockM,
    uint  lockH
    ) public onlyOwner
  {
    _lock.lockL = lockL;
    _lock.lockM = lockM;
    _lock.lockH = lockH;
  }

  /**
  * @dev Get the state of investor
  */
  function queryState() external view returns(
    PresaleStat memory prsStat, // general state of presale
    PricePolicy memory price,   // price policy info 
    LockPolicy memory lockout,  // lockout policy info 
    Investor memory investor    // Individual investor information
  ) {

    // presale state
    prsStat = ico;
    if (block.timestamp > endTime)
      prsStat.remaining = 0;
    else 
      prsStat.remaining = endTime.sub(block.timestamp);
    (uint256 liqBnb, uint256 additionalCost) = _calcEthForPreStaking(10**9, 0);
    prsStat.curPrice = liqBnb.add(additionalCost);
    (prsStat.stakedMtax, prsStat.stakedBNB) = getLiquidityPairAmount();
    prsStat.stakedLP = pair.totalSupply();
    // price policy info
    price = _price;
    // lockout policy info
    lockout = _lock;
    // investor info
    investor = investors[msg.sender];
    investor.lp = pair.balanceOf(msg.sender);
    uint256 elapsedTime = block.timestamp.sub(investor.regTime);
    if (elapsedTime >= investor.lockout)
      investor.lockout = 0;
    else
      investor.lockout = investor.lockout.sub(elapsedTime);
  }

  /**
  * @dev Check pre-stake validation
  * @return return true if it is possible to pre-stake.
  */
  function validPreStake(uint256 amount, uint lockPeriod) private view returns(bool) {
    // check if estamating amount of pre-staking token exceeds the limit
    uint256 weiAmount = ico.stakedMtax.add(amount);
    if (amount == 0 || weiAmount > ico.amountLimit)
      revert("Required amount is too much!");
    
    // check lockPeriod
    if (lockPeriod == 0 || lockPeriod < _lock.min 
      /*|| lockPeriod > getPresaleRemainTime()*/)
      revert("Lock period is too short!");
    
    // If previouse request is not expired yet
    // The expiration time of the current request must be greater than the expiration time of the previous request.
    Investor memory i = investors[msg.sender];
    if (i.regTime != 0 &&
      block.timestamp.add(lockPeriod) < i.regTime.add(i.lockout))
      revert("Lock period must greater than your current remain lock time.");
    return true;
  }

  /**
  * @dev Calculate BNB for pre-staking
  * @param amount amount of mtax token to pre-stake
  * @param lockPeriod lock period
  * @return calculated BNB amount.
  */
  function _calcEthForPreStaking(uint256 amount, uint lockPeriod) private view returns(uint256, uint256) {    
    (uint256 curStakedToken, uint256 curStakedBNB) = getLiquidityPairAmount();
    uint256 liqBnb;
    uint256 additionalCost;

    // check if liquidity pool exists
    if (curStakedToken == 0 || curStakedBNB == 0)
      revert("Liquidity pool is not configured yet!");
    liqBnb = amount
      .mul(curStakedBNB)
      .div(curStakedToken);
    if (lockPeriod == 0)
      return (liqBnb, 0);
    if (lockPeriod >= _lock.lockM && lockPeriod < _lock.lockH) {
      // medium lock degree
      additionalCost = liqBnb.mul(_price.discountL).div(100);
    } else if (lockPeriod >= _lock.lockH) {
      // high lock degree
      additionalCost = liqBnb.mul(_price.discountH).div(100);
    } else {
      additionalCost = liqBnb.mul(_price.discount).div(100);
    }

    return (liqBnb, additionalCost);
  }

  /**
  * @dev Shows the possibility of pre-staking a certain amount of tokens and the BNB required for it..
  * @param amount Amount of token to pre-stake.
  * @param lockPeriod Period of time of releasing locked LP tokens.
  * return Amount of BNB and extra token proper to adding liquidity.
  */
  function lookupPreStake(uint256 amount, uint lockPeriod) external view returns(uint256 totalBnb, uint256 liqBnb, uint256 additionalBnb) {
    // Check pre-stake validation
    if (!validPreStake(amount, lockPeriod)) {
      totalBnb = 0;
      liqBnb = 0;
      additionalBnb = 0;
    } else {
      // caculate BNB for pre-staking
      (uint256 _liqBnb, uint256 _additionalBnb) = _calcEthForPreStaking(amount, lockPeriod);
      totalBnb = _liqBnb.add(_additionalBnb);
      liqBnb = _liqBnb;
      additionalBnb = _additionalBnb;
    }
  }

  /**
  * @dev Accept request of pre-stake and add liquidity.
  * @param amount Amount of token to pre-stake.
  * @param lockPeriod Period of time of releasing locked LP tokens.
  * @return Amount of liquidity for pre-staking
  */
  function requestPreStake(uint256 amount, uint lockPeriod, address recommender) external returns(uint256) {
    uint256 depositBnb;
    // Check pre-stake validation
    require(validPreStake(amount, lockPeriod), "Cannot pre-stake with this required parameters.");
    // caculate BNB for pre-staking
    (uint256 amountOfBNB, uint256 additionalBnb) = _calcEthForPreStaking(amount, lockPeriod);
    depositBnb = amountOfBNB.add(additionalBnb);
    // check payment & receive eth from sender
    require(tokenForPayment.balanceOf(msg.sender) >= depositBnb, "Out of request ETH!");
    tokenForPayment.transferFrom(msg.sender, address(this), depositBnb);
    // add liquidity
    metaAx.transferFrom(owner(), address(this), amount); // get mtax tokens from owner to adding liquidity
    require(metaAx.balanceOf(address(this)) >= amount, "Insufficient mtax to add liquidity!");
    (uint256 stakedToken, uint256 stakedBNB, uint256 liquidity) = addLiquidity(amount, amountOfBNB);
    // register investor
    Investor storage investor = investors[msg.sender];
    if (investor.regTime == 0) // check if already requested befor
    {
      investorList[ico.investorCount] = msg.sender;
      ico.investorCount = ico.investorCount.add(1);
    }
    investor.amount = investor.amount.add(stakedToken);
    investor.bnb = investor.bnb.add(stakedBNB);
    investor.lp = investor.lp.add(liquidity);
    investor.reservedAmount = investor.reservedAmount.add(stakedToken);
    investor.reservedLP = investor.reservedLP.add(liquidity);
    investor.reservedBNB = investor.reservedBNB.add(stakedBNB);
    investor.regTime = block.timestamp;
    investor.lockout = lockPeriod;
    // send rewards to referrers
    require(recommender != msg.sender, "Referrer must not be the same as the sender's address!");
    uint256 agentBonus = 0;
    // send addtional bnb to recommender
    uint i = 0;
    while (recommender != address(0) && i < _agent.length) {
        uint256 bonus = additionalBnb.mul(_agent[i].bnbRewardPercent).div(100);
        tokenForPayment.transfer(recommender, bonus);
        agentBonus = agentBonus.add(bonus);
        metaAx.transferFrom(owner(), recommender, stakedToken.mul(_agent[i].mtaxRewardPercent).div(100));
        i ++;
        recommender = referrals[recommender];
    }
    // send addtional bnb to owner
    require(agentBonus < additionalBnb, "Agent bonus amount should not be over than additional cost.");
    tokenForPayment.transfer(owner(), additionalBnb.sub(agentBonus));
    // add referrer to the referral map
    referrals[msg.sender] = recommender;
    // accumlate additional bnb
    ico.spentBonus = ico.spentBonus.add(additionalBnb);
    return liquidity;
  }

  /**
  * @dev check if an investor ready to withdraw lp token
  */
  function _isReadyToWithdraw(address who) private view returns(bool) {
    return (investors[who].reservedAmount != 0 && investors[who].reservedLP != 0 &&
      investors[who].regTime != 0 && 
      block.timestamp.sub(investors[who].regTime) >= investors[who].lockout);
  }

  /**
  * @dev send lp tokens to investor's wallet
  */
  function _sendLpToInvestor(address to) private returns(uint256) {
    Investor storage i = investors[to];
    // transfer LP token from this contract to the investor's wallet
    if (i.reservedLP > 0)
      pair.transfer(to, i.reservedLP);

    // Release the investor from register list
    uint256 lp = i.reservedLP;
    i.reservedAmount = 0;
    i.reservedLP = 0;
    i.reservedBNB = 0;
    i.regTime = 0;
    i.lockout = 0;
    return lp;
  }

  /**
  * @dev Investor will actually be the onwer of LP tokens.
  */
  function withdrawLP() external returns(uint256) {
    // check if this account is registerd
    require(_isReadyToWithdraw(msg.sender), "Cannot become to LP owner!");
    uint256 lp = _sendLpToInvestor(msg.sender);
    return lp;
  }

  /**
  * @dev add liquidity with certain amount pair of tokens
  * @param tokenAmount MetaAx token amount
  * @param ethAmount BNB amount
  */
  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private returns(uint256 stakedToken, uint256 stakedBNB, uint256 liquidity) {
    // approve token transfer to cover all possible scenarios
    metaAx.approve(address(uniswapV2Router), tokenAmount);
    tokenForPayment.approve(address(uniswapV2Router), ethAmount);
    // add the liquidity
    (stakedToken,stakedBNB,liquidity) = uniswapV2Router.addLiquidity(
        address(metaAx),
        address(tokenForPayment),
        tokenAmount,
        ethAmount,
        0,
        0,
        address(this),
        block.timestamp
    );
  }

  /**
  * @dev Get the remaining time until the end of pre-staking period
  */
  function getPresaleRemainTime() public view returns(uint256) {
    if (endTime < block.timestamp)
      return 0;
    return endTime.sub(block.timestamp);
  }

  /**
  * @dev Send all LP tokents to every proper owner.
  */
  function withdrawAll() external onlyOwner {
    for(uint i = 0; i < ico.investorCount; i ++) {
      address investor = investorList[i];
      if (_isReadyToWithdraw(investor))
        _sendLpToInvestor(investor);
    }
    uint256 balanceInIco = metaAx.balanceOf(address(this));
    if (balanceInIco != 0)
        metaAx.transfer(owner(), balanceInIco);
  }

  function getLiquidityPairAmount() private view returns(uint256 amountMtax, uint256 amountBnb)  {
    (uint256 token0, uint256 token1, ) = pair.getReserves();
    if (pair.token0() == address(metaAx)) {
      amountMtax = token0;
      amountBnb = token1;
    }
    else {
      amountMtax = token1;
      amountBnb = token0;
    }
  }
}

pragma solidity ^0.6.12;
interface IPancakePair {
  event Approval(address indexed owner, address indexed spender, uint value);
  event Transfer(address indexed from, address indexed to, uint value);

  function name() external pure returns (string memory);
  function symbol() external pure returns (string memory);
  function decimals() external pure returns (uint8);
  function totalSupply() external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function PERMIT_TYPEHASH() external pure returns (bytes32);
  function nonces(address owner) external view returns (uint);

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

  event Mint(address indexed sender, uint amount0, uint amount1);
  event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
  event Swap(
      address indexed sender,
      uint amount0In,
      uint amount1In,
      uint amount0Out,
      uint amount1Out,
      address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function price0CumulativeLast() external view returns (uint);
  function price1CumulativeLast() external view returns (uint);
  function kLast() external view returns (uint);

  function mint(address to) external returns (uint liquidity);
  function burn(address to) external returns (uint amount0, uint amount1);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
  function skim(address to) external;
  function sync() external;

  function initialize(address, address) external;
}

/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

pragma solidity ^0.6.12;
interface IERC20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IMetaAX is IERC20{
    // function approve(address spender, uint256 amount) external override returns (bool);
    // function transfer(address recipient, uint256 amount) external override returns (bool);
    function uniswapV2Router() external view returns(IUniswapV2Router02);
    function uniswapV2Pair() external view returns(address);
    function excludeFromFee(address account) external;
    function isExcludedFromFee(address account) external view returns(bool);
}