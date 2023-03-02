/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

pragma solidity ^0.8.0;

contract LockToken {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public constant LOCK_DURATION_IN_MINUTES = 60 * 24 * 365; // 1 year
    uint256 public constant LOCK_RELEASE_RATE = 10; // 0.001%
    uint256 public lockedBalance;
    uint256 public lockStartTime;

    constructor() {
        name = "99% Lock Token";
        symbol = "99LT";
        decimals = 18;
        totalSupply = 10000000 * (10 ** decimals); // 10 million tokens with 18 decimal places
        balanceOf[msg.sender] = totalSupply;
        lockedBalance = totalSupply - 9999999 * (10 ** decimals); // 9.9 million tokens locked with 18 decimal places
        lockStartTime = block.timestamp;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        if (msg.sender == address(this)) {
            // allow transfer from the locked balance after release
            require(block.timestamp >= lockStartTime + LOCK_DURATION_IN_MINUTES * 1 minutes, "Tokens still locked");
            require(_value <= lockedBalance, "Not enough locked balance");
            lockedBalance -= _value;
        }
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function releaseLockedTokens() public returns (bool success) {
        require(block.timestamp >= lockStartTime + LOCK_DURATION_IN_MINUTES * 1 minutes, "Tokens still locked");
        uint256 elapsedMinutes = (block.timestamp - lockStartTime) / 1 minutes;
        uint256 releasedTokens = lockedBalance * LOCK_RELEASE_RATE * elapsedMinutes / 10000;
        if (releasedTokens >= lockedBalance) {
            // release all remaining locked balance
            releasedTokens = lockedBalance;
            lockedBalance = 0;
        } else {
            lockedBalance -= releasedTokens;
        }
        balanceOf[address(this)] += releasedTokens;
        emit Transfer(address(this), msg.sender, releasedTokens);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}