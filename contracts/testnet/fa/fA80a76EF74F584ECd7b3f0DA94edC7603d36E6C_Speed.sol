pragma solidity ^0.8.4;

import "./IBEP20.sol";

contract Speed {
    IBEP20 private immutable token;

    mapping(address => bool) isParticipated;
    mapping(address => Participant) adrToInfo;
    uint256 public usersAmount = 5500;
    uint256 levlToPayment;

    mapping(address => address) referals;
    mapping(address => bool) isRefAvailable;

    mapping(address => uint256) moneyFromReferals;
    mapping(address => uint256) totalMoney;

    mapping(uint256 => uint256) curTabId;

    mapping(address => minTable[]) adrToTables;

    mapping(uint256 => Table) IdToTable;
    mapping(address => bool) adrToEverParticipated;

    uint256 levlToAmount;

    struct minTable {
        uint256 id;
    }

    struct Participant {
        uint256 playerId;
        uint256 tableId;
        uint256 timest;
        uint256 idInTable;
        uint256 startingTime;
    }

    uint256 refFee;
    uint256 adminFee;

    mapping(uint256 => winner) idWinnerToInfo;
    mapping(uint256 => trans) idTransToInfo;
    mapping(address => uint256) adrToLostMoney;

    struct winner {
        address user;
        uint256 tableId;
        uint256 time;
        uint256 money;
    }

    struct trans {
        uint256 tableId;
        address user;
        uint256 time;
        uint256 money;
    }

    uint256 deadline;

    address public owner;

    bool public isActive;

    event tableClosed(address leader_, uint256 money_, uint256 tableId_);

    event newParticipant(
        uint256 tableId,
        address tableLeader,
        uint256 updatedLeaderMoney,
        address ref
    );

    event losingMoney(address user, uint256 money);

    constructor(address busdAddress, address owner_) {
        require(busdAddress != address(0x0));
        token = IBEP20(busdAddress);
        owner = owner_;

        levlToPayment = 20 * 10**18;

        deadline = 1 days;
        isActive = true;
    }

    struct Table {
        address leader;
        bool leaderPaid;
        address[3] users;
        uint256 tableId;
        uint256 userCount;
        bool[3] isPaid;
        bool isPaidAll;
        uint256[3] time;
    }

    function participate(address ref) external {
        require(isActive, "Game is not active yet");

        usersAmount++;
        adrToInfo[msg.sender].playerId = usersAmount;

        adrToInfo[msg.sender].startingTime = block.timestamp;

        if (
            (block.timestamp > adrToInfo[msg.sender].timest + deadline) &&
            adrToInfo[msg.sender].timest != 0
        ) {
            isParticipated[msg.sender] = false;
        }
        require(isParticipated[msg.sender] == false, "Already participated");
        for (uint256 i = 1; i <= levlToAmount + 1; i++) {
            if ((IdToTable[i].leader == address(0x0))) {
                levlToAmount++;

                IdToTable[i].leader = msg.sender;
                IdToTable[i].tableId = i;
                isParticipated[msg.sender] = true;
                uint256 time = block.timestamp;

                adrToEverParticipated[msg.sender] = true;

                adrToInfo[msg.sender].timest = time;

                adrToInfo[msg.sender].tableId = i;

                referals[msg.sender] = ref;

                if (
                    referals[msg.sender] != msg.sender ||
                    adrToEverParticipated[ref] == false
                ) {
                    token.transferFrom(
                        msg.sender,
                        referals[msg.sender],
                        (levlToPayment * refFee) / 100
                    );
                    moneyFromReferals[referals[msg.sender]] +=
                        (levlToPayment * refFee) /
                        100;
                    totalMoney[referals[msg.sender]] +=
                        (levlToPayment * refFee) /
                        100;

                    token.transferFrom(
                        msg.sender,
                        owner,
                        (levlToPayment * (100 - refFee)) / 100
                    );
                    totalMoney[owner] += (levlToPayment * (100 - refFee)) / 100;
                } else {
                    if (referals[msg.sender] != msg.sender) {
                        adrToLostMoney[ref] += (levlToPayment * refFee) / 100;
                    }
                    token.transferFrom(msg.sender, owner, levlToPayment);
                    totalMoney[owner] += levlToPayment;
                }

                IdToTable[adrToInfo[msg.sender].tableId].leaderPaid = true;

                isRefAvailable[msg.sender] = true;
                break;
            } else if (IdToTable[i].userCount < 2 && IdToTable[i].leaderPaid) {
                adrToEverParticipated[msg.sender] = true;
                IdToTable[i].userCount++;
                IdToTable[i].users[IdToTable[i].userCount] = msg.sender;

                isParticipated[msg.sender] = true;
                uint256 time = block.timestamp;
                IdToTable[i].time[IdToTable[i].userCount] = time;

                adrToInfo[msg.sender].idInTable = IdToTable[i].userCount;

                adrToInfo[msg.sender].timest = time;

                adrToInfo[msg.sender].tableId = i;

                referals[msg.sender] = ref;

                curTabId[1] = i;

                if (
                    referals[msg.sender] != msg.sender ||
                    adrToEverParticipated[ref] == false
                ) {
                    //ref
                    token.transferFrom(
                        msg.sender,
                        referals[msg.sender],
                        (levlToPayment * refFee) / 100
                    );
                    moneyFromReferals[referals[msg.sender]] +=
                        (levlToPayment * refFee) /
                        100;
                    totalMoney[referals[msg.sender]] +=
                        (levlToPayment * refFee) /
                        100;
                    //admin
                    token.transferFrom(
                        msg.sender,
                        owner,
                        (levlToPayment * adminFee) / 100
                    );
                    totalMoney[owner] += (levlToPayment * adminFee) / 100;
                    //leader
                    token.transferFrom(
                        msg.sender,
                        IdToTable[adrToInfo[msg.sender].tableId].leader,
                        (levlToPayment * (100 - refFee - adminFee)) / 100
                    );
                    totalMoney[
                        IdToTable[adrToInfo[msg.sender].tableId].leader
                    ] += (levlToPayment * 100 - refFee - adminFee) / 100;
                } else {
                    if (referals[msg.sender] != msg.sender) {
                        adrToLostMoney[ref] += (levlToPayment * refFee) / 100;
                    }
                    token.transferFrom(
                        msg.sender,
                        owner,
                        (levlToPayment * (adminFee + refFee)) / 100
                    );
                    totalMoney[owner] +=
                        (levlToPayment * (adminFee + refFee)) /
                        100;

                    token.transferFrom(
                        msg.sender,
                        IdToTable[adrToInfo[msg.sender].tableId].leader,
                        (levlToPayment * (100 - (adminFee + refFee))) / 100
                    );
                    totalMoney[
                        IdToTable[adrToInfo[msg.sender].tableId].leader
                    ] += (levlToPayment * (100 - (adminFee + refFee))) / 100;
                }

                for (uint256 l = 1; l < 16; l++) {
                    if (idTransToInfo[l].user == address(0x0)) {
                        idTransToInfo[l].user = IdToTable[
                            adrToInfo[msg.sender].tableId
                        ].leader;
                        idTransToInfo[l].time = block.timestamp;
                        idTransToInfo[l].tableId = adrToInfo[msg.sender]
                            .tableId;

                        idTransToInfo[l].money =
                            (levlToPayment * (100 - (adminFee + refFee))) /
                            100;
                        break;
                    }

                    if (l == 15) {
                        for (uint256 j = 1; j < 15; j++) {
                            idTransToInfo[j].user = idTransToInfo[j + 1].user;
                            idTransToInfo[j].time = idTransToInfo[j + 1].time;
                            idTransToInfo[j].tableId = idTransToInfo[j + 1]
                                .tableId;

                            idTransToInfo[j].money = idTransToInfo[j + 1].money;
                        }
                        idTransToInfo[15].user = IdToTable[
                            adrToInfo[msg.sender].tableId
                        ].leader;
                        idTransToInfo[15].time = block.timestamp;
                        idTransToInfo[15].tableId = adrToInfo[msg.sender]
                            .tableId;

                        idTransToInfo[15].money =
                            (levlToPayment * (100 - (adminFee + refFee))) /
                            100;
                    }
                }

                emit newParticipant(
                    adrToInfo[msg.sender].tableId,
                    IdToTable[adrToInfo[msg.sender].tableId].leader,
                    totalMoney[IdToTable[adrToInfo[msg.sender].tableId].leader],
                    referals[msg.sender]
                );

                IdToTable[i].isPaid[adrToInfo[msg.sender].idInTable] = true;

                if (IdToTable[i].userCount == 2) {
                    IdToTable[i].isPaidAll = true;
                    closeTable();
                }

                isRefAvailable[msg.sender] = true;

                break;
            }
        }
    }

    function closeTable() internal {
        for (uint256 i = 1; i < 11; i++) {
            if (idWinnerToInfo[i].user == address(0x0)) {
                idWinnerToInfo[i].user = IdToTable[
                    adrToInfo[msg.sender].tableId
                ].leader;
                idWinnerToInfo[i].time = block.timestamp;
                idWinnerToInfo[i].tableId = adrToInfo[msg.sender].tableId;
                idWinnerToInfo[i].money =
                    (levlToPayment * 3 * (100 - (adminFee + refFee))) /
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
                idWinnerToInfo[10].user = IdToTable[
                    adrToInfo[msg.sender].tableId
                ].leader;
                idWinnerToInfo[10].time = block.timestamp;
                idWinnerToInfo[10].tableId = adrToInfo[msg.sender].tableId;
                idWinnerToInfo[10].money =
                    (levlToPayment * 3 * (100 - (adminFee + refFee))) /
                    100;
            }
        }

        emit tableClosed(
            IdToTable[adrToInfo[msg.sender].tableId].leader,
            (levlToPayment * 3 * (100 - (adminFee + refFee))) / 100,
            adrToInfo[msg.sender].tableId
        );

        isParticipated[IdToTable[adrToInfo[msg.sender].tableId].leader] ==
            false;
        adrToInfo[IdToTable[adrToInfo[msg.sender].tableId].leader].tableId = 0;
        adrToInfo[IdToTable[adrToInfo[msg.sender].tableId].leader].timest = 0;
        adrToInfo[IdToTable[adrToInfo[msg.sender].tableId].leader]
            .idInTable = 0;

        isRefAvailable[IdToTable[adrToInfo[msg.sender].tableId].leader] = false;

        for (uint256 i = 1; i < 3; i++) {
            address curUser = IdToTable[adrToInfo[msg.sender].tableId].users[i];

            levlToAmount++;
            IdToTable[levlToAmount].leader = curUser;

            IdToTable[levlToAmount].tableId = levlToAmount;

            IdToTable[levlToAmount].leaderPaid = true;

            isParticipated[
                IdToTable[adrToInfo[msg.sender].tableId].leader
            ] = true;

            adrToInfo[curUser].tableId = levlToAmount;

            adrToInfo[curUser].timest = block.timestamp;
        }
    }

    function checkMyData(address user)
        external
        view
        returns (Participant memory)
    {
        return adrToInfo[user];
    }

    function tableAmount() external view returns (uint256) {
        return levlToAmount;
    }

    function tableInfo(uint256 tableId) public view returns (Table memory) {
        return IdToTable[tableId];
    }

    function myTableInfo(address user)
        external
        view
        returns (
            address leader,
            uint256 idOfTable,
            uint256 countOfUsers,
            uint256 myStartingTime,
            bool isAllPaid,
            Table memory
        )
    {
        return (
            IdToTable[adrToInfo[user].tableId].leader,
            adrToInfo[user].tableId,
            IdToTable[adrToInfo[user].tableId].userCount,
            adrToInfo[user].timest,
            IdToTable[adrToInfo[user].tableId].isPaidAll,
            tableInfo(adrToInfo[user].tableId)
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
        return (
            adrToInfo[user].playerId,
            totalMoney[user],
            adrToLostMoney[user],
            moneyFromReferals[user],
            adrToInfo[user].startingTime
        );
    }

    function changeActiveStatus() external {
        require(owner == msg.sender, "Not owner");
        isActive = !isActive;
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
            adrToInfo[user].tableId,
            adrToInfo[user].tableId - curTabId[1]
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