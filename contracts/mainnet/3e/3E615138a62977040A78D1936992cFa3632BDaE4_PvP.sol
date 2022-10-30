/**
 *Submitted for verification at BscScan.com on 2022-10-30
*/

//   /$$$$$$  /$$                 /$$                 /$$                           /$$
//  /$$__  $$| $$                |__/                | $$                          |__/
// | $$  \__/| $$$$$$$   /$$$$$$  /$$ /$$$$$$$       | $$        /$$$$$$   /$$$$$$  /$$  /$$$$$$  /$$$$$$$
// | $$      | $$__  $$ |____  $$| $$| $$__  $$      | $$       /$$__  $$ /$$__  $$| $$ /$$__  $$| $$__  $$
// | $$      | $$  \ $$  /$$$$$$$| $$| $$  \ $$      | $$      | $$$$$$$$| $$  \ $$| $$| $$  \ $$| $$  \ $$
// | $$    $$| $$  | $$ /$$__  $$| $$| $$  | $$      | $$      | $$_____/| $$  | $$| $$| $$  | $$| $$  | $$
// |  $$$$$$/| $$  | $$|  $$$$$$$| $$| $$  | $$      | $$$$$$$$|  $$$$$$$|  $$$$$$$| $$|  $$$$$$/| $$  | $$
//  \______/ |__/  |__/ \_______/|__/|__/  |__/      |________/ \_______/ \____  $$|__/ \______/ |__/  |__/
//                                                                        /$$  \ $$
//                                                                       |  $$$$$$/
//                                                                        \______/
// Chain Legion is an on-chain RPG project which uses NFT Legionnaires as in-game playable characters.
// There are 7,777 mintable tokens in total within this contract.
//
// Join the on-chain evolution at:
//      - chainlegion.com
//      - play.chainlegion.com
//      - t.me/ChainLegion
//      - twitter.com/ChainLegionNFT
//
// Contract made by Lizard Man, CEO of Chain Legion
//      - twitter.com/reallizardev
//      - t.me/lizardev

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.17 < 0.9.0;


/** @dev Public log for gathering battle data */
struct ExposedBattleLog {
    bool    isVictory;
    uint256 opponentId;
    uint256 totalTurns;
    uint256 damageDealt;
    uint256 damageTaken;
}


struct Log {
    uint128 wins;
    uint128 losses;
}

interface IPvPLogger {

    function log(uint256 winner, uint256 loser,
                 ExposedBattleLog calldata, ExposedBattleLog calldata) external;

}


/** @dev Represents a token which is queued for battle */
struct QueueSlot {
    bool    isPresent;
    uint128 tokenId;
}

/** @dev Represents 2 matched tokens which are awaiting ChainLink */
struct PendingMatch {
    uint128 t1;
    uint128 t2;
}

/** @dev Internal structure for tracking important battle metrics */
struct InternalMatchDetails {
    uint256[] tokenIds;
    uint256[] totalDamage;
    uint256   totalTurns;
}


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


/**
    @dev A simple implementation of an on-chain authority book.
    @dev Contract offers checks on whether a certain address is an authority
    @dev As well as a setter function, callable by authorities only
 */
contract IdentityProvider {

    /**
        @dev Sets the deployer address as the initial authority
     */
    constructor() {
        __setAuthority(msg.sender, true);
    }

    /** @dev Collection of all authorities */
    mapping (address => bool) private __authorities;

    /** @dev Requires that the caller is an authority */
    modifier onlyAuthority(address address_) {
        require (__authorities[address_], "IdentityProvider: Not authorized.");
        _;        
    }

    /** @dev Sets the authority state for the given address. Caller must be authorized */
    function setAuthority(address address_, bool state_) external onlyAuthority(msg.sender) {
       __setAuthority(address_, state_);
    }

    function __setAuthority(address address_, bool state_) private {
        __authorities[address_] = state_;
    }

    /** @dev Performs an assertion that the given address is an authority */
    function requireAuthority(address address_) external view onlyAuthority(address_) {}

}


abstract contract AbstractVRFConsumer is VRFConsumerBaseV2 {

    constructor(uint32 randomWordCount_,
                uint64 subscriptionId_, 
                address vrfCoordinatorAddress_)
    VRFConsumerBaseV2(vrfCoordinatorAddress_) {
        _randomWordCount = randomWordCount_;
        __subscriptionId = subscriptionId_;
        __coordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress_);
    }

    // Static config
    bytes32 constant private __keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint16 constant private __requestConfirmations = 3;

    // Modifiable ChainLink params
    uint32 constant private __callbackGasLimit = 500_000;
    uint32 internal immutable _randomWordCount;
   
    // Injectable params
    uint64 immutable private __subscriptionId;
    VRFCoordinatorV2Interface immutable private __coordinator;

    function _requestRandomWords() internal returns(uint256 requestId) {
        return __coordinator.requestRandomWords(
            __keyHash,
            __subscriptionId,
            __requestConfirmations,
            __callbackGasLimit,
            _randomWordCount
        );
    }

    function fulfillRandomWords(uint256 requestId_, uint256[] memory randomWords_) internal override {
        _handleCallback(requestId_, randomWords_);
    }

    function _handleCallback(uint256 requestId_, uint256[] memory randomWords_) internal virtual;

}


abstract contract SimpleOwnable {
    
    address private immutable __owner;

    constructor () {
        __owner = msg.sender;
    }

    function _onlyOwner() internal view {
        require (msg.sender == __owner, "SimpleOwnable: Ownership required.");
    }

    function _owner() internal view returns(address) {
        return __owner;
    }

}


library FundTransfer {

    function _sendFunds(address recipient_, uint256 amount_) internal {
        (bool success, ) = payable(recipient_).call{value: amount_}("");
        require (success, "FundTransfer: Failed to send.");
    }

}


abstract contract PayableV2 is SimpleOwnable {
    using FundTransfer for address;

    uint256 public immutable fee;

    constructor (uint256 fee_) {
        fee = fee_;
    }

    function _requirePayment() internal {
        require (msg.value >= fee, "PayableV2: Insufficient msg.value");
    }

    function withdrawAll() external {
        _owner()._sendFunds(address(this).balance);
    }

}


/**
    @dev Defines ownership function for ERC721 tokens.
 */
interface IERC721Ownable {

    /** @dev Returns the current owner of the given ERC721 token id */
    function ownerOf(uint256 tokenId) external view returns (address);

}

abstract contract ERC721Ownable {

    IERC721Ownable internal immutable _mint;

    constructor (address address_) {
        _mint = IERC721Ownable(address_);
    }

    function _onlyOwnerOf(uint256 tokenId_) internal view {
        address owner = _mint.ownerOf(tokenId_);
        require (owner == msg.sender, "ERC721Ownable: Ownership required.");
    }

}


struct AttributeBundle {
    uint64 strength;
    uint64 constitution;
    uint64 haste;
    uint64 lethality;
}

interface IAttributeReader {

    function get(uint256 tokenId) external view returns(AttributeBundle memory);

}


/**
    @dev Functions to read level and xp data.
 */
interface IExperienceTracker {

    function isInitialized(uint256 tokenId) external view returns(bool);

    function getLevel(uint256 tokenId) external view returns(uint256);

    function getXp(uint256 tokenId) external view returns(uint256);

}


/**
    @dev Provides functions to manipulate XP points.
 */
interface IExperienceModifier {

    /** @dev Adds the given amount of XP points to the given token id */
    function addExperiencePoints(uint256 amount, uint256 id) external;

}


struct BattleSpecs {
    uint64 dph;
    uint64 hp;
    uint64 speed;
    uint64 dps;
}

contract PvP is AbstractVRFConsumer,
                PayableV2, 
                ERC721Ownable {
    using FundTransfer for address;

    mapping (uint256 => PendingMatch) private __matches;
    mapping (uint256 => QueueSlot) public queue;

    uint256 public winnerXp = 50;
    uint256 public loserXp = 20;

    IPvPLogger private immutable __logger;
    IExperienceTracker private immutable __xpTracker;
    IExperienceModifier private immutable __xpMod;
    IAttributeReader private immutable __attrs;
    
    uint256 private __opexFeePercentage;
    address private immutable __feeCollector;

    /** @dev Emits when a token id hasn't found an opponent and is put in a queue */
    event PlayerQueued(uint256 indexed tokenId);
    /** @dev Emits when 2 token ids have been matched for a battle. This will emit twice, for both tokens. */
    event MatchFound(uint256 indexed tokenId);

    constructor (uint256 fee_,
                 uint256 opexFee_,
                 address mint_,
                 address attributes_,
                 address xp_,
                 uint64 subscriptionId_,
                 address vrfCoordinator_,
                 address logger_) 
    AbstractVRFConsumer(1, subscriptionId_, vrfCoordinator_)
    PayableV2(fee_) 
    ERC721Ownable(mint_) {
        __xpTracker = IExperienceTracker(xp_);
        __xpMod = IExperienceModifier(xp_);
        __attrs = IAttributeReader(attributes_);
        __logger = IPvPLogger(logger_);
        __opexFeePercentage = opexFee_;
        __feeCollector = msg.sender;
    }

    function initiateBattle(uint256 tokenId_) external payable {
        _requirePayment();
        _onlyOwnerOf(tokenId_);
        uint256 level = __xpTracker.getLevel(tokenId_);
        require (level > 0, "PVP: Not initialized.");
        (bool found, uint128 opponentId) = __findMatch(level, tokenId_);
        if (found) {
            uint256 rid = _requestRandomWords();
            __matches[rid] = PendingMatch({t1: opponentId, t2: uint128(tokenId_)});
            emit MatchFound(opponentId);
            emit MatchFound(tokenId_);
        } 
        else {
            queue[level] = QueueSlot({isPresent: true, tokenId: uint128(tokenId_)});
            emit PlayerQueued(tokenId_);
        }
    }

    function __findMatch(uint256 level_, uint256 tokenId_) private returns(bool, uint128) {
        // Search for exact level match
        (bool found, uint128 opponentId) = __inspectQueueForMatches(level_, tokenId_);
        if (found) return (found, opponentId);
        
        // Search for +-1 level matches
        (found, opponentId) = __inspectQueueForMatches(level_ - 1, tokenId_);
        if (found) return (found, opponentId);

        (found, opponentId) = __inspectQueueForMatches(level_ + 1, tokenId_);
        if (found) return (found, opponentId);
        
        // Failed to find match
        return (false, 0);
    }

    function __inspectQueueForMatches(uint256 level_, uint256 tokenId_) private returns(bool, uint128) {
        QueueSlot memory pendingMatchMem = queue[level_];
        if (pendingMatchMem.isPresent) {
            uint128 opponentId = pendingMatchMem.tokenId;
            require (uint256(opponentId) != tokenId_, "PVP: This token is already in queue.");
            delete queue[level_];
            return (true, opponentId);
        }
        else return (false, 0);
    }

    function _handleCallback(uint256 requestId_, uint256[] memory randomWords_) internal override {
        PendingMatch memory storedMatchMem = __matches[requestId_];

        // Conduct battle and get winning token id back
        (uint256 winnerIndex, InternalMatchDetails memory matchDetails) = __prepareAndBattle(uint256(storedMatchMem.t1), 
                                                                                             uint256(storedMatchMem.t2),
                                                                                             randomWords_[0]);
        uint256 loserIndex = winnerIndex == 0 ? 1 : 0;

        uint256 winnerId = matchDetails.tokenIds[winnerIndex];
        uint256 loserId = matchDetails.tokenIds[loserIndex];

        // Find owner of the winningTokenId token, send them the rewards
        __payoutWinner(_mint.ownerOf(winnerId));

        __logger.log(
            winnerId,
            loserId,
            ExposedBattleLog({
                isVictory: true,
                opponentId: loserId,
                totalTurns: matchDetails.totalTurns, 
                damageDealt: matchDetails.totalDamage[winnerIndex],
                damageTaken: matchDetails.totalDamage[loserIndex]
            }),
            ExposedBattleLog({
                isVictory: false,
                opponentId: winnerId,
                totalTurns: matchDetails.totalTurns, 
                damageDealt: matchDetails.totalDamage[loserIndex],
                damageTaken: matchDetails.totalDamage[winnerIndex]
            })
        );

        __xpMod.addExperiencePoints(winnerXp, winnerId);
        __xpMod.addExperiencePoints(loserXp, loserId);

        delete __matches[requestId_];
    }

    /** @dev Pull required battle data from external contracts and initiate the battle protocol */
    function __prepareAndBattle(uint256 t1_, 
                                uint256 t2_, 
                                uint256 cl_) 
    private view returns (uint256, InternalMatchDetails memory) {
        AttributeBundle memory a1 = __attrs.get(t1_);
        AttributeBundle memory a2 = __attrs.get(t2_);

        bytes memory cl = abi.encodePacked(cl_);
        BattleSpecs[2] memory bs = [
            calculateBattleSpecs(a1, __xpTracker.getLevel(t1_)), 
            calculateBattleSpecs(a2, __xpTracker.getLevel(t2_))
        ];

        return __battle(t1_, t2_, bs, cl);
    }

    function __battle(uint256 t1_, 
                      uint256 t2_, 
                      BattleSpecs[2] memory bs_, 
                      bytes memory cl_) 
    private pure returns(uint256, InternalMatchDetails memory) {
        InternalMatchDetails memory matchDetails = InternalMatchDetails({
            tokenIds: new uint256[](2),
            totalDamage: new uint256[](2),
            totalTurns: 0
        });
        matchDetails.tokenIds[0] = t1_;
        matchDetails.tokenIds[1] = t2_;

        uint256[2] memory speed = [uint256(bs_[0].speed), uint256(bs_[1].speed)];
        uint256 speedThreshold = speed[0] > speed[1] ? (speed[0] * 2) : (speed[1] * 2);
        uint256[2] memory stacks = [uint256(0), uint256(0)];

        bool isFirstAttacking = speed[0] > speed[1];

        unchecked {
            // 32 bytes in the random uint256, thus 32 turns at most.
            for (uint256 i = 0; i < 32; i++) {
                uint256 attacker = isFirstAttacking ? 0 : 1;
                uint256 defender = isFirstAttacking ? 1 : 0;

                uint256 roll = uint256(uint8(cl_[i]));
                uint256 turnDamage = __calculateTurnDamage(bs_[attacker].dph, roll) + stacks[attacker];
                if ((roll ** 2) % speedThreshold < speed[attacker]) {
                    turnDamage += bs_[attacker].dph;
                }

                // Update match details
                matchDetails.totalDamage[attacker] += turnDamage;
                matchDetails.totalTurns += 1;

                // If total cummulative damage > opponent hp, attacker wins
                if (bs_[defender].hp <= matchDetails.totalDamage[attacker]) {
                    return (attacker, matchDetails);
                }
            
                stacks[attacker] += bs_[attacker].dps;
                isFirstAttacking = !isFirstAttacking;
            }

            // If both players still standing, more HP wins
            return (
                (bs_[0].hp - matchDetails.totalDamage[1]) > (bs_[1].hp - matchDetails.totalDamage[0]) ? 0 : 1, 
                matchDetails
            );
        }
    }

    /** @dev Calculate BattleSpecs from Attributes and level */
    function calculateBattleSpecs(AttributeBundle memory a_, uint256 level_) public view returns(BattleSpecs memory) {
        unchecked {
            return BattleSpecs({
                dph: __calculateLevelBaseBattleStat(40, level_) + a_.strength,
                hp: __calculateLevelBaseBattleStat(200, level_) + (a_.constitution * 6),
                speed: __calculateLevelBaseBattleStat(5, level_) + a_.haste,
                dps: a_.lethality
            });
        }
    }

    /** @dev Magic numbers go woosh */
    uint256[] private __PRECOMPUTED = [
        100000,
        105000,
        110250,
        115763,
        121551,
        127628,
        134010,
        140710,
        147746,
        155133,
        162889
    ];

    /** @dev Returns the base level stat which is an exponential function of `base_` param with a 5% growth curve */
    function __calculateLevelBaseBattleStat(uint256 base_, uint256 level_) private view returns(uint64) {
        unchecked {
            uint256 n = level_ - 1;
            uint256 y = base_ * __PRECOMPUTED[n % 10];
            n = n - n % 10;
            while (n > 0) {
                y = y * __PRECOMPUTED[10] / 100_000;
                n = n - 10;
            }
            if (y % 100_000 >= 50_000) {
                return uint64(y / 100_000) + 1;
            }
            else {
                return uint64(y / 100_000);
            }            
        }
    }

    /** @dev Maximum +- DPH deviation allowed for ChainLink */
    uint256 private constant MAX_DMG_MOD = 30;

    function __calculateTurnDamage(uint256 dph_, uint256 chainLink_) private pure returns(uint256) {
        unchecked {
            bool coinflip = (chainLink_ % (2 * MAX_DMG_MOD)) >= MAX_DMG_MOD;
            uint256 dmgMod = (chainLink_ % MAX_DMG_MOD) + 1;
            if (coinflip) return dph_ + ((dph_ * dmgMod) / 100);
            else          return dph_ - ((dph_ * dmgMod) / 100);
        }
    }

    /** @dev Sends (2 * Fee) to the winner, while taxing according to __opexFeePercentage */
    function __payoutWinner(address winner_) private {
        unchecked {
            uint256 untaxedPayout = fee * 2;
            uint256 tax = (untaxedPayout / 100) * __opexFeePercentage;
            uint256 taxedPayout = untaxedPayout - tax;
            
            winner_._sendFunds(taxedPayout);
            __feeCollector._sendFunds(tax); 
        }
    }

    /** @dev Setter function for battle xp rewards */
    function setXpRewards(uint256 winner_, uint256 loser_) external {
        _onlyOwner();
        winnerXp = winner_;
        loserXp = loser_;
    }

    function setOpexFeePercentage(uint256 percentage_) external {
        _onlyOwner();
        __opexFeePercentage = percentage_;
    }

}