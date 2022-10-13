/************************************************************
 *
 * Autor: BotPlanet
 *
 * 446576656c6f7065723a20416e746f6e20506f6c656e79616b61 ****/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO is Ownable, ReentrancyGuard {
    // Structs

    struct User {
        uint256 balance;
        uint256 lastVoteEndTime;
        mapping(uint256 => bool) isVoted;
    }

    struct Proposal {
        address targetContract; // Target contract who receive quorum decision and call function with arguments
        bytes encodedMessage; // Message to send if quorum vote "true" to target contract (function + arguments)
        string description; // Description of proposal
        bool isFinished; // Indicate if this proposal is finished
        uint256 endTime; // When proposal is end and is not possible vote more
        uint256 consenting; // Sum of balances of users who voted "true". Is not number of users
        uint256 dissenters; // Sum of balances of users who voted "false". Is not number of users
        uint256 usersVotedTotal; // Count of user who voted true and false
        uint256 minumumUserTokens; // How many tokens is needed to vote. Zero is not allowed
        uint256 usersVotedTrue; // Count of user who voted true
    }

    // Events

    event Received(address indexed sender, uint256 amount);
    event ETHWithdrawn(address indexed receiver, uint256 indexed amount);

    event Credited(address indexed user, uint256 amount);
    event TokensWithdrawn(address indexed user, uint256 amount);

    event ProposalAdded(uint256 indexed id, uint256 time);
    event Voted(address indexed user, uint256 indexed proposal, bool answer);
    event FinishedEmergency(uint indexed proposalId);
    event Finished(
        uint256 indexed ProposalId,
        bool status,
        address indexed targetContract,
        uint256 votesAmount,
        uint256 usersVotedTotal,
        uint256 usersVotedTrue
    );

    // Usings

    using Counters for Counters.Counter;

    // Attributies

    Counters.Counter private _proposalsCounter;
    Counters.Counter private _activeUsers;
    // Token used for vote
    IERC20 private _voteToken;
    // Miminum quorum % accepted in proposal
    uint256 private _minimumQuorum;
    // Time to vote in seconds
    uint256 private _debatingPeriodDuration;
    // Minimum sum of votes balances to accept proposal
    uint256 private _minimumVotes;
    mapping(address => User) private _users;
    mapping(uint256 => Proposal) private _proposals;

    // Modifiers

    modifier endProposalCondition(uint256 proposalId) {
        require(
            _proposals[proposalId].endTime <= block.timestamp,
            "DAO: Voting time is not over yet"
        );
        require(
            _proposals[proposalId].isFinished == false,
            "DAO: Voting has already ended"
        );
        _;
    }

    // Constructos

    constructor(
        address voteToken_,
        uint256 minimumQuorum_,
        uint256 debatingPeriodDuration_,
        uint256 minimumVotes_
    ) {
        _voteToken = IERC20(voteToken_);
        _minimumQuorum = minimumQuorum_;
        _debatingPeriodDuration = debatingPeriodDuration_;
        _minimumVotes = minimumVotes_;
    }

    // Public methods

    // Add proposal for vote by active users.
    // Signature param - encoded function with args.
    function addProposal(
        address targetContract_,
        bytes calldata signature_,
        string calldata description_,
        uint256 minumumUserTokens_
    ) external onlyOwner nonReentrant {
        uint256 current = _proposalsCounter.current();

        _proposals[current] = Proposal(
            targetContract_,
            signature_,
            description_,
            false,
            block.timestamp + _debatingPeriodDuration,
            0,
            0,
            0,
            minumumUserTokens_,
            0
        );

        _proposalsCounter.increment();
        emit ProposalAdded(current, block.timestamp);
    }

    // User deposit some tokens. Is necesary to allow vote in proposal
    function deposit(uint256 amount_) external {
        require(amount_ > 0, "DAO: Amount is 0");
        _voteToken.transferFrom(msg.sender, address(this), amount_);
        if (_users[msg.sender].balance == 0) {
            _activeUsers.increment();
        }
        _users[msg.sender].balance += amount_;
        emit Credited(msg.sender, amount_);
    }

    // User vote for proposal true or false
    function vote(uint256 proposalId_, bool answer_) external nonReentrant {
        require(_users[msg.sender].balance > 0, "DAO: No tokens on balance");
        require(
            _users[msg.sender].balance >=
                _proposals[proposalId_].minumumUserTokens,
            "DAO: Need more tokens to vote"
        );
        require(
            _proposals[proposalId_].endTime > block.timestamp,
            "DAO: The voting is already over or does not exist"
        );
        require(
            _users[msg.sender].isVoted[proposalId_] == false,
            "DAO: You have already voted in this proposal"
        );

        if (answer_) {
            _proposals[proposalId_].consenting += _users[msg.sender].balance;
            _proposals[proposalId_].usersVotedTrue++;
        } else {
            _proposals[proposalId_].dissenters += _users[msg.sender].balance;
        }

        _users[msg.sender].isVoted[proposalId_] = true;
        _users[msg.sender].lastVoteEndTime = _proposals[proposalId_].endTime;
        _proposals[proposalId_].usersVotedTotal++;

        emit Voted(msg.sender, proposalId_, answer_);
    }

    // Finish proposal when is ended period of vote.
    // If Quorum vote "true" - execute encoded message to target contract.
    // If Quorum vote "false" - don't do nothing
    function finishProposal(uint256 proposalId_)
        external
        endProposalCondition(proposalId_)
        nonReentrant
    {
        Proposal storage proposal = _proposals[proposalId_];

        uint256 votesAmount = proposal.consenting + proposal.dissenters;
        // The number of users is multiplied by 10 to the 3rd power
        // to eliminate errors, provided that users are less than 10 / 100
        uint256 votersPercentage = _calculateVotersPercentage();
        uint256 usersTrue = proposal.usersVotedTrue * 10**3;

        if (votesAmount >= _minimumVotes && usersTrue >= votersPercentage) {
            (bool success, bytes memory returnedData) = proposal
                .targetContract
                .call{value: 0}(proposal.encodedMessage);
            require(success, string(returnedData));

            emit Finished(
                proposalId_,
                true,
                proposal.targetContract,
                votesAmount,
                proposal.usersVotedTotal,
                proposal.usersVotedTrue
            );
        } else {
            emit Finished(
                proposalId_,
                false,
                proposal.targetContract,
                votesAmount,
                proposal.usersVotedTotal,
                proposal.usersVotedTrue
            );
        }
        proposal.isFinished = true;
    }

    // A function that can be called by proposal voting to end the voting urgently.
    function endProposal(uint256 proposalId_)
        external
        onlyOwner
        endProposalCondition(proposalId_)
    {
        _proposals[proposalId_].isFinished = true;
        emit FinishedEmergency(proposalId_);
    }

    // User is allowed to withdraw his tokens when is ended proposal time to vote
    function withdrawTokens(uint256 amount_) external {
        require(
            _users[msg.sender].balance >= amount_,
            "DAO: Insufficient funds on the balance"
        );
        require(
            _users[msg.sender].lastVoteEndTime < block.timestamp,
            "DAO: The last vote you participated in hasn't ended yet"
        );

        _users[msg.sender].balance -= amount_;

        if (_users[msg.sender].balance == 0) {
            _activeUsers.decrement();
        }

        emit TokensWithdrawn(msg.sender, amount_);
    }

    // Withdraw ETH/BNB/etc, contract need it in case of quorum vote "true" and is needed to execute function to target contract
    function withdrawETH(address payable to_, uint256 amount_)
        external
        onlyOwner
    {
        Address.sendValue(to_, amount_);
        emit ETHWithdrawn(to_, amount_);
    }

    // Receive ETH/BNB/etc needed to execute encoded message to target contract
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Get proposal information by id
    function getProposalById(uint256 id_)
        external
        view
        returns (Proposal memory)
    {
        return _proposals[id_];
    }

    // Getters associated with counters

    // Get last proposal id
    function getLastProposalId() external view returns (uint256) {
        return _proposalsCounter.current();
    }

    // Get number of active users with balance in DAO is greater zero
    function getActiveUsers() external view returns (uint256) {
        return _activeUsers.current();
    }

    // Getters associated with user

    // Check if user is voted for proposal by wallet address of user and proposal id
    function isUserVoted(address voter_, uint256 proposalId_)
        external
        view
        returns (bool)
    {
        return _users[voter_].isVoted[proposalId_];
    }

    // Get end time of voted last proposal by user
    function userLastVoteEndTime(address voter_)
        external
        view
        returns (uint256)
    {
        return _users[voter_].lastVoteEndTime;
    }

    // Get balance of user in DAO
    function getUserBalance(address voter_) external view returns (uint256) {
        return _users[voter_].balance;
    }

    // Getters associated with condition constants

    // Get token address contract used by balance of users
    function getToken() external view returns (address) {
        return address(_voteToken);
    }

    // Get minimum quorum to decision. Normaly is 51% of total active users
    function getMinQuorum() external view returns (uint256) {
        return _minimumQuorum;
    }

    // Get debate period in seconds
    function getDebatePeriod() external view returns (uint256) {
        return _debatingPeriodDuration;
    }

    // Get minum numbers of votes to accept proposal
    function getMinVotes() external view returns (uint256) {
        return _minimumVotes;
    }

    // Private methods

    // Calculate voters percentage by minumum quorum
    function _calculateVotersPercentage() private view returns (uint256) {
        return ((_activeUsers.current() * 10**3) / 100) * _minimumQuorum;
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