/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

pragma solidity 0.5.8;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
	// Empty internal constructor, to prevent people from mistakenly deploying
	// an instance of this contract, which should be used via inheritance.
	constructor() internal {}
	// solhint-disable-previous-line no-empty-blocks

	function _msgSender() internal view returns (address) {
		return msg.sender;
	}
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
	address private _owner;

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor () internal {
		_owner = _msgSender();
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(isOwner(), "Ownable: caller is not the owner");
		_;
	}

	/**
	 * @dev Returns true if the caller is the current owner.
	 */
	function isOwner() public view returns (bool) {
		return _msgSender() == _owner;
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		_owner = newOwner;
	}
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
	struct Role {
		mapping(address => bool) bearer;
	}

	/**
	 * @dev Give an account access to this role.
	 */
	function add(Role storage role, address account) internal {
		require(!has(role, account), "Roles: account already has role");
		role.bearer[account] = true;
	}

	/**
	 * @dev Remove an account's access to this role.
	 */
	function remove(Role storage role, address account) internal {
		require(has(role, account), "Roles: account does not have role");
		role.bearer[account] = false;
	}

	/**
	 * @dev Check if an account has this role.
	 * @return bool
	 */
	function has(Role storage role, address account) internal view returns (bool) {
		require(account != address(0), "Roles: account is the zero address");
		return role.bearer[account];
	}
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole is Context, Ownable {
	using Roles for Roles.Role;

	Roles.Role private _whitelistAdmins;

	constructor () internal {
	}

	modifier onlyWhitelistAdmin() {
		require(isWhitelistAdmin(_msgSender()) || isOwner(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
		_;
	}

	function isWhitelistAdmin(address account) public view returns (bool) {
		return _whitelistAdmins.has(account) || isOwner();
	}

	function addWhitelistAdmin(address account) public onlyOwner {
		_whitelistAdmins.add(account);
	}

	function removeWhitelistAdmin(address account) public onlyOwner {
		_whitelistAdmins.remove(account);
	}
}

contract TRC20 {
    function totalSupply() public view returns (uint theTotalSupply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract BigWin is WhitelistAdminRole {
	using SafeMath for *;
	// uint ethWei = 1 ether;
	uint unit100     = 100 * (10 ** 6);
	uint usd500      = 500 * (10 ** 6);
	uint usd1000     = 1000 * (10 ** 6);
	uint usd1100     = 1100 * (10 ** 6);
	uint usd2000     = 2000 * (10 ** 6);
	uint usd2100     = 2100 * (10 ** 6);
	uint usd3000     = 3000 * (10 ** 6);
	uint usd20000    = 20000 * (10 ** 6);

	address payable private devAddr = address(0xd039499e92af2067170b26062747D25b65f85012);
	address payable private comfortAddr = address(0xd039499e92af2067170b26062747D25b65f85012);
	address public usdtAddr = address(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C);

	struct User {
		uint id;
		address userAddress;
		uint freeAmount;
		uint freezeAmount;
		uint lineAmount;
		uint inviteAmonut;
		uint dayBonusAmount;
		uint bonusAmount;
		uint level;
		uint lineLevel;
		uint resTime;
		uint investTimes;
		string inviteCode;
		string beCode;
		uint rewardIndex;
		uint lastRwTime;
	}

	struct UserGlobal {
		uint id;
		address userAddress;
		string inviteCode;
		string beCode;
		uint status;
	}

	struct AwardData {
		uint oneInvAmount;
		uint twoInvAmount;
		uint threeInvAmount;
	}

	uint startTime;
	uint lineStatus = 0;
	mapping(uint => uint) rInvestCount;
	mapping(uint => uint) rInvestMoney;
	uint period = 1 days;
	uint uid = 0;
	uint rid = 1;
	mapping(uint => uint[]) lineArrayMapping;
	mapping(uint => mapping(address => User)) userRoundMapping;
	mapping(address => UserGlobal) userMapping;
	mapping(string => address) addressMapping;
	mapping(uint => address) indexMapping;
	mapping(uint => mapping(address => mapping(uint => AwardData))) userAwardDataMapping;
	uint bonuslimit = 3000 * (10 ** 6); // 15 ether;
	uint sendLimit = 20000 * (10 ** 6); // 100 ether;
	uint withdrawLimit = 3000 * (10 ** 6); // 15 ether;
	uint canImport = 1;
	uint canSetStartTime = 1;

	modifier isHuman() {
		address addr = msg.sender;
		uint codeLength;
		assembly {codeLength := extcodesize(addr)}
		require(codeLength == 0, "sorry humans only");
		require(tx.origin == msg.sender, "sorry, humans only");
		_;
	}

	constructor () public {
	}

	function() external payable {
	}

	function setUSDTAddr(address addr) public onlyOwner {
		usdtAddr = addr;
	}

	function getLevel(uint value) public view returns (uint) {
		if (value >= usd500 && value <= usd1000) {
			return 1;
		}
		if (value >= usd1100 && value <= usd2000) {
			return 2;
		}
		if (value >= usd2100 && value <= usd3000) {
			return 3;
		}
		return 0;
	}

	function getNodeLevel(uint value) public view returns (uint) {
		if (value >= usd500 && value <= usd1000) {
			return 1;
		}
		if (value >= usd1100 && value <= usd2000) {
			return 2;
		}
		if (value >= usd3000) {
			return 3;
		}
		return 0;
	}

	function getScByLevel(uint level) public pure returns (uint) {
		if (level == 1) {
			return 5;
		}
		if (level == 2) {
			return 7;
		}
		if (level == 3) {
			return 10;
		}
		return 0;
	}

	function getFireScByLevel(uint level) public pure returns (uint) {
		if (level == 1) {
			return 3;
		}
		if (level == 2) {
			return 6;
		}
		if (level == 3) {
			return 10;
		}
		return 0;
	}

	function getRecommendScaleByLevelAndTim(uint level, uint times) public pure returns (uint){
		if (level == 1 && times == 1) {
			return 40;
		}
		if (level == 2 && times == 1) {
			return 60;
		}
		if (level == 2 && times == 2) {
			return 40;
		}
		if (level == 3) {
			if (times == 1) {
				return 90;
			}
			if (times == 2) {
				return 60;
			}
			if (times == 3) {
				return 40;
			}
			if (times >= 4 && times <= 10) {
				return 8;
			}
			if (times >= 11 && times <= 20) {
				return 4;
			}
			if (times >= 21) {
				return 1;
			}
		}
		return 0;
	}

	function compareStr(string memory _str, string memory str) public pure returns (bool) {
		if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
			return true;
		}
		return false;
	}

	function verydangerous(uint time) external onlyOwner {
		require(canSetStartTime == 1, "verydangerous, limited!");
		require(time > now, "no, verydangerous");
		startTime = time;
		canSetStartTime = 0;
	}

	function donnotimitate() public view returns (bool) {
		return startTime != 0 && now > startTime;
	}

	function updateLine(uint line) external onlyWhitelistAdmin {
		lineStatus = line;
	}

	function isLine() private view returns (bool) {
		return lineStatus != 0;
	}

	function actAllLimit(uint bonusLi, uint sendLi, uint withdrawLi) external onlyOwner {
		// require(bonusLi >= 15 ether && sendLi >= 100 ether && withdrawLi >= 15 ether, "invalid amount");
		require(bonusLi >= usd3000 && sendLi >= usd20000 && withdrawLi >= usd3000, "invalid amount");
		bonuslimit = bonusLi;
		sendLimit = sendLi;
		withdrawLimit = withdrawLi;
	}

	function stopImport() external onlyOwner {
		canImport = 0;
	}

	function actUserStatus(address addr, uint status) external onlyWhitelistAdmin {
		require(status == 0 || status == 1 || status == 2, "bad parameter status");
		UserGlobal storage userGlobal = userMapping[addr];
		userGlobal.status = status;
	}

	function transferInvestAmount(uint amt) private {
		require(amt >= usd500 && amt <= usd3000, "between 1000 USDT and 3000 USDT");
		require(amt == amt.div(unit100).mul(unit100), "must be multor of 100 USDT");
		TRC20(usdtAddr).transferFrom(msg.sender, address(this), amt);
	}

	function deposit(uint amt, string memory inviteCode, string memory beCode) public isHuman() {
		require(donnotimitate(), "no, donnotimitate");
		// require(msg.value >= 1 * ethWei && msg.value <= 15 * ethWei, "between 1 and 15");
		// require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");
		transferInvestAmount(amt);

		UserGlobal storage userGlobal = userMapping[msg.sender];
		if (userGlobal.id == 0) {
			require(!compareStr(inviteCode, "") && bytes(inviteCode).length == 6, "invalid invite code");
			address beCodeAddr = addressMapping[beCode];
			require(isUsed(beCode), "beCode not exist");
			require(beCodeAddr != msg.sender, "beCodeAddr can't be self");
			require(!isUsed(inviteCode), "invite code is used");
			registerUser(msg.sender, inviteCode, beCode);
		}
		uint investAmout;
		uint lineAmount;
		if (isLine()) {
			lineAmount = amt; // msg.value;
		} else {
			investAmout = amt; // msg.value;
		}
		User storage user = userRoundMapping[rid][msg.sender];
		if (user.id != 0) {
			require(user.freezeAmount.add(user.lineAmount) == 0, "only once invest");
			user.freezeAmount = investAmout;
			user.lineAmount = lineAmount;
			user.level = getLevel(user.freezeAmount);
			user.lineLevel = getNodeLevel(user.freezeAmount.add(user.freeAmount).add(user.lineAmount));
		} else {
			user.id = userGlobal.id;
			user.userAddress = msg.sender;
			user.freezeAmount = investAmout;
			user.level = getLevel(investAmout);
			user.lineAmount = lineAmount;
			user.lineLevel = getNodeLevel(user.freezeAmount.add(user.freeAmount).add(user.lineAmount));
			user.inviteCode = userGlobal.inviteCode;
			user.beCode = userGlobal.beCode;
		}

		rInvestCount[rid] = rInvestCount[rid].add(1);
		rInvestMoney[rid] = rInvestMoney[rid].add(amt);
		if (!isLine()) {
			sendFeetoAdmin(amt);
			countBonus(user.userAddress);
		} else {
			lineArrayMapping[rid].push(user.id);
		}
	}

	function importGlobal(address addr, string calldata inviteCode, string calldata beCode) external onlyWhitelistAdmin {
		require(canImport == 1, "import stopped");
		UserGlobal storage user = userMapping[addr];
		require(user.id == 0, "user already exists");
		require(!compareStr(inviteCode, ""), "empty invite code");
		if (uid != 0) {
			require(!compareStr(beCode, ""), "empty beCode");
		}
		address beCodeAddr = addressMapping[beCode];
		require(beCodeAddr != addr, "beCodeAddr can't be self");
		require(!isUsed(inviteCode), "invite code is used");

		registerUser(addr, inviteCode, beCode);
	}

	function helloworld(uint start, uint end, uint isUser) external onlyWhitelistAdmin {
		for (uint i = start; i <= end; i++) {
			uint userId = 0;
			if (isUser == 0) {
				userId = lineArrayMapping[rid][i];
			} else {
				userId = i;
			}
			address userAddr = indexMapping[userId];
			User storage user = userRoundMapping[rid][userAddr];
			if (user.freezeAmount == 0 && user.lineAmount >= usd500 && user.lineAmount <= usd3000) {
				user.freezeAmount = user.lineAmount;
				user.level = getLevel(user.freezeAmount);
				user.lineAmount = 0;
				sendFeetoAdmin(user.freezeAmount);
				countBonus(user.userAddress);
			}
		}
	}

	function countBonus(address userAddr) private {
		User storage user = userRoundMapping[rid][userAddr];
		if (user.id == 0) {
			return;
		}
		uint scale = getScByLevel(user.level);
		user.dayBonusAmount = user.freezeAmount.mul(scale).div(1000);
		user.investTimes = 0;
		UserGlobal memory userGlobal = userMapping[userAddr];
		// if (user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit && userGlobal.status == 0) {
		if (user.freezeAmount >= usd500 && user.freezeAmount <= bonuslimit && userGlobal.status == 0) {
			getaway(user.beCode, user.freezeAmount, scale);
		}
	}

	function getaway(string memory beCode, uint money, uint shareSc) private {
		string memory tmpReferrer = beCode;

		for (uint i = 1; i <= 25; i++) {
			if (compareStr(tmpReferrer, "")) {
				break;
			}
			address tmpUserAddr = addressMapping[tmpReferrer];
			UserGlobal storage userGlobal = userMapping[tmpUserAddr];
			User storage calUser = userRoundMapping[rid][tmpUserAddr];

			if (calUser.freezeAmount.add(calUser.freeAmount).add(calUser.lineAmount) == 0) {
				tmpReferrer = userGlobal.beCode;
				continue;
			}

			// uint recommendSc = getRecommendScaleByLevelAndTim(3, i);
			uint recommendSc = getRecommendScaleByLevelAndTim(calUser.level, i);
			uint moneyResult = 0;
			// if (money <= 15 ether) {
			if (money <= usd3000) {
				moneyResult = money;
			} else {
				// moneyResult = 15 ether;
				moneyResult = usd3000;
			}

			if (recommendSc != 0) {
				uint tmpDynamicAmount = moneyResult.mul(shareSc).mul(recommendSc);
				tmpDynamicAmount = tmpDynamicAmount.div(1000).div(100);
				earneth(userGlobal.userAddress, tmpDynamicAmount, calUser.rewardIndex, i);
			}
			tmpReferrer = userGlobal.beCode;
		}
	}

	function earneth(address userAddr, uint dayInvAmount, uint rewardIndex, uint times) private {
		for (uint i = 0; i < 5; i++) {
			AwardData storage awData = userAwardDataMapping[rid][userAddr][rewardIndex.add(i)];
			if (times == 1) {
				awData.oneInvAmount += dayInvAmount;
			}
			if (times == 2) {
				awData.twoInvAmount += dayInvAmount;
			}
			awData.threeInvAmount += dayInvAmount;
		}
	}

	function happy() public isHuman() {
		require(donnotimitate(), "no donnotimitate");
		User storage user = userRoundMapping[rid][msg.sender];
		require(user.id != 0, "user not exist");
		uint sendMoney = user.freeAmount + user.lineAmount;
		bool isEnough = false;
		uint resultMoney = 0;

		(isEnough, resultMoney) = isEnoughBalance(sendMoney);

		if (resultMoney > 0 && resultMoney <= withdrawLimit) {
			sendMoneyToUser(msg.sender, resultMoney);
			user.freeAmount = 0;
			user.lineAmount = 0;
			user.lineLevel = getNodeLevel(user.freezeAmount);
		}
	}

	function christmas(uint start, uint end) external onlyWhitelistAdmin {
		for (uint i = start; i <= end; i++) {
			address userAddr = indexMapping[i];
			User storage user = userRoundMapping[rid][userAddr];
			UserGlobal memory userGlobal = userMapping[userAddr];
			if (now.sub(user.lastRwTime) <= 12 hours) {
				continue;
			}
			user.lastRwTime = now;
			if (userGlobal.status == 1) {
				user.rewardIndex = user.rewardIndex.add(1);
				continue;
			}
			uint bonusSend = 0;
			// if (user.id != 0 && user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit) {
			if (user.id != 0 && user.freezeAmount >= usd500 && user.freezeAmount <= bonuslimit) {
				if (user.investTimes < 5) {
					bonusSend += user.dayBonusAmount;
					user.bonusAmount = user.bonusAmount.add(bonusSend);
					user.investTimes = user.investTimes.add(1);
				} else {
					user.freeAmount = user.freeAmount.add(user.freezeAmount);
					user.freezeAmount = 0;
					user.dayBonusAmount = 0;
					user.level = 0;
				}
			}
			uint lineAmount = user.freezeAmount.add(user.freeAmount).add(user.lineAmount);
			// if (lineAmount < 1 ether || lineAmount > withdrawLimit) {
			if (lineAmount < usd500 || lineAmount > withdrawLimit) {
				user.rewardIndex = user.rewardIndex.add(1);
				continue;
			}
			uint inviteSend = 0;
			if (userGlobal.status == 0) {
				AwardData memory awData = userAwardDataMapping[rid][userAddr][user.rewardIndex];
				user.rewardIndex = user.rewardIndex.add(1);
				uint lineValue = lineAmount.div(unit100).div(2);
				if (lineValue >= 15) {
					inviteSend += awData.threeInvAmount;
				} else {
					// if (user.lineLevel == 1 && lineAmount >= 1 ether && awData.oneInvAmount > 0) {
					if (user.lineLevel == 1 && lineAmount >= usd500 && awData.oneInvAmount > 0) {
						inviteSend += awData.oneInvAmount.div(15).mul(lineValue).div(2);
					}
					// if (user.lineLevel == 2 && lineAmount >= 6 ether && (awData.oneInvAmount > 0 || awData.twoInvAmount > 0)) {
					if (user.lineLevel == 2 && lineAmount >= usd1000 && (awData.oneInvAmount > 0 || awData.twoInvAmount > 0)) {
						inviteSend += awData.oneInvAmount.div(15).mul(lineValue).mul(7).div(10);
						inviteSend += awData.twoInvAmount.div(15).mul(lineValue).mul(5).div(7);
					}
					// if (user.lineLevel == 3 && lineAmount >= 11 ether && awData.threeInvAmount > 0) {
					if (user.lineLevel == 3 && lineAmount >= usd2100 && awData.threeInvAmount > 0) {
						inviteSend += awData.threeInvAmount.div(15).mul(lineValue);
					}
					if (user.lineLevel < 3) {
						uint fireSc = getFireScByLevel(user.lineLevel);
						inviteSend = inviteSend.mul(fireSc).div(10);
					}
				}
			} else if (userGlobal.status == 2) {
				user.rewardIndex = user.rewardIndex.add(1);
			}

			if (bonusSend.add(inviteSend) <= sendLimit) {
				user.inviteAmonut = user.inviteAmonut.add(inviteSend);
				bool isEnough = false;
				uint resultMoney = 0;
				(isEnough, resultMoney) = isEnoughBalance(bonusSend.add(inviteSend));
				if (resultMoney > 0) {
					uint comfortMoney = resultMoney.div(10);
					sendMoneyToUser(comfortAddr, comfortMoney);
					resultMoney = resultMoney.sub(comfortMoney);
					address sendAddr = address((userAddr));
					sendMoneyToUser(sendAddr, resultMoney);
				}
			}
		}
	}

	function isEnoughBalance(uint sendMoney) private view returns (bool, uint){
		if (sendMoney >= address(this).balance) {
			return (false, address(this).balance);
		} else {
			return (true, sendMoney);
		}
	}

	function sendFeetoAdmin(uint amount) private {
		// devAddr.transfer(amount.div(25));
		TRC20(usdtAddr).transfer(devAddr, amount.div(25));
	}

	function sendMoneyToUser(address userAddress, uint money) private {
		if (money > 0) {
			// userAddress.transfer(money);
			TRC20(usdtAddr).transfer(userAddress, money);
		}
	}

	function isUsed(string memory code) public view returns (bool) {
		address addr = addressMapping[code];
		return uint(addr) != 0;
	}

	function getUserAddressByCode(string memory code) public view returns (address) {
		require(isWhitelistAdmin(msg.sender), "Permission denied");
		return addressMapping[code];
	}

	function registerUser(address addr, string memory inviteCode, string memory beCode) private {
		UserGlobal storage userGlobal = userMapping[addr];
		uid++;
		userGlobal.id = uid;
		userGlobal.userAddress = addr;
		userGlobal.inviteCode = inviteCode;
		userGlobal.beCode = beCode;

		addressMapping[inviteCode] = addr;
		indexMapping[uid] = addr;
	}

	/// @dev usdt balance of address(this)
	function usdtbalance() public view returns (uint) {
		return TRC20(usdtAddr).balanceOf(address(this));
	}

	function endRound() external onlyOwner {
		require(usdtbalance() < usd500, "contract balance must be lower than 500 usdt");
		rid++;
		startTime = now.add(period).div(1 days).mul(1 days);
		canSetStartTime = 1;
	}

	function donnottouch() public view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
		return (
		rid,
		uid,
		startTime,
		rInvestCount[rid],
		rInvestMoney[rid],
		bonuslimit,
		sendLimit,
		withdrawLimit,
		canImport,
		lineStatus,
		lineArrayMapping[rid].length,
		canSetStartTime
		);
	}

	function getUserByAddress(address addr, uint roundId) public view returns (uint[14] memory info, string memory inviteCode, string memory beCode) {
		require(isWhitelistAdmin(msg.sender) || msg.sender == addr, "Permission denied for view user's privacy");

		if (roundId == 0) {
			roundId = rid;
		}

		UserGlobal memory userGlobal = userMapping[addr];
		User memory user = userRoundMapping[roundId][addr];
		info[0] = userGlobal.id;
		info[1] = user.lineAmount;
		info[2] = user.freeAmount;
		info[3] = user.freezeAmount;
		info[4] = user.inviteAmonut;
		info[5] = user.bonusAmount;
		info[6] = user.lineLevel;
		info[7] = user.dayBonusAmount;
		info[8] = user.rewardIndex;
		info[9] = user.investTimes;
		info[10] = user.level;
		uint grantAmount = 0;
		// if (user.id > 0 && user.freezeAmount >= 1 ether && user.freezeAmount <= bonuslimit && 
		// 		user.investTimes < 5 && userGlobal.status != 1) {
		if (user.id > 0 && user.freezeAmount >= usd500 && user.freezeAmount <= bonuslimit && 
				user.investTimes < 5 && userGlobal.status != 1) {
			grantAmount += user.dayBonusAmount;
		}
		if (userGlobal.status == 0) {
			uint inviteSend = 0;
			AwardData memory awData = userAwardDataMapping[rid][user.userAddress][user.rewardIndex];
			uint lineAmount = user.freezeAmount.add(user.freeAmount).add(user.lineAmount);
			if (lineAmount >= usd500) {
				uint lineValue = lineAmount.div(unit100).div(2);
				if (lineValue >= 15) {
					inviteSend += awData.threeInvAmount;
				} else {
					// if (user.lineLevel == 1 && lineAmount >= 1 ether && awData.oneInvAmount > 0) {
					if (user.lineLevel == 1 && lineAmount >= usd500 && awData.oneInvAmount > 0) {
						inviteSend += awData.oneInvAmount.div(15).mul(lineValue).div(2);
					}
					if (user.lineLevel == 2 && lineAmount >= usd500 && (awData.oneInvAmount > 0 || awData.twoInvAmount > 0)) {
						inviteSend += awData.oneInvAmount.div(15).mul(lineValue).mul(7).div(10);
						inviteSend += awData.twoInvAmount.div(15).mul(lineValue).mul(5).div(7);
					}
					if (user.lineLevel == 3 && lineAmount >= usd500 && awData.threeInvAmount > 0) {
						inviteSend += awData.threeInvAmount.div(15).mul(lineValue);
					}
					if (user.lineLevel < 3) {
						uint fireSc = getFireScByLevel(user.lineLevel);
						inviteSend = inviteSend.mul(fireSc).div(10);
					}
				}
				grantAmount += inviteSend;
			}
		}
		info[11] = grantAmount;
		info[12] = user.lastRwTime;
		info[13] = userGlobal.status;

		return (info, userGlobal.inviteCode, userGlobal.beCode);
	}

	function getUserAddressById(uint id) public view returns (address) {
		require(isWhitelistAdmin(msg.sender), "Permission denied");
		return indexMapping[id];
	}

	function getLineUserId(uint index, uint rouId) public view returns (uint) {
		require(isWhitelistAdmin(msg.sender), "Permission denied");
		if (rouId == 0) {
			rouId = rid;
		}
		return lineArrayMapping[rid][index];
	}
}

/**
* @title SafeMath
* @dev Math operations with safety checks that revert on error
*/
library SafeMath {
	/**
	* @dev Multiplies two numbers, reverts on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "mul overflow");

		return c;
	}

	/**
	* @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0, "div zero");
		// Solidity only automatically asserts when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a, "lower sub bigger");
		uint256 c = a - b;

		return c;
	}

	/**
	* @dev Adds two numbers, reverts on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "overflow");

		return c;
	}

	/**
	* @dev Divides two numbers and returns the remainder (unsigned integer modulo),
	* reverts when dividing by zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0, "mod zero");
		return a % b;
	}

	/**
	* @dev compare two numbers and returns the smaller one.
	*/
	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a > b ? b : a;
	}
}