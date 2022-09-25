/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library Strings {
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function mint(address to, uint256 value) external returns (bool);
    function burnFrom(address from, uint256 value) external;
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}

contract Ownable {
    address internal _owner;

    constructor(address initialOwner) {
        require(initialOwner != address(0));
        _owner = initialOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract Chickly is Ownable {
    using Strings for uint256;

    string public constant name = "Chickly NFT Collection";
    string public constant symbol = "CKLY";
    uint256 public totalSupply;

	IERC20 BUSD;
    uint256 rateBUSD = 250;

	uint256 constant BASE_PERCENT = 100;
	uint256 constant MARKETING_FEE = 200;
	uint256 constant PROJECT_FEE = 1000;
	uint256 constant PERCENTS_DIVIDER = 10000;
	uint256 constant CONTRACT_BALANCE_STEP = 40e18; ///
	uint256 constant TIME_STEP = 1 hours; ///
	uint256 constant DEPOSITS_MAX = 25;
	uint256 constant HOLD_STEP = 10;
	uint256[] REFERRAL_PERCENTS = [
        700,
        200,
        100
    ];

	struct Plan {
        uint256 price;
        uint16 ROI;
    }

    Plan[] plans;

	uint32 startUNIX;
    uint32[] times;

	uint24 _totalUsers;
    uint256[2] _totalInvested;

	address payable marketingAddress;
	address payable projectAddress;

	struct Deposit {
		uint8 plan;
		uint256 value;
		uint256 withdrawn;
        uint256 bonus;
		uint32 start;
	}

	struct User {
		Deposit[] deposits;
        uint32[3] timestamps;
        uint256[2] reserved;
		uint256[6] totalRefBonus;
        uint256[2] refBonus;
		uint24[3] referals;
		address referrer;
	}

	mapping (address => User) internal users;

    mapping(uint256 => mapping(address => uint256)) private _balances;
    string private _uri;

    uint16[] percents = [
        0,50,100
    ];

	event NewDeposit(address indexed user, uint8 plan, uint256 amount);
	event Withdrawn(address indexed user, uint256 bnb, uint256 busd);
    event Feed(address indexed user);
    event Reinvest(address indexed user, uint8 plan, uint256 amount);
    event Revived(address indexed user, uint256 depositId, uint8 plan, uint256 amount);
    event ContractBonusUpd(uint256 oldPercent, uint256 newPercent);
    event NewReferral(address indexed referrer, address indexed referral, uint256 indexed level);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    mapping (uint256 => uint256) airdropped;
    uint256 _totalAirdropped;
    bool airdropFinished;
    function airdrop(address[] memory accounts, uint8[] memory planIds, uint256[] memory amounts, bool finish) public {
        require(!airdropFinished);
        uint256 sum;
        for (uint256 i = 0; i < accounts.length; i++) {
            _createDeposit(accounts[i], planIds[i], amounts[i]);
            sum += plans[planIds[i]].price * amounts[i];
        }
        uint256 today = (block.timestamp - startUNIX) / TIME_STEP;
        airdropped[today] += sum;
        _totalAirdropped += sum;
        require(airdropped[today] <= 5e18 && _totalAirdropped <= 500e18);
        airdropFinished = finish;
    }

    constructor(address busd, address payable marketingAddr, address payable projectAddr, uint32 startDate, string memory baseURI) Ownable(msg.sender) {
        BUSD = IERC20(busd);
		marketingAddress = marketingAddr;
		projectAddress = projectAddr;
		startUNIX = startDate;
        _uri = baseURI;

        plans.push(Plan(4e13, 17000));
        plans.push(Plan(4e14, 18000));
        plans.push(Plan(2e15, 19000));
        plans.push(Plan(12e15, 20000));
        plans.push(Plan(40e15, 22000));
        plans.push(Plan(10e18, 17000));
        plans.push(Plan(100e18, 18000));
        plans.push(Plan(500e18, 19000));
        plans.push(Plan(3000e18, 20000));
        plans.push(Plan(10000e18, 22000));

        times.push(startUNIX);
	}

	function buyNFT(uint8 plan, uint256 amount, address referrer) public payable {
		require(uint32(block.timestamp) >= startUNIX, "Not started yet");
        require(amount >= 1, "Amount must be more than 0");
        require(users[msg.sender].deposits.length + 1 <= DEPOSITS_MAX, "Deposits amount limit exceeded");
        uint256 value = plans[plan].price * amount;
        if (plan < 5) {
            require(msg.value >= value, "You must attach enough BNB to tx");
            require(value <= CONTRACT_BALANCE_STEP, "Maximum limit BNB per deposit");
            if (msg.value > value) {
                uint256 mod = msg.value - value;
                payable(msg.sender).transfer(mod);
            }
        } else if (plan < 10) {
            if (msg.value > 0) {
                payable(msg.sender).transfer(msg.value);
            }
            require(BUSD.allowance(msg.sender, address(this)) >= value, "You must approve enough BUSD first");
            require(value / rateBUSD <= CONTRACT_BALANCE_STEP, "Maximum limit BUSD per deposit");
            BUSD.transferFrom(msg.sender, address(this), value);
        } else revert("Plan number must be from 0 to 9");

		User storage user = users[msg.sender];
		if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
			user.referrer = referrer;

            address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
					users[upline].referals[i] += 1;
                    emit NewReferral(upline, msg.sender, i);
					upline = users[upline].referrer;
				} else break;
            }
		}

		_createDeposit(msg.sender, plan, amount);

        uint256 oldPercent;
        uint256 newPercent;
        uint256 stage = (_totalInvested[0] + (_totalInvested[1] / rateBUSD)) / CONTRACT_BALANCE_STEP;
        if (stage < percents.length) {
            oldPercent = percents[times.length-1];
            newPercent = percents[stage];
        } else {
            oldPercent = percents[percents.length-1] + (times.length - percents.length);
            newPercent = percents[percents.length-1] + (stage+1 - percents.length);
        }

        if (newPercent > oldPercent && newPercent <= 2000) {
            times.push(uint32(block.timestamp));
            emit ContractBonusUpd(oldPercent, newPercent);
        }
	}

	function _createDeposit(address account, uint8 plan, uint256 amount) internal {
        User storage user = users[account];

		uint256 price = plans[plan].price * amount;

        uint8 flag;
        if (plan >= 5) {
            flag = 1;
        }

        _refPayment(account, price, flag);

        uint32 blocktimestamp = uint32(block.timestamp);

		if (user.deposits.length == 0) {
			user.timestamps = [blocktimestamp, blocktimestamp, blocktimestamp];
			_totalUsers += 1;
		}

		user.deposits.push(Deposit(plan, price, 0, 0, blocktimestamp));
        totalSupply += amount;
        _balances[plan][account] += amount;
		emit TransferSingle(msg.sender, address(0), account, plan, amount);

        _totalInvested[flag] += price;
		emit NewDeposit(account, plan, amount);
	}

    function _refPayment(address account, uint256 value, uint8 busd) internal {
        User storage user = users[account];

        if (busd == 0) {
            projectAddress.transfer(value * PROJECT_FEE / PERCENTS_DIVIDER);
        } else {
            BUSD.transfer(projectAddress, value * PROJECT_FEE / PERCENTS_DIVIDER);
        }

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 refBonus = value * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
					users[upline].refBonus[busd] += refBonus;
                    users[upline].totalRefBonus[i+(busd*3)] += refBonus;
					emit RefBonus(upline, account, i, refBonus);
					upline = users[upline].referrer;
				} else break;
			}
		}
	}

    function feed() public {
        User storage user = users[msg.sender];

        require(user.timestamps[2] + TIME_STEP <= block.timestamp, "Not hungry yet");

        uint256 holdPercent = _getHoldBonus(user.timestamps[1], user.timestamps[2], user.timestamps[2] + TIME_STEP);
        uint256 bonusPercent = holdPercent + _getContractBonus(user.timestamps[2], user.timestamps[2] + TIME_STEP);

        if (bonusPercent > 0) {
            for (uint256 i = 0; i < user.deposits.length; i++) {
                uint256 roi = user.deposits[i].value * plans[user.deposits[i].plan].ROI / PERCENTS_DIVIDER;
                if (user.deposits[i].withdrawn + user.deposits[i].bonus < roi && user.deposits[i].start < user.timestamps[2] + TIME_STEP) {

                    uint256 value;
                    if (user.deposits[i].start <= user.timestamps[2]) {
                        value = user.deposits[i].value * bonusPercent / PERCENTS_DIVIDER / TIME_STEP;
                    } else if (user.deposits[i].start <= user.timestamps[2] + TIME_STEP) {
                        value = user.deposits[i].value * (_getHoldBonus(user.timestamps[1], user.deposits[i].start, user.timestamps[2] + TIME_STEP) + _getContractBonus(user.deposits[i].start, user.timestamps[2] + TIME_STEP)) / TIME_STEP / PERCENTS_DIVIDER;
                    }

                    user.deposits[i].bonus += value;
                }
            }
        }

        user.timestamps[2] = (block.timestamp - user.timestamps[2]) < TIME_STEP * 2 ? uint32(user.timestamps[2] + TIME_STEP) : uint32(block.timestamp);

        emit Feed(msg.sender);
    }

    function reinvest(uint256 value, uint8 plan) public {
        User storage user = users[msg.sender];

        require(plan < plans.length, "Plan number must be from 0 to 9");
        uint256 amount = value / plans[plan].price;
        value = amount * plans[plan].price;
        require(amount >= 1, "Amount must be more than 0");
        require(user.deposits.length + 1 <= DEPOSITS_MAX, "Deposits amount limit exceeded");

		(uint256 totalBNB, uint256 totalBUSD) = _withdraw();

        user.reserved[0] += totalBNB;
        user.reserved[1] += totalBUSD;

        uint8 flag;
        if (plan >= 5) {
            flag = 1;
        }

        require(user.reserved[flag] >= value, "Not enough profit available");
        user.reserved[flag] -= value;

        _createDeposit(msg.sender, plan, amount);

        emit Reinvest(msg.sender, plan, amount);
    }

    function revive(uint256 depositId) public payable {
        User storage user = users[msg.sender];

        uint8 plan = user.deposits[depositId].plan;
        uint256 value = user.deposits[depositId].value * 90 / 100;

        if (user.deposits[depositId].withdrawn < user.deposits[depositId].value * plans[plan].ROI / PERCENTS_DIVIDER) {
    		(uint256 totalBNB, uint256 totalBUSD) = _withdraw();
            user.reserved[0] += totalBNB;
            user.reserved[1] += totalBUSD;
            require(user.deposits[depositId].withdrawn >= user.deposits[depositId].value * plans[plan].ROI / PERCENTS_DIVIDER, "Deposit is not expired yet");
        }

        uint8 flag;
        if (plan < 5) {
            if (msg.value < value) {
                require(user.reserved[0] + msg.value >= value, "You must attach enough BNB to tx");
                user.reserved[0] -= value - msg.value;
            } else if (msg.value > value) {
                uint256 mod = msg.value - value;
                payable(msg.sender).transfer(mod);
            }
        } else {
            if (msg.value > 0) {
                payable(msg.sender).transfer(msg.value);
            }
            uint256 allowance = BUSD.allowance(msg.sender, address(this));
            uint256 balance = BUSD.balanceOf(msg.sender);
            allowance = balance >= allowance ? allowance : balance;
            if (allowance < value) {
                require(user.reserved[1] + allowance >= value, "You must approve enough BUSD first");
                user.reserved[1] -= value - allowance;
            }
            if (allowance > 0) {
                BUSD.transferFrom(msg.sender, address(this), allowance);
            }
            flag = 1;
        }

        _refPayment(msg.sender, value, flag);

        user.deposits[depositId].withdrawn = 0;
        user.deposits[depositId].bonus = 0;
        user.deposits[depositId].start = uint32(block.timestamp);
        _totalInvested[flag] += value;

        emit Revived(msg.sender, depositId, plan, value);
    }

	function withdraw() public {
        (uint256 totalBNB, uint256 totalBUSD) = _withdraw();

		require(totalBNB > 0 || totalBUSD > 0, "User has no profit");

		users[msg.sender].timestamps[1] = uint32(block.timestamp);

        if (totalBNB > 0) {
            payable(msg.sender).transfer(totalBNB);
            marketingAddress.transfer(totalBNB * MARKETING_FEE / PERCENTS_DIVIDER);
        }

        if (totalBUSD > 0) {
            BUSD.transfer(msg.sender, totalBUSD);
            BUSD.transfer(marketingAddress, totalBUSD * MARKETING_FEE / PERCENTS_DIVIDER);
        }

        emit Withdrawn(msg.sender, totalBNB, totalBUSD);
	}

    function _withdraw() internal returns(uint256 totalBNB, uint256 totalBUSD) {
        User storage user = users[msg.sender];

        totalBNB = user.reserved[0] + user.refBonus[0];
        totalBUSD = user.reserved[1] + user.refBonus[1];
        user.reserved[0] = 0;
        user.reserved[1] = 0;
        user.refBonus[0] = 0;
        user.refBonus[1] = 0;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint8 plan = user.deposits[i].plan;
            uint256 roi = user.deposits[i].value * plans[plan].ROI / PERCENTS_DIVIDER;
            if (user.deposits[i].withdrawn < roi) {
                uint256 from = user.deposits[i].start > user.timestamps[0] ? user.deposits[i].start : user.timestamps[0];
                uint256 to = block.timestamp;
                uint256 profit = user.deposits[i].value * BASE_PERCENT / PERCENTS_DIVIDER * (to - from) / TIME_STEP + user.deposits[i].bonus;
                user.deposits[i].bonus = 0;
                from = 0;
                if (to >= user.timestamps[2] + TIME_STEP) {
                    if (user.deposits[i].start <= user.timestamps[2]) {
                        from = user.timestamps[2];
                    } else if (user.deposits[i].start < user.timestamps[2] + TIME_STEP) {
                        from = user.deposits[i].start;
                    }
                    to = user.timestamps[2] + TIME_STEP;
                } else {
                    if (to >= user.deposits[i].start + TIME_STEP) {
                        from = user.timestamps[2];
                    } else {
                        from = user.deposits[i].start;
                    }
                }
                if (from > 0) {
                    profit += user.deposits[i].value * (_getHoldBonus(user.timestamps[1], from, to) + _getContractBonus(from, to)) / PERCENTS_DIVIDER / TIME_STEP;
                }
                if (user.deposits[i].withdrawn + profit > roi) {
                    profit = roi - user.deposits[i].withdrawn;
                }
                user.deposits[i].withdrawn += profit;
                if (plan < 5) {
                    totalBNB += profit;
                } else {
                    totalBUSD += profit;
                }
            }
        }

        user.timestamps[0] = uint32(block.timestamp);
    }

    function _getCurrentContractBonus() internal view returns(uint256 contractBonus) {
        if ((_totalInvested[0] + (_totalInvested[1] / rateBUSD)) / CONTRACT_BALANCE_STEP < percents.length) {
            contractBonus = percents[times.length-1];
        } else {
            contractBonus = percents[percents.length-1] + (times.length - percents.length);
        }
    }

	function _getContractBonus(uint256 start, uint256 finish) internal view returns(uint256 contractBonus) {
        uint256 count = times.length-1;
        while (start < times[count]) {
            count--;
        }
        while (true) {
            uint256 percent = count < percents.length-1 ? percents[count] : percents[percents.length-1] + (count - percents.length-1);
            if (count < times.length-1 && finish > times[count+1]) {
                contractBonus += percent * (times[count+1] - start);
                start = times[count+1];
                count++;
            } else {
                uint256 end = count < times.length-1 ? times[count+1] : block.timestamp;
                finish = finish < end ? finish : end;
                contractBonus += percent * (finish - start);
                break;
            }
        }
    }

	function _getUserHoldBonus(address userAddress) internal view returns(uint256) {
        User memory user = users[userAddress];
        if (user.timestamps[1] > 0) {
            return (block.timestamp - user.timestamps[1]) / TIME_STEP * HOLD_STEP;
        } else {
            return 0;
        }

	}

    function _getHoldBonus(uint256 lastWithdrawal, uint256 start, uint256 finish) internal view returns(uint256) {
        if (block.timestamp - lastWithdrawal < TIME_STEP || finish < start) return 0;

        uint256 startPercent = HOLD_STEP * (start - lastWithdrawal) / TIME_STEP;
        uint256 finishPercent = HOLD_STEP * (finish - lastWithdrawal) / TIME_STEP;

        if (finishPercent > startPercent) {
            uint256 middle = (lastWithdrawal + (finishPercent / HOLD_STEP) * TIME_STEP);
            return startPercent * (middle - start) + finishPercent * (finish - middle);
        } else {
            return startPercent * (finish - start);
        }
	}

    function getUserInfo(address userAddress) public view returns(uint256 amountOfDeposits, uint256[2] memory invested, bool[] memory active, uint256[2] memory available, uint256[2] memory remaining, uint256[2] memory totalAccrued, uint256 holdBonus, uint256 userPercent, uint256 lastWithdrawal, uint256 nextFeed) {
        User memory user = users[userAddress];
        amountOfDeposits = user.deposits.length;

        active = new bool[](amountOfDeposits);

        available[0] = user.reserved[0];
        available[1] = user.reserved[1];

        for (uint256 i = 0; i < amountOfDeposits; i++) {
            uint256 flag;
            if (user.deposits[i].plan >= 5) {
                flag = 1;
            }
            invested[flag] += user.deposits[i].value;
            uint256 roi = user.deposits[i].value * plans[user.deposits[i].plan].ROI / PERCENTS_DIVIDER;
            uint256 profit = 0;
            if (user.deposits[i].withdrawn < roi) {
                uint256 from = user.deposits[i].start > user.timestamps[0] ? user.deposits[i].start : user.timestamps[0];
                uint256 to = block.timestamp;
                profit = user.deposits[i].value * BASE_PERCENT / PERCENTS_DIVIDER * (to - from) / TIME_STEP + user.deposits[i].bonus;
                from = 0;
                if (to >= user.timestamps[2] + TIME_STEP) {
                    if (user.deposits[i].start <= user.timestamps[2]) {
                        from = user.timestamps[2];
                    } else if (user.deposits[i].start < user.timestamps[2] + TIME_STEP) {
                        from = user.deposits[i].start;
                    }
                    to = user.timestamps[2] + TIME_STEP;
                } else {
                    if (to >= user.deposits[i].start + TIME_STEP) {
                        from = user.timestamps[2];
                    } else {
                        from = user.deposits[i].start;
                    }
                }
                if (from > 0) {
                    profit += user.deposits[i].value * (_getHoldBonus(user.timestamps[1], from, to) + _getContractBonus(from, to)) / PERCENTS_DIVIDER / TIME_STEP;
                }
                if (user.deposits[i].withdrawn + profit > roi) {
                    profit = roi - user.deposits[i].withdrawn;
                } else {
                    active[i] = true;
                    remaining[flag] = roi - (user.deposits[i].withdrawn + profit);
                }
                available[flag] += profit;
            }
            totalAccrued[flag] += profit + user.deposits[i].withdrawn;
        }

        for (uint8 j; j < 2; j++) {
            for (uint8 k; k < 3; k++) {
                totalAccrued[j] += user.totalRefBonus[3*j + k];
            }
        }
        holdBonus = _getUserHoldBonus(userAddress);
        userPercent = BASE_PERCENT + _getCurrentContractBonus() + holdBonus;
        lastWithdrawal = user.timestamps[1];
        nextFeed = user.timestamps[2] + TIME_STEP > block.timestamp ? user.timestamps[2] + TIME_STEP - block.timestamp : 0;
    }

    function getDepositsInfo(address userAddress) public view returns(bool[] memory active, uint256[] memory startUnix, uint8[] memory plan, uint256[] memory amount, uint256[] memory finishAmount, uint256[] memory totalAccrued, uint256[] memory remaining) {
        User memory user = users[userAddress];

        uint256 amountOfDeposits = user.deposits.length;

        active = new bool[](amountOfDeposits);
        startUnix = new uint256[](amountOfDeposits);
        plan = new uint8[](amountOfDeposits);
        amount = new uint256[](amountOfDeposits);
        finishAmount = new uint256[](amountOfDeposits);
        totalAccrued = new uint256[](amountOfDeposits);
        remaining = new uint256[](amountOfDeposits);

        for (uint256 i = 0; i < amountOfDeposits; i++) {
            startUnix[i] = user.deposits[i].start;
            plan[i] = user.deposits[i].plan;
            amount[i] = user.deposits[i].value;
            uint256 roi = user.deposits[i].value * plans[user.deposits[i].plan].ROI / PERCENTS_DIVIDER;
            finishAmount[i] = roi;
            if (user.deposits[i].withdrawn < roi) {
                uint256 from = startUnix[i] > user.timestamps[0] ? startUnix[i] : user.timestamps[0];
                uint256 to = block.timestamp;
                uint256 profit = user.deposits[i].value * BASE_PERCENT / PERCENTS_DIVIDER * (to - from) / TIME_STEP + user.deposits[i].bonus;
                from = 0;
                if (to >= user.timestamps[2] + TIME_STEP) {
                    if (user.deposits[i].start <= user.timestamps[2]) {
                        from = user.timestamps[2];
                    } else if (user.deposits[i].start < user.timestamps[2] + TIME_STEP) {
                        from = user.deposits[i].start;
                    }
                    to = user.timestamps[2] + TIME_STEP;
                } else {
                    if (to >= user.deposits[i].start + TIME_STEP) {
                        from = user.timestamps[2];
                    } else {
                        from = user.deposits[i].start;
                    }
                }
                if (from > 0) {
                    profit += user.deposits[i].value * (_getHoldBonus(user.timestamps[1], from, to) + _getContractBonus(from, to)) / PERCENTS_DIVIDER / TIME_STEP;
                }
                if (user.deposits[i].withdrawn + profit < roi) {
                    active[i] = true;
                    remaining[i] = roi - (user.deposits[i].withdrawn + profit);
                }
            }
            totalAccrued[i] = finishAmount[i] - remaining[i];
        }
    }

    function getRefInfo(address userAddress) public view returns(address referrer, uint24[3] memory referals, uint256[2] memory bonus, uint256[6] memory totalBonuses) {
        User memory user = users[userAddress];
        referrer = user.referrer;
        referals = user.referals;
        bonus = user.refBonus;
        totalBonuses = user.totalRefBonus;
    }

    function getSiteInfo() public view returns(uint256 totalUsers, uint256[2] memory totalInvested, uint256[2] memory balance, uint256 contractBonus) {
        totalUsers = _totalUsers;
        totalInvested[0] = _totalInvested[0];
        totalInvested[1] = _totalInvested[1];
        balance[0] = address(this).balance;
        balance[1] = BUSD.balanceOf(address(this));
        contractBonus = _getCurrentContractBonus();
    }

    function balanceOf(address account, uint256 id) public view returns(uint256) {
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view returns(uint256[] memory) {
        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        return batchBalances;
    }

	function uri(uint256 id) public view returns (string memory) {
        return bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, id.toString(), ".json")) : "";
    }

    function supportsInterface(bytes4 interfaceId) public pure returns(bool) {
		return
			interfaceId == type(IERC1155).interfaceId ||
			interfaceId == type(IERC1155MetadataURI).interfaceId ||
			interfaceId == type(IERC165).interfaceId;
	}

}