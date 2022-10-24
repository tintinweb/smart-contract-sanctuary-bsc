/**
 *Submitted for verification at BscScan.com on 2022-10-24
*/

// File: IERC20.sol


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
// File: SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
// File: voting.sol


pragma solidity >=0.7.0 <0.9.0;



/// @title Voting with delegation.
contract Ballot {
    using SafeMath for uint256;

    address public chairPerson;
    uint256 public pollId;
    bool public acceptingProposals;
    bool public pollOpened;

    IERC20 public daoToken;

    uint256 private _proposalId;
    Proposal private submission;

    mapping(uint256 => mapping(uint256 => Proposal)) public pollHistory;
    mapping(uint256 => uint256) public pollWinner;
    mapping(address => uint256) public votersWeightUsed;
    // Proposal[] public proposals;

    event NewProposal(
        uint256 id,
        bytes32 title,
        bytes32 description,
        address account,
        address owner
    );
    event VoteSubmitted(address voter, uint256 proposalId);

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 title; // short title (up to 32 bytes)
        bytes32 description; // short description or link to detail description
        uint256 voteCount; // number of accumulated votes
        address account; // wallet address to transfer fund if selected
        address owner; // wallet account that submit the proposal
    }

    constructor(IERC20 _daoToken) {
        acceptingProposals = false;
        pollOpened = false;
        pollId = 0;
        _proposalId = 0;
        chairPerson = msg.sender;

        daoToken = _daoToken;
    }

    // chair allow public to start submitting proposals
    function openProposalsSubmissionForNextPoll() external {
        require(
            chairPerson == msg.sender,
            "Only a chair can open proposals acceptance"
        );
        acceptingProposals = true;
    }

    // chair stop accepting proposals
    function closeProposalsSubmissionForNextPoll() external {
        require(
            chairPerson == msg.sender,
            "Only a chair can close proposals acceptance"
        );
        acceptingProposals = false;
    }

    // Append new proposal to the to the end of `proposals`.
    function submitProposal(
        address owner,
        bytes32 title,
        bytes32 description,
        address account
    ) external {
        require(
            acceptingProposals == true,
            "Poll is currently not accepting proposals"
        );
        require(
            msg.sender == chairPerson,
            "Only the chair can submit a proposal on owner's behalf"
        );
        submission = Proposal({
            title: title,
            description: description,
            account: account,
            voteCount: 0,
            owner: owner
        });

        pollHistory[pollId][_proposalId] = submission;

        emit NewProposal(_proposalId, title, description, account, owner);
        _proposalId.add(1);
    }

    function startPoll() external {
        require(chairPerson == msg.sender, "Only the chair can open a poll");
        require(pollOpened == false, "One poll is currently open");
        pollOpened = true;
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(address sender, uint256 proposaId) external {
        require(pollOpened == true, "No poll is currently open");
        require(
            daoToken.balanceOf(sender) > 0,
            "You have not right to vote due to your insuffient KOLO token balance"
        );
        require(
            msg.sender == chairPerson,
            "Only the chair can submit a vote on owner's behalf"
        );
        require(proposaId <= _proposalId, "The proposal identifier is unknown");

        uint256 balance = daoToken.balanceOf(sender);
        uint256 weight = balance - votersWeightUsed[sender];

        require(
            weight > 0,
            "You've already voted or you have now new right to vote"
        );

        // mapping(int256 => mapping(uint256 => Proposal)) public pollHistory;
        Proposal memory candidate = pollHistory[pollId][proposaId];
        candidate.voteCount.add(weight);
        pollHistory[pollId][proposaId] = candidate;

        votersWeightUsed[sender] = balance;
        emit VoteSubmitted(sender, proposaId);
    }

    function closePoll() external {
        require(chairPerson == msg.sender, "Only the chair can close a poll");
        require(pollOpened == true, "No poll is currently open");
        pollOpened = false;

        pollId.add(1);
    }

    function getPollProposal(uint256 _pollId, uint256 _proposaId)
        external
        view
        returns (
            bytes32,
            bytes32,
            uint256,
            address,
            address
        )
    {
        Proposal memory proposal = pollHistory[_pollId][_proposaId];
        return (
            proposal.title,
            proposal.description,
            proposal.voteCount,
            proposal.account,
            proposal.owner
        );
    }

    function declarePollWinner(uint256 _pollId, uint256 _proposaId) external {
        require(
            chairPerson == msg.sender,
            "Only the chair can declare a poll winner"
        );
        pollWinner[_pollId] = _proposaId;
    }

    function getPollWinner(uint256 _pollId)
        external
        view
        returns (
            bytes32,
            bytes32,
            uint256,
            address,
            address
        )
    {
        uint256 winnerId = pollWinner[_pollId];
        Proposal memory proposal = pollHistory[_pollId][winnerId];
        return (
            proposal.title,
            proposal.description,
            proposal.voteCount,
            proposal.account,
            proposal.owner
        );
    }

    function proposalId() external view returns (uint256) {
        return _proposalId;
    }

    function voteWeight(address owner) external view returns (uint256) {
        uint256 balance = daoToken.balanceOf(owner);
        uint256 weight = balance - votersWeightUsed[owner];

        return weight;
    }
}