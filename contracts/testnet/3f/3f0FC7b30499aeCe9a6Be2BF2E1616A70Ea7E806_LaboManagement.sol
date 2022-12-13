// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./Interfaces.sol";

// Labo management is where labo owner will create potion with credit
// Credit come from workers in labo and time passed in
// workers are Zais who want to be sorceler , when a Zai work in spot in a Labo, he will gain mana 
contract LaboManagement is ERC721Holder, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    IAddresses public gameAddresses;
    IPotions public Potions;
    ILaboratory public ILabNFT;
    IPayments public IPay;
    IZaiNFT public IZai;
    IZaiMeta public ZaiMeta;
    IOpenAndClose public IOpen;
    IDelegate public IDel;
    address public claimNftAddress;

    mapping(uint256 => EnumerableSet.UintSet) private laboUnsoldPotions;

    uint256 public workingSpotPrice = 200000 * 1E18;

    // a Labo can't have infinite credit, it is capped
    // owner have to come and create potion to use credit of labo
    uint256 public maxCredit = 2000000;

    uint256 public pointCreditCost = 10000;

    // stored for futur rewards
    mapping(uint256 => uint256) public zaiNumberOfWork;
    mapping(address => uint256) public userNumberOfWork;

    mapping(uint256 => LaboStruct.LabDetails) public labDetails;

    event GameAddressesSetted(address gameAddresses);
    event InterfacesUpdated(address potions,address payments,address zaiNFT,address zaiMeta,address openAndClose,address delegate, address claimNFT);
    event PotionSold(address indexed labOwner,uint256 indexed laboId, address indexed buyer, uint256 price,uint256 potionId);
    event PotionCreatedForSale(address indexed labOwner,uint256 indexed laboId,uint256 price,uint256 potionId, uint256 potionType, uint256 potionPower);
    event PotionPriceChanged(uint256 potionId,uint256 price);
    event PotionOffered(address indexed labOwner,uint256 indexed laboId,address indexed offeredTo,uint256 potionId, uint256 potionType, uint256 potionPower);
    event MetricsChanged(string indexed metricType, uint256 oldMetric, uint256 newMetric);


    constructor(ILaboratory _laboNFT){
        ILabNFT = _laboNFT;
        uint256 _preMintLabs = ILabNFT.getPreMintNumber();
        for(uint256 i = 1 ; i <= _preMintLabs ;){
            labDetails[i].numberOfSpots = ILabNFT.numberOfWorkingSpots(i);
            unchecked {
                ++ i;
            }
        }
    }

    modifier onlyLaboOwner(uint256 _laboId) {
        require(
            ILabNFT.ownerOf(
                _laboId
            ) == msg.sender
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

    function setGameAddresses(address _address) external onlyOwner {
        require(address(gameAddresses) == address(0x0), "game addresses already setted");
        gameAddresses = IAddresses(_address);
        emit GameAddressesSetted(_address);
    }
    
    function updateInterfaces() external  {
        Potions = IPotions(gameAddresses.getAddressOf(AddressesInit.Addresses.POTIONS_NFT));
        IPay = IPayments(gameAddresses.getAddressOf(AddressesInit.Addresses.PAYMENTS));
        IZai = IZaiNFT(gameAddresses.getAddressOf(AddressesInit.Addresses.ZAI_NFT));
        ZaiMeta =IZaiMeta(gameAddresses.getAddressOf(AddressesInit.Addresses.ZAI_META));
        IOpen = IOpenAndClose(gameAddresses.getAddressOf(AddressesInit.Addresses.OPEN_AND_CLOSE));
        IDel = IDelegate(gameAddresses.getAddressOf(AddressesInit.Addresses.DELEGATE));
        claimNftAddress = gameAddresses.getAddressOf(AddressesInit.Addresses.CLAIM_NFTS);
        emit InterfacesUpdated(address(Potions), address(IPay),address(IZai), address(ZaiMeta), address(IOpen),address(IDel), claimNftAddress);
    }

    // UPDATE AUDIT : used when openAndClose create a new center for init number of spot
    function initSpotsNumber(uint256 _tokenId) external returns(bool){
        require(msg.sender == address(ILabNFT),"Only lab");
        labDetails[_tokenId].numberOfSpots = 3;
        return true;
    }

    function setPointCreditCost(uint256 _cost) external onlyOwner {
        uint256 oldCost = pointCreditCost;
        pointCreditCost = _cost;
        emit MetricsChanged("POINT_CREDIT_COST", oldCost, _cost);
    }

    function setMaxCredit(uint256 _credit) external onlyOwner {
        require(_credit >= 1000000 && _credit <= 10000000, "Not a good value");
        uint256 _oldMetric = maxCredit;
        maxCredit = _credit;
        emit MetricsChanged("MAX_CREDIT_CAP_FOR_LABORATORY", _oldMetric, _credit);
    }

    function setWorkingSpotPrice(uint256 _price) external onlyOwner {
        uint256 _oldMetric = workingSpotPrice;
        workingSpotPrice = _price;
        emit MetricsChanged("WORKING_SPOT_PRICE_FOR_LABORATORY", _oldMetric, _price);
    }

    // UPDATE AUDIT : for front end 
    function getLabDetails(uint256 _tokenId) external view returns(LaboStruct.LabDetails memory){
        return labDetails[_tokenId];
    }

    // UPDATE AUDIT : can add more than 1 spot 
    function addWorkingSpotToLab(uint256 _laboId, uint256 _quantity)
        external
        onlyLaboOwner(_laboId)
        returns (bool)
    {
        uint256 _totalPrice = workingSpotPrice * _quantity;

        require(IPay.payWithRewardOrWallet(msg.sender,_totalPrice ));
        IPay.distributeFees(_totalPrice);

        require(ILabNFT.updateNumberOfWorkingSpots(_laboId, _quantity));
        labDetails[_laboId].numberOfSpots += _quantity;
        return true;
    }

    function workInASpot(
        uint256 _zaiId,
        uint256 _laboId,
        uint256 _spotId
    ) external canUseZai(_zaiId) {
        // UPDATE AUDIT : prevent bot action
        require(tx.origin == msg.sender, "contract not allowed");

        require(
            ILabNFT.ownerOf(_laboId) != claimNftAddress,
            "Lab not active"
        );
        require(ZaiMeta.isFree(_zaiId), "Not Free");
        require(
            ILabNFT.numberOfWorkingSpots(_laboId) > _spotId,
            "spot doesn't exist"
        );
        LaboStruct.WorkInstance storage w = labDetails[_laboId].workingSpot[_spotId];
        require(
            w.zaiId == 0 || block.timestamp > w.beginingAt + 1 days,
            "Spot not free"
        );

        _updateCredits(_laboId);

        if (w.zaiId != 0) {
            require(
                _updateZai(
                    w.zaiId,
                    _getManaWon(block.timestamp, w.beginingAt),
                    true
                )
            );
        } else {
            ++ labDetails[_laboId].employees;
        }
        w.zaiId = _zaiId;
        w.beginingAt = block.timestamp;
        ZaiMeta.updateStatus(
            _zaiId,
            3,
            _laboId,
            _spotId
        );
    }

    function stopWorking(
        uint256 _zaiId,
        uint256 _laboId,
        uint256 _spotId
    ) external canUseZai(_zaiId) {
        // UPDATE AUDIT : delete checking spot existance => we only need to check zai working on spot
        LaboStruct.WorkInstance storage w = labDetails[_laboId].workingSpot[_spotId];
        require(w.zaiId == _zaiId, "Your zai doesn't work on this spot");
        require(
            _updateZai(
                w.zaiId,
                _getManaWon(block.timestamp, w.beginingAt),
                (block.timestamp - w.beginingAt > 1 days)
            )
        );
        w.beginingAt = 0;
        w.zaiId = 0;
        -- labDetails[_laboId].employees;
        _updateCredits(_laboId);
    }

    function _getManaWon(uint256 _finished, uint256 _start)
        internal
        pure
        returns (uint256 mana)
    {
        uint256 _duration = _finished - _start;
        if (_duration <= 21600) {
            // less than 6 h
            mana = 0;
        } else if (_duration <= 43200) {
            // less than 12h
            mana = 500;
        } else if (_duration <= 86400) {
            // less than 24h
            mana = 1000;
        } else if (_duration <= 129600) {
            // less than 36h
            mana = 2000;
        } else {
            mana = 3000;
        }
    }

    // manaMax is the maximum a Zai can store in mana
    // to increase manaMax, a Zai must finish at least 24h of work in a spot
    // a Zai can't have more than 10k of manamax
    function _updateZai(
        uint256 _zaiId,
        uint256 _mana,
        bool _manaMaxUpgrade
    ) internal returns (bool) {
        ZaiMeta.updateStatus(_zaiId, 0, 0, 0);
        if (_manaMaxUpgrade) {
            ++ zaiNumberOfWork[_zaiId];
            ++ userNumberOfWork[
                IZai.ownerOf(_zaiId)
            ];
        }

        return (
            ZaiMeta.updateMana(
                _zaiId,
                _mana,
                0,
                // 2 first work give 1000 manaMax. next give 100
                _manaMaxUpgrade ? zaiNumberOfWork[_zaiId] <= 2 ? 1000 : 100 : 0
            )
        );
    }

    function getCredit(uint256 _laboId) external view returns (uint256) {
        return _getCredit(_laboId);
    }

    function _getCredit(uint256 _laboId)
        internal
        view
        returns (uint256 credits)
    {
        LaboStruct.LabDetails storage lab = labDetails[_laboId];
        uint256 _creditLastUpdate = ILabNFT.getCreditLastUpdate(_laboId);

        if (_creditLastUpdate == 0) {
            credits = 0;
        } else {
            uint256 _timePassed = block.timestamp - _creditLastUpdate;
            if (lab.employees != 0) {
                credits =
                    lab.potionsCredits +
                    (_timePassed * lab.employees);
                if (credits > maxCredit) {
                    credits = maxCredit;
                }
            } else {
                credits = lab.potionsCredits + (_timePassed / 4);
            }
        }
    }

    function createAndSellPotion(
        uint256 _quantity,
        uint256 _price,
        uint256 _type,
        uint256 _power,
        uint256 _laboId
    ) external onlyLaboOwner(_laboId) returns (bool) {
        require(_quantity != 0 && _power != 0,"Quantity and Power can't be 0");
        require(_type < 5 || _type == 8, "not good potion");
        require(_quantity <= 5, "Only 5 potions max can be created by tx");
        require(
            IOpen.canLaboSell(
                _laboId
            ),
            "You can't"
        );
        LaboStruct.LabDetails storage lab = labDetails[_laboId];
        _updateCredits(_laboId);
        require(
            lab.potionsCredits >= (_quantity * _power * pointCreditCost),
            "Not enough credits"
        );

        lab.potionsCredits -= (_quantity * _power * pointCreditCost);

        for (uint256 i ; i < _quantity; ) {
            uint256 potionId = Potions.mintPotionForSale(
                _laboId,
                _price,
                _type,
                _power
            );
            laboUnsoldPotions[_laboId].add(potionId);
            emit PotionCreatedForSale(msg.sender, _laboId, _price, potionId, _type, _power);
            unchecked {
                ++i;
            }
        }

        return true;
    }

    function changePotionPrice(
        uint256 _potionId,
        uint256 _laboId,
        uint256 _price
    ) external onlyLaboOwner(_laboId) returns (bool) {
        emit PotionPriceChanged(_potionId, _price);
        return
            Potions.changePotionPrice(
                _potionId,
                _laboId,
                _price
            );
    }

    function getUnsoldPotions(uint256 _laboId, uint256 _startIndex, uint256 _quantity)
        external
        view
        returns (PotionStruct.Potion[] memory unSoldPotions)
    {
        uint256 unSoldNumber = laboUnsoldPotions[_laboId].length();

        if(unSoldNumber < _quantity){
            for (uint256 i ; i < unSoldNumber; ) {
                uint256 potionId = laboUnsoldPotions[_laboId].at(i);
                PotionStruct.Potion memory p = Potions.getFullPotion(potionId);
                unSoldPotions[i] = p;
                unchecked {
                    ++i;
                }
            }
        }else if(_startIndex + _quantity > unSoldNumber){
            for (uint256 i = _startIndex; i < unSoldNumber; ) {
                uint256 potionId = laboUnsoldPotions[_laboId].at(i);
                PotionStruct.Potion memory p = Potions.getFullPotion(potionId);
                unSoldPotions[i - _startIndex] = p;
                unchecked {
                    ++i;
                }
            }
        }else{
            for (uint256 i = _startIndex; i < _startIndex + _quantity; ) {
                uint256 potionId = laboUnsoldPotions[_laboId].at(i);
                PotionStruct.Potion memory p = Potions.getFullPotion(potionId);
                unSoldPotions[i - _startIndex] = p;
                unchecked {
                    ++i;
                }
            }
        }
    }

    // offering potion (to owner or anybody) cost 2 x the pointCredit needs 
    function offerPotion(
        uint256 _type,
        uint256 _power,
        uint256 _laboId,
        address _to
    ) external onlyLaboOwner(_laboId) {
        require(_type < 5 || _type == 8, "not good potion");
        require(
            IOpen.canLaboSell(
                _laboId
            ),
            "You can't"
        );
        LaboStruct.LabDetails storage lab = labDetails[_laboId];
        _updateCredits(_laboId);
        require(
            lab.potionsCredits >= (_power * 2 * pointCreditCost),
            "Not enough credits"
        );
        lab.potionsCredits -= (_power * 2 * pointCreditCost);

        uint256 potionId =  Potions.offerPotion(
                _type,
                _power,
                _to
            );

        emit PotionOffered(msg.sender, _laboId, _to, potionId, _type, _power);
        
    }

    function buyPotions(
        uint256[] memory _potionsIds,
        uint256[] memory _maxPrice
    ) external {
        for (uint256 i ; i < _potionsIds.length; ) {
            buyPotion(_potionsIds[i], _maxPrice[i]);
            unchecked {
                ++i;
            }
        }
    }

    function buyPotion(uint256 _potionId, uint256 _maxPrice) public {
        require(
            IERC721(address(Potions)).ownerOf(_potionId) == address(this),
            "Not in sale"
        );

        PotionStruct.Potion memory p = Potions.getFullPotion(
            _potionId
        );
        require(IOpen.canLaboSell(p.fromLab),"Labo who mint this potion is closed");

        require(_maxPrice >= p.listingPrice, "Price changed");

        require(IPay.payWithRewardOrWallet(msg.sender, p.listingPrice));
        IPay.payOwner(p.seller, p.listingPrice);


        require(IPotions(address(Potions)).updatePotionSaleTimestamp(_potionId));

        labDetails[p.fromLab].revenues += p.listingPrice;
        laboUnsoldPotions[p.fromLab].remove(_potionId);

        IERC721(address(Potions)).transferFrom(
            address(this),
            msg.sender,
            _potionId
        );

        emit PotionSold(p.seller,p.fromLab,msg.sender,p.listingPrice,_potionId);
    }

    // used to prevent Zai locked in a "work" instance when a labo is in close process
    function cleanSlotsBeforeClosing(uint256 _laboId) external returns (bool) {
        require(
            msg.sender == address(IOpen),
            "Not authorized to clean"
        );
        LaboStruct.LabDetails storage lab = labDetails[_laboId];

        if (lab.employees == 0) {
            return true;
        } else {
            uint256 numberOfSpots = ILabNFT.numberOfWorkingSpots(_laboId);
            for (uint256 i = 0; i < numberOfSpots; ) {
                LaboStruct.WorkInstance storage w = lab.workingSpot[i];
                if (w.zaiId != 0) {
                    bool _manaMaxUpgrade = block.timestamp - w.beginingAt >
                        1 days;
                    require(
                        _updateZai(
                            w.zaiId,
                            _getManaWon(block.timestamp, w.beginingAt),
                            _manaMaxUpgrade
                        )
                    );
                    w.beginingAt = 0;
                    w.zaiId = 0;
                    -- lab.employees;
                    if (lab.employees == 0) {
                        break;
                    }
                }
                unchecked {
                    ++i;
                }
            }
            return true;
        }
    }

    function _updateCredits(uint256 _laboId) internal {
        uint256 _credit = _getCredit(_laboId);
        require(
            ILabNFT.updateCreditLastUpdate(_laboId)
        );
        labDetails[_laboId].potionsCredits = _credit;
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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