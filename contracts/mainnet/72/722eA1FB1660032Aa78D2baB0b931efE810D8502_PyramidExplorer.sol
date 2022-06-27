/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

pragma solidity ^0.8.10;

/**
*  ____                                            __      ____                   ___                                
* /\  _`\                                   __    /\ \    /\  _`\                /\_ \                               
*\ \ \L\ \__  __  _ __    __      ___ ___ /\_\   \_\ \   \ \ \L\_\  __  _  _____\//\ \     ___   _ __    __   _ __  
* \ \ ,__/\ \/\ \/\`'__\/'__`\  /' __` __`\/\ \  /'_` \   \ \  _\L /\ \/'\/\ '__`\\ \ \   / __`\/\`'__\/'__`\/\`'__\
*  \ \ \/\ \ \_\ \ \ \//\ \L\.\_/\ \/\ \/\ \ \ \/\ \L\ \   \ \ \L\ \/>  </\ \ \L\ \\_\ \_/\ \L\ \ \ \//\  __/\ \ \/ 
*   \ \_\ \/`____ \ \_\\ \__/.\_\ \_\ \_\ \_\ \_\ \___,_\   \ \____//\_/\_\\ \ ,__//\____\ \____/\ \_\\ \____\\ \_\ 
*    \/_/  `/___/> \/_/ \/__/\/_/\/_/\/_/\/_/\/_/\/__,_ /    \/___/ \//\/_/ \ \ \/ \/____/\/___/  \/_/ \/____/ \/_/ 
*             /\___/                                                         \ \_\                                  
*             \/__/                                                           \/_/                                  
*/


// SPDX-License-Identifier: MIT
interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

contract PyramidExplorer is VRFConsumerBaseV2
{
    /** Kernel used */
    address public owner;
    bool public started;
    PyramidNFTInterface private pyramidNft;

    /** Chainlink VRF related */
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 subscriptionId;
    address vrfCoordinator;
    bytes32 keyHash;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;

    /** Magic */
    uint constant PSN = 10000;
    uint constant PSNH = 5000;

    /** Application variables */
    uint public TREASURE_TO_HIRE_1EXPLORER = 2592000;
    uint public PERCENTS_DIVIDER = 1000;
    uint public REFERRAL = 60;
    uint public DEV_FEE = 30;

    uint public MIN_INVEST_LIMIT = 0.01 ether;
    uint public MAX_DEPOSIT_LIMIT = 50 ether;

    uint public COMPOUND_BONUS = 50;
    uint public COMPOUND_BONUS_MAX_TIMES = 5;
    uint public COMPOUND_STEP = 24 hours;

    uint public WITHDRAWAL_TAX = 800;
    uint public COMPOUND_TIMES_MANDATORY = 5;

    uint public CUTOFF_STEP = 48 hours;
    uint public WITHDRAW_COOLDOWN = 12 hours;
    uint public DEEP_EXPLORATION_COOLDOWN = 30 minutes;

    uint public MARKET_TREASURE_DIVISOR = 20; // 100/20 = 5 5%
    uint public MARKET_TREASURE_DIVISOR_SELL = 1; // 100%

    uint[] public TYPE_1_CHANCES = [500, 250, 150, 50, 40, 10];
    uint[] public TYPE_1_MULTIPLIER = [200, 400, 2000, 3000, 5000, 10000];

    uint[] public TYPE_2_CHANCES = [300, 250, 200, 150, 90, 10];
    uint[] public TYPE_2_MULTIPLIER = [300, 500, 1200, 1500, 2600, 4000];

    // Contract stats
    uint public marketTreasures;
    uint public totalReferralBonus;
    uint public totalStake;
    uint public totalDeposits;
    uint public totalCompound;

    struct Pyramid {
        uint initialDeposit;
        uint explorers;
        uint claimedTreasures;
        uint lastExplore;
        address referrer;
        uint dailyCompoundBonus;
        uint lastWithdraw;
        uint pyramidId;
    }

    struct Queue {
        uint requestId;
        uint depositAmount;
        bool isSettled;
        uint16 queueType;
        uint multiplier;
        uint outcome;
        uint time;
    }

    mapping(address => Pyramid) public pyramids;
    mapping(address => Queue) public queues;
    mapping(uint => address) public requestIdToSender;
    mapping(address => uint) public lastDeepExploration;

    /** Events */
    event Deposit(
        address indexed sender,
        uint amount,
        uint treasures
    );

    event Withdraw(
        address indexed sender,
        uint amount
    );

    event Compound(
        address indexed sender,
        uint amount,
        uint explorers
    );

    event ReferralSent(
        address indexed sender,
        address indexed referrer,
        uint treasures
    );

    event VrfRequested(
        address indexed sender,
        uint requestId,
        uint depositAmount
    );

    event QueueClaimed(
        address indexed sender,
        uint16 queueType,
        uint outcome,
        uint multiplier,
        uint depositAmount
    );

    constructor(uint64 _subscriptionId, address _vrfCoordinator, bytes32 _keyHash) VRFConsumerBaseV2(_vrfCoordinator)
    {
        owner = msg.sender;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        vrfCoordinator = _vrfCoordinator;
        keyHash = _keyHash;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Owner only");
        _;
    }

    modifier onlyStarted() {
        require(started == true, "Not started.");
        _;
    }

    fallback() external payable {}
    receive() external payable {}

    // Hatch Eggs
    function rehireExplorers(bool isCompound) public onlyStarted {
        Pyramid storage pyramid = pyramids[msg.sender];

        uint treasureUsed = getMyTreasure(msg.sender);
        uint treasureForCompound = treasureUsed;

        if (isCompound) {
            treasureForCompound += getDailyCompoundBonus(msg.sender, treasureForCompound);
        }

        uint treasureValue = calculateTreasureSell(treasureForCompound);

        // Check compound bouns add
        if (
            block.timestamp - pyramid.lastExplore >= COMPOUND_STEP &&
            pyramid.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES
        ) {
            pyramid.dailyCompoundBonus ++;
        }

        // Reset pyramid
        pyramid.claimedTreasures = 0;
        pyramid.lastExplore = block.timestamp;
        pyramid.explorers += treasureForCompound / TREASURE_TO_HIRE_1EXPLORER;

        // Emit event
        emit Compound(msg.sender, treasureValue, treasureForCompound / TREASURE_TO_HIRE_1EXPLORER);

        marketTreasures += (treasureUsed / MARKET_TREASURE_DIVISOR);
    }

    // Buy Eggs
    function hireExplorer(address _referrer) external payable onlyStarted {
        // Get Pyramid
        Pyramid storage pyramid = pyramids[msg.sender];

        // Validation
        require(msg.value >= MIN_INVEST_LIMIT, "MIN_INVEST_LIMIT");
        require(pyramid.initialDeposit <= MAX_DEPOSIT_LIMIT, "MAX_DEPOSIT_LIMIT");

        // Initialize referrer.
        if (_referrer != address(0) && pyramid.referrer == address(0) && _referrer != msg.sender) {
            pyramid.referrer = _referrer;
        }

        // Buy treasures
        AddTreasure(msg.sender, msg.value);

        // Use treasures to hire explorers
        rehireExplorers(false);
    }

    function AddTreasure(address sender, uint amount) internal {
        Pyramid storage pyramid = pyramids[sender];

        // Calculate treasures
        uint treasuresBought = calculateTreasureBuy(amount, address(this).balance - amount);
        treasuresBought -= devFee(treasuresBought);

        // Transfer dev fee
        (bool transferSuccess, ) = owner.call{value: devFee(amount)}("");
        require(transferSuccess, "Transfer dev fee failed.");

        // Transfer referral bonus
        if (pyramid.referrer != address(0)) {
            uint referralBonusTreasures = treasuresBought * REFERRAL / PERCENTS_DIVIDER;
            pyramids[pyramid.referrer].claimedTreasures += referralBonusTreasures;
            emit ReferralSent(sender, pyramid.referrer, referralBonusTreasures);
        }

        // Add pyramid deposit amount
        pyramid.claimedTreasures += treasuresBought;
        pyramid.initialDeposit += amount;

        // Emit event
        emit Deposit(sender, amount - devFee(amount), treasuresBought);

        // Check NFT minting
        if (pyramid.pyramidId == 0) {
            pyramid.pyramidId = pyramidNft.safeMint(sender);
        }
    }

    // Sell Eggs
    function harvestTreasure() public onlyStarted {
        Pyramid storage pyramid = pyramids[msg.sender];

        uint hasTreasures = getMyTreasure(msg.sender);
        uint treasureValue = calculateTreasureSell(hasTreasures);

        // Check withdraw cooldown
        require(block.timestamp - pyramid.lastWithdraw >= WITHDRAW_COOLDOWN, "Withdraw Cooldown");

        // Check early withdraw tax
        if (pyramid.dailyCompoundBonus < COMPOUND_TIMES_MANDATORY) {
            treasureValue -= (treasureValue * WITHDRAWAL_TAX) / PERCENTS_DIVIDER;
        } else {
            pyramid.dailyCompoundBonus = 0;
        }

        if (address(this).balance < treasureValue) {
            treasureValue = address(this).balance;
        }

        // Dev fee
        uint payout = treasureValue - devFee(treasureValue);
        (bool ownerSuccess, ) = owner.call{value: devFee(treasureValue)}("");
        require(ownerSuccess, "Dev fee pay failed");

        // Reset pyramid
        pyramid.claimedTreasures = 0;
        pyramid.lastWithdraw = block.timestamp;
        pyramid.lastExplore = block.timestamp;

        // Emit event
        emit Withdraw(msg.sender, payout);

        marketTreasures += (hasTreasures / MARKET_TREASURE_DIVISOR_SELL);

        // Transfer
        (bool pyramidSuccess, ) = msg.sender.call{value: payout}("");
        require(pyramidSuccess, "msg.sender pay failed");
    }

    function hireMysteryExplorers(address _referrer) external payable onlyStarted {
        createQueue(1, _referrer);
    }

    function deepExploration(address _referrer) external payable onlyStarted {
        require(lastDeepExploration[msg.sender] + DEEP_EXPLORATION_COOLDOWN <= block.timestamp, "Deep exploration cooldown time.");
        require(getMyTreasure(msg.sender) >= TREASURE_TO_HIRE_1EXPLORER, "Your treasure is not enough to hire one explorer");
        createQueue(2, _referrer);
    }

    function createQueue(uint16 _queueType, address _referrer) internal {
        // Get Pyramid
        Pyramid storage pyramid = pyramids[msg.sender];

        // Validation
        require(msg.value >= MIN_INVEST_LIMIT, "MIN_INVEST_LIMIT");
        require(pyramid.initialDeposit <= MAX_DEPOSIT_LIMIT, "MAX_DEPOSIT_LIMIT");

        // Initialize referrer.
        if (_referrer != address(0) && pyramid.referrer == address(0) && _referrer != msg.sender) {
            pyramid.referrer = _referrer;
        }

        // Each address can only have one queue at a time.
        Queue storage queue = queues[msg.sender];
        require(queue.isSettled == false, "Each address can only have one queue at a time");
        require(queue.depositAmount == 0, "Each address can only have one queue at a time");

        // Request a random word from Chainlink VRF
        uint requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            1
        );

        // Save VRF queue
        queue.depositAmount = msg.value;
        queue.isSettled = false;
        queue.queueType = _queueType; // 1: MysteryHire 2: Explore
        queue.requestId = requestId;
        queue.time = block.timestamp;

        // Mapping request ID and sender address.
        requestIdToSender[requestId] = msg.sender;

        // Emit event
        emit VrfRequested(msg.sender, requestId, msg.value);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address sender = requestIdToSender[requestId];
        // Handle randomness
        Queue storage queue = queues[sender];

        // Check
        require(queue.depositAmount > 0, "Queue not exist.");
        require(queue.isSettled == false, "Queue is settled already.");

        // Decide multiplier
        uint multiplier;
        uint outcome = randomWords[0] % PERCENTS_DIVIDER;

        uint[] memory chances;
        uint[] memory multipliers;

        if (queue.queueType == 1) {
            chances = TYPE_1_CHANCES;
            multipliers = TYPE_1_MULTIPLIER;
        }
        if (queue.queueType == 2) {
            chances = TYPE_2_CHANCES;
            multipliers = TYPE_2_MULTIPLIER;
        }

        uint sum = 0;
        for (uint i = 0; i < chances.length; i ++) {
            sum += chances[i];
            if (outcome < sum) {
                multiplier = multipliers[i];
                break;
            }
        }

        require(multiplier > 0, "Chance mapping failed");

        queue.isSettled = true;
        queue.multiplier = multiplier;
        queue.outcome = outcome;
    }

    function claimQueueReward() external onlyStarted {
        Queue storage queue = queues[msg.sender];

        require(queue.isSettled == true, "Queue is not settled yet.");
        require(queue.depositAmount > 0, "Queue is not existed.");

        if (queue.queueType == 1) {
            uint amount = (queue.depositAmount * queue.multiplier) / PERCENTS_DIVIDER;
            AddTreasure(msg.sender, amount);
            rehireExplorers(false);
        }

        if (queue.queueType == 2) {
            Pyramid storage pyramid = pyramids[msg.sender];

            uint treasureUsed = getMyTreasure(msg.sender);
            uint treasureForCompound = treasureUsed;
            treasureForCompound = (treasureForCompound * queue.multiplier) / PERCENTS_DIVIDER;
            treasureForCompound += getDailyCompoundBonus(msg.sender, treasureForCompound);

            if (
                block.timestamp - pyramid.lastExplore >= COMPOUND_STEP &&
                pyramid.dailyCompoundBonus < COMPOUND_BONUS_MAX_TIMES
            ) {
                pyramid.dailyCompoundBonus ++;
            }

            uint treasureValue = calculateTreasureSell(treasureForCompound);

            pyramid.claimedTreasures = 0;
            pyramid.lastExplore = block.timestamp;
            pyramid.explorers += treasureForCompound / TREASURE_TO_HIRE_1EXPLORER;

            emit Compound(msg.sender, treasureValue, treasureForCompound / TREASURE_TO_HIRE_1EXPLORER);

            marketTreasures += treasureUsed / MARKET_TREASURE_DIVISOR;

            lastDeepExploration[msg.sender] = block.timestamp;
        }

        delete queues[msg.sender];
    }

    function refundQueue(address _address) external {
        Queue storage queue = queues[_address];
        require(queue.isSettled == false, "Queue is settled");
        require(queue.depositAmount > 0, "Refund deposited queue only");
        require(block.timestamp - queue.time > 3600, "Refund time limit");

        (bool pyramidSuccess, ) = msg.sender.call{value: queue.depositAmount}("");
        require(pyramidSuccess, "msg.sender pay failed");

        delete queues[msg.sender];
    }

    /** Getters */
    function getMyTreasure(address _address) public view returns(uint) {
        return pyramids[_address].claimedTreasures + getTreasureSinceLastExplore(_address);
    }

    function getTreasureSinceLastExplore(address _address) public view returns(uint) {
        uint secondsPassed = block.timestamp - pyramids[_address].lastExplore;
        secondsPassed = min(secondsPassed, CUTOFF_STEP);
        return secondsPassed * pyramids[_address].explorers;
    }

    function getDailyCompoundBonus(address _address, uint _amount) public view returns(uint) {
        if (pyramids[_address].dailyCompoundBonus == 0) {
            return 0;
        } else {
            uint totalBonus = pyramids[_address].dailyCompoundBonus * COMPOUND_BONUS;
            return (_amount * totalBonus) / PERCENTS_DIVIDER;
        }
    }

    function getPyramid(address _address) public view returns(
        uint _initialDeposit,
        uint _explorers,
        uint _claimedTreasures,
        uint _lastExplore,
        address _referrer,
        uint _dailyCompoundBonus,
        uint _lastWithdraw,
        uint _lastDeepExploration
    ) {
         _initialDeposit = pyramids[_address].initialDeposit;
         _explorers = pyramids[_address].explorers;
         _claimedTreasures = pyramids[_address].claimedTreasures;
         _lastExplore = pyramids[_address].lastExplore;
         _referrer = pyramids[_address].referrer;
         _dailyCompoundBonus = pyramids[_address].dailyCompoundBonus;
         _lastWithdraw = pyramids[_address].lastWithdraw;
         _lastDeepExploration = lastDeepExploration[_address];
        }

    function getQueue(address _address) public view returns(
        uint _requestId,
        uint _depositAmount,
        bool _isSettled,
        uint16 _queueType,
        uint _multiplier,
        uint _outcome,
        uint _time
    ) {
        _requestId = queues[_address].requestId;
        _depositAmount = queues[_address].depositAmount;
        _isSettled = queues[_address].isSettled;
        _queueType = queues[_address].queueType;
        _multiplier = queues[_address].multiplier;
        _outcome = queues[_address].outcome;
        _time = queues[_address].time;
    }

    /** Calculation functions */
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private pure returns(uint) {
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function calculateTreasureSell(uint _treasures) public view returns(uint) {
        return calculateTrade(_treasures, marketTreasures, address(this).balance);
    }

    function calculateTreasureBuy(uint _amount, uint _contractBalance) public view returns(uint) {
        return calculateTrade(_amount, _contractBalance, marketTreasures);
    }

    function calculateTreasureBuySimple(uint _amount) public view returns(uint) {
        return calculateTreasureBuy(_amount, address(this).balance);
    }

    function devFee(uint _amount) public view returns(uint) {
        return (_amount * DEV_FEE) / PERCENTS_DIVIDER;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    /** Owner functions */
    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function initialize() payable external onlyOwner {
        require(marketTreasures == 0 && started == false);
        started = true;
        marketTreasures = 259200000000;
    }

    function setSubscriptionId(uint64 _subscriptionId) external onlyOwner {
        subscriptionId = _subscriptionId;
    }

    function setVrfCoordinator(address _vrfCoordinator) external onlyOwner {
        vrfCoordinator = _vrfCoordinator;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    }

    function setKeyhash(bytes32 _keyhash) external onlyOwner {
        keyHash = _keyhash;
    }

    function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
        callbackGasLimit = _callbackGasLimit;
    }

    function setRequestConfirmations(uint16 _requestConfirmations) external onlyOwner {
        requestConfirmations = _requestConfirmations;
    }

    function setTreasureToHire1Explorer(uint _value) external onlyOwner {
        require(_value >= 479520 && _value <= 2592000); /** min 3% max 12% */
        TREASURE_TO_HIRE_1EXPLORER = _value;
    }

    function setReferral(uint _value) external onlyOwner {
        require(_value >= 10 && _value <= 100); /** min 1% max 10% */
        REFERRAL = _value;
    }

    function setDevFee(uint _value) external onlyOwner {
        require(_value <= 60); /** max 6% */
        DEV_FEE = _value;
    }

    function setMinInvestLimit(uint _value) external onlyOwner {
        MIN_INVEST_LIMIT = _value;
    }

    function setMaxDepositLimit(uint _value) external onlyOwner {
        MAX_DEPOSIT_LIMIT = _value;
    }

    function setCompoundBonus(uint _value) external onlyOwner {
        require(_value >= 10 && _value <=500);
        COMPOUND_BONUS = _value;
    }

    function setCompoundBonusMaxTimes(uint _value) external onlyOwner {
        require(_value <= 30);
        COMPOUND_BONUS_MAX_TIMES = _value;
    }

    function setCompoundStep(uint _value) external onlyOwner {
        COMPOUND_STEP = _value;
    }

    function setWithdrawalTax(uint _value) external onlyOwner {
        require(_value <= 800); // max: 80%
        WITHDRAWAL_TAX = _value;
    }

    function setCompoundTimesMandatory(uint _value) external onlyOwner {
        require(_value <= 30); // max times: 30
        COMPOUND_TIMES_MANDATORY = _value;
    }

    function setCutoffStep(uint _value) external onlyOwner {
        CUTOFF_STEP = _value;
    }

    function setWithdrawCooldown(uint _value) external onlyOwner {
        WITHDRAW_COOLDOWN = _value;
    }

    function setDeepExplorationCooldown(uint _value) external onlyOwner {
        DEEP_EXPLORATION_COOLDOWN = _value;
    }

    function setMarketTreasureDivisor(uint _value) external onlyOwner {
        require(_value <= 50); // 100/50 = 2%, 100/20 = 5%, 100/10 = 10%
        MARKET_TREASURE_DIVISOR = _value;
    }

    function setType1Chances(uint[] memory _chances) external onlyOwner {
        TYPE_1_CHANCES = _chances;
    }

    function setType1Multiplier(uint[] memory _multiplier) external onlyOwner {
        TYPE_1_MULTIPLIER = _multiplier;
    }

    function setType2Chances(uint[] memory _chances) external onlyOwner {
        TYPE_2_CHANCES = _chances;
    }

    function setType2Multiplier(uint[] memory _multiplier) external onlyOwner {
        TYPE_2_MULTIPLIER = _multiplier;
    }

    function setNft(address _contractAddress) external onlyOwner {
        pyramidNft = PyramidNFTInterface(_contractAddress);
    }
}

contract PyramidNFTInterface {
    function safeMint(address to) public returns(uint) {}
}