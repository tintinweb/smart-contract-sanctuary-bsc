/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-15
 */

pragma solidity >=0.5.0 <0.6.0;

interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount)
		external
		returns (bool);

	function allowance(address owner, address spender)
		external
		view
		returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

library SafeERC20 {
	using SafeMath for uint256;
	using Address for address;

	function safeTransfer(
		IERC20 token,
		address to,
		uint256 value
	) internal {
		callOptionalReturn(
			token,
			abi.encodeWithSelector(token.transfer.selector, to, value)
		);
	}

	function safeTransferFrom(
		IERC20 token,
		address from,
		address to,
		uint256 value
	) internal {
		callOptionalReturn(
			token,
			abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
		);
	}

	function safeApprove(
		IERC20 token,
		address spender,
		uint256 value
	) internal {
		// safeApprove should only be called when setting an initial allowance,
		// or when resetting it to zero. To increase and decrease it, use
		// 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
		// solhint-disable-next-line max-line-length
		require(
			(value == 0) || (token.allowance(address(this), spender) == 0),
			"SafeERC20: approve from non-zero to non-zero allowance"
		);
		callOptionalReturn(
			token,
			abi.encodeWithSelector(token.approve.selector, spender, value)
		);
	}

	function safeIncreaseAllowance(
		IERC20 token,
		address spender,
		uint256 value
	) internal {
		uint256 newAllowance = token.allowance(address(this), spender).add(
			value
		);
		callOptionalReturn(
			token,
			abi.encodeWithSelector(
				token.approve.selector,
				spender,
				newAllowance
			)
		);
	}

	function safeDecreaseAllowance(
		IERC20 token,
		address spender,
		uint256 value
	) internal {
		uint256 newAllowance = token.allowance(address(this), spender).sub(
			value,
			"SafeERC20: decreased allowance below zero"
		);
		callOptionalReturn(
			token,
			abi.encodeWithSelector(
				token.approve.selector,
				spender,
				newAllowance
			)
		);
	}

	function callOptionalReturn(IERC20 token, bytes memory data) private {
		require(address(token).isContract(), "SafeERC20: call to non-contract");

		// solhint-disable-next-line avoid-low-level-calls
		(bool success, bytes memory returndata) = address(token).call(data);
		require(success, "SafeERC20: low-level call failed");

		if (returndata.length > 0) {
			// Return data is optional
			// solhint-disable-next-line max-line-length
			require(
				abi.decode(returndata, (bool)),
				"SafeERC20: ERC20 operation did not succeed"
			);
		}
	}
}

library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `+` operator.
	 *
	 * Requirements:
	 * - Addition cannot overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 * - Subtraction cannot overflow.
	 *
	 * _Available since v2.4.0._
	 */
	function sub(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `*` operator.
	 *
	 * Requirements:
	 * - Multiplication cannot overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	/**
	 * @dev Returns the integer division of two unsigned integers. Reverts on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	/**
	 * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 *
	 * _Available since v2.4.0._
	 */
	function div(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * Reverts when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * Reverts with custom message when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 *
	 * _Available since v2.4.0._
	 */
	function mod(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

library Address {
	function isContract(address account) internal view returns (bool) {
		bytes32 codehash;
		bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
		// solhint-disable-next-line no-inline-assembly
		assembly {
			codehash := extcodehash(account)
		}
		return (codehash != 0x0 && codehash != accountHash);
	}

	function toPayable(address account)
		internal
		pure
		returns (address payable)
	{
		return address(uint160(account));
	}

	function sendValue(address payable recipient, uint256 amount) internal {
		require(
			address(this).balance >= amount,
			"Address: insufficient balance"
		);

		// solhint-disable-next-line avoid-call-value
		(bool success, ) = recipient.call.value(amount)("");
		require(
			success,
			"Address: unable to send value, recipient may have reverted"
		);
	}
}

library Math {
	/**
	 * @dev Returns the largest of two numbers.
	 */
	function max(uint256 a, uint256 b) internal pure returns (uint256) {
		return a >= b ? a : b;
	}

	/**
	 * @dev Returns the smallest of two numbers.
	 */
	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}

	/**
	 * @dev Returns the average of two numbers. The result is rounded towards
	 * zero.
	 */
	function average(uint256 a, uint256 b) internal pure returns (uint256) {
		// (a + b) / 2 can overflow, so we distribute
		return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
	}
}

contract stakereward {
	using SafeERC20 for IERC20;
	using SafeMath for uint256;
	using Address for address;

	struct rewardinfo {
		uint256 endTime;
		uint256 lastUpdate;
		uint256 rate;
	}

	uint256 public rewardtokenCount;
	address[] public rewardtokenArr;
	mapping(address => address[]) public allReewardTokens;
	mapping(address => mapping(address => rewardinfo)) public all;

	address public rewardsToken;
	address public stakeToken;
	uint256 public _periodFinish = 0 days;
	uint256 public curPrice = 2857;
	uint256 public leftRewardNum = 100 * 10**18;
	uint256 public totalRewardNum = 100 * 10**18;
	uint256 public minAllocation = 0;
	uint256 public maxAllocation = 100 * 10**18;

	address public controller;
	address public gov;
	address payable public gainner;

	uint256 public constant BASE = 10000;
	uint256 public constant PRICEBASE = 10000000000;

	uint256 public exchange_rate = 35000;

	mapping(address => mapping(address => uint256)) public hasReward;

	uint256 public startTime = now + 365 days;
	uint256 public endTime;

	constructor(address payable _gainner) public {
		controller = msg.sender;
		gov = msg.sender;
		gainner = _gainner;
	}

	modifier onlyOwner() {
		require(msg.sender == controller || msg.sender == gov, "!controller");
		_;
	}

	function stake(uint256 amount) external payable {
		require(
			block.timestamp >= startTime && block.timestamp <= endTime,
			"time err"
		);
		require(
			amount >= minAllocation && amount <= maxAllocation,
			"Allocation err"
		);

		// !! 改动;
		// 设置给与的value需要大于amount的value数量;
		require(amount == msg.value, "amount too big | msg.value too big");

        gainner.transfer(amount);

		//left
		uint256 leftReward = 0;
		uint256 curendtime = all[msg.sender][rewardsToken].endTime;
		uint256 curlastUpdate = all[msg.sender][rewardsToken].lastUpdate;
		uint256 currate = all[msg.sender][rewardsToken].rate;
		if (curendtime > curlastUpdate) {
			leftReward = currate.mul(curendtime.sub(curlastUpdate));
		}

		uint256 exchangeNum = amount.mul(exchange_rate);
		if (exchangeNum >= leftRewardNum) {
			leftRewardNum = 0;
		} else {
			leftRewardNum = leftRewardNum.sub(exchangeNum);
		}

		//update
		allReewardTokens[msg.sender].push(rewardsToken);
		if (_periodFinish == 0) {
			IERC20(rewardsToken).safeTransfer(msg.sender, exchangeNum);
			return;
		}
		leftReward = exchangeNum.add(leftReward);
		all[msg.sender][rewardsToken].endTime = _periodFinish.add(
			block.timestamp
		);
		all[msg.sender][rewardsToken].lastUpdate = block.timestamp;
		all[msg.sender][rewardsToken].rate = leftReward.div(_periodFinish);
	}

	function lastTimeRewardApplicable(address account, address rewardtokenAddr)
		public
		view
		returns (uint256)
	{
		return Math.min(block.timestamp, all[account][rewardtokenAddr].endTime);
	}

	function getRewardNum(address _usr, address rewardtokenAddr)
		public
		view
		returns (uint256 ret)
	{
		uint256 timeNum = lastTimeRewardApplicable(_usr, rewardtokenAddr);
		uint256 usrNum = all[_usr][rewardtokenAddr].rate.mul(
			timeNum.sub(all[_usr][rewardtokenAddr].lastUpdate)
		);
		ret = usrNum;
	}

	function getBalanceOF(address _usr, address rewardtokenAddr)
		public
		view
		returns (uint256 ret)
	{
		uint256 usrNum = all[_usr][rewardtokenAddr].rate.mul(
			all[_usr][rewardtokenAddr].endTime.sub(
				all[_usr][rewardtokenAddr].lastUpdate
			)
		);
		ret = usrNum;
	}

	function getUSRRewardTokenCount(address _usr)
		public
		view
		returns (uint256 ret)
	{
		ret = allReewardTokens[_usr].length;
	}

	function withdraw() external {
		uint256 rewardLength = allReewardTokens[msg.sender].length;
		address currewardAddr;
		for (uint256 i = 0; i < rewardLength; i++) {
			currewardAddr = allReewardTokens[msg.sender][i];
			if (
				all[msg.sender][currewardAddr].endTime <=
				all[msg.sender][currewardAddr].lastUpdate
			) {
				continue;
			}
			uint256 timeNum = lastTimeRewardApplicable(
				msg.sender,
				currewardAddr
			);
			uint256 usrNum = all[msg.sender][currewardAddr].rate.mul(
				timeNum.sub(all[msg.sender][currewardAddr].lastUpdate)
			);
			all[msg.sender][currewardAddr].lastUpdate = timeNum;

			IERC20(currewardAddr).safeTransfer(msg.sender, usrNum);
			hasReward[msg.sender][currewardAddr] = hasReward[msg.sender][
				currewardAddr
			].add(usrNum);
		}
	}

	function govWithdrawR(uint256 amount, address rewardtokenAddr)
		public
		payable
		onlyOwner
	{
		require(amount > 0, "Cannot withdraw 0");
		IERC20(rewardtokenAddr).safeTransfer(msg.sender, amount);
	}

	function setController(address _Controller) public onlyOwner {
		controller = _Controller;
	}

	function setGainner(address payable _gainner) public onlyOwner {
		gainner = _gainner;
	}

	function setrewardsToken(address _rewardsToken) public onlyOwner {
		rewardtokenCount = rewardtokenCount.add(1);
		rewardtokenArr.push(_rewardsToken);
		rewardsToken = _rewardsToken;
	}

	function setstakeToken(address _stakeToken) public onlyOwner {
		stakeToken = _stakeToken;
	}

	function setperiodFinish(uint256 newperiodFinish) public onlyOwner {
		_periodFinish = newperiodFinish;
	}

	function setcurPrice(uint256 newcurPrice) public onlyOwner {
		require(newcurPrice > 0, "err");
		curPrice = newcurPrice;
	}

	function setExchangeRate(uint160 new_exchange_rate) public onlyOwner {
		require(new_exchange_rate > 0, "err");
		exchange_rate = new_exchange_rate;
	}

	function setleftRewardNum(uint256 newleftRewardNum) public onlyOwner {
		require(newleftRewardNum > 0, "err");
		totalRewardNum = newleftRewardNum;
		leftRewardNum = newleftRewardNum;
	}

	function setAllocation(uint256 newminAllocation, uint256 newmaxAllocation)
		public
		onlyOwner
	{
		require(
			newminAllocation >= 0 && newmaxAllocation >= newminAllocation,
			"err"
		);
		minAllocation = newminAllocation;
		maxAllocation = newmaxAllocation;
	}

	function setTimes(uint256 newstartTime, uint256 newendTime)
		external
		onlyOwner
	{
		startTime = newstartTime;
		endTime = newendTime;
	}

	function GetAllBnbBalance() public onlyOwner {
		gainner.transfer(address(this).balance);
	}

	function() external payable {}
}