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
    IZaiMeta public IMeta;
    IDelegate public IDel;
    IPotions public Potions;
    IRanking public IRank;
    ILootProgress public ILoot;
    ILevelStorage public ILevel;
    IPayments public IPay;
    IFightingLibrary public IFightLib;
    IRewardsWinningFound public IRewards;
    IOracle public Oracle;
    //IStats public Stats;

    bool public inPause;

    uint256[4] public staminaRegenerationDuration = [16200, 14400, 10800, 5400]; // in seconds (bronze 4h30 / silver 4h / gold 3h / platinum 1h30 )
    // UPDATE AUDIT : platinum got 50
    uint256[4] public bzaiRewardCountPerDay = [3, 8, 15, 50]; // Number of fight by day where Zai can get BZAI rewards
    // UPDATE AUDIT : 2000 => 4000 (game xp balance update)
    uint256 public xpRewardByFight = 4000;

    mapping(uint256 => uint256) _zaiStamina;
    mapping(uint256 => uint256) _firstOf5FightTimestamp;

    mapping(uint256 => uint256) _lastWinTimestamp;
    mapping(uint256 => uint256) _dayWinCounter;

    event FightResult(
        address indexed player,
        uint256 indexed zaiId,
        uint256[30] progress,
        uint256[9] elements,
        uint256[9] powers
    );
    // UPDATE AUDIT : RewardFightWon => RewardWon is in payment contract now

    event GameAddressesSetted(address gameAddresses);
    event InterfacesUpdated(address zaiNFT, address delegate, address potions, address ranking,address loot, address level, address payments,address rewards, address oracle);
    event PauseActivated(bool isOnPause);
    event XpRewardUpdated(uint256 previousValue, uint256 newValue);
    event BzaiRewardCountPerDayUpdated(uint256[4] previousDatas, uint256[4] newDatas);
    event RegenerationDurationUpdated(uint256[4] previousDatas, uint256[4] newDatas);
    event RestPotionUsed(address user, uint256 indexed zaiId, uint256 potionId);

    constructor(address _library) {
        IFightLib = IFightingLibrary(_library);
    }

    function setGameAddresses(address _address) external onlyOwner {
        require(gameAddresses == IAddresses(address(0x0)), "Already setted");
        gameAddresses = IAddresses(_address);
        emit GameAddressesSetted(_address);
    }

    function updateInterfaces() external {
        IMeta = IZaiMeta(gameAddresses.getAddressOf(AddressesInit.Addresses.ZAI_META));
        IDel = IDelegate(gameAddresses.getAddressOf(AddressesInit.Addresses.DELEGATE));
        Potions = IPotions(gameAddresses.getAddressOf(AddressesInit.Addresses.POTIONS_NFT));
        ILoot = ILootProgress(gameAddresses.getAddressOf(AddressesInit.Addresses.LOOT));
        ILevel = ILevelStorage(gameAddresses.getAddressOf(AddressesInit.Addresses.LEVEL_STORAGE));
        IPay = IPayments(gameAddresses.getAddressOf(AddressesInit.Addresses.PAYMENTS));
        IRank = IRanking(gameAddresses.getAddressOf(AddressesInit.Addresses.RANKING));
        IRewards = IRewardsWinningFound(gameAddresses.getAddressOf(AddressesInit.Addresses.REWARDS_WINNING_PVE));
        Oracle = IOracle(gameAddresses.getAddressOf(AddressesInit.Addresses.ORACLE));
        emit InterfacesUpdated(address(IMeta), address(IDel), address(Potions), address(IRank), address(ILoot), address(ILevel), address(IPay), address(IRewards), address(Oracle));
    }

    function pauseUnpauseGame() external onlyOwner {
        inPause = !inPause;
        emit PauseActivated(inPause);
    }

    // For some events there will be more xp available to win
    function setXpRewardByFight(uint256 _xp) external onlyOwner {
        uint256 _previousValue = xpRewardByFight;
        xpRewardByFight = _xp;
        emit XpRewardUpdated(_previousValue, _xp);
    }

    // For some events Zai will be allow to win more or
    function setBzaiRewardCountPerDay(uint256[4] memory _nbOfFight)
        external
        onlyOwner
    {
        uint256[4] memory _previousDatas = bzaiRewardCountPerDay;
        bzaiRewardCountPerDay = _nbOfFight;
        emit BzaiRewardCountPerDayUpdated(_previousDatas, _nbOfFight);
    }

    // For some events Zai will be allow to make more fight without necessity to regenerate
    function setRegenerationDuration(uint256[4] memory _durations)
        external
        onlyOwner
    {
        uint256[4] memory _previousDatas = staminaRegenerationDuration;
        staminaRegenerationDuration = _durations;
        emit RegenerationDurationUpdated(_previousDatas, _durations);
    }

    function getDayWinByZai(uint256 zaiId) external view returns (uint256) {
        if (_lastWinTimestamp[zaiId] > IRank.getDayBegining()) {
            return _dayWinCounter[zaiId];
        } else {
            return 0;
        }
    }

   // UPDATE AUDIT : return next fight unlocking timestamp for front end
    function getZaiStamina(uint256 _zaiId)
        external
        view
        returns (uint256 result, uint256 nextUnlockingFight) 
    {
        ZaiStruct.ZaiMinDatasForFight memory z = IMeta.getZaiMinDatasForFight(_zaiId);
        (result, ) = _getZaiStamina(_zaiId, z);
        nextUnlockingFight = _firstOf5FightTimestamp[_zaiId] + staminaRegenerationDuration[z.state];
    }

    function _getZaiStamina(uint256 _zaiId, ZaiStruct.ZaiMinDatasForFight memory z)
        internal
        view
        returns (uint256 stamina, uint256 added)
    {
        // if no fight return max stamina : 5
        if (_firstOf5FightTimestamp[_zaiId] == 0) {
            stamina = 5;
        } else {
            unchecked{
                // take the old variable
                stamina = _zaiStamina[_zaiId];
                // calculate time passed since the first of 5 last fights
                uint256 _timeSinceLastFight = block.timestamp -
                    _firstOf5FightTimestamp[_zaiId];
                // if there is > 1 stamina duration
                if (
                    _timeSinceLastFight >=
                    staminaRegenerationDuration[z.state]
                ) {
                    // calculate number of stamina to add no need modulo cause in solidity 100 / 60 = 1
                    added =
                        _timeSinceLastFight /
                        staminaRegenerationDuration[z.state];
                    // max stamina is 5
                    if (stamina + added >= 5) {
                        stamina = 5;
                    } else {
                        stamina += added;
                    }
                }
            }
        }
    }

    function _updateStamina(uint256 _zaiId, ZaiStruct.ZaiMinDatasForFight memory z)
        internal
        returns (bool)
    {
        //reload
        (uint256 stamina, uint256 added) = _getZaiStamina(_zaiId, z);
        _zaiStamina[_zaiId] = stamina;
        require(_zaiStamina[_zaiId] != 0, "exhausted Zai!");

        unchecked{
            if (stamina == 5) {
                _firstOf5FightTimestamp[_zaiId] = block.timestamp;
            } else {
                _firstOf5FightTimestamp[_zaiId] += (added *
                    staminaRegenerationDuration[z.state]);
            }
            // reduce stamina counter
            -- _zaiStamina[_zaiId]; //
        }
        return true;
    }

    function useRestPotion(uint256 _zaiId, uint256 _potionId) external {
        require(
            IDel.canUseZai(_zaiId, msg.sender),
            "Not your zai nor delegated"
        );

        require(Potions.ownerOf(_potionId) == msg.sender);
        ZaiStruct.ZaiMinDatasForFight memory z = IMeta.getZaiMinDatasForFight(_zaiId);
        (uint256 stamina, ) = _getZaiStamina(_zaiId, z);
        if (stamina >= 2) {
            revert("Zai doesn't need rest portion");
        }
        // UPDATE AUDIT : delete this option
        // rest for training
        PotionStruct.Powers memory p = Potions.getPotionPowers(_potionId);
        require(p.rest != 0, "Not a rest p");
        Potions.emptyingPotion(_potionId);
        _zaiStamina[_zaiId] = 5;
        emit RestPotionUsed(msg.sender, _zaiId, _potionId);
    }

    // _elements (0: water ; 1: fire ; 2:metal ; 3:air ; 4:stone)
    // UPDATE AUDIT : replace uint256[9] memory by calldata
    // UPDATE AUDIT : no need to returns uint256[30] memory
    function initFighting(
        uint256 _zaiId,
        uint256[9] calldata _elements,
        uint256[9] calldata _powers,
        uint256[] calldata _usedPotions
    )
        external
    {
        // UPDATE AUDIT : prevent bot action
        require(tx.origin == msg.sender, "contract not allowed");
        // UPDATE AUDIT : check max potion number
        require(_usedPotions.length <=3, "Max 3 potions by fight");
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
        ZaiStruct.ZaiMinDatasForFight memory z = IMeta.getZaiMinDatasForFight(_zaiId);
        // check if Zai is not in training, working or coaching. Must be free
        require(z.statusId == 0, "Not free");
        // update stamin of Zai
        require(_updateStamina(_zaiId, z), "Stamina error");

        // UPDATE AUDIT : updateUserProgress return the beginning day avoiding call this more than 1 time
        // update loot progress (weekly reward when you play all days)
        uint256 _dayBegining = ILoot.updateUserProgress(msg.sender);

        // UPDATE AUDIT : checking potions is done in _getZaiPowersByElement

        // check if user respect number of powers rule ( don't use more than Zai can use with potions or not)
        (
            uint8[5] memory _gotPowers,
            uint256 _xpMult
        ) = _getZaiPowersByElement(z, _usedPotions);

        require(
            IFightLib.isPowersUsedCorrect(
                _gotPowers,
                IFightLib.getUsedPowersByElement(_elements, _powers)
            ),
            "cheat!"
        );

        // create randoms
        uint256 _random = Oracle.getRandom();

        // UPDATE AUDIT : init uint256[30] result here
        uint256[30] memory result; //[0: obsolete,1:myScore, 2:challengerScore, 3-11: ElementByRoundOfChallenger, 12-20: PowerUseByChallengerByRound, 21 number of potions used by challenger, 22-23-24 type of potions if relevent, 25-26-27 power of potions if relevent, 28 xpWon, 29 BZAI won ]

        // UPDATE AUDIT : random is sent to ILevel avoiding calling 2 times random function
        // get a challenger (can't be the same Zai used by the user)
        result[0] = ILevel.getRandomZaiFromLevel(z.level, _zaiId,_random);

        // store in memory challenger Zai NFT Datas
        ZaiStruct.ZaiMinDatasForFight memory c = IMeta.getZaiMinDatasForFight(result[0]);

        // create challenger pattern
        result = IFightLib.getNewPattern(_random, c, result);

        // update the fighting progress in the return array
        result = IFightLib.updateFightingProgress(result, _elements, _powers);

        // update all counters
        result[28] = _getXpToWin(_powers, _gotPowers, _xpMult);
        result = _updateCounterWinLoss(
            z,
            _zaiId,
            result,
            scholarDatas,
            _xpMult,
            _dayBegining
        );

        // create event of fight
        emit FightResult(msg.sender,_zaiId, result,_elements,_powers);
    }

    // UPDATE AUDIT : replace uint256[] memory by calldata
    function _getXpToWin(
        uint256[9] calldata _powers,
        uint8[5] memory _gotPowers,
        uint256 _xpMult
    ) internal view returns (uint256 _xp) {
        unchecked{
            uint256 _totalPowers = _gotPowers[0] +
                _gotPowers[1] +
                _gotPowers[2] +
                _gotPowers[3] +
                _gotPowers[4];
            uint256 _totalUsedPowers;
            for (uint256 i ; i < 9; ) {
                _totalUsedPowers += _powers[i];
                
                ++i;
                
            }
            // minimum xp to win is xpRewardByFight / 2 => we use * 100 for more precision
            _xp = (xpRewardByFight * 100) / 2;
            // calculate xp :
            // max xp - (half max xp / ratio powers used vs power got) / 100 for more precision
            _xp = ((2 * _xp) - (_xp * _totalUsedPowers / _totalPowers)) / 100;

            if (_xpMult > 1) {
                _xp *= _xpMult;
            }
        }
    }

    // UPDATE AUDIT : add dayBegining
    function _updateCounterWinLoss(
        ZaiStruct.ZaiMinDatasForFight memory z,
        uint256 _zaiId,
        uint256[30] memory _toReturn,
        ZaiStruct.ScholarDatas memory _scholarDatas,
        uint256 _xpMult,
        uint256 _dayBegining
    ) internal returns (uint256[30] memory) {
        // UPDATE AUDIT:delete stats updates
        uint256 _xpWon = xpRewardByFight / 10;
        uint256 _bzaiWon;
        if (_toReturn[1] < _toReturn[2]) {
            _toReturn[28] = _xpWon * _xpMult;
        } else if (_toReturn[1] == _toReturn[2]) {
            _toReturn[28] = _xpWon * 2 * _xpMult;
        } else {
            //Player win
            // UPDATE AUDIT : got _dayBegining now
            if (_lastWinTimestamp[_zaiId] < _dayBegining) {
                _dayWinCounter[_zaiId] = 1;
            } else {
                ++ _dayWinCounter[_zaiId];
            }
            _lastWinTimestamp[_zaiId] = block.timestamp;
            if (
                _dayWinCounter[_zaiId] <=
                bzaiRewardCountPerDay[z.state]
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
                        _bzaiWon,
                        z.state
                    );
                } else {
                    require(
                        IPay.rewardPlayer(
                            _scholarDatas.delegateDatas.ownerAddress,
                            _bzaiWon,
                            _zaiId,
                            z.state
                        )
                    );
                }
            }
            }
        if (IMeta.updateXp(_zaiId, _toReturn[28]) > z.level) {
            _zaiStamina[_zaiId] = 5;
        }

        // UPDATE AUDIT: update 200 => xpRewardByFight/10 && 400 => xpRewardByFight/5 && 1000 => 200 => xpRewardByFight/2
        require(
            IRank.updatePlayerRankings(
                msg.sender,
                _toReturn[1] < _toReturn[2] ? xpRewardByFight/10 : _toReturn[1] == _toReturn[2]
                    ? xpRewardByFight/5
                    : xpRewardByFight/2
            ),
            "Ranking error"
        );
        _toReturn[29] = _bzaiWon;
        
        return _toReturn;
    }

    function _paySchoolarAndOwner(
        ZaiStruct.ScholarDatas memory _scholarDatas,
        uint256 _zaiId,
        uint256 _reward,
        uint256 _state
    ) internal returns (uint256 _scholarReward) {
        uint256 _ownerReward;
        address _ownerAddress;
        address _scholarAddress;

        if (_scholarDatas.delegateDatas.scholarAddress != address(0x0)) {
            require(IDel.updateLastScholarPlayed(_zaiId));
            _ownerReward =
                (_reward *
                    (100 - _scholarDatas.delegateDatas.percentageForScholar)) /
                100;
            _scholarReward = _reward - _ownerReward;

            _scholarAddress = _scholarDatas.delegateDatas.scholarAddress;
            _ownerAddress = _scholarDatas.delegateDatas.ownerAddress;
        } else {
            require(
                _scholarDatas.guildeDatas.percentagePlatformFees + 
                _scholarDatas.guildeDatas.percentageForScholar + 
                _scholarDatas.guildeDatas.percentageForGuilde == 100, 
                "Percentage from RNFT Guilde doesn't match"
            );

            uint256 _platfromFees = _reward * _scholarDatas.guildeDatas.percentagePlatformFees / 100;
            
            _scholarReward =
                (_reward * _scholarDatas.guildeDatas.percentageForScholar) /
                100;
            _ownerReward = _reward - _platfromFees - _scholarReward;

            _scholarAddress = _scholarDatas.guildeDatas.renterOf;
            _ownerAddress = _scholarDatas.guildeDatas.masterOf;

            require(
                IPay.rewardPlayer(
                    _scholarDatas.guildeDatas.platformAddress,
                    _platfromFees,
                    0,
                    0
                )
            );
        }

        require(IPay.rewardPlayer(_ownerAddress, _ownerReward,_zaiId,_state));
        require(IPay.rewardPlayer(_scholarAddress, _scholarReward,0,0));
    }

    // UPDATE AUDIT : function isn't view
    function _getZaiPowersByElement(
        ZaiStruct.ZaiMinDatasForFight memory z,
        uint256[] memory _potions
    ) internal returns (uint8[5] memory _powers, uint256 _xpMult) {
        unchecked{
            _powers = [
                z.water,
                z.fire,
                z.metal,
                z.air,
                z.stone
            ];
        }
        _xpMult = 1;

        for (uint256 i ; i < _potions.length; ) {
            // UPDATE AUDIT : check if owner
            require(
                Potions.ownerOf(_potions[i]) == msg.sender,
                "Not your potion"
            );
            // UPDATE AUDIT : get only potion.powers for GAS fees optimization
            PotionStruct.Powers memory p = Potions.getPotionPowers(_potions[i]);

            if (p.water != 0) {
                _powers[0] += p.water;
            }
            if (p.fire != 0) {
                _powers[1] += p.fire;
            }
            if (p.metal != 0) {
                _powers[2] += p.metal;
            }
            if (p.air != 0) {
                _powers[3] += p.air;
            }
            if (p.stone != 0) {
                _powers[4] += p.stone;
            }
            if (p.xp != 0) {
                require(_xpMult == 1, "Only 1 xp potion by fight");
                _xpMult = p.xp;
            }
            // UPDATE AUDIT : emptying potion
            Potions.emptyingPotion(_potions[i]);
            unchecked{
                ++ i;
            }    
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 


library ZaiStruct {
    // Zai powers
    struct Powers {
        uint8 water;
        uint8 fire;
        uint8 metal;
        uint8 air;
        uint8 stone;
    }

    // A zai can work in a center , training or coaching. He can't fight if he isn't free
    //string[4] _status = ["Free","Training","Coaching","Working"];
    // UPDATE AUDIT : add spotId
    struct Activity {
        uint8 statusId;
        uint8 onSpotId;
        uint16 onCenter;
    }

    struct ZaiMetaData {
        uint8 state; // _states index
        uint8 seasonOf;
        uint32 ipfsPathId;
        bool isGod;
    }

    struct Zai {
        uint8 level;
        uint8 creditForUpgrade; // credit to use to raise powers
        uint16 manaMax;
        uint16 mana;
        uint32 xp;
        Powers powers;
        Activity activity;
        ZaiMetaData metadata;
        string name;
    }

    struct ZaiMinDatasForFight{
        uint8 level;
        uint8 state;
        uint8 statusId;
        uint8 water;
        uint8 fire;
        uint8 metal;
        uint8 air;
        uint8 stone;
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
        uint8 percentageForScholar;
        uint16 contractDuration;
        uint32 contractEnd;
        uint32 lastScholarPlayed;
        bool renewable;
    }

    struct GuildeDatas {
        address renterOf;
        address masterOf;
        address platformAddress;
        uint8 percentageForScholar;
        uint8 percentageForGuilde;
        uint8 percentagePlatformFees;
    }

    struct ScholarDatas {
        GuildeDatas guildeDatas;
        DelegateData delegateDatas;
    }
}

library PotionStruct {
    struct Powers {
        uint8 water;
        uint8 fire;
        uint8 metal;
        uint8 air;
        uint8 stone;
        uint8 rest;
        uint8 xp;
        uint8 mana;
    }

    struct Potion {
        address seller;
        uint256 listingPrice;
        uint256 fromLab;
        uint256 potionId;
        uint256 saleTimestamp;
        uint8 potionType; // 0: water ; 1: fire ; 2:metal ; 3:air ; 4:stone  ; 5:rest ; 6:xp ; 7:multiple ; 99 : empty
        Powers powers;
    }
}

library LaboStruct {
    struct WorkInstance {
        uint256 zaiId;
        uint256 beginingAt;
    }

    struct LabDetails {
        uint256 revenues;
        uint256 employees;
        uint256 potionsCredits;
        uint256 numberOfSpots;
        WorkInstance[10] workingSpot;
    }
}

library AddressesInit {
    enum Addresses{
        ALCHEMY, 
        BZAI_TOKEN,
        CHICKEN,
        CLAIM_NFTS,
        DELEGATE,
        EGGS_NFT,
        FIGHT,
        FIGHT_PVP,
        IPFS_STORAGE,
        LABO_MANAGEMENT,
        LABO_NFT,
        LEVEL_STORAGE,
        LOOT,
        MARKET_PLACE,
        MARKET_DUTCH_AUCTION_ZAI,
        NURSERY_MANAGEMENT,
        NURSERY_NFT,
        OPEN_AND_CLOSE,
        ORACLE,
        PAYMENTS,
        POTIONS_NFT,
        PVP_GAME,
        RANKING,
        RENT_MY_NFT,
        REWARDS_PVP,
        REWARDS_WINNING_PVE,
        REWARDS_RANKING,
        TRAINING_MANAGEMENT,
        TRAINING_NFT,
        ZAI_META,
        ZAI_NFT
    }

    //     ALCHEMY, 0
    //     BZAI_TOKEN, 1 
    //     CHICKEN, 2
    //     CLAIM_NFTS, 3
    //     DELEGATE, 4
    //     EGGS_NFT, 5
    //     FIGHT, 6
    //     FIGHT_PVP, 7
    //     IPFS_STORAGE, 8
    //     LABO_MANAGEMENT, 9
    //     LABO_NFT, 10
    //     LEVEL_STORAGE, 11
    //     LOOT, 12
    //     MARKET_PLACE, 13
    //     MARKET_DUTCH_AUCTION_ZAI, 14
    //     NURSERY_MANAGEMENT, 15
    //     NURSERY_NFT, 16
    //     OPEN_AND_CLOSE, 17
    //     ORACLE, 18
    //     PAYMENTS, 19
    //     POTIONS_NFT, 20
    //     PVP_GAME, 21
    //     RANKING, 22
    //     RENT_MY_NFT, 23
    //     REWARDS_PVP, 24
    //     REWARDS_WINNING_PVE, 25
    //     REWARDS_RANKING, 26
    //     TRAINING_MANAGEMENT, 27
    //     TRAINING_NFT, 28
    //     ZAI_META, 29
    //     ZAI_NFT, 30

}

interface IAddresses {
   
    function isAuthToManagedNFTs(address _address) external view returns (bool);

    function isAuthToManagedPayments(address _address)
        external
        view
        returns (bool);

    function getAddressOf(AddressesInit.Addresses _contract) external view returns(address);
}

interface IBZAI is IERC20 {
    function burn(uint256 _amount) external returns (bool);
}

interface IChicken {
    function mintChicken(address _to) external returns (uint256);
}

interface IDelegate {
    function gotDelegationForZai(uint256 _zaiId) external view returns(ZaiStruct.ScholarDatas memory scholarDatas);

    function canUseZai(uint256 _zaiId, address _user) external view returns(bool);

    function getDelegateDatasByZai(uint256 _zaiId) external view returns(ZaiStruct.DelegateData memory);

    function isZaiDelegated(uint256 _zaiId) external view returns(bool);

    function updateLastScholarPlayed(uint256 _zaiId) external returns(bool);

    function updateInterfaces() external;
}

interface IEggs is IERC721{
    function mintEgg(
        address _to,
        uint256 _state,
        uint256 _maturityDuration
    ) external returns (uint256);

}

interface IFighting {
    function updateInterfaces() external;
}

interface IFightingLibrary {
    function updateFightingProgress(
        uint256[30] memory _toReturn,
        uint256[9] calldata _elements,
        uint256[9] calldata _powers
    ) external pure returns (uint256[30] memory);

    function getUsedPowersByElement(
        uint256[9] calldata _elements,
        uint256[9] calldata _powers
    ) external pure returns (uint256[5] memory);

    function isPowersUsedCorrect(
        uint8[5] calldata _got,
        uint256[5] calldata _used
    ) external pure returns (bool);

    function getNewPattern(
        uint256 _random,
        ZaiStruct.ZaiMinDatasForFight memory c,
        uint256[30] memory _toReturn
    ) external pure returns (uint256[30] memory result);
}

interface IGuildeDelegation {
    function getRentingDatas(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (ZaiStruct.GuildeDatas memory);
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

    function getCurrentSeason() external view returns (uint8);

    function updateInterfaces() external;
}

interface ILaboratory is IERC721 {
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

    function updateNumberOfWorkingSpots(uint256 _tokenId, uint256 _quantity)
        external
        returns (bool);

    function getPreMintNumber() external view returns (uint256);

    function updateInterfaces() external;
}

interface ILabManagement {

    function initSpotsNumber(uint256 _tokenId) external returns(bool);

    function cleanSlotsBeforeClosing(uint256 _laboId) external returns (bool);

    function updateInterfaces() external;
}

interface ILevelStorage {
    function addFighter(uint256 _level, uint256 _zaiId) external returns (bool);

    function removeFighter(uint256 _level, uint256 _zaiId)
        external
        returns (bool);

    function getLevelLength(uint256 _level) external view returns (uint256);

    function getRandomZaiFromLevel(uint256 _level, uint256 _idForbiden, uint256 _random)
        external
        view
        returns (uint256);

    function updateInterfaces() external;
}

interface ILootProgress {
    // UPDATE AUDIT : update interface
    function updateUserProgress(address _user) external returns(uint256 beginingDay);

    function updateInterfaces() external;
}

interface IMarket {
    function updateInterfaces() external;
}

interface INurseryNFT is IERC721{

    function getPreMintNumber() external view returns (uint256);
}

interface INurseryManagement {
    function getEggsPrices(uint256 _nursId)
        external
        view
        returns (ZaiStruct.EggsPrices memory);

    function updateInterfaces() external;
}

interface IOpenAndClose {
    function getLaboCreatingTime(uint256 _tokenId)
        external
        view
        returns (uint256);

    function canLaboSell(uint256 _tokenId) external view returns (bool);

    function canTrain(uint256 _tokenId) external view returns (bool);

    function updateInterfaces() external;
}

interface IOracle {
    function getRandom() external returns (uint256);
}

interface IPayments {
    function payOwner(address _owner, uint256 _value) external returns (bool);

    function getMyReward(address _user) external view returns (uint256);

    function distributeFees(uint256 _amount) external returns (bool);

    function rewardPlayer(address _user, uint256 _amount, uint256 _zaiId, uint256 _state)
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

    function payWithRewardOrWallet(address _user, uint256 _amount)
        external
        returns (bool);
}

interface IPotions is IERC721{
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

    function getPotionPowers(uint256 _tokenId)
        external
        view
        returns (PotionStruct.Powers memory);

    function updateInterfaces() external; 
}

interface IRanking {
    function updatePlayerRankings(address _user, uint256 _xpWin)
        external
        returns (bool);

    function getDayBegining() external view returns (uint256);

    function updateInterfaces() external;
}

interface IReserveForChalengeRewards {
    function updateRewards() external returns (bool,uint256);
}

interface IReserveForWinRewards {
    function updateRewards() external returns (bool,uint256);
}

interface IRewardsPvP {
    function updateInterfaces() external;
}

interface IRewardsRankingFound {
    function getDailyRewards(address _rewardStoringAddress)
        external
        returns (uint256);

    function getWeeklyRewards(address _rewardStoringAddress)
        external
        returns (uint256);

    function updateInterfaces() external;
}

interface IRewardsWinningFound {
    function getWinningRewards(uint256 level, bool bonus) external returns (uint256);

    function updateInterfaces() external;
}

interface ITraining is IERC721{
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

    function updateInterfaces() external;
}

interface ITrainingManagement {

    function initSpotsNumber(uint256 _tokenId) external returns(bool);

    function cleanSlotsBeforeClosing(uint256 _laboId) external returns (bool);

    function updateInterfaces() external;
}

interface IZaiNFT is IERC721 {
    function mintZai(
        address _to,
        string memory _name,
        uint256 _state
    ) external returns (uint256);

    function createNewChallenger() external returns (uint256);

    function burnZai(uint256 _tokenId) external returns(bool);
}

interface IZaiMeta {
    function getZaiURI(uint256 tokenId) external view returns (string memory);

    function createZaiDatas( 
        uint256 _newItemId,
        string memory _name,
        uint256 _state,
        uint256 _level
    ) external;

    function getZai(uint256 _tokenId)
        external
        view
        returns (ZaiStruct.Zai memory);

    function getZaiMinDatasForFight(uint256 _tokenId)
        external
        view
        returns (ZaiStruct.ZaiMinDatasForFight memory zaiMinDatas);

    function isFree(uint256 _tokenId) external view returns (bool);

    function updateStatus(
        uint256 _tokenId,
        uint256 _newStatusID,
        uint256 _center,
        uint256 _spotId
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

    function updateInterfaces() external;
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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