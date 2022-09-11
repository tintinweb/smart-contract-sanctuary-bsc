/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-06
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

pragma solidity >= 0.8.15 < 0.9.0;

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

contract XP is IExperienceTracker, IExperienceModifier {

    constructor (address identityProviderAddress_) {
        __identityProvider = IdentityProviderV2(identityProviderAddress_);
    }
    
    mapping (uint256 => uint256) private __xp;
    mapping (uint256 => uint256) private __levels;

    IdentityProviderV2 immutable private __identityProvider;

    event Initialized(uint256 id);
    event ExperienceGained(uint256 indexed id, uint256 amount);

    /**
        @dev Initializes the given id to level 1.
        @dev IDs which have not been initialized cannot be used as in-game playables.
     */
    function initialize(uint256 id_) external {
        require (__levels[id_] == 0, "XP: Already initialized.");
        __levels[id_] = 1;
        emit Initialized(id_);
    }

    /** @dev Increments the level counter for the given token id, if the required amount of XP has been reached */
    function levelUp(uint256 id_) external {
        uint256 currentLevel = __levels[id_];
        require (currentLevel > 0, "XP: Not initialized.");

        uint256 nextLevel = currentLevel + 1;

        uint256 currentXp = __xp[id_];
        uint256 requiredXp = calculateXpForLevel(nextLevel);
        require (currentXp >= requiredXp, "XP: Insufficient experience points.");

        __levels[id_] = nextLevel;
    }

    /** @dev Formula to calculate the amount of XP required for the given level */
    function calculateXpForLevel(uint256 level_) public pure returns(uint256) {
        return (5 * (2*level_**3 + 3*level_**2 + 37*level_ - 42)) / 3;
    }


    /** @dev See `IExperienceModifier.addExperiencePoints(amount, id)` */
    function addExperiencePoints(uint256 amount_, uint256 id_) external {
        __identityProvider.requireContract(msg.sender);
        require (__levels[id_] > 0, "XP: Not initialized.");
        __xp[id_] += amount_;
        emit ExperienceGained(id_, amount_);
    }

    /** @dev See `IExperienceTracker.isInitialized(tokenId)` */
    function isInitialized(uint256 tokenId_) external view override returns(bool) {
        return __levels[tokenId_] > 0;
    }

    /** @dev See `IExperienceTracker.getLevel(tokenId)` */
    function getLevel(uint256 tokenId_) external view override returns(uint256) {
        return __levels[tokenId_];
    }

    /** @dev See `IExperienceTracker.getXp(tokenId)` */
    function getXp(uint256 tokenId_) external view override returns(uint256) {
        return __xp[tokenId_];
    }

}