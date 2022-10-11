// SPDX-License-Identifier: MIT
// DreamIdol Contracts (DIStar1155.sol)

pragma solidity ^0.8.0;
import "./DIStarAssetDefine.sol";

contract DIStar1155Codec is IDIStar1155Codec {
    // struct DIStar1155IDAttr {
    //     uint32  role; // star role, =0 match any role, >0 role id
    //     uint16  tp; // type =1 : character item, =2 : expedition item, =3 : room item, =4 : mystery box
    //     uint32  id; // id
    // }

    function getDIStarAttrByID(uint256 id)
        external
        pure
        override
        returns (DIStar1155IDAttr memory attr)
    {
        attr.role = uint32(id & 0xffffffff);
        attr.tp = uint16((id >> 32) & 0xffff);
        attr.id = uint32((id >> (32 + 16)) & 0xffffffff);
    }

    function setDIStarAttrToID(DIStar1155IDAttr memory attr)
        external
        pure
        override
        returns (uint256 id)
    {
        id =
            uint256(attr.role) |
            (uint256(attr.tp) << 32) |
            (uint256(attr.id) << (32 + 16));
    }

    function getIDFromRoleAndAttribue(uint32 role, uint256 attr)
        external
        pure
        override
        returns (uint256 id)
    {
        uint16 _tp = uint16((attr >> 32) & 0xffff);
        uint32 _id = uint32((attr >> (32 + 16)) & 0xffffffff);
        id = (uint256(_id) << (32 + 16)) | (uint256(_tp) << 32) | uint256(role);
    }

    function getTpFromID(uint256 id)
        external
        pure
        override
        returns (uint16 tp)
    {
        tp = uint16((id >> 32) & 0xffff);
    }

    // struct DIStar1155DataBase {
    //     uint8   grade; // grade

    //     uint248 reserve1; // for update
    //     uint32[] reserve2; // for update
    // }

    // struct DIStarCharacterItem {
    //     uint8 citp; // charcter item type = 1: add exp, = 2: add combat power, = 3: change skill
    //     uint64 add;
    // }
    function getCharacterItemData(DIStar1155DataBase memory data)
        external
        pure
        override
        returns (DIStarCharacterItem memory ed)
    {
        uint248 srcdata = data.reserve1;
        ed.citp = uint8(srcdata & 0xff);
        ed.add = uint64((srcdata >> 8) & 0xffffffffffffffff);
    }

    // struct DIStarExpeditionItem {
    //     uint64 combatPower;
    //     uint8 slot;
    //     uint32 avatar;
    //     uint32 func;
    // }
    function getExpeditionData(DIStar1155DataBase memory data)
        external
        pure
        override
        returns (DIStarExpeditionItem memory ed)
    {
        uint248 srcdata = data.reserve1;
        ed.combatPower = uint64(srcdata & 0xffffffffffffffff);
        ed.slot = uint8((srcdata >> 64) & 0xff);
        ed.avatar = uint32((srcdata >> (64 + 8)) & 0xffffffff);
        ed.func = uint32((srcdata >> (64 + 8 + 32)) & 0xffffffff);
    }

    // struct DIStarRoomItem {
    //     uint32 roomItemId;
    //     uint32 roomItemType;
    // }
    function getRoomItemData(DIStar1155DataBase memory data)
        external
        pure
        override
        returns (DIStarRoomItem memory rd)
    {
        uint248 srcdata = data.reserve1;
        rd.roomItemId = uint32(srcdata & 0xffffffff);
        rd.roomItemType = uint32((srcdata >> 32) & 0xffffffff);
    }

    // struct DIMysteryBoxItem {
    //     uint32 randomType;
    //     uint32 mysteryType;
    // }
    function getMysteryBoxData(DIStar1155DataBase memory data)
        external
        pure
        override
        returns (DIMysteryBoxItem memory rd)
    {
        uint248 srcdata = data.reserve1;
        rd.randomType = uint32(srcdata & 0xffffffff);
        rd.mysteryType = uint32((srcdata >> 32) & 0xffffffff);
    }

    // struct DIStarCharacterItem {
    //     uint8 citp; // charcter item type = 1: add exp, = 2: add combat power, = 3: change skill
    //     uint64 add;
    // }
    function fromCharacterItemData(DIStarCharacterItem memory data)
        external
        pure
        override
        returns (DIStar1155DataBase memory outdata)
    {
        outdata.grade = 0;
        outdata.reserve1 = uint248(data.citp) | (uint248(data.add) << 8);
        outdata.reserve2 = new uint32[](0);
    }

    // struct DIStarExpeditionItem {
    //     uint64 combatPower;
    //     uint8 slot;
    //     uint32 avatar;
    //     uint32 func;
    // }
    function fromExpeditionItemData(DIStarExpeditionItem memory data)
        external
        pure
        override
        returns (DIStar1155DataBase memory outdata)
    {
        outdata.grade = 0;
        outdata.reserve1 =
            uint248(data.combatPower) |
            (uint248(data.slot) << 64) |
            (uint248(data.avatar) << (64 + 8)) |
            (uint248(data.func) << (64 + 8 + 32));
        outdata.reserve2 = new uint32[](0);
    }

    // struct DIStarRoomItem {
    //     uint32 roomItemId;
    //     uint32 roomItemType;
    // }
    function fromRoomItemData(DIStarRoomItem memory data)
        external
        pure
        override
        returns (DIStar1155DataBase memory outdata)
    {
        outdata.grade = 0;
        outdata.reserve1 =
            uint248(data.roomItemId) |
            (uint248(data.roomItemType) << 32);
        outdata.reserve2 = new uint32[](0);
    }

    // struct DIMysteryBoxItem {
    //     uint32 randomType;
    //     uint32 mysteryType;
    // }
    function fromMysteryBoxData(DIMysteryBoxItem memory data)
        external
        pure
        override
        returns (DIStar1155DataBase memory outdata)
    {
        outdata.grade = 0;
        outdata.reserve1 =
            uint248(data.randomType) |
            (uint248(data.mysteryType) << 32);
        outdata.reserve2 = new uint32[](0);
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