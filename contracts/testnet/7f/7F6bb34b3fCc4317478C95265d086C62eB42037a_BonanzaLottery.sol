// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ILottery.sol";
import "./interfaces/IRandom.sol";
import "./interfaces/IReferral.sol";
import "./interfaces/ICoupon.sol";
import "./libs/ArrayLib.sol";

contract BonanzaLottery is ILottery, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant MIN_LENGTH_LOTTERY = 15 minutes - 5 minutes; // 4 hours
    uint256 public constant MAX_LENGTH_LOTTERY = 4 days + 5 minutes; // 4 days
    uint256 public constant MIN_DISCOUNT_DIVISOR = 300;

    uint256 public currentLotteryId;
    uint256 public currentTicketId;
    uint256 public maxNumberTicketsPerBuyOrClaim = 100;

    uint256 public minJpPrize = 1200 ether;
    uint256[] public maxPrizes = [500 ether, 15 ether, 1500000000 gwei];
    uint256 public maxPriceTicket = 50 ether;
    uint256 public minPriceTicket = 0.005 ether;

    IRandom public randomGenerator;
    IERC20 public currency;
    IReferral public referralProgram;
    ICoupon public couponCenter;
    address public injectorAddress;
    address public operatorAddress;
    address public treasuryAddress;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct Ticket {
        bytes6 number;
        address owner;
    }

    struct Lottery {
        uint256 startTime;
        uint256 endTime;
        uint256 priceTicket;
        uint256 discountDivisor;
        uint256 firstTicketId;
        uint256 firstTicketIdNextLottery;
        uint256 amountUsed;
        uint256 totalReferral;
        uint256 amountTotal;
        uint256 jpTreasury;
        uint256 affiliateTreasury;
        uint256 escrowCredit;
        uint256 escrowBalance;
        uint256 totalPrizeRate;
        uint256 guaranteeFundRate;
        uint256 affiliateRate;
        uint256 affiliatePrize;
        uint256[3] normalPrizeRates;
        uint256[4] prizeAmounts;
        uint256[4] ticketsWin;
        bytes finalNumber;
        Status status;
        bool saleoff;
    }

    mapping(uint256 => Lottery) private lotteries;
    mapping(uint256 => Ticket) private tickets;
    mapping(uint256 => mapping(uint256 => address)) private _ticketOwner;

    // Keep track of user ticket ids for a given lotteryId
    mapping(address => mapping(uint256 => uint256[])) private userTicketIdsPerLotteryId;

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "Not operator");
        _;
    }

    modifier onlyOwnerOrInjector() {
        require(
            (msg.sender == owner()) || (msg.sender == injectorAddress),
            "Not owner or injector"
        );
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    event AdminTokenRecovery(address token, uint256 amount);
    event LotteryClose(uint256 indexed lotteryId, uint256 firstTicketIdNextLottery);
    event LotteryInjection(
        uint256 indexed lotteryId,
        uint256 injectedAmount,
        uint256 depositAmount
    );
    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 endTime,
        uint256 priceTicket,
        uint256 firstTicketId
    );
    event LotteryNumberDrawn(uint256 indexed lotteryId, bytes finalNumber);
    event NewOperatorAndTreasuryAndInjectorAddresses(
        address operator,
        address treasury,
        address injector
    );
    event NewCoupon(address coupon);
    event NewReferral(address referral);
    event NewRandomGenerator(address indexed randomGenerator);
    event TicketsPurchase(
        address indexed buyer,
        uint256 indexed lotteryId,
        uint256 numberTickets,
        uint256 couponId
    );
    event TicketsClaim(
        address indexed claimer,
        uint256 amount,
        uint256 indexed lotteryId,
        uint256 numberTickets
    );
    event AffiliatePrizeClaim(
        address claimer,
        uint256 amount,
        uint256 lotteryId,
        uint256 ticketId
    );
    event ReceiveLuckyNumber(uint256 indexed requestId, uint256 drawID, uint256[] randomWords);

    constructor(
        address _currency,
        address _randomGeneratorAddress,
        address _coupon,
        address _referral
    ) {
        currency = IERC20(_currency);
        randomGenerator = IRandom(_randomGeneratorAddress);
        couponCenter = ICoupon(_coupon);
        referralProgram = IReferral(_referral);
    }

    function buyTickets(uint256 lotteryId, bytes6[] calldata ticketNumbers)
        external
        notContract
        nonReentrant
    {
        ICoupon.Coupon memory _coupon;
        _buyTickets(lotteryId, ticketNumbers, _coupon);
    }

    function buyTicketsWithRef(
        uint256 lotteryId,
        bytes6[] calldata ticketNumbers,
        uint256 ref
    ) external {
        if (!referralProgram.hasReferrer(msg.sender)) {
            referralProgram.addReferrer(msg.sender, ref);
        }

        ICoupon.Coupon memory _coupon;
        _buyTickets(lotteryId, ticketNumbers, _coupon);
    }

    function buyWithCoupon(
        uint256 lotteryId,
        bytes6[] calldata ticketNumbers,
        ICoupon.Coupon calldata coupon
    ) external {
        _buyTickets(lotteryId, ticketNumbers, coupon);
    }

    function buyTicketsWithBoth(
        uint256 lotteryId,
        bytes6[] calldata ticketNumbers,
        uint256 ref,
        ICoupon.Coupon calldata coupon
    ) external {
        if (!referralProgram.hasReferrer(msg.sender)) {
            referralProgram.addReferrer(msg.sender, ref);
        }
        _buyTickets(lotteryId, ticketNumbers, coupon);
    }

    /**
     * @notice Claim a set of winning tickets for a lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(uint256 _lotteryId, uint256[] calldata _ticketIds)
        external
        override
        notContract
        nonReentrant
    {
        require(_ticketIds.length != 0, "Length must be >0");
        require(_ticketIds.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");
        require(lotteries[_lotteryId].status == Status.Claimable, "Lottery not claimable");

        uint256 rewardToTransfer;

        for (uint256 i = 0; i < _ticketIds.length; i++) {
            uint256 thisTicketId = _ticketIds[i];

            require(
                lotteries[_lotteryId].firstTicketIdNextLottery > thisTicketId,
                "TicketId too high"
            );
            require(lotteries[_lotteryId].firstTicketId <= thisTicketId, "TicketId too low");
            require(msg.sender == tickets[thisTicketId].owner, "Not the owner");

            // Update the lottery ticket owner to 0x address
            tickets[thisTicketId].owner = address(0);

            uint8 _matched = ArrayLib.countMatch(
                lotteries[_lotteryId].finalNumber,
                tickets[thisTicketId].number
            );

            // Check user is claiming the correct bracket
            require(_matched >= 3, "No prize for this ticket");
            uint256 amount = lotteries[_lotteryId].prizeAmounts[6 - _matched];

            // Save the owner for affiliate program
            if (_matched == 6) {
                _ticketOwner[_lotteryId][thisTicketId] = msg.sender;
            }

            // Increment the reward to transfer
            rewardToTransfer += amount;
        }

        // Transfer money to msg.sender
        currency.safeTransfer(msg.sender, rewardToTransfer);

        emit TicketsClaim(msg.sender, rewardToTransfer, _lotteryId, _ticketIds.length);
    }

    function claimAffiliate(uint256 _lotteryId, uint256 _ticketId)
        external
        notContract
        nonReentrant
    {
        require(lotteries[_lotteryId].firstTicketIdNextLottery > _ticketId, "TicketId too high");
        require(lotteries[_lotteryId].firstTicketId <= _ticketId, "TicketId too low");
        require(lotteries[_lotteryId].affiliatePrize != 0, "No prize");

        address owner = _ticketOwner[_lotteryId][_ticketId];
        require(owner != address(0), "Claimed or not win jackpot");

        (address referrer, ) = referralProgram.getReferralAccount(owner);

        if (referrer != address(0)) {
            require(msg.sender == referrer, "Not referrer of this ticket owner");
        } else {
            _checkOwner();
        }

        _ticketOwner[_lotteryId][_ticketId] = address(0);
        currency.safeTransfer(msg.sender, lotteries[_lotteryId].affiliatePrize);

        emit AffiliatePrizeClaim(
            msg.sender,
            lotteries[_lotteryId].affiliatePrize,
            _lotteryId,
            _ticketId
        );
    }

    /**
     * @notice Close lottery
     * @param lotteryId: lottery id
     * @dev Callable by operator
     */
    function closeLottery(uint256 lotteryId) external override onlyOperator nonReentrant {
        require(lotteries[lotteryId].status == Status.Open, "Lottery not open");
        require(block.timestamp > lotteries[lotteryId].endTime, "Lottery not over");
        lotteries[lotteryId].firstTicketIdNextLottery = currentTicketId;

        randomGenerator.requestRandomNumbers();
        lotteries[lotteryId].status = Status.Close;

        emit LotteryClose(lotteryId, currentTicketId);
    }

    /**
     * @notice Draw the final number, calculate rewards, and make lottery claimable
     * @param _lotteryId: lottery id
     * @dev Callable by operator
     */
    function drawFinalNumberAndMakeLotteryClaimable(
        uint256 _lotteryId,
        uint256[4] calldata winCounts
    ) external override onlyOperator nonReentrant {
        require(lotteries[_lotteryId].status == Status.Close, "Lottery not close");
        require(_lotteryId == randomGenerator.viewLatestLotteryId(), "Numbers not drawn");

        Lottery storage lottery = lotteries[_lotteryId];

        lottery.status = Status.Claimable;
        lottery.finalNumber = randomGenerator.viewRandomResult();
        lottery.ticketsWin = winCounts;
        lottery.prizeAmounts[1] = _calculatePrize(
            lottery.amountTotal,
            lottery.normalPrizeRates[0],
            winCounts[1],
            maxPrizes[0]
        );
        lottery.prizeAmounts[2] = _calculatePrize(
            lottery.amountTotal,
            lottery.normalPrizeRates[1],
            winCounts[2],
            maxPrizes[1]
        );
        lottery.prizeAmounts[3] = _calculatePrize(
            lottery.amountTotal,
            lottery.normalPrizeRates[2],
            winCounts[3],
            maxPrizes[2]
        );

        uint256 prizeAmount = (lottery.amountTotal * lottery.totalPrizeRate) / 10000;

        uint256 jpAmount = prizeAmount -
            (lottery.prizeAmounts[1] *
                winCounts[1] +
                lottery.prizeAmounts[2] *
                winCounts[2] +
                lottery.prizeAmounts[3] *
                winCounts[3]);

        if (lottery.escrowCredit > 0) {
            uint256 guaranteeFund = (lottery.amountTotal * lottery.guaranteeFundRate) / 10000;
            if (guaranteeFund > lottery.escrowCredit) {
                jpAmount -= lottery.escrowCredit;
                lottery.escrowBalance += lottery.escrowCredit;
                lottery.escrowCredit = 0;
            } else {
                lottery.escrowCredit -= guaranteeFund;
                jpAmount -= guaranteeFund;
                lottery.escrowBalance += guaranteeFund;
            }
        }

        uint256 affiliateTreasury = (lottery.amountTotal * lottery.affiliateRate) / 10000;
        uint256 treasuryAmount = lottery.amountTotal -
            lottery.amountUsed -
            prizeAmount -
            affiliateTreasury;
        lottery.affiliateTreasury += affiliateTreasury;
        if (winCounts[0] > 0) {
            lottery.jpTreasury = 0;
            lottery.prizeAmounts[0] =
                ((lotteries[_lotteryId - 1].jpTreasury + jpAmount) * 1000) /
                winCounts[0] /
                1000;

            lottery.affiliatePrize = (lottery.affiliateTreasury * 1000) / winCounts[0] / 1000;
            lottery.affiliateTreasury = 0;
        } else {
            lottery.jpTreasury = lotteries[_lotteryId - 1].jpTreasury + jpAmount;
        }

        currency.safeTransfer(treasuryAddress, treasuryAmount);
        if (lottery.totalReferral > 0) {
            currency.safeTransfer(address(referralProgram), lottery.totalReferral);
        }

        emit LotteryNumberDrawn(currentLotteryId, lottery.finalNumber);
    }

    /**
     * @notice Inject funds. Deposit some fund to escrow and then move to jpTreasury
     * @dev Callable by owner or injector address
     */
    function injectFunds() external override onlyOwnerOrInjector {
        require(minJpPrize > lotteries[currentLotteryId].jpTreasury, "Treasury is enough funds");
        require(
            currentLotteryId == 0 || lotteries[currentLotteryId].status == Status.Claimable,
            "Lottery is not claimable"
        );
        uint256 _amount = minJpPrize - lotteries[currentLotteryId].jpTreasury;

        uint256 depositAmount;
        if (lotteries[currentLotteryId].escrowBalance >= _amount) {
            lotteries[currentLotteryId].escrowBalance -= _amount;
            depositAmount = 0;
        } else {
            lotteries[currentLotteryId].escrowBalance = 0;
            depositAmount = _amount - lotteries[currentLotteryId].escrowBalance;
        }

        lotteries[currentLotteryId].jpTreasury += _amount;
        lotteries[currentLotteryId].escrowCredit += _amount;

        if (depositAmount > 0) {
            currency.safeTransferFrom(address(msg.sender), address(this), depositAmount);
        }

        emit LotteryInjection(currentLotteryId, _amount, depositAmount);
    }

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     * @param _endTime: endTime of the lottery
     * @param _priceTicket: price of a ticket
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicket,
        uint256 _discountDivisor,
        uint256 totalPrizeRate,
        uint256[3] calldata _rates,
        uint256 guaranteeFundRate,
        uint256 affiliateFundRate,
        bool saleoff
    ) external override onlyOperator {
        require(
            (currentLotteryId == 0) || (lotteries[currentLotteryId].status == Status.Claimable),
            "Not time to start lottery"
        );
        require(
            lotteries[currentLotteryId].jpTreasury >= minJpPrize,
            "Not enough treasury to start"
        );
        require(
            ((_endTime - block.timestamp) > MIN_LENGTH_LOTTERY) &&
                ((_endTime - block.timestamp) < MAX_LENGTH_LOTTERY),
            "Lottery length outside of range"
        );

        require(
            (_priceTicket >= minPriceTicket) && (_priceTicket <= maxPriceTicket),
            "Outside of limits"
        );

        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR, "Discount divisor too low");
        require(
            _rates[1] + _rates[2] + _rates[0] + guaranteeFundRate < totalPrizeRate,
            "Rate invalid"
        );

        uint256 lastLotteryId = currentLotteryId;
        currentLotteryId++;

        lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: _endTime,
            priceTicket: _priceTicket,
            discountDivisor: _discountDivisor,
            firstTicketId: currentTicketId,
            firstTicketIdNextLottery: currentTicketId,
            amountUsed: 0,
            totalReferral: 0,
            amountTotal: 0,
            finalNumber: new bytes(6),
            prizeAmounts: [uint256(0), 0, 0, 0],
            ticketsWin: [uint256(0), 0, 0, 0],
            jpTreasury: 0,
            affiliateTreasury: lotteries[lastLotteryId].affiliateTreasury,
            escrowCredit: lotteries[lastLotteryId].escrowCredit,
            escrowBalance: lotteries[lastLotteryId].escrowBalance,
            totalPrizeRate: totalPrizeRate,
            normalPrizeRates: _rates,
            guaranteeFundRate: guaranteeFundRate,
            affiliateRate: affiliateFundRate,
            affiliatePrize: 0,
            saleoff: saleoff
        });

        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            _endTime,
            _priceTicket,
            currentTicketId
        );
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev Only callable by owner.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(currency), "Cannot be currency token");

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Change the random generator
     * @dev The calls to functions are used to verify the new generator implements them properly.
     * It is necessary to wait for the VRF response before starting a round.
     * Callable only by the contract owner
     * @param _randomGeneratorAddress: address of the random generator
     */
    function changeRandomGenerator(address _randomGeneratorAddress) external onlyOwner {
        require(
            lotteries[currentLotteryId].status == Status.Claimable,
            "Lottery not in claimable"
        );

        // Request a random number from the generator based on a seed
        IRandom(_randomGeneratorAddress).requestRandomNumbers();

        // Calculate the finalNumber based on the randomResult generated by ChainLink's fallback
        IRandom(_randomGeneratorAddress).viewRandomResult();

        randomGenerator = IRandom(_randomGeneratorAddress);

        emit NewRandomGenerator(_randomGeneratorAddress);
    }

    function setMinAndMaxTicketPrice(uint256 _minPriceTicket, uint256 _maxPriceTicket)
        external
        onlyOwner
    {
        require(_minPriceTicket <= _maxPriceTicket, "minPrice must be < maxPrice");

        minPriceTicket = _minPriceTicket;
        maxPriceTicket = _maxPriceTicket;
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

        emit NewOperatorAndTreasuryAndInjectorAddresses(
            _operatorAddress,
            _treasuryAddress,
            _injectorAddress
        );
    }

    /**
     * @dev Only callable by owner
     * @param _referral: address of the referral
     */
    function setReferral(address _referral) external onlyOwner {
        referralProgram = IReferral(_referral);

        emit NewReferral(_referral);
    }

    /**
     * @dev Only callable by owner
     * @param _coupon: address of the coupon
     */
    function setCoupon(address _coupon) external onlyOwner {
        couponCenter = ICoupon(_coupon);

        emit NewCoupon(_coupon);
    }

    /**
     * @notice View current lottery id
     */
    function viewCurrentLotteryId() external view returns (uint256) {
        return currentLotteryId;
    }

    /**
     * @notice View lottery information
     * @param _lotteryId: lottery id
     */
    function viewLottery(uint256 _lotteryId) external view returns (Lottery memory) {
        return lotteries[_lotteryId];
    }

    /**
     * @notice View ticker statuses and numbers for an array of ticket ids
     * @param _ticketIds: array of _ticketId
     */
    function viewNumbersAndAddressForTicketIds(uint256[] calldata _ticketIds)
        external
        view
        returns (bytes6[] memory, address[] memory)
    {
        uint256 length = _ticketIds.length;
        bytes6[] memory ticketNumbers = new bytes6[](length);
        address[] memory ticketStatuses = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            ticketNumbers[i] = tickets[_ticketIds[i]].number;
            ticketStatuses[i] = tickets[_ticketIds[i]].owner;
        }

        return (ticketNumbers, ticketStatuses);
    }

    /**
     * @notice View rewards for a given ticket, providing a bracket, and lottery id
     * @dev Computations are mostly offchain. This is used to verify a ticket!
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     */
    function viewRewardsForTicketId(uint256 _lotteryId, uint256 _ticketId)
        external
        view
        returns (uint256)
    {
        // Check lottery is in claimable status
        if (lotteries[_lotteryId].status != Status.Claimable) {
            return 0;
        }

        // Check ticketId is within range
        if (
            (lotteries[_lotteryId].firstTicketIdNextLottery < _ticketId) &&
            (lotteries[_lotteryId].firstTicketId >= _ticketId)
        ) {
            return 0;
        }

        uint8 _matched = ArrayLib.countMatch(
            lotteries[_lotteryId].finalNumber,
            tickets[_ticketId].number
        );
        return _matched >= 3 ? lotteries[_lotteryId].prizeAmounts[6 - _matched] : 0;
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
        external
        view
        returns (
            uint256[] memory,
            bytes6[] memory,
            bool[] memory,
            uint256
        )
    {
        uint256 length = _size;
        uint256 numberTicketsBoughtAtLotteryId = userTicketIdsPerLotteryId[_user][_lotteryId]
            .length;

        if (length > (numberTicketsBoughtAtLotteryId - _cursor)) {
            length = numberTicketsBoughtAtLotteryId - _cursor;
        }

        uint256[] memory lotteryTicketIds = new uint256[](length);
        bytes6[] memory ticketNumbers = new bytes6[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            lotteryTicketIds[i] = userTicketIdsPerLotteryId[_user][_lotteryId][i + _cursor];
            ticketNumbers[i] = tickets[lotteryTicketIds[i]].number;

            // True = ticket claimed
            if (tickets[lotteryTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true;
            } else {
                // ticket not claimed (includes the ones that cannot be claimed)
                ticketStatuses[i] = false;
            }
        }

        return (lotteryTicketIds, ticketNumbers, ticketStatuses, _cursor + length);
    }

    /**
     * @notice Buy tickets for the current lottery
     * @param lotteryId: lotteryId
     * @param ticketNumbers: array of ticket numbers
     * @dev Callable by users
     */
    function _buyTickets(
        uint256 lotteryId,
        bytes6[] memory ticketNumbers,
        ICoupon.Coupon memory coupon
    ) internal {
        require(ticketNumbers.length != 0, "No ticket specified");
        require(ticketNumbers.length <= maxNumberTicketsPerBuyOrClaim, "Too many tickets");

        require(lotteries[lotteryId].status == Status.Open, "Lottery is not open");
        require(block.timestamp < lotteries[lotteryId].endTime, "Lottery is over");

        uint256 baseAmount = ticketNumbers.length * lotteries[lotteryId].priceTicket;
        uint256 amountToTransfer = lotteries[lotteryId].saleoff
            ? _calculateTotalPriceForBulkTickets(
                lotteries[lotteryId].discountDivisor,
                lotteries[lotteryId].priceTicket,
                ticketNumbers.length
            )
            : baseAmount;

        (uint256 reduceAmount, uint256 totalReferral) = referralProgram.payReferral(
            msg.sender,
            address(currency),
            baseAmount
        );

        uint256 couponSale;
        if (coupon.id != 0) {
            couponSale = couponCenter.useCoupon(coupon, baseAmount);
        }
        currency.safeTransferFrom(
            msg.sender,
            address(this),
            amountToTransfer - reduceAmount - couponSale
        );

        // Increment amount
        lotteries[lotteryId].amountTotal += baseAmount;
        lotteries[lotteryId].totalReferral += totalReferral;
        lotteries[lotteryId].amountUsed +=
            baseAmount -
            amountToTransfer +
            totalReferral +
            couponSale;

        for (uint256 i = 0; i < ticketNumbers.length; i++) {
            bytes6 number = ticketNumbers[i];
            _validateTicket(number);

            userTicketIdsPerLotteryId[msg.sender][lotteryId].push(currentTicketId);

            tickets[currentTicketId] = Ticket({number: number, owner: msg.sender});

            // Increase lottery ticket number
            currentTicketId++;
        }

        emit TicketsPurchase(msg.sender, lotteryId, ticketNumbers.length, coupon.id);
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
        return
            (_priceTicket * _numberTickets * (_discountDivisor + 1 - _numberTickets)) /
            _discountDivisor;
    }

    function _validateTicket(bytes6 number) internal pure {
        require(uint8(number[0]) <= 45 && uint8(number[0]) >= 1, "numbers should in range 1-45");
        for (uint8 i = 1; i < 6; i++) {
            require(
                uint8(number[i]) <= 45 && uint8(number[i]) >= 1,
                "number should in range 1-45"
            );
            require(uint8(number[i]) > uint8(number[i - 1]), "number should be asc");
        }
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

    function _calculatePrize(
        uint256 amountTotal,
        uint256 rate,
        uint256 winCount,
        uint256 maxPrize
    ) internal pure returns (uint256 prize) {
        if (winCount == 0) {
            return 0;
        }
        prize = (amountTotal * rate) / 10000 / winCount;

        if (prize > maxPrize) {
            prize = maxPrize;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
pragma solidity ^0.8.14;

interface ILottery {
    /**
     * @notice Buy tickets for the current lottery
     * @param _lotteryId: lotteryId
     * @param _ticketNumbers: array of ticket numbers
     * @dev Callable by users
     */
    function buyTickets(uint256 _lotteryId, bytes6[] calldata _ticketNumbers) external;

    /**
     * @notice Claim a set of winning tickets for a lottery
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(uint256 _lotteryId, uint256[] calldata _ticketIds) external;

    /**
     * @notice Close lottery
     * @param _lotteryId: lottery id
     * @dev Callable by operator
     */
    function closeLottery(uint256 _lotteryId) external;

    /**
     * @notice Draw the final number, calculate reward in CAKE per group, and make lottery claimable
     * @param _lotteryId: lottery id
     * @dev Callable by operator
     */
    function drawFinalNumberAndMakeLotteryClaimable(
        uint256 _lotteryId,
        uint256[4] calldata winCounts
    ) external;

    /**
     * @notice Inject funds
     * @dev Callable by operator
     */
    function injectFunds() external;

    /**
     * @notice Start the lottery
     * @dev Callable by operator
     */
    function startLottery(
        uint256 _endTime,
        uint256 _priceTicket,
        uint256 _discountDivisor,
        uint256 totalPrizeRate,
        uint256[3] calldata _rates,
        uint256 guaranteeFundRate,
        uint256 affiliateFundRate,
        bool saleoff
    ) external;

    function viewCurrentLotteryId() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IRandom {
    /**
     * Requests randomness from a user-provided seed
     */
    function requestRandomNumbers() external;

    /**
     * View latest lotteryId numbers
     */
    function viewLatestLotteryId() external view returns (uint256);

    /**
     * Views random result
     */
    function viewRandomResult() external view returns (bytes memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IReferral {
    /// @notice Adds an address as referrer.
    /// @param user The address of the user.
    /// @param id The id referer would set as referrer of user.
    function addReferrer(address user, uint256 id) external;

    /// @notice Calculates and allocate referrer(s) credits to uplines.
    /// @param user Address of the gamer to find referrer(s).
    /// @param token The token to allocate.
    /// @param amount The number of tokens allocated for referrer(s).
    function payReferral(
        address user,
        address token,
        uint256 amount
    ) external returns (uint256 payneeReduced, uint256 totalReferral);

    /// @notice Utils function for check whether an address has the referrer.
    /// @param user The address of the user.
    /// @return Whether user has a referrer.
    function hasReferrer(address user) external view returns (bool);

    /// @notice Gets the referrer's account information.
    /// @param user Address of the referrer.
    /// @return referer The address of referer.
    /// @return index Identify the index.
    function getReferralAccount(address user) external view returns (address referer, uint8 index);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface ICoupon {
    struct Coupon {
        uint256 id;
        uint256 saleoff;
        uint256 maxSaleOff;
        uint256 minPayment;
        uint256 start;
        uint256 end;
        address owner;
        bytes sig;
    }

    function useCoupon(Coupon memory coupon, uint256 payAmount) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library ArrayLib {
    function countMatch(bytes memory first, bytes6 second)
        internal
        pure
        returns (uint8)
    {
        uint8 matchedCount = 0;
        // Simply get (start from) the first number from the input array
        for (uint8 ii = 0; ii < first.length; ii++) {
            // and check it against the second array numbers, from first to fourth,
            for (uint8 jj = 0; jj < second.length; jj++) {
                // If you find it
                if (first[ii] == second[jj]) {
                    matchedCount += 1;
                    break;
                }
            }
        }

        return matchedCount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
                /// @solidity memory-safe-assembly
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