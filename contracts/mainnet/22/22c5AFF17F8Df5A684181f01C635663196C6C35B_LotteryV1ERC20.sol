// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IMiner {
    function lotteryPays(uint _amount) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "./IMiner.sol";
import "../Libs/IERC20.sol";

contract LotteryV1ERC20 is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    bool internal pickingWinner;

    address public token;
    address public dealerAddr;
    address public ownerAddr;
    address public minerAddr;
    uint public devFee;
    uint public minerFee;
    uint public lotteryFee;
    uint public ticketPrice;
    uint public currentLotteryId;
    
    uint64 public c_subscriptionId;
    uint32 public c_callbackGasLimit = 2500000;
    address public c_vrfCoordinator;
    bytes32 public c_keyHash;
    uint16 public c_requestConfirmations = 3;
    uint32 public c_numWords = 1;
    uint256 public lastRandomNumber;

    struct Ticket {
        uint id;
        address addr;
    }
    struct Lottery {
        uint id;
        uint256 soldTickets;
        uint winningNumber;
        uint wonAmount;
        address winner;
        mapping (address => uint) userTickets;
        mapping (uint => Ticket) tickets;
    }
    mapping (uint => Lottery) public lotterys;

    event purchasedTickets(address indexed _from, uint _quantity, uint _value);
    event numberRequested(address indexed _from, uint _blockNumber, uint _currentLotteryId);
    event pickedWinner(address indexed _from, uint _lotteryId, address indexed _winnerAddress, uint _winningNumber, uint _value);
    event ticketPriceUpdated(uint _newTicketPrice);
    event ReceivedFromMiner(address _from, uint _minerValue);
    
    constructor(address _vrfCoordinator, address _dealerAddr) VRFConsumerBaseV2(_vrfCoordinator) {
        c_vrfCoordinator = _vrfCoordinator;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        dealerAddr = _dealerAddr;
        ownerAddr = msg.sender;
        lotterys[0].id = 0;
        currentLotteryId = 1;
        lotterys[currentLotteryId].id = currentLotteryId;
        lotterys[currentLotteryId].soldTickets = 0;
        ticketPrice = 0.01 ether;
        devFee = 5;
        minerFee = 10;
        lotteryFee = 15;
    }

    function buyTickets(uint numberOfTickets) public {
        require(!pickingWinner, "Lottery is picking winner, please wait until next round");
        uint ticketsPrice = numberOfTickets * ticketPrice;
        ERC20(token).transferFrom(address(msg.sender), address(this), ticketsPrice);

        uint newTicketNumber;
        for (uint i = 0; i < numberOfTickets; i++) {
            newTicketNumber = lotterys[currentLotteryId].soldTickets + 1;
            lotterys[currentLotteryId].tickets[newTicketNumber] = Ticket(newTicketNumber, msg.sender);
            lotterys[currentLotteryId].soldTickets = newTicketNumber;
        }
        lotterys[currentLotteryId].userTickets[msg.sender] = lotterys[currentLotteryId].userTickets[msg.sender] + numberOfTickets;
        emit purchasedTickets(msg.sender, numberOfTickets, ticketsPrice);
    }
    
    function pickWinner() external onlyOwnerOrDealer {
        require(lotterys[currentLotteryId].soldTickets > 0, "Sold Tickets is 0");
        pickingWinner = true;

        // Will revert if subscription is not set and funded.
        COORDINATOR.requestRandomWords(c_keyHash, c_subscriptionId, c_requestConfirmations, c_callbackGasLimit, c_numWords);
        emit numberRequested(msg.sender, block.number, currentLotteryId);
    }

    function fulfillRandomWords(uint256, uint256[] memory randomness) internal override {
        lastRandomNumber = randomness[0];
        payWinner();
    }

    function payWinner() internal {
        uint _currentLotteryId = currentLotteryId;
        uint256 index;
        if (lotterys[_currentLotteryId].soldTickets == 1) {
            index = 1;
        } else {
            index = (lastRandomNumber % lotterys[_currentLotteryId].soldTickets) + 1;
        }
        lotterys[_currentLotteryId].winner = lotterys[_currentLotteryId].tickets[index].addr;
        lotterys[_currentLotteryId].winningNumber = index;
        uint feeAmount = (ERC20(token).balanceOf(address(this)) * devFee) / 100;
        uint minerAmount = (ERC20(token).balanceOf(address(this)) * minerFee) / 100;
        uint lotteryAmount = (ERC20(token).balanceOf(address(this)) * lotteryFee) / 100;
        uint wonAmount =  ERC20(token).balanceOf(address(this)) - feeAmount - minerAmount - lotteryAmount;
        lotterys[_currentLotteryId].wonAmount = wonAmount;
        currentLotteryId++;
        ERC20(token).transfer(ownerAddr, feeAmount);
        ERC20(token).transfer(minerAddr, minerAmount);
        IMiner(minerAddr).lotteryPays(minerAmount);
        ERC20(token).transfer(lotterys[_currentLotteryId].winner, wonAmount);
        emit pickedWinner(lotterys[_currentLotteryId].winner, _currentLotteryId, lotterys[_currentLotteryId].winner, index, wonAmount);
        pickingWinner = false;
    }
   
    function getBalance() public view returns (uint) {
       return ERC20(token).balanceOf(address(this));
    }

    function getSoldTickets() public view returns (uint) {
        return lotterys[currentLotteryId].soldTickets;
    }

    function getUserTickets(address _userAddress) public view returns (uint) {
        return lotterys[currentLotteryId].userTickets[_userAddress];
    }

    function getPlayerByTicketId(uint _ticketId) public view returns (address) {
        return lotterys[currentLotteryId].tickets[_ticketId].addr;
    }

    function getWinnerByLotteryId(uint _lotteryId) public view returns (address) {
        return lotterys[_lotteryId].winner;
    }

    function getTicketPrice() public view returns (uint) {
        return ticketPrice;
    }

    // Chainlink Maintenance Tasks
    function setGasLimitPrice(uint32 _gasLimitPrice) public onlyOwner {
        c_callbackGasLimit = _gasLimitPrice;
    }
    function setSubscriptionId(uint64 _c_subscriptionId) public onlyOwner {
        c_subscriptionId = _c_subscriptionId;
    }
    function setVRFKeyHash(bytes32 _c_keyHash) public onlyOwner {
        c_keyHash = _c_keyHash;
    }
    
    // Miner Connection & Lottery Maintenance
    function setMinerAddress(address _minerAddr) public onlyOwner {
        minerAddr = _minerAddr;
    }
    function setDealerAddress(address _dealerAddr) public onlyOwner {
        dealerAddr = _dealerAddr;
    }
    function minerPays(uint _amount) public payable {
        require(msg.sender == minerAddr, "Only miner can run this");
        emit ReceivedFromMiner(msg.sender, _amount);
    }  
    function setTokenAddress(address _tokenAddr) public onlyOwner {
        token = _tokenAddr;
    }
    function setTicketPrice(uint _ticketPrice) public onlyOwnerOrDealer {
        ticketPrice = _ticketPrice;
        emit ticketPriceUpdated(_ticketPrice);
    }

    modifier onlyOwner() {
      require(msg.sender == ownerAddr, "Only owner can run this");
      _;
    }

    modifier onlyOwnerOrDealer() {
      require(msg.sender == dealerAddr || msg.sender == ownerAddr, "Only dealer or owner can run this");
      _;
    }
}