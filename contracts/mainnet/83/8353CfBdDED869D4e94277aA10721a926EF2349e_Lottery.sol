// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import 'Ownable.sol';
import 'SafeERC20.sol';
import 'IERC20.sol';
import 'ILottery.sol';
import 'IRandomNumberGenerator.sol';
import 'ReentrancyGuard.sol';
pragma abicoder v2;

contract Lottery is ReentrancyGuard, ILottery, Ownable {
    using SafeERC20 for IERC20;

    address public injectorAddress;
    address public operatorAddress;
    address public treasuryAddress;

    uint256 public currentLotteryId;
    uint256 public currentTicketId;

    uint256 public maxNumberTicketsPerBuyOrClaim = 100;

    uint256 public maxPriceTicket = 1000000000 * (10 ** 8);
    uint256 public minPriceTicket = 0.5 * (10 ** 8);

    uint256 public pendingInjectionNextLottery;

    uint256 public constant MIN_DISCOUNT_DIVISOR = 300;
    uint256 public constant MIN_LENGTH_LOTTERY = 1 minutes;
    uint256 public constant MAX_LENGTH_LOTTERY = 7 days + 5 minutes; // 7 days
    uint256 public constant MAX_TREASURY_FEE = 10000; // 100%

    IERC20 public paymentToken;
    IRandomNumberGenerator public randomGenerator;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct LotteryItem {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 priceTicket;
        uint256 discountDivisor;
        uint256[6] rewardsBreakdown; // 0: 1 matching number // 5: 6 matching numbers
        uint256 treasuryFee; // 500: 5% // 200: 2% // 50: 0.5%
        uint256[6] tokenPerTicketInBracket;
        uint256[6] countWinnersPerBracket;
        uint256 firstTicketId;
        uint256 firstTicketIdNextLottery;
        uint256 amountCollected;
        uint256 amountRoundCollected;
        uint256 numberBuyer;
        uint32 finalNumber;
    }

    struct Ticket {
        uint32 number;
        address owner;
    }

    // Mapping are cheaper than arrays
    mapping(uint256 => LotteryItem) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;

    // Bracket calculator is used for verifying claims for ticket prizes
    mapping(uint32 => uint32) private _bracketCalculator;

    // Keeps track of number of ticket per unique combination for each lotteryId
    mapping(uint256 => mapping(uint256 => uint256)) private _numberTicketsPerLotteryId;

    // Keep track of user ticket ids for a given lotteryId
    mapping(address => mapping(uint256 => uint256[])) private _userTicketIdsPerLotteryId;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    modifier onlyOwnerOrInjector() {
        require((msg.sender == owner()) || (msg.sender == injectorAddress), "Not owner or injector");
        _;
    }

    event LotteryClose(uint256 indexed lotteryId, uint256 firstTicketIdNextLottery);
    event LotteryInjection(uint256 indexed lotteryId, uint256 injectedAmount);
    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 endTime,
        uint256 priceTicket,
        uint256 firstTicketId,
        uint256 injectedAmount
    );
    event LotteryNumberDrawn(uint256 indexed lotteryId, uint256 finalNumber, uint256 countWinningTickets);
    event NewOperatorAndTreasuryAndInjectorAddresses(address operator, address treasury, address injector);
    event NewRandomGenerator(address indexed randomGenerator);
    event TicketsPurchase(address indexed buyer, uint256 indexed lotteryId, uint256 numberTickets, uint256[] listTicketId);
    event TicketsClaim(address indexed claimer, uint256 amount, uint256 indexed lotteryId, uint256 numberTickets);

    /**
     * @notice Constructor
     * @dev RandomNumberGenerator must be deployed prior to this contract
     * @param _paymentTokenAddress: address of the payment token
     * @param _randomGeneratorAddress: address of the RandomGenerator contract used to work with ChainLink VRF
     */
    constructor(address _paymentTokenAddress, address _randomGeneratorAddress) {
        paymentToken = IERC20(_paymentTokenAddress);
        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);

        // Initializes a mapping
        _bracketCalculator[0] = 1;
        _bracketCalculator[1] = 11;
        _bracketCalculator[2] = 111;
        _bracketCalculator[3] = 1111;
        _bracketCalculator[4] = 11111;
        _bracketCalculator[5] = 111111;
    }

    /**
     * @notice Buy tickets for the current lottery
     * @param _lotteryId: lotteryId
     * @param _ticketNumbers: array of ticket numbers between 1,000,000 and 1,999,999
     * @dev Callable by users
     */
    function buyTickets(uint256 _lotteryId, uint32[] calldata _ticketNumbers) external override notContract nonReentrant {
        require(_ticketNumbers.length != 0, "No ticket specified");
        require(_ticketNumbers.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");

        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp < _lotteries[_lotteryId].endTime, "Lottery ended");

        // Calculate number of payment token to this contract
        uint256 amountTokenToTransfer = _calculateTotalPriceForBulkTickets(
            _lotteries[_lotteryId].discountDivisor,
            _lotteries[_lotteryId].priceTicket,
            _ticketNumbers.length
        );

        // Transfer payment tokens to this contract
        paymentToken.safeTransferFrom(address(msg.sender), address(this), amountTokenToTransfer);

        // Increment the total amount collected for the lottery round
        _lotteries[_lotteryId].amountCollected += amountTokenToTransfer;
        _lotteries[_lotteryId].amountRoundCollected += amountTokenToTransfer;
        uint256[] memory listTicketId = new uint256[](_ticketNumbers.length);

        for (uint256 i = 0; i < _ticketNumbers.length; i++) {
            uint32 thisTicketNumber = _ticketNumbers[i];

            require((thisTicketNumber >= 1000000) && (thisTicketNumber <= 1999999), "Outside range");

            _numberTicketsPerLotteryId[_lotteryId][1 + (thisTicketNumber % 10)]++;
            _numberTicketsPerLotteryId[_lotteryId][11 + (thisTicketNumber % 100)]++;
            _numberTicketsPerLotteryId[_lotteryId][111 + (thisTicketNumber % 1000)]++;
            _numberTicketsPerLotteryId[_lotteryId][1111 + (thisTicketNumber % 10000)]++;
            _numberTicketsPerLotteryId[_lotteryId][11111 + (thisTicketNumber % 100000)]++;
            _numberTicketsPerLotteryId[_lotteryId][111111 + (thisTicketNumber % 1000000)]++;

            if (_userTicketIdsPerLotteryId[msg.sender][_lotteryId].length == 0) {
                _lotteries[_lotteryId].numberBuyer++;
            }
            _userTicketIdsPerLotteryId[msg.sender][_lotteryId].push(currentTicketId);

            _tickets[currentTicketId] = Ticket({number : thisTicketNumber, owner : msg.sender});
            listTicketId[i] = currentTicketId;
            // Increase lottery ticket number
            currentTicketId++;
        }

        emit TicketsPurchase(msg.sender, _lotteryId, _ticketNumbers.length, listTicketId);
    }

    /**
     * @notice Claim a set of winning tickets for a lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @param _brackets: array of brackets for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external override notContract nonReentrant {
        require(_ticketIds.length == _brackets.length, "Not same length");
        require(_ticketIds.length != 0, "Length must be >0");
        require(_ticketIds.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");
        require(_lotteries[_lotteryId].status == Status.Claimable, "Lottery not claimable");

        // Initializes the rewardToTransfer
        uint256 rewardToTransfer;

        for (uint256 i = 0; i < _ticketIds.length; i++) {
            require(_brackets[i] < 6, "Bracket out of range");
            // Must be between 0 and 5

            uint256 thisTicketId = _ticketIds[i];

            require(_lotteries[_lotteryId].firstTicketIdNextLottery > thisTicketId, "TicketId too high");
            require(_lotteries[_lotteryId].firstTicketId <= thisTicketId, "TicketId too low");
            require(msg.sender == _tickets[thisTicketId].owner, "Not the owner");

            // Update the lottery ticket owner to 0x address
            _tickets[thisTicketId].owner = address(0);

            uint256 rewardForTicketId = _calculateRewardsForTicketId(_lotteryId, thisTicketId, _brackets[i]);

            // Check user is claiming the correct bracket
            require(rewardForTicketId != 0, "No prize for this bracket");

            if (_brackets[i] != 5) {
                require(_calculateRewardsForTicketId(_lotteryId, thisTicketId, _brackets[i] + 1) == 0, "Bracket must be higher");
            }

            // Increment the reward to transfer
            rewardToTransfer += rewardForTicketId;
        }

        // Transfer money to msg.sender
        paymentToken.safeTransfer(msg.sender, rewardToTransfer);

        emit TicketsClaim(msg.sender, rewardToTransfer, _lotteryId, _ticketIds.length);
    }

    /**
     * @notice Close lottery
     * @param _lotteryId: lottery id
     * @dev Callable by operator
     */
    function closeLottery(uint256 _lotteryId) external override onlyOperator nonReentrant {
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp > _lotteries[_lotteryId].endTime, "Lottery not over");
        _lotteries[_lotteryId].firstTicketIdNextLottery = currentTicketId;
        randomGenerator.getRandomNumber();
        _lotteries[_lotteryId].status = Status.Close;
        emit LotteryClose(_lotteryId, currentTicketId);
    }

    /**
     * @notice Draw the final number, calculate reward per group, and make lottery claimable
     * @param _lotteryId: lottery id
     * @param _autoInjection: reinjects funds into next lottery (vs. withdrawing all)
     * @dev Callable by operator
     */
    function calculateReward(uint256 _lotteryId, bool _autoInjection) external override onlyOperator nonReentrant {
        require(_lotteries[_lotteryId].status == Status.Close, "Lottery not close");
        require(_lotteryId == randomGenerator.viewLatestLotteryId(), "Numbers not drawn");

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        uint32 finalNumber = randomGenerator.viewRandomResult();

        // Initialize a number to count addresses in the previous bracket
        uint256 numberAddressesInPreviousBracket;

        // Initializes the amount to withdraw to treasury
        uint256 amountToWithdrawToTreasury = (_lotteries[_lotteryId].amountRoundCollected / 10000 * _lotteries[_lotteryId].treasuryFee);

        // Calculate the amount to share post-treasury fee
        uint256 amountToShareToWinners = _lotteries[_lotteryId].amountCollected - amountToWithdrawToTreasury;
        uint256 amountToPayToWinners = 0;
        // Calculate prizes for each bracket by starting from the highest one
        for (uint32 i = 0; i < 6; i++) {
            uint32 j = 5 - i;
            uint32 transformedWinningNumber = _bracketCalculator[j] + (finalNumber % (uint32(10) ** (j + 1)));

            _lotteries[_lotteryId].countWinnersPerBracket[j] = _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] - numberAddressesInPreviousBracket;

            // A. If number of users for this _bracket number is superior to 0
            if ((_lotteries[_lotteryId].countWinnersPerBracket[j]) != 0) {
                // B. If rewards at this bracket are > 0, calculate, else, report the numberAddresses from previous bracket
                if (_lotteries[_lotteryId].rewardsBreakdown[j] != 0) {
                    amountToPayToWinners += (_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners / 10000);
                    _lotteries[_lotteryId].tokenPerTicketInBracket[j] =
                    (
                    (_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners) /
                    (_lotteries[_lotteryId].countWinnersPerBracket[j])
                    ) / 10000;

                    // Update numberAddressesInPreviousBracket
                    numberAddressesInPreviousBracket = _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber];
                }
                // A. No reward token to distribute, they are added to the amount to withdraw to treasury address
            }
        }

        // Update internal statuses for lottery
        _lotteries[_lotteryId].finalNumber = finalNumber;
        _lotteries[_lotteryId].status = Status.Claimable;

        if (_autoInjection) {
            pendingInjectionNextLottery = amountToWithdrawToTreasury;
            amountToWithdrawToTreasury = 0;
        }

        pendingInjectionNextLottery += (amountToShareToWinners - amountToPayToWinners);

        // Transfer reward to treasury address
        paymentToken.safeTransfer(treasuryAddress, amountToWithdrawToTreasury);

        emit LotteryNumberDrawn(currentLotteryId, finalNumber, numberAddressesInPreviousBracket);
    }

    /**
     * @notice Change the random generator
     * @dev The calls to functions are used to verify the new generator implements them properly.
     * It is necessary to wait for the VRF response before starting a round.
     * Callable only by the contract owner
     * @param _randomGeneratorAddress: address of the random generator
     */
    function changeRandomGenerator(address _randomGeneratorAddress) external onlyOwner {
        require(_lotteries[currentLotteryId].status == Status.Claimable, "Not in claimable");
        // Request a random number from the generator
        IRandomNumberGenerator(_randomGeneratorAddress).getRandomNumber();
        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        IRandomNumberGenerator(_randomGeneratorAddress).viewRandomResult();
        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);
        emit NewRandomGenerator(_randomGeneratorAddress);
    }

    /**
     * @notice Inject funds
     * @param _lotteryId: lottery id
     * @param _amount: amount to inject
     * @dev Callable by owner or injector address
     */
    function injectFunds(uint256 _lotteryId, uint256 _amount) external override onlyOwnerOrInjector {
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");

        paymentToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        _lotteries[_lotteryId].amountCollected += _amount;

        emit LotteryInjection(_lotteryId, _amount);
    }

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     * @param _endTime: endTime of the lottery
     * @param _priceTicket: price of a ticket
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _rewardsBreakdown: breakdown of rewards per bracket (must sum to 10,000)
     * @param _treasuryFee: treasury fee (10,000 = 100%, 100 = 1%)
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicket,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown,
        uint256 _treasuryFee
    ) external override onlyOperator {
        require(
            (currentLotteryId == 0) || (_lotteries[currentLotteryId].status == Status.Claimable),
            "Not time to start lottery"
        );

        require(
            ((_endTime - block.timestamp) >= MIN_LENGTH_LOTTERY) && ((_endTime - block.timestamp) <= MAX_LENGTH_LOTTERY),
            "Lottery length outside of range"
        );

        require(
            (_priceTicket >= minPriceTicket) && (_priceTicket <= maxPriceTicket),
            "Outside of limits"
        );

        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Discount divisor too low");
        require(_treasuryFee <= MAX_TREASURY_FEE, "Treasury fee too high");

        require(
            (_rewardsBreakdown[0] +
            _rewardsBreakdown[1] +
            _rewardsBreakdown[2] +
            _rewardsBreakdown[3] +
            _rewardsBreakdown[4] +
            _rewardsBreakdown[5]) == 10000,
            "Rewards must equal 10000"
        );

        currentLotteryId++;

        _lotteries[currentLotteryId] = LotteryItem({
        status : Status.Open,
        startTime : block.timestamp,
        endTime : _endTime,
        priceTicket : _priceTicket,
        discountDivisor : _discountDivisor,
        rewardsBreakdown : _rewardsBreakdown,
        treasuryFee : _treasuryFee,
        tokenPerTicketInBracket : [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
        countWinnersPerBracket : [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
        firstTicketId : currentTicketId,
        firstTicketIdNextLottery : currentTicketId,
        amountCollected : pendingInjectionNextLottery,
        amountRoundCollected : 0,
        numberBuyer : 0,
        finalNumber : 0
        });

        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            _endTime,
            _priceTicket,
            currentTicketId,
            pendingInjectionNextLottery
        );
        pendingInjectionNextLottery = 0;
    }

    function retrieveToken(address tokenAddress, uint256 amount, address userAddress) external onlyOwnerOrInjector {
        require(tokenAddress != address(paymentToken), "Cannot be payment token");
        IERC20(tokenAddress).safeTransfer(userAddress, amount);
    }

    function setMinAndMaxTicketPrice(uint256 _minPriceTicket, uint256 _maxPriceTicket) external onlyOwner {
        require(_minPriceTicket <= _maxPriceTicket, "minPrice must be < maxPrice");
        minPriceTicket = _minPriceTicket;
        maxPriceTicket = _maxPriceTicket;
    }

    function setMaxNumberTicketsPerBuy(uint256 _maxNumberTicketsPerBuy) external onlyOwner {
        require(_maxNumberTicketsPerBuy != 0, "Must be > 0");
        maxNumberTicketsPerBuyOrClaim = _maxNumberTicketsPerBuy;
    }


    function setAddress(
        address _operatorAddress,
        address _treasuryAddress,
        address _injectorAddress
    ) external onlyOwner {
        require(_operatorAddress != address(0), "Zero address");
        require(_treasuryAddress != address(0), "Zero address");
        require(_injectorAddress != address(0), "Zero address");

        operatorAddress = _operatorAddress;
        treasuryAddress = _treasuryAddress;
        injectorAddress = _injectorAddress;

        emit NewOperatorAndTreasuryAndInjectorAddresses(_operatorAddress, _treasuryAddress, _injectorAddress);
    }

    /**
     * @notice Calculate price of a set of tickets
     * @param _discountDivisor: divisor for the discount
     * @param _priceTicket price of a ticket
     * @param _numberTickets number of tickets to buy
     */
    function calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) external pure returns (uint256) {
        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Must be >= MIN_DISCOUNT_DIVISOR");
        require(_numberTickets != 0, "Number of tickets must be > 0");

        return _calculateTotalPriceForBulkTickets(_discountDivisor, _priceTicket, _numberTickets);
    }

    function viewCurrentLotteryId() external view override returns (uint256) {
        return currentLotteryId;
    }

    function viewLottery(uint256 _lotteryId) external view returns (
        uint32 status,
        uint256 startTime,
        uint256 endTime,
        uint256 priceTicket,
        uint256 discountDivisor,
        uint256 treasuryFee,
        uint256 firstTicketId,
        uint256 firstTicketIdNextLottery,
        uint256 amountCollected,
        uint256 amountRoundCollected,
        uint256 numberBuyer,
        uint256 finalNumber
    ) {
        LotteryItem memory lottery = _lotteries[_lotteryId];
        return (
        uint32(lottery.status),
        lottery.startTime,
        lottery.endTime,
        lottery.priceTicket,
        lottery.discountDivisor,
        lottery.treasuryFee,
        lottery.firstTicketId,
        lottery.firstTicketIdNextLottery,
        lottery.amountCollected,
        lottery.amountRoundCollected,
        lottery.numberBuyer,
        lottery.finalNumber
        );
    }

    function getRewardInfo(uint256 _lotteryId) external view returns (uint256[6] memory rewardsBreakdown, uint256[6] memory tokenPerTicketInBracket, uint256[6] memory countWinnersPerBracket) {
        LotteryItem memory lottery = _lotteries[_lotteryId];
        return (
        lottery.rewardsBreakdown,
        lottery.tokenPerTicketInBracket,
        lottery.countWinnersPerBracket
        );
    }

    /**
     * @notice View ticker statuses and numbers for an array of ticket ids
     * @param _ticketIds: array of _ticketId
     */
    function viewNumbersAndStatusesForTicketIds(uint256[] calldata _ticketIds) external view returns (uint32[] memory, bool[] memory) {
        uint256 length = _ticketIds.length;
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            ticketNumbers[i] = _tickets[_ticketIds[i]].number;
            if (_tickets[_ticketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                ticketStatuses[i] = false;
            }
        }

        return (ticketNumbers, ticketStatuses);
    }

    /**
     * @notice View rewards for a given ticket, providing a bracket, and lottery id
     * @dev Computations are mostly offchain. This is used to verify a ticket!
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function viewRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) external view returns (uint256) {
        // Check lottery is in claimable status
        if (_lotteries[_lotteryId].status != Status.Claimable) {
            return 0;
        }

        // Check ticketId is within range
        if (
            (_lotteries[_lotteryId].firstTicketIdNextLottery < _ticketId) &&
            (_lotteries[_lotteryId].firstTicketId >= _ticketId)
        ) {
            return 0;
        }

        return _calculateRewardsForTicketId(_lotteryId, _ticketId, _bracket);
    }

    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given lottery
     * @param _user: user address
     * @param _lotteryId: lottery id
     * @param _cursor: cursor to start where to retrieve the tickets
     * @param _size: the number of tickets to retrieve
     */
    function viewUserInfoForLotteryId(
        address _user,
        uint256 _lotteryId,
        uint256 _cursor,
        uint256 _size
    )
    external view returns (
        uint256[] memory,
        uint32[] memory,
        bool[] memory,
        uint256
    )
    {
        uint256 length = _size;
        uint256 numberTicketsBoughtAtLotteryId = _userTicketIdsPerLotteryId[_user][_lotteryId].length;

        if (length > (numberTicketsBoughtAtLotteryId - _cursor)) {
            length = numberTicketsBoughtAtLotteryId - _cursor;
        }

        uint256[] memory lotteryTicketIds = new uint256[](length);
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            lotteryTicketIds[i] = _userTicketIdsPerLotteryId[_user][_lotteryId][i + _cursor];
            ticketNumbers[i] = _tickets[lotteryTicketIds[i]].number;

            // True = ticket claimed
            if (_tickets[lotteryTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                // ticket not claimed (includes the ones that cannot be claimed)
                ticketStatuses[i] = false;
            }
        }

        return (lotteryTicketIds, ticketNumbers, ticketStatuses, _cursor + length);
    }

    /**
     * @notice Calculate rewards for a given ticket
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function _calculateRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) internal view returns (uint256) {
        // Retrieve the winning number combination
        uint256 userNumber = _lotteries[_lotteryId].finalNumber;

        // Retrieve the user number combination from the ticketId
        uint32 winningTicketNumber = _tickets[_ticketId].number;

        // Apply transformation to verify the claim provided by the user is true
        uint32 transformedWinningNumber = _bracketCalculator[_bracket] + (winningTicketNumber % (uint32(10) ** (_bracket + 1)));

        uint256 transformedUserNumber = _bracketCalculator[_bracket] + (userNumber % (uint32(10) ** (_bracket + 1)));

        // Confirm that the two transformed numbers are the same, if not throw
        if (transformedWinningNumber == transformedUserNumber) {
            return _lotteries[_lotteryId].tokenPerTicketInBracket[_bracket];
        } else {
            return 0;
        }
    }

    /**
     * @notice Calculate final price for bulk of tickets
     * @param _discountDivisor: divisor for the discount (the smaller it is, the greater the discount is)
     * @param _priceTicket: price of a ticket
     * @param _numberTickets: number of tickets purchased
     */
    function _calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) internal pure returns (uint256) {
        return (_priceTicket * _numberTickets * (_discountDivisor + 1 - _numberTickets)) / _discountDivisor;
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}