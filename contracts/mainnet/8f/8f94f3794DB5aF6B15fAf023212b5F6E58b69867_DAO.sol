/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

// SPDX-License-Identifier: MIT


// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: dao.sol






pragma solidity 0.8.11;


interface IPool {
    // Functions
    function lpSupply() external view returns (uint256);
    function pendingReward(address _user) external view returns (uint256);
    function userInfo(address) external pure returns (uint256, uint256, uint256);
}

contract DAOInterface {
    // The minimum debate period that a generic proposal can have
    uint constant minProposalDebatePeriod = 2 days;
    // The minimum debate period that a generic proposal can have
    uint constant maxProposalDebatePeriod = 7 days;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it throws)
    uint constant executeProposalPeriod = 15 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant maxDepositDivisor = 100;
    // The period to execute the proposal after the voting ends
    uint constant executeTimelockPeriod = 2 days;

    // Governance pool
    IPool public governancePool;

    // Proposal ID last
    uint public proposalID;

    // Proposals to spend the DAO's ether
    // Proposal[] public proposals;
    mapping (uint => Proposal) public proposals;
    // The quorum needed for each proposal is partially calculated by
    // totalSupply / minQuorumDivisor
    uint public minQuorumDivisor;
    // The unix time of the last time quorum was reached on a proposal
    uint public lastTimeMinQuorumMet;

    // Address of the proposer
    address public proposer;

    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public allowedRecipients;

    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public blocked;

    // Proposal struct
    struct Proposal {
        // Title
        string title;
        // A plain text description of the proposal
        string description;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // A unix timestamp, denoting when the owner can execute the proposal
        uint executionDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool proposalPassed;
        // A hash to check validity of a proposal
        bytes32 proposalHash;
        // Number of Tokens in favor of the proposal
        uint yea;
        // Number of Tokens opposed to the proposal
        uint nay;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) votedYes;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) votedNo;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => uint256) voted;
        // Address of the shareholder who created the proposal
        address creator;
        // Address of the shareholder who created the proposal
        address recipient;
    }

    event ProposalAdded(uint indexed proposalID, string title, string description);
    event Voted(uint indexed proposalID, bool position, address indexed voter);
    event ProposalTallied(uint indexed proposalID, bool result, uint quorum);
    event AllowedRecipientChanged(address indexed _recipient, bool _allowed);
}

// The DAO contract itself
contract DAO is DAOInterface, Ownable, ReentrancyGuard {

    // Modifier that allows only shareholders to vote and create new proposals
    modifier onlyTokenHolders {
        (uint256 amount, , ) = governancePool.userInfo(msg.sender);
        require(amount > 0, "no voting power");
        _;
    }

    // Modifier that allows only proposer to vote
    modifier onlyProposer {
        require(address(msg.sender) == address(proposer), "not the proposer");
        _;
    }

    constructor(
        address _owner,
        address _proposer,
        IPool _governancePool
    ) {
        // transfer ownership
        transferOwnership(_owner);

        // init variables
        lastTimeMinQuorumMet = block.timestamp;
        minQuorumDivisor = 7; // sets the minimal quorum to 14.3%
        proposer = _proposer;
        governancePool = _governancePool;

        // init recipients
        allowedRecipients[address(_governancePool)] = true;
    }

    function newProposal(
        address _recipient,
        string memory _title,
        string memory _description,
        bytes calldata _transactionData,
        uint64 _debatingPeriod
    ) onlyProposer nonReentrant public returns (uint _proposalID) {

        // requires
        require(allowedRecipients[_recipient] == true, "recipient not allowed");
        require(_debatingPeriod >= minProposalDebatePeriod, "debating period to short");
        require(_debatingPeriod <= maxProposalDebatePeriod, "debating period to long");
        require(address(msg.sender) != address(this), "err");

        // to prevent owner from halving quorum before first proposal
        if (proposalID == 0) { 
            lastTimeMinQuorumMet = block.timestamp;
        }

        // get proposal ID
        _proposalID = proposalID;

        // add proposal
        Proposal storage p = proposals[_proposalID];
        p.title = _title;
        p.description = _description;
        p.proposalHash = keccak256(_transactionData);
        p.votingDeadline = block.timestamp + _debatingPeriod;
        p.executionDeadline = block.timestamp + _debatingPeriod + executeTimelockPeriod;
        p.open = true;
        p.creator = msg.sender;
        p.recipient = _recipient;

        // increment
        proposalID++;

        // event
        emit ProposalAdded(_proposalID, _title, _description);
    }

    function checkProposalCode(uint _proposalID, bytes calldata _transactionData) public view returns (bool _codeChecksOut) {
        Proposal storage p = proposals[_proposalID];
        return p.proposalHash == keccak256(_transactionData);
    }

    function vote(uint _proposalID, bool _supportsProposal) nonReentrant onlyTokenHolders public {

        // get proposal
        Proposal storage p = proposals[_proposalID];

        // unvote user
        unVote(_proposalID);

        // user amount
        (uint256 amount, , ) = governancePool.userInfo(msg.sender);

        // vote
        if (_supportsProposal) {
            p.yea += amount;
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += amount;
            p.votedNo[msg.sender] = true;
        }

        // Set vote
        p.voted[msg.sender] = amount;

        // block user for
        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalID;
        } else if (p.votingDeadline > proposals[blocked[msg.sender]].votingDeadline) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            blocked[msg.sender] = _proposalID;
        }

        // register user vote
        emit Voted(_proposalID, _supportsProposal, msg.sender);
    }

    function unVote(uint _proposalID) onlyTokenHolders public {

        // get proposal
        Proposal storage p = proposals[_proposalID];

        // require
        require(block.timestamp < p.votingDeadline, "voting deadline reached");

        // unvote from yes
        if (p.voted[msg.sender] > 0) {
            if (p.votedYes[msg.sender]) {
                p.yea -= p.voted[msg.sender];
                p.votedYes[msg.sender] = false;
            }
            // unvote from no
            if (p.votedNo[msg.sender]) {
                p.nay -= p.voted[msg.sender];
                p.votedNo[msg.sender] = false;
            }
        }

        // Set un vote
        p.voted[msg.sender] = 0;
    }

    function executeProposal(uint _proposalID, bytes calldata _transactionData) nonReentrant onlyOwner payable public returns (bool _success) {
        
        // get proposal
        Proposal storage p = proposals[_proposalID];
        // get quorum
        uint quorum = p.yea + p.nay;

        // require
        require(block.timestamp >= p.votingDeadline, "voting still on");
        require(block.timestamp >= p.executionDeadline, "not execution time");
        require(p.open == true, "proposal is closed");
        require(p.proposalPassed == false, "not recursively");
        require(checkProposalCode(_proposalID, _transactionData) == true, "proposal doesn't match transaction data");

        // if we are over deadline and waiting period, assert proposal is closed
        if (p.open && block.timestamp > p.votingDeadline + executeProposalPeriod) {
            closeProposal(_proposalID);
            return false;
        }

        // if quorum not reached
        if (quorum < minQuorum()) {
            closeProposal(_proposalID);
            return false;
        }

        // quorum reached
        lastTimeMinQuorumMet = block.timestamp;

        // Execute result
        if (p.yea > p.nay) {
            // we are setting this here before the CALL() value transfer to
            // assure that in the case of a malicious recipient contract trying
            // to call executeProposal() recursively money can't be transferred
            // multiple times out of the DAO
            p.proposalPassed = true;

            // this call is as generic as any transaction. It sends all gas and
            // can do everything a transaction can do. It can be used to reenter
            // the DAO. The `p.proposalPassed` variable prevents the call from 
            // reaching this line again
            (_success, ) = p.recipient.call{value: msg.value}(_transactionData);
            require(_success == true, "transaction failed");
        }

        // close the proposual
        closeProposal(_proposalID);

        // emit event
        emit ProposalTallied(_proposalID, _success, quorum);
    }

    function closeProposal(uint _proposalID) internal {
        Proposal storage p = proposals[_proposalID];
        p.open = false;
    }

    function changeAllowedRecipients(address _recipient, bool _allowed) onlyOwner external returns (bool _success) {
        allowedRecipients[_recipient] = _allowed;
        emit AllowedRecipientChanged(_recipient, _allowed);
        return true;
    }

    function minQuorum() internal view returns (uint _minQuorum) {
        return IPool(governancePool).lpSupply() / minQuorumDivisor;
    }

    function numberOfProposals() public view returns (uint _numberOfProposals) {
        return proposalID;
    }

    function getOrModifyBlocked(address _account) internal returns (bool) {
        if (blocked[_account] == 0) {
            return false;
        }
        Proposal storage p = proposals[blocked[_account]];
        if (!p.open) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() nonReentrant public returns (bool) {
        return getOrModifyBlocked(msg.sender);
    }

    function getUserBlocked(address _account) external view returns (bool) {
        if (numberOfProposals() == 0) {
            return false;
        }
        Proposal storage p = proposals[blocked[_account]];
        if (block.timestamp > p.votingDeadline) {
            return false;
        }
        if (p.votedYes[_account] == true || p.votedNo[_account] == true) {
            return true;
        }
        return false;
    }

    function getUserVote(uint _proposalID, address _account) external view returns (bool) {
        Proposal storage p = proposals[_proposalID];
        require(p.voted[_account] > 0, "no vote");
        if (p.votedYes[_account] == true) {
            return true;
        } 
        return false;
    }
}