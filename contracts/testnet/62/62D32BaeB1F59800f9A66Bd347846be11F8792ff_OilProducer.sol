/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File contracts/OilPump.sol

pragma solidity ^0.8.4;

contract OilProducer is ReentrancyGuard {
    // settings
    uint256 public developersPercent;
    uint256 public marketingPercent;
    uint256 public lotteryPercent;
    uint256 public ownerPercent;
    uint256 public refPercent;
    uint256 public pumpCost;
    uint256 public pumpProfitPerDay;
    uint256 public scStartDay;
    uint256 public lotteryPrizePool;
    address public owner;
    address public refDefault;
    address public marketingWallet;

    //tools
    uint256 lastDaylyIncomeTime;
    uint256 lastLotterSpinTime;
    uint256 amountOfUsers;
    uint256 amountOfPumps;
    uint256 contractTVL;
    uint256 public periodOfIncome;
    uint256 public periodOfLottery;
    address pointerForLinking;
    uint256 amountOfUsersInCurrentLottery;

    /*struct of user. It helps to track pumps, balance, refs amount. */
    struct User {
        uint256 obtainedPumps; //Pumps that in game
        uint256 pumpToAddDuringNextIncome; //Pumps would be in game after next claim
        uint256 freeBalance; //Balance, that could be spend on pumps or withdrawed
        uint256 amountOfRefs; //amount of refs to participate in lottery
        uint256 totalEarnedMoney;
        address ref; //Ref of this person
        address nextOne; //Link to next user
        bool isRegistred;
    }

    mapping(address => User) addrToUser; // main mapping

    mapping(uint256 => address[]) public winners;

    event newRef(address addr, uint256 hisRefs);

    event newPlaceFormed(
        address[] winners,
        uint256 numberOfWinners,
        uint256 place
    );

    constructor(
        address[3] memory _wallets,
        uint256 _developersPercent,
        uint256 _marketingPercent,
        uint256 _ownerPercent,
        uint256 _lotteryPercent,
        uint256 _refPercent,
        uint256 _pumpCost,
        uint256 _pumpProfitPerDay,
        uint256[3] memory _times
    ) {
        developersPercent = _developersPercent;
        marketingPercent = _marketingPercent;
        lotteryPercent = _lotteryPercent;
        refPercent = _refPercent;
        pumpCost = _pumpCost;
        pumpProfitPerDay = _pumpProfitPerDay;
        scStartDay = _times[0];
        owner = _wallets[0];
        ownerPercent = _ownerPercent;
        refDefault = _wallets[1];
        marketingWallet = _wallets[2];

        lastDaylyIncomeTime = _times[0];
        lastLotterSpinTime = _times[0];
        pointerForLinking = _wallets[0];
        periodOfIncome = _times[1];
        periodOfLottery = _times[2];
        addrToUser[_wallets[0]].isRegistred = true;
    }

    function BuyPump(address _ref) public payable {
        require(block.timestamp > scStartDay, "Not time yet");
        require(msg.value % pumpCost == 0, "Wrong amount of money");
        if (addrToUser[msg.sender].ref == address(0)) {
            amountOfUsers++;
            if (_ref == address(0) || _ref == msg.sender) {
                addrToUser[msg.sender].ref = refDefault;
            } else {
                addrToUser[msg.sender].ref = _ref;
                if (addrToUser[_ref].amountOfRefs == 0) {
                    amountOfUsersInCurrentLottery++;
                }
                addrToUser[_ref].amountOfRefs++;
                if (!addrToUser[_ref].isRegistred) {
                    addrToUser[pointerForLinking].nextOne = _ref;
                    pointerForLinking = _ref;
                    addrToUser[_ref].isRegistred = true;
                }
                emit newRef(_ref, addrToUser[_ref].amountOfRefs);
                //recount
                //_refArrayRecount(_ref);
            }
            addrToUser[msg.sender].isRegistred = true;

            addrToUser[pointerForLinking].nextOne = msg.sender;
            pointerForLinking = msg.sender;
        }

        uint256 pumpsToBuy = ((msg.value * 10) / (pumpCost * 10));

        _pay(msg.value);

        addrToUser[msg.sender].pumpToAddDuringNextIncome += pumpsToBuy;
        amountOfPumps += pumpsToBuy;
        contractTVL += msg.value;
    }

    function _daylyIncome() external {
        require(lastDaylyIncomeTime <= block.timestamp, "not time yet");
        address user = addrToUser[owner].nextOne;
        while (user != address(0)) {
            addrToUser[user].freeBalance +=
                addrToUser[user].obtainedPumps *
                pumpProfitPerDay;
            addrToUser[user].totalEarnedMoney +=
                addrToUser[user].obtainedPumps *
                pumpProfitPerDay;
            addrToUser[user].obtainedPumps += addrToUser[user]
                .pumpToAddDuringNextIncome;
            addrToUser[user].pumpToAddDuringNextIncome = 0;
            user = addrToUser[user].nextOne;
        }
        lastDaylyIncomeTime = block.timestamp + periodOfIncome;
    }

    function Reinvest() public {
        require(
            addrToUser[msg.sender].freeBalance >= pumpCost,
            "Not enough money"
        );
        uint256 pumpsToBuy = addrToUser[msg.sender].freeBalance / pumpCost;
        _pay(pumpCost * pumpsToBuy);

        addrToUser[msg.sender].freeBalance -= pumpCost * pumpsToBuy;
        addrToUser[msg.sender].pumpToAddDuringNextIncome += pumpsToBuy;
        amountOfPumps += pumpsToBuy;
        contractTVL += pumpCost * pumpsToBuy;
    }

    function Withdraw() public nonReentrant {
        require(
            addrToUser[msg.sender].freeBalance > 0,
            "Not enough money to withdraw"
        );
        payable(msg.sender).transfer(addrToUser[msg.sender].freeBalance);
        addrToUser[msg.sender].freeBalance = 0;
    }

    function _lotterySpin() external {
        require(lastLotterSpinTime <= block.timestamp, "Not time yet");
        if (amountOfUsersInCurrentLottery > 0) {
            uint256[10] memory lotteryTablePercents = [
                uint256(1),
                2,
                3,
                4,
                5,
                6,
                7,
                18,
                24,
                30
            ];
            address[] memory sortedTable = sort();
            uint256 i;
            uint256 j;
            address previous = sortedTable[j];
            j++;
            delete winners[i];
            winners[i].push(previous);

            while (i < 10 && j < sortedTable.length) {
                if (
                    addrToUser[sortedTable[j]].amountOfRefs ==
                    addrToUser[previous].amountOfRefs
                ) {
                    winners[i].push(sortedTable[j]);
                } else {
                    emit newPlaceFormed(winners[i], winners[i].length, i + 1);
                    i++;
                    delete winners[i];
                    winners[i].push(sortedTable[j]);
                }
                previous = sortedTable[j];
                j++;
            }

            for (uint256 index = 0; index < 10; index++) {
                for (uint256 k = 0; j < winners[index].length; j++) {
                    addrToUser[winners[index][k]]
                        .freeBalance += ((lotteryTablePercents[index] *
                        lotteryPrizePool) /
                        100 /
                        winners[index].length);
                    addrToUser[winners[index][k]]
                        .totalEarnedMoney += ((lotteryTablePercents[index] *
                        lotteryPrizePool) /
                        100 /
                        winners[index].length);
                }
                // delete winners[index];
            }
        }
        address user = addrToUser[owner].nextOne;
        while (user != address(0)) {
            addrToUser[user].amountOfRefs = 0;
            user = addrToUser[user].nextOne;
        }
        lotteryPrizePool = 0;
        amountOfUsersInCurrentLottery = 0;

        lastLotterSpinTime = block.timestamp + periodOfLottery;
    }

    function sort() internal returns (address[] memory) {
        address[] memory temp = new address[](amountOfUsersInCurrentLottery);
        address user = addrToUser[owner].nextOne;
        uint256 i;
        while (user != address(0)) {
            if (addrToUser[user].amountOfRefs > 0) {
                temp[i] = user;
                i++;
            }
            user = addrToUser[user].nextOne;
        }
        if (temp.length >= 2) {
            quickSort(temp, 0, temp.length - 1);
        }
        return temp;
    }

    function quickSort(
        address[] memory arr,
        uint256 left,
        uint256 right
    ) internal {
        uint256 i = left;
        uint256 j = right;
        if (i == j) return;
        address pivot = arr[uint256(left + (right - left) / 2)];
        while (i <= j) {
            while (
                addrToUser[arr[uint256(i)]].amountOfRefs >
                addrToUser[pivot].amountOfRefs
            ) i++;
            while (
                addrToUser[pivot].amountOfRefs >
                addrToUser[arr[uint256(j)]].amountOfRefs
            ) j--;
            if (i <= j) {
                (arr[uint256(i)], arr[uint256(j)]) = (
                    arr[uint256(j)],
                    arr[uint256(i)]
                );
                i++;
                j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    function _pay(uint256 value) private {
        payable(owner).transfer((value * ownerPercent) / 100);
        payable(marketingWallet).transfer((value * marketingPercent) / 100);
        payable(addrToUser[msg.sender].ref).transfer(
            (value * refPercent) / 100
        );
        addrToUser[msg.sender].totalEarnedMoney += ((value * refPercent) / 100);
        payable(owner).transfer((value * developersPercent) / 100);
        lotteryPrizePool += ((value * lotteryPercent) / 100);
    }

    function getUser() external view returns (User memory) {
        return addrToUser[msg.sender];
    }

    function getLotteryTable(uint256 a) public view returns (address[] memory) {
        return winners[a];
    }

    function getStatistic() external view returns (uint256[7] memory) {
        return [
            contractTVL,
            lotteryPrizePool,
            developersPercent,
            marketingPercent,
            lotteryPercent,
            amountOfUsers,
            amountOfPumps
        ];
    }

    function getLotteryTime() external view returns (uint256) {
        return lastLotterSpinTime;
    }

    function getPumpProfit() external view returns (uint256) {
        return pumpProfitPerDay;
    }

    function getPriceOfPump() external view returns (uint256) {
        return pumpCost;
    }

    function getPumps() external view returns (uint256) {
        return
            addrToUser[msg.sender].obtainedPumps +
            addrToUser[msg.sender].pumpToAddDuringNextIncome;
    }

    function getUsersInLotter() external view returns (address[] memory) {
        address[] memory tmp = new address[](amountOfUsersInCurrentLottery);
        address user = addrToUser[owner].nextOne;
        uint256 i = 0;
        while (user != address(0)) {
            if (addrToUser[user].amountOfRefs > 0) {
                tmp[i] = user;
                i++;
            }
            user = addrToUser[user].nextOne;
        }
        return tmp;
    }
}