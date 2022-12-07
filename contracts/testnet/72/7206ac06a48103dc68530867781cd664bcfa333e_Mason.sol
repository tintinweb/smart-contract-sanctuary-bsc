/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// File: MasonVault.sol

// MASON Club - 2% daily in BNB
// 🌎 Website: https://mason.club


pragma solidity 0.8.12;

contract MasonVault {
    address masonAddress;

    modifier onlyMason() {
        require(msg.sender == masonAddress, "Only Mason");
        _;
    }


    constructor(address _masonAddress) {
        masonAddress = _masonAddress;
    }

    fallback() external payable {
        // custom function code
    }

    receive() external payable {
        // custom function code
    }

    function sendGift(address _address) external onlyMason {
        payable(_address).transfer(address(this).balance);
    }
}
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: Mason.sol

// MASON Club - 2% daily in BNB
// 🌎 Website: https://mason.club


pragma solidity 0.8.12;




contract Mason is Ownable{

	event Investment(
		address indexed user,
		uint256 amount
	);

	event Withdrawal(
		address indexed user,
		uint256 amount
	);

	event Registration(
		address indexed user,
		address indexed referal
	);

	event RefBonus(
		address indexed user,
		uint256 amount,
		address referal,
		uint256 indexed lvl
	);

	// CONSTANTS
	uint256 constant private RATIO_MULTIPLIER = 10000;
    uint256 constant private MAX_DEPOSIT_STEP = 10;
    uint256 constant private MARKETING_FEE = 900;
    uint256 constant private DEV_FEE = 300;
	uint256 constant private DIVIDENDS_PERCENT = 200;
	uint256 constant private GIFT_PERCENT = 200;
	uint256 constant private SEC_IN_24H = 1 days;
	uint256 constant private SEC_IN_WEEK = 7 days;
	uint256 constant private MIN_INVESTMENT = 0.02 ether;
	uint256 constant private GIFT_TIMEOUT = 5 minutes;
	uint256[] private REFER_BONUS_PERCENT = [1000, 500, 300, 200, 100];

	// STATE
	uint256 public initializedAt;
	uint256 public giftAmount = 0;
	address payable public lastPayAddress;
	uint256 public lastPayTime;

	uint256 public allInvestCount = 0;
	uint256 public allInvest = 0;
	uint256 public allPaymentsCount = 0;
	uint256 public allPayments = 0;
	uint256 public allMarketingPayments = 0;
	uint256 public usersCount = 0;
	uint256[] public adminRefSysPayment = [0,0,0,0,0];
	uint256[] public adminRefSysPaymentCount = [0,0,0,0,0];
	uint256[] public allReferBonus = [0,0,0,0,0];
	uint256[] public allReferBonusCount = [0,0,0,0,0];

	address payable public marketingAddress;
	address payable public devAddress;
	address payable public vaultAddress;

    struct User {
        uint256 invested;
        uint256 investedCount;
        uint256 payments;
        uint256 paymentsCount;
        uint256[5] referBonus;
        uint256[5] referBonusCount;
        address payable refer;
        address[] referals;
        uint256 referalsCount;
        uint256 lastPayment;
        uint256 registeredAt;
	}

	mapping (address => User) public users;

	constructor() {
		// createUserIfNotExist(msg.sender, address(0));
		// setMarketingAddress(msg.sender);
		// setDevAddress(msg.sender);
        initializedAt = block.timestamp;
    }

	function getMaxDeposit(address _address) public view returns (uint256) {
        User memory user = users[_address];
        uint256 weeksPast = 1 + (block.timestamp - initializedAt) * 10 / SEC_IN_WEEK / 10;
        uint256 maxDepositSinceInitialisation = MAX_DEPOSIT_STEP * weeksPast;

        uint256 maxDeposit = min(maxDepositSinceInitialisation, 500 ether);

        if (maxDeposit == 0) maxDeposit = MAX_DEPOSIT_STEP;

        return maxDeposit - user.invested;
    }

    function createUserIfNotExist(address _address, address refer) private {
        
    	User memory user = users[_address];
        if (user.registeredAt == 0) {
            if (refer != address(0)) {
                require(users[refer].registeredAt > 0, "REFER NOT REGISTERED");
                users[refer].referals.push(_address);
				users[refer].referalsCount++;
            }
			

            user.invested = 0;
            user.investedCount = 0;
            user.payments = 0;
            user.paymentsCount = 0;
            // user.cashback = 0;
            user.referBonus = [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)];
            user.referBonusCount = [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)];
            user.registeredAt = block.timestamp;
            user.lastPayment = block.timestamp;
            // user.claimedAmount = 0;
            usersCount++;
            user.refer = payable(refer);

			users[_address] = user;

            emit Registration(refer, _address);
        }
        
    }

    function lastPayGift() public {
		if (lastPayTime > 0 && (block.timestamp - GIFT_TIMEOUT) > lastPayTime) {
			MasonVault(vaultAddress).sendGift(lastPayAddress);
			lastPayTime = 0;
			giftAmount = 0;
		}
	}

	function setMarketingAddress(address _address) public onlyOwner {
		marketingAddress = payable(_address);
	}

	function setDevAddress(address _address) public onlyOwner {
		devAddress = payable(_address);
	}

	function setVaultAddress(address _vaultAddress) external onlyOwner {
        require(_vaultAddress != address(0), "ZERO ADDRESS");
        
        vaultAddress = payable(_vaultAddress);
    }

	function withdraw() public {
		
		User storage user = users[msg.sender];

		//payment
		if (user.registeredAt > 0) {
			uint256 amount = 0;
			amount = user.invested * DIVIDENDS_PERCENT / RATIO_MULTIPLIER * (block.timestamp - user.lastPayment) / SEC_IN_24H;
			user.lastPayment = block.timestamp;
			if (amount > 0) {

				if (amount > address(this).balance) {
					amount = address(this).balance;
				}

				//payment user statistics
				user.paymentsCount++;
				user.payments += amount;

				//payment global statistics
				allPaymentsCount++;
				allPayments += amount;

				//payment operation
				emit Withdrawal(msg.sender, amount);
				payable(msg.sender).transfer(amount);

				uint256 fee = amount * DEV_FEE / RATIO_MULTIPLIER;

				payable(devAddress).transfer(fee);
			}
		}

	}

	function deposit(address payable refer) external payable {
		require(msg.value >= MIN_INVESTMENT, "value to invest must be >= 0.2 bnb");

        createUserIfNotExist(msg.sender, refer);

        lastPayGift();
        withdraw();

        User storage user = users[msg.sender];

		user.investedCount++;
		user.invested += msg.value;

		uint256 gift = msg.value * GIFT_PERCENT / RATIO_MULTIPLIER;

		giftAmount +=  gift;

		payable(vaultAddress).transfer(gift);

		lastPayAddress = payable(msg.sender);

		lastPayTime = block.timestamp;

		//investment global statistics
		allInvestCount++;
		allInvest += msg.value;

		//investment operation
		emit Investment(msg.sender, msg.value);

		//refer bonus

		User storage user_refer = user;
		uint256 sum = 0;
		for(uint256 lvl = 0; lvl < REFER_BONUS_PERCENT.length; lvl++){
			sum = msg.value * REFER_BONUS_PERCENT[lvl] / RATIO_MULTIPLIER;
			if (user_refer.refer != address(0)) {
				if (getUserStatus(user_refer.refer) > lvl) {
					//refer bonus user statistics
					users[user_refer.refer].referBonusCount[lvl]++;
					users[user_refer.refer].referBonus[lvl] += sum;
					//refer bonus global statistics
					allReferBonus[lvl] += sum;
					allReferBonusCount[lvl]++;
					//refer bonus operation
					emit RefBonus(user_refer.refer, sum, msg.sender, lvl + 1);
					payable(address(user_refer.refer)).transfer(sum);

					sum = 0;
				}
				user_refer = users[user_refer.refer];
			}

			if (sum > 0) {
				adminRefSysPayment[lvl] += sum;
				adminRefSysPaymentCount[lvl]++;
				payable(owner()).transfer(sum);
			}
		}
		//marketing fee
	    uint256 fee = msg.value * MARKETING_FEE / RATIO_MULTIPLIER;
	    allMarketingPayments += fee;
		payable(marketingAddress).transfer(fee);


	}

	function getReferals(address _address) public view returns (address[] memory) {
		return users[_address].referals;
	}

	function getRefersBonus(address _address) public view returns (uint256[5] memory) {
		return users[_address].referBonus;
	}

	function getRefersBonusCount(address _address) public view returns (uint256[5] memory) {
		return users[_address].referBonusCount;
	}

	function getUserStatus(address user) public view returns (uint256){
		uint256 sum = 0;
		if (users[user].invested <= 0) {
			return 0;
		}
		for(uint256 lvl = 0; lvl < REFER_BONUS_PERCENT.length; lvl++) {
			sum += users[user].referBonus[lvl] * RATIO_MULTIPLIER / REFER_BONUS_PERCENT[lvl];
		}
		if (sum >= 300 ether) {
			return REFER_BONUS_PERCENT.length;
		}
		if (sum >= 150 ether) {
			return REFER_BONUS_PERCENT.length - 1;
		}
		return REFER_BONUS_PERCENT.length - 2;
	}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}