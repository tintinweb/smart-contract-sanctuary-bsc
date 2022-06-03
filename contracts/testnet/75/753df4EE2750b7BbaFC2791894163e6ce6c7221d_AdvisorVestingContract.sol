// SPDX-License-Identifier: Cryptopolis

pragma solidity ^0.8.13;

import "./interfaces/IAdvisorVestingERC20.sol";
import "./openzepplin/utils/math/SafeMath.sol";
import "./libs/baseObjects.sol";
// import "hardhat/console.sol";

contract AdvisorVestingContract {

    using SafeMath for uint256;

    event StartBlockSet(uint256 startBlock);
    event ScheduleAdded(uint schedule);
    event RecipientAdded(address recipient, uint amount);
    event TokensReleased(uint schedule, address holder, address token, uint256 amount);

    event NewPollCreated(BaseObjects.Poll _vote);
    event PollEnded(uint256 startBlock);
    event Voted(uint256 _pollId, bool _inFavour, address _voter);
    event VoteCanceled(uint256 _pollId, uint256 _option, address _voter, uint256 _noOfVotes);
    event StakingPoolLiquidityInitiated(uint256 _amount);

    constructor(address _erc20Contract) {
        owner = msg.sender;
        erc20Contract = _erc20Contract;
    }

    /**
     * @dev
     * public address for the owner of the contract
     */
    address public owner;

    /**
     * @dev
     * public address of the erc20 contract linked to this staking contract
     */
    address erc20Contract;

    uint256 startBlock;

    mapping (address => BaseObjects.Vester)  vesters;    // balances assigned to a wallet for a schedule

    // The total number of tokens managed by the contract
    uint256 public totalManaged;

    // total amount the contract has released.
    uint256 public totalReleased;

    // The recipients we know
    address[] public recipientsManaged;

    BaseObjects.Schedule[] schedules;
    
    /**
     * @dev
     * array which holds all polls of this contract
     */
    BaseObjects.Poll[] public polls;

    /**
     * @dev
     * mapping which stores wether an given address already voted on a given poll
     */
    mapping(address => mapping(uint => bool)) public votedCheck;

    /**
     * @dev
     * stores the amount of infavour votes
     */
    uint256 inFavour;

    /**
     * @dev
     * access modifier for the owner
     */
    modifier onlyOwner {
        require(msg.sender == owner, "The sender of the message needs to be the contract owner");
        _;
    }

    /**
     * @dev
     * adds a schedule with the given data
     * @param _id is the id of the vote
     * @param _numBlocks is the total number of blocks the vesting runs over
     * @param _minBlockWait is the blocks a wallet needs to wait between two claims of vested token
     */
    function addSchedule(string calldata _id, uint256 _numBlocks, uint256 _minBlockWait) public onlyOwner {
        BaseObjects.Schedule memory schedule;

        schedule.id = _id;
        schedule.numBlocks = _numBlocks;
        schedule.minBlockWait = _minBlockWait;
        schedule.totalVestings = SafeMath.div(_numBlocks, _minBlockWait);
        schedules.push(schedule);
        emit ScheduleAdded(schedules.length - 1);
    }

    /**
     * @dev
     * sets a new start block for the vesting period
     * @param _newStartBlock is the new startblock to set
     *
     * Called by the owner once before the vesting start, can only be changed later using a poll. 
     * The constructor sets the start block to zero, and it can therefore be set ONCE to kick off the
     * vesting without a poll.
     */
    function setStartBlock(uint256 _newStartBlock) public onlyOwner {
        require(startBlock == 0, "You can now only update the start block using a poll");
        startBlock = _newStartBlock;
        emit StartBlockSet(startBlock);
    }

     /**
      * @dev Returns the current start block 
      */
    function getStartBlock() public view returns (uint256) {
        return startBlock;
    }

     /**
      * @dev Returns the amount of schedules we have
      */
    function getNumSchedules() public view returns (uint256) {
        return schedules.length;
    }
    
     /**
      * @dev Returns a specific schedule
      */
    function getSchedule(uint index) public view returns (BaseObjects.Schedule memory) {
        return schedules[index];
    }
    
     /**
      * @dev The amount of token managed by this contract
      */
    function getVestingLockedTokens() public view returns (uint256) {
        return(ICryptopolisERC20(erc20Contract).balanceOf(address(this)));
    }
    
     /**
      * @dev Add a wallet to be managed by the contract
      * @param _recipientAddress is the awallet which will be able to vest token
      * @param _amount is the amount of token the _recipientAddress can vest in total
      * @param _schedule is the schedule this wallet runs on
      */
    function addRecipientWallet(address _recipientAddress, uint256 _amount, uint _schedule) public onlyOwner {
        require(vesters[_recipientAddress].totalReward == 0, "Can't add the same recipient more than once");
        require(totalManaged + _amount <= ICryptopolisERC20(erc20Contract).balanceOf(address(this)), "There are not enough tokens available");

        BaseObjects.Vester memory vester;
        vester.vesterAddress = _recipientAddress;

        require(schedules[_schedule].numBlocks > 0, "Can't add the same recipient more than once");
        vester.schedule = _schedule;

        vester.rewardPerVestingPeriod = SafeMath.div(_amount, schedules[_schedule].totalVestings);
        vester.totalReward = _amount;

//        console.log("addRecipientWallet: Total amount: %s, number of vestings: %s, rewardPerVestingPeriod: %s", _amount, schedules[_schedule].totalVestings, vester.rewardPerVestingPeriod);

        totalManaged += _amount;
        vesters[_recipientAddress] = vester;
        recipientsManaged.push(_recipientAddress);

        emit RecipientAdded(_recipientAddress, _amount);
    }

     /**
      * @dev Returns the amount of vesters we have
      */
    function getNumRecipients() public view returns (uint) {
        return recipientsManaged.length;
    }
    
     /**
      * @dev Returns the amount of vesters we have
      */
    function getRecipientAddress(uint index) public view returns (address) {
        return recipientsManaged[index];
    }
    
     /**
      * @dev Returns a specific vester
      */
    function getRecipientInfo(address recipientAddress) public view returns (BaseObjects.Vester memory) {
        return vesters[recipientAddress];
    }
    
     /**
      * @dev Calculate the amount that can be vested right now
      * @param _recipientAddress is the wallet to calculate the vesting amount for
      */
    function calculateVestingAmount(address _recipientAddress) internal view returns(uint256) {
        require(block.number > startBlock, "Not started vesting yet");
        require(startBlock > 0, "Not started vesting yet");
        uint256 lastVested = startBlock;
        if (vesters[_recipientAddress].lastVestedBlock > lastVested) {
            lastVested = vesters[_recipientAddress].lastVestedBlock;
        }

        // console.log("calculateVestingAmount: LastVested: %s", lastVested);
        uint256 blocksToVest = block.number - lastVested;

        uint256 vestingsAvailableNow = SafeMath.div(blocksToVest, schedules[vesters[_recipientAddress].schedule].minBlockWait);

        // console.log("calculateVestingAmount: NumBlocks: %s, BlockWait: %s", schedules[vesters[_recipientAddress].schedule].numBlocks, schedules[vesters[_recipientAddress].schedule].minBlockWait);

        if (vestingsAvailableNow == 0) {
            return 0;
        }
        
        // console.log("calculateVestingAmount: number of blocks to Vest: %s, vestingsAvailable: %s", blocksToVest, vestingsAvailableNow);
        // console.log("calculateVestingAmount: TotalVestings: %s", schedules[vesters[_recipientAddress].schedule].totalVestings);

        // console.log("calculateVestingAmount: Reward per vesting: %s", vesters[_recipientAddress].totalReward);

        uint256 vestingAmountAvailableNow = SafeMath.mul(vesters[_recipientAddress].rewardPerVestingPeriod, vestingsAvailableNow);

        // console.log("calculateVestingAmount: vestingAmountAvailableNow before limiting: %s", vestingAmountAvailableNow);

        // Limit the amount vested to the total amount available for this wallet
        if (SafeMath.add(vestingAmountAvailableNow, vesters[_recipientAddress].claimedVestingRewards) > vesters[_recipientAddress].totalReward) {
            vestingAmountAvailableNow = SafeMath.sub(vesters[_recipientAddress].totalReward, vesters[_recipientAddress].claimedVestingRewards);
        }

        return vestingAmountAvailableNow;
    }

     /**
      * @dev Preview the amount that can be vested right now
      */
    function getVestingAmount(address recipientAddress) public view returns (uint256) {
        // console.log("Current: %s, start: %s",block.number,schedules[onSchedule[msg.sender]].startBlock);
        // console.log("Last vested: %s",released[msg.sender]);
//        require(block.number > schedules[onSchedule[msg.sender]].minBlockWait + released[msg.sender], "Not ready for distribution");

        return calculateVestingAmount(recipientAddress);
    }

     /**
      * @dev Perform the vesting right now
      */
    function vestAvailable() public {
        uint256 vestingAmount = calculateVestingAmount(msg.sender);
        vesters[msg.sender].lastVestedBlock = block.number;
        vesters[msg.sender].claimedVestingRewards += vestingAmount;
        totalManaged -= vestingAmount;
        totalReleased += vestingAmount;
        ICryptopolisERC20(erc20Contract).transfer(msg.sender, vestingAmount);

        emit TokensReleased(vesters[msg.sender].schedule, msg.sender, erc20Contract, vestingAmount);
    }

     /**
      * @dev Change the owner of the contract
      */
    function setOwner(address newOwnerAddress) public onlyOwner {
        owner = newOwnerAddress;
    }

    /**
     *
     * @dev allows admin to create a poll
     * @param _text is the poll text
     * @param _endBlock holds the block at which the admin can close the poll
     *
     */
    function createPoll(string calldata _text, uint256 _endBlock, uint256 _newVestingStartBlock) public onlyOwner {
        if(polls.length > 0) {
            require(!polls[polls.length - 1].open, "There can only be one open vote at a time");
        }
        require(_newVestingStartBlock > _endBlock, "The new vesting start block can not be before the poll end");
        BaseObjects.Poll memory newPoll = BaseObjects.Poll(_text, _endBlock, _newVestingStartBlock, 0, true);
        polls.push(newPoll);
        // what sense does it make to store the polls, if we delete the result of it? If we want to do it like this, then we should simply create one poll and delete it afterwards
        inFavour = 0;
        emit NewPollCreated(newPoll);
    }

    /**
     *
     * @dev allows the admin to close an open poll
     *
     */
    function closeOpenPoll() public onlyOwner {
        require(polls[polls.length - 1].endBlock < block.number, "The end block of this vote has not been reached yet");
        polls[polls.length - 1].open = false;
        uint256 threshold = SafeMath.div(totalManaged, 2);
//        console.log("InFavour %s, threshold %s", inFavour, threshold);
        if (inFavour > threshold) {
//            console.log("Set vesting block to %s", polls[polls.length - 1].newVestingStartBlock);
            startBlock = polls[polls.length - 1].newVestingStartBlock;
        }
        emit PollEnded(startBlock);
    }

    /**
     *
     * @dev allows a vesters to vote on a postponment.
     * @param _inFavour If the voter agrees on the postponement
     *
     */
    function voteOnPoll(bool _inFavour) public {
        require(vesters[msg.sender].totalReward > 0, "Only recipients are allowed to vote");
        require(polls.length > 0, "There is no open poll");
        require(polls[polls.length - 1].open, "There is no open poll");
        require(!votedCheck[msg.sender][polls.length - 1], "Address already voted");
        require(block.number <= polls[polls.length - 1].endBlock, "The ending block of this poll was reached already");
        votedCheck[msg.sender][polls.length - 1] = true;
        if (_inFavour) {
            // console.log("Contribution %s",vesters[msg.sender].totalReward);
            inFavour += vesters[msg.sender].totalReward;
        }
        emit Voted(polls.length - 1, _inFavour, msg.sender);
    }   

    /**
     *
     * @dev public getter which returns all information for a single poll
     * @param _index is the index of the poll to query for details
     *
     */
    function getPollDetails(uint _index) public view returns (BaseObjects.Poll memory) {
        BaseObjects.Poll memory newPoll = polls[_index];
        return newPoll;
    }

    /**
     *
     * @dev internal helper to get the amount of polls
     *
     */
    function pollCount() public view returns (uint256) {
        return polls.length;
    }

    /**
     *
     * @dev internal helper to check if the last poll is still open
     *
     */
    function checkIfPollIsOpen() internal view returns (bool) {
        return polls[polls.length - 1].open;
    }
}

// SPDX-License-Identifier: Cryptopolis

pragma solidity 0.8.13;

interface ICryptopolisERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: Cryptopolis

pragma solidity ^0.8.13;

library BaseObjects {

    struct Poll {
        string pollText;
        uint256 endBlock;
        uint256 newVestingStartBlock;
        uint256 inFavour;
        bool open;
    }

    struct Schedule {
        string id;               // eg. "foundation", "marketing" etc.
        uint256 numBlocks;       // number of blocks to vest over
        uint256 minBlockWait;    // number of blocks to wait after withdrawing
        uint256 totalVestings;   // The total number of vestings we expect
    }

    struct Vester {
        address vesterAddress;          //address of the vester
        uint    schedule;               //schedule of the wallet
        uint256 lastVestedBlock;        // The block we last vested at
        uint256 rewardPerVestingPeriod; // the total amount of vesting rewards this vester can claim
        uint256 claimedVestingRewards;  // counts up from 0 until it reaches the rewardPerVestingPeriod
        uint256 totalReward;            // The total reward for this vester
    }
}