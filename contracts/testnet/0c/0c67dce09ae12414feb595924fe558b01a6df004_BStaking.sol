/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract BStaking {
    token public BUSD = token(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
	address public owner;
	address public project;
	address public developer;

	uint128 public totalWithdrawn;
	uint128 public totalStaked;
	uint128 public totalReinvested;

	uint64 public totalStakeCount;

	uint8 public developer_percent = 5;
	uint8 public project_percent = 10;
	uint8 public constant PERCENT_DIVIDER = 100;
	uint8 public constant PERCENT_TOTAL = 180;
	uint8 public constant PERCENT_PERDAY = 6;
	uint32 public constant TIME_STEP = 1 days;
    uint128 public constant INVEST_MIN_AMOUNT = 10 ether;
	uint8[3] public REFERRAL_PERCENTS = [7, 3, 2];


	constructor(address _project, address _developer) {
		project = _project;
		developer = _developer;
		owner = msg.sender;
	}

	struct User {
		address referrer;
		uint96 leftOver;

		uint32 lastClaim;
		uint112 totalClaimable;
		uint112 totalInvested;

		uint128 bonusTotal;
		uint128 bonusClaimed;
	}

	mapping(address => User) public users;

	function makeStake(address referrer, uint256 amount) public {
		require(amount >= INVEST_MIN_AMOUNT, "Minimum not met.");

		User storage user = users[msg.sender];

		BUSD.transferFrom(msg.sender, address(this), amount);
		BUSD.transfer(developer, amount * developer_percent / PERCENT_DIVIDER);
		BUSD.transfer(project, amount * project_percent / PERCENT_DIVIDER);

		if(msg.sender != owner && user.referrer == address(0)) {
			if(users[referrer].totalInvested == 0) referrer = owner;
			user.referrer = referrer;
		}

		address upline = referrer;
		uint256 comamount;
		for(uint256 i = 0; i < 3; ++i) {
			if(upline == address(0)) break;
			comamount = amount * REFERRAL_PERCENTS[i] / PERCENT_DIVIDER;
			BUSD.transfer(upline, comamount);
			emit ReferralBonus(upline, msg.sender, comamount, i);
			upline = users[upline].referrer;
		}

		comamount = getClaimable();

		if(comamount > 0) user.leftOver += uint96(comamount);

		user.lastClaim = uint32(block.timestamp);
		user.totalInvested += uint112(amount);
		user.totalClaimable += uint112(amount * PERCENT_TOTAL / PERCENT_DIVIDER);

		emit NewStake(msg.sender, amount);
	}

	function reStake() public {
		User storage user = users[msg.sender];

		uint256 claimable = user.totalInvested * PERCENT_PERDAY / PERCENT_DIVIDER * (block.timestamp - user.lastClaim) / TIME_STEP;

		if(user.leftOver > 0) {
			claimable += user.leftOver;
			user.leftOver = 0;
		}

		if(claimable > user.totalClaimable) claimable = user.totalClaimable;

        uint256 contractBalance = BUSD.balanceOf(address(this)) - claimable * developer_percent / PERCENT_DIVIDER;

    	BUSD.transfer(developer, claimable * developer_percent / PERCENT_DIVIDER);
        if (contractBalance < claimable) {
            claimable = contractBalance;
        }

        user.totalInvested += uint112(claimable);
        user.totalClaimable += uint112(claimable * PERCENT_TOTAL / PERCENT_DIVIDER - claimable);
		user.lastClaim = uint32(block.timestamp);

		emit NewStake(msg.sender, claimable);
	}

	function withdraw() public {
		User storage user = users[msg.sender];
		require(user.lastClaim + 1 minutes < block.timestamp, "Once every minute.");

		uint256 claimable = user.totalInvested * PERCENT_PERDAY / PERCENT_DIVIDER * (block.timestamp - user.lastClaim) / TIME_STEP;

		if(user.leftOver > 0) {
			claimable += user.leftOver;
			user.leftOver = 0;
		}

		if(claimable > user.totalClaimable) claimable = user.totalClaimable;

        uint256 contractBalance = BUSD.balanceOf(address(this)) - claimable * developer_percent / PERCENT_DIVIDER;

    	BUSD.transfer(developer, claimable * developer_percent / PERCENT_DIVIDER);

        if (contractBalance < claimable) {
            claimable = contractBalance;
        }

		BUSD.transfer(msg.sender, claimable);
        
        user.totalClaimable -= uint112(claimable);
		user.lastClaim = uint32(block.timestamp);

		emit Withdraw(msg.sender, claimable);
	}

	function getClaimable() internal view returns (uint256 claimable) {
		User memory user = users[msg.sender];
		claimable = user.totalInvested * PERCENT_PERDAY / PERCENT_DIVIDER * (block.timestamp - user.lastClaim) / TIME_STEP;
		if(claimable > user.totalClaimable) claimable = user.totalClaimable;
	}

	function changeAddress(uint256 n, address addr) public onlyOwner {
		if(n == 1) {
			developer = addr;
		}
		else if(n == 2) {
			project = addr;
		}
		else {
			BUSD = token(addr);
		}
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	event NewStake(address indexed user, uint256 amount);
	event ReferralBonus(address indexed referrer, address indexed user, uint256 level, uint256 amount);
	event Withdraw(address indexed user, uint256 amount);
}

interface token {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}