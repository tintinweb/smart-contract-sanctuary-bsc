/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;


// Copyright © 2021 Anton "BaldyAsh" Grigorev. All rights reserved.
struct NFTConfig {
    address lootboxAddress;
    address rarityCalculator;
}

struct RarityRates {
    uint8 common;
    uint8 rare;
    uint8 epic;
    uint8 legendary;
}

struct HashrateMultipliers {
    uint8[3] common;
    uint8[3] rare;
    uint8[3] epic;
    uint8[3] legendary;
}

struct VoteDiscounts {
    uint8[3] common;
    uint8[3] rare;
    uint8[3] epic;
    uint8[3] legendary;
}

enum Rarity {
    Common,
    Rare,
    Epic,
    Legendary
}

enum Level {
    Gen0,
    Gen1,
    Gen2
}

// Copyright © 2021 Anton "BaldyAsh" Grigorev. All rights reserved.
interface IRarityCalculator {
    function calculateRarityAndHashrate(
        uint256 blockNumber,
        uint256 id,
        address owner
    ) external view returns (Rarity, uint256);

    function getHashrate(
        Level level,
        Rarity rarity,
        uint256 baseHashrate
    ) external pure returns (uint256);

    function getVoteMultiplier(Level level, Rarity rarity) external pure returns (uint256);

    function getVoteDiscount(Level level, Rarity rarity) external pure returns (uint256);
}

// Copyright © 2021 Anton "BaldyAsh" Grigorev. All rights reserved.
library NFTConstants {
    uint8 internal constant HASHRATE_MULTIPLIERS_COMMON_GEN0 = 10;
    uint8 internal constant HASHRATE_MULTIPLIERS_COMMON_GEN1 = 40;
    uint8 internal constant HASHRATE_MULTIPLIERS_COMMON_GEN2 = 120;

    uint8 internal constant HASHRATE_MULTIPLIERS_RARE_GEN0 = 10;
    uint8 internal constant HASHRATE_MULTIPLIERS_RARE_GEN1 = 30;
    uint8 internal constant HASHRATE_MULTIPLIERS_RARE_GEN2 = 75;

    uint8 internal constant HASHRATE_MULTIPLIERS_EPIC_GEN0 = 10;
    uint8 internal constant HASHRATE_MULTIPLIERS_EPIC_GEN1 = 25;
    uint8 internal constant HASHRATE_MULTIPLIERS_EPIC_GEN2 = 50;

    uint8 internal constant HASHRATE_MULTIPLIERS_LEGENDARY_GEN0 = 10;
    uint8 internal constant HASHRATE_MULTIPLIERS_LEGENDARY_GEN1 = 20;
    uint8 internal constant HASHRATE_MULTIPLIERS_LEGENDARY_GEN2 = 30;

    uint8 internal constant VOTE_MULTIPLIER_COMMON_GEN0 = 100;
    uint8 internal constant VOTE_MULTIPLIER_COMMON_GEN1 = 99;
    uint8 internal constant VOTE_MULTIPLIER_COMMON_GEN2 = 98;

    uint8 internal constant VOTE_MULTIPLIER_RARE_GEN0 = 100;
    uint8 internal constant VOTE_MULTIPLIER_RARE_GEN1 = 98;
    uint8 internal constant VOTE_MULTIPLIER_RARE_GEN2 = 96;

    uint8 internal constant VOTE_MULTIPLIER_EPIC_GEN0 = 100;
    uint8 internal constant VOTE_MULTIPLIER_EPIC_GEN1 = 96;
    uint8 internal constant VOTE_MULTIPLIER_EPIC_GEN2 = 94;

    uint8 internal constant VOTE_MULTIPLIER_LEGENDARY_GEN0 = 100;
    uint8 internal constant VOTE_MULTIPLIER_LEGENDARY_GEN1 = 94;
    uint8 internal constant VOTE_MULTIPLIER_LEGENDARY_GEN2 = 92;

    uint8 internal constant COMMON_RATE = 69;
    uint8 internal constant RARE_RATE = 94;
    uint8 internal constant EPIC_RATE = 99;
    uint8 internal constant LEGENDARY_RATE = 100;

    uint8 internal constant MAX_LEVEL = 2;

    uint256 internal constant COMMON_RANGE_MAX = 20;
    uint256 internal constant COMMON_RANGE_MIN = 10;

    uint256 internal constant RARE_RANGE_MAX = 55;
    uint256 internal constant RARE_RANGE_MIN = 27;

    uint256 internal constant EPIC_RANGE_MAX = 275;
    uint256 internal constant EPIC_RANGE_MIN = 125;

    uint256 internal constant LEGENDARY_RANGE_MAX = 1400;
    uint256 internal constant LEGENDARY_RANGE_MIN = 650;
}

// Copyright © 2021 Anton "BaldyAsh" Grigorev. All rights reserved.
library NFTErrors {
    error NoPermission();
    error SameAddress();
    error SameConfig();
    error SameRates();
    error WrongRarity();
    error Overflow();
    error UnexistingToken();
    error SameValue();
    error WrongLevel();
    error MaxLevel();
}

// Copyright © 2021 Anton "BaldyAsh" Grigorev. All rights reserved.
contract RarityCalculator is IRarityCalculator {
    //solhint-disable code-complexity
    //solhint-disable function-max-lines

    function calculateRarityAndHashrate(
        uint256 blockNumber,
        uint256 id,
        address owner
    ) external view override returns (Rarity, uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(blockhash(blockNumber), id, owner)));
        uint256 rarityRate = random % NFTConstants.LEGENDARY_RATE;
        uint256 randomForRange = (random - (random % 10));
        if (rarityRate < NFTConstants.COMMON_RATE) {
            uint256 range = NFTConstants.COMMON_RANGE_MAX - NFTConstants.COMMON_RANGE_MIN + 1;
            return (Rarity.Common, (randomForRange % range) + NFTConstants.COMMON_RANGE_MIN);
        } else if (rarityRate < NFTConstants.RARE_RATE) {
            uint256 range = NFTConstants.RARE_RANGE_MAX - NFTConstants.RARE_RANGE_MIN + 1;
            return (Rarity.Rare, (randomForRange % range) + NFTConstants.RARE_RANGE_MIN);
        } else if (rarityRate < NFTConstants.EPIC_RATE) {
            uint256 range = NFTConstants.EPIC_RANGE_MAX - NFTConstants.EPIC_RANGE_MIN + 1;
            return (Rarity.Epic, (randomForRange % range) + NFTConstants.EPIC_RANGE_MIN);
        } else if (rarityRate < NFTConstants.LEGENDARY_RATE) {
            uint256 range = NFTConstants.LEGENDARY_RANGE_MAX - NFTConstants.LEGENDARY_RANGE_MIN + 1;
            return (Rarity.Legendary, (randomForRange % range) + NFTConstants.LEGENDARY_RANGE_MIN);
        } else {
            revert NFTErrors.Overflow();
        }
    }

    function getHashrate(
        Level level,
        Rarity rarity,
        uint256 baseHashrate
    ) external pure override returns (uint256) {
        if (rarity == Rarity.Common) {
            if (level == Level.Gen0) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_COMMON_GEN0;
            } else if (level == Level.Gen1) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_COMMON_GEN1;
            } else if (level == Level.Gen2) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_COMMON_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else if (rarity == Rarity.Rare) {
            if (level == Level.Gen0) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_RARE_GEN0;
            } else if (level == Level.Gen1) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_RARE_GEN1;
            } else if (level == Level.Gen2) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_RARE_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else if (rarity == Rarity.Epic) {
            if (level == Level.Gen0) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_EPIC_GEN0;
            } else if (level == Level.Gen1) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_EPIC_GEN1;
            } else if (level == Level.Gen2) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_EPIC_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else if (rarity == Rarity.Legendary) {
            if (level == Level.Gen0) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_LEGENDARY_GEN0;
            } else if (level == Level.Gen1) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_LEGENDARY_GEN1;
            } else if (level == Level.Gen2) {
                return baseHashrate * NFTConstants.HASHRATE_MULTIPLIERS_LEGENDARY_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else {
            revert NFTErrors.WrongRarity();
        }
    }

    function getVoteDiscount(Level level, Rarity rarity) external pure override returns (uint256) {
        return 100 - getVoteMultiplier(level, rarity);
    }

    function getVoteMultiplier(Level level, Rarity rarity) public pure override returns (uint256) {
        if (rarity == Rarity.Common) {
            if (level == Level.Gen0) {
                return NFTConstants.VOTE_MULTIPLIER_COMMON_GEN0;
            } else if (level == Level.Gen1) {
                return NFTConstants.VOTE_MULTIPLIER_COMMON_GEN1;
            } else if (level == Level.Gen2) {
                return NFTConstants.VOTE_MULTIPLIER_COMMON_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else if (rarity == Rarity.Rare) {
            if (level == Level.Gen0) {
                return NFTConstants.VOTE_MULTIPLIER_RARE_GEN0;
            } else if (level == Level.Gen1) {
                return NFTConstants.VOTE_MULTIPLIER_RARE_GEN1;
            } else if (level == Level.Gen2) {
                return NFTConstants.VOTE_MULTIPLIER_RARE_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else if (rarity == Rarity.Epic) {
            if (level == Level.Gen0) {
                return NFTConstants.VOTE_MULTIPLIER_EPIC_GEN0;
            } else if (level == Level.Gen1) {
                return NFTConstants.VOTE_MULTIPLIER_EPIC_GEN1;
            } else if (level == Level.Gen2) {
                return NFTConstants.VOTE_MULTIPLIER_EPIC_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else if (rarity == Rarity.Legendary) {
            if (level == Level.Gen0) {
                return NFTConstants.VOTE_MULTIPLIER_LEGENDARY_GEN0;
            } else if (level == Level.Gen1) {
                return NFTConstants.VOTE_MULTIPLIER_LEGENDARY_GEN1;
            } else if (level == Level.Gen2) {
                return NFTConstants.VOTE_MULTIPLIER_LEGENDARY_GEN2;
            } else {
                revert NFTErrors.WrongLevel();
            }
        } else {
            revert NFTErrors.WrongRarity();
        }
    }

    //solhint-enable code-complexity
    //solhint-enable function-max-lines
}