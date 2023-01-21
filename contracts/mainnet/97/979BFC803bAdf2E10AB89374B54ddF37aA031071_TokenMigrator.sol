// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import './Address.sol';
import "./SafeMath.sol";
import "./SafeERC20.sol";

import './IERC20.sol';

import './Owned.sol';
import './TokensRecoverable.sol';

contract TokenMigrator is Owned, TokensRecoverable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;

    struct UserData {
        uint256 amount;
        uint256 claimed;
        uint256 lastClaimTimestamp;
    }

    uint256 public totalClaimed;
    uint256 public totalClaimers;

    mapping(address => UserData) public users;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event ClaimTokens(address indexed user, uint256 amount, uint256 timestamp);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor() {

    }

    receive() payable external {

    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Get balance of the distributed token in this contract
    function tokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // Get the amount of tokens available for a user to claim
    function availableOf(address _user) public view returns (uint256) {
        return (users[_user].amount.sub(users[_user].claimed));
    }

    // Get the total claimable amount of tokens for a user
    function claimableOf(address _user) public view returns (uint256) {
        return (users[_user].amount);
    }

    // Get the amount of tokens already claimed by a user
    function claimedOf(address _user) public view returns (uint256) {
        return (users[_user].claimed);
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Claim tokens
    function claim() public returns (bool _success) {
        uint256 amount = availableOf(msg.sender);
        require(amount > 0, "Nothing to claim");
        
        users[msg.sender].claimed = users[msg.sender].claimed.add(amount);

        token.transfer(msg.sender, amount);

        totalClaimed = totalClaimed.add(amount);
        totalClaimers = totalClaimers.add(1);

        users[msg.sender].lastClaimTimestamp = block.timestamp;

        emit ClaimTokens(msg.sender, amount, block.timestamp);
        return true;
    }

    //////////////////////////
    // RESTRICTED FUNCTIONS //
    //////////////////////////

    // Set token to be claimed
    function setToken(address _token) public ownerOnly() {
        token = IERC20(_token);
    }

    // Add users to the distribution
    function batchAddUsers(address[] memory _users, uint256[] memory _amounts) public ownerOnly() {
        require(_users.length == _amounts.length, "Invalid input");
        for (uint256 i = 0; i < _users.length; i++) {
            _addUser(_users[i], _amounts[i]);
        }
    }

    ////////////////////////
    // INTERNAL FUNCTIONS //
    ////////////////////////

    function _addUser(address _user, uint256 _amount) internal {
        users[_user].amount = users[_user].amount.add(_amount);
    }
}