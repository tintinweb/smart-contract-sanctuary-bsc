// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIExpedition.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../Utility/TransferHelper.sol";
import "../Utility/DIArrayHelper.sol";
import "../XWorldGames/XWorldInterfaces.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIStar1155.sol";

import "../DIStar/DIStar.sol";
import "../version.sol"; 
import "./DIExpedition_V2_Config.sol";

//import "hardhat/console.sol";

/**
 * @dev Dream Idol Expedition contract
 * this contract implements {DIExpeditionProxy}
 */
contract DIExpedition is
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    IERC721ReceiverUpgradeable,
    IERC1155Receiver,
    ERC1967UpgradeUpgradeable
{
    using DIArrayHelper for uint256[];

    event EquipedCharcterSetuped(
        address indexed userAddr,
        uint256 indexed fansNFTId,
        uint8 ecIndex,
        EquipedCharacter ec
    );
    event EquipedCharacterDismissed(
        address indexed userAddr,
        uint8 ecIndex,
        EquipedCharacter ec
    );
    event EquipedCharcterAddEquip(
        address indexed userAddr,
        uint256 indexed fansNFTId,
        uint8 ecIndex,
        uint256[] star1155ExpeditionItemIds,
        EquipedCharacter ec
    );
    event EquipedCharcterRemoveEquip(
        address indexed userAddr,
        uint256 indexed fansNFTId,
        uint8 ecIndex,
        uint256 star1155ExpeditionItemId,
        EquipedCharacter ec
    );
    event EquipedCharcterRemoveEquipFailed(
        address indexed userAddr,
        uint256 indexed fansNFTId,
        uint8 ecIndex,
        uint256 star1155ExpeditionItemId
    );
    event UserExpeditionStarted(
        address indexed userAddr,
        uint32 indexed levelId,
        EquipedCharacter ec
    );
    event UserExpeditionPullbacked(
        address indexed userAddr,
        uint32 indexed levelId,
        EquipedCharacter ec
    );
    event DreamPointFilled(
        address indexed userAddr,
        uint32 indexed levelId,
        uint64 currentRound,
        uint256 dpValue,
        EquipedCharacter ec
    );
    event UserRoundFinished(
        address indexed userAddr,
        uint32 indexed levelId,
        uint64 round,
        ExpeditionUserStatus userStatus
    );

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant STAR_ROLE = keccak256("STAR_ROLE");

    DITokens1155 public _token1155_notuse;//deprecated
    DIFansNFT public _fansNFT_notuse;//deprecated
    DIStar1155 public _star1155_notuse;//deprecated
    DIStarNFT public _starNft_notuse;//deprecated
    DIStarPool public _starPool_notuse;//deprecated

    DIStarFactory public _starFactory_notuse;//deprecated

    MaxEquipedCharsBySP[] public _maxEquipedCharsBySP_notuse;//deprecated
    mapping(address => EquipedCharacter[]) public _equipedChars;
    mapping(address => uint8[]) public _freeEquipedCharIndices;

    mapping(uint32 => ExpeditionLevelConfig) public _expeditionLevelConfs_notuse;//deprecated
    mapping(uint32 => ExpeditionLevel) _expeditionLevels;

    DIExpedition_V2_Config config;

    // do not use constructor, use initialize instead
    constructor() {}

    /**
     * @dev get current implement version
     *
     * @return current version in string
     */
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }

    // use initializer to limit call once
    // initializer store in proxy ,so only first contract call this
    function initialize() public initializer {
        __Context_init_unchained();

        __Pausable_init_unchained();

        __AccessControl_init_unchained();
        __ERC1967Upgrade_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(STAR_ROLE, _msgSender());
    }

    /**
     * @dev pause contract
     *
     * Requirements:
     * - caller must have `PAUSER_ROLE`
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "DI1");
        _pause();
    }

    /**
     * @dev pause contract
     *
     * Requirements:
     * - caller must have `PAUSER_ROLE`
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "DI1");
        _unpause();
    }

    function setConfigAddress(address configaddr) external {
        config = DIExpedition_V2_Config(configaddr);
    }

    function getConfigAddress() public view returns (address) {
        return address(config);
    }

    function setupEquipedCharacter_Transfer(
        uint256 starNftCharId,
        uint256[] memory star1155ExpeditionItemIds
    ) internal returns(DIStarNFTDataBase memory nftData,DIFansNFTData memory fansData, uint64 fansNFTId,IDIStarNFTCodec nftCodec) {
        DIStarNFT _starNft = config._starNft();
        require(_starNft.ownerOf(starNftCharId) == _msgSender(), "DI6");
        require(star1155ExpeditionItemIds.length <= 6, "DI7");
        nftData = _starNft.getNftData(starNftCharId);
        //console.log("[sol]nftData.reserve1",nftData.reserve1);
        require(nftData.role > 0, "DI8");
        require(nftData.tp == 1, "DI9");
        // check star nft

        // transfer star nft
        _starNft.safeTransferFrom(_msgSender(), address(this), starNftCharId);

         // get fans nft data
        DIStar star = DIStar(
            config._starFactory().getDIStarAddress(nftData.role)
        );
        require(address(star) != address(0), "DIa");
        fansNFTId = star.getFansNFTByUser(_msgSender());
        require(fansNFTId != 0, "DIb");

        fansData = config._fansNFT().getNftData(fansNFTId);

        nftCodec = IDIStarNFTCodec(_starNft.getCodec());
    }

    function setupEquipedCharacter(
        uint256 starNftCharId,
        uint256[] memory star1155ExpeditionItemIds
    ) external returns (uint8 index) {

        DIStarNFTDataBase memory nftData;
        DIFansNFTData memory fansData;
        uint64 fansNFTId;
        IDIStarNFTCodec nftCodec;

        (nftData,fansData,fansNFTId,nftCodec) = setupEquipedCharacter_Transfer(
            starNftCharId,
            star1155ExpeditionItemIds
        );

       

        EquipedCharacter storage ec;
        (index, ec) = _getFreeEquipedCharacter(fansData);

        require(ec.role == 0 && ec.totalCombatPower == 0, "DIc");

        // get character data & setup combat power
        //IDIStarNFTCodec nftCodec = IDIStarNFTCodec(_starNft.getCodec());
        DIStarCharacter memory cd = nftCodec.getCharacterData(nftData);

        //console.log("[sol]cd.combatPower",cd.combatPower);
        ec.role = nftData.role;
        ec.totalCombatPower = cd.combatPower;
        ec.starNftCharId = starNftCharId;

        DIStar1155 _star1155 = config._star1155();
        IDIStar1155Codec codec = IDIStar1155Codec(_star1155.getCodec());
        for (uint32 i = 0; i < star1155ExpeditionItemIds.length; ++i) {
            // check expedition item 1155 id
            DIStar1155IDAttr memory itemAttr = codec.getDIStarAttrByID(
                star1155ExpeditionItemIds[i]
            );
            require(itemAttr.tp == 2, "DId");
            require(itemAttr.role == nftData.role || itemAttr.role == 0, "DIe");

            // transfer expedition item 1155
            require(
                _star1155.balanceOf(
                    _msgSender(),
                    star1155ExpeditionItemIds[i]
                ) >= 1,
                "DIf"
            );
            _star1155.safeTransferFrom(
                _msgSender(),
                address(this),
                star1155ExpeditionItemIds[i],
                1,
                "se"
            );

            // get expedition item data & add combat power
            (, DIStar1155DataBase memory expeditionData) = _star1155.getNftData(
                star1155ExpeditionItemIds[i]
            );
            DIStarExpeditionItem memory ed = codec.getExpeditionData(
                expeditionData
            );
            //console.log("[sol]setupEquipedCharacter combatPower",ed.combatPower);
            ec.totalCombatPower += ed.combatPower;
        }
        ec.star1155ExpeditionItemIds = star1155ExpeditionItemIds;
        ec.inLevelId = 0;
        //console.log("[sol]setupEquipedCharacter totalCombatPower fansData",ec.totalCombatPower,fansData.sp);
        //require(ec.totalCombatPower <= fansData.sp, "DIExpedition: support power not enough");
        if (ec.totalCombatPower > fansData.sp) {
            ec.totalCombatPower = fansData.sp;
        }

        emit EquipedCharcterSetuped(_msgSender(), fansNFTId, index, ec);

        return index;
    }

    function dismissEquipedCharacter(uint8 equipedCharIndex) external {
        // dissmis equiped character and get back assets
        EquipedCharacter[] storage ecs = _equipedChars[_msgSender()];
        require(equipedCharIndex < ecs.length, "DIg");
        EquipedCharacter storage ec = ecs[equipedCharIndex];
        require(ec.role > 0, "DIh");

        require(ec.inLevelId == 0, "DIi");
        DIStarNFT _starNft = config._starNft();
        // transfer star nft
        require(_starNft.ownerOf(ec.starNftCharId) == address(this), "DIj");
        _starNft.safeTransferFrom(
            address(this),
            _msgSender(),
            ec.starNftCharId
        );
        DIStar1155 _star1155 = config._star1155();
        for (uint32 i = 0; i < ec.star1155ExpeditionItemIds.length; ++i) {
            require(
                _star1155.balanceOf(
                    address(this),
                    ec.star1155ExpeditionItemIds[i]
                ) >= 1,
                "DIf"
            );
            _star1155.safeTransferFrom(
                address(this),
                _msgSender(),
                ec.star1155ExpeditionItemIds[i],
                1,
                "dis"
            );
        }

        uint8[] storage freeIndices = _freeEquipedCharIndices[_msgSender()];
        freeIndices.push(equipedCharIndex);

        emit EquipedCharacterDismissed(_msgSender(), equipedCharIndex, ec);

        //config._deleteEquipedCharacter(equipedCharIndex);
        delete ecs[equipedCharIndex];
    }

    function addEquipToCharacter(
        uint8 equipedCharIndex,
        uint256[] memory star1155ExpeditionItemIds
    ) external {
        // add equip to equiped character
        EquipedCharacter[] storage ecs = _equipedChars[_msgSender()];
        require(equipedCharIndex < ecs.length, "DIg");
        EquipedCharacter storage ec = ecs[equipedCharIndex];
        require(ec.role > 0, "DIh");

        // get fans nft data
        DIStar star = DIStar(config._starFactory().getDIStarAddress(ec.role));
        uint64 fansNFTId = star.getFansNFTByUser(_msgSender());
        require(fansNFTId != 0, "DIb");

        require(ec.inLevelId == 0, "DIi");

        require(
            ec.star1155ExpeditionItemIds.length +
                star1155ExpeditionItemIds.length <=
                6,
            "DI7"
        );

        DIStar1155 _star1155 = config._star1155();
        IDIStar1155Codec codec = IDIStar1155Codec(_star1155.getCodec());
        for (uint32 i = 0; i < star1155ExpeditionItemIds.length; ++i) {
            // check expedition item 1155 id
            DIStar1155IDAttr memory itemAttr = codec.getDIStarAttrByID(
                star1155ExpeditionItemIds[i]
            );
            require(itemAttr.tp == 2, "DId");
            require(itemAttr.role == ec.role || itemAttr.role == 0, "DIe");

            // transfer expedition item 1155
            require(
                _star1155.balanceOf(
                    _msgSender(),
                    star1155ExpeditionItemIds[i]
                ) >= 1,
                "DIf"
            );
            _star1155.safeTransferFrom(
                _msgSender(),
                address(this),
                star1155ExpeditionItemIds[i],
                1,
                "add"
            );

            // get expedition item data & add combat power
            (, DIStar1155DataBase memory expeditionData) = _star1155.getNftData(
                star1155ExpeditionItemIds[i]
            );
            DIStarExpeditionItem memory ed = codec.getExpeditionData(
                expeditionData
            );
            //console.log("[sol]setupEquipedCharacter combatPower",ed.combatPower);
            ec.totalCombatPower += ed.combatPower;

            ec.star1155ExpeditionItemIds.push(star1155ExpeditionItemIds[i]);
        }

        DIFansNFTData memory fansData = config._fansNFT().getNftData(fansNFTId);

        //console.log("[sol]setupEquipedCharacter totalCombatPower fansData",ec.totalCombatPower,fansData.sp);
        //require(ec.totalCombatPower <= fansData.sp, "DIExpedition: support power not enough");
        if (ec.totalCombatPower > fansData.sp) {
            ec.totalCombatPower = fansData.sp;
        }

        emit EquipedCharcterAddEquip(
            _msgSender(),
            fansNFTId,
            equipedCharIndex,
            star1155ExpeditionItemIds,
            ec
        );
    }

    function removeEquipFromCharacter(
        uint8 equipedCharIndex,
        uint256 star1155ExpeditionItemId
    ) external {
        // remove equip from equiped characters
        EquipedCharacter[] storage ecs = _equipedChars[_msgSender()];
        require(equipedCharIndex < ecs.length, "DIg");
        EquipedCharacter storage ec = ecs[equipedCharIndex];
        require(ec.role > 0, "DIh");

        // get fans nft data
        DIStar star = DIStar(config._starFactory().getDIStarAddress(ec.role));
        uint64 fansNFTId = star.getFansNFTByUser(_msgSender());
        require(fansNFTId != 0, "DIb");

        DIStar1155 _star1155 = config._star1155();
        bool success;
        for (uint32 i = 0; i < ec.star1155ExpeditionItemIds.length; ++i) {
            require(
                _star1155.balanceOf(
                    address(this),
                    ec.star1155ExpeditionItemIds[i]
                ) >= 1,
                "DIf"
            );

            if (ec.star1155ExpeditionItemIds[i] == star1155ExpeditionItemId) {
                _star1155.safeTransferFrom(
                    address(this),
                    _msgSender(),
                    ec.star1155ExpeditionItemIds[i],
                    1,
                    "remove"
                );

                // get expedition item data & add combat power
                IDIStar1155Codec codec = IDIStar1155Codec(_star1155.getCodec());
                (, DIStar1155DataBase memory expeditionData) = _star1155
                    .getNftData(ec.star1155ExpeditionItemIds[i]);
                DIStarExpeditionItem memory ed = codec.getExpeditionData(
                    expeditionData
                );

                // sub combat power
                require(ec.totalCombatPower > ed.combatPower, "DIk");
                ec.totalCombatPower -= ed.combatPower;

                // remove from array
                ec.star1155ExpeditionItemIds.remove(i);

                success = true;

                break;
            }
        }

        if (success) {
            emit EquipedCharcterRemoveEquip(
                _msgSender(),
                fansNFTId,
                equipedCharIndex,
                star1155ExpeditionItemId,
                ec
            );
        } else {
            emit EquipedCharcterRemoveEquipFailed(
                _msgSender(),
                fansNFTId,
                equipedCharIndex,
                star1155ExpeditionItemId
            );
        }
    }

    function startExpedition(uint8 equipedCharIndex, uint32 levelId) external {
        // check equiped character
        EquipedCharacter[] storage ecs = _equipedChars[_msgSender()];
        require(equipedCharIndex < ecs.length, "DIg");
        EquipedCharacter storage ec = ecs[equipedCharIndex];
        require(ec.role > 0, "DIh");

        require(ec.inLevelId == 0, "DIl");

        for (uint256 i = 0; i < ecs.length; ++i) {
            require(
                ecs[i].inLevelId != levelId,
                "DI: other equiped char in same level"
            );
        }

        // // get fans nft data
        // DIStar star = DIStar(_starFactory.getDIStarAddress(ec.role));
        // require(address(star) != address(0), "DIa");
        // uint64 fansNFTId =  star.getFansNFTByUser(_msgSender());
        // require(fansNFTId != 0, "DIb");

        ExpeditionLevelConfig memory conf = config.getExpeditionLevelConfig(
            levelId
        );
        require(conf.maxDreamCoinPerRound > 0, "DI4");

        require(conf.maxCombatPower >= ec.totalCombatPower, "DIm");
        require(conf.minCombatPower <= ec.totalCombatPower, "DIn");
        require(conf.role == ec.role || conf.role == 0, "DIo");

        DIStar star = DIStar(config._starFactory().getDIStarAddress(ec.role));
        DIStarInfo memory starInfo = star.getStarInfo();
        require(conf.level <= starInfo.level, "DIp");

        ec.inLevelId = levelId;

        emit UserExpeditionStarted(_msgSender(), levelId, ec);
    }

    function pullbackExpedition(uint8 equipedCharIndex) external {
        // check equiped character
        EquipedCharacter[] storage ecs = _equipedChars[_msgSender()];
        require(equipedCharIndex < ecs.length, "DIg");
        EquipedCharacter storage ec = ecs[equipedCharIndex];
        require(ec.inLevelId > 0, "DIq");

        ExpeditionLevel storage level = _expeditionLevels[ec.inLevelId];
        ExpeditionLevelStatus storage levelStatus = level.roundStatus[
            level.currentRound
        ];

        require(
            levelStatus.userStatus[_msgSender()].userDreamPoint <= 0,
            "DIr"
        );

        ec.inLevelId = 0;

        emit UserExpeditionPullbacked(_msgSender(), ec.inLevelId, ec);
    }

    function fillDreamPoint(uint8 equipedCharIndex, uint256 dpValue) external {
        // check equiped character
        EquipedCharacter[] storage ecs = _equipedChars[_msgSender()];
        require(equipedCharIndex < ecs.length, "DIg");
        EquipedCharacter storage ec = ecs[equipedCharIndex];
        require(ec.inLevelId > 0, "DIq");

        // // get fans nft data
        // DIStar star = DIStar(_starFactory.getDIStarAddress(ec.role));
        // require(address(star) != address(0), "DIa");
        // uint64 fansNFTId =  star.getFansNFTByUser(_msgSender());
        // require(fansNFTId != 0, "DIb");

        ExpeditionLevelConfig memory conf = config.getExpeditionLevelConfig(
            ec.inLevelId
        );
        require(conf.maxDreamCoinPerRound > 0, "DI4");

        (
            ExpeditionLevel storage level,
            ExpeditionLevelStatus storage levelStatus
        ) = _checkAndProcCurrRound(ec.inLevelId, conf);

        // calc dp by cp
        uint64 maxDreamPoint = (ec.totalCombatPower *
            conf.dreamPointPerCombatPower) / 1000000;

        // check dream point value range
        require(
            dpValue >= conf.minDreamPoint &&
                levelStatus.userStatus[_msgSender()].userDreamPoint + dpValue <=
                maxDreamPoint,
            // getMaxDreamPointByCombatPower(ec.totalCombatPower)
            "DIs"
        );
        DITokens1155 _token1155 = config._token1155();
        require(
            _token1155.balanceOf(_msgSender(), _token1155.DREAM_POINT_ID()) >=
                dpValue,
            "DIt"
        );
        // burn dream point
        _token1155.burn(_msgSender(), _token1155.DREAM_POINT_ID(), dpValue);

        levelStatus.userStatus[_msgSender()].userDreamPoint += dpValue;
        levelStatus.totalDreamPoint += dpValue;

        emit DreamPointFilled(
            _msgSender(),
            ec.inLevelId,
            level.currentRound,
            dpValue,
            ec
        );
    }

    function finishUserRound(uint32 levelId, uint64 round) external {
        ExpeditionLevelConfig memory conf = config.getExpeditionLevelConfig(
            levelId
        );
        require(conf.maxDreamCoinPerRound > 0, "DI4");

        (ExpeditionLevel storage level, ) = _checkAndProcCurrRound(
            levelId,
            conf
        );

        require(round < level.currentRound, "DIu");

        ExpeditionLevelStatus storage levelStatus = level.roundStatus[round];
        require(levelStatus.endBlock > 0, "DIv");

        ExpeditionUserStatus storage userStatus = levelStatus.userStatus[
            _msgSender()
        ];
        require(userStatus.userDreamPoint > 0, "DIw");
        require(userStatus.dreamCoinGained <= 0, "DIx");

        // get all dream coin to mint in this round
        uint256 dreamCoinToMint = conf.maxDreamCoinPerRound;

        if (conf.role > 0) {
            address starAddr = config._starFactory().getDIStarAddress(
                conf.role
            );
            uint8 starLevel = DIStar(starAddr).getStarInfo().level;

            if (starLevel < conf.starLevelAddDreamCoinPerRound.length) {
                dreamCoinToMint += conf.starLevelAddDreamCoinPerRound[
                    starLevel
                ];
            }
        }

        uint256 dreamCoinGained = (userStatus.userDreamPoint *
            conf.dreamCoinPerDreamPoint) / 1000000; // fixed rate
        userStatus.dreamCoinGained =
            (userStatus.userDreamPoint * dreamCoinToMint) /
            levelStatus.totalDreamPoint; // divided by total dream points
        if (dreamCoinGained < userStatus.dreamCoinGained) {
            // use the minimum one
            userStatus.dreamCoinGained = dreamCoinGained;
        }

        require(
            levelStatus.totalDreamCoinGained + userStatus.dreamCoinGained <=
                dreamCoinToMint,
            "DIy"
        );

        levelStatus.totalDreamCoinGained += userStatus.dreamCoinGained;

        config._starPool().giveDreamCoins(
            _msgSender(),
            userStatus.dreamCoinGained
        );

        emit UserRoundFinished(_msgSender(), levelId, round, userStatus);
    }

    function _getFreeEquipedCharacter(DIFansNFTData memory fansData)
        internal
        returns (uint8 index, EquipedCharacter storage ec)
    {
        // check equiped characters array length
        EquipedCharacter[] storage ecs = _equipedChars[_msgSender()];
        uint8[] storage freeIndices = _freeEquipedCharIndices[_msgSender()];
        require(
            ecs.length < 128 &&
                (ecs.length <
                    config.getMaxEquipedCharactersByFansSP(fansData.sp) ||
                    freeIndices.length > 0),
            "DIz"
        );

        // add new equiped characters
        if (freeIndices.length > 0) {
            index = freeIndices[freeIndices.length - 1];
            freeIndices.pop();
        } else {
            index = uint8(ecs.length);
            ecs.push();
        }
        ec = ecs[index];
    }

    function getCurrentLevelRound(uint32 levelId)
        external
        view
        returns (uint64 round)
    {
        return _expeditionLevels[levelId].currentRound;
    }

    function getLevelRoundStatus(uint32 levelId, uint64 round)
        external
        view
        returns (
            uint256 endBlock,
            uint256 totalDreamPoint,
            uint256 totalDreamCoinGained
        )
    {
        endBlock = _expeditionLevels[levelId].roundStatus[round].endBlock;
        totalDreamPoint = _expeditionLevels[levelId]
            .roundStatus[round]
            .totalDreamPoint;
        totalDreamCoinGained = _expeditionLevels[levelId]
            .roundStatus[round]
            .totalDreamCoinGained;
    }

    function getLevelRoundUserStatus(
        uint32 levelId,
        uint64 round,
        address userAddr
    ) external view returns (uint256 userDreamPoint, uint256 dreamCoinGained) {
        userDreamPoint = _expeditionLevels[levelId]
            .roundStatus[round]
            .userStatus[userAddr]
            .userDreamPoint;
        dreamCoinGained = _expeditionLevels[levelId]
            .roundStatus[round]
            .userStatus[userAddr]
            .dreamCoinGained;
    }

    function _checkAndProcCurrRound(
        uint32 levelId,
        ExpeditionLevelConfig memory conf
    )
        internal
        returns (
            ExpeditionLevel storage level,
            ExpeditionLevelStatus storage levelStatus
        )
    {
        level = _expeditionLevels[levelId];
        if (level.currentRound <= 0) {
            // first round
            level.currentRound = 1;
            level.roundStatus[level.currentRound].endBlock =
                block.number +
                conf.blockInterval;
            //level.status.totalDreamPoint = 0;
        }

        levelStatus = level.roundStatus[level.currentRound];

        // new round
        if (levelStatus.endBlock <= block.number) {
            level.currentRound++;
            levelStatus = level.roundStatus[level.currentRound];
            levelStatus.endBlock = block.number + conf.blockInterval;
        }
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        operator;
        from;
        tokenId;
        data;
        return this.onERC721Received.selector;
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        operator;
        from;
        tokenId;
        value;
        data;
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        operator;
        from;
        ids;
        values;
        data;
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIFansNFT.sol)

pragma solidity ^0.8.0;

import "./core/DIExtendableNFT.sol";
import "./version.sol";
// nft fixed data
struct DIFansNFTData{
    uint64  maxSP; // max support power
    uint64  sp; // support power
    uint64  invitorNftId; // invitor fans nft token id, use uint64 instead of uint256 to save gas
    uint64  producerNftId; // belong to which producer nft token id, use uint64 instead of uint256 to save gas

    uint8   fanType; // 1: gensis producer, 2: super fan, 3: fan
    uint32  starRole; // card role
    uint8   grade;

    uint208 reserve; // for update
    uint32[] reserve1; // for update
}

/**
 * @dev Extension of {XWorldExtendableNFT} that with fixed token data struct
 */
contract DIFansNFT is DIExtendableNFT {
    using Counters for Counters.Counter;
    
    /**
    * @dev emit when new token has been minted, see {DIFansNFTData}
    *
    * @param to owner of new token
    * @param tokenId new token id
    * @param data token data see {DIFansNFTData}
    */
    event DIFansNFTMint(address indexed to, uint256 indexed tokenId, DIFansNFTData data);

    /**
    * @dev emit when token data modified, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param grade token data see {DIFansNFTData}
    */
    event DIFansModGrade(uint256 indexed tokenId, uint8 grade);

    /**
    * @dev emit when token data modified, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param maxSP token data see {DIFansNFTData}
    */
    event DIFansModMaxSP(uint256 indexed tokenId, uint64 maxSP);

    /**
    * @dev emit when token data modified, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param maxSP max sp after add, token data see {DIFansNFTData}
    * @param maxSPAdd max sp added, token data see {DIFansNFTData}
    */
    event DIFansAddMaxSP(uint256 indexed tokenId, uint64 maxSP, uint64 maxSPAdd);

    /**
    * @dev emit when token data modified, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param sp token data see {DIFansNFTData}
    */
    event DIFansModSp(uint256 indexed tokenId, uint64 sp);

    /**
    * @dev emit when token data modified, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param sp sp after add, token data see {DIFansNFTData}
    * @param spAdd sp added, token data see {DIFansNFTData}
    */
    event DIFansAddSp(uint256 indexed tokenId, uint64 sp, uint64 spAdd);

    /**
    * @dev emit when token data modified, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param reserve token data see {DIFansNFTData}
    */
    event DIFansModReserve(uint256 indexed tokenId, uint208 reserve);

    /**
    * @dev emit when token data modified, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param index data index
    * @param reserve token data see {DIFansNFTData}
    */
    event DIFansModReserve1(uint256 indexed tokenId, uint32 index, uint208 reserve);
    
    /**
    * @dev emit when token reserve1 data append, see {DIFansNFTData}
    *
    * @param tokenId new token id
    * @param index data index
    * @param reserve token data see {DIFansNFTData}
    */
    event DIFansAppendReserve1(uint256 indexed tokenId, uint32 index, uint208 reserve);
    
    mapping(uint256 => DIFansNFTData) private _nftDatas; // token id => nft data stucture

    bytes32 public constant FACTORY_ADMIN_ROLE = keccak256("FACTORY_ADMIN_ROLE");

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        DIExtendableNFT(name, symbol, baseTokenURI)
    {
        mint(_msgSender(), DIFansNFTData({
            fanType:0,
            starRole:0,
            grade:0,
            maxSP:0,
            sp:0,
            invitorNftId:0,
            producerNftId:0,
            reserve:0,
            reserve1:new uint32[](0)
        })); // mint first token to notify event scan

        _setRoleAdmin(DATA_ROLE, FACTORY_ADMIN_ROLE);
        _setRoleAdmin(FREEZE_ROLE, FACTORY_ADMIN_ROLE);
    }
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }
    /**
     * @dev Creates a new token for `to`, emit {XWorldNFTMint}. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     *
     * @param to new token owner address
     * @param data token data see {DIFansNFTData}
     * @return new token id
     */
    function mint(address to, DIFansNFTData memory data) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        DIFansNFTData storage nftData = _nftDatas[curID];
        nftData.fanType = data.fanType;
        nftData.starRole = data.starRole;
        nftData.grade = data.grade;
        nftData.maxSP = data.maxSP;
        nftData.sp = data.sp;
        nftData.invitorNftId = data.invitorNftId;
        nftData.producerNftId = data.producerNftId;
        nftData.reserve = data.reserve;
        nftData.reserve1 = data.reserve1;

        emit DIFansNFTMint(to, curID, data);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param grade token data see {DIFansNFTData}
     */
    function modGrade(uint256 tokenId, uint8 grade) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");

        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        nftData.grade = grade;
        
        emit DIFansModGrade(tokenId, grade);
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param maxSP token data see {DIFansNFTData}
     */
    function modMaxSP(uint256 tokenId, uint64 maxSP) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");
        
        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        nftData.maxSP = maxSP;
        if(nftData.sp > nftData.maxSP){
            nftData.sp = nftData.maxSP;
        }

        emit DIFansModMaxSP(tokenId, maxSP);
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param maxSPAdd max sp to add, token data see {DIFansNFTData}
     */
    function addMaxSP(uint256 tokenId, uint64 maxSPAdd, uint64 maxSPLimit) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");
        
        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        // check max sp limit
        if(nftData.maxSP + maxSPAdd > maxSPLimit) {
            if(nftData.maxSP >= maxSPLimit) {
                maxSPAdd = 0;
            }
            else {
                maxSPAdd = maxSPLimit - nftData.maxSP;
            }
        }

        nftData.maxSP += maxSPAdd;

        emit DIFansAddMaxSP(tokenId, nftData.maxSP, maxSPAdd);
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param sp token data see {DIFansNFTData}
     */
    function modSp(uint256 tokenId, uint64 sp) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");
        
        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        nftData.sp = sp;
        if(nftData.sp > nftData.maxSP){
            nftData.sp = nftData.maxSP;
        }

        emit DIFansModSp(tokenId, sp);
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param spAdd sp to add, token data see {DIFansNFTData}
     */
    function addSp(uint256 tokenId, uint64 spAdd) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");
        
        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        nftData.sp += spAdd;
        if(nftData.sp > nftData.maxSP){
            nftData.sp = nftData.maxSP;
        }

        emit DIFansAddSp(tokenId, nftData.sp, spAdd);
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param reserve token data see {DIFansNFTData}
     */
    function modReserve(uint256 tokenId, uint208 reserve) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");
        
        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        nftData.reserve = reserve;

        emit DIFansModReserve(tokenId, reserve);
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param reserve token data see {DIFansNFTData}
     * @return index data index
     */
    function appendReserve1(uint256 tokenId, uint32 reserve) external returns(uint32 index) {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");
        
        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        index = uint32(nftData.reserve1.length);
        nftData.reserve1.push(reserve);

        emit DIFansAppendReserve1(tokenId, index, reserve);
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param index data index
     * @param reserve token data see {DIFansNFTData}
     */
    function modReserve1(uint256 tokenId, uint32 index, uint32 reserve) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");
        
        DIFansNFTData storage nftData = _nftDatas[tokenId];
        
        require(nftData.fanType > 0, "DIFansNFT: token not exist");

        nftData.reserve1[index] = reserve;

        emit DIFansModReserve1(tokenId, index, reserve);
    }

    /**
     * @dev get token data
     *
     * @param tokenId token id
     * @param data token data see {DIFansNFTData}
     */
    function getNftData(uint256 tokenId) external view returns(DIFansNFTData memory data){
        require(_exists(tokenId), "T1");

        data = _nftDatas[tokenId];
    }

}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStar1155.sol)

pragma solidity ^0.8.0;

import "./core/DIExtendable1155.sol";
import "./version.sol";
// 1155 id : 1: joy (dream point), 2: dream (dream coin)
contract DITokens1155 is DIExtendable1155 {

    uint256 public constant DREAM_POINT_ID = 1;
    uint256 public constant DREAM_COIN_ID = 2;

    constructor(string memory uri) DIExtendable1155("Dream Idol Tokens", "DITS", uri) {
        mint(_msgSender(), 0, 1, new bytes(0)); // mint first token to notify event scan
    }
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStar1155.sol)

pragma solidity ^0.8.0;

import "./core/DIExtendable1155.sol";

import "./DIStarAssetDefine.sol";
import "./version.sol";
// 1155 id : combine with dream idol star 1155 attribute, see IDIStar1155Codec
contract DIStar1155 is DIExtendable1155 {

    address public _codec;

    mapping(uint256 => DIStar1155DataBase) private _datas; // token id => nft data stucture

    constructor(string memory uri) DIExtendable1155("Dream Idol Star Semi-fungible Token", "DIST", uri) {
        mint(_msgSender(), 0, 1, new bytes(0)); // mint first token to notify event scan
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(DATA_ROLE, _msgSender());
    }

    function setCodec(address c) external {
        require(
            hasRole(DATA_ROLE, _msgSender()),
            "call DIStar1155.setCodec need DATA_ROLE"
        );

        _codec = c;
    }
    function getCodec() external view returns(address c) {
        return _codec;
    }
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }
    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param data token data see {DIStar1155DataBase}
     */
    function modNftData(uint256 tokenId, DIStar1155DataBase memory data) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");

        _datas[tokenId] = data;
    }

    /**
     * @dev get token data
     *
     * @param tokenId token id
     * @param data token data see {DIStar1155DataBase}
     */
    function getNftData(uint256 tokenId) external view returns(uint256 nftId, DIStar1155DataBase memory data){
        nftId = tokenId;
        data = _datas[tokenId];
    }

}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStar1155.sol)

pragma solidity ^0.8.0;

//定义baseversion，整体需要清理数据时修改此处即可
string constant baseversionTag = "_1010C";

// contracts/TransferHelper.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// contracts/XWorldInterfaces.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IXWGRecyclePoolManager {
    // methType = 0 : lock, methType = 1 : unlock;
    function changeRecycleBalance(uint256 methType, uint256 amount) external;
}

interface IXWGDCCardNFT {
    function mint(address player) external returns (uint256);
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IXWGDCCardNFTRepository {

    function add(uint256 id, uint32[] calldata role, uint grade, uint[] calldata skills, uint fiveElements) external;

    function updateRole(uint256 id, uint index, uint32 value) external;
    function updateGrade(uint256 id, uint grade) external;
    function updateSkill(uint256 id, uint index, uint16 value) external;
    function updateFiveElements(uint256 id, uint fiveElement) external;

    function remove(uint256 id) external;

    function get(uint256 id) external view returns(uint32[] memory role, uint grade, uint[] memory skills, uint fiveElement);
}


// id=tp<<8|grade; xwg fuel tp=3, grade=1;
interface IXWorldCardCrystal1155 {
    function burn(address account, uint256 id, uint256 value) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIArrayHelper.sol)

pragma solidity ^0.8.0;

library DIArrayHelper {
    function remove(uint[] storage array, uint index) external {
        require(index < array.length && array.length > 0, "out of array range");

        for(uint i=index; i < array.length - 1; ++i) {
            array[i] = array[i+1];
        }
        array.pop();
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStar.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../Binance/Interface/ISBT721.sol";

import "../XWorldGames/XWorldInterfaces.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIStar1155.sol";

import "./IDIStarFactory.sol";
import "./DIStarPool.sol";
import "./DIStarAssetStore1155.sol";
import "./DIStarAssetStoreNFT.sol";
import "../version.sol";
struct DIStarInfo {
    uint32 fansCount; // fans count
    uint8 level; // level 
    uint64 popularity; // popularity
    uint64 reputation; // reputation
}

struct FansNFTOpData {
    mapping(uint32=>uint256) lastCheckinBlock; // checkin type => last checkin block number
    mapping(uint32=>uint256) lastSupportBlock; // support type => block number
    mapping(uint32=>uint256) lastDreamCoinSupportBlock; // support type => block number
}

/**
 * @dev Dream Idol Star contract, manage stars
 * this contract implements {DIStarProxy}
 */
contract DIStar is
    Initializable,
    ContextUpgradeable, 
    PausableUpgradeable, 
    AccessControlUpgradeable,
    ERC1967UpgradeUpgradeable
{
    event StarPopularityAdded(uint32 indexed starRole, uint64 pop, uint64 popAdded);
    event StarReputationAdded(uint32 indexed starRole, uint64 rep, uint64 repAdded);
    event FansNFTBinded(uint32 indexed starRole, uint64 indexed tokenId, address indexed userAddr);
    event FansNFTUnbinded(uint32 indexed starRole, uint64 indexed tokenId, address indexed userAddr);

    event DaylyCheckin(uint32 indexed starRole, address indexed userAddr, uint64 indexed tokenId, CheckinConfig checkInConf);
    event DaylySupport(uint32 indexed starRole, address indexed userAddr, uint64 indexed tokenId, SupportConfig supportConf);
    event DaylyDCSupport(uint32 indexed starRole, address indexed userAddr, uint64 indexed tokenId, DreamCoinSupportConfig supportConf);
    
    event StarUpgraded(uint32 indexed starRole, uint8 newLevel, address indexed opAddr);
    event StarRoomItemActivated(uint32 indexed starRole, DIStarRoomItem item);
    event FansNFTSPUpgrade(address indexed userAddr, uint32 indexed starRole, uint64 indexed tokenId, uint64 spAdd, uint256 dcValue);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant STAR_ROLE = keccak256("STAR_ROLE");

    uint32 public _starRole;
    DIStarInfo public _starInfos;
    DIStarRoomItem[] public _starRoomItems;

    DIFansNFT public _fansNFT;
    DIStarPool public _starPool;
    DIStarAssetStore1155 public _starStore1155;
    DIStarAssetStoreNFT public _starStoreNft;
    DITokens1155 public _token1155;

    IDIStarFactory_Config public _starFactory;

    mapping(uint64=>address) _fansNFT2UserAddr;
    mapping(address=>uint64) _userAddrBindFansNFT;

    mapping(uint64=>FansNFTOpData) _fansNFTOpDatas; // fans nft id => fans nft operation data

    // do not use constructor, use initialize instead
    constructor() {}

    /**
     * @dev get current implement version
     *
     * @return current version in string
     */
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }
    // use initializer to limit call once
    // initializer store in proxy ,so only first contract call this
    function initialize() public initializer {
        __Context_init_unchained();

        __Pausable_init_unchained();

        __AccessControl_init_unchained();
        __ERC1967Upgrade_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(STAR_ROLE, _msgSender());

        _starInfos.level = 1; // init level to 1
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIStar: must have pauser role to pause"
        );
        _pause();
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIStar: must have pauser role to unpause"
        );
        _unpause();
    }

    /**
    * @dev set contract address of {DIFansNFT}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param fansNFT address of {DIFansNFT}
    */
    function setDIFansNftAddress(address fansNFT) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _fansNFT = DIFansNFT(fansNFT);
    }

    /**
    * @dev set contract address of {DIStarPool}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param pool address of {DIStarPool}
    */
    function setDIStarPoolAddress(address pool) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: must have manager role"
        );
        _starPool = DIStarPool(pool);
    }

    /**
    * @dev set contract address of {IDIStarFactory}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param f address of {IDIStarFactory}
    */
    function setIDIStarFactory_Config(address f) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _starFactory = IDIStarFactory_Config(f);
    }

    /**
    * @dev set contract address of {DIStarAssetStore1155} and {DIStarAssetStoreNFT}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param store1155 address of {DIStarAssetStore}
    * @param storenft address of {DIStarAssetStoreNFT}
    */
    function setDIStarAssetStore(address store1155, address storenft) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _starStore1155 = DIStarAssetStore1155(store1155);
        _starStoreNft = DIStarAssetStoreNFT(storenft);
    }

    /**
    * @dev set contract address of {DITokens1155}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param token1155 address of {DITokens1155}
    */
    function setDITokens1155Address(address token1155) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _token1155 = DITokens1155(token1155);
    }

    function getStarInfo() external view returns(DIStarInfo memory info) {
        return _starInfos;
    }

    // // call by {DIFansCreator} contract, when success convert a genesis fan nft
    // function onGenesisFanCreated(uint256 tokenId, DIFansNFTData memory data, uint8 creatingPhase) external {
    //     require(
    //         hasRole(STAR_ROLE, _msgSender()),
    //         "DIStar: must have star role"
    //     );

    //     DIStarInfo storage starInfo = _starInfos[data.starRole];
    //     starInfo.fansCount++;

    //     // TO DO : 
    //     tokenId;
    //     creatingPhase;
    // }

    // call by {DIFansCreator} contract, when success genesis
    function onGenesisSuccess(uint32 starRole) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStar: must have star role"
        );
        
        _starRole = starRole;
    }

    // call by {DIFansCreator} contract, when success convert a super fan nft
    function onSuperFanCreated(uint256 tokenId, DIFansNFTData memory data) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStar: must have star role"
        );

        tokenId; // not used

        // add fans count
        _starInfos.fansCount++;

        DIStarsConfig memory config = _starFactory.getDIStarConfig();

        if(_fansNFT.exists(data.invitorNftId)) {
            // add max sp for inviter
            _addFansMaxSP(data.invitorNftId, _fansNFT.getNftData(data.invitorNftId), config.inviteSuperFanMaxSP);

            address inviterAddr = getUserByFansNFT(data.invitorNftId);
            if(inviterAddr != address(0)) {
                // give dream point
                //_token1155.mint(inviterAddr, _token1155.DREAM_POINT_ID(), config.inviteSuperFanDP, "invite");
                _starPool.giveDreamPoints(inviterAddr, config.inviteSuperFanDP);
            }
        }

        // add star popularity
        _addStarPop(config.newSuperFanPop);
    }
    // call by {DIFansCreator} contract, when success convert a normal fan nft
    function onNormalFanCreated(uint256 tokenId, DIFansNFTData memory data) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStar: must have star role"
        );

        tokenId; // not used

        // add fans count
        _starInfos.fansCount++;

        DIStarsConfig memory config = _starFactory.getDIStarConfig();

        if(_fansNFT.exists(data.invitorNftId)) {
            // add max sp for inviter
            _addFansMaxSP(data.invitorNftId, _fansNFT.getNftData(data.invitorNftId), config.inviteNormalFanMaxSP);

            address inviterAddr = getUserByFansNFT(data.invitorNftId);
            if(inviterAddr != address(0)) {
                // give dream point
                //_token1155.mint(inviterAddr, _token1155.DREAM_POINT_ID(), config.inviteNormalFanDP, "invite");
                _starPool.giveDreamPoints(inviterAddr, config.inviteNormalFanDP);
            }
        }

        // add star popularity
        _addStarPop(config.newNormalFanPop);
    }

    // call by {DIStarAssetStore} contract, when a room item finished fund raise
    function onStarRoomItemActivate(DIStarRoomItem memory item) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStar: must have star role"
        );

        _starRoomItems.push(item);

        emit StarRoomItemActivated(_starRole, item);
    }

    // query method
    function getUserByFansNFT(uint64 tokenId) public view returns(address userAddr) {
        return _fansNFT2UserAddr[tokenId];
    }

    // query method
    function getFansNFTByUser(address userAddr) public view returns(uint64 tokenId) {
        return _userAddrBindFansNFT[userAddr];
    }

    // call by other contract, add max sp to fans nft
    function addFansMaxSP(uint256 fansNFTId, DIFansNFTData memory fansNftData, uint64 maxSpAdd) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStar: must have star role"
        );

        _addFansMaxSP(fansNFTId, fansNftData, maxSpAdd);
    }

    // call by client wallet, binding a fans nft as main fan with caller wallet
    // this op will freeze nft which binded
    function bindFansNFT(uint256 tokenId) external whenNotPaused {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        require(_fansNFT.ownerOf(tokenId) == _msgSender(), "DIStar: ownership error");
        require(_fansNFT2UserAddr[uint64(tokenId)] == address(0), "DIStar: nft already binded");

        _fansNFT2UserAddr[uint64(tokenId)] = _msgSender();
        _userAddrBindFansNFT[_msgSender()] = uint64(tokenId);

        // freeze token from transfer
        _fansNFT.freeze(tokenId);

        emit FansNFTBinded(_starRole, uint64(tokenId), _msgSender());
    }

    // call by client wallet, unbinding a fans nft from caller wallet
    function unbindFansNFT(uint256 tokenId) external whenNotPaused {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        require(_fansNFT.ownerOf(tokenId) == _msgSender(), "DIStar: ownership error");

        address userAddr = _fansNFT2UserAddr[uint64(tokenId)];
        require(userAddr != address(0), "DIStar: nft not binded");

        _fansNFT2UserAddr[uint64(tokenId)] = address(0);
        _userAddrBindFansNFT[userAddr] = 0;

        // unfreeze token from transfer
        _fansNFT.unfreeze(tokenId);

        emit FansNFTUnbinded(_starRole, uint64(tokenId), userAddr);
    }

    // call by client wallet, dayly checkin and get dream point
    function daylyCheckin(uint32 checkinType) external whenNotPaused {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        uint64 fansNFTId = _userAddrBindFansNFT[_msgSender()];
        require(fansNFTId != 0, "DIStar: must bind fans nft");

        //DIFansNFTData memory fansNFTData = _fansNFT.getNftData(fansNFTId);
        DIStarsConfig memory config = _starFactory.getDIStarConfig();

        FansNFTOpData storage nftOpData = _fansNFTOpDatas[fansNFTId];

        // check blocks passed 
        require(block.number - nftOpData.lastCheckinBlock[checkinType] > config.checkinBlocksInterval, 
            "DIStar: checkin block number not ready");

        // change lastCheckinBlock
        nftOpData.lastCheckinBlock[checkinType] += 
            (block.number - nftOpData.lastCheckinBlock[checkinType])/config.checkinBlocksInterval * config.checkinBlocksInterval;

        CheckinConfig memory checkInConf = _starFactory.getCheckinConfigByLevel(_starInfos.level, checkinType);
        require(checkInConf.maxSPAdd > 0, "DIStar: checkin config error");

        // add max sp to user
        _addFansMaxSP(fansNFTId, _fansNFT.getNftData(fansNFTId), checkInConf.maxSPAdd);

        if(checkInConf.dpAdd > 0){
            // give dream point
            //_token1155.mint(_msgSender(), _token1155.DREAM_POINT_ID(), checkInConf.dpAdd, "checkin");
            _starPool.giveDreamPoints(_msgSender(), checkInConf.dpAdd);
        }

        // add star popularity
        _addStarPop(checkInConf.popAdd);

        emit DaylyCheckin(_starRole, _msgSender(), fansNFTId,checkInConf);
    }

    // call by client wallet, dayly support cost other token and get dream point
    function daylySupport(uint32 supportType) external whenNotPaused {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        uint64 fansNFTId = _userAddrBindFansNFT[_msgSender()];
        require(fansNFTId != 0, "DIStar: must bind fans nft");

        //DIStarsConfig memory config = _starFactory.getDIStarConfig();

        FansNFTOpData storage nftOpData = _fansNFTOpDatas[fansNFTId];

        SupportConfig memory supportConfig = _starFactory.getSupportConfigByLevelAndType(_starInfos.level, supportType);
        require(supportConfig.tokenAddr != address(0), "DIStar: support config error");

        // check blocks passed 
        require(block.number - nftOpData.lastSupportBlock[supportType] > supportConfig.blocksInterval, 
            "DIStar: support block number not ready");

        // change lastCheckinBlock
        nftOpData.lastSupportBlock[supportType] += 
            (block.number - nftOpData.lastSupportBlock[supportType])/supportConfig.blocksInterval * supportConfig.blocksInterval;

        // charge token
        if(supportConfig.tokenId > 0) {
            // erc1155
            require(IERC1155(supportConfig.tokenAddr).balanceOf(_msgSender(), supportConfig.tokenId) >= supportConfig.tokenValue, "DIStar: insufficient token");

            // transfer tokens
            _starPool.charge1155Token(supportConfig.tokenAddr, _msgSender(), supportConfig.tokenId, supportConfig.tokenValue, "support");
            
            // notify star pool support income
            _starPool.onShare1155Income(_starPool.INCOME_STAR_SUPPORT(), supportConfig.tokenAddr, supportConfig.tokenId, fansNFTId, supportConfig.tokenValue);
        }
        else {
            require(IERC20(supportConfig.tokenAddr).balanceOf(_msgSender()) >= supportConfig.tokenValue, "DIStar: insufficient token");

            // transfer tokens
            _starPool.charge20Token(supportConfig.tokenAddr, _msgSender(), supportConfig.tokenValue);
            
            // notify star pool support income
            _starPool.onShare20Income(_starPool.INCOME_STAR_SUPPORT(), supportConfig.tokenAddr, fansNFTId, supportConfig.tokenValue);
        }

        if(supportConfig.maxSPAdd > 0) {
            // add max sp to fan
            _addFansMaxSP(fansNFTId, _fansNFT.getNftData(fansNFTId), supportConfig.maxSPAdd);
        }

        if(supportConfig.dpAdd > 0){
            // give dream point
            //_token1155.mint(_msgSender(), _token1155.DREAM_POINT_ID(), supportConfig.dpAdd, "support");
            _starPool.giveDreamPoints(_msgSender(), supportConfig.dpAdd);
        }

        if(supportConfig.spAdd > 0)
        {
            //givs sp
            _addFansSP(fansNFTId, supportConfig.spAdd);
        }

        // add star reputation
        _addStarRep(supportConfig.repAdd);

        emit DaylySupport(_starRole, _msgSender(), fansNFTId, supportConfig);
    }

    // call by client wallet, dayly support cost other token and get dream point
    function daylyDreamCoinSupport(uint32 supportType) external whenNotPaused {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        uint64 fansNFTId = _userAddrBindFansNFT[_msgSender()];
        require(fansNFTId != 0, "DIStar: must bind fans nft");

        //DIStarsConfig memory config = _starFactory.getDIStarConfig();

        FansNFTOpData storage nftOpData = _fansNFTOpDatas[fansNFTId];

        DreamCoinSupportConfig memory dcSupportConfig = _starFactory.getDCSupportConfigByLevelAndType(_starInfos.level, supportType);
        require(dcSupportConfig.value > 0, "DIStar: DC support config error");

        // check blocks passed 
        require(block.number - nftOpData.lastDreamCoinSupportBlock[supportType] > dcSupportConfig.blocksInterval, 
            "DIStar: support block number not ready");

        // change lastCheckinBlock
        nftOpData.lastDreamCoinSupportBlock[supportType] += 
            (block.number - nftOpData.lastDreamCoinSupportBlock[supportType])/dcSupportConfig.blocksInterval * dcSupportConfig.blocksInterval;

        // charge token
        require(_token1155.balanceOf(_msgSender(), _token1155.DREAM_COIN_ID()) >= dcSupportConfig.value, "DIStar: insufficient token");
        //_token1155.burn(_msgSender(), _token1155.DREAM_COIN_ID(), dcSupportConfig.value);
        _starPool.burn1155Token(address(_token1155), _msgSender(), _token1155.DREAM_COIN_ID(), dcSupportConfig.value);

        if(dcSupportConfig.maxSPAdd > 0) {
            // add max sp to fan
            _addFansMaxSP(fansNFTId, _fansNFT.getNftData(fansNFTId), dcSupportConfig.maxSPAdd);
        }
        if(dcSupportConfig.spAdd > 0) {
            // add sp to fan
            _fansNFT.addSp(fansNFTId, dcSupportConfig.spAdd);
        }

        // add star reputation
        _addStarRep(dcSupportConfig.repAdd);

        emit DaylyDCSupport(_starRole, _msgSender(), fansNFTId, dcSupportConfig);
    }

    // call by client wallet, upgrade star level when it's ready, get maxSP/sp/dp reward back.
    function upgradeStar() external {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        uint64 fansNFTId = _userAddrBindFansNFT[_msgSender()];
        require(fansNFTId != 0, "DIStar: must bind fans nft");

        StarLevelConfig memory lvlConf = _starFactory.getStarLevelConfigByLevel(_starInfos.level);
        require(lvlConf.reputation > 0, "DIStar: level config error");

        StarLevelConfig memory nextLvlConf = _starFactory.getStarLevelConfigByLevel(_starInfos.level+1);
        require(nextLvlConf.reputation > 0, "DIStar: can't upgrade");

        require(_starInfos.popularity >= lvlConf.popularity, "DIStar: popularity not enough");
        require(_starInfos.reputation >= lvlConf.reputation, "DIStar: reputation not enough");
        require(_starInfos.fansCount >= lvlConf.fansAmount, "DIStar: fans not enough");

        _starInfos.level++;

        // unlock star store assets and put onsale
        _starStore1155.unlockStarLevelAssets(_starRole, _starInfos.level);
        _starStoreNft.unlockStarLevelAssets(_starRole, _starInfos.level);

        if(lvlConf.maxSPAdd > 0) {
            // add max sp to fan
            _addFansMaxSP(fansNFTId, _fansNFT.getNftData(fansNFTId), lvlConf.maxSPAdd);
        }

        if(lvlConf.dpAdd > 0){
            // give dream point
            //_token1155.mint(_msgSender(), _token1155.DREAM_POINT_ID(), lvlConf.dpAdd, "upgrade");
            _starPool.giveDreamPoints(_msgSender(), lvlConf.dpAdd);
        }

        emit StarUpgraded(_starRole, _starInfos.level, _msgSender());
    }

    // call by client wallet, upgrade fans sp by burn dream coin.
    function upgradeFansNftSp(uint256 dcValue) external {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        uint64 fansNFTId = _userAddrBindFansNFT[_msgSender()];
        require(fansNFTId != 0, "DIStar: must bind fans nft");

        uint64 spAdd = _starFactory.getFansNFTSPByDreamCoin(dcValue);

        DIFansNFTData memory fansNftData = _fansNFT.getNftData(fansNFTId);
        require(fansNftData.sp + spAdd <= fansNftData.maxSP, "DIStar: max sp limited");

        require(_token1155.balanceOf(_msgSender(), _token1155.DREAM_COIN_ID()) >= dcValue, "DIStar: insufficient token");
        
        //_token1155.burn(_msgSender(), _token1155.DREAM_COIN_ID(), dcValue);
        _starPool.burn1155Token(address(_token1155), _msgSender(), _token1155.DREAM_COIN_ID(), dcValue);

        _fansNFT.addSp(fansNFTId, spAdd);

        emit FansNFTSPUpgrade(_msgSender(), _starRole, fansNFTId, spAdd, dcValue);
    }

    // call by client wallet, upgrade star character nft by burn star 1155 character item.
    function upgradeStarCharacterNft(uint256 item1155Id, uint256 value) external {
        // TO DO : upgrade star character nft
    }

    // internal functions
    function _addStarPop(uint64 popAdd) internal {
        _starInfos.popularity += popAdd;

        emit StarPopularityAdded(_starRole, _starInfos.popularity, popAdd);
    }

    function _addStarRep(uint64 repAdd) internal {
        _starInfos.reputation += repAdd;

        emit StarReputationAdded(_starRole, _starInfos.reputation, repAdd);
    }

    function _addFansMaxSP(uint256 fansNFTId, DIFansNFTData memory fansNftData, uint64 maxSpAdd) internal {
        // check fans sp limit by star level
        uint64 maxSPLimit = _starFactory.getMaxSPLimitByStarLevel(_starInfos.level);

        uint64 gradeAdd = maxSpAdd*_starFactory.getMaxSPFactorByGrade(fansNftData.grade)/1000000;
        maxSpAdd += gradeAdd + maxSpAdd*_starFactory.getMaxSPFactorByFanType(fansNftData.fanType)/1000000;

        _fansNFT.addMaxSP(fansNFTId, maxSpAdd, maxSPLimit);
    }
    function _addFansSP(uint256 fansNFTId, uint64 spAdd) internal {

        _fansNFT.addSp(fansNFTId, spAdd);
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIExpedition.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../Utility/TransferHelper.sol";
import "../Utility/DIArrayHelper.sol";
import "../XWorldGames/XWorldInterfaces.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIStar1155.sol";

import "../DIStar/DIStar.sol";
//import "hardhat/console.sol";
struct EquipedCharacter {
    uint32 role;
    uint256 starNftCharId;
    uint256[] star1155ExpeditionItemIds;
    uint64 totalCombatPower;
    uint32 inLevelId;
}

struct ExpeditionLevelConfig {
    uint64 maxCombatPower; // maximum combat power allowed
    uint64 minCombatPower; // minimum combat power request
    uint32 role; // = 0 allow any role, > 0 specify role
    uint8 level; // minimum star level request
    uint256 blockInterval;
    uint256 maxDreamCoinPerRound;
    uint256 dreamCoinPerDreamPoint; // dc = dp * dreamCoinPerDreamPoint / 1000000;
    uint256 minDreamPoint; // minimum dream point to fill
    uint32 dreamPointPerCombatPower; // dp = cp * dreamPointPerCombatPower / 1000000;
    uint256[] starLevelAddDreamCoinPerRound; // indexed by starlevel, give additional maxDreamCoinPerRound
}

struct ExpeditionUserStatus {
    uint256 userDreamPoint;
    uint256 dreamCoinGained;
}

struct ExpeditionLevelStatus {
    uint256 endBlock;
    uint256 totalDreamPoint;
    uint256 totalDreamCoinGained;
    mapping(address => ExpeditionUserStatus) userStatus;
}

struct ExpeditionLevel {
    uint64 currentRound;
    mapping(uint64 => ExpeditionLevelStatus) roundStatus;
}
struct MaxEquipedCharsBySP {
    uint64 sp;
    uint8 count;
}

contract DIExpedition_V2_Config is AccessControlUpgradeable {
    using DIArrayHelper for uint256[];

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    DITokens1155 public _token1155;
    DIFansNFT public _fansNFT;
    DIStar1155 public _star1155;
    DIStarNFT public _starNft;
    DIStarPool public _starPool;

    DIStarFactory public _starFactory;


    MaxEquipedCharsBySP[] public _maxEquipedCharsBySP;
   


    mapping(uint32 => ExpeditionLevelConfig) public _expeditionLevelConfs;


    // do not use constructor, use initialize instead
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }
  /**
     * @dev set contract address of {DITokens1155}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param token1155 address of {DITokens1155}
     */
    function setDITokens1155Address(address token1155) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DI5"
        );
        _token1155 = DITokens1155(token1155);
    }

    function getVersion() public pure returns (string memory) {
        return "2.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }
    /**
     * @dev set contract address of {DIFansNFT}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param fansNFT address of {DIFansNFT}
     */
    function setDIFansNftAddress(address fansNFT) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DI5"
        );
        _fansNFT = DIFansNFT(fansNFT);
    }

    /**
     * @dev set contract address of {DIStar1155}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param star1155 address of {DIStar1155}
     */
    function setDIStar1155Address(address star1155) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DI5"
        );
        _star1155 = DIStar1155(star1155);
    }

    /**
     * @dev set contract address of {DIStarNFT}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param starNft address of {DIStarNFT}
     */
    function setDIStarNftAddress(address starNft) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DI5"
        );
        _starNft = DIStarNFT(starNft);
    }

    /**
     * @dev set contract address of {DIStarPool}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param pool address of {DIStarPool}
     */
    function setDIStarPoolAddress(address pool) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DI5"
        );
        _starPool = DIStarPool(pool);
    }

    /**
     * @dev set contract address of {IDIStarFactory}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param f address of {IDIStarFactory}
     */
    function setDIStarFactory(address f) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DI5"
        );
        _starFactory = DIStarFactory(f);
    }

    function setMaxEquipedCharactersByFansSp(uint64 sp, uint8 count) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "DI5");

        _maxEquipedCharsBySP.push(MaxEquipedCharsBySP({sp: sp, count: count}));
    }

    function getMaxEquipedCharactersByFansSP(uint64 sp)
        public
        view
        returns (uint8 maxCount)
    {
        uint256 i = 0;
        for (; i < _maxEquipedCharsBySP.length; ++i) {
            if (sp <= _maxEquipedCharsBySP[i].sp) {
                return _maxEquipedCharsBySP[i].count;
            }
        }

        if (i > 0) {
            return _maxEquipedCharsBySP[i - 1].count;
        }

        revert("DI3");
    }

    function setExpeditionLevelConfig(
        uint32 levelId,
        ExpeditionLevelConfig memory config
    ) public {
        require(hasRole(MANAGER_ROLE, _msgSender()), "DI5");

        ExpeditionLevelConfig storage conf = _expeditionLevelConfs[levelId];
        conf.maxCombatPower = config.maxCombatPower; // maximum combat power allowed
        conf.minCombatPower = config.minCombatPower; // minimum combat power request
        conf.role = config.role; // = 0 allow any role, > 0 specify role
        conf.level = config.level; // minimum star level request

        conf.blockInterval = config.blockInterval;
        conf.maxDreamCoinPerRound = config.maxDreamCoinPerRound;
        conf.dreamCoinPerDreamPoint = config.dreamCoinPerDreamPoint; // dc = dp * dreamCoinPerDreamPoint / 1000000;
        conf.minDreamPoint = config.minDreamPoint; // minimum dream point to fill
        conf.dreamPointPerCombatPower = config.dreamPointPerCombatPower;
        
        conf.starLevelAddDreamCoinPerRound = config.starLevelAddDreamCoinPerRound; 
        // indexed by starlevel, give additional maxDreamCoinPerRound
    }

    function setExpeditionLevelConfigs(
        uint32[] memory levelIds,
        ExpeditionLevelConfig[] memory configs
    ) public {
        require(hasRole(MANAGER_ROLE, _msgSender()), "DI5");
        
        require(levelIds.length == configs.length, "DI2");
        for (uint32 i = 0; i < configs.length; i++) {
            ExpeditionLevelConfig storage conf = _expeditionLevelConfs[
                levelIds[i]
            ];
            ExpeditionLevelConfig memory config = configs[i];
            conf.maxCombatPower = config.maxCombatPower; // maximum combat power allowed
            conf.minCombatPower = config.minCombatPower; // minimum combat power request
            conf.role = config.role; // = 0 allow any role, > 0 specify role
            conf.level = config.level; // minimum star level request

            conf.blockInterval = config.blockInterval;
            conf.maxDreamCoinPerRound = config.maxDreamCoinPerRound;
            conf.dreamCoinPerDreamPoint = config.dreamCoinPerDreamPoint; // dc = dp * dreamCoinPerDreamPoint / 1000000;
            conf.minDreamPoint = config.minDreamPoint; // minimum dream point to fill
            conf.dreamPointPerCombatPower = config.dreamPointPerCombatPower;
            conf.starLevelAddDreamCoinPerRound = config
                .starLevelAddDreamCoinPerRound; // indexed by starlevel, give additional maxDreamCoinPerRound
        }
    }
    function getExpeditionLevelConfig(uint32 index) public view returns(ExpeditionLevelConfig memory)
    {
        return _expeditionLevelConfs[index];
    }

    function getMaxDreamPointByCombatPower(uint32 inLevelId, uint64 cp)
        public
        view
        returns (uint256 dreamPoint)
    {
        // calc dp by cp
        ExpeditionLevelConfig memory conf = _expeditionLevelConfs[inLevelId];
        require(conf.maxDreamCoinPerRound > 0, "DI4");

        dreamPoint = (cp * conf.dreamPointPerCombatPower) / 1000000;
        return dreamPoint;
    }




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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC1155/IERC1155Receiver.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC721Receiver.sol)

pragma solidity ^0.8.0;

import "../token/ERC721/IERC721ReceiverUpgradeable.sol";

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIExtendableNFT.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";
import "./IERC2981Royalties.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract ERC721PresetMinterPauserAutoId is
    Context,
    AccessControl,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable, 
    IERC2981Royalties
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter internal _tokenIdTracker;

    string internal _baseTokenURI;

    // erc2981 royalty fee, /10000
    uint256 public _royalties;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
        _royalties = 25; // 0.25%

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev update base token uri.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function updateURI(string calldata baseTokenURI) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "M1");
        _baseTokenURI = baseTokenURI;
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P1");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "P2");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // set royalties
    function setRoyalties(uint256 royalties) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role");
        _royalties = royalties;
    }

    /// @inheritdoc	IERC2981Royalties
    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = address(this);
        royaltyAmount = (value * _royalties) / 10000;
    }

    // fetch royalty income
    function fetchIncome(address erc20) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role");

        uint256 amount = IERC20(erc20).balanceOf(address(this));
        if(amount > 0) {
            TransferHelper.safeTransfer(erc20, _msgSender(), amount);
        }
    }
}

/**
 * @dev Extension of {ERC721PresetMinterPauserAutoId} that allows token dynamic extend data section
 */
contract DIExtendableNFT is ERC721PresetMinterPauserAutoId {
    
    bytes32 public constant DATA_ROLE = keccak256("DATA_ROLE");
    bytes32 public constant FREEZE_ROLE = keccak256("FREEZE_ROLE");

    /**
    * @dev emit when token has been freezed or unfreeze

    * @param tokenId freezed token id
    * @param freeze freezed or not
    */
    event DINFTFreeze(uint256 indexed tokenId, bool freeze);
    
    /**
    * @dev emit when new data section created

    * @param extendName new data section name
    * @param nameBytes data section name after keccak256
    */
    event DINFTExtendName(string extendName, bytes32 nameBytes);

    /**
    * @dev emit when token data section changed

    * @param tokenId tokenid which data has been changed
    * @param nameBytes data section name after keccak256
    * @param extendData data after change
    */
    event DINFTExtendModify(uint256 indexed tokenId, bytes32 nameBytes, bytes extendData);

    // record of token already extended data section
    struct NFTExtendsNames{
        bytes32[]   NFTExtendDataNames; // array of data sectioin name after keccak256
    }

    // extend data mapping
    struct NFTExtendData {
        bool _exist;
        mapping(uint256 => bytes) ExtendDatas; // tokenid => data mapping
    }

    mapping(uint256 => bool) private _nftFreezed; // tokenid => is freezed
    mapping(uint256 => NFTExtendsNames) private _nftExtendNames; // tokenid => extended data sections
    mapping(bytes32 => NFTExtendData) private _nftExtendDataMap; // extend name => extend datas mapping

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        ERC721PresetMinterPauserAutoId(name, symbol, baseTokenURI) 
    {
    }

    /**
    * @dev freeze token, emit {DINFTFreeze} event
    *
    * Requirements:
    * - caller must have `FREEZE_ROLE`
    *
    * @param tokenId token to freeze
    */
    function freeze(uint256 tokenId) external {
        require(hasRole(FREEZE_ROLE, _msgSender()), "R2");

        _nftFreezed[tokenId] = true;

        emit DINFTFreeze(tokenId, true);
    }

    /**
    * @dev unfreeze token, emit {DINFTFreeze} event
    *
    * Requirements:
    * - caller must have `FREEZE_ROLE`
    *
    * @param tokenId token to unfreeze
    */
    function unfreeze(uint256 tokenId) external {
        require(hasRole(FREEZE_ROLE, _msgSender()), "R3");

        delete _nftFreezed[tokenId];

        emit DINFTFreeze(tokenId, false);
    }

    /**
    * @dev check token, return true if not freezed
    *
    * @param tokenId token to check
    * @return ture if token is not freezed
    */
    function notFreezed(uint256 tokenId) public view returns (bool) {
        return !_nftFreezed[tokenId];
    }

    /**
    * @dev check token, return true if it's freezed
    *
    * @param tokenId token to check
    * @return ture if token is freezed
    */
    function isFreezed(uint256 tokenId) public view returns (bool) {
        return _nftFreezed[tokenId];
    }

    /**
    * @dev check token, return true if it exists
    *
    * @param tokenId token to check
    * @return ture if token exists
    */
    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    /**
    * @dev add new token data section, emit {DINFTExtendName} event
    *
    * Requirements:
    * - caller must have `MINTER_ROLE`
    *
    * @param extendName string of new data section name
    */
    function extendNftData(string memory extendName) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "R5");

        bytes32 nameBytes = keccak256(bytes(extendName));
        NFTExtendData storage extendData = _nftExtendDataMap[nameBytes];
        extendData._exist = true;

        emit DINFTExtendName(extendName, nameBytes);
    }

    /**
    * @dev add extend token data with specify 'extendName', emit {DINFTExtendModify} event
    *
    * Requirements:
    * - caller must have general `DATA_ROLE` or `DATA_ROLE` with the specify `extendName`
    *
    * @param tokenId token to add extend data
    * @param extendName data section name in string
    * @param extendData extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function addTokenExtendNftData(
        uint256 tokenId,
        string memory extendName,
        bytes memory extendData
    ) external whenNotPaused {
        require(
            hasRole(DATA_ROLE, _msgSender()) ||
                hasRole(
                    keccak256(abi.encodePacked("DATA_ROLE", extendName)),
                    _msgSender()
                ),
            "R6"
        );

        bytes32 nameBytes = keccak256(bytes(extendName));
        require(_extendNameExist(nameBytes), "E1");
        require(!_tokenExtendNameExist(tokenId, nameBytes), "E2");

        // modify extend data
        NFTExtendData storage extendDatas = _nftExtendDataMap[nameBytes];
        extendDatas.ExtendDatas[tokenId] = extendData;

        // save token extend data names
        NFTExtendsNames storage nftData = _nftExtendNames[tokenId];
        nftData.NFTExtendDataNames.push(nameBytes);

        emit DINFTExtendModify(tokenId, nameBytes, extendData);
    }

    /**
    * @dev modify extend token data with specify 'extendName', emit {DINFTExtendModify} event
    *
    * Requirements:
    * - caller must have general `DATA_ROLE` or `DATA_ROLE` with the specify `extendName`
    *
    * @param tokenId token to modify extend data
    * @param extendName data section name in string
    * @param extendData extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function modifyTokenExtendNftData(
        uint256 tokenId,
        string memory extendName,
        bytes memory extendData
    ) external whenNotPaused {
        require(
            hasRole(DATA_ROLE, _msgSender()) ||
                hasRole(
                    keccak256(abi.encodePacked("DATA_ROLE", extendName)),
                    _msgSender()
                ),
            "call DIExtendableNFT.modifyTokenExtendNftData need DATA_ROLE"
        );

        bytes32 nameBytes = keccak256(bytes(extendName));
        require(_extendNameExist(nameBytes), "E4");
        require(_tokenExtendNameExist(tokenId, nameBytes), "E5");

        // modify extend data
        NFTExtendData storage extendDatas = _nftExtendDataMap[nameBytes];
        extendDatas.ExtendDatas[tokenId] = extendData;

        emit DINFTExtendModify(tokenId, nameBytes, extendData);
    }

    /**
    * @dev get extend token data with specify 'extendName'
    *
    * @param tokenId token to get extend data
    * @param extendName data section name in string
    * @return extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function getTokenExtendNftData(uint256 tokenId, string memory extendName)
        external
        view
        returns (bytes memory)
    {
        bytes32 nameBytes = keccak256(bytes(extendName));
        require(_extendNameExist(nameBytes), "E6");

        NFTExtendData storage extendDatas = _nftExtendDataMap[nameBytes];
        return extendDatas.ExtendDatas[tokenId];
    }

    function _extendNameExist(bytes32 nameBytes) internal view returns (bool) {
        return _nftExtendDataMap[nameBytes]._exist;
    }
    function _tokenExtendNameExist(uint256 tokenId, bytes32 nameBytes) internal view returns(bool) {
        NFTExtendsNames memory nftData = _nftExtendNames[tokenId];
        for(uint i=0; i<nftData.NFTExtendDataNames.length; ++i){
            if(nftData.NFTExtendDataNames[i] == nameBytes){
                return true;
            }
        }
        return false;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(notFreezed(tokenId), "F1");

        super._beforeTokenTransfer(from, to, tokenId);

        if (to == address(0)) {
            // delete token extend datas;
            NFTExtendsNames memory nftData = _nftExtendNames[tokenId];
            for(uint i = 0; i< nftData.NFTExtendDataNames.length; ++i){
                NFTExtendData storage extendData = _nftExtendDataMap[nftData.NFTExtendDataNames[i]];
                delete extendData.ExtendDatas[tokenId];
            }

            // delete token datas
            delete _nftExtendNames[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IERC2981Royalties
/// @dev Interface for the ERC2981 - Token Royalty standard
interface IERC2981Royalties {
    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _value - the sale price of the NFT asset specified by _tokenId
    /// @return _receiver - address of who should be sent the royalty payment
    /// @return _royaltyAmount - the royalty payment amount for value sale price
    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../utils/Context.sol";

/**
 * @title ERC721 Burnable Token
 * @dev ERC721 Token that can be burned (destroyed).
 */
abstract contract ERC721Burnable is Context, ERC721 {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC721 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC721Pausable is ERC721, Pausable {
    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIExtendable1155.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";
import "./IERC2981Royalties.sol";

/**
 * @dev {ERC1155} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract ERC1155PresetMinterPauser is 
    Context, 
    AccessControl, 
    ERC1155Burnable, 
    ERC1155Pausable, 
    ERC1155Supply, 
    IERC2981Royalties 
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // erc2981 royalty fee, /10000
    uint256 public _royalties;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `PAUSER_ROLE` to the account that
     * deploys the contract.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri
    ) ERC1155(uri) {
        _name = name_;
        _symbol = symbol_;
        _royalties = 25; // 0.25%

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @dev As 1155 contract name for some dApp which read name from contract, See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev As 1155 contract symbol for some dApp which read symbol from contract, See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev update base token uri, See {IERC1155MetadataURI-uri}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function updateURI(string calldata newuri) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to update");
        _setURI(newuri);
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mint(to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role to mint");

        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC1155Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // set royalties
    function setRoyalties(uint256 royalties) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role");
        _royalties = royalties;
    }

    /// @inheritdoc	IERC2981Royalties
    function royaltyInfo(uint256, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = address(this);
        royaltyAmount = (value * _royalties) / 10000;
    }

    // fetch royalty income
    function fetchIncome(address erc20) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC1155PresetMinterPauser: must have minter role");

        uint256 amount = IERC20(erc20).balanceOf(address(this));
        if(amount > 0) {
            TransferHelper.safeTransfer(erc20, _msgSender(), amount);
        }
    }
}

contract DIExtendable1155 is ERC1155PresetMinterPauser {
    
    bytes32 public constant DATA_ROLE = keccak256("DATA_ROLE");

    /**
    * @dev emit when token data section changed

    * @param id 1155 id which data has been changed
    * @param extendData data after change
    */
    event DIExtendable1155Modify(uint256 indexed id, bytes extendData);

    mapping(uint256=>bytes) _extendDatas;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri) ERC1155PresetMinterPauser(name_, symbol_, uri) 
    {
    }

    /**
    * @dev modify extend 1155 data, emit {DIExtendable1155Modify} event
    *
    * Requirements:
    * - caller must have general `DATA_ROLE`
    *
    * @param id 1155 id to modify extend data
    * @param extendData extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function modifyExtendData(
        uint256 id,
        bytes memory extendData
    ) external whenNotPaused {
        require(
            hasRole(DATA_ROLE, _msgSender()),
            "call DIExtendable1155.modifyExtendData need DATA_ROLE"
        );

        require(
            exists(id),
            "E4"
        );

        // modify extend data
        _extendDatas[id] = extendData;

        emit DIExtendable1155Modify(id, extendData);
    }

    /**
    * @dev get extend 1155 data 
    *
    * @param id 1155 id to get extend data
    * @return extend data in bytes, use a codec to encode or decode the bytes data outside
    */
    function getTokenExtendNftData(uint256 id)
        external
        view
        returns (bytes memory)
    {
        require(exists(id), "E6");

        return _extendDatas[id];
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Burnable is ERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );

        _burnBatch(account, ids, values);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC1155 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Pausable is ERC1155, Pausable {
    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarAssetDefine.sol)

pragma solidity ^0.8.0;

import "./DIStarAssetDefine.sol";

struct DIStar1155IDAttr {
    uint32  role; // star role, =0 match any role, >0 role id
    uint16  tp; // type =1 : character item, =2 : expedition item, =3 : room item, =4 : mystery box
    uint32  id; // id
}

struct DIStar1155DataBase {
    uint8   grade; // grade

    uint248 reserve1; // for update
    uint32[] reserve2; // for update
}

struct DIStarCharacterItem {
    uint8 citp; // charcter item type = 1: add exp, = 2: add combat power, = 3: change skill
    uint64 add;
}

struct DIStarExpeditionItem {
    uint64 combatPower;
    uint8 slot;
    uint32 avatar;
    uint32 func;
}

struct DIStarRoomItem {
    uint32 roomItemId;
    uint32 roomItemType;
}

struct DIMysteryBoxItem {
    uint32 randomType;
    uint32 mysteryType;
}

interface IDIStar1155Codec {
    function getDIStarAttrByID(uint256 id) external pure returns(DIStar1155IDAttr memory attr);
    function setDIStarAttrToID(DIStar1155IDAttr memory attr) external pure returns(uint256 id);

    function getIDFromRoleAndAttribue(uint32 role, uint256 attr) external pure returns(uint256 id);
    function getTpFromID(uint256 id) external pure returns(uint16 tp);

    function getCharacterItemData(DIStar1155DataBase memory data) external pure returns(DIStarCharacterItem memory ed);
    function fromCharacterItemData(DIStarCharacterItem memory data)
        external
        pure
        returns (DIStar1155DataBase memory outdata);

    function getExpeditionData(DIStar1155DataBase memory data) external pure returns(DIStarExpeditionItem memory ed);
    function fromExpeditionItemData(DIStarExpeditionItem memory data)
        external
        pure
        returns (DIStar1155DataBase memory outdata);

    function getRoomItemData(DIStar1155DataBase memory data) external pure returns(DIStarRoomItem memory rd);
    function fromRoomItemData(DIStarRoomItem memory data)
        external
        pure
        returns (DIStar1155DataBase memory outdata);

    function getMysteryBoxData(DIStar1155DataBase memory data) external pure returns(DIMysteryBoxItem memory rd);
    function fromMysteryBoxData(DIMysteryBoxItem memory data)
        external
        pure
        returns (DIStar1155DataBase memory outdata);
}

interface IDIStarNFTCodec {
    function getCharacterData(DIStarNFTDataBase memory data) external pure returns(DIStarCharacter memory cd);
    function fromCharacterData(DIStarCharacter memory data) external pure returns (DIStarNFTDataBase memory outdata);
}

struct DIStarNFTDataBase {
    uint32  role;
    uint8  tp; // type = 1: character nft
    uint8   grade; // grade

    uint216 reserve1; // for update
    uint256 reserve2; // for update
    uint32[] reserve3; // for update
}

struct DIStarCharacter {
    uint8 level;
    uint64 exp;
    uint64 combatPower;
    uint32 avatar;
    uint32 skill;
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (IDIStarFactory.sol)

pragma solidity ^0.8.0;

struct DIStarsConfig {
    // fans sp by dream coin
    uint256 supportPowerByDreamCoin; // sp = dream coin * supportPowerByDreamCoin / 100000000

    // super fan 
    uint64 inviteSuperFanMaxSP; // maxSP add to inviter
    uint64 inviteSuperFanDP; // give dream point to inviter
    uint64 newSuperFanPop; // add popularity to star

    // normal fan
    uint64 inviteNormalFanMaxSP; // maxSP add to inviter
    uint64 inviteNormalFanDP; // give dream point to inviter
    uint64 newNormalFanPop; // add popularity to star

    // checkin
    uint64 checkinBlocksInterval; // indicate must wait how many blocks after previous checkin
}

struct StarLevelConfig {
    uint64 popularity; // popularity needed to upgrade to next level, in total
    uint64 reputation; // reputation needed to upgrade to next level, in total
    uint32 fansAmount; // fans amount needed to upgrade to next level, in total

    uint64 fansMaxSPLimit; // fans nft max sp limit in current star level

    uint64 maxSPAdd; // max sp add to fans nft who done the level upgrade
    uint64 dpAdd; // dream point give to user who done the level upgrade
}

struct CheckinConfig {
    uint64 maxSPAdd; // maxSP add to fan
    uint64 dpAdd; // dream point give to user
    uint64 popAdd; // add popularity to star
}

struct SupportConfig {
    address tokenAddr; // cost token address (erc20 or erc1155)
    uint256 tokenId; // cost token id (=0 means erc20, else erc1155 token id)
    uint256 tokenValue; // cost token value

    uint64 maxSPAdd; // maxSP add to fan
    uint64 dpAdd; // dream point give to user
    uint64 spAdd;

    uint64 repAdd; // add reputation to star

    uint256 blocksInterval;  // indicate must wait how many blocks after previous support
}

struct DreamCoinSupportConfig {
    uint256 value; // cost token value

    uint64 maxSPAdd; // maxSP add to fan
    uint64 spAdd; // sp add to fan
    uint64 repAdd; // add reputation to star

    uint256 blocksInterval;  // indicate must wait how many blocks after previous support
}

interface IDIStarFactory_Config {
    function getDIStarConfig() external returns(DIStarsConfig memory config);
    function getCheckinConfigByLevel(uint8 starLevel, uint32 checkinType) external returns(CheckinConfig memory config);
    function getSupportConfigByLevelAndType(uint8 starLevel, uint32 supportType) external returns(SupportConfig memory config);
    function getDCSupportConfigByLevelAndType(uint8 starLevel, uint32 supportType) external returns(DreamCoinSupportConfig memory config);
    function getStarLevelConfigByLevel(uint8 starLevel) external returns(StarLevelConfig memory config);
    function getMaxSPLimitByStarLevel(uint8 starLevel) external returns(uint64 maxSPLimit);
    function getFansNFTSPByDreamCoin(uint256 dcValue) external view returns(uint64 sp);
    function getMaxSPFactorByGrade(uint8 grade) external view returns(uint32 factor);
    function getMaxSPFactorByFanType(uint8 fanType) external view returns(uint32 factor);

    function VerifyBAB(address addr) external returns(bool);
    function isBABCheckin(uint32 checkinType) external returns(bool);
    function isBABSupport(uint32 supportType) external returns(bool);
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarAssetStore.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../Utility/TransferHelper.sol";
import "../XWorldGames/XWorldInterfaces.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIStar1155.sol";
import "../DIStarNFT.sol";

import "./DIStar.sol";
import "./DIStarPool.sol";
import "./DIStarFactory.sol";
import "./DIStarAssetStoreDefine.sol";
import "../version.sol";
//import "hardhat/console.sol";
/**
 * @dev Dream Idol star assets store
 * this contract implements {DIStarAssetStoreProxy}
 */
contract DIStarAssetStore1155 is
    Initializable,
    ContextUpgradeable, 
    PausableUpgradeable, 
    AccessControlUpgradeable,
    ERC1967UpgradeUpgradeable
{
    using DICloudSales for DICloudSales.CloudSalesInfo;
    using DIStepIncreaseSales for DIStepIncreaseSales.SalesInfo;

    event Star1155PutOnSale(uint32 indexed role, uint32 sellId, SaleStar1155Config conf);
    event Star1155ModOnSale(uint32 indexed role, uint32 sellId, SaleStar1155Config conf);
    event StarAsset1155FundRaise(address indexed userAddr, uint32 indexed role, uint32 sellId, address indexed tokenAddr, uint256 value);
    event StarAsset1155FundRaiseFinished(address indexed userAddr,uint32 indexed role, uint32 sellId, address indexed tokenAddr, uint256 totalFundRaised, uint256 fundRaiseTarget);
    event BuyStarAsset1155(address indexed userAddr, uint32 indexed role, uint32 sellId, uint256 token1155Id, uint256 amount, address indexed tokenAddr, uint256 value);
    
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant STAR_ROLE = keccak256("STAR_ROLE");
    bytes32 public constant FACTORY_ADMIN_ROLE = keccak256("FACTORY_ADMIN_ROLE");

    DIFansNFT public _fansNFT;
    DIStar1155 public _star1155;
    DIStarNFT public _starNft;
    DIStarPool public _starPool;

    DIStarFactory public _starFactory;

    mapping(uint8=>SaleStar1155Config[]) public _levelUnlockGeneral1155Confs; // level => star 1155 config

    mapping(uint32=>mapping(uint8=>SaleStar1155Config[])) public _levelUnlockStarSpecial1155Confs; // star role => level => star 1155 config
    
    mapping(uint32=>Star1155Sales) _star1155Sales; // star role => 1155 sales
    
    // do not use constructor, use initialize instead
    constructor() {}

    /**
     * @dev get current implement version
     *
     * @return current version in string
     */
    function getVersion() public pure returns (string memory) {
        return "1.2";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }

    // use initializer to limit call once
    // initializer store in proxy ,so only first contract call this
    function initialize() public initializer {
        __Context_init_unchained();

        __Pausable_init_unchained();

        __AccessControl_init_unchained();
        __ERC1967Upgrade_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FACTORY_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(STAR_ROLE, _msgSender());

        _setRoleAdmin(STAR_ROLE, FACTORY_ADMIN_ROLE);
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "R1"
        );
        _pause();
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "R1"
        );
        _unpause();
    }

    function initializeAddrs(
        address fansNFT,
        address star1155,
        address starNft,
        address pool,
        address f
    ) external 
    {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "R2"
        );

        _fansNFT = DIFansNFT(fansNFT);
        _star1155 = DIStar1155(star1155);
        _starNft = DIStarNFT(starNft);
        _starPool = DIStarPool(pool);
        _starFactory = DIStarFactory(f);
    }

    function setGeneralStar1155ConfigByLevel(uint8 level, SaleStar1155Config[] memory confs) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "R2"
        );
        delete _levelUnlockGeneral1155Confs[level];
        SaleStar1155Config[] storage c = _levelUnlockGeneral1155Confs[level];
        for(uint256 i=0; i< confs.length; ++i){
            c.push(confs[i]);
        }
        //console.log("[sol]setGeneralStar1155ConfigByLevel",c.length);
    }

    function setSpecialStar1155ConfigByRoleLevel(uint32 role, uint8 level, SaleStar1155Config[] memory confs) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "R2"
        );

        delete _levelUnlockStarSpecial1155Confs[role][level];
        SaleStar1155Config[] storage c = _levelUnlockStarSpecial1155Confs[role][level];
        for(uint256 i=0; i< confs.length; ++i){
            c.push(confs[i]);
        }
        //console.log("[sol]setSpecialStar1155ConfigByRoleLevel",c.length);
    }

    function getStar1155SellIdSeed(uint32 role) external view returns(uint32 idSeed) {
        return _star1155Sales[role].sellIdSeed;
    }

    function getStar1155OnSaleInfo(uint32 role, uint32 sellId) external view returns(Star1155SaleInfoSimple memory info) {
        Star1155SaleInfo storage si = _star1155Sales[role].saleInfo[sellId];

        info.tokenId = si.tokenId;
        info.tokenData = si.tokenData;

        info.cloudSaleFinished = si.cloudSaleFinished;
        info.cloudSaleTokenAddr = si.cloudSaleInfo.tokenAddr;
        info.fundRaiseTarget = si.cloudSaleInfo.fundRaiseTarget;
        info.minimumSend = si.cloudSaleInfo.minimumSend;
        info.maximumPerUser = si.cloudSaleInfo.maximumPerUser;
        info.finishBlock = si.cloudSaleInfo.finishBlock;
        info.totalFundRaised = si.cloudSaleInfo.totalFundRaised;
        info.totalRefunded = si.cloudSaleInfo.totalRefunded;

        info.incSaleTokenAddr = si.incSaleTokenAddr;
        info.maxSupply = si.maxSupply;
        info.startSaleTime = si.startSaleTime;
        info.finishSaleTime = si.finishSaleTime;
        info.increaseSalesInfo = si.increaseSalesInfo;
    }

    function getStar1155CloudSaleInfoByUser(uint32 role, uint32 sellId, address userAddr) external view returns(uint256 fundRaised, bool refunded) {
        Star1155SaleInfo storage si = _star1155Sales[role].saleInfo[sellId];

        fundRaised = si.cloudSaleInfo.fundRaised[userAddr];
        refunded = si.cloudSaleInfo.refunded[userAddr];
    }

    function unlockStarLevelAssets(uint32 role, uint8 level) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "R3"
        );

        // general 1155 configs
        SaleStar1155Config[] memory confs1155 = _levelUnlockGeneral1155Confs[level];
        for(uint256 i=0; i< confs1155.length; ++i) {
            _putOnsaleStar1155(role, confs1155[i]);
        }

        // special 1155 configs
        confs1155 = _levelUnlockStarSpecial1155Confs[role][level];
        for(uint256 i=0; i< confs1155.length; ++i) {
            _putOnsaleStar1155(role, confs1155[i]);
        }
    }

    function putOnSale1155(uint32 role, SaleStar1155Config memory conf) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "R3"
        );

        _putOnsaleStar1155(role, conf);
    }

    function starAsset1155RaiseFund(uint32 role, uint32 sellId, uint256 value) external {
        DIStar star = DIStar(_starFactory.getDIStarAddress(role));
        require(address(star) != address(0), "starAsset1155RaiseFund E1");

        uint64 fansNFTId =  star.getFansNFTByUser(_msgSender());
        require(fansNFTId != 0, "starAsset1155RaiseFund E2");

        Star1155SaleInfo storage saleInfo = _star1155Sales[role].saleInfo[sellId];
        require(!saleInfo.cloudSaleFinished, "starAsset1155RaiseFund E3");
        require(saleInfo.cloudSaleInfo.tokenAddr != address(0), "starAsset1155RaiseFund E4");

        saleInfo.cloudSaleInfo.sendToken(_msgSender(), value); // send token to _starPool

        // share income
        _starPool.onShare20Income(_starPool.INCOME_STARASSET_CLOUDSALE(), saleInfo.cloudSaleInfo.tokenAddr, fansNFTId, value);

        emit StarAsset1155FundRaise(_msgSender(), role, sellId, saleInfo.cloudSaleInfo.tokenAddr, value);

        // give maxSP/sp/dp award
        if(saleInfo.maxSPAdd > 0) {
            star.addFansMaxSP(fansNFTId, _fansNFT.getNftData(fansNFTId), saleInfo.maxSPAdd);
        }
        if(saleInfo.dpAdd > 0) {
            //_starPool.giveDreamPoints(_msgSender(), saleInfo.dpAdd);
            _starPool.mintDreamPoints(_msgSender(), saleInfo.dpAdd, "raisefund");
        }
        if(saleInfo.spAdd > 0) {
            _fansNFT.addSp(fansNFTId,saleInfo.spAdd);
        }
        if(saleInfo.cloudSaleInfo.fundRaisePercent() >= 1000000) {
            // raise finished
            saleInfo.cloudSaleFinished = true;


//            console.log("[sol]starAsset1155RaiseFund",saleInfo.tokenId,saleInfo.tokenData.grade,saleInfo.tokenData.reserve1);
            // set nft data
            _star1155.modNftData(saleInfo.tokenId, saleInfo.tokenData);

            emit StarAsset1155FundRaiseFinished(_msgSender(), role, sellId, saleInfo.cloudSaleInfo.tokenAddr, saleInfo.cloudSaleInfo.totalFundRaised, saleInfo.cloudSaleInfo.fundRaiseTarget);
        
            // check if it's room item
            IDIStar1155Codec codec = IDIStar1155Codec(_star1155.getCodec());

//            DIStarExpeditionItem memory ed = codec.getExpeditionData( saleInfo.tokenData );
//            console.log("[sol]combatPower=",ed.combatPower);

            uint16 tp = codec.getTpFromID(saleInfo.tokenId);
            if(tp == 3) {
                // room item
                star.onStarRoomItemActivate(codec.getRoomItemData(saleInfo.tokenData));
            }
        }
    }

    function buyStarAsset1155(uint32 role, uint32 sellId, uint256 amount, uint256 highiestPrice) external {
        DIStar star = DIStar(_starFactory.getDIStarAddress(role));
        require(address(star) != address(0), "buyStarAsset1155 E1");

        uint64 fansNFTId =  star.getFansNFTByUser(_msgSender());
        require(fansNFTId != 0, "buyStarAsset1155 E2");

        Star1155SaleInfo storage saleInfo = _star1155Sales[role].saleInfo[sellId];

        require(saleInfo.increaseSalesInfo.price > 0, "buyStarAsset1155 E3");
        require(saleInfo.cloudSaleFinished, "buyStarAsset1155 E4");

        if(saleInfo.startSaleTime > 0) {
            require(saleInfo.startSaleTime < block.timestamp, "buyStarAsset1155 E8");
        }
        if(saleInfo.finishSaleTime > 0) {
            require(saleInfo.finishSaleTime > block.timestamp, "buyStarAsset1155 E9");
        }
        if(saleInfo.maxSupply > 0) {
            require(saleInfo.increaseSalesInfo.soldCount + amount <= saleInfo.maxSupply, "buyStarAsset1155 E5");
        }

        if(saleInfo.increaseSalesInfo.sellStep > 0) {
            require(amount <= saleInfo.increaseSalesInfo.sellStep, "buyStarAsset1155 Ea");
        }

        require(saleInfo.increaseSalesInfo.price <= highiestPrice, "buyStarAsset1155 E6");
        uint256 value = amount * saleInfo.increaseSalesInfo.price;

        require(IERC20(saleInfo.incSaleTokenAddr).balanceOf(_msgSender()) >= value, "buyStarAsset1155 E7");
        TransferHelper.safeTransferFrom(saleInfo.incSaleTokenAddr, _msgSender(), address(_starPool), value);

        _star1155.mint(_msgSender(), saleInfo.tokenId, amount, "buy");

        // call share income
        _starPool.onShare20Income(_starPool.INCOME_STARASSET_SELL(), saleInfo.incSaleTokenAddr, fansNFTId, value);

        emit BuyStarAsset1155(_msgSender(), role, sellId, saleInfo.tokenId, amount, saleInfo.incSaleTokenAddr, value);

        // notify on sell
        saleInfo.increaseSalesInfo.onSell(uint64(amount));
    }

    function modOnSaleStar1155(uint32 role, uint32 sellId, SaleStar1155Config memory conf) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "R3"
        );

        Star1155Sales storage star1155Sale = _star1155Sales[role];
        Star1155SaleInfo storage saleInfo = star1155Sale.saleInfo[sellId];

        saleInfo.maxSPAdd = conf.maxSPAdd;
        saleInfo.dpAdd = conf.dpAdd;
        saleInfo.spAdd = conf.spAdd;

        saleInfo.cloudSaleInfo.minimumSend = conf.cloudSaleInfo.minimumSend;
        saleInfo.cloudSaleInfo.maximumPerUser = conf.cloudSaleInfo.maximumPerUser;

        saleInfo.maxSupply = conf.incSaleInfo.maxSupply;
        saleInfo.startSaleTime = conf.incSaleInfo.startSaleTime;
        saleInfo.finishSaleTime = conf.incSaleInfo.finishSaleTime;

        saleInfo.increaseSalesInfo.sellStep = conf.incSaleInfo.sellStep;
        saleInfo.increaseSalesInfo.increasePercent = conf.incSaleInfo.increasePercent;
        saleInfo.increaseSalesInfo.price = conf.incSaleInfo.price;

        emit Star1155ModOnSale(role, sellId, conf);
    }

    function _putOnsaleStar1155(uint32 role, SaleStar1155Config memory conf) internal {
        Star1155Sales storage star1155Sale = _star1155Sales[role];

        uint32 sellId = star1155Sale.sellIdSeed;
        star1155Sale.sellIdSeed++;

        Star1155SaleInfo storage saleInfo = star1155Sale.saleInfo[sellId];

        IDIStar1155Codec codec = IDIStar1155Codec(_star1155.getCodec());
        saleInfo.tokenId = codec.getIDFromRoleAndAttribue(role, conf.tokenIdWithoutRole);
        saleInfo.tokenData = conf.tokenData;

        //console.log("[sol]_putOnsaleStar1155",conf.tokenData.reserve1,conf.tokenData.grade);
        saleInfo.maxSPAdd = conf.maxSPAdd;
        saleInfo.dpAdd = conf.dpAdd;
        saleInfo.spAdd = conf.spAdd;

        if(conf.cloudSaleInfo.fundRaiseTarget > 0) {
            // cloudsale first
            saleInfo.cloudSaleInfo.initSalesInfo(
                conf.cloudSaleInfo.tokenAddr, 
                address(_starPool),
                conf.cloudSaleInfo.fundRaiseTarget,
                conf.cloudSaleInfo.minimumSend,
                conf.cloudSaleInfo.maximumPerUser,
                conf.cloudSaleInfo.finishBlock
            );
            saleInfo.cloudSaleFinished = false;
        }
        else {

            saleInfo.cloudSaleFinished = true;

            _star1155.modNftData(saleInfo.tokenId, saleInfo.tokenData);
        }

        saleInfo.maxSupply = conf.incSaleInfo.maxSupply;
        saleInfo.startSaleTime = conf.incSaleInfo.startSaleTime;
        saleInfo.finishSaleTime = conf.incSaleInfo.finishSaleTime;
        saleInfo.incSaleTokenAddr = conf.incSaleInfo.tokenAddr;
        saleInfo.increaseSalesInfo.initSalesInfo(
            conf.incSaleInfo.sellStep,
            conf.incSaleInfo.increasePercent,
            conf.incSaleInfo.price
        );

        emit Star1155PutOnSale(role, sellId, conf);
    }

}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarPool.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../Utility/TransferHelper.sol";
import "../XWorldGames/XWorldInterfaces.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIFans/DIFansCreator.sol";
import "./DIStarFactory.sol";
import "../version.sol";
//import "hardhat/console.sol";
struct IncomeShareConfig {
    uint64 inviteRates; // rate=r/10000, share income with inviter
    uint64 producerRates; // rate=r/10000, share income with producer
    uint64 teamRates; // rate=r/10000, team share
    uint64 burnRates; // rate=r/10000, burn share
}

struct IncomeStatus {
    uint256 totalIncome; // totalIncome = fansNFTPool + starPool + teamPool + burnPool
    uint256 fansNFTPool; // all fans nft income sum. see {_fansNFT20Revenue},{_fansNFT1155Revenue}
    uint256 starPool; // all star pool sum. see {_star20Pools},{_star1155Pools}
    uint256 teamPool; // team income 
    uint256 burnPool; // income to burnning
}

struct ShareIncomeRes {
    uint32 starRole; // star role id
    uint64 fansNFTId; // fans NFT id who generate income
    uint64 inviterNFTId; // inviter nft id
    uint64 producerNFTId; // producer nft id

    uint256 value; // total income value
    uint256 inviterIncome; // income goes to inviter
    uint256 producerIncome; // income goes to producer
    uint256 teamIncome; // income goes to team
    uint256 burnIncome; // income goes to burn
    uint256 starPoolIncome; // income goes to star
}

/**
 * @dev Dream Idol Star contract, manage stars
 * this contract implements {DIStarProxy}
 */
contract DIStarPool is
    Initializable,
    ContextUpgradeable, 
    PausableUpgradeable, 
    AccessControlUpgradeable,
    ERC1967UpgradeUpgradeable
{
    event Share20Income(address indexed tokenAddr, bytes32 indexed incomeType, ShareIncomeRes incomeRes);
    event Share1155Income(address indexed tokenAddr, uint256 indexed tokenId, bytes32 indexed incomeType, ShareIncomeRes incomeRes);

    event UserDITokenFetched(address indexed userAddr, uint256 indexed tokenId, uint256 value);
    event UserDITokenAdded(address indexed userAddr, uint256 indexed tokenId, uint256 addValue);

    event Team20RevenueFetched(address indexed tokenAddr, uint256 value, address indexed toAddr, uint256 teamPool, uint256 totalIncome);
    event Team1155RevenueFetched(address indexed tokenAddr, uint256 indexed tokenId, uint256 value, address indexed toAddr, uint256 teamPool, uint256 totalIncome);
    event Income20Burned(address indexed tokenAddr, uint256 burned, uint256 totalIncome);
    event Income1155Burned(address indexed tokenAddr, uint256 tokenId, uint256 burned, uint256 totalIncome);
    event FansNFT20RevenueFetched(uint64 indexed fansNFTId, address indexed tokenAddr, address indexed usetAddr, uint256 revenue, uint256 fansNFTPool, uint256 totalIncome);
    event FansNFT1155RevenueFetched(uint64 indexed fansNFTId, address indexed tokenAddr, uint256 indexed tokenId, address usetAddr, uint256 revenue, uint256 fansNFTPool, uint256 totalIncome);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant STAR_ROLE = keccak256("STAR_ROLE");
    bytes32 public constant DREAM_POINT_MINTER_ROLE = keccak256("DREAM_POINT_MINTER_ROLE");
    bytes32 public constant DREAM_COIN_MINTER_ROLE = keccak256("DREAM_COIN_MINTER_ROLE");

    bytes32 public constant FACTORY_ADMIN_ROLE = keccak256("FACTORY_ADMIN_ROLE");
    // income type --------
    bytes32 public constant INCOME_STAR_SUPPORT_1155 = keccak256("INCOME_STAR_SUPPORT_1155");
    bytes32 public constant INCOME_STAR_SUPPORT_20 = keccak256("INCOME_STAR_SUPPORT_20");
    bytes32 public constant INCOME_STAR_SUPPORT = keccak256("INCOME_STAR_SUPPORT"); // discard
    bytes32 public constant INCOME_CONVERT_FANSNFT = keccak256("INCOME_CONVERT_FANSNFT");
    bytes32 public constant INCOME_STARASSET_CLOUDSALE = keccak256("INCOME_STARASSET_CLOUDSALE");
    bytes32 public constant INCOME_STARASSET_SELL = keccak256("INCOME_STARASSET_SELL");

    DIFansNFT public _fansNFT;
    DITokens1155 public _token1155;
    DIStarFactory public _starFactory;
    DIFansCreator public _fansCreator;

    mapping(bytes32=>IncomeShareConfig) public _incomeShareConf; // income type => income share config

    mapping(address=>mapping(uint256=>uint256)) public _userDITokens; // user address => DIToken id => value

    mapping(address=>IncomeStatus) public _income20Status; // token address => income status
    mapping(address=>mapping(uint256=>IncomeStatus)) public _income1155Status; // token address => token id => income status

    mapping(uint64=>mapping(address=>uint256)) public _fansNFT20Revenue; // fansNFT id => token address => token value
    mapping(uint64=>mapping(address=>mapping(uint256=>uint256))) public _fansNFT1155Revenue; // fansNFT id => token addres => token id => token value

    mapping(uint32=>mapping(address=>uint256)) public _star20Pools; // star role => token address => token value
    mapping(uint32=>mapping(address=>mapping(uint256=>uint256))) public _star1155Pools; // star role => token address => token id => token value

    // do not use constructor, use initialize instead
    constructor() {}

    /**
     * @dev get current implement version
     *
     * @return current version in string
     */
    function getVersion() public pure returns (string memory) {
        return "1.1";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }
    // use initializer to limit call once
    // initializer store in proxy ,so only first contract call this
    function initialize() public initializer {
        __Context_init_unchained();

        __Pausable_init_unchained();

        __AccessControl_init_unchained();
        __ERC1967Upgrade_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FACTORY_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(STAR_ROLE, _msgSender());

        _setRoleAdmin(DREAM_POINT_MINTER_ROLE, FACTORY_ADMIN_ROLE);
        _setRoleAdmin(STAR_ROLE, FACTORY_ADMIN_ROLE);
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIStarPool: must have pauser role to pause"
        );
        _pause();
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIStarPool: must have pauser role to unpause"
        );
        _unpause();
    }

    /**
    * @dev set contract address of {DIFansNFT}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param fansNFT address of {DIFansNFT}
    */
    function setDIFansNftAddress(address fansNFT) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarPool: must have manager role"
        );
        _fansNFT = DIFansNFT(fansNFT);
    }

    /**
    * @dev set contract address of {DIStarFactory}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param addr address of {DIStarFactory}
    */
    function setDIStarFactoryAddress(address addr) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _starFactory = DIStarFactory(addr);
    }

    /**
    * @dev set contract address of {DIFansCreator}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param addr address of {DIFansCreator}
    */
    function setDIFansCreatorAddress(address addr) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _fansCreator = DIFansCreator(addr);
    }

    /**
    * @dev set contract address of {DITokens1155}
    *
    * Requirements:
    * - caller must have `MANAGER_ROLE`
    *
    * @param token1155 address of {DITokens1155}
    */
    function setDITokens1155Address(address token1155) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _token1155 = DITokens1155(token1155);
    }

    function _checkConfig(IncomeShareConfig memory conf) internal pure {
        // share can't bigger than 100%
        require(conf.inviteRates + conf.producerRates + conf.teamRates + conf.burnRates < 10000, "DIStarPool: rate error");
    }

    function setIncomeShare(bytes32 incomeType, IncomeShareConfig memory conf) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarPool: must have manager role"
        );

        _checkConfig(conf);
        _incomeShareConf[incomeType] = conf;
    }

    // query method
    function getFansNFT20Revenue(uint64 fansNFTId, address tokenAddr) external view returns(uint256 value) {
        return _fansNFT20Revenue[fansNFTId][tokenAddr];
    }

    // query method
    function getFansNFT1155Revenue(uint64 fansNFTId, address tokenAddr, uint256 tokenId) external view returns(uint256 value) {
        return _fansNFT1155Revenue[fansNFTId][tokenAddr][tokenId];
    }

    // query method
    function getIncome20Status(address tokenAddr) external view returns(IncomeStatus memory status) {
        return _income20Status[tokenAddr];
    }

    // query method
    function getIncome1155Status(address tokenAddr, uint256 tokenId) external view returns(IncomeStatus memory status) {
        return _income1155Status[tokenAddr][tokenId];
    }

    // query method
    function getDITokenAmount(address userAddr, uint256 tokenId) external view returns(uint256 value) {
        return _userDITokens[userAddr][tokenId];
    }

    // call by client wallet, fetch dream idol tokens in star pool
    function fetchDITokens(uint256 tokenId) external returns(uint256 value) {
        value = _userDITokens[_msgSender()][tokenId];
        require(value > 0, "DIStarPool: insufficient dream points");

        _token1155.mint(_msgSender(), tokenId, value, "fetch");

        _userDITokens[_msgSender()][tokenId] = 0;

        emit UserDITokenFetched(_msgSender(), tokenId, value);

        return value;
    }

    // call by other contract, dispatch dream point to user in star pool
    function giveDreamPoints(address toUserAddr, uint256 value) external {
        require(
            hasRole(DREAM_POINT_MINTER_ROLE, _msgSender()),
            "DIStarPool: must have dream point minter role"
        );

        _userDITokens[toUserAddr][_token1155.DREAM_POINT_ID()] += value;

        emit UserDITokenAdded(toUserAddr, _token1155.DREAM_POINT_ID(), value);
    }
    // call by service, direct mint dream point to user
    function mintDreamPoints(address toUserAddr, uint256 value, bytes memory data) external {
        require(
            hasRole(DREAM_POINT_MINTER_ROLE, _msgSender()),
            "DIStarPool: must have dream point minter role"
        );

        // TO DO : risk check

        _token1155.mint(toUserAddr, _token1155.DREAM_POINT_ID(), value, data);
    }

    // call by other contract, dispatch dream coin to user in star pool
    function giveDreamCoins(address toUserAddr, uint256 value) external {
        require(
            hasRole(DREAM_COIN_MINTER_ROLE, _msgSender()),
            "DIStarPool: must have dream coin minter role"
        );

        _userDITokens[toUserAddr][_token1155.DREAM_COIN_ID()] += value;

        emit UserDITokenAdded(toUserAddr, _token1155.DREAM_COIN_ID(), value);
    }
    // call by service, direct mint dream coin to user
    function mintDreamCoins(address toUserAddr, uint256 value, bytes memory data) external {
        require(
            hasRole(DREAM_COIN_MINTER_ROLE, _msgSender()),
            "DIStarPool: must have dream coin minter role"
        );

        // TO DO : risk check

        _token1155.mint(toUserAddr, _token1155.DREAM_COIN_ID(), value, data);
    }


    // call by service, burn all burnPool token
    function burnPool20(address tokenAddr) external whenNotPaused {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarPool: must have manager role"
        );

        // check income status
        IncomeStatus storage incomeStatus = _income20Status[tokenAddr];
        require(incomeStatus.burnPool <= incomeStatus.totalIncome, "DIStarPool: income status error");

        // check balance of
        require(IERC20(tokenAddr).balanceOf(address(this))>=incomeStatus.burnPool, "DIStarPool: insufficient token");

        // burn
        ERC20Burnable(tokenAddr).burn(incomeStatus.burnPool);

        // sub income status
        incomeStatus.totalIncome -= incomeStatus.burnPool;

        emit Income20Burned(tokenAddr, incomeStatus.burnPool, incomeStatus.totalIncome);

        incomeStatus.burnPool = 0;
    }

    // call by service, burn all burnPool token
    function burnPool1155(address tokenAddr, uint256 tokenId) external whenNotPaused {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarPool: must have manager role"
        );

        // check income status
        IncomeStatus storage incomeStatus = _income1155Status[tokenAddr][tokenId];
        require(incomeStatus.burnPool <= incomeStatus.totalIncome, "DIStarPool: income status error");

        // check balance of
        require(IERC1155(tokenAddr).balanceOf(address(this), tokenId)>=incomeStatus.burnPool, "DIStarPool: insufficient token");

        // burn
        ERC1155Burnable(tokenAddr).burn(address(this), tokenId, incomeStatus.burnPool);

        // sub income status
        incomeStatus.totalIncome -= incomeStatus.burnPool;

        emit Income1155Burned(tokenAddr, tokenId, incomeStatus.burnPool, incomeStatus.totalIncome);

        incomeStatus.burnPool = 0;
    }

    // call by service, fetch team income
    function fetchTeam20Revenue(address tokenAddr, uint256 value, address toAddr) external whenNotPaused {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarPool: must have manager role"
        );

        // check income status
        IncomeStatus storage incomeStatus = _income20Status[tokenAddr];
        require(value <= incomeStatus.teamPool && incomeStatus.teamPool <= incomeStatus.totalIncome, "DIStarPool: income status error");

        // check balance of
        require(IERC20(tokenAddr).balanceOf(address(this))>=value, "DIStarPool: insufficient token");

        // transfer
        TransferHelper.safeTransfer(tokenAddr,  toAddr, value);

        // sub income status
        incomeStatus.teamPool -= value;
        incomeStatus.totalIncome -= value;

        emit Team20RevenueFetched(tokenAddr, value, toAddr, incomeStatus.teamPool, incomeStatus.totalIncome);
    }

    // call by service, fetch team income
    function fetchTeam1155Revenue(address tokenAddr, uint256 tokenId, uint256 value, address toAddr) external whenNotPaused {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarPool: must have manager role"
        );

        // check income status
        IncomeStatus storage incomeStatus = _income1155Status[tokenAddr][tokenId];
        require(value <= incomeStatus.teamPool && incomeStatus.teamPool <= incomeStatus.totalIncome, "DIStarPool: income status error");

        // check balance of
        require(IERC1155(tokenAddr).balanceOf(address(this), tokenId)>=value, "DIStarPool: insufficient token");

        // transfer
        IERC1155(tokenAddr).safeTransferFrom(address(this), toAddr, tokenId, value, "fetchteam");

        // sub income status
        incomeStatus.teamPool -= value;
        incomeStatus.totalIncome -= value;

        emit Team1155RevenueFetched(tokenAddr, tokenId, value, toAddr, incomeStatus.teamPool, incomeStatus.totalIncome);
    }

    // call by client wallet, fetch fans nft income, must own fan nft
    function fetchFansNFT20Revenue(uint64 fansNFTId, address tokenAddr) external whenNotPaused {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        require(_fansNFT.ownerOf(fansNFTId) == _msgSender(), "DIStarPool: ownership error");

        // check amount
        uint256 rev = _fansNFT20Revenue[fansNFTId][tokenAddr];
        require(rev > 0, "DIStarPool: no revenue");

        // check income status
        IncomeStatus storage incomeStatus = _income20Status[tokenAddr];
        require(incomeStatus.fansNFTPool >= rev && incomeStatus.totalIncome >= rev, "DIStarPool: income status error");

        // check balance of
        require(IERC20(tokenAddr).balanceOf(address(this))>=rev, "DIStarPool: insufficient token");

        // transfer
        TransferHelper.safeTransfer(tokenAddr, _msgSender(), rev);

        _fansNFT20Revenue[fansNFTId][tokenAddr] = 0;

        // sub income status
        incomeStatus.fansNFTPool -= rev;
        incomeStatus.totalIncome -= rev;

        emit FansNFT20RevenueFetched(fansNFTId, tokenAddr, _msgSender(), rev, incomeStatus.fansNFTPool, incomeStatus.totalIncome);
    }

    // call by client wallet, fetch fans nft income, must own fan nft
    function fetchFansNFT1155Revenue(uint64 fansNFTId, address tokenAddr, uint256 tokenId) external whenNotPaused {
        require(tx.origin == _msgSender(), "DIStar: only for outside account");

        require(_fansNFT.ownerOf(fansNFTId) == _msgSender(), "DIStarPool: ownership error");

        // check amount
        uint256 rev = _fansNFT1155Revenue[fansNFTId][tokenAddr][tokenId];
        require(rev > 0, "DIStarPool: no revenue");

        // check income status
        IncomeStatus storage incomeStatus = _income1155Status[tokenAddr][tokenId];
        require(incomeStatus.fansNFTPool >= rev && incomeStatus.totalIncome >= rev, "DIStarPool: income status error");

        // check balance of
        require(IERC1155(tokenAddr).balanceOf(address(this), tokenId)>=rev, "DIStarPool: insufficient token");

        // transfer
        IERC1155(tokenAddr).safeTransferFrom(address(this), _msgSender(), tokenId, rev, "fetchfan");

        _fansNFT1155Revenue[fansNFTId][tokenAddr][tokenId] = 0;

        // sub income status
        incomeStatus.fansNFTPool -= rev;
        incomeStatus.totalIncome -= rev;

        emit FansNFT1155RevenueFetched(fansNFTId, tokenAddr, tokenId, _msgSender(), rev, incomeStatus.fansNFTPool, incomeStatus.totalIncome);
    }

    function _isCallFromValidateCharger() internal view returns(bool) {
        require(address(_fansCreator)!=address(0),"DIStarPool:_starFactory Not Init.");
        return (_msgSender() == address(_fansCreator) || _starFactory.getDIStarIdByContractAddress(_msgSender()) != 0);
    }

    // call by other contracts for burn erc721 token
    function burn721Token(address tokenAddr,address fromAddr,uint256 tokenId) external
    {
        require(IERC721(tokenAddr).ownerOf(tokenId)==fromAddr,"DIStarPool: burn721Token check owner fail.");

        ERC721Burnable(tokenAddr).burn(tokenId);
    }
    // // call by other contracts for transfer erc721 token
    // function charge721Token(address tokenAddr, address fromAddr, address toAddr, uint256 tokenId, bytes memory data) external {
    //     require(_isCallFromValidateCharger(), "DIStarPool: not validate charger");

    //     IERC721(tokenAddr).safeTransferFrom(fromAddr, toAddr, tokenId, data);
    // }

    // // call by other contracts for burn erc20 token
    // function burn20Token(address tokenAddr,address fromAddr,uint256 amount) external
    // {
    //     ERC20Burnable(tokenAddr).burnFrom(fromAddr, amount);
    // }
    // call by other contracts for transfer erc20 token
    function charge20Token(address tokenAddr, address fromAddr, uint256 value) external {
        require(_isCallFromValidateCharger(), "DIStarPool: not validate charger");

        TransferHelper.safeTransferFrom(
                tokenAddr,
                fromAddr,
                address(this),
                value
            );
    }

    // call by other contracts for transfer erc1155 token
    function charge1155Token(address tokenAddr, address fromAddr, uint256 id, uint256 value, bytes memory data) external {  
        require(_isCallFromValidateCharger(), "DIStarPool: not validate charger");

        IERC1155(tokenAddr).safeTransferFrom(fromAddr, address(this), id, value, data);
    }

    // call by other contracts for burn erc1155 token
    function burn1155Token(address tokenAddr, address fromAddr, uint256 id, uint256 value) external {
        require(_isCallFromValidateCharger(), "DIStarPool: not validate charger");

        ERC1155Burnable(tokenAddr).burn(fromAddr, id, value);
    }

    // call by other contracts when transfer erc20 token to pool
    function onShare20Income(bytes32 incomeType, address tokenAddr, uint64 fansNFTId, uint256 value) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStarPool: must have star role"
        );

        _share20Income(tokenAddr, fansNFTId, value, incomeType);
    }
    // call by other contracts when transfer erc1155 token to pool
    function onShare1155Income(bytes32 incomeType, address tokenAddr, uint256 tokenId, uint64 fansNFTId, uint256 value) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStarPool: must have star role"
        );

        _share1155Income(tokenAddr, tokenId, fansNFTId, value, incomeType);
    }

    function _share20Income(address tokenAddr, uint64 fansNFTId, uint256 value, bytes32 incomeType) internal {
       
        //console.log("[sol]_share20Income",tokenAddr);
        IncomeShareConfig memory shareConfig = _incomeShareConf[incomeType];
        require(shareConfig.inviteRates | shareConfig.producerRates | shareConfig.teamRates | shareConfig.burnRates > 0, 
            "DIStarPool: income share config error");

        require(address(_fansNFT)!=address(0),"DIStarPool:_fansNFT not set.");
        DIFansNFTData memory fansNFTData = _fansNFT.getNftData(fansNFTId);

        // check income status
        IncomeStatus storage incomeStatus = _income20Status[tokenAddr];
        require(IERC20(tokenAddr).balanceOf(address(this)) >= incomeStatus.totalIncome + value, "DIStarPool: income overflow");

        // calc shares
        ShareIncomeRes memory incomeRes = ShareIncomeRes({
            starRole: fansNFTData.starRole,
            fansNFTId: fansNFTId,
            inviterNFTId: fansNFTData.invitorNftId,
            producerNFTId: fansNFTData.producerNftId,

            value: value,
            inviterIncome: value * shareConfig.inviteRates/10000,
            producerIncome: value * shareConfig.producerRates/10000,
            teamIncome: value * shareConfig.teamRates/10000,
            burnIncome: value * shareConfig.burnRates/10000,
            starPoolIncome: 0
        });
        //console.log("[sol]fansNFTData.invitorNftId",fansNFTData.invitorNftId,incomeRes.inviterIncome);
        //console.log("[sol]fansNFTData.producerNftId",fansNFTData.producerNftId,incomeRes.producerIncome);
        if(fansNFTData.invitorNftId > 0) {
            // dispatch inviter revenue
            _fansNFT20Revenue[fansNFTData.invitorNftId][tokenAddr] += incomeRes.inviterIncome;
            incomeStatus.fansNFTPool +=  incomeRes.inviterIncome;
        }
        else {
            // no inviter, go to star pool
            incomeRes.inviterIncome = 0;
        }

        if(fansNFTData.producerNftId > 0) {
            // dispatch producer revenue
            _fansNFT20Revenue[fansNFTData.producerNftId][tokenAddr] += incomeRes.producerIncome;
            incomeStatus.fansNFTPool +=  incomeRes.producerIncome;
        }
        else {
            // no producer, go to star pool
            incomeRes.producerIncome = 0;
        }

        // calc star pool income
        incomeRes.starPoolIncome = value - incomeRes.inviterIncome - incomeRes.producerIncome - incomeRes.teamIncome - incomeRes.burnIncome;

        // dispatch team income
        incomeStatus.teamPool += incomeRes.teamIncome;

        // dispatch burn income
        incomeStatus.burnPool += incomeRes.burnIncome;

        // dispatch star pool income
        _star20Pools[fansNFTData.starRole][tokenAddr] += incomeRes.starPoolIncome;
        incomeStatus.starPool += incomeRes.starPoolIncome;

        // rec totalIncome
        incomeStatus.totalIncome += value;

        emit Share20Income(tokenAddr, incomeType, incomeRes);
    }

    function _share1155Income(address tokenAddr, uint256 tokenId, uint64 fansNFTId, uint256 value, bytes32 incomeType) internal {
        IncomeShareConfig memory shareConfig = _incomeShareConf[incomeType];
        require(shareConfig.inviteRates | shareConfig.producerRates | shareConfig.teamRates | shareConfig.burnRates > 0, 
            "DIStarPool: income share config error");

        DIFansNFTData memory fansNFTData = _fansNFT.getNftData(fansNFTId);

        // check income status
        IncomeStatus storage incomeStatus = _income1155Status[tokenAddr][tokenId];
        require(IERC1155(tokenAddr).balanceOf(address(this), tokenId) >= incomeStatus.totalIncome + value, "DIStarPool: income overflow");

        // calc shares
        ShareIncomeRes memory incomeRes = ShareIncomeRes({
            starRole: fansNFTData.starRole,
            fansNFTId: fansNFTId,
            inviterNFTId: fansNFTData.invitorNftId,
            producerNFTId: fansNFTData.producerNftId,

            value: value,
            inviterIncome: value * shareConfig.inviteRates/10000,
            producerIncome: value * shareConfig.producerRates/10000,
            teamIncome: value * shareConfig.teamRates/10000,
            burnIncome: value * shareConfig.burnRates/10000,
            starPoolIncome: 0
        });

        if(fansNFTData.invitorNftId > 0) {
            // dispatch inviter revenue
            _fansNFT1155Revenue[fansNFTData.invitorNftId][tokenAddr][tokenId] += incomeRes.inviterIncome;
            incomeStatus.fansNFTPool +=  incomeRes.inviterIncome;
        }
        else {
            // no inviter, go to star pool
            incomeRes.inviterIncome = 0;
        }

        if(fansNFTData.producerNftId > 0) {
            // dispatch producer revenue
            _fansNFT1155Revenue[fansNFTData.producerNftId][tokenAddr][tokenId] += incomeRes.producerIncome;
            incomeStatus.fansNFTPool +=  incomeRes.producerIncome;
        }
        else {
            // no producer, go to star pool
            incomeRes.producerIncome = 0;
        }

        // calc star pool income
        incomeRes.starPoolIncome = value - incomeRes.inviterIncome - incomeRes.producerIncome - incomeRes.teamIncome - incomeRes.burnIncome;

        // dispatch team income
        incomeStatus.teamPool += incomeRes.teamIncome;

        // dispatch burn income
        incomeStatus.burnPool += incomeRes.burnIncome;

        // dispatch star pool income
        _star1155Pools[fansNFTData.starRole][tokenAddr][tokenId] += incomeRes.starPoolIncome;
        incomeStatus.starPool += incomeRes.starPoolIncome;

        // rec totalIncome
        incomeStatus.totalIncome += value;

        emit Share1155Income(tokenAddr, tokenId, incomeType, incomeRes);
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarAssetStore.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "../Utility/TransferHelper.sol";
import "../XWorldGames/XWorldInterfaces.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIStar1155.sol";
import "../DIStarNFT.sol";

import "./DIStar.sol";
import "./DIStarPool.sol";
import "./DIStarFactory.sol";
import "./DIStarAssetStoreDefine.sol";
import "../version.sol";
//import "hardhat/console.sol";
/**
 * @dev Dream Idol star assets store
 * this contract implements {DIStarAssetStoreProxy}
 */
contract DIStarAssetStoreNFT is
    Initializable,
    ContextUpgradeable, 
    PausableUpgradeable, 
    AccessControlUpgradeable,
    ERC1967UpgradeUpgradeable
{
    using DICloudSales for DICloudSales.CloudSalesInfo;
    using DIStepIncreaseSales for DIStepIncreaseSales.SalesInfo;

    event StarNftPutOnSale(uint32 indexed role, uint32 sellId, SaleStarNftConfig conf);
    event StarNftModOnSale(uint32 indexed role, uint32 sellId, SaleStarNftConfig conf);
    event StarAssetNftFundRaise(address indexed userAddr, uint32 indexed role, uint32 sellId, address indexed tokenAddr, uint256 value);
    event StarAssetNftFundRaiseFinished(address indexed userAddr,uint32 indexed role, uint32 sellId, address indexed tokenAddr, uint256 totalFundRaised, uint256 fundRaiseTarget);
    event BuyStarAssetNFT(address indexed userAddr, uint32 indexed role, uint32 sellId, uint256 nftId, address indexed tokenAddr, uint256 value);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant STAR_ROLE = keccak256("STAR_ROLE");
    bytes32 public constant FACTORY_ADMIN_ROLE = keccak256("FACTORY_ADMIN_ROLE");

    DIFansNFT public _fansNFT;
    DIStar1155 public _star1155;
    DIStarNFT public _starNft;
    DIStarPool public _starPool;

    DIStarFactory public _starFactory;

    mapping(uint8=>SaleStarNftConfig[]) public _levelUnlockGeneralNftConfs; // level => star nft config

    mapping(uint32=>mapping(uint8=>SaleStarNftConfig[])) public _levelUnlockStarSpecialNftConfs; // star role => level => star 1155 config

    mapping(uint32=>StarNFTSales) _starNftSales; // star role => nft sales

    // do not use constructor, use initialize instead
    constructor() {}

    /**
     * @dev get current implement version
     *
     * @return current version in string
     */
    function getVersion() public pure returns (string memory) {
        return "1.1";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }

    // use initializer to limit call once
    // initializer store in proxy ,so only first contract call this
    function initialize() public initializer {
        __Context_init_unchained();

        __Pausable_init_unchained();

        __AccessControl_init_unchained();
        __ERC1967Upgrade_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FACTORY_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(STAR_ROLE, _msgSender());

        _setRoleAdmin(STAR_ROLE, FACTORY_ADMIN_ROLE);
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "R1"
        );
        _pause();
    }

    /**
    * @dev pause contract
    *
    * Requirements:
    * - caller must have `PAUSER_ROLE`
    */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "R1"
        );
        _unpause();
    }

    function initializeAddrs(
        address fansNFT,
        address star1155,
        address starNft,
        address pool,
        address f
    ) external 
    {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "R2"
        );

        _fansNFT = DIFansNFT(fansNFT);
        _star1155 = DIStar1155(star1155);
        _starNft = DIStarNFT(starNft);
        _starPool = DIStarPool(pool);
        _starFactory = DIStarFactory(f);
    }

    function setGeneralStarNftConfigByLevel(uint8 level, SaleStarNftConfig[] memory confs) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "R2"
        );
        delete _levelUnlockGeneralNftConfs[level];
        SaleStarNftConfig[] storage c = _levelUnlockGeneralNftConfs[level];
        for(uint256 i=0; i< confs.length; ++i){
            c.push(confs[i]);
        }
        //console.log("[sol]setGeneralStarNftConfigByLevel",c.length);
    }

    function setSpecialStarNftConfigByRoleLevel(uint32 role, uint8 level, SaleStarNftConfig[] memory confs) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "R2"
        );

        delete _levelUnlockStarSpecialNftConfs[role][level];
        SaleStarNftConfig[] storage c = _levelUnlockStarSpecialNftConfs[role][level];
        for(uint256 i=0; i< confs.length; ++i){
            c.push(confs[i]);
        }
        //console.log("[sol]setSpecialStarNftConfigByRoleLevel",c.length);
    }

    function getStarNftSellIdSeed(uint32 role) external view returns(uint32 idSeed) {
        return _starNftSales[role].sellIdSeed;
    }

    function getStarNftOnSaleInfo(uint32 role, uint32 sellId) external view returns(StarNFTSaleInfoSimple memory info) {
        StarNFTSaleInfo storage si = _starNftSales[role].saleInfo[sellId];

        info.mintInfo = si.mintInfo;

        info.cloudSaleFinished = si.cloudSaleFinished;
        info.cloudSaleTokenAddr = si.cloudSaleInfo.tokenAddr;
        info.fundRaiseTarget = si.cloudSaleInfo.fundRaiseTarget;
        info.minimumSend = si.cloudSaleInfo.minimumSend;
        info.maximumPerUser = si.cloudSaleInfo.maximumPerUser;
        info.finishBlock = si.cloudSaleInfo.finishBlock;
        info.totalFundRaised = si.cloudSaleInfo.totalFundRaised;
        info.totalRefunded = si.cloudSaleInfo.totalRefunded;

        info.incSaleTokenAddr = si.incSaleTokenAddr;
        info.maxSupply = si.maxSupply;
        info.startSaleTime = si.startSaleTime;
        info.finishSaleTime = si.finishSaleTime;
        info.increaseSalesInfo = si.increaseSalesInfo;
    }

    function getStarNftCloudSaleInfoByUser(uint32 role, uint32 sellId, address userAddr) external view returns(uint256 fundRaised, bool refunded) {
        StarNFTSaleInfo storage si = _starNftSales[role].saleInfo[sellId];

        fundRaised = si.cloudSaleInfo.fundRaised[userAddr];
        refunded = si.cloudSaleInfo.refunded[userAddr];
    }

    function unlockStarLevelAssets(uint32 role, uint8 level) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "R3"
        );

        // general nft configs
        SaleStarNftConfig[] memory confsnft = _levelUnlockGeneralNftConfs[level];
        for(uint256 i=0; i< confsnft.length; ++i) {
            _putOnsaleStarNft(role, confsnft[i]);
        }

        // special nft configs
        confsnft = _levelUnlockStarSpecialNftConfs[role][level];
        for(uint256 i=0; i< confsnft.length; ++i) {
            _putOnsaleStarNft(role, confsnft[i]);
        }
    }

    function putOnSaleNft(uint32 role, SaleStarNftConfig memory conf) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "R3"
        );

        _putOnsaleStarNft(role, conf);
    }

    function starAssetNftRaiseFund(uint32 role, uint32 sellId, uint256 value) external {
        DIStar star = DIStar(_starFactory.getDIStarAddress(role));
        require(address(star) != address(0), "starAssetNftRaiseFund E1");

        uint64 fansNFTId =  star.getFansNFTByUser(_msgSender());
        require(fansNFTId != 0, "starAssetNftRaiseFund E2");

        StarNFTSaleInfo storage saleInfo = _starNftSales[role].saleInfo[sellId];
        require(!saleInfo.cloudSaleFinished, "starAssetNftRaiseFund E3");
        require(saleInfo.cloudSaleInfo.tokenAddr != address(0), "starAssetNftRaiseFund E4");

        saleInfo.cloudSaleInfo.sendToken(_msgSender(), value); // send token to _starPool

        // share income
        _starPool.onShare20Income(_starPool.INCOME_STARASSET_CLOUDSALE(), saleInfo.cloudSaleInfo.tokenAddr, fansNFTId, value);

        emit StarAssetNftFundRaise(_msgSender(), role, sellId, saleInfo.cloudSaleInfo.tokenAddr, value);

        // give maxSP/sp/dp award
        if(saleInfo.maxSPAdd > 0) {
            star.addFansMaxSP(fansNFTId, _fansNFT.getNftData(fansNFTId), saleInfo.maxSPAdd);
        }
        if(saleInfo.dpAdd > 0) {
            //_starPool.giveDreamPoints(_msgSender(), saleInfo.dpAdd);
            _starPool.mintDreamPoints(_msgSender(), saleInfo.dpAdd, "raisefund");
        }
        if(saleInfo.spAdd >0)
        {
            _fansNFT.addSp(fansNFTId, saleInfo.spAdd);
        }
        if(saleInfo.cloudSaleInfo.fundRaisePercent() >= 1000000) {
            // raise finished
            saleInfo.cloudSaleFinished = true;

            emit StarAssetNftFundRaiseFinished(_msgSender(), role, sellId, saleInfo.cloudSaleInfo.tokenAddr, saleInfo.cloudSaleInfo.totalFundRaised, saleInfo.cloudSaleInfo.fundRaiseTarget);
        }
    }

    function buyStarAssetNft(uint32 role, uint32 sellId, uint highiestPrice) external {
        DIStar star = DIStar(_starFactory.getDIStarAddress(role));
        require(address(star) != address(0), "buyStarAssetNft E1");

        uint64 fansNFTId =  star.getFansNFTByUser(_msgSender());
        require(fansNFTId != 0, "buyStarAssetNft E2");

        StarNFTSaleInfo storage saleInfo = _starNftSales[role].saleInfo[sellId];

        require(saleInfo.increaseSalesInfo.price > 0, "buyStarAssetNft E3");
        require(saleInfo.cloudSaleFinished, "buyStarAssetNft E4");

        if(saleInfo.startSaleTime > 0) {
            require(saleInfo.startSaleTime < block.timestamp, "buyStarAssetNft E8");
        }
        if(saleInfo.finishSaleTime > 0) {
            require(saleInfo.finishSaleTime > block.timestamp, "buyStarAssetNft E9");
        }
        if(saleInfo.maxSupply > 0) {
            require(saleInfo.increaseSalesInfo.soldCount + 1 <= saleInfo.maxSupply, "buyStarAssetNft E5");
        }

        require(saleInfo.increaseSalesInfo.price <= highiestPrice, "buyStarAssetNft E6");

        require(IERC20(saleInfo.incSaleTokenAddr).balanceOf(_msgSender()) >= saleInfo.increaseSalesInfo.price, "buyStarAssetNft E7");
        TransferHelper.safeTransferFrom(saleInfo.incSaleTokenAddr, _msgSender(), address(_starPool), saleInfo.increaseSalesInfo.price);



        
        uint256 nftId = _starNft.mint(_msgSender(), saleInfo.mintInfo);
        // console.log("[sol]starnft id", nftId);
        // console.log("[sol]starnft role", saleInfo.mintInfo.role);
        // console.log("[sol]starnft tp", saleInfo.mintInfo.tp);
        // console.log("[sol]starnft grade", saleInfo.mintInfo.grade);
        // console.log("[sol]starnft reserve1", saleInfo.mintInfo.reserve1);
        // call share income
        _starPool.onShare20Income(_starPool.INCOME_STARASSET_SELL(), saleInfo.incSaleTokenAddr, fansNFTId, saleInfo.increaseSalesInfo.price);

        emit BuyStarAssetNFT(_msgSender(), role, sellId, nftId, saleInfo.incSaleTokenAddr, saleInfo.increaseSalesInfo.price);

        // notify on sell
        // this maybe change price,so should do it last
        saleInfo.increaseSalesInfo.onSell(1);
    }

    function modOnSaleStarNft(uint32 role, uint32 sellId, SaleStarNftConfig memory conf) external {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "R3"
        );

        StarNFTSales storage starNftSale = _starNftSales[role];
        StarNFTSaleInfo storage saleInfo = starNftSale.saleInfo[sellId];

        // saleInfo.mintInfo = conf.mintInfo;
        // saleInfo.mintInfo.role = role;
        saleInfo.maxSPAdd = conf.maxSPAdd;
        saleInfo.dpAdd = conf.dpAdd;
        saleInfo.spAdd = conf.spAdd;

        saleInfo.cloudSaleInfo.minimumSend = conf.cloudSaleInfo.minimumSend;
        saleInfo.cloudSaleInfo.maximumPerUser = conf.cloudSaleInfo.maximumPerUser;

        saleInfo.maxSupply = conf.incSaleInfo.maxSupply;
        saleInfo.startSaleTime = conf.incSaleInfo.startSaleTime;
        saleInfo.finishSaleTime = conf.incSaleInfo.finishSaleTime;

        saleInfo.increaseSalesInfo.sellStep = conf.incSaleInfo.sellStep;
        saleInfo.increaseSalesInfo.increasePercent = conf.incSaleInfo.increasePercent;
        saleInfo.increaseSalesInfo.price = conf.incSaleInfo.price;

        emit StarNftModOnSale(role, sellId, conf);
    }

    function _putOnsaleStarNft(uint32 role, SaleStarNftConfig memory conf) internal {
        StarNFTSales storage starNftSale = _starNftSales[role];

        uint32 sellId = starNftSale.sellIdSeed;
        starNftSale.sellIdSeed++;

        StarNFTSaleInfo storage saleInfo = starNftSale.saleInfo[sellId];

        saleInfo.mintInfo = conf.mintInfo;
        saleInfo.mintInfo.role = role;
        // console.log("[sol]_putOnsaleStarNft role", saleInfo.mintInfo.role);
        // console.log("[sol]_putOnsaleStarNft tp", saleInfo.mintInfo.tp);
        // console.log("[sol]starnft grade", saleInfo.mintInfo.grade);
        // console.log("[sol]_putOnsaleStarNft reserve1", saleInfo.mintInfo.reserve1);
        saleInfo.maxSPAdd = conf.maxSPAdd;
        saleInfo.dpAdd = conf.dpAdd;
        saleInfo.spAdd = conf.spAdd;
        if(conf.cloudSaleInfo.fundRaiseTarget > 0) {
            // cloudsale first
            saleInfo.cloudSaleInfo.initSalesInfo(
                conf.cloudSaleInfo.tokenAddr, 
                address(_starPool),
                conf.cloudSaleInfo.fundRaiseTarget,
                conf.cloudSaleInfo.minimumSend,
                conf.cloudSaleInfo.maximumPerUser,
                conf.cloudSaleInfo.finishBlock
            );
            saleInfo.cloudSaleFinished = false;
        }
        else {
            saleInfo.cloudSaleFinished = true;
        }

        saleInfo.maxSupply = conf.incSaleInfo.maxSupply;
        saleInfo.startSaleTime = conf.incSaleInfo.startSaleTime;
        saleInfo.finishSaleTime = conf.incSaleInfo.finishSaleTime;
        saleInfo.incSaleTokenAddr = conf.incSaleInfo.tokenAddr;
        saleInfo.increaseSalesInfo.initSalesInfo(
            conf.incSaleInfo.sellStep,
            conf.incSaleInfo.increasePercent,
            conf.incSaleInfo.price
        );

        emit StarNftPutOnSale(role, sellId, conf);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISBT721 {
    /**
     * @dev This emits when a new token is created and bound to an account by
     * any mechanism.
     * Note: For a reliable `to` parameter, retrieve the transaction's
     * authenticated `to` field.
     */
    event Attest(address indexed to, uint256 indexed tokenId);

    /**
     * @dev This emits when an existing SBT is revoked from an account and
     * destroyed by any mechanism.
     * Note: For a reliable `from` parameter, retrieve the transaction's
     * authenticated `from` field.
     */
    event Revoke(address indexed from, uint256 indexed tokenId);

    /**
     * @dev This emits when an existing SBT is burned by an account
     */
    event Burn(address indexed from, uint256 indexed tokenId);

    /**
     * @dev Mints SBT
     *
     * Requirements:
     * - this method can only be invoked by the owner
     *
     * Emits a {Attest} event.
     * @return The tokenId of the minted SBT
     */
    function attest(address to) external returns (uint256);

    /**
     * @dev Revokes SBT
     *
     * Requirements:
     *
     * - `from` must exist.
     *
     * Emits a {Revoke} event.
     */
    function revoke(address from) external;

    /**
     * @notice At any time, an SBT receiver must be able to
     *  disassociate themselves from an SBT publicly through calling this
     *  function.
     *
     * Emits a {Burn} event.
     */
    function burn() external;

    /**
     * @notice Count all SBTs assigned to an owner
     * @dev SBTs assigned to the zero address is considered invalid, and this
     * function throws for queries about the zero address.
     * @param owner An address for whom to query the balance
     * @return The number of SBTs owned by `owner`, possibly zero
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @param from The address of the SBT owner
     * @return The tokenId of the owner's SBT, and throw an error if there is no SBT belongs to the given address
     */
    function tokenIdOf(address from) external view returns (uint256);

    /**
     * @notice Find the address bound to a SBT
     * @dev SBTs assigned to zero address are considered invalid, and queries
     *  about them do throw.
     * @param tokenId The identifier for an SBT
     * @return The address of the owner bound to the SBT
     */
    function ownerOf(uint256 tokenId) external view returns (address);
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarNFT.sol)

pragma solidity ^0.8.0;

import "./core/DIExtendableNFT.sol";

import "./DIStarAssetDefine.sol";
import "./version.sol";
/**
 * @dev Extension of {XWorldExtendableNFT} that with fixed token data struct
 */
contract DIStarNFT is DIExtendableNFT {
    using Counters for Counters.Counter;
    
    bytes32 public constant FACTORY_ADMIN_ROLE = keccak256("FACTORY_ADMIN_ROLE");
    /**
    * @dev emit when new token has been minted, see {DIStarNFTDataBase}
    *
    * @param to owner of new token
    * @param tokenId new token id
    * @param data token data see {DIStarNFTDataBase}
    */
    event DIFansNFTMint(address indexed to, uint256 indexed tokenId, DIStarNFTDataBase data);

    address public _codec;
    
    mapping(uint256 => DIStarNFTDataBase) private _nftDatas; // token id => nft data stucture

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI) 
        DIExtendableNFT(name, symbol, baseTokenURI)
    {
        mint(_msgSender(), DIStarNFTDataBase({
            role:0,
            grade:0,
            tp:0,
            reserve1:0,
            reserve2:0,
            reserve3:new uint32[](0)
        })); // mint first token to notify event scan
        
       _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
       _setupRole(DATA_ROLE, _msgSender());
    }

    function setCodec(address c) external {
        require(
            hasRole(DATA_ROLE, _msgSender()),
            "call DIStarNFT.setCodec need DATA_ROLE"
        );

        _codec = c;
    }
    function getCodec() external view returns(address c) {
        return _codec;
    }
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }
    /**
     * @dev Creates a new token for `to`, emit {XWorldNFTMint}. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     *
     * @param to new token owner address
     * @param data token data see {DIStarNFTDataBase}
     * @return new token id
     */
    function mint(address to, DIStarNFTDataBase memory data) public returns(uint256) {
        require(hasRole(MINTER_ROLE, _msgSender()), "R1");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 curID = _tokenIdTracker.current();

        _mint(to, curID);

        // Save token datas
        _nftDatas[curID] = data;

        emit DIFansNFTMint(to, curID, data);

        // increase token id
        _tokenIdTracker.increment();

        return curID;
    }

    /**
     * @dev modify token data
     *
     * @param tokenId token id
     * @param data token data see {DIStarNFTDataBase}
     */
    function modNftData(uint256 tokenId, DIStarNFTDataBase memory data) external {
        require(hasRole(DATA_ROLE, _msgSender()), "R1");

        _nftDatas[tokenId] = data;
    }

    /**
     * @dev get token data
     *
     * @param tokenId token id
     * @param data token data see {DIStarNFTDataBase}
     */
    function getNftData(uint256 tokenId) external view returns(DIStarNFTDataBase memory data){
        require(_exists(tokenId), "T1");

        data = _nftDatas[tokenId];
    }

}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarFactory.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIStar1155.sol";

import "./IDIStarFactory.sol";
import "./DIStar.sol";
import "./DIStarPool.sol";
import "./DIStarProxy.sol";
import "./DIStarAssetStore1155.sol";
import "./DIStarAssetStoreNFT.sol";
import "./DIStarAssetStoreDefine.sol";

import "./DIStarFactory_V2_Config.sol";
import "../version.sol";
/**
 * @dev Dream Idol Star factory contract, creating star contracts
 * this contract implements {DIStarFactoryProxy}
 */
contract DIStarFactory is
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ERC1967UpgradeUpgradeable
{
    event DIStarCreated(uint32 indexed starRole, address indexed addr);

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant STAR_ROLE = keccak256("STAR_ROLE");

    mapping(address => uint32) public _addressToStarId;
    mapping(uint32 => address) public _starContracts;
    uint32[] public _starsCreated;

    address public _currDIStarImpl;

    DIFansNFT public _fansNFT;
    DIStarPool public _starPool;
    DIStarAssetStore1155 public _starStore1155;
    DIStarAssetStoreNFT public _starStoreNft;

    DIStarFactory_V2_Config config;

    constructor() {}

    /**
     * @dev get current implement version
     *
     * @return current version in string
     */
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }

    // use initializer to limit call once
    // initializer store in proxy ,so only first contract call this
    function initialize() public initializer {
        __Context_init_unchained();

        __Pausable_init_unchained();

        __AccessControl_init_unchained();
        __ERC1967Upgrade_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(STAR_ROLE, _msgSender());
    }

    /**
     * @dev pause contract
     *
     * Requirements:
     * - caller must have `PAUSER_ROLE`
     */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIStarFactory: must have pauser role to pause"
        );
        _pause();
    }

    /**
     * @dev pause contract
     *
     * Requirements:
     * - caller must have `PAUSER_ROLE`
     */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIStarFactory: must have pauser role to unpause"
        );
        _unpause();
    }

    function setConfigAddress(address configaddr) external{

        config = DIStarFactory_V2_Config(configaddr);
    }
    
    function getConfigAddress() public view returns(address)
    {
        return address(config);
    }
    /**
     * @dev set contract address of {DIFansNFT}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param fansNFT address of {DIFansNFT}
     */
    function setDIFansNftAddress(address fansNFT) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: must have manager role"
        );
        _fansNFT = DIFansNFT(fansNFT);
    }

    /**
     * @dev set contract address of {DIStarPool}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param pool address of {DIStarPool}
     */
    function setDIStarPoolAddress(address pool) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: must have manager role"
        );
        _starPool = DIStarPool(pool);
    }

    /**
     * @dev set contract address of {DIStarAssetStore1155} and {DIStarAssetStoreNFT}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param store1155 address of {DIStarAssetStore}
     * @param storenft address of {DIStarAssetStoreNFT}
     */
    function setDIStarAssetStore(address store1155, address storenft) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStar: must have manager role"
        );
        _starStore1155 = DIStarAssetStore1155(store1155);
        _starStoreNft = DIStarAssetStoreNFT(storenft);
    }

 
    
    // query method
    function getTotalStars() external view returns (uint32 starCount) {
        return uint32(_starsCreated.length);
    }

    // query method
    function getDIStarByIndex(uint32 index)
        external
        view
        returns (uint32 starRole)
    {
        return _starsCreated[index];
    }

    // query method
    function getDIStarAddress(uint32 starRole) external view returns (address) {
        return _starContracts[starRole];
    }

    // query method
    function getDIStarIdByContractAddress(address addr) external view returns (uint32) {
        return _addressToStarId[addr];
    }

   
    // call by service, upgrade DIStar contract implement address for all DIStar proxies
    function upgradeDIStarImpl(address newImplAddr) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: must have manager role"
        );

        _currDIStarImpl = newImplAddr;

        for (uint32 i = 0; i < _starsCreated.length; ++i) {
            DIStarProxy starCon = DIStarProxy(
                payable(_starContracts[_starsCreated[i]])
            );

            starCon.upgradeTo(_currDIStarImpl);
        }
    }

    // call by {DIFansCreator}, after all genesis fan converted, {DIFansCreator} will call {DIStarFactory.createDIStar} to create {DIStar} contract
    function createDIStar(uint32 starRole)
        external
        returns (address starConAddr)
    {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStarFactory: must have star role"
        );

        require(
            _starContracts[starRole] == address(0),
            "DIStarFactory: star role already exist"
        );

        starConAddr = address(
            new DIStarProxy{salt: keccak256(abi.encode(starRole))}(
                _currDIStarImpl
            )
        );

        _starsCreated.push(starRole);
        _starContracts[starRole] = starConAddr;
        _addressToStarId[starConAddr] = starRole;

        DIStar starCon = DIStar(starConAddr);

        // set contract addresses
        starCon.setIDIStarFactory_Config(address(config));
        starCon.setDIFansNftAddress(address(_fansNFT));
        starCon.setDIStarPoolAddress(address(_starPool));
        starCon.setDIStarAssetStore(
            address(_starStore1155),
            address(_starStoreNft)
        );
        starCon.setDITokens1155Address(address(_starPool._token1155()));
        // grant new contract star role to caller(DIFansCreatorProxy)
        starCon.grantRole(starCon.STAR_ROLE(), _msgSender());
        starCon.grantRole(starCon.STAR_ROLE(), address(_starStore1155));
        starCon.grantRole(starCon.STAR_ROLE(), address(_starStoreNft));

        // grant roles to new star contract
        _fansNFT.grantRole(_fansNFT.DATA_ROLE(), starConAddr);
        _fansNFT.grantRole(_fansNFT.FREEZE_ROLE(), starConAddr);
        _fansNFT.grantRole(_fansNFT.DATA_ROLE(), address(_starStore1155));
        _fansNFT.grantRole(_fansNFT.DATA_ROLE(), address(_starStoreNft));
        _starPool.grantRole(_starPool.DREAM_POINT_MINTER_ROLE(), starConAddr);
        _starPool.grantRole(_starPool.STAR_ROLE(), starConAddr);
        _starStore1155.grantRole(_starStore1155.STAR_ROLE(), starConAddr);
        _starStoreNft.grantRole(_starStoreNft.STAR_ROLE(), starConAddr);

        // put initialize asset on store
        SaleStar1155Config[] memory confs1155 = config.getDIStarInitAsset1155Configs(starRole);
        for (uint256 i = 0; i < confs1155.length; ++i) {
            _starStore1155.putOnSale1155(starRole, confs1155[i]);
        }
        SaleStarNftConfig[] memory confsNft = config.getDIStarInitAssetNftConfigs(starRole);
        for (uint256 i = 0; i < confsNft.length; ++i) {
            _starStoreNft.putOnSaleNft(starRole, confsNft[i]);
        }

        emit DIStarCreated(starRole, starConAddr);
    }

    // call by service, call to {DIStar} contract indicate by {starRole}, since manager role of {DIStar} is {DIStarFactory},
    // all manager method of {DIStar} must call from {DIStarFactory}
    function callDIStar(uint32 starRole, bytes memory callData)
        external
        returns (bytes memory retrundata)
    {
        require(
            hasRole(STAR_ROLE, _msgSender()),
            "DIStarFactory: must have star role"
        );

        address starConAddr = _starContracts[starRole];

        bool success;
        (success, retrundata) = starConAddr.call(callData);

        require(success, "DIStarFactory: call DIStar failed");
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarAssetStoreDefine.sol)

pragma solidity ^0.8.0;

import "../Utility/DICloudSales.sol";
import "../Utility/DIStepIncreaseSales.sol";

import "../DIStar1155.sol";

import "./DIStar.sol";

struct Star1155SaleInfoSimple {
    uint256 tokenId;
    DIStar1155DataBase tokenData;

    bool cloudSaleFinished;
    address cloudSaleTokenAddr;
    uint256 fundRaiseTarget; // raise goal
    uint256 minimumSend; // minimum token must send by a single buyin
    uint256 maximumPerUser; // maximum token send per user
    uint256 finishBlock; // keep cloud sale till finish block number, if =0, then keep sale for ever
    uint256 totalFundRaised; // totoal fund raised value
    uint256 totalRefunded; // totoal refund value

    address incSaleTokenAddr;
    uint64 maxSupply;
    uint64 startSaleTime;
    uint64 finishSaleTime;
    DIStepIncreaseSales.SalesInfo increaseSalesInfo;
}

struct Star1155SaleInfo {
    uint256 tokenId;
    DIStar1155DataBase tokenData;

    bool cloudSaleFinished;
    uint64 maxSPAdd; // max sp add per raise
    uint256 dpAdd; // dream point add per raise
    uint64 spAdd;
    DICloudSales.CloudSalesInfo cloudSaleInfo;

    address incSaleTokenAddr;
    uint64 maxSupply;
    uint64 startSaleTime;
    uint64 finishSaleTime;
    DIStepIncreaseSales.SalesInfo increaseSalesInfo;
}
struct Star1155Sales {
    mapping(uint32 => Star1155SaleInfo) saleInfo;

    uint32 sellIdSeed;
}

struct StarNFTSaleInfoSimple {
    DIStarNFTDataBase mintInfo;

    bool cloudSaleFinished;
    address cloudSaleTokenAddr;
    uint256 fundRaiseTarget; // raise goal
    uint256 minimumSend; // minimum token must send by a single buyin
    uint256 maximumPerUser; // maximum token send per user
    uint256 finishBlock; // keep cloud sale till finish block number, if =0, then keep sale for ever
    uint256 totalFundRaised; // totoal fund raised value
    uint256 totalRefunded; // totoal refund value

    address incSaleTokenAddr;
    uint64 maxSupply;
    uint64 startSaleTime;
    uint64 finishSaleTime;
    DIStepIncreaseSales.SalesInfo increaseSalesInfo;
}
struct StarNFTSaleInfo {
    DIStarNFTDataBase mintInfo;

    bool cloudSaleFinished;
    uint64 maxSPAdd; // max sp add per raise
    uint256 dpAdd; // dream point add per raise
    uint64 spAdd;
    DICloudSales.CloudSalesInfo cloudSaleInfo;

    address incSaleTokenAddr;
    uint64 maxSupply;
    uint64 startSaleTime;
    uint64 finishSaleTime;
    DIStepIncreaseSales.SalesInfo increaseSalesInfo;
}
struct StarNFTSales {
    mapping(uint32 => StarNFTSaleInfo) saleInfo;

    uint32 sellIdSeed;
}

struct CloudSaleInfoConfig {
    address tokenAddr; // token address

    uint256 fundRaiseTarget; // =0 no cloudsale, >0 start with cloudsale
    uint256 minimumSend; // minimum token must send by a single buyin
    uint256 maximumPerUser; // maximum token send per user
    uint256 finishBlock; // keep sale till finish block number, if =0, then keep sale for ever
}
struct StepIncSaleInfoConfig {
    address tokenAddr; // token address

    uint64 sellStep; // increase after sellStep is sold, =0 means never increase price
    uint32 increasePercent; // increase percent each time, increase per = increasePercent/1000000
    uint256 price; // start price
    uint64 maxSupply; // maximum supply, = 0 no limit
    uint64 startSaleTime; // start sale time, = 0 no limit
    uint64 finishSaleTime; // finish sale time, = 0 no limit
}
struct SaleStar1155Config {
    uint256 tokenIdWithoutRole;
    DIStar1155DataBase tokenData;

    uint64 maxSPAdd; // max sp add per raise
    uint256 dpAdd; // dream point add per raise
    uint64 spAdd;
    CloudSaleInfoConfig cloudSaleInfo;
    StepIncSaleInfoConfig incSaleInfo;
}
struct SaleStarNftConfig {
    DIStarNFTDataBase mintInfo;

    uint64 maxSPAdd; // max sp add per raise
    uint256 dpAdd; // dream point add per raise
    uint64 spAdd;
    CloudSaleInfoConfig cloudSaleInfo;
    StepIncSaleInfoConfig incSaleInfo; 
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
// DreamIdol Contracts (DIStarProxy.sol)

pragma solidity ^0.8.2;

import "../core/DIUpgradeableProxy.sol";

/**
* @dev proxy of {DIStar}
*/
contract DIStarProxy is DIUpgradeableProxy {

    constructor(address _impl)
        payable
        DIUpgradeableProxy(_impl)
    {
    }
}

/**
* @dev proxy of {DIStarPool}
*/
contract DIStarPoolProxy is DIUpgradeableProxy {

    constructor(address _impl)
        payable
        DIUpgradeableProxy(_impl)
    {
    }
}

/**
* @dev proxy of {DIStarFactory}
*/
contract DIStarFactoryProxy is DIUpgradeableProxy {

    constructor(address _impl)
        payable
        DIUpgradeableProxy(_impl)
    {
    }
}

/**
* @dev proxy of {DIStarAssetStoreNFT}
*/
contract DIStarAssetStoreNFTProxy is DIUpgradeableProxy {

    constructor(address _impl)
        payable
        DIUpgradeableProxy(_impl)
    {
    }
}

/**
* @dev proxy of {DIStarAssetStore1155}
*/
contract DIStarAssetStore1155Proxy is DIUpgradeableProxy {

    constructor(address _impl)
        payable
        DIUpgradeableProxy(_impl)
    {
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStarFactory.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

import "../DIFansNFT.sol";
import "../DITokens1155.sol";
import "../DIStar1155.sol";

import "./IDIStarFactory.sol";
import "./DIStar.sol";
import "./DIStarPool.sol";
import "./DIStarProxy.sol";
import "./DIStarAssetStore1155.sol";
import "./DIStarAssetStoreNFT.sol";
import "./DIStarAssetStoreDefine.sol";


import "../Binance/Interface/ISBT721.sol";
/**
 * @dev Dream Idol Star factory contract, creating star contracts
 * this contract implements {DIStarFactoryProxy}
 */
contract DIStarFactory_V2_Config is AccessControlUpgradeable,IDIStarFactory_Config
{ 
    mapping(uint32 => SaleStar1155Config[]) public _starInitAsset1155Confs; // star role => 1155 asset sale config
    mapping(uint32 => SaleStarNftConfig[]) public _starInitAssetNftConfs; // star role => 1155 asset sale config

    // configs
    DIStarsConfig public _starConfig;
    mapping(uint8 => mapping(uint32 => CheckinConfig)) public _checkinConfigs; // star level => checkin type => checkin config
    mapping(uint8 => mapping(uint32 => SupportConfig)) public _supportConfigs; // star level => support type => support config
    mapping(uint8 => mapping(uint32 => DreamCoinSupportConfig))
        
    public _dcSupportConfigs; // star level => support type => dream coin support config
    mapping(uint8 => StarLevelConfig) public _starLevelConfigs; // star level => star level config
    mapping(uint8 => uint32) public _gradeMaxSPFactor; // grade => maxSP factor, add maxSP*factor/1000000
    mapping(uint8 => uint32) public _fanTypeMaxSPFactor; // fan type => maxSP factor, add maxSP*factor/1000000

    mapping(uint32 => bool) public _BABCheckin; // star level => checkin type => is bab checkin
    mapping(uint32 => bool) public _BABSupports; // star level => support type => is bab support


    ISBT721 public _isbt721;


    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }



    /**
     * @dev set dream idol stars config
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param config see {DIStarsConfig}
     */
    function setDIStarsConfig(DIStarsConfig memory config) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e2"
        );

        _starConfig = config;
    }

    function setCheckinConfig(uint8 starLevel, uint32 checkinType, CheckinConfig memory config)
        external
    {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e3"
        );
        _checkinConfigs[starLevel][checkinType] = config;
    }

    function setSupportConfig(
        uint8 starLevel,
        uint32 supportType,
        SupportConfig memory config
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e4"
        );
        _supportConfigs[starLevel][supportType] = config;
    }

    function setDreamCoinSupportConfig(
        uint8 starLevel,
        uint32 supportType,
        DreamCoinSupportConfig memory config
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e5"
        );
        _dcSupportConfigs[starLevel][supportType] = config;
    }

    // mark a checkin is bab checkin
    function setBABCheckin(
        uint32 supportType,bool support
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e6"
        );
        _BABCheckin[supportType] = support;
    }

    // mark a support is bab support
    function setBABSupport(
        uint32 supportType,bool support
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e7"
        );
        _BABSupports[supportType] = support;
    }

    function setStarLevelConfig(uint8 starLevel, StarLevelConfig memory config)
        external
    {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e8"
        );
        _starLevelConfigs[starLevel] = config;
    }

    function setMaxSPFactorByGrade(uint8 grade, uint32 factor) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e9"
        );
        _gradeMaxSPFactor[grade] = factor;
    }

    function setMaxSPFactorByFanType(uint8 fanType, uint32 factor) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e10"
        );
        _fanTypeMaxSPFactor[fanType] = factor;
    }

    function setDIStarInitAssetNftConfigs(
        uint32 starRole,
        SaleStarNftConfig[] memory confs
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "DI5");

        delete _starInitAsset1155Confs[starRole];
        SaleStarNftConfig[] storage c = _starInitAssetNftConfs[starRole];
       
        for (uint256 i = 0; i < confs.length; ++i) {
            c.push(confs[i]);
        }
    }
    
    function getDIStarInitAssetNftConfigs(
        uint32 starRole
    ) public view returns (SaleStarNftConfig[] memory) {
       
        SaleStarNftConfig[] memory c = _starInitAssetNftConfs[starRole];
        return c;
    }
    

    function setDIStarInitAsset1155Configs(
        uint32 starRole,
        SaleStar1155Config[] memory confs
    ) external {
        require(hasRole(MANAGER_ROLE, _msgSender()), "DI5");

        SaleStar1155Config[] storage c = _starInitAsset1155Confs[starRole];
        delete _starInitAsset1155Confs[starRole];
        for (uint256 i = 0; i < confs.length; ++i) {
            c.push(confs[i]);
        }
    }

    function getDIStarInitAsset1155Configs(
        uint32 starRole
        
    ) public view returns(SaleStar1155Config[] memory ) {
        SaleStar1155Config[] memory c = _starInitAsset1155Confs[starRole];
        return c;
    }
    
    function setISBT721Address(address isbt721) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: e14"
        );
        _isbt721 = ISBT721(isbt721);
    }

    // configs for star, see {DIStarsConfig}
    function getDIStarConfig()
        external
        view
        override
        returns (DIStarsConfig memory config)
    {
        return _starConfig;
    }

    // configs for star, checkin config by star level, see {CheckinConfig}
    function getCheckinConfigByLevel(uint8 starLevel, uint32 checkinType)
        external
        view
        override
        returns (CheckinConfig memory config)
    {
        return _checkinConfigs[starLevel][checkinType];
    }

    // configs for star, support config by star level and support type, see {SupportConfig}
    function getSupportConfigByLevelAndType(uint8 starLevel, uint32 supportType)
        external
        view
        override
        returns (SupportConfig memory config)
    {
        return _supportConfigs[starLevel][supportType];
    }

    // configs for star, dream coin support config by star level and support type, see {DreamCoinSupportConfig}
    function getDCSupportConfigByLevelAndType(
        uint8 starLevel,
        uint32 supportType
    ) external view override returns (DreamCoinSupportConfig memory config) {
        return _dcSupportConfigs[starLevel][supportType];
    }

    // configs for star, star level config by star level, see {StarLevelConfig}
    function getStarLevelConfigByLevel(uint8 starLevel)
        external
        view
        override
        returns (StarLevelConfig memory config)
    {
        return _starLevelConfigs[starLevel];
    }

    function getMaxSPLimitByStarLevel(uint8 starLevel) 
        external 
        view
        override 
        returns(uint64 maxSPLimit) 
    {
        return _starLevelConfigs[starLevel].fansMaxSPLimit;
    }

    // configs for star, calculate support power by burn dream coint value
    function getFansNFTSPByDreamCoin(uint256 dcValue)
        external
        view
        override
        returns (uint64 sp)
    {
        return
            uint64((_starConfig.supportPowerByDreamCoin * dcValue) / 100000000);
    }

    // configs for star, get maxSP factor of grade, add maxSP*factor/1000000
    function getMaxSPFactorByGrade(uint8 grade)
        external
        view
        override
        returns (uint32 factor)
    {
        return _gradeMaxSPFactor[grade];
    }

    // configs for star, get maxSP factor of fanType, add maxSP*factor/1000000
    function getMaxSPFactorByFanType(uint8 fanType)
        external
        view
        override
        returns (uint32 factor)
    {
        return _fanTypeMaxSPFactor[fanType];
    }




    // is support a bab support
    function isBABCheckin(uint32 checkinType) external view override returns(bool) {
        return _BABCheckin[checkinType];
    }

    // is support a bab support
    function isBABSupport(uint32 supportType) external view override returns(bool) {
        return _BABSupports[supportType];
    }

    function VerifyBAB(address addr) external view override returns(bool){
        return _isbt721.balanceOf(addr) > 0;
    }
 
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIFansCreator.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/DIStepIncreaseSales.sol";
import "../XWorldGames/XWorldInterfaces.sol";

import "../DIStar/DIStar.sol";
import "../DIStar/DIStarFactory.sol";
import "../DIStar/DIStarPool.sol";
import "../DIFansNFT.sol";
import "../version.sol";
//import "hardhat/console.sol";

/**
 * @dev Dream Idol Fans Creator contract, creating fans nft
 * this contract implements {DIFansCreatorProxy}
 */
contract DIFansCreator is
    Initializable,
    ContextUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ERC1967UpgradeUpgradeable
{
    using DIStepIncreaseSales for DIStepIncreaseSales.SalesInfo;

    struct FansCreateInfo {
        uint8 creatingPhase; // =0 not start, =1 genesis phase, =2 normal phase
        uint32 genesisNFTCreated;
        uint32 superFanNFTCreated;
    }

    event FansGenesisPhaseStarted(uint32 indexed starRole);
    event FansNormalPhaseStarted(uint32 indexed starRole);
    event GenesisFanNFTCreated(
        address indexed to,
        uint256 indexed xwgDCNFTId,
        uint256 indexed fanNFTId
    );
    event SuperFanNFTCreated(
        address indexed to,
        uint256 indexed xwgDCNFTId,
        uint256 indexed fanNFTId
    );
    event NormalFanNFTCreated(
        address indexed to,
        uint256 indexed starRole,
        uint256 indexed fanNFTId
    );

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    DIFansNFT public _fansNFT;
    IXWGDCCardNFT public _xwgDCNFT;
    IXWGDCCardNFTRepository public _xwgDCNFTRepo;
    DIStarFactory public _starFactory;
    DIStarPool public _starPool;

    mapping(uint32 => FansCreateInfo) public _fansCreateInfo; // star role => create info
    mapping(uint32 => mapping(address => DIStepIncreaseSales.SalesInfo))
        public _genesisFanPrices; // star role => token address => sales info
    mapping(uint32 => mapping(address => DIStepIncreaseSales.SalesInfo))
        public _superFanPrices; // star role => token address => sales info
    mapping(uint32 => mapping(address => DIStepIncreaseSales.SalesInfo))
        public _normalFanPrices; // star role => token address => sales info

    uint32 public _maxGenesisNFTCount; // genesis nft total amount
    uint32 public _minGenesisNFTCount; // minimum genesis nft needed for genesis
    uint32 public _maxSuperFanNFTCount; // super fan nft total amount

    uint64 public _initMaxSP;
    mapping(uint8 => uint64) public _gradInitMaxSP; // grade => init maxSP add
    mapping(uint8 => uint64) public _fanTypeInitMaxSP; // fan type => init maxSP add

    // do not use constructor, use initialize instead
    constructor() {}

    /**
     * @dev get current implement version
     *
     * @return current version in string
     */
    function getVersion() public pure returns (string memory) {
        return "1.0";
    }
    function getVersionTag() public pure returns(string memory)
    {
        return baseversionTag;
    }

    // use initializer to limit call once
    // initializer store in proxy ,so only first contract call this
    function initialize() public initializer {
        __Context_init_unchained();

        __Pausable_init_unchained();

        __AccessControl_init_unchained();
        __ERC1967Upgrade_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(CREATOR_ROLE, _msgSender());
    }

    /**
     * @dev pause contract
     *
     * Requirements:
     * - caller must have `PAUSER_ROLE`
     */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIFansCreator: must have pauser role to pause"
        );
        _pause();
    }

    /**
     * @dev pause contract
     *
     * Requirements:
     * - caller must have `PAUSER_ROLE`
     */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "DIFansCreator: must have pauser role to unpause"
        );
        _unpause();
    }

    function getFansCreateInfo(uint32 starRole)
        external
        view
        returns (FansCreateInfo memory info)
    {
        info = _fansCreateInfo[starRole];
    }

    /**
     * @dev set contract address of {DIFansNFT}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param fansNFT address of {DIFansNFT}
     */
    function setDIFansNftAddress(address fansNFT) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _fansNFT = DIFansNFT(fansNFT);
    }

    /**
     * @dev set contract address of {DIStarFactory}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param starFactory address of {DIStarFactory}
     */
    function setStarFactoryAddress(address starFactory) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _starFactory = DIStarFactory(starFactory);
    }

    /**
     * @dev set contract address of {DIStarPool}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param pool address of {DIStarPool}
     */
    function setDIStarPoolAddress(address pool) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIStarFactory: must have manager role"
        );
        _starPool = DIStarPool(pool);
    }

    /**
     * @dev set contract address of {IXWGDCCardNFT},{IXWGDCCardNFTRepository}
     *
     * Requirements:
     * - caller must have `MANAGER_ROLE`
     *
     * @param xwgDCNFT address of {IXWGDCCardNFT}
     * @param xwgDCNFTRepo address of {IXWGDCCardNFTRepository}
     */
    function setXWGDCNftAddress(address xwgDCNFT, address xwgDCNFTRepo)
        external
    {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _xwgDCNFT = IXWGDCCardNFT(xwgDCNFT);
        _xwgDCNFTRepo = IXWGDCCardNFTRepository(xwgDCNFTRepo);
    }

    function setGenesisNFTCount(uint32 maxCount, uint32 minCount) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _maxGenesisNFTCount = maxCount;
        _minGenesisNFTCount = minCount;
    }

    function setMaxSuperFanNFTCount(uint32 count) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _maxSuperFanNFTCount = count;
    }

    function setGenesisFanPrice(
        address tokenAddr,
        uint32 starRole,
        uint64 step,
        uint32 percent,
        uint256 price
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _genesisFanPrices[starRole][tokenAddr].initSalesInfo(
            step,
            percent,
            price
        );
    }

    function setSuperFanPrice(
        address tokenAddr,
        uint32 starRole,
        uint64 step,
        uint32 percent,
        uint256 price
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _superFanPrices[starRole][tokenAddr].initSalesInfo(
            step,
            percent,
            price
        );
    }

    function setNormalFanPrice(
        address tokenAddr,
        uint32 starRole,
        uint64 step,
        uint32 percent,
        uint256 price
    ) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _normalFanPrices[starRole][tokenAddr].initSalesInfo(
            step,
            percent,
            price
        );
    }

    function setInitMaxSP(uint64 maxSP) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _initMaxSP = maxSP;
    }

    function setGradeInitMaxSP(uint8 grade, uint64 maxSP) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _gradInitMaxSP[grade] = maxSP;
    }

    function setFanTypeInitMaxSP(uint8 fanType, uint64 maxSP) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );
        _fanTypeInitMaxSP[fanType] = maxSP;
    }

    // query method, get fans created info
    function getFansCreatedInfo(uint32 starRole)
        external
        view
        returns (FansCreateInfo memory info)
    {
        return _fansCreateInfo[starRole];
    }

    // query method, get genesis fan price info
    function getGenesisSalesInfo(uint32 starRole, address tokenAddr)
        external
        view
        returns (DIStepIncreaseSales.SalesInfo memory info)
    {
        return _genesisFanPrices[starRole][tokenAddr];
    }

    // query method, get super fan price info
    function getSuperSalesInfo(uint32 starRole, address tokenAddr)
        external
        view
        returns (DIStepIncreaseSales.SalesInfo memory info)
    {
        return _superFanPrices[starRole][tokenAddr];
    }

    // query method, get normal fan price info
    function getNormalSalesInfo(uint32 starRole, address tokenAddr)
        external
        view
        returns (DIStepIncreaseSales.SalesInfo memory info)
    {
        return _normalFanPrices[starRole][tokenAddr];
    }

    // call by service, start genesis fans convert
    function launchGenesisFansConvert(uint32 starRole) external {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            "DIFansCreator: must have manager role"
        );

        FansCreateInfo storage info = _fansCreateInfo[starRole];

        require(
            info.creatingPhase == 0,
            "DIFansCreator: fans process already started"
        );

        info.creatingPhase = 1; // go to genesis phase.
        //info.genesisNFTCreated = 0;
        //info.superFanNFTCreated = 0;

        emit FansGenesisPhaseStarted(starRole);
    }

    // call by client wallet, convert a genesis fan nft
    function convertGenesisFan(
        uint256 xwgDCNftId,
        address tokenAddr,
        uint256 highiestPrice
    ) external whenNotPaused returns (uint256 fanNFTId) {
        require(
            _xwgDCNFT.ownerOf(xwgDCNftId) == _msgSender(),
            "DIFansCreator: must own dc nft"
        );

        // get card info
        (uint32[] memory role, uint256 grade, , ) = _xwgDCNFTRepo.get(
            xwgDCNftId
        );
        require(grade >= 4, "DIFansCreator: genesis fan grade must >= 4");

        FansCreateInfo storage info = _fansCreateInfo[role[0]];

        require(
            info.creatingPhase > 0,
            "DIFansCreator: fans process not in genesis phase"
        );

        require(
            info.genesisNFTCreated < _maxGenesisNFTCount,
            "DIFansCreator: no more genesis nft left"
        );

        _starPool.burn721Token(address(_xwgDCNFT), _msgSender(), xwgDCNftId);
        //_xwgDCNFT.burn(xwgDCNftId);

        // charge
        DIStepIncreaseSales.SalesInfo storage salesInfo = _genesisFanPrices[
            role[0]
        ][tokenAddr];
        require(salesInfo.sellStep > 0, "DIFansCreator: token price not set");
        if (salesInfo.price > 0) {
            require(
                salesInfo.price <= highiestPrice,
                "DIFansCreator: price grow out of range"
            );
            require(
                IERC20(tokenAddr).balanceOf(_msgSender()) >= salesInfo.price,
                "DIFansCreator: insufficient token"
            );
            _starPool.charge20Token(
                tokenAddr,
                _msgSender(),
                salesInfo.price
            );

           
        }

        DIFansNFTData memory data = DIFansNFTData({
            fanType: 1,
            starRole: role[0],
            grade: uint8(grade),
            maxSP: _initMaxSP +
                _gradInitMaxSP[uint8(grade)] +
                _fanTypeInitMaxSP[1],
            sp: 1,
            invitorNftId: 0,
            producerNftId: 0,
            reserve: 0,
            reserve1: new uint32[](0)
        });

        fanNFTId = _fansNFT.mint(_msgSender(), data);

        emit GenesisFanNFTCreated(_msgSender(), xwgDCNftId, fanNFTId);

        // increase genesis nft created
        info.genesisNFTCreated++;
        //console.log("[sol]info.creatingPhase", info.creatingPhase);
        if (
            info.creatingPhase == 1 &&
            info.genesisNFTCreated >= _minGenesisNFTCount
        ) {
            info.creatingPhase = 2; // change to normal phase
            emit FansNormalPhaseStarted(role[0]);

            //console.log("[sol]create DIStar contract", role[0]);
            // create DIStar contract
            DIStar starContract = DIStar(_starFactory.createDIStar(role[0]));
            starContract.onGenesisSuccess(role[0]);

            // TO DO : give sp/maxsp/dream point
        }

        if (salesInfo.price > 0) {
            // call share income
            _starPool.onShare20Income(
                _starPool.INCOME_CONVERT_FANSNFT(),
                tokenAddr,
                uint64(fanNFTId),
                salesInfo.price
            );

            // notify on sell
            // this maybe change price,so should do it last
            salesInfo.onSell(1);
        }
    }

    // call by client wallet, convert a super fan nft
    function convertSuperFan(
        uint256 xwgDCNftId,
        address tokenAddr,
        uint64 inviterId,
        uint256 highiestPrice
    ) external whenNotPaused returns (uint256 fanNFTId) {
        require(
            _xwgDCNFT.ownerOf(xwgDCNftId) == _msgSender(),
            "DIFansCreator: must own dc nft"
        );

        // get card info
        (uint32[] memory role, uint256 grade, , ) = _xwgDCNFTRepo.get(
            xwgDCNftId
        );
        require(grade >= 2, "DIFansCreator: genesis fan grade must >= 2");

        FansCreateInfo storage info = _fansCreateInfo[role[0]];
        require(
            info.creatingPhase == 2,
            "DIFansCreator: fans process not in normal phase"
        );
        require(
            info.superFanNFTCreated < _maxSuperFanNFTCount,
            "DIFansCreator: no more super nft left"
        );

        _starPool.burn721Token(address(_xwgDCNFT), _msgSender(), xwgDCNftId);
        //_xwgDCNFT.burn(xwgDCNftId);

        // charge
        DIStepIncreaseSales.SalesInfo storage salesInfo = _superFanPrices[
            role[0]
        ][tokenAddr];
        require(salesInfo.sellStep > 0, "DIFansCreator: token price not set");
        if (salesInfo.price > 0) {
            require(
                salesInfo.price <= highiestPrice,
                "DIFansCreator: price grow out of range"
            );
            require(
                IERC20(tokenAddr).balanceOf(_msgSender()) >= salesInfo.price,
                "DIFansCreator: insufficient token"
            );
            _starPool.charge20Token(
                tokenAddr,
                _msgSender(),
                salesInfo.price
            );

          
        }

        // get inviter info
        require(_fansNFT.exists(inviterId), "DIFansCreator: inviter not exist");
        DIFansNFTData memory inviterData = _fansNFT.getNftData(inviterId);

        DIFansNFTData memory data = DIFansNFTData({
            fanType: 2,
            starRole: role[0],
            grade: uint8(grade),
            maxSP: _initMaxSP +
                _gradInitMaxSP[uint8(grade)] +
                _fanTypeInitMaxSP[2],
            sp: 1,
            invitorNftId: inviterId,
            producerNftId: inviterData.producerNftId,
            reserve: 0,
            reserve1: new uint32[](0)
        });

        if (inviterData.fanType == 1) {
            // inviter is genesis fan, producer is inviter
            data.producerNftId = inviterId;
        }

        fanNFTId = _fansNFT.mint(_msgSender(), data);

        // increase super fan nft created
        info.superFanNFTCreated++;

        emit SuperFanNFTCreated(_msgSender(), xwgDCNftId, fanNFTId);

        DIStar starContract = DIStar(_starFactory.getDIStarAddress(role[0]));
        starContract.onSuperFanCreated(fanNFTId, data);

        if (salesInfo.price > 0) {
            // call share income
            _starPool.onShare20Income(
                _starPool.INCOME_CONVERT_FANSNFT(),
                tokenAddr,
                uint64(fanNFTId),
                salesInfo.price
            );

            // notify on sell
            // this maybe change price,so should do it last
            salesInfo.onSell(1);
        }
    }

    // call by client wallet, convert a normal fan nft
    function convertNormalFan(
        uint32 starRole,
        address tokenAddr,
        uint64 inviterId,
        uint256 highiestPrice
    ) external whenNotPaused returns (uint256 fanNFTId) {
        FansCreateInfo storage info = _fansCreateInfo[starRole];
        require(
            info.creatingPhase == 2,
            "DIFansCreator: fans process not in normal phase"
        );

        // charge
        DIStepIncreaseSales.SalesInfo storage salesInfo = _superFanPrices[
            starRole
        ][tokenAddr];
        require(salesInfo.sellStep > 0, "DIFansCreator: token price not set");
        if (salesInfo.price > 0) {
            require(
                salesInfo.price <= highiestPrice,
                "DIFansCreator: price grow out of range"
            );
            require(
                IERC20(tokenAddr).balanceOf(_msgSender()) >= salesInfo.price,
                "DIFansCreator: insufficient token"
            );
            _starPool.charge20Token(
                tokenAddr,
                _msgSender(),
                salesInfo.price
            );

        }

        // get inviter info
        require(_fansNFT.exists(inviterId), "DIFansCreator: inviter not exist");
        DIFansNFTData memory inviterData = _fansNFT.getNftData(inviterId);

        DIFansNFTData memory data = DIFansNFTData({
            fanType: 3,
            starRole: starRole,
            grade: 1,
            maxSP: _initMaxSP,
            sp: 1,
            invitorNftId: inviterId,
            producerNftId: inviterData.producerNftId,
            reserve: 0,
            reserve1: new uint32[](0)
        });

        if (inviterData.fanType == 1) {
            // inviter is genesis fan, producer is inviter
            data.producerNftId = inviterId;
        }

        fanNFTId = _fansNFT.mint(_msgSender(), data);

        emit NormalFanNFTCreated(_msgSender(), starRole, fanNFTId);

        DIStar starContract = DIStar(_starFactory.getDIStarAddress(starRole));
        starContract.onNormalFanCreated(fanNFTId, data);

        if (salesInfo.price > 0) {
            // call share income
            _starPool.onShare20Income(
                _starPool.INCOME_CONVERT_FANSNFT(),
                tokenAddr,
                uint64(fanNFTId),
                salesInfo.price
            );

            
            // notify on sell
            // this maybe change price,so should do it last
            salesInfo.onSell(1);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStepIncreaseSales.sol)

pragma solidity ^0.8.0;

/**
 * @dev price increase by step of sale
 */
library DIStepIncreaseSales {

    struct SalesInfo {
        uint64 sellStep; // increase after sellStep is sold, =0 means never increase price
        uint32 increasePercent; // increase percent each time, increase per = increasePercent/1000000

        uint64 soldCount; // indicate how many is sold
        uint256 price; // current price
    }

    function initSalesInfo(SalesInfo storage info, uint64 step, uint32 percent, uint256 price) external {
        info.sellStep = step;
        info.increasePercent = percent;
        info.price = price;
        info.soldCount = 0;
    }

    function onSell(SalesInfo storage info,uint64 count) external {
        uint64 valuestep =info.soldCount/info.sellStep;
        
        info.soldCount += count;
        
        //require(info.sellStep > 0, "sales info error");
        if(info.sellStep == 0) {
            return;
        }
        
        uint64 valuestep2 =info.soldCount/info.sellStep;
        if(valuestep2>valuestep){
        //if(info.soldCount % info.sellStep == 0) {
            info.price += (info.price * info.increasePercent / 1000000)
            *(valuestep2-valuestep);
        }
    }
}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DICloudSales.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../Utility/TransferHelper.sol";

//import "hardhat/console.sol";
/**
 * @dev cloud sales library
 */
library DICloudSales {

    struct CloudSalesInfo {
        address tokenAddr; // token address
        address targetAddr; // token will be transfered to target address
        uint256 fundRaiseTarget; // raise goal
        uint256 minimumSend; // minimum token must send by a single buyin
        uint256 maximumPerUser; // maximum token send per user
        uint256 finishBlock; // keep sale till finish block number, if =0, then keep sale for ever

        mapping(address=>uint256) fundRaised; // user address => fund raised by each wallet address
        uint256 totalFundRaised; // totoal fund raised value

        // if finish block is passed, sales is finish, and target raise number not reached, then user can get their token back
        mapping(address=>bool) refunded; // user address => is this address refunded
        uint256 totalRefunded; // totoal refund value
    }

    function initSalesInfo(CloudSalesInfo storage info, address tokenAddr, address targetAddr, 
        uint256 raiseTarget, uint256 minimumSend, uint256 maximumPerUser, uint256 finishBlock) external 
    {
        info.tokenAddr = tokenAddr;
        info.targetAddr = targetAddr;
        info.fundRaiseTarget = raiseTarget;
        info.minimumSend = minimumSend;
        info.maximumPerUser = maximumPerUser;
        info.finishBlock = finishBlock;
        info.totalFundRaised = 0;
    }

    function sendToken(CloudSalesInfo storage info, address userAddr, uint256 value) external {
        require(IERC20(info.tokenAddr).balanceOf(userAddr) >= value, "cloudsale: insufficent token");
        if(info.finishBlock > 0) {
            require(block.number < info.finishBlock, "cloudsale: sales finish");
        }
        require(value >= info.minimumSend, "cloudsale: value too small");
        require(info.fundRaised[userAddr] + value <= info.maximumPerUser, "cloudsale: value too big");

        //console.log("[sol]sendToken tokenAddr",info.tokenAddr);
        //console.log("[sol]sendToken userAddr",userAddr);
        //console.log("[sol]sendToken  info.targetAddr", info.targetAddr);
        //console.log("[sol]sendToken  value", value);

        TransferHelper.safeTransferFrom(info.tokenAddr, userAddr, info.targetAddr, value);

        info.fundRaised[userAddr] += value;
        info.totalFundRaised += value;
    }

    function getBackToken(CloudSalesInfo storage info, address userAddr) external returns(uint256 value){
        require(info.finishBlock > 0 && block.number > info.finishBlock, "cloudsale: sales not finish");
        require(info.totalFundRaised < info.fundRaiseTarget, "cloudsale: sales success");

        value = info.fundRaised[userAddr];
        require(value > 0, "cloudsale: no fund");

        require(IERC20(info.tokenAddr).balanceOf(info.targetAddr) >= value, "cloudsale: insufficent token");
        require(!info.refunded[userAddr], "cloudsale: already refunded");

        TransferHelper.safeTransferFrom(info.tokenAddr, info.targetAddr, userAddr, value);

        info.refunded[userAddr] = true;
        info.totalRefunded += value;
    }

    function fundRaisePercent(CloudSalesInfo storage info) external view returns(uint256 percentInMillion) {
        return info.totalFundRaised * 1000000 / info.fundRaiseTarget;
    }

    function getUserRaised(CloudSalesInfo storage info, address userAddr) external view returns(uint256 userRaised) {
        return info.fundRaised[userAddr];
    }

}

// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIUpgradeableProxy.sol)

pragma solidity ^0.8.2;
//ERC1967Upgrade require solidity 0.8.2

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

//use EIP1967

contract DIUpgradeableProxy is Context, ERC1967Proxy {
 
    //only call initialize foronce
    constructor(address _impl)
        payable
        ERC1967Proxy(_impl, abi.encodeWithSignature("initialize()", 0))
    {
        _changeAdmin(msg.sender);
    }

    function upgradeTo(address _impl) public {
        require(
            _msgSender() == _getAdmin(),
            "upgradeTo:Only admin can do this."
        );
        _upgradeTo(_impl);
    }
 
    function getAdmin() public view returns (address) {
        return _getAdmin();
    }

    function changeAdmin(address newAdmin) public {
        require(
            _msgSender() == _getAdmin(),
            "changeAdmin:Only admin can do this."
        );
        _changeAdmin(newAdmin);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overridden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../interfaces/draft-IERC1822.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
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
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            Address.functionDelegateCall(newImplementation, data);
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
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
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
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
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
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
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
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822Proxiable {
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
library StorageSlot {
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
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