pragma solidity ^0.8.13;

import "./IBEP20.sol";

contract GoodGame {
    IBEP20 private immutable token;

    mapping(address => bool) isParticipated;
    mapping(address => Participant) adrToInfo;
    mapping(uint256 => uint256) levlToPayment;

    struct Participant {
        uint256 level;
        uint256 tableId;
        uint256 payment;
        uint256 timest;
        uint256 idInTable;
    }

    mapping(uint256 => mapping(uint256 => Table)) levlToIdToTable;

    mapping(uint256 => uint256) levlToAmount;

    uint256 deadline;

    address public owner;

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

        //deadline = 1 days;
        deadline = 10 minutes;
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

    // Участвовать в первый раз или когда время вышло.

    function participate() external {
        isTimeIsOver(msg.sender);

        require(isParticipated[msg.sender] == false, "Already participated");
        for (uint256 i = 1; i <= levlToAmount[1] + 1; i++) {
            if (
                (levlToIdToTable[1][i].leader == address(0)) ||
                (block.timestamp >
                    adrToInfo[levlToIdToTable[1][i].leader].timest + deadline)
            ) {
                if (levlToIdToTable[1][i].leader == address(0)) {
                    levlToAmount[1]++;
                }

                levlToIdToTable[1][i].leader = msg.sender;
                levlToIdToTable[1][i].tableId = levlToAmount[1];
                isParticipated[msg.sender] = true;
                uint256 time = block.timestamp;

                adrToInfo[msg.sender].timest = time;
                adrToInfo[msg.sender].level = 1;
                adrToInfo[msg.sender].tableId = levlToAmount[1];
                adrToInfo[msg.sender].payment = levlToPayment[1];
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

                adrToInfo[msg.sender].idInTable =
                    levlToIdToTable[1][i].userCount -
                    1;
                adrToInfo[msg.sender].timest = time;
                adrToInfo[msg.sender].level = 1;
                adrToInfo[msg.sender].tableId = levlToAmount[1];
                adrToInfo[msg.sender].payment = levlToPayment[1];
                break;
            } else if (
                levlToIdToTable[1][i].isPaidAll == false &&
                levlToIdToTable[1][i].leaderPaid
            ) {
                for (uint256 j = 1; j < 7; j++) {
                    if (
                        (block.timestamp >
                            levlToIdToTable[1][i].time[j] + deadline) &&
                        (levlToIdToTable[1][i].isPaid[j] == false)
                    ) {
                        adrToInfo[levlToIdToTable[1][i].users[j]].level = 0;
                        adrToInfo[levlToIdToTable[1][i].users[j]].tableId = 0;
                        isParticipated[levlToIdToTable[1][i].users[j]] = false;
                        adrToInfo[levlToIdToTable[1][i].users[j]].payment = 0;
                        adrToInfo[levlToIdToTable[1][i].users[j]].timest = 0;
                        adrToInfo[levlToIdToTable[1][i].users[j]].idInTable = 0;

                        levlToIdToTable[1][i].users[j] = msg.sender;
                        isParticipated[msg.sender] = true;
                        uint256 time = block.timestamp;
                        levlToIdToTable[1][i].time[j] = time;

                        adrToInfo[msg.sender].idInTable = j;
                        adrToInfo[msg.sender].timest = time;
                        adrToInfo[msg.sender].level = 1;
                        adrToInfo[msg.sender].tableId = levlToAmount[1];
                        adrToInfo[msg.sender].payment = levlToPayment[1];
                        i = levlToAmount[1] + 2;

                        break;
                    }
                }
            }
        }
    }

    function isTimeIsOver(address user) internal {
        if (isParticipated[user]) {
            for (
                uint256 i = 1;
                i <
                levlToIdToTable[adrToInfo[user].level][adrToInfo[user].tableId]
                    .users
                    .length;
                i++
            ) {
                if (
                    levlToIdToTable[adrToInfo[user].level][
                        adrToInfo[user].tableId
                    ].users[i] == user
                ) {
                    if (
                        levlToIdToTable[adrToInfo[user].level][
                            adrToInfo[user].tableId
                        ].isPaid[i] == false
                    ) {
                        if (
                            block.timestamp >
                            levlToIdToTable[adrToInfo[user].level][
                                adrToInfo[user].tableId
                            ].time[i] +
                                deadline
                        ) {
                            isParticipated[user] = false;
                        }
                    }
                }
            }
        }
    }

    function payToAdmin() external {
        require(block.timestamp <= adrToInfo[msg.sender].timest + deadline);
        require(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leaderPaid == false
        );
        require(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].leader == msg.sender
        );

        token.transferFrom(msg.sender, owner, adrToInfo[msg.sender].payment);
        levlToIdToTable[adrToInfo[msg.sender].level][
            adrToInfo[msg.sender].tableId
        ].leaderPaid = true;
    }

    function payToLeader() external {
        //require(amount >= adrToInfo[msg.sender].payment);
        require(block.timestamp <= adrToInfo[msg.sender].timest + deadline);
        require(
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].isPaid[adrToInfo[msg.sender].idInTable] == false
        );

        token.transferFrom(
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
        for (
            uint256 i = 1;
            i <= levlToAmount[adrToInfo[msg.sender].level + 1] + 1;
            i++
        ) {
            if (
                levlToIdToTable[adrToInfo[msg.sender].level + 1][i].leader ==
                address(0) ||
                (block.timestamp >
                    adrToInfo[levlToIdToTable[1][i].leader].timest + deadline)
            ) {
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
                    if (levlToIdToTable[1][i].leader == address(0)) {
                        levlToAmount[adrToInfo[msg.sender].level + 1]++;
                    }

                    levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                        .leader = levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader;
                    levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                        .tableId = levlToAmount[
                        adrToInfo[msg.sender].level + 1
                    ];
                    isParticipated[
                        levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader
                    ] = true;

                    adrToInfo[
                        levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader
                    ].level = adrToInfo[msg.sender].level + 1;
                    adrToInfo[
                        levlToIdToTable[adrToInfo[msg.sender].level][
                            adrToInfo[msg.sender].tableId
                        ].leader
                    ].tableId = i;
                    break;
                }
            } else if (
                levlToIdToTable[adrToInfo[msg.sender].level + 1][i].userCount !=
                6 &&
                levlToIdToTable[1][i].leaderPaid
            ) {
                levlToIdToTable[adrToInfo[msg.sender].level + 1][i].userCount++;
                levlToIdToTable[adrToInfo[msg.sender].level + 1][i].users[
                        levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                            .userCount
                    ] = levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader;

                isParticipated[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ] = true;
                uint256 time = block.timestamp;
                levlToIdToTable[adrToInfo[msg.sender].level + 1][i].time[
                        levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                            .userCount
                    ] = time;

                adrToInfo[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ].idInTable =
                    levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                        .userCount -
                    1;
                adrToInfo[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ].timest = time;
                adrToInfo[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ].level = adrToInfo[msg.sender].level + 1;
                adrToInfo[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ].tableId = i;
                adrToInfo[
                    levlToIdToTable[adrToInfo[msg.sender].level][
                        adrToInfo[msg.sender].tableId
                    ].leader
                ].payment = levlToPayment[adrToInfo[msg.sender].level + 1]; //пофиксить оплату для каждого уровня
                break;
            } else if (
                levlToIdToTable[adrToInfo[msg.sender].level + 1][i].isPaidAll ==
                false &&
                levlToIdToTable[1][i].leaderPaid
            ) {
                for (uint256 j = 1; j < 7; j++) {
                    if (
                        (block.timestamp >
                            levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                                .time[j] +
                                deadline) &&
                        (levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                            .isPaid[j] == false)
                    ) {
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                                .users[j]
                        ].level = 0;
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                                .users[j]
                        ].tableId = 0;
                        isParticipated[
                            levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                                .users[j]
                        ] = false;

                        levlToIdToTable[adrToInfo[msg.sender].level + 1][i]
                            .users[j] = levlToIdToTable[
                            adrToInfo[msg.sender].level
                        ][adrToInfo[msg.sender].tableId].leader;
                        isParticipated[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ] = true;
                        uint256 time = block.timestamp;
                        levlToIdToTable[1][i].time[j] = time;

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
                        ].level = adrToInfo[msg.sender].level + 1;
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ].tableId = i;
                        adrToInfo[
                            levlToIdToTable[adrToInfo[msg.sender].level][
                                adrToInfo[msg.sender].tableId
                            ].leader
                        ].payment = levlToPayment[
                            adrToInfo[msg.sender].level + 1
                        ];
                        i = levlToAmount[adrToInfo[msg.sender].level + 1] + 2;
                        break;
                    }
                }
            }
        }

        for (
            uint256 i = 1;
            i <
            levlToIdToTable[adrToInfo[msg.sender].level][
                adrToInfo[msg.sender].tableId
            ].userCount;
            i++
        ) {
            levlToAmount[adrToInfo[msg.sender].level]++;
            levlToIdToTable[adrToInfo[msg.sender].level][
                levlToAmount[adrToInfo[msg.sender].level] + 1
            ].leader = levlToIdToTable[adrToInfo[msg.sender].level][
                levlToAmount[adrToInfo[msg.sender].level]
            ].users[i];
            levlToIdToTable[adrToInfo[msg.sender].level][
                levlToAmount[adrToInfo[msg.sender].level] + 1
            ].tableId = levlToAmount[adrToInfo[msg.sender].level];
            isParticipated[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    adrToInfo[msg.sender].tableId
                ].leader
            ] = true;

            //adrToInfo[levlToIdToTable[adrToInfo[msg.sender].level][adrToInfo[msg.sender].tableId].leader].level = adrToInfo[msg.sender].level;
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    levlToAmount[adrToInfo[msg.sender].level]
                ].users[i]
            ].tableId = levlToAmount[adrToInfo[msg.sender].level];
            adrToInfo[
                levlToIdToTable[adrToInfo[msg.sender].level][
                    levlToAmount[adrToInfo[msg.sender].level]
                ].users[i]
            ].payment = levlToPayment[adrToInfo[msg.sender].level + 1];
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
        require(msg.sender == owner, "Not owner");
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

    function changeOwner(address adr) external {
        require(msg.sender == owner, "Not owner");
        owner = adr;
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