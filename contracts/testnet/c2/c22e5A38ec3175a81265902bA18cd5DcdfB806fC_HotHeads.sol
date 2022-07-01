/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract HotHeads {

    uint256[] prices = [
        0.00004 ether,
        0.00006 ether,
        0.00010 ether,
        0.00013 ether,
        0.00015 ether,
        0.00020 ether,
        0.00030 ether,
        0.00040 ether,
        0.00050 ether,
        0.00100 ether,
        0.00200 ether
    ];

    uint256[] times = [
        191 hours,
        167 hours,
        143 hours,
        119 hours,
        95 hours,
        71 hours,
        47 hours,
        23 hours,
        11 hours,
        5 hours,
        0
    ];

    uint256 public startDateUnix;

    uint256[] gameRefPercents = [
        14,
        7,
        4
    ];

    uint256[] stakingRefPercents = [
        30,
        15,
        10
    ];

    address payable[][] public data;
    mapping (uint256 => mapping (uint256 => uint256)) public count;
    uint256[11] public pushUp;
    uint256[11] public pushDown;

    function balance() public view returns(uint) {
        return address(this).balance;
    }

    function get() public view returns(address payable[] memory s) {
        return(data[10]);
    }

    /// public

    uint256 constant INVEST_MIN_AMOUNT = 4e16; // 0.04 bnb
    uint256 constant INVEST_MAX_AMOUNT = 30e18; // 30 bnb

    uint256 constant PERIOD = 150 hours;
    uint256 constant PROJECT_FEE = 10;
    uint256 constant STAKING_FEE = 15;
    uint256 constant ROI = 300;
    uint256 constant PERCENTS_DIVIDER = 100;

    uint256 public totalInvested;
    uint256 public totalRefBonus;

    struct Deposit {
        uint256 amount;
        uint256 start;
        uint256 withdrawn;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[3] referals;
        uint256[3] dailyBonuses;
        uint256[3] refBonuses;
        uint256 totalBonus;

        uint256[11] _slots;
        uint256[11] _rewards;
    }

    mapping (address => User) internal users;

    address payable commissionWallet;

    event Fireslot(address indexed account, uint8 level);
    event Payment(address indexed recipient, uint8 level, address from, uint256 amount);
    event RefPayment(address indexed recipient, uint8 level, address from, uint256 amount);
    event NewDeposit(address indexed account, uint256 amount);
    event Reinvest(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event RefBonus(address indexed account, uint256 amount);
    event Fee(uint256 amount);

    constructor(address payable wallet, uint256 dep) {
        require(!isContract(wallet));
        commissionWallet = wallet;
        startDateUnix = block.timestamp;
        users[commissionWallet].referrer = commissionWallet;

        address payable[] memory s = new address payable[](1);
        s[0] = commissionWallet;
        for (uint256 i; i < 11; i++) {
            data.push(s);
        }

        users[commissionWallet].checkpoint = block.timestamp;
        users[commissionWallet].deposits.push(Deposit(dep, block.timestamp, 0));
    }

    fallback() external payable {
        if (msg.value > 0) {
            invest(bytesToAddress(msg.data));
        } else {
            withdraw();
        }
    }

    receive() external payable {
        if (msg.value > 0) {
            invest(address(0));
        } else {
            withdraw();
        }
    }

    function buyFireslot(uint8 level, address referrer) public payable {
        require(block.timestamp >= startDateUnix + times[level], "Slot not opened yet");
        User storage user = users[msg.sender];

        uint256 amount = msg.value / prices[level];
        require(amount >= 1, "Incorrect value");

        payable(msg.sender).transfer(msg.value % prices[level]);
        uint256 adminFee = msg.value * PROJECT_FEE / PERCENTS_DIVIDER;

        if (user.referrer == address(0) && referrer != msg.sender) {
			user.referrer = referrer;
			address ref = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (ref != address(0)) {
					users[ref].referals[i]++;

					ref = users[ref].referrer;
				} else break;
			}
		}

        address payable recipient;
        user._slots[level] += amount;
        for (uint256 i = 0; i < amount; i++) {
            data[level].push(payable(msg.sender));

            if (data[level].length < 3 || data[level].length % 2 == 0) {
                recipient = commissionWallet;
            } else {
                recipient = data[level][data[level].length / 2];
                count[level][data[level].length / 2]++;

                uint256 nextId = ((data[level].length-1) / 2)-1;
                address payable next = data[level][nextId];
                if (count[level][nextId] != 4 || next == commissionWallet) {
                    data[level].push(next);
                    count[level][data[level].length-1] = count[level][nextId];
                }
            }

            recipient.transfer(prices[level] / 2);
            user._rewards[level] += prices[level] / 2;
            emit Fireslot(msg.sender, level);
            emit Payment(recipient, level, msg.sender, prices[level] / 2);

            uint256 pushValue = prices[level] * 15 / 2 / PERCENTS_DIVIDER;

            if (level != 10) {
                pushUp[level] += pushValue;
                if (pushUp[level] >= prices[level+1]) {
                    data[level+1].push(commissionWallet); //
                    pushUp[level] -= prices[level+1];
                }
            } else {
                adminFee += pushValue;
            }

            if (level != 0) {
                pushDown[level] += pushValue;
                if (pushDown[level] >= prices[level-1]) {
                    data[level-1].push(commissionWallet); //
                    pushDown[level] -= prices[level-1];
                }
            } else {
                adminFee += pushValue;
            }
        }

        address upline = user.referrer;
        for (uint8 j = 0; j < 3; j++) {
            if (upline != address(0) && upline != commissionWallet) {
                uint256 refBonus = msg.value * gameRefPercents[j] / PERCENTS_DIVIDER;

                if (users[upline]._slots[level] > 0) {
                    users[upline].totalBonus += refBonus;
                    payable(upline).transfer(refBonus);
                    emit RefPayment(upline, j, msg.sender, refBonus);
                } else {
                    adminFee += refBonus;
                }

                upline = users[upline].referrer;
            } else {
                for (uint256 k = j; k < 3; k++) {
                    adminFee += msg.value * gameRefPercents[k] / PERCENTS_DIVIDER;
                }
                break;
            }
        }

        commissionWallet.transfer(adminFee);
        emit Fee(adminFee);
    }

    function invest(address referrer) public payable {
		checkIn(msg.value, referrer);
        emit NewDeposit(msg.sender, msg.value);
	}

	function reinvest() public {
		uint256 totalAmount = checkOut();

		checkIn(totalAmount, address(0));
        emit Reinvest(msg.sender, totalAmount);
	}

	function withdraw() public {
		uint256 totalAmount = checkOut();

		payable(msg.sender).transfer(totalAmount);
        emit Withdraw(msg.sender, totalAmount);
	}

	function checkIn(uint256 value, address referrer) internal {
		require(value >= INVEST_MIN_AMOUNT && value <= INVEST_MAX_AMOUNT, "Incorrect amount");

		uint256 adminFee = value * STAKING_FEE / PERCENTS_DIVIDER;
		commissionWallet.transfer(adminFee);
        emit Fee(adminFee);

		User storage user = users[msg.sender];

        if (user.referrer == address(0) && referrer != msg.sender) {
			user.referrer = referrer;
			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {

					users[upline].referals[i]++;
                    users[upline].dailyBonuses[i] += (value * 2 / 100) * stakingRefPercents[i] / 100;

					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
		}

		user.deposits.push(Deposit(value, block.timestamp, 0));

		totalInvested += value;

	}

	function checkOut() internal returns(uint256) {
		User storage user = users[msg.sender];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start + PERIOD;
			uint256 roi = user.deposits[i].amount * ROI / PERCENTS_DIVIDER;
			if (user.deposits[i].withdrawn < roi) {
				uint256 profit;
				if (block.timestamp >= finish) {
					profit = roi - user.deposits[i].withdrawn;
				} else {
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = block.timestamp;
					profit = roi * (to - from) / PERIOD;
				}

				totalAmount += profit;
				user.deposits[i].withdrawn += profit;
			}
		}

        uint256 refBonus;
        address upline = user.referrer;
        for (uint256 i = 0; i < 3; i++) {
            refBonus += user.refBonuses[i];
            user.refBonuses[i] = 0;
            if (upline != address(0)) {
                users[upline].refBonuses[i] += totalAmount * stakingRefPercents[i] / 100;

                upline = users[upline].referrer;
            }
        }
        user.totalBonus += refBonus;
        totalAmount += refBonus;

		require(totalAmount > 0, "User has no dividends");

		user.checkpoint = block.timestamp;

        emit RefBonus(msg.sender, refBonus);

		return totalAmount;
	}

    function getSiteInfo() public view returns(uint256[11] memory amt, uint256[11] memory time) {
        for (uint256 i; i < 11; i++) {
            uint t = (startDateUnix + times[i]);
            time[i] = block.timestamp < t ? t - block.timestamp : 0;
            amt[i] = data[i].length;
        }
    }

    function getUserInfo(address account) public view returns(uint256[11] memory slots, uint256[11] memory rewards, uint256[11] memory invested, address[3] memory referrers, uint256[3] memory referrals) {
        User storage user = users[account];

        slots = user._slots;
        rewards = user._rewards;

        for (uint256 i; i < 11; i++) {
            invested[i] = user._slots[i] * prices[i];
        }

        referrers[0] = user.referrer;
        referrers[1] = users[referrers[0]].referrer;
        referrers[2] = users[referrers[1]].referrer;

        referrals = user.referals;
    }

    function getStakingInfo(address account) public view returns(uint256 invested, uint256 avialable, uint256 withdrawn, uint256[3] memory refBonus, uint256 totalBonus) {
        User storage user = users[account];

		for (uint256 i = 0; i < user.deposits.length; i++) {
			uint256 finish = user.deposits[i].start + PERIOD;
			uint256 roi = user.deposits[i].amount * ROI / PERCENTS_DIVIDER;
			if (user.deposits[i].withdrawn < roi) {
				uint256 profit;
				if (block.timestamp >= finish) {
					profit = roi - user.deposits[i].withdrawn;
				} else {
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = block.timestamp;
					profit = roi * (to - from) / PERIOD;

				}

				avialable += profit;
			}

			invested += user.deposits[i].amount;
			withdrawn += user.deposits[i].withdrawn;
		}

        refBonus = user.refBonuses;

		totalBonus = user.totalBonus;
    }

    function getDepositInfo(address account, uint256 i) public view returns(bool active, uint256 startUnix, uint256 amount, uint256 timePassed, uint256 dailyAmount, uint256 evenUnix, uint256 avialable, uint256 withdrawn, uint256 finishAmount, uint256 finishUnix) {
        User storage user = users[account];

        amount = user.deposits[i].amount;
        withdrawn = user.deposits[i].withdrawn;
        startUnix = user.deposits[i].start;
        timePassed = block.timestamp - startUnix;
        evenUnix = startUnix + (PERIOD / 3);
        finishUnix = startUnix + PERIOD;
        dailyAmount = amount * 2 / 100;
        finishAmount = amount * ROI / PERCENTS_DIVIDER;

        if (withdrawn < finishAmount) {
            if (block.timestamp >= finishUnix) {
                avialable = finishAmount - withdrawn;
                active = false;
            } else {
                uint256 from = startUnix > user.checkpoint ? startUnix : user.checkpoint;
                uint256 to = block.timestamp;
                avialable = finishAmount * (to - from) / PERIOD;
                active = true;
            }
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function bytesToAddress(bytes memory _source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(_source,0x14))
        }
        return parsedreferrer;
    }

}