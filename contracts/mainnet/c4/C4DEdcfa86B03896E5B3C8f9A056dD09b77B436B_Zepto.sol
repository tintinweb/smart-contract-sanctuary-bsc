// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./LotteryWinner.sol";

contract Zepto is LotteryWinner {
    address payable private _team;

    uint256 private _prizePool;
    address payable private _winner;
    uint256 private _lastClick = 0;

    uint256 private _price;
    uint256 private _feeTeam; // /10000
    uint256 private _feeAffiliation; // /10000
    uint8 private _indexFiftyWinners = 0;

    uint256 private _ticketsSold;
    address[51] private _fiftyWinners;
    address[] private _lotteryWinners;

    bool private _isAlreadyIn;

    uint256 private _window;

    event Click(
        address indexed bidder,
        address indexed referrer,
        uint256 blockNumber
    );

    constructor(
        uint256 price_,
        uint256 feeTeam_,
        uint256 feeAffiliation_,
        uint256 window_,
        uint64 sId,
        address vrfCoordinator_,
        bytes32 keyHash_
    ) payable LotteryWinner(sId, vrfCoordinator_, keyHash_) {
        _team = payable(msg.sender);
        _winner = payable(msg.sender);
        _price = price_;
        _feeTeam = feeTeam_;
        _feeAffiliation = feeAffiliation_;
        _window = window_;
    }

    receive() external payable {
        click(address(0));
    }

    fallback() external payable {
        click(address(0));
    }

    modifier reentrancyGuard() {
        require(!_isAlreadyIn, "reentrancyGuard");
        _isAlreadyIn = true;
        _;
        _isAlreadyIn = false;
    }

    function startGame() public payable {
        require(msg.value >= _price * 10, "invalid price");
        require(_lastClick == 0, "Game already started !");
        _lastClick = block.number;
    }

    function prizePool() public view returns (uint256) {
        return _prizePool;
    }

    function winner() public view returns (address) {
        return _winner;
    }

    function lastClick() public view returns (uint256) {
        return _lastClick;
    }

    function price() public view returns (uint256) {
        return _price;
    }

    function feeAffiliation() public view returns (uint256) {
        return _feeAffiliation;
    }

    function feeTeam() public view returns (uint256) {
        return _feeTeam;
    }

    function indexFiftyWinners() public view returns (uint256) {
        return _indexFiftyWinners;
    }

    function ticketsSold() public view returns (uint256) {
        return _ticketsSold;
    }

    function fiftyWinners() public view returns (address[51] memory) {
        return _fiftyWinners;
    }

    function lotteryWinners() public view returns (address[] memory) {
        return _lotteryWinners;
    }

    function window() public view returns (uint256) {
        return _window;
    }

    function topFiftyParticipants() public view returns (uint256 count) {
        for (uint256 i; i < _fiftyWinners.length; i++) {
            if (_fiftyWinners[i] != address(0)) {
                count++;
            }
        }
    }

    function topFiftyWinners() public view returns (address[] memory winners) {
        uint256 _counter;
        for (uint256 i; i < _fiftyWinners.length; i++) {
            if (_fiftyWinners[i] != address(0)) {
                winners[_counter] = _fiftyWinners[i];
                _counter++;
            }
        }
    }

    function lotteryTicketsSold() public view returns (uint256) {
        return _lotteryWinners.length;
    }

    function remainingTime() public view returns (uint256) {
        if (_lastClick + _window > block.number) {
            return _lastClick + _window - block.number;
        } else {
            return 0;
        }
    }

    function click(address _referrer) public payable reentrancyGuard {
        uint256 _amount = msg.value;
        require(_amount >= _price, "Too low amount");
        require(remainingTime() > 0, "Game is closed");

        _winner = payable(msg.sender);
        _lastClick = block.number;

        if (_referrer != address(0)) {
            payable(_referrer).send((_amount * _feeAffiliation) / 10000);
        }
        // add to 50+ winners
        _indexFiftyWinners = _indexFiftyWinners == 50
            ? 0
            : _indexFiftyWinners + 1;
        _fiftyWinners[_indexFiftyWinners] = payable(msg.sender);
        // add to lottery
        _lotteryWinners.push(payable(msg.sender));

        _team.send((_amount * _feeTeam) / 10000);
        _ticketsSold++;
        emit Click(msg.sender, _referrer, block.number);
    }

    function payWinner() external reentrancyGuard {
        require(block.number > _lastClick + _window, "Game window is not over");
        require(_lastClick > 0, "Game is not started");

        // Sets final amount of the prize pool
        _prizePool = address(this).balance;

        // Pay top 50 winners
        // 0,6% per winner -> 30% total
        uint256 topFiftyPrize = (_prizePool * 6) / 1000;
        for (uint256 index = 0; index < 50; index++) {
            if (_fiftyWinners[index] != address(0)) {
                payable(_fiftyWinners[index]).send(topFiftyPrize);
            }
        }

        // Determine lottery winner
        // 20% total
        require(requestSubmitted == 0, "no you don't, you dirty goblin");
        requestRandomWords(_lotteryWinners.length);

        // Pay grand prize winner
        _winner.send(address(this).balance - (_prizePool / 5));
    }

    function payLotteryWinner() external {
        require(winningTicketPlusOne != 0, "no winner yet");

        uint256 lotteryWinner = winningTicketPlusOne - 1;
        payable(_lotteryWinners[lotteryWinner]).send(_prizePool / 5);
    }

    function rngFailsafe() external {
        // Approximatley a month's worth of blocks (3 sec block time)
        uint256 nbBlockPerMonth = 30 days;
        require(requestSubmitted + nbBlockPerMonth < block.number, "not yet");

        requestRandomWords(_lotteryWinners.length);
    }

    function winnerSaveFunds(address token, uint256 amount) external {
        require(block.number > _lastClick + _window, "Game window is not over");

        // Calls transfer() on token contract
        // this enables winner to claim any BEP-20 tokens
        // that were mistakenly sent to the contract
        token.call(abi.encodeWithSelector(0xa9059cbb, _winner, amount));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

// create subscription, set consumer and fund it
// https://docs.chain.link/docs/get-a-random-number/
// https://vrf.chain.link/bsc/new

contract LotteryWinner is VRFConsumerBaseV2 {
    // MUST be passed in constructor!
    VRFCoordinatorV2Interface public COORDINATOR;

    // Your subscription ID.
    // MUST be passed in constructor!
    uint64 public s_subscriptionId;

    // BSC coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 public keyHash;

    uint32 public callbackGasLimit = 100_069; // so funny..

    // The default is 3, but you can set this higher.
    uint16 public requestConfirmations = 12;

    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 public numWords = 1;

    uint256 public s_randomWord;
    uint256 public s_requestId;

    // For ticketing system
    uint256 public requestSubmitted;
    uint256 public nbTickets;
    uint256 public winningTicketPlusOne;

    constructor(uint64 subscriptionId, address vrfCoordinator_, bytes32 keyHash_) VRFConsumerBaseV2(vrfCoordinator_) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
        s_subscriptionId = subscriptionId;
        keyHash = keyHash_;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords(uint256 nbTickets_) internal {
        requestSubmitted = block.number;
        nbTickets = nbTickets_;

        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        require(requestId == s_requestId, "stranger danger");
        s_randomWord = randomWords[0];
        uint256 winningTicket = randomWords[0] % nbTickets;

        // add one to know if initialized but later substract it
        winningTicketPlusOne = winningTicket + 1;
    }
}

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