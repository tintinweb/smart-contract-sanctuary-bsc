/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

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

	mapping(uint256 => mapping(address => uint256)) private _balances;

    string private _uri;

    string public constant name = "TESTNAME";
    string public constant symbol = "TNM";
    uint256 public totalSupply = 0;

	IERC20 BUSD;
    uint256 rateBUSD = 250;

	uint256 constant BASE_PERCENT = 100;
	uint256 constant MARKETING_FEE = 200;
	uint256 constant PROJECT_FEE = 1000;
	uint256 constant PERCENTS_DIVIDER = 10000;
	uint256 constant CONTRACT_BALANCE_STEP = 4e18; ///
	uint256 constant TIME_STEP = 1 hours; ///
	uint256 constant DEPOSITS_MAX = 25;
	uint256 constant HOLD_STEP = 10;
	uint256[] REFERRAL_PERCENTS = [
        700,
        200,
        100
    ];

    uint256[] public times;

	struct Plan {
        uint256 price;
        uint256 ROI;
    }

    Plan[] plans;

	uint32 public startUNIX;

	uint24 totalUsers;

	address payable marketingAddress;
	address payable projectAddress;

	struct Deposit {
		uint8 plan;
		uint256 value;
		uint256 withdrawn;
        uint256 holdBonus;
		uint256 start;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
        uint256 lastWithdrawal;
        uint256 lastFeed;
		address referrer;
		uint256[3] referals;
        uint256[2] bonus;
		uint256[6] totalBonuses;
        uint256[2] reserved;
	}

	mapping (address => User) internal users;

    uint256[] percents = [
        0,15,30,45,60,75,90,105,115,125,135,145,155,165,175,185,195,205,213,221,229,237,345,253,261,269,277,285,293,301,308,315,322,329,336,343,350,357,364,371,378,385,392,399,406,412,418,424,
        430,436,442,448,454,460,466,472,478,484,490,496,502,507,512,517,522,527,532,537,542,547,552,557,562,567,572,577,582,587,592,597,602,602,606,610,614,618,622,626,630,634,638,642,646,650,654,658,662,666,
        670,674,678,682,686,690,694,698,702,702,705,708,711,714,717,720,723,726,729,732,735,738,741,744,747,750,753,756,759,762,765,768,771,774,777,780,783,786,789,792,795,798,801,801,803,805,807,809,811,813,
        815,817,819,821,823,825,827,829,831,833,835,837,839,841,843,845,847,849,851,853,855,857,859,861,863,865,867,869,871,873,875,877,879,881,883,885,887,889,891,893,895,897,899,901
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

	constructor(address busd) Ownable(msg.sender) { ///
        BUSD = IERC20(busd);
		marketingAddress = payable(msg.sender);
		projectAddress = payable(msg.sender);
		startUNIX = 0;

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

        times.push(0);
	}

    bool airdropFinished;
    function airdrop(address[] memory accounts, uint8[] memory planIds, uint256[] memory amounts, bool finish) public {
        require(!airdropFinished);
        for (uint256 i = 0; i < accounts.length; i++) {
            createDeposit(accounts[i], planIds[i], amounts[i]);
        }
        airdropFinished = finish;
    }

	function buyNFT(uint8 plan, uint256 amount, address referrer) public payable {
		require(uint32(block.timestamp) >= startUNIX, "Not started yet");
        require(amount >= 1);
        require(users[msg.sender].deposits.length + amount <= DEPOSITS_MAX);
        if (plan < 5) {
            if (msg.value > plans[plan].price * amount) {
                uint256 mod = msg.value - (plans[plan].price * amount);
                payable(msg.sender).transfer(mod);
            }
        } else if (plan < 10) {
            require(msg.value == 0);
            BUSD.transferFrom(msg.sender, address(this), plans[plan].price * amount);
        } else revert();

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

		createDeposit(msg.sender, plan, amount);

        uint256 oldPercent;
        uint256 newPercent;
        uint256 stage = (address(this).balance + (BUSD.balanceOf(address(this)) / rateBUSD)) / CONTRACT_BALANCE_STEP; /// balance or turnover
        if (stage < percents.length) {
            oldPercent = percents[times.length];
            newPercent = percents[stage];
        } else {
            oldPercent = percents[percents.length-1] + (times.length - percents.length);
            newPercent = percents[percents.length-1] + (stage+1 - percents.length);
        }

        if (newPercent > oldPercent) {
            times.push(block.timestamp);
            emit ContractBonusUpd(oldPercent, newPercent);
        }
	}

	function createDeposit(address account, uint8 plan, uint256 amount) internal {
        User storage user = users[account];

		uint256 value = plans[plan].price * amount;

        uint8 flag;
        if (plan >= 5) {
            flag = 1;
        }

        _refPayment(account, value, flag);

		if (user.deposits.length == 0) {
			user.checkpoint = uint32(block.timestamp);
    		user.lastWithdrawal = uint32(block.timestamp);
    		user.lastFeed = uint32(block.timestamp);
			totalUsers += 1;
		}

		user.deposits.push(Deposit(plan, value, 0, 0, uint32(block.timestamp)));
        totalSupply += amount;
        _balances[plan][account] += amount;
		emit TransferSingle(msg.sender, address(0), account, plan, amount);

		emit NewDeposit(account, plan, amount);
	}

    function _refPayment(address account, uint256 value, uint8 busd) internal {
        User storage user = users[account];

        projectAddress.transfer(value * PROJECT_FEE / PERCENTS_DIVIDER);

		if (user.referrer != address(0)) {
			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 refBonus = value * REFERRAL_PERCENTS[i] / PERCENTS_DIVIDER;
					users[upline].bonus[busd] += refBonus;
                    users[upline].totalBonuses[i+(busd*3)] += refBonus;
					emit RefBonus(upline, account, i, refBonus);
					upline = users[upline].referrer;
				} else break;
			}
		}
	}

	function withdraw() public {
        uint256 totalBNB;
        uint256 totalBUSD;

		(totalBNB, totalBUSD) = _withdraw();

		require(totalBNB > 0 || totalBUSD > 0, "User has no profit");

		users[msg.sender].lastWithdrawal = block.timestamp;

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

        totalBNB = user.reserved[0];
        totalBUSD = user.reserved[1];
        delete user.reserved;

        uint256 holdPercent;
        if (block.timestamp - user.lastFeed < TIME_STEP) {
            holdPercent = getUserHoldBonus(msg.sender);
        }

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint8 plan = user.deposits[i].plan;
            uint256 roi = user.deposits[i].value * plans[plan].ROI / PERCENTS_DIVIDER;
            if (user.deposits[i].withdrawn < roi) {
                uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                uint256 to = block.timestamp;
                uint256 profit = (user.deposits[i].value / 100 * (to - from) + (user.deposits[i].value * getContractBonus(from, to) / PERCENTS_DIVIDER)) / TIME_STEP + user.deposits[i].holdBonus;
                if (holdPercent > 0) {
                    uint256 time = user.deposits[i].start < user.lastFeed ? block.timestamp - user.lastFeed : block.timestamp - user.deposits[i].start;
                    profit += user.deposits[i].value * holdPercent / PERCENTS_DIVIDER * time / TIME_STEP;
                }
                user.deposits[i].holdBonus = 0;
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

        user.checkpoint = block.timestamp;
    }

    function reinvest(uint256 value, uint8 plan) public {
        User storage user = users[msg.sender];

        require(plan < plans.length);
        uint256 amount = value / plans[plan].price;
        value = amount * plans[plan].price;
        require(amount >= 1);
        require(user.deposits.length + 1 <= DEPOSITS_MAX);

        uint256 totalBNB;
        uint256 totalBUSD;
		(totalBNB, totalBUSD) = _withdraw();

        user.reserved[0] += totalBNB;
        user.reserved[1] += totalBUSD;

        uint8 flag;
        if (plan >= 5) {
            flag = 1;
        }

        require(user.reserved[flag] >= value);
        user.reserved[flag] -= value;

        createDeposit(msg.sender, plan, amount);

        emit Reinvest(msg.sender, plan, amount);
    }

    function revive(uint256 depositId) public payable {
        User storage user = users[msg.sender];

        uint256 totalBNB;
        uint256 totalBUSD;
		(totalBNB, totalBUSD) = _withdraw();

        user.reserved[0] += totalBNB;
        user.reserved[1] += totalBUSD;

        uint8 plan = user.deposits[depositId].plan;
        uint256 value = user.deposits[depositId].value * 90 / 100;
        require(user.deposits[depositId].withdrawn >= user.deposits[depositId].value * plans[plan].ROI / PERCENTS_DIVIDER, "Deposit is not expired yet");

        uint8 flag;
        if (plan < 5) {
            require(msg.value >= value);
            if (msg.value > value) {
                uint256 mod = msg.value - value;
                payable(msg.sender).transfer(mod);
            }
        } else {
            BUSD.transferFrom(msg.sender, address(this), value);
            flag = 1;
        }

        _refPayment(msg.sender, value, flag); /// discounted?

        user.deposits[depositId].withdrawn = 0;
        user.deposits[depositId].start = uint32(block.timestamp);

        emit Revived(msg.sender, depositId, plan, user.deposits[depositId].value / plans[plan].price);
    }

    function feed() public {
        User storage user = users[msg.sender];

        uint256 holdBonus = getUserHoldBonus(msg.sender);
        require(user.lastFeed + TIME_STEP <= block.timestamp && holdBonus > 0, "Chicken not hungry yet");

        for (uint256 i = 0; i < user.deposits.length; i++) {
            uint256 roi = user.deposits[i].value * plans[user.deposits[i].plan].ROI / PERCENTS_DIVIDER;
            if (user.deposits[i].withdrawn + user.deposits[i].holdBonus < roi && user.deposits[i].start < user.lastFeed + TIME_STEP) {
                uint256 time = user.deposits[i].start <= user.lastFeed ? TIME_STEP : (user.lastFeed + TIME_STEP) - user.deposits[i].start;
                uint256 value = user.deposits[i].value * holdBonus * time / TIME_STEP / PERCENTS_DIVIDER;
                user.deposits[i].holdBonus += value;
            }
        }

        user.lastFeed = (block.timestamp - user.lastFeed) < TIME_STEP * 2 ? user.lastFeed + TIME_STEP : block.timestamp;

        emit Feed(msg.sender);
    }

	function getContractBonus(uint256 start, uint256 finish) public view returns(uint256 contractBonus) {
        require(finish >= start);
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

	function getUserHoldBonus(address userAddress) public view returns (uint256) {
        uint256 start = users[userAddress].lastWithdrawal;
        uint256 finish = block.timestamp;
        if (finish < start) return 0;
		uint256 _days = (finish - start) / TIME_STEP;
		return HOLD_STEP * _days;
	}

    function getUserInfo(address userAddress) public view returns(uint256 amountOfDeposits, uint256[2] memory invested, bool[] memory active, uint256[2] memory available, uint256[2] memory remaining, uint256 userPercent, uint256 lastWithdrawal, uint256 nextFeed) {
        User memory user = users[userAddress];
        amountOfDeposits = user.deposits.length;

        active = new bool[](amountOfDeposits);

        available[0] = user.reserved[0];
        available[1] = user.reserved[1];

        uint256 holdPercent;
        if (block.timestamp - user.lastFeed < TIME_STEP) {
            holdPercent = getUserHoldBonus(userAddress);
        }

        for (uint256 i = 0; i < amountOfDeposits; i++) {
            uint256 flag;
            if (user.deposits[i].plan >= 5) {
                flag = 1;
            }
            invested[flag] += user.deposits[i].value;
            uint256 roi = user.deposits[i].value * plans[user.deposits[i].plan].ROI / PERCENTS_DIVIDER;
            if (user.deposits[i].withdrawn < roi) {
                uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
                uint256 profit = (user.deposits[i].value / 100 * (block.timestamp - from) + (user.deposits[i].value * getContractBonus(from, block.timestamp) / PERCENTS_DIVIDER)) / TIME_STEP + user.deposits[i].holdBonus;
                if (holdPercent > 0) {
                    uint256 time = user.deposits[i].start < user.lastFeed ? block.timestamp - user.lastFeed : block.timestamp - user.deposits[i].start;
                    profit += user.deposits[i].value * holdPercent / PERCENTS_DIVIDER * time / TIME_STEP;
                }
                if (user.deposits[i].withdrawn + profit > roi) {
                    profit = roi - user.deposits[i].withdrawn;
                } else {
                    active[i] = true;
                    available[flag] += profit;
                    remaining[flag] = roi - (user.deposits[i].withdrawn + profit);
                }
                available[flag] += profit;
            }
        }

        userPercent = BASE_PERCENT + getUserHoldBonus(userAddress);
        lastWithdrawal = user.lastWithdrawal;
        nextFeed = user.lastFeed + TIME_STEP > block.timestamp ? user.lastFeed + TIME_STEP - block.timestamp : 0;
    }

    function getRefInfo(address userAddress) public view returns(address referrer, uint256[3] memory referals, uint256[2] memory bonus, uint256[6] memory totalBonuses) {
        User memory user = users[userAddress];
        referrer = user.referrer;
        referals = user.referals;
        bonus = user.bonus;
        totalBonuses = user.totalBonuses;
    }

    function getDepositsInfo(address userAddress) public view returns(bool[] memory active, uint256[] memory startUnix, uint8[] memory plan, uint256[] memory amount, uint256[] memory finishAmount, uint256[] memory remaining) {
        User memory user = users[userAddress];

        uint256 amountOfDeposits = user.deposits.length;

        active = new bool[](amountOfDeposits);
        startUnix = new uint256[](amountOfDeposits);
        amount = new uint256[](amountOfDeposits);
        finishAmount = new uint256[](amountOfDeposits);
        remaining = new uint256[](amountOfDeposits);

        uint256 holdPercent;
        if (block.timestamp - user.lastFeed < TIME_STEP) {
            holdPercent = getUserHoldBonus(userAddress);
        }

        for (uint256 i = 0; i < amountOfDeposits; i++) {
            startUnix[i] = user.deposits[i].start;
            plan[i] = user.deposits[i].plan;
            amount[i] = user.deposits[i].value;
            uint256 roi = user.deposits[i].value * plans[user.deposits[i].plan].ROI / PERCENTS_DIVIDER;
            finishAmount[i] = roi;
            if (user.deposits[i].withdrawn < roi) {
                uint256 from = startUnix[i] > user.checkpoint ? startUnix[i] : user.checkpoint;
                uint256 profit = (user.deposits[i].value / 100 * (block.timestamp - from) + (user.deposits[i].value * getContractBonus(from, block.timestamp) / PERCENTS_DIVIDER)) / TIME_STEP + user.deposits[i].holdBonus;
                if (holdPercent > 0) {
                    uint256 time = startUnix[i] < user.lastFeed ? block.timestamp - user.lastFeed : block.timestamp - startUnix[i];
                    profit += user.deposits[i].value * holdPercent / PERCENTS_DIVIDER * time / TIME_STEP;
                }
                if (user.deposits[i].withdrawn + profit < roi) {
                    active[i] = true;
                    remaining[i] = roi - (user.deposits[i].withdrawn + profit);
                }
            }
        }
    }

    function balanceBUSD() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getSiteInfo() public view returns(uint) {

    }

	function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
		return
			interfaceId == type(IERC1155).interfaceId ||
			interfaceId == type(IERC1155MetadataURI).interfaceId ||
			interfaceId == type(IERC165).interfaceId;
	}

	function baseURI() public view returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

	function uri(uint256 id) public view returns (string memory) {
        return bytes(baseURI()).length > 0 ? string(abi.encodePacked(baseURI(), id.toString())) : "";
    }

}