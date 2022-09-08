/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.15 < 0.9.0;



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
    uint32 private __callbackGasLimit = 220_000;
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


library ContractDetector {

    function _isContract(address address_) internal view returns(bool) {
        return (address_.code.length > 0);
    }

}


contract IdentityProviderV2 {
    using ContractDetector for address;

    mapping (address => bool) private __eoa;
    mapping (address => bool) private __contracts;

    constructor() {
        __eoa[msg.sender] = true;
    }

    function setEOA(address address_, bool state_) external {
        requireEOA(msg.sender);
        __eoa[address_] = state_;
    }

    function setContract(address address_, bool state_) external {
        requireEOA(msg.sender);
        require (address_._isContract(), "IdentityProviderV2: Cannot add EOA address as contract authority.");
        __contracts[address_] = state_;
    }

    function requireEOA(address address_) public view {
        require (__eoa[address_], "IdentityProviderV2: Not an EOA authority.");
    }

    function requireContract(address address_) external view {
        require (__contracts[address_], "IdentityProviderV2: Not a contract authority.");
    }

}


library FundTransfer {

    function _sendFunds(address recipient_, uint256 amount_) internal {
        (bool success, ) = payable(recipient_).call{value: amount_}("");
        require (success, "FundTransfer: Failed to send.");
    }

}


abstract contract PayableContract {
    using FundTransfer for address;

    uint256 private immutable __fee;
    IdentityProviderV2 private immutable __ipv2;

    constructor (uint256 fee_, address ipv2Address_) {
        __fee = fee_;
        __ipv2 = IdentityProviderV2(ipv2Address_);
    }

    modifier withFee {
        require (msg.value >= __fee);
        _;
    }

    function fee() public view returns(uint256) {
        return __fee;
    }

    function withdrawAll() external {
        address caller = msg.sender;
        __ipv2.requireEOA(caller);
        caller._sendFunds(address(this).balance);
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

    modifier onlyOwnerOf(uint256 tokenId_) {
        address owner = _mint.ownerOf(tokenId_);
        require (owner == msg.sender, "ERC721Ownable: Ownership required.");
        _;
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


/** @dev Internal battle calculation numbers */
struct BattleSpecs {
    uint64 dph;
    uint64 hp;
    uint64 speed;
    uint64 dps; 
}

/** @dev epresents a token which is queued for battle */
struct PendingMatch {
    bool    isPresent;
    uint128 tokenId;
}

/** @dev Represents 2 matched tokens which are awaiting ChainLink */
struct Match {
    uint128 t1;
    uint128 t2;
}

/** @dev Internal structure for tracking important battle metrics */
struct FullMatchDetails {
    uint256[] tokenIds;
    uint256[] totalDamage;
    uint256   totalTurns;
}

/** @dev Public log for gathering battle data */
struct BattleLog {
    bool    isVictory;
    uint256 opponentId;
    uint256 totalTurns;
    uint256 damageDealt;
    uint256 damageTaken;
}

contract PvP is AbstractVRFConsumer,
                PayableContract, 
                ERC721Ownable {
    using FundTransfer for address;

    mapping (uint256 => Match) private __matches;
    mapping (uint256 => PendingMatch) public queue;
    IExperienceTracker private immutable __xp;
    IAttributeReader private immutable __attrs;
    uint256 private immutable __opexFeePercentage;
    address private immutable __feeCollector;

    event PlayerQueued(uint256 indexed tokenId);
    event MatchFound(uint256 indexed tokenId);
    event MatchFinished(uint256 indexed tokenId, BattleLog battleLog);

    constructor (address identityProviderAddress_,
                 uint256 fee_,
                 uint256 executionFee_,
                 address mintAddress_,
                 address attributesAddress_,
                 address xpAddress_,
                 uint64 subscriptionId_,
                 address vrfCoordinatorAddress_,
                 address feeCollectorAddress_) 
    AbstractVRFConsumer(1, subscriptionId_, vrfCoordinatorAddress_)
    PayableContract(fee_, identityProviderAddress_) 
    ERC721Ownable(mintAddress_) {
        __xp = IExperienceTracker(xpAddress_);
        __attrs = IAttributeReader(attributesAddress_);
        __opexFeePercentage = executionFee_;
        __feeCollector = feeCollectorAddress_;
    }

    // Matchmaking functions 
    ////////////////////////

    function initiateBattle(uint256 tokenId_) external payable withFee onlyOwnerOf(tokenId_) {
        uint256 level = __xp.getLevel(tokenId_);
        require (level > 0, "PVP: Not initialized.");
        (bool found, uint128 opponentId) = __findMatch(level, tokenId_);
        if (found) {
            uint256 rid = _requestRandomWords();
            __matches[rid] = Match({t1: opponentId, t2: uint128(tokenId_)});
            emit MatchFound(opponentId);
            emit MatchFound(tokenId_);
        }
        else {
            queue[level] = PendingMatch({isPresent: true, tokenId: uint128(tokenId_)});
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
        PendingMatch storage pendingMatchRef = queue[level_];
        if (pendingMatchRef.isPresent) {
            uint128 opponentId = pendingMatchRef.tokenId;
            require (uint256(opponentId) != tokenId_, "PVP: This token is already in queue.");
            delete queue[level_];
            return (true, opponentId);
        }
        else return (false, 0);
    }

    // Battle coordination functions 
    ////////////////////////

    function _handleCallback(uint256 requestId_, uint256[] memory randomWords_) internal override {
        uint256 cl = randomWords_[0];

        Match storage storedMatchRef = __matches[requestId_];
        uint256 t1 = uint256(storedMatchRef.t1);
        uint256 t2 = uint256(storedMatchRef.t2);

        // Conduct battle and get winning token id back
        (uint256 winnerIndex, FullMatchDetails memory matchDetails) = __prepareAndBattle(t1, t2, cl);
        uint256 loserIndex = winnerIndex == 0 ? 1 : 0;

        // Find owner of the winningTokenId token, send them the rewards
        address owner = _mint.ownerOf(matchDetails.tokenIds[winnerIndex]);
        __payoutWinner(owner);

        emit MatchFinished(matchDetails.tokenIds[winnerIndex], BattleLog({
            isVictory: true,
            opponentId: matchDetails.tokenIds[loserIndex],
            totalTurns: matchDetails.totalTurns, 
            damageDealt: matchDetails.totalDamage[winnerIndex],
            damageTaken: matchDetails.totalDamage[loserIndex]
        }));
        emit MatchFinished(matchDetails.tokenIds[loserIndex], BattleLog({
            isVictory: false,
            opponentId: matchDetails.tokenIds[winnerIndex],
            totalTurns: matchDetails.totalTurns, 
            damageDealt: matchDetails.totalDamage[loserIndex],
            damageTaken: matchDetails.totalDamage[winnerIndex]
        }));

        delete __matches[requestId_];
    }

    /** @dev Pull required battle data from external contracts and initiate the battle protocol */
    function __prepareAndBattle(uint256 t1_, uint256 t2_, uint256 cl_) private view returns (uint256, FullMatchDetails memory) {
        AttributeBundle memory a1 = __attrs.get(t1_);
        AttributeBundle memory a2 = __attrs.get(t2_);

        bytes memory cl = abi.encodePacked(cl_);
        BattleSpecs[2] memory bs = [__calculateBattleStats(a1, __xp.getLevel(t1_)), __calculateBattleStats(a2, __xp.getLevel(t2_))];

        return __battle(t1_, t2_, bs, cl);
    }

    function __battle(uint256 t1_, uint256 t2_, BattleSpecs[2] memory bs, bytes memory cl_) private pure returns(uint256, FullMatchDetails memory) {
        FullMatchDetails memory matchDetails = FullMatchDetails(
            new uint256[](2),
            new uint256[](2),
            0
        );
        matchDetails.tokenIds[0] = t1_;
        matchDetails.tokenIds[1] = t2_;

        uint256[2] memory speed;
        uint256[2] memory stacks;
        bool isFirstAttacking = bs[0].speed > bs[1].speed;

        // 32 bytes in the random uint256, thus 32 turns at most.
        for (uint256 i = 0; i < 32; i++) {
            uint256 attacker = isFirstAttacking ? 0 : 1;
            uint256 defender = isFirstAttacking ? 1 : 0;

            uint256 turnDamage = __calculateTurnDamage(bs[attacker].dph, uint8(cl_[i])) + stacks[attacker];
            if (speed[attacker] >= speed[defender] * 2) {
                // If the attacker speed reached double that of the defender, he gets an additional strike
                turnDamage += bs[attacker].dph;
                // We reset the speed counters
                speed[0] = 0; 
                speed[1] = 0;
            }

            // Update match details
            matchDetails.totalDamage[attacker] += uint120(turnDamage);       
            matchDetails.totalTurns += 1;

            // If total cummulative damage > opponent hp, attacker wins
            if (bs[defender].hp <= matchDetails.totalDamage[attacker]) {
                return (attacker, matchDetails);
            }
        
            stacks[attacker] += bs[attacker].dps;

            speed[0] += bs[0].speed;
            speed[1] += bs[1].speed;

            isFirstAttacking = !isFirstAttacking;
        }

        // If both players still standing, more HP wins
        return (
            (bs[0].hp - matchDetails.totalDamage[1]) > (bs[1].hp - matchDetails.totalDamage[0]) ? 0 : 1, 
            matchDetails
        );
    }

    // Battle calculation functions 
    ////////////////////////

    function __calculateBattleStats(AttributeBundle memory a_, uint256 level_) private view returns(BattleSpecs memory) {
        return BattleSpecs({
            dph: __calculateLevelBaseBattleStat(20, level_) + a_.strength,
            hp: __calculateLevelBaseBattleStat(100, level_) + (a_.constitution * 6),
            speed: __calculateLevelBaseBattleStat(20, level_) + a_.haste,
            dps: (a_.lethality / 2)
        });
    }

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

    function __calculateLevelBaseBattleStat(uint256 base_, uint256 level_) private view returns(uint64) {
        uint256 n = level_ - 1;
        uint256 y = base_ * __PRECOMPUTED[n % 10];
        n = n - n % 10;
        while (n > 0) {
            y = y * __PRECOMPUTED[10] / 100_000;
            n = n - 10;
        }
        return uint64(y / 100_000);
    }

    /** @dev Maximum +- DPH deviation allowed for ChainLink */
    uint8 private constant MAX_DMG_MOD = 30;
    uint8 private constant DMG_DELIMITER = 100;

    function __calculateTurnDamage(uint256 dph_, uint8 chainLink_) private pure returns(uint256) {
        bool coinflip = (chainLink_ % (2 * MAX_DMG_MOD)) > MAX_DMG_MOD;
        uint256 dmgMod = uint256(chainLink_ % MAX_DMG_MOD);
        if (coinflip) return dph_ + ((dph_ * dmgMod) / DMG_DELIMITER);
        else          return dph_ - ((dph_ * dmgMod) / DMG_DELIMITER);
    }

    // Fund management functions 
    ////////////////////////

    /** @dev Sends (2 * Fee) to the winningTokenId, while taxing according to __opexFeePercentage */
    function __payoutWinner(address winner_) private {
        uint256 untaxedPayout = fee() * 2;
        uint256 tax = (untaxedPayout / 100) * __opexFeePercentage;
        uint256 taxedPayout = untaxedPayout - tax;

        assert (address(this).balance >= untaxedPayout);
        
        winner_._sendFunds(taxedPayout);
        // Withdrawing accumulated funds manually can (and will) cause a crash
        __feeCollector._sendFunds(tax);
    }

}