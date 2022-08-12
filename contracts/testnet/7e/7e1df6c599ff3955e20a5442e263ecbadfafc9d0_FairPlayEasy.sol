pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import "./IBEP20.sol";

contract FairPlayEasy {
    IBEP20 private immutable token;

    mapping(address => bool) isParticipated;
    mapping(address => Participant) adrToInfo;
    uint256 public usersAmount = 5500;
    mapping(uint256 => uint256) levlToPayment;

    mapping(uint256 => uint256) curTabId;

    mapping(address => uint256) totalMoney;

    mapping(address => minTable[]) adrToTables;

    bool public isActive;

    struct minTable {
        uint256 lvl;
        uint256 id;
    }

    struct Participant {
        uint256 playerId;
        uint256 level;
        uint256 tableId;
        uint256 payment;
        uint256 timest;
        uint256 idInTable;
        uint256 startingTime;
    }

    mapping(uint256 => mapping(uint256 => Table)) levlToIdToTable;

    mapping(uint256 => uint256) levlToAmount;

    mapping(uint256 => winner) idWinnerToInfo;
    mapping(uint256 => trans) idTransToInfo;

    struct winner {
        address user;
        uint256 tableId;
        uint256 time;
        uint256 money;
    }

    struct trans {
        uint256 level;
        uint256 tableId;
        address user;
        uint256 time;
        uint256 money;
    }

    mapping(address => mapping(uint256 => bool)) isInQueue;

    uint256 deadline;

    address public owner;

    event tableClosed(
        address leader_,
        uint256 money_,
        uint256 lostMoney,
        uint256 level_,
        uint256 tableId_
    );

    event newParticipant(
        uint256 level,
        uint256 tableId,
        address tableLeader,
        uint256 updatedLeaderMoney
    );

    constructor(address busdAddress, address owner_) {
        require(busdAddress != address(0x0));
        token = IBEP20(busdAddress);
        owner = owner_;

        levlToPayment[1] = 30 * 10**18;
        levlToPayment[2] = 120 * 10**18;
        levlToPayment[3] = 480 * 10**18;
        levlToPayment[4] = 1920 * 10**18;
        levlToPayment[5] = 7680 * 10**18;
        levlToPayment[6] = 30720 * 10**18;

        deadline = 1 days;
    }

    struct Table {
        address leader;
        bool leaderPaid;
        address[7] users;
        uint256 tableId;
        uint256 userCount;
        bool[7] isPaid;
        bool isPaidAll;
        uint256[7] time;
    }

    function participate() external {
        require(isActive, "Game is not active yet");

        usersAmount++;
        adrToInfo[msg.sender].playerId = usersAmount;
        isInQueue[msg.sender][adrToInfo[msg.sender].level] = false;
        adrToInfo[msg.sender].startingTime = block.timestamp;

        if (
            (block.timestamp > adrToInfo[msg.sender].timest + deadline) &&
            adrToInfo[msg.sender].timest != 0
        ) {
            isParticipated[msg.sender] = false;
        }
        require(isParticipated[msg.sender] == false, "Already participated");
        for (uint256 i = 1; i <= levlToAmount[1] + 1; i++) {
            if ((levlToIdToTable[1][i].leader == address(0x0))) {
                levlToAmount[1]++;

                levlToIdToTable[1][i].leader = msg.sender;
                levlToIdToTable[1][i].tableId = i;
                isParticipated[msg.sender] = true;
                uint256 time = block.timestamp;

                adrToInfo[msg.sender].timest = time;
                adrToInfo[msg.sender].level = 1;
                adrToInfo[msg.sender].tableId = i;
                adrToInfo[msg.sender].payment = levlToPayment[1];

                token.transferFrom(
                    msg.sender,
                    levlToIdToTable[1][i].leader,
                    (adrToInfo[msg.sender].payment * 95) / 100
                );

                totalMoney[levlToIdToTable[1][i].leader] +=
                    (adrToInfo[msg.sender].payment * 95) /
                    100;
                token.transferFrom(
                    msg.sender,
                    owner,
                    (adrToInfo[msg.sender].payment * 5) / 100
                );
                totalMoney[owner] += (adrToInfo[msg.sender].payment * 5) / 100;

                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leaderPaid = true;

                break;
            } else if (
                levlToIdToTable[1][i].userCount < 6 &&
                levlToIdToTable[1][i].leaderPaid
            ) {
                levlToIdToTable[1][i].userCount++;
                levlToIdToTable[1][i].users[
                    levlToIdToTable[1][i].userCount
                ] = msg.sender;

                isParticipated[msg.sender] = true;
                uint256 time = block.timestamp;
                levlToIdToTable[1][i].time[
                    levlToIdToTable[1][i].userCount
                ] = time;

                adrToInfo[msg.sender].idInTable = levlToIdToTable[1][i]
                    .userCount;

                adrToInfo[msg.sender].timest = time;
                adrToInfo[msg.sender].level = 1;
                adrToInfo[msg.sender].tableId = i;
                adrToInfo[msg.sender].payment = levlToPayment[1];
                curTabId[adrToInfo[msg.sender].level] = i;

                token.transferFrom(
                    msg.sender,
                    levlToIdToTable[1][i].leader,
                    (adrToInfo[msg.sender].payment * 95) / 100
                );

                totalMoney[levlToIdToTable[1][i].leader] +=
                    (adrToInfo[msg.sender].payment * 95) /
                    100;
                token.transferFrom(
                    msg.sender,
                    owner,
                    (adrToInfo[msg.sender].payment * 5) / 100
                );
                totalMoney[owner] += (adrToInfo[msg.sender].payment * 5) / 100;

                levlToIdToTable[1][i].isPaid[
                    adrToInfo[msg.sender].idInTable
                ] = true;

                for (uint256 l = 1; l < 16; l++) {
                    if (idTransToInfo[l].user == address(0x0)) {
                        idTransToInfo[l].user = levlToIdToTable[
                            adrToInfo[msg.sender].level
                        ][adrToInfo[msg.sender].tableId].leader;
                        idTransToInfo[l].time = block.timestamp;
                        idTransToInfo[l].tableId = adrToInfo[msg.sender]
                            .tableId;
                        idTransToInfo[l].level = adrToInfo[msg.sender].level;
                        idTransToInfo[l].money =
                            (levlToPayment[adrToInfo[msg.sender].level] *
                                6 *
                                95) /
                            100;
                        break;
                    }

                    if (l == 15) {
                        for (uint256 j = 1; j < 15; j++) {
                            idTransToInfo[j].user = idTransToInfo[j + 1].user;
                            idTransToInfo[j].time = idTransToInfo[j + 1].time;
                            idTransToInfo[j].tableId = idTransToInfo[j + 1]
                                .tableId;
                            idTransToInfo[j].level = idTransToInfo[j + 1].level;
                            idTransToInfo[j].money = idTransToInfo[j + 1].money;
                        }
                        idTransToInfo[15].user = levlToIdToTable[
                            adrToInfo[msg.sender].level
                        ][adrToInfo[msg.sender].tableId].leader;
                        idTransToInfo[15].time = block.timestamp;
                        idTransToInfo[15].tableId = adrToInfo[msg.sender]
                            .tableId;
                        idTransToInfo[15].level = adrToInfo[msg.sender].level;
                        idTransToInfo[15].money =
                            (levlToPayment[adrToInfo[msg.sender].level] *
                                6 *
                                95) /
                            100;
                    }
                }

                emit newParticipant(
                    adrToInfo[msg.sender].level,
                    adrToInfo[msg.sender].tableId,
                    levlToIdToTable[1][i].leader,
                    totalMoney[
                        levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader
                    ]
                );

                if (levlToIdToTable[1][i].userCount == 6) {
                    levlToIdToTable[1][i].isPaidAll = true;
                    closeTable();
                }

                break;
            }
        }
    }

    function nextLevel() external {
        require(isActive, "Game is not active yet");
        require(
            block.timestamp <= adrToInfo[msg.sender].timest + deadline,
            "you're late"
        );

        require(adrToInfo[msg.sender].level != 1, "already paid");
        require(
            isInQueue[msg.sender][adrToInfo[msg.sender].level] == true,
            "address is not in queue"
        );

        isInQueue[msg.sender][adrToInfo[msg.sender].level] = false;

        for (
            uint256 i = 1;
            i <= levlToAmount[adrToInfo[msg.sender].level] + 1;
            i++
        ) {
            if (
                levlToIdToTable[adrToInfo[msg.sender].level][i].leader ==
                address(0x0)
            ) {
                levlToAmount[adrToInfo[msg.sender].level]++;

                token.transferFrom(
                    msg.sender,
                    levlToIdToTable[1][i].leader,
                    (adrToInfo[msg.sender].payment * 95) / 100
                );

                totalMoney[levlToIdToTable[1][i].leader] +=
                    (adrToInfo[msg.sender].payment * 95) /
                    100;
                token.transferFrom(
                    msg.sender,
                    owner,
                    (adrToInfo[msg.sender].payment * 5) / 100
                );
                totalMoney[owner] += (adrToInfo[msg.sender].payment * 5) / 100;

                levlToIdToTable[adrToInfo[msg.sender].level][i].leader = msg
                    .sender;
                levlToIdToTable[adrToInfo[msg.sender].level][i]
                    .tableId = levlToAmount[adrToInfo[msg.sender].level];
                isParticipated[msg.sender] = true;

                adrToInfo[msg.sender].level = adrToInfo[msg.sender].level;
                adrToInfo[msg.sender].tableId = levlToAmount[
                    adrToInfo[msg.sender].level
                ];

                adrToInfo[msg.sender].payment = levlToPayment[
                    adrToInfo[msg.sender].level
                ];

                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leaderPaid = true;

                break;
            } else if (
                levlToIdToTable[adrToInfo[msg.sender].level][i].userCount != 6 // отправляем лидера учатником на след уровень, если стол не забит
            ) {
                levlToIdToTable[adrToInfo[msg.sender].level][i].userCount++;

                levlToIdToTable[adrToInfo[msg.sender].level][i].users[
                    levlToIdToTable[adrToInfo[msg.sender].level][i].userCount
                ] = msg.sender;

                isParticipated[msg.sender] = true;

                levlToIdToTable[adrToInfo[msg.sender].level][i].time[
                        levlToIdToTable[adrToInfo[msg.sender].level][i]
                            .userCount
                    ] = adrToInfo[msg.sender].timest;

                adrToInfo[msg.sender].idInTable = levlToIdToTable[
                    adrToInfo[msg.sender].level
                ][i].userCount;

                adrToInfo[msg.sender].level = adrToInfo[msg.sender].level;

                adrToInfo[msg.sender].tableId = i;

                adrToInfo[msg.sender].payment = levlToPayment[
                    adrToInfo[msg.sender].level
                ];
                curTabId[adrToInfo[msg.sender].level] = i;

                for (uint256 l = 1; l < 16; l++) {
                    if (idTransToInfo[l].user == address(0x0)) {
                        idTransToInfo[l].user = levlToIdToTable[
                            adrToInfo[msg.sender].level
                        ][adrToInfo[msg.sender].tableId].leader;
                        idTransToInfo[l].time = block.timestamp;
                        idTransToInfo[l].tableId = adrToInfo[msg.sender]
                            .tableId;
                        idTransToInfo[l].level = adrToInfo[msg.sender].level;
                        idTransToInfo[l].money =
                            (levlToPayment[adrToInfo[msg.sender].level] *
                                6 *
                                95) /
                            100;
                        break;
                    }

                    if (l == 15) {
                        for (uint256 j = 1; j < 15; j++) {
                            idTransToInfo[j].user = idTransToInfo[j + 1].user;
                            idTransToInfo[j].time = idTransToInfo[j + 1].time;
                            idTransToInfo[j].tableId = idTransToInfo[j + 1]
                                .tableId;
                            idTransToInfo[j].level = idTransToInfo[j + 1].level;
                            idTransToInfo[j].money = idTransToInfo[j + 1].money;
                        }
                        idTransToInfo[15].user = levlToIdToTable[
                            adrToInfo[msg.sender].level
                        ][adrToInfo[msg.sender].tableId].leader;
                        idTransToInfo[15].time = block.timestamp;
                        idTransToInfo[15].tableId = adrToInfo[msg.sender]
                            .tableId;
                        idTransToInfo[15].level = adrToInfo[msg.sender].level;
                        idTransToInfo[15].money =
                            (levlToPayment[adrToInfo[msg.sender].level] *
                                6 *
                                95) /
                            100;
                    }
                }

                payToLeader();
                break;
            }
        }
    }

    function payToLeader() internal {
        require(
            block.timestamp <= adrToInfo[msg.sender].timest + deadline,
            "you are late"
        );
        require(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].isPaid[adrToInfo[msg.sender].idInTable] == false,
            "you already paid"
        );
        require(adrToInfo[msg.sender].level != 1, "already paid");
        require(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader != msg.sender,
            "leader"
        );

        token.transferFrom(
            msg.sender,
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader,
            (adrToInfo[msg.sender].payment * 95) / 100
        );

        totalMoney[
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader
        ] += (adrToInfo[msg.sender].payment * 95) / 100;
        token.transferFrom(
            msg.sender,
            owner,
            (adrToInfo[msg.sender].payment * 5) / 100
        );
        totalMoney[owner] += (adrToInfo[msg.sender].payment * 5) / 100;

        emit newParticipant(
            adrToInfo[msg.sender].level,
            adrToInfo[msg.sender].tableId,
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader,
            totalMoney[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ]
        );

        levlToIdToTable[adrToInfo[msg.sender].level][
            adrToInfo[msg.sender].tableId
        ].isPaid[adrToInfo[msg.sender].idInTable] = true;
        uint256 count;
        for (uint256 i = 1; i < 7; i++) {
            if (
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].isPaid[i] == true
            ) {
                count++;
            }
        }
        if (count == 6) {
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].isPaidAll = true;
            closeTable();
        }
    }

    function closeTable() internal {
        curTabId[adrToInfo[msg.sender].level]++;
        for (uint256 i = 1; i < 11; i++) {
            if (idWinnerToInfo[i].user == address(0x0)) {
                idWinnerToInfo[i].user = levlToIdToTable[
                    adrToInfo[msg.sender].level
                ][adrToInfo[msg.sender].tableId].leader;
                idWinnerToInfo[i].time = block.timestamp;
                idWinnerToInfo[i].tableId = adrToInfo[msg.sender].tableId;
                idWinnerToInfo[i].money =
                    (levlToPayment[adrToInfo[msg.sender].level] * 6 * 95) /
                    100;
                break;
            }

            if (i == 10) {
                for (uint256 j = 1; j < 10; j++) {
                    idWinnerToInfo[j].user = idWinnerToInfo[j + 1].user;
                    idWinnerToInfo[j].time = idWinnerToInfo[j + 1].time;
                    idWinnerToInfo[j].tableId = idWinnerToInfo[j + 1].tableId;
                    idWinnerToInfo[j].money = idWinnerToInfo[j + 1].money;
                }
                idWinnerToInfo[10].user = levlToIdToTable[
                    adrToInfo[msg.sender].level
                ][adrToInfo[msg.sender].tableId].leader;
                idWinnerToInfo[10].time = block.timestamp;
                idWinnerToInfo[10].tableId = adrToInfo[msg.sender].tableId;
                idWinnerToInfo[10].money =
                    (levlToPayment[adrToInfo[msg.sender].level] * 6 * 95) /
                    100;
            }
        }
        uint256 lost = 0;
        if (
            block.timestamp >
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].timest +
                deadline
        ) {
            lost =
                (levlToPayment[
                    adrToInfo[
                        levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader
                    ].level
                ] *
                    6 *
                    95) /
                100;
        }

        emit tableClosed(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader,
            (levlToPayment[adrToInfo[msg.sender].level] * 6 * 95) / 100,
            lost,
            adrToInfo[msg.sender].level,
            adrToInfo[msg.sender].tableId
        );

        if (adrToInfo[msg.sender].level == 6) {
            isParticipated[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ] == false;
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].level = 0;
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].tableId = 0;
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].timest = 0;
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].idInTable = 0;
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].payment = 0;
        } else {
            adrToTables[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].push(
                    minTable(
                        adrToInfo[msg.sender].level,
                        adrToInfo[msg.sender].tableId
                    )
                );
            isInQueue[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ][adrToInfo[msg.sender].level + 1] = true;

            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].level = adrToInfo[msg.sender].level + 1;

            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ].timest = block.timestamp;
        }

        for (uint256 i = 1; i < 7; i++) {
            address curUser = levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].users[i];

            levlToAmount[adrToInfo[msg.sender].level]++;
            levlToIdToTable[adrToInfo[msg.sender].level][
                levlToAmount[adrToInfo[msg.sender].level]
            ].leader = levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].users[i];

            levlToIdToTable[adrToInfo[msg.sender].level][
                levlToAmount[adrToInfo[msg.sender].level]
            ].tableId = levlToAmount[adrToInfo[msg.sender].level];

            levlToIdToTable[adrToInfo[msg.sender].level][
                levlToAmount[adrToInfo[msg.sender].level]
            ].leaderPaid = true;

            isParticipated[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ] = true;

            adrToInfo[curUser].tableId = levlToAmount[
                adrToInfo[msg.sender].level
            ];

            adrToInfo[curUser].payment = levlToPayment[
                adrToInfo[msg.sender].level
            ];

            adrToInfo[curUser].timest = block.timestamp;
        }
    }

    function changeActiveStatus() external {
        require(owner == msg.sender, "Not owner");
        isActive = !isActive;
    }

    function checkMyData(address user)
        external
        view
        returns (Participant memory)
    {
        return adrToInfo[user];
    }

    function tableAmount(uint256 levl) external view returns (uint256) {
        return levlToAmount[levl];
    }

    function tableInfo(uint256 levl, uint256 tableId)
        external
        view
        returns (Table memory)
    {
        return levlToIdToTable[levl][tableId];
    }

    function myTableInfo(address user)
        external
        view
        returns (
            address leader,
            uint256 idOfTable,
            uint256 countOfUsers,
            uint256 myStartingTime,
            bool isAllPaid
        )
    {
        return (
            levlToIdToTable[adrToInfo[user].level][adrToInfo[user].tableId]
                .leader,
            adrToInfo[user].tableId,
            levlToIdToTable[adrToInfo[user].level][adrToInfo[user].tableId]
                .userCount,
            adrToInfo[user].timest,
            levlToIdToTable[adrToInfo[user].level][adrToInfo[user].tableId]
                .isPaidAll
        );
    }

    function userInfo(address user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 lost = 0;
        if (block.timestamp > adrToInfo[user].timest + deadline) {
            lost = (levlToPayment[adrToInfo[user].level] * 6 * 95) / 100;
        }
        return (
            adrToInfo[user].playerId,
            totalMoney[user],
            lost,
            adrToInfo[user].startingTime
        );
    }

    function checkWinnerInfo(uint256 id) external view returns (winner memory) {
        require(id > 0 && id < 11, "Not right number");
        return (idWinnerToInfo[id]);
    }

    function checkAllMyTableInfo(address user)
        external
        view
        returns (
            minTable[] memory,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            adrToTables[user],
            adrToInfo[user].level,
            adrToInfo[user].tableId,
            adrToInfo[user].tableId - curTabId[adrToInfo[user].level]
        );
    }

    function restTime(address user) external view returns (uint256) {
        if (isParticipated[user]) {
            if (block.timestamp > adrToInfo[user].timest + deadline) {
                return 0;
            } else {
                return block.timestamp - adrToInfo[user].timest;
            }
        } else {
            return 0;
        }
    }

    function checkQueue(address user, uint256 levl)
        external
        view
        returns (bool)
    {
        return isInQueue[user][levl];
    }

    function lastWinners() external view returns (winner[11] memory) {
        winner[11] memory myWinners;
        for (uint256 i = 1; i < 11; i++) {
            myWinners[i] = idWinnerToInfo[i];
        }
        return myWinners;
    }

    function lastTransactions() external view returns (trans[16] memory) {
        trans[16] memory myTrans;
        for (uint256 i = 1; i < 16; i++) {
            myTrans[i] = idTransToInfo[i];
        }
        return myTrans;
    }
}