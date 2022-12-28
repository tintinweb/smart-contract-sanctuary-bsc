/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

/**
 *Website: aimtoken.tech
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract AIMstaking {
	token public AIM = token(0x7798184925900A9D8F258069d4A56Bb3998aA9C8);
	address public owner;
	address public project;
	address public leader;
	address public developer;

	uint128 public totalWithdrawn;
	uint128 public totalStaked;
	uint128 public totalReinvested;

	uint64 public totalDeposits;

	uint8 public developer_percent = 2;
	uint8 public project_percent = 10;
	uint8 public leader_percent = 2;
	uint8 public constant PERCENT_DIVIDER = 100;
	uint8 public constant PERCENT_TOTAL = 150;
	uint8 public constant PERCENT_PERDAY = 1;

	uint8 public constant DIRECT_PERCENT = 5;
	uint8 public constant LEVEL1_PERCENT = 3;
	uint8 public constant LEVEL2_PERCENT = 2;

	uint32 public constant TIME_STEP = 1 days;
	uint32 public constant STAKE_LENGTH = TIME_STEP * PERCENT_TOTAL / PERCENT_PERDAY;
    uint128 public constant INVEST_MIN_AMOUNT = 100 ether; //100 AIM




	constructor(address _project, address _developer, address _leader) {
		project = _project;
		developer = _developer;
		leader = _leader;
		owner = msg.sender;
	}

	struct User {
		address referrer;
		uint32 lastClaim;
		uint32 startIndex;

		uint96 bonus_0;
		uint32 downlines_0;
		uint96 bonus_1;
		uint32 downlines_1;
		uint96 bonus_2;
		uint32 downlines_2;
		uint128 bonusClaimed;
	}

	struct Stake {
		uint96 amount;
		uint32 startDate;
	}

	mapping(address => User) public users;
	mapping(address => Stake[]) public stakes;
	mapping(address => mapping(uint32 => address)) public directs;

	function makeStake(address referrer, uint256 amount) public {
		require(amount >= INVEST_MIN_AMOUNT, "Minimum not met.");

		User storage user = users[msg.sender];

		AIM.transferFrom(msg.sender, address(this), amount);
		AIM.transfer(developer, amount * developer_percent / PERCENT_DIVIDER);
		AIM.transfer(project, amount * project_percent / PERCENT_DIVIDER);
		AIM.transfer(leader, amount * leader_percent / PERCENT_DIVIDER);

		User storage refUser;

		if(msg.sender != owner && user.referrer == address(0)) {
			if(stakes[referrer].length == 0) referrer = owner;
			user.referrer = referrer;

			refUser = users[referrer];

			directs[referrer][refUser.downlines_0] = msg.sender;
			refUser.downlines_0++;

			if(referrer != owner) {
				refUser = users[refUser.referrer];
				refUser.downlines_1++;
				if(refUser.referrer != address(0)) {
					refUser = users[refUser.referrer];
					refUser.downlines_2++;
				}
			}
		}

		uint96 comamount;
		if(user.referrer != address(0)) {

			refUser = users[user.referrer];

			comamount = uint96(amount * DIRECT_PERCENT / PERCENT_DIVIDER);
			refUser.bonus_0 += comamount;
			emit ReferralBonus(user.referrer, msg.sender, comamount, 0);

			if(user.referrer != owner) {

				comamount = uint96(amount * LEVEL1_PERCENT / PERCENT_DIVIDER);

				emit ReferralBonus(refUser.referrer, msg.sender, comamount, 1);
				refUser = users[refUser.referrer];
				refUser.bonus_1 += comamount;

				if(refUser.referrer != address(0)) {
					comamount = uint96(amount * LEVEL2_PERCENT / PERCENT_DIVIDER);
					users[refUser.referrer].bonus_2 += comamount;

					emit ReferralBonus(refUser.referrer, msg.sender, comamount, 2);
				}
			}
		}

		stakes[msg.sender].push(Stake(uint96(amount * PERCENT_TOTAL / PERCENT_DIVIDER), uint32(block.timestamp)));

		totalStaked += uint128(amount);
		totalDeposits++;

		emit NewStake(msg.sender, amount);
	}

	function reStake() public {

		User storage user = users[msg.sender];
		require(user.lastClaim + 1 minutes < block.timestamp, "Once every minute.");

		uint256 claimable;

		uint256 length = stakes[msg.sender].length;
		Stake memory stake;

		uint32 newStartIndex;
		uint32 lastClaim;

		for(uint32 i = user.startIndex; i < length; ++i) {
			stake = stakes[msg.sender][i];
			if(stake.startDate + STAKE_LENGTH > user.lastClaim) {
				lastClaim = stake.startDate > user.lastClaim ? stake.startDate : user.lastClaim;

				if(block.timestamp >= stake.startDate + STAKE_LENGTH) {
					claimable += stake.amount * (stake.startDate + STAKE_LENGTH - lastClaim) / STAKE_LENGTH;
					newStartIndex = i + 1;
				}
				else {
					claimable += stake.amount * (block.timestamp - lastClaim) / STAKE_LENGTH;
				}

			}
		}
		if(newStartIndex != user.startIndex) user.startIndex = newStartIndex;

		require(claimable > 0, "You don't have any claimable.");

		user.lastClaim = uint32(block.timestamp);

    	AIM.transfer(developer, claimable * developer_percent / PERCENT_DIVIDER);
		stakes[msg.sender].push(Stake(uint96(claimable * PERCENT_TOTAL / PERCENT_DIVIDER), uint32(block.timestamp)));

		totalReinvested += uint128(claimable);
		totalDeposits++;

		emit NewStake(msg.sender, claimable);
	}

	function withdraw() public {
		User storage user = users[msg.sender];
		require(user.lastClaim + 1 minutes < block.timestamp, "Once every minute.");

		uint256 claimable;

		uint256 length = stakes[msg.sender].length;
		Stake memory stake;

		uint32 newStartIndex;
		uint32 lastClaim;

		for(uint32 i = user.startIndex; i < length; ++i) {
			stake = stakes[msg.sender][i];
			if(stake.startDate + STAKE_LENGTH > user.lastClaim) {
				lastClaim = stake.startDate > user.lastClaim ? stake.startDate : user.lastClaim;

				if(block.timestamp >= stake.startDate + STAKE_LENGTH) {
					claimable += stake.amount * (stake.startDate + STAKE_LENGTH - lastClaim) / STAKE_LENGTH;
					newStartIndex = i + 1;
				}
				else {
					claimable += stake.amount * (block.timestamp - lastClaim) / STAKE_LENGTH;
				}

			}
		}
		if(newStartIndex != user.startIndex) user.startIndex = newStartIndex;

		require(claimable > 0, "You don't have any claimable.");
		
		user.lastClaim = uint32(block.timestamp);

		AIM.transfer(msg.sender, claimable);
		AIM.transfer(developer, claimable * developer_percent / PERCENT_DIVIDER);

		totalWithdrawn += uint128(claimable);
        
		emit Withdraw(msg.sender, claimable);
	}

	function withdrawReferralBonus() public {
		User storage user = users[msg.sender];

		uint128 bonusTotal = user.bonus_0 + user.bonus_1 + user.bonus_2;

		AIM.transfer(msg.sender, bonusTotal - user.bonusClaimed);

		user.bonusClaimed = bonusTotal;
	}

	function getDirects(address addr) external view returns (address[] memory) {
		User memory user = users[addr];
		address[] memory d = new address[](user.downlines_0);
		for(uint256 i = 0; i < user.downlines_0; ++i) {
			d[i] = directs[addr][uint32(i)];
		}
		return d;
	}

	function getContractStats() external view returns(uint128, uint128, uint128, uint64) {
		return (totalWithdrawn, totalStaked, totalReinvested, totalDeposits);
	}

	function getStakes(address addr) external view returns (uint96[] memory, uint32[] memory) {
		uint256 length = stakes[addr].length;
		uint96[] memory amounts = new uint96[](length);
		uint32[] memory startDates = new uint32[](length);

		for(uint256 i = 0; i < length; ++i) {
			amounts[i] = stakes[addr][i].amount;
			startDates[i] = stakes[addr][i].startDate;
		}

		return (amounts, startDates);
	}

	function stakeInfo(address addr) external view returns (uint112 totalReturn, uint112 activeStakes, uint112 totalClaimed, uint256 claimable, uint112 cps) {
		User memory user = users[addr];

		uint256 length = stakes[addr].length;
		Stake memory stake;

		uint32 lastClaim;

		for(uint256 i = 0; i < length; ++i) {
			stake = stakes[addr][i];
			totalReturn += stake.amount;

			lastClaim = stake.startDate > user.lastClaim ? stake.startDate : user.lastClaim;

			if(block.timestamp < stake.startDate + STAKE_LENGTH) {
				cps += stake.amount * PERCENT_PERDAY / PERCENT_TOTAL / 24 / 60 / 60;
				activeStakes += stake.amount;
			}
			if(lastClaim >= stake.startDate + STAKE_LENGTH) {
				totalClaimed += stake.amount;
			}
			else {
				totalClaimed += stake.amount * (lastClaim - stake.startDate) / STAKE_LENGTH;
			}

			if(i >= user.startIndex) {
				if(block.timestamp >= stake.startDate + STAKE_LENGTH) {
					claimable += stake.amount * (stake.startDate + STAKE_LENGTH - lastClaim) / STAKE_LENGTH;
				}
				else {
					claimable += stake.amount * (block.timestamp - lastClaim) / STAKE_LENGTH;
				}
			}
		}

	}

	function changeAddress(uint256 n, address addr) public onlyOwner {
		if(n == 1) {
			developer = addr;
		}
		else if(n == 2) {
			project = addr;
		}
		else if(n == 3) {
			leader = addr;
		}
		else {
			AIM = token(addr);
		}
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	event NewStake(address indexed user, uint256 amount);
	event ReferralBonus(address indexed referrer, address indexed user, uint256 level, uint96 amount);
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