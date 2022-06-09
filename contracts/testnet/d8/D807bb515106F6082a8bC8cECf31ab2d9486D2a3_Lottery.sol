// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

error Inavlid__TicketAmount();
error Usdt__TransferFailed();
error Please__BuyTicketFirst();
error Only__Owner__Allowed();
error Ticket__Already__Buy();
error Ticket__Cannot__Buy_At_This_Time();
error Lottery_Is_Not_Started_Yet();
error Lottery_Is_Not_Ended_Yet();
error LotteryEndTimeCannotBeInThePast();
error LotteryStartTimeCannotBeInThePast();
error LotteryAlreadyStarted();
error PleaseAnnouceWinnerBeforeStoppingLottery();
error Approve__Failed();

contract Lottery is Initializable {
    address public owner;
    address[] public tickets; //addresses of players who buy tickets
    uint256 public ticketPrice;
    IERC20 public usdt;

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

    guessRandomNumber[] public randomNumbers; //random guess numbers by players
    guessRandomStars[] public randomStars; //random guess stars by players

    struct distributionPercentage {
        uint256 prize1;
        uint256 prize2;
        uint256 prize3;
        uint256 prize4;
        uint256 prize5;
        uint256 prize6;
    }
    uint256 public maintenaceAndStakeHoldersFee;
    address public maintenaceAndStakeHolders;

    distributionPercentage public distributionFee; //distribution fee for each prize winner
    mapping(address => bool) public isTicketSold;

    guessRandomNumber public winningNumbers;
    guessRandomStars public winningStars;
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
        uint256 maintenaceAndStakeHoldersAmount;
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

    mapping(uint256 => historyOfPrizeWinners)
        public historyOfLotteryPrizeWinners;
    mapping(uint256 => historyOfPrizePerPersonAmount)
        public historyOfPrizePerPersonAmounts;
    mapping(uint256 => historyOfPrizeTotalAmount)
        public historyOfPrizeTotalAmounts;
    mapping(uint256 => historyOfWinnigNumber) public historyOfWinnigNumbers;

    uint256 public roundNumber;
    bool public isTicketCanBeSold;
    uint256 public lotteryStartTime;
    uint256 public lotteryEndTime;
    uint256 public cooldownTime;
    bool public isLotteryStarted;

    modifier checkTicketSold(address buyer) {
        if (isTicketSold[buyer] != true) {
            revert Please__BuyTicketFirst();
        }
        _;
    }
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Only__Owner__Allowed();
        }
        _;
    }

    modifier checkLotteryStarted() {
        if (isLotteryStarted == false) {
            revert Lottery_Is_Not_Started_Yet();
        }
        _;
    }

    event Winners(
        uint256 w1,
        uint256 w2,
        uint256 w3,
        uint256 w4,
        uint256 w5,
        uint256 w6
    );

    function initialize(
        address _usdt,
        address _maintenaceAndStakeHolders,
        uint256 _maintenaceAndStakeHoldersFee,
        uint256 _ticketPrice,
        uint256 _distributionFee1,
        uint256 _distributionFee2,
        uint256 _distributionFee3,
        uint256 _distributionFee4,
        uint256 _distributionFee5,
        uint256 _distributionFee6
    ) public initializer {
        owner = msg.sender;
        usdt = IERC20(_usdt);
        maintenaceAndStakeHolders = _maintenaceAndStakeHolders;
        maintenaceAndStakeHoldersFee = _maintenaceAndStakeHoldersFee;
        ticketPrice = _ticketPrice;
        distributionFee = distributionPercentage(
            _distributionFee1,
            _distributionFee2,
            _distributionFee3,
            _distributionFee4,
            _distributionFee5,
            _distributionFee6
        );
        roundNumber = 1;
    }

    function buyTicket(uint256 _amount) external {
        if (block.timestamp < (lotteryStartTime + cooldownTime)) {
            revert Lottery_Is_Not_Started_Yet();
        }

        if (block.timestamp > lotteryEndTime) {
            revert Lottery_Is_Not_Started_Yet();
        }

        if (_amount != ticketPrice) {
            revert Inavlid__TicketAmount();
        }

        if (isTicketSold[msg.sender] == true) {
            revert Ticket__Already__Buy();
        }

        if (isTicketCanBeSold == false) {
            revert Ticket__Cannot__Buy_At_This_Time();
        }

        bool approveSuccess = usdt.approve(address(this), _amount);

        if (approveSuccess == false) {
            revert Approve__Failed();
        }

        bool success = usdt.transferFrom(msg.sender, address(this), _amount);

        if (!success) {
            revert Usdt__TransferFailed();
        }
        isTicketSold[msg.sender] = true;
    }

    function addGuessNumber(
        uint256 _number1,
        uint256 _number2,
        uint256 _number3,
        uint256 _number4,
        uint256 _number5,
        uint256 _star1,
        uint256 _star2
    ) external checkTicketSold(msg.sender) {
        isTicketSold[msg.sender] = false;
        tickets.push(msg.sender);
        randomNumbers.push(
            guessRandomNumber(_number1, _number2, _number3, _number4, _number5)
        );
        randomStars.push(guessRandomStars(_star1, _star2));
    }

    function addWinningNumber(
        uint256 _number1,
        uint256 _number2,
        uint256 _number3,
        uint256 _number4,
        uint256 _number5,
        uint256 _star1,
        uint256 _star2
    ) external onlyOwner {
        winningNumbers = guessRandomNumber(
            _number1,
            _number2,
            _number3,
            _number4,
            _number5
        );
        winningStars = guessRandomStars(_star1, _star2);
    }

    function annouceWinner() external onlyOwner {
        // if (block.timestamp < (lotteryEndTime)) {
        //     revert Lottery_Is_Not_Ended_Yet();
        // }

        require(block.timestamp < lotteryEndTime,"Lottery Is Not Ended Yet!");

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
        prizes memory prize;
        prize.prize1 = (poolPrize * distributionFee.prize1) / 10000;
        prize.prize2 = (poolPrize * distributionFee.prize2) / 10000;
        prize.prize3 = (poolPrize * distributionFee.prize3) / 10000;
        prize.prize4 = (poolPrize * distributionFee.prize4) / 10000;
        prize.prize5 = (poolPrize * distributionFee.prize5) / 10000;
        prize.prize6 = (poolPrize * distributionFee.prize6) / 10000;
        uint256 maintenanceAndStakeHoldersAmount = (poolPrize *
            maintenaceAndStakeHoldersFee) / 10000;

        emit Winners(
            winners.totalPrize1Winner,
            winners.totalPrize2Winner,
            winners.totalPrize3Winner,
            winners.totalPrize4Winner,
            winners.totalPrize5Winner,
            winners.totalPrize6Winner
        );

        if (winners.totalPrize1Winner > 0) {
            distributePrize(
                winners.totalPrize1Winner,
                prize1Winner,
                prize.prize1
            );
        }
        if (winners.totalPrize2Winner > 0) {
            distributePrize(
                winners.totalPrize2Winner,
                prize2Winner,
                prize.prize2
            );
        }
        if (winners.totalPrize3Winner > 0) {
            distributePrize(
                winners.totalPrize3Winner,
                prize3Winner,
                prize.prize3
            );
        }
        if (winners.totalPrize4Winner > 0) {
            distributePrize(
                winners.totalPrize4Winner,
                prize4Winner,
                prize.prize4
            );
        }
        if (winners.totalPrize5Winner > 0) {
            distributePrize(
                winners.totalPrize5Winner,
                prize5Winner,
                prize.prize5
            );
        }
        if (winners.totalPrize6Winner > 0) {
            distributePrize(
                winners.totalPrize6Winner,
                prize6Winner,
                prize.prize6
            );
        }

        sendMaintenaceAndStakeHoldersAmount(maintenanceAndStakeHoldersAmount);

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
            maintenanceAndStakeHoldersAmount //maintenaceAndStakeHoldersAmount
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

        //reset lottery for new round
        delete tickets;
        delete randomNumbers;
        delete randomStars;
        lotteryStartTime = block.timestamp;
        lotteryEndTime = (block.timestamp + 7 minutes);
        winningNumbers = guessRandomNumber(0, 0, 0, 0, 0);
        winningStars = guessRandomStars(0, 0);
        roundNumber++;
    }

    function calculatePrize(uint256 prize, uint256 total)
        internal
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
        uint256 prize
    ) internal {
        uint256 amountPerWinner = prize / _totalWinner;
        for (uint256 i = 0; i < _totalWinner; i++) {
            bool success = usdt.transfer(winners[i], amountPerWinner);
            if (!success) {
                revert Usdt__TransferFailed();
            }
        }
    }

    function sendMaintenaceAndStakeHoldersAmount(uint256 _amount) internal {
        bool success = usdt.transfer(maintenaceAndStakeHolders, _amount);
        if (!success) {
            revert Usdt__TransferFailed();
        }
    }

    function getWinners()
        internal
        view
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
                //repeat numbers are not allowed for this logic

                if (
                    randomNumbers[i].number1 == winningNumbers.number1 ||
                    randomNumbers[i].number1 == winningNumbers.number2 ||
                    randomNumbers[i].number1 == winningNumbers.number3 ||
                    randomNumbers[i].number1 == winningNumbers.number4 ||
                    randomNumbers[i].number1 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbers[i].number2 == winningNumbers.number1 ||
                    randomNumbers[i].number2 == winningNumbers.number2 ||
                    randomNumbers[i].number2 == winningNumbers.number3 ||
                    randomNumbers[i].number2 == winningNumbers.number4 ||
                    randomNumbers[i].number2 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbers[i].number3 == winningNumbers.number1 ||
                    randomNumbers[i].number3 == winningNumbers.number3 ||
                    randomNumbers[i].number3 == winningNumbers.number3 ||
                    randomNumbers[i].number3 == winningNumbers.number4 ||
                    randomNumbers[i].number3 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbers[i].number4 == winningNumbers.number1 ||
                    randomNumbers[i].number4 == winningNumbers.number4 ||
                    randomNumbers[i].number4 == winningNumbers.number3 ||
                    randomNumbers[i].number4 == winningNumbers.number4 ||
                    randomNumbers[i].number4 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (
                    randomNumbers[i].number5 == winningNumbers.number1 ||
                    randomNumbers[i].number5 == winningNumbers.number5 ||
                    randomNumbers[i].number5 == winningNumbers.number3 ||
                    randomNumbers[i].number5 == winningNumbers.number4 ||
                    randomNumbers[i].number5 == winningNumbers.number5
                ) {
                    matchedNumber++;
                }
                if (matchedNumber == 5) {
                    if (
                        randomStars[i].star1 == winningStars.star1 ||
                        randomStars[i].star1 == winningStars.star2
                    ) {
                        matchedStar++;
                    }
                    if (
                        randomStars[i].star2 == winningStars.star1 ||
                        randomStars[i].star2 == winningStars.star2
                    ) {
                        matchedStar++;
                    }
                }
                if (matchedNumber == 5 && matchedStar == 2) {
                    prize1Winner[prizeWinner.totalPrize1Winner] = tickets[i];
                    prizeWinner.totalPrize1Winner++;
                } else if (matchedNumber == 5 && matchedStar == 1) {
                    prize2Winner[prizeWinner.totalPrize2Winner] = tickets[i];
                    prizeWinner.totalPrize2Winner++;
                } else if (matchedNumber == 5) {
                    prize3Winner[prizeWinner.totalPrize3Winner] = tickets[i];
                    prizeWinner.totalPrize3Winner++;
                } else if (matchedNumber == 4) {
                    prize4Winner[prizeWinner.totalPrize4Winner] = tickets[i];
                    prizeWinner.totalPrize4Winner++;
                } else if (matchedNumber == 3) {
                    prize5Winner[prizeWinner.totalPrize5Winner] = tickets[i];
                    prizeWinner.totalPrize5Winner++;
                } else if (matchedNumber == 2) {
                    prize6Winner[prizeWinner.totalPrize6Winner] = tickets[i];
                    prizeWinner.totalPrize6Winner++;
                }
            }
        }
    }

    function changeTicketPrice(uint256 _price) external onlyOwner {
        ticketPrice = _price;
    }

    function changeMaintenaceAndStakeHoldersFee(uint256 _fee)
        external
        onlyOwner
    {
        maintenaceAndStakeHoldersFee = _fee;
    }

    function changeMaintenaceAndStakeHoldersAddress(
        address _maintenanceAndStakeHolderAddress
    ) external onlyOwner {
        maintenaceAndStakeHolders = _maintenanceAndStakeHolderAddress;
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

    function setIsTicketCanBeSold(bool _isTicketCanBeSold) external onlyOwner {
        isTicketCanBeSold = _isTicketCanBeSold;
    }

    function setLotteryStartTime(uint256 _lotteryStartTime) external onlyOwner {
        if (block.timestamp >= _lotteryStartTime) {
            revert LotteryStartTimeCannotBeInThePast();
        }
        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = _lotteryStartTime + 7 minutes;
    }

    function setLotteryEndTime(uint256 _lotteryEndTime) external onlyOwner {
        if (block.timestamp >= _lotteryEndTime) {
            revert LotteryEndTimeCannotBeInThePast();
        }
        lotteryEndTime = _lotteryEndTime;
    }

    function setCooldownTime(uint256 _cooldownTime) external onlyOwner {
        cooldownTime = _cooldownTime;
    }

    function stopLottery() external onlyOwner {
        // if (tickets.length > 0) {
        require(
            tickets.length > 0,
            "Please Annouce Winner Before Stopping Lottery"
        );
        // }
        // if (block.timestamp <= lotteryEndTime) {
        //     revert PleaseAnnouceWinnerBeforeStoppingLottery();
        // }
        require(
            block.timestamp <= lotteryEndTime,
            "Please Annouce Winner Before Stopping Lottery"
        );

        isLotteryStarted = false;
    }

    function startLottery(uint256 _lotteryStartTime) external onlyOwner {
        if (isLotteryStarted) {
            revert LotteryAlreadyStarted();
        }
        if (block.timestamp >= _lotteryStartTime) {
            revert LotteryStartTimeCannotBeInThePast();
        }
        lotteryStartTime = _lotteryStartTime;
        lotteryEndTime = lotteryStartTime + 7 minutes;
        isLotteryStarted = true;
    }

    function getCurrentTotalPlayers() external view returns (uint256) {
        return tickets.length;
    }
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}