//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IMetaAx.sol";
import "./pair.sol";

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
    publishN:1, 
    publishD:50000, 
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
  AgentPolicy public _agent = AgentPolicy({
    bnbRewardPercent: 20,
    mtaxRewardPercent: 10
  });
  // timestamp of start/end of pre-staking epoch
  uint256 private startTime;
  uint256 public endTime;
  // agent list
  mapping(address => bool) _agents;
  // router & pair for liquidity
  IUniswapV2Router02 public immutable uniswapV2Router;
  IPancakePair public immutable pair;
  
  constructor (address payable tokenAddr) public {
    metaAx = IMetaAX(tokenAddr);
    uniswapV2Router = metaAx.uniswapV2Router();
    pair = IPancakePair(metaAx.uniswapV2Pair());
    // time duration of pre staking epoch
    startTime = block.timestamp;
    endTime = startTime.add(ico.remaining);
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
  * @param bnbRewardPercent BNB reward percentage for agent
  * @param mtaxRewardPercent MTAX reward percentage for agent
  */
  function setAgentPolicy(
    uint8 bnbRewardPercent, 
    uint8 mtaxRewardPercent) public onlyOwner
  {
    _agent.bnbRewardPercent = bnbRewardPercent;
    _agent.mtaxRewardPercent = mtaxRewardPercent;
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
  function requestPreStake(uint256 amount, uint lockPeriod, address recommender) external payable returns(uint256) {
    uint256 depositBnb;
    // Check pre-stake validation
    require(validPreStake(amount, lockPeriod), "Cannot pre-stake with this required parameters.");
    // Check recommender
    // if (recommender != address(0))
    //   require(_agents[recommender], "Not regestered recommender!");
    // caculate BNB for pre-staking
    (uint256 amountOfBNB, uint256 additionalBnb) = _calcEthForPreStaking(amount, lockPeriod);
    depositBnb = amountOfBNB.add(additionalBnb);
    // check payment
    require(msg.value >= depositBnb, "Out of request BNB!");
    // add liquidity
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
    // return remaining funds back to the investor
    if (msg.value > depositBnb)
      payable(msg.sender).call{value: msg.value.sub(depositBnb), gas:30000}("");
    // send addtional bnb to owner
    uint256 agentBonus = 0;
    // send addtional bnb to recommender
    if (recommender != address(0))
    {
      agentBonus = additionalBnb.mul(_agent.bnbRewardPercent).div(100);
      payable(recommender).call{value: agentBonus, gas:30000}("");
      metaAx.transfer(recommender, stakedToken.mul(_agent.mtaxRewardPercent).div(100));
    }
    (bool sent, ) = payable(owner()).call{value: additionalBnb.sub(agentBonus), gas:30000}("");
    require(sent, "Failed to send BNB to owner!");
    // accumlate additional bnb
    ico.spentBonus = ico.spentBonus.add(additionalBnb);
    return liquidity;
  }

  /**
  * @dev Set/release requested address as the agent
  */
  function setAgent(address addr, bool yn) external onlyOwner {
    _agents[addr] = yn;
  }

  /**
  * @dev Check if this account is agent
  */
  function isAgent(address addr) external view returns(bool) {
    return _agents[addr];
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
  * @dev add liquidity with certain amount paire of tokens
  * @param tokenAmount MetaAx token amount
  * @param ethAmount BNB amount
  */
  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private returns(uint256 stakedToken, uint256 stakedBNB, uint256 liquidity) {
    // approve token transfer to cover all possible scenarios
    metaAx.approve(address(uniswapV2Router), tokenAmount);
    // add the liquidity
    (stakedToken,stakedBNB,liquidity) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
        address(metaAx),
        tokenAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
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