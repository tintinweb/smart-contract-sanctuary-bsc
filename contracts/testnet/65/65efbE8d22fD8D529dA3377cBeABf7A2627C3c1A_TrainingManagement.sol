// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces.sol";

// contract who manage training center NFT
// owner of NFT can set training slots with coach or not , select duration and price of slots
// coach will get a part of the training price
// Zai who train in a slot will raise his xp (1sec training give 1xp point)
// when zai is training with coach, he will win more xp ((level Coach - level Zai +1) * seconds of training) 
contract TrainingManagement is Ownable {
    IERC20 BZAI;
    IAddresses public gameAddresses;

    constructor(address _BZAI) {
        BZAI = IERC20(_BZAI);
    }

    mapping(uint256 => uint256) public tcRevenues;

    event TrainingPurchase(address indexed trainingOwner, uint256 price);
    event CoachPaid(address indexed coachOwner, uint256 price);

    uint256 public addSpotPrice = 200000 * 1E18;

    uint256 public minimumTrainingPrice = 100 * 1E18;
    uint256 public maxDurationTraining = 21600; // 6 h

    mapping(uint256 => uint256) _lastTrainTimestamp;

    mapping(uint256 => uint256) public zaiTrainingNumber;
    mapping(uint256 => uint256) public zaiCoachingNumber;
    mapping(address => uint256) public userTrainingNumber;
    mapping(address => uint256) public userCoachingNumber;

    string[6] slotStatus = [
        "not_set",
        "closed",
        "free",
        "in_use",
        "waiting_coach",
        "waiting_for_finish_training"
    ];

    struct coachDatas {
        bool coachRequired;
        uint256 minLevelReq;
        uint256 currentCoachLevel;
        uint256 percentPayment;
        uint256 coachId;
    }

    struct TrainingInstance {
        bool spotOpened;
        uint256 price;
        uint256 duration;
        uint256 endAt;
        uint256 zaiId;
        coachDatas coach;
    }

    mapping(uint256 => mapping(uint256 => TrainingInstance))
        public trainingSpots;
    
    modifier onlyCenterOwner(uint256 _trainingId) {
        require(
            ITraining(gameAddresses.getTrainingNFTAddress()).ownerOf(
                _trainingId
            ) == msg.sender,
            "Not your center"
        );
        _;
    }

    modifier canUseZai(uint256 _zaiId) {
        require(
            IDelegate(gameAddresses.getDelegateZaiAddress()).canUseZai(
                _zaiId,
                msg.sender
            ),
            "Not your zai nor delegated"
        );
        _;
    }

    modifier zaiReady(uint256 _zaiId) {
        require(
            IZaiNFT(gameAddresses.getZaiAddress()).isFree(_zaiId),
            "Zai not free"
        );
        require(
            block.timestamp >= _lastTrainTimestamp[_zaiId] + 1 days,
            "zai need to rest: only 1 training by day"
        );
        _;
    }

    function setGameAddresses(address _address) public onlyOwner {
        require(gameAddresses == IAddresses(address(0x0)), "Already setted");
        gameAddresses = IAddresses(_address);
    }

    function setSpotPrice(uint256 _price) external onlyOwner {
        addSpotPrice = _price;
    }

    function setminimumTrainingPrice(uint256 _price) external onlyOwner {
        minimumTrainingPrice = _price;
    }

    function getZaiLastTrainBegining(uint256 _zaiId)
        external
        view
        returns (uint256)
    {
        return _lastTrainTimestamp[_zaiId];
    }

    function restFromTraining(uint256 _zaiId) external returns(bool){
        require(msg.sender == gameAddresses.getFightAddress(),"Not authorized to rest a Zai");
        _lastTrainTimestamp[_zaiId] = 0;
        return true;
    }

    // 0 = not params, 1= closed, 2 = Free, 3 = in use, 4 = waitingcoach
    function getSpotStatus(uint256 _spotId, uint256 _trainingId)
        external
        view
        returns (string memory)
    {
        return slotStatus[_getSpotStatus(_spotId, _trainingId)];
    }

    function _getSpotStatus(uint256 _spotId, uint256 _trainingId)
        internal
        view
        returns (uint256 _state)
    {
        TrainingInstance memory t = trainingSpots[_trainingId][_spotId];
        if (t.price == 0) {
            return 0;
        } else if (t.coach.coachId == 0 && t.coach.coachRequired) {
            return 4;
        } else if (!t.spotOpened) {
            return 1;
        } else if (block.timestamp >= t.endAt) {
            return 2;
        } else {
            return 3;
        }
    }

    function upgradeTC(uint256 _spotsQty, uint256 _trainingId)
        external
        onlyCenterOwner(_trainingId)
        returns (bool)
    {
        IPayments IPay = IPayments(gameAddresses.getPaymentsAddress());
        require(
            IPay.payWithRewardOrWallet(msg.sender, _spotsQty * addSpotPrice)
        );
        IPay.distributeFees(_spotsQty * addSpotPrice);

        return
            ITraining(gameAddresses.getTrainingNFTAddress()).addTrainingSpots(
                _trainingId,
                _spotsQty
            );
    }

    function closeTrainingSpot(uint256 _spotId, uint256 _trainingId)
        external
        onlyCenterOwner(_trainingId)
    {
        require(
            IOpenAndClose(gameAddresses.getOpenAndCloseAddress()).canTrain(
                _trainingId
            ),
            "!Ready"
        );
        require(
            ITraining(gameAddresses.getTrainingNFTAddress())
                .numberOfTrainingSpots(_trainingId) >= _spotId,
            "!Exist"
        );
        trainingSpots[_trainingId][_spotId].spotOpened = false;
    }

    function setTrainingSpot(
        uint256 _spotId,
        uint256 _trainingId,
        uint256 _duration,
        uint256 _price,
        bool _coachNeeded,
        uint256 _minCoachLevel,
        uint256 _coachPercentPayment
    ) external onlyCenterOwner(_trainingId) {
        require(
            IOpenAndClose(gameAddresses.getOpenAndCloseAddress()).canTrain(
                _trainingId
            ),
            "!Ready"
        );
        require(_price >= minimumTrainingPrice, "Price too low");
        require(_duration <= maxDurationTraining, "Training can't exceed 6h");
        require(
            ITraining(gameAddresses.getTrainingNFTAddress())
                .numberOfTrainingSpots(_trainingId) >= _spotId,
            "!Exist"
        );
        TrainingInstance storage t = trainingSpots[_trainingId][_spotId];
        require(block.timestamp >= t.endAt, "Spot is in use");

        if (t.zaiId != 0 || t.coach.coachId != 0) {
            IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
            _cleanSlot(_trainingId, _spotId, IZai);
        }
        t.duration = _duration;
        t.price = _price;

        if (_coachNeeded) {
            t.coach.minLevelReq = _minCoachLevel;
            t.coach.percentPayment = _coachPercentPayment;
            t.coach.coachRequired = true;
        } else {
            t.spotOpened = true;
        }
    }

    function registerCoaching(
        uint256 _zaiId,
        uint256 _spotId,
        uint256 _trainingId
    ) external canUseZai(_zaiId) zaiReady(_zaiId) {
        TrainingInstance storage t = trainingSpots[_trainingId][_spotId];
        IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
        require(t.coach.coachRequired, "!Exist");
        require(
            t.coach.coachId == 0 || block.timestamp > t.endAt,
            "Got coach or training not finished"
        );

        if (block.timestamp > t.endAt && t.endAt != 0) {
            _cleanSlot(_trainingId, _spotId, IZai);
        }

        ZaiStruct.Zai memory z = IZai.getZai(_zaiId);

        require(z.level >= t.coach.minLevelReq, "!Level");
        require(IZai.isFree(_zaiId), "Zai!=Free");

        IZai.updateStatus(_zaiId, 2, _trainingId);
        t.coach.coachId = _zaiId;
        t.spotOpened = true;
        t.coach.currentCoachLevel = z.level;
    }

    function stopHiringCoach(
        uint256 _spotId,
        uint256 _trainingId,
        uint256 _newPrice
    ) external onlyCenterOwner(_trainingId) {
        TrainingInstance storage t = trainingSpots[_trainingId][_spotId];
        t.coach.minLevelReq = 0;
        t.coach.coachRequired = false;
        t.price = _newPrice;
    }

    function kickCoachFromSpot(uint256 _spotId, uint256 _trainingId)
        external
        onlyCenterOwner(_trainingId)
    {
        TrainingInstance storage t = trainingSpots[_trainingId][_spotId];
        require(t.coach.coachId != 0, "No coach to kick");
        require(block.timestamp >= t.endAt, "Training is not finished");

        IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
        _cleanSlot(_trainingId, _spotId, IZai);
    }

    function cleanSpot(uint256 _trainingId, uint256 _spotId)
        external
        onlyCenterOwner(_trainingId)
    {
        IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
        _cleanSlot(_trainingId, _spotId, IZai);
    }

    function beginTraining(
        uint256 _spotId,
        uint256 _trainingId,
        uint256 _zaiId,
        uint256 _maxPrice
    ) external canUseZai(_zaiId) zaiReady(_zaiId) {
        _lastTrainTimestamp[_zaiId] = block.timestamp;
        IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
        TrainingInstance storage t = trainingSpots[_trainingId][_spotId];

        require(t.spotOpened, "Spot not opened");
        require(block.timestamp >= t.endAt, "Previous training not finished");
        IZai.updateStatus(_zaiId, 1, _trainingId);

        zaiTrainingNumber[_zaiId] += 1;
        userTrainingNumber[msg.sender] += 1;

        address ownerOfTC = ITraining(gameAddresses.getTrainingNFTAddress())
            .ownerOf(_trainingId);
        uint256 ownerPayment = t.price;
        uint256 coachPayment;
        address ownerOfCoach;

        if (t.coach.coachId != 0) {
            require(t.zaiId == 0, "coach need to rest");
            _lastTrainTimestamp[t.coach.coachId] = block.timestamp;

            coachPayment = (ownerPayment * t.coach.percentPayment) / 100;
            ownerPayment -= coachPayment;
            ownerOfCoach = IZaiNFT(gameAddresses.getZaiAddress()).ownerOf(
                t.coach.coachId
            );

            zaiCoachingNumber[t.coach.coachId] += 1;
            userCoachingNumber[ownerOfCoach] += 1;
        }
        if (t.zaiId != 0) {
            _updateZai(t.zaiId, t.duration, t.coach.coachId, IZai);
            IZai.updateStatus(t.zaiId, 0, 0);
            t.zaiId = 0;
        }

        IPayments IPay = IPayments(gameAddresses.getPaymentsAddress());
        require(
            _maxPrice >= ownerPayment + coachPayment,
            "Price has been changed"
        );
        require(
            IPay.payWithRewardOrWallet(msg.sender, ownerPayment + coachPayment)
        );

        IPay.payOwner(ownerOfTC, ownerPayment);
        emit TrainingPurchase(ownerOfTC, ownerPayment);

        if (coachPayment > 0) {
            IPay.payOwner(ownerOfCoach, coachPayment);
            emit CoachPaid(ownerOfCoach, coachPayment);
        }

        tcRevenues[_trainingId] += t.price;
        t.endAt = block.timestamp + t.duration;
        t.zaiId = _zaiId;
    }

    function quiteCoaching(
        uint256 _zaiId,
        uint256 _spotId,
        uint256 _trainingId
    ) external canUseZai(_zaiId) {
        TrainingInstance storage t = trainingSpots[_trainingId][_spotId];
        require(
            _zaiId == t.coach.coachId,
            "Not your Zai who's coaching in this training slot"
        );

        IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
        _cleanSlot(_trainingId, _spotId, IZai);
    }

    function finishTraining(
        uint256 _spotId,
        uint256 _trainingId,
        uint256 _zaiId
    ) external canUseZai(_zaiId) {
        TrainingInstance memory t = trainingSpots[_trainingId][_spotId];
        require(block.timestamp >= t.endAt, "Training is not finished");
        require(_zaiId == t.zaiId, "Not your Zai in this training slot");

        IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
        _cleanSlot(_trainingId, _spotId, IZai);
    }

    function cleanSlotsBeforeClosing(uint256 _trainingId)
        external
        returns (bool)
    {
        require(
            msg.sender == gameAddresses.getOpenAndCloseAddress(),
            "Not authorized to clean spot"
        );
        uint256 numberOfTrainingSpots = ITraining(
            gameAddresses.getTrainingNFTAddress()
        ).numberOfTrainingSpots(_trainingId);
        IZaiMeta IZai = IZaiMeta(gameAddresses.getZaiMetaAddress());
        if (numberOfTrainingSpots == 0) {
            return true;
        } else {
            for (uint256 i = 1; i <= numberOfTrainingSpots; ) {
                _cleanSlot(_trainingId, i, IZai);
                unchecked {
                    ++i;
                }
            }
            return true;
        }
    }

    function _cleanSlot(
        uint256 _trainingId,
        uint256 _spotId,
        IZaiMeta IZai
    ) internal {
        TrainingInstance storage t = trainingSpots[_trainingId][_spotId];
        require(block.timestamp >= t.endAt, "training is not over");
        t.endAt = 0;
        if (t.zaiId != 0) {
            _updateZai(t.zaiId, t.duration, t.coach.coachId, IZai);
            IZai.updateStatus(t.zaiId, 0, 0);
            t.zaiId = 0;
        }
        if (t.coach.coachId != 0) {
            IZai.updateStatus(t.coach.coachId, 0, 0);
            t.coach.coachId = 0;
            t.coach.currentCoachLevel = 0;
            t.spotOpened = false;
        }
    }

    function _updateZai(
        uint256 _zaiId,
        uint256 _duration,
        uint256 _coachId,
        IZaiMeta I
    ) private {
        ZaiStruct.Zai memory z = I.getZai(_zaiId);

        if (_coachId != 0) {
            ZaiStruct.Zai memory c = I.getZai(_coachId);
            if (c.level - z.level > 0) {
                uint256 levelDiff = (c.level - z.level + 1);
                _duration = _duration * (levelDiff > 20 ? 20 : levelDiff); // max multiplier 20
            }
        }

        uint256 levelTens = z.level - (z.level % 10);
        uint256 multiplierXp = 1;
        if (levelTens > 0) {
            multiplierXp = (levelTens / 10) + 1; // if level 10+ duration is multiply by 2 // if level 20+ duration is multiply by 3...
        }

        I.updateXp(_zaiId, _duration * multiplierXp);
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