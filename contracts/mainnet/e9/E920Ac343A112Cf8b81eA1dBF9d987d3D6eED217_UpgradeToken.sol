/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address owner, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

// File: UpgradeToken.sol

contract UpgradeToken {
    struct User {
        uint256 received;
        uint256 claimed;
        bool hasClaimed;
    }
    address public owner;
    uint256 public timeLimit;

    IToken public v1;
    IToken public v2;
    address public vault;
    mapping(address => User) public user;
    uint256 public totalReceived;
    uint256 public totalClaimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _v1, address _vault) {
        owner = msg.sender;
        v1 = IToken(_v1);
        vault = _vault;
        timeLimit = 1669399200;
    }

    function sendToVault() public {
        require(block.timestamp < timeLimit, "Blocked");
        User storage _user = user[msg.sender];
        uint256 _balance = v1.balanceOf(msg.sender);
        v1.transferFrom(msg.sender, vault, _balance);
        _user.received += _balance;
        totalReceived += _balance;
        if (_user.hasClaimed) _user.hasClaimed = false;
    }

    function claim() external {
        require(address(v2) != address(0), "Not set");
        User storage _user = user[msg.sender];
        uint256 claimAmount = _user.received - _user.claimed;
        require(!_user.hasClaimed, "Already claimed");
        require(
            v2.balanceOf(address(this)) + 1 > claimAmount,
            "Insufficient V2"
        );
        _user.hasClaimed = true;
        v2.transfer(msg.sender, claimAmount);
        totalClaimed += claimAmount;
        _user.claimed += claimAmount;
    }

    function setV2(address _v2) external onlyOwner {
        v2 = IToken(_v2);
    }

    function setTimeLimit(uint256 _newLimit) external onlyOwner {
        require(block.timestamp <= _newLimit, "Limit wrong");
        timeLimit = _newLimit;
    }
}