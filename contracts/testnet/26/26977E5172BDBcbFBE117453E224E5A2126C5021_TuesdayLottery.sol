/**
 *Submitted for verification at BscScan.com on 2022-07-23
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
contract TuesdayLottery is ReentrancyGuard {
    struct guessRandomNumberAndStars {
        uint8 number1;
        uint8 number2;
        uint8 number3;
        uint8 number4;
        uint8 number5;
        uint8 star1;
        uint8 star2;
    }
    struct guessInfo {
        guessRandomNumberAndStars guess;
        address user;
    }
    struct distributionPercentage {
        uint16 prize1;
        uint16 prize2;
        uint16 prize3;
        uint16 prize4;
        uint16 prize5;
        uint16 prize6;
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
        uint8 number1;
        uint8 number2;
        uint8 number3;
        uint8 number4;
        uint8 number5;
        uint8 star1;
        uint8 star2;
    }
    struct roundInfoPerPerson {
        guessRandomNumberAndStars guessNumbersAndStars;
        uint256 ticketNumber;
        uint8 lotteryType;
    }

    struct Distribute {
        uint256 winningIndex;
        uint256 wininnigCategory;
        uint256 winningPrice;
        bool status;
        uint8 lotteryType;
    }
    struct Ticketwinner {
        uint256 winningIndex;
        uint256 wininnigCategory;
        bool status;
        uint8 lotteryType;
        uint256 ticketNumber;
    }

    struct roundHistory {
        historyOfWinnigNumber historyOfWinningNumbers;
        historyOfPrizeTotalAmount historyOfPrizeTotalAmount;
        historyOfPrizePerPersonAmount historyOfPrizePerPersonAmount;
        historyOfPrizeWinners historyOfPrizeWinners;
    }
    
    address public owner;
    uint256 public ticketPrice;
    IERC20 public usdt;

    mapping(uint256 => guessInfo) public guessInfos; //random guess numbers and stars by players
    uint256 public guessCount; //number of tickets

    uint16 public constant maintenanceStakeAndGoodCausesFee=2000;
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
    guessRandomNumberAndStars private winningNumbersAndStars;

    uint256 public roundNumber=1;
    uint256 public lotteryStartTime;
    uint256 public lotteryEndTime;
    uint256 public cooldownTime;
    bool public isLotteryStarted=true;
    bool public isTicketCanBeSold=true;
    bool public isFridayLotteryActive=true;
    mapping(address => uint256) public buyTickets;
    address public fridayLotteryAddress;

    modifier checkTicketSold(address buyer, uint256 guesses) {
        require(buyTickets[buyer] >= 1, "Please Buy Ticket First");
        require(
            buyTickets[buyer] >= guesses,
            "You have not enough tickets to add these lucky numbers"
        );
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
    event TicketBought(address indexed buyer, uint256 tickets);
    event TicketGuessed(
        uint256 indexed roundNumber,
        address indexed buyer,
        roundInfoPerPerson info
    );
    event DistributePrize(
        uint256 indexed roundNumber,
        address indexed winner,
        Distribute info
    );
    event TicketWinner(
        uint256 indexed roundNumber,
        address indexed winner,
        Ticketwinner info
    );

    event RoundHistory(
        uint256 roundNumber,
        roundHistory info,
        uint8 lotteryType
    );
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

        require(
            isTicketCanBeSold != false,
            "Tickets sale is closed for this draw"
        );

        uint256 _ticketPrice = ticketPrice;
        uint256 allowance = usdt.allowance(msg.sender, address(this));
        require(allowance >= _ticketPrice, "You do not have enough allowance");
        uint256 totalTickets = allowance / _ticketPrice;
        bool success = usdt.transferFrom(
            msg.sender,
            address(this),
            (totalTickets * _ticketPrice)
        );
        require(success, "Usdt Transfer Failed");
        buyTickets[msg.sender] += totalTickets;
        emit TicketBought(msg.sender, totalTickets);
    }

    function addGuessNumber(
        guessRandomNumberAndStars[] calldata _guessNumberAndStars
    )
        external
        checkLotteryStarted
        checkTicketSold(msg.sender, _guessNumberAndStars.length)
    {
        require(
            block.timestamp > (lotteryStartTime + cooldownTime),
            "The Lottery Is Not Started Yet!"
        );

        require(block.timestamp <= lotteryEndTime, "The Lottery has ended!");
        require(
            isTicketCanBeSold != false,
            "Add Lucky Number is closed for this draw"
        );

        uint256 len = _guessNumberAndStars.length;
        uint256 _buyTickets = buyTickets[msg.sender];
        uint256 _guessCount = guessCount;

        for (uint256 i = 0; i < len; ) {
            guessRandomNumberAndStars
                calldata _numbersAndStars = _guessNumberAndStars[i];
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
                            _numbersAndStars.number2 !=
                            _numbersAndStars.number4 &&
                            _numbersAndStars.number2 !=
                            _numbersAndStars.number5)
                    ) &&
                    (
                        (_numbersAndStars.number3 != _numbersAndStars.number4 &&
                            _numbersAndStars.number3 !=
                            _numbersAndStars.number5)
                    ) &&
                    ((_numbersAndStars.number4 != _numbersAndStars.number5)) &&
                    (_numbersAndStars.star1 != _numbersAndStars.star2)),
                "Lucky Numbers And Stars Must Be Unique Numbers"
            );

            guessInfos[_guessCount] = guessInfo(
                guessRandomNumberAndStars(
                    _numbersAndStars.number1,
                    _numbersAndStars.number2,
                    _numbersAndStars.number3,
                    _numbersAndStars.number4,
                    _numbersAndStars.number5,
                    _numbersAndStars.star1,
                    _numbersAndStars.star2
                ),
                msg.sender
            );
            emit TicketGuessed(
                roundNumber,
                msg.sender,
                roundInfoPerPerson(
                    guessRandomNumberAndStars(
                        _numbersAndStars.number1,
                        _numbersAndStars.number2,
                        _numbersAndStars.number3,
                        _numbersAndStars.number4,
                        _numbersAndStars.number5,
                        _numbersAndStars.star1,
                        _numbersAndStars.star2
                    ),
                    _guessCount,
                    0
                )
            );
            --_buyTickets;
            ++_guessCount;
            unchecked {
                ++i;
            }
        }
        buyTickets[msg.sender] = _buyTickets;
        guessCount = _guessCount;
    }

    function addWinningNumber(
        uint8 _number1,
        uint8 _number2,
        uint8 _number3,
        uint8 _number4,
        uint8 _number5,
        uint8 _star1,
        uint8 _star2
    ) external checkLotteryStarted onlyOwner {
        require(
            block.timestamp > lotteryEndTime,
            "You can not add winning numbers before the lottery has ended."
        );

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

        require(
            winningNumbersAndStars.number1 == 0,
            "Winning Numbers Already Added"
        );

        winningNumbersAndStars = guessRandomNumberAndStars(
            _number1,
            _number2,
            _number3,
            _number4,
            _number5,
            _star1,
            _star2
        );
    }

    function annouceWinner() external checkLotteryStarted nonReentrant onlyOwner {
        uint256 _lotteryEndTime = lotteryEndTime;
        require(
            (winningNumbersAndStars.number1 != 0 &&
                winningNumbersAndStars.number2 != 0 &&
                winningNumbersAndStars.number3 != 0 &&
                winningNumbersAndStars.number4 != 0 &&
                winningNumbersAndStars.number5 != 0 &&
                winningNumbersAndStars.star1 != 0 &&
                winningNumbersAndStars.star2 != 0),
            "Please Enter Winning Numbers Before Annoucing The Winners"
        );

        require(
            block.timestamp >= _lotteryEndTime,
            "Lottery Is Not Ended Yet!"
        );

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
        distributionPercentage memory distributionFees = distributionFee;

        prizes memory prize = prizes(0, 0, 0, 0, 0, 0);

        prize.prize1 = (poolPrize * distributionFees.prize1) / 10000;
        prize.prize2 = (poolPrize * distributionFees.prize2) / 10000;
        prize.prize3 = (poolPrize * distributionFees.prize3) / 10000;
        prize.prize4 = (poolPrize * distributionFees.prize4) / 10000;
        prize.prize5 = (poolPrize * distributionFees.prize5) / 10000;
        prize.prize6 = (poolPrize * distributionFees.prize6) / 10000;
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
        totalPrize memory _totalPrizeWinner = totalPrize(
            winners.totalPrize1Winner,
            winners.totalPrize2Winner,
            winners.totalPrize3Winner,
            winners.totalPrize4Winner,
            winners.totalPrize5Winner,
            winners.totalPrize6Winner
        );
        historyOfPrizeWinners memory historyOfLotteryPrizeWinnerss = historyOfPrizeWinners(
            _totalPrizeWinner.totalPrize1Winner, //prize1Winners,
            _totalPrizeWinner.totalPrize2Winner, //prize2Winners,
            _totalPrizeWinner.totalPrize3Winner, //prize3Winners,
            _totalPrizeWinner.totalPrize4Winner, //prize4Winners,
            _totalPrizeWinner.totalPrize5Winner, //prize5Winners,
            _totalPrizeWinner.totalPrize6Winner //prize6Winners,
        );
        historyOfPrizePerPersonAmount memory historyOfPrizePerPersonAmountss = historyOfPrizePerPersonAmount(
            calculatePrize(prize.prize1, _totalPrizeWinner.totalPrize1Winner), //prize1PerPersonAmount,
            calculatePrize(prize.prize2, _totalPrizeWinner.totalPrize2Winner), //prize2PerPersonAmount,
            calculatePrize(prize.prize3, _totalPrizeWinner.totalPrize3Winner), //prize3PerPersonAmount,
            calculatePrize(prize.prize4, _totalPrizeWinner.totalPrize4Winner), //prize4PerPersonAmount,
            calculatePrize(prize.prize5, _totalPrizeWinner.totalPrize5Winner), //prize5PerPersonAmount,
            calculatePrize(prize.prize6, _totalPrizeWinner.totalPrize6Winner) //prize6PerPersonAmount
        );

        historyOfPrizeTotalAmount memory historyOfPrizeTotalAmountss = historyOfPrizeTotalAmount(
            poolPrize, //totalPrize,
            block.timestamp,
            guessCount,
            prize.prize1, //prize1PerPersonAmount,
            prize.prize2, //prize2PerPersonAmount,
            prize.prize3, //prize3PerPersonAmount,
            prize.prize4, //prize4PerPersonAmount,
            prize.prize5, //prize5PerPersonAmount,
            prize.prize6, //prize6PerPersonAmount,
            maintenanceStakeAndGoodCausesAmount //maintenanceStakeAndGoodCausesAmount
        );

        historyOfWinnigNumber memory historyOfWinningNumberss = historyOfWinnigNumber(
            winningNumbersAndStars.number1, //number1,
            winningNumbersAndStars.number2, //number2,
            winningNumbersAndStars.number3, //number3,
            winningNumbersAndStars.number4, //number4,
            winningNumbersAndStars.number5, //number5,
            winningNumbersAndStars.star1, //star1,
            winningNumbersAndStars.star2 //star2,
        );

        emit RoundHistory(
            roundNumber,
            roundHistory(
                historyOfWinningNumberss,
                historyOfPrizeTotalAmountss,
                historyOfPrizePerPersonAmountss,
                historyOfLotteryPrizeWinnerss
            ),
            0
        );
        
        // reset lottery for new round
        guessCount = 0;
        lotteryStartTime = lotteryEndTime;
        lotteryEndTime = (lotteryEndTime + 7 days);
        winningNumbersAndStars = guessRandomNumberAndStars(0, 0, 0, 0, 0, 0, 0);
        ++roundNumber;

        //Roll Over Amount To next draw if other lottery is activated or not
        if (isFridayLotteryActive) {
            bool success = usdt.transfer( fridayLotteryAddress, usdt.balanceOf(address(this)));
            require(success, "Roll Over Failed!");
        }    
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
        for (uint256 i = 0; i < _totalWinner; ) {
            emit DistributePrize(
                roundNumber,
                winners[i],
                Distribute(i, _wininnigCategory, amountPerWinner, true, 0)
            );
            bool success = usdt.transfer(winners[i], amountPerWinner);
            require(success, "Usdt Transfer Failed!");
            unchecked {
                ++i;
            }
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
        uint256 totalTickets = guessCount;

        prize1Winner = new address[](totalTickets);
        prize2Winner = new address[](totalTickets);
        prize3Winner = new address[](totalTickets);
        prize4Winner = new address[](totalTickets);
        prize5Winner = new address[](totalTickets);
        prize6Winner = new address[](totalTickets);

        {
            for (uint256 i = 0; i < totalTickets; ) {
                uint8 matchedNumber = 0;
                uint8 matchedStar = 0;
                guessInfo memory guess = guessInfos[i];
                if (
                    guess.guess.number1 == winningNumbersAndStars.number1 ||
                    guess.guess.number1 == winningNumbersAndStars.number2 ||
                    guess.guess.number1 == winningNumbersAndStars.number3 ||
                    guess.guess.number1 == winningNumbersAndStars.number4 ||
                    guess.guess.number1 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number2 == winningNumbersAndStars.number1 ||
                    guess.guess.number2 == winningNumbersAndStars.number2 ||
                    guess.guess.number2 == winningNumbersAndStars.number3 ||
                    guess.guess.number2 == winningNumbersAndStars.number4 ||
                    guess.guess.number2 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number3 == winningNumbersAndStars.number1 ||
                    guess.guess.number3 == winningNumbersAndStars.number3 ||
                    guess.guess.number3 == winningNumbersAndStars.number3 ||
                    guess.guess.number3 == winningNumbersAndStars.number4 ||
                    guess.guess.number3 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number4 == winningNumbersAndStars.number1 ||
                    guess.guess.number4 == winningNumbersAndStars.number4 ||
                    guess.guess.number4 == winningNumbersAndStars.number3 ||
                    guess.guess.number4 == winningNumbersAndStars.number4 ||
                    guess.guess.number4 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (
                    guess.guess.number5 == winningNumbersAndStars.number1 ||
                    guess.guess.number5 == winningNumbersAndStars.number5 ||
                    guess.guess.number5 == winningNumbersAndStars.number3 ||
                    guess.guess.number5 == winningNumbersAndStars.number4 ||
                    guess.guess.number5 == winningNumbersAndStars.number5
                ) {
                    ++matchedNumber;
                }
                if (matchedNumber == 5) {
                    if (
                        guess.guess.star1 == winningNumbersAndStars.star1 ||
                        guess.guess.star1 == winningNumbersAndStars.star2
                    ) {
                        ++matchedStar;
                    }
                    if (
                        guess.guess.star2 == winningNumbersAndStars.star1 ||
                        guess.guess.star2 == winningNumbersAndStars.star2
                    ) {
                        ++matchedStar;
                    }
                }
                if (matchedNumber == 5 && matchedStar == 2) {
                    uint256 winningIndex = prizeWinner.totalPrize1Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 1, true, 0, i)
                    );
                    prize1Winner[prizeWinner.totalPrize1Winner] = guess.user;
                    ++prizeWinner.totalPrize1Winner;
                } else if (matchedNumber == 5 && matchedStar == 1) {
                    uint256 winningIndex = prizeWinner.totalPrize2Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 2, true, 0, i)
                    );
                    prize2Winner[prizeWinner.totalPrize2Winner] = guess.user;
                    ++prizeWinner.totalPrize2Winner;
                } else if (matchedNumber == 5) {
                    uint256 winningIndex = prizeWinner.totalPrize3Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 3, true, 0, i)
                    );

                    prize3Winner[prizeWinner.totalPrize3Winner] = guess.user;
                    ++prizeWinner.totalPrize3Winner;
                } else if (matchedNumber == 4) {
                    uint256 winningIndex = prizeWinner.totalPrize4Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 4, true, 0, i)
                    );

                    prize4Winner[prizeWinner.totalPrize4Winner] = guess.user;
                    ++prizeWinner.totalPrize4Winner;
                } else if (matchedNumber == 3) {
                    uint256 winningIndex = prizeWinner.totalPrize5Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 5, true, 0, i)
                    );

                    prize5Winner[prizeWinner.totalPrize5Winner] = guess.user;
                    ++prizeWinner.totalPrize5Winner;
                } else if (matchedNumber == 2) {
                    uint256 winningIndex = prizeWinner.totalPrize6Winner;
                    emit TicketWinner(
                        roundNumber,
                        guess.user,
                        Ticketwinner(winningIndex, 6, true, 0, i)
                    );
                    prize6Winner[prizeWinner.totalPrize6Winner] = guess.user;
                    ++prizeWinner.totalPrize6Winner;
                }
                unchecked {
                    ++i;
                }
            }
        }
    }

    function changeTicketPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Ticket price must be greater than 0");

        ticketPrice = _price;
    }

    function getMaintenanceStakeAndGoodCausesFee()
        external
        pure
        returns (uint16)
    {
        return maintenanceStakeAndGoodCausesFee;
    }

    function changeMaintenanceStakeAndGoodCausesAddress(
        address _maintenanceStakeAndGoodCausesAddress
    ) external onlyOwner {
        maintenanceStakeAndGoodCauses = _maintenanceStakeAndGoodCausesAddress;
    }

    function getDistributionFee()
        external
        view
        returns (distributionPercentage memory)
    {
        return distributionFee;
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
        lotteryEndTime = lotteryStartTime + 7 days;
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
            guessCount == 0,
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
        lotteryEndTime = _lotteryStartTime + 7 days;
        isTicketCanBeSold = true;
        isLotteryStarted = true;
    }

    function getCurrentTotalPlayers() external view returns (uint256) {
        return guessCount;
    }

    function transferOwnerShip(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function getTotalBuyTickets() external view returns (uint256) {
        return buyTickets[msg.sender];
    }

    function setFridayLotteryAddress(address _fridayLotteryAddress)
        external
        onlyOwner
    {
        fridayLotteryAddress = _fridayLotteryAddress;
    }

    function setFridayLotteryActive(bool _isActive) external onlyOwner {
        isFridayLotteryActive = _isActive;
    }
}