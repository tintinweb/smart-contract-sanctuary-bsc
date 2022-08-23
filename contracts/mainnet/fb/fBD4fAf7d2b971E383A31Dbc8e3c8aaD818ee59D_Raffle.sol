/*
    PigBnb Raffle - BSC Gambling
    Developed by Kraitor <TG: kraitordev>
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Imported OZ helper contracts
import "@openzeppelin/contracts/utils/Address.sol";
import "./BasicLibraries/Auth.sol";
import "./Libraries/BnbPigIface.sol";
// Safe math
import "./BasicLibraries/SafeMath.sol";
import "./LotteryLibraries/SafeMath16.sol";
import "./LotteryLibraries/SafeMath8.sol";

contract Raffle is Auth {
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;

    // State variables 
    // Store the address of the miner
    BnbPigIface internal pig_;
    // Auto executions
    address public autoAdr;
    // Counter for lottery IDs 
    uint256 public lotteryIdCounter_ = 0;

    // Ticket id
    uint256 public ticketIdCounter_ = 0;

    // Cost per ticket in BNB
    uint256 public costPerTicket_ = 5 * (10**17); //0.5

    // Next lottery prize pool
    uint256 public nextLotPrizePool_ = 10 * (10 ** 18);

    // Ticket id mapped to owner
    mapping(uint256 => address) public ticketIdOwner_;

    // All the needed info around a lottery
    struct LottoInfo {
        uint256 lotteryID;           // ID for lotto
        uint256 prizePool;           // The amount of BNB for prize money
        //uint256 raisedAmount;        // Amount raised for current lottery (tickets and miner taxes)
        uint256 amountUnclaimed;     // Amount to be claimed by the winner
        uint256 timestampLotClosed;  // Winners only can claim on the first 12 hours
        uint256 beginLotteryTicketID;// First lottery ticket ID
        uint256 lotteryWinner;       // The ticket winner                
    }

    // Lottery ID's to info
    mapping(uint256 => LottoInfo) internal allLotteries_;

    //Manual settings
    uint256 public manualInitialPool;

    uint8 public profitsTaxMinerTVL = 25;
    uint8 public profitsTaxDev = 5;
    address public devAdr;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event LotteryClosed(uint256 lotId, uint256 timestampClosed, uint256 nextPrizePool, uint256 ticketIdWinner);

    event NewLotto(uint256 lotteryId, uint256 nextLotPrizePool_);

    event NewBatchMint(address user, uint256 nTickets, uint256 cost, uint256 payment);

    event ClaimedReward(address user, uint256 lotId, uint256 ticketId, uint256 amountPaid);

    //-------------------------------------------------------------------------
    // MODIFIERS
    //-------------------------------------------------------------------------

    modifier onlyAutoAdr() {
        require(
            msg.sender == address(autoAdr),
            "Only auto executions account"
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

    constructor() Auth(msg.sender) { 
        authorize(address(this)); 

        autoAdr = msg.sender;
        devAdr = msg.sender;
    }

    //-------------------------------------------------------------------------
    // VIEW FUNCTIONS
    //-------------------------------------------------------------------------

    function getAllLottosInfo() external view returns(LottoInfo [] memory){ 
        LottoInfo [] memory allLotos = new LottoInfo [](lotteryIdCounter_);
        for(uint i = 1; i <= lotteryIdCounter_; i++){
            allLotos[i-1] = allLotteries_[i]; 
        }
        return allLotos;
    }

    function getLottoInfo(uint256 _lotteryId) external view returns(LottoInfo memory){ return allLotteries_[_lotteryId]; }

    function getLottoTicketOwners(uint256 _ticketBegin, uint256 _ticketEnd) external view returns(address [] memory){
        uint256 answerLenght = _ticketEnd - _ticketBegin+1;
        address [] memory ticketsOwners = new address [] (answerLenght);
        
        uint256 _count = 0;
        for(uint256 _i = _ticketBegin; _i <= _ticketEnd; _i++){
            ticketsOwners[_count] = ticketIdOwner_[_i];
            _count++;
        }

        return ticketsOwners;
    }

    //-------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS 
    //-------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    // Restricted Access Functions (authorized)

    function endLottery(uint256 ticketIdWinner) external authorized {
        uint256 _lotteryId = lotteryIdCounter_;

        // End lottery
        require(allLotteries_[_lotteryId].timestampLotClosed == 0, 'Already ended');
        require(address(this).balance >= allLotteries_[_lotteryId].prizePool, 'Not enough funds collected');
        require(allLotteries_[_lotteryId].beginLotteryTicketID > 0, 'No people joined');
        require(allLotteries_[_lotteryId].beginLotteryTicketID <= ticketIdWinner && ticketIdWinner <= ticketIdCounter_, 'Invalid winner');

        // Next lottery prize pool
        nextLotPrizePool_ = address(this).balance;

        // Set end timestamp for claiming expire
        allLotteries_[_lotteryId].timestampLotClosed = block.timestamp;
        
        // We have to distribute the pool prize
        uint256 totalTax = profitsTaxMinerTVL.add(profitsTaxDev);
        uint256 totalAmountTaxed = allLotteries_[_lotteryId].prizePool.mul(totalTax).div(100);

        // Amount to be claimed by the winner
        allLotteries_[_lotteryId].amountUnclaimed = allLotteries_[_lotteryId].prizePool.sub(totalAmountTaxed);

        // Winner
        allLotteries_[_lotteryId].lotteryWinner = ticketIdWinner;

        // Taxes paid
        payable(address(pig_)).transfer(totalAmountTaxed.mul(profitsTaxMinerTVL).div(totalTax));
        payable(address(devAdr)).transfer(totalAmountTaxed.mul(profitsTaxDev).div(totalTax)); 

        // Emit lottery closed
        emit LotteryClosed(_lotteryId, allLotteries_[_lotteryId].timestampLotClosed, nextLotPrizePool_, ticketIdWinner);

        //New lottery created auto
        this.createNewLotto();
    }  

    function createNewLotto() external authorized {        
        require(lotteryIdCounter_ == 0 || allLotteries_[lotteryIdCounter_].timestampLotClosed != 0, 'Last lottery not closed');

        // Incrementing lottery ID 
        lotteryIdCounter_ = lotteryIdCounter_.add(1);
        uint256 lotteryId = lotteryIdCounter_;

        uint256 nextLotPrizePool = nextLotPrizePool_;
        if(manualInitialPool != 0){
            nextLotPrizePool = manualInitialPool;
        }

        // Setting data in struct
        LottoInfo storage newLottery = allLotteries_[lotteryId];
        newLottery.lotteryID = lotteryId;
        newLottery.prizePool = nextLotPrizePool;
        //newLottery.raisedAmount = 0;
        newLottery.amountUnclaimed = 0;
        newLottery.timestampLotClosed = 0;
        newLottery.beginLotteryTicketID = 0;
        newLottery.lotteryWinner = 0;

        emit NewLotto(lotteryId, nextLotPrizePool);
    }

    function setManualConfig(uint256 _manualInitialPool, uint256 _costPerTicket) external authorized {
        manualInitialPool = _manualInitialPool;
        costPerTicket_ = _costPerTicket;
    }

    function setAutoAdr(address _autoAdr) external authorized { 
        autoAdr = _autoAdr; 
        authorize(autoAdr); 
    }

    function setTaxes(uint8 _profitsTaxMinerTVL, uint8 _profitsTaxDev, address _devAdr) external authorized {
        require(100 > _profitsTaxMinerTVL.add(_profitsTaxDev), 'Invalid values');
        profitsTaxMinerTVL = _profitsTaxMinerTVL;
        profitsTaxDev = _profitsTaxDev;
        devAdr = _devAdr;
    }

    function withdraw(uint256 _amount) external authorized { payable(msg.sender).transfer(_amount); }

    function setMinerCA(address _adr) external authorized { pig_ = BnbPigIface(_adr); }

    //-------------------------------------------------------------------------
    // Automatic functions

    // We have to check if its time to close the lotto (will be checked each 12h)
    function autoCheckerCloseLotto() external view returns(bool) {
        uint256 _lotteryId = lotteryIdCounter_;

        // Can end lottery?
        if(
            allLotteries_[_lotteryId].timestampLotClosed == 0 &&
            address(this).balance >= allLotteries_[_lotteryId].prizePool &&
            allLotteries_[_lotteryId].beginLotteryTicketID > 0
        ){
            return true;
        }

        return false;
    }

    //-------------------------------------------------------------------------
    // General Access Functions

    function batchBuyLottoTicketFriend(address _friend, uint8 _numberOfTickets) external payable {
        require(lotteryIdCounter_ != 0, 'Not initialized');

        // Getting the cost
        uint256 totalCost = costPerTicket_.mul(_numberOfTickets);

        // Amount required
        require(totalCost <= msg.value, "Amount paid not enough");

        // Assign tickets to the sender
        for(uint256 i=0; i<_numberOfTickets; i++){ assignTicket(_friend); }

        // Emitting event with all information
        emit NewBatchMint(_friend, _numberOfTickets, totalCost, msg.value);
    }

    function batchBuyLottoTicket(uint8 _numberOfTickets) external payable notContract() {
        require(lotteryIdCounter_ != 0, 'Not initialized');

        // Getting the cost
        uint256 totalCost = costPerTicket_.mul(_numberOfTickets);

        // Amount required
        require(totalCost <= msg.value, "Amount paid not enough");

        // Assign tickets to the sender
        for(uint256 i=0; i<_numberOfTickets; i++){ assignTicket(msg.sender); }

        // Emitting event with all information
        emit NewBatchMint(msg.sender, _numberOfTickets, totalCost, msg.value);
    }

    function claimReward(uint256 _lotteryId) external notContract() {
        require(lotteryIdCounter_ != 0, 'Not initialized');
        require(_lotteryId < lotteryIdCounter_, 'Only can claim already ended lotteries');
        require(ticketIdOwner_[allLotteries_[_lotteryId].lotteryWinner] == msg.sender, 'You did not win that lottery');
        require(block.timestamp.sub(allLotteries_[_lotteryId].timestampLotClosed) < (12 hours), 'Only can claim in the first 12 hours');

        // That lot
        LottoInfo storage _lot = allLotteries_[_lotteryId];

        // Amount to pay
        uint256 amountPay = _lot.amountUnclaimed;

        // Transfering the user their winnings
        payable(address(msg.sender)).transfer(amountPay);

        // Amount claimed
        _lot.amountUnclaimed = 0;

        emit ClaimedReward(msg.sender, _lotteryId, allLotteries_[_lotteryId].lotteryWinner, amountPay);
    }

    function reinvestRewardsIntoMiner(uint256 _lotteryId) external notContract(){
        require(lotteryIdCounter_ != 0, 'Not initialized');
        require(_lotteryId < lotteryIdCounter_, 'Only can claim already ended lotteries');
        require(ticketIdOwner_[allLotteries_[_lotteryId].lotteryWinner] == msg.sender, 'You did not win that lottery');
        require(block.timestamp.sub(allLotteries_[_lotteryId].timestampLotClosed) < (12 hours), 'Only can claim in the first 12 hours');

        // That lot
        LottoInfo storage _lot = allLotteries_[_lotteryId];

        // Amount to pay
        uint256 amountPay = _lot.amountUnclaimed;

        //Reinvest into the miner //50% bonus
        pig_.hirePigsLottery{value: amountPay}(msg.sender);

        // Amount claimed
        _lot.amountUnclaimed = 0;
    }

    function fund() external payable {}

    //-------------------------------------------------------------------------
    // INTERNAL FUNCTIONS 
    //-------------------------------------------------------------------------

    // Assign ticket to address and current loto
    function assignTicket(address _adr) internal returns(uint256){
        ticketIdCounter_ = ticketIdCounter_.add(1);
        ticketIdOwner_[ticketIdCounter_] = address(_adr);

        LottoInfo storage _lot = allLotteries_[lotteryIdCounter_];
        // Initialize lot ini ticket if needed
        if(_lot.beginLotteryTicketID == 0){
            _lot.beginLotteryTicketID = ticketIdCounter_;
        }

        return ticketIdCounter_;
    }

    receive() external payable {}
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