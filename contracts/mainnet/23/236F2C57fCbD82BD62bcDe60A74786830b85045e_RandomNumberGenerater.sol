/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

pragma solidity ^0.8.4;

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


contract RandomNumberGenerater is VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId = 107;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 50000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    mapping(uint256 => uint256[]) public s_randomWords;
    uint256 public s_requestId;

    uint256 public lotteryID = 1;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }

    function pickWinner() external onlyOwner {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        s_randomWords[lotteryID].push(randomWords[0]);
    }

    function nextLottery() public onlyOwner {
      lotteryID++;
    }

    function getRandomWords() external view returns(uint256[] memory) {
      return s_randomWords[lotteryID-1];
    }
}