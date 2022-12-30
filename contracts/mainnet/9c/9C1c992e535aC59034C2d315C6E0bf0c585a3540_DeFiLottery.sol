/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.5 <0.9.0;

interface IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

abstract contract ReentrancyGuard {
  bool internal locked;

  modifier noReentrant() {
    require(!locked, "No re-entrancy");
    locked = true;
    _;
    locked = false;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    _setOwner(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _setOwner(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");

    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;

    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

contract DeFiLottery is Context, Ownable, ReentrancyGuard {
  IERC20 private tokenInterface;

  address private tokenContract;
  address private devAddress;
  address constant burnAddress = 0x000000000000000000000000000000000000dEaD;

  uint256 private contractStarted = 0;
  uint256[] private lotteryDataId;
  uint256 private nonce;
  uint256 private devFee = 5;
  uint256 private jackpotFee = 15;
  uint256 private burnFee = 0;
  uint256 private ticketPrice = 1 ether;
  uint256 private statsAwarded = 0;
  uint256 private statsBurned = 0;

  struct biggestLotteryRewardDataStruct {
    uint256 id;
    uint256 round;
    uint256 timestamp;
    uint256 prize;
    address participant;
  }

  struct biggestJackpotRewardDataStruct {
    uint256 round;
    uint256 timestamp;
    uint256 prize;
    address participant;
  }

  struct jackpotDataStruct {
    uint256 timestamp;
    uint256 started;
    uint256 end;
    uint256 round;
    uint256 balance;
    uint256 maxTime;
    address[] participants;
    lotteryPreviousWinnersDataStruct[] previousWinners;
  }

  struct lotteryPreviousWinnersDataStruct {
    uint256 round;
    uint256 timestamp;
    uint256 prize;
    address participant;
  }

  struct lotteryDataStruct {
    uint256 id;
    string game;
    bool exists;
    uint256 timestamp;
    uint256 started;
    uint256 end;
    uint256 round;
    uint256 stepping;
    uint256 balance;
    uint256 maxBalance;
    uint256 maxParticipants;
    uint256 maxTime;
    uint256 maxTicketsPerParticipant;
    address[] participants;
    lotteryPreviousWinnersDataStruct[] previousWinners;
  }

  struct lotteryBlacklistDataStruct {
    bool exists;
    uint256 timestamp;
  }

  biggestJackpotRewardDataStruct statsJackpotBiggestReward;
  biggestLotteryRewardDataStruct statsLotteryBiggestReward;

  jackpotDataStruct jackpotData;

  mapping(uint256 => lotteryDataStruct) private lotteryData;
  mapping(address => lotteryBlacklistDataStruct) private lotteryBlacklist;

  modifier isContractStarted {
    require(contractStarted > 0, "Contract not yet started.");

    _;
  }

  event lotteryEventParticipate(uint256 indexed id, string game, uint256 indexed round, uint256 timestamp, address indexed participant, uint256 tickets);
  event lotteryEventWinner(uint256 indexed id, string game, uint256 indexed round, uint256 timestamp, uint256 prize, uint256 participants, address indexed winnerAddress);
  event lotteryEventExtend(uint256 indexed id, uint256 indexed round, uint256 timestamp, uint256 end);
  event jackpotEventWinner(uint256 indexed round, uint256 timestamp, uint256 prize, uint256 participants, address indexed winnerAddress);
  event jackpotEventExtend(uint256 indexed round, uint256 timestamp, uint256 end);

  constructor(address _tokenContract, uint256 _nonce, address _devAddress) {
    tokenContract = _tokenContract;
    tokenInterface = IERC20(tokenContract);
    nonce = _nonce;
    devAddress = _devAddress;
  }

  function initializeContract() external onlyOwner {
    require(contractStarted == 0, "Contract already started.");

    unchecked {
      contractStarted = getCurrentTime();

      jackpotData.maxTime = 7 days;
      jackpotData.timestamp = contractStarted;
      jackpotData.started = jackpotData.timestamp;
      jackpotData.end = jackpotData.started + jackpotData.maxTime;
      jackpotData.round = 1;

      lotteryData[1].id = 1;
      lotteryData[1].game = 'lottery5';
      lotteryData[1].exists = true;
      lotteryData[1].timestamp = contractStarted;
      lotteryData[1].started = lotteryData[1].timestamp;
      lotteryData[1].round = 1;
      lotteryData[1].stepping = 1;
      lotteryData[1].maxParticipants = 5;
      lotteryData[1].maxTicketsPerParticipant = 5;

      lotteryData[2].id = 2;
      lotteryData[2].game = 'lottery10';
      lotteryData[2].exists = true;
      lotteryData[2].timestamp = contractStarted;
      lotteryData[2].started = lotteryData[2].timestamp;
      lotteryData[2].round = 1;
      lotteryData[2].stepping = 1;
      lotteryData[2].maxParticipants = 10;
      lotteryData[2].maxTicketsPerParticipant = 10;

      lotteryData[3].id = 3;
      lotteryData[3].game = 'lottery100';
      lotteryData[3].exists = true;
      lotteryData[3].timestamp = contractStarted;
      lotteryData[3].started = lotteryData[3].timestamp;
      lotteryData[3].round = 1;
      lotteryData[3].stepping = 5;
      lotteryData[3].maxParticipants = 100;
      lotteryData[3].maxTicketsPerParticipant = 100;

      lotteryData[4].id = 4;
      lotteryData[4].game = 'lottery500';
      lotteryData[4].exists = true;
      lotteryData[4].timestamp = contractStarted;
      lotteryData[4].started = lotteryData[4].timestamp;
      lotteryData[4].round = 1;
      lotteryData[4].stepping = 10;
      lotteryData[4].maxParticipants = 500;
      lotteryData[4].maxTicketsPerParticipant = 500;

      lotteryData[5].id = 5;
      lotteryData[5].game = 'lottery1000';
      lotteryData[5].exists = true;
      lotteryData[5].timestamp = contractStarted;
      lotteryData[5].started = lotteryData[5].timestamp;
      lotteryData[5].round = 1;
      lotteryData[5].stepping = 10;
      lotteryData[5].maxParticipants = 1000;
      lotteryData[5].maxTicketsPerParticipant = 1000;

      lotteryData[6].id = 6;
      lotteryData[6].game = 'dailyLottery';
      lotteryData[6].exists = true;
      lotteryData[6].maxTime = 24 hours;
      lotteryData[6].timestamp = contractStarted;
      lotteryData[6].started = lotteryData[6].timestamp;
      lotteryData[6].end = lotteryData[6].started + lotteryData[6].maxTime;
      lotteryData[6].round = 1;
      lotteryData[6].stepping = 10;
      lotteryData[6].maxBalance = 0;
      lotteryData[6].maxParticipants = 5000;
      lotteryData[6].maxTicketsPerParticipant = 500;

      lotteryDataId = [ 1, 2, 3, 4, 5, 6 ];
    }
  }

  function getTokenContract() external view returns (address) {
    return tokenContract;
  }

  function setDevAddress(address addr) external onlyOwner {
    devAddress = addr;
  }

  function setDevFeePercent(uint256 percent) external onlyOwner {
    devFee = percent;
  }

  function setBurnFeePercent(uint256 percent) external onlyOwner {
    burnFee = percent;
  }

  function setJackpotFeePercent(uint256 percent) external onlyOwner {
    jackpotFee = percent;
  }

  function isJackpotEligible(address addr) public view returns (bool) {
    uint256 count = jackpotData.participants.length;

    unchecked {
      for (uint256 i = 0; i < count; i++) {
        if (jackpotData.participants[i] != addr) { continue; }

        return true;
      }

      return false;
    }
  }

  function setTicketPrice(uint256 price) external onlyOwner {
    ticketPrice = price * 1 ether;
  }

  function isBlacklisted(address addr) public view returns (bool) {
    return lotteryBlacklist[addr].exists;
  }

  function blacklistWallet(address addr) external onlyOwner {
    require(!isBlacklisted(addr), "Address is already blacklisted.");

    lotteryBlacklist[addr] = lotteryBlacklistDataStruct(true, getCurrentTime());
  }

  function removeBlacklistWallet(address addr) external onlyOwner {
    require(isBlacklisted(addr), "Address is not blacklisted.");

    delete lotteryBlacklist[addr];
  }

  function getJackpotBalance() external view returns (uint256) {
    return jackpotData.balance;
  }

  function getJackpotData() public view isContractStarted returns (jackpotDataStruct memory data) {
    data = jackpotData;
  }

  function getStats() external view isContractStarted returns (uint256, uint256, uint256, uint256 , uint256, biggestJackpotRewardDataStruct memory, biggestLotteryRewardDataStruct memory) {
    return (devFee, jackpotFee, burnFee, statsAwarded, statsBurned, statsJackpotBiggestReward, statsLotteryBiggestReward);
  }

  function getCurrentTime() internal view returns (uint256) {
    return block.timestamp;
  }

  function getRandom(uint256 salt) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.difficulty, getCurrentTime(), nonce, salt)));
  }

  function getLotteryTicketCount(uint256 id, address addr) public view isContractStarted returns (uint256) {
    require(lotteryData[id].exists, "No data for this lottery index.");

    unchecked {
      lotteryDataStruct storage currentLotteryData = lotteryData[id];
      uint256 tickets = 0;
      uint256 count = currentLotteryData.participants.length;

      for (uint256 i = 0; i < count; i++) {
        if (currentLotteryData.participants[i] != addr) { continue; }

        tickets++;
      }

      return tickets;
    }
  }

  function newLotteryData(uint256 id, string memory game, uint256 stepping, uint256 maxBalance, uint256 maxParticipants, uint256 maxTime, uint256 maxTicketsPerParticipant) external onlyOwner {
    require(!lotteryData[id].exists, "This lottery index already exists.");

    lotteryData[id].id = id;
    lotteryData[id].game = game;
    lotteryData[id].exists = true;
    lotteryData[id].timestamp = getCurrentTime();
    lotteryData[id].started = lotteryData[id].timestamp;
    lotteryData[id].end = lotteryData[id].started + maxTime;
    lotteryData[id].round = 1;
    lotteryData[id].stepping = stepping;
    lotteryData[id].balance = 0;
    lotteryData[id].maxBalance = maxBalance * 1 ether;
    lotteryData[id].maxParticipants = maxParticipants;
    lotteryData[id].maxTime = maxTime;
    lotteryData[id].maxTicketsPerParticipant = maxTicketsPerParticipant;

    lotteryDataId.push(id);
  }

  function setLotteryData(uint256 id, uint256 stepping, uint256 maxBalance, uint256 maxParticipants, uint256 maxTime, uint256 maxTicketsPerParticipant) external onlyOwner {
    require(lotteryData[id].exists, "This lottery index does not exists.");

    lotteryData[id].stepping = stepping;
    lotteryData[id].maxBalance = maxBalance * 1 ether;
    lotteryData[id].maxParticipants = maxParticipants;
    lotteryData[id].maxTime = maxTime;
    lotteryData[id].maxTicketsPerParticipant = maxTicketsPerParticipant;

    lotteryDataId.push(id);
  }

  function getLotteryParticipants(uint256 id) external view onlyOwner isContractStarted returns (address[] memory) {
    require(lotteryData[id].exists, "No data for this lottery index.");

    return lotteryData[id].participants;
  }

  function getLotteryData(uint256 id) public view isContractStarted returns (lotteryDataStruct memory data, uint256 price) {
    require(lotteryData[id].exists, "No data for this lottery index.");

    data = lotteryData[id];
    price = ticketPrice;
  }

  function lotteryParticipate(uint256 id, uint256 tickets) external payable noReentrant isContractStarted {
    require(!isBlacklisted(msg.sender), "Address is blacklisted.");

    lotteryDataStruct storage currentLotteryData = lotteryData[id];

    require(currentLotteryData.exists, "No data for this lottery index.");
    require(currentLotteryData.maxParticipants > 0, "Participation exceeded for this lottery round.");
    require(tickets % currentLotteryData.stepping == 0, "Stepping not satisfied for this lottery round.");
    require(currentLotteryData.maxParticipants >= currentLotteryData.participants.length + tickets, "Participation exceeded for this lottery round.");
    require(currentLotteryData.maxTicketsPerParticipant == 0 || tickets <= currentLotteryData.maxTicketsPerParticipant, "Participation exceeded for this lottery round.");
    require(currentLotteryData.end == 0 || (currentLotteryData.end > 0 && currentLotteryData.end >= getCurrentTime()), "Time is up for this lottery round.");

    unchecked {
      if (currentLotteryData.maxTicketsPerParticipant > 0) {
        uint256 total = 0;
        uint256 participants = currentLotteryData.participants.length;

        for (uint256 i = 0; i < participants; i++) {
          if (currentLotteryData.participants[i] != msg.sender) { continue; }

          total++;
        }

        require(total + tickets <= currentLotteryData.maxTicketsPerParticipant, "Participation exceeded for this lottery game index.");
      }

      uint256 amount = tickets * ticketPrice;

      require(tokenInterface.balanceOf(msg.sender) >= amount, "Insufficient balance.");
      require(tokenInterface.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance.");

      uint256 devFeeAmount = amount * devFee / 100;
      uint256 burnFeeAmount = amount * burnFee / 100;
      uint256 jackpotFeeAmount = amount * jackpotFee / 100;
      uint256 totalFeeAmount = devFeeAmount + burnFeeAmount;
      uint256 participationAmount = amount - totalFeeAmount;

      if (devFeeAmount > 0) {
        bool txDevFee = tokenInterface.transferFrom(msg.sender, devAddress, devFeeAmount);
        require(txDevFee, "Transfer error (devAddress)");
      }

      if (burnFeeAmount > 0) {
        bool txBurnFee = tokenInterface.transferFrom(msg.sender, burnAddress, burnFeeAmount);
        require(txBurnFee, "Transfer error (burnAddress)");

        statsBurned += burnFeeAmount;
      }

      bool txTickets = tokenInterface.transferFrom(msg.sender, address(this), participationAmount);
      require(txTickets, "Transfer error (contractAddress)");

      for (uint256 i = 0; i < tickets; i++) { currentLotteryData.participants.push(msg.sender); }

      currentLotteryData.balance += participationAmount - jackpotFeeAmount;
      currentLotteryData.timestamp = getCurrentTime();

      jackpotData.balance += jackpotFeeAmount;
      jackpotData.timestamp = getCurrentTime();

      if (!isJackpotEligible(msg.sender)) { jackpotData.participants.push(msg.sender); }

      emit lotteryEventParticipate(id, currentLotteryData.game, currentLotteryData.round, getCurrentTime(), msg.sender, tickets);
    }

    lotteryDraw(id);
  }

  function execLotteryDraw(uint256 id) public onlyOwner returns (bool) {
    return lotteryDraw(id);
  }

  function execJackpotDraw() public onlyOwner returns (bool) {
    return jackpotDraw();
  }

  function lotteryDraw(uint256 id) internal isContractStarted returns (bool) {
    lotteryDataStruct storage currentLotteryData = lotteryData[id];

    require(currentLotteryData.timestamp <= getCurrentTime());

    if ((currentLotteryData.end > 0 && getCurrentTime() >= currentLotteryData.end) || (currentLotteryData.maxBalance > 0 && currentLotteryData.balance >= currentLotteryData.maxBalance) || (currentLotteryData.maxParticipants > 0 && currentLotteryData.participants.length >= currentLotteryData.maxParticipants)) {
      unchecked {
        if ((currentLotteryData.end > 0 && getCurrentTime() >= currentLotteryData.end) && currentLotteryData.balance == 0) {
          currentLotteryData.timestamp = getCurrentTime();
          currentLotteryData.end = currentLotteryData.timestamp + 24 hours;

          emit lotteryEventExtend(id, currentLotteryData.round, currentLotteryData.timestamp, currentLotteryData.end);
          return false;
        }

        uint256 winnerId = getRandom(currentLotteryData.timestamp) % currentLotteryData.participants.length;
        address winnerAddress = payable(currentLotteryData.participants[winnerId]);

        bool txPrize = tokenInterface.transfer(winnerAddress, currentLotteryData.balance);
        require(txPrize, "Transfer error (winnerAddress)");

        emit lotteryEventWinner(id, currentLotteryData.game, currentLotteryData.round, getCurrentTime(), currentLotteryData.balance, currentLotteryData.participants.length, winnerAddress);

        statsAwarded += currentLotteryData.balance;

        if (currentLotteryData.balance > statsLotteryBiggestReward.prize) {
          statsLotteryBiggestReward.id = currentLotteryData.id;
          statsLotteryBiggestReward.round = currentLotteryData.round;
          statsLotteryBiggestReward.timestamp = getCurrentTime();
          statsLotteryBiggestReward.prize = currentLotteryData.balance;
          statsLotteryBiggestReward.participant = winnerAddress;
        }

        currentLotteryData.previousWinners.push(lotteryPreviousWinnersDataStruct(currentLotteryData.round, getCurrentTime(), currentLotteryData.balance, winnerAddress));

        currentLotteryData.round++;
        currentLotteryData.balance = 0;
        currentLotteryData.timestamp = currentLotteryData.timestamp;
        currentLotteryData.started = getCurrentTime();
        currentLotteryData.end = currentLotteryData.maxTime > 0 ? currentLotteryData.started + currentLotteryData.maxTime : 0;
        delete currentLotteryData.participants;
      }

      return true;
    }

    if ((currentLotteryData.end > 0 && getCurrentTime() >= currentLotteryData.end) && currentLotteryData.balance == 0) {
      currentLotteryData.timestamp = getCurrentTime();
      currentLotteryData.end = currentLotteryData.timestamp + 24 hours;

      emit lotteryEventExtend(id, currentLotteryData.round, currentLotteryData.timestamp, currentLotteryData.end);
    }

    return false;
  }

  function jackpotDraw() internal isContractStarted returns (bool) {
    require(jackpotData.timestamp <= getCurrentTime());

    if (jackpotData.end > getCurrentTime()) { return false; }

    unchecked {
      if (jackpotData.balance == 0) {
        jackpotData.timestamp = getCurrentTime();
        jackpotData.end = jackpotData.timestamp + 24 hours;

        emit jackpotEventExtend(jackpotData.round, jackpotData.timestamp, jackpotData.end);
        return false;
      }

      uint256 winnerId = getRandom(jackpotData.timestamp) % jackpotData.participants.length;
      address winnerAddress = payable(jackpotData.participants[winnerId]);

      uint256 devFeeAmount = jackpotData.balance * devFee / 100;
      uint256 burnFeeAmount = jackpotData.balance * burnFee / 100;
      uint256 totalFeeAmount = devFeeAmount + burnFeeAmount;
      uint256 prizeAmount = jackpotData.balance - totalFeeAmount;

      if (devFeeAmount > 0) {
        bool txDevFee = tokenInterface.transfer(devAddress, devFeeAmount);
        require(txDevFee, "Transfer error (devAddress)");
      }

      if (burnFeeAmount > 0) {
        bool txBurnFee = tokenInterface.transfer(burnAddress, burnFeeAmount);
        require(txBurnFee, "Transfer error (burnAddress)");

        statsBurned += burnFeeAmount;
      }

      bool txPrize = tokenInterface.transfer(winnerAddress, prizeAmount);
      require(txPrize, "Transfer error (winnerAddress)");

      emit jackpotEventWinner(jackpotData.round, getCurrentTime(), jackpotData.balance, jackpotData.participants.length, winnerAddress);

      statsAwarded += jackpotData.balance;

      if (jackpotData.balance > statsJackpotBiggestReward.prize) {
        statsJackpotBiggestReward.round = jackpotData.round;
        statsJackpotBiggestReward.timestamp = getCurrentTime();
        statsJackpotBiggestReward.prize = jackpotData.balance;
        statsJackpotBiggestReward.participant = winnerAddress;
      }

      jackpotData.previousWinners.push(lotteryPreviousWinnersDataStruct(jackpotData.round, getCurrentTime(), jackpotData.balance, winnerAddress));

      jackpotData.round++;
      jackpotData.balance = 0;
      jackpotData.timestamp = getCurrentTime();
      jackpotData.started =jackpotData.timestamp;
      jackpotData.end = jackpotData.started + jackpotData.maxTime;
      delete jackpotData.participants;
    }

    return true;
  }
}