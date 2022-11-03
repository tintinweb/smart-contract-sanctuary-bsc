/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract GoldenCoinFootball is Ownable {
    struct Player {
        uint256 playerLevel;
        uint256 goldenCoin;
        uint256 goldenDollar;
        uint256 goldenDollarFarm;
        uint256 performance;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeposits;
    }
    mapping(address => Player) public players;
    uint256 public totalPlayers;
    uint256 public totalInvested;
    address public manager;
    address payable public team;

    constructor() {
        team = payable(0x55cE9504a7e239273ad51618496a63A1c53733B7);
        manager = _msgSender();
        renounceOwnership();
    }

    function addGoldenCoins(address ref) public payable {
        uint256 goldenCoin = msg.value / 8e13;
        require(goldenCoin > 0, "Add Golden Coins: Zero GoldenCoin");
        address user = _msgSender();
        totalInvested += msg.value;
        if (players[user].timestamp == 0) {
            totalPlayers++;
            ref = players[ref].timestamp == 0 ? manager : ref;
            players[ref].refs++;
            players[user].playerLevel = 0;
            players[user].ref = ref;
            players[user].timestamp = block.timestamp;
        }
        ref = players[user].ref;
        players[ref].goldenCoin += (goldenCoin * 3) / 100;
        players[ref].refDeposits += goldenCoin;
        players[user].goldenCoin += goldenCoin;
        bool sent;
        (sent,) = payable(team).call{value : (msg.value * 6) / 100}("");
        require(sent, "Add Golden Coins: failed to send ETH");
    }

    function withdrawMoney() public {
        address user = _msgSender();
        uint256 goldenDollar = players[user].goldenDollar;
        players[user].goldenDollar = 0;
        uint256 amount = goldenDollar * 2e14;
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
    }

    function collectMoney() public {
        address user = _msgSender();
        syncPlayers(user);
        players[user].hrs = 0;
        players[user].goldenDollar += players[user].goldenDollarFarm;
        players[user].goldenDollarFarm = 0;
    }

    function upgradePlayer() public {
        address user = _msgSender();
        syncPlayers(user);
        require(players[user].playerLevel < 12, "User is not registered");
        players[user].goldenCoin -= getLevelPrice(players[user].playerLevel);
        players[user].performance += getPerformance(players[user].playerLevel);
        players[user].playerLevel += 1;
    }

    function sellPlayer() public {
        collectMoney();
        address user = _msgSender();
        players[user].playerLevel = 0;
        players[user].goldenDollar += players[user].performance * 10;
        players[user].performance = 0;
    }

    function syncPlayers(address user) internal {
        require(players[user].timestamp > 0, "User is not registered");
        if (players[user].performance > 0) {
            uint256 hrs = block.timestamp / 3600 - players[user].timestamp / 3600;
            if (hrs + players[user].hrs > 24) {
                hrs = 24 - players[user].hrs;
            }
            players[user].goldenDollarFarm += hrs * players[user].performance / 24;
            players[user].hrs += hrs;
        }
        players[user].timestamp = block.timestamp;
    }

    function getLevelPrice(uint256 playerLevel) internal pure returns (uint256) {
        return [125, 1250, 3250, 6250, 9500, 12500, 25000, 50000,100000,250000,500000,750000,1000000][playerLevel];
    }

    function getPerformance(uint256 playerLevel) internal pure returns (uint256) {
        return [1, 10, 37, 98, 203, 359, 642, 1213, 2360,5233,10982,19644,31245][playerLevel];
    }

    function updateTeam(address team_) external {
        require(manager == _msgSender(), "caller is not the manager");
        team = payable(team_);

    }
}