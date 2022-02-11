// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol';

import './interfaces/IPlearnLucky.sol';
import './interfaces/IRandomNumberGenerator.sol';

contract PlearnLucky is IPlearnLucky, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public operatorAddress;
    address public burningAddress; //Send tokens from every deposit to burn

    uint256 internal _currentLuckyId;
    //uint256 internal _currentTicketId;
    uint32 internal _currentTicketNumber;

    uint256 public maxNumberTicketsPerBuyOrClaim;
    uint256 public maxPriceTicketInPlearn;
    uint256 public minPriceTicketInPlearn;
    uint256 public maxDiffPriceUpdate;

    uint256 public maxLengthRound;
    uint256 public minLengthRound;

    uint32 public startNumber;

    IERC20Upgradeable public plearnToken;
    IRandomNumberGenerator public randomGenerator;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Lucky {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 priceTicketInPlearn;
        uint256 priceTicketInBUSD;
        uint256 discountDivisor;
        uint256 maxTicketsPerRound;
        uint256 maxTicketsPerUser;
        uint32[] countLuckyNumbersPerBracket;
        uint32 countReservePerBracket;
        uint32 firstTicketNumber;
        uint32 firstTicketNumberNextLucky;
        uint256 amountCollectedInPlearn;
        bool enableReserve;
        uint32[] luckyNumbers;
        uint32[] reserveNumbers;
    }

    // struct Ticket {
    //     uint32 number;
    //     address owner;
    // }

    // Mapping are cheaper than arrays
    mapping(uint256 => Lucky) private _lucks;
    mapping(uint256 => mapping(uint32 => address)) private _ticketOwnersPerRound;

    mapping(uint256 => mapping(uint32 => uint32)) private _confirmedTicketNumbersPerRound;

    // Keep track of user ticket ids for a given round Id
    mapping(address => mapping(uint256 => uint32[])) private _userTicketNumbersPerRound;

    modifier notContract() {
        require(!_isContract(msg.sender), 'Contract not allowed');
        require(msg.sender == tx.origin, 'Proxy contract not allowed');
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, 'Not operator');
        _;
    }

    event AdminTokenRecovery(address token, uint256 amount);
    event LuckyClose(uint256 indexed luckyId, uint32 firstTicketNumberNextLottery);
    event LuckyOpen(
        uint256 indexed luckyId,
        uint256 startTime,
        uint256 endTime,
        uint256 priceTicketInPlearn,
        uint256 priceTicketInBUSD,
        uint256 maxTicketsPerRound,
        uint256 maxTicketsPerUser,
        uint32[] countLuckyNumbersPerBracket,
        uint32 countReservePerBracket,
        uint32 firstTicketNumber
    );
    event LuckyNumbersDrawn(uint256 indexed luckyId, uint32[] luckyNumbers);
    event NewManagingAddresses(address operator, address burningAddress);
    event NewRandomGenerator(address indexed randomGenerator);
    event TicketsConfirm(address indexed confirmer, uint256 indexed luckyId, uint32[] ticketNumber, uint32[] barckets);
    event TicketsPurchase(address indexed buyer, uint256 indexed luckyId, uint256 numberTickets);
    event TicketsTransfer(address indexed from, address indexed to, uint32[] ticketNumber);

    /**
     * @notice Constructor
     * @dev RandomNumberGenerator must be deployed prior to this contract
     * @param _plearnTokenAddress: address of the Plearn token
     * @param _randomGeneratorAddress: address of the RandomGenerator contract used to work with ChainLink VRF
     */
    function initialize(address _plearnTokenAddress, address _randomGeneratorAddress) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();

        // Initializes values
        maxNumberTicketsPerBuyOrClaim = 100; //type(uint256).max;
        maxPriceTicketInPlearn = 50 ether;
        minPriceTicketInPlearn = 0.005 ether;
        maxDiffPriceUpdate = 1500; //Difference between old and new price given from oracle

        minLengthRound = 1 hours - 5 minutes; // 1 hours
        maxLengthRound = 60 days + 5 minutes; // 60 days

        startNumber = 100000;

        plearnToken = IERC20Upgradeable(_plearnTokenAddress);
        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);
    }

    /**
     * @notice Buy tickets for the current lucky
     * @param _luckyId: lucky id
     * @param _numberTickets: number of ticket want to buy
     * @dev Callable by users
     */
    function buyTickets(uint256 _luckyId, uint256 _numberTickets) external override notContract nonReentrant {
        require(_lucks[_luckyId].status == Status.Open, 'Lucky is not open');
        require(block.timestamp < _lucks[_luckyId].endTime, 'Lucky is over');
        require(_numberTickets != 0, 'Number of tickets must be > 0');
        require(_numberTickets <= maxNumberTicketsPerBuyOrClaim, 'Too many tickets');
        require(
            (_userTicketNumbersPerRound[msg.sender][_luckyId].length + _numberTickets) <=
                _lucks[_luckyId].maxTicketsPerUser,
            'Limit tickets per user each a round'
        );
        require((_currentTicketNumber + _numberTickets) <= _lucks[_luckyId].maxTicketsPerRound, 'Ticket not enough');

        // Calculate number of Plearn to this contract
        uint256 amountPlearnToTransfer = calculateTotalPriceForTickets(
            _lucks[_luckyId].discountDivisor,
            _lucks[_luckyId].priceTicketInPlearn,
            _numberTickets
        );

        // Transfer Plearn tokens to this contract
        plearnToken.safeTransferFrom(address(msg.sender), address(this), amountPlearnToTransfer);

        // Increment the total amount collected for the lottery round
        _lucks[_luckyId].amountCollectedInPlearn += amountPlearnToTransfer;

        uint32 thisTicketNumber = _currentTicketNumber;
        for (uint256 i = 0; i < _numberTickets; i++) {
            _ticketOwnersPerRound[_luckyId][thisTicketNumber] = msg.sender;
            _userTicketNumbersPerRound[msg.sender][_luckyId].push(thisTicketNumber);
            thisTicketNumber++;
        }

        _currentTicketNumber = thisTicketNumber;
        _lucks[_luckyId].firstTicketNumberNextLucky = _currentTicketNumber;

        emit TicketsPurchase(msg.sender, _luckyId, _numberTickets);
    }

    /**
     * @notice Calculate final price for bulk of tickets
     * @param _discountDivisor: divisor for the discount (the smaller it is, the greater the discount is)
     * @param _priceTicket: price of a ticket (in Plearn)
     * @param _numberTickets: number of tickets purchased
     */
    function calculateTotalPriceForTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) public pure returns (uint256) {
        require(_numberTickets != 0, 'Number of tickets must be > 0');
        if (_discountDivisor != 0) {
            return (_priceTicket * _numberTickets * (_discountDivisor + 1 - _numberTickets)) / _discountDivisor;
        } else {
            return _priceTicket * _numberTickets;
        }
    }

    /**
     * @notice Close lucky round
     * @param _luckyId: lucky id
     * @dev Callable by operator
     */
    function closeLucky(uint256 _luckyId) external override onlyOperator nonReentrant {
        require(_lucks[_luckyId].status == Status.Open, 'Lucky not open');
        require(block.timestamp > _lucks[_luckyId].endTime, 'Lucky not over');

        randomGenerator.clearRandomResults();
        randomGenerator.requestRandomNumber();

        _lucks[_luckyId].status = Status.Close;

        emit LuckyClose(_luckyId, _currentTicketNumber);
    }

    /**
     * @notice Confirm a set of lucky tickets
     * @param _luckyId: lucky id
     * @param _ticketNumbers: array of ticket numbers
     * @param _brackets: array of bracket for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function confirmTickets(
        uint256 _luckyId,
        uint32[] calldata _ticketNumbers,
        uint32[] calldata _brackets
    ) external override notContract nonReentrant {
        require(_ticketNumbers.length == _brackets.length, 'Not same length');
        require(_ticketNumbers.length != 0, 'Length must be >0');
        require(_ticketNumbers.length <= maxNumberTicketsPerBuyOrClaim, 'Too many tickets');
        require(_lucks[_luckyId].status == Status.Claimable, 'Lucky not claimable');

        for (uint256 i = 0; i < _ticketNumbers.length; i++) {
            /**
             * @notice May be not to check ticket number with first and last,
             * because have to check ticket number is a lucky number already.
             */
            (uint32 firstNumber, uint32 lastNumber) = _getFirstAndLastTicketNumberInRound(_luckyId);
            require(_ticketNumbers[i] >= firstNumber, 'Ticket number too low');
            require(_ticketNumbers[i] <= lastNumber, 'Ticket number too high');
            require(_isConfirmable(_luckyId, _ticketNumbers[i]), 'Ticket cannot be confirmed yet');

            /**
             * @note Check is owner and ticket not confiramed
             */
            require(msg.sender == _ticketOwnersPerRound[_luckyId][_ticketNumbers[i]], 'Not the owner');
            require(_confirmedTicketNumbersPerRound[_luckyId][_ticketNumbers[i]] == 0, 'Ticket is confirmed');

            /**
             * @note Check bracket
             */
            require(_brackets[i] != 0, 'Bracket must be >0');
            require((_brackets[i] - 1) < _lucks[_luckyId].countLuckyNumbersPerBracket.length, 'Bracket too high');
            (, uint32[] memory countAvailablesPerBracket) = getBracketStatus(_luckyId);
            require(countAvailablesPerBracket[_brackets[i] - 1] != 0, 'Bracket unavailable');

            _confirmedTicketNumbersPerRound[_luckyId][_ticketNumbers[i]] = _brackets[i];
        }

        emit TicketsConfirm(msg.sender, _luckyId, _ticketNumbers, _brackets);
    }

    /**
     * @notice Draw the lucky numbers
     * @param _luckyId: lucky id
     * @param _autoAllocateBracket: //auto allowcate barcket to lucky tickets
     * @dev Callable by operator
     */
    function drawLuckyNumbersAndMakeTicketConfirmable(uint256 _luckyId, bool _autoAllocateBracket)
        external
        override
        onlyOperator
        nonReentrant
    {
        require(_lucks[_luckyId].status == Status.Close, 'Lucky not close');
        require(_luckyId == randomGenerator.getLastedLuckyId(), 'Lucky numbers not drawn');

        //Withdraw burn
        _withdrawBurn(_luckyId);

        // Calculate the winner numbers based on the randomResult generated by ChainLink's fallback
        uint32[] memory luckyNumbers = randomGenerator.getRandomResults();
        uint32 countLuckyNumbersPerRound = _getCountLuckyNumbersPerRound(_luckyId);

        _lucks[_luckyId].luckyNumbers = new uint32[](countLuckyNumbersPerRound);
        if (_lucks[_luckyId].countReservePerBracket != 0) {
            _lucks[_luckyId].reserveNumbers = new uint32[](_lucks[_luckyId].countReservePerBracket);
        }

        for (uint32 i = 0; i < luckyNumbers.length; i++) {
            if (i < countLuckyNumbersPerRound) {
                _lucks[_luckyId].luckyNumbers[i] = luckyNumbers[i];
            } else {
                _lucks[_luckyId].reserveNumbers[i - countLuckyNumbersPerRound] = luckyNumbers[i];
            }
        }

        // Allocate winner tickets to brackets
        if (_autoAllocateBracket) {
            uint32 bracketIndex = 0;
            uint32 count = 0;

            for (uint256 i = 0; i < luckyNumbers.length; i++) {
                uint32 luckyNumber = luckyNumbers[i];
                _confirmedTicketNumbersPerRound[_luckyId][luckyNumber] = (bracketIndex + 1);
                count++;
                if (count == _lucks[_luckyId].countLuckyNumbersPerBracket[bracketIndex]) {
                    count = 0;
                    bracketIndex++;
                }
            }
        }

        if (!_autoAllocateBracket) {
            _lucks[_luckyId].status = Status.Claimable;
        }

        emit LuckyNumbersDrawn(_luckyId, _lucks[_luckyId].luckyNumbers);
    }

    function enableConfirmationForReserve(uint256 _luckyId) external onlyOwner {
        require(_lucks[_luckyId].status == Status.Claimable, 'Lucky not claimable');
        _lucks[_luckyId].enableReserve = true;
    }

    function getBracketStatus(uint256 _luckyId)
        public
        view
        returns (uint32[] memory countLuckyNumbersPerBracket, uint32[] memory countAvailablesPerBracket)
    {
        countAvailablesPerBracket = _lucks[_luckyId].countLuckyNumbersPerBracket;

        for (uint256 i = 0; i < _lucks[_luckyId].luckyNumbers.length; i++) {
            uint32 bracket = _confirmedTicketNumbersPerRound[_luckyId][_lucks[_luckyId].luckyNumbers[i]];
            if (bracket != 0) {
                uint32 bracketIndex = bracket - 1;
                uint32 countInBracket = countAvailablesPerBracket[bracketIndex];
                countInBracket--;
                countAvailablesPerBracket[bracketIndex] = countInBracket;
            }
        }

        return (_lucks[_luckyId].countLuckyNumbersPerBracket, countAvailablesPerBracket);
    }

    function getCountLuckyNumbersPerRound(uint256 _luckyId) external view returns (uint32) {
        return _getCountLuckyNumbersPerRound(_luckyId);
    }

    /**
     * @notice Return count of lucky numbers and reserve each a round
     */
    function getCountRandomsPerRound(uint256 _luckyId) external view override returns (uint32) {
        return _getCountLuckyNumbersPerRound(_luckyId) + _lucks[_luckyId].countReservePerBracket;
    }

    function getCountTicketsInRound(uint256 _luckyId) external view override returns (uint256) {
        return _getCountTicketsInRound(_luckyId);
    }

    /**
     * @notice Return current lucky id
     */
    function getCurrentLuckyId() external view override returns (uint256) {
        return _currentLuckyId;
    }

    /**
     * @notice Return first ticket number and last ticket number each a round
     * @param _luckyId: lucky id
     */
    function getFirstAndLastTicketNumberInRound(uint256 _luckyId)
        external
        view
        override
        returns (uint32 firstTicketNumber, uint32 lastTicketNumber)
    {
        return _getFirstAndLastTicketNumberInRound(_luckyId);
    }

    /**
     * @notice Get round information
     * @param _luckyId: round id
     */
    function getLuckyInfo(uint256 _luckyId) external view returns (Lucky memory) {
        return _lucks[_luckyId];
    }

    function getLuckyTickets(uint256 _luckyId)
        external
        view
        returns (uint32[] memory luckyNumbers, address[] memory owners)
    {
        luckyNumbers = _lucks[_luckyId].luckyNumbers;
        owners = new address[](luckyNumbers.length);

        for (uint256 i = 0; i < luckyNumbers.length; i++) {
            owners[i] = _ticketOwnersPerRound[_luckyId][luckyNumbers[i]];
        }
    }

    function getMyTicketNumbers(uint256 _luckyId) external view returns (uint32[] memory) {
        return _userTicketNumbersPerRound[msg.sender][_luckyId];
    }

    function getReserveTickets(uint256 _luckyId)
        external
        view
        returns (uint32[] memory reserveNumbers, address[] memory owners)
    {
        reserveNumbers = _lucks[_luckyId].reserveNumbers;
        owners = new address[](reserveNumbers.length);

        for (uint256 i = 0; i < reserveNumbers.length; i++) {
            owners[i] = _ticketOwnersPerRound[_luckyId][reserveNumbers[i]];
        }
    }

    function getTicketInfo(uint256 _luckyId, uint32 _ticketNumber)
        external
        view
        returns (
            address owner,
            bool isLucky,
            uint32 bracket,
            bool isConfirmed
        )
    {
        owner = _ticketOwnersPerRound[_luckyId][_ticketNumber];
        isLucky = isLuckyNumber(_luckyId, _ticketNumber);
        bracket = _confirmedTicketNumbersPerRound[_luckyId][_ticketNumber];
        isConfirmed = bracket != 0;
    }

    /**
     * @notice View user ticket ids, and statuses of user for a given lucky
     * @param _user: user address
     * @param _luckyId: lucky id
     * @param _start: cursor to start where to retrieve the tickets
     * @param _size: the number of tickets to retrieve
     */
    function getUserInfo(
        address _user,
        uint256 _luckyId,
        uint256 _start,
        uint256 _size
    )
        external
        view
        returns (
            uint32[] memory ticketNumbers,
            bool[] memory ticketStatuses,
            uint32[] memory brackets,
            uint256 index,
            uint256 all
        )
    {
        if (_size > (_userTicketNumbersPerRound[_user][_luckyId].length - _start)) {
            _size = _userTicketNumbersPerRound[_user][_luckyId].length - _start;
        }

        ticketNumbers = new uint32[](_size);
        ticketStatuses = new bool[](_size);
        brackets = new uint32[](_size);

        for (uint256 i = 0; i < _size; i++) {
            ticketNumbers[i] = _userTicketNumbersPerRound[_user][_luckyId][i + _start];
            ticketStatuses[i] = isLuckyNumber(_luckyId, ticketNumbers[i]);
            brackets[i] = _confirmedTicketNumbersPerRound[_luckyId][ticketNumbers[i]];
        }

        return (
            ticketNumbers,
            ticketStatuses,
            brackets,
            _start + _size,
            _userTicketNumbersPerRound[_user][_luckyId].length
        );
    }

    function isLuckyNumber(uint256 _luckyId, uint256 _ticketNumber) public view returns (bool) {
        bool isLucky = false;
        if (_lucks[_luckyId].status != Status.Open) {
            for (uint32 i = 0; i < _lucks[_luckyId].luckyNumbers.length; i++) {
                if (_ticketNumber == _lucks[_luckyId].luckyNumbers[i]) {
                    isLucky = true;
                    break;
                }
            }
        }
        return isLucky;
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(plearnToken), 'Cannot be Plearn token');

        IERC20Upgradeable(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Set Plearn price ticket upper/lower limit
     * @dev Only callable by owner
     * @param _minPriceTicketInPlearn: minimum price of a ticket in Plearn
     * @param _maxPriceTicketInPlearn: maximum price of a ticket in PLearn
     */
    function setMinAndMaxTicketPriceInPlearn(uint256 _minPriceTicketInPlearn, uint256 _maxPriceTicketInPlearn)
        external
        onlyOwner
    {
        require(_minPriceTicketInPlearn <= _maxPriceTicketInPlearn, 'minPrice must be < maxPrice');
        minPriceTicketInPlearn = _minPriceTicketInPlearn;
        maxPriceTicketInPlearn = _maxPriceTicketInPlearn;
    }

    /**
     * @notice Set max number of tickets
     * @dev Only callable by owner
     */
    function setMaxNumberTicketsPerBuy(uint256 _maxNumberTicketsPerBuy) external onlyOwner {
        require(_maxNumberTicketsPerBuy != 0, 'Must be > 0');
        maxNumberTicketsPerBuyOrClaim = _maxNumberTicketsPerBuy;
    }

    /**
     * @notice Set max difference between old and new price when update from oracle
     * @dev Only callable by owner
     */
    function setMaxDiffPriceUpdate(uint256 _maxDiffPriceUpdate) external onlyOwner {
        require(_maxDiffPriceUpdate != 0, 'Must be > 0');
        maxDiffPriceUpdate = _maxDiffPriceUpdate;
    }

    /**
     * @notice Set operator, and burning addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     * @param _burningAddress: address to collect burn tokens
     */
    function setManagingAddresses(address _operatorAddress, address _burningAddress) external onlyOwner {
        require(_operatorAddress != address(0), 'Cannot be zero address');
        require(_burningAddress != address(0), 'Cannot be zero address');

        operatorAddress = _operatorAddress;
        burningAddress = _burningAddress;

        emit NewManagingAddresses(_operatorAddress, _burningAddress);
    }

    /**
     * @notice Change the random generator
     * @dev The calls to functions are used to verify the new generator implements them properly.
     * It is necessary to wait for the VRF response before starting a round.
     * Callable only by the contract owner
     * @param _randomGeneratorAddress: address of the random generator
     */
    function setRandomGenerator(address _randomGeneratorAddress) external onlyOwner {
        require(_lucks[_currentLuckyId].status == Status.Claimable, 'Lucky not in claimable');

        // Request a random number from the generator based on a seed
        IRandomNumberGenerator(_randomGeneratorAddress).requestRandomNumber();

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        IRandomNumberGenerator(_randomGeneratorAddress).getRandomResults();

        randomGenerator = IRandomNumberGenerator(_randomGeneratorAddress);

        emit NewRandomGenerator(_randomGeneratorAddress);
    }

    function setStartNumber(uint32 _startNumber) external onlyOwner {
        startNumber = _startNumber;
    }

    /**
     * @notice Start lucky round
     * @dev Callable by operator
     * @param _endTime: endTime of ther lucky
     * @param _priceTicketInPlearn: price of a ticket in Plearn
     * @param _priceTicketInBUSD: price of a ticket in BUSD
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _maxTicketsPerRound: maximum of ticket to salable in each round
     * @param _maxTicketsPerUser: maximum of ticket to salable for user in each round
     * @param _countLuckyNumbersPerBracket: array of number of lucky in each round
     */
    function startLucky(
        uint256 _endTime,
        uint256 _priceTicketInPlearn, //For now
        uint256 _priceTicketInBUSD,
        uint256 _discountDivisor,
        uint256 _maxTicketsPerRound,
        uint256 _maxTicketsPerUser,
        uint32[] calldata _countLuckyNumbersPerBracket,
        uint32 _countReservePerBracket
    ) external override onlyOperator {
        require((_currentLuckyId == 0) || (_lucks[_currentLuckyId].status != Status.Open), 'Not time to start lucky');

        require(
            ((_endTime - block.timestamp) > minLengthRound) && ((_endTime - block.timestamp) < maxLengthRound),
            'Round length outside of range'
        );

        //TODO()
        //Calculation price in Plern
        //uint256 _priceTicketInPlearn = _getPriceInPlearn(_priceTicketInBUSD);

        require(
            (_priceTicketInPlearn >= minPriceTicketInPlearn) && (_priceTicketInPlearn <= maxPriceTicketInPlearn),
            'Price ticket in Plearn Outside of limits'
        );

        uint32 countLuckyNumbersPerRound = 0;
        for (uint32 i = 0; i < _countLuckyNumbersPerBracket.length; i++) {
            countLuckyNumbersPerRound += _countLuckyNumbersPerBracket[i];
        }
        countLuckyNumbersPerRound += _countReservePerBracket;
        require(countLuckyNumbersPerRound != 0, 'Number of lucky per round must be > 0');

        //Reset current ticket number
        _currentTicketNumber = startNumber;
        _currentLuckyId++;

        _lucks[_currentLuckyId] = Lucky({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: _endTime,
            priceTicketInPlearn: _priceTicketInPlearn,
            priceTicketInBUSD: _priceTicketInBUSD,
            discountDivisor: _discountDivisor,
            maxTicketsPerRound: _maxTicketsPerRound,
            maxTicketsPerUser: _maxTicketsPerUser,
            countLuckyNumbersPerBracket: _countLuckyNumbersPerBracket,
            countReservePerBracket: _countReservePerBracket,
            firstTicketNumber: _currentTicketNumber,
            firstTicketNumberNextLucky: _currentTicketNumber,
            amountCollectedInPlearn: 0,
            enableReserve: false,
            luckyNumbers: new uint32[](0),
            reserveNumbers: new uint32[](0)
        });

        emit LuckyOpen(
            _currentLuckyId,
            block.timestamp,
            _endTime,
            _priceTicketInPlearn,
            _priceTicketInBUSD,
            _maxTicketsPerRound,
            _maxTicketsPerUser,
            _countLuckyNumbersPerBracket,
            _countReservePerBracket,
            _currentTicketNumber
        );
    }

    /**
     * @notice Tranfer a set of tickets to other address
     * @param _to: the address to tranfer ownership of ticket
     * @param _luckyId: lucky id
     * @param _ticketNumbers: array of ticket number
     * @dev Callable by users only, not contract!
     */
    function tranferTickets(
        address _to,
        uint256 _luckyId,
        uint32[] calldata _ticketNumbers
    ) external override notContract nonReentrant {
        require(_to != address(0), 'Cannot be zero address');
        for (uint32 i = 0; i < _ticketNumbers.length; i++) {
            require(msg.sender == _ticketOwnersPerRound[_luckyId][_ticketNumbers[i]], 'Not the owner');
            _ticketOwnersPerRound[_luckyId][_ticketNumbers[i]] = _to;

            //Find index to start ship element
            uint32 index = 0;
            for (uint32 j = 0; j < _userTicketNumbersPerRound[msg.sender][_luckyId].length; j++) {
                if (_ticketNumbers[i] == _userTicketNumbersPerRound[msg.sender][_luckyId][j]) {
                    index = j;
                    break;
                }
            }

            //ship element in array
            //uint32[] memory thisUserTicketNumbers = _userTicketNumbersPerRound[msg.sender][_luckyId];
            for (uint32 k = index; k < _userTicketNumbersPerRound[msg.sender][_luckyId].length - 1; k++) {
                _userTicketNumbersPerRound[msg.sender][_luckyId][k] = _userTicketNumbersPerRound[msg.sender][_luckyId][
                    k + 1
                ];
            }
            _userTicketNumbersPerRound[msg.sender][_luckyId].pop();
        }

        //_userTicketNumbersPerRound[msg.sender][_luckyId].
        emit TicketsTransfer(msg.sender, _to, _ticketNumbers);
    }

    function _getCountTicketsInRound(uint256 _luckyId) internal view returns (uint256) {
        if (_lucks[_luckyId].firstTicketNumberNextLucky > _lucks[_luckyId].firstTicketNumber) {
            return _lucks[_luckyId].firstTicketNumberNextLucky - _lucks[_luckyId].firstTicketNumber;
        } else {
            return 0;
        }
    }

    function _getCountLuckyNumbersPerRound(uint256 _luckyId) internal view returns (uint32) {
        uint32 countLuckyNumbersPerRound = 0;
        for (uint32 i = 0; i < _lucks[_luckyId].countLuckyNumbersPerBracket.length; i++) {
            countLuckyNumbersPerRound += _lucks[_luckyId].countLuckyNumbersPerBracket[i];
        }
        return countLuckyNumbersPerRound;
    }

    function _getFirstAndLastTicketNumberInRound(uint256 _luckyId) internal view returns (uint32, uint32) {
        if (_lucks[_luckyId].firstTicketNumberNextLucky > _lucks[_luckyId].firstTicketNumber) {
            return (_lucks[_luckyId].firstTicketNumber, _lucks[_luckyId].firstTicketNumberNextLucky - 1);
        } else {
            return (0, 0);
        }
    }

    function _isConfirmable(uint256 _luckyId, uint32 _ticketNumber) internal view returns (bool) {
        bool isConfirmable = isLuckyNumber(_luckyId, _ticketNumber);

        //Check have endble confirmation for reserve numbers
        if (!isConfirmable && _lucks[_luckyId].enableReserve) {
            for (uint32 i; i < _lucks[_luckyId].reserveNumbers.length; i++) {
                if (_ticketNumber == _lucks[_luckyId].reserveNumbers[i]) {
                    isConfirmable = true;
                    break;
                }
            }
        }
        return isConfirmable;
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

    /**
     * @notice Withdraw burn
     * @param _luckyId: lucky Id
     * @dev Return collected amount
     */
    function _withdrawBurn(uint256 _luckyId) private {
        require(_lucks[_luckyId].status == Status.Close, 'Lucky not close');

        uint256 collectedAmount = _lucks[_luckyId].amountCollectedInPlearn;
        plearnToken.safeTransfer(burningAddress, collectedAmount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPlearnLucky {
    /**
     * @notice Buy tickets for the current lucky
     * @param _luckyId: lucky id
     * @param _numberTickets: number of ticket want to buy
     * @dev Callable by users
     */
    function buyTickets(uint256 _luckyId, uint256 _numberTickets) external;

    /**
     * @notice Close lucky round
     * @param _luckyId: lucky id
     * @dev Callable by operator
     */
    function closeLucky(uint256 _luckyId) external;

    /**
     * @notice Confirm a set of lucky tickets
     * @param _luckyId: lucky id
     * @param _ticketNumbers: array of ticket numbers
     * @param _brackets: array of bracket for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function confirmTickets(
        uint256 _luckyId,
        uint32[] calldata _ticketNumbers,
        uint32[] calldata _brackets
    ) external;

    /**
     * @notice Draw the lucky numbers
     * @param _luckyId: lucky id
     * @param _autoAllocateBracket: //auto allowcate barcket to lucky tickets
     * @dev Callable by operator
     */
    function drawLuckyNumbersAndMakeTicketConfirmable(uint256 _luckyId, bool _autoAllocateBracket) external;

    //TODO("Add note message")
    //function getBracketStatus(uint256 _luckyId) external returns (uint32[] memory, uint32[] memory);

    /**
     * @notice Return count of lucky numbers and reserve each a round
     */
    function getCountRandomsPerRound(uint256 _luckyId) external returns (uint32);

    function getCountTicketsInRound(uint256 _luckyId) external returns (uint256);

    /**
     * @notice Return current lucky id
     */
    function getCurrentLuckyId() external returns (uint256);

    /**
     * @notice Return first ticket number and last ticket number each a round
     * @param _luckyId: lucky id
     */
    function getFirstAndLastTicketNumberInRound(uint256 _luckyId)
        external
        returns (uint32 firstTicketNumber, uint32 lastTicketNumber);

    /**
     * @notice Start lucky round
     * @dev Callable by operator
     * @param _endTime: endTime of ther lucky
     * @param _priceTicketInPlearn: price of a ticket in Plearn
     * @param _priceTicketInBUSD: price of a ticket in BUSD
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     * @param _maxTicketsPerRound: maximum of ticket to salable in each round
     * @param _maxTicketsPerUser: maximum of ticket to salable for user in each round
     * @param _countLuckyNumbersPerBracket: array of number of lucky in each round
     */
    function startLucky(
        uint256 _endTime,
        uint256 _priceTicketInPlearn, //For now
        uint256 _priceTicketInBUSD,
        uint256 _discountDivisor,
        uint256 _maxTicketsPerRound,
        uint256 _maxTicketsPerUser,
        uint32[] calldata _countLuckyNumbersPerBracket,
        uint32 _countReservePerBracket
    ) external;

     /**
     * @notice Tranfer a set of tickets to other address
     * @param _to: the address to tranfer ownership of ticket
     * @param _luckyId: lucky id
     * @param _ticketNumbers: array of ticket number
     * @dev Callable by users only, not contract!
     */
    function tranferTickets(address _to, uint256 _luckyId, uint32[] calldata _ticketNumbers) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IRandomNumberGenerator {

    /**
     * @notice Clear previous random result before start new round 
     */
    function clearRandomResults() external;

    /**
     * @notice Return latest lucky id that random numbers has generated
     */
    function getLastedLuckyId() external view returns (uint256);

    /**
     * @notice Return array of randomness number
     */
    function getRandomResults() external view returns (uint32[] memory);

    /**
     * @notice Requests to generate random numbers
     */
    function requestRandomNumber() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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