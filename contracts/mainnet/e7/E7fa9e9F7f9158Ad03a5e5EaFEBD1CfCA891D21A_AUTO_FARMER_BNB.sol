/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract AUTO_FARMER_BNB {
    bool start = false;

    uint256 private immutable checkPoint = 604800;
    address private owner;
    uint256 private fee = 5;
    uint256 private maxInvest = 10e18;
    uint256 private tDeposit;
    uint256 private tDepositCount;
    uint256 private tPayout;
    uint256 private tPayoutCount;

    struct User {
		uint256 deposit;
        uint256 payout;
		uint256 lastTime;
		uint256 rPayout;
        uint256 rCount;
	}

    mapping (address => User) private users;

    event DepositSingle(address Player, uint256 Amount);
    event CompoundSingle(address Player, uint256 Amount);
    event WithdrawSingle(address Player, uint256 Amount);
    event FeeOwnerSingle(uint256 Fee);
    event FeeReferralSingle(uint256 Fee);

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {}

    function deposit(address addr) public payable {
        if (start == false) revert("no started");
        if (msg.value > maxInvest) revert("amount refused");
        if (users[msg.sender].deposit >= maxInvest) revert("max amount reached");

        uint256 oFee = calculateFee(msg.value);
        payable (owner).transfer(oFee);

        uint256 rFee = 0;
        if (addr != address(0) && addr != msg.sender) {
            rFee = calculateFee(msg.value);
            payable (addr).transfer(rFee);
            users[addr].rPayout += rFee;
            users[addr].rCount++;
        }

        users[msg.sender].deposit += msg.value;
        users[msg.sender].lastTime = block.timestamp;
        tDeposit += msg.value - oFee - rFee;
        tDepositCount++;

        emit DepositSingle(msg.sender, msg.value);
        emit FeeOwnerSingle(oFee);
        emit FeeReferralSingle(rFee);
    }

    function compound() public {
        if (users[msg.sender].deposit == 0) revert("no deposit");
        if (users[msg.sender].deposit >= maxInvest) revert("max amount reached");
        if (users[msg.sender].lastTime + checkPoint > block.timestamp) revert("not time to claim");

        uint256 amount = getUserRewards(msg.sender);
        users[msg.sender].deposit += amount;
        users[msg.sender].lastTime = block.timestamp;

        emit CompoundSingle(msg.sender, amount);
    }

    function withdraw() public {
        if (users[msg.sender].deposit == 0) revert("no deposit");
        if (getBalance() == 0) revert("no funds");
        if (users[msg.sender].payout >= users[msg.sender].deposit * 2) revert("gains of only 200%");
        if (users[msg.sender].lastTime + checkPoint > block.timestamp) revert("not time to claim");

        uint256 amount = getUserRewards(msg.sender);
        if (getBalance() < amount) amount = getBalance();

        uint256 oFee = calculateFee(amount);
        payable (owner).transfer(oFee);

        users[msg.sender].lastTime = block.timestamp;
        users[msg.sender].payout += amount;

        payable (msg.sender).transfer(amount - oFee);
        tPayout += amount;
        tPayoutCount++;

        emit WithdrawSingle(msg.sender, amount);
        emit FeeOwnerSingle(oFee);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getMaxInvest() public view returns(uint256) {
        return maxInvest;
    }

    function getDeposit() public view returns(uint256) {
        return tDeposit;
    }

    function getDepositCount() public view returns(uint256) {
        return tDepositCount;
    }

    function getPayout() public view returns(uint256) {
        return tPayout;
    }

    function getPayoutCount() public view returns(uint256) {
        return tPayoutCount;
    }

	function getUserDeposit(address addr) public view returns(uint256) {
		return users[addr].deposit;
	}

	function getUserPayout(address addr) public view returns(uint256) {
		return users[addr].payout;
	}

	function getUserCheckPoint(address addr) public view returns(uint256) {
		return users[addr].lastTime;
	}

    function getUserReferralsPayout(address addr) public view returns(uint256) {
		return users[addr].rPayout;
	}

    function getUserReferralsCount(address addr) public view returns(uint256) {
		return users[addr].rCount;
	}

    function getUserRewards(address addr) public view returns(uint256) {
        uint256 rewards = min(checkPoint, block.timestamp - users[addr].lastTime);
        return rewards * users[addr].deposit / 4838400;
    }

    function started() external {
        if (owner != msg.sender) revert("only owner");
        if (start != false) revert("started");
        start = true;
    }

    function setMaxInvest(uint256 amount_) external {
        if (owner != msg.sender) revert("only owner");
        maxInvest = amount_;
    }

    function setFee(uint256 fee_) external {
        if (owner != msg.sender) revert("only owner");
        if (fee_ > 5) revert("equal or less 5%");
        fee = fee_;
    }

    function setOwner(address owner_) external {
        if (owner != msg.sender) revert("only owner");
        owner = owner_;
    }

    function calculateFee(uint256 amount) internal view returns(uint256) {
        return amount * fee / 100;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}