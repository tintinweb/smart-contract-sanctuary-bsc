/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TheMergeClub {
  using SafeMath for uint256;

  uint256 public constant INTEREST_RATE_DIVISOR = 1000000000000;
  uint256 public constant DEV_COMMISSION = 10;//%
  // uint256 public constant SEC_RATE = 2893564; //DAILY 25%
  uint256 public constant SEC_RATE = 925940; //DAILY 8%
  uint256 public constant LOTTERY_FEE_RATE = 10;//%
  uint256 public constant LOTTERY_PRIZE_RATE = 20;//%
  uint256 public constant MIN_DEPOSIT = 50 ether;
  uint256 public constant TOP_5_PLAYER_BONUS = 100; //%
  uint256 public constant AFTER_5_TOP_10_PLAYER_BONUS = 50;//%
  
  uint256 public releaseTime;
  uint256 public totalPlayers;
  uint256 public totalPayout;
  uint256 public totalInvested;

  uint256 public devPool;
  IERC20 public busdToken;
  address public owner;

  struct Player {
    uint256 depositAmount;
    uint256 time;
    uint256 interestProfit;
    uint256 affRewards;
    uint256 payoutSum;
    address affFrom;
  }

  struct Jackpot {
    uint256 lastTime;
    address lastWinner;
  }

  Jackpot public jackpot;
  mapping(address => Player) public players;

  // 5 level of ref
  uint256[] public affRate = [5, 4, 3, 2, 1];
  uint256 public constant SUM_AFF_RATE = 15;
  mapping(address => uint256[5]) public affSums;

  uint256 public lotteryPool;
  address[] public lotteryTickets;

  address[] public earlyPlayers;

  event NewDeposit(address indexed addr, uint256 amount);
  event Withdraw(address indexed addr, uint256 amount);
  event JackpotReward(address indexed addr, uint256 amount);

  constructor(uint256 _releaseTime, address _busdTokenAddress) {
    owner = msg.sender;
    releaseTime = _releaseTime;
    busdToken = IERC20(_busdTokenAddress);
    jackpot = Jackpot(block.timestamp, address(0));
  }

  function register(address _addr, address _affAddr) private {
    Player storage player = players[_addr];

    player.affFrom = _affAddr;

    for (uint256 i = 0; i < affRate.length; i++) {
      affSums[_affAddr][i] = affSums[_affAddr][i].add(1);
      _affAddr = players[_affAddr].affFrom;
    }
  }

  function deposit(address _affAddr, uint256 amount) public {
    require(block.timestamp >= releaseTime, "not start yet!");
    collect(msg.sender);
    require(amount >= MIN_DEPOSIT);
    busdToken.transferFrom(msg.sender, address(this), amount);

    Player storage player = players[msg.sender];

    uint256 _depositAmount = amount;
    if (player.time == 0) {
      player.time = block.timestamp;
      totalPlayers++;
      if (_affAddr != address(0) && players[_affAddr].depositAmount > 0) {
        register(msg.sender, _affAddr);
      } else {
        register(msg.sender, owner);
      }

      if (totalPlayers <= 5){
        _depositAmount += _depositAmount.mul(TOP_5_PLAYER_BONUS).div(100);
        earlyPlayers.push(msg.sender);
      }
      if (totalPlayers > 5 && totalPlayers <= 15){
        _depositAmount += _depositAmount.mul(AFTER_5_TOP_10_PLAYER_BONUS).div(100);
        earlyPlayers.push(msg.sender);
      }
    }
    
    player.depositAmount = player.depositAmount.add(_depositAmount);

    distributeRef(amount, player.affFrom);
    sendJackpot();

    lotteryTickets.push(msg.sender);
    totalInvested = totalInvested.add(amount);
    uint256 devEarn = amount.mul(DEV_COMMISSION).div(100);
    devPool = devPool.add(devEarn);

    emit NewDeposit(msg.sender, amount);
  }

  function withdraw() public {
    collect(msg.sender);
    require(players[msg.sender].interestProfit > 0);

    transferPayout(msg.sender, players[msg.sender].interestProfit);
    sendJackpot();
  }

  function reinvest() public {
    collect(msg.sender);
    Player storage player = players[msg.sender];
    uint256 depositAmount = player.interestProfit;
    require(contractBalance() >= depositAmount);
    player.interestProfit = 0;
    player.depositAmount = player.depositAmount.add(depositAmount);
  }

  function collect(address _addr) private {
    Player storage player = players[_addr];

    uint256 secPassed = block.timestamp.sub(player.time);
    if (secPassed > 0 && player.time > 0) {
      uint256 collectProfit =
        (player.depositAmount.mul(secPassed.mul(SEC_RATE))).div(
          INTEREST_RATE_DIVISOR
        );
      player.interestProfit = player.interestProfit.add(collectProfit);
      player.time = player.time.add(secPassed);
    }
  }

  function transferPayout(address _receiver, uint256 _amount) private {
    if (_amount > 0 && _receiver != address(0)) {
      uint256 _contractBalance = contractBalance();
      if (_contractBalance > 0) {
        uint256 payout = _amount > _contractBalance ? _contractBalance : _amount;
        totalPayout = totalPayout.add(payout);

        Player storage player = players[_receiver];
        player.payoutSum = player.payoutSum.add(payout);
        player.interestProfit = player.interestProfit.sub(payout);

        emit Withdraw(msg.sender, payout);

        uint256 jackPotFee = payout.mul(LOTTERY_FEE_RATE).div(100);
        payout = payout.sub(jackPotFee);
        lotteryPool = lotteryPool.add(jackPotFee);

        busdToken.transfer(msg.sender, payout);
      }
    }
  }

  function sendJackpot() private {
    if (block.timestamp < jackpot.lastTime + 1 days){
      return;
    }

    if (lotteryPool <= 0) {
      return;
    }
    
    if (lotteryTickets.length < 1){
      return;
    }

    uint256 winner = generateRandomNumber() % lotteryTickets.length;
    address winnerAddress = lotteryTickets[winner];
    jackpot = Jackpot(block.timestamp, winnerAddress);
    lotteryTickets = new address[](0);
    
    uint256 jackpotReward = lotteryPool.mul(LOTTERY_PRIZE_RATE).div(100);
    emit JackpotReward(msg.sender, jackpotReward);

    busdToken.transfer(winnerAddress, jackpotReward);
  }

  function generateRandomNumber() private view returns (uint256) {
    return uint256(keccak256(abi.encode(block.timestamp)));
  }

  function distributeRef(uint256 _bnb, address _affFrom) private {
    uint256 _allaff = (_bnb.mul(SUM_AFF_RATE)).div(100);
    address affAddr = _affFrom;
    for (uint256 i = 0; i < affRate.length; i++) {
      uint256 _affRewards = (_bnb.mul(affRate[i])).div(100);
      _allaff = _allaff.sub(_affRewards);
      players[affAddr].affRewards = _affRewards.add(
        players[affAddr].affRewards
      );
      busdToken.transfer(affAddr, _affRewards);
      affAddr = players[affAddr].affFrom;
    }

    if (_allaff > 0) {
      busdToken.transfer(owner, _allaff);
    }
  }

  function getProfit(address _addr) public view returns (uint256) {
    address playerAddress = _addr;
    Player storage player = players[playerAddress];
    if (player.time == 0) {
      return 0;
    }

    uint256 secPassed = block.timestamp.sub(player.time);
    if (secPassed > 0) {
      uint256 collectProfit = (player.depositAmount.mul(secPassed.mul(SEC_RATE))).div(INTEREST_RATE_DIVISOR);
      return collectProfit.add(player.interestProfit);
    }

    return 0;
  }

  function getAffSums(address _addr)
    public
    view
    returns (uint256[] memory data, uint256 totalAff)
  {
    uint256[] memory _affSums = new uint256[](10);
    uint256 total;
    for (uint8 i = 0; i < 10; i++) {
      _affSums[i] = affSums[_addr][i];
      total = total.add(_affSums[i]);
    }
    return (_affSums, total);
  }

  function contractBalance() public view returns (uint256) {
    uint256 balance = busdToken.balanceOf(address(this));
    balance = balance.sub(devPool).sub(lotteryPool);

    return balance;
  }

  function getTicketCount(address _addr) public view returns (uint256) {
    uint256 ticketCount = 0 ;
    uint256 totalTicket = lotteryTickets.length;
    for (uint8 i = 0; i < totalTicket; i++) {
      if (lotteryTickets[i] == _addr){
        ticketCount++;
      }
    }
    return ticketCount;
  }

  function claimDevIncome(address _addr, uint256 _amount)
    public
    returns (address to, uint256 value)
  {
    require(msg.sender == owner, "unauthorized call");
    require(_amount <= devPool, "invalid amount");
    uint256 currentBalance = busdToken.balanceOf(address(this));

    if (currentBalance < _amount) {
      _amount = currentBalance;
    }

    devPool = devPool.sub(_amount);

    busdToken.transfer(_addr, _amount);

    return (_addr, _amount);
  }

  function updateStarttime(uint256 _releaseTime) public returns (bool) {
    require(msg.sender == owner, "unauthorized call");
    releaseTime = _releaseTime;
    return true;
  }
}

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
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "invliad mul");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "invliad div");
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "invliad sub");
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "invliad +");

    return c;
  }
}