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
    IAddresses public gameAddresses;
    IFighting public IFight;
    ITraining public ITrainNFT;
    IZaiNFT public IZai;
    IZaiMeta public IZMeta;
    IDelegate public IDel;
    IPayments public IPay;
    IOpenAndClose public IOpen;

    uint256 public addSpotPrice = 200000 * 1E18;

    uint256 public minimumTrainingPrice = 100 * 1E18;
    uint256 constant MAX_DURATION_TRAINING = 21600; // 6 h

    uint256 public levelDiffCap = 10;

    mapping(uint256 => uint256) _lastTrainTimestamp;

    // UPDATE AUDIT : stats in struct
    struct Stats {
        uint256 trainingNumber;
        uint256 coachingNumber;
    }

    mapping(uint256 => Stats) public zaiStats;
    mapping(address => Stats) public userStats;

    struct CoachDatas {
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
        CoachDatas coach;
    }

    struct TrainingDetails{
        uint256 revenues;
        uint256 numberOfSpots;
        TrainingInstance[10] trainingSpots;
    }

    mapping(uint256 => TrainingDetails) public trainingDetails;

    event TrainingPurchase(
        address indexed trainingOwner,
        address indexed buyer, 
        uint256 purchasedPrice, 
        uint256 trainingId, 
        uint256 spotId, 
        uint256 zaiId
    );
    event CoachPaid(
        address indexed coachOwner,
        address buyer, 
        uint256 purchasedPrice,
        uint256 trainingId, 
        uint256 spotId, 
        uint256 coachId
        );
    event GameAddressesSetted(address gameAddresses);
    event InterfacesUpdated(address fighting, address trainingNFT, address zai, address zaiMeta, address delegate, address payments, address openAndClose);
    event MinimumTrainingPriceUpdated(uint256 previousPrice, uint256 nextPrice);
    event SpotPriceUpdated(uint256 previousPrice, uint256 nextPrice);
    event LevelCapUpdated(uint256 oldMetric, uint256 NewMetric);

    constructor(ITraining _trainNFT){
        ITrainNFT = _trainNFT;
        uint256 _preMintTrain = ITrainNFT.getPreMintNumber();
        for(uint256 i = 1 ; i <= _preMintTrain ;){
            trainingDetails[i].numberOfSpots = ITrainNFT.numberOfTrainingSpots(i);
            unchecked {
                ++ i;
            }
        }
    }
    
    modifier onlyCenterOwner(uint256 _trainingId) {
        require(
            ITrainNFT.ownerOf(
                _trainingId
            ) == msg.sender,
            "Not your center"
        );
        _;
    }

    modifier canUseZai(uint256 _zaiId) {
        require(
            IDel.canUseZai(
                _zaiId,
                msg.sender
            ),
            "Not your zai nor delegated"
        );
        _;
    }

    modifier zaiReady(uint256 _zaiId) {
        require(
            IZMeta.isFree(_zaiId),
            "Zai not free"
        );
        require(
            block.timestamp >= _lastTrainTimestamp[_zaiId] + 1 days,
            "zai need to rest: only 1 training by day"
        );
        _;
    }

    function setGameAddresses(address _address) external onlyOwner {
        require(gameAddresses == IAddresses(address(0x0)), "Already setted");
        gameAddresses = IAddresses(_address);
        emit GameAddressesSetted(_address);
    }

    function updateInterfaces() external {
        IFight = IFighting(gameAddresses.getAddressOf(AddressesInit.Addresses.FIGHT));
        ITrainNFT = ITraining(gameAddresses.getAddressOf(AddressesInit.Addresses.TRAINING_NFT));
        IZai = IZaiNFT(gameAddresses.getAddressOf(AddressesInit.Addresses.ZAI_NFT));
        IZMeta = IZaiMeta(gameAddresses.getAddressOf(AddressesInit.Addresses.ZAI_META));
        IDel = IDelegate(gameAddresses.getAddressOf(AddressesInit.Addresses.DELEGATE));
        IPay = IPayments(gameAddresses.getAddressOf(AddressesInit.Addresses.PAYMENTS));
        IOpen = IOpenAndClose(gameAddresses.getAddressOf(AddressesInit.Addresses.OPEN_AND_CLOSE));
        emit InterfacesUpdated(address(IFight), address(ITrainNFT), address(IZai), address(IZMeta), address(IDel), address(IPay), address(IOpen));
    }

    // UPDATE AUDIT : used when openAndClose create a new center for init number of spot
    function initSpotsNumber(uint256 _tokenId) external returns(bool){
        require(msg.sender == address(ITrainNFT),"Only");
        trainingDetails[_tokenId].numberOfSpots = 3;
        return true;
    }

     // UPDATE AUDIT : levelDiff is capped 
    function setLevelDiffCap(uint256 _levelDiffCap) external onlyOwner {
        uint256 oldMetric = levelDiffCap;
        levelDiffCap = _levelDiffCap;
        emit LevelCapUpdated(oldMetric, _levelDiffCap);
    }

    function setSpotPrice(uint256 _price) external onlyOwner {
        uint256 _previousPrice = addSpotPrice;
        addSpotPrice = _price;
        emit SpotPriceUpdated(_previousPrice, _price);
    }

    function setminimumTrainingPrice(uint256 _price) external onlyOwner {
        uint256 _previousPrice = minimumTrainingPrice;
        minimumTrainingPrice = _price;
        emit MinimumTrainingPriceUpdated(_previousPrice, _price);
    }

     // UPDATE AUDIT : for front end
    function getTrainingCenterDetails(uint256 _tokenId) external view returns(TrainingDetails memory){
        return trainingDetails[_tokenId];
    }

    function getZaiLastTrainBegining(uint256 _zaiId)
        external
        view
        returns (uint256)
    {
        return _lastTrainTimestamp[_zaiId];
    }

    function upgradeTC(uint256 _quantity, uint256 _trainingId)
        external
        onlyCenterOwner(_trainingId)
        returns (bool)
    {
        uint256 _totalPrice = _quantity * addSpotPrice;
        require(
            IPay.payWithRewardOrWallet(msg.sender,_totalPrice )
        );
        IPay.distributeFees(_totalPrice);

        require(
            ITrainNFT.addTrainingSpots(
                _trainingId,
                _quantity
            )
        );
        trainingDetails[_trainingId].numberOfSpots += _quantity;
        return true;
            
    }

    // UPDATE AUDIT : training with coach is capped to 3h
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
            IOpen.canTrain(
                _trainingId
            ),
            "!Ready"
        );

        require(
            trainingDetails[_trainingId].numberOfSpots > _spotId,
            "Spot doesn't exist!"
        );

                // UPDATE AUDIT : training with coach is capped to 3h
        //              && minimum price with coach * 2
        if(_coachNeeded){
            require(_duration <= MAX_DURATION_TRAINING / 2, "Training can't exceed 3h");
            require(_price >= minimumTrainingPrice * 2, "Price too low");
            require(_coachPercentPayment < 90, "maximum 90% for the coach");
        }else{
            require(_duration <= MAX_DURATION_TRAINING, "Training can't exceed 6h");
            require(_price >= minimumTrainingPrice, "Price too low");
        }

        TrainingInstance storage t = trainingDetails[_trainingId].trainingSpots[_spotId];

        // UPDATE AUDIT : owner of center can change setup of training spot at any time
        // this way kick a coach or stop hiring isn't needed
        // if spot fininished or didn't start, we clean the spot for coaching and training
        if (block.timestamp >= t.endAt || t.endAt == 0) {
            _cleanSlot(_trainingId, _spotId);
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
        TrainingInstance storage t = trainingDetails[_trainingId].trainingSpots[_spotId];
        require(t.coach.coachRequired, "Spot doesn't need a coach !");
        require(
            t.coach.coachId == 0 || 
            (block.timestamp > t.endAt && t.endAt != 0),
            "Got coach or training not finished"
        );

        if (block.timestamp > t.endAt && t.endAt != 0) {
            _cleanSlot(_trainingId, _spotId);
        }

        ZaiStruct.Zai memory z = IZMeta.getZai(_zaiId);

        require(z.level >= t.coach.minLevelReq, "!Level");
        require(z.activity.statusId == 0, "Zai!=Free");

        t.coach.coachId = _zaiId;
        t.spotOpened = true;
        t.coach.currentCoachLevel = z.level;
        IZMeta.updateStatus(_zaiId, 2, _trainingId, _spotId);

    }

    function beginTraining(
        uint256 _spotId,
        uint256 _trainingId,
        uint256 _zaiId,
        uint256 _maxPrice
    ) external canUseZai(_zaiId) zaiReady(_zaiId) {
        _lastTrainTimestamp[_zaiId] = block.timestamp;
        TrainingInstance storage t = trainingDetails[_trainingId].trainingSpots[_spotId];

        require(t.spotOpened, "Spot not opened");
        require(block.timestamp >= t.endAt, "Previous training not finished");

        ++ zaiStats[_zaiId].trainingNumber;
        ++ userStats[msg.sender].trainingNumber;

        address ownerOfTC = ITrainNFT.ownerOf(_trainingId);
        uint256 ownerPayment = t.price;
        uint256 coachPayment;
        address ownerOfCoach;

        if (t.coach.coachId != 0) {
            require(t.zaiId == 0, "coach need to rest");
            _lastTrainTimestamp[t.coach.coachId] = block.timestamp;

            coachPayment = (ownerPayment * t.coach.percentPayment) / 100;
            ownerPayment -= coachPayment;
            ownerOfCoach = IZai.ownerOf(
                t.coach.coachId
            );

            ++ zaiStats[t.coach.coachId].coachingNumber;
            ++ userStats[ownerOfCoach].coachingNumber;
        }
        if (t.zaiId != 0) {
            _updateZai(t.zaiId, t.duration, t.coach.coachId);
            uint256 _tempZaiId = t.zaiId;
            t.zaiId = 0;
            IZMeta.updateStatus(_tempZaiId, 0, 0, 0);
        }

        require(
            _maxPrice >= ownerPayment + coachPayment,
            "Price has been changed"
        );

        trainingDetails[_trainingId].revenues += t.price;
        t.endAt = block.timestamp + t.duration;
        t.zaiId = _zaiId;

        IZMeta.updateStatus(_zaiId, 1, _trainingId, _spotId);

        require(
            IPay.payWithRewardOrWallet(msg.sender, ownerPayment + coachPayment)
        );

        IPay.payOwner(ownerOfTC, ownerPayment);

        if (coachPayment != 0) {
            IPay.payOwner(ownerOfCoach, coachPayment);
            emit CoachPaid(ownerOfCoach, msg.sender, coachPayment, _trainingId,_spotId, t.coach.coachId);
        }
        emit TrainingPurchase(ownerOfTC, msg.sender, ownerPayment + coachPayment, _trainingId,_spotId, _zaiId);
    }

    function cleanSpot(uint256 _trainingId, uint256 _spotId)
        external
        onlyCenterOwner(_trainingId)
    {
        _cleanSlot(_trainingId, _spotId);
    }

    function quiteCoaching(
        uint256 _zaiId,
        uint256 _spotId,
        uint256 _trainingId
    ) external canUseZai(_zaiId) {
        TrainingInstance storage t = trainingDetails[_trainingId].trainingSpots[_spotId];
        require(
            _zaiId == t.coach.coachId,
            "Not your Zai who's coaching in this training slot"
        );

        _cleanSlot(_trainingId, _spotId);
    }

    function finishTraining(
        uint256 _spotId,
        uint256 _trainingId,
        uint256 _zaiId
    ) external canUseZai(_zaiId) {
        TrainingInstance memory t = trainingDetails[_trainingId].trainingSpots[_spotId];
        require(_zaiId == t.zaiId, "Not your Zai in this training slot");

        _cleanSlot(_trainingId, _spotId);
    }

    function cleanSlotsBeforeClosing(uint256 _trainingId)
        external
        returns (bool)
    {
        require(
            msg.sender == address(IOpen),
            "Not authorized to clean spot"
        );
        uint256 numberOfTrainingSpots = trainingDetails[_trainingId].numberOfSpots;
        if (numberOfTrainingSpots == 0) {
            return true;
        } else {
            for (uint256 i = 1; i <= numberOfTrainingSpots; ) {
                _cleanSlot(_trainingId, i);
                unchecked {
                    ++i;
                }
            }
            return true;
        }
    }

    function _cleanSlot(
        uint256 _trainingId,
        uint256 _spotId
    ) internal {
        TrainingInstance storage t = trainingDetails[_trainingId].trainingSpots[_spotId];
        require(block.timestamp >= t.endAt, "training is not over");
        t.endAt = 0;
        if (t.zaiId != 0) {
            uint256 _zaiId = t.zaiId;
            _updateZai(t.zaiId, t.duration, t.coach.coachId);
            t.zaiId = 0;
            IZMeta.updateStatus(_zaiId, 0, 0, 0);
        }
        if (t.coach.coachId != 0) {
            uint256 _coachId = t.coach.coachId;
            t.coach.coachId = 0;
            t.coach.currentCoachLevel = 0;
            t.spotOpened = false;
            IZMeta.updateStatus(_coachId, 0, 0, 0);
        }
    }

    function _updateZai(
        uint256 _zaiId,
        uint256 _duration,
        uint256 _coachId
    ) private {
        ZaiStruct.Zai memory z = IZMeta.getZai(_zaiId);
        // UPDATE AUDIT : 1 sec training give 0.5pts xp
        _duration /=2;

        if (_coachId != 0) {
            ZaiStruct.Zai memory c = IZMeta.getZai(_coachId);
            if (c.level > z.level) {
                uint256 levelDiff = (c.level - z.level + 1);
                // UPDATE AUDIT : levelDiff is capped 
                _duration = _duration * (levelDiff > levelDiffCap ? levelDiffCap : levelDiff); // max multiplier cap
            }
        }

        uint256 levelTens = z.level - (z.level % 10);
        uint256 multiplierXp = 1;
        if (levelTens != 0) {
            multiplierXp = (levelTens / 10) + 1; // if level 10+ duration is multiply by 2 // if level 20+ duration is multiply by 3...
        }

        IZMeta.updateXp(_zaiId, _duration * multiplierXp);
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