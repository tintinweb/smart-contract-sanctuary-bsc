/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

/// SPDX-License-Identifier: RXFNDTN

pragma solidity ^0.8.7;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░██████╗░░░███████╗░░██╗░░░██╗░░ //
// ░░██╔══██╗░░██╔════╝░░╚██╗░██╔╝░░ //
// ░░██████╔╝░░█████╗░░░░░╚████╔╝░░░ //
// ░░██╔══██╗░░██╔══╝░░░░░██╔═██╗░░░ //
// ░░██║░░██║░░███████╗░░██╔╝░░██╗░░ //
// ░░╚═╝░░╚═╝░░╚══════╝░░╚═╝░░░╚═╝░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░ Latin: king, ruler, monarch ░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //
// ░░░ Copyright (C) 2023 rex.io ░░░ //
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ //

// ********************************* //
// ******** LIQUIDDERY GAME ******** //
// ********************************* //
// ***** READ THE TERMS BELOW ****** //
// ********************************* //

/*

TERMS and IMPORTANT NOTES

(1) PURPOSE OF THE GAME

- Increase REX price, liquidity, marketing/dev
- FUN. :-)
- GENEROUS CASHBACKS!


(2) Contract explanations

Imagine a game with "rounds":
During an active "LIQUIDDERY Round",
users may buy "LIQUIDDERY Tickets".
1 Ticket costs 20 BUSD.
There 500 tickets available per round.

With the last ticket being sold, the round ends
and the contract requests a set of random numbers
from the CHAINLINK oracle.

When the random numbers have arrived (after approx.
1 min) the contract may be triggered to determine
the random cashback winners. The determination of
the winners automatically starts a new round and
enables the cashback winners to withdraw their
BUSD cashbacks directly from the contract.

The cashbacks are to be thought of as a THANK YOU
for the participation and REX project support.

There are 25 cashback possibilities
for each participating ticket to win per round:
- 1x  BUSD 2,000
- 2x  BUSD 1,000
- 4x  BUSD 500
- 8x  BUSD 250
- 10x BUSD 100

Total cashback per round: 9,000 BUSD.
That is 90% for cashbacks!

CHANCES:
The chance for a cashback is 25/500,
which equals 1/20 per Ticket.

LIMITS:
An address may buy a maximum of 20 Tickets per round.


(3) BUSD TOKEN MANAGEMENT

90% of the BUSD go back to the participants as CASHBACK,
10% is used for the REX ecosystem and Chainlink costs.


(4) Fallback / Security implementations

1. Be aware, there is no 100% guarantee
a smart contract will do what it should.

2. The design of the "rounds", a low Ticket price and
fallback functions (for foreseeable events) shall help
preventing from losses. Nevertheless, unforeseen events
might happen and all BUSD might be lost.

3. FALLBACK #1
If the oracle fails to deliver a random number,
the prizes cannot be distributed. To restore the sent
BUSD, there is a function available (that the "owner"
may trigger) to emergency end the current round -
in that case, all sent (!) BUSD are made available
to be claimed back by the participants, automatically.

4. FALLBACK #2
If people send tokens to the contract without using
the defined functions, they might be stuck in the
contract forever. To prevent from tokens being stuck,
the "owner" has the right to sent tokens back to the
sender.

5. ADMIN RIGHTS
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
may pause the "buyTickets" function to have some time
to investigate on the issue and search for a solution,
if the "owner" thinks it's useful to investigate.
Please note, that pausing the contract does not allow
the "owner" to withdraw any participant's BUSD.

In case of reported misuse of the contract that is
obviously leading to unintended behavior, the "owner"
may "emergency end" the current round, for example if
an investigation leads to the conclusion there is no
solution to the issue.
In this case, all sent (!) BUSD are made available
to be claimed back by the participants, automatically.

All participating addresses have equal rights.


(5) FURTHER NOTES

Despite the aim of this contract is PROMOTING
AND SUPPORTING REX, using this contract might
be considered gambling (as there is a CASHBACK
mechanism involved), so please read and understand
the following NOTES ON GAMBLING:

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
pursuits. It often entails betting beyond your means
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
the contract will fully support you! You can set
a Cooling-Off period for your address for a day,
a week or a month. Taking regular breaks is
crucial for responsible gamblers. You can tell the
contract to block you for a certain amount of days.

***********************************
Made with ❤️ by the REX Community
***********************************

***************************************
coinmarketcap.com/currencies/rex-token/
***************************************

***********************************
THANKS FOR USING REX DEFI PROTOCOLS
***********************************

*/


/// ********************************
/// CHAINLINK INTERFACES
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
    uint32 callbackGasLimit = 900000;
    uint32 numWords = 35;
    /// see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;

    IBEP20 public BUSD_TOKEN;

    event TicketsSold(address indexed sender, uint32 indexed round, uint32 tickets);
    event CashbackDistributed(uint32 round, uint256 busdDistributed);
    event CashbackClaimed(address receiver, uint256 amount);
    event RoundIsDistributed(uint32 round);
    event RoundNotDistributed(uint32 round);
    event RoundHasRandomError(uint32 round);

    bool public saleOpen = true;                /// prevent from participation while waiting for oracle
    bool public noRestart = false;              /// prevent from a new round to start - possible for deployer

    uint32 public currentRound;                 /// starts with round 0
    uint32 public soldTickets;                  /// keep track of sold tickets (variable is reset every round)
    uint32 constant TOTAL_NO_OF_TICKETS = 500;  /// Tickets per round
    uint32 constant MAX_TICKETS = 20;           /// limitation per address
    uint256 constant TICKET_PRICE = 20E18;      /// 20 BUSD
    uint256 totalUnclaimedBUSD;                 /// keep track of unclaimed BUSD in the contract

    mapping(uint32 => uint256) private requestIdOfRound;      /// round -> [Chainlink] requestId // stored for each round
    mapping(uint32 => bool) public roundIsDistributed;        /// store info for each round
    mapping(address => uint256) private addrBlockedUntilTime; /// address -> blocktime (until a user has blocked themselves)
    mapping(address => uint256) public cashbackBusdAvail;     /// amount of BUSD an address may claim
    mapping(address => uint256) public cashbackBusdRecvd;     /// amount of BUSD an address has claimed
    mapping(address => uint256) public addrTotalSpentBusd;    /// to read participation from outside later

    mapping(address => mapping(uint32 => uint32)) public addrTicketsRound;  /// address->round->tickets
    mapping(uint32 => mapping(uint32 => address)) public participants;      /// round -> entry number -> address
    mapping(uint32 => mapping(uint32 => uint32)) public randomNumber;       /// round -> entry number -> randomNumber

    address constant busd_address = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

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
    }

    /// @notice An external function for a participant to buy 1 to MAX_TICKETS Tickets
    /// @dev User must approve BUSD first
    /// @param noOfTickets The desired no. of Tickets
    function buyTickets(uint32 noOfTickets)
        external notContract nonReentrant
    {
        require(saleOpen == true, "LIQUIDDERY: Sale not active");
        require(noOfTickets <= (TOTAL_NO_OF_TICKETS - soldTickets), "LIQUIDDERY: Not enough tickets left");
        require(noOfTickets > 0 && noOfTickets <= MAX_TICKETS, "LIQUIDDERY: Invalid ticket amount");
        require(noOfTickets <= (MAX_TICKETS - addrTicketsRound[msg.sender][currentRound]), "LIQUIDDERY: Max tickets exxceeded");
        require(isBlocked(msg.sender) == false, "LIQUIDDERY: You blocked yourself");

        /// Store the bought tickets for this address for this round (for MAX_TICKETS check)
        addrTicketsRound[msg.sender][currentRound] += noOfTickets;

        /// withdraw BUSD from user to contract
        uint256 _busd_amount = TICKET_PRICE.mul(uint256(noOfTickets));
        require(BUSD_TOKEN.transferFrom(msg.sender, address(this), _busd_amount), "LIQUIDDERY: Transfer of BUSD failed.");

        /// save the participant's address in the participants list (for each bought Ticket)
        /// offset: i = soldTickets
        uint32 j = soldTickets + noOfTickets;
        for (uint32 i = soldTickets; i < j; i++) {
            participants[currentRound][i] = msg.sender;
        }

        soldTickets += noOfTickets;                       /// update soldTickets
        addrTotalSpentBusd[msg.sender] += _busd_amount;   /// save amount for further use in the ecosystem

        /// if the last ticket has been sold, end round and start ORACLE request
        if (soldTickets == TOTAL_NO_OF_TICKETS) {
            saleOpen = false;
            requestIdOfRound[currentRound] = requestRandomWords();  /// save returned ID in "requestIdOfRound"
        }

        emit TicketsSold(msg.sender, currentRound, noOfTickets);
    }

    /// @notice An external function to trigger the cashback distribution
    /// @dev Can only be triggered by an address, not a contract
    function distributeRound() external notContract nonReentrant {
        require(oracleReady() == true, "LIQUIDDERY: Wait for Oracle");
        require(roundIsDistributed[currentRound] == false, "LIQUIDDERY: Already distributed");

        bool randomError = false;
        uint256 _id = requestIdOfRound[currentRound];
        uint256 _t = uint256(TOTAL_NO_OF_TICKETS);

        /// the first received number is unique, therefore set immediately (winner 0)
        randomNumber[currentRound][0] = uint32(s_requests[_id].randomWords[0] % _t);

        /// then while-loop until all other unique numbers are found (winners 1 to 24)
        uint32 candidate;
        uint32 candIndex = 1;       /// index for Chainlink "randomWords"
        uint32 foundUniqueNum = 1;  /// index for inserting new unique nums into "randomNumber" mapping
        uint32 loopIndex = 0;       /// index to go through the "randomNumber" mapping
        bool isDuplicate;

        while (foundUniqueNum < 25 && !randomError) {                         /// loop until we have 25 unique numbers, or exit with "randomError"
            candidate = uint32(s_requests[_id].randomWords[candIndex] % _t);  /// load a candidate from randomWords (modulo TOTAL_NO_OF_TICKETS)
            isDuplicate = false;                                              /// reset to false
            loopIndex = 0;                                                    /// reset for looping through randomNumber, starting from 0

            while (isDuplicate == false && loopIndex < foundUniqueNum) {      /// loop until duplicate is found or endOfArray
                if (candidate == randomNumber[currentRound][loopIndex]) {     /// if the candidate is in the array...
                    isDuplicate = true;                                       /// ... set isDuplicate to true
                }
                loopIndex++;
            }
            /// if no duplicate found, put candidate into randomNumber, else do nothing (proceed with next candIndex)
            if (!isDuplicate) {
                randomNumber[currentRound][foundUniqueNum] = candidate;
                foundUniqueNum++;
            }
            candIndex++;
            if (candIndex == 35) {
                /// CATCH ERROR: in this case the 10 extra random words have not been enough, we need a new set of numbers
                randomError = true;
            }
        }

        if (!randomError) {
            /// store cashbacks in winners' addresses' cashbackBusdAvail
            cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][0] ] ] += 2000E18;
            cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][1] ] ] += 1000E18;
            cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][2] ] ] += 1000E18;
            cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][3] ] ] +=  500E18;
            cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][4] ] ] +=  500E18;
            cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][5] ] ] +=  500E18;
            cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][6] ] ] +=  500E18;
            for (uint32 i = 7; i < 15; i++) {
                cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][i] ] ] += 250E18;
            }
            for (uint32 j = 15; j < 25; j++) {
                cashbackBusdAvail[ participants[currentRound][ randomNumber[currentRound][j] ] ] += 100E18;
            }

            /// send remaining BUSD to marketing fund, so the team may decide how to distribute it
            /// a portion is needed to refill the Chainlink oracle payment tokens
            BUSD_TOKEN.transfer(0x917f0bA27BDD7C0E9d6BFa7286E7eFAA295384F0, uint256(1000E18));

            /// start next round and reset variables
            roundIsDistributed[currentRound] == true;
            currentRound += 1;
            soldTickets = 0;
            totalUnclaimedBUSD += uint256(9000E18);

            /// set the contract active again (unless deployer has set noRestart to true)
            if (!noRestart) { saleOpen = true; }

            emit RoundIsDistributed(currentRound-1);
        } else {
            /// RANDOM_ERROR: we new random numbers for the same round and overwrite requestIdOfRound[currentRound]
            requestIdOfRound[currentRound] = requestRandomWords();          /// save returned ID in "requestIdOfRound"
            s_requests[requestIdOfRound[currentRound]].fulfilled == false;  /// temporarily set to false
            emit RoundHasRandomError(currentRound);                         /// track error
        }
    }

    /// @notice Enables participants to block themselves for 1 to 365 days.
    /// @notice Not possible to change the blocked time, if already blocked.
    function blockMeForXDays(uint256 _days) external notContract returns (bool) {
        require(isBlocked(msg.sender) == false, "LIQUIDDERY: You are blocked already");
        require(_days > 0 && _days <= 365, "LIQUIDDERY: Invalid days");

        addrBlockedUntilTime[msg.sender] = block.timestamp + ((1 days)*_days);
        return true;
    }

    /// @notice Allows an address to claim all its "cashbackBusdAvail"
    /// @return claimed BUSD amount that has been claimed successfully
    function claimCashbackBusd()
        external notContract nonReentrant returns (uint256 claimed)
    {
        require(cashbackBusdAvail[msg.sender] > 0, "LIQUIDDERY: No BUSD to claim");    /// check positive balance
        claimed = cashbackBusdAvail[msg.sender];                                     /// get amount
        cashbackBusdAvail[msg.sender] = 0;                                           /// reset to zero
        cashbackBusdRecvd[msg.sender] += claimed;                                    /// add to "already received BUSD"
        totalUnclaimedBUSD -= claimed;                                               /// deduct
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

    /// @notice Enables owner to emergency end the current round,
    /// @notice no more buys, make BUSD from ticket-buys claimable back
    function emergencyEndRound(bool _restart) external onlyOwner {
        /// make the BUSD claimable back for each entry / participant so far [=soldTickets]
        for (uint32 i = 0; i < soldTickets; i++) {
            cashbackBusdAvail[ participants[currentRound][i] ] += TICKET_PRICE;
            totalUnclaimedBUSD += TICKET_PRICE;
        }

        /// start next round and reset variables
        currentRound += 1;
        soldTickets = 0;

        /// if desired, open a new round of ticket sales
        if (_restart) {
            saleOpen = true;
        } else {
            saleOpen = false;
        }

        emit RoundNotDistributed( currentRound-1 );
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
        noRestart = true;
    }

    /// @notice An internal function to check for contracts
    function _notContract(address _addr) private view returns (bool) {
        uint32 size; assembly { size := extcodesize(_addr) } return (size == 0); }

    /// @notice An internal function to check for a BUSD surplus
    /// @notice That is, when there are more BUSD in the contract, than users have sent by buying tickets
    function getBusdSurplus() private view returns (uint256 surplus) {
        return BUSD_TOKEN.balanceOf(address(this)).sub(totalUnclaimedBUSD).sub((TICKET_PRICE * uint256(soldTickets)));
    }

    /// @notice A function for the owner allowing sending tokens from the contract to receivers
    /// @notice Example: Tokens that have accidentially been sent to the contract, which happens a lot
    /// @param token The token's address to withdraw (BUSD is only allowed if they have been sent accidentially => surplus)
    /// @param receiver The receiver
    /// @param amount Amount of tokens (must be > 0)
    function withdrawTokensToAddr(address token, address receiver, uint256 amount) external onlyOwner {
        require(amount > 0, "LIQUIDDERY: Zero tokens requested");

        IBEP20 Token = IBEP20(token);                         /// get Token
        uint256 _tokenBal = Token.balanceOf(address(this));   /// get available token balance of this contract

        if (token == address(BUSD_TOKEN)) {
            require(amount <= getBusdSurplus(), "LIQUIDDERY: BUSD surplus too low");
        } else {
            require(amount <= _tokenBal, "LIQUIDDERY: Not enough tokens");
        }

        Token.transfer(receiver, amount);
    }
}