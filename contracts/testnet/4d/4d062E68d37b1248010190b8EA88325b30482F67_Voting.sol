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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

interface IVoting {
    function getWinningChoice(
        uint256 proposalId
    ) external view returns (uint8 choice);

    function createProposal(
        string memory title,
        string memory body,
        string[] memory choices,
        uint64 start,
        uint64 end
    ) external returns (uint256 id);

    function sendVote(uint256 proposalId, uint8 choice) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IVoting.sol";

contract Voting is IVoting, Ownable {
    IERC20 public weightToken;

    address public creator;
    uint256 public proposalsCount;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(uint256 => Vote)) public votes;
    mapping(uint256 => uint256) public votesCount;
    mapping(uint256 => mapping(address => uint256)) public voterId;
    mapping(uint256 => mapping(uint8 => uint256)) public choiceBalance;

    struct Proposal {
        uint256 id;
        string title;
        string body;
        string[] choices;
        address author;
        uint64 start;
        uint64 end;
    }

    struct Vote {
        uint256 balance;
        uint64 created;
        uint8 choice; //indexed from 1
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
        require(
            creator == address(0) || creator == msg.sender,
            "Access denied"
        );
        require(_start < _end, "Invalid end time");
        require(_choices.length > 1, "Invalid choices size");

        proposalsCount = proposalsCount + 1;
        id = proposalsCount;

        Proposal storage proposal = proposals[id];
        proposal.id = id;
        proposal.title = _title;
        proposal.body = _body;
        proposal.choices = _choices;
        proposal.start = _start;
        proposal.end = _end;
        proposal.author = msg.sender;

        emit ProposalCreated(id);
    }

    function sendVote(uint256 _id, uint8 _choice) external {
        Proposal memory proposal = proposals[_id];
        string[] memory choices = _getChoices(_id);

        require(choices.length > 1, "Proposal not exists");
        require(
            block.timestamp >= proposal.start &&
                block.timestamp <= proposal.end,
            "Voting is over"
        );
        require(_choice > 0 && _choice <= choices.length, "Incorrect choice");

        uint256 voteId = voterId[_id][msg.sender];
        uint256 balance = weightToken.balanceOf(msg.sender);

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

    function getWinningChoice(
        uint256 _id
    ) external view returns (uint8 choice) {
        Proposal memory proposal = proposals[_id];
        string[] memory choices = _getChoices(_id);

        require(choices.length > 1, "Proposal not exists");
        require(block.timestamp > proposal.end, "Voting is active");

        choice = 0;

        uint256 maxBalance = 0;

        for (uint8 i = 1; i <= choices.length; i++) {
            uint256 currentBalance = choiceBalance[_id][i];

            if (currentBalance == maxBalance) {
                choice = 0;
            }

            if (currentBalance > maxBalance) {
                maxBalance = currentBalance;
                choice = i;
            }
        }

        require(choice > 0, "No winner");
    }

    function getChoices(
        uint _id
    ) external view returns (string[] memory choices) {
        choices = _getChoices(_id);
    }

    function setCreator(address _creator) external onlyOwner {
        creator = _creator;
    }

    function _getChoices(
        uint _id
    ) internal view returns (string[] memory choices) {
        choices = proposals[_id].choices;
    }
}