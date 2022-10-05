/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/*
  _     ___                _           __        __  __ _       
 | |   / __\__ _ _ __   __| |_   _    /__\ __ _ / _|/ _| | ___  
/ __) / /  / _` | '_ \ / _` | | | |  / \/// _` | |_| |_| |/ _ \ 
\__ \/ /__| (_| | | | | (_| | |_| | / _  \ (_| |  _|  _| |  __/ 
(   /\____/\__,_|_| |_|\__,_|\__, | \/ \_/\__,_|_| |_| |_|\___| 
 |_|                         |___/        
        
*/
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/security/[email protected]

// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @chainlink/contracts/src/v0.8/interfaces/[email protected]

pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  function createSubscription() external returns (uint64 subId);

  function getSubscription(uint64 subId)
    external
    view
    returns (
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


// File @chainlink/contracts/src/v0.8/[email protected]

pragma solidity ^0.8.0;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
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

// File contracts/Clock360Lottery.sol

pragma solidity ^0.8.4;
contract CandyRaffle is VRFConsumerBaseV2, Ownable, Pausable {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId = 313;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;
    uint32 callbackGasLimit = 50000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    mapping(uint256 => uint256[]) public s_randomWords;
    uint256 public s_requestId;

    uint256 public lotteryID = 2;
    mapping(uint256 => address) lotteryWinners;
    mapping(uint256 => uint256) potSizes;
    mapping(uint256 => uint256) endTimes;

    address[] public players;

    address public tokenAddress = 0x824293562F37Dc988f9816A5aD3fefE139A9B2cc;
    IERC20 token;

    uint256 public maxTicketsPerPlayer = 100;
    mapping(uint256 => mapping(address => uint256)) public numTicketsBought;

    uint256 public fee = 10000 ether;
    uint256 public duration = 1 weeks;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        token = IERC20(tokenAddress);
        _pause();
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

    function enter(uint8[] calldata tickets) external payable whenNotPaused {
        require(tickets[0] + numTicketsBought[lotteryID][msg.sender] <= maxTicketsPerPlayer && endTimes[lotteryID] > block.timestamp, "Too many tickets for this player");
        uint _tickets = tickets[0];
        numTicketsBought[lotteryID][msg.sender] += _tickets;
        uint i = 0;

        for ( i; i < _tickets; ++i) {
            unchecked{
                players.push(msg.sender);
            }
        }

        token.transferFrom(msg.sender, address(this), _tickets * fee);
    }

    function start() external onlyOwner {
        endTimes[lotteryID] = block.timestamp + duration;
        _unpause();
    }

    function pickWinner() external onlyOwner {
        require(block.timestamp >= endTimes[lotteryID] && players.length > 0, "Lottery is not over");

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

    function fulfillRandomWords(uint256, uint256[] memory randomWords)
        internal
        override
    {
        s_randomWords[lotteryID] = randomWords;
    }

    function payoutLottery() external {
        require(s_randomWords[lotteryID][0] > 0, "Randomness not set");
            uint256 index = s_randomWords[lotteryID][0] % players.length;
            lotteryWinners[lotteryID] = players[index];
            lotteryID++;
            players = new address[](0);
    }

     function changeDuration(uint256 _newDuration) external onlyOwner {
        duration = _newDuration;
    }

    function maxParams(uint256 _newMaxAmountPerPlayer, uint256 _newFee) external onlyOwner {
        maxTicketsPerPlayer = _newMaxAmountPerPlayer;
        fee = _newFee;
    }

    function transferTokens(uint256 _amount, address _destination) external onlyOwner{
        token.approve(address(_destination), _amount * (10**18));
        token.transfer(_destination, _amount);
    }
}