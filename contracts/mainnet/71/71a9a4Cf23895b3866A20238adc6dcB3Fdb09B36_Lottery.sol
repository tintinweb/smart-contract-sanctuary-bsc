// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Imported OZ helper contracts
import "@openzeppelin/contracts/utils/Address.sol";
import "./BasicLibraries/Auth.sol";
// Allows for intergration with ChainLink VRF
//import "./LotteryLibraries/IRandomNumberGenerator.sol";
// Interface for Lottery NFT to mint tokens
import "./LotteryLibraries/ILotteryNFT.sol";
import "./Libraries/BnbPigIface.sol";
// Allows for time manipulation. Set to 0x address on test/mainnet deploy
import "./Libraries/Testable.sol";
// Safe math
import "./BasicLibraries/SafeMath.sol";
import "./LotteryLibraries/SafeMath16.sol";
import "./LotteryLibraries/SafeMath8.sol";

contract Lottery is Auth, Testable {
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;

    // State variables
    // Storing of the NFT
    ILotteryNFT internal nft_;
    // Storing of the randomness generator 
    //IRandomNumberGenerator internal randomGenerator_;
    address internal randomGenerator_;
    // Counter for lottery IDs 
    uint256 public lotteryIdCounter_;

    // Lottery size (number of numbers on each ticket, alsoprice distribution size, example [20, 30, 50])
    uint8 public sizeOfLottery_ = 5;//10;
    // Max range for numbers (starting at 0) (numbers investors can choose)
    uint16 public maxValidRange_ = 10;//50;
    
    // Cost per ticket
    uint256 public costPerTicket = uint256(1 ether).div(10);
    // Prize pool
    uint256 public prizePool = 0;//costPerTicket.mul(50);
    // Prize distribution
    uint8 [] prizeDistribution = [2, 8, 15, 25, 50];//[1, 2, 4, 5, 6, 7, 10, 15, 20, 30];

    // Represents the status of the lottery
    enum Status { 
        NotStarted,     // The lottery has not started yet
        Open,           // The lottery is open for ticket purchases 
        Closed,         // The lottery is no longer open for ticket purchases
        Completed       // The lottery has been closed and the numbers drawn
    }
    // All the needed info around a lottery
    struct LottoInfo {
        uint256 lotteryID;          // ID for lotto
        Status lotteryStatus;       // Status for lotto
        uint256 prizePool;          // The amount of BNB for prize money
        uint256 costPerTicket;      // Cost per ticket in BNB
        uint256 nSoldTickets;       // Number of tickets sold
        uint8[] prizeDistribution;  // The distribution for prize money
        uint256 startingTimestamp;  // Block timestamp for star of lotto
        uint256 closingTimestamp;   // Block timestamp for end of entries
        uint16[] winningNumbers;    // The winning numbers
    }
    // Lottery ID's to info
    mapping(uint256 => LottoInfo) internal allLotteries_;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event NewBatchMint(address indexed minter, uint256[] ticketIDs, uint16[] numbers, uint256 totalCost, uint256 pricePaid);

    event RequestNumbers(uint256 lotteryId, bytes32 requestId);

    event UpdatedSizeOfLottery(address admin, uint8 newLotterySize);

    event UpdatedMaxRange(address admin, uint16 newMaxRange);

    event UpdatedBuckets(address admin, uint8 bucketOneMax,uint8 bucketTwoMax);

    event LotteryOpen(uint256 lotteryId, uint256 ticketSupply);

    event LotteryClose(uint256 lotteryId, uint256 ticketSupply);

    event ClaimedReward(address user, uint256 lotId, uint256 ticketId, uint256 nMatchingNumbers, uint256 startingPrizePool, uint256 payableAmount);

    event ClaimedRewardBatch(address user, uint256 lotId, uint256 [] ticketId, uint256 nMatchingNumbers, uint256 startingPrizePool, uint256 payableAmount);

    //-------------------------------------------------------------------------
    // MODIFIERS
    //-------------------------------------------------------------------------

    modifier onlyRandomGenerator() {
        require(
            msg.sender == address(randomGenerator_),
            "Only random generator"
        );
        _;
    }

    modifier notContract() {
        require(!address(msg.sender).isContract(), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
       _;
    }

    //-------------------------------------------------------------------------
    // CONSTRUCTOR
    //-------------------------------------------------------------------------

    constructor(address _timer, uint8 _sizeOfLotteryNumbers, uint16 _maxValidNumberRange) Testable(_timer) Auth(msg.sender) {
        require(_sizeOfLotteryNumbers != 0 &&_maxValidNumberRange != 0, "Lottery setup cannot be 0");

        sizeOfLottery_ = _sizeOfLotteryNumbers;
        maxValidRange_ = _maxValidNumberRange;
    }

    function initialize(address _lotteryNFT, address _IRandomNumberGenerator) external authorized {
        require(_lotteryNFT != address(0) && _IRandomNumberGenerator != address(0), "Contracts cannot be 0 address");

        nft_ = ILotteryNFT(_lotteryNFT);
        randomGenerator_ = _IRandomNumberGenerator;//IRandomNumberGenerator(_IRandomNumberGenerator);
    }

    //-------------------------------------------------------------------------
    // VIEW FUNCTIONS
    //-------------------------------------------------------------------------

    function costToBuyTickets(uint256 _lotteryId, uint256 _numberOfTickets) external view returns(uint256) {
        uint256 pricePer = allLotteries_[_lotteryId].costPerTicket;
        return pricePer.mul(_numberOfTickets);
    }

    function getAllLottosInfo() external view returns(LottoInfo [] memory){ 
        LottoInfo [] memory allLotos = new LottoInfo [](lotteryIdCounter_);
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            allLotos[i-1] = allLotteries_[i]; 
        }
        return allLotos;
    }

    function getAllLottosOpenInfo() external view returns(LottoInfo [] memory){ 
        uint _countOpened = 0;
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            if(allLotteries_[i].lotteryStatus == Status.Open){
                _countOpened++;
            } 
        }

        LottoInfo [] memory allLotos = new LottoInfo [](_countOpened);
        _countOpened = 0;
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            if(allLotteries_[i].lotteryStatus == Status.Open){
                allLotos[_countOpened] = allLotteries_[i]; 
                _countOpened++;
            }
        }
        return allLotos;
    }

    function getAllLottosClosedInfo() external view returns(LottoInfo [] memory){ 
        uint _countClosed = 0;
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            if(allLotteries_[i].lotteryStatus == Status.Closed){
                _countClosed++;
            } 
        }

        LottoInfo [] memory allLotos = new LottoInfo [](_countClosed);
        _countClosed = 0;
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            if(allLotteries_[i].lotteryStatus == Status.Closed){
                allLotos[_countClosed] = allLotteries_[i]; 
                _countClosed++;
            }
        }
        return allLotos;
    }

    function getAllLottosCompletedActiveInfo() external view returns(LottoInfo [] memory){ 
        uint _countCompleted = 0;
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            if(allLotteries_[i].lotteryStatus == Status.Completed && allLotteries_[i].closingTimestamp.add(24 hours) >= getCurrentTime()){
                _countCompleted++;
            } 
        }

        LottoInfo [] memory allLotos = new LottoInfo [](_countCompleted);
        _countCompleted = 0;
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            if(allLotteries_[i].lotteryStatus == Status.Completed && allLotteries_[i].closingTimestamp.add(24 hours) >= getCurrentTime()){
                allLotos[_countCompleted] = allLotteries_[i]; 
                _countCompleted++;
            }
        }
        return allLotos;
    }

    function getLottoCurrentPrizePool(uint256 _lotteryId) external view returns(uint256){
        if(allLotteries_[_lotteryId].prizePool == 0 && allLotteries_[_lotteryId].lotteryStatus == Status.Open){
            return allLotteries_[_lotteryId].costPerTicket * allLotteries_[_lotteryId].nSoldTickets;
        }else{
            return allLotteries_[_lotteryId].prizePool;
        }
    }

    function getBasicLottoInfo(uint256 _lotteryId) external view returns(LottoInfo memory){ return allLotteries_[_lotteryId]; }

    function getMaxRange() external view returns(uint16) { return maxValidRange_; }

    //-------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS 
    //-------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    // Restricted Access Functions (authorized)

    function updateSizeOfLottery(uint8 _newSize) external authorized {
        require(sizeOfLottery_ != _newSize, "Cannot set to current size");
        require(sizeOfLottery_ != 0, "Lottery size cannot be 0");
        sizeOfLottery_ = _newSize;

        emit UpdatedSizeOfLottery(msg.sender, _newSize);
    }

    function updateMaxRange(uint16 _newMaxRange) external authorized {
        require(maxValidRange_ != _newMaxRange, "Cannot set to current size");
        require(maxValidRange_ != 0, "Max range cannot be 0");
        maxValidRange_ = _newMaxRange;

        emit UpdatedMaxRange(msg.sender, _newMaxRange);
    }

    function updateTicketCost(uint256 _costPerTicket) external authorized { costPerTicket = _costPerTicket; }

    function updatePrizePool(uint256 _prizePool) external authorized { prizePool = _prizePool; }

    function updatePrizeDistribution(uint8 [] memory _prizeDistribution) external authorized { prizeDistribution = _prizeDistribution; }

    function updateRandomGenerator(address _randomGenerator) external authorized { randomGenerator_ = _randomGenerator; }

    function closeLottery(uint256 _lotteryId) external authorized {
        // Checks that the lottery is past the closing block
        require(allLotteries_[_lotteryId].closingTimestamp <= getCurrentTime(), "Cannot close for now");
        // Checks lottery numbers have not already been drawn
        require(allLotteries_[_lotteryId].lotteryStatus == Status.Open, "Lottery State incorrect for draw");
        // Sets lottery status to closed
        allLotteries_[_lotteryId].lotteryStatus = Status.Closed;
        // Sets prize taking into account tickets sold
        if(allLotteries_[_lotteryId].prizePool == 0){
            allLotteries_[_lotteryId].prizePool = allLotteries_[_lotteryId].costPerTicket * allLotteries_[_lotteryId].nSoldTickets;
        }
    }

    function numbersDrawn(uint256 _lotteryId, uint256 _randomNumber) external onlyRandomGenerator() {
        require(allLotteries_[_lotteryId].lotteryStatus == Status.Closed, "Close lottery first");

        allLotteries_[_lotteryId].lotteryStatus = Status.Completed;
        allLotteries_[_lotteryId].winningNumbers = _split(_randomNumber);

        emit LotteryClose(_lotteryId, nft_.getTotalSupply());
    }

    /**
     * @param   _startingTimestamp The block timestamp for the beginning of the 
     *          lottery. 
     * @param   _closingTimestamp The block timestamp after which no more tickets
     *          will be sold for the lottery. Note that this timestamp MUST
     *          be after the starting block timestamp. 
     */
    function createNewLotto(uint256 _startingTimestamp, uint256 _closingTimestamp) external authorized returns(uint256) {
        require(prizeDistribution.length == sizeOfLottery_, "Invalid distribution");

        uint256 prizeDistributionTotal = 0;
        for (uint256 j = 0; j < prizeDistribution.length; j++) {
            prizeDistributionTotal = prizeDistributionTotal.add(
                uint256(prizeDistribution[j])
            );
        }

        // Ensuring that prize distribution total is 100%
        require(prizeDistributionTotal == 100, "Prize distribution is not 100%");
        require(costPerTicket != 0, "Cost cannot be 0");
        require(_startingTimestamp != 0 &&_startingTimestamp < _closingTimestamp, "Timestamps for lottery invalid");

        // Incrementing lottery ID 
        lotteryIdCounter_ = lotteryIdCounter_.add(1);
        uint256 lotteryId = lotteryIdCounter_;
        uint16[] memory winningNumbers = new uint16[](sizeOfLottery_);
        Status lotteryStatus;
        if(_startingTimestamp <= getCurrentTime()) {
            lotteryStatus = Status.Open;
        } else {
            lotteryStatus = Status.NotStarted;
        }
        // Saving data in struct
        LottoInfo memory newLottery = LottoInfo(
            lotteryId,
            lotteryStatus,
            prizePool,
            costPerTicket,
            0,
            prizeDistribution,
            _startingTimestamp,
            _closingTimestamp,
            winningNumbers
        );
        allLotteries_[lotteryId] = newLottery;

        // Emitting important information around new lottery.
        emit LotteryOpen(lotteryId, nft_.getTotalSupply());

        return lotteryId;
    }

    function withdraw(uint256 _amount) external authorized { payable(msg.sender).transfer(_amount); }

    //-------------------------------------------------------------------------
    // General Access Functions

    function batchBuyLottoTicket(uint256 _lotteryId, uint8 _numberOfTickets, uint16[] calldata _chosenNumbersForEachTicket) external payable notContract() {
        // Ensuring the lottery is within a valid time
        require(getCurrentTime() >= allLotteries_[_lotteryId].startingTimestamp, "Invalid time for mint:start");
        require(getCurrentTime() < allLotteries_[_lotteryId].closingTimestamp, "Invalid time for mint:end");

        if(allLotteries_[_lotteryId].lotteryStatus == Status.NotStarted) {
            if(allLotteries_[_lotteryId].startingTimestamp <= getCurrentTime()) {
                allLotteries_[_lotteryId].lotteryStatus = Status.Open;
            }
        }
        allLotteries_[_lotteryId].nSoldTickets += _numberOfTickets; //Update the tickets sold

        require(allLotteries_[_lotteryId].lotteryStatus == Status.Open, "Lottery not in state for mint");
        require(_numberOfTickets <= 50, "Batch mint too large");

        // Temporary storage for the check of the chosen numbers array
        uint256 numberCheck = _numberOfTickets.mul(sizeOfLottery_);
        // Ensuring that there are the right amount of chosen numbers
        require(_chosenNumbersForEachTicket.length == numberCheck, "Invalid chosen numbers");

        // Ensuring tickets are in the configured range
        for(uint16 _i = 0; _i < _chosenNumbersForEachTicket.length; _i++){
            require(_chosenNumbersForEachTicket[_i] < maxValidRange_, 'Number not in valid range');
        }

        // Getting the cost
        uint256 totalCost = this.costToBuyTickets(_lotteryId, _numberOfTickets);
        //Amount required
        require(totalCost <= msg.value, "Amount paid not enough");

        // Batch mints the user their tickets
        uint256[] memory ticketIds = nft_.batchMint(msg.sender, _lotteryId, _numberOfTickets, _chosenNumbersForEachTicket, sizeOfLottery_);

        // Emitting event with all information
        emit NewBatchMint(msg.sender, ticketIds, _chosenNumbersForEachTicket, totalCost, msg.value);
    }

    function claimReward(uint256 _lotteryId, uint256 _tokenId) external notContract() {
        // Transfering the user their winnings
        uint256 payment_amount = processRewardsClaiming(_lotteryId, _tokenId);
        require(address(this).balance >= payment_amount, 'Not enough balance to pay');
        payable(address(msg.sender)).transfer(payment_amount);
    }

    function batchClaimRewards(uint256 _lotteryId, uint256[] calldata _tokeIds) external notContract() {
        // Transferring the user their winnings
        uint256 payment_amount = batchProcessRewardsClaiming(_lotteryId, _tokeIds);
        require(address(this).balance >= payment_amount, 'Not enough balance to pay');
        payable(address(msg.sender)).transfer(payment_amount);
    }

    //-------------------------------------------------------------------------
    // INTERNAL FUNCTIONS 
    //-------------------------------------------------------------------------

    function processRewardsClaiming(uint256 _lotteryId, uint256 _tokenId) internal returns(uint256) {
        // Checking the lottery is in a valid time for claiming
        require(allLotteries_[_lotteryId].closingTimestamp <= getCurrentTime(), "Wait till end to claim");        
        require(allLotteries_[_lotteryId].closingTimestamp.add(24 hours) >= getCurrentTime(), "Rewards only can be claimed the first 24h");   
        // Checks the lottery winning numbers are available 
        require(allLotteries_[_lotteryId].lotteryStatus == Status.Completed, "Winning Numbers not chosen yet");
        require(nft_.getOwnerOfTicket(_tokenId) == msg.sender, "Only the owner can claim");
        // Sets the claim of the ticket to true (if claimed, will revert)
        require(nft_.claimTicket(_tokenId, _lotteryId), "Numbers for ticket invalid");

        uint256 startingPrizePool = allLotteries_[_lotteryId].prizePool;
        // Getting the number of matching tickets
        uint8 matchingNumbers = _getNumberOfMatching(nft_.getTicketNumbers(_tokenId), allLotteries_[_lotteryId].winningNumbers);
        // Getting the prize amount for those matching tickets
        uint256 prizeAmount = _prizeForMatching(matchingNumbers, _lotteryId);
        // Removing the prize amount from the pool
        allLotteries_[_lotteryId].prizePool = allLotteries_[_lotteryId].prizePool.sub(prizeAmount);

        emit ClaimedReward(msg.sender, _lotteryId, _tokenId, matchingNumbers, startingPrizePool, prizeAmount);

        return prizeAmount;
    }

    function batchProcessRewardsClaiming(uint256 _lotteryId, uint256[] calldata _tokeIds) internal returns(uint256) {
        require(_tokeIds.length <= 50, "Batch claim too large");
        // Checking the lottery is in a valid time for claiming
        require(allLotteries_[_lotteryId].closingTimestamp <= getCurrentTime(), "Wait till end to claim");
        require(allLotteries_[_lotteryId].closingTimestamp.add(24 hours) >= getCurrentTime(), "Rewards only can be claimed the first 24h");   
        // Checks the lottery winning numbers are available 
        require(allLotteries_[_lotteryId].lotteryStatus == Status.Completed,"Winning Numbers not chosen yet");

        // Creates a storage for all winnings
        uint256 totalPrize = 0;
        uint256 nMatchingNumbers = 0;
        uint256 startingPrizePool = allLotteries_[_lotteryId].prizePool;

        // Loops through each submitted token
        for (uint256 i = 0; i < _tokeIds.length; i++) {

            // Checks user is owner (will revert entire call if not)
            require(nft_.getOwnerOfTicket(_tokeIds[i]) == msg.sender, "Only the owner can claim");

            // If token has already been claimed, skip token
            if(nft_.getTicketClaimStatus(_tokeIds[i])) {
                continue;
            }

            // Claims the ticket (will only revert if numbers invalid)
            require(nft_.claimTicket(_tokeIds[i], _lotteryId), "Numbers for ticket invalid");

            // Getting the number of matching tickets
            uint8 matchingNumbers = _getNumberOfMatching(nft_.getTicketNumbers(_tokeIds[i]), allLotteries_[_lotteryId].winningNumbers);
            nMatchingNumbers = nMatchingNumbers.add(matchingNumbers);
            // Getting the prize amount for those matching tickets
            uint256 prizeAmount = _prizeForMatching(matchingNumbers, _lotteryId);

            // Removing the prize amount from the pool
            allLotteries_[_lotteryId].prizePool = allLotteries_[_lotteryId].prizePool.sub(prizeAmount);
            totalPrize = totalPrize.add(prizeAmount);
        }

        emit ClaimedRewardBatch(msg.sender, _lotteryId, _tokeIds, nMatchingNumbers, startingPrizePool, totalPrize);

        return totalPrize;
    }

    function _getNumberOfMatching(uint16[] memory _usersNumbers, uint16[] memory _winningNumbers) internal pure returns(uint8){
        uint8 noOfMatching;
        // Loops through all wimming numbers
        for (uint256 i = 0; i < _winningNumbers.length; i++) {
            // If the winning numbers and user numbers match
            if(_usersNumbers[i] == _winningNumbers[i]) {
                // The number of matching numbers incrases
                noOfMatching += 1;
            }
        }
        return noOfMatching;
    }

    /**
     * @param   _noOfMatching: The number of matching numbers the user has
     * @param   _lotteryId: The ID of the lottery the user is claiming on
     * @return  uint256: The prize amount in BNB the user is entitled to 
     */
    function _prizeForMatching( uint8 _noOfMatching, uint256 _lotteryId) internal view returns(uint256) {
        uint256 prize = 0;
        // If user has no matching numbers their prize is 0
        if(_noOfMatching == 0) {
            return 0;
        } 
        // Getting the percentage of the pool the user has won
        uint256 perOfPool = allLotteries_[_lotteryId].prizeDistribution[_noOfMatching-1];
        // Timesing the percentage one by the pool
        prize = allLotteries_[_lotteryId].prizePool.mul(perOfPool);
        // Returning the prize divided by 100 (as the prize distribution is scaled)
        return prize.div(100);
    }

    function _split(uint256 _randomNumber) internal view returns(uint16[] memory) {
        // Temparary storage for winning numbers
        uint16[] memory winningNumbers = new uint16[](sizeOfLottery_);
        // Loops the size of the number of tickets in the lottery
        for(uint i = 0; i < sizeOfLottery_; i++){
            // Encodes the random number with its position in loop
            bytes32 hashOfRandom = keccak256(abi.encodePacked(_randomNumber, i));
            // Casts random number hash into uint256
            uint256 numberRepresentation = uint256(hashOfRandom);
            // Sets the winning number position to a uint16 of random hash number
            winningNumbers[i] = uint16(numberRepresentation.mod(maxValidRange_));
        }
        return winningNumbers;
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BasicLibraries/Auth.sol";
import "./BasicLibraries/SafeMath.sol";

/**
 * @title Universal store of current contract time for testing environments.
 */
contract Timer is Auth {
    using SafeMath for uint256;
    uint256 private currentTime;

    bool enabled = false;

    constructor() Auth(msg.sender) { }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set `currentTime` to.
     */
    function setCurrentTime(uint256 time) external authorized {
        require(time >= currentTime, "Return to the future Doc!");
        currentTime = time;
    }

    function enable(bool _enabled) external authorized {
        require(enabled == false, 'Can not be disabled');
        enabled = _enabled;
    }

    function increaseDays(uint256 _days) external authorized {
        currentTime = getCurrentTime().add(uint256(1 days).mul(_days));
    }

    function increaseMinutes(uint256 _minutes) external authorized {
        currentTime = getCurrentTime().add(uint256(1 minutes).mul(_minutes));
    }

    function increaseSeconds(uint256 _seconds) external authorized {
        currentTime = getCurrentTime().add(uint256(1 seconds).mul(_seconds));
    }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint256 for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if(enabled){
            return currentTime;
        }
        else{
            return block.timestamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * This library is a version of Open Zeppelin's SafeMath, modified to support
 * unsigned 32 bit integers.
 */
library SafeMath8 {
  /**
    * @dev Returns the addition of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `+` operator.
    *
    * Requirements:
    * - Addition cannot overflow.
    */
  function add(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
  function sub(uint8 a, uint8 b) internal pure returns (uint8) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint8 c = a - b;

    return c;
  }

  /**
    * @dev Returns the multiplication of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `*` operator.
    *
    * Requirements:
    * - Multiplication cannot overflow.
    */
  function mul(uint8 a, uint8 b) internal pure returns (uint8) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint8 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
    * @dev Returns the integer division of two unsigned integers. Reverts on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function div(uint8 a, uint8 b) internal pure returns (uint8) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath: division by zero");
    uint8 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function mod(uint8 a, uint8 b) internal pure returns (uint8) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * This library is a version of Open Zeppelin's SafeMath, modified to support
 * unsigned 32 bit integers.
 */
library SafeMath16 {
  /**
    * @dev Returns the addition of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `+` operator.
    *
    * Requirements:
    * - Addition cannot overflow.
    */
  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint16 c = a - b;

    return c;
  }

  /**
    * @dev Returns the multiplication of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `*` operator.
    *
    * Requirements:
    * - Multiplication cannot overflow.
    */
  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint16 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
    * @dev Returns the integer division of two unsigned integers. Reverts on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath: division by zero");
    uint16 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function mod(uint16 a, uint16 b) internal pure returns (uint16) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ILotteryNFT {

    //-------------------------------------------------------------------------
    // VIEW FUNCTIONS
    //-------------------------------------------------------------------------

    function getTotalSupply() external view returns(uint256);

    function getTicketNumbers(
        uint256 _ticketID
    ) 
        external 
        view 
        returns(uint16[] memory);

    function getOwnerOfTicket(
        uint256 _ticketID
    ) 
        external 
        view 
        returns(address);

    function getTicketClaimStatus(
        uint256 _ticketID
    ) 
        external 
        view
        returns(bool);

    //-------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS 
    //-------------------------------------------------------------------------

    function batchMint(
        address _to,
        uint256 _lottoID,
        uint8 _numberOfTickets,
        uint16[] calldata _numbers,
        uint8 sizeOfLottery
    )
        external
        returns(uint256[] memory);

    function claimTicket(uint256 _ticketId, uint256 _lotteryId) external returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./../Timer.sol";

/**
 * @title Base class that provides time overrides, but only if being run in test mode.
 */
abstract contract Testable {
    // If the contract is being run on the test network, then `timerAddress` will be the 0x0 address.
    // Note: this variable should be set on construction and never modified.
    address public timerAddress;

    /**
     * @notice Constructs the Testable contract. Called by child contracts.
     * @param _timerAddress Contract that stores the current time in a testing environment.
     * Must be set to 0x0 for production environments that use live time.
     */
    constructor(address _timerAddress) {
        timerAddress = _timerAddress;
    }

    /**
     * @notice Reverts if not running in test mode.
     */
    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    /**
     * @notice Sets the current time.
     * @dev Will revert if not running in test mode.
     * @param time timestamp to set current Testable time to.
     */
    // function setCurrentTime(uint256 time) external onlyIfTest {
    //     Timer(timerAddress).setCurrentTime(time);
    // }

    /**
     * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
     * Otherwise, it will return the block timestamp.
     * @return uint for the current Testable timestamp.
     */
    function getCurrentTime() public view returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface BnbPigIface {
    function hirePigsLottery(address friendAdr) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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