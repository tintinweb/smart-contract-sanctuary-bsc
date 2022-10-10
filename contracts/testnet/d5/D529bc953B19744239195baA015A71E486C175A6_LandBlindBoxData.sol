// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./Lockable.sol";

contract LandBlindBoxData is ModuleBase, Lockable {
    uint256 private roundIndex;

    struct NodeData {
        address account;
        uint256 totalAmount;
        uint256 withRewardAmount;
        uint256 count;
        uint256 bingoNum;
        uint256 utoPrice;
    }

    struct BingoData {
        uint256 position;
        uint256 tokenId;
    }

    //container of all nodes
    //key: roundIndex => NodeData
    mapping(uint256 => NodeData) mapNodeData;

    //container of user nodes
    //key: account => (user_buy_index => roundIndex)
    mapping(address => mapping(uint256 => uint256)) mapUserData;
    mapping(address => uint256) mapUserBuyNum;

    //container of bingo in round
    //key: roundIndex => (index of bingoNum => BingoData)
    mapping(uint256 => mapping(uint256 => BingoData)) mapBingo;

    constructor(address _auth, address _moduleMgr)
        ModuleBase(_auth, _moduleMgr)
    {}

    function getCurrentRoundIndex() external view returns (uint256 res) {
        res = roundIndex;
    }

    function increaseRoundIndex(uint256 n) external onlyCaller {
        roundIndex += n;
    }

    function newNodeData(
        address account,
        uint256 totalAmount,
        uint256 withRewardAmount,
        uint256 count,
        uint256 bingoNum,
        uint256 utoPrice
    ) external onlyCaller {
        mapNodeData[roundIndex] = NodeData(
            account,
            totalAmount,
            withRewardAmount,
            count,
            bingoNum,
            utoPrice
        );
    }

    function getNodeData(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            address account,
            uint256 totalAmount,
            uint256 withRewardAmount,
            uint256 count,
            uint256 bingoNum
        )
    {
        if (mapNodeData[roundNumber].count > 0) {
            res = true;
            account = mapNodeData[roundNumber].account;
            totalAmount = mapNodeData[roundNumber].totalAmount;
            withRewardAmount = mapNodeData[roundNumber].withRewardAmount;
            count = mapNodeData[roundNumber].count;
            bingoNum = mapNodeData[roundNumber].bingoNum;
        }
    }

    function increaseUserBuyNumber(address account, uint256 n)
        external
        onlyCaller
    {
        mapUserBuyNum[account] += n;
    }

    function getUserBuyNumber(address account)
        external
        view
        returns (uint256 res)
    {
        res = mapUserBuyNum[account];
    }

    function setUserBuyRound(
        address account,
        uint256 index,
        uint256 roundNumber
    ) external onlyCaller {
        mapUserData[account][index] = roundNumber;
    }

    function getUserBuyRound(address account, uint256 index)
        external
        view
        returns (uint256 res)
    {
        res = mapUserData[account][index];
    }

    function getUserBuyData(address _account, uint256 index)
        external
        view
        returns (
            bool res,
            address account,
            uint256 totalAmount,
            uint256 withRewardAmount,
            uint256 count,
            uint256 bingoNum
        )
    {
        if (mapUserData[_account][index] > 0) {
            uint256 roundNumber = mapUserData[_account][index];
            if (mapNodeData[roundNumber].count > 0) {
                res = true;
                account = mapNodeData[roundNumber].account;
                totalAmount = mapNodeData[roundNumber].totalAmount;
                withRewardAmount = mapNodeData[roundNumber].withRewardAmount;
                count = mapNodeData[roundNumber].count;
                bingoNum = mapNodeData[roundNumber].bingoNum;
            }
        }
    }

    function setBingo(
        uint256 roundNumber,
        uint256 index,
        uint256 position,
        uint256 tokenId
    ) external onlyCaller {
        mapBingo[roundNumber][index] = BingoData(position, tokenId);
    }

    function getBingoList(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            uint256[] memory positions,
            uint256[] memory tokenIds
        )
    {
        if (mapNodeData[roundNumber].bingoNum > 0) {
            uint256 bingoNum = mapNodeData[roundNumber].bingoNum;
            res = true;
            positions = new uint256[](bingoNum);
            tokenIds = new uint256[](bingoNum);
            for (uint8 i = 0; i < bingoNum; ++i) {
                positions[i] = mapBingo[roundNumber][i].position;
                tokenIds[i] = mapBingo[roundNumber][i].tokenId;
            }
        }
    }
}