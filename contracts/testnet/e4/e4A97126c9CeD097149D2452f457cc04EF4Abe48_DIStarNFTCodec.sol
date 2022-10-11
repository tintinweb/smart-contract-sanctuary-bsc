// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStar1155.sol)

pragma solidity ^0.8.0;
import "./DIStarAssetDefine.sol";

// struct DIStarCharacter {
//     uint8 level;
//     uint64 exp;
//     uint64 combatPower;
//     uint32 avatar;
//     uint32 skill;
// }
contract DIStarNFTCodec is IDIStarNFTCodec {
    function getCharacterData(DIStarNFTDataBase memory data)
        external
        pure
        override
        returns (DIStarCharacter memory cd)
    {
        uint216 srcdata = data.reserve1;
        cd.level = uint8(srcdata & 0xff);
        cd.exp = uint64((srcdata >> 8) & 0xffffffffffffffff);
        cd.combatPower = uint64((srcdata >> (8 + 64)) & 0xffffffffffffffff);
        cd.avatar = uint32((srcdata >> (8 + 64 + 64)) & 0xffffffff);
        cd.skill = uint32((srcdata >> (8 + 64 + 64 + 32)) & 0xffffffff);
    }

    function fromCharacterData(DIStarCharacter memory data)
        external
        pure
        override
        returns (DIStarNFTDataBase memory outdata)
    {
        outdata.reserve1 =
            uint216(data.level) |
            (uint216(data.exp) << 8) |
            (uint216(data.combatPower) << (8 + 64)) |
            (uint216(data.avatar) << (8 + 64 + 64)) |
            (uint216(data.skill) << (8 + 64 + 64 + 32));
        outdata.reserve2 = 0;
        outdata.reserve3 = new uint32[](0);
    }
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