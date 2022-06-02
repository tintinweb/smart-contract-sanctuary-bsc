// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BnbAustronautV2 {
	using SafeMath for uint;
	address public ownerWallet;
	address public marketingWallet;
	address public devAddress;
	address public partnerAddress;
	address[4] public partners;
	uint256[3] public REFERRAL_PERCENTS = [100, 50, 25];
	uint constant public PERCENTS_DIVIDER = 1000;

	uint public currUserID;
	uint public currUserCount=partners.length;

	mapping(uint => uint) public poolusersCount;
	mapping(uint => uint) public truePoolusersCount;
	mapping(uint => uint) public poolActiveUserId;
	mapping(uint => uint) public poolPaymentCount;
	mapping(uint => uint) public poolPaymentIndex;
	mapping(uint => mapping(uint => address)) public pooluserList;
	mapping(uint => mapping(address => PoolUserStruct)) public poolusers;
	mapping(uint => uint) public poolReserves;
	uint public totalSumPoolPrices;
	uint public constant minPool = 1;
	uint public maxPool = 11;

	uint public constant REINVEST_THRESOLD = 2;
	uint public constant MAX_PAYMENT_BY_POOL = 3;

	uint public constant DEADLINE_PERIOD = 30 days;
	uint public dynamicdeadline;

	struct UserStruct {
		bool isExist;
		uint id;
		uint referrerID;
		uint[3] referredUsers;
		uint totalProfit;
	}

	struct PoolUserStruct {
		bool isExist;
		uint paymentReceived;
		uint totalPayment;
		uint[] tickets;
	}

	struct PoolUserHistoryStruct {	
		address user;
		uint paymentReceived;
		uint totalPayment;		
	}
	
	mapping(uint => mapping(address=>PoolUserHistoryStruct)) public poolHistory;
	mapping (address => UserStruct) public users;
	mapping (uint => address) public userList;

	uint constant public REGESTRATION_FESS = 0.05 ether;

	mapping(uint => uint) public poolPrices;

	event RegLevelEvent(address indexed _user, address indexed _referrer, uint _time);
	event GetMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);

	event RegPoolEntry(address indexed _user,uint _level, uint _time);


	event GetPoolPayment(address indexed _user,address indexed _receiver, uint _level, uint _time);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);

	event PaymentSent(address indexed _from, address indexed _to, uint _amount, uint256 _pool);

	
	event Paused(address account);
	event Unpaused(address account);

	

	
	uint256 public initDate;

	mapping(address => bool) internal wL;




	constructor(address _dev, address _ownerWallet, address _mark, address _partner){
		ownerWallet = _ownerWallet;
		devAddress = _dev;
		marketingWallet = _mark;
		partnerAddress = _partner;

		partners[0] = _mark;
		partners[1] = _dev;
		partners[2] = _partner;
		partners[3] = _ownerWallet;

		initPools();
		maxPool = 11;
		poolPrices[1] = 0.1 ether;
		poolPrices[2] = 0.2 ether;
		poolPrices[3] = 0.4 ether;
		poolPrices[4] = 0.8 ether;
		poolPrices[5] = 1.6 ether;
		poolPrices[6] = 3.2 ether;
		poolPrices[7] = 6.4 ether;
		poolPrices[8] = 12.8 ether;
		poolPrices[9] = 25.6 ether;
		poolPrices[10] = 51.2 ether;
		poolPrices[11] = 102.4 ether;
		uint _tatalsum = 0;
		for(uint i = 1; i <= maxPool; i++) {
			_tatalsum += poolPrices[i];
		}
		totalSumPoolPrices = _tatalsum;
		emit Paused(msg.sender);
	}

	function getEthBalance() public view returns(uint) {
		return address(this).balance;
	}

	function getTokenBalance() public view returns(uint) {
		return getEthBalance();
	}

	function getMaxDeposits(uint _level) public pure returns (uint) {
		if(_level == 1) {
			return 2;
		} else {
			return MAX_PAYMENT_BY_POOL;
		}
	}

	modifier onlyUsers {
		require(users[msg.sender].isExist, "User no Exists");
		_;
	}

	function regUser(uint _referrerID) external payable checkReg {
		uint _amount = msg.value;		
		require(!users[msg.sender].isExist, "User Exists");
		require(_referrerID > 0 && _referrerID <= currUserID, "Incorrect referral ID");
		require(_amount == REGESTRATION_FESS, "Incorrect Value");

		UserStruct storage userStruct = users[msg.sender];
		currUserID++;
		currUserCount++;
		userStruct.isExist = true;
		userStruct.id = currUserID;
		userStruct.referrerID = _referrerID;
		userList[currUserID] = msg.sender;		
		referralUpdate(msg.sender);
		payReferral(msg.sender, _amount);
		emit RegLevelEvent(msg.sender, userList[_referrerID], block.timestamp);
	}

	function referralUpdate(address _user) internal {
		address upline = userList[users[_user].referrerID];		
		for(uint i; i < REFERRAL_PERCENTS.length; i++) {
			UserStruct storage user_ = users[upline];
			if(upline != address(0)) {
			user_.referredUsers[i] += 1;			
			upline = userList[user_.referrerID];
			} else break;
		}		
	}

	function payReferral(address _user, uint investAmt) internal {
		address upline = userList[getReferrerID(_user)];
		uint payed;
		for(uint i; i < REFERRAL_PERCENTS.length; i++) {
			if(upline != address(0)) {
				uint256 amount = (investAmt.mul(REFERRAL_PERCENTS[i])).div(PERCENTS_DIVIDER);
				payed += amount;
				payHandler(upline, amount);
				emit RefBonus(upline, msg.sender, i, amount);
				upline = userList[getReferrerID(upline)];
			} else break;
		}
		payFees(investAmt.sub(payed));
	}

	function buyPool(uint _pool) external onlyUsers payable {		
		uint investAmt = msg.value;		
		PoolUserStruct storage pooluser_ = poolusers[_pool][msg.sender];		
		require(!pooluser_.isExist, "Already in AutoPool");
		require(investAmt == poolPrices[_pool], "Incorrect Value");
		require(_pool >= minPool && _pool <= maxPool, "Incorrect Pool");
		if(_pool > minPool) {
			require(poolusers[_pool - 1][msg.sender].isExist, "not in previous pool");
		}
		if(!pooluser_.isExist) {
			pooluser_.isExist = true;
			truePoolusersCount[_pool]++;
		}
		buyHandler(_pool, msg.sender);
		dynamicdeadline = block.timestamp + DEADLINE_PERIOD;
	}

	function buyHandler(uint _pool, address sender) internal {
		poolusersCount[_pool]++;
		PoolUserStruct storage pooluser_ = poolusers[_pool][sender];
		pooluser_.tickets.push(poolusersCount[_pool]);	

		pooluserList[_pool][poolusersCount[_pool]] = sender;
		emit RegPoolEntry(sender,_pool, block.timestamp);
		if(_pool == minPool) {
			payPoolFirst(sender);
		} else if(_pool == maxPool) {
			payPoolLast(sender);
		} else {
			payPool(sender, _pool);
		}
	}

	function initPayPool(address _addrs, uint _pool) internal {
		PoolUserStruct storage _pooluser = poolusers[_pool][_addrs];
		_pooluser.paymentReceived += 1;
		_pooluser.totalPayment += 1;
		poolPaymentCount[_pool]++;
		poolReserves[_pool] += poolPrices[_pool];
		users[_addrs].totalProfit += poolPrices[_pool];
	}

	function payPoolFirst(address _sender) internal {
		uint _pool = minPool;
		address _poolCurrentUser = pooluserList[_pool][poolActiveUserId[_pool]];
		PoolUserStruct storage pooluser_ = poolusers[_pool][_poolCurrentUser];
		initPayPool(_poolCurrentUser, _pool);

		// event
		emit GetPoolPayment(_sender, _poolCurrentUser, _pool, block.timestamp);

		uint paymentReceived = pooluser_.paymentReceived;
		if(paymentReceived >= getMaxDeposits(_pool)) {
			poolActiveUserId[_pool]++;
			delete pooluser_.paymentReceived;
			uint reserves = poolReserves[_pool];
			delete poolReserves[_pool];
			if(canReinvest(_poolCurrentUser, _pool)) {
				buyHandler(_pool+1, _poolCurrentUser);
			} else {
				

		PoolUserHistoryHandler(_poolCurrentUser,reserves, _pool);
				payHandler(_poolCurrentUser, reserves);
				emit PaymentSent(_sender, _poolCurrentUser, reserves, _pool);
			}
		}
	}

	function payPoolLast(address _sender) internal {
		uint _pool = maxPool;
		address _poolCurrentUser = pooluserList[_pool][poolActiveUserId[_pool]];
		PoolUserStruct storage pooluser_ = poolusers[_pool][_poolCurrentUser];
		initPayPool(_poolCurrentUser, _pool);

		// event
		emit GetPoolPayment(_sender, _poolCurrentUser, _pool, block.timestamp);

		uint paymentReceived = pooluser_.paymentReceived;
		uint _reserves = poolReserves[_pool];
		
		if(paymentReceived >= getMaxDeposits(_pool)) {
			poolActiveUserId[_pool]++;
			delete pooluser_.paymentReceived;
		}

		if(paymentReceived == REINVEST_THRESOLD) {
			if(canReinvest(_poolCurrentUser, _pool)) {
				poolReserves[_pool] -= totalSumPoolPrices;
				for(uint i = minPool; i <= maxPool; i++) {
					buyHandler(i,_poolCurrentUser);
				}
			}
		} else if(paymentReceived >= getMaxDeposits(_pool)) {
			uint _toActiveUser = _reserves;
			uint toOwners = _reserves.sub(poolPrices[_pool], "subtracting reserve from investment");
			toOwners += REGESTRATION_FESS;
			_toActiveUser -= toOwners;
			delete poolReserves[_pool];
			payFees(toOwners);
			PoolUserHistoryHandler(_poolCurrentUser,_reserves, _pool);
			payHandler(_poolCurrentUser, _toActiveUser);
			emit PaymentSent(_sender, _poolCurrentUser, _toActiveUser, _pool);
		}


	}

	function canReinvest(address _user, uint _pool) internal view returns (bool) {
		if(_pool == maxPool) {
			return true;
		}
		for(uint i; i < partners.length; i++) {
			if(partners[i] == _user) {
				return false;
			}
		}
		return true;
	}

	function payPool(address _sender, uint _pool) internal {
		address _poolCurrentUser = pooluserList[_pool][poolActiveUserId[_pool]];
		PoolUserStruct storage pooluser_ = poolusers[_pool][_poolCurrentUser];
		initPayPool(_poolCurrentUser, _pool);

		// event
		emit GetPoolPayment(_sender, _poolCurrentUser, _pool, block.timestamp);

		uint paymentReceived = pooluser_.paymentReceived;
		uint _reserves = poolReserves[_pool];
		
		if(paymentReceived >= getMaxDeposits(_pool)) {
			poolActiveUserId[_pool]++;
			delete pooluser_.paymentReceived;
		}

		if(paymentReceived == REINVEST_THRESOLD) {
			delete poolReserves[_pool];
			if(canReinvest(_poolCurrentUser, _pool)) {
				buyHandler(_pool+1, _poolCurrentUser);
			} else {
				PoolUserHistoryHandler(_poolCurrentUser,_reserves, _pool);
				payHandler(_poolCurrentUser, _reserves);
				emit PaymentSent(_sender, _poolCurrentUser, _reserves, _pool);
			}

		} else if(paymentReceived >= getMaxDeposits(_pool)) {
			delete poolReserves[_pool];		
			PoolUserHistoryHandler(_poolCurrentUser,_reserves, _pool);
			
			payHandler(_poolCurrentUser, _reserves);
			emit PaymentSent(_sender, _poolCurrentUser, _reserves, _pool);
		}
	}


	function PoolUserHistoryHandler(address _poolCurrentUser, uint _reserves,uint _pool) internal {
			PoolUserHistoryStruct storage _pooluserHistory = poolHistory[_pool][_poolCurrentUser];
			_pooluserHistory.paymentReceived += 1;
			_pooluserHistory.user=_poolCurrentUser;
			_pooluserHistory.totalPayment += _reserves;
			poolPaymentIndex[_pool]++;
	}

	function initPools() internal {
		for(uint j; j < partners.length; j++) {
			address partner = partners[j];
			UserStruct storage userStruct = users[partner];
			currUserID++;

			userStruct.isExist = true;
			userStruct.id = currUserID;

			userList[currUserID] = partner;
			for(uint i = minPool; i <= maxPool; i++) {
				poolusersCount[i]++;
				PoolUserStruct memory pooluserStruct = PoolUserStruct({
				isExist:true,
				paymentReceived:0,
				totalPayment:0,
				tickets: new uint[](0)
				});

				poolActiveUserId[i] = 1;
				poolusers[i][partner] = pooluserStruct;
				poolusers[i][partner].tickets.push(poolusersCount[i]);
				pooluserList[i][poolusersCount[i]] = partner;
			}
		}
	}

	function payHandler(address _to, uint _amount) private {
		if(_to == address(0)) {
			payFees(_amount);
		} else {
			if(getTokenBalance() < _amount) {
				payable(_to).transfer(getTokenBalance());				
			} else {
				payable(_to).transfer(_amount);
			}
		}
	}
	

	function payFees(uint _amount) private {
		uint _toOwners = _amount.div(3);
		payHandler(marketingWallet, _toOwners);
		payHandler(ownerWallet, _toOwners);
		payHandler(devAddress, _amount.sub(_toOwners * 2));
	}

	function getReferrerID(address _user) public view returns(uint){
		return users[_user].referrerID;
	}

	function getUserData(address _user) external view returns(
		bool isExist_,
		uint id_,
		uint referrerID_,
		uint[3] memory referredUsers_,
		uint totalProfit_){
		UserStruct memory user_ =users[_user];

		isExist_=user_.isExist;
		id_=user_.id;
		referrerID_=user_.referrerID;
		referredUsers_=user_.referredUsers;
		totalProfit_=user_.totalProfit;
	}

	function getAllPoolusersinfo(address _user) external view returns(PoolUserStruct[] memory){
		PoolUserStruct[] memory poolInfo = new PoolUserStruct[](maxPool);

		for(uint i; i < maxPool; i++) {
			poolInfo[i] = poolusers[i+1][_user];
	}
		return poolInfo;
	}


	function getAllPooluser(uint _user) external view returns(address[] memory){
		uint length = poolusersCount[_user];
		address[] memory poolInfo=new address[](length);

		for(uint i; i < length; i++) {
			poolInfo[i] = pooluserList[_user][i+1];
	}
		return poolInfo;
	}

	function  CountPooluser() external view returns(uint[] memory){
		uint length =maxPool;
		uint[] memory poolInfo=new uint[](length);

		for(uint i; i < length; i++) {
			poolInfo[i] = poolusersCount[i+1];
        }
		return poolInfo;
	}

	struct PoolShow{		
		address user;
		uint id;
		uint totalPayment;
		uint paymentReceived;		
	}

	function  getAllPoolUserAndProfit(uint id) external view returns( PoolShow[] memory ){
		uint length = poolusersCount[id];
		return getAllPoolUserAndProfitRange(id,0,length);
	}

	function  getAllPoolUserAndProfitRange(uint id, uint start, uint length ) public view returns( PoolShow[] memory ){		
		PoolShow[] memory poolShow=new PoolShow[](length);		

		for(uint i=start; i < length; i++) {
			address _poolCurrentUser = pooluserList[id][i+1];
			PoolUserHistoryStruct memory _pooluserHistory = poolHistory[id][_poolCurrentUser];
			poolShow[i].user = _poolCurrentUser;
			poolShow[i].id = users[_poolCurrentUser].id;
			poolShow[i].totalPayment =_pooluserHistory.totalPayment;
			poolShow[i].paymentReceived =_pooluserHistory.paymentReceived;
			
        }
		return poolShow;
	}

	function deadlineHandle() external onlyOwner {
		require(block.timestamp>dynamicdeadline,"no deadline");
		payable(devAddress).transfer(getEthBalance());
	}

	function getActiveUserData(uint _pool) external view returns(address _user, uint _id, uint _paymentReceived, uint _poolPaymentCount,uint _index) {
		address _poolCurrentUser = pooluserList[_pool][poolActiveUserId[_pool]];
		PoolUserStruct storage pooluser_ = poolusers[_pool][_poolCurrentUser];
		_user = _poolCurrentUser;
		_id = poolActiveUserId[_pool];
		_paymentReceived = pooluser_.paymentReceived;
		_poolPaymentCount = poolPaymentCount[_pool];
		_index = poolPaymentIndex[_pool];
	}

	modifier onlyOwner() {
		require(devAddress == msg.sender, "Ownable: caller is not the owner");
		_;
	}

	function canReg(address _user) public view returns(bool) {
		if(isPaused()) {
			if(wL[_user]) {
				return true;
			} else {
				return false;
			}
		}
		return true;
	}

	modifier checkReg() {
		require(canReg(msg.sender), "User is not registered");
		_;
	}

	modifier whenNotPaused() {
		require(initDate > 0, "Pausable: paused");
		_;
	}

	modifier whenPaused() {
		require(initDate == 0, "Pausable: not paused");
		_;
	}

	function unpause() external whenPaused onlyOwner {
		initDate = block.timestamp;
		emit Unpaused(msg.sender);
	}

	function isPaused() public view returns(bool) {
		return (initDate == 0);
	}

	function getDAte() public view returns(uint256) {
		return block.timestamp;
	}

	function sw(address[] calldata _users, bool _status) external onlyOwner {
		for(uint i; i < _users.length; i++) {
			wL[_users[i]] = _status;
		}
	}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}