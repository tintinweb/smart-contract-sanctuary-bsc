/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

pragma solidity ^0.8.17;

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Village {
    struct Player {
        uint256 timestamp;
        uint256 numberOfWithdrawals;
        uint256 pendingFunds;
        uint256 profitPerHour;
        uint256 referrals;
        uint256 referralEarnings;
        address partner;
        uint256 village;
    }

    mapping(address => Player) public players;

    uint256 public totalInvested;
    uint256 public totalPlayers;
    uint256 public totalBuildings;

    address public constant owner = 0x5dCeBE3873a8E3aaF0c7D7FD5535a93075A13D81;
    ERC20 public constant token = ERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);

    modifier needsRepair() {
        uint256 t = players[msg.sender].timestamp;
        require(t > 0 && (block.timestamp / 3600 - t / 3600) == 0, "needsRepair");
        _;
    }

    function build(address partner, uint8 index, bool reinvest) public needsRepair {
        require(index < 10, "indexError");

        uint256 price;
        uint256 profit;

        if (index == 0) {
            price = 1;
            profit = 1;
        } else if (index == 1) {
            price = 3;
            profit = 3;
        } else if (index == 2) {
            price = 10;
            profit = 11;
        } else if (index == 3) {
            price = 30;
            profit = 34;
        } else if (index == 4) {
            price = 50;
            profit = 59;
        } else if (index == 5) {
            price = 100;
            profit = 122;
        } else if (index == 6) {
            price = 250;
            profit = 320;
        } else if (index == 7) {
            price = 750;
            profit = 1000;
        } else if (index == 8) {
            price = 2000;
            profit = 2800;
        } else if (index == 9) {
            price = 5000;
            profit = 7500;
        }

        price *= 1e18;
        profit *= 1e15;

        if (players[msg.sender].partner == address(0)) {
            bool isPartner = msg.sender != partner && players[partner].profitPerHour > 0;
            players[msg.sender].partner = isPartner ? partner : owner;
            players[isPartner ? partner : owner].referrals += 1;
        }

        if (reinvest) {
            uint256 pendingFunds = players[msg.sender].pendingFunds;
            if (pendingFunds >= price) {
                players[msg.sender].pendingFunds -= price;
            } else {
                players[msg.sender].pendingFunds = 0;
                token.transferFrom(msg.sender, address(this), price - pendingFunds);
            }
        } else {
            token.transferFrom(msg.sender, address(this), price);
        }

        address p = players[msg.sender].partner;
        players[p].pendingFunds += (price * 6) / 100;
        players[p].referralEarnings += (price * 6) / 100;
        players[owner].pendingFunds += (price * 4) / 100;

        players[msg.sender].profitPerHour += profit;

        uint256 village = players[msg.sender].village;
        village = (village == 0 ? 10 : village * 10) + index;
        if (village < 2e20) {
            players[msg.sender].village = village;
        }

        totalInvested += price;
        totalBuildings += 1;
    }

    function multicall(bytes[] calldata data) public {
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success);
        }
    }

    function withdraw() public needsRepair {
        uint256 w = players[msg.sender].numberOfWithdrawals;
        require(w < 3, "limit");

        players[msg.sender].numberOfWithdrawals = w + 1;

        uint256 amount = players[msg.sender].pendingFunds;
        uint256 contractBalance = token.balanceOf(address(this));
        if (amount > contractBalance) amount = contractBalance;

        players[msg.sender].pendingFunds -= amount;
        token.transfer(msg.sender, amount);
    }

    function repair() public {
        uint256 t = players[msg.sender].timestamp;
        if (t == 0) {
            totalPlayers += 1;
            players[msg.sender].timestamp = block.timestamp;
            return;
        }

        uint256 h = block.timestamp / 3600 - t / 3600;
        if (h == 0) return;
        if (h > 24) h = 24;

        players[msg.sender].pendingFunds += players[msg.sender].profitPerHour * h;
        players[msg.sender].timestamp = block.timestamp;
    }
}