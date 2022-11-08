// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./interfaces/IERC20Permit.sol";

contract Ballot {
    IERC20Permit public immutable daoToken;
    address public immutable chairPerson;

    bool private _acceptingProjects = false;
    bool private _pollOpened = false;

    uint256 private _pollId = 1;
    uint256 private _projectId = 1;

    mapping(uint256 => mapping(uint256 => Project)) private _pollHistory;
    mapping(uint256 => uint256[]) private _tracker;
    mapping(uint256 => uint256) _pollWinner;

    modifier onlyOwner() {
        require(msg.sender == chairPerson, "Not owner");
        _;
    }

    event NewProjectSubmitted(uint256 projectId, bytes32 title, address owner);
    event VoteSubmitted(address voter, uint256 projectId);

    struct Project {
        uint256 id;
        bytes32 title;
        uint256 voteCount;
    }

    constructor(address erc20Token) {
        daoToken = IERC20Permit(erc20Token);
        chairPerson = msg.sender;
    }

    // change the status of the _acceptingProjects
    function setProjectStatus() external onlyOwner() {
        if (_acceptingProjects == false) {
            _acceptingProjects = true;
        } else {
            _acceptingProjects = false;
        }
    }

    // change the status of the acceptingroposal
    function setPollStatus() external onlyOwner {
        if (_pollOpened == false) {
            _pollOpened = true;
        } else {
            _pollOpened = false;
            _pollId = _pollId + 1;
        }
    }

    function isAcceptingProjects() external view returns (bool) {
        return _acceptingProjects;
    }

    function isPollOpened() external view returns (bool) {
        return _pollOpened;
    }

    function currentPollId() external view returns (uint256) {
        return _pollId;
    }

    function currentProjectId() external view returns (uint256) {
        return _projectId;
    }

    // Append new project to the to history
    function submitProject(bytes32 title) external returns (uint256) {
        require(_acceptingProjects == true, "No new project allowed now");
        Project memory submission = Project({id: _projectId, title: title, voteCount: 0});

        _pollHistory[_pollId][_projectId] = submission;

        _tracker[_pollId].push(_projectId);
        emit NewProjectSubmitted(_projectId, title, msg.sender);
        _projectId = _projectId + 1;

        return _projectId - 1;
    }

    function getProjects(uint256 pollId)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory ids = _tracker[pollId];

        return (ids);
    }

    function voteWeight(address sender) external view returns (uint256 balance, uint256 allowance) {
        balance = daoToken.balanceOf(sender);
        allowance = daoToken.allowance(sender, address(this));
    }

    // vote a Projectn with all KOL tokens
    function vote(address sender, uint256 projectId, uint256 amountOfVotes) external {
        require(_pollOpened == true, "Poll not open");
        require(projectId <= _projectId, "Invalid project id");

        // check if the user has any token
        require(daoToken.balanceOf(sender) >= amountOfVotes, "Insufficient KOL");
        require(daoToken.allowance(sender, address(this)) >= amountOfVotes, "Insufficient allowance");

        // daoToken.permit(sender, address(this), amountOfVotes, deadline, v, r, s);
        daoToken.transferFrom(sender, address(this), amountOfVotes);

        Project memory candidate = _pollHistory[_pollId][_projectId];
        candidate.voteCount = candidate.voteCount + amountOfVotes;
        _pollHistory[_pollId][projectId] = candidate;

        emit VoteSubmitted(msg.sender, projectId);
    }

    function declarePollWinner(uint256 pollId, uint256 projectId)
        external
        onlyOwner
    {
        _pollWinner[pollId] = projectId;
    }

    function getPollWinner(uint256 pollId)
        external
        view
        returns (uint256, bytes32)
    {
        uint256 winnerId = _pollWinner[pollId];
        Project memory project = _pollHistory[pollId][winnerId];
        return (project.id, project.title);
    }

    function retrieveVotedTokens() external onlyOwner() {
        daoToken.transfer(chairPerson, daoToken.balanceOf(address(this)));
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit is IERC20 {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}