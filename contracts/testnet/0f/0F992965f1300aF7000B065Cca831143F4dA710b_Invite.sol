/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.0;

contract Invite is Ownable {
    struct Miner {
        string name;
        bool exist;
        bool enable;
    }

    mapping(address => Miner) public miners;

    mapping(address => address) private inviter;
    mapping(address => address[]) private inviterSuns;

    address[] private allMiners;

    event AddMiner(address indexed miner);
    event MinerEnable(address indexed miner, bool enable);
    event Bind(address indexed user, address indexed inviter);

    function invite(address user, address parent) external returns (bool) {
        address miner_ = msg.sender;
        require(miners[miner_].enable, "Invite: miner permission denied");
        require(inviter[user] == address(0), "Invite: user has invited");
        require(parent != address(0), "Invite: parent is zero address");

        inviter[user] = parent;
        inviterSuns[parent].push(user);

        emit Bind(user, parent);

        return true;
    }

    function addMinter(address miner_, string memory name_) external onlyOwner {
        require(!miners[miner_].exist, "Invite: miner is exist");

        miners[miner_] = Miner({name: name_, exist: true, enable: true});

        allMiners.push(miner_);
        emit AddMiner(miner_);
    }

    function minerEnable(address miner_, bool enable) external onlyOwner {
        miners[miner_].enable = enable;
        emit MinerEnable(miner_, enable);
    }

    function getInviter(address user) external view returns (address) {
        return inviter[user];
    }

    function setInviter(address parent, address[] memory users) external onlyOwner returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            address user = users[i];
            require(inviter[user] == address(0), "Invite: user has invited");
            require(parent != address(0), "Invite: parent is zero address");

            inviter[user] = parent;
            inviterSuns[parent].push(user);

            emit Bind(user, parent);

        }
        
        return true;
    }

    function getInviterSuns(address user)
        external
        view
        returns (address[] memory)
    {
        return inviterSuns[user];
    }

    function getInviterSunSize(address user) external view returns (uint256) {
        return inviterSuns[user].length;
    }
}