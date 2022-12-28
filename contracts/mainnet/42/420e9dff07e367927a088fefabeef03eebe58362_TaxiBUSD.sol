/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

pragma solidity ^0.8.17;

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TaxiBUSD {
    struct Player {
        uint256 timestamp;
        uint256 numberOfWithdrawals;
        uint256 pendingFunds;
        uint256 profitPerHour;
        uint256[5] cars;
    }

    mapping(address => Player) public players;

    uint256 public numberOfPlayers;
    uint256 public totalPaid;
    uint256 public startTimestamp = block.timestamp;

    address public constant owner = 0x5dCeBE3873a8E3aaF0c7D7FD5535a93075A13D81;
    ERC20 public constant BUSDToken = ERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    modifier requiredGasoline() {
        uint256 t = players[msg.sender].timestamp;
        require(t > 0 && (block.timestamp / 3600 - t / 3600) == 0, "requiredGasoline");
        _;
    }

    function buyCar(uint256 index) public requiredGasoline {
        uint256 price = [5e18, 25e18, 120e18, 600e18, 3000e18][index];
        uint256 profit = [0.005e18, 0.026e18, 0.13e18, 0.7e18, 3.75e18][index];

        BUSDToken.transferFrom(msg.sender, address(this), price);
        BUSDToken.transfer(owner, (price * 8) / 100);

        players[msg.sender].cars[index] += 1;
        players[msg.sender].profitPerHour += profit;
    }

    function getCars(address player) public view returns (uint256[5] memory cars) {
        return players[player].cars;
    }

    function multicall(bytes[] calldata data) public {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success);
        }
    }

    function addGasoline() public {
        uint256 t = players[msg.sender].timestamp;
        if (t == 0) {
            players[msg.sender].timestamp = block.timestamp;
            numberOfPlayers += 1;
            return;
        }

        uint256 h = block.timestamp / 3600 - t / 3600;
        if (h == 0) return;
        if (h > 20) h = 20;

        players[msg.sender].pendingFunds += players[msg.sender].profitPerHour * h;
        players[msg.sender].timestamp = block.timestamp;
    }

    function withdraw() public requiredGasoline {
        uint256 w = players[msg.sender].numberOfWithdrawals;
        require(w < 3, "limit");

        players[msg.sender].numberOfWithdrawals = w + 1;

        uint256 amount = players[msg.sender].pendingFunds;
        uint256 contractBalance = BUSDToken.balanceOf(address(this));
        if (amount > contractBalance) amount = contractBalance;

        players[msg.sender].pendingFunds -= amount;
        BUSDToken.transfer(msg.sender, amount);
        totalPaid += amount;
    }
}