/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface VRFCoordinatorV2Interface {
  
  function getRequestConfig() external view returns (uint16, uint32, bytes32[] memory);

  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  function createSubscription() external returns (uint64 subId);

  function getSubscription(uint64 subId) external view returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  function addConsumer(uint64 subId, address consumer) external;

  function removeConsumer(uint64 subId, address consumer) external;

  function cancelSubscription(uint64 subId, address to) external;
}

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

pragma solidity ^0.8.4;
contract FortuneLottery is VRFConsumerBaseV2, Ownable, Pausable {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId = 60;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 50000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    mapping(uint256 => uint256[]) public s_randomWords;
    uint256 public s_requestId;

    uint256 public lotteryID = 1;
    mapping(uint256 => address) lotteryWinners;
    mapping(uint256 => uint256) potSizes;
    mapping(uint256 => uint256) endTimes;

    address[] public players;

    address public teamAddress;

    uint256 public maxTicketsPerPlayer = 100;
    uint256 public ticketPrice = 0.1 ether;
    mapping(uint256 => mapping(address => uint256)) public numTicketsBought;

    uint256 public winnerShare = 500;
    uint256 public shareDenominator = 1000;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        teamAddress = msg.sender;
        _pause();
    }

    function setTeamAddress(address _teamAddress) external onlyOwner {
        teamAddress = _teamAddress;
    }

    function setTicketPrice(uint256 _ticketPrice) external onlyOwner {
        ticketPrice = _ticketPrice;
    }

    function totalEntries() external view returns (uint256) {
        return players.length;
    }

    function pastEntries(uint256 _id) external view returns (uint256) {
        return potSizes[_id];
    }

    function userEntries(address user) external view returns (uint256) {
        return numTicketsBought[lotteryID][user];
    }

    function previousWinner() external view returns (address) {
        require(lotteryID > 1, "No winners yet");
        return lotteryWinners[lotteryID - 1];
    }

    function pastWinner(uint256 _id) external view returns (address) {
        require(_id < lotteryID, "No winner yet");
        return lotteryWinners[_id];
    }

    function endTime(uint256 _id) external view returns (uint256) {
        return endTimes[_id];
    }

    function isActive() external view returns (bool) {
        return (endTimes[lotteryID] > block.timestamp) && !paused();
    }

    function enter(uint256 tickets) external payable whenNotPaused {
        require(tickets > 0, "Must make at least one entry");
        require(tickets + numTicketsBought[lotteryID][msg.sender] <= maxTicketsPerPlayer, "Too many tickets for this player");
        require(endTimes[lotteryID] > block.timestamp, "Lottery is over");
        require(msg.value == tickets * ticketPrice, "payable amount is not correct!");

        numTicketsBought[lotteryID][msg.sender] += tickets;

        for (uint256 i = 0; i < tickets; i++) {
            players.push(msg.sender);
        }
    }

    function start(uint256 _endTime) external onlyOwner {
        require(_endTime > block.timestamp, "End time must be in the future");
        endTimes[lotteryID] = _endTime;
        _unpause();
    }

    function setEndTime(uint _endTime) external onlyOwner {
        require(_endTime > block.timestamp, "End time must be in the future");
        endTimes[lotteryID] = _endTime;
    }

    function pickWinner() external onlyOwner {
        require(players.length > 0);
        require(block.timestamp >= endTimes[lotteryID], "Lottery is not over");

        _pause();
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        potSizes[lotteryID] = players.length;
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        s_randomWords[lotteryID] = randomWords;
    }

    function payoutLottery() external onlyOwner {
        require(s_randomWords[lotteryID][0] > 0, "Randomness not set");

        if (players.length > 0) {
            uint256 totalAmount = players.length * 10**18;
            uint256 winnerAmount = (totalAmount * winnerShare) / shareDenominator;
            uint256 teamAmount = totalAmount - winnerAmount;

            uint256 index = s_randomWords[lotteryID][0] % players.length;
            lotteryWinners[lotteryID] = players[index];

            payable(players[index]).transfer(winnerAmount);
            payable(teamAddress).transfer(teamAmount);
        }
        lotteryID++;
        players = new address[](0);
    }
}