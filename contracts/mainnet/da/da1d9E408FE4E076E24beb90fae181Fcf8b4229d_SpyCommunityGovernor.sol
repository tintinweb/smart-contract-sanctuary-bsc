pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/ICompoundPool.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract SpyCommunityGovernor is Ownable {
    using SafeMath for uint256;

    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Queued,
        Expired,
        Executed
    }

    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct Receipt {
        bool hasVoted;
        uint8 support;
        uint256 votes;
    }

    struct Proposal {
        uint256 id;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 expiringTime;
        uint256 snapshot;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool canceled;
        bool executed;
        mapping(address => Receipt) receipts;
        bytes32 descriptionHash;
    }
    mapping(uint256 => Proposal) private _proposals;
    mapping(address => mapping(uint256 => uint256)) private _extraWeights;
    mapping(address => mapping(uint256 => bool)) private _hasCalculatedWeights;
    mapping(address => bool) public executors;

    IERC20 public spy;
    uint256 private _delay = 4 hours; // 4 hours
    uint256 public constant MINIMUM_DURATION = 8 hours; 
    uint256 public constant MINIMUM_EXECUTION_DURATION = 8 hours;
    uint256 private _threshold = 0;
    // Dev has right to change parameters
    address public dev;
    uint256[] public spyFarmIds;
    address[] public compoundPools;
    IMasterChef public masterchef;

    // only dev can propose a proposal
    modifier onlyDev(){
        require(_msgSender() == dev, "Only dev");
        _;
    }

    modifier onlyExecutor(){
        require(executors[_msgSender()], "Only dev");
        _;
    }

    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        uint256 startTime,
        uint256 endTime,
        uint256 expiringTime,
        string description
    );
    event ProposalCanceled(uint256 proposalId);
    event ProposalExecuted(uint256 proposalId);
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);


    constructor(
        address _spy, 
        address _masterchef,
        uint256[] memory _spyFarmIds, 
        address[] memory _compoundPools)
    {
        spy = IERC20(_spy);
        dev = _msgSender();
        executors[dev] = true;
        masterchef = IMasterChef(_masterchef);
        compoundPools = _compoundPools;
        spyFarmIds = _spyFarmIds;
    }

    function propose(
        uint256 duration,
        uint256 executionDuration,
        string memory description
    ) external returns (uint256) {
        address proposer = _msgSender();

        require(duration >= MINIMUM_DURATION, "duration is less than minimum value");
        require(executionDuration >= MINIMUM_EXECUTION_DURATION, "execution duration is less than minimum value");
        require(
            getVotes(proposer, block.number - 1) >= proposalThreshold(),
            "GovernorCompatibilityBravo: proposer votes below proposal threshold"
        );


        bytes32 descriptionHash = keccak256(bytes(description));
        uint256 proposalId = hashProposal(duration, executionDuration, descriptionHash);

        Proposal storage proposal = _proposals[proposalId];
        require(proposal.proposer == address(0), "duplicated proposal");
        proposal.proposer = proposer;
        proposal.descriptionHash = descriptionHash;
        proposal.startTime = block.timestamp + _delay;
        proposal.endTime = proposal.startTime + duration;
        proposal.expiringTime = proposal.endTime + executionDuration;
        proposal.snapshot = block.number + _delay.div(3);

        emit ProposalCreated(
            proposalId,
            proposer,
            proposal.startTime,
            proposal.endTime,
            proposal.expiringTime,
            description
        );

        return proposalId;
    }

    function castVote(uint256 proposalId, uint8 support) external returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, support, "");
    }

    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) external returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, support, reason);
    }

    function execute(uint256 proposalId) external onlyExecutor {
        require(state(proposalId) == ProposalState.Queued, "Not queued");
        require(executors[_msgSender()], "Not executor");
        Proposal storage proposal = _proposals[proposalId];
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }

    function cancel(uint256 proposalId) external onlyExecutor {
        ProposalState proposalState = state(proposalId);
        require(proposalState == ProposalState.Active || proposalState == ProposalState.Pending, "Not pending or running");
        Proposal storage proposal = _proposals[proposalId];
        require(executors[_msgSender()] || proposal.proposer == _msgSender(), "Not propser");
        proposal.canceled = true;
        emit ProposalCanceled(proposalId);
    }

    function setExecutor(address executor, bool isExcutor) external onlyDev {
        executors[executor] = isExcutor;
    }

    function setDelay(uint256 delay) external onlyDev {
        _delay = delay;
    }

    function setThreshold(uint256 threshold) external onlyDev {
        _threshold = threshold;
    }

    function proposalSnapshot(uint256 proposalId) public view returns (uint256) {
        return _proposals[proposalId].snapshot;
    }

    function votingDelay() public view returns (uint256) {
        return _delay;
    }

    function proposalThreshold() public view returns (uint256) {
        return _threshold;
    }

    function proposals(uint256 proposalId) public view 
        returns (
            uint256 id,
            address proposer,
            uint256 startTime,
            uint256 endTime,
            uint256 expiringTime,
            uint256 forVotes,
            uint256 againstVotes,
            uint256 abstainVotes,
            bool canceled,
            bool executed
        )
    {

        Proposal storage proposal = _proposals[proposalId];
        id = proposalId;
        startTime = proposal.startTime;
        endTime = proposal.endTime;
        expiringTime = proposal.expiringTime;
        proposer = proposal.proposer;
        forVotes = proposal.forVotes;
        againstVotes = proposal.againstVotes;
        abstainVotes = proposal.abstainVotes;

        ProposalState status = state(proposalId);
        canceled = status == ProposalState.Canceled;
        executed = status == ProposalState.Executed;
    }

    function state(uint256 proposalId) public view returns (ProposalState) {
        Proposal storage proposal = _proposals[proposalId];

        if (proposal.executed) {
            return ProposalState.Executed;
        }

        if (proposal.canceled) {
            return ProposalState.Canceled;
        }

        if (proposal.startTime == 0) {
            revert("Governor: unknown proposal id");
        }

        if (proposal.startTime >= block.timestamp) {
            return ProposalState.Pending;
        }

        if (proposal.endTime >= block.number) {
            return ProposalState.Active;
        }

        if (_voteSucceeded(proposalId)) {
            if (proposal.expiringTime >= block.number) {
                return ProposalState.Queued;
            }

            return ProposalState.Expired;
        } else {
            return ProposalState.Defeated;
        }
    }

    function voteWeightForProposal(uint256 proposalId, address account) external view returns (uint256) {
        uint256 snapshot = proposalSnapshot(proposalId);
        return spy.balanceOf(account) + _extraWeights[account][snapshot];
    }

    function calculatedWeightForProposal(uint256 proposalId, address account) external view returns (bool) {
        uint256 snapshot = proposalSnapshot(proposalId);
        return _hasCalculatedWeights[account][snapshot];
    }

    function hasVoted(uint256 proposalId, address account) external view returns (bool) {
        return _proposals[proposalId].receipts[account].hasVoted;
    }

    function hashProposal(
        uint256 duration,
        uint256 executionDuration,
        bytes32 descriptionHash
    ) public view returns (uint256) {
        return uint256(keccak256(abi.encode(duration, executionDuration, descriptionHash)));
    }

    function getVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {
        return spy.balanceOf(account) + _extraWeights[account][blockNumber];
    }

    function calculateWeight(uint256 proposalId, address account) public {
        uint256 snapshot = proposalSnapshot(proposalId);
        require(!_hasCalculatedWeights[account][snapshot], "Already calculated");

        uint256 extraWeight = 0;

        // calculate staked balance into farming pools
        for (uint256 i = 0; i < spyFarmIds.length; i ++) {
            (address lpToken,,,,) = masterchef.poolInfo(spyFarmIds[i]);
            (uint256 amount,,,) = masterchef.userInfo(spyFarmIds[i], account);
            uint256 totalSupply = IUniswapV2Pair(lpToken).totalSupply();
            uint256 balance0 = spy.balanceOf(lpToken);
            uint256 amount0 = amount.mul(balance0).div(totalSupply);
            extraWeight = extraWeight.add(amount0);
        }

        // calculate staked balance into compound pools
        for (uint256 i = 0; i < compoundPools.length; i ++) {
            ICompoundPool pool = ICompoundPool(compoundPools[i]);
            uint256 farmPid = pool.farmPid();
            uint256 amount = pool.lpOf(account);
            (address lpToken,,,,) = masterchef.poolInfo(farmPid);
            uint256 totalSupply = IUniswapV2Pair(lpToken).totalSupply();
            uint256 balance0 = spy.balanceOf(lpToken);
            uint256 amount0 = amount.mul(balance0) / totalSupply;
            extraWeight = extraWeight.add(amount0);
        }

        _extraWeights[account][snapshot] = extraWeight;
        _hasCalculatedWeights[account][snapshot] = true;
    }

    function _voteSucceeded(uint256 proposalId) internal view returns (bool) {
        Proposal storage proposal = _proposals[proposalId];
        return proposal.forVotes > proposal.againstVotes;
    }

    function _castVote(
        uint256 proposalId,
        address account,
        uint8 support,
        string memory reason
    ) internal virtual returns (uint256)
    {

        require(state(proposalId) == ProposalState.Active, "Governor: vote not currently active");

        Proposal storage proposal = _proposals[proposalId];
        require(_hasCalculatedWeights[account][proposal.snapshot], "You did not calculate your weight yet");

        uint256 weight = getVotes(account, proposal.snapshot);
        Receipt storage receipt = proposal.receipts[account];
        require(!receipt.hasVoted, "vote already cast");
        receipt.hasVoted = true;
        receipt.votes = weight;
        receipt.support = support;

        if (support == uint8(VoteType.Against)) {
            proposal.againstVotes += weight;
        } else if (support == uint8(VoteType.For)) {
            proposal.forVotes += weight;
        } else if (support == uint8(VoteType.Abstain)) {
            proposal.abstainVotes += weight;
        } else {
            revert("invalid vote type");
        }

        emit VoteCast(account, proposalId, support, weight, reason);

        return weight;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

pragma solidity ^0.8.4;

interface IMasterChef {

    function poolInfo(uint256 _pid) external view returns (
        address lpToken,
        uint256 allocPoint,
        uint256 lastRewardBlock,
        uint256 accPositionPerShare,
        uint256 harvestInterval
    );

    function userInfo(uint256 _pid, address _user) external view returns (
        uint256 amount,
        uint256 rewardDebt,
        uint256 rewardLockedUp,
        uint256 nextHarvestUntil
    );
}

pragma solidity ^0.8.4;

interface ICompoundPool {
    function farmPid() external view returns (uint256);
    function lpOf(address user) external view returns (uint256);
}

pragma solidity ^0.8.4;

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint);
}