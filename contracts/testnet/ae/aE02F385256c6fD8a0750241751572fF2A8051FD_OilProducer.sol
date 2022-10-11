/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

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

pragma solidity ^0.8.17;

contract OilProducer is ReentrancyGuard {
    // settings
    uint256 public developersPercent;
    uint256 public marketingPercent;
    uint256 public lotteryPercent;
    uint256 public ownerPercent;
    uint256 public refPercent;
    uint256 pumpCost;
    uint256 pumpProfitPerDay;
    uint256 public scStartDay;
    uint256 public lotteryPrizePool;

    address public owner;
    address public developer;
    address public refDefault;
    address public marketingWallet;

    //tools
    uint256 public lastIncomeTime;
    uint256 lastLotterSpinTime;
    uint256 amountOfUsers;
    uint256 amountOfPumps;
    uint256 contractTVL;
    uint256 public periodOfIncome;
    uint256 public periodOfLottery;
    address pointerForLinking;
    uint256 amountOfUsersInCurrentLottery;
    uint256 timeDaylyIncome;

    /*struct of user. It helps to track pumps, balance, refs amount. */
    struct User {
        uint256 obtainedPumps; //Pumps that in game
        uint256 pumpToAddDuringNextIncome; //Pumps would be in game after next claim
        uint256 freeBalance; //Balance, that could be spend on pumps or withdrawed
        uint256 tempBalance;
        uint256 lastIncomeTime;
        uint256 lastDaylyIncomeTime;
        uint256 amountOfRefs; //amount of refs to participate in lottery
        uint256 totalEarnedMoney;
        uint256 totalRefMoney;
        address ref; //Ref of this person
        address nextOne; //Link to next user
        bool isRegistred;
    }

    mapping(address => User) addrToUser; // main mapping

    mapping(uint256 => mapping(uint256 => address[])) public winners;
    mapping(uint256 => uint256) public lotaryTimes;
    uint256 public countLotary; 

    event newRef(address addr, uint256 hisRefs);
    event newPlaceFormed(address[] winners, uint256 numberOfWinners, uint256 place);

    /*constructor(
        address[4] memory _wallets,
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
        ownerPercent = _ownerPercent;
        lotteryPercent = _lotteryPercent;
        refPercent = _refPercent;
        pumpCost = _pumpCost;
        pumpProfitPerDay = _pumpProfitPerDay;

        owner = _wallets[0];
        developer = _wallets[1];
        refDefault = _wallets[2];
        marketingWallet = _wallets[3];

        scStartDay = _times[0];
        lastIncomeTime = _times[0];
        lastLotterSpinTime = _times[0];
        periodOfIncome = _times[1] * 60;
        periodOfLottery = _times[2] * 60;

        timeDaylyIncome = 10 * 60; //3600 * 24;

        pointerForLinking = refDefault;
        addrToUser[refDefault].isRegistred = true;
        amountOfUsers = 1;
    }*/

    constructor(
    ) {
        developersPercent =  1;//_developersPercent;
        marketingPercent = 2; //_marketingPercent;
        ownerPercent = 3; // _ownerPercent;
        lotteryPercent = 4; // _lotteryPercent;
        refPercent = 5; // _refPercent;
        pumpCost = 100000000000000000;// _pumpCost;
        pumpProfitPerDay = 10000000000000000; //_pumpProfitPerDay;

        owner = msg.sender; // _wallets[0];
        developer = msg.sender; // _wallets[1];
        refDefault = msg.sender; // _wallets[2];
        marketingWallet = msg.sender; // _wallets[3];

        scStartDay = block.timestamp; // _times[0];
        lastIncomeTime = block.timestamp; // _times[0];
        lastLotterSpinTime = block.timestamp; // _times[0];
        periodOfIncome = 1 * 60;
        periodOfLottery = 15 * 60;

        timeDaylyIncome = 5 * 60; //3600 * 24;

        pointerForLinking = refDefault;
        addrToUser[pointerForLinking].isRegistred = true;
        amountOfUsers = 1;
        // 0x0000000000000000000000000000000000000000
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
            }
            if (addrToUser[addrToUser[msg.sender].ref].amountOfRefs == 0) {
                amountOfUsersInCurrentLottery++;
            }
            addrToUser[addrToUser[msg.sender].ref].amountOfRefs++;
            if (!addrToUser[addrToUser[msg.sender].ref].isRegistred) {
                addrToUser[pointerForLinking].nextOne = addrToUser[msg.sender].ref;
                pointerForLinking = addrToUser[msg.sender].ref;
                addrToUser[addrToUser[msg.sender].ref].isRegistred = true;
                addrToUser[addrToUser[msg.sender].ref].lastIncomeTime = block.timestamp;
                addrToUser[addrToUser[msg.sender].ref].lastDaylyIncomeTime = block.timestamp;
            }

            emit newRef(addrToUser[msg.sender].ref, addrToUser[addrToUser[msg.sender].ref].amountOfRefs);

            addrToUser[msg.sender].isRegistred = true;
            addrToUser[msg.sender].lastDaylyIncomeTime = block.timestamp;
            addrToUser[msg.sender].lastIncomeTime = block.timestamp;
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
        require(lastIncomeTime <= block.timestamp, "not time yet");
        address user = refDefault;
        while (user != address(0)) {
            uint256 k = (block.timestamp - addrToUser[user].lastIncomeTime) / periodOfIncome;
            if(k > 0){
              addrToUser[user].tempBalance += addrToUser[user].obtainedPumps * (pumpProfitPerDay / (timeDaylyIncome / periodOfIncome)) * k;
              addrToUser[user].obtainedPumps += addrToUser[user].pumpToAddDuringNextIncome;
              addrToUser[user].pumpToAddDuringNextIncome = 0;
              addrToUser[user].lastIncomeTime = block.timestamp;
            }
            if((addrToUser[user].lastDaylyIncomeTime + timeDaylyIncome) <= block.timestamp){
              addrToUser[user].freeBalance += addrToUser[user].tempBalance;
              addrToUser[user].totalEarnedMoney += addrToUser[user].tempBalance;
              addrToUser[user].tempBalance = 0;
              addrToUser[user].lastDaylyIncomeTime += timeDaylyIncome;
            }
            user = addrToUser[user].nextOne;
        }
        lastIncomeTime = block.timestamp + periodOfIncome;
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
            winners[countLotary][i].push(previous);

            while (i < 10 && j < sortedTable.length) {
                if (addrToUser[sortedTable[j]].amountOfRefs == addrToUser[previous].amountOfRefs) {
                    winners[countLotary][i].push(sortedTable[j]);
                } else {
                    emit newPlaceFormed(winners[countLotary][i], winners[countLotary][i].length, i + 1);
                    i++;
                    delete winners[countLotary][i];
                    winners[countLotary][i].push(sortedTable[j]);
                }
                previous = sortedTable[j];
                j++;
            }

            for (uint256 index = 0; index < 10; index++) {
                for (uint256 k = 0; j < winners[countLotary][index].length; j++) {
                    addrToUser[winners[countLotary][index][k]].freeBalance += ((lotteryTablePercents[9-index] * lotteryPrizePool) / 100 / winners[countLotary][index].length);
                    addrToUser[winners[countLotary][index][k]].totalEarnedMoney += ((lotteryTablePercents[9-index] * lotteryPrizePool) / 100 / winners[countLotary][index].length);
                }
            }
        }
        address user = refDefault;
        while (user != address(0)) {
            addrToUser[user].amountOfRefs = 0;
            user = addrToUser[user].nextOne;
        }
        lotteryPrizePool = 0;
        amountOfUsersInCurrentLottery = 0;
        lotaryTimes[countLotary] = block.timestamp;
        countLotary++;
        lastLotterSpinTime = block.timestamp + periodOfLottery;
    }

    function sort() internal returns (address[] memory) {
        address[] memory temp = new address[](amountOfUsersInCurrentLottery);
        address user = refDefault;
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
            while (addrToUser[arr[uint256(i)]].amountOfRefs > addrToUser[pivot].amountOfRefs) 
              i++;
            while (addrToUser[pivot].amountOfRefs > addrToUser[arr[uint256(j)]].amountOfRefs) 
              j--;
            if (i <= j) {
                (arr[uint256(i)], arr[uint256(j)]) = (arr[uint256(j)],arr[uint256(i)]);
                i++;
                if(j > 0)
                    j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    function _pay(uint256 value) private {
        payable(owner).transfer((value * ownerPercent) / 100);
        payable(marketingWallet).transfer((value * marketingPercent) / 100);
        payable(addrToUser[msg.sender].ref).transfer((value * refPercent) / 100);
        addrToUser[addrToUser[msg.sender].ref].totalRefMoney += ((value * refPercent) / 100);
        payable(developer).transfer((value * developersPercent) / 100);
        lotteryPrizePool += ((value * lotteryPercent) / 100);
    }

    function getUser() external view returns (User memory) {
        return addrToUser[msg.sender];
    }

    function getLotteryTable(uint256 number) public view returns (address[][10] memory) {
        return 
        [
            winners[number][0],
            winners[number][1],
            winners[number][2],
            winners[number][3],
            winners[number][4],
            winners[number][5],
            winners[number][6],
            winners[number][7],
            winners[number][8],
            winners[number][9]
        ];
    }

    function getStatistic() external view returns (uint256[7] memory) {
        return [
            contractTVL,
            lotteryPrizePool,
            developersPercent + ownerPercent,
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

    function getUsersInLotter() external view returns (address[] memory, uint256[] memory) {
        address[] memory tmp = new address[](amountOfUsersInCurrentLottery);
        uint256[] memory tmp_sum = new uint256[](amountOfUsersInCurrentLottery);
        address user = refDefault;
        uint256 i = 0;
        while (user != address(0)) {
            if (addrToUser[user].amountOfRefs > 0) {
                tmp[i] = user;
                tmp_sum[i] = addrToUser[user].amountOfRefs;
                i++;
            }
            user = addrToUser[user].nextOne;
        }
        return (tmp, tmp_sum);
    }
}