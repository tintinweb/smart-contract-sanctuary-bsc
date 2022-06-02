/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


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

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


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
}

// File: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol


pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// File: lottery.sol

/**
 * Lottery contract for Ascentpad
 */


pragma solidity ^0.8.7;





/**
 * The main lottery contract. It is constructed with an application.
 */
contract Lottery is VRFConsumerBaseV2 {

    // The address of the ascent token.
    address tokenContractAddress = 0x7A66eBFD6Ef9e74213119717A3d03758A4A5891e;

    // The participant structure to keep track of participants.
    struct PlayerIndex {
        uint256 idx;
        uint32 numberOfTickets;
    }

    // The current index;
    uint256 currentIndex;

    // The owner of the contract
    address owner;

    // The address mapping capturing the different players who have
    // participated so far in the lottery. We are setting this up
    // as a mapping to get O(1) access complexity.
    mapping(address => PlayerIndex) playerIndices;

    // The array of different player addresses so that we can iterate
    // later.
    address[] public players;

    // The opening time of the lottery, i.e. when the lottery begins,
    // in epoch time.
    uint256 public openingTime;

    // The end time of the lottery, i.e. when the lottery ends.
    uint256 public endTime;

    // The price of the ticket;
    uint256 public ticketPrice;

    // The number of winning slots
    uint32 public winningSlotNumber;

    // The final winner array
    address[] public winners;

    // The indicator that the random number generation has been
    // kicked off.
    bool randomNumbersGenerationKickedOff;

    // The maximum number of tickets per wallet.
    uint32 public maxNumberOfTicketsPerWallet;

    //////////////////////////////////////////////////
    // This section is initializing the needed
    // variables for chainlink
    //////////////////////////////////////////////////
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    // The chainlink subscription id
    uint64 s_subscriptionId;

    address vrfCoordinator;

    // Rinkeby LINK token contract. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    // TODO: Set this address correctly
    address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    // TODO: Get this value
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // The interface does not expose MAX_NUM_WORDS, so we have to put it here.
    uint32 public constant MAX_NUM_WORDS = 500;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    // TODO: Check this limit as well.
    uint32 callbackGasLimit = MAX_NUM_WORDS * 30000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    mapping(uint256 => uint256[]) public requestIdToRandomWords;
    uint256[] requestIdsInOrder;
    uint256 public s_requestId;
    address s_owner;

    // The value of calls that we will need to make to the vrf
    uint32 numberOfCallsToVrfNeeded;

    // End of chainlink variables.
    //////////////////////////////////////////////////

    constructor(
        uint256 _openingTime,
        uint256 _endTime,
        uint256 _ticketPrice,
        uint32 _winningSlotNumber,
        uint32 _maxNumberOfTicketsPerWallet,
        address _ascTokenContractAddress,
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _gasLane,
        address _linkTokenAddress,
        address _owner) VRFConsumerBaseV2(_vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
        tokenContractAddress = _ascTokenContractAddress;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        owner = _owner;
        currentIndex = 0;
        ticketPrice = _ticketPrice;
        openingTime = _openingTime;
        endTime = _endTime;
        keyHash = _gasLane;
        link = _linkTokenAddress;
        winningSlotNumber = _winningSlotNumber;
        require(_maxNumberOfTicketsPerWallet > 0);
        maxNumberOfTicketsPerWallet = _maxNumberOfTicketsPerWallet;
        require(winningSlotNumber <= MAX_NUM_WORDS);
        s_subscriptionId = _subscriptionId;
        randomNumbersGenerationKickedOff = false;
        uint32 maxNumWords = MAX_NUM_WORDS;
        uint32 div = winningSlotNumber/maxNumWords;
        uint32 rem = winningSlotNumber % maxNumWords;
        numberOfCallsToVrfNeeded =  div + (rem > 0 ? 1 : 0);
    }

    // The modifier to let people enter the lottery only while
    // the lottery is open.
    modifier onlyWhileOpen() {
        require(isOpen());
        _;
    }

    // The modifier to check that the address of the
    modifier didNotMaxOutTicketBuy() {
        require(playerIndices[msg.sender].numberOfTickets < maxNumberOfTicketsPerWallet);
        _;
    }

    // The function to figure out if the lottery is still open.
    function isOpen() public view returns (bool) {
        return (block.timestamp >= openingTime) && (block.timestamp < endTime);
    }

    // The event emitted whenever a ticket is being bought.
    event TicketBought(address indexed user, uint256 timestamp);

    // Random number generation finished
    event RandomNumberGenerationFinished(uint256 timestamp);

    // The event emitted for each user after the lottery is completed.
    event WinnerEvent(address indexed user);

    /**
     * The function to buy a ticket for the lottery
     */
    function buyTicket()
        public
        payable
        onlyWhileOpen
        didNotMaxOutTicketBuy
        returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);
        address from_address = msg.sender;
        token.transferFrom(from_address, address(this), ticketPrice);
        currentIndex = currentIndex + 1;
        if (playerIndices[from_address].numberOfTickets == 0) {
            PlayerIndex memory playerIndex = PlayerIndex(currentIndex, 1);
            playerIndices[from_address] = playerIndex;
        } else {
            playerIndices[from_address].numberOfTickets++;
        }
        players.push(from_address);
        emit TicketBought(from_address, block.timestamp);
        return true;
    }

    // The function for the owner to withdraw their tokens.
    function withdrawTokens(uint256 amount)
        public
        payable
        onlyOwner
        returns (bool) {
        IERC20 token = IERC20(tokenContractAddress);
        if(token.balanceOf(address(this)) < amount) {
            revert("Balance of this contract is less then amount of withdraw");
        }
        token.transfer(owner, amount);
        return true;
    }

    // Ensuring that only the owner is able to call a specific function
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // The modifier to check that the lottery is finished to check the
    modifier afterFinished () {
        require (block.timestamp >= endTime);
        _;
    }

    // This function generates the needed random numbers
    // before the calculateWinners function can be called.
    function generateNeededRandomNumbers()
        public
        afterFinished
        onlyOwner {
        require(randomNumbersGenerationKickedOff == false);
        randomNumbersGenerationKickedOff = true;
        uint32 maxNumWords = MAX_NUM_WORDS;
        uint32 rem = winningSlotNumber % maxNumWords;
        uint32 i = 0;
        for(i = 0; i < numberOfCallsToVrfNeeded; i++) {
            uint32 numWords = ((i == numberOfCallsToVrfNeeded - 1) && (rem != 0)) ? rem : maxNumWords;
            COORDINATOR.requestRandomWords(
                keyHash,
                s_subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                numWords);
        }
    }

    // overriding the requested method by chainlink to fulfill
    // the random numbers.
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
        ) internal override {
        requestIdToRandomWords[requestId] = randomWords;
        requestIdsInOrder.push(requestId);
        if (requestIdsInOrder.length == numberOfCallsToVrfNeeded) {
            emit RandomNumberGenerationFinished(block.timestamp);
        }
    }

    // This is a modifier ensuring that we are only calling a
    // specific function after the call to all random numbers
    // is finished.
    modifier afterRandomNumbersAreGenerated() {
        require(requestIdsInOrder.length == numberOfCallsToVrfNeeded);
        _;
    }

    // After the lottery period is done, the winners can be calculated
    // and finalized.
    function calculateWinners()
        public
        onlyOwner
        afterFinished
        afterRandomNumbersAreGenerated {
        require(randomNumbersGenerationKickedOff);
        require(winners.length == 0);
        if (players.length <= winningSlotNumber) {
            winners = players;
        } else {
            _fillWinnerArrayFromPlayers();
        }
        _announceWinners();
    }

    function _announceWinners()
        private
        afterFinished {
        require (winners.length == (players.length <= winningSlotNumber ? players.length : winningSlotNumber));
        uint32 i;
        for (i = 0; i < winners.length; i++) {
            emit WinnerEvent(winners[i]);
        }
    }

    struct UniqueHashIndex {
        uint256 idx;
        bool isValue;
    }

    mapping(uint256 => UniqueHashIndex) hash;

    // The function to fill the array of winners from players.
    function _fillWinnerArrayFromPlayers()
        private {
        require(players.length > winningSlotNumber); // Just in case
        uint256[] memory randomNumbers = new uint256[](winningSlotNumber);
        uint256 i;
        uint256 j;
        uint256 randomNumbersCurrentIndex = 0;
        for (i = 0; i < requestIdsInOrder.length; i++) {
            uint256[] memory randomNumbersForRequestId = requestIdToRandomWords[requestIdsInOrder[i]];
            for (j = 0; j < randomNumbersForRequestId.length; j++) {
                randomNumbers[randomNumbersCurrentIndex] = randomNumbersForRequestId[j];
                randomNumbersCurrentIndex = randomNumbersCurrentIndex + 1;
            }
        }
        require(randomNumbers.length == winningSlotNumber); // Sanity check
        for (i = 0; i < winningSlotNumber; i++) {
            j = randomNumbers[i] % (players.length - i);
            uint256 nextWinnerIdx;
            if (hash[j].isValue) {
                nextWinnerIdx = hash[j].idx;
                hash[j].idx = 0;
                hash[j].isValue = false;
            } else {
                nextWinnerIdx = j;
            }
            winners.push(players[nextWinnerIdx]);
            if (j > i) {
                if (hash[i].isValue) {
                    hash[j] = hash[i];
                    hash[i].idx = 0;
                    hash[i].isValue = false;
                } else {
                    hash[j].idx = i;
                    hash[j].isValue = true;
                }
            }
        }
    }

    /**
     * The modifier to ensure that the winners have been completely added
     * by the randomizer.
     */
    modifier afterWinnerDeterminationComplete() {
        require(winners.length >= winningSlotNumber);
        _;
    }

    function addOtherWinners(address winnerAddress)
        public
        onlyOwner
        afterWinnerDeterminationComplete {
        winners.push(winnerAddress);
        winningSlotNumber++;
    }

    function isWinner(address addressToCheck)
        public
        view
        afterWinnerDeterminationComplete
        returns (bool) {
        uint32 i;
        for (i = 0; i < winners.length; i++) {
            if (addressToCheck == winners[i]) {
                return true;
            }
        }
        return false;
    }
}