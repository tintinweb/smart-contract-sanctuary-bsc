/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

/// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.8.7;

// ******************************** //
// ** Liquiddery® Games presents ** //
// ******************************** //
// ****** "BITCOIN LOTTERY" ******* //
// ******************************** //
// ** Read the Whitepaper below! ** //
// ******************************** //
// **** Play on liquiddery.com **** //
// ******************************** //

/*

WHITEPAPER

(1) PURPOSE OF THE GAME

Prove that blockchain games are FUN.


(2) Contract explanations

Rules of the "Bitcoin Lottery”.
The rules are simple.

1) Imagine a game with rounds.
2) During an active round users may buy tickets.
3) 1 ticket costs 50 BUSD.
4) Each user may buy up to 20 tickets per round,
   even in several transactions, if desired.
5) "Gifted tickets": Users may not only buy up to
   20 tickets for themselves, but also for other
   users (the limit of 20 tickets per user still
   applies).
6) The BUSD are collected in a pool.
7) As soon as the pool has enough BUSD to buy a
   Bitcoin (plus a 10% dev and maintenance fee),
   the round ends.
8) The winner is determined (within 1 minute),
   the Bitcoin is sent to the winner automatically.
9) A new round starts immediately.


There is only 1 prize per round: 1 Bitcoin.

Note: As the contratc operates on BNB Smart Chain,
it uses the "Binance-Peg BTCB Token" ("BTCB"),
which is the Bitcoin on BNB Smart Chain.
Address: 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c
Link: https://www.binance.com/en/price/bitcoin-bep2

CHANCE TO WIN:
As the Bitcoin price might chance during the game,
the chance to win depends on the Bitcoin price.
To calculate the chances, here's a table.

Bitcoin price (price + 10% fee) -- chance
40,000 BUSD (44,000) -- 50:44,000 = 1:880
35,000 BUSD (38,500) -- 50:38,500 = 1:770
30,000 BUSD (33,000) -- 50:33,000 = 1:660
25,000 BUSD (27,500) -- 50:27,500 = 1:550
20,000 BUSD (22,000) -- 50:22,000 = 1:440
15,000 BUSD (16,500) -- 50:16,500 = 1:330
10,000 BUSD (11,000) -- 50:11,000 = 1:220

Observation: The lower the Bitcoin price,
the higher the chances for each ticket to win.


(3) Fallback / Security implementations

A. Be aware, there is no 100% guarantee
a smart contract will do what it should.

B. The design of the "rounds", a low Ticket price and
fallback functions (for foreseeable events) shall help
preventing from losses. Nevertheless, unforeseen events
might happen and the BUSD might be lost.

C. FALLBACK #1
If the oracle fails to deliver a random number,
the prize cannot be distributed. To restore the sent
BUSD, there is a function available (that the "owner"
may trigger) to emergency end the current round -
in that case, all sent (!) BUSD are made available
to be claimed back by the participants, automatically.

D. FALLBACK #2
If people send tokens to the contract without using
the defined functions, they might be stuck in the
contract forever. To prevent from tokens being stuck,
the "owner" has the right to sent tokens back to the
sender.

E. ADMIN RIGHTS
This contract has an "owner" / admin, with special
rights as described above: Triggering fallback
functions or an emergency exit, or send back tokens
that have been send to this contract accidentally.

The owner does NOT have the right to withdraw any
of the participants' BUSD tokens. Therefore, the
funds are safe from being stolen by the "owner" -
no matter what.

In case of reported misuse of the contract that is
obviously leading to unintended behavior, the "owner"
may "emergency end" the current round.
In this case, all sent (!) BUSD are made available
to be claimed back by the participants, automatically.

All participating addresses have equal rights.


(4) NOTES ON GAMBLING

Despite the aim of this contract is FUN, using this
contract might be considered gambling (as there is
a prize involved), so please read and understand
the following notes.

1. It is the user's sole responsibility to inquire
about the existing laws and regulations of the given
jurisdiction for "online gambling".

2. Always make sure you treat gambling as a form of
entertainment and not as a source of income. Never
bet more than you can afford to lose or while being
in a state and make sure you take regular breaks
from gambling.

3. Playing to a degree that starts to compromise,
disrupt or damage family, personal or recreational
pursuits, often entails betting beyond your means
and sometimes feeling an uncontrollable impulse to
gamble. Always make sure to treat gambling as a form
of entertainment and not a source of income.

4. If you think that you have started to spend more
money than you can afford, or gaming starts
interfering with your normal daily routines, you may
contact any of the following organisations for
consultation and support:
Gambling Anonymous / GamCare / Gambling Therapy
(or please find other organizations in your country).

5. Feel the need to be apart for a while?
The contract will fully support you. You can set
a Cooling-Off period for your address for a day,
a week or a month. You can tell the contract to
block you for a certain amount of days. Taking
regular breaks is crucial for responsible gamblers.

********************************
Made with ❤️ by the REX Community
********************************

***********************************
THANKS FOR USING REX DEFI PROTOCOLS
***********************************

***************************************
coinmarketcap.com/currencies/rex-token/
***************************************

*/


/// ********************************
/// INTERFACES
/// ********************************

interface VRFCoordinatorV2Interface {
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
}

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

interface IUniswapV2Router02 {
  function getAmountsIn(uint amountOut, address[] calldata path)
      external view returns (uint[] memory amounts);

  function swapTokensForExactTokens(
      uint amountOut,
      uint amountInMax,
      address[] calldata path,
      address to,
      uint deadline
    ) external returns (uint[] memory amounts);
}

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

  /// rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  /// proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  /// the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

/// ********************************
/// BEP20 INTERFACE
/// ********************************

interface IBEP20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/// ********************************
/// REENTRANCY CONTRACT
/// ********************************

/// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    /// Booleans are more expensive than uint256 or any type that takes up a full
    /// word because each write operation emits an extra SLOAD to first read the
    /// slot's contents, replace the bits taken up by the boolean, and then write
    /// back. This is the compiler's defense against contract upgrades and
    /// pointer aliasing, and it cannot be disabled.

    /// The values being non-zero value makes deployment a bit more expensive,
    /// but in exchange the refund on every call to nonReentrant will be lower in
    /// amount. Since refunds are capped to a percentage of the total
    /// transaction's gas, it is best to keep them low in cases like this one, to
    /// increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        /// On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        /// Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        /// By storing the original value once again, a refund is triggered (see
        /// https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/// ********************************
/// LIBRARIES
/// ********************************

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "LIQUIDDERY: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "LIQUIDDERY: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "LIQUIDDERY: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "LIQUIDDERY: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "LIQUIDDERY: modulo by zero");
        return a % b;
    }
}

/// ********************************
/// MAIN CONTRACT
/// ********************************

contract Liquiddery is VRFConsumerBaseV2, ConfirmedOwner, ReentrancyGuard {

    using SafeMath for uint256;

    /// CHAINLINK imports
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    struct RequestStatus {
        bool fulfilled;   /// whether the request has been successfully fulfilled
        bool exists;      /// whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests;
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint16 requestConfirmations = 20;
    uint32 callbackGasLimit = 100000;
    uint32 numWords = 1;
    /// see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;


    IUniswapV2Router02 public constant UNISWAP_ROUTER = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20 public BUSD_TOKEN;                   /// Binance Dollar
    IBEP20 public BTCB_TOKEN;                   /// Binance Bitcoin
    address constant busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant btcb_address = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address constant maintenance_address = 0x701e10b0c7B41De66F5eAF45524c47EA91d56e7B;
    address private lastBuyer;                  /// track lastBuyer details

    event TicketsSold(address indexed sender, uint32 indexed round, uint32 tickets);
    event CashbackClaimed(address receiver, uint256 amount);
    event RoundDistributed(uint32 round);
    event GameHasEnded(uint32 round);
    event BitcoinBought(uint32 round, uint256 busdSpent);

    bool public saleOpen = true;                /// prevent from participation while waiting for oracle
    bool public endAfterRound = false;          /// if set to true, the game stops after the round, cannot be undone

    uint32 constant MAX_TICKETS = 20;           /// limitation: max tickets to buy per address
    uint32 public currentRound;                 /// starts with round 0
    uint32 private lastNumber;                  /// track lastBuyer details
    uint32 private lastNumberTotal;             /// track lastBuyer details

    uint256 private lastTime;                   /// track lastBuyer details
    uint256 constant TICKET_PRICE = 50E18;      /// 50 BUSD
    uint256 constant FULL_BTCB = uint256(1E18); /// a constant for 1 Bitcoin with decimals
    uint256 public totalUnclaimedBUSD;          /// keep track of unclaimed BUSD in the contract (just for cases of emergencyEndRound)

    mapping(uint32 => uint32) public soldTickets;             /// round -> tickets sold // stored for each round
    mapping(uint32 => uint256) private requestIdOfRound;      /// round -> [Chainlink] requestId // stored for each round
    mapping(uint32 => bool) public roundIsDistributed;        /// store info for each round

    mapping(address => uint256) private addrBlockedUntilTime; /// address -> blocktime (until a user has blocked themselves)
    mapping(address => uint256) public cashbackBusdAvail;     /// amount of BUSD an address may claim
    mapping(address => uint256) public cashbackBusdRecvd;     /// amount of BUSD an address has claimed
    mapping(address => uint256) public addrTotalSpentBusd;    /// to read BUSD participation from outside later
    mapping(address => uint256) public addrTotalBitcoinRec;   /// to read BTCB wins from outside later

    mapping(address => mapping(uint32 => uint32)) public addrTicketsRound;  /// address->round->tickets
    mapping(uint32 => mapping(uint32 => address)) public participants;      /// round -> entry number -> address
    mapping(uint32 => uint32) public randomNumber;                          /// round -> randomNumber (1 number, 1 winner)
    mapping(uint32 => uint256) public roundStartTimes;                      /// round -> start time

    modifier notContract() {
        require(_notContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    /// @notice CHAINLINK import
    /// @notice HARDCODED FOR BSC
    /// @notice COORDINATOR: 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE
    constructor(
        uint64 subscriptionId
    )
        VRFConsumerBaseV2(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0xc587d9053cd1118f25F645F9E08BB98c9712A4EE
        );
        s_subscriptionId = subscriptionId;
        BUSD_TOKEN = IBEP20(busd_address);
        BTCB_TOKEN = IBEP20(btcb_address);
        roundStartTimes[currentRound] = block.timestamp;
    }

    /// @notice An external function for a participant to buy 1 to MAX_TICKETS Tickets
    /// @dev User must approve BUSD first
    /// @param noOfTickets The desired no. of Tickets
    function buyTickets(uint32 noOfTickets, address receiver)
        external notContract nonReentrant
    {
        require(saleOpen == true, "LIQUIDDERY: Sale not active");
        require(noOfTickets > 0, "LIQUIDDERY: Invalid ticket amount");
        require(noOfTickets <= (MAX_TICKETS - addrTicketsRound[msg.sender][currentRound]), "LIQUIDDERY: Max tickets exceeded");
        require(isBlocked(msg.sender) == false, "LIQUIDDERY: You blocked yourself");
        require(receiver != address(0) && _notContract(receiver), "LIQUIDDERY: Invalid receiver");
        require(noOfTickets <= (MAX_TICKETS - addrTicketsRound[receiver][currentRound]), "LIQUIDDERY: Max tickets exceeded");

        /// Store the bought tickets for this address for this round (for MAX_TICKETS check)
        addrTicketsRound[receiver][currentRound] += noOfTickets;

        /// withdraw BUSD from user to contract
        uint256 _busd_amount = TICKET_PRICE.mul(uint256(noOfTickets));
        require(BUSD_TOKEN.transferFrom(msg.sender, address(this), _busd_amount), "LIQUIDDERY: Transfer of BUSD failed.");

        /// save the participant's address in the participants list
        /// 1 entry for each bought ticket
        /// offset: i = soldTickets[currentRound]
        uint32 j = soldTickets[currentRound] + noOfTickets;
        for (uint32 i = soldTickets[currentRound]; i < j; i++) {
            participants[currentRound][i] = receiver;
        }

        soldTickets[currentRound] += noOfTickets;         /// update soldTickets[currentRound]
        addrTotalSpentBusd[msg.sender] += _busd_amount;   /// save amount for further use in the ecosystem

        /// fun stats
        lastTime = block.timestamp;
        lastBuyer = receiver;
        lastNumber = noOfTickets;
        lastNumberTotal = addrTicketsRound[receiver][currentRound];

        /// check whether there is enough money in the pool to end the round
        /// path order: [BUSD, BTCB]
        uint256 pool = TICKET_PRICE.mul(uint256(soldTickets[currentRound]));
        uint256[] memory busdNeededForBtc;
        uint256 busdNeededPlusFee;
        address[] memory path = new address[](2);
            path[0] = busd_address;
            path[1] = btcb_address;
        busdNeededForBtc = UNISWAP_ROUTER.getAmountsIn(FULL_BTCB, path);    /// get "exact" No of BUSD needed
        busdNeededPlusFee = busdNeededForBtc[0].mul(11).div(10);            /// add 10% dev/maintenance

        if (pool >= busdNeededPlusFee) {
            saleOpen = false;

            uint256 busdNeededForBtcX = busdNeededForBtc[0].add( busdNeededForBtc[0].div(500) );   /// add 0.2% for safety = "maxAmountIn"
            uint256[] memory busdSpent;

            BUSD_TOKEN.approve(address(UNISWAP_ROUTER), busdNeededForBtcX);  /// allow router to withdraw BUSD ("maxAmountIn")
            busdSpent = UNISWAP_ROUTER.swapTokensForExactTokens(             /// swap & save spent BUSD (should equal "busdNeededForBtc")
                FULL_BTCB,                                                   /// 1 full Bitcoin, 18 decimals
                busdNeededForBtcX,                                           /// use busdNeededForBtcX instead of busdNeededForBtc
                path,
                address(this),
                block.timestamp + 2 hours
            );
            requestIdOfRound[currentRound] = requestRandomWords();              /// ask ORACLE & save returned ID in "requestIdOfRound"

            emit BitcoinBought(currentRound, busdSpent[0]);
        }

        emit TicketsSold(msg.sender, currentRound, noOfTickets);
    }

    /// @notice An external function to trigger the Bitcoin distribution, starts new round
    /// @dev Can only be triggered by an address, not a contract
    function distributeRound() external notContract nonReentrant {
        require(oracleReady() == true, "LIQUIDDERY: Wait for Oracle");
        require(roundIsDistributed[currentRound] == false, "LIQUIDDERY: Already distributed");

        /// fetch random number from s_requests, modulo to the amounts of sold tickets, save number
        randomNumber[currentRound] = uint32(s_requests[requestIdOfRound[currentRound]].randomWords[0] % uint256(soldTickets[currentRound]));

        /// send Bitcoin to winner
        address winner = participants[currentRound][randomNumber[currentRound]];
        BTCB_TOKEN.transfer(winner, FULL_BTCB);
        addrTotalBitcoinRec[winner] += FULL_BTCB;

        /// send remaining BUSD to dev/maintenance address
        /// (minus totalUnclaimedBUSD from emergencyEndRound)
        /// So, all BUSD being sent to the contract without using "buyTickets" will be also withdrawn
        uint256 remainingBusd = BUSD_TOKEN.balanceOf(address(this)).sub(totalUnclaimedBUSD);
        BUSD_TOKEN.transfer(maintenance_address, remainingBusd);

        /// start next round and reset variables
        roundIsDistributed[currentRound] = true;
        emit RoundDistributed(currentRound);
        currentRound += 1;
        roundStartTimes[currentRound] = block.timestamp;
        lastTime = 0;
        lastBuyer = address(0);
        lastNumber = 0;
        lastNumberTotal = 0;

        /// close the game after the round?
        if (!endAfterRound) { saleOpen = true; }
    }

    /// @notice An external function for a participant to end the round, if the target is reached
    function endRoundPriceChange()
        external notContract nonReentrant
    {
        require(saleOpen == true, "LIQUIDDERY: Sale not active");
        require(getTargetReached() == true, "LIQUIDDERY: Target not reached");

        saleOpen = false;

        uint256[] memory busdNeededForBtc;
        uint256 busdNeededPlusFee;
        address[] memory path = new address[](2);
            path[0] = busd_address;
            path[1] = btcb_address;
        busdNeededForBtc = UNISWAP_ROUTER.getAmountsIn(FULL_BTCB, path);    /// get "exact" No of BUSD needed
        busdNeededPlusFee = busdNeededForBtc[0].mul(11).div(10);            /// add 10% dev/maintenance

        uint256 busdNeededForBtcX = busdNeededForBtc[0].add( busdNeededForBtc[0].div(500) );   /// add 0.2% for safety = "maxAmountIn"
        uint256[] memory busdSpent;

        BUSD_TOKEN.approve(address(UNISWAP_ROUTER), busdNeededForBtcX);  /// allow router to withdraw BUSD ("maxAmountIn")
        busdSpent = UNISWAP_ROUTER.swapTokensForExactTokens(             /// swap & save spent BUSD (should equal "busdNeededForBtc")
            FULL_BTCB,                                                   /// 1 full Bitcoin, 18 decimals
            busdNeededForBtcX,                                           /// use busdNeededForBtcX instead of busdNeededForBtc
            path,
            address(this),
            block.timestamp + 2 hours
        );
        requestIdOfRound[currentRound] = requestRandomWords();              /// ask ORACLE & save returned ID in "requestIdOfRound"

        emit BitcoinBought(currentRound, busdSpent[0]);
    }

    /// @notice Emergency function to end the current round (onlyOwner),
    /// @notice no more buys, make BUSD from ticket-buys claimable back, game ends
    function emergencyEndRound() external onlyOwner {
        /// make the BUSD claimable back for each soldTickets of the round
        for (uint32 i = 0; i < soldTickets[currentRound]; i++) {
            cashbackBusdAvail[ participants[currentRound][i] ] += TICKET_PRICE;
        }
        /// keep track of the claim-backs
        totalUnclaimedBUSD += TICKET_PRICE.mul(uint256(soldTickets[currentRound]));

        emit GameHasEnded(currentRound);

        roundIsDistributed[currentRound] = true;
        currentRound += 1;
        endAfterRound = true;
        saleOpen = false;
    }

    /// @notice Enables participants to block themselves for 1 to 365 days.
    /// @notice Not possible to change the blocked time, if already blocked.
    function blockMeForXDays(uint256 _days) external notContract returns (bool) {
        require(isBlocked(msg.sender) == false, "LIQUIDDERY: You are blocked already");
        require(_days > 0 && _days <= 365, "LIQUIDDERY: Invalid days");

        addrBlockedUntilTime[msg.sender] = block.timestamp + ((1 days)*_days);
        return true;
    }

    /// @notice Allows an address to claim all its "cashbackBusdAvail" (in case there was an emergencyEndRound)
    /// @return claimed BUSD amount that has been claimed successfully
    function claimCashbackBusd()
        external notContract nonReentrant returns (uint256 claimed)
    {
        require(cashbackBusdAvail[msg.sender] > 0, "LIQUIDDERY: No BUSD to claim");  /// check positive balance
        claimed = cashbackBusdAvail[msg.sender];                                     /// get amount
        cashbackBusdAvail[msg.sender] = 0;                                           /// reset to zero
        cashbackBusdRecvd[msg.sender] += claimed;                                    /// add to "already received BUSD"
        totalUnclaimedBUSD -= claimed;                                               /// keep track for emergencyEndRound
        BUSD_TOKEN.transfer(msg.sender, claimed);                                    /// transfer BUSD to claimer
        emit CashbackClaimed(msg.sender, claimed);                                   /// track
    }

    /// @notice CHAINLINK import
    function requestRandomWords() private returns (uint256 requestId)
    {
        /// Will revert if ORACLE subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    /// @notice A function to save the received random numbers
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    /// @notice An external view function to check whether the ORACLE request has been fulfilled
    function getRequestStatus(
        uint32 _round
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[requestIdOfRound[_round]].exists, "request not found");
        RequestStatus memory request = s_requests[requestIdOfRound[_round]];
        return (request.fulfilled, request.randomWords);
    }

    /// @notice An external view function to get the current status
    function getCurrentPoolAndTarget() public view returns (uint256 pool, uint256 target) {
        pool = TICKET_PRICE.mul(uint256(soldTickets[currentRound]));
        uint256[] memory temp;
        address[] memory path = new address[](2);
            path[0] = busd_address;
            path[1] = btcb_address;
        temp = UNISWAP_ROUTER.getAmountsIn(FULL_BTCB, path);
        target = temp[0].mul(11).div(10);
    }

    /// @notice An external view function to get the current status
    function getTargetReached() public view returns (bool reached) {
        uint256 pool = TICKET_PRICE.mul(uint256(soldTickets[currentRound]));
        uint256[] memory temp;
        address[] memory path = new address[](2);
            path[0] = busd_address;
            path[1] = btcb_address;
        temp = UNISWAP_ROUTER.getAmountsIn(FULL_BTCB, path);
        uint256 target = temp[0].mul(11).div(10);
        reached = pool >= target;
    }

    /// @notice An external view function to read the round's stats
    function getStatsOfRound(uint32 _round) external view returns (
        address winner,
        uint32 winningTicket,
        uint256 totalTickets
    ) {
        winner = _round < currentRound ? participants[_round][randomNumber[_round]] : address(0);
        winningTicket = _round < currentRound ? randomNumber[_round] : 0;
        totalTickets = soldTickets[_round];
    }

    function getRoundStartTime() external view returns (uint256) {
        return roundStartTimes[currentRound];
    }

    function getLastBuy() external view returns (uint256, address, uint32, uint32) {
        return (lastTime, lastBuyer, lastNumber, lastNumberTotal);
    }

    /// @notice A public function to check whether the ORACLE has answered (in the current round)
    /// @return true if oracle has answered
    function oracleReady() public view returns (bool) {
        return saleOpen == false && s_requests[requestIdOfRound[currentRound]].fulfilled == true;
    }

    /// @notice A public function to check whether an address is currently blocked (has blocked itself)
    function isBlocked(address _who) public view returns (bool) {
        return addrBlockedUntilTime[_who] >= block.timestamp;
    }

    /// An external function for the deployer to prevent the contract from starting a new round after the current round
    function stopAfterRound() external onlyOwner {
        endAfterRound = true;
    }

    /// @notice An internal function to check for contracts
    function _notContract(address _addr) private view returns (bool) {
        uint32 size; assembly { size := extcodesize(_addr) } return (size == 0); }

    /// @notice A function for the owner allowing sending tokens from the contract to receivers
    /// @notice Example: Tokens that have accidentially been sent to the contract, which happens a lot
    /// @param token The token's address to withdraw (BUSD not allowed)
    /// @param receiver The receiver
    /// @param amount Amount of tokens (must be > 0)
    function withdrawTokensToAddr(address token, address receiver, uint256 amount) external onlyOwner {
        require(amount > 0, "LIQUIDDERY: Zero tokens requested");
        require(token != address(BUSD_TOKEN), "LIQUIDDERY: BUSD not allowed");
        IBEP20 Token = IBEP20(token);                         /// get Token
        uint256 _tokenBal = Token.balanceOf(address(this));   /// get available token balance of this contract
        require(amount <= _tokenBal, "LIQUIDDERY: Not enough tokens");
        Token.transfer(receiver, amount);
    }
}