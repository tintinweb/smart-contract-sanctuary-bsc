// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "./BHeroDetails.sol";
import "./IBHeroDesign.sol";
import "./Utils.sol";

contract BHeroDesign is AccessControlUpgradeable, UUPSUpgradeable, IBHeroDesign {
  struct StatsRange {
    uint256 min;
    uint256 max;
  }

  struct Stats {
    StatsRange stamina;
    StatsRange speed;
    uint256 bombCount;
    StatsRange bombPower;
    uint256 bombRange;
    uint256 ability;
  }

  struct AbilityDesign {
    uint256 minCost;
    uint256 maxCost;
    uint256 incrementalCost;
  }

  using BHeroDetails for BHeroDetails.Details;

  bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
  bytes32 public constant DESIGNER_ROLE = keccak256("DESIGNER_ROLE");

  uint256 private constant COLOR_COUNT = 5;
  uint256 private constant BOMB_SKIN_COUNT = 20;

  // Mapping from rarity to stats.
  mapping(uint256 => Stats) private rarityStats;

  uint256[] private abilityIds;
  uint256 private tokenLimit;
  uint256[] private dropRate;
  uint256 private mintCost;
  uint256 private maxLevel;
  uint256[][] private upgradeCosts;
  uint256[] private abilityRate;
  AbilityDesign[] private abilityDesigns;
  uint256 private skinCount;
  uint256[] private superBoxDropRate;
  uint256 private superBoxMintCost;
  uint256 private senMintCost;
  uint256 private mintCostHeroS;
  uint256 private senMintCostHeroS;
  //using in HeroS
  uint256[] private dropRateHeroS;
  uint256 private constant maskLast8Bits = uint256(0xff);
  uint256 private constant maskFirst248Bits = ~uint256(0xff);
  //number rock need to upgrade shield level
  uint256[][6] private numRockUpgradeShieldLevel;
  //all skins
  uint256[] private skinArr;

  function initialize() public initializer {
    __AccessControl_init();
    __UUPSUpgradeable_init();

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(UPGRADER_ROLE, msg.sender);
    _setupRole(DESIGNER_ROLE, msg.sender);

    rarityStats[0] = Stats(
      StatsRange(1, 3), //
      StatsRange(1, 3),
      1,
      StatsRange(1, 3),
      1,
      1
    );
    rarityStats[1] = Stats(
      StatsRange(3, 6), //
      StatsRange(3, 6),
      2,
      StatsRange(3, 6),
      2,
      2
    );
    rarityStats[2] = Stats(
      StatsRange(6, 9), //
      StatsRange(6, 9),
      3,
      StatsRange(6, 9),
      3,
      3
    );
    rarityStats[3] = Stats(
      StatsRange(9, 12), //
      StatsRange(9, 12),
      4,
      StatsRange(9, 12),
      4,
      4
    );
    rarityStats[4] = Stats(
      StatsRange(12, 15), //
      StatsRange(12, 15),
      5,
      StatsRange(12, 15),
      5,
      5
    );
    rarityStats[5] = Stats(
      StatsRange(15, 18), //
      StatsRange(15, 18),
      6,
      StatsRange(15, 18),
      6,
      6
    );
    abilityIds = [1, 2, 3, 4, 5, 6, 7];
    abilityRate = [1, 2, 1, 1, 1, 2, 2];
    tokenLimit = 500;
    dropRate = [8287, 1036, 518, 104, 52, 4];
    mintCost = 10 ether;
    senMintCost = 5 ether;
    maxLevel = 5;
    upgradeCosts.push([1 ether, 2 ether, 4 ether, 7 ether]);
    upgradeCosts.push([2 ether, 4 ether, 5 ether, 9 ether]);
    upgradeCosts.push([2 ether, 4 ether, 5 ether, 10 ether]);
    upgradeCosts.push([3 ether, 7 ether, 11 ether, 22 ether]);
    upgradeCosts.push([7 ether, 18 ether, 40 ether, 146 ether]);
    upgradeCosts.push([9 ether, 25 ether, 56 ether, 199 ether]);
    abilityDesigns.push(AbilityDesign(2 ether, 2 ether, 0 ether));
    abilityDesigns.push(AbilityDesign(5 ether, 10 ether, 1 ether));
    abilityDesigns.push(AbilityDesign(10 ether, 20 ether, 2 ether));
    abilityDesigns.push(AbilityDesign(20 ether, 40 ether, 4 ether));
    abilityDesigns.push(AbilityDesign(35 ether, 60 ether, 5 ether));
    abilityDesigns.push(AbilityDesign(50 ether, 80 ether, 6 ether));
    skinCount = 10;
    superBoxDropRate = [8424, 1036, 418, 51, 21, 50];
    superBoxMintCost = 50 ether;
    mintCostHeroS = 50 ether;
    senMintCostHeroS = 50 ether;
    dropRateHeroS = [8287, 1036, 518, 104, 52, 4];
    //default apply HeroS
    numRockUpgradeShieldLevel[0] = [0, 0, 0, 0, 0, 0];
    numRockUpgradeShieldLevel[1] = [1, 2, 4, 6, 8, 10];
    numRockUpgradeShieldLevel[2] = [1, 2, 4, 6, 8, 10];
    numRockUpgradeShieldLevel[3] = [1, 2, 4, 6, 8, 10];
    //skin value
    skinArr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 14, 15, 16];
  }

  function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

  function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  /** Sets the rarity stats. */
  function setRarityStats(uint256 rarity, Stats memory stats) external onlyRole(DESIGNER_ROLE) {
    rarityStats[rarity] = stats;
  }

  /** Sets the token limit. */
  function setTokenLimit(uint256 value) external onlyRole(DESIGNER_ROLE) {
    tokenLimit = value;
  }

  /** Sets the drop rate. */
  function setDropRate(uint256[] memory value) external onlyRole(DESIGNER_ROLE) {
    dropRate = value;
  }

  function setDropRateHeroS(uint256[] memory value) external onlyRole(DESIGNER_ROLE) {
    dropRateHeroS = value;
  }

  function setSuperBoxDropRate(uint256[] memory value) external onlyRole(DESIGNER_ROLE) {
    superBoxDropRate = value;
  }

  /** Sets the minting fee. */
  function setMintCost(uint256 value) external onlyRole(DESIGNER_ROLE) {
    mintCost = value;
  }

  function setSenMintCost(uint256 value) external onlyRole(DESIGNER_ROLE) {
    senMintCost = value;
  }

  function setMintCostHeroS(uint256 value) external onlyRole(DESIGNER_ROLE) {
    mintCostHeroS = value;
  }

  function setSenMintCostHeroS(uint256 value) external onlyRole(DESIGNER_ROLE) {
    senMintCostHeroS = value;
  }

  function setSuperBoxMintCost(uint256 value) external onlyRole(DESIGNER_ROLE) {
    superBoxMintCost = value;
  }

  /** Sets max upgrade level. */
  function setMaxLevel(uint256 value) external onlyRole(DESIGNER_ROLE) {
    maxLevel = value;
  }

  /** Sets the current upgrade cost. */
  function setUpgradeCosts(uint256[][] memory value) external onlyRole(DESIGNER_ROLE) {
    upgradeCosts = value;
  }

  function setAbilityRate(uint256[] memory value) external onlyRole(DESIGNER_ROLE) {
    abilityRate = value;
  }

  function setRandomizeAbilityCost(
    uint256 rarity,
    uint256 minCost,
    uint256 maxCost,
    uint256 incrementalCost
  ) external onlyRole(DESIGNER_ROLE) {
    if (abilityDesigns.length > rarity) {
      AbilityDesign storage design = abilityDesigns[rarity];
      design.minCost = minCost;
      design.maxCost = maxCost;
      design.incrementalCost = incrementalCost;
    } else {
      require(abilityDesigns.length == rarity, "Invalid rarity");
      abilityDesigns.push(AbilityDesign(minCost, maxCost, incrementalCost));
    }
  }

  function setSkinVal(uint256[] memory value) external onlyRole(DESIGNER_ROLE) {
    skinArr = value;
  }

  /**
   * Change number rocks need to upgrade shield level
   * level default is 0 => show level 1
   * value is array number rocks needed
   */
  function setNumRockUpgradeShieldLevel(uint256 level, uint256[6] memory value) external onlyRole(DESIGNER_ROLE) {
    numRockUpgradeShieldLevel[level] = value;
  }

  function getRarityStats() external view returns (Stats[] memory) {
    uint256 size = dropRate.length;
    Stats[] memory result = new Stats[](size);
    for (uint256 i = 0; i < size; ++i) {
      result[i] = rarityStats[i];
    }
    return result;
  }

  function getTokenLimit() external view override returns (uint256) {
    return tokenLimit;
  }

  function getDropRate() external view override returns (uint256[] memory) {
    return dropRate;
  }

  function getSuperBoxDropRate() external view returns (uint256[] memory) {
    return superBoxDropRate;
  }

  function getMintCost() external view override returns (uint256) {
    return mintCost;
  }

  function getSenMintCost() external view override returns (uint256) {
    return senMintCost;
  }

  function getSuperBoxMintCost() external view override returns (uint256) {
    return superBoxMintCost;
  }

  function getMintCostHeroS() external view override returns (uint256) {
    return mintCostHeroS;
  }

  function getSenMintCostHeroS() external view override returns (uint256) {
    return senMintCostHeroS;
  }

  function getDropRateHeroS() external view override returns (uint256[] memory) {
    return dropRateHeroS;
  }

  function getMaxLevel() external view override returns (uint256) {
    return maxLevel;
  }

  function getUpgradeCost(uint256 rarity, uint256 level) external view override returns (uint256) {
    return upgradeCosts[rarity][level];
  }

  function getUpgradeCosts() external view returns (uint256[][] memory) {
    return upgradeCosts;
  }

  function getAbilityRate() external view returns (uint256[] memory) {
    return abilityRate;
  }

  function getRandomizeAbilityCost(uint256 rarity, uint256 times) external view override returns (uint256) {
    AbilityDesign storage design = abilityDesigns[rarity];
    uint256 cost = design.minCost + design.incrementalCost * times;
    return MathUpgradeable.min(cost, design.maxCost);
  }

  function getAbilityDesigns() external view returns (AbilityDesign[] memory) {
    return abilityDesigns;
  }

  function getRockUpgradeShieldLevel(uint256 rarity, uint256 level) external view override returns (uint256) {
    return numRockUpgradeShieldLevel[level][rarity];
  }

  function createTokens(
    uint256 tokenId,
    uint256 count,
    uint256 details
  ) external view override returns (uint256[] memory tokenDetails) {
    tokenDetails = new uint256[](count);
    uint256 rarity;
    uint256 targetBlock = details & ((1 << 30) - 1);
    uint256 dropLength = (details >> 40) & 31;
    uint256[] memory dropRateOption = new uint256[](dropLength);
    for (uint256 j = 0; j < dropLength; ++j) {
      dropRateOption[j] = (details >> (45 + j * 15)) & (2**15 - 1);
    }
    require(block.number > targetBlock, "Target block not arrived");
    uint256 seed = uint256(blockhash(targetBlock));
    if (seed == 0) {
      if (rarity == BHeroDetails.ALL_RARITY) {
        // Expired, forced common.
        if (dropLength > 0) {
          for (uint256 k = 0; k < dropLength; ++k) {
            if (dropRateOption[k] > 0) {
              rarity = k + 1;
              break;
            }
          }
        } else {
          // apply hero request before
          rarity = 1;
        }
      }

      // Re-roll seed.
      targetBlock = (block.number & maskFirst248Bits) + (targetBlock & maskLast8Bits);
      if (targetBlock >= block.number) {
        targetBlock -= 256;
      }
      seed = uint256(blockhash(targetBlock));
    }

    for (uint256 i = 0; i < count; ++i) {
      uint256 id = tokenId + i;
      uint256 tokenSeed = uint256(keccak256(abi.encode(seed, id)));
      uint256 detailResult;
      (, detailResult) = createRandomToken(tokenSeed, id, rarity, details, dropRateOption);
      tokenDetails[i] = detailResult;
    }
  }

  function createRandomToken(
    uint256 seedVal,
    uint256 id,
    uint256 rarity,
    uint256 detailsVal,
    uint256[] memory dropRateOption
  ) internal view returns (uint256 nextSeed, uint256 encodedDetails) {
    BHeroDetails.Details memory details;
    details.id = id;

    //fix: Stack too deep
    uint256 seed =seedVal;
    uint256 category = (detailsVal >> 30) & 31;
    bool isHeroS = ((detailsVal >> 35) & 1) == 1;
    uint256 skin = (detailsVal >> 135) & (2**5 - 1);

    bool isFusion = category == 3;
    bool isSuperBox = category == 1;

    if (isHeroS) {
      // Exclusive abilities for hero S.
      uint256[] memory abilityArr = new uint256[](1);
      abilityArr[0] = 1;
      details.abilityHeroS = abilityArr;
    }

    if (rarity == BHeroDetails.ALL_RARITY) {
      //random normal Hero and Super Hero
      (seed, details.rarity) = Utils.weightedRandom(
        seed,
        isSuperBox ? superBoxDropRate : dropRateOption.length > 0 ? dropRateOption : dropRate
      );
    } else {
      // Specified rarity.
      details.rarity = rarity - 1;
    }

    //check fusion action
    if (isFusion) {
      uint256 rarityTarget;
      uint256 maxVal;
      for (uint256 i = 0; i < dropRateOption.length; i++) {
        if (maxVal < dropRateOption[i]) {
          maxVal = dropRateOption[i];
          rarityTarget = i;
        }
      }

      //fusion failed
      if (rarityTarget != details.rarity) {
        return (seed, 0);
      }
    }

    details.level = 1;

    Stats storage stats = rarityStats[details.rarity];
    details.bombCount = stats.bombCount;
    details.bombRange = stats.bombRange;

    (seed, details.color) = Utils.randomRangeInclusive(seed, 1, COLOR_COUNT);
    if (skin == BHeroDetails.ALL_SKIN) {
      //except all event skill
      uint256 indexArr;
      uint256 lengthArr = skinArr.length - 1;
      uint256 seedSkin = seed;
      (seed, indexArr) = Utils.randomRangeInclusive(seedSkin, 0, lengthArr);
      details.skin = skinArr[indexArr];
    } else {
      details.skin = skin; // Start from one.
    }
    (seed, details.stamina) = Utils.randomRangeInclusive(seed, stats.stamina.min, stats.stamina.max);
    (seed, details.speed) = Utils.randomRangeInclusive(seed, stats.speed.min, stats.speed.max);
    (seed, details.bombSkin) = Utils.randomRangeInclusive(seed, 1, BOMB_SKIN_COUNT);
    (seed, details.bombPower) = Utils.randomRangeInclusive(seed, stats.bombPower.min, stats.bombPower.max);
    (seed, details.abilities) = generateAbilities(seed, details.rarity);
    details.blockNumber = block.number;

    nextSeed = seed;
    encodedDetails = details.encode();
  }

  function randomizeAbilities(uint256 seed, uint256 _details)
    external
    view
    override
    returns (uint256 nextSeed, uint256 encodedDetails)
  {
    BHeroDetails.Details memory details = BHeroDetails.decode(_details);
    (seed, details.abilities) = generateAbilities(seed, details.rarity);
    nextSeed = seed;
    encodedDetails = details.encode();
  }

  function generateAbilities(uint256 seed, uint256 rarity)
    internal
    view
    returns (uint256 nextSeed, uint256[] memory abilities)
  {
    uint256[] memory rate = abilityRate;
    if (rarity == 0) {
      // Common, ignore piercing block skill.
      rate[2] = 0;
    }
    Stats storage stats = rarityStats[rarity];
    (seed, abilities) = Utils.weightedRandomSampling(seed, abilityIds, rate, stats.ability);
    nextSeed = seed;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {
  function randomSeed(uint256 seed) internal view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), block.difficulty, seed)));
  }

  /// Random [0, modulus)
  function random(uint256 seed, uint256 modulus) internal view returns (uint256 nextSeed, uint256 result) {
    nextSeed = randomSeed(seed);
    result = nextSeed % modulus;
  }

  /// Random [from, to)
  function randomRange(
    uint256 seed,
    uint256 from,
    uint256 to
  ) internal view returns (uint256 nextSeed, uint256 result) {
    require(from < to, "Invalid random range");
    (nextSeed, result) = random(seed, to - from);
    result += from;
  }

  /// Random [from, to]
  function randomRangeInclusive(
    uint256 seed,
    uint256 from,
    uint256 to
  ) internal view returns (uint256 nextSeed, uint256 result) {
    return randomRange(seed, from, to + 1);
  }

  /// Weighted random.
  function weightedRandom(uint256 seed, uint256[] memory weights)
    internal
    view
    returns (uint256 nextSeed, uint256 index)
  {
    require(weights.length > 0, "Array must not empty");
    uint256 totalWeight;
    for (uint256 i = 0; i < weights.length; ++i) {
      totalWeight += weights[i];
    }
    uint256 randMod;
    (seed, randMod) = randomRange(seed, 0, totalWeight);
    uint256 total;
    for (uint256 i = 0; i < weights.length; i++) {
      total += weights[i];
      if (randMod < total) {
        return (seed, i);
      }
    }
    return (seed, 0);
  }

  /// Reservoir sampling.
  function randomSampling(
    uint256 seed,
    uint256[] storage arr,
    uint256 size
  ) internal view returns (uint256 nextSeed, uint256[] memory result) {
    require(arr.length >= size, "Invalid sampling size");
    result = new uint256[](size);
    for (uint256 i = 0; i < size; ++i) {
      result[i] = arr[i];
    }
    uint256 j;
    for (uint256 i = size; i < arr.length; ++i) {
      (seed, j) = randomRangeInclusive(seed, 0, i);
      if (j < size) {
        result[j] = arr[i];
      }
    }
    nextSeed = seed;
  }

  function weightedRandomSampling(
    uint256 seed,
    uint256[] storage arr,
    uint256[] memory weights,
    uint256 size
  ) internal view returns (uint256 nextSeed, uint256[] memory result) {
    require(arr.length >= size, "Invalid sampling size");
    result = new uint256[](size);
    uint256 index;
    for (uint256 i = 0; i < size; ++i) {
      (seed, index) = weightedRandom(seed, weights);
      weights[index] = 0;
      result[i] = arr[index];
    }
    nextSeed = seed;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBHeroDesign {
  function getTokenLimit() external view returns (uint256);

  function getMintCost() external view returns (uint256);

  function getSenMintCost() external view returns (uint256);

  function getSuperBoxMintCost() external view returns (uint256);

  function getMaxLevel() external view returns (uint256);

  function getUpgradeCost(uint256 rarity, uint256 level) external view returns (uint256);

  function getRandomizeAbilityCost(uint256 rarity, uint256 times) external view returns (uint256);

  function getDropRate() external view returns (uint256[] memory);

  function getDropRateHeroS() external view returns (uint256[] memory);

  function getMintCostHeroS() external view returns (uint256);

  function getSenMintCostHeroS() external view returns (uint256);

  function getRockUpgradeShieldLevel(uint256 rarity, uint256 level) external view returns (uint256);

  function randomizeAbilities(uint256 seed, uint256 details)
    external
    view
    returns (uint256 nextSeed, uint256 encodedDetails);

  function createTokens(uint256 tokenId, uint256 count, uint256 details) external view returns (uint256[] memory tokenDetails);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BHeroDetails {
  uint256 public constant ALL_RARITY = 0;
  uint256 public constant ALL_SKIN = 0;

  struct Details {
    uint256 id;
    uint256 index;
    uint256 rarity;
    uint256 level;
    uint256 color;
    uint256 skin;
    uint256 stamina;
    uint256 speed;
    uint256 bombSkin;
    uint256 bombCount;
    uint256 bombPower;
    uint256 bombRange;
    uint256[] abilities;
    uint256 blockNumber;
    uint256 randomizeAbilityCounter;
    uint256[] abilityHeroS;
    uint256 numResetShield;
    uint256 numUpgradeShieldLevel;
  }

  function encode(Details memory details) internal pure returns (uint256) {
    uint256 value;
    value |= details.id;
    value |= details.index << 30;
    value |= details.rarity << 40;
    value |= details.level << 45;
    value |= details.color << 50;
    value |= details.skin << 55;
    value |= details.stamina << 60;
    value |= details.speed << 65;
    value |= details.bombSkin << 70;
    value |= details.bombCount << 75;
    value |= details.bombPower << 80;
    value |= details.bombRange << 85;
    value |= details.abilities.length << 90;
    for (uint256 i = 0; i < details.abilities.length; ++i) {
      value |= details.abilities[i] << (95 + i * 5);
    }
    value |= details.blockNumber << 145;
    value |= details.randomizeAbilityCounter << 175;

    value |= details.abilityHeroS.length << 180;
    for (uint256 j = 0; j < details.abilityHeroS.length; ++j) {
      value |= details.abilityHeroS[j] << (185 + j * 5);
    }
    value |= details.numUpgradeShieldLevel << 235;
    value |= details.numResetShield << 240;

    return value;
  }

  function decode(uint256 details) internal pure returns (Details memory result) {
    result.id = decodeId(details);
    result.index = decodeIndex(details);
    result.rarity = decodeRarity(details);
    result.level = decodeLevel(details);
    result.color = (details >> 50) & 31;
    result.skin = (details >> 55) & 31;
    result.stamina = (details >> 60) & 31;
    result.speed = (details >> 65) & 31;
    result.bombSkin = (details >> 70) & 31;
    result.bombCount = (details >> 75) & 31;
    result.bombPower = (details >> 80) & 31;
    result.bombRange = (details >> 85) & 31;
    uint256 ability = (details >> 90) & 31;
    result.abilities = new uint256[](ability);
    for (uint256 i = 0; i < ability; ++i) {
      result.abilities[i] = (details >> (95 + i * 5)) & 31;
    }
    result.blockNumber = decodeBlockNumber(details);
    result.randomizeAbilityCounter = decodeRandomizeAbilityCounter(details);

    uint256 abilitySizeHeroS = (details >> 180) & 31;
    result.abilityHeroS = new uint256[](abilitySizeHeroS);
    for (uint256 j = 0; j < abilitySizeHeroS; ++j) {
      result.abilityHeroS[j] = (details >> (185 + j * 5)) & 31;
    }
    result.numUpgradeShieldLevel = (details >> 235) & 31;
    result.numResetShield = (details >> 240) & (2**10 - 1);
  }

  function decodeId(uint256 details) internal pure returns (uint256) {
    return details & ((1 << 30) - 1);
  }

  function decodeIndex(uint256 details) internal pure returns (uint256) {
    return (details >> 30) & ((1 << 10) - 1);
  }

  function decodeRarity(uint256 details) internal pure returns (uint256) {
    return (details >> 40) & 31;
  }

  function decodeLevel(uint256 details) internal pure returns (uint256) {
    return (details >> 45) & 31;
  }

  function decodeBlockNumber(uint256 details) internal pure returns (uint256) {
    return (details >> 145) & ((1 << 30) - 1);
  }

  function decodeRandomizeAbilityCounter(uint256 details) internal pure returns (uint256) {
    return (details >> 175) & 31;
  }

  function increaseLevel(uint256 details) internal pure returns (uint256) {
    uint256 level = decodeLevel(details);
    details &= ~(uint256(31) << 45);
    details |= (level + 1) << 45;
    return details;
  }

  //using to burn heros and reset shield
  function decodeNumResetShield(uint256 details) internal pure returns (uint256) {
    return (details >> 240) & (2**10 - 1);
  }

  function decodeShieldLevel(uint256 details) internal pure returns (uint256) {
    return (details >> 235) & 31;
  }

  function increaseNumResetShield(uint256 details) internal pure returns (uint256) {
    uint256 numResetShield = decodeNumResetShield(details);
    details &= ~(uint256(2**10 - 1) << 240);
    details |= (numResetShield + 1) << 240;
    return details;
  }

  /**
   * default shield level blockchain is 0 - display level 1
   */
  function increaseShieldLevel(uint256 details) internal pure returns (uint256) {
    uint256 level = decodeShieldLevel(details);
    details &= ~(uint256(31) << 235);
    details |= (level + 1) << 235;
    return details;
  }

  function setShieldLevel(uint256 details, uint256 newLevel) internal pure returns (uint256) {
    details &= ~(uint256(31) << 235);
    details |= newLevel << 235;
    return details;
  }

  function increaseRandomizeAbilityCounter(uint256 details) internal pure returns (uint256) {
    uint256 value = decodeRandomizeAbilityCounter(details);
    if (value >= 31) {
      return details;
    }
    details &= ~(uint256(31) << 175);
    details |= (value + 1) << 175;
    return details;
  }

  function setId(uint256 details, uint256 id) internal pure returns (uint256) {
    details &= ~((uint256(1) << 30) - 1);
    details |= id;
    return details;
  }

  function setIndex(uint256 details, uint256 index) internal pure returns (uint256) {
    details &= ~(uint256(1023) << 30);
    details |= index << 30;
    return details;
  }

  function isHeroS(uint256 details) internal pure returns (bool) {
    uint256 length = (details >> 180) & 31;
    return length > 0;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

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
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControlUpgradeable.sol";
import "../utils/ContextUpgradeable.sol";
import "../utils/StringsUpgradeable.sol";
import "../utils/introspection/ERC165Upgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}