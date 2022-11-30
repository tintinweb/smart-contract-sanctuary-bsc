// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./interfaces/IVotingPower.sol";
import "./interfaces/IBSKTStakingContract.sol";
// import "hardhat/console.sol"; // remove or comment 

contract Governor {
    using Timers for Timers.BlockNumber;
    using SafeCast for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _pollingCounter;
    Counters.Counter private _executiveCounter;
    address private _owner;
    address private basketCoin;
    address private stakedContract;
    address private basketCoinNFT;
    address private votingPowerContractor;

    constructor (address _basketCoin, address _stakedContract, address _basketCoinNFT, address _votingPowerContract) {
        require(_basketCoin != address(0), "BasketCoin not defined");
        require(_stakedContract != address(0), "StakedCoin not defined");
        require(_basketCoinNFT != address(0), "BasketCoinNFT not defined");
        require(_votingPowerContract != address(0), "VotiingPower Contract not defined");
        _owner = _msgSender();
        basketCoin = _basketCoin;
        stakedContract = _stakedContract;
        basketCoinNFT = _basketCoinNFT;
        votingPowerContractor = _votingPowerContract;
    }

    /**
        Events
     */
    event PollingProposalCreated(
        uint256 proposalId,
        address proposer,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    event ExecutiveProposalCreated(
        uint256 proposalId,
        address proposer,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );
    event pollingProposalCanceled(uint256 proposalId);
    event executiveProposalCanceled(uint256 proposalId);
    event PollingVoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);
    event ExecutiveVoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);
    /**
     * @dev Emitted when a proposal is canceled.
     */
    event PollingProposalCanceled(uint256 proposalId);
    event ExecutiveProposalCanceled(uint256 proposalId);

    /**
     * @dev Emitted when a proposal is executed.
     */
    event PollingProposalExecuted(uint256 proposalId);
    event ExecutiveProposalExecuted(uint256 proposalId);


    enum VoteType {
        Against,
        For,
        Abstain
    }

    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
    
    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
        address[] voters;
    }

    uint256 private quorumFractionDenominator = 100;
    uint256 private quorumFractionNumerator = 4;

    mapping(uint256 => ProposalVote) private _pollingProposalVotes;
    mapping(uint256 => ProposalVote) private _executiveProposalVotes;

    struct ProposalCore {
        Timers.BlockNumber voteStart;
        Timers.BlockNumber voteEnd;
        bool executed;
        bool canceled;
        string description;
        uint256 proposalStart;
        uint256 proposalEnd;
    }

    mapping(uint256 => ProposalCore) private _pollingProposals;
    mapping(uint256 => ProposalCore) private _executiveProposals;
    mapping(address => bool) private _admins;

    /**
        Access control Mechanisms
     */

    function _msgSender() view private returns (address) {
        return msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    /**
     * add and remove admins to create executive proposals
     */

    function addAdmin(address admin) external onlyOwner {
        _admins[admin] = true;
    } 

    function removeAdmin(address admin) external onlyOwner {
        _admins[admin] = false;
    }

    function isAdmin(address user) external view returns (bool) {
        return _admins[user];
    }

    /**
     * Update quorum denominator
     */
    function updateQuorumDenominator(uint256 _quorumDenominator) external onlyOwner {
        quorumFractionDenominator = _quorumDenominator;
    }
    function updateQuorumNumerator(uint256 _quorumNumerator) external onlyOwner {
        quorumFractionNumerator = _quorumNumerator;
    }

    /**
     * Create Proposal for 
     */
    function createPollingProposal(string calldata description, uint64 votingPeriod, string[] calldata cards, string calldata pairName) public returns(uint256 _pollingProposalId) {
        {  
            require(((calculateVotingPower(cards, _msgSender(), pairName)) / (IVotingPower(votingPowerContractor).getDivisor())) > IVotingPower(votingPowerContractor).getMinimumVotingPower(), "Not enough voting power");
        }
        uint256 proposalId = _pollingCounter.current();
        _pollingCounter.increment();
        ProposalCore storage proposal = _pollingProposals[proposalId];

        {
            uint64 snapshot = block.number.toUint64();
            uint64 deadline = snapshot + votingPeriod;
            proposal.voteStart.setDeadline(snapshot);
            proposal.voteEnd.setDeadline(deadline);
            proposal.description = description;
            proposal.proposalStart = block.timestamp;
            proposal.proposalEnd = block.timestamp + votingPeriod;

            emit PollingProposalCreated(
                proposalId,
                _msgSender(), 
                snapshot,
                deadline,
                proposal.description
            );
            return proposalId;
        }
        
    }

    /**
     * Create Proposal for 
     */
    function createExecutiveProposal(string calldata description, uint64 votingPeriod, string[] calldata cards, string calldata pairName) public returns(uint256 _pollingProposalId) {
        require(_admins[_msgSender()] == true || _msgSender() == _owner, "Admin Access Required");
        uint256 votingPower = calculateVotingPower(cards, _msgSender(), pairName);
        require(votingPower / (IVotingPower(votingPowerContractor).getDivisor()) > IVotingPower(votingPowerContractor).getMinimumVotingPower(), "Not enough voting power");

        uint256 proposalId = _executiveCounter.current();
        _executiveCounter.increment();
        ProposalCore storage proposal = _executiveProposals[proposalId];
        
        uint64 snapshot = block.number.toUint64();
        uint64 deadline = snapshot + votingPeriod;
        proposal.voteStart.setDeadline(snapshot);
        proposal.voteEnd.setDeadline(deadline);
        proposal.description = description;
        proposal.proposalStart = block.timestamp;
        proposal.proposalEnd = block.timestamp + votingPeriod;

        emit ExecutiveProposalCreated(
            proposalId,
            _msgSender(), 
            snapshot,
            deadline,
            proposal.description
        );
        return proposalId;
    }

    function calculateVotingPower(string[] calldata cards, address voter, string calldata pairName) internal view returns(uint256 votingPower){
        uint256 power = 0;
        for(uint256 i=0; i< cards.length; i++) {
            power += IVotingPower(votingPowerContractor).getVotingPower(cards[i]);
        }
        power += IERC20(basketCoin).balanceOf(voter) * (IVotingPower(votingPowerContractor).getDivisor());
        power += IBSKTStakingPool(stakedContract).balanceOf(voter) * (IVotingPower(votingPowerContractor).getDivisor());

        if(IVotingPower(votingPowerContractor).getMultiplier(pairName) > 0) {
                power = power * IVotingPower(votingPowerContractor).getMultiplier(pairName);
        }
        return power;
    }

    function castPollingVote(
        uint256 proposalId,
        uint8 support,
        string calldata reason,
        string[] calldata cards, 
        string calldata pairName
    ) external {

        address voter = _msgSender();

        ProposalVote storage proposal = _pollingProposalVotes[proposalId];
        // require(state(proposalId) == ProposalState.Active, "Governor: vote not currently active");

        uint256 power = calculateVotingPower(cards, voter, pairName);

        require(!proposal.hasVoted[voter], "Governor: vote already cast");
        proposal.hasVoted[voter] = true;
        proposal.voters.push(voter);
        if(power > 0) {
            if (support == uint8(VoteType.Against)) {
                proposal.againstVotes += power;
            } else if (support == uint8(VoteType.For)) {
                proposal.forVotes += power;
            } else if (support == uint8(VoteType.Abstain)) {
                proposal.abstainVotes += power;
            } else {
                revert("Governor: invalid value for enum VoteType");
            }
        }

        emit PollingVoteCast(voter, proposalId, support, power, reason);  

    }

    function castExecutiveVote(
        uint256 proposalId,
        uint8 support,
        string calldata reason,
        string[] calldata cards, 
        string calldata pairName
    ) external {

        address voter = _msgSender();

        ProposalVote storage proposal = _executiveProposalVotes[proposalId];
        // require(state(proposalId) == ProposalState.Active, "Governor: vote not currently active");

        uint256 power = calculateVotingPower(cards, voter, pairName);

        require(!proposal.hasVoted[voter], "Governor: vote already cast");
        proposal.hasVoted[voter] = true;
        proposal.voters.push(voter);

        if(power > 0) {
            if (support == uint8(VoteType.Against)) {
                proposal.againstVotes += power;
            } else if (support == uint8(VoteType.For)) {
                proposal.forVotes += power;
            } else if (support == uint8(VoteType.Abstain)) {
                proposal.abstainVotes += power;
            } else {
                revert("Governor: invalid value for enum VoteType");
            }
        }

        emit ExecutiveVoteCast(voter, proposalId, support, power, reason);

    }

    function hasVotedOnPollingProposal(address user, uint256 proposalId) external view returns(bool hastVoted) {
       ProposalVote storage votingData = _pollingProposalVotes[proposalId];
       return votingData.hasVoted[user];
    }

    function hasVotedOnExecutiveProposal(address user, uint256 proposalId) external view returns(bool hastVoted) {
       ProposalVote storage votingData = _executiveProposalVotes[proposalId];
       return votingData.hasVoted[user];
    }

    function getVotingPowerOfUser(
        string[] calldata cards, 
        string calldata pairName,
        address user
    ) external view returns (uint256 votingPower) {
        return calculateVotingPower(cards, user, pairName);
    }

    function getPollingProposaldetails(uint256 proposalId) external view returns (
        string memory description,
        uint256 voteStart,
        uint256 voteEnd,
        uint256 againstVotes,
        uint256 forVotes,
        uint256 abstainVotes,
        address[] memory voters,
        ProposalState status
    ){
        ProposalCore storage proposal = _pollingProposals[proposalId];
        ProposalVote storage proposalVotes = _pollingProposalVotes[proposalId];
        ProposalState statusquo = pollingProposalStatus(proposalId);
        string memory _description = proposal.description;
        address[] memory _voters = proposalVotes.voters;

        return (
            _description,
            proposal.proposalStart,
            proposal.proposalEnd,
            proposalVotes.againstVotes,
            proposalVotes.forVotes,
            proposalVotes.abstainVotes,
            _voters,
            statusquo
        );

    }

    function getExecutiveProposaldetails(uint256 proposalId) external view returns (
        string memory description,
        uint256 voteStart,
        uint256 voteEnd,
        uint256 againstVotes,
        uint256 forVotes,
        uint256 abstainVotes,
        address[] memory voters,
        ProposalState status
    ){
        ProposalCore storage proposal = _executiveProposals[proposalId];
        ProposalVote storage proposalVotes = _executiveProposalVotes[proposalId];
        ProposalState statusquo = executiveProposalStatus(proposalId);
        string memory _description = proposal.description;
        address[] memory _voters = proposalVotes.voters;

        return (
            _description,
            proposal.proposalStart,
            proposal.proposalEnd,
            proposalVotes.againstVotes,
            proposalVotes.forVotes,
            proposalVotes.abstainVotes,
            _voters,
            statusquo
        );

    }

    function getPollingProposalCount() external view returns(uint256 count) {
        return _pollingCounter.current();
    }

    function getExecutiveProposalCount() external view returns(uint256 count) {
        return _executiveCounter.current();
    }

    function pollingProposalStatus(uint256 proposalId) public view virtual returns (ProposalState) {
        ProposalCore storage proposal = _pollingProposals[proposalId];
        if (proposal.executed) {
            return ProposalState.Executed;
        }

        if (proposal.canceled) {
            return ProposalState.Canceled;
        }

        uint256 snapshot = pollingProposalSnapshot(proposalId);
        
        if (snapshot == 0) {
            revert("Governor: unknown proposal id");
        }

        if (snapshot >= block.number) {
            return ProposalState.Pending;
        }

        uint256 deadline = pollingProposalDeadline(proposalId);
        if (deadline >= block.number) {
            return ProposalState.Active;
        }
       
        if (_pollingQuorumReached(proposalId) && _pollingVoteSucceeded(proposalId)) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    function executiveProposalStatus(uint256 proposalId) public view virtual returns (ProposalState) {
        ProposalCore storage proposal = _executiveProposals[proposalId];

        if (proposal.executed) {
            return ProposalState.Executed;
        }

        if (proposal.canceled) {
            return ProposalState.Canceled;
        }

        uint256 snapshot = executiveProposalSnapshot(proposalId);

        if (snapshot == 0) {
            revert("Governor: unknown proposal id");
        }

        if (snapshot >= block.number) {
            return ProposalState.Pending;
        }

        uint256 deadline = executiveProposalDeadline(proposalId);

        if (deadline >= block.number) {
            return ProposalState.Active;
        }

        if (_executiveQuorumReached(proposalId) && _executiveVoteSucceeded(proposalId)) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    function pollingProposalSnapshot(uint256 proposalId) public view virtual returns (uint256) {
        return _pollingProposals[proposalId].voteStart.getDeadline();
    }

    function executiveProposalSnapshot(uint256 proposalId) public view virtual returns (uint256) {
        return _executiveProposals[proposalId].voteStart.getDeadline();
    }

    function pollingProposalDeadline(uint256 proposalId) public view virtual  returns (uint256) {
        return _pollingProposals[proposalId].voteEnd.getDeadline();
    }

    function executiveProposalDeadline(uint256 proposalId) public view virtual returns (uint256) {
        return _executiveProposals[proposalId].voteEnd.getDeadline();
    }

    function _pollingQuorumReached(uint256 proposalId) internal view virtual returns (bool) {
        ProposalVote storage proposalvote = _pollingProposalVotes[proposalId];
        return quorum() <= ((proposalvote.forVotes + proposalvote.abstainVotes) / IVotingPower(votingPowerContractor).getDivisor());
    }

    function _executiveQuorumReached(uint256 proposalId) internal view virtual returns (bool) {
        ProposalVote storage proposalvote = _executiveProposalVotes[proposalId];
        return quorum() <= ((proposalvote.forVotes + proposalvote.abstainVotes)/ IVotingPower(votingPowerContractor).getDivisor());
    }

    function quorum() internal view virtual returns (uint256) {
        uint256 totalSupply = IERC20(basketCoin).totalSupply() + IBSKTStakingPool(stakedContract).totalSupply() + IERC721Enumerable(basketCoinNFT).totalSupply();
        return (totalSupply * quorumFractionNumerator) / quorumFractionDenominator;
    }

    function _pollingVoteSucceeded(uint256 proposalId) internal view virtual returns (bool) {
        ProposalVote storage proposalvote = _pollingProposalVotes[proposalId];
        return proposalvote.forVotes > proposalvote.againstVotes;
    }

    function _executiveVoteSucceeded(uint256 proposalId) internal view virtual returns (bool) {
        ProposalVote storage proposalvote = _executiveProposalVotes[proposalId];
        return proposalvote.forVotes > proposalvote.againstVotes;
    }

    function executePollingProposal(
        uint256 proposalId
    ) public virtual returns (uint256) {
        require(_admins[_msgSender()] == true || _msgSender() == _owner, "Admin Access Required");

        ProposalState status = pollingProposalStatus(proposalId);

        require(
            status == ProposalState.Succeeded || status == ProposalState.Queued,
            "Governor: proposal not successful"
        );
        _pollingProposals[proposalId].executed = true;

        emit PollingProposalExecuted(proposalId);

        return proposalId;
    }

    function executeExecutiveProposal(
        uint256 proposalId
    ) public virtual returns (uint256) {
        require(_admins[_msgSender()] == true || _msgSender() == _owner, "Admin Access Required");

        ProposalState status = executiveProposalStatus(proposalId);
        require(
            status == ProposalState.Succeeded || status == ProposalState.Queued,
            "Governor: proposal not successful"
        );
        _executiveProposals[proposalId].executed = true;

        emit ExecutiveProposalExecuted(proposalId);

        return proposalId;
    }

    function cancelPollingProposal(uint256 proposalId) public virtual returns(uint256) {
        require(_admins[_msgSender()] == true || _msgSender() == _owner, "Admin Access Required");

        ProposalState status = pollingProposalStatus(proposalId);
        require(
            status != ProposalState.Canceled && status != ProposalState.Expired && status != ProposalState.Executed,
            "Governor: proposal not active"
        );

        _pollingProposals[proposalId].canceled = true;
        emit pollingProposalCanceled(proposalId);

        return proposalId;
    }

    function cancelExecutiveProposal(uint256 proposalId) public virtual returns(uint256) {
        require(_admins[_msgSender()] == true || _msgSender() == _owner, "Admin Access Required");

        ProposalState status = executiveProposalStatus(proposalId);
        require(
            status != ProposalState.Canceled && status != ProposalState.Expired && status != ProposalState.Executed,
            "Governor: proposal not active"
        );

        _executiveProposals[proposalId].canceled = true;
        emit executiveProposalCanceled(proposalId);

        return proposalId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Timers.sol)

pragma solidity ^0.8.0;

/**
 * @dev Tooling for timepoints, timers and delays
 */
library Timers {
    struct Timestamp {
        uint64 _deadline;
    }

    function getDeadline(Timestamp memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(Timestamp storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(Timestamp storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(Timestamp memory timer) internal view returns (bool) {
        return timer._deadline > block.timestamp;
    }

    function isExpired(Timestamp memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.timestamp;
    }

    struct BlockNumber {
        uint64 _deadline;
    }

    function getDeadline(BlockNumber memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(BlockNumber storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(BlockNumber storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(BlockNumber memory timer) internal view returns (bool) {
        return timer._deadline > block.number;
    }

    function isExpired(BlockNumber memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.number;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IVotingPower {

    function setVotingPower(string memory card, uint256 _votingPower) external;

    function getVotingPower(string memory card) external view returns (uint256 _votingPower);

    function setMultiplier(string memory sequenceName, uint256 _multiplier) external;

    function getMultiplier(string memory sequenceName) external view returns(uint256 _multiplier);

    function setDivisor(uint256 _divisor) external;

    function getDivisor() external view returns (uint256 _divisor);

    function setMinimumVotingPower(uint256 power) external;

    function getMinimumVotingPower() external view returns(uint256 _minimumVotingPower);
}

// SPDX-License-Identifier: UNLICENSED
// !! THIS FILE WAS AUTOGENERATED BY abi-to-sol v^0.8.4. SEE SOURCE BELOW. !!
pragma solidity ^0.8.4;

interface IBSKTStakingPool {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Rewarded(address indexed from, address indexed to, uint256 value);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function BSKTASREWARD() external view returns (address);

    function STAKEBSKT() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function duration() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function exit() external;

    function getReward() external;

    function isOwner() external view returns (bool);

    function lastTimeRewardApplicable() external view returns (uint256);

    function lastUpdateTime() external view returns (uint256);

    function minimumBsktStakingEntry(address) external view returns (bool);

    function notifyRewardRate(uint256 _reward) external;

    function owner() external view returns (address);

    function periodFinish() external view returns (uint256);

    function renounceOwnership() external;

    function rewardPerToken() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewards(address) external view returns (uint256);

    function setDuration(uint256 _duration) external;

    function stake(uint256 amount) external;

    function starttime() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function userRewardPerTokenPaid(address) external view returns (uint256);

    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}