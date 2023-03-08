/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BEBIN.APP token contract
 * @dev ERC20 token contract with additional features
 * @custom:dev-run-script scripts/BEBINToken.js
 */
contract BEBINToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;
    mapping(address => bool) public isMinter;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool frozen);
    event Mint(address indexed to, uint256 amount);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event Voted(address indexed voter, uint256 proposalId, bool inSupport, uint256 voteWeight);
    event Staked(address indexed staker, uint256 amount);

    uint256 private constant MAX_SUPPLY = 96000000 * 10 ** 18;
    uint256 private constant INITIAL_SUPPLY = 24000000 * 10 ** 18;
    uint256 private constant VOTING_DURATION = 7 days;
    uint256 private constant UNFREEZE_DURATION = 1 days;
    uint256 private constant STAKING_DURATION = 30 days;

    uint256 private _nextProposalId;
    uint256 private _votingStartTimestamp;
    uint256 private _unfreezeStartTimestamp;
    uint256 private _stakingStartTimestamp;

    struct Proposal {
        uint256 id;
        string title;
        string description;
        uint256 votingDeadline;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) voted;
        mapping(address => uint256) voteWeight;
    }

    mapping(uint256 => Proposal) private _proposals;

    constructor() {
        name = "BEBIN.APP";
        symbol = "BBT";
        decimals = 18;
        totalSupply = INITIAL_SUPPLY;
        balanceOf[msg.sender] = totalSupply;

        _votingStartTimestamp = block.timestamp;
        _unfreezeStartTimestamp = block.timestamp;
    }
}