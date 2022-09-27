// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces.sol";

// Zai fighting contract for PvE game
// player will give a strategy to his Zai and environment will found a challenger from the same level and create a strategy for him
// player can use potion xp to multiply xp reward and potion with element power to take advantage in fight
// The is a stamina of 5 max (number of fight the Zai can make)
// Stamina is automatic regenerated with time but faster with a Zai state rarity
// Fight will automaticly create and update ranking (xp won) each day and week
// Fight will check delegate data (scholarship)
// fight will give BZAI rewards if zai win the fight (with a limit quantity by day depending on zai state rarity)
contract ZaiFighting is Ownable {
    IAddresses public gameAddresses;
    IZaiNFT public IZai;
    IZaiMeta public IMeta;
    IDelegate public IDel;
    IPotions public Potions;
    IRanking public IRank;
    ILootProgress public ILoot;
    ILevelStorage public ILevel;
    IPayments public IPay;
    IFightingLibrary public IFightLib;
    IRewardsWinningFound public IRewards;
    IStats public Stats;

    bool public inPause;

    uint256 _nonce = 156328739087143210;
    event FightResult(
        uint256 indexed zaiId,
        uint256 challengerId,
        uint256[30] progress
    );
    event RewardFightWon(address indexed user, uint256 amount, uint256 date);

    uint256[4] public staminaRegenerationDuration = [16200, 14400, 10800, 5400]; // in seconds (bronze 4h30 / silver 4h / gold 3h / platinum 1h30 )
    uint256[4] public bzaiRewardCountPerDay = [3, 9, 15, 25]; // Number of fight by day where Zai can get BZAI rewards

    uint256 public xpRewardByFight = 2000;

    mapping(uint256 => uint256) _zaiStamina;
    mapping(uint256 => uint256) _firstOf5FightTimestamp;

    mapping(uint256 => uint256) _lastWinTimestamp;
    mapping(uint256 => uint256) _dayWinCounter;

    constructor(address _library) {
        IFightLib = IFightingLibrary(_library);
    }

    function setGameAddresses(address _address) external onlyOwner {
        require(
            gameAddresses == IAddresses(address(0x0)),
            "game addresses already setted"
        );
        gameAddresses = IAddresses(_address);
    }

    function updateInterfaces() external onlyOwner {
        IZai = IZaiNFT(gameAddresses.getZaiAddress());
        IMeta = IZaiMeta(gameAddresses.getZaiMetaAddress());
        IDel = IDelegate(gameAddresses.getDelegateZaiAddress());
        Potions = IPotions(gameAddresses.getPotionAddress());
        ILoot = ILootProgress(gameAddresses.getLootAddress());
        ILevel = ILevelStorage(gameAddresses.getLevelStorageAddress());
        IPay = IPayments(gameAddresses.getPaymentsAddress());
        IRank = IRanking(gameAddresses.getRankingContract());
        IRewards = IRewardsWinningFound(gameAddresses.getWinRewardsAddress());
        Stats = IStats(gameAddresses.getZaiStatsAddress());
    }

    function pauseUnpauseGame() external onlyOwner {
        inPause = !inPause;
    }

    // For some events there will be more xp available to win
    function setXpRewardByFight(uint256 _xp) external onlyOwner {
        xpRewardByFight = _xp;
    }

    // For some events Zai will be allow to win more or
    function setBzaiRewardCountPerDay(uint256[4] memory _nbOfFight)
        external
        onlyOwner
    {
        bzaiRewardCountPerDay = _nbOfFight;
    }

    // For some events Zai will be allow to make more fight without necessity to regenerate
    function setRegenerationDuration(uint256[4] memory _durations)
        external
        onlyOwner
    {
        staminaRegenerationDuration = _durations;
    }

    function getDayWinByZai(uint256 zaiId) external view returns (uint256) {
        if (_lastWinTimestamp[zaiId] > IRank.getDayBegining()) {
            return _dayWinCounter[zaiId];
        } else {
            return 0;
        }
    }

    function getZaiStamina(uint256 _zaiId)
        external
        view
        returns (uint256 result)
    {
        ZaiStruct.Zai memory z = IMeta.getZai(_zaiId);
        (result, ) = _getZaiStamina(_zaiId, z);
    }

    function _getZaiStamina(uint256 _zaiId, ZaiStruct.Zai memory z)
        internal
        view
        returns (uint256 stamina, uint256 added)
    {
        // if no fight return max stamina : 5
        if (_firstOf5FightTimestamp[_zaiId] == 0) {
            stamina = 5;
        } else {
            // take the old variable
            stamina = _zaiStamina[_zaiId];
            // calculate time passed since the first of 5 last fights
            uint256 _timeSinceLastFight = block.timestamp -
                _firstOf5FightTimestamp[_zaiId];
            // if there is > 1 stamina duration
            if (
                _timeSinceLastFight >=
                staminaRegenerationDuration[z.metadata.state]
            ) {
                // calculate number of stamina to add no need modulo cause in solidity 100 / 60 = 1
                added =
                    _timeSinceLastFight /
                    staminaRegenerationDuration[z.metadata.state];
                // max stamina is 5
                if (stamina + added >= 5) {
                    stamina = 5;
                } else {
                    stamina += added;
                }
            }
        }
    }

    function _updateStamina(uint256 _zaiId, ZaiStruct.Zai memory z)
        internal
        returns (bool)
    {
        //reload
        (uint256 stamina, uint256 added) = _getZaiStamina(_zaiId, z);
        _zaiStamina[_zaiId] = stamina;
        require(_zaiStamina[_zaiId] > 0, "exhausted Zai!");

        if (stamina == 5) {
            _firstOf5FightTimestamp[_zaiId] = block.timestamp;
        } else {
            _firstOf5FightTimestamp[_zaiId] += (added *
                staminaRegenerationDuration[z.metadata.state]);
        }
        // reduce stamina counter
        _zaiStamina[_zaiId] -= 1; //
        return true;
    }

    function useRestPotion(uint256 _zaiId, uint256 _potionId) external {
        require(
            IDel.canUseZai(_zaiId, msg.sender),
            "Not your zai nor delegated"
        );

        require(Potions.ownerOf(_potionId) == msg.sender);
        ZaiStruct.Zai memory z = IMeta.getZai(_zaiId);
        (uint256 stamina, ) = _getZaiStamina(_zaiId, z);
        if (stamina >= 2) {
            revert("Zai doesn't need rest portion");
        }
        // rest for training
        require(ITrainingManagement(gameAddresses.getTrainingCenterAddress()).restFromTraining(_zaiId));
        PotionStruct.Potion memory p = Potions.getFullPotion(_potionId);
        require(p.powers.rest > 0, "Not a rest p");
        Potions.emptyingPotion(_potionId);
        _zaiStamina[_zaiId] += p.powers.rest;
    }

    // _elements (0: water ; 1: fire ; 2:metal ; 3:air ; 4:stone)
    function initFighting(
        uint256 _zaiId,
        uint256[9] memory _elements,
        uint256[9] memory _powers,
        uint256[3] memory _usedPotions
    )
        external
        returns (
            uint256[30] memory result //[0: challengerId,1:myScore, 2:challengerScore, 3-11: ElementByRoundOfChallenger, 12-20: PowerUseByChallengerByRound, 21 number of potions used by challenger, 22-23-24 type of potions if relevent, 25-26-27 power of potions if relevent, 28 xpWon, 29 BZAI won ]
        )
    {
        require(!inPause, "Game is in pause");
        // store delegationDatas for this Zai
        ZaiStruct.ScholarDatas memory scholarDatas = IDel.gotDelegationForZai(
            _zaiId
        );

        // If Zai is in delegation process, Zai can't be used by his owner
        if (scholarDatas.delegateDatas.ownerAddress == msg.sender) {
            require(
                scholarDatas.delegateDatas.scholarAddress == address(0x0),
                "You delegated your Zai"
            );
        }

        // check if zai can be use by msg.sender (owner or got delegation)
        require(
            scholarDatas.delegateDatas.ownerAddress == msg.sender ||
                scholarDatas.delegateDatas.scholarAddress == msg.sender,
            "Not your zai nor delegated"
        );

        // store Zai NFT datas
        ZaiStruct.Zai memory z = IMeta.getZai(_zaiId);
        // check if Zai is not in training, working or coaching. Must be free
        require(z.activity.statusId == 0, "Not free");
        // update stamin of Zai
        require(_updateStamina(_zaiId, z), "Stamina error");

        // update loot progress (weekly reward when you play all days)
        ILoot.updateUserProgress(msg.sender);

        // if msg.sender use potions in this fight, transfer them to fighting smart contract
        for (uint256 i = 0; i < 3; ) {
            if (_usedPotions[i] != 0) {
                require(
                    Potions.ownerOf(_usedPotions[i]) == msg.sender,
                    "Not your potion"
                );
                Potions.burnPotion(_usedPotions[i]);
            } else {
                break;
            }
            unchecked {
                ++i;
            }
        }

        // check if user respect number of powers rule ( don't use more than Zai can use with potions or not)
        (
            uint256[5] memory _gotPowers,
            uint256 _xpMult
        ) = _getZaiPowersByElement(z, _usedPotions);

        require(
            IFightLib.isPowersUsedCorrect(
                _gotPowers,
                IFightLib.getUsedPowersByElement(_elements, _powers)
            ),
            "cheat!"
        );

        // get a challenger (can't be the same Zai used by the user)
        uint256 _challengerId = ILevel.getRandomZaiFromLevel(z.level, _zaiId);

        // store challengerId for futur call of _updateCounterWinLoss
        result[0] = _challengerId;

        // store in memory challenger Zai NFT Datas
        ZaiStruct.Zai memory c = IMeta.getZai(_challengerId);

        // create randoms
        uint256 _randoms = _generateRandomDatas(msg.sender);

        // create challenger pattern
        result = IFightLib.getNewPattern(_randoms, c, result);

        // update the fighting progress in the return array
        result = IFightLib.updateFightingProgress(result, _elements, _powers);

        // update all counters
        result[28] = _getXpToWin(_powers, _gotPowers, _xpMult);
        result = _updateCounterWinLoss(
            z,
            _zaiId,
            result,
            scholarDatas,
            _xpMult
        );

        // create event of fight
        emit FightResult(_zaiId, _challengerId, result);
    }

    function _getXpToWin(
        uint256[9] memory _powers,
        uint256[5] memory _gotPowers,
        uint256 _xpMult
    ) internal view returns (uint256 _xp) {
        uint256 _totalPowers = _gotPowers[0] +
            _gotPowers[1] +
            _gotPowers[2] +
            _gotPowers[3] +
            _gotPowers[4];
        uint256 _totalUsedPowers;
        for (uint256 i = 0; i < 9; ) {
            _totalUsedPowers += _powers[i];
            unchecked {
                ++i;
            }
        }
        // minimum xp to win is xpRewardByFight / 2 => we use * 100 for more precision
        _xp = (xpRewardByFight * 100) / 2;
        // calculate xp :
        // max xp - (half max xp / ratio powers used vs power got) / 100 for more precision
        _xp = ((2 * _xp) - ((_xp / _totalPowers) * _totalUsedPowers)) / 100;

        if (_xpMult > 1) {
            _xp *= _xpMult;
        }
    }

    function _updateCounterWinLoss(
        ZaiStruct.Zai memory z,
        uint256 _zaiId,
        uint256[30] memory _toReturn,
        ZaiStruct.ScholarDatas memory _scholarDatas,
        uint256 _xpMult
    ) internal returns (uint256[30] memory) {
        require(
            Stats.updateCounterWinLoss(_zaiId, _toReturn[0], _toReturn, IRank),
            "Stat issue"
        );

        uint256 _xpWon = xpRewardByFight / 10;
        uint256 _bzaiWon;
        if (_toReturn[1] < _toReturn[2]) {
            _toReturn[28] = _xpWon * _xpMult;
        } else if (_toReturn[1] == _toReturn[2]) {
            _toReturn[28] = _xpWon * 2 * _xpMult;
        } else {
            //Player win
            if (_lastWinTimestamp[_zaiId] < IRank.getDayBegining()) {
                _dayWinCounter[_zaiId] = 1;
            } else {
                _dayWinCounter[_zaiId] += 1;
            }
            _lastWinTimestamp[_zaiId] = block.timestamp;
            if (
                _dayWinCounter[_zaiId] <=
                bzaiRewardCountPerDay[z.metadata.state]
            ) {
                // get reward. there is a bonus when Zai got 2x score of challenger 
                _bzaiWon = IRewards.getWinningRewards(z.level,(_toReturn[1]/2 >= _toReturn[2]));
                if (
                    _scholarDatas.delegateDatas.scholarAddress !=
                    address(0x0) ||
                    _scholarDatas.guildeDatas.renterOf != address(0x0)
                ) {
                    _bzaiWon = _paySchoolarAndOwner(
                        _scholarDatas,
                        _zaiId,
                        _bzaiWon
                    );
                } else {
                    require(
                        IPay.rewardPlayer(
                            _scholarDatas.delegateDatas.ownerAddress,
                            _bzaiWon
                        )
                    );
                    emit RewardFightWon(
                        _scholarDatas.delegateDatas.ownerAddress,
                        _bzaiWon,
                        block.timestamp
                    );
                }
            }
        }
        if (IMeta.updateXp(_zaiId, _toReturn[28]) > z.level) {
            _zaiStamina[_zaiId] = 5;
        }

        require(
            IRank.updatePlayerRankings(
                msg.sender,
                _toReturn[1] < _toReturn[2] ? 200 : _toReturn[1] == _toReturn[2]
                    ? 400
                    : 1000
            ),
            "Ranking error"
        );

        _toReturn[29] = _bzaiWon;
        return _toReturn;
    }

    function _paySchoolarAndOwner(
        ZaiStruct.ScholarDatas memory _scholarDatas,
        uint256 _zaiId,
        uint256 _reward
    ) internal returns (uint256 _scholarReward) {
        uint256 _date = block.timestamp;
        uint256 _ownerReward;
        address _ownerAddress;
        address _scholarAddress;

        if (_scholarDatas.delegateDatas.scholarAddress != address(0x0)) {
            require(IDel.updateLastScholarPlayed(_zaiId));
            _ownerReward =
                (_reward *
                    (100 - _scholarDatas.delegateDatas.percentageForScholar)) /
                100;
            _scholarReward =
                (_reward * _scholarDatas.delegateDatas.percentageForScholar) /
                100;
            _scholarAddress = _scholarDatas.delegateDatas.scholarAddress;
            _ownerAddress = _scholarDatas.delegateDatas.ownerAddress;
        } else {
            _scholarReward =
                (_reward * _scholarDatas.guildeDatas.percentageForScholar) /
                100;
            _ownerReward =
                (_reward * _scholarDatas.guildeDatas.percentageForGuilde) /
                100;

            _scholarAddress = _scholarDatas.guildeDatas.renterOf;
            _ownerAddress = _scholarDatas.guildeDatas.masterOf;

            require(
                IPay.rewardPlayer(
                    _scholarDatas.guildeDatas.platformAddress,
                    (_reward *
                        _scholarDatas.guildeDatas.percentagePlatformFees) / 100
                )
            );
        }

        emit RewardFightWon(_scholarAddress, _scholarReward, _date);
        emit RewardFightWon(
            _scholarDatas.delegateDatas.ownerAddress,
            _ownerReward,
            _date
        );

        require(IPay.rewardPlayer(_ownerAddress, _ownerReward));
        require(IPay.rewardPlayer(_scholarAddress, _scholarReward));
    }

    function _getZaiPowersByElement(
        ZaiStruct.Zai memory z,
        uint256[3] memory _potions
    ) internal view returns (uint256[5] memory _powers, uint256 _xpMult) {
        _powers = [
            z.powers.water,
            z.powers.fire,
            z.powers.metal,
            z.powers.air,
            z.powers.stone
        ];
        _xpMult = 1;

        if (_potions.length > 0) {
            for (uint256 i = 0; i < _potions.length; i++) {
                PotionStruct.Potion memory p = Potions.getFullPotion(
                    _potions[i]
                );

                if (p.powers.water > 0) {
                    _powers[0] += p.powers.water;
                }
                if (p.powers.fire > 0) {
                    _powers[1] += p.powers.fire;
                }
                if (p.powers.metal > 0) {
                    _powers[2] += p.powers.metal;
                }
                if (p.powers.air > 0) {
                    _powers[3] += p.powers.air;
                }
                if (p.powers.stone > 0) {
                    _powers[4] += p.powers.stone;
                }
                if (p.powers.xp > 0) {
                    require(_xpMult == 1, "Only 1 xp potion by fight");
                    _xpMult = p.powers.xp;
                }
            }
        }
    }

    // utils
    function _generateRandomDatas(address _user) private returns (uint256) {
        _nonce = IOracle(gameAddresses.getOracleAddress()).getRandom(
            keccak256(abi.encodePacked(_user, _nonce, block.timestamp))
        );

        return (_nonce);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library ZaiStruct {
    // Zai powers
    struct Powers {
        uint256 water;
        uint256 fire;
        uint256 metal;
        uint256 air;
        uint256 stone;
    }

    // A zai can work in a center , training or coaching. He can't fight if he isn't free
    //string[4] _status = ["Free","Training","Coaching","Working"];
    struct Activity {
        uint256 statusId;
        uint256 onCenter;
    }

    struct ZaiMetaData {
        uint256 state; // _states index
        uint256 ipfsPathId;
        uint256 seasonOf;
        bool isGod;
    }

    struct Zai {
        uint256 xp;
        uint256 manaMax;
        uint256 mana;
        uint256 level;
        uint256 creditForUpgrade; // credit to use to raise powers
        string name;
        Powers powers;
        Activity activity;
        ZaiMetaData metadata;
    }

    struct Stats {
        uint256 zaiTotalWins;
        uint256 zaiTotalDraw;
        uint256 zaiTotalLoss;
        uint256 zaiTotalFights;
    }

    struct EggsPrices {
        uint256 bronzePrice;
        uint256 silverPrice;
        uint256 goldPrice;
        uint256 platinumPrice;
    }

    struct MintedData {
        uint256 bronzeMinted;
        uint256 silverMinted;
        uint256 goldMinted;
        uint256 platinumMinted;
    }

    struct WorkInstance {
        uint256 zaiId;
        uint256 beginingAt;
    }

    struct DelegateData {
        address scholarAddress;
        address ownerAddress;
        uint256 contractDuration;
        uint256 contractEnd;
        uint256 percentageForScholar;
        uint256 lastScholarPlayed;
        bool renewable;
    }

    struct GuildeDatas {
        address renterOf;
        address masterOf;
        address platformAddress;
        uint256 percentageForScholar;
        uint256 percentageForGuilde;
        uint256 percentagePlatformFees;
    }

    struct ScholarDatas {
        GuildeDatas guildeDatas;
        DelegateData delegateDatas;
    }
}

library PotionStruct {
    struct Powers {
        uint256 water;
        uint256 fire;
        uint256 metal;
        uint256 air;
        uint256 stone;
        uint256 rest;
        uint256 xp;
        uint256 mana;
    }

    struct Potion {
        Powers powers;
        uint256 potionType; // 0: water ; 1: fire ; 2:metal ; 3:air ; 4:stone  ; 5:rest ; 6:xp ; 7:multiple ; 99 : empty
        address seller;
        uint256 listingPrice;
        uint256 fromLab;
        uint256 potionId;
        uint256 saleTimestamp;
    }
}

interface IOracle {
    function getRandom(bytes32 _id) external returns (uint256);
}

interface IZaiMeta {
    function getZaiURI(uint256 tokenId) external view returns (string memory);

    function createZaiDatas(
        uint256 _newItemId,
        string memory _name,
        uint256 _state,
        address _to,
        uint256 _level
    ) external;

    function getZai(uint256 _tokenId)
        external
        view
        returns (ZaiStruct.Zai memory);

    function getZaiState(uint256 _tokenId)
        external
        view
        returns (string memory);

    function getStatus(uint256 _tokenId)
        external
        view
        returns (uint256[2] memory);

    function isFree(uint256 _tokenId) external view returns (bool);

    function updateStatus(
        uint256 _tokenId,
        uint256 _newStatusID,
        uint256 _center
    ) external;

    function updateXp(uint256 _id, uint256 _xp)
        external
        returns (uint256 level);

    function updateMana(
        uint256 _tokenId,
        uint256 _manaUp,
        uint256 _manaDown,
        uint256 _maxUp
    ) external returns (bool);

    function getNextLevelUpPoints(uint256 _level)
        external
        view
        returns (uint256);
}

interface IZaiNFT is IERC721Enumerable {
    function mintZai(
        address _to,
        string memory _name,
        uint256 _state
    ) external returns (uint256);

    function createNewChallenger() external returns (uint256);

    function isFree(uint256 _tokenId) external view returns (bool);

    function getZai(uint256 _tokenId)
        external
        view
        returns (ZaiStruct.Zai memory);

    function getNextLevelUpPoints(uint256 _level)
        external
        view
        returns (uint256);
}

interface IipfsIdStorage {
    function getTokenURI(
        uint256 _season,
        uint256 _state,
        uint256 _id
    ) external view returns (string memory);

    function getNextIpfsId(uint256 _state, uint256 _nftId)
        external
        returns (uint256);

    function getCurrentSeason() external view returns (uint256);
}

interface ILaboratory is IERC721Enumerable {
    function mintLaboratory(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function getCreditLastUpdate(uint256 _tokenId)
        external
        view
        returns (uint256);

    function updateCreditLastUpdate(uint256 _tokenId) external returns (bool);

    function numberOfWorkingSpots(uint256 _tokenId)
        external
        view
        returns (uint256);

    function updateNumberOfWorkingSpots(uint256 _tokenId)
        external
        returns (bool);

    function getPreMintNumber() external view returns (uint256);
}

interface ILabManagement {
    function createdPotionsForLab(uint256 _tokenId)
        external
        view
        returns (uint256);

    function laboratoryRevenues(uint256 _tokenId)
        external
        view
        returns (uint256);

    function getCredit(uint256 _laboId) external view returns (uint256);

    function workingSpot(uint256 _laboId, uint256 _slotId)
        external
        view
        returns (ZaiStruct.WorkInstance memory);

    function cleanSlotsBeforeClosing(uint256 _laboId) external returns (bool);
}

interface IBZAI is IERC20 {
    function burn(uint256 _amount) external returns (bool);
}

interface ITraining is IERC721Enumerable {
    function mintTrainingCenter(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function numberOfTrainingSpots(uint256 _tokenId)
        external
        view
        returns (uint256);

    function addTrainingSpots(uint256 _tokenId, uint256 _amount)
        external
        returns (bool);

    function getPreMintNumber() external view returns (uint256);
}

interface ITrainingManagement {
    function cleanSlotsBeforeClosing(uint256 _laboId) external returns (bool);

    function getZaiLastTrainBegining(uint256 _zaiId)
        external
        view
        returns (uint256);

    function restFromTraining(uint256 _zaiId) external returns(bool);
}

interface INursery is IERC721Enumerable {
    function nextStateToMint(uint256 _tokenId) external view returns (uint256);

    function getEggsPrices(uint256 _nursId)
        external
        view
        returns (ZaiStruct.EggsPrices memory);

    function getNurseryMintedDatas(uint256 _tokenId)
        external
        view
        returns (ZaiStruct.MintedData memory);

    function getNextUnlock(uint256 _tokenId) external view returns (uint256);

    function getPreMintNumber() external view returns (uint256);

    function nurseryRevenues(uint256 _tokenId) external view returns (uint256);

    function nurseryMintedDatas(uint256 _tokenId)
        external
        view
        returns (ZaiStruct.MintedData memory);
}

interface IBZAIToken {
    function burnToken(uint256 _amount) external;
}

interface IPayments {
    function payOwner(address _owner, uint256 _value) external returns (bool);

    function getMyReward(address _user) external view returns (uint256);

    function distributeFees(uint256 _amount) external returns (bool);

    function rewardPlayer(address _user, uint256 _amount)
        external
        returns (bool);

    function getMyCentersRevenues(address _user)
        external
        view
        returns (uint256);

    function burnRevenuesForEggs(address _owner, uint256 _amount)
        external
        returns (bool);

    function payNFTOwner(address _owner, uint256 _amount)
        external
        returns (bool);

    function payRNFT(uint256 _amount) external returns (bool);

    function payWithRewardOrWallet(address _user, uint256 _amount)
        external
        returns (bool);
}

interface IEggs is IERC721Enumerable {
    function mintEgg(
        address _to,
        uint256 _state,
        uint256 _maturityDuration
    ) external returns (uint256);

    function burnEgg(uint256 _tokenId) external returns (bool);

    function isMature(uint256 _tokenId) external view returns (bool);

    function getStateIndex(uint256 _tokenId) external view returns (uint256);
}

interface IPotions is IERC721Enumerable {
    function mintPotionForSale(
        uint256 _fromLab,
        uint256 _price,
        uint256 _type,
        uint256 _power
    ) external returns (uint256);

    function offerPotion(
        uint256 _type,
        uint256 _power,
        address _to
    ) external returns (uint256);

    function updatePotion(uint256 _tokenId) external;

    function burnPotion(uint256 _tokenId) external returns (bool);

    function emptyingPotion(uint256 _tokenId) external returns(bool); 

    function mintMultiplePotion(uint256[7] memory _powers, address _owner)
        external
        returns (uint256);

    function changePotionPrice(
        uint256 _tokenId,
        uint256 _laboId,
        uint256 _price
    ) external returns (bool);

    function updatePotionSaleTimestamp(uint256 _tokenId)
        external
        returns (bool);

    function getFullPotion(uint256 _tokenId)
        external
        view
        returns (PotionStruct.Potion memory);
}

interface IAddresses {
    function getBZAIAddress() external view returns (address);

    function getOracleAddress() external view returns (address);

    function getZaiAddress() external view returns (address);

    function getZaiMetaAddress() external view returns (address);

    function getIpfsStorageAddress() external view returns (address);

    function getLaboratoryAddress() external view returns (address);

    function getLaboratoryNFTAddress() external view returns (address);

    function getTrainingCenterAddress() external view returns (address);

    function getTrainingNFTAddress() external view returns (address);

    function getNurseryAddress() external view returns (address);

    function getPotionAddress() external view returns (address);

    function getFightAddress() external view returns (address);

    function getEggsAddress() external view returns (address);

    function getMarketZaiAddress() external view returns (address);

    function getPaymentsAddress() external view returns (address);

    function getChallengeRewardsAddress() external view returns (address);

    function getWinRewardsAddress() external view returns (address);

    function getOpenAndCloseAddress() external view returns (address);

    function getAlchemyAddress() external view returns (address);

    function getWinChallengeAddress() external view returns (address);

    function isAuthToManagedNFTs(address _address) external view returns (bool);

    function isAuthToManagedPayments(address _address)
        external
        view
        returns (bool);

    function getLevelStorageAddress() external view returns (address);

    function getRankingContract() external view returns (address);

    function getAuthorizedSigner() external view returns (address);

    function getDelegateZaiAddress() external view returns (address);

    function getZaiStatsAddress() external view returns (address);

    function getLootAddress() external view returns (address);

    function getClaimNFTsAddress() external view returns (address);

    function getRentMyNftAddress() external view returns (address);

    function getChickenAddress() external view returns (address);

    function getPvPAddress() external view returns (address);

    function getRewardsPvPAddress() external view returns (address);
}

interface IOpenAndClose {
    function getLaboCreatingTime(uint256 _tokenId)
        external
        view
        returns (uint256);

    function canLaboSell(uint256 _tokenId) external view returns (bool);

    function canTrain(uint256 _tokenId) external view returns (bool);

    function laboratoryMinted() external view returns (uint256);

    function trainingCenterMinted() external view returns (uint256);

    function getLaboratoryName(uint256 _tokenId)
        external
        view
        returns (string memory);

    function getNurseryName(uint256 _tokenId)
        external
        view
        returns (string memory);

    function getTrainingCenterName(uint256 _tokenId)
        external
        view
        returns (string memory);

    function getLaboratoryState(uint256 _tokenId)
        external
        view
        returns (string memory);
}

interface IReserveForChalengeRewards {
    function updateRewards() external returns (bool);
}

interface IReserveForWinRewards {
    function updateRewards() external returns (bool);
}

interface ILevelStorage {
    function addFighter(uint256 _level, uint256 _zaiId) external returns (bool);

    function removeFighter(uint256 _level, uint256 _zaiId)
        external
        returns (bool);

    function getLevelLength(uint256 _level) external view returns (uint256);

    function getRandomZaiFromLevel(uint256 _level, uint256 _idForbiden)
        external
        returns (uint256 _zaiId);
}

interface IRewardsRankingFound {
    function getDailyRewards(address _rewardStoringAddress)
        external
        returns (uint256);

    function getWeeklyRewards(address _rewardStoringAddress)
        external
        returns (uint256);
}

interface IRewardsWinningFound {
    function getWinningRewards(uint256 level, bool bonus) external returns (uint256);
}

interface IRewardsPvP {
    function getWinningRewards() external returns (uint256);
}

interface IRanking {
    function updatePlayerRankings(address _user, uint256 _xpWin)
        external
        returns (bool);

    function getDayBegining() external view returns (uint256);

    function getDayAndWeekRankingCounter()
        external
        view
        returns (uint256 dayNumber, uint256 weekNumber);
}

interface IDelegate {
    function gotDelegationForZai(uint256 _zaiId)
        external
        view
        returns (ZaiStruct.ScholarDatas memory scholarDatas);

    function canUseZai(uint256 _zaiId, address _user)
        external
        view
        returns (bool);

    function getDelegateDatasByZai(uint256 _zaiId)
        external
        view
        returns (ZaiStruct.DelegateData memory);

    function isZaiDelegated(uint256 _zaiId) external view returns (bool);

    function updateLastScholarPlayed(uint256 _zaiId) external returns (bool);
}

interface IStats {
    function updateCounterWinLoss(
        uint256 _zaiId,
        uint256 _challengerId,
        uint256[30] memory _fightProgress,
        IRanking IRank
    ) external returns (bool);

    function getZaiStats(uint256 _zaiId)
        external
        view
        returns (uint256[4] memory);

    function updateAllPowersInGame(ZaiStruct.Powers memory toAdd)
        external
        returns (bool);


    function reduceAllPowersInGame(ZaiStruct.Powers memory toReduce)
        external
        returns (bool);
}

interface IFighting {
    function getZaiStamina(uint256 _zaiId) external view returns (uint256);

    function getDayWinByZai(uint256 zaiId) external view returns (uint256);
}

interface IFightingLibrary {
    function updateFightingProgress(
        uint256[30] memory _toReturn,
        uint256[9] memory _elements,
        uint256[9] memory _powers
    ) external pure returns (uint256[30] memory);

    function getUsedPowersByElement(
        uint256[9] memory _elements,
        uint256[9] memory _powers
    ) external pure returns (uint256[5] memory);

    function isPowersUsedCorrect(
        uint256[5] memory _got,
        uint256[5] memory _used
    ) external pure returns (bool);

    function getNewPattern(
        uint256 _random,
        ZaiStruct.Zai memory c,
        uint256[30] memory _toReturn
    ) external pure returns (uint256[30] memory result);
}

interface ILootProgress {
    function updateUserProgress(address _user) external;
}

interface IGuildeDelegation {
    function getRentingDatas(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (ZaiStruct.GuildeDatas memory);
}

interface IChicken {
    function mintChicken(address _to) external returns (uint256);
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
interface IERC165 {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}