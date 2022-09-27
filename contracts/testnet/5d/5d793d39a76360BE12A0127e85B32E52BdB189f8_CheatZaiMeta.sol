// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../Interfaces.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Zai meta data
//
contract CheatZaiMeta is Ownable {
    address zaiContract;
    IZaiNFT IZai;
    ILevelStorage ILevel;
    IAddresses public gameAddresses;
    address public levelStorage;
    address public gameV2optionsAddress;

    uint256 fivePowersMinLevel = 15;
    uint256 fourPowersMinLevel = 10;
    uint256 threePowersMinLevel = 5;

    uint256 _nonce = 941823548153;

    mapping(uint256 => string[7]) _godNames;

    mapping(uint256 => ZaiStruct.Zai) _zai;

    constructor(string[7] memory _names, address _levelStorage) {
        _godNames[1] = _names;
        levelStorage = _levelStorage;
        ILevel = ILevelStorage(_levelStorage);
    }

    // ---------------------------------
    // cheat function TO DELETE BEFORE DEPLOYMENT
    // ---------------------------------

    function cheatZaiManaForTest(uint256 _zaiId) external {
        ZaiStruct.Zai storage z = _zai[_zaiId];

        z.manaMax = 10000;
        z.mana = 10000;
    }

    function cheatZaiXpForTest(uint256 _id, uint256 _xp) external {
        ZaiStruct.Zai storage z = _zai[_id];
        z.xp += _xp;
        // update level
        uint256 level = _getLevel(z.xp);

        if (ILevel.getLevelLength(level) < 10) {
            for (uint256 i = 0; i < 3; ) {
                uint256 _newItemId = IZai.createNewChallenger();
                _preMintZai(level, _newItemId);
                unchecked {
                    ++i;
                }
            }
        }
        if (level > z.level) {
            // update new level
            // max element points is on level 50 : 3 x 50 + 8pts = 158pts
            uint256 _numberOfLevelUp = (level > 50 ? 50 : level) - z.level;
            // zai win 3 points by level raised
            z.creditForUpgrade = z.creditForUpgrade + (_numberOfLevelUp * 3);

            if (z.level < 50) {
                // zai update from level storage
                require(ILevel.removeFighter(z.level, _id));
                require(ILevel.addFighter((level > 50 ? 50 : level), _id));
            }
            z.level = level;
        }
    }

    // ---------------------------------
    // ---------------------------------
    // ---------------------------------

    // in exchange of runes , owner of a Zai can reset elements point
    // will be managed in V2 game
    function resetZaiPowers(uint256 _zaiId, address _ownerOfZai) external {
        require(
            msg.sender == gameV2optionsAddress,
            "Not authorized to reset Zai"
        );
        require(IZai.ownerOf(_zaiId) == _ownerOfZai, "Wrong owner");
        ZaiStruct.Zai storage z = _zai[_zaiId];
        IStats(gameAddresses.getZaiStatsAddress()).reduceAllPowersInGame(z.powers);

        uint256 _totalPoints = z.powers.water +
            z.powers.fire +
            z.powers.metal +
            z.powers.air +
            z.powers.stone;

        z.powers = ZaiStruct.Powers(0, 0, 0, 0, 0);
        z.creditForUpgrade = _totalPoints;

    }

    // in exchange of runes , owner of a Zai can rename his Zai
    function renameZai(
        uint256 _zaiId,
        address _ownerOfZai,
        string memory _name
    ) external {
        require(
            msg.sender == gameV2optionsAddress,
            "Not authorized to reset Zai"
        );
        require(IZai.ownerOf(_zaiId) == _ownerOfZai, "Wrong owner");
        _zai[_zaiId].name = _name;
    }

    function setGameAddresses(address _address) external onlyOwner {
        require(
            gameAddresses == IAddresses(address(0x0)),
            "game addresses already setted"
        );
        gameAddresses = IAddresses(_address);
    }

    function setGameV2optionsAddress(address _address) external onlyOwner {
        gameV2optionsAddress = _address;
    }

    function getZai(uint256 _tokenId)
        external
        view
        returns (ZaiStruct.Zai memory)
    {
        return _zai[_tokenId];
    }

    function getZaiURI(uint256 tokenId) external view returns (string memory) {
        ZaiStruct.Zai memory z = _zai[tokenId];
        return
            IipfsIdStorage(gameAddresses.getIpfsStorageAddress()).getTokenURI(
                z.metadata.seasonOf,
                z.metadata.state,
                z.metadata.ipfsPathId
            );
    }

    function setGodNames(string[7] memory _names, uint256 _season)
        external
        onlyOwner
    {
        _godNames[_season] = _names;
    }

    function setZaiContract(address _zaiContract) external onlyOwner {
        require(zaiContract == address(0x0));
        zaiContract = _zaiContract;
        IZai = IZaiNFT(_zaiContract);
    }

    modifier onlyZai() {
        require(msg.sender == zaiContract, "Not authorized1");
        _;
    }

    modifier onlyAuth() {
        require(gameAddresses.isAuthToManagedNFTs(msg.sender), "Not authorized to manage Zai Meta");
        _;
    }

    function _getState(uint256 state) internal pure returns (string memory) {
        string[4] memory _states = ["Bronze", "Silver", "Gold", "Platinum"];
        return _states[state];
    }

    function getStatus(uint256 _tokenId)
        external
        view
        returns (uint256[2] memory)
    {
        return [
            _zai[_tokenId].activity.statusId,
            _zai[_tokenId].activity.onCenter
        ];
    }

    function updateStatus(
        uint256 _tokenId,
        uint256 _newStatusID,
        uint256 _center
    ) external onlyAuth {
        _zai[_tokenId].activity.statusId = _newStatusID;
        _zai[_tokenId].activity.onCenter = _center;
    }

    function updateMana(
        uint256 _tokenId,
        uint256 _manaUp,
        uint256 _manaDown,
        uint256 _maxUp
    ) external onlyAuth returns (bool) {
        ZaiStruct.Zai storage z = _zai[_tokenId];
        if (_maxUp > 0) {
            if (z.manaMax + _maxUp > 10000) {
                z.manaMax = 10000;
            } else {
                z.manaMax += _maxUp;
            }
        }

        if (_manaUp > 0) {
            if (z.mana + _manaUp > z.manaMax) {
                z.mana = z.manaMax;
            } else {
                z.mana += _manaUp;
            }
        }

        if (_manaDown > 0) {
            require(_manaDown <= z.mana, "Zai don't have enough mana");
            z.mana -= _manaDown;
        }
        return true;
    }

    function getZaiState(uint256 _tokenId)
        external
        view
        returns (string memory)
    {
        return _getState(_zai[_tokenId].metadata.state);
    }

    function isFree(uint256 _tokenId) external view returns (bool) {
        return (_zai[_tokenId].activity.statusId == 0);
    }

    function _preMintZai(uint256 _level, uint256 _newItemId) internal {
        _createZaiDatas(_newItemId, "challenger", 0, levelStorage, _level);
        ZaiStruct.Zai storage z = _zai[_newItemId];

        z.level = _level;
        z.xp = _getNextLevelUpPoints(_level);
    }

    function createZaiDatas(
        uint256 _newItemId,
        string memory _name,
        uint256 _state,
        address _to,
        uint256 _level
    ) external onlyZai {
        _createZaiDatas(_newItemId, _name, _state, _to, _level);
    }

    function _createZaiDatas(
        uint256 _newItemId,
        string memory _name,
        uint256 _state,
        address _to,
        uint256 _level
    ) internal {
        IipfsIdStorage I = IipfsIdStorage(
            gameAddresses.getIpfsStorageAddress()
        );
        require(ILevel.addFighter(_level, _newItemId));

        ZaiStruct.Zai storage z = _zai[_newItemId];
        uint256 _ipfsId = I.getNextIpfsId(_state, _newItemId);
        z.metadata.ipfsPathId = _ipfsId;
        z.metadata.seasonOf = I.getCurrentSeason();

        // All zais are created with 8 powers points in a random distribution
        uint256 random = _getRandom(_to, _ipfsId);
        uint256 _points = (_level * 3) + 8;

        z.metadata.state = _state;
        if (_state == 3 && _ipfsId <= 7) {
            // gods got 10 or 12 pts base
            z.name = _getGodNames(_ipfsId, z.metadata.seasonOf);
            z.powers = _getGodsPowers(_ipfsId);
            z.metadata.isGod = true;
        } else {
            z.name = _name;
            z.powers = _getRandomPowers(_level, _points, random);
        }
        _updateAllPowers(z.powers);
    }

    // return new level
    function updateXp(uint256 _id, uint256 _xp)
        external
        onlyAuth
        returns (uint256 level)
    {
        ZaiStruct.Zai storage z = _zai[_id];
        z.xp += _xp;
        // update level
        level = _getLevel(z.xp);

        if (ILevel.getLevelLength(level) < 10) {
            for (uint256 i = 0; i < 3; ) {
                uint256 _newItemId = IZai.createNewChallenger();
                _preMintZai(level, _newItemId);
                unchecked {
                    ++i;
                }
            }
        }
        if (level > z.level) {
            // update new level
            // max element points is on level 50 : 3 x 50 + 8pts = 158pts
            uint256 _numberOfLevelUp = (level > 50 ? 50 : level) - z.level;
            // zai win 3 points by level raised
            z.creditForUpgrade = z.creditForUpgrade + (_numberOfLevelUp * 3);

            if (z.level < 50) {
                // zai update from level storage
                require(ILevel.removeFighter(z.level, _id));
                require(ILevel.addFighter((level > 50 ? 50 : level), _id));
            }
            z.level = level;
        }
    }

    function updatePowers(
        uint256 _zaiId,
        uint256 _water,
        uint256 _fire,
        uint256 _metal,
        uint256 _air,
        uint256 _stone
    ) external {
        ZaiStruct.Zai storage z = _zai[_zaiId];
        require(
            IDelegate(gameAddresses.getDelegateZaiAddress()).canUseZai(
                _zaiId,
                msg.sender
            ),
            "Not your zai nor delegated"
        );
        require(z.creditForUpgrade >= (_water + _fire + _metal + _air + _stone),"Not enough credit");

        z.creditForUpgrade -= (_water + _fire + _metal + _air + _stone);
        z.powers = _updatePowers(
            z.level,
            z.powers,
            ZaiStruct.Powers(_water, _fire, _metal, _air, _stone),
            z.metadata.isGod
        );
        _updateAllPowers(ZaiStruct.Powers(_water, _fire, _metal, _air, _stone));
    }

    function _getGodNames(uint256 _ipfsId, uint256 _season)
        internal
        view
        returns (string memory)
    {
        return _godNames[_season][_ipfsId - 1];
    }

    function _updateAllPowers(ZaiStruct.Powers memory powers) internal {
        require(
            IStats(gameAddresses.getZaiStatsAddress()).updateAllPowersInGame(
                powers
            )
        );
    }

    function _getRandomPowers(
        uint256 level,
        uint256 _points,
        uint256 random
    ) internal view returns (ZaiStruct.Powers memory) {
        uint256 _random = random;
        uint8[5] memory elements = [0, 1, 2, 3, 4];
        uint8 numberOfElements = 5;

        if (level >= fourPowersMinLevel && level < fivePowersMinLevel) {
            numberOfElements = 4;
            elements[_random % 5] = elements[4];
            _random /= 10;
        } else if (level >= threePowersMinLevel && level < fourPowersMinLevel) {
            numberOfElements = 3;
            elements[_random % 5] = elements[4];
            _random /= 10;
            elements[_random % 4] = elements[3];
            _random /= 10;
        } else if (level < threePowersMinLevel) {
            numberOfElements = 2;
            elements[_random % 5] = elements[4];
            _random /= 10;
            elements[_random % 4] = elements[3];
            _random /= 10;
            elements[_random % 3] = elements[2];
            _random /= 10;
        }
        ZaiStruct.Powers memory p;

        while (_points > 0) {
            _random /= 10;

            if (elements[_random % numberOfElements] == 0) {
                p.water += 1;
            }
            if (elements[_random % numberOfElements] == 1) {
                p.fire += 1;
            }
            if (elements[_random % numberOfElements] == 2) {
                p.metal += 1;
            }
            if (elements[_random % numberOfElements] == 3) {
                p.air += 1;
            }
            if (elements[_random % numberOfElements] == 4) {
                p.stone += 1;
            }
            _points -= 1;
            if (_random == 0) {
                _random = random;
            }
        }
        return p;
    }

    function _getGodsPowers(uint256 _ipfsId)
        internal
        pure
        returns (ZaiStruct.Powers memory powers)
    {
        if (_ipfsId == 1 || _ipfsId == 2) {
            powers.water = 3;
            powers.fire = 3;
            powers.metal = 3;
            powers.air = 3;
            powers.stone = 3;
        }
        if (_ipfsId == 3) {
            powers.water = 10;
        }
        if (_ipfsId == 4) {
            powers.fire = 10;
        }
        if (_ipfsId == 5) {
            powers.metal = 10;
        }
        if (_ipfsId == 6) {
            powers.air = 10;
        }
        if (_ipfsId == 7) {
            powers.stone = 10;
        }
    }

    function _updatePowers(
        uint256 level,
        ZaiStruct.Powers memory powers,
        ZaiStruct.Powers memory toAdd,
        bool isGod
    ) internal view returns (ZaiStruct.Powers memory) {
        powers.water += toAdd.water;
        powers.fire += toAdd.fire;
        powers.metal += toAdd.metal;
        powers.air += toAdd.air;
        powers.stone += toAdd.stone;

        uint256 nbOfElements;
        if (powers.water > 0) {
            nbOfElements += 1;
        }
        if (powers.fire > 0) {
            nbOfElements += 1;
        }
        if (powers.metal > 0) {
            nbOfElements += 1;
        }
        if (powers.air > 0) {
            nbOfElements += 1;
        }
        if (powers.stone > 0) {
            nbOfElements += 1;
        }
        bool result;
        if (level >= fivePowersMinLevel) {
            result = true;
        } else if (level >= fourPowersMinLevel && nbOfElements <= 4) {
            result = true;
        } else if (level >= threePowersMinLevel && nbOfElements <= 3) {
            result = true;
        } else if (level < threePowersMinLevel && nbOfElements <= 2) {
            result = true;
        }
        if (!isGod) {
            require(result, "level not compatible with this upgrade");
        }
        return powers;
    }

    function getToAdd(uint256 _toAdd) internal pure returns (uint256) {
        return ((_toAdd * 110) / 100);
    }

    function getLevel(uint256 _xp) external pure returns (uint256) {
        return _getLevel(_xp);
    }

    function _getLevel(uint256 _xp) internal pure returns (uint256) {
        uint256 _xpNeededToGoUp = 10000;
        uint256 _level = 0;
        uint256 _toAdd = 10000;
        while (_xp >= _xpNeededToGoUp) {
            _level = _level + 1;
            _toAdd = getToAdd(_toAdd);
            _xpNeededToGoUp = _xpNeededToGoUp + _toAdd;
        }
        return _level;
    }

    function getNextLevelUpPoints(uint256 _level)
        external
        pure
        returns (uint256)
    {
        return _getNextLevelUpPoints(_level);
    }

    function _getNextLevelUpPoints(uint256 _level)
        internal
        pure
        returns (uint256)
    {
        if (_level == 0) {
            return 0;
        } else if (_level == 1) {
            return 10000;
        } else {
            uint256 _xpNeededToGoUp = 10000;
            uint256 _toAdd = 10000;
            for (uint256 i = 1; i < _level; ) {
                _toAdd = getToAdd(_toAdd);
                _xpNeededToGoUp = _xpNeededToGoUp + _toAdd;
                unchecked {
                    ++i;
                }
            }
            return _xpNeededToGoUp;
        }
    }

    function _getRandom(address _to, uint256 _id) internal returns (uint256) {
        _nonce = IOracle(gameAddresses.getOracleAddress()).getRandom(
            keccak256(abi.encodePacked(_to, _id, _nonce))
        );
        return _nonce;
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