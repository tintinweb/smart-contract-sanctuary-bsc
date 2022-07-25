pragma solidity ^0.8.13;

import "./IBEP20.sol";

contract GoodGame2 {
    IBEP20 private immutable token;

    mapping(address => bool) isParticipated;
    mapping(address => Participant) adrToInfo;
    uint256 public usersAmount = 5500;
    mapping(uint256 => uint256) levlToPayment;

    mapping(address => address) referals;
    mapping(address => bool) isRefAvailable;

    mapping(address => uint256) moneyFromReferals;
    mapping(address => uint256) totalMoney;

    mapping(address => minTable[]) adrToTables;

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

    //address[10] lastWinners;

    struct winner {
        address user;
        uint256 tableId;
        uint256 time;
        uint256 money;
    }

    mapping(address => mapping(uint256 => bool)) isInQueue;

    uint256 deadline;

    address public owner;

    event tableClosed(
        address leader_,
        uint256 money_,
        uint256 level_,
        uint256 tableId_
    );

    constructor(address busdAddress, address owner_) {
        require(busdAddress != address(0x0));
        token = IBEP20(busdAddress);
        owner = owner_;

        /*levlToPayment[1] = 2000 * 10**18;
        levlToPayment[2] = 4000 * 10**18;
        levlToPayment[3] = 8000 * 10**18;
        levlToPayment[4] = 16000 * 10**18;
        levlToPayment[5] = 32000 * 10**18;*/

        levlToPayment[1] = 1 * 10**18;
        levlToPayment[2] = 2 * 10**18;
        levlToPayment[3] = 3 * 10**18;
        levlToPayment[4] = 4 * 10**18;
        levlToPayment[5] = 5 * 10**18;

        //deadline = 1 days;
        deadline = 1 days;
    }

    struct Table {
        address leader;
        bool leaderPaid;
        address[4] users;
        uint256 tableId;
        uint256 userCount;
        bool[4] isPaid;
        bool isPaidAll;
        uint256[4] time;
    }

    // Участвовать в первый раз или когда время вышло.

    function participate(address ref) external {
        //isTimeIsOver(msg.sender);
        usersAmount++;
        adrToInfo[msg.sender].playerId = usersAmount;
        isInQueue[msg.sender][adrToInfo[msg.sender].level] = false;
        adrToInfo[msg.sender].startingTime = block.timestamp;

        //token.transferFrom(msg.sender,levlToIdToTable[adrToInfo[msg.sender].level][adrToInfo[msg.sender].tableId].leader,(adrToInfo[msg.sender].payment * 95) / 100);
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
                referals[msg.sender] = ref;

                //adrToTables[msg.sender].push(minTable(1, i));

                /*token.transferFrom(
                    msg.sender,
                    owner,
                    adrToInfo[msg.sender].payment
                );*/

                if (referals[msg.sender] != msg.sender) {
                    if (
                        adrToInfo[referals[msg.sender]].level >=
                        adrToInfo[msg.sender].level &&
                        isRefAvailable[referals[msg.sender]]
                    ) {
                        token.transferFrom(
                            msg.sender,
                            referals[msg.sender],
                            (adrToInfo[msg.sender].payment * 10) / 100
                        );
                        moneyFromReferals[referals[msg.sender]] +=
                            (adrToInfo[msg.sender].payment * 10) /
                            100;
                        totalMoney[referals[msg.sender]] +=
                            (adrToInfo[msg.sender].payment * 10) /
                            100;
                        token.transferFrom(
                            msg.sender,
                            owner,
                            (adrToInfo[msg.sender].payment * 90) / 100
                        );
                        totalMoney[owner] +=
                            (adrToInfo[msg.sender].payment * 90) /
                            100;
                    } else {
                        token.transferFrom(
                            msg.sender,
                            owner,
                            adrToInfo[msg.sender].payment
                        );
                        totalMoney[owner] += adrToInfo[msg.sender].payment;
                    }
                } else {
                    token.transferFrom(
                        msg.sender,
                        owner,
                        adrToInfo[msg.sender].payment
                    );
                    totalMoney[owner] += adrToInfo[msg.sender].payment;
                }

                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leaderPaid = true;

                isRefAvailable[msg.sender] = true;
                break;
            } else if (
                levlToIdToTable[1][i].userCount < 3 &&
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

                //-------------------------------------

                adrToInfo[msg.sender].idInTable = levlToIdToTable[1][i]
                    .userCount;

                //-------------------------------------
                adrToInfo[msg.sender].timest = time;
                adrToInfo[msg.sender].level = 1;
                adrToInfo[msg.sender].tableId = i;
                adrToInfo[msg.sender].payment = levlToPayment[1];
                referals[msg.sender] = ref;
                //adrToTables[msg.sender].push(minTable(1, i));
                /*token.transferFrom(
                    msg.sender,
                    levlToIdToTable[1][i].leader,
                    (levlToPayment[1] * 95) / 100
                );
                token.transferFrom(
                    msg.sender,
                    owner,
                    (levlToPayment[1] * 5) / 100
                );*/

                if (referals[msg.sender] != address(0)) {
                    if (
                        adrToInfo[referals[msg.sender]].level >=
                        adrToInfo[msg.sender].level &&
                        isRefAvailable[referals[msg.sender]]
                    ) {
                        token.transferFrom(
                            msg.sender,
                            referals[msg.sender],
                            (adrToInfo[msg.sender].payment * 10) / 100
                        );
                        moneyFromReferals[referals[msg.sender]] +=
                            (adrToInfo[msg.sender].payment * 10) /
                            100;
                        totalMoney[referals[msg.sender]] +=
                            (adrToInfo[msg.sender].payment * 10) /
                            100;
                        token.transferFrom(
                            msg.sender,
                            owner,
                            (adrToInfo[msg.sender].payment * 5) / 100
                        );
                        totalMoney[owner] +=
                            (adrToInfo[msg.sender].payment * 5) /
                            100;
                        token.transferFrom(
                            msg.sender,
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader,
                            (adrToInfo[msg.sender].payment * 85) / 100
                        );
                        totalMoney[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ] += (adrToInfo[msg.sender].payment * 85) / 100;
                    } else {
                        token.transferFrom(
                            msg.sender,
                            owner,
                            (adrToInfo[msg.sender].payment * 15) / 100
                        );
                        totalMoney[owner] +=
                            (adrToInfo[msg.sender].payment * 15) /
                            100;

                        token.transferFrom(
                            msg.sender,
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader,
                            (adrToInfo[msg.sender].payment * 85) / 100
                        );
                        totalMoney[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ] += (adrToInfo[msg.sender].payment * 85) / 100;
                    }
                } else {
                    token.transferFrom(
                        msg.sender,
                        owner,
                        (adrToInfo[msg.sender].payment * 15) / 100
                    );
                    totalMoney[owner] +=
                        (adrToInfo[msg.sender].payment * 15) /
                        100;

                    token.transferFrom(
                        msg.sender,
                        levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader,
                        (adrToInfo[msg.sender].payment * 85) / 100
                    );
                    totalMoney[
                        levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader
                    ] += (adrToInfo[msg.sender].payment * 85) / 100;
                }

                levlToIdToTable[1][i].isPaid[
                    adrToInfo[msg.sender].idInTable
                ] = true;

                if (levlToIdToTable[1][i].userCount == 3) {
                    levlToIdToTable[1][i].isPaidAll = true;
                    closeTable();
                }

                isRefAvailable[msg.sender] = true;

                break;
            }
        }
    }

    function nextLevel() external {
        require(
            block.timestamp <= adrToInfo[msg.sender].timest + deadline,
            "you're late"
        );
        /*require(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leaderPaid == false,
            "already paid"
        );*/
        require(adrToInfo[msg.sender].level != 1, "already paid");
        require(
            isInQueue[msg.sender][adrToInfo[msg.sender].level] == true,
            "address is not in queue"
        );

        isRefAvailable[msg.sender] = true;

        /*token.transferFrom(msg.sender, owner, adrToInfo[msg.sender].payment);*/

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

                if (referals[msg.sender] != msg.sender) {
                    if (
                        adrToInfo[referals[msg.sender]].level >=
                        adrToInfo[msg.sender].level &&
                        isRefAvailable[referals[msg.sender]]
                    ) {
                        token.transferFrom(
                            msg.sender,
                            referals[msg.sender],
                            (adrToInfo[msg.sender].payment * 10) / 100
                        );
                        totalMoney[referals[msg.sender]] +=
                            (adrToInfo[msg.sender].payment * 10) /
                            100;
                        moneyFromReferals[referals[msg.sender]] +=
                            (adrToInfo[msg.sender].payment * 10) /
                            100;
                        token.transferFrom(
                            msg.sender,
                            owner,
                            (adrToInfo[msg.sender].payment * 90) / 100
                        );
                        totalMoney[owner] +=
                            (adrToInfo[msg.sender].payment * 90) /
                            100;
                    } else {
                        token.transferFrom(
                            msg.sender,
                            owner,
                            adrToInfo[msg.sender].payment
                        );
                        totalMoney[owner] += adrToInfo[msg.sender].payment;
                    }
                } else {
                    token.transferFrom(
                        msg.sender,
                        owner,
                        adrToInfo[msg.sender].payment
                    );
                    totalMoney[owner] += adrToInfo[msg.sender].payment;
                }

                levlToIdToTable[adrToInfo[msg.sender].level][i].leader = msg
                    .sender; // лидер
                levlToIdToTable[adrToInfo[msg.sender].level][i]
                    .tableId = levlToAmount[adrToInfo[msg.sender].level]; // айди стола
                isParticipated[msg.sender] = true; // участвовал

                adrToInfo[msg.sender].level = adrToInfo[msg.sender].level; // уровень
                adrToInfo[msg.sender].tableId = levlToAmount[
                    adrToInfo[msg.sender].level
                ]; // айди стола

                adrToInfo[msg.sender].payment = levlToPayment[
                    adrToInfo[msg.sender].level
                ];

                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leaderPaid = true;

                break;
            } else if (
                levlToIdToTable[adrToInfo[msg.sender].level][i].userCount != 3 // отправляем лидера учатником на след уровень, если стол не забит
            ) {
                levlToIdToTable[adrToInfo[msg.sender].level][i].userCount++;
                // добавляет юзера
                levlToIdToTable[adrToInfo[msg.sender].level][i].users[
                    levlToIdToTable[adrToInfo[msg.sender].level][i].userCount
                ] = msg.sender;

                //участвует
                isParticipated[msg.sender] = true;

                //время в стол
                levlToIdToTable[adrToInfo[msg.sender].level][i].time[
                        levlToIdToTable[adrToInfo[msg.sender].level][i]
                            .userCount
                    ] = adrToInfo[msg.sender].timest;

                //айди в столе participant
                adrToInfo[msg.sender].idInTable = levlToIdToTable[
                    adrToInfo[msg.sender].level
                ][i].userCount;
                //время participant

                //уровень participant
                adrToInfo[msg.sender].level = adrToInfo[msg.sender].level;
                //айди стола participant
                adrToInfo[msg.sender].tableId = i;
                // оплата participant
                adrToInfo[msg.sender].payment = levlToPayment[
                    adrToInfo[msg.sender].level
                ];
                payToLeader();
                break;
            } /*else if (
                levlToIdToTable[adrToInfo[msg.sender].level][i].isPaidAll ==
                false // Если у участников на след уровне закончился дедлайн, то вместо них отправляем лидера
            ) {
                for (uint256 j = 1; j < 4; j++) {
                    if (
                        (block.timestamp >
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .time[j] +
                                deadline) &&
                        (levlToIdToTable[adrToInfo[msg.sender].level][i].isPaid[
                            j - 1
                        ] == false)
                    ) {
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .users[j]
                        ].idInTable = 0;

                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .users[j]
                        ].timest = 0;

                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .users[j]
                        ].payment = 0;

                        // уровень
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .users[j]
                        ].level = 0;
                        //айди стола
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .users[j]
                        ].tableId = 0;
                        //участие
                        isParticipated[
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .users[j]
                        ] = false;

                        isRefAvailable[
                            levlToIdToTable[adrToInfo[msg.sender].level][i]
                                .users[j]
                        ] = false;

                        levlToIdToTable[adrToInfo[msg.sender].level][i].users[
                                j
                            ] = levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader;

                        isParticipated[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ] = true;

                        uint256 time = block.timestamp;
                        levlToIdToTable[adrToInfo[msg.sender].level][i].time[
                                j
                            ] = time;

                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ].idInTable = j;
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ].timest = time;
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ].level = adrToInfo[msg.sender].level;
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ].tableId = i;
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ].payment = levlToPayment[adrToInfo[msg.sender].level];
                        i = levlToAmount[adrToInfo[msg.sender].level] + 2;
                        break;
                    }
                }
            }*/
        }
    }

    function payToLeader() internal {
        //require(amount >= adrToInfo[msg.sender].payment);
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

        /*token.transferFrom(
            msg.sender,
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader,
            (adrToInfo[msg.sender].payment * 95) / 100
        );
        token.transferFrom(
            msg.sender,
            owner,
            (adrToInfo[msg.sender].payment * 5) / 100
        );*/

        isRefAvailable[msg.sender] = true;

        if (referals[msg.sender] != msg.sender) {
            if (
                adrToInfo[referals[msg.sender]].level >=
                adrToInfo[msg.sender].level &&
                isRefAvailable[referals[msg.sender]]
            ) {
                token.transferFrom(
                    msg.sender,
                    referals[msg.sender],
                    (adrToInfo[msg.sender].payment * 10) / 100
                );
                totalMoney[referals[msg.sender]] +=
                    (adrToInfo[msg.sender].payment * 10) /
                    100;
                moneyFromReferals[referals[msg.sender]] +=
                    (adrToInfo[msg.sender].payment * 10) /
                    100;
                token.transferFrom(
                    msg.sender,
                    owner,
                    (adrToInfo[msg.sender].payment * 5) / 100
                );
                totalMoney[owner] += (adrToInfo[msg.sender].payment * 5) / 100;
                token.transferFrom(
                    msg.sender,
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader,
                    (adrToInfo[msg.sender].payment * 85) / 100
                );
                totalMoney[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ] += (adrToInfo[msg.sender].payment * 85) / 100;
            } else {
                token.transferFrom(
                    msg.sender,
                    owner,
                    (adrToInfo[msg.sender].payment * 15) / 100
                );
                totalMoney[owner] += (adrToInfo[msg.sender].payment * 15) / 100;
                token.transferFrom(
                    msg.sender,
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader,
                    (adrToInfo[msg.sender].payment * 85) / 100
                );
                totalMoney[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ] += (adrToInfo[msg.sender].payment * 85) / 100;
            }
        } else {
            token.transferFrom(
                msg.sender,
                owner,
                adrToInfo[msg.sender].payment
            );
            totalMoney[owner] += adrToInfo[msg.sender].payment;
        }

        levlToIdToTable[adrToInfo[msg.sender].level][
            adrToInfo[msg.sender].tableId
        ].isPaid[adrToInfo[msg.sender].idInTable] = true;
        uint256 count;
        for (uint256 i = 1; i < 4; i++) {
            if (
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].isPaid[i] == true
            ) {
                count++;
            }
        }
        if (count == 3) {
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].isPaidAll = true;
            closeTable();
        }
    }

    function closeTable() internal {
        for (uint256 i = 1; i < 11; i++) {
            if (idWinnerToInfo[i].user == address(0x0)) {
                idWinnerToInfo[i].user = levlToIdToTable[
                    adrToInfo[msg.sender].level
                ][adrToInfo[msg.sender].tableId].leader;
                idWinnerToInfo[i].time = block.timestamp;
                idWinnerToInfo[i].tableId = adrToInfo[msg.sender].tableId;
                idWinnerToInfo[i].money =
                    (levlToPayment[adrToInfo[msg.sender].level] * 3 * 85) /
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
                    (levlToPayment[adrToInfo[msg.sender].level] * 3 * 85) /
                    100;
            }
        }

        emit tableClosed(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader,
            (levlToPayment[adrToInfo[msg.sender].level] * 3 * 85) / 100,
            adrToInfo[msg.sender].level,
            adrToInfo[msg.sender].tableId
        );

        if (adrToInfo[msg.sender].level == 5) {
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

            isRefAvailable[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ] = false;
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

        uint256 startLvl = levlToAmount[adrToInfo[msg.sender].level];

        for (uint256 i = 1; i < 4; i++) {
            adrToTables[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].users[i]
            ].push(
                    minTable(
                        adrToInfo[msg.sender].level,
                        adrToInfo[msg.sender].tableId
                    )
                );

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

            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][startLvl].users[i]
            ].tableId = levlToAmount[adrToInfo[msg.sender].level];

            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][startLvl].users[i]
            ].payment = levlToPayment[adrToInfo[msg.sender].level];

            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][startLvl].users[i]
            ].timest = block.timestamp;
        }
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
            uint256,
            uint256
        )
    {
        uint256 lost = 0;
        if (block.timestamp > adrToInfo[msg.sender].timest + deadline) {
            lost = (levlToPayment[adrToInfo[user].level] * 3 * 85) / 100;
        }
        return (
            adrToInfo[user].playerId,
            totalMoney[user],
            lost,
            moneyFromReferals[user],
            adrToInfo[msg.sender].startingTime
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
            uint256
        )
    {
        return (
            adrToTables[user],
            adrToInfo[msg.sender].level,
            adrToInfo[msg.sender].tableId
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
}

pragma solidity ^0.8.13;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}