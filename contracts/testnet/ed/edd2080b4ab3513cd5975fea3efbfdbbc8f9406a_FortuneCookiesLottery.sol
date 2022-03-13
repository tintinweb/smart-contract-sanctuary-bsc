// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IFortuneCookiesLottery.sol';
import './IRandomNumberGenerator.sol';
import './SafeERC20.sol';
import './IERC20.sol';
import './Address.sol';
import './Ownable.sol';
import './ReentrancyGuard.sol';

/** @title FortuneCookiesLottery Lottery.
 * @notice It is a contract for a lottery system using randomness provided externally.
 */
contract FortuneCookiesLottery is ReentrancyGuard, IFortuneCookiesLottery, Ownable {
    using SafeERC20 for IERC20;

    address public injectorAddress;
    address public operatorAddress;
    address public treasuryAddress;
    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public initialLotteryId;
    uint256 public currentLotteryId;
    uint256 public currentTicketId;

    uint256 public maxNumberTicketsPerBuyOrClaim = 100;

    uint256 public maxPriceTicketInCalcifire = 1000 ether;
    uint256 public minPriceTicketInCalcifire = 0.001 ether;

    uint256 public pendingInjectionNextLottery;

    uint256 public constant MIN_DISCOUNT_DIVISOR = 300;
    uint256 public constant MIN_LENGTH_LOTTERY = 1 hours - 5 minutes; // 1 hour
    uint256 public constant MAX_LENGTH_LOTTERY = 7 days + 5 minutes; // 7 days
    uint256 public constant MAX_TREASURY_FEE = 3000; // 30%
    uint256 public constant MAX_BURN_FEE = 2000; // 20%

    IERC20 public calcifireToken;
    IRandomNumberGenerator public randomGenerator;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 priceTicketInCalcifire;
        uint256 discountDivisor;
        uint256[5] rewardsBreakdown; // 0: 1 matching number // 4: 5 matching numbers
        uint256 treasuryFee; // 500: 5% // 200: 2% // 50: 0.5%
        uint256 treasuryAmount; // 500: 5% // 200: 2% // 50: 0.5%
        uint256 burnFee; //20%
        uint256 burnAmount;
        uint256[5] calcifirePerBracket;
        uint256[5] countWinnersPerBracket;
        uint256 firstTicketId;
        uint256 firstTicketIdNextLottery;
        uint256 amountCollectedInCalcifire;
        uint256 amountToShareToWinners;
        uint32 finalNumber;
    }

    struct Ticket {
        uint32 number;
        address owner;
    }

    // Mapping are cheaper than arrays
    mapping(uint256 => Lottery) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;

    // Bracket calculator is used for verifying claims for ticket prizes
    mapping(uint32 => uint32) private _bracketCalculator;

    // Keeps track of number of ticket per unique combination for each lotteryId
    mapping(uint256 => mapping(uint32 => uint256)) private _numberTicketsPerLotteryId;

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

    event AdminTokenRecovery(address token, uint256 amount);
    event LotteryClose(uint256 indexed lotteryId, uint256 firstTicketIdNextLottery);
    event LotteryInjection(uint256 indexed lotteryId, uint256 injectedAmount);
    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 endTime,
        uint256 priceTicketInCalcifire,
        uint256 firstTicketId,
        uint256 injectedAmount
    );
    event LotteryNumberDrawn(uint256 indexed lotteryId, uint256 finalNumber, uint256 countWinningTickets);
    event NewOperatorAndTreasuryAndInjectorAddresses(address operator, address treasury, address injector);
    event NewRandomGenerator(address indexed randomGenerator);
    event TicketsPurchase(address indexed buyer, uint256 indexed lotteryId, uint256 numberTickets);
    event TicketsClaim(address indexed claimer, uint256 amount, uint256 indexed lotteryId, uint256 numberTickets);

    /**
     * @notice Constructor
     * @dev RandomNumberGenerator must be deployed prior to this contract
     * @param _calcifireTokenAddress: address of the CALCIFIRE token
     * @param _randomGeneratorAddress: address of the RandomGenerator contract used to work with ChainLink VRF
     */
    constructor(address _calcifireTokenAddress, address _randomGeneratorAddress, uint256 _initialLotteryId) {
        calcifireToken = IERC20(_calcifireTokenAddress);
        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);
        initialLotteryId = _initialLotteryId;
        currentLotteryId = _initialLotteryId;

        // Initializes a mapping
        _bracketCalculator[0] = 1;
        _bracketCalculator[1] = 11;
        _bracketCalculator[2] = 111;
        _bracketCalculator[3] = 1111;
        _bracketCalculator[4] = 11111;
    }

    function randomTicket(uint256 ticketId) private view returns (uint32) {
        uint256 randomHash = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, ticketId)));

        return uint32(100000 + (randomHash % 100000));
    }

    /**
     * @notice Buy tickets for the current lottery
     * @param _lotteryId: lotteryId
     * @param _ticketAmount: amount of tickets to buy
     * @dev Callable by users
     */
    function buyTickets(uint256 _lotteryId, uint256 _ticketAmount)
        external
        override
        notContract
        nonReentrant
    {
        require(_ticketAmount != 0, "No ticket specified");
        require(_ticketAmount <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");

        require(_lotteries[_lotteryId].status == Status.Open, "Lottery is not open");
        require(block.timestamp < _lotteries[_lotteryId].endTime, "Lottery is over");

        // Initializes thisTicketNumber
        uint32 thisTicketNumber;

        // Calculate number of CALCIFIRE to this contract
        uint256 amountCalcifireToTransfer = _calculateTotalPriceForBulkTickets(
            _lotteries[_lotteryId].discountDivisor,
            _lotteries[_lotteryId].priceTicketInCalcifire,
            _ticketAmount
        );

        // Transfer CALCIFIRE tokens to this contract
        calcifireToken.safeTransferFrom(address(msg.sender), address(this), amountCalcifireToTransfer);

        // Increment the total amount collected for the lottery round
        _lotteries[_lotteryId].amountCollectedInCalcifire += amountCalcifireToTransfer;

        for (uint256 i = 0; i < _ticketAmount; i++) {
            thisTicketNumber = randomTicket(currentTicketId);

            require((thisTicketNumber >= 100000) && (thisTicketNumber <= 199999), "Outside range");

            _numberTicketsPerLotteryId[_lotteryId][1 + (thisTicketNumber % 10)]++;
            _numberTicketsPerLotteryId[_lotteryId][11 + (thisTicketNumber % 100)]++;
            _numberTicketsPerLotteryId[_lotteryId][111 + (thisTicketNumber % 1000)]++;
            _numberTicketsPerLotteryId[_lotteryId][1111 + (thisTicketNumber % 10000)]++;
            _numberTicketsPerLotteryId[_lotteryId][11111 + (thisTicketNumber % 100000)]++;

            _userTicketIdsPerLotteryId[msg.sender][_lotteryId].push(currentTicketId);

            _tickets[currentTicketId] = Ticket({number: thisTicketNumber, owner: msg.sender});

            // Increase lottery ticket number
            currentTicketId++;
        }

        emit TicketsPurchase(msg.sender, _lotteryId, _ticketAmount);
    }

    /**
     * @notice Claim a set of winning tickets for a lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds
    ) external override notContract nonReentrant {
        require(_ticketIds.length != 0, "Length must be >0");
        require(_ticketIds.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");
        require(_lotteries[_lotteryId].status == Status.Claimable, "Lottery not claimable");

        // Initializes the rewardInCalcifireToTransfer
        uint256 rewardInCalcifireToTransfer;

        for (uint256 i = 0; i < _ticketIds.length; i++) {

            uint256 thisTicketId = _ticketIds[i];

            require(_lotteries[_lotteryId].firstTicketIdNextLottery > thisTicketId, "TicketId too high");
            require(_lotteries[_lotteryId].firstTicketId <= thisTicketId, "TicketId too low");
            require(msg.sender == _tickets[thisTicketId].owner, "Not the owner");

            // Update the lottery ticket owner to 0x address
            _tickets[thisTicketId].owner = address(0);

            uint256 rewardForTicketId = _calculateRewardsForTicketId(_lotteryId, thisTicketId);

            // Check user claim is valid
            require(rewardForTicketId != 0, "No prize for this ticket");

            // Increment the reward to transfer
            rewardInCalcifireToTransfer += rewardForTicketId;
        }

        // Transfer money to msg.sender
        calcifireToken.safeTransfer(msg.sender, rewardInCalcifireToTransfer);

        emit TicketsClaim(msg.sender, rewardInCalcifireToTransfer, _lotteryId, _ticketIds.length);
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

        // Request a random number from the generator based on a seed
        randomGenerator.getRandomNumber();

        _lotteries[_lotteryId].status = Status.Close;

        emit LotteryClose(_lotteryId, currentTicketId);
    }

    /**
     * @notice Draw the final number, calculate reward in CALCIFIRE per group, and make lottery claimable
     * @param _lotteryId: lottery id
     * @param _autoInjection: reinjects funds into next lottery (vs. withdrawing all)
     * @dev Callable by operator
     */
    function drawFinalNumberAndMakeLotteryClaimable(uint256 _lotteryId, bool _autoInjection)
        external
        override
        onlyOperator
        nonReentrant
    {
        require(_lotteries[_lotteryId].status == Status.Close, "Lottery not close");
        require(_lotteryId == randomGenerator.viewLatestLotteryId(), "Numbers not drawn");

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        uint32 finalNumber = randomGenerator.viewRandomResult();

        // Initialize a number to count addresses in the previous bracket
        uint256 numberAddressesInPreviousBracket;

        // Initializes the amount to withdraw to treasury
        uint256 amountToWithdrawToTreasury = ((_lotteries[_lotteryId].amountCollectedInCalcifire) * (_lotteries[_lotteryId].treasuryFee)) /10000;

        // Initializes burn amount
        uint256 amountToBurn = ((_lotteries[_lotteryId].amountCollectedInCalcifire) * (_lotteries[_lotteryId].burnFee)) /10000;

        // Calculate the amount to share post treasury and burn fee
        uint256 amountToShareToWinners = ( _lotteries[_lotteryId].amountCollectedInCalcifire - (amountToWithdrawToTreasury + amountToBurn) );

        // Calculate prizes in CALCIFIRE for each bracket by starting from the highest one
        for (uint32 i = 0; i < 5; i++) {
            uint32 j = 4 - i;
            uint32 transformedWinningNumber = _bracketCalculator[j] + (finalNumber % (uint32(10)**(j + 1)));

            _lotteries[_lotteryId].countWinnersPerBracket[j] =
                _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] -
                numberAddressesInPreviousBracket;

            // A. If number of users for this _bracket number is superior to 0
            if (
                (_numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] - numberAddressesInPreviousBracket) !=
                0
            ) {
                // B. If rewards at this bracket are > 0, calculate, else, report the numberAddresses from previous bracket
                if (_lotteries[_lotteryId].rewardsBreakdown[j] != 0) {
                    _lotteries[_lotteryId].calcifirePerBracket[j] =
                        ((_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners) /
                            (_numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber] -
                                numberAddressesInPreviousBracket)) /
                        10000;

                    // Update numberAddressesInPreviousBracket
                    numberAddressesInPreviousBracket = _numberTicketsPerLotteryId[_lotteryId][transformedWinningNumber];
                }
                // A. No CALCIFIRE to distribute, they are added to the amount to withdraw to treasury address
            } else {
                _lotteries[_lotteryId].calcifirePerBracket[j] = 0;

                amountToWithdrawToTreasury +=
                    (_lotteries[_lotteryId].rewardsBreakdown[j] * amountToShareToWinners) /
                    10000;
            }
        }

        // Update internal statuses for lottery
        _lotteries[_lotteryId].finalNumber = finalNumber;
        _lotteries[_lotteryId].status = Status.Claimable;


        if (_autoInjection == false) {
            amountToWithdrawToTreasury += (_lotteries[_lotteryId].amountCollectedInCalcifire - amountToShareToWinners);
        }
        else {
          amountToWithdrawToTreasury = 0;
          pendingInjectionNextLottery = amountToWithdrawToTreasury + (_lotteries[_lotteryId].amountCollectedInCalcifire - amountToShareToWinners);
        }

        _lotteries[_lotteryId].burnAmount = amountToBurn;
        _lotteries[_lotteryId].treasuryAmount = amountToWithdrawToTreasury;
        _lotteries[_lotteryId].amountToShareToWinners = amountToShareToWinners;

        // Transfer CALCIFIRE to burn address
        calcifireToken.safeTransfer(burnAddress, amountToBurn);

        // Transfer CALCIFIRE to treasury address
        calcifireToken.safeTransfer(treasuryAddress, amountToWithdrawToTreasury);

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
        require(_lotteries[currentLotteryId].status == Status.Claimable, "Lottery not in claimable");

        // Request a random number from the generator based on a seed
        IRandomNumberGenerator(_randomGeneratorAddress).getRandomNumber();

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        IRandomNumberGenerator(_randomGeneratorAddress).viewRandomResult();

        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);

        emit NewRandomGenerator(_randomGeneratorAddress);
    }

    /**
     * @notice Inject funds
     * @param _lotteryId: lottery id
     * @param _amount: amount to inject in CALCIFIRE token
     * @dev Callable by owner or injector address
     */
    function injectFunds(uint256 _lotteryId, uint256 _amount) external override onlyOwnerOrInjector {
        require(_lotteries[_lotteryId].status == Status.Open, "Lottery not open");

        calcifireToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        _lotteries[_lotteryId].amountCollectedInCalcifire += _amount;

        emit LotteryInjection(_lotteryId, _amount);
    }

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     * @param _endTime: endTime of the lottery
     * @param _priceTicketInCalcifire: price of a ticket in CALCIFIRE
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _rewardsBreakdown: breakdown of rewards per bracket (must sum to 10,000)
     * @param _treasuryFee: treasury fee (10,000 = 100%, 100 = 1%)
     * @param _burnFee: % transferred to burn address
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicketInCalcifire,
        uint256 _discountDivisor,
        uint256[5] calldata _rewardsBreakdown,
        uint256 _treasuryFee,
        uint256 _burnFee
    ) external override onlyOperator {
        require(
            (currentLotteryId == initialLotteryId) || (_lotteries[currentLotteryId].status == Status.Claimable),
            "Not time to start lottery"
        );

        require(
            ((_endTime - block.timestamp) > MIN_LENGTH_LOTTERY) && ((_endTime - block.timestamp) < MAX_LENGTH_LOTTERY),
            "Lottery length outside of range"
        );

        require(
            (_priceTicketInCalcifire >= minPriceTicketInCalcifire) && (_priceTicketInCalcifire <= maxPriceTicketInCalcifire),
            "Outside of limits"
        );

        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Discount divisor too low");
        require(_treasuryFee <= MAX_TREASURY_FEE, "Treasury fee too high");
        require(_burnFee <= MAX_BURN_FEE, "Burn fee too high");

        require(
            (_rewardsBreakdown[0] +
                _rewardsBreakdown[1] +
                _rewardsBreakdown[2] +
                _rewardsBreakdown[3] +
                _rewardsBreakdown[4]) == 10000,
            "Rewards must equal 10000"
        );

        currentLotteryId++;

        _lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: _endTime,
            priceTicketInCalcifire: _priceTicketInCalcifire,
            discountDivisor: _discountDivisor,
            rewardsBreakdown: _rewardsBreakdown,
            treasuryFee: _treasuryFee,
            treasuryAmount: 0,
            burnFee: _burnFee,
            burnAmount: 0,
            calcifirePerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            countWinnersPerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            firstTicketId: currentTicketId,
            firstTicketIdNextLottery: currentTicketId,
            amountCollectedInCalcifire: pendingInjectionNextLottery,
            amountToShareToWinners: 0,
            finalNumber: 0
        });

        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            _endTime,
            _priceTicketInCalcifire,
            currentTicketId,
            pendingInjectionNextLottery
        );

        pendingInjectionNextLottery = 0;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(calcifireToken), "Cannot be CALCIFIRE token");

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Set CALCIFIRE price ticket upper/lower limit
     * @dev Only callable by owner
     * @param _minPriceTicketInCalcifire: minimum price of a ticket in CALCIFIRE
     * @param _maxPriceTicketInCalcifire: maximum price of a ticket in CALCIFIRE
     */
    function setMinAndMaxTicketPriceInCalcifire(uint256 _minPriceTicketInCalcifire, uint256 _maxPriceTicketInCalcifire)
        external
        onlyOwner
    {
        require(_minPriceTicketInCalcifire <= _maxPriceTicketInCalcifire, "minPrice must be < maxPrice");

        minPriceTicketInCalcifire = _minPriceTicketInCalcifire;
        maxPriceTicketInCalcifire = _maxPriceTicketInCalcifire;
    }

    /**
     * @notice Set max number of tickets
     * @dev Only callable by owner
     */
    function setMaxNumberTicketsPerBuy(uint256 _maxNumberTicketsPerBuy) external onlyOwner {
        require(_maxNumberTicketsPerBuy != 0, "Must be > 0");
        maxNumberTicketsPerBuyOrClaim = _maxNumberTicketsPerBuy;
    }

    /**
     * @notice Set operator, treasury, and injector addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     * @param _treasuryAddress: address of the treasury
     * @param _injectorAddress: address of the injector
     */
    function setOperatorAndTreasuryAndInjectorAddresses(
        address _operatorAddress,
        address _treasuryAddress,
        address _injectorAddress
    ) external onlyOwner {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(_treasuryAddress != address(0), "Cannot be zero address");
        require(_injectorAddress != address(0), "Cannot be zero address");

        operatorAddress = _operatorAddress;
        treasuryAddress = _treasuryAddress;
        injectorAddress = _injectorAddress;

        emit NewOperatorAndTreasuryAndInjectorAddresses(_operatorAddress, _treasuryAddress, _injectorAddress);
    }

    /**
     * @notice Calculate price of a set of tickets
     * @param _discountDivisor: divisor for the discount
     * @param _priceTicket price of a ticket (in CALCIFIRE)
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

    /**
     * @notice View current lottery id
     */
    function viewCurrentLotteryId() external view override returns (uint256) {
        return currentLotteryId;
    }

    /**
     * @notice View lottery information
     * @param _lotteryId: lottery id
     */
    function viewLottery(uint256 _lotteryId) external view returns (Lottery memory) {
        return _lotteries[_lotteryId];
    }

    /**
     * @notice View if ticket is already owned
     * @param _ticketId: Id of the ticket
     */
    function viewIfTicketIsOwned(uint256 _ticketId) public view returns ( bool )
    {
        if (_tickets[_ticketId].owner == address(0)) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @notice View ticker statuses and numbers for an array of ticket ids
     * @param _ticketIds: array of _ticketId
     */
    function viewNumbersAndStatusesForTicketIds(uint256[] calldata _ticketIds)
        external
        view
        returns (uint32[] memory, bool[] memory)
    {
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
     */
    function viewRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId
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

        return _calculateRewardsForTicketId(_lotteryId, _ticketId);
    }

    /**
     * @notice View total user rewards for a given lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     */
    function viewTotalRewardForTickets(
        uint256 _lotteryId,
        uint256[] calldata _ticketIds
    ) external view returns (uint256) {

        // Check lottery is in claimable status
        if (_lotteries[_lotteryId].status != Status.Claimable) {
            return 0;
        }

        // Initializes the rewardInCalcifireToTransfer
        uint256 rewardInCalcifireToTransfer;

        for (uint256 i = 0; i < _ticketIds.length; i++) {

            uint256 thisTicketId = _ticketIds[i];

            // Check ticketId is within range
            if (
                (_lotteries[_lotteryId].firstTicketIdNextLottery < thisTicketId) &&
                (_lotteries[_lotteryId].firstTicketId >= thisTicketId)
            ) {
                return 0;
            }

            uint256 rewardForTicketId = _calculateRewardsForTicketId(_lotteryId, thisTicketId);

            // Check user claim is valid
            require(rewardForTicketId != 0, "No prize for this ticket");

            // Increment the reward to transfer
            rewardInCalcifireToTransfer += rewardForTicketId;
        }

        return rewardInCalcifireToTransfer;
    }

    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given lottery
     * @param _user: user address
     * @param _lotteryId: lottery id
     */
    function viewUserInfoForLotteryId(
        address _user,
        uint256 _lotteryId
    )
        external
        view
        returns (
            uint256[] memory,
            uint32[] memory,
            bool[] memory,
            uint256
        )
    {
        uint256 numberTicketsBoughtAtLotteryId = _userTicketIdsPerLotteryId[_user][_lotteryId].length;

        uint256[] memory lotteryTicketIds = new uint256[](numberTicketsBoughtAtLotteryId);
        uint32[] memory ticketNumbers = new uint32[](numberTicketsBoughtAtLotteryId);
        bool[] memory ticketStatuses = new bool[](numberTicketsBoughtAtLotteryId);

        for (uint256 i = 0; i < numberTicketsBoughtAtLotteryId; i++) {
            lotteryTicketIds[i] = _userTicketIdsPerLotteryId[_user][_lotteryId][i];
            ticketNumbers[i] = _tickets[lotteryTicketIds[i]].number;

            // True = ticket claimed
            if (_tickets[lotteryTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                // ticket not claimed (includes the ones that cannot be claimed)
                ticketStatuses[i] = false;
            }
        }

        return (lotteryTicketIds, ticketNumbers, ticketStatuses, numberTicketsBoughtAtLotteryId);
    }

    /**
     * @notice Calculate rewards for a given ticket
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     */
    function _calculateRewardsForTicketId(
        uint256 _lotteryId,
        uint256 _ticketId
    ) internal view returns (uint256) {
        // Retrieve the winning number combination
        uint32 winningTicketNumber = _lotteries[_lotteryId].finalNumber;

        // Retrieve the user number combination from the ticketId
        uint32 userNumber = _tickets[_ticketId].number;


        for (uint32 i = 4; i >= 0; i--) {
          // Apply transformation to verify the claim provided by the user is true
          uint32 transformedWinningNumber = _bracketCalculator[i] +
              (winningTicketNumber % (uint32(10)**(i + 1)));

          uint32 transformedUserNumber = _bracketCalculator[i] + (userNumber % (uint32(10)**(i + 1)));

          // Confirm that the two transformed numbers are the same, if not throw
          if (transformedWinningNumber == transformedUserNumber) {
              return _lotteries[_lotteryId].calcifirePerBracket[i];
          }
        }

        return 0;
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

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}