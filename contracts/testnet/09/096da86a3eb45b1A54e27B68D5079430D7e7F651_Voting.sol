// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Voting {
    IERC20 public weightToken;

    uint256 public proposalsCount;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(uint256 => Vote)) public votes;
    mapping(uint256 => uint256) public votesCount;
    mapping(uint256 => mapping(address => uint256)) public voterId;
    mapping(uint256 => mapping(uint64 => uint256)) public choiceBalance;

    struct Proposal {
        string title;
        string body;
        string[] choices;
        address author;
        uint64 start;
        uint64 end;
    }

    struct Vote {
        uint128 balance;
        uint64 created;
        uint64 choice; //indexed from 1
        address voter;
    }

    event ProposalCreated(uint256 indexed id);
    event VoteSent(address indexed voter);

    constructor(IERC20 _weightToken) {
        weightToken = _weightToken;
    }

    function createProposal(
        string memory _title,
        string memory _body,
        string[] memory _choices,
        uint64 _start,
        uint64 _end
    ) external returns (uint256 id) {
        require(_start < _end, "Invalid end time");
        require(_choices.length > 1, "Invalid choices size");

        proposalsCount = proposalsCount + 1;
        id = proposalsCount;

        Proposal storage proposal = proposals[id];
        proposal.title = _title;
        proposal.body = _body;
        proposal.choices = _choices;
        proposal.start = _start;
        proposal.end = _end;
        proposal.author = msg.sender;

        emit ProposalCreated(id);
    }

    function sendVote(uint256 _id, uint64 _choice) external {
        string[] memory choices = _getChoices(_id);

        require(choices.length > 1, "Proposal not exists");
        require(_choice > 0 && _choice <= choices.length, "Incorrect choice");

        uint256 voteId = voterId[_id][msg.sender];
        uint128 balance = uint128(weightToken.balanceOf(msg.sender));

        Vote storage vote = votes[_id][voteId];

        if (voteId == 0) {
            voteId = votesCount[_id] + 1;
            votesCount[_id] = voteId;
            voterId[_id][msg.sender] = voteId;
        } else {
            choiceBalance[_id][vote.choice] -= vote.balance;
        }

        vote = votes[_id][voteId];
        vote.balance = balance;
        vote.choice = _choice;
        vote.voter = msg.sender;
        vote.created = uint64(block.timestamp);

        choiceBalance[_id][_choice] += balance;

        emit VoteSent(msg.sender);
    }

    function getChoices(
        uint _id
    ) external view returns (string[] memory choices) {
        choices = _getChoices(_id);
    }

    function _getChoices(
        uint _id
    ) internal view returns (string[] memory choices) {
        choices = proposals[_id].choices;
    }
}