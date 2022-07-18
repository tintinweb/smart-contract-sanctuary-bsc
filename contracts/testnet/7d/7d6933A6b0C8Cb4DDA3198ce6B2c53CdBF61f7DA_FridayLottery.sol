/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

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

pragma solidity ^0.8.7;
contract FridayLottery is ReentrancyGuard {
    struct guessRandomNumber {
        uint256 number1;
        uint256 number2;
        uint256 number3;
        uint256 number4;
        uint256 number5;
    }

    struct guessRandomStars {
        uint256 star1;
        uint256 star2;
    }

    struct guessRandomNumberAndStars {
        uint256 number1;
        uint256 number2;
        uint256 number3;
        uint256 number4;
        uint256 number5;
        uint256 star1;
        uint256 star2;
    }

    struct distributionPercentage {
        uint256 prize1;
        uint256 prize2;
        uint256 prize3;
        uint256 prize4;
        uint256 prize5;
        uint256 prize6;
    }

    struct totalPrize {
        uint256 totalPrize1Winner;
        uint256 totalPrize2Winner;
        uint256 totalPrize3Winner;
        uint256 totalPrize4Winner;
        uint256 totalPrize5Winner;
        uint256 totalPrize6Winner;
    }
    struct prizes {
        uint256 prize1;
        uint256 prize2;
        uint256 prize3;
        uint256 prize4;
        uint256 prize5;
        uint256 prize6;
    }
    struct historyOfPrizeWinners {
        uint256 prize1Winners;
        uint256 prize2Winners;
        uint256 prize3Winners;
        uint256 prize4Winners;
        uint256 prize5Winners;
        uint256 prize6Winners;
    }
    struct historyOfPrizePerPersonAmount {
        uint256 prize1PerPersonAmount;
        uint256 prize2PerPersonAmount;
        uint256 prize3PerPersonAmount;
        uint256 prize4PerPersonAmount;
        uint256 prize5PerPersonAmount;
        uint256 prize6PerPersonAmount;
    }

    struct historyOfPrizeTotalAmount {
        uint256 totalPoolPrize;
        uint256 drawnDate;
        uint256 totalPlayers;
        uint256 prize1TotalAmount;
        uint256 prize2TotalAmount;
        uint256 prize3TotalAmount;
        uint256 prize4TotalAmount;
        uint256 prize5TotalAmount;
        uint256 prize6TotalAmount;
        uint256 maintenanceStakeAndGoodCausesAmount;
    }
    struct historyOfWinnigNumber {
        uint256 number1;
        uint256 number2;
        uint256 number3;
        uint256 number4;
        uint256 number5;
        uint256 star1;
        uint256 star2;
    }
    struct roundInfo {
        uint256 roundNumber;
        guessRandomNumber guessNumber;
        guessRandomStars guessStars;
        bool status;
        uint256 winningPrice;
        uint256 wininnigCategory;
        uint256 ticketNumber;
        uint256 winningIndex;
    }

    address public owner;
    address[] private tickets; 
    uint256 public ticketPrice;
    IERC20 public usdt;
    // guessRandomNumber[] private randomNumbersAndStars; //random guess numbers by players
    // guessRandomStars[] private randomStars; //random guess stars by players
    guessRandomNumberAndStars[] private randomNumbersAndStars; //random guess numbers and stars by players

    uint256 public maintenanceStakeAndGoodCausesFee = 2000;
    address public maintenanceStakeAndGoodCauses;

    distributionPercentage public distributionFee = //distribution fee for each prize winner
        distributionPercentage(
            4000, //distributionFee1
            2000, //distributionFee2
            1000, //distributionFee3
            500, //distributionFee4
            300, //distributionFee5
            200 //distributionFee6
        ); 
    guessRandomNumber private winningNumbers = guessRandomNumber(0, 0, 0, 0, 0);
    guessRandomStars private winningStars = guessRandomStars(0, 0);

    mapping(uint256 => historyOfPrizeWinners)
        public historyOfLotteryPrizeWinners;
    mapping(uint256 => historyOfPrizePerPersonAmount)
        public historyOfPrizePerPersonAmounts;
    mapping(uint256 => historyOfPrizeTotalAmount)
        public historyOfPrizeTotalAmounts;
    mapping(uint256 => historyOfWinnigNumber) public historyOfWinnigNumbers;

    uint256 public roundNumber = 1;
    bool public isTicketCanBeSold = true;
    uint256 public lotteryStartTime;
    uint256 public lotteryEndTime;
    uint256 public cooldownTime;
    bool public isLotteryStarted = true;

    mapping(uint256 => mapping(address => roundInfo[]))
        public yourHistoryPerRound;

    roundInfo[] private roundPerson;
    roundInfo[] private resetPerson;
    mapping(address => uint256) public buyTickets;
    bool public isTuesdayLotteryActive=true;
    address public tuesdayLotteryAddress=address(0x94EE58BD64d0E0E5bd59a312B1A34E96f3fF8858);

    modifier checkTicketSold(address buyer,uint guesses) {
        require(buyTickets[buyer] >= 1, "Please Buy Ticket First");
        require(buyTickets[buyer] >= guesses, "You have not enough tickets to add these lucky numbers");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Allowed");
        _;
    }

    modifier checkLotteryStarted() {
        require(isLotteryStarted != false, "The Lottery Is Not Started Yet!");
        _;
    }

    constructor(
        address _owner,
        address _usdt,
        address _maintenanceStakeAndGoodCauses,
        uint256 _ticketPrice,
        uint256 _cooldownTime,
        uint256 _lotteryStartTime
    ) ReentrancyGuard() {
        owner = _owner;
        usdt = IERC20(_usdt);
        maintenanceStakeAndGoodCauses = _maintenanceStakeAndGoodCauses;
        ticketPrice = _ticketPrice;
        cooldownTime = _cooldownTime;
        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = _lotteryStartTime + 7 days;
    }

    function buyTicket() external checkLotteryStarted {
        require(
            block.timestamp > (lotteryStartTime + cooldownTime),
            "The Lottery Is Not Started Yet!"
        );

        require(block.timestamp <= lotteryEndTime, "The Lottery has ended!");

        require(isTicketCanBeSold != false, "Tickets sale is closed for this draw");

        uint256 allowance = usdt.allowance(msg.sender, address(this));

        require(allowance >= ticketPrice, "You do not have enough allowance");
        uint256 totalTickets = allowance / ticketPrice;
        bool success = usdt.transferFrom(
            msg.sender,
            address(this),
            (totalTickets * ticketPrice)
        );

        require(success, "Usdt Transfer Failed");

        buyTickets[msg.sender] += totalTickets;
    }

    function addGuessNumber(
        guessRandomNumberAndStars [] calldata _guessNumberAndStars
    ) external checkLotteryStarted checkTicketSold(msg.sender, _guessNumberAndStars.length) {
        require(
            block.timestamp > (lotteryStartTime + cooldownTime),
            "The Lottery Is Not Started Yet!"
        );

        require(block.timestamp <= lotteryEndTime, "The Lottery has ended!");
        require(isTicketCanBeSold != false, "Add Lucky Number is closed for this draw");
        
        uint len = _guessNumberAndStars.length;
        uint _buyTickets=buyTickets[msg.sender];

        for (uint i = 0; i < len; ) {
            guessRandomNumberAndStars calldata _numbersAndStars = _guessNumberAndStars[i];
            require(
            (_numbersAndStars.number1 != 0 &&
                _numbersAndStars.number2 != 0 &&
                _numbersAndStars.number3 != 0 &&
                _numbersAndStars.number4 != 0 &&
                _numbersAndStars.number5 != 0 &&
                _numbersAndStars.star1 != 0 &&
                _numbersAndStars.star2 != 0),
            "Lucky Numbers And Stars Cannot Be Zero"
        );

        require(
            ((_numbersAndStars.number1 != _numbersAndStars.number2 &&
                _numbersAndStars.number1 != _numbersAndStars.number3 &&
                _numbersAndStars.number1 != _numbersAndStars.number4 &&
                _numbersAndStars.number1 != _numbersAndStars.number5) &&
                (
                    (_numbersAndStars.number2 != _numbersAndStars.number3 &&
                        _numbersAndStars.number2 != _numbersAndStars.number4 &&
                        _numbersAndStars.number2 != _numbersAndStars.number5)
                ) &&
                ((_numbersAndStars.number3 != _numbersAndStars.number4 && _numbersAndStars.number3 != _numbersAndStars.number5)) &&
                ((_numbersAndStars.number4 != _numbersAndStars.number5)) &&
                (_numbersAndStars.star1 != _numbersAndStars.star2)),
            "Lucky Numbers And Stars Must Be Unique Numbers"
        );

        _buyTickets-= 1;
        yourHistoryPerRound[roundNumber][msg.sender].push(
            roundInfo(
                roundNumber,
                guessRandomNumber(
                    _numbersAndStars.number1,
                    _numbersAndStars.number2,
                    _numbersAndStars.number3,
                    _numbersAndStars.number4,
                    _numbersAndStars.number5
                ),
                guessRandomStars(_numbersAndStars.star1, _numbersAndStars.star2),
                false,
                0,
                0,
                tickets.length,
                0
            )
        );
        tickets.push(msg.sender);
        // randomNumbers.push(
        //     guessRandomNumber(_numbersAndStars.number1, _numbersAndStars.number2, _numbersAndStars.number3, _numbersAndStars.number4, _numbersAndStars.number5)
        // );
        // randomStars.push(guessRandomStars(_numbersAndStars.star1, _numbersAndStars.star2));

        randomNumbersAndStars.push(
            guessRandomNumberAndStars(
                _numbersAndStars.number1,
                _numbersAndStars.number2,
                _numbersAndStars.number3,
                _numbersAndStars.number4,
                _numbersAndStars.number5,
                _numbersAndStars.star1,
                _numbersAndStars.star2
            )
        );
        
            unchecked {
                ++i;
            }
        }

        buyTickets[msg.sender]=_buyTickets;
        
    }

    function addWinningNumber(
        uint256 _number1,
        uint256 _number2,
        uint256 _number3,
        uint256 _number4,
        uint256 _number5,
        uint256 _star1,
        uint256 _star2
    ) external checkLotteryStarted onlyOwner {
        require(block.timestamp > lotteryEndTime, "You can not add winning numbers before the lottery has ended.");

        require(
            (_number1 != 0 &&
                _number2 != 0 &&
                _number3 != 0 &&
                _number4 != 0 &&
                _number5 != 0 &&
                _star1 != 0 &&
                _star2 != 0),
            "Winning Numbers And Stars Cannot Be Zero"
        );

        require(
            ((_number1 != _number2 &&
                _number1 != _number3 &&
                _number1 != _number4 &&
                _number1 != _number5) &&
                (
                    (_number2 != _number3 &&
                        _number2 != _number4 &&
                        _number2 != _number5)
                ) &&
                ((_number3 != _number4 && _number3 != _number5)) &&
                ((_number4 != _number5)) &&
                (_star1 != _star2)),
            "Winning Numbers And Stars Must Be Unique Numbers"
        );

        require(winningNumbers.number1 == 0, "Winning Numbers Already Added");

        winningNumbers = guessRandomNumber(
            _number1,
            _number2,
            _number3,
            _number4,
            _number5
        );
        winningStars = guessRandomStars(_star1, _star2);
    }

    function annouceWinner()
        external
        checkLotteryStarted
        nonReentrant
        onlyOwner
    {
        require(
            (winningNumbers.number1 != 0 &&
                winningNumbers.number2 != 0 &&
                winningNumbers.number3 != 0 &&
                winningNumbers.number4 != 0 &&
                winningNumbers.number5 != 0 &&
                winningStars.star1 != 0 &&
                winningStars.star2 != 0),
            "Please Enter Winning Numbers Before Annoucing The Winners"
        );

        require(block.timestamp >= lotteryEndTime, "Lottery Is Not Ended Yet!");

        (
            totalPrize memory winners,
            address[] memory prize1Winner,
            address[] memory prize2Winner,
            address[] memory prize3Winner,
            address[] memory prize4Winner,
            address[] memory prize5Winner,
            address[] memory prize6Winner
        ) = getWinners();

        uint256 poolPrize = usdt.balanceOf(address(this));
        prizes memory prize = prizes(0, 0, 0, 0, 0, 0);
        prize.prize1 = (poolPrize * distributionFee.prize1) / 10000;
        prize.prize2 = (poolPrize * distributionFee.prize2) / 10000;
        prize.prize3 = (poolPrize * distributionFee.prize3) / 10000;
        prize.prize4 = (poolPrize * distributionFee.prize4) / 10000;
        prize.prize5 = (poolPrize * distributionFee.prize5) / 10000;
        prize.prize6 = (poolPrize * distributionFee.prize6) / 10000;
        uint256 maintenanceStakeAndGoodCausesAmount = (poolPrize *
            maintenanceStakeAndGoodCausesFee) / 10000;

        if (winners.totalPrize1Winner > 0) {
            distributePrize(
                winners.totalPrize1Winner,
                prize1Winner,
                prize.prize1,
                1
            );
        }
        if (winners.totalPrize2Winner > 0) {
            distributePrize(
                winners.totalPrize2Winner,
                prize2Winner,
                prize.prize2,
                2
            );
        }
        if (winners.totalPrize3Winner > 0) {
            distributePrize(
                winners.totalPrize3Winner,
                prize3Winner,
                prize.prize3,
                3
            );
        }
        if (winners.totalPrize4Winner > 0) {
            distributePrize(
                winners.totalPrize4Winner,
                prize4Winner,
                prize.prize4,
                4
            );
        }
        if (winners.totalPrize5Winner > 0) {
            distributePrize(
                winners.totalPrize5Winner,
                prize5Winner,
                prize.prize5,
                5
            );
        }
        if (winners.totalPrize6Winner > 0) {
            distributePrize(
                winners.totalPrize6Winner,
                prize6Winner,
                prize.prize6,
                6
            );
        }

        sendMaintenanceStakeAndGoodCausesAmount(
            maintenanceStakeAndGoodCausesAmount
        );

        historyOfLotteryPrizeWinners[roundNumber] = historyOfPrizeWinners(
            winners.totalPrize1Winner, //prize1Winners,
            winners.totalPrize2Winner, //prize2Winners,
            winners.totalPrize3Winner, //prize3Winners,
            winners.totalPrize4Winner, //prize4Winners,
            winners.totalPrize5Winner, //prize5Winners,
            winners.totalPrize6Winner //prize6Winners,
        );
        historyOfPrizePerPersonAmounts[
            roundNumber
        ] = historyOfPrizePerPersonAmount(
            calculatePrize(prize.prize1, winners.totalPrize1Winner), //prize1PerPersonAmount,
            calculatePrize(prize.prize2, winners.totalPrize2Winner), //prize2PerPersonAmount,
            calculatePrize(prize.prize3, winners.totalPrize3Winner), //prize3PerPersonAmount,
            calculatePrize(prize.prize4, winners.totalPrize4Winner), //prize4PerPersonAmount,
            calculatePrize(prize.prize5, winners.totalPrize5Winner), //prize5PerPersonAmount,
            calculatePrize(prize.prize6, winners.totalPrize6Winner) //prize6PerPersonAmount
        );

        historyOfPrizeTotalAmounts[roundNumber] = historyOfPrizeTotalAmount(
            poolPrize, //totalPrize,
            block.timestamp,
            tickets.length,
            prize.prize1, //prize1PerPersonAmount,
            prize.prize2, //prize2PerPersonAmount,
            prize.prize3, //prize3PerPersonAmount,
            prize.prize4, //prize4PerPersonAmount,
            prize.prize5, //prize5PerPersonAmount,
            prize.prize6, //prize6PerPersonAmount,
            maintenanceStakeAndGoodCausesAmount //maintenanceStakeAndGoodCausesAmount
        );

        historyOfWinnigNumbers[roundNumber] = historyOfWinnigNumber(
            winningNumbers.number1, //number1,
            winningNumbers.number2, //number2,
            winningNumbers.number3, //number3,
            winningNumbers.number4, //number4,
            winningNumbers.number5, //number5,
            winningStars.star1, //star1,
            winningStars.star2 //star2,
        );

        //Roll Over Amount To next draw if other lottery is activated or not

        if (isTuesdayLotteryActive) {
            bool success = usdt.transfer(
                tuesdayLotteryAddress,
                usdt.balanceOf(address(this))
            );
            require(success, "Usdt Transfer Failed!");
        }

        // reset lottery for new round
        delete tickets;
        // tickets = new address[](0);
        delete randomNumbersAndStars;    
        // delete randomNumbers;
        // delete randomStars;

        lotteryStartTime = lotteryEndTime;
        lotteryEndTime = (lotteryEndTime + 7 days);
        winningNumbers = guessRandomNumber(0, 0, 0, 0, 0);
        winningStars = guessRandomStars(0, 0);
        roundNumber++;
    }

    function calculatePrize(uint256 prize, uint256 total)
        private
        pure
        returns (uint256)
    {
        if (total > 0) {
            return prize / total;
        } else {
            return prize;
        }
    }

    function distributePrize(
        uint256 _totalWinner,
        address[] memory winners,
        uint256 prize,
        uint256 _wininnigCategory
    ) private {
        uint256 amountPerWinner = prize / _totalWinner;
        for (uint256 i = 0; i < _totalWinner; i++) {
            roundPerson = yourHistoryPerRound[roundNumber][winners[i]];
            for (uint256 j = 0; j < roundPerson.length; j++) {
                if (
                    roundPerson[j].winningIndex == i &&
                    roundPerson[j].wininnigCategory == _wininnigCategory
                ) {
                    roundPerson[j] = roundInfo(
                        roundNumber,
                        roundPerson[j].guessNumber,
                        roundPerson[j].guessStars,
                        true,
                        amountPerWinner,
                        _wininnigCategory,
                        roundPerson[j].ticketNumber,
                        roundPerson[j].winningIndex
                    );
                    yourHistoryPerRound[roundNumber][tickets[i]] = roundPerson;
                    break;
                }
            }
            bool success = usdt.transfer(winners[i], amountPerWinner);
            require(success, "Usdt Transfer Failed!");
        }
    }

    function sendMaintenanceStakeAndGoodCausesAmount(uint256 _amount) private {
        bool success = usdt.transfer(maintenanceStakeAndGoodCauses, _amount);
        require(success, "Usdt Transfer Failed!");
    }

    function getWinners()
        private
        returns (
            totalPrize memory prizeWinner,
            address[] memory prize1Winner,
            address[] memory prize2Winner,
            address[] memory prize3Winner,
            address[] memory prize4Winner,
            address[] memory prize5Winner,
            address[] memory prize6Winner
        )
    {
        uint256 totalTickets = tickets.length;

        prize1Winner = new address[](totalTickets);
        prize2Winner = new address[](totalTickets);
        prize3Winner = new address[](totalTickets);
        prize4Winner = new address[](totalTickets);
        prize5Winner = new address[](totalTickets);
        prize6Winner = new address[](totalTickets);

        {
            for (uint256 i = 0; i < totalTickets; i++) {
                uint256 matchedNumber = 0;
                uint256 matchedStar = 0;
                if (
                    randomNumbersAndStars[i].number1 == winningNumbers.number1 ||
                    randomNumbersAndStars[i].number1 == winningNumbers.number2 ||
                    randomNumbersAndStars[i].number1 == winningNumbers.number3 ||
                    randomNumbersAndStars[i].number1 == winningNumbers.number4 ||
                    randomNumbersAndStars[i].number1 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbersAndStars[i].number2 == winningNumbers.number1 ||
                    randomNumbersAndStars[i].number2 == winningNumbers.number2 ||
                    randomNumbersAndStars[i].number2 == winningNumbers.number3 ||
                    randomNumbersAndStars[i].number2 == winningNumbers.number4 ||
                    randomNumbersAndStars[i].number2 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbersAndStars[i].number3 == winningNumbers.number1 ||
                    randomNumbersAndStars[i].number3 == winningNumbers.number3 ||
                    randomNumbersAndStars[i].number3 == winningNumbers.number3 ||
                    randomNumbersAndStars[i].number3 == winningNumbers.number4 ||
                    randomNumbersAndStars[i].number3 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbersAndStars[i].number4 == winningNumbers.number1 ||
                    randomNumbersAndStars[i].number4 == winningNumbers.number4 ||
                    randomNumbersAndStars[i].number4 == winningNumbers.number3 ||
                    randomNumbersAndStars[i].number4 == winningNumbers.number4 ||
                    randomNumbersAndStars[i].number4 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbersAndStars[i].number5 == winningNumbers.number1 ||
                    randomNumbersAndStars[i].number5 == winningNumbers.number5 ||
                    randomNumbersAndStars[i].number5 == winningNumbers.number3 ||
                    randomNumbersAndStars[i].number5 == winningNumbers.number4 ||
                    randomNumbersAndStars[i].number5 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (matchedNumber == 5) {
                    if (
                        randomNumbersAndStars[i].star1 == winningStars.star1 ||
                        randomNumbersAndStars[i].star1 == winningStars.star2
                    ) {
                        matchedStar++;
                    }
                    if (
                        randomNumbersAndStars[i].star2 == winningStars.star1 ||
                        randomNumbersAndStars[i].star2 == winningStars.star2
                    ) {
                        matchedStar++;
                    }
                }
                if (matchedNumber == 5 && matchedStar == 2) {
                    roundPerson = yourHistoryPerRound[roundNumber][tickets[i]];
                    for (uint256 j = 0; j < roundPerson.length; j++) {
                        if (roundPerson[j].ticketNumber == i) {
                            roundPerson[j] = roundInfo(
                                roundNumber,
                                roundPerson[j].guessNumber,
                                roundPerson[j].guessStars,
                                true,
                                0,
                                1,
                                roundPerson[j].ticketNumber,
                                prizeWinner.totalPrize1Winner
                            );
                            yourHistoryPerRound[roundNumber][
                                tickets[i]
                            ] = roundPerson;
                            break;
                        }
                    }
                    prize1Winner[prizeWinner.totalPrize1Winner] = tickets[i];
                    prizeWinner.totalPrize1Winner++;
                } else if (matchedNumber == 5 && matchedStar == 1) {
                    roundPerson = yourHistoryPerRound[roundNumber][tickets[i]];
                    for (uint256 j = 0; j < roundPerson.length; j++) {
                        if (roundPerson[j].ticketNumber == i) {
                            roundPerson[j] = roundInfo(
                                roundNumber,
                                roundPerson[j].guessNumber,
                                roundPerson[j].guessStars,
                                true,
                                0,
                                2,
                                roundPerson[j].ticketNumber,
                                prizeWinner.totalPrize2Winner
                            );
                            yourHistoryPerRound[roundNumber][
                                tickets[i]
                            ] = roundPerson;
                            break;
                        }
                    }

                    prize2Winner[prizeWinner.totalPrize2Winner] = tickets[i];
                    prizeWinner.totalPrize2Winner++;
                } else if (matchedNumber == 5) {
                    roundPerson = yourHistoryPerRound[roundNumber][tickets[i]];
                    for (uint256 j = 0; j < roundPerson.length; j++) {
                        if (roundPerson[j].ticketNumber == i) {
                            roundPerson[j] = roundInfo(
                                roundNumber,
                                roundPerson[j].guessNumber,
                                roundPerson[j].guessStars,
                                true,
                                0,
                                3,
                                roundPerson[j].ticketNumber,
                                prizeWinner.totalPrize3Winner
                            );
                            yourHistoryPerRound[roundNumber][
                                tickets[i]
                            ] = roundPerson;
                            break;
                        }
                    }

                    prize3Winner[prizeWinner.totalPrize3Winner] = tickets[i];
                    prizeWinner.totalPrize3Winner++;
                } else if (matchedNumber == 4) {
                    roundPerson = yourHistoryPerRound[roundNumber][tickets[i]];
                    for (uint256 j = 0; j < roundPerson.length; j++) {
                        if (roundPerson[j].ticketNumber == i) {
                            roundPerson[j] = roundInfo(
                                roundNumber,
                                roundPerson[j].guessNumber,
                                roundPerson[j].guessStars,
                                true,
                                0,
                                4,
                                roundPerson[j].ticketNumber,
                                prizeWinner.totalPrize4Winner
                            );
                            yourHistoryPerRound[roundNumber][
                                tickets[i]
                            ] = roundPerson;
                            break;
                        }
                    }

                    prize4Winner[prizeWinner.totalPrize4Winner] = tickets[i];
                    prizeWinner.totalPrize4Winner++;
                } else if (matchedNumber == 3) {
                    roundPerson = yourHistoryPerRound[roundNumber][tickets[i]];
                    for (uint256 j = 0; j < roundPerson.length; j++) {
                        if (roundPerson[j].ticketNumber == i) {
                            roundPerson[j] = roundInfo(
                                roundNumber,
                                roundPerson[j].guessNumber,
                                roundPerson[j].guessStars,
                                true,
                                0,
                                5,
                                roundPerson[j].ticketNumber,
                                prizeWinner.totalPrize5Winner
                            );
                            yourHistoryPerRound[roundNumber][
                                tickets[i]
                            ] = roundPerson;
                            break;
                        }
                    }

                    prize5Winner[prizeWinner.totalPrize5Winner] = tickets[i];
                    prizeWinner.totalPrize5Winner++;
                } else if (matchedNumber == 2) {
                    for (uint256 j = 0; j < roundPerson.length; j++) {
                        if (roundPerson[j].ticketNumber == i) {
                            roundPerson[j] = roundInfo(
                                roundNumber,
                                roundPerson[j].guessNumber,
                                roundPerson[j].guessStars,
                                true,
                                0,
                                6,
                                roundPerson[j].ticketNumber,
                                prizeWinner.totalPrize6Winner
                            );
                            yourHistoryPerRound[roundNumber][
                                tickets[i]
                            ] = roundPerson;
                            break;
                        }
                    }

                    prize6Winner[prizeWinner.totalPrize6Winner] = tickets[i];
                    prizeWinner.totalPrize6Winner++;
                }
            }
        }
    }

    function changeTicketPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Ticket price must be greater than 0");

        ticketPrice = _price;
    }

    function changeMaintenanceStakeAndGoodCausesFee(uint256 _fee)
        external
        onlyOwner
    {
        maintenanceStakeAndGoodCausesFee = _fee;
    }

    function changeMaintenanceStakeAndGoodCausesAddress(
        address _maintenanceStakeAndGoodCausesAddress
    ) external onlyOwner {
        maintenanceStakeAndGoodCauses = _maintenanceStakeAndGoodCausesAddress;
    }

    function changeDistributionFee(
        uint256 _distributionFee1,
        uint256 _distributionFee2,
        uint256 _distributionFee3,
        uint256 _distributionFee4,
        uint256 _distributionFee5,
        uint256 _distributionFee6
    ) external onlyOwner {
        distributionFee = distributionPercentage(
            _distributionFee1,
            _distributionFee2,
            _distributionFee3,
            _distributionFee4,
            _distributionFee5,
            _distributionFee6
        );
    }

    function getBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this));
    }

    function setIsTicketCanBeSold(bool _isTicketCanBeSold)
        external
        onlyOwner
        checkLotteryStarted
    {
        isTicketCanBeSold = _isTicketCanBeSold;
    }

    function setLotteryStartTime(uint256 _lotteryStartTime)
        external
        onlyOwner
        checkLotteryStarted
    {
        require(
            block.timestamp < _lotteryStartTime,
            "Lottery Start Time Cannot Be In The Past!"
        );
        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = _lotteryStartTime + 7 days;
    }

    function setLotteryEndTime(uint256 _lotteryEndTime)
        external
        onlyOwner
        checkLotteryStarted
    {
        require(
            block.timestamp < _lotteryEndTime,
            "Lottery End Time Cannot Be In The Past!"
        );

        lotteryEndTime = _lotteryEndTime;
    }

    function setCooldownTime(uint256 _cooldownTime) external onlyOwner {
        cooldownTime = _cooldownTime;
    }

    function stopLottery() external onlyOwner checkLotteryStarted {
        require(
            tickets.length == 0,
            "Please Annouce Winner Before Stopping The Lottery"
        );

        require(
            block.timestamp >= lotteryEndTime,
            "Lottery Cannot Be Stopped Before The Lottery End Time"
        );

        isLotteryStarted = false;
    }

    function startLottery(uint256 _lotteryStartTime) external onlyOwner {
        require(isLotteryStarted == false, "Lottery Has Already Started");

        require(
            block.timestamp < _lotteryStartTime,
            "Lottery Start Time Cannot Be In The Past!"
        );

        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = lotteryStartTime + 7 days;
        isTicketCanBeSold = true;
        isLotteryStarted = true;
    }

    function getCurrentTotalPlayers() external view returns (uint256) {
        return tickets.length;
    }

    function getYourHistoryPerRound(uint256 round, address _personAddress)
        public
        view
        returns (roundInfo[] memory)
    {
        return yourHistoryPerRound[round][_personAddress];
    }

    function getYourHistory(uint256 _roundNumber)
        public
        view
        returns (roundInfo[] memory)
    {
        roundInfo[] memory array = yourHistoryPerRound[_roundNumber][
            msg.sender
        ];
        return array;
    }

    function transferOwnerShip(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function getTotalBuyTickets() external view returns (uint256) {
        return buyTickets[msg.sender];
    }

    function setTuesdayLotteryAddress(address _tuesdayLotteryAddress)
        external
        onlyOwner
    {
        tuesdayLotteryAddress = _tuesdayLotteryAddress;
    }

    function setTuesdayLotteryActive(bool _isActive) external onlyOwner {
        isTuesdayLotteryActive = _isActive;
    }
}