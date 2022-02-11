//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./interfaces/ISummitRNGModule.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";



/*
---------------------------------------------------------------------------------------------
--   S U M M I T . D E F I
---------------------------------------------------------------------------------------------


Summit is highly experimental.
It has been crafted to bring a new flavor to the defi world.
We hope you enjoy the Summit.defi experience.
If you find any bugs in these contracts, please claim the bounty (see docs)


Created with love by Architect and the Summit team





---------------------------------------------------------------------------------------------
--   E L E V A T I O N   H E L P E R
---------------------------------------------------------------------------------------------


ElevationHelper.sol handles shared functionality between the elevations / expedition
Handles the allocation multiplier for each elevation
Handles the duration of each round



*/

contract ElevationHelper is Ownable {
    // ---------------------------------------
    // --   V A R I A B L E S
    // ---------------------------------------

    address public cartographer;                                            // Allows cartographer to act as secondary owner-ish
    address public expeditionV2;

    // Constants for elevation comparisons
    uint8 constant OASIS = 0;
    uint8 constant PLAINS = 1;
    uint8 constant MESA = 2;
    uint8 constant SUMMIT = 3;
    uint8 constant EXPEDITION = 4;
    uint8 constant roundEndLockoutDuration = 120;

    
    uint16[5] public allocMultiplier = [100, 110, 125, 150, 100];            // Alloc point multipliers for each elevation    
    uint16[5] public pendingAllocMultiplier = [100, 110, 125, 150, 100];     // Pending alloc point multipliers for each elevation, updated at end of round for elevation, instantly for oasis   
    uint8[5] public totemCount = [1, 2, 5, 10, 2];                          // Number of totems at each elevation

    
    uint256 constant baseRoundDuration = 3600;                              // Duration (seconds) of the smallest round chunk
    uint256[5] public durationMult = [0, 2, 2, 2, 6];                      // Number of round chunks for each elevation
    uint256[5] public pendingDurationMult = [0, 2, 2, 2, 6];               // Duration mult that takes effect at the end of the round

    uint256[5] public unlockTimestamp;                                      // Time at which each elevation unlocks to the public
    uint256[5] public roundNumber;                                          // Current round of each elevation
    uint256[5] public roundEndTimestamp;                                    // Time at which each elevation's current round ends
    mapping(uint256 => uint256) public expeditionDeityDivider;                // Higher / lower integer for each expedition round

    mapping(uint8 => mapping(uint256 => uint256)) public totemWinsAccum;    // Accumulator of the total number of wins for each totem
    mapping(uint8 => mapping(uint256 => uint8)) public winningTotem;        // The specific winning totem for each elevation round


    address public summitRNGModuleAdd;                                      // VRF module address



    // ---------------------------------------
    // --   E V E N T S
    // ---------------------------------------

    event WinningTotemSelected(uint8 indexed elevation, uint256 indexed round, uint8 indexed totem);
    event DeityDividerSelected(uint256 indexed expeditionRound, uint256 indexed deityDivider);
    event UpgradeSummitRNGModule(address indexed _summitRNGModuleAdd);
    event SetElevationRoundDurationMult(uint8 indexed _elevation, uint8 _mult);
    event SetElevationAllocMultiplier(uint8 indexed _elevation, uint16 _allocMultiplier);



    
    // ---------------------------------------
    // --   I N I T I A L I Z A T I O N
    // ---------------------------------------

    /// @dev Creates ElevationHelper contract with cartographer as owner of certain functionality
    /// @param _cartographer Address of main Cartographer contract
    constructor(address _cartographer, address _expeditionV2) {
        require(_cartographer != address(0), "Cartographer missing");
        require(_expeditionV2 != address(0), "Expedition missing");
        cartographer = _cartographer;
        expeditionV2 = _expeditionV2;
    }

    /// @dev Turns on the Summit ecosystem across all contracts
    /// @param _enableTimestamp Timestamp at which Summit was enabled, used to set unlock points for each elevation
    function enable(uint256 _enableTimestamp)
        external
        onlyCartographer
    {
        // The next top of hour from the enable timestamp
        uint256 nextHourTimestamp = _enableTimestamp + (3600 - (_enableTimestamp % 3600));

        // Setting when each elevation of the ecosystem unlocks
        unlockTimestamp = [
            nextHourTimestamp,                       // Oasis - throwaway
            nextHourTimestamp + 0 days,              // Plains
            nextHourTimestamp + 1 days,              // Mesa
            nextHourTimestamp + 2 days,              // Summit
            nextHourTimestamp + 3 days               // Expedition
        ];

        // The first 'round' ends when the elevation unlocks
        roundEndTimestamp = unlockTimestamp;
        
        // Timestamp of the first seed round starting
        ISummitRNGModule(summitRNGModuleAdd).setSeedRoundEndTimestamp(unlockTimestamp[PLAINS] - roundEndLockoutDuration);
    }



    // ---------------------------------------
    // --   M O D I F I E R S
    // ---------------------------------------

    modifier onlyCartographer() {
        require(msg.sender == cartographer, "Only cartographer");
        _;
    }
    modifier onlyCartographerOrExpedition() {
        require(msg.sender == cartographer || msg.sender == expeditionV2, "Only cartographer or expedition");
        _;
    }
    modifier allElevations(uint8 _elevation) {
        require(_elevation <= EXPEDITION, "Bad elevation");
        _;
    }
    modifier elevationOrExpedition(uint8 _elevation) {
        require(_elevation >= PLAINS && _elevation <= EXPEDITION, "Bad elevation");
        _;
    }
    





    // ---------------------------------------
    // --   U T I L S (inlined for brevity)
    // ---------------------------------------


    /// @dev Allocation multiplier of an elevation
    /// @param _elevation Desired elevation
    function elevationAllocMultiplier(uint8 _elevation) public view returns (uint256) {
        return uint256(allocMultiplier[_elevation]);
    }
    
    /// @dev Duration of elevation round in seconds
    /// @param _elevation Desired elevation
    function roundDurationSeconds(uint8 _elevation) public view returns (uint256) {
        return durationMult[_elevation] * baseRoundDuration;
    }

    /// @dev Current round of the expedition
    function currentExpeditionRound() public view returns (uint256) {
        return roundNumber[EXPEDITION];
    }

    /// @dev Deity divider (random offset which skews chances of each deity winning) of the current expedition round
    function currentDeityDivider() public view returns (uint256) {
        return expeditionDeityDivider[currentExpeditionRound()];
    }

    /// @dev Modifies a given alloc point with the multiplier of that elevation, used to set a single allocation for a token while each elevation is set automatically
    /// @param _allocPoint Base alloc point to modify
    /// @param _elevation Fetcher for the elevation multiplier
    function elevationModulatedAllocation(uint256 _allocPoint, uint8 _elevation) external view allElevations(_elevation) returns (uint256) {
        return _allocPoint * allocMultiplier[_elevation];
    }

    /// @dev Checks whether elevation is is yet to be unlocked for farming
    /// @param _elevation Which elevation to check
    function elevationLocked(uint8 _elevation) external view returns (bool) {
        return block.timestamp <= unlockTimestamp[_elevation];
    }

    /// @dev Checks whether elevation is locked due to round ending in next {roundEndLockoutDuration} seconds
    /// @param _elevation Which elevation to check
    function endOfRoundLockoutActive(uint8 _elevation) external view returns (bool) {
        if (roundEndTimestamp[_elevation] == 0) return false;
        return block.timestamp >= (roundEndTimestamp[_elevation] - roundEndLockoutDuration);
    }

    /// @dev The next round available for a new pool to unlock at. Used to add pools but not start them until the next rollover
    /// @param _elevation Which elevation to check
    function nextRound(uint8 _elevation) external view returns (uint256) {
        return block.timestamp <= unlockTimestamp[_elevation] ? 1 : (roundNumber[_elevation] + 1);
    }

    /// @dev Whether a round has ended
    /// @param _elevation Which elevation to check
    function roundEnded(uint8 _elevation) internal view returns (bool) {
        return block.timestamp >= roundEndTimestamp[_elevation];
    }

    /// @dev Seconds remaining in round of elevation
    /// @param _elevation Which elevation to check time remaining of
    function timeRemainingInRound(uint8 _elevation) public view returns (uint256) {
        return roundEnded(_elevation) ? 0 : roundEndTimestamp[_elevation] - block.timestamp;
    }

    /// @dev Getter of fractional amount of round remaining
    /// @param _elevation Which elevation to check progress of
    /// @return Fraction raised to 1e12
    function fractionRoundRemaining(uint8 _elevation) external view returns (uint256) {
        return timeRemainingInRound(_elevation) * 1e12 / roundDurationSeconds(_elevation);
    }

    /// @dev Getter of fractional progress through round
    /// @param _elevation Which elevation to check progress of
    /// @return Fraction raised to 1e12
    function fractionRoundComplete(uint8 _elevation) external view returns (uint256) {
        return ((roundDurationSeconds(_elevation) - timeRemainingInRound(_elevation)) * 1e12) / roundDurationSeconds(_elevation);
    }

    /// @dev Start timestamp of current round
    /// @param _elevation Which elevation to check
    function currentRoundStartTime(uint8 _elevation) external view returns(uint256) {
        return roundEndTimestamp[_elevation] - roundDurationSeconds(_elevation);
    }




    
    // ------------------------------------------------------------------
    // --   P A R A M E T E R S
    // ------------------------------------------------------------------

    /// @dev Upgrade the RNG module when VRF becomes available on FTM, will only use `getRandomNumber` functionality
    /// @param _summitRNGModuleAdd Address of new VRF randomness module
    function upgradeSummitRNGModule (address _summitRNGModuleAdd)
        public
        onlyOwner
    {
        require(_summitRNGModuleAdd != address(0), "SummitRandomnessModule missing");
        summitRNGModuleAdd = _summitRNGModuleAdd;
        emit UpgradeSummitRNGModule(_summitRNGModuleAdd);
    }


    /// @dev Update round duration mult of an elevation
    function setElevationRoundDurationMult(uint8 _elevation, uint8 _mult)
        public
        onlyOwner elevationOrExpedition(_elevation)
    {
        require(_mult > 0, "Duration mult must be non zero");
        pendingDurationMult[_elevation] = _mult;
        emit SetElevationRoundDurationMult(_elevation, _mult);
    }


    /// @dev Update emissions multiplier of an elevation
    function setElevationAllocMultiplier(uint8 _elevation, uint16 _allocMultiplier)
        public
        onlyOwner allElevations(_elevation)
    {
        require(_allocMultiplier <= 300, "Multiplier cannot exceed 3X");
        pendingAllocMultiplier[_elevation] = _allocMultiplier;
        if (_elevation == OASIS) {
            allocMultiplier[_elevation] = _allocMultiplier;
        }
        emit SetElevationAllocMultiplier(_elevation, _allocMultiplier);
    }



    // ------------------------------------------------------------------
    // --   R O L L O V E R   E L E V A T I O N   R O U N D
    // ------------------------------------------------------------------


    /// @dev Validates that the selected elevation is able to be rolled over
    /// @param _elevation Which elevation is attempting to be rolled over
    function validateRolloverAvailable(uint8 _elevation)
        external view
    {
        // Elevation must be unlocked for round to rollover
        require(block.timestamp >= unlockTimestamp[_elevation], "Elevation locked");
        // Rollover only becomes available after the round has ended, if timestamp is before roundEnd, the round has already been rolled over and its end timestamp pushed into the future
        require(block.timestamp >= roundEndTimestamp[_elevation], "Round already rolled over");
    }


    /// @dev Uses the seed and future block number to generate a random number, which is then used to select the winning totem and if necessary the next deity divider
    /// @param _elevation Which elevation to select winner for
    function selectWinningTotem(uint8 _elevation)
        external
        onlyCartographerOrExpedition elevationOrExpedition(_elevation)
    {
        uint256 rand = ISummitRNGModule(summitRNGModuleAdd).getRandomNumber(_elevation, roundNumber[_elevation]);

        // Uses the random number to select the winning totem
        uint8 winner = chooseWinningTotem(_elevation, rand);

        // Updates data with the winning totem
        markWinningTotem(_elevation, winner);

        // If necessary, uses the random number to generate the next deity divider for expeditions
        if (_elevation == EXPEDITION)
            setNextDeityDivider(rand);
    }


    /// @dev Final step in the rollover pipeline, incrementing the round numbers to bring current
    /// @param _elevation Which elevation is being updated
    function rolloverElevation(uint8 _elevation)
        external
        onlyCartographerOrExpedition
    {
        // Incrementing round number, does not need to be adjusted with overflown rounds
        roundNumber[_elevation] += 1;

        // Failsafe to cover multiple rounds needing to be rolled over if no user rolled them over previously (almost impossible, but just in case)
        uint256 overflownRounds = ((block.timestamp - roundEndTimestamp[_elevation]) / roundDurationSeconds(_elevation));
        
        // Brings current with any extra overflown rounds
        roundEndTimestamp[_elevation] += roundDurationSeconds(_elevation) * overflownRounds;

        // Updates round duration if necessary
        if (pendingDurationMult[_elevation] != durationMult[_elevation]) {
            durationMult[_elevation] = pendingDurationMult[_elevation];
        }

        // Adds the duration of the current round (updated if necessary) to the current round end timestamp
        roundEndTimestamp[_elevation] += roundDurationSeconds(_elevation);

        // Updates elevation allocation multiplier if necessary
        if (pendingAllocMultiplier[_elevation] != allocMultiplier[_elevation]) {
            allocMultiplier[_elevation] = pendingAllocMultiplier[_elevation];
        }
    }


    /// @dev Simple modulo on generated random number to choose the winning totem (inlined for brevity)
    /// @param _elevation Which elevation the winner will be selected for
    /// @param _rand The generated random number to select with
    function chooseWinningTotem(uint8 _elevation, uint256 _rand) internal view returns (uint8) {
        if (_elevation == EXPEDITION)
            return (_rand % 100) < currentDeityDivider() ? 0 : 1;

        return uint8((_rand * totemCount[_elevation]) / 100);
    }


    /// @dev Stores selected winning totem (inlined for brevity)
    /// @param _elevation Elevation to store at
    /// @param _winner Selected winning totem
    function markWinningTotem(uint8 _elevation, uint8 _winner) internal {
        totemWinsAccum[_elevation][_winner] += 1;
        winningTotem[_elevation][roundNumber[_elevation]] = _winner;   

        emit WinningTotemSelected(_elevation, roundNumber[_elevation], _winner);
    }


    /// @dev Sets random deity divider (50 - 90) for next expedition round (inlined for brevity)
    /// @param _rand Same rand that chose winner
    function setNextDeityDivider(uint256 _rand) internal {
        // Number between 50 - 90 based on previous round winning number, helps to balance the divider between the deities
        uint256 expedSelector = (_rand % 100);
        uint256 divider = 50 + ((expedSelector * 40) / 100);
        expeditionDeityDivider[currentExpeditionRound() + 1] = divider;

        emit DeityDividerSelected(currentExpeditionRound() + 1, divider);
    }


    
    
    // ------------------------------------------------------------------
    // --   F R O N T E N D
    // ------------------------------------------------------------------
    
    /// @dev Fetcher of historical data for past winning totems
    /// @param _elevation Which elevation to check historical winners of
    /// @return Array of 20 values, first 10 of which are win count accumulators for each totem, last 10 of which are winners of previous 10 rounds of play
    function historicalWinningTotems(uint8 _elevation) public view allElevations(_elevation) returns (uint256[] memory, uint256[] memory) {

        uint256 round = roundNumber[_elevation];
        uint256 winHistoryDepth = Math.min(10, round);

        uint256[] memory winsAccum = new uint256[](totemCount[_elevation]);
        uint256[] memory prevWinHistory = new uint256[](winHistoryDepth);

        if (_elevation > OASIS) {
            uint256 prevRound = round == 0 ? 0 : round - 1;
            for (uint8 i = 0; i < totemCount[_elevation]; i++) {
                winsAccum[i] = totemWinsAccum[_elevation][i];
            }
            for (uint8 j = 0; j < winHistoryDepth; j++) {
                prevWinHistory[j] = winningTotem[_elevation][prevRound - j];
            }
        }

        return (winsAccum, prevWinHistory);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;


interface ISummitRNGModule {
    function getRandomNumber(uint8 elevation, uint256 roundNumber) external view returns (uint256);
    function setSeedRoundEndTimestamp(uint256 _seedRoundEndTimestamp) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}